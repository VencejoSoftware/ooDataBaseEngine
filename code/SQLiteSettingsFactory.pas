{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object factory to build SQLite connection settings objects
  @created(15/04/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit SQLiteSettingsFactory;

interface

uses
  DataStorage,
  ConnectionSettings, ConnectionSettingsFactory,
  SQLiteSettings;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(ISQLiteSettings SQLiteSettings objects))
  @member(
    Build Construct a new @link(ISQLiteSettings SQLiteSettings object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(ISQLiteSettings SQLiteSettings object))
  )
}
{$ENDREGION}
  ISQLiteSettingsFactory = interface
    ['{F34F51F2-3025-4935-9883-D75B8521FD81}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): ISQLiteSettings;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionSettingsFactory))
  Object factory for SQLite database settings
  @member(Build @seealso(IConnectionSettingsFactory.Build))
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

  TSQLiteSettingsFactory = class sealed(TInterfacedObject, ISQLiteSettingsFactory)
  strict private
    _ConnectionSettingsFactory: IConnectionSettingsFactory;
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): ISQLiteSettings;
    constructor Create;
    class function New: ISQLiteSettingsFactory;
  end;

implementation

function TSQLiteSettingsFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage): ISQLiteSettings;
var
  Settings: IConnectionSettings;
begin
  Settings := _ConnectionSettingsFactory.Build(ObjectName, DataStorage);
  Result := TSQLiteSettings.New(Settings, DataStorage.ReadString(ObjectName, 'Charset'));
end;

constructor TSQLiteSettingsFactory.Create;
begin
  _ConnectionSettingsFactory := TConnectionSettingsFactory.New(nil);
end;

class function TSQLiteSettingsFactory.New: ISQLiteSettingsFactory;
begin
  Result := TSQLiteSettingsFactory.Create;
end;

end.
