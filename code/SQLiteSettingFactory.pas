{$REGION 'documentation'}
{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object factory to build SQLite connection Setting objects
  @created(15/04/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit SQLiteSettingFactory;

interface

uses
  DataStorage,
  ConnectionSetting, ConnectionSettingFactory,
  SQLiteSetting;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(ISQLiteSetting SQLiteSetting objects))
  @member(
    Build Construct a new @link(ISQLiteSetting SQLiteSetting object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(ISQLiteSetting SQLiteSetting object))
  )
}
{$ENDREGION}
  ISQLiteSettingFactory = interface
    ['{F34F51F2-3025-4935-9883-D75B8521FD81}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): ISQLiteSetting;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionSettingFactory))
  Object factory for SQLite database Setting
  @member(Build @seealso(IConnectionSettingFactory.Build))
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

  TSQLiteSettingFactory = class sealed(TInterfacedObject, ISQLiteSettingFactory)
  strict private
    _ConnectionSettingFactory: IConnectionSettingFactory;
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): ISQLiteSetting;
    constructor Create;
    class function New: ISQLiteSettingFactory;
  end;

implementation

function TSQLiteSettingFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage): ISQLiteSetting;
var
  Setting: IConnectionSetting;
begin
  Setting := _ConnectionSettingFactory.Build(ObjectName, DataStorage);
  Result := TSQLiteSetting.New(Setting, DataStorage.ReadString(ObjectName, 'Charset'));
end;

constructor TSQLiteSettingFactory.Create;
begin
  _ConnectionSettingFactory := TConnectionSettingFactory.New(nil);
end;

class function TSQLiteSettingFactory.New: ISQLiteSettingFactory;
begin
  Result := TSQLiteSettingFactory.Create;
end;

end.
