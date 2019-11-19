unit DatabaseLoginFactory;

interface

uses
  SysUtils,
  INIFiles,
  Credential,
  CryptLib,
  DatabaseLogin;

type
  EDatabaseLoginFactory = class sealed(Exception)
  end;

  IDatabaseLoginFactory = interface
    ['{393DAEE9-7186-42F9-B9AD-7A78D28AE745}']
    function BuildByINI(const FilePath: String; const Section: String): IDatabaseLogin;
  end;

  TDatabaseLoginFactory = class sealed(TInterfacedObject, IDatabaseLoginFactory)
  strict private
    _CryptLib: ICryptLib;
  private
    function BuildByFirebirdEngine(const IniObject: TIniFile; const Section: String): IDatabaseLogin;
    function BuildByOracleEngine(const IniObject: TIniFile; const Section: String): IDatabaseLogin;
  public
    function BuildByINI(const FilePath: String; const Section: String): IDatabaseLogin;
    constructor Create(const CryptLib: ICryptLib);
    class function New(const CryptLib: ICryptLib): IDatabaseLoginFactory;
  end;

implementation

function TDatabaseLoginFactory.BuildByFirebirdEngine(const IniObject: TIniFile; const Section: String): IDatabaseLogin;
var
  StoragePath, Login, Password, LibrayPath, Dialect, Charset: String;
begin
  StoragePath := _CryptLib.Decrypt(IniObject.ReadString(Section, 'StoragePath', EmptyStr));
  Login := _CryptLib.Decrypt(IniObject.ReadString(Section, 'Login', 'sysdba'));
  Password := _CryptLib.Decrypt(IniObject.ReadString(Section, 'Password', 'masterkey'));
  LibrayPath := IniObject.ReadString(Section, 'LibrayPath', 'fbclient.dll');
  Dialect := IniObject.ReadString(Section, 'Dialect', '3');
  Charset := IniObject.ReadString(Section, 'Charset', 'ISO8859_1');
  Result := TDatabaseLogin.New(TCredential.New(Login, Password));
  Result.Parameters.Add('ENGINE', 'Firebird');
  Result.Parameters.Add('LIB_PATH', LibrayPath);
  Result.Parameters.Add('DB_PATH', StoragePath);
  Result.Parameters.Add('DIALECT', Dialect);
  Result.Parameters.Add('CHARSET', Charset);
end;

function TDatabaseLoginFactory.BuildByOracleEngine(const IniObject: TIniFile; const Section: String): IDatabaseLogin;
var
  TnsName, Login, Password: String;
begin
  TnsName := _CryptLib.Decrypt(IniObject.ReadString(Section, 'TnsName', EmptyStr));
  Login := _CryptLib.Decrypt(IniObject.ReadString(Section, 'Login', 'sysdba'));
  Password := _CryptLib.Decrypt(IniObject.ReadString(Section, 'Password', 'masterkey'));
  Result := TDatabaseLogin.New(TCredential.New(Login, Password));
  Result.Parameters.Add('ENGINE', 'Oracle');
  Result.Parameters.Add('TNS_NAME', TnsName);
end;

function TDatabaseLoginFactory.BuildByINI(const FilePath, Section: String): IDatabaseLogin;
var
  IniObject: TIniFile;
  Engine: String;
begin
  Result := nil;
  if not FileExists(FilePath) then
    raise EDatabaseLoginFactory.Create('Database engine INI file not found!');
  IniObject := TIniFile.Create(FilePath);
  try
    Engine := IniObject.ReadString(Section, 'Engine', EmptyStr);
    if SameText('Firebird', Engine) then
      Result := BuildByFirebirdEngine(IniObject, Section)
    else if SameText('Oracle', Engine) then
      Result := BuildByOracleEngine(IniObject, Section);
  finally
    IniObject.Free;
  end;
end;

constructor TDatabaseLoginFactory.Create(const CryptLib: ICryptLib);
begin
  _CryptLib := CryptLib;
end;

class function TDatabaseLoginFactory.New(const CryptLib: ICryptLib): IDatabaseLoginFactory;
begin
  Result := TDatabaseLoginFactory.Create(CryptLib);
end;

end.
