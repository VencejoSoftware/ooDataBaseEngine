{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit SQLiteSettings_test;

interface

uses
  SysUtils,
  SQLiteSetting,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TSQLiteSettingTest = class sealed(TTestCase)
  published
    procedure EmbededUserIsEmpty;
    procedure EmbededPasswordIsEmpty;
    procedure EmbededStorageNameIsdb_sqlitedb3;
    procedure EmbededLibraryPathIsSQLite3dll;
  end;

implementation

procedure TSQLiteSettingTest.EmbededUserIsEmpty;
begin
  CheckEquals(EmptyStr, TSQLiteSetting.NewEmbedded(EmptyStr, EmptyStr).Credential.User);
end;

procedure TSQLiteSettingTest.EmbededPasswordIsEmpty;
begin
  CheckEquals(EmptyStr, TSQLiteSetting.NewEmbedded(EmptyStr, EmptyStr).Credential.Password);
end;

procedure TSQLiteSettingTest.EmbededStorageNameIsdb_sqlitedb3;
begin
  CheckEquals('db_sqlite.db3', TSQLiteSetting.NewEmbedded('db_sqlite.db3', EmptyStr).StorageName);
end;

procedure TSQLiteSettingTest.EmbededLibraryPathIsSQLite3dll;
begin
  CheckEquals('sqlite3.dll', TSQLiteSetting.NewEmbedded(EmptyStr, 'sqlite3.dll').LibraryPath);
end;

initialization

RegisterTest('SQLite test', TSQLiteSettingTest {$IFNDEF FPC}.Suite {$ENDIF});

end.
