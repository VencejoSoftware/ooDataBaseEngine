{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ConnectionSettings_test;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSettings,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TConnectionSettingsTest = class sealed(TTestCase)
  published
    procedure CredentialAreAlbertoAnd1234Pass;
    procedure StorageNameIsCDATABASE;
    procedure LibraryPathIsFbClientDll;
    procedure ServerIsLocalhostAndPortIsZero;
  end;

implementation

procedure TConnectionSettingsTest.CredentialAreAlbertoAnd1234Pass;
var
  ConnectionSettings: IConnectionSettings;
begin
  ConnectionSettings := TConnectionSettings.New(TCredential.New('Alberto', '2134Pass'), EmptyStr, EmptyStr,
    TServer.New('Localhost', 0));
  CheckEquals('Alberto', ConnectionSettings.Credential.User);
  CheckEquals('2134Pass', ConnectionSettings.Credential.Password);
end;

procedure TConnectionSettingsTest.ServerIsLocalhostAndPortIsZero;
var
  Settings: IConnectionSettings;
begin
  Settings := TConnectionSettings.New(TCredential.New('Alberto', '2134Pass'), 'C:\database\', 'fbclient.dll',
    TServer.New('localhost', 0));
  CheckEquals('localhost', Settings.Server.Address);
  CheckEquals(0, Settings.Server.Port);
end;

procedure TConnectionSettingsTest.StorageNameIsCDATABASE;
begin
  CheckEquals('C:\database\', TConnectionSettings.New(TCredential.New('Alberto', '2134Pass'), 'C:\database\',
    EmptyStr, TServer.New('Localhost', 0)).StorageName);
end;

procedure TConnectionSettingsTest.LibraryPathIsFbClientDll;
begin
  CheckEquals('fbclient.dll', TConnectionSettings.New(TCredential.New('Alberto', '2134Pass'), 'C:\database\',
    'fbclient.dll', TServer.New('Localhost', 0)).LibraryPath);
end;

initialization

RegisterTest(TConnectionSettingsTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
