{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit FirebirdSetting_test;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSetting, FirebirdSetting, FirebirdTransactionSetting,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TFirebirdSettingTest = class sealed(TTestCase)
  strict private
    _FirebirdSetting: IFirebirdSetting;
  private
    function ConnectionSetting: IConnectionSetting;
    function TransactionSetting: IFirebirdTransactionSetting;
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

procedure TFirebirdSettingTest.UserIsSysdba;
begin
  CheckEquals('sysdba', _FirebirdSetting.Credential.User);
end;

procedure TFirebirdSettingTest.PasswordIsMasterkey;
begin
  CheckEquals('masterkey', _FirebirdSetting.Credential.Password);
end;

procedure TFirebirdSettingTest.StorageNameIsDatabaseFdb;
begin
  CheckEquals('database.fdb', _FirebirdSetting.StorageName);
end;

procedure TFirebirdSettingTest.LibraryPathIsFbClientDll;
begin
  CheckEquals('fbclient.dll', _FirebirdSetting.LibraryPath);
end;

procedure TFirebirdSettingTest.PortIs3050;
begin
  CheckEquals(3050, _FirebirdSetting.Server.Port);
end;

procedure TFirebirdSettingTest.CollationIsISO8859_1;
begin
  CheckEquals('ISO8859_1', _FirebirdSetting.Collation);
end;

procedure TFirebirdSettingTest.DialectIs3;
begin
  CheckEquals(3, _FirebirdSetting.Dialect);
end;

procedure TFirebirdSettingTest.VersionIsFirebird30;
begin
  CheckEquals('firebird-3.0', _FirebirdSetting.Version);
end;

procedure TFirebirdSettingTest.TransactionIsReadCommitedWriteModeNoWaitForLockSharedRecVersion;
begin
  CheckTrue(TFirebirdTransactionIsolationLevel.ReadCommited = _FirebirdSetting.TransactionSetting.IsolationLevel);
  CheckTrue(TFirebirdTransactionAccessMode.WriteMode = _FirebirdSetting.TransactionSetting.AccessMode);
  CheckTrue(TFirebirdTransactionLockResolution.NoWaitForLock = _FirebirdSetting.TransactionSetting.LockResolution);
  CheckTrue(TFirebirdTransactionTableReservation.Shared = _FirebirdSetting.TransactionSetting.TableReservation);
  CheckTrue(TFirebirdTransactionRecordVersion.RecVersion = _FirebirdSetting.TransactionSetting.RecordVersion);
  CheckTrue([] = _FirebirdSetting.TransactionSetting.ExtraOptions);
end;

function TFirebirdSettingTest.ConnectionSetting: IConnectionSetting;
begin
  Result := TConnectionSetting.New(TCredential.New('sysdba', 'masterkey'), 'database.fdb', 'fbclient.dll',
    TServer.New('localhost', 3050));
end;

function TFirebirdSettingTest.TransactionSetting: IFirebirdTransactionSetting;
begin
  Result := TFirebirdTransactionSetting.New(ReadCommited, WriteMode, NoWaitForLock, Shared, RecVersion, []);
end;

procedure TFirebirdSettingTest.SetUp;
begin
  inherited;
  _FirebirdSetting := TFirebirdSetting.New(ConnectionSetting, 'ISO8859_1', 'firebird-3.0', 3, TransactionSetting);
end;

initialization

RegisterTest('Firebird test', TFirebirdSettingTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
