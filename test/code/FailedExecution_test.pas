{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit FailedExecution_test;

interface

uses
  Classes, SysUtils,
  Statement,
  ExecutionResult,
  FailedExecution,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TFailedExecutionTest = class sealed(TTestCase)
  published
    procedure StatementIsSelectFromTable;
    procedure FailedIsTrue;
    procedure ErrorCodeIs666;
    procedure MessageIsTableNotExists;
  end;

implementation

procedure TFailedExecutionTest.StatementIsSelectFromTable;
begin
  CheckEquals('SELECT * FROM TABLE;', TFailedExecution.New(TStatement.New('SELECT * FROM TABLE'), 666,
    'Table not exists').Statement.Syntax);
end;

procedure TFailedExecutionTest.FailedIsTrue;
begin
  CheckTrue(TFailedExecution.New(TStatement.New('SELECT * FROM TABLE'), 666, 'Table not exists').Failed);
end;

procedure TFailedExecutionTest.ErrorCodeIs666;
begin
  CheckEquals(666, TFailedExecution.New(TStatement.New('SELECT * FROM TABLE'), 666, 'Table not exists').ErrorCode);
end;

procedure TFailedExecutionTest.MessageIsTableNotExists;
begin
  CheckEquals('Table not exists', TFailedExecution.New(TStatement.New('SELECT * FROM TABLE'), 666,
    'Table not exists').Message);
end;

initialization

RegisterTests('FailedExecution test', [TFailedExecutionTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
