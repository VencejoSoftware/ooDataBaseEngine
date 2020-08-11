{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database engine connection for firebird
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FirebirdEmbedded15Engine;

interface

// TODO: Revisar documentacion

uses
  SysUtils,
  DB,
  uib, uibdataset, uiblib, uibase,
  ConnectionSettings, FirebirdSettings,
  DatabaseEngine,
  Statement,
  ExecutionResult, FailedExecution, SuccededExecution, DatasetExecution;

type
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseEngine))
  Firebird database engine
  @member(Connect @seealso(IDatabaseEngine.Connect))
  @member(New Create a new @classname as interface)
}
{$ENDREGION}
  TFirebirdEmbedded15Engine = class sealed(TInterfacedObject, IDatabaseEngine)
  strict private
    _Database: TUIBDatabase;
    _Transaction: TUIBTransaction;
  private
    function ExecutePreparing(const Statement: IStatement): IExecutionResult;
    function ExecuteDirect(const Statement: IStatement): IExecutionResult;
    function ExecuteTransactionStatement(const Statement: IStatement; const Kind: TStatementKind): IExecutionResult;
    function CastParams(const Params: TSQLParams): TParams;
  public
    function InTransaction: Boolean;
    function BeginTransaction: Boolean;
    function CommitTransaction: Boolean;
    function RollbackTransaction: Boolean;
    function Connect(const Settings: IConnectionSettings): Boolean;
    function Disconnect: Boolean;
    function IsConnected: Boolean;
    function Execute(const Statement: IStatement; const UseGlobalTransaction: Boolean): IExecutionResult;
    function ExecuteReturning(const Statement: IStatement; const CommitData: Boolean;
      const UseGlobalTransaction: Boolean): IExecutionResult;
    function ExecuteScript(const StatementList: IStatementList; const SkipErrors: Boolean = False)
      : IExecutionResultList;
    constructor Create;
    destructor Destroy; override;
    class function New: IDatabaseEngine;
  end;

implementation

function TFirebirdEmbedded15Engine.InTransaction: Boolean;
begin
  Result := _Transaction.InTransaction;
end;

function TFirebirdEmbedded15Engine.BeginTransaction: Boolean;
begin
  _Transaction.StartTransaction;
  Result := True;
end;

function TFirebirdEmbedded15Engine.CommitTransaction: Boolean;
begin
  _Transaction.Commit;
  Result := True;
end;

function TFirebirdEmbedded15Engine.RollbackTransaction: Boolean;
begin
  if InTransaction then
    _Transaction.RollBack;
  Result := True;
end;

function TFirebirdEmbedded15Engine.Connect(const Settings: IConnectionSettings): Boolean;
var
  FirebirdSettings: IFirebirdSettings;
begin
  FirebirdSettings := (Settings as IFirebirdSettings);
  _Database.Params.Clear;
  _Database.Params.Append(Format('sql_dialect=%d', [FirebirdSettings.Dialect]));
  _Database.Params.Append(Format('DEFAULT CHARACTER SET %s', [FirebirdSettings.Collation]));
  _Database.Params.Append(Format('SET NAMES %s', [FirebirdSettings.Collation]));
  _Database.Params.Append(Format('lc_ctype=%s', [FirebirdSettings.Collation]));
  _Database.LibraryName := FirebirdSettings.LibraryPath;
  _Database.UserName := FirebirdSettings.Credential.User;
  _Database.PassWord := FirebirdSettings.Credential.PassWord;
// _Database.Role := Config.Role;
  _Database.DatabaseName := FirebirdSettings.StorageName;
  _Database.SQLDialect := FirebirdSettings.Dialect;
  _Database.Connected := True;
  Result := _Database.Connected;
end;

function TFirebirdEmbedded15Engine.Disconnect: Boolean;
begin
  _Database.Connected := False;
  Result := not _Database.Connected;
end;

function TFirebirdEmbedded15Engine.IsConnected: Boolean;
begin
  Result := _Database.Connected;
end;

function TFirebirdEmbedded15Engine.CastParams(const Params: TSQLParams): TParams;
begin

end;

function TFirebirdEmbedded15Engine.ExecutePreparing(const Statement: IStatement): IExecutionResult;
var
  FBSql: TUIBStatement;
begin
  FBSql := TUIBStatement.Create(_Database);
  try
    FBSql.Transaction := _Transaction;
    FBSql.SQL.Text := Statement.Syntax;
    FBSql.Prepare(False);
    Statement.ResolveBindParameters(CastParams(FBSql.Params));
    FBSql.ExecSQL;
    Result := TSuccededExecution.New(Statement, FBSql.RowsAffected);
  finally
    FBSql.Free;
  end;
end;

function TFirebirdEmbedded15Engine.ExecuteDirect(const Statement: IStatement): IExecutionResult;
var
  FBSql: TUIBStatement;
begin
  FBSql := TUIBStatement.Create(_Database);
  try
    FBSql.Transaction := _Transaction;
    FBSql.SQL.Text := Statement.Syntax;
    FBSql.ExecSQL;
    Result := TSuccededExecution.New(Statement, FBSql.RowsAffected);
  finally
    FBSql.Free;
  end;
end;

function TFirebirdEmbedded15Engine.Execute(const Statement: IStatement; const UseGlobalTransaction: Boolean)
  : IExecutionResult;
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

function TFirebirdEmbedded15Engine.ExecuteReturning(const Statement: IStatement; const CommitData: Boolean;
  const UseGlobalTransaction: Boolean): IExecutionResult;
var
  Dataset: TUIBDataSet;
  Transaction: TUIBTransaction;
begin
  Dataset := TUIBDataSet.Create(_Database);
  if UseGlobalTransaction then
    Transaction := _Transaction
  else
  begin
    Transaction := TUIBTransaction.Create(Dataset);
    Transaction.Database := _Database;
    Transaction.Options := [tpRead, tpNowait, tpReadCommitted, tpRecVersion];
  end;
  try
    Dataset.Database := _Database;
    Dataset.Transaction := Transaction;
    Dataset.SQL.Text := Statement.Syntax;

    if Statement.HasBindParameters then
    begin
      // TODO: not exists!
      // Dataset.Prepare;
      Statement.ResolveBindParameters(CastParams(Dataset.Params));
    end;
    if CommitData and not UseGlobalTransaction then
      Transaction.StartTransaction;;
    Dataset.Open;
    if CommitData and not UseGlobalTransaction then
      Transaction.Commit;
    Dataset.First;
    Result := TDatasetExecution.New(Statement, Dataset);
  except
    on E: Exception do
    begin
      if CommitData and not UseGlobalTransaction then
        Transaction.RollBack;;
      Dataset.Free;
      Result := TFailedExecution.New(Statement, 0, E.Message);
    end;
  end;
end;

function TFirebirdEmbedded15Engine.ExecuteTransactionStatement(const Statement: IStatement; const Kind: TStatementKind)
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

function TFirebirdEmbedded15Engine.ExecuteScript(const StatementList: IStatementList; const SkipErrors: Boolean = False)
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

constructor TFirebirdEmbedded15Engine.Create;
begin
  _Database := TUIBDatabase.Create(nil);
  _Transaction := TUIBTransaction.Create(_Database);
  _Transaction.Database := _Database;
  _Transaction.Options := [tpConcurrency, tpWait, tpWrite];
end;

destructor TFirebirdEmbedded15Engine.Destroy;
begin
  if InTransaction then
    RollbackTransaction;
  Disconnect;
  _Transaction.Free;
  _Database.Free;
  inherited;
end;

class function TFirebirdEmbedded15Engine.New: IDatabaseEngine;
begin
  Result := TFirebirdEmbedded15Engine.Create;
end;

end.
