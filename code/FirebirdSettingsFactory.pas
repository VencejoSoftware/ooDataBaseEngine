{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object factory to build Firebird connection settings objects
  @created(15/04/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FirebirdSettingsFactory;

interface

uses
  KeyCipher,
  DataStorage,
  ConnectionSettings, ConnectionSettingsFactory,
  FirebirdTransactionSettings, FirebirdTransactionSettingsFactory,
  FirebirdSettings;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(IFirebirdSettings FirebirdSettings objects))
  @member(
    Build Construct a new @link(IFirebirdSettings FirebirdSettings object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(IFirebirdSettings FirebirdSettings object))
  )
}
{$ENDREGION}
  IFirebirdSettingsFactory = interface
    ['{5A5E45BE-4045-4FC1-916B-3E62A215FFA6}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdSettings;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionSettingsFactory))
  Object factory for Firebird database settings
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

  TFirebirdSettingsFactory = class sealed(TInterfacedObject, IFirebirdSettingsFactory)
  strict private
    _ConnectionSettingsFactory: IConnectionSettingsFactory;
    _TransactionSettingsFactory: IFirebirdTransactionSettingsFactory;
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdSettings;
    constructor Create(const Cipher: IKeyCipher);
    class function New(const Cipher: IKeyCipher): IFirebirdSettingsFactory;
  end;

implementation

function TFirebirdSettingsFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage)
  : IFirebirdSettings;
var
  Settings: IConnectionSettings;
  TransactionSettings: IFirebirdTransactionSettings;
begin
  Settings := _ConnectionSettingsFactory.Build(ObjectName, DataStorage);
  TransactionSettings := _TransactionSettingsFactory.Build(ObjectName, DataStorage);
  Result := TFirebirdSettings.New(Settings, DataStorage.ReadString(ObjectName, 'Collation'),
    DataStorage.ReadString(ObjectName, 'Version'), DataStorage.ReadInteger(ObjectName, 'Dialect'), TransactionSettings);
end;

constructor TFirebirdSettingsFactory.Create(const Cipher: IKeyCipher);
begin
  _ConnectionSettingsFactory := TConnectionSettingsFactory.New(Cipher);
  _TransactionSettingsFactory := TFirebirdTransactionSettingsFactory.New;
end;

class function TFirebirdSettingsFactory.New(const Cipher: IKeyCipher): IFirebirdSettingsFactory;
begin
  Result := TFirebirdSettingsFactory.Create(Cipher);
end;

end.
