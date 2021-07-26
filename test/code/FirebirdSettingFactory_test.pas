{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit FirebirdSettingFactory_test;

interface

uses
  SysUtils,
  DataStorage,
  FirebirdSetting, FirebirdSettingFactory,
  XorCipher,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TFirebirdSettingFactoryTest = class sealed(TTestCase)
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

procedure TFirebirdSettingFactoryTest.BuildReturnObject;
var
  FirebirdSettingFactory: IFirebirdSettingFactory;
  FirebirdSetting: IFirebirdSetting;
begin
  FirebirdSettingFactory := TFirebirdSettingFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
  FirebirdSetting := FirebirdSettingFactory.Build('FirebirdEngine25', _DataStorage);
  CheckTrue(Assigned(FirebirdSetting));
  CheckEquals(ExpandFileName(DEPENDS_PATH + 'TEST_2_5.FDB'), FirebirdSetting.StorageName);
  CheckEquals(ExpandFileName(DEPENDS_PATH + 'Firebird25x64\fbembed.dll'), FirebirdSetting.LibraryPath);
  CheckEquals('sysdba', FirebirdSetting.Credential.User);
  CheckEquals('6F63727564736A6478', FirebirdSetting.Credential.Password);
  CheckTrue(FirebirdSetting.Credential.IsValidPassword('masterkey'));
  CheckEquals('localhost', FirebirdSetting.Server.Address);
  CheckEquals(3050, FirebirdSetting.Server.Port);
  CheckEquals('ISO8859_1', FirebirdSetting.Collation);
  CheckEquals('firebird-2.5', FirebirdSetting.Version);
  CheckEquals(3, FirebirdSetting.Dialect);
end;

procedure TFirebirdSettingFactoryTest.BuildWithoutCipherReturnObject;
var
  FirebirdSettingFactory: IFirebirdSettingFactory;
  FirebirdSetting: IFirebirdSetting;
begin
  FirebirdSettingFactory := TFirebirdSettingFactory.New(nil);
  FirebirdSetting := FirebirdSettingFactory.Build('FirebirdEngine25', _DataStorage);
  CheckTrue(Assigned(FirebirdSetting));
  CheckEquals(ExpandFileName(DEPENDS_PATH + 'TEST_2_5.FDB'), FirebirdSetting.StorageName);
  CheckEquals(ExpandFileName(DEPENDS_PATH + 'Firebird25x64\fbembed.dll'), FirebirdSetting.LibraryPath);
  CheckEquals('sysdba', FirebirdSetting.Credential.User);
  CheckEquals('6F63727564736A6478', FirebirdSetting.Credential.Password);
  CheckTrue(FirebirdSetting.Credential.IsValidPassword('6F63727564736A6478'));
  CheckEquals('localhost', FirebirdSetting.Server.Address);
  CheckEquals(3050, FirebirdSetting.Server.Port);
  CheckEquals('ISO8859_1', FirebirdSetting.Collation);
  CheckEquals('firebird-2.5', FirebirdSetting.Version);
  CheckEquals(3, FirebirdSetting.Dialect);
end;

procedure TFirebirdSettingFactoryTest.BuildEmptyValuesReturnException;
var
  FirebirdSettingFactory: IFirebirdSettingFactory;
  Failed: Boolean;
begin
  Failed := False;
  try
    FirebirdSettingFactory := TFirebirdSettingFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
    FirebirdSettingFactory.Build('unknown', _DataStorage);
  except
    on E: EDataStorage do
    begin
      CheckEquals('Object name "unknown" dont exists', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TFirebirdSettingFactoryTest.SetUp;
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'settings.ini');
end;

initialization

RegisterTests('Firebird test', [TFirebirdSettingFactoryTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
