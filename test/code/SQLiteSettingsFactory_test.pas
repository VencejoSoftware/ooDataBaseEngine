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
  SQLiteSettings, SQLiteSettingsFactory,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TSQLiteSettingsFactoryTest = class sealed(TTestCase)
  const
    DEPENDS_PATH = '..\..\..\dependencies\';
  strict private
    _DataStorage: IDataStorage;
    _SQLiteSettingsFactory: ISQLiteSettingsFactory;
  protected
    procedure SetUp; override;
  published
    procedure BuildReturnObject;
    procedure BuildEmptyValuesReturnException;
  end;

implementation

procedure TSQLiteSettingsFactoryTest.BuildReturnObject;
var
  SQLiteSettings: ISQLiteSettings;
begin
  SQLiteSettings := _SQLiteSettingsFactory.Build('SQLiteEngine', _DataStorage);
  CheckTrue(Assigned(SQLiteSettings));
  CheckEquals(DEPENDS_PATH + 'TEST.db3', SQLiteSettings.StorageName);
  CheckEquals(DEPENDS_PATH + 'SQLite3x64\sqlite3.dll', SQLiteSettings.LibraryPath);
  CheckFalse(Assigned(SQLiteSettings.Credential));
  CheckFalse(Assigned(SQLiteSettings.Server));
  CheckEquals('UTF16', SQLiteSettings.CharSet);
end;

procedure TSQLiteSettingsFactoryTest.BuildEmptyValuesReturnException;
var
  Failed: Boolean;
begin
  Failed := False;
  try
    _SQLiteSettingsFactory.Build('unknown', _DataStorage);
  except
    on E: EDataStorage do
    begin
      CheckEquals('Object name "unknown" dont exists', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TSQLiteSettingsFactoryTest.SetUp;
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'settings.ini');
  _SQLiteSettingsFactory := TSQLiteSettingsFactory.New;
end;

initialization

RegisterTests('Connection settings test', [TSQLiteSettingsFactoryTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
