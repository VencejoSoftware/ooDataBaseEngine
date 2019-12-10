{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ExecutionResult_test;

interface

uses
  Classes, SysUtils,
  FailedExecution,
  SuccededExecution,
  ExecutionResult,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TExecutionResultListTest = class sealed(TTestCase)
  published
    procedure CountIs4;
    procedure FailedIsTrue;
  end;

implementation

{ TExecutionResultListTest }

procedure TExecutionResultListTest.CountIs4;
var
  ExecutionResultList: IExecutionResultList;
begin
  ExecutionResultList := TExecutionResultList.New;
  ExecutionResultList.Add(TSuccededExecution.New('UPDATE TABLE SET FIELD = 1', 10));
  ExecutionResultList.Add(TFailedExecution.New('EXECUTE PROCEDURE aaa', 123, 'aaa not defined'));
  ExecutionResultList.Add(TSuccededExecution.New('SELECT FIRST 1 1 FROM DEMO', 1));
  ExecutionResultList.Add(TSuccededExecution.New('UPDATE TABLE SET FIELD = 1', 10));
  CheckEquals(4, ExecutionResultList.Count);
end;

procedure TExecutionResultListTest.FailedIsTrue;
var
  ExecutionResultList: IExecutionResultList;
begin
  ExecutionResultList := TExecutionResultList.New;
  ExecutionResultList.Add(TSuccededExecution.New('UPDATE TABLE SET FIELD = 1', 10));
  ExecutionResultList.Add(TFailedExecution.New('EXECUTE PROCEDURE aaa', 123, 'aaa not defined'));
  ExecutionResultList.Add(TSuccededExecution.New('SELECT FIRST 1 1 FROM DEMO', 1));
  ExecutionResultList.Add(TSuccededExecution.New('UPDATE TABLE SET FIELD = 1', 10));
  CheckTrue(ExecutionResultList.Failed);
end;

initialization

RegisterTests('ExecutionResult test', [TExecutionResultListTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
