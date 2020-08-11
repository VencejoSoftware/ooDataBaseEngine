library DataBaseEngineLib;

uses
  SimpleShareMem,
  LogActor,
  ADOEngine in '..\..\code\ADOEngine.pas',
  ADOSettings in '..\..\code\ADOSettings.pas',
  ADOSettingsFactory in '..\..\code\ADOSettingsFactory.pas',
  ConnectionSettings in '..\..\code\ConnectionSettings.pas',
  ConnectionSettingsFactory in '..\..\code\ConnectionSettingsFactory.pas',
  Credential in '..\..\code\Credential.pas',
  CredentialFactory in '..\..\code\CredentialFactory.pas',
  CryptedCredential in '..\..\code\CryptedCredential.pas',
  DatabaseEngine in '..\..\code\DatabaseEngine.pas',
  DatabaseValueFormat in '..\..\code\DatabaseValueFormat.pas',
  DatasetExecution in '..\..\code\DatasetExecution.pas',
  DataStorage in '..\..\code\DataStorage.pas',
  EntityCached in '..\..\code\EntityCached.pas',
  ExecutionResult in '..\..\code\ExecutionResult.pas',
  FailedExecution in '..\..\code\FailedExecution.pas',
  FirebirdEngine in '..\..\code\FirebirdEngine.pas',
  FirebirdSettings in '..\..\code\FirebirdSettings.pas',
  FirebirdSettingsFactory in '..\..\code\FirebirdSettingsFactory.pas',
  LoggedDatabaseEngine in '..\..\code\LoggedDatabaseEngine.pas',
  Server in '..\..\code\Server.pas',
  ServerFactory in '..\..\code\ServerFactory.pas',
  SQLiteEngine in '..\..\code\SQLiteEngine.pas',
  SQLiteSettings in '..\..\code\SQLiteSettings.pas',
  SQLiteSettingsFactory in '..\..\code\SQLiteSettingsFactory.pas',
  Statement in '..\..\code\Statement.pas',
  SuccededExecution in '..\..\code\SuccededExecution.pas',
  ZeosDatabaseEngine in '..\..\code\ZeosDatabaseEngine.pas',
  FirebirdTransactionSettings in '..\..\code\FirebirdTransactionSettings.pas',
  FirebirdTransactionSettingsFactory in '..\..\code\FirebirdTransactionSettingsFactory.pas';

{$R *.res}

function NewADOEngine: IDatabaseEngine; stdcall; export;
begin
  Result := TADOEngine.New;
end;

function NewFirebirdEngine: IDatabaseEngine; stdcall; export;
begin
  Result := TFirebirdEngine.New;
end;

// function NewFirebirdEmbedded15Engine: IDatabaseEngine; stdcall; export;
// begin
// Result := TFirebirdEmbedded15Engine.New;
// end;

function NewLoggedDatabaseEngine(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor): IDatabaseEngine;
  stdcall; export;
begin
  Result := TLoggedDatabaseEngine.New(DatabaseEngine, LogActor);
end;

exports
  NewADOEngine,
  NewFirebirdEngine,
// NewFirebirdEmbedded15Engine,
  NewLoggedDatabaseEngine;

begin
  IsMultiThread := True;

end.
