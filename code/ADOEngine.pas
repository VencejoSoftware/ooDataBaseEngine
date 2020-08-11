{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database engine connection for ADO connectors
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ADOEngine;

interface

uses
  ActiveX,
  SysUtils,
  DB,
  ADODB,
  ConnectionSetting,
  Statement,
  ExecutionResult, FailedExecution, SuccededExecution, DatasetExecution,
  DatabaseEngine;

type
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseEngine))
  ADO connectors implementation
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
    @param(Statement Statement syntax)
    @param(Kind Transaction action kind)
    @return(@link(IExecutionResult Execution result object))
  )
  @member(Create Object constructor)
  @member(Destroy Object destructor)
  @member(New Create a new @classname as interface)
}
{$ENDREGION}
  TADOEngine = class sealed(TInterfacedObject, IDatabaseEngine)
  strict private
    _Connection: TADOConnection;
  private
    function ExecuteTransactionStatement(const Statement: IStatement; const Kind: TStatementKind): IExecutionResult;
  public
    function InTransaction: Boolean;
    function BeginTransaction: Boolean;
    function CommitTransaction: Boolean;
    function RollbackTransaction: Boolean;
    function Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean;
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

function TADOEngine.InTransaction: Boolean;
begin
  Result := _Connection.InTransaction;
end;

function TADOEngine.BeginTransaction: Boolean;
begin
  if not InTransaction then
    _Connection.BeginTrans;
  Result := True;
end;

function TADOEngine.CommitTransaction: Boolean;
begin
  if InTransaction then
    _Connection.CommitTrans;
  Result := True;
end;

function TADOEngine.RollbackTransaction: Boolean;
begin
  if InTransaction then
    _Connection.RollbackTrans;
  Result := True;
end;

function TADOEngine.Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean;
var
  ConnectionString: WideString;
begin
// if not Login.Parameters.TryGetValue('CONNECTION_STRING', ConnectionString) then
// raise Exception.Create('Connection string not found in parameter list');
// _Connection.ConnectionString := ConnectionString;
// _Connection.Connected := True;
// Result := _Connection.Connected;
end;

function TADOEngine.Disconnect: Boolean;
begin
  _Connection.Connected := False;
  Result := _Connection.Connected;
end;

function TADOEngine.IsConnected: Boolean;
begin
  Result := _Connection.Connected;
end;

// var
// Dataset: TADODataSet;
// begin
// Dataset := TADODataSet.Create(_Connection);
// Dataset.Connection := _Connection;
// Dataset.CommandText := Statement;
// try
// Dataset.Open;
// Result := TDatasetExecution.New(Statement, Dataset);
// except
// on E: Exception do
// begin
// Dataset.Free;
// Result := TFailedExecution.New(Statement, 0, E.Message);
// end;
// end;
// end;

function TADOEngine.Execute(const Statement: IStatement; const UseGlobalTransaction: Boolean): IExecutionResult;
var
  AffectedRows: Integer;
begin
// if not UseGlobalTransaction then
// BeginTransaction;
// try
// _Connection.Execute(Statement, AffectedRows);
// if not UseGlobalTransaction then
// CommitTransaction;
// Result := TSuccededExecution.New(Statement, AffectedRows);
// except
// on E: Exception do
// begin
// if not UseGlobalTransaction then
// RollbackTransaction;
// Result := TFailedExecution.New(Statement, 0, E.Message);
// end;
// end;
end;

function TADOEngine.ExecuteReturning(const Statement: IStatement; const CommitData: Boolean;
  const UseGlobalTransaction: Boolean): IExecutionResult;
var
  Command: TADOCommand;
  Dataset: TADODataSet;
begin
// BeginTransaction;
// try
// Command := TADOCommand.Create(_Connection);
// try
// Command.Connection := _Connection;
// Command.CommandText := Statement;
// Command.CommandType := TCommandType.cmdText;
// Dataset := TADODataSet.Create(_Connection);
// (Result as TADODataSet).Recordset := Command.Execute;
// if CommitTransaction then
// Result := TDatasetExecution.New(Statement, Dataset);
// finally
// Command.Free;
// end;
// except
// on E: Exception do
// begin
// RollbackTransaction;
// Result := TFailedExecution.New(Statement, 0, E.Message);
// end;
// end;
end;

function TADOEngine.ExecuteTransactionStatement(const Statement: IStatement; const Kind: TStatementKind)
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

function TADOEngine.ExecuteScript(const StatementList: IStatementList; const SkipErrors: Boolean = False)
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

constructor TADOEngine.Create;
begin
  CoInitialize(nil);
  _Connection := TADOConnection.Create(nil);
  _Connection.LoginPrompt := False;
end;

destructor TADOEngine.Destroy;
begin
  Disconnect;
  _Connection.Free;
  CoUninitialize;
  inherited;
end;

class function TADOEngine.New: IDatabaseEngine;
begin
  Result := TADOEngine.Create;
end;

end.
