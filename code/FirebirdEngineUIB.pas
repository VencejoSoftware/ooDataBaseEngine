{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database engine connection for firebird using UIB components
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FirebirdEngineUIB;

interface

uses
  SysUtils,
  DB,
  uib, uibdataset, uiblib, uibase,
  ConnectionSetting, FirebirdSetting,
  Statement,
  CryptedCredential,
  ExecutionResult, FailedExecution, SuccededExecution, DatasetExecution,
  DatabaseEngine;

type
  TFirebirdEngineUIB = class sealed(TInterfacedObject, IDatabaseEngine)
  strict private
    _Database: TUIBDatabase;
    _Transaction: TUIBTransaction;
  private
    function ExecuteTransactionStatement(const Statement: IStatement; const Kind: TStatementKind): IExecutionResult;
    function ExecuteDirect(const Statement: IStatement): IExecutionResult;
    function ExecutePreparing(const Statement: IStatement): IExecutionResult;
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

function TFirebirdEngineUIB.InTransaction: Boolean;
begin
  Result := _Transaction.InTransaction;
end;

function TFirebirdEngineUIB.BeginTransaction: Boolean;
begin
  if not InTransaction then
    _Transaction.StartTransaction;
  Result := True;
end;

function TFirebirdEngineUIB.CommitTransaction: Boolean;
begin
  if InTransaction then
    _Transaction.Commit;
  Result := True;
end;

function TFirebirdEngineUIB.RollbackTransaction: Boolean;
begin
  if InTransaction then
    _Transaction.RollBack;
  Result := True;
end;

function TFirebirdEngineUIB.Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean;
var
  FirebirdSetting: IFirebirdSetting;
begin
  FirebirdSetting := (Setting as IFirebirdSetting);
  if Assigned(FirebirdSetting.Credential) then
  begin
    _Database.UserName := Setting.Credential.User;
    if Supports(Setting.Credential, ICryptedCredential) then
      _Database.Password := (Setting.Credential as ICryptedCredential).RevealPassword(PasswordKey)
    else
      _Database.Password := Setting.Credential.Password;
  end;
  _Database.LibraryName := Setting.LibraryPath;
  _Database.Params.Clear;
  _Database.Params.Append(Format('sql_dialect=%d', [FirebirdSetting.Dialect]));
  _Database.Params.Append(Format('DEFAULT CHARACTER SET %s', [FirebirdSetting.Collation]));
  _Database.Params.Append(Format('SET NAMES %s', [FirebirdSetting.Collation]));
  _Database.Params.Append(Format('lc_ctype=%s', [FirebirdSetting.Collation]));
// Revisar
  _Transaction.Options := [tpConcurrency, tpWait, tpWrite];

  if Assigned(Setting.Server) then
  begin
    _Database.DatabaseName := Setting.Server.Address;
    if Setting.Server.Port <> 0 then
      _Database.DatabaseName := _Database.DatabaseName + '/' + IntToStr(Setting.Server.Port);
    _Database.DatabaseName := _Database.DatabaseName + ':' + Setting.StorageName;
  end
  else
    _Database.DatabaseName := Setting.StorageName;
  _Database.Connected := True;
  _Database.Password := EmptyWideStr;
  Result := _Database.Connected;
end;

function TFirebirdEngineUIB.IsConnected: Boolean;
begin
  Result := _Database.Connected;
end;

function TFirebirdEngineUIB.Disconnect: Boolean;
begin
  _Database.Connected := False;
  Result := not _Database.Connected;
end;

function TFirebirdEngineUIB.ExecuteDirect(const Statement: IStatement): IExecutionResult;
var
  FBSql: TUIBStatement;
begin
  FBSql := TUIBStatement.Create(_Database);
  try
    FBSql.Transaction := _Transaction;
    FBSql.SQL.Text := Statement.Syntax;
    FBSql.Prepare(False);
    FBSql.ExecSQL;
    Result := TSuccededExecution.New(Statement, FBSql.RowsAffected);
  finally
    FBSql.Close;
    FBSql.Free;
  end;
end;

function SQLParamsToTParams(const Params: TSQLParams): TParams;
begin

end;

function TFirebirdEngineUIB.ExecutePreparing(const Statement: IStatement): IExecutionResult;
var
  FBSql: TUIBStatement;
begin
  FBSql := TUIBStatement.Create(_Database);
  try
    FBSql.Transaction := _Transaction;
    FBSql.SQL.Text := Statement.Syntax;
    FBSql.Prepare(True);
    Statement.ResolveBindParameters(SQLParamsToTParams(FBSql.Params));
    FBSql.ExecSQL;
    Result := TSuccededExecution.New(Statement, FBSql.RowsAffected);
  finally
    FBSql.Close;
    FBSql.Free;
  end;
end;

function TFirebirdEngineUIB.Execute(const Statement: IStatement; const UseGlobalTransaction: Boolean): IExecutionResult;
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

function TFirebirdEngineUIB.ExecuteReturning(const Statement: IStatement; const CommitData: Boolean;
  const UseGlobalTransaction: Boolean): IExecutionResult;
var
  Dataset: TUIBDataSet;
begin
  Dataset := TUIBDataSet.Create(_Database);
  try
    Dataset.Database := _Database;
    Dataset.Transaction := _Transaction;
    Dataset.SQL.Text := Statement.Syntax;
    if Statement.HasBindParameters then
    begin
// Revisar
// Dataset.Prepare;
      Statement.ResolveBindParameters(SQLParamsToTParams(FBSql.Params));
    end;
    if CommitData and not UseGlobalTransaction then
      BeginTransaction;
    Dataset.Open;
    if CommitData and not UseGlobalTransaction then
      CommitTransaction;
    Dataset.First;
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

function TFirebirdEngineUIB.ExecuteTransactionStatement(const Statement: IStatement; const Kind: TStatementKind)
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

function TFirebirdEngineUIB.ExecuteScript(const StatementList: IStatementList; const SkipErrors: Boolean = False)
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
// var
// ScriptExecute: TUIBScript;
// begin
// ScriptExecute := TUIBScript.Create(_Database);
// try
// ScriptExecute.Database := _Database;
// ScriptExecute.Transaction := Transaction;
// ScriptExecute.Script.Text := Script;
// if RightStr(Trim(ScriptExecute.Script.Text), 1) <> ';' then
// ScriptExecute.Script.Text := ScriptExecute.Script.Text + ';';
// ScriptExecute.ExecuteScript;
// Result := True;
// finally
// ScriptExecute.Free;
// end;
end;

constructor TFirebirdEngineUIB.Create;
begin
  _Database := TUIBDatabase.Create(nil);
  _Transaction := TUIBTransaction.Create(_Database);
  _Transaction.Database := _Database;
end;

destructor TFirebirdEngineUIB.Destroy;
begin
  if IsConnected and InTransaction then
    RollbackTransaction;
  Disconnect;
  _Transaction.Free;
  _Database.Free;
  inherited;
end;

class function TFirebirdEngineUIB.New: IDatabaseEngine;
begin
  Result := TFirebirdEngineUIB.Create;
end;

end.
