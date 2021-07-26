{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
program DatabaseEngineConsoleDemo;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  SysUtils,
  DB,
  XorCipher,
  Log,
  LogActor,
  ConsoleLog,
  DataStorage,
  ConnectionSetting,
  ConnectionSettingFactory,
  FirebirdSetting,
  FirebirdSettingFactory,
  DatabaseEngine,
  Statement,
  ExecutionResult,
  FailedExecution,
  DatasetExecution,
  DatabaseEngineLib in '..\..\code\DatabaseEngineLib.pas';

var
  DatabaseEngineLib: IDatabaseEngineLib;

procedure DemoDataBaseFirebird;
const
  DEPENDS_PATH = '..\..\..\..\dependencies\';
var
  LibPath: WideString;
  // DataStorage: IDataStorage;
  Setting: IConnectionSetting;
  DatabaseEngine: IDatabaseEngine;
  ExecutionResult: IExecutionResult;
  Dataset: TDataSet;
  SQL: String;
  LogActor: ILogActor;
begin
  LogActor := TLogActor.New(TConsoleLog.New(nil));
  DatabaseEngine := DatabaseEngineLib.NewLoggedDatabaseEngine(DatabaseEngineLib.NewFirebirdEngine, LogActor);
  // DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'Setting.ini');
  // Setting := TFirebirdSettingFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'))
  // .Build('FirebirdEngine', DataStorage);
{$IFDEF WIN64}
  LibPath := DEPENDS_PATH + 'Firebird25x64\fbembed.dll';
{$ELSE}
  LibPath := DEPENDS_PATH + 'Firebird25x32\fbembed.dll';
{$ENDIF}
  Setting := TFirebirdSetting.NewEmbedded(DEPENDS_PATH + 'TEST.FDB', LibPath, 'ISO8859_1', 'Firebird');
  DatabaseEngine.Connect(Setting);
  try
    SQL := 'select current_timestamp from RDB$DATABASE';
    ExecutionResult := DatabaseEngine.ExecuteReturning(TStatement.New(SQL), False);
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
    ExecutionResult := DatabaseEngine.Execute(TStatement.New(SQL), False);
  finally
    DatabaseEngine.Disconnect;
  end;
end;

procedure DemoDataBaseFirebird15;
const
  DEPENDS_PATH = '..\..\..\..\dependencies\';
  PASSWORD_KEY = '4A383018-9998-4D3C-A423-41253A290481';
var
  DataStorage: IDataStorage;
  Setting: IConnectionSetting;
  DatabaseEngine: IDatabaseEngine;
  ExecutionResult: IExecutionResult;
  Dataset: TDataSet;
  SQL: String;
  LogActor: ILogActor;
begin
  LogActor := TLogActor.New(TConsoleLog.New(nil));
  DatabaseEngine := DatabaseEngineLib.NewLoggedDatabaseEngine(DatabaseEngineLib.NewFirebirdEngine, LogActor);
  DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'Setting.ini');
  Setting := TFirebirdSettingFactory.New(TXorCipher.New(PASSWORD_KEY)).Build('FirebirdEngine15', DataStorage);
  DatabaseEngine.Connect(Setting, PASSWORD_KEY);
  try
    SQL := 'select current_timestamp from RDB$DATABASE';
    ExecutionResult := DatabaseEngine.ExecuteReturning(TStatement.New(SQL), False);
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
    // DemoDataBaseFirebird15;
    WriteLn('Press any key to exit');
    ReadLn;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

end.
