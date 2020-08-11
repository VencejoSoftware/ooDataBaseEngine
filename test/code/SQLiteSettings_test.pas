{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit SQLiteSettings_test;

interface

uses
  SysUtils,
  SQLiteSettings,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TSQLiteSettingsTest = class sealed(TTestCase)
  published
    procedure EmbededUserIsEmpty;
    procedure EmbededPasswordIsEmpty;
    procedure EmbededStorageNameIsdb_sqlitedb3;
    procedure EmbededLibraryPathIsSQLite3dll;
  end;

implementation

procedure TSQLiteSettingsTest.EmbededUserIsEmpty;
begin
  CheckEquals(EmptyStr, TSQLiteSettings.NewEmbedded(EmptyStr, EmptyStr).Credential.User);
end;

procedure TSQLiteSettingsTest.EmbededPasswordIsEmpty;
begin
  CheckEquals(EmptyStr, TSQLiteSettings.NewEmbedded(EmptyStr, EmptyStr).Credential.Password);
end;

procedure TSQLiteSettingsTest.EmbededStorageNameIsdb_sqlitedb3;
begin
  CheckEquals('db_sqlite.db3', TSQLiteSettings.NewEmbedded('db_sqlite.db3', EmptyStr).StorageName);
end;

procedure TSQLiteSettingsTest.EmbededLibraryPathIsSQLite3dll;
begin
  CheckEquals('sqlite3.dll', TSQLiteSettings.NewEmbedded(EmptyStr, 'sqlite3.dll').LibraryPath);
end;

initialization

RegisterTest(TSQLiteSettingsTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
