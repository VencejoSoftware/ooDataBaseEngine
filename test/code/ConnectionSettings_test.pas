{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ConnectionSettings_test;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSetting,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TConnectionSettingTest = class sealed(TTestCase)
  published
    procedure CredentialAreAlbertoAnd1234Pass;
    procedure StorageNameIsCDATABASE;
    procedure LibraryPathIsFbClientDll;
    procedure ServerIsLocalhostAndPortIsZero;
  end;

implementation

procedure TConnectionSettingTest.CredentialAreAlbertoAnd1234Pass;
var
  ConnectionSetting: IConnectionSetting;
begin
  ConnectionSetting := TConnectionSetting.New(TCredential.New('Alberto', '2134Pass'), EmptyStr, EmptyStr,
    TServer.New('Localhost', 0));
  CheckEquals('Alberto', ConnectionSetting.Credential.User);
  CheckEquals('2134Pass', ConnectionSetting.Credential.Password);
end;

procedure TConnectionSettingTest.ServerIsLocalhostAndPortIsZero;
var
  Setting: IConnectionSetting;
begin
  Setting := TConnectionSetting.New(TCredential.New('Alberto', '2134Pass'), 'C:\database\', 'fbclient.dll',
    TServer.New('localhost', 0));
  CheckEquals('localhost', Setting.Server.Address);
  CheckEquals(0, Setting.Server.Port);
end;

procedure TConnectionSettingTest.StorageNameIsCDATABASE;
begin
  CheckEquals('C:\database\', TConnectionSetting.New(TCredential.New('Alberto', '2134Pass'), 'C:\database\', EmptyStr,
    TServer.New('Localhost', 0)).StorageName);
end;

procedure TConnectionSettingTest.LibraryPathIsFbClientDll;
begin
  CheckEquals('fbclient.dll', TConnectionSetting.New(TCredential.New('Alberto', '2134Pass'), 'C:\database\',
    'fbclient.dll', TServer.New('Localhost', 0)).LibraryPath);
end;

initialization

RegisterTest(TConnectionSettingTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
