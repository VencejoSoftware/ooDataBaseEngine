{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
program test;

uses
  RunTest,
  ConnectionParam_test in '..\code\ConnectionParam_test.pas',
  DatabaseLogin_test in '..\code\DatabaseLogin_test.pas',
  ConnectionParam in '..\..\code\ConnectionParam.pas',
  DatabaseEngine in '..\..\code\DatabaseEngine.pas',
  DatabaseEngineLib in '..\..\code\DatabaseEngineLib.pas',
  DatabaseLogin in '..\..\code\DatabaseLogin.pas',
  DatabaseLoginFactory in '..\..\code\DatabaseLoginFactory.pas',
  DatabaseValueFormat in '..\..\code\DatabaseValueFormat.pas',
  DatasetExecution in '..\..\code\DatasetExecution.pas',
  EntityCached in '..\..\code\EntityCached.pas',
  ExecutionResult in '..\..\code\ExecutionResult.pas',
  FailedExecution in '..\..\code\FailedExecution.pas',
  FirebirdEngine in '..\..\code\FirebirdEngine.pas',
  SuccededExecution in '..\..\code\SuccededExecution.pas',
  DatabaseValueFormat_test in '..\code\DatabaseValueFormat_test.pas',
  ExecutionResult_test in '..\code\ExecutionResult_test.pas',
  FailedExecution_test in '..\code\FailedExecution_test.pas',
  SuccededExecution_test in '..\code\SuccededExecution_test.pas',
  DatasetExecution_test in '..\code\DatasetExecution_test.pas',
  ADOEngine in '..\..\code\ADOEngine.pas',
  FirebirdEngine_test in '..\code\FirebirdEngine_test.pas';

{R *.RES}

begin
  Run;

end.
