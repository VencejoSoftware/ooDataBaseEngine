{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database engine connection parameter object
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ConnectionParam;

interface

uses
  SysUtils, StrUtils,
  IterableList;

type
{$REGION 'documentation'}
{
  @abstract(Connection parameter error object)
}
{$ENDREGION}
  EConnectionParam = class(Exception)

  end;
{$REGION 'documentation'}
{
  @abstract(Connection engine parameter object)
  Connection parameter object
  @member(Key Parameter unique identifier)
  @member(Value Parameter value)
}
{$ENDREGION}

  IConnectionParam = interface
    ['{C84BE68B-23CD-4DBD-BD2A-1994985DF746}']
    function Key: WideString;
    function Value: WideString;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionParam))
  @member(Key @seealso(IConnectionParam.Key))
  @member(Value @seealso(IConnectionParam.Value))
  @member(
    Create Object constructor
    @param(Key Parameter identifier)
    @param(Value Parameter content value)
  )
  @member(
    New Create a new @classname as interface
    @param(Key Parameter identifier)
    @param(Value Parameter content value)
  )
}
{$ENDREGION}

  TConnectionParam = class sealed(TInterfacedObject, IConnectionParam)
  strict private
    _Key, _Value: WideString;
  public
    function Key: WideString;
    function Value: WideString;
    constructor Create(const Key, Value: WideString);
    class function New(const Key, Value: WideString): IConnectionParam;
    class function NewByText(const Text: WideString; const Separator: Char): IConnectionParam;
  end;

{$REGION 'documentation'}
{
  @abstract(Connection parameter list interface)
  @member(
    ExistKey Checks if parameter key exists
    @param(Key Parameter key identifier)
    @return(@true if exist key, @false if not)
  )
  @member(
    ItemByKey Find parameter in list using his key
    @param(Key Parameter key identifier)
    @return(Parameter if exist, nil if not)
  )
  @member(
    TryGetValue Find parameter in list using his key
    @param(Key Parameter key identifier)
    @param(Value Output value if exists key)
    @return(@true if key exist and get value, @false if not)
  )
}
{$ENDREGION}

  IConnectionParamList = interface(IIterableList<IConnectionParam>)
    ['{CA153DD5-4C3B-48E5-B9AB-CBF56B793C8C}']
    function ExistKey(const Key: WideString): Boolean;
    function ItemByKey(const Key: WideString): IConnectionParam;
    function TryGetValue(const Key: WideString; out Value: WideString): Boolean;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IConnectionParamList))
  @member(ExistKey @seealso(IConnectionParamList.ExistKey))
  @member(ItemByKey @seealso(IConnectionParamList.ItemByKey))
  @member(TryGetValue @seealso(IConnectionParamList.TryGetValue))
  @member(
    ParseContent Take an WideString and split parsing and building each parameter object
    @param(Content Raw WideString to split and parse)
    @param(ItemSeparator Parameter separator)
    @param(ValueSeparator Content value separator)
  )
  @member(
    New Create a new @classname as interface
  )
  @member(
    NewFromContent Create and parse content to build object list
    @param(Content Content text to parse)
    @param(ItemSeparator Parameter separator)
    @param(ValueSeparator Content value separator)
  )
}
{$ENDREGION}

  TConnectionParamList = class sealed(TIterableList<IConnectionParam>, IConnectionParamList)
  private
    procedure ParseContent(const Content: WideString; const ItemSeparator, ValueSeparator: Char);
  public
    function ExistKey(const Key: WideString): Boolean;
    function ItemByKey(const Key: WideString): IConnectionParam;
    function TryGetValue(const Key: WideString; out Value: WideString): Boolean;
    class function New: IConnectionParamList;
    class function NewFromContent(const Content: WideString; const ItemSeparator, ValueSeparator: Char)
      : IConnectionParamList;
  end;

implementation

{ TConnectionParam }

function TConnectionParam.Key: WideString;
begin
  Result := _Key;
end;

function TConnectionParam.Value: WideString;
begin
  Result := _Value;
end;

constructor TConnectionParam.Create(const Key, Value: WideString);
begin
  if Length(Trim(Key)) < 1 then
    raise EConnectionParam.Create('Key can not be empty');
  _Key := Key;
  _Value := Value;
end;

class function TConnectionParam.New(const Key, Value: WideString): IConnectionParam;
begin
  Result := TConnectionParam.Create(Key, Value);
end;

class function TConnectionParam.NewByText(const Text: WideString; const Separator: Char): IConnectionParam;
var
  Key, Value: WideString;
  SeparatorPos: Integer;
begin
  SeparatorPos := Pos(Separator, Text);
  Key := Copy(Text, 1, Pred(SeparatorPos));
  Value := Copy(Text, Succ(SeparatorPos));
  Result := TConnectionParam.Create(Key, Value);
end;

{ TConnectionParamList }

function TConnectionParamList.ExistKey(const Key: WideString): Boolean;
begin
  Result := Assigned(ItemByKey(Key));
end;

function TConnectionParamList.ItemByKey(const Key: WideString): IConnectionParam;
var
  Item: IConnectionParam;
begin
  Result := nil;
  for Item in Self do
    if Key = Item.Key then
      Exit(Item);
end;

function TConnectionParamList.TryGetValue(const Key: WideString; out Value: WideString): Boolean;
var
  Item: IConnectionParam;
begin
  Item := ItemByKey(Key);
  Result := Assigned(Item);
  if Result then
    Value := Item.Value
  else
    Value := EmptyStr;
end;

procedure TConnectionParamList.ParseContent(const Content: WideString; const ItemSeparator, ValueSeparator: Char);
Var
  SeparatorPos, PosOffset: Integer;
  Text: WideString;
begin
  PosOffset := 1;
  repeat
    SeparatorPos := PosEx(ItemSeparator, Content, PosOffset);
    if SeparatorPos > 0 then
    begin
      Text := Copy(Content, PosOffset, SeparatorPos - PosOffset);
      if Length(Text) > 0 then
        Add(TConnectionParam.NewByText(Text, ValueSeparator));
      PosOffset := Succ(SeparatorPos);
    end;
  until SeparatorPos < 1;
  Text := Copy(Content, PosOffset, Succ(Length(Content) - PosOffset));
  if Length(Text) > 0 then
    Add(TConnectionParam.NewByText(Text, ValueSeparator));
end;

class function TConnectionParamList.New: IConnectionParamList;
begin
  Result := TConnectionParamList.Create;
end;

class function TConnectionParamList.NewFromContent(const Content: WideString; const ItemSeparator, ValueSeparator: Char)
  : IConnectionParamList;
begin
  Result := TConnectionParamList.New;
  (Result as TConnectionParamList).ParseContent(Content, ItemSeparator, ValueSeparator);
end;

end.
