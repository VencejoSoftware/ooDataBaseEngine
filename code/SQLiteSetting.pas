{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define the Setting for a SQLite connection
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit SQLiteSetting;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSetting;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the Setting for a SQLite connection)
  @member(
    CharSet Kind of connection charSet
    @return(Text with connection charset)
  )
}
{$ENDREGION}
  ISQLiteSetting = interface(IConnectionSetting)
    ['{DAD02332-1B8D-42C4-8AE5-2A305BCB7BEC}']
    function CharSet: WideString;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(ISQLiteSetting))
  @member(Credential @seealso(IConnectionSetting.Credential))
  @member(StorageName @seealso(IConnectionSetting.StorageName))
  @member(LibraryPath @seealso(IConnectionSetting.LibraryPath))
  @member(Server @seealso(IConnectionSetting.Server))
  @member(CharSet @seealso(ISQLiteSetting.CharSet))
  @member(
    Create Object constructor
    @param(Setting @link(IConnectionSetting Object with base connection Setting))
    @param(CharSet Connection charset)
  )
  @member(
    New Create a new @classname as interface
    @param(Setting @link(IConnectionSetting Object with base connection Setting))
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

  TSQLiteSetting = class sealed(TInterfacedObject, ISQLiteSetting)
  strict private
    _Setting: IConnectionSetting;
    _CharSet: WideString;
  public
    function Credential: ICredential;
    function StorageName: WideString;
    function LibraryPath: WideString;
    function Server: IServer;
    function CharSet: WideString;
    constructor Create(const Setting: IConnectionSetting; const CharSet: WideString);
    class function New(const Setting: IConnectionSetting; const CharSet: WideString = 'UTF16'): ISQLiteSetting;
    class function NewEmbedded(const DatabasePath, LibraryPath: WideString; const CharSet: WideString = 'UTF16')
      : ISQLiteSetting;
  end;

implementation

function TSQLiteSetting.Credential: ICredential;
begin
  Result := _Setting.Credential;
end;

function TSQLiteSetting.StorageName: WideString;
begin
  Result := _Setting.StorageName;
end;

function TSQLiteSetting.LibraryPath: WideString;
begin
  Result := _Setting.LibraryPath;
end;

function TSQLiteSetting.Server: IServer;
begin
  Result := _Setting.Server;
end;

function TSQLiteSetting.CharSet: WideString;
begin
  Result := _CharSet;
end;

constructor TSQLiteSetting.Create(const Setting: IConnectionSetting; const CharSet: WideString);
begin
  _Setting := Setting;
  _CharSet := CharSet;
end;

class function TSQLiteSetting.New(const Setting: IConnectionSetting; const CharSet: WideString): ISQLiteSetting;
begin
  Result := TSQLiteSetting.Create(Setting, CharSet);
end;

class function TSQLiteSetting.NewEmbedded(const DatabasePath, LibraryPath, CharSet: WideString): ISQLiteSetting;
begin
  Result := TSQLiteSetting.New(TConnectionSetting.New(TCredential.NewEmpty, DatabasePath, LibraryPath, nil));
end;

end.
