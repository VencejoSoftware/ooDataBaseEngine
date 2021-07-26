{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit FirebirdTransactionSettingFactory_test;

interface

uses
  SysUtils,
  DataStorage,
  FirebirdTransactionSetting, FirebirdTransactionSettingFactory,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TFirebirdTransactionSettingFactoryTest = class sealed(TTestCase)
  strict private
    _DataStorage: IDataStorage;
  protected
    procedure SetUp; override;
  published
    procedure BuildReturnObject;
    procedure BuildEmptyValuesReturnException;
  end;

implementation

procedure TFirebirdTransactionSettingFactoryTest.BuildReturnObject;
var
  FirebirdTransactionSettingFactory: IFirebirdTransactionSettingFactory;
  FirebirdTransactionSetting: IFirebirdTransactionSetting;
begin
  FirebirdTransactionSettingFactory := TFirebirdTransactionSettingFactory.New;
  FirebirdTransactionSetting := FirebirdTransactionSettingFactory.Build('FirebirdEngine25', _DataStorage);
  CheckTrue(Assigned(FirebirdTransactionSetting));
  CheckTrue(ReadCommited = FirebirdTransactionSetting.IsolationLevel);
  CheckTrue(WriteMode = FirebirdTransactionSetting.AccessMode);
  CheckTrue(NoWaitForLock = FirebirdTransactionSetting.LockResolution);
  CheckTrue(Shared = FirebirdTransactionSetting.TableReservation);
  CheckTrue(RecVersion = FirebirdTransactionSetting.RecordVersion);
  CheckTrue([VerbTime, NoAutoUndo] = FirebirdTransactionSetting.ExtraOptions);
end;

procedure TFirebirdTransactionSettingFactoryTest.BuildEmptyValuesReturnException;
var
  FirebirdTransactionSettingFactory: IFirebirdTransactionSettingFactory;
  Failed: Boolean;
begin
  Failed := False;
  FirebirdTransactionSettingFactory := TFirebirdTransactionSettingFactory.New;
  try
    FirebirdTransactionSettingFactory.Build('unknown', _DataStorage);
  except
    on E: EDataStorage do
    begin
      CheckEquals('Object name "unknown" dont exists', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TFirebirdTransactionSettingFactoryTest.SetUp;
const
  DEPENDS_PATH = '..\..\..\dependencies\';
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'settings.ini');
end;

initialization

RegisterTests('Firebird test', [TFirebirdTransactionSettingFactoryTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
