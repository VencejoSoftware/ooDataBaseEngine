unit DBConnectionConfig;

interface

type
  IDBConnectionConfig = interface
    ['{6C081B58-A8D6-47B6-9286-4ABB9C691AEF}']
    function User: String;
    function Pass: String;
    function Path: String;
    function LibraryPath: String;
  end;

  TDBConnectionConfig = class sealed(TInterfacedObject, IDBConnectionConfig)
  strict private
    _User, _Pass, _Path, _LibraryPath: String;
  public
    function User: String;
    function Pass: String;
    function Path: String;
    function LibraryPath: String;
    constructor Create(const User, Pass, Path, LibraryPath: String);
    class function New(const User, Pass, Path, LibraryPath: String): IDBConnectionConfig;
  end;

implementation

function TDBConnectionConfig.User: String;
begin
  Result := _User;
end;

function TDBConnectionConfig.Pass: String;
begin
  Result := _Pass;
end;

function TDBConnectionConfig.Path: String;
begin
  Result := _Path;
end;

function TDBConnectionConfig.LibraryPath: String;
begin
  Result := _LibraryPath;
end;

constructor TDBConnectionConfig.Create(const User, Pass, Path, LibraryPath: String);
begin
  _User := User;
  _Pass := Pass;
  _Path := Path;
  _LibraryPath := LibraryPath;
end;

class function TDBConnectionConfig.New(const User, Pass, Path, LibraryPath: String): IDBConnectionConfig;
begin
  Result := TDBConnectionConfig.Create(User, Pass, Path, LibraryPath);
end;

end.
