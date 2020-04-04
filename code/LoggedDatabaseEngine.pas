{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Logged Database engine object
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit LoggedDatabaseEngine;

interface

uses
  SysUtils,
  Log,
  LogActor,
  DatabaseLogin,
  ExecutionResult,
  FailedExecution,
  DatabaseEngine;

type
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseEngine))
  Database engine decorator with logging capabilities
  @member(InTransaction @seealso(IDatabaseEngine.InTransaction))
  @member(BeginTransaction @seealso(IDatabaseEngine.BeginTransaction))
  @member(CommitTransaction @seealso(IDatabaseEngine.CommitTransaction))
  @member(RollbackTransaction @seealso(IDatabaseEngine.RollbackTransaction))
  @member(Connect @seealso(IDatabaseEngine.Connect))
  @member(Disconnect @seealso(IDatabaseEngine.Disconnect))
  @member(IsConnected @seealso(IDatabaseEngine.IsConnected))
  @member(OpenDataset @seealso(IDatabaseEngine.OpenDataset))
  @member(Execute @seealso(IDatabaseEngine.Execute))
  @member(ExecuteReturning @seealso(IDatabaseEngine.ExecuteReturning))
  @member(
    Create Object constructor
    @param(DatabaseEngine @link(IDatabaseEngine Data base engine object to encapsulate))
    @param(LogActor @link(ILogActor LogActor object to handle events))
  )
  @member(Destroy Object destructor)
  @member(
    New Create a new @classname as interface
    @param(DatabaseEngine @link(IDatabaseEngine Database engine object to encapsulate))
    @param(LogActor @link(ILogActor LogActor object to handle events))
  )
}
{$ENDREGION}
  TLoggedDatabaseEngine = class sealed(TInterfacedObject, IDatabaseEngine)
  strict private
    _DatabaseEngine: IDatabaseEngine;
    _Logactor: ILogActor;
  public
    function InTransaction: Boolean;
    function BeginTransaction: Boolean;
    function CommitTransaction: Boolean;
    function RollbackTransaction: Boolean;
    function Connect(const Login: IDatabaseLogin): Boolean;
    function Disconnect: Boolean;
    function IsConnected: Boolean;
    function OpenDataset(const Statement: WideString): IExecutionResult;
    function Execute(const Statement: WideString; const UseGlobalTransaction: Boolean = False): IExecutionResult;
    function ExecuteReturning(const Statement: WideString; const UseGlobalTransaction: Boolean = False)
      : IExecutionResult;
    constructor Create(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor);
    class function New(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor): IDatabaseEngine;
  end;

implementation

function TLoggedDatabaseEngine.InTransaction: Boolean;
begin
  Result := _DatabaseEngine.InTransaction;
end;

function TLoggedDatabaseEngine.BeginTransaction: Boolean;
begin
  Result := False;
  _Logactor.WriteDebug('Starting transaction');
  try
    Result := _DatabaseEngine.BeginTransaction;
    _Logactor.WriteDebug('Transaction started');
  except
    on E: Exception do
      _Logactor.WriteException(E, True)
  end;
end;

function TLoggedDatabaseEngine.CommitTransaction: Boolean;
begin
  Result := False;
  _Logactor.WriteDebug('Commiting transaction');
  try
    Result := _DatabaseEngine.CommitTransaction;
    _Logactor.WriteDebug('Transaction commited');
  except
    on E: Exception do
      _Logactor.WriteException(E, True)
  end;
end;

function TLoggedDatabaseEngine.RollbackTransaction: Boolean;
begin
  Result := False;
  _Logactor.WriteDebug('Rollbacking transaction');
  try
    Result := _DatabaseEngine.RollbackTransaction;
    _Logactor.WriteDebug('Transaction rollbacked');
  except
    on E: Exception do
      _Logactor.WriteException(E, True)
  end;
end;

function TLoggedDatabaseEngine.Connect(const Login: IDatabaseLogin): Boolean;
var
  DBName: WideString;
begin
  Result := False;
  if not Login.Parameters.TryGetValue('NAME', DBName) then
    DBName := EmptyWideStr;
  _Logactor.WriteDebug('Connection to database ' + DBName);
  try
    Result := _DatabaseEngine.Connect(Login);
    _Logactor.WriteDebug('Database connected ' + DBName);
  except
    on E: Exception do
      _Logactor.WriteException(E, True)
  end;
end;

function TLoggedDatabaseEngine.Disconnect: Boolean;
begin
  Result := False;
  _Logactor.WriteDebug('Disconnection from database');
  try
    Result := _DatabaseEngine.Disconnect;
    _Logactor.WriteDebug('Database disconnected');
  except
    on E: Exception do
      _Logactor.WriteException(E, True)
  end;
end;

function TLoggedDatabaseEngine.IsConnected: Boolean;
begin
  Result := _DatabaseEngine.IsConnected;
end;

function TLoggedDatabaseEngine.OpenDataset(const Statement: WideString): IExecutionResult;
begin
  _Logactor.WriteDebug(Format('Opening dataset. Statemenet "%s"', [Statement]));
  try
    if Supports(Result, IFailedExecution) then
      _Logactor.WriteError((Result as IFailedExecution).Message)
    else
      Result := _DatabaseEngine.OpenDataset(Statement);
    _Logactor.WriteDebug(Format('Dataset opened. Statemenet "%s"', [Statement]));
  except
    on E: Exception do
      _Logactor.WriteException(E, True)
  end;
end;

function TLoggedDatabaseEngine.Execute(const Statement: WideString; const UseGlobalTransaction: Boolean = False)
  : IExecutionResult;
begin
  _Logactor.WriteDebug(Format('Executing statemenet "%s"', [Statement]));
  try
    Result := _DatabaseEngine.Execute(Statement, UseGlobalTransaction);
    if Supports(Result, IFailedExecution) then
      _Logactor.WriteError((Result as IFailedExecution).Message)
    else
      _Logactor.WriteDebug(Format('Executed statemenet "%s"', [Statement]));
  except
    on E: Exception do
      _Logactor.WriteException(E, True)
  end;
end;

function TLoggedDatabaseEngine.ExecuteReturning(const Statement: WideString;
  const UseGlobalTransaction: Boolean = False): IExecutionResult;
begin
  _Logactor.WriteDebug(Format('Executing returning statemenet "%s"', [Statement]));
  try
    Result := _DatabaseEngine.ExecuteReturning(Statement, UseGlobalTransaction);
    if Supports(Result, IFailedExecution) then
      _Logactor.WriteError((Result as IFailedExecution).Message)
    else
      _Logactor.WriteDebug(Format('Executed returning statemenet "%s"', [Statement]));
  except
    on E: Exception do
      _Logactor.WriteException(E, True)
  end;
end;

constructor TLoggedDatabaseEngine.Create(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor);
begin
  _Logactor := LogActor;
  _DatabaseEngine := DatabaseEngine;
end;

class function TLoggedDatabaseEngine.New(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor)
  : IDatabaseEngine;
begin
  Result := TLoggedDatabaseEngine.Create(DatabaseEngine, LogActor);
end;

end.
