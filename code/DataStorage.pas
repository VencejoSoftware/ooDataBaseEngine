{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to external data access
  @created(15/04/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit DataStorage;

interface

uses
  SysUtils,
  INIFiles;

type
{$REGION 'documentation'}
{
  @abstract(Exception object)
}
{$ENDREGION}
  EDataStorage = class sealed(Exception)

  end;
{$REGION 'documentation'}
{
  @abstract(Object to external data access)
  @member(
    ReadString Read a string from extenal storage
    @param(ObjectName Object name identifier)
    @param(FieldName Field name to get value)
    @return(Readed string value)
  )
  @member(
    ReadInteger Read an integer from extenal storage
    @param(ObjectName Object name identifier)
    @param(FieldName Field name to get value)
    @return(Readed integer value)
  )
}
{$ENDREGION}

  IDataStorage = interface
    ['{316D9E03-B454-46CF-85BD-44D95F0F6E9D}']
    function ReadString(const ObjectName, FieldName: WideString): WideString;
    function ReadInteger(const ObjectName, FieldName: WideString): NativeInt;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDataStorage))
  Uses a INI file object to access a external file data
  @member(ReadString @seealso(IDataStorage.ReadString))
  @member(ReadInteger @seealso(IDataStorage.ReadInteger))
  @member(
    CheckObjectExistence Checks if the object name section exist, if not raise an exception
    @param(ObjectName Object name identifier)
  )
  @member(
    Create Object constructor
    @param(FilePath INI file path)
  )
  @member(
    New Creates a new @classname as interface
    @param(FilePath INI file path)
  )
}
{$ENDREGION}

  TINIDataStorage = class sealed(TInterfacedObject, IDataStorage)
  strict private
    _INI: TIniFile;
  private
    procedure CheckObjectExistence(const ObjectName: WideString);
  public
    function ReadString(const ObjectName, FieldName: WideString): WideString;
    function ReadInteger(const ObjectName, FieldName: WideString): NativeInt;
    constructor Create(const FilePath: String);
    destructor Destroy; override;
    class function New(const FilePath: String): IDataStorage;
  end;

implementation

procedure TINIDataStorage.CheckObjectExistence(const ObjectName: WideString);
begin
  if not _INI.SectionExists(ObjectName) then
    raise EDataStorage.Create(Format('Object name "%s" dont exists', [ObjectName]));
end;

function TINIDataStorage.ReadString(const ObjectName, FieldName: WideString): WideString;
begin
  CheckObjectExistence(ObjectName);
  Result := _INI.ReadString(ObjectName, FieldName, EmptyWideStr);
end;

function TINIDataStorage.ReadInteger(const ObjectName, FieldName: WideString): NativeInt;
begin
  CheckObjectExistence(ObjectName);
  Result := _INI.ReadInteger(ObjectName, FieldName, 0);
end;

constructor TINIDataStorage.Create(const FilePath: String);
begin
  _INI := TIniFile.Create(FilePath);
end;

destructor TINIDataStorage.Destroy;
begin
  _INI.Free;
  inherited;
end;

class function TINIDataStorage.New(const FilePath: String): IDataStorage;
begin
  Result := TINIDataStorage.Create(FilePath);
end;

end.
