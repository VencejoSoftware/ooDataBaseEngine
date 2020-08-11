{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ServerFactory_test;

interface

uses
  SysUtils,
  DataStorage,
  Server, ServerFactory,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TServerFactoryTest = class sealed(TTestCase)
  strict private
    _DataStorage: IDataStorage;
    _ServerFactory: IServerFactory;
  protected
    procedure SetUp; override;
  published
    procedure BuildReturnObject;
    procedure BuildEmptyValuesReturnException;
  end;

implementation

procedure TServerFactoryTest.BuildReturnObject;
var
  Server: IServer;
begin
  Server := _ServerFactory.Build('FirebirdEngine', _DataStorage);
  CheckTrue(Assigned(Server));
  CheckEquals('localhost', Server.Address);
  CheckEquals(3050, Server.Port);
end;

procedure TServerFactoryTest.BuildEmptyValuesReturnException;
var
  Failed: Boolean;
begin
  Failed := False;
  try
    _ServerFactory.Build('unknown', _DataStorage);
  except
    on E: EDataStorage do
    begin
      CheckEquals('Object name "unknown" dont exists', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TServerFactoryTest.SetUp;
const
  DEPENDS_PATH = '..\..\..\dependencies\';
begin
  inherited;
  _DataStorage := TINIDataStorage.New(DEPENDS_PATH + 'settings.ini');
  _ServerFactory := TServerFactory.New;
end;

initialization

RegisterTests('Connection settings test', [TServerFactoryTest {$IFNDEF FPC}.Suite {$ENDIF}]);

end.
