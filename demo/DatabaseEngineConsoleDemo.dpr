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
  Login.Parameters.Add(TConnectionParam.New('LIB_PATH', '..\..\..\dependencies\fbclient.dll'));
  Login.Parameters.Add(TConnectionParam.New('ENGINE', 'Firebird'));
  Login.Parameters.Add(TConnectionParam.New('DB_PATH', '..\..\..\dependencies\TEST.FDB'));
  Login.Parameters.Add(TConnectionParam.New('DIALECT', '3'));
  Login.Parameters.Add(TConnectionParam.New('CHARSET', 'ISO8859_1'));
  DatabaseEngine.Connect(Login);
  try
    SQL := 'select rdb$relation_name from rdb$relations where rdb$view_blr is null and (rdb$system_flag is null or rdb$system_flag = 0)';
    ExecutionResult := DatabaseEngine.OpenDataset(SQL);
    if not ExecutionResult.Failed then
      if Supports(ExecutionResult, IDatasetExecution) then
      begin
        Dataset := (ExecutionResult as IDatasetExecution).Dataset;
        while not Dataset.Eof do
        begin
          WriteLn(Dataset.Fields[0].AsString);
          Dataset.Next
        end;
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
    WriteLn('Press any key to exit');
    ReadLn;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
