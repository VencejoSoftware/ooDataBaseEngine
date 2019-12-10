{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit SuccededExecution_test;

interface

uses
  Classes, SysUtils,
  ExecutionResult,
  SuccededExecution,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TSuccededExecutionTest = class sealed(TTestCase)
  published
    procedure StatementIsSelectFromTable;
    procedure FailedIsFalse;
    procedure AffectedRowsIs10;
  end;

implementation

procedure TSuccededExecutionTest.StatementIsSelectFromTable;
begin
  CheckEquals('SELECT * FROM TABLE', TSuccededExecution.New('SELECT * FROM TABLE', 10).Statement);
end;

procedure TSuccededExecutionTest.FailedIsFalse;
begin
  CheckFalse(TSuccededExecution.New('SELECT * FROM TABLE', 10).Failed);
end;

procedure TSuccededExecutionTest.AffectedRowsIs10;
begin
  CheckEquals(10, TSuccededExecution.New('SELECT * FROM TABLE', 10).AffectedRows);
end;

initialization

RegisterTests('SuccededExecution test', [TSuccededExecutionTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
