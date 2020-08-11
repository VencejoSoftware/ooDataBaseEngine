{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit FirebirdSettingsFactory_test;

interface

uses
  SysUtils,
  DataStorage,
  FirebirdSettings, FirebirdSettingsFactory,
  XorCipher,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TFirebirdSettingsFactoryTest = class sealed(TTestCase)
  const
    DEPENDS_PATH = '..\..\..\dependencies\';
  strict private
    _DataStorage: IDataStorage;
  protected
    procedure SetUp; override;
  published
    procedure BuildReturnObject;
    procedure BuildWithoutCipherReturnObject;
    procedure BuildEmptyValuesReturnException;
  end;

implementation

procedure TFirebirdSettingsFactoryTest.BuildReturnObject;
var
  FirebirdSettingsFactory: IFirebirdSettingsFactory;
  FirebirdSettings: IFirebirdSettings;
begin
  FirebirdSettingsFactory := TFirebirdSettingsFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
  FirebirdSettings := FirebirdSettingsFactory.Build('FirebirdEngine', _DataStorage);
  CheckTrue(Assigned(FirebirdSettings));
  CheckEquals(DEPENDS_PATH + 'TEST.FDB', FirebirdSettings.StorageName);
  CheckEquals(DEPENDS_PATH + 'Firebird25x64\fbembed.dll', FirebirdSettings.LibraryPath);
  CheckEquals('sysdba', FirebirdSettings.Credential.User);
  CheckEquals('6F63727564736A6478', FirebirdSettings.Credential.Password);
  CheckEquals('localhost', FirebirdSettings.Server.Address);
  CheckEquals(3050, FirebirdSettings.Server.Port);
  CheckEquals('ISO8859_1', FirebirdSettings.Collation);
  CheckEquals('firebird-2.5', FirebirdSettings.Version);
  CheckEquals(3, FirebirdSettings.Dialect);
end;

procedure TFirebirdSettingsFactoryTest.BuildWithoutCipherReturnObject;
var
  FirebirdSettingsFactory: IFirebirdSettingsFactory;
  FirebirdSettings: IFirebirdSettings;
begin
  FirebirdSettingsFactory := TFirebirdSettingsFactory.New(nil);
  FirebirdSettings := FirebirdSettingsFactory.Build('FirebirdEngine', _DataStorage);
  CheckTrue(Assigned(FirebirdSettings));
  CheckEquals(DEPENDS_PATH + 'TEST.FDB', FirebirdSettings.StorageName);
  CheckEquals(DEPENDS_PATH + 'Firebird25x64\fbembed.dll', FirebirdSettings.LibraryPath);
  CheckEquals('sysdba', FirebirdSettings.Credential.User);
  CheckEquals('masterkey', FirebirdSettings.Credential.Password);
  CheckEquals('localhost', FirebirdSettings.Server.Address);
  CheckEquals(3050, FirebirdSettings.Server.Port);
  CheckEquals('ISO8859_1', FirebirdSettings.Collation);
  CheckEquals('firebird-2.5', FirebirdSettings.Version);
  CheckEquals(3, FirebirdSettings.Dialect);
end;

procedure TFirebirdSettingsFactoryTest.BuildEmptyValuesReturnException;
var
  FirebirdSettingsFactory: IFirebirdSettingsFactory;
  Failed: Boolean;
begin
  Failed := False;
  try
    FirebirdSettingsFactory := TFirebirdSettingsFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
    FirebirdSettingsFactory.Build('unknown', _DataStorage);
  except
    on E: EDataStorage do
    begin
      CheckEquals('Object name "unknown" dont exists', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TFirebirdSettingsFactoryTest.SetUp;
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'settings.ini');
end;

initialization

RegisterTests('Connection settings test', [TFirebirdSettingsFactoryTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
