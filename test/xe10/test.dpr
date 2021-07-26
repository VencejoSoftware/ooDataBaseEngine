{
  Copyright (c) 2021, Vencejo Software
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
  FirebirdEngine25_test in '..\code\FirebirdEngine25_test.pas',
  SQLiteEngine in '..\..\code\SQLiteEngine.pas',
  SQLiteEngine_test in '..\code\SQLiteEngine_test.pas',
  ZeosDatabaseEngine in '..\..\code\ZeosDatabaseEngine.pas',
  Statement in '..\..\code\Statement.pas',
  FirebirdSetting in '..\..\code\FirebirdSetting.pas',
  ConnectionSetting in '..\..\code\ConnectionSetting.pas',
  SQLiteSettings_test in '..\code\SQLiteSettings_test.pas',
  FirebirdSetting_test in '..\code\FirebirdSetting_test.pas',
  ConnectionSettings_test in '..\code\ConnectionSettings_test.pas',
  SQLiteSetting in '..\..\code\SQLiteSetting.pas',
  ConnectionSettingFactory in '..\..\code\ConnectionSettingFactory.pas',
  DataStorage in '..\..\code\DataStorage.pas',
  DataStorage_test in '..\code\DataStorage_test.pas',
  ConnectionSettingsFactory_test in '..\code\ConnectionSettingsFactory_test.pas',
  SQLiteSettingFactory in '..\..\code\SQLiteSettingFactory.pas',
  SQLiteSettingsFactory_test in '..\code\SQLiteSettingsFactory_test.pas',
  FirebirdSettingFactory_test in '..\code\FirebirdSettingFactory_test.pas',
  ADOSetting in '..\..\code\ADOSetting.pas',
  ADOSettingFactory in '..\..\code\ADOSettingFactory.pas',
  FirebirdSettingFactory in '..\..\code\FirebirdSettingFactory.pas',
  FirebirdTransactionSettingFactory in '..\..\code\FirebirdTransactionSettingFactory.pas',
  FirebirdTransactionSetting in '..\..\code\FirebirdTransactionSetting.pas',
  FirebirdTransactionSetting_test in '..\code\FirebirdTransactionSetting_test.pas',
  FirebirdTransactionSettingFactory_test in '..\code\FirebirdTransactionSettingFactory_test.pas',
  Statement_test in '..\code\Statement_test.pas';

{ R *.RES }

begin
  Run;

end.
