{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit SQLiteEngine_test;

interface

uses
  SysUtils, DB,
  Statement,
  ConnectionSetting, SQLiteSetting,
  ExecutionResult, SuccededExecution, DatasetExecution,
  DatabaseEngine, SQLiteEngine,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TSQLiteEngineTest = class sealed(TTestCase)
  const
    SCRIPT = //
      'BEGIN TRANSACTION;' + sLineBreak + //
      'DROP TABLE TEST_TABLE;' + sLineBreak + //
      'CREATE TABLE TEST_TABLE(TEST_FIELD VARCHAR(8));' + sLineBreak + //
      'COMMIT;' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal1'');' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal2'');';
  strict private
    _Setting: IConnectionSetting;
    _DatabaseEngine: IDatabaseEngine;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure IsConnectedToTestIsTrue;
    procedure SomeTransaction;
    procedure RunScriptToCreateTablesWithError;
    procedure RunScriptToCreateTables;
    procedure ExecuteReturningReturnDataset;
    procedure BuildDatasetErrorSQLFail;
    procedure ExecuteUpdateReturn2AffectedRows;
    procedure StartCommitRollbackReturn2AffectedRows;
  end;

implementation

procedure TSQLiteEngineTest.IsConnectedToTestIsTrue;
begin
  _DatabaseEngine.Connect(_Setting);
  try
    CheckTrue(_DatabaseEngine.IsConnected);
  finally
    _DatabaseEngine.Disconnect;
  end;
  CheckFalse(_DatabaseEngine.IsConnected);
end;

procedure TSQLiteEngineTest.SomeTransaction;
begin
  _DatabaseEngine.Connect(_Setting);
  try
    CheckFalse(_DatabaseEngine.InTransaction);
    _DatabaseEngine.BeginTransaction;
    CheckTrue(_DatabaseEngine.InTransaction);
    _DatabaseEngine.CommitTransaction;
    CheckFalse(_DatabaseEngine.InTransaction);
    _DatabaseEngine.BeginTransaction;
    CheckTrue(_DatabaseEngine.InTransaction);
    _DatabaseEngine.RollbackTransaction;
    CheckFalse(_DatabaseEngine.InTransaction);
  finally
    _DatabaseEngine.Disconnect;
  end;
end;

procedure TSQLiteEngineTest.RunScriptToCreateTablesWithError;
var
  Failed: Boolean;
  StatementList: IStatementList;
begin
  _DatabaseEngine.Connect(_Setting);
  Failed := False;
  try
    try
      StatementList := TStatementList.New;
      StatementList.LoadFromText(SCRIPT);
      CheckTrue(_DatabaseEngine.ExecuteScript(StatementList, False).Failed);
    except
      on E: EDatabaseEngine do
        Failed := True;
    end;
    CheckTrue(Failed);
  finally
    _DatabaseEngine.Disconnect;
  end;
end;

procedure TSQLiteEngineTest.RunScriptToCreateTables;
var
  ExecutionResultList: IExecutionResultList;
  ExecutionResult: IExecutionResult;
  StatementList: IStatementList;
  RowsAffected: NativeUInt;
begin
  _DatabaseEngine.Connect(_Setting);
  try
    StatementList := TStatementList.New;
    StatementList.LoadFromText(SCRIPT);
    ExecutionResultList := _DatabaseEngine.ExecuteScript(StatementList, True);
    RowsAffected := 0;
    for ExecutionResult in ExecutionResultList do
      if Supports(ExecutionResult, ISuccededExecution) then
        Inc(RowsAffected, (ExecutionResult as ISuccededExecution).AffectedRows);
    CheckEquals(4, RowsAffected);
  finally
    _DatabaseEngine.Disconnect;
  end;
end;

procedure TSQLiteEngineTest.ExecuteReturningReturnDataset;
var
  ExecutionResult: IExecutionResult;
  DataSet: TDataSet;
  i: Integer;
  StatementList: IStatementList;
begin
  _DatabaseEngine.Connect(_Setting);
  try
    StatementList := TStatementList.New;
    StatementList.LoadFromText(SCRIPT);
    _DatabaseEngine.ExecuteScript(StatementList, True);
    ExecutionResult := _DatabaseEngine.ExecuteReturning(TStatement.New('SELECT * FROM TEST_TABLE'), False);
    if not ExecutionResult.Failed then
    begin
      DataSet := (ExecutionResult as IDatasetExecution).DataSet;
      i := 1;
      while not DataSet.Eof do
      begin
        CheckEquals('TestVal' + IntToStr(i), DataSet.FieldByName('TEST_FIELD').AsString);
        DataSet.Next;
        Inc(i)
      end;
    end;
  finally
    _DatabaseEngine.Disconnect;
  end;
end;

procedure TSQLiteEngineTest.BuildDatasetErrorSQLFail;
var
  ExecutionResult: IExecutionResult;
  StatementList: IStatementList;
begin
  _DatabaseEngine.Connect(_Setting);
  try
    StatementList := TStatementList.New;
    StatementList.LoadFromText(SCRIPT);
    _DatabaseEngine.ExecuteScript(StatementList, True);
    ExecutionResult := _DatabaseEngine.ExecuteReturning(TStatement.New('SELECT * FROM ERROR_TABLE'), False);
    CheckTrue(ExecutionResult.Failed);
  finally
    _DatabaseEngine.Disconnect;
  end;
end;

procedure TSQLiteEngineTest.ExecuteUpdateReturn2AffectedRows;
var
  StatementList: IStatementList;
  ExecutionResult: IExecutionResult;
begin
  _DatabaseEngine.Connect(_Setting);
  try
    StatementList := TStatementList.New;
    StatementList.LoadFromText(SCRIPT);
    _DatabaseEngine.ExecuteScript(StatementList, True);
    ExecutionResult := _DatabaseEngine.Execute(TStatement.New('UPDATE TEST_TABLE SET TEST_FIELD = ''a'''));
    CheckFalse(ExecutionResult.Failed);
    if Supports(ExecutionResult, ISuccededExecution) then
      CheckEquals(2, (ExecutionResult as ISuccededExecution).AffectedRows);
  finally
    _DatabaseEngine.Disconnect;
  end;
end;

procedure TSQLiteEngineTest.StartCommitRollbackReturn2AffectedRows;
var
  ExecutionResultList: IExecutionResultList;
  ExecutionResult: IExecutionResult;
  StatementList: IStatementList;
  RowsAffected: NativeUInt;
begin
  _DatabaseEngine.Connect(_Setting);
  try
    StatementList := TStatementList.NewByArray([TStatement.New('BEGIN TRANSACTION'), TStatement.New('ROOLBACK'),
      TStatement.New('COMMIT')]);
    ExecutionResultList := _DatabaseEngine.ExecuteScript(StatementList, True);
    RowsAffected := 0;
    for ExecutionResult in ExecutionResultList do
      if Supports(ExecutionResult, ISuccededExecution) then
        Inc(RowsAffected, (ExecutionResult as ISuccededExecution).AffectedRows);
    CheckEquals(2, RowsAffected);
  finally
    _DatabaseEngine.Disconnect;
  end;
end;

procedure TSQLiteEngineTest.SetUp;
const
  DEPENDS_PATH = '..\..\..\dependencies\';
var
  LibPath: WideString;
begin
  inherited;
{$IFDEF WIN64}
  LibPath := DEPENDS_PATH + 'SQLite3x64\sqlite3.dll ';
{$ELSE}
  LibPath := DEPENDS_PATH + 'SQLite3x32\sqlite3.dll';
{$ENDIF}
  _Setting := TSQLiteSetting.NewEmbedded(ExpandFileName(DEPENDS_PATH + 'TEST.DB3'), LibPath);
  _DatabaseEngine := TSQLiteEngine.New;
end;

procedure TSQLiteEngineTest.TearDown;
begin
  inherited;
  if FileExists(_Setting.StorageName) then
    DeleteFile(_Setting.StorageName);
end;

initialization

RegisterTests('SQLite test', [TSQLiteEngineTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
