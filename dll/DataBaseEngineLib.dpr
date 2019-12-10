{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
library DataBaseEngineLib;

uses
  SimpleShareMem,
  ADOEngine in '..\code\ADOEngine.pas',
  DatabaseEngine in '..\code\DatabaseEngine.pas',
  DatabaseLogin in '..\code\DatabaseLogin.pas',
  DatabaseValueFormat in '..\code\DatabaseValueFormat.pas',
  FirebirdEngine in '..\code\FirebirdEngine.pas',
  DatabaseLoginFactory in '..\code\DatabaseLoginFactory.pas',
  ConnectionParam in '..\code\ConnectionParam.pas',
  DatasetExecution in '..\code\DatasetExecution.pas',
  ExecutionResult in '..\code\ExecutionResult.pas',
  FailedExecution in '..\code\FailedExecution.pas',
  SuccededExecution in '..\code\SuccededExecution.pas';

{$R *.res}

function NewADOEngine: IDatabaseEngine; stdcall; export;
begin
  Result := TADOEngine.New;
end;

function NewFirebirdEngine: IDatabaseEngine; stdcall; export;
begin
  Result := TFirebirdEngine.New;
end;

exports
  NewADOEngine,
  NewFirebirdEngine;

begin
  IsMultiThread := True;

end.
