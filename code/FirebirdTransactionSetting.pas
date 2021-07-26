{$REGION 'documentation'}
{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define the firebird transaction settings
  @created(11/08/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FirebirdTransactionSetting;

interface

uses
  SysUtils;

type
{$REGION 'documentation'}
{
  Enum for firebird transaction isolation level (read https://wiki.lazarus.freepascal.org/Firebird#Advanced_transactions)
  @value Consistency Also called Table Stability: stable, serializable view of data, but locks tables. Unlikely you will need this
  @value Concurrency Also called Snapshot: you see database as it was when the transaction started. Has more overhead than isc_tpb_read_committed. Better than ANSI Serializable because it has no phantom reads.
  @value ReadCommited You see all changes committed by other transactions
}
{$ENDREGION}
  TFirebirdTransactionIsolationLevel = (Consistency, Concurrency, ReadCommited);

{$REGION 'documentation'}
{
  Enum for firebird transaction isolation level (read https://wiki.lazarus.freepascal.org/Firebird#Advanced_transactions)
  @value ReadMode Read permission mode
  @value WriteMode Read and write permission mode
}
{$ENDREGION}
  TFirebirdTransactionAccessMode = (ReadMode, WriteMode);

{$REGION 'documentation'}
{
  Enum for firebird transaction lock resolution (read https://wiki.lazarus.freepascal.org/Firebird#Advanced_transactions)
  @value NoWaitForLock If another transaction is editing the record then don't wait
  @value WaitForLock If another transaction is editing the record then wait for it to finish. Can mitigate "live locks" in heavy contention
}
{$ENDREGION}
  TFirebirdTransactionLockResolution = (NoWaitForLock, WaitForLock);

{$REGION 'documentation'}
{
  Enum for firebird to deal with locking entire tables (read https://wiki.lazarus.freepascal.org/Firebird#Advanced_transactions)
  @value Shared First specify this, then either lock_read or lock_write for one or more tables. Shared read or write mode for tables.
  @value ProtecteAccess First specify this, then either lock_read or lock_write for one or more tables. Lock on tables; can allow deadlock-free operation at the cost of delayed transactions
  @value LockRead Set a read lock. Specify which table to lock, e.g. isc_tpb_lock_read=CUSTOMERS
  @value LockWrite Set a read/write lock. Specify which table to lock, e.g. isc_tpb_lock_read=CUSTOMERS
}
{$ENDREGION}
  TFirebirdTransactionTableReservation = (Shared, ProtecteAccess, LockRead, LockWrite);

{$REGION 'documentation'}
{
  Enum for firebird to deal with locking entire tables (read https://wiki.lazarus.freepascal.org/Firebird#Advanced_transactions)
  @value NoRecVersion Only newest record version is read. Can be useful for batch/bulk insert operations together with isc_tpb_read_committed)
  @value RecVersion The latest committed version is read, even when the other transaction has other uncommitted changes note: verify this. More overhead than isc_tpb_no_rec_version
}
{$ENDREGION}
  TFirebirdTransactionRecordVersion = (NoRecVersion, RecVersion);

{$REGION 'documentation'}
{
  Enum for firebird transaction extra options (read https://wiki.lazarus.freepascal.org/Firebird#Advanced_transactions)
  @value Exclusive Translates to protected in Firebird
  @value VerbTime Related to deferred constraints, which could execute at verb time or commit time. Firebird: not implemented, always use verb time
  @value CommitTime Related to deferred constraints, which could execute at verb time or commit time. Firebird: not implemented, always use verb time
  @value IgnoreLimbo Ignores the records created by transactions in limbo. Limbo transactions are failing two-phase commits in multi-database transactions. Unlikely that you will need this feature
  @value AutoCommit Autocommit this transaction: every statement is a separate transaction. Probably specifically for JayBird JDBC driver
  @value RestartRequest Apparently looks for requests in the connection which had been active in another transaction, unwinds them, and restarts them under the new transaction
  @value NoAutoUndo Disable transaction-level undo log, handy for getting max throughput when performing a batch update. Has no effect when only reading data
  @value LockTimeout Specify number of seconds to wait for lock release, if you use isc_tpb_wait. If this value is reached without lock release, an error is reported
}
{$ENDREGION}
  TFirebirdTransactionExtra = (Exclusive, VerbTime, CommitTime, IgnoreLimbo, AutoCommit, RestartRequest, NoAutoUndo,
    LockTimeout);
  TFirebirdTransactionExtraSet = set of TFirebirdTransactionExtra;
{$REGION 'documentation'}
{
  @abstract(String array type with firebird transaction options)
}
{$ENDREGION}
  TFirebirdTransactionParams = TArray<String>;

{$REGION 'documentation'}
{
  @abstract(Object to define the Firebird transactions options)
  @member(
    IsolationLevel Transaction isolation level
    @return(@link(IsolationLevel))
  )
  @member(
    AccessMode Transaction table access mode
    @return(@link(TFirebirdTransactionAccessMode))
  )
  @member(
    LockResolution Transaction lock resolution
    @return(@link(TFirebirdTransactionLockResolution))
  )
  @member(
    TableReservation Transaction table reservation
    @return(@link(TFirebirdTransactionTableReservation))
  )
  @member(
    RecordVersion Transaction record version mode
    @return(@link(TFirebirdTransactionRecordVersion))
  )
  @member(
    TransactionExtra Transaction extra options
    @return(@link(TFirebirdTransactionExtraSet))
  )
  @member(
    ToStringArray Convert transaction settings to array of string
    @return(@link(TFirebirdTransactionParams))
  )
}
{$ENDREGION}

  IFirebirdTransactionSetting = interface
    ['{A4FBF688-BE4A-4CB1-9D8A-270B9D63F02E}']
    function IsolationLevel: TFirebirdTransactionIsolationLevel;
    function AccessMode: TFirebirdTransactionAccessMode;
    function LockResolution: TFirebirdTransactionLockResolution;
    function TableReservation: TFirebirdTransactionTableReservation;
    function RecordVersion: TFirebirdTransactionRecordVersion;
    function ExtraOptions: TFirebirdTransactionExtraSet;
    function ToStringArray: TFirebirdTransactionParams;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IFirebirdTransactionSetting))
  @member(IsolationLevel @seealso(IFirebirdTransactionSetting.IsolationLevel))
  @member(AccessMode @seealso(IFirebirdTransactionSetting.AccessMode))
  @member(LockResolution @seealso(IFirebirdTransactionSetting.LockResolution))
  @member(TableReservation @seealso(IFirebirdTransactionSetting.TableReservation))
  @member(RecordVersion @seealso(IFirebirdTransactionSetting.RecordVersion))
  @member(ExtraOptions @seealso(IFirebirdTransactionSetting.ExtraOptions))
  @member(ToStringArray @seealso(IFirebirdTransactionSetting.ToStringArray))
  @member(
    Create Object constructor
    @param(IsolationLevel Isolation level)
    @param(AccessMode Access Mode)
    @param(LockResolution Lock Resolution)
    @param(TableReservation Table Reservation)
    @param(RecordVersion Record Version)
    @param(ExtraOptions Extra options)
  )
  @member(
    New Create a new @classname as interface
    @param(IsolationLevel Isolation level)
    @param(AccessMode Access Mode)
    @param(LockResolution Lock Resolution)
    @param(TableReservation Table Reservation)
    @param(RecordVersion Record Version)
    @param(ExtraOptions Extra options)
  )
}
{$ENDREGION}

  TFirebirdTransactionSetting = class sealed(TInterfacedObject, IFirebirdTransactionSetting)
  strict private
    _IsolationLevel: TFirebirdTransactionIsolationLevel;
    _AccessMode: TFirebirdTransactionAccessMode;
    _LockResolution: TFirebirdTransactionLockResolution;
    _TableReservation: TFirebirdTransactionTableReservation;
    _RecordVersion: TFirebirdTransactionRecordVersion;
    _ExtraOptions: TFirebirdTransactionExtraSet;
  public
    function IsolationLevel: TFirebirdTransactionIsolationLevel;
    function AccessMode: TFirebirdTransactionAccessMode;
    function LockResolution: TFirebirdTransactionLockResolution;
    function TableReservation: TFirebirdTransactionTableReservation;
    function RecordVersion: TFirebirdTransactionRecordVersion;
    function ExtraOptions: TFirebirdTransactionExtraSet;
    function ToStringArray: TFirebirdTransactionParams;
    constructor Create(const IsolationLevel: TFirebirdTransactionIsolationLevel;
      const AccessMode: TFirebirdTransactionAccessMode; const LockResolution: TFirebirdTransactionLockResolution;
      const TableReservation: TFirebirdTransactionTableReservation;
      const RecordVersion: TFirebirdTransactionRecordVersion; const ExtraOptions: TFirebirdTransactionExtraSet);
    class function New(const IsolationLevel: TFirebirdTransactionIsolationLevel;
      const AccessMode: TFirebirdTransactionAccessMode; const LockResolution: TFirebirdTransactionLockResolution;
      const TableReservation: TFirebirdTransactionTableReservation;
      const RecordVersion: TFirebirdTransactionRecordVersion; const ExtraOptions: TFirebirdTransactionExtraSet)
      : IFirebirdTransactionSetting;
  end;

implementation

function TFirebirdTransactionSetting.IsolationLevel: TFirebirdTransactionIsolationLevel;
begin
  Result := _IsolationLevel;
end;

function TFirebirdTransactionSetting.AccessMode: TFirebirdTransactionAccessMode;
begin
  Result := _AccessMode;
end;

function TFirebirdTransactionSetting.LockResolution: TFirebirdTransactionLockResolution;
begin
  Result := _LockResolution;
end;

function TFirebirdTransactionSetting.TableReservation: TFirebirdTransactionTableReservation;
begin
  Result := _TableReservation;
end;

function TFirebirdTransactionSetting.RecordVersion: TFirebirdTransactionRecordVersion;
begin
  Result := _RecordVersion;
end;

function TFirebirdTransactionSetting.ExtraOptions: TFirebirdTransactionExtraSet;
begin
  Result := _ExtraOptions;
end;

function TFirebirdTransactionSetting.ToStringArray: TFirebirdTransactionParams;
const
  ISOLATION_LEVEL: array [TFirebirdTransactionIsolationLevel] of string = ('isc_tpb_read_committed',
    'isc_tpb_concurrency', 'isc_tpb_consistency');
  ACCESS_MODE: array [TFirebirdTransactionAccessMode] of string = ('isc_tpb_read', 'isc_tpb_write');
  LOCK_RESOLUTION: array [TFirebirdTransactionLockResolution] of string = ('isc_tpb_nowait', 'isc_tpb_wait');
  TABLE_RESERVATION: array [TFirebirdTransactionTableReservation] of string = ('isc_tpb_shared', 'isc_tpb_protected',
    'isc_tpb_lock_read', 'isc_tpb_lock_write');
  RECORD_VERSION: array [TFirebirdTransactionRecordVersion] of string = ('isc_tpb_no_rec_version',
    'isc_tpb_rec_version');
  EXTRA_OPTIONS: array [TFirebirdTransactionExtra] of string = ('isc_tpb_exclusive', 'isc_tpb_verb_time',
    'isc_tpb_commit_time', 'isc_tpb_ignore_limbo', 'isc_tpb_autocommit', 'isc_tpb_restart_requests',
    'isc_tpb_no_auto_undo', 'isc_tpb_lock_timeout');
var
  ExtraOption: TFirebirdTransactionExtra;
begin
  SetLength(Result, 5);
  Result[0] := ISOLATION_LEVEL[_IsolationLevel];
  Result[1] := ACCESS_MODE[_AccessMode];
  Result[2] := LOCK_RESOLUTION[_LockResolution];
  Result[3] := TABLE_RESERVATION[_TableReservation];
  Result[4] := RECORD_VERSION[_RecordVersion];
  for ExtraOption := Low(TFirebirdTransactionExtra) to High(TFirebirdTransactionExtra) do
    if ExtraOption in _ExtraOptions then
    begin
      SetLength(Result, Succ(Length(Result)));
      Result[High(Result)] := EXTRA_OPTIONS[ExtraOption];
    end;
end;

constructor TFirebirdTransactionSetting.Create(const IsolationLevel: TFirebirdTransactionIsolationLevel;
  const AccessMode: TFirebirdTransactionAccessMode; const LockResolution: TFirebirdTransactionLockResolution;
  const TableReservation: TFirebirdTransactionTableReservation; const RecordVersion: TFirebirdTransactionRecordVersion;
  const ExtraOptions: TFirebirdTransactionExtraSet);
begin
  _IsolationLevel := IsolationLevel;
  _AccessMode := AccessMode;
  _LockResolution := LockResolution;
  _TableReservation := TableReservation;
  _RecordVersion := RecordVersion;
  _ExtraOptions := ExtraOptions;
end;

class function TFirebirdTransactionSetting.New(const IsolationLevel: TFirebirdTransactionIsolationLevel;
  const AccessMode: TFirebirdTransactionAccessMode; const LockResolution: TFirebirdTransactionLockResolution;
  const TableReservation: TFirebirdTransactionTableReservation; const RecordVersion: TFirebirdTransactionRecordVersion;
  const ExtraOptions: TFirebirdTransactionExtraSet): IFirebirdTransactionSetting;
begin
  Result := TFirebirdTransactionSetting.Create(IsolationLevel, AccessMode, LockResolution, TableReservation,
    RecordVersion, ExtraOptions);
end;

end.
