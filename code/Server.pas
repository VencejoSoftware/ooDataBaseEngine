{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define the server connection credential settings
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit Server;

interface

uses
  SysUtils;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the server connection settings)
  @member(
    Address Server address
    @return(Address of server)
  )
  @member(
    Port Connection port
    @return(Number of port)
  )
}
{$ENDREGION}
  IServer = interface
    ['{980298B0-A62E-4D64-80A1-A02055FBE51A}']
    function Address: WideString;
    function Port: Word;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IServer))
  @member(Address @seealso(IServer.Address))
  @member(Port @seealso(IServer.Port))
  @member(
    Create Object constructor
    @param(Address IP/address to use)
    @param(Port Port to connect)
  )
  @member(
    New Creates a new @classname as interface
    @param(Address IP/address to use)
    @param(Port Port to connect)
  )
  @member(
    NewByAddress Creates a new @classname as interface using "ADDRESS:PORT" format
    @param(FullAddress Formatted text)
  )
}
{$ENDREGION}

  TServer = class sealed(TInterfacedObject, IServer)
  strict private
    _Address: WideString;
    _Port: Word;
  public
    function Address: WideString;
    function Port: Word;
    constructor Create(const Address: WideString; Port: Word);
    class function New(const Address: WideString; Port: Word): IServer;
    class function NewByAddress(const FullAddress: WideString): IServer; static;
  end;

implementation

function TServer.Address: WideString;
begin
  Result := _Address;
end;

function TServer.Port: Word;
begin
  Result := _Port;
end;

constructor TServer.Create(const Address: WideString; Port: Word);
begin
  _Address := Address;
  _Port := Port;
end;

class function TServer.New(const Address: WideString; Port: Word): IServer;
begin
  Result := TServer.Create(Address, Port);
end;

class function TServer.NewByAddress(const FullAddress: WideString): IServer;
var
  Address: WideString;
  Port: Word;
  PosSep: Integer;
begin
  PosSep := Pos(':', FullAddress);
  if PosSep > 0 then
  begin
    Address := Copy(FullAddress, 1, Pred(PosSep));
    Port := StrToInt(Copy(FullAddress, Succ(PosSep)));
  end
  else
  begin
    Address := FullAddress;
    Port := 0;
  end;
  Result := TServer.New(Address, Port);
end;

end.
