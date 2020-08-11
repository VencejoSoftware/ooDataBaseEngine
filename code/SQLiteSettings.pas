{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define the settings for a SQLite connection
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit SQLiteSettings;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSettings;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the settings for a SQLite connection)
  @member(
    CharSet Kind of connection charSet
    @return(Text with connection charset)
  )
}
{$ENDREGION}
  ISQLiteSettings = interface(IConnectionSettings)
    ['{DAD02332-1B8D-42C4-8AE5-2A305BCB7BEC}']
    function CharSet: WideString;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(ISQLiteSettings))
  @member(Credential @seealso(IConnectionSettings.Credential))
  @member(StorageName @seealso(IConnectionSettings.StorageName))
  @member(LibraryPath @seealso(IConnectionSettings.LibraryPath))
  @member(Server @seealso(IConnectionSettings.Server))
  @member(CharSet @seealso(ISQLiteSettings.CharSet))
  @member(
    Create Object constructor
    @param(Settings @link(IConnectionSettings Object with base connection settings))
    @param(CharSet Connection charset)
  )
  @member(
    New Create a new @classname as interface
    @param(Settings @link(IConnectionSettings Object with base connection settings))
    @param(CharSet Connection charset)
  )
  @member(
    NewEmbedded Create a new @classname as interface for embeded connection
    @param(DatabasePath Database file path)
    @param(LibraryPath SQLite client library path)
    @param(CharSet Connection charset)
  )
}
{$ENDREGION}

  TSQLiteSettings = class sealed(TInterfacedObject, ISQLiteSettings)
  strict private
    _Settings: IConnectionSettings;
    _CharSet: WideString;
  public
    function Credential: ICredential;
    function StorageName: WideString;
    function LibraryPath: WideString;
    function Server: IServer;
    function CharSet: WideString;
    constructor Create(const Settings: IConnectionSettings; const CharSet: WideString);
    class function New(const Settings: IConnectionSettings; const CharSet: WideString = 'UTF16'): ISQLiteSettings;
    class function NewEmbedded(const DatabasePath, LibraryPath: WideString; const CharSet: WideString = 'UTF16')
      : ISQLiteSettings;
  end;

implementation

function TSQLiteSettings.Credential: ICredential;
begin
  Result := _Settings.Credential;
end;

function TSQLiteSettings.StorageName: WideString;
begin
  Result := _Settings.StorageName;
end;

function TSQLiteSettings.LibraryPath: WideString;
begin
  Result := _Settings.LibraryPath;
end;

function TSQLiteSettings.Server: IServer;
begin
  Result := _Settings.Server;
end;

function TSQLiteSettings.CharSet: WideString;
begin
  Result := _CharSet;
end;

constructor TSQLiteSettings.Create(const Settings: IConnectionSettings; const CharSet: WideString);
begin
  _Settings := Settings;
  _CharSet := CharSet;
end;

class function TSQLiteSettings.New(const Settings: IConnectionSettings; const CharSet: WideString): ISQLiteSettings;
begin
  Result := TSQLiteSettings.Create(Settings, CharSet);
end;

class function TSQLiteSettings.NewEmbedded(const DatabasePath, LibraryPath, CharSet: WideString): ISQLiteSettings;
begin
  Result := TSQLiteSettings.New(TConnectionSettings.New(TCredential.NewEmpty, DatabasePath, LibraryPath, nil));
end;

end.
