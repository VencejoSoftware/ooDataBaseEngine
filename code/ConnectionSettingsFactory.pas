{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object factory to build connection settings objects
  @created(15/04/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ConnectionSettingsFactory;

interface

uses
  KeyCipher,
  DataStorage,
  Server, ServerFactory,
  Credential, CredentialFactory,
  ConnectionSettings;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(IConnectionSettings ConnectionSettings objects))
  @member(
    Build Construct a new @link(IConnectionSettings ConnectionSettings object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(IConnectionSettings ConnectionSettings object))
  )
}
{$ENDREGION}
  IConnectionSettingsFactory = interface
    ['{DAEDA43C-5798-4FD7-AAD7-2347DD3DA62A}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IConnectionSettings;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionSettingsFactory))
  @member(Build @seealso(IConnectionSettingsFactory.Build))
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

  TConnectionSettingsFactory = class sealed(TInterfacedObject, IConnectionSettingsFactory)
  strict private
    _ServerFactory: IServerFactory;
    _CredentialFactory: ICredentialFactory;
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IConnectionSettings;
    constructor Create(const Cipher: IKeyCipher);
    class function New(const Cipher: IKeyCipher): IConnectionSettingsFactory;
  end;

implementation

function TConnectionSettingsFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage)
  : IConnectionSettings;
var
  Credential: ICredential;
  Server: IServer;
begin
  Credential := _CredentialFactory.Build(ObjectName, DataStorage);
  Server := _ServerFactory.Build(ObjectName, DataStorage);
  Result := TConnectionSettings.New(Credential, DataStorage.ReadString(ObjectName, 'StorageName'),
    DataStorage.ReadString(ObjectName, 'LibrayPath'), Server);
end;

constructor TConnectionSettingsFactory.Create(const Cipher: IKeyCipher);
begin
  _ServerFactory := TServerFactory.New;
  _CredentialFactory := TCredentialFactory.New(Cipher);
end;

class function TConnectionSettingsFactory.New(const Cipher: IKeyCipher): IConnectionSettingsFactory;
begin
  Result := TConnectionSettingsFactory.Create(Cipher);
end;

end.
