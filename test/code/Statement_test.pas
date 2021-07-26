{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit Statement_test;

interface

uses
  SysUtils,
  DB,
  Statement,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TStatementTest = class sealed(TTestCase)
  private
    procedure ParameterBind(const Statement: IStatement; const Parameters: TParams);
  published
    procedure SimpleStatementResultSQL;
    procedure StartTransactionResultTransactionStartSQL;
    procedure CommitTransactionResultTransactionStartSQL;
    procedure RollbackTransactionResultTransactionStartSQL;
    procedure StatementWithBindedParametersShouldReturnParsedSQL;
  end;

  TStatementListTest = class sealed(TTestCase)
  published
    procedure LoadFromTextWithEmptyTextResultAsEmptyList;
    procedure LoadFromTextResultAList;
    procedure LoadFromTextWithBlockOfCodeResultAList;
  end;

implementation

procedure TStatementTest.SimpleStatementResultSQL;
const
  SQL = 'SELECT * FROM TABLE';
var
  Statement: IStatement;
begin
  Statement := TStatement.New(SQL, nil);
  CheckEquals(SQL + TStatement.STATEMENT_DELIMITER, Statement.Syntax);
  CheckEquals(False, Statement.HasBindParameters);
  CheckEquals(Ord(TStatementKind.Unknown), Ord(Statement.Kind));
end;

procedure TStatementTest.StartTransactionResultTransactionStartSQL;
const
  SQL = 'BEGIN TRANSACTION';
var
  Statement: IStatement;
begin
  Statement := TStatement.New(SQL, nil);
  CheckEquals(SQL + TStatement.STATEMENT_DELIMITER, Statement.Syntax);
  CheckEquals(False, Statement.HasBindParameters);
  CheckEquals(Ord(TStatementKind.Start), Ord(Statement.Kind));
end;

procedure TStatementTest.CommitTransactionResultTransactionStartSQL;
const
  SQL = 'COMMIT';
var
  Statement: IStatement;
begin
  Statement := TStatement.New(SQL, nil);
  CheckEquals(SQL + TStatement.STATEMENT_DELIMITER, Statement.Syntax);
  CheckEquals(False, Statement.HasBindParameters);
  CheckEquals(Ord(TStatementKind.Commit), Ord(Statement.Kind));
end;

procedure TStatementTest.RollbackTransactionResultTransactionStartSQL;
const
  SQL = 'ROLLBACK';
var
  Statement: IStatement;
begin
  Statement := TStatement.New(SQL, nil);
  CheckEquals(SQL + TStatement.STATEMENT_DELIMITER, Statement.Syntax);
  CheckEquals(False, Statement.HasBindParameters);
  CheckEquals(Ord(TStatementKind.Rollback), Ord(Statement.Kind));
end;

procedure TStatementTest.ParameterBind(const Statement: IStatement; const Parameters: TParams);
begin
  CheckEquals(10, Parameters.ParamByName('ID').AsInteger);
end;

procedure TStatementTest.StatementWithBindedParametersShouldReturnParsedSQL;
const
  SQL = 'SELECT * FROM TABLE WHERE ID = :ID';
var
  Statement: IStatement;
  Params: TParams;
begin
  Statement := TStatement.New(SQL, ParameterBind);
  Params := TParams.Create(nil);
  try
    with Params.AddParameter do
    begin
      Name := 'ID';
      AsInteger := 10;
    end;
    Statement.ResolveBindParameters(Params);
  finally
    Params.Free;
  end;
  CheckEquals(SQL + TStatement.STATEMENT_DELIMITER, Statement.Syntax);
  CheckEquals(True, Statement.HasBindParameters);
  CheckEquals(Ord(TStatementKind.Unknown), Ord(Statement.Kind));
end;

{ TStatementListTest }

procedure TStatementListTest.LoadFromTextWithEmptyTextResultAsEmptyList;
var
  StatementList: IStatementList;
begin
  StatementList := TStatementList.New;
  StatementList.LoadFromText(EmptyStr);
  CheckEquals(True, StatementList.IsEmpty);
end;

procedure TStatementListTest.LoadFromTextResultAList;
const
  TEXT = //
    'BEGIN TRANSACTION;' + sLineBreak + //
    'INSERT INTO TABLE (ID) VALUES (1);' + sLineBreak + //
    'COMMIT;';
var
  StatementList: IStatementList;
begin
  StatementList := TStatementList.New;
  StatementList.LoadFromText(TEXT);
  CheckEquals(3, StatementList.Count);
end;

procedure TStatementListTest.LoadFromTextWithBlockOfCodeResultAList;
const
  TEXT = //
    'CREATE TABLE CREDENTIAL (' + sLineBreak + //
    '  ID       INTEGER NOT NULL,' + sLineBreak + //
    '  LOGIN    VARCHAR(50) NOT NULL,' + sLineBreak + //
    '  PASSWORD VARCHAR(1024));' + sLineBreak + //
    sLineBreak + //
    'ALTER TABLE CREDENTIAL ADD CONSTRAINT CREDENTIAL_PK PRIMARY KEY (ID);' + sLineBreak + //
    sLineBreak + //
    'CREATE UNIQUE INDEX CREDENTIAL_LOGIN_IX ON CREDENTIAL(LOGIN);' + sLineBreak + //
    sLineBreak + //
    'CREATE GENERATOR CREDENTIAL_SQ;' + sLineBreak + //
    sLineBreak + //
    '--START-BLOCK;' + sLineBreak + //
    'CREATE TRIGGER CREDENTIAL_TG FOR CREDENTIAL ACTIVE BEFORE INSERT POSITION 0' + sLineBreak + //
    'AS' + sLineBreak + //
    'BEGIN' + sLineBreak + //
    '  if (NEW.ID is null) then' + sLineBreak + //
    '    NEW.ID = gen_id(CREDENTIAL_SQ, 1);' + sLineBreak + //
    'END;' + sLineBreak + //
    '--END-BLOCK;';
var
  StatementList: IStatementList;
begin
  StatementList := TStatementList.New;
  StatementList.LoadFromText(TEXT);
  CheckEquals(5, StatementList.Count);
end;

initialization

RegisterTests('Statement test', [TStatementTest {$IFNDEF FPC}.Suite {$ENDIF}, TStatementListTest{$IFNDEF FPC}.Suite
{$ENDIF}]);

end.
