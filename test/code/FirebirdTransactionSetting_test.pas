{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit FirebirdTransactionSetting_test;

interface

uses
  Classes, SysUtils,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF},
  FirebirdTransactionSetting;

type
  TFirebirdTransactionSettingTest = class sealed(TTestCase)
  strict private
    _TransactionSetting: IFirebirdTransactionSetting;
  public
    procedure SetUp; override;
  published
    procedure IsolationLevelIsConcurrency;
    procedure AccessModeIsWriteMode;
    procedure LockResolutionisWaitForLock;
    procedure TableReservationIsProtectAcces;
    procedure RecordVersionIsRecVersion;
    procedure ExtraOptionsHaveIgnoreLimboAndNoAutoUnd;
    procedure ToStringArrayReturnArray;
  end;

implementation

procedure TFirebirdTransactionSettingTest.IsolationLevelIsConcurrency;
begin
  CheckTrue(_TransactionSetting.IsolationLevel = Concurrency);
end;

procedure TFirebirdTransactionSettingTest.AccessModeIsWriteMode;
begin
  CheckTrue(_TransactionSetting.AccessMode = WriteMode);
end;

procedure TFirebirdTransactionSettingTest.LockResolutionisWaitForLock;
begin
  CheckTrue(_TransactionSetting.LockResolution = WaitForLock);
end;

procedure TFirebirdTransactionSettingTest.TableReservationIsProtectAcces;
begin
  CheckTrue(_TransactionSetting.TableReservation = ProtecteAccess);
end;

procedure TFirebirdTransactionSettingTest.RecordVersionIsRecVersion;
begin
  CheckTrue(_TransactionSetting.RecordVersion = RecVersion);
end;

procedure TFirebirdTransactionSettingTest.ExtraOptionsHaveIgnoreLimboAndNoAutoUnd;
begin
  CheckTrue(_TransactionSetting.ExtraOptions = [IgnoreLimbo, NoAutoUndo]);
end;

procedure TFirebirdTransactionSettingTest.ToStringArrayReturnArray;
var
  Params: TArray<String>;
begin
  Params := _TransactionSetting.ToStringArray;
  CheckEquals(7, Length(Params));
  CheckEquals('isc_tpb_concurrency', Params[0]);
  CheckEquals('isc_tpb_write', Params[1]);
  CheckEquals('isc_tpb_wait', Params[2]);
  CheckEquals('isc_tpb_protected', Params[3]);
  CheckEquals('isc_tpb_rec_version', Params[4]);
  CheckEquals('isc_tpb_ignore_limbo', Params[5]);
  CheckEquals('isc_tpb_no_auto_undo', Params[6]);
end;

procedure TFirebirdTransactionSettingTest.SetUp;
begin
  inherited;
  _TransactionSetting := TFirebirdTransactionSetting.New(Concurrency, WriteMode, WaitForLock, ProtecteAccess,
    RecVersion, [IgnoreLimbo, NoAutoUndo]);
end;

initialization

RegisterTests('Firebird test', [TFirebirdTransactionSettingTest.Suite]);

end.
