{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit DataStorage_test;

interface

uses
  SysUtils,
  DataStorage,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TINIDataStorageTest = class sealed(TTestCase)
  strict private
    _DataStorage: IDataStorage;
  protected
    procedure SetUp; override;
  published
    procedure ReadStringReturnText;
    procedure ReadIntegerReturn666;
  end;

implementation

procedure TINIDataStorageTest.ReadStringReturnText;
begin
  CheckEquals('Text', _DataStorage.ReadString('test', 'text_field'));
end;

procedure TINIDataStorageTest.ReadIntegerReturn666;
begin
  CheckEquals(666, _DataStorage.ReadInteger('test', 'integer_field'));
end;

procedure TINIDataStorageTest.SetUp;
const
  DEPENDS_PATH = '..\..\..\dependencies\';
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'settings.ini');
end;

initialization

RegisterTests('DataStorageTest test', [TINIDataStorageTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
