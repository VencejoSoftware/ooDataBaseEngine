{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit DatabaseLogin_test;

interface

uses
  Classes, SysUtils,
  ConnectionParam,
  DatabaseLogin,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TDatabaseLoginTest = class sealed(TTestCase)
  published
    procedure UserIsUserDemo;
    procedure PasswordIs12345;
    procedure ParameterCountIs3;
  end;

implementation

procedure TDatabaseLoginTest.UserIsUserDemo;
begin
  CheckEquals('UserDemo', TDatabaseLogin.New('UserDemo', '12345').User);
end;

procedure TDatabaseLoginTest.PasswordIs12345;
begin
  CheckEquals('12345', TDatabaseLogin.New('UserDemo', '12345').Password);
end;

procedure TDatabaseLoginTest.ParameterCountIs3;
var
  DatabaseLogin: IDatabaseLogin;
begin
  DatabaseLogin := TDatabaseLogin.New('UserDemo', '12345');
  DatabaseLogin.Parameters.Add(TConnectionParam.New('Key1', 'Value1'));
  DatabaseLogin.Parameters.Add(TConnectionParam.New('Key2', 'Value2'));
  DatabaseLogin.Parameters.Add(TConnectionParam.New('Key3', 'Value3'));
  CheckEquals(3, DatabaseLogin.Parameters.Count);
end;

initialization

RegisterTests('DatabaseLogin test', [TDatabaseLoginTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
