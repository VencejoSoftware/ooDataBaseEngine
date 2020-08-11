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
unit ConnectionSettings;

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
  IConnectionSettings = interface
    ['{4C0F6BDE-CB21-4611-B2B2-4B7CE5B30820}']
    function Credential: ICredential;
    function StorageName: WideString;
    function LibraryPath: WideString;
    function Server: IServer;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionSettings))
  @member(Credential @seealso(IConnectionSettings.Credential))
  @member(StorageName @seealso(IConnectionSettings.StorageName))
  @member(LibraryPath @seealso(IConnectionSettings.LibraryPath))
  @member(Server @seealso(IConnectionSettings.Server))
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

  TConnectionSettings = class sealed(TInterfacedObject, IConnectionSettings)
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
      : IConnectionSettings;
  end;

implementation

function TConnectionSettings.Credential: ICredential;
begin
  Result := _Credential;
end;

function TConnectionSettings.StorageName: WideString;
begin
  Result := _StorageName;
end;

function TConnectionSettings.LibraryPath: WideString;
begin
  Result := _LibraryPath;
end;

function TConnectionSettings.Server: IServer;
begin
  Result := _Server;
end;

constructor TConnectionSettings.Create(const Credential: ICredential; const StorageName, LibraryPath: WideString;
  const Server: IServer);
begin
  _Credential := Credential;
  _StorageName := StorageName;
  _LibraryPath := LibraryPath;
  _Server := Server;
end;

class function TConnectionSettings.New(const Credential: ICredential; const StorageName, LibraryPath: WideString;
  const Server: IServer): IConnectionSettings;
begin
  Result := TConnectionSettings.Create(Credential, StorageName, LibraryPath, Server);
end;

end.
