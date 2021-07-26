{$REGION 'documentation'}
{
  Copyright (c) 2021, Vencejo Software
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
  SysUtils, StrUtils, Types,
  RTTI,
  DataStorage,
  FirebirdTransactionSetting;

type
{$REGION 'documentation'}
{
  @abstract(Class for serialization errors)
}
{$ENDREGION}
  EFirebirdTransactionSettingFactory = class sealed(exception)
  end;

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
    ['{EEDED277-8A00-4E40-9D6E-53EDC2A57EAC}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdTransactionSetting;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IFirebirdTransactionSettingFactory))
  @member(
    StringToIsolationLevel Converts string to TFirebirdTransactionIsolationLevel
    @param(Value String value)
    @return(@link(TFirebirdTransactionIsolationLevel))
  )
  @member(
    StringToAccessMode Converts string to TFirebirdTransactionAccessMode
    @param(Value String value)
    @return(@link(TFirebirdTransactionAccessMode))
  )
  @member(
    StringToLockResolution Converts string to TFirebirdTransactionLockResolution
    @param(Value String value)
    @return(@link(TFirebirdTransactionLockResolution))
  )
  @member(
    StringToTableReservation Converts string to TFirebirdTransactionTableReservation
    @param(Value String value)
    @return(@link(TFirebirdTransactionTableReservation))
  )
  @member(
    StringToRecordVersion Converts string to TFirebirdTransactionRecordVersion
    @param(Value String value)
    @return(@link(TFirebirdTransactionRecordVersion))
  )
  @member(
    StringToExtraOptions Converts string to TFirebirdTransactionExtraSet
    @param(Value String value)
    @return(@link(TFirebirdTransactionExtraSet))
  )
  @member(Build @seealso(IFirebirdTransactionSettingFactory.Build))
  @member(Create Object constructor)
  @member(New Create a new @classname as interface)
}
{$ENDREGION}

  TFirebirdTransactionSettingFactory = class sealed(TInterfacedObject, IFirebirdTransactionSettingFactory)
  private
    function StringToIsolationLevel(const Value: String): TFirebirdTransactionIsolationLevel;
    function StringToAccessMode(const Value: String): TFirebirdTransactionAccessMode;
    function StringToLockResolution(const Value: String): TFirebirdTransactionLockResolution;
    function StringToTableReservation(const Value: String): TFirebirdTransactionTableReservation;
    function StringToRecordVersion(const Value: String): TFirebirdTransactionRecordVersion;
    function StringToExtraOptions(const Value: String): TFirebirdTransactionExtraSet;
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): IFirebirdTransactionSetting;
    class function New: IFirebirdTransactionSettingFactory;
  end;

implementation

function TFirebirdTransactionSettingFactory.StringToIsolationLevel(const Value: String)
  : TFirebirdTransactionIsolationLevel;
begin
  Result := TRttiEnumerationType.GetValue<TFirebirdTransactionIsolationLevel>(Value);
end;

function TFirebirdTransactionSettingFactory.StringToAccessMode(const Value: String): TFirebirdTransactionAccessMode;
begin
  Result := TRttiEnumerationType.GetValue<TFirebirdTransactionAccessMode>(Value);
end;

function TFirebirdTransactionSettingFactory.StringToLockResolution(const Value: String)
  : TFirebirdTransactionLockResolution;
begin
  Result := TRttiEnumerationType.GetValue<TFirebirdTransactionLockResolution>(Value);
end;

function TFirebirdTransactionSettingFactory.StringToTableReservation(const Value: String)
  : TFirebirdTransactionTableReservation;
begin
  Result := TRttiEnumerationType.GetValue<TFirebirdTransactionTableReservation>(Value);
end;

function TFirebirdTransactionSettingFactory.StringToRecordVersion(const Value: String)
  : TFirebirdTransactionRecordVersion;
begin
  Result := TRttiEnumerationType.GetValue<TFirebirdTransactionRecordVersion>(Value);
end;

function TFirebirdTransactionSettingFactory.StringToExtraOptions(const Value: String): TFirebirdTransactionExtraSet;
var
  SplittedItems: TStringDynArray;
  ItemValue: String;
  ExtraOption: TFirebirdTransactionExtra;
begin
  Result := [];
  SplittedItems := SplitString(Value, ',');
  for ItemValue in SplittedItems do
  begin
    ExtraOption := TRttiEnumerationType.GetValue<TFirebirdTransactionExtra>(ItemValue);
    Include(Result, ExtraOption);
  end;
end;

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
  IsolationLevel := StringToIsolationLevel(DataStorage.ReadString(ObjectName, 'Transaction.IsolationLevel'));
  AccessMode := StringToAccessMode(DataStorage.ReadString(ObjectName, 'Transaction.AccessMode'));
  LockResolution := StringToLockResolution(DataStorage.ReadString(ObjectName, 'Transaction.LockResolution'));
  TableReservation := StringToTableReservation(DataStorage.ReadString(ObjectName, 'Transaction.TableReservation'));
  RecordVersion := StringToRecordVersion(DataStorage.ReadString(ObjectName, 'Transaction.RecordVersion'));
  ExtraOptions := StringToExtraOptions(DataStorage.ReadString(ObjectName, 'Transaction.ExtraOptions'));
  Result := TFirebirdTransactionSetting.New(IsolationLevel, AccessMode, LockResolution, TableReservation, RecordVersion,
    ExtraOptions);
end;

class function TFirebirdTransactionSettingFactory.New: IFirebirdTransactionSettingFactory;
begin
  Result := TFirebirdTransactionSettingFactory.Create;
end;

end.
