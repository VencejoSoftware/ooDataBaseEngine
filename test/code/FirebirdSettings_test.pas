{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit FirebirdSettings_test;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSettings, FirebirdSettings, FirebirdTransactionSettings,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TFirebirdSettingsTest = class sealed(TTestCase)
  strict private
    _FirebirdSettings: IFirebirdSettings;
  private
    function ConnectionSettings: IConnectionSettings;
    function TransactionSettings: IFirebirdTransactionSettings;
  protected
    procedure SetUp; override;
  published
    procedure UserIsSysdba;
    procedure PasswordIsMasterkey;
    procedure StorageNameIsDatabaseFdb;
    procedure LibraryPathIsFbClientDll;
    procedure PortIs3050;
    procedure CollationIsISO8859_1;
    procedure DialectIs3;
    procedure VersionIsFirebird30;
    procedure TransactionIsReadCommitedWriteModeNoWaitForLockSharedRecVersion;
  end;

implementation

procedure TFirebirdSettingsTest.UserIsSysdba;
begin
  CheckEquals('sysdba', _FirebirdSettings.Credential.User);
end;

procedure TFirebirdSettingsTest.PasswordIsMasterkey;
begin
  CheckEquals('masterkey', _FirebirdSettings.Credential.Password);
end;

procedure TFirebirdSettingsTest.StorageNameIsDatabaseFdb;
begin
  CheckEquals('database.fdb', _FirebirdSettings.StorageName);
end;

procedure TFirebirdSettingsTest.LibraryPathIsFbClientDll;
begin
  CheckEquals('fbclient.dll', _FirebirdSettings.LibraryPath);
end;

procedure TFirebirdSettingsTest.PortIs3050;
begin
  CheckEquals(3050, _FirebirdSettings.Server.Port);
end;

procedure TFirebirdSettingsTest.CollationIsISO8859_1;
begin
  CheckEquals('ISO8859_1', _FirebirdSettings.Collation);
end;

procedure TFirebirdSettingsTest.DialectIs3;
begin
  CheckEquals(3, _FirebirdSettings.Dialect);
end;

procedure TFirebirdSettingsTest.VersionIsFirebird30;
begin
  CheckEquals('firebird-3.0', _FirebirdSettings.Version);
end;

procedure TFirebirdSettingsTest.TransactionIsReadCommitedWriteModeNoWaitForLockSharedRecVersion;
begin
  CheckTrue(TFirebirdTransactionIsolationLevel.ReadCommited = _FirebirdSettings.TransactionSettings.IsolationLevel);
  CheckTrue(TFirebirdTransactionAccessMode.WriteMode = _FirebirdSettings.TransactionSettings.AccessMode);
  CheckTrue(TFirebirdTransactionLockResolution.NoWaitForLock = _FirebirdSettings.TransactionSettings.LockResolution);
  CheckTrue(TFirebirdTransactionTableReservation.Shared = _FirebirdSettings.TransactionSettings.TableReservation);
  CheckTrue(TFirebirdTransactionRecordVersion.RecVersion = _FirebirdSettings.TransactionSettings.RecordVersion);
  CheckTrue([] = _FirebirdSettings.TransactionSettings.ExtraOptions);
end;

function TFirebirdSettingsTest.ConnectionSettings: IConnectionSettings;
begin
  Result := TConnectionSettings.New(TCredential.New('sysdba', 'masterkey'), 'database.fdb', 'fbclient.dll',
    TServer.New('localhost', 3050));
end;

function TFirebirdSettingsTest.TransactionSettings: IFirebirdTransactionSettings;
begin
  Result := TFirebirdTransactionSettings.New(ReadCommited, WriteMode, NoWaitForLock, Shared, RecVersion, []);
end;

procedure TFirebirdSettingsTest.SetUp;
begin
  inherited;
  _FirebirdSettings := TFirebirdSettings.New(ConnectionSettings, 'ISO8859_1', 'firebird-3.0', 3, TransactionSettings);
end;

initialization

RegisterTest(TFirebirdSettingsTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
