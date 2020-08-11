{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
program test;

uses
  RunTest,
  DatabaseEngine in '..\..\code\DatabaseEngine.pas',
  DatabaseEngineLib in '..\..\code\DatabaseEngineLib.pas',
  DatabaseValueFormat in '..\..\code\DatabaseValueFormat.pas',
  DatasetExecution in '..\..\code\DatasetExecution.pas',
  EntityCached in '..\..\code\EntityCached.pas',
  ExecutionResult in '..\..\code\ExecutionResult.pas',
  FailedExecution in '..\..\code\FailedExecution.pas',
  FirebirdEngine in '..\..\code\FirebirdEngine.pas',
  SuccededExecution in '..\..\code\SuccededExecution.pas',
  DatabaseValueFormat_test in '..\code\DatabaseValueFormat_test.pas',
  ExecutionResult_test in '..\code\ExecutionResult_test.pas',
  FailedExecution_test in '..\code\FailedExecution_test.pas',
  SuccededExecution_test in '..\code\SuccededExecution_test.pas',
  DatasetExecution_test in '..\code\DatasetExecution_test.pas',
  ADOEngine in '..\..\code\ADOEngine.pas',
  FirebirdEngine_test in '..\code\FirebirdEngine_test.pas',
  SQLiteEngine in '..\..\code\SQLiteEngine.pas',
  SQLiteEngine_test in '..\code\SQLiteEngine_test.pas',
  ZeosDatabaseEngine in '..\..\code\ZeosDatabaseEngine.pas',
  Credential in '..\..\code\Credential.pas',
  Credential_test in '..\code\Credential_test.pas',
  Statement in '..\..\code\Statement.pas',
  FirebirdSettings in '..\..\code\FirebirdSettings.pas',
  ConnectionSettings in '..\..\code\ConnectionSettings.pas',
  SQLiteSettings_test in '..\code\SQLiteSettings_test.pas',
  FirebirdSettings_test in '..\code\FirebirdSettings_test.pas',
  ConnectionSettings_test in '..\code\ConnectionSettings_test.pas',
  Server in '..\..\code\Server.pas',
  SQLiteSettings in '..\..\code\SQLiteSettings.pas',
  ConnectionSettingsFactory in '..\..\code\ConnectionSettingsFactory.pas',
  DataStorage in '..\..\code\DataStorage.pas',
  ServerFactory in '..\..\code\ServerFactory.pas',
  DataStorage_test in '..\code\DataStorage_test.pas',
  ServerFactory_test in '..\code\ServerFactory_test.pas',
  CredentialFactory in '..\..\code\CredentialFactory.pas',
  CredentialFactory_test in '..\code\CredentialFactory_test.pas',
  ConnectionSettingsFactory_test in '..\code\ConnectionSettingsFactory_test.pas',
  SQLiteSettingsFactory in '..\..\code\SQLiteSettingsFactory.pas',
  SQLiteSettingsFactory_test in '..\code\SQLiteSettingsFactory_test.pas',
  FirebirdSettingsFactory_test in '..\code\FirebirdSettingsFactory_test.pas',
  Server_test in '..\code\Server_test.pas',
  CryptedCredential in '..\..\code\CryptedCredential.pas',
  CryptedCredential_test in '..\code\CryptedCredential_test.pas',
  ADOSettings in '..\..\code\ADOSettings.pas',
  ADOSettingsFactory in '..\..\code\ADOSettingsFactory.pas',
  FirebirdSettingsFactory in '..\..\code\FirebirdSettingsFactory.pas',
  FirebirdTransactionSettingsFactory in '..\..\code\FirebirdTransactionSettingsFactory.pas',
  FirebirdTransactionSettings in '..\..\code\FirebirdTransactionSettings.pas',
  FirebirdTransactionSettings_test in '..\code\FirebirdTransactionSettings_test.pas';

{R *.RES}

begin
  Run;

end.
