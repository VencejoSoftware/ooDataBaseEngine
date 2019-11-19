unit FirebirdConnectionConfig;

interface

uses
  DBConnectionConfig;

type
  IFirebirdConnectionConfig = interface(IDBConnectionConfig)
    ['{4981BA43-5BA6-4128-88B1-5CB10039F6DF}']
    function Port: Word;
    function Dialect: Byte;
    function Charset: String;
    function Role: String;
  end;

  TFirebirdConnectionConfig = class sealed(TInterfacedObject, IFirebirdConnectionConfig)
  strict private
    _ConnectionConfig: IDBConnectionConfig;
    _Port: Word;
    _Dialect: Byte;
    _Charset, _Role: String;
  public
    function User: String;
    function Pass: String;
    function Path: String;
    function LibraryPath: String;
    function Port: Word;
    function Dialect: Byte;
    function Charset: String;
    function Role: String;
    constructor Create(const Config: IDBConnectionConfig; const Port: Word; const Dialect: Byte;
      const Charset, Role: String);
    class function New(const Config: IDBConnectionConfig; const Port: Word; const Dialect: Byte;
      const Charset, Role: String): IFirebirdConnectionConfig;
  end;

implementation

function TFirebirdConnectionConfig.User: String;
begin
  Result := _ConnectionConfig.User;
end;

function TFirebirdConnectionConfig.Pass: String;
begin
  Result := _ConnectionConfig.Pass;
end;

function TFirebirdConnectionConfig.Path: String;
begin
  Result := _ConnectionConfig.Path;
end;

function TFirebirdConnectionConfig.LibraryPath: String;
begin
  Result := _ConnectionConfig.LibraryPath;
end;

function TFirebirdConnectionConfig.Port: Word;
begin
  Result := _Port;
end;

function TFirebirdConnectionConfig.Dialect: Byte;
begin
  Result := _Dialect;
end;

function TFirebirdConnectionConfig.Charset: String;
begin
  Result := _Charset;
end;

function TFirebirdConnectionConfig.Role: String;
begin
  Result := _Role;
end;

constructor TFirebirdConnectionConfig.Create(const Config: IDBConnectionConfig; const Port: Word; const Dialect: Byte;
  const Charset, Role: String);
begin
  _ConnectionConfig := Config;
  _Port := Port;
  _Dialect := Dialect;
  _Charset := Charset;
  _Role := Role;
end;

class function TFirebirdConnectionConfig.New(const Config: IDBConnectionConfig; const Port: Word; const Dialect: Byte;
  const Charset, Role: String): IFirebirdConnectionConfig;
begin
  Result := TFirebirdConnectionConfig.Create(Config, Port, Dialect, Charset, Role);
end;

end.
