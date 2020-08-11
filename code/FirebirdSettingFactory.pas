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
unit FirebirdSettingFactory;

interface

uses
  KeyCipher,
  DataStorage,
  ConnectionSetting, ConnectionSettingFactory,
  FirebirdTransactionSetting, FirebirdTransactionSettingFactory,
  FirebirdSetting;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(IFirebirdSetting FirebirdSetting objects))
  @member(
    Build Construct a new @link(IFirebirdSetting FirebirdSetting object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(IFirebirdSetting FirebirdSetting object))
  )
}
{$ENDREGION}
  IFirebirdSettingFactory = interface
    ['{5A5E45BE-4045-4FC1-916B-3E62A215FFA6}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdSetting;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionSettingFactory))
  Object factory for Firebird database Setting
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

  TFirebirdSettingFactory = class sealed(TInterfacedObject, IFirebirdSettingFactory)
  strict private
    _ConnectionSettingFactory: IConnectionSettingFactory;
    _TransactionSettingFactory: IFirebirdTransactionSettingFactory;
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdSetting;
    constructor Create(const Cipher: IKeyCipher);
    class function New(const Cipher: IKeyCipher): IFirebirdSettingFactory;
  end;

implementation

function TFirebirdSettingFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdSetting;
var
  Setting: IConnectionSetting;
  TransactionSetting: IFirebirdTransactionSetting;
begin
  Setting := _ConnectionSettingFactory.Build(ObjectName, DataStorage);
  TransactionSetting := _TransactionSettingFactory.Build(ObjectName, DataStorage);
  Result := TFirebirdSetting.New(Setting, DataStorage.ReadString(ObjectName, 'Collation'),
    DataStorage.ReadString(ObjectName, 'Version'), DataStorage.ReadInteger(ObjectName, 'Dialect'), TransactionSetting);
end;

constructor TFirebirdSettingFactory.Create(const Cipher: IKeyCipher);
begin
  _ConnectionSettingFactory := TConnectionSettingFactory.New(Cipher);
  _TransactionSettingFactory := TFirebirdTransactionSettingFactory.New;
end;

class function TFirebirdSettingFactory.New(const Cipher: IKeyCipher): IFirebirdSettingFactory;
begin
  Result := TFirebirdSettingFactory.Create(Cipher);
end;

end.
