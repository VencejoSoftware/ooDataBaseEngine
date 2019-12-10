{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
program DatabaseEngineConsoleDemo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  DB,
  DatabaseEngine,
  ExecutionResult,
  FailedExecution,
  DatasetExecution,
  DatabaseLogin,
  DatabaseEngineLib in '..\code\DatabaseEngineLib.pas',
  ConnectionParam in '..\code\ConnectionParam.pas';

var
  DatabaseEngineLib: IDatabaseEngineLib;

procedure DemoDataBaseFirebird;
var
  DatabaseEngine: IDatabaseEngine;
  Login: IDatabaseLogin;
  ExecutionResult: IExecutionResult;
  Dataset: TDataSet;
  SQL: String;
begin
  DatabaseEngine := DatabaseEngineLib.NewFirebirdEngine;
  Login := TDatabaseLogin.New('sysdba', 'masterkey');
  Login.Parameters.Add(TConnectionParam.New('LIB_PATH', '..\..\..\test\build\debug\fbembed.dll'));
  Login.Parameters.Add(TConnectionParam.New('ENGINE', 'Firebird'));
  Login.Parameters.Add(TConnectionParam.New('DB_PATH', '..\..\..\test\build\debug\TEST.FDB'));
  Login.Parameters.Add(TConnectionParam.New('DIALECT', '3'));
  Login.Parameters.Add(TConnectionParam.New('CHARSET', 'ISO8859_1'));
  DatabaseEngine.Connect(Login);
  try
    SQL := 'SELECT u.RDB$USER, u.RDB$RELATION_NAME FROM RDB$USER_PRIVILEGES u';
    ExecutionResult := DatabaseEngine.OpenDataset(SQL);
    if not ExecutionResult.Failed then
      if Supports(ExecutionResult, IDatasetExecution) then
      begin
        Dataset := (ExecutionResult as IDatasetExecution).Dataset;
        while not Dataset.Eof do
        begin
          WriteLn(Format('%s, %s', [Dataset.Fields[0].AsString, Dataset.Fields[1].AsString]));
          Dataset.Next
        end;
      end;
  finally
    DatabaseEngine.Disconnect;
  end;
end;

procedure DemoDataBaseOracle;
const
  ORA_CONNECTION_STRING = 'Provider=OraOLEDB.Oracle;Data Source=%s; User Id=%s; Password=%s';
var
  DatabaseEngine: IDatabaseEngine;
  Login: IDatabaseLogin;
  ExecutionResult: IExecutionResult;
  Dataset: TDataSet;
  SQL: String;
begin
  DatabaseEngine := DatabaseEngineLib.NewADOEngine;
  Login := TDatabaseLogin.New('[ORACLE_LOGIN_USER]', '[ORACLE_PASSWORD]');
  Login.Parameters.Add(TConnectionParam.New('ENGINE', 'Oracle'));
  Login.Parameters.Add(TConnectionParam.New('TNS_NAME', '[YOUR_TNS_NAME]'));
  Login.Parameters.Add(TConnectionParam.New('CONNECTION_STRING', Format(ORA_CONNECTION_STRING,
    [Login.Parameters.ItemByKey('TNS_NAME').Value, Login.User, Login.Password])));
  DatabaseEngine.Connect(Login);
  try
    SQL := 'SELECT CURRENT_TIMESTAMP FROM DUAL';
    ExecutionResult := DatabaseEngine.OpenDataset(SQL);
    if not ExecutionResult.Failed then
      if Supports(ExecutionResult, IDatasetExecution) then
      begin
        Dataset := (ExecutionResult as IDatasetExecution).Dataset;
        WriteLn(Dataset.Fields[0].AsString);
      end;
  finally
    DatabaseEngine.Disconnect;
  end;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    DatabaseEngineLib := TDatabaseEngineLib.New('.\DataBaseEngineLib.dll');
    DemoDataBaseFirebird;
// DemoDataBaseOracle;
    WriteLn('Press any key to exit');
    ReadLn;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
