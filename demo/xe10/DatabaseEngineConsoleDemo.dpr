{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
program DatabaseEngineConsoleDemo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  DB,
  Log,
  LogActor,
  ConsoleLog,
  DatabaseEngine,
  ExecutionResult,
  FailedExecution,
  DatasetExecution,
  DatabaseLogin,
  ConnectionParam,
  DatabaseEngineLib in '..\..\code\DatabaseEngineLib.pas';

var
  DatabaseEngineLib: IDatabaseEngineLib;

procedure DemoDataBaseFirebird;
const
  DEPENDS_PATH = '..\..\..\..\dependencies\';
var
  DatabaseEngine: IDatabaseEngine;
  Login: IDatabaseLogin;
  ExecutionResult: IExecutionResult;
  Dataset: TDataSet;
  SQL: String;
  LogActor: ILogActor;
begin
  LogActor := TLogActor.New(TConsoleLog.New(nil));
  DatabaseEngine := DatabaseEngineLib.NewLoggedDatabaseEngine(DatabaseEngineLib.NewFirebirdEngine, LogActor);
  Login := TDatabaseLogin.New('sysdba', 'masterkey');
{$IFDEF WIN64}
  Login.Parameters.Add(TConnectionParam.New('LIB_PATH', DEPENDS_PATH + 'Firebird25x64\fbembed.dll'));
{$ELSE}
  Login.Parameters.Add(TConnectionParam.New('LIB_PATH', DEPENDS_PATH + 'Firebird25x32\fbembed.dll'));
{$ENDIF}
  Login.Parameters.Add(TConnectionParam.New('ENGINE', 'Firebird'));
  Login.Parameters.Add(TConnectionParam.New('DB_PATH', DEPENDS_PATH + 'TEST.FDB'));
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
    SQL := 'INSERT INTO NON_EXISTS(FIELD) VALUES (1)';
    ExecutionResult := DatabaseEngine.Execute(SQL);
  finally
    DatabaseEngine.Disconnect;
  end;
end;

const
{$IFDEF WIN64}
  DEPLOY_PATH = '..\..\..\..\dll\build\Win64\Debug\';
{$ELSE}
  DEPLOY_PATH = '..\..\..\..\dll\build\Win32\Debug\';
{$ENDIF}

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    DatabaseEngineLib := TDatabaseEngineLib.New(DEPLOY_PATH + 'DataBaseEngineLib.dll');
    DemoDataBaseFirebird;
    WriteLn('Press any key to exit');
    ReadLn;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
