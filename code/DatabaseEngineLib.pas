unit DatabaseEngineLib;

interface

uses
  SysUtils, Windows,
  DatabaseEngine;

type
  IDatabaseEngineLib = interface
    ['{597C385A-F2B4-4231-B76F-5787139477BD}']
    function NewADOEngine: IDatabaseEngine;
    function NewFirebirdEngine: IDatabaseEngine;
  end;

  TDatabaseEngineLib = class sealed(TInterfacedObject, IDatabaseEngineLib)
  strict private
  type
    TNewADOEngine = function: IDatabaseEngine; stdcall;
    TNewFirebirdEngine = function: IDatabaseEngine; stdcall;
  strict private
    _LibHandle: THandle;
    _NewADOEngine: TNewADOEngine;
    _NewFirebirdEngine: TNewFirebirdEngine;
  private
    function SanitizedFilePath(const Path: String): String;
  public
    function NewADOEngine: IDatabaseEngine;
    function NewFirebirdEngine: IDatabaseEngine;
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
