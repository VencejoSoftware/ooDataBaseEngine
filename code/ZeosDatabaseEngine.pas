{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database engine connection based in ZEOSLib components
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ZeosDatabaseEngine;

interface

uses
  SysUtils,
  DB,
  ZConnection, ZDataset, ZDbcIntfs,
  ConnectionSetting,
  Statement,
  CryptedCredential,
  ExecutionResult, FailedExecution, SuccededExecution, DatasetExecution,
  DatabaseEngine;

type
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseEngine))
  Zeos database connection
  @member(InTransaction @seealso(IDatabaseEngine.InTransaction))
  @member(BeginTransaction @seealso(IDatabaseEngine.BeginTransaction))
  @member(CommitTransaction @seealso(IDatabaseEngine.CommitTransaction))
  @member(RollbackTransaction @seealso(IDatabaseEngine.RollbackTransaction))
  @member(Connect @seealso(IDatabaseEngine.Connect))
  @member(Disconnect @seealso(IDatabaseEngine.Disconnect))
  @member(IsConnected @seealso(IDatabaseEngine.IsConnected))
  @member(Execute @seealso(IDatabaseEngine.Execute))
  @member(ExecuteReturning @seealso(IDatabaseEngine.ExecuteReturning))
  @member(ExecuteScript @seealso(IDatabaseEngine.ExecuteScript))
  @member(
    ExecuteTransactionStatement Execute a context transaction statement
    @param(Statement @link(IStatement Statement object))
    @param(Kind Transaction action kind)
    @return(@link(IExecutionResult Execution result object))
  )
  @member(
    ExecuteDirect Executes a statment object directly, optimized for speed
    @param(Statement @link(IStatement Statement object))
    @return(@link(IExecutionResult Execution result object));
  )
  @member(
    ExecutePreparing Prepare and execute a statement
    @param(Statement @link(IStatement Statement object))
    @return(@link(IExecutionResult Execution result object));
  )
  @member(Create Object constructor)
  @member(Destroy Object destructor)
  @member(New Create a new @classname as interface)
}
{$ENDREGION}
  TZeosEngine = class(TInterfacedObject, IDatabaseEngine)
  strict private
    _Database: TZConnection;
  private
    function ExecuteTransactionStatement(const Statement: IStatement; const Kind: TStatementKind): IExecutionResult;
    function ExecuteDirect(const Statement: IStatement): IExecutionResult;
    function ExecutePreparing(const Statement: IStatement): IExecutionResult;
  protected
    property Database: TZConnection read _Database;
  public
    function InTransaction: Boolean;
    function BeginTransaction: Boolean;
    function CommitTransaction: Boolean;
    function RollbackTransaction: Boolean;
    function Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean; virtual;
    function Disconnect: Boolean;
    function IsConnected: Boolean;
    function Execute(const Statement: IStatement; const UseGlobalTransaction: Boolean): IExecutionResult;
    function ExecuteReturning(const Statement: IStatement; const CommitData: Boolean;
      const UseGlobalTransaction: Boolean): IExecutionResult; virtual;
    function ExecuteScript(const StatementList: IStatementList; const SkipErrors: Boolean = False)
      : IExecutionResultList;
    constructor Create;
    destructor Destroy; override;
    class function New: IDatabaseEngine;
  end;

implementation

function TZeosEngine.InTransaction: Boolean;
begin
  Result := _Database.InTransaction;
end;

function TZeosEngine.BeginTransaction: Boolean;
begin
  if not InTransaction then
    _Database.StartTransaction;
  Result := True;
end;

function TZeosEngine.CommitTransaction: Boolean;
begin
  if InTransaction then
    _Database.Commit;
  Result := True;
end;

function TZeosEngine.RollbackTransaction: Boolean;
begin
  if InTransaction then
    _Database.RollBack;
  Result := True;
end;

function TZeosEngine.Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean;
begin
  if Assigned(Setting.Credential) then
  begin
    Database.User := Setting.Credential.User;
    if Supports(Setting.Credential, ICryptedCredential) then
      Database.Password := (Setting.Credential as ICryptedCredential).RevealPassword(PasswordKey)
    else
      Database.Password := Setting.Credential.Password;
  end;
  Database.TransactIsolationLevel := tiReadCommitted;
  Database.LibraryLocation := Setting.LibraryPath;
  Database.Database := Setting.StorageName;
  if Assigned(Setting.Server) then
  begin
    Database.HostName := Setting.Server.Address;
    Database.Port := Setting.Server.Port;
  end;
  Database.Properties.Clear;
  Result := False;
end;

function TZeosEngine.IsConnected: Boolean;
begin
  Result := _Database.Connected;
end;

function TZeosEngine.Disconnect: Boolean;
begin
  _Database.Connected := False;
  Result := not _Database.Connected;
end;

function TZeosEngine.ExecuteDirect(const Statement: IStatement): IExecutionResult;
var
  AffectedRows: Integer;
begin
  _Database.ExecuteDirect(Statement.Syntax, AffectedRows);
  if AffectedRows < 1 then
    AffectedRows := 0;
  Result := TSuccededExecution.New(Statement, AffectedRows);
end;

function TZeosEngine.ExecutePreparing(const Statement: IStatement): IExecutionResult;
var
  Dataset: TZquery;
begin
  Dataset := TZquery.Create(_Database);
  try
    Dataset.Connection := _Database;
    Dataset.SQL.Text := Statement.Syntax;
    Dataset.Prepare;
    Statement.ResolveBindParameters(Dataset.Params);
    Dataset.ExecSQL;
    Result := TSuccededExecution.New(Statement, Dataset.RowsAffected);
  finally
    Dataset.Free;
  end;
end;

function TZeosEngine.Execute(const Statement: IStatement; const UseGlobalTransaction: Boolean): IExecutionResult;
begin
  if not UseGlobalTransaction then
    BeginTransaction;
  try
    if Statement.HasBindParameters then
      Result := ExecutePreparing(Statement)
    else
      Result := ExecuteDirect(Statement);
    if not UseGlobalTransaction then
      CommitTransaction;
  except
    on E: Exception do
    begin
      if not UseGlobalTransaction then
        RollbackTransaction;
      Result := TFailedExecution.New(Statement, 0, E.Message);
    end;
  end;
end;

function TZeosEngine.ExecuteReturning(const Statement: IStatement; const CommitData: Boolean;
  const UseGlobalTransaction: Boolean): IExecutionResult;
var
  Dataset: TZquery;
begin
  Dataset := TZquery.Create(_Database);
  try
    Dataset.Connection := _Database;
    Dataset.SQL.Text := Statement.Syntax;
    if Statement.HasBindParameters then
    begin
      Dataset.Prepare;
      Statement.ResolveBindParameters(Dataset.Params);
    end;
    if CommitData and not UseGlobalTransaction then
      BeginTransaction;
    Dataset.Open;
    if CommitData and not UseGlobalTransaction then
      CommitTransaction;
    Result := TDatasetExecution.New(Statement, Dataset);
  except
    on E: Exception do
    begin
      if CommitData and not UseGlobalTransaction then
        RollbackTransaction;
      Dataset.Free;
      Result := TFailedExecution.New(Statement, 0, E.Message);
    end;
  end;
end;

function TZeosEngine.ExecuteTransactionStatement(const Statement: IStatement; const Kind: TStatementKind)
  : IExecutionResult;
begin
  case Kind of
    Start:
      BeginTransaction;
    Commit:
      CommitTransaction;
    RollBack:
      RollbackTransaction;
  end;
  Result := TSuccededExecution.New(Statement, 1);
end;

function TZeosEngine.ExecuteScript(const StatementList: IStatementList; const SkipErrors: Boolean = False)
  : IExecutionResultList;
var
  Statement: IStatement;
  Kind: TStatementKind;
  ExecutionResult: IExecutionResult;
begin
  Result := TExecutionResultList.New;
  for Statement in StatementList do
  begin
    Kind := Statement.Kind;
    if Kind = Unknown then
      ExecutionResult := Execute(Statement, True)
    else
      ExecutionResult := ExecuteTransactionStatement(Statement, Kind);
    Result.Add(ExecutionResult);
    if ExecutionResult.Failed and not SkipErrors then
      raise EDatabaseEngine.Create((ExecutionResult as IFailedExecution).Message);
  end;
end;

constructor TZeosEngine.Create;
begin
  _Database := TZConnection.Create(nil);
end;

destructor TZeosEngine.Destroy;
begin
  if IsConnected and InTransaction then
    RollbackTransaction;
  Disconnect;
  _Database.Free;
  inherited;
end;

class function TZeosEngine.New: IDatabaseEngine;
begin
  Result := TZeosEngine.Create;
end;

end.
