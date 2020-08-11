{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object factory to build transaction settings objects
  @created(11/08/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FirebirdTransactionSettingFactory;

interface

uses
  KeyCipher,
  DataStorage,
  FirebirdTransactionSetting;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(IFirebirdTransactionSetting FirebirdTransactionSetting objects))
  @member(
    Build Construct a new @link(IFirebirdTransactionSetting transaction setting object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(IFirebirdTransactionSetting FirebirdTransactionSetting object))
  )
}
{$ENDREGION}
  IFirebirdTransactionSettingFactory = interface
    ['{F404E4AC-AE7D-4FFD-B6B7-140C56D06A68}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdTransactionSetting;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IFirebirdTransactionSettingFactory))
  @member(Build @seealso(IFirebirdTransactionSettingFactory.Build))
  @member(Create Object constructor)
  @member(New Create a new @classname as interface)
}
{$ENDREGION}

  TFirebirdTransactionSettingFactory = class sealed(TInterfacedObject, IFirebirdTransactionSettingFactory)
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdTransactionSetting;
    class function New: IFirebirdTransactionSettingFactory;
  end;

implementation

function TFirebirdTransactionSettingFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage)
  : IFirebirdTransactionSetting;
var
  IsolationLevel: TFirebirdTransactionIsolationLevel;
  AccessMode: TFirebirdTransactionAccessMode;
  LockResolution: TFirebirdTransactionLockResolution;
  TableReservation: TFirebirdTransactionTableReservation;
  RecordVersion: TFirebirdTransactionRecordVersion;
  ExtraOptions: TFirebirdTransactionExtraSet;
begin

  Result := TFirebirdTransactionSetting.New(IsolationLevel, AccessMode, LockResolution, TableReservation, RecordVersion,
    ExtraOptions);
end;

class function TFirebirdTransactionSettingFactory.New: IFirebirdTransactionSettingFactory;
begin
  Result := TFirebirdTransactionSettingFactory.Create;
end;

end.
