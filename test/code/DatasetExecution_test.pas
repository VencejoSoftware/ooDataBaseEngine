{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit DatasetExecution_test;

interface

uses
  Classes, SysUtils,
  DB,
  ExecutionResult,
  DatasetExecution,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDatasetExecutionTest = class sealed(TTestCase)
  published
    procedure StatementIsSelectFromTable;
    procedure FailedIsFalse;
    procedure DatasetIsAssigned;
  end;

implementation

procedure TDatasetExecutionTest.StatementIsSelectFromTable;
begin
  CheckEquals('SELECT * FROM TABLE', TDatasetExecution.New('SELECT * FROM TABLE', TDataset.Create(nil)).Statement);
end;

procedure TDatasetExecutionTest.FailedIsFalse;
begin
  CheckFalse(TDatasetExecution.New('SELECT * FROM TABLE', TDataset.Create(nil)).Failed);
end;

procedure TDatasetExecutionTest.DatasetIsAssigned;
begin
  CheckTrue(Assigned(TDatasetExecution.New('SELECT * FROM TABLE', TDataset.Create(nil)).Dataset));
end;

initialization

RegisterTests('DatasetExecution test', [TDatasetExecutionTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
