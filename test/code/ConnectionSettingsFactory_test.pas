{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ConnectionSettingsFactory_test;

interface

uses
  SysUtils,
  DataStorage,
  ConnectionSettings, ConnectionSettingsFactory,
  XorCipher,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TConnectionSettingsFactoryTest = class sealed(TTestCase)
  const
    DEPENDS_PATH = '..\..\..\dependencies\';
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

procedure TConnectionSettingsFactoryTest.BuildReturnObject;
var
  ConnectionSettingsFactory: IConnectionSettingsFactory;
  ConnectionSettings: IConnectionSettings;
begin
  ConnectionSettingsFactory := TConnectionSettingsFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
  ConnectionSettings := ConnectionSettingsFactory.Build('FirebirdEngine', _DataStorage);
  CheckTrue(Assigned(ConnectionSettings));
  CheckEquals(DEPENDS_PATH + 'TEST.FDB', ConnectionSettings.StorageName);
  CheckEquals(DEPENDS_PATH + 'Firebird25x64\fbembed.dll', ConnectionSettings.LibraryPath);
  CheckEquals('sysdba', ConnectionSettings.Credential.User);
  CheckEquals('6F63727564736A6478', ConnectionSettings.Credential.Password);
  CheckEquals('localhost', ConnectionSettings.Server.Address);
  CheckEquals(3050, ConnectionSettings.Server.Port);
end;

procedure TConnectionSettingsFactoryTest.BuildWithOutCipherReturnObject;
var
  ConnectionSettingsFactory: IConnectionSettingsFactory;
  ConnectionSettings: IConnectionSettings;
begin
  ConnectionSettingsFactory := TConnectionSettingsFactory.New(nil);
  ConnectionSettings := ConnectionSettingsFactory.Build('FirebirdEngine', _DataStorage);
  CheckTrue(Assigned(ConnectionSettings));
  CheckEquals(DEPENDS_PATH + 'TEST.FDB', ConnectionSettings.StorageName);
  CheckEquals(DEPENDS_PATH + 'Firebird25x64\fbembed.dll', ConnectionSettings.LibraryPath);
  CheckEquals('sysdba', ConnectionSettings.Credential.User);
  CheckEquals('masterkey', ConnectionSettings.Credential.Password);
  CheckEquals('localhost', ConnectionSettings.Server.Address);
  CheckEquals(3050, ConnectionSettings.Server.Port);
end;

procedure TConnectionSettingsFactoryTest.BuildEmptyValuesReturnException;
var
  ConnectionSettingsFactory: IConnectionSettingsFactory;
  Failed: Boolean;
begin
  Failed := False;
  ConnectionSettingsFactory := TConnectionSettingsFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
  try
    ConnectionSettingsFactory.Build('unknown', _DataStorage);
  except
    on E: EDataStorage do
    begin
      CheckEquals('Object name "unknown" dont exists', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TConnectionSettingsFactoryTest.SetUp;
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'settings.ini');
end;

initialization

RegisterTests('Connection settings test', [TConnectionSettingsFactoryTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
