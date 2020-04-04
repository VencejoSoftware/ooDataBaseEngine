{
  Copyright (c) 2020, Vencejo Software
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
  RxMemDS,
  TestFramework
{$ENDIF};

type
  TDatasetExecutionTest = class sealed(TTestCase)
  private
    function MockDataset: TDataset;
  published
    procedure StatementIsSelectFromTable;
    procedure FailedIsFalse;
    procedure DatasetIsAssigned;
  end;

implementation

function TDatasetExecutionTest.MockDataset: TDataset;
begin
{$IFDEF FPC}
  Result := TDataset.Create(nil);
{$ELSE}
  Result := TRxMemoryData.Create(nil);
{$ENDIF}
end;

procedure TDatasetExecutionTest.StatementIsSelectFromTable;
begin
  CheckEquals('SELECT * FROM TABLE', TDatasetExecution.New('SELECT * FROM TABLE', MockDataset).Statement);
end;

procedure TDatasetExecutionTest.FailedIsFalse;
begin
  CheckFalse(TDatasetExecution.New('SELECT * FROM TABLE', MockDataset).Failed);
end;

procedure TDatasetExecutionTest.DatasetIsAssigned;
begin
  CheckTrue(Assigned(TDatasetExecution.New('SELECT * FROM TABLE', MockDataset).Dataset));
end;

initialization

RegisterTests('DatasetExecution test', [TDatasetExecutionTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
