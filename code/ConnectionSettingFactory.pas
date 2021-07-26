{$REGION 'documentation'}
{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object factory to build connection settings objects
  @created(15/04/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ConnectionSettingFactory;

interface

uses
  SysUtils,
  KeyCipher,
  DataStorage,
  Server, ServerFactory,
  Credential, CredentialFactory,
  ConnectionSetting;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(IConnectionSetting ConnectionSetting objects))
  @member(
    Build Construct a new @link(IConnectionSetting ConnectionSetting object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(IConnectionSetting ConnectionSetting object))
  )
}
{$ENDREGION}
  IConnectionSettingFactory = interface
    ['{DAEDA43C-5798-4FD7-AAD7-2347DD3DA62A}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IConnectionSetting;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionSettingFactory))
  @member(Build @seealso(IConnectionSettingFactory.Build))
  @member(
    Create Object constructor
    @param(Cipher Encoder/decoder for sensible data)
  )
  @member(
    New Create a new @classname as interface
    @param(Cipher Encoder/decoder for sensible data)
  )
}
{$ENDREGION}

  TConnectionSettingFactory = class sealed(TInterfacedObject, IConnectionSettingFactory)
  strict private
    _ServerFactory: IServerFactory;
    _CredentialFactory: ICredentialFactory;
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IConnectionSetting;
    constructor Create(const Cipher: IKeyCipher);
    class function New(const Cipher: IKeyCipher): IConnectionSettingFactory;
  end;

implementation

function TConnectionSettingFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage)
  : IConnectionSetting;
var
  Credential: ICredential;
  Server: IServer;
  StorageName, LibrayPath: WideString;
begin
  Credential := _CredentialFactory.Build(ObjectName, DataStorage);
  Server := _ServerFactory.Build(ObjectName, DataStorage);
  StorageName := DataStorage.ReadString(ObjectName, 'StorageName');
  if FileExists(StorageName) then
    StorageName := ExpandFileName(StorageName);
  LibrayPath := ExpandFileName(DataStorage.ReadString(ObjectName, 'LibrayPath'));
  Result := TConnectionSetting.New(Credential, StorageName, LibrayPath, Server);
end;

constructor TConnectionSettingFactory.Create(const Cipher: IKeyCipher);
begin
  _ServerFactory := TServerFactory.New;
  _CredentialFactory := TCredentialFactory.New(Cipher);
end;

class function TConnectionSettingFactory.New(const Cipher: IKeyCipher): IConnectionSettingFactory;
begin
  Result := TConnectionSettingFactory.Create(Cipher);
end;

end.
