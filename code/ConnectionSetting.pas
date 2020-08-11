{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define the settings of a connection
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ConnectionSetting;

interface

uses
  Credential,
  Server;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the settings of a connection)
  @member(
    Credential @link(ICredential Object connection credentials)
    @return(Object with the connection credentials)
  )
  @member(
    StorageName Path to the data media storage
    @return(Path to the data media storage)
  )
  @member(
    Server Server object
    @return(@link(IServer Server object))
  )
}
{$ENDREGION}
  IConnectionSetting = interface
    ['{4C0F6BDE-CB21-4611-B2B2-4B7CE5B30820}']
    function Credential: ICredential;
    function StorageName: WideString;
    function LibraryPath: WideString;
    function Server: IServer;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionSetting))
  @member(Credential @seealso(IConnectionSetting.Credential))
  @member(StorageName @seealso(IConnectionSetting.StorageName))
  @member(LibraryPath @seealso(IConnectionSetting.LibraryPath))
  @member(Server @seealso(IConnectionSetting.Server))
  @member(
    Create Object constructor
    @param(Credential @link(ICredential Object connection credentials))
    @param(StorageName Path to the data media storage)
    @param(LibraryPath Path to library driver)
    @param(Server @link(IServer Server object))
  )
  @member(
    New Create a new @classname as interface
    @param(Credential @link(ICredential Object connection credentials))
    @param(StorageName Path to the data media storage)
    @param(LibraryPath Path to library driver)
    @param(Server @link(IServer Server object))
  )
}
{$ENDREGION}

  TConnectionSetting = class sealed(TInterfacedObject, IConnectionSetting)
  strict private
    _Credential: ICredential;
    _StorageName, _LibraryPath: WideString;
    _Server: IServer;
  public
    function Credential: ICredential;
    function StorageName: WideString;
    function LibraryPath: WideString;
    function Server: IServer;
    constructor Create(const Credential: ICredential; const StorageName, LibraryPath: WideString;
      const Server: IServer);
    class function New(const Credential: ICredential; const StorageName, LibraryPath: WideString; const Server: IServer)
      : IConnectionSetting;
  end;

implementation

function TConnectionSetting.Credential: ICredential;
begin
  Result := _Credential;
end;

function TConnectionSetting.StorageName: WideString;
begin
  Result := _StorageName;
end;

function TConnectionSetting.LibraryPath: WideString;
begin
  Result := _LibraryPath;
end;

function TConnectionSetting.Server: IServer;
begin
  Result := _Server;
end;

constructor TConnectionSetting.Create(const Credential: ICredential; const StorageName, LibraryPath: WideString;
  const Server: IServer);
begin
  _Credential := Credential;
  _StorageName := StorageName;
  _LibraryPath := LibraryPath;
  _Server := Server;
end;

class function TConnectionSetting.New(const Credential: ICredential; const StorageName, LibraryPath: WideString;
  const Server: IServer): IConnectionSetting;
begin
  Result := TConnectionSetting.Create(Credential, StorageName, LibraryPath, Server);
end;

end.
