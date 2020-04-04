{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database engine library
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit DatabaseEngineLib;

interface

uses
  SysUtils, Windows,
  LogActor,
  DatabaseEngine;

type
{$REGION 'documentation'}
{
  @abstract(Database engine library)
  Object to encapsulate the database engine building
  @member(NewADOEngine Creates a new ADO database engine object)
  @member(NewFirebirdEngine Creates a new Firebird database engine object)
  @member(
    NewLoggedDatabaseEngine Creates a new logged database engine object
    @param(DatabaseEngine @link(IDatabaseEngine Database engine object to encapsulate))
    @param(Log @link(ILog Log object to handle events))
  )
}
{$ENDREGION}
  IDatabaseEngineLib = interface
    ['{597C385A-F2B4-4231-B76F-5787139477BD}']
    function NewADOEngine: IDatabaseEngine;
    function NewFirebirdEngine: IDatabaseEngine;
    function NewLoggedDatabaseEngine(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor): IDatabaseEngine;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseEngineLib))
  @member(NewADOEngine @seealso(IDatabaseEngineLib.NewADOEngine))
  @member(NewFirebirdEngine @seealso(IDatabaseEngineLib.ValuNewFirebirdEngine))
  @member(
    SanitizedFilePath Expand path to absolute to skip errores
    @param(Path Library path)
    @return(String with path sanitized)
  )
  @member(
    Create Object constructor. If DLL file not exists raise a error
    @param(DLLPath Path to lib binary)
  )
  @member(
    Destroy Object destructor
  )
  @member(
    New Create a new @classname as interface
    @param(DLLPath Path to lib binary)
  )
}
{$ENDREGION}

  TDatabaseEngineLib = class sealed(TInterfacedObject, IDatabaseEngineLib)
  strict private
  type
    TNewADOEngine = function: IDatabaseEngine; stdcall;
    TNewFirebirdEngine = function: IDatabaseEngine; stdcall;
    TNewLoggedDatabaseEngine = function(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor)
      : IDatabaseEngine; stdcall;
  strict private
    _LibHandle: THandle;
    _NewADOEngine: TNewADOEngine;
    _NewFirebirdEngine: TNewFirebirdEngine;
    _NewLoggedDatabaseEngine: TNewLoggedDatabaseEngine;
  private
    function SanitizedFilePath(const Path: String): String;
  public
    function NewADOEngine: IDatabaseEngine;
    function NewFirebirdEngine: IDatabaseEngine;
    function NewLoggedDatabaseEngine(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor): IDatabaseEngine;
    constructor Create(const DLLPath: String);
    destructor Destroy; override;
    class function New(const DLLPath: String): IDatabaseEngineLib;
  end;

implementation

function TDatabaseEngineLib.NewADOEngine: IDatabaseEngine;
begin
  if Assigned(@_NewADOEngine) then
    Result := _NewADOEngine;
end;

function TDatabaseEngineLib.NewFirebirdEngine: IDatabaseEngine;
begin
  if Assigned(@_NewFirebirdEngine) then
    Result := _NewFirebirdEngine;
end;

function TDatabaseEngineLib.NewLoggedDatabaseEngine(const DatabaseEngine: IDatabaseEngine; const LogActor: ILogActor)
  : IDatabaseEngine;
begin
  if Assigned(@_NewLoggedDatabaseEngine) then
    Result := _NewLoggedDatabaseEngine(DatabaseEngine, LogActor);
end;

function TDatabaseEngineLib.SanitizedFilePath(const Path: String): String;
begin
  Result := ExpandFileName(String(Path));
end;

constructor TDatabaseEngineLib.Create(const DLLPath: String);
begin
  if not FileExists(SanitizedFilePath(DLLPath)) then
    raise Exception.Create('Database engine DLL path not found');
  _LibHandle := LoadLibrary(PChar(SanitizedFilePath(DLLPath)));
  if _LibHandle = 0 then
    RaiseLastOSError;
  @_NewFirebirdEngine := GetProcAddress(_LibHandle, PChar('NewFirebirdEngine'));
  @_NewADOEngine := GetProcAddress(_LibHandle, PChar('NewADOEngine'));
  @_NewLoggedDatabaseEngine := GetProcAddress(_LibHandle, PChar('NewLoggedDatabaseEngine'));
end;

destructor TDatabaseEngineLib.Destroy;
begin
  if _LibHandle <> 0 then
    FreeLibrary(_LibHandle);
  inherited;
end;

class function TDatabaseEngineLib.New(const DLLPath: String): IDatabaseEngineLib;
begin
  Result := TDatabaseEngineLib.Create(DLLPath);
end;

end.
