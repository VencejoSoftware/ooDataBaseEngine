{$REGION 'documentation'}
{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database login factory object
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit DatabaseLoginFactory;

interface

uses
  SysUtils,
  INIFiles,
  Cipher,
  ConnectionParam,
  DatabaseLogin;

type
{$REGION 'documentation'}
{
  @abstract(Database login factory error object)
}
{$ENDREGION}
  EDatabaseLoginFactory = class sealed(Exception)
  end;

{$REGION 'documentation'}
{
  @abstract(Database login factory object)
  Database login builder based in files or streams
  @member(
    BuildByINI Build a new @link(IDatabaseLogin Login object) using a INI file, taking the "Engine" tag to determine the kind of Login object
    @param(FilePath INI path)
    @param(Section INI section to use)
    @return(@link(IDatabaseLogin Login object))
  )
}
{$ENDREGION}

  IDatabaseLoginFactory = interface
    ['{393DAEE9-7186-42F9-B9AD-7A78D28AE745}']
    function BuildByINI(const FilePath: String; const Section: String): IDatabaseLogin;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseLoginFactory))
  @member(BuildByINI @seealso(IDatabaseLoginFactory.BuildByINI))
  @member(
    BuildByFirebirdEngine Build a new @link(IDatabaseLogin Login object) for firebird connection
    @param(FilePath INI path)
    @param(Section INI section to use)
  )
  @member(
    BuildByOracleEngine Build a new @link(IDatabaseLogin Login object) for ADO connections
    @param(FilePath INI path)
    @param(Section INI section to use)
  )
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

  TDatabaseLoginFactory = class sealed(TInterfacedObject, IDatabaseLoginFactory)
  strict private
    _Cipher: ICipher;
  private
    function BuildByFirebirdEngine(const IniObject: TIniFile; const Section: String): IDatabaseLogin;
    function BuildByOracleEngine(const IniObject: TIniFile; const Section: String): IDatabaseLogin;
  public
    function BuildByINI(const FilePath: String; const Section: String): IDatabaseLogin;
    constructor Create(const Cipher: ICipher);
    class function New(const Cipher: ICipher): IDatabaseLoginFactory;
  end;

implementation

function TDatabaseLoginFactory.BuildByFirebirdEngine(const IniObject: TIniFile; const Section: String): IDatabaseLogin;
var
  StoragePath, User, Password, LibrayPath, Dialect, Charset: WideString;
begin
  StoragePath := _Cipher.Decode(IniObject.ReadString(Section, 'StoragePath', EmptyStr));
  User := _Cipher.Decode(IniObject.ReadString(Section, 'User', 'sysdba'));
  Password := _Cipher.Decode(IniObject.ReadString(Section, 'Password', 'masterkey'));
  LibrayPath := IniObject.ReadString(Section, 'LibrayPath', 'fbclient.dll');
  Dialect := IniObject.ReadString(Section, 'Dialect', '3');
  Charset := IniObject.ReadString(Section, 'Charset', 'ISO8859_1');
  Result := TDatabaseLogin.New(User, Password);
  Result.Parameters.Add(TConnectionParam.New('NAME', 'Firebird.' + Section));
  Result.Parameters.Add(TConnectionParam.New('ENGINE', 'Firebird'));
  Result.Parameters.Add(TConnectionParam.New('LIB_PATH', LibrayPath));
  Result.Parameters.Add(TConnectionParam.New('DB_PATH', StoragePath));
  Result.Parameters.Add(TConnectionParam.New('DIALECT', Dialect));
  Result.Parameters.Add(TConnectionParam.New('CHARSET', Charset));
end;

function TDatabaseLoginFactory.BuildByOracleEngine(const IniObject: TIniFile; const Section: String): IDatabaseLogin;
const
  ORA_CONNECTION_STRING = 'Provider=OraOLEDB.Oracle;Data Source=%s; User Id=%s; Password=%s';
var
  TnsName, User, Password: WideString;
begin
  TnsName := _Cipher.Decode(IniObject.ReadString(Section, 'TnsName', EmptyStr));
  User := _Cipher.Decode(IniObject.ReadString(Section, 'User', 'sysdba'));
  Password := _Cipher.Decode(IniObject.ReadString(Section, 'Password', 'masterkey'));
  Result := TDatabaseLogin.New(User, Password);
  Result.Parameters.Add(TConnectionParam.New('NAME', 'Oracle.' + TnsName));
  Result.Parameters.Add(TConnectionParam.New('ENGINE', 'Oracle'));
  Result.Parameters.Add(TConnectionParam.New('TNS_NAME', TnsName));
  Result.Parameters.Add(TConnectionParam.New('CONNECTION_STRING', Format(ORA_CONNECTION_STRING,
    [TnsName, User, Password])));
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
    else
      if SameText('Oracle', Engine) then
        Result := BuildByOracleEngine(IniObject, Section);
  finally
    IniObject.Free;
  end;
end;

constructor TDatabaseLoginFactory.Create(const Cipher: ICipher);
begin
  _Cipher := Cipher;
end;

class function TDatabaseLoginFactory.New(const Cipher: ICipher): IDatabaseLoginFactory;
begin
  Result := TDatabaseLoginFactory.Create(Cipher);
end;

end.
