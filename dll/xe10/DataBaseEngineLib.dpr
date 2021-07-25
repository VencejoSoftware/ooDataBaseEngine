library DataBaseEngineLib;

uses
  SimpleShareMem,
  SysUtils,
  Version,
  VersionStage,
  VersionFormat,
  LogActor,
  AppLogActor,
  ADOEngine in '..\..\code\ADOEngine.pas',
  ADOSetting in '..\..\code\ADOSetting.pas',
  ADOSettingFactory in '..\..\code\ADOSettingFactory.pas',
  ConnectionSetting in '..\..\code\ConnectionSetting.pas',
  ConnectionSettingFactory in '..\..\code\ConnectionSettingFactory.pas',
  DatabaseEngine in '..\..\code\DatabaseEngine.pas',
  DatabaseValueFormat in '..\..\code\DatabaseValueFormat.pas',
  DatasetExecution in '..\..\code\DatasetExecution.pas',
  DataStorage in '..\..\code\DataStorage.pas',
  EntityCached in '..\..\code\EntityCached.pas',
  ExecutionResult in '..\..\code\ExecutionResult.pas',
  FailedExecution in '..\..\code\FailedExecution.pas',
  FirebirdEngine in '..\..\code\FirebirdEngine.pas',
  FirebirdSetting in '..\..\code\FirebirdSetting.pas',
  FirebirdSettingFactory in '..\..\code\FirebirdSettingFactory.pas',
  FirebirdTransactionSetting in '..\..\code\FirebirdTransactionSetting.pas',
  FirebirdTransactionSettingFactory in '..\..\code\FirebirdTransactionSettingFactory.pas',
  LoggedDatabaseEngine in '..\..\code\LoggedDatabaseEngine.pas',
  SQLiteEngine in '..\..\code\SQLiteEngine.pas',
  SQLiteSetting in '..\..\code\SQLiteSetting.pas',
  SQLiteSettingFactory in '..\..\code\SQLiteSettingFactory.pas',
  Statement in '..\..\code\Statement.pas',
  SuccededExecution in '..\..\code\SuccededExecution.pas',
  ZeosDatabaseEngine in '..\..\code\ZeosDatabaseEngine.pas';

{$R *.res}

function Version: IVersion; stdcall;
begin
  Result := TVersion.New(1, 0, 0, 0, TVersionStage.New(TVersionStageCode.Productive), EncodeDate(2020, 08, 12));
end;

function BuildLogActor(const LogActor: ILogActor): ILogActor;
begin
  Result := TAppLogActor.New(LogActor, 'DataBaseEngineLib(' + TVersionFormat.New(Version).AsString + ')');
end;

function NewADOEngine: IDatabaseEngine; stdcall;
begin
  Result := TADOEngine.New;
end;

function NewFirebirdEngine: IDatabaseEngine; stdcall;
begin
  Result := TFirebirdEngine.New;
end;

// function NewFirebirdEmbedded15Engine: IDatabaseEngine; stdcall;
// begin
// Result := TFirebirdEmbedded15Engine.New;
// end;

function NewLoggedDatabaseEngine(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor)
  : IDatabaseEngine; stdcall;
begin
  Result := TLoggedDatabaseEngine.New(DatabaseEngine, BuildLogActor(LogActor));
end;

exports
  NewADOEngine,
  NewFirebirdEngine,
// NewFirebirdEmbedded15Engine,
  NewLoggedDatabaseEngine;

begin
  IsMultiThread := True;

end.
