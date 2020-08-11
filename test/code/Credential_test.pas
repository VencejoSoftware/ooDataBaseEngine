{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit Credential_Test;

interface

uses
  Classes, SysUtils,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF},
  Credential;

type
  TCredentialTest = class sealed(TTestCase)
  strict private
    _Credential: ICredential;
  public
    procedure SetUp; override;
  published
    procedure UserIsAdmin;
    procedure PasswordIsSecretCode;
    procedure IsValidPasswordIsTrue;
  end;

implementation

procedure TCredentialTest.UserIsAdmin;
begin
  CheckEquals('ADMIN', _Credential.User);
end;

procedure TCredentialTest.PasswordIsSecretCode;
begin
  CheckEquals('SecretCode', _Credential.Password);
end;

procedure TCredentialTest.IsValidPasswordIsTrue;
begin
  CheckTrue(_Credential.IsValidPassword('SecretCode'));
end;

procedure TCredentialTest.SetUp;
begin
  inherited;
  _Credential := TCredential.New('ADMIN', 'SecretCode');
end;

initialization

RegisterTest('Credential test', TCredentialTest.Suite);

end.
