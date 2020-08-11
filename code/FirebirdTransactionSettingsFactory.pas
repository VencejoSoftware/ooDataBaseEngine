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
unit FirebirdTransactionSettingsFactory;

interface

uses
  KeyCipher,
  DataStorage,
  FirebirdTransactionSettings;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(IFirebirdTransactionSettings FirebirdTransactionSettings objects))
  @member(
    Build Construct a new @link(IFirebirdTransactionSettings transaction setting object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(IFirebirdTransactionSettings FirebirdTransactionSettings object))
  )
}
{$ENDREGION}
  IFirebirdTransactionSettingsFactory = interface
    ['{F404E4AC-AE7D-4FFD-B6B7-140C56D06A68}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdTransactionSettings;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IFirebirdTransactionSettingsFactory))
  @member(Build @seealso(IFirebirdTransactionSettingsFactory.Build))
  @member(Create Object constructor)
  @member(New Create a new @classname as interface)
}
{$ENDREGION}

  TFirebirdTransactionSettingsFactory = class sealed(TInterfacedObject, IFirebirdTransactionSettingsFactory)
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdTransactionSettings;
    class function New: IFirebirdTransactionSettingsFactory;
  end;

implementation

function TFirebirdTransactionSettingsFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage)
  : IFirebirdTransactionSettings;
var
  IsolationLevel: TFirebirdTransactionIsolationLevel;
  AccessMode: TFirebirdTransactionAccessMode;
  LockResolution: TFirebirdTransactionLockResolution;
  TableReservation: TFirebirdTransactionTableReservation;
  RecordVersion: TFirebirdTransactionRecordVersion;
  ExtraOptions: TFirebirdTransactionExtraSet;
begin

  Result := TFirebirdTransactionSettings.New(IsolationLevel, AccessMode, LockResolution, TableReservation,
    RecordVersion, ExtraOptions);
end;

class function TFirebirdTransactionSettingsFactory.New: IFirebirdTransactionSettingsFactory;
begin
  Result := TFirebirdTransactionSettingsFactory.Create;
end;

end.
