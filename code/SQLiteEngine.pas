{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database engine connection for sqlite
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit SQLiteEngine;

interface

uses
  ExecutionResult,
  ConnectionSetting, SQLiteSetting,
  DatabaseEngine,
  Statement,
  ZeosDatabaseEngine;

type
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseEngine))
  SQLite database connection
  @member(Connect @seealso(IDatabaseEngine.Connect))
  @member(New Create a new @classname as interface)
}
{$ENDREGION}
  TSQLiteEngine = class sealed(TZeosEngine)
  public
    function Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean; override;
    class function New: IDatabaseEngine;
  end;

implementation

function TSQLiteEngine.Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean;
var
  SQLiteSetting: ISQLiteSetting;
begin
  inherited Connect(Setting, PasswordKey);
  SQLiteSetting := (Setting as ISQLiteSetting);
  Database.Protocol := 'sqlite-3';
  Database.ClientCodepage := SQLiteSetting.Charset;
  Database.Connect;
  Result := IsConnected;
end;

class function TSQLiteEngine.New: IDatabaseEngine;
begin
  Result := TSQLiteEngine.Create;
end;

end.