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
  ConnectionSetting, ConnectionSettingFactory,
  XorCipher,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TConnectionSettingFactoryTest = class sealed(TTestCase)
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

procedure TConnectionSettingFactoryTest.BuildReturnObject;
var
  ConnectionSettingFactory: IConnectionSettingFactory;
  ConnectionSetting: IConnectionSetting;
begin
  ConnectionSettingFactory := TConnectionSettingFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
  ConnectionSetting := ConnectionSettingFactory.Build('FirebirdEngine25', _DataStorage);
  CheckTrue(Assigned(ConnectionSetting));
  CheckEquals(DEPENDS_PATH + 'TEST_2_5.FDB', ConnectionSetting.StorageName);
  CheckEquals(DEPENDS_PATH + 'Firebird25x64\fbembed.dll', ConnectionSetting.LibraryPath);
  CheckEquals('sysdba', ConnectionSetting.Credential.User);
  CheckEquals('6F63727564736A6478', ConnectionSetting.Credential.Password);
  CheckEquals('localhost', ConnectionSetting.Server.Address);
  CheckEquals(3050, ConnectionSetting.Server.Port);
end;

procedure TConnectionSettingFactoryTest.BuildWithOutCipherReturnObject;
var
  ConnectionSettingFactory: IConnectionSettingFactory;
  ConnectionSetting: IConnectionSetting;
begin
  ConnectionSettingFactory := TConnectionSettingFactory.New(nil);
  ConnectionSetting := ConnectionSettingFactory.Build('FirebirdEngine25', _DataStorage);
  CheckTrue(Assigned(ConnectionSetting));
  CheckEquals(DEPENDS_PATH + 'TEST_2_5.FDB', ConnectionSetting.StorageName);
  CheckEquals(DEPENDS_PATH + 'Firebird25x64\fbembed.dll', ConnectionSetting.LibraryPath);
  CheckEquals('sysdba', ConnectionSetting.Credential.User);
  CheckEquals('6F63727564736A6478', ConnectionSetting.Credential.Password);
  CheckEquals('localhost', ConnectionSetting.Server.Address);
  CheckEquals(3050, ConnectionSetting.Server.Port);
end;

procedure TConnectionSettingFactoryTest.BuildEmptyValuesReturnException;
var
  ConnectionSettingFactory: IConnectionSettingFactory;
  Failed: Boolean;
begin
  Failed := False;
  ConnectionSettingFactory := TConnectionSettingFactory.New(TXorCipher.New('1DB90020-0F32-4879-80AB-AA92C902FC8D'));
  try
    ConnectionSettingFactory.Build('unknown', _DataStorage);
  except
    on E: EDataStorage do
    begin
      CheckEquals('Object name "unknown" dont exists', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TConnectionSettingFactoryTest.SetUp;
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'Settings.ini');
end;

initialization

RegisterTests('Connection Setting test', [TConnectionSettingFactoryTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
