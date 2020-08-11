{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit Server_test;

interface

uses
  Classes, SysUtils,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF},
  Server;

type
  TServerTest = class sealed(TTestCase)
  strict private
    _Server: IServer;
  public
    procedure SetUp; override;
  published
    procedure AddressIs127_0_0_1;
    procedure PortIs666;
    procedure NewByAddressIsSRV01_Port29;
  end;

implementation

procedure TServerTest.AddressIs127_0_0_1;
begin
  CheckEquals('127.0.0.1', _Server.Address);
end;

procedure TServerTest.PortIs666;
begin
  CheckEquals(666, _Server.Port);
end;

procedure TServerTest.NewByAddressIsSRV01_Port29;
var
  Server: IServer;
begin
  Server := TServer.NewByAddress('SRV01:25');
  CheckEquals('SRV01', Server.Address);
  CheckEquals(25, Server.Port);
end;

procedure TServerTest.SetUp;
begin
  inherited;
  _Server := TServer.New('127.0.0.1', 666);
end;

initialization

RegisterTests('Server test', [TServerTest.Suite]);

end.
