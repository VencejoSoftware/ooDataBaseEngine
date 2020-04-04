library DataBaseEngineLib;

uses
  SimpleShareMem,
  LogActor,
  ADOEngine in '..\..\code\ADOEngine.pas',
  ConnectionParam in '..\..\code\ConnectionParam.pas',
  DatabaseEngine in '..\..\code\DatabaseEngine.pas',
  DatabaseLogin in '..\..\code\DatabaseLogin.pas',
  DatabaseLoginFactory in '..\..\code\DatabaseLoginFactory.pas',
  DatabaseValueFormat in '..\..\code\DatabaseValueFormat.pas',
  DatasetExecution in '..\..\code\DatasetExecution.pas',
  EntityCached in '..\..\code\EntityCached.pas',
  ExecutionResult in '..\..\code\ExecutionResult.pas',
  FailedExecution in '..\..\code\FailedExecution.pas',
  FirebirdEngine in '..\..\code\FirebirdEngine.pas',
  LoggedDatabaseEngine in '..\..\code\LoggedDatabaseEngine.pas',
  SuccededExecution in '..\..\code\SuccededExecution.pas';

{$R *.res}

function NewADOEngine: IDatabaseEngine; stdcall; export;
begin
  Result := TADOEngine.New;
end;

function NewFirebirdEngine: IDatabaseEngine; stdcall; export;
begin
  Result := TFirebirdEngine.New;
end;

function NewLoggedDatabaseEngine(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor): IDatabaseEngine;
  stdcall; export;
begin
  Result := TLoggedDatabaseEngine.New(DatabaseEngine, LogActor);
end;

exports
  NewADOEngine,
  NewFirebirdEngine,
  NewLoggedDatabaseEngine;

begin
  IsMultiThread := True;

end.
