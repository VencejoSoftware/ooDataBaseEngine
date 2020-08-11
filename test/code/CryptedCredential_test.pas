{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit CryptedCredential_test;

interface

uses
  Classes, SysUtils,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF},
  KeyCipher, XorCipher,
  Credential, CryptedCredential;

type
  TCryptedCredentialTest = class sealed(TTestCase)
  strict private
    _Credential: ICryptedCredential;
  public
    procedure SetUp; override;
  published
    procedure UserIsAdmin;
    procedure PasswordIsEncrypted;
    procedure IsValidPasswordIsTrue;
    procedure ErroneousRevealPasswordRaiseError;
    procedure RevealPasswordIsSecretCode;
  end;

implementation

procedure TCryptedCredentialTest.UserIsAdmin;
begin
  CheckEquals('ADMIN', _Credential.User);
end;

procedure TCryptedCredentialTest.PasswordIsEncrypted;
begin
  CheckEquals('516762736475426E6567', _Credential.Password);
end;

procedure TCryptedCredentialTest.RevealPasswordIsSecretCode;
begin
  CheckEquals('SecretCode', _Credential.RevealPassword('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
end;

procedure TCryptedCredentialTest.ErroneousRevealPasswordRaiseError;
var
  ErrorFound: Boolean;
begin
  ErrorFound := False;
  try
    _Credential.RevealPassword('FAIL-TEST');
  except
    on E: Exception do
    begin
      ErrorFound := True;
      CheckEquals('Invalid Reveal Key', E.Message);
    end;
  end;
  CheckTrue(ErrorFound);
end;

procedure TCryptedCredentialTest.IsValidPasswordIsTrue;
begin
  CheckTrue(_Credential.IsValidPassword('SecretCode'));
end;

procedure TCryptedCredentialTest.SetUp;
var
  Cipher: IKeyCipher;
begin
  inherited;
  Cipher := TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D');
  _Credential := TCryptedCredential.New('ADMIN', 'SecretCode', Cipher);
end;

initialization

RegisterTest('Credential test', TCryptedCredentialTest.Suite);

end.
