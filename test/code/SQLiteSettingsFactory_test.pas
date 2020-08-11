{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit SQLiteSettingsFactory_test;

interface

uses
  SysUtils,
  DataStorage,
  SQLiteSetting, SQLiteSettingFactory,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TSQLiteSettingFactoryTest = class sealed(TTestCase)
  const
    DEPENDS_PATH = '..\..\..\dependencies\';
  strict private
    _DataStorage: IDataStorage;
    _SQLiteSettingFactory: ISQLiteSettingFactory;
  protected
    procedure SetUp; override;
  published
    procedure BuildReturnObject;
    procedure BuildEmptyValuesReturnException;
  end;

implementation

procedure TSQLiteSettingFactoryTest.BuildReturnObject;
var
  SQLiteSetting: ISQLiteSetting;
begin
  SQLiteSetting := _SQLiteSettingFactory.Build('SQLiteEngine', _DataStorage);
  CheckTrue(Assigned(SQLiteSetting));
  CheckEquals(DEPENDS_PATH + 'TEST.db3', SQLiteSetting.StorageName);
  CheckEquals(DEPENDS_PATH + 'SQLite3x64\sqlite3.dll', SQLiteSetting.LibraryPath);
  CheckFalse(Assigned(SQLiteSetting.Credential));
  CheckFalse(Assigned(SQLiteSetting.Server));
  CheckEquals('UTF16', SQLiteSetting.CharSet);
end;

procedure TSQLiteSettingFactoryTest.BuildEmptyValuesReturnException;
var
  Failed: Boolean;
begin
  Failed := False;
  try
    _SQLiteSettingFactory.Build('unknown', _DataStorage);
  except
    on E: EDataStorage do
    begin
      CheckEquals('Object name "unknown" dont exists', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TSQLiteSettingFactoryTest.SetUp;
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'Setting.ini');
  _SQLiteSettingFactory := TSQLiteSettingFactory.New;
end;

initialization

RegisterTests('Connection Setting test', [TSQLiteSettingFactoryTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
