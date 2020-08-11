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
unit ADOSetting;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSetting;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the Setting for a ADO based connection)
  @member(
    ConnectionString Connection string
    @return(Text ADO connection string)
  )
}
{$ENDREGION}
  IADOSetting = interface(IConnectionSetting)
    ['{413D8BC7-1581-49B7-96E7-BD830232BE23}']
    function ConnectionString: WideString;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(ISQLiteSetting))
  @member(Credential @seealso(IConnectionSetting.Credential))
  @member(StorageName @seealso(IConnectionSetting.StorageName))
  @member(LibraryPath @seealso(IConnectionSetting.LibraryPath))
  @member(Server @seealso(IConnectionSetting.Server))
  @member(ConnectionString @seealso(ISQLiteSetting.ConnectionString))
  @member(
    Create Object constructor
    @param(Setting @link(IConnectionSetting Object with base connection Setting))
    @param(ConnectionString Connection ConnectionString)
  )
  @member(
    New Create a new @classname as interface
    @param(Setting @link(IConnectionSetting Object with base connection Setting))
    @param(ConnectionString Connection ConnectionString)
  )
}
{$ENDREGION}

  TADOSetting = class sealed(TInterfacedObject, IADOSetting)
  strict private
    _Setting: IConnectionSetting;
    _ConnectionString: WideString;
  public
    function Credential: ICredential;
    function StorageName: WideString;
    function LibraryPath: WideString;
    function Server: IServer;
    function ConnectionString: WideString;
    constructor Create(const Setting: IConnectionSetting; const Provider, DataSource: WideString);
    class function New(const Setting: IConnectionSetting; const Provider, DataSource: WideString): IADOSetting;
  end;

implementation

function TADOSetting.Credential: ICredential;
begin
  Result := _Setting.Credential;
end;

function TADOSetting.StorageName: WideString;
begin
  Result := _Setting.StorageName;
end;

function TADOSetting.LibraryPath: WideString;
begin
  Result := _Setting.LibraryPath;
end;

function TADOSetting.Server: IServer;
begin
  Result := _Setting.Server;
end;

function TADOSetting.ConnectionString: WideString;
begin
  Result := _ConnectionString;
end;

constructor TADOSetting.Create(const Setting: IConnectionSetting; const Provider, DataSource: WideString);
begin
  _Setting := Setting;
  _ConnectionString := Format('Provider=%s;Data Source=%s; User Id=%s; Password=%s',
    [Provider, DataSource, Setting.Credential.User, Setting.Credential.Password]);
end;

class function TADOSetting.New(const Setting: IConnectionSetting; const Provider, DataSource: WideString): IADOSetting;
begin
  Result := TADOSetting.Create(Setting, Provider, DataSource);
end;

end.
