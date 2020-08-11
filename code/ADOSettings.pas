{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define the settings for a ADO based connection
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ADOSettings;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSettings;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the settings for a ADO based connection)
  @member(
    ConnectionString Connection string
    @return(Text ADO connection string)
  )
}
{$ENDREGION}
  IADOSettings = interface(IConnectionSettings)
    ['{413D8BC7-1581-49B7-96E7-BD830232BE23}']
    function ConnectionString: WideString;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(ISQLiteSettings))
  @member(Credential @seealso(IConnectionSettings.Credential))
  @member(StorageName @seealso(IConnectionSettings.StorageName))
  @member(LibraryPath @seealso(IConnectionSettings.LibraryPath))
  @member(Server @seealso(IConnectionSettings.Server))
  @member(ConnectionString @seealso(ISQLiteSettings.ConnectionString))
  @member(
    Create Object constructor
    @param(Settings @link(IConnectionSettings Object with base connection settings))
    @param(ConnectionString Connection ConnectionString)
  )
  @member(
    New Create a new @classname as interface
    @param(Settings @link(IConnectionSettings Object with base connection settings))
    @param(ConnectionString Connection ConnectionString)
  )
}
{$ENDREGION}

  TADOSettings = class sealed(TInterfacedObject, IADOSettings)
  strict private
    _Settings: IConnectionSettings;
    _ConnectionString: WideString;
  public
    function Credential: ICredential;
    function StorageName: WideString;
    function LibraryPath: WideString;
    function Server: IServer;
    function ConnectionString: WideString;
    constructor Create(const Settings: IConnectionSettings; const Provider, DataSource: WideString);
    class function New(const Settings: IConnectionSettings; const Provider, DataSource: WideString): IADOSettings;
  end;

implementation

function TADOSettings.Credential: ICredential;
begin
  Result := _Settings.Credential;
end;

function TADOSettings.StorageName: WideString;
begin
  Result := _Settings.StorageName;
end;

function TADOSettings.LibraryPath: WideString;
begin
  Result := _Settings.LibraryPath;
end;

function TADOSettings.Server: IServer;
begin
  Result := _Settings.Server;
end;

function TADOSettings.ConnectionString: WideString;
begin
  Result := _ConnectionString;
end;

constructor TADOSettings.Create(const Settings: IConnectionSettings; const Provider, DataSource: WideString);
begin
  _Settings := Settings;
  _ConnectionString := Format('Provider=%s;Data Source=%s; User Id=%s; Password=%s',
    [Provider, DataSource, Settings.Credential.User, Settings.Credential.Password]);
end;

class function TADOSettings.New(const Settings: IConnectionSettings; const Provider, DataSource: WideString)
  : IADOSettings;
begin
  Result := TADOSettings.Create(Settings, Provider, DataSource);
end;

end.
