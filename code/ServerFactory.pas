{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object factory to build Server objects
  @created(15/04/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ServerFactory;

interface

uses
  DataStorage,
  Server;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(IServer Server objects))
  @member(
    Build Construct a new @link(IServer server object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(IServer Server object))
  )
}
{$ENDREGION}
  IServerFactory = interface
    ['{48B3EAA1-9CF5-4F24-AB8D-B58691B1E6CB}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IServer;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IServerFactory))
  @member(Build @seealso(IServerFactory.Build))
  @member(New Creates a new @classname as interface)
}
{$ENDREGION}

  TServerFactory = class sealed(TInterfacedObject, IServerFactory)
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IServer;
    class function New: IServerFactory;
  end;

implementation

function TServerFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage): IServer;
var
  Address: WideString;
  Port: Word;
begin
  Address := DataStorage.ReadString(ObjectName, 'server.address');
  Port := DataStorage.ReadInteger(ObjectName, 'server.port');
  if (Length(Address) > 0) or (Port <> 0) then
    Result := TServer.New(Address, Port)
  else
    Result := nil;
end;

class function TServerFactory.New: IServerFactory;
begin
  Result := TServerFactory.Create;
end;

end.
