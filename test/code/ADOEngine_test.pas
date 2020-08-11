{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ADOEngine_test;

interface

uses
  Forms, SysUtils, DB,
  ADODB,
  ooFS.Archive, ooFS.Archive.Delete,
  Statement,
  SQL,
  UserCredential,
  ExecutionResult, SuccededExecution, DatasetExecution,
  RepositoryConnection,
  ConnectionSettings, SQLiteSettings,
  SQLiteConnection,
  ADOConnection,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TADOConnectionTest = class sealed(TTestCase)
  const
    SCRIPT = //
      'DROP TABLE TEST_TABLE;' + sLineBreak + //
      'BEGIN TRANSACTION;' + sLineBreak + //
      'CREATE TABLE TEST_TABLE(TEST_FIELD VARCHAR(8));' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal1'');' + sLineBreak + //
      'INSERT INTO TEST_TABLE (TEST_FIELD) VALUES (''TestVal2'');' + sLineBreak + //
      'COMMIT;';
  private
    ADOConnection: ADODB.TADOConnection;
    function DBPath: String;
    function ConnectionSettings: ISQLiteSettings;
    procedure CreateDB(const Settings: ISQLiteSettings);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ConnectToTest;
    procedure ServerDateTimeIsNow;
    procedure ServerDateTimeIsNowWithOutSQL;
    procedure SomeTransaction;
    procedure RunScriptToCreateTablesWithError;
    procedure RunScriptToCreateTables;
    procedure BuildDatasetTestTable;
    procedure BuildDatasetErrorSQLFail;
    procedure UpdateWithExecuteSQL;
    procedure StartCommitRollbackStatement;
  end;

implementation

procedure TADOConnectionTest.ConnectToTest;
var
  Connection: IRepositoryConnection;
begin
  Connection := TADOConnection.New(ADOConnection, nil);
  Connection.Connect;
  try
    CheckTrue(Connection.IsConnected);
  finally
    Connection.Disconnect;
  end;
end;

procedure TADOConnectionTest.ServerDateTimeIsNow;
const
  SQL_SERVER_DATETIME = 'SELECT strftime(''%d/%m/%Y %H:%M:%S'', CURRENT_TIMESTAMP) AS SERVER_DATE';
begin
  CheckEquals(Date, Trunc(TADOConnection.New(ADOConnection, TSQL.New(SQL_SERVER_DATETIME)).ServerDateTime));
end;

procedure TADOConnectionTest.ServerDateTimeIsNowWithOutSQL;
var
  Failed: Boolean;
begin
  Failed := False;
  try
    CheckEquals(Date, Trunc(TADOConnection.New(ADOConnection, nil).ServerDateTime));
  except
    on E: ERepositoryConnection do
      Failed := True;
  end;
  CheckTrue(Failed);
end;

procedure TADOConnectionTest.SomeTransaction;
var
  Connection: IRepositoryConnection;
begin
  Connection := TADOConnection.New(ADOConnection, nil);
  Connection.Connect;
  try
    CheckFalse(Connection.InTransaction);
    Connection.BeginTransaction;
    CheckTrue(Connection.InTransaction);
    Connection.CommitTransaction;
    CheckFalse(Connection.InTransaction);
    Connection.BeginTransaction;
    CheckTrue(Connection.InTransaction);
    Connection.RollbackTransaction;
    CheckFalse(Connection.InTransaction);
  finally
    Connection.Disconnect;
  end;
end;

procedure TADOConnectionTest.RunScriptToCreateTablesWithError;
var
  Connection: IRepositoryConnection;
  Failed: Boolean;
  StatementList: IStatementList;
begin
  Connection := TADOConnection.New(ADOConnection, nil);
  Connection.Connect;
  try
    Failed := False;
    try
      StatementList := TStatementList.New;
      StatementList := TSQLList.NewFromSyntax(SCRIPT + 'error line');
      CheckTrue(Connection.ExecuteBatch(StatementList, False).Failed);
    except
      on E: ERepositoryConnection do
        Failed := True;
    end;
    CheckTrue(Failed);
  finally
    Connection.Disconnect;
  end;
end;

procedure TADOConnectionTest.RunScriptToCreateTables;
var
  Connection: IRepositoryConnection;
  ExecutionResultList: IExecutionResultList;
  ExecutionResult: IExecutionResult;
  StatementList: IStatementList;
  RowsAffected: NativeUInt;
begin
  Connection := TADOConnection.New(ADOConnection, nil);
  Connection.Connect;
  try
    StatementList := TSQLList.NewFromSyntax(SCRIPT);
    ExecutionResultList := Connection.ExecuteBatch(StatementList, True);
    RowsAffected := 0;
    for ExecutionResult in ExecutionResultList do
      if Supports(ExecutionResult, ISuccededExecution) then
        Inc(RowsAffected, (ExecutionResult as ISuccededExecution).AffectedRows);
    CheckEquals(4, RowsAffected);
  finally
    Connection.Disconnect;
  end;
end;

procedure TADOConnectionTest.BuildDatasetTestTable;
var
  Connection: IRepositoryConnection;
  ExecutionResult: IExecutionResult;
  DataSet: TDataSet;
  i: Integer;
  StatementList: IStatementList;
begin
  Connection := TADOConnection.New(ADOConnection, nil);
  Connection.Connect;
  try
    StatementList := TSQLList.NewFromSyntax(SCRIPT);
    Connection.ExecuteBatch(StatementList, True);
    ExecutionResult := Connection.BuildDataset(TSQL.New('SELECT * FROM TEST_TABLE'));
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
    Connection.Disconnect;
  end;
end;

procedure TADOConnectionTest.BuildDatasetErrorSQLFail;
var
  Connection: IRepositoryConnection;
  ExecutionResult: IExecutionResult;
  StatementList: IStatementList;
begin
  Connection := TADOConnection.New(ADOConnection, nil);
  Connection.Connect;
  try
    StatementList := TSQLList.NewFromSyntax(SCRIPT);
    Connection.ExecuteBatch(StatementList, True);
    ExecutionResult := Connection.BuildDataset(TSQL.New('SELECT * FROM ERROR_TABLE'));
    CheckTrue(ExecutionResult.Failed);
  finally
    Connection.Disconnect;
  end;
end;

procedure TADOConnectionTest.UpdateWithExecuteSQL;
var
  Connection: IRepositoryConnection;
  StatementList: IStatementList;
  ExecutionResult: IExecutionResult;
begin
  Connection := TADOConnection.New(ADOConnection, nil);
  Connection.Connect;
  try
    StatementList := TStatementList.New;
    StatementList := TSQLList.NewFromSyntax(SCRIPT);
    Connection.ExecuteBatch(StatementList, True);
    ExecutionResult := Connection.ExecuteStatement(TSQL.New('UPDATE TEST_TABLE SET TEST_FIELD = ''a'';'));
    CheckFalse(ExecutionResult.Failed);
    if Supports(ExecutionResult, ISuccededExecution) then
      CheckEquals(2, (ExecutionResult as ISuccededExecution).AffectedRows);
  finally
    Connection.Disconnect;
  end;
end;

procedure TADOConnectionTest.StartCommitRollbackStatement;
const
  SCRIPT_TRANSACTION = //
    'BEGIN TRANSACTION;' + sLineBreak + //
    'ROLLBACK;' + sLineBreak + //
    'COMMIT;';
var
  Connection: IRepositoryConnection;
  ExecutionResultList: IExecutionResultList;
  ExecutionResult: IExecutionResult;
  StatementList: IStatementList;
  RowsAffected: NativeUInt;
begin
  Connection := TADOConnection.New(ADOConnection, nil);
  Connection.Connect;
  try
    StatementList := TSQLList.NewFromSyntax(SCRIPT_TRANSACTION);
    ExecutionResultList := Connection.ExecuteBatch(StatementList, True);
    RowsAffected := 0;
    for ExecutionResult in ExecutionResultList do
      if Supports(ExecutionResult, ISuccededExecution) then
        Inc(RowsAffected, (ExecutionResult as ISuccededExecution).AffectedRows);
    CheckEquals(3, RowsAffected);
  finally
    Connection.Disconnect;
  end;
end;

function TADOConnectionTest.DBPath: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'db_ado.db3';
end;

function TADOConnectionTest.ConnectionSettings: ISQLiteSettings;
var
  Credential: IUserCredential;
begin
  Credential := TUserCredential.New(EmptyStr, EmptyStr);
  Result := TSQLiteSettings.New(TConnectionSettings.New(Credential, DBPath, 'sqlite3.dll'));
end;

procedure TADOConnectionTest.CreateDB(const Settings: ISQLiteSettings);
begin
  TSQLiteConnection.New(Settings).CreateDatabase;
end;

procedure TADOConnectionTest.SetUp;
begin
  inherited;
  CreateDB(ConnectionSettings);
  ADOConnection := ADODB.TADOConnection.Create(Application);
  ADOConnection.ConnectionString := //
    'DRIVER=SQLite3 ODBC Driver;Database=' + DBPath + //
    ';LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;';
  ADOConnection.Open(EmptyStr, EmptyStr);
end;

procedure TADOConnectionTest.TearDown;
begin
  inherited;
  ADOConnection.Free;
  TFSArchiveDelete.New(TFSArchive.New(nil, ConnectionSettings.StoragePath)).Execute;
end;

initialization

RegisterTest(TADOConnectionTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
