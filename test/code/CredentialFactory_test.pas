{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit CredentialFactory_test;

interface

uses
  SysUtils,
  DataStorage,
  Credential, CredentialFactory,
  XorCipher,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TCredentialFactoryTest = class sealed(TTestCase)
  strict private
    _DataStorage: IDataStorage;
  protected
    procedure SetUp; override;
  published
    procedure BuildReturnObject;
    procedure BuildWithOutCipherReturnObject;
    procedure BuildEmptyValuesReturnException;
  end;

implementation

procedure TCredentialFactoryTest.BuildReturnObject;
var
  CredentialFactory: ICredentialFactory;
  Credential: ICredential;
begin
  CredentialFactory := TCredentialFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
  Credential := CredentialFactory.Build('FirebirdEngine25', _DataStorage);
  CheckTrue(Assigned(Credential));
  CheckEquals('sysdba', Credential.User);
  CheckEquals('6F63727564736A6478', Credential.Password);
  CheckTrue(Credential.IsValidPassword('masterkey'));
end;

procedure TCredentialFactoryTest.BuildWithOutCipherReturnObject;
var
  CredentialFactory: ICredentialFactory;
  Credential: ICredential;
begin
  CredentialFactory := TCredentialFactory.New(nil);
  Credential := CredentialFactory.Build('FirebirdEngine25', _DataStorage);
  CheckTrue(Assigned(Credential));
  CheckEquals('sysdba', Credential.User);
  CheckEquals('6F63727564736A6478', Credential.Password);
  CheckTrue(Credential.IsValidPassword('6F63727564736A6478'));
end;

procedure TCredentialFactoryTest.BuildEmptyValuesReturnException;
var
  CredentialFactory: ICredentialFactory;
  Failed: Boolean;
begin
  Failed := False;
  CredentialFactory := TCredentialFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
  try
    CredentialFactory.Build('unknown', _DataStorage);
  except
    on E: EDataStorage do
    begin
      CheckEquals('Object name "unknown" dont exists', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TCredentialFactoryTest.SetUp;
const
  DEPENDS_PATH = '..\..\..\dependencies\';
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'settings.ini');
end;

initialization

RegisterTests('Connection setting test', [TCredentialFactoryTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
