{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Simple method to cache entity and lists
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit EntityCached;

interface

uses
  SysUtils, DateUtils,
  System.RTTI,
  Generics.Collections;

type
  IEntityCached<T> = interface
    ['{C745B362-5E64-42F4-A84A-405F186B964E}']
    function Entity: T;
    function IsExpired: Boolean;
  end;

  TEntityCached<T> = class sealed(TInterfacedObject, IEntityCached<T>)
  strict private
    _Entity: T;
    _ExpirationTime: TDateTime;
  public
    function Entity: T;
    function IsExpired: Boolean;
    constructor Create(const Entity: T; const SecondsToExpire: Word);
    class function New(const Entity: T; const SecondsToExpire: Word): IEntityCached<T>;
  end;

  IEntityCachedList<T> = interface
    ['{7A3F1CB2-9E8F-4951-8DA0-50F7E9AA7B40}']
    function Add(const Entity: T): Integer;
    function ItemByCode(const Code: WideString): T;
    function Update(const Code: WideString; const Entity: T): Boolean;
  end;

  TEntityCachedList<T> = class(TInterfacedObject, IEntityCachedList<T>)
  type
    TEntityComparator = reference to function(const Code: WideString; const Entity: T): Boolean;
    TEntityList = TList<IEntityCached<T>>;
  strict private
    _Comparator: TEntityComparator;
    _SecondsToExpire: Word;
    _List: TEntityList;
    function EntityCachedByCode(const Code: WideString): IEntityCached<T>;
    function IsAssignedEntity(const Entity: T): Boolean;
  public
    function Add(const Entity: T): Integer;
    function ItemByCode(const Code: WideString): T;
    function Update(const Code: WideString; const Entity: T): Boolean;
    constructor Create(const Comparator: TEntityComparator; const SecondsToExpire: Word);
    destructor Destroy; override;
    class function New(const Comparator: TEntityComparator; const SecondsToExpire: Word): IEntityCachedList<T>;
  end;

  IEntityQueryCached<T> = interface
    ['{33EA76E8-AAEB-4C9E-A24D-FBF016068D65}']
    function Filter: WideString;
    function List: T;
    function IsExpired: Boolean;
  end;

  TEntityQueryCached<T> = class sealed(TInterfacedObject, IEntityQueryCached<T>)
  strict private
    _Filter: WideString;
    _List: T;
    _ExpirationTime: TDateTime;
  public
    function Filter: WideString;
    function List: T;
    function IsExpired: Boolean;
    constructor Create(const Filter: WideString; const List: T; const SecondsToExpire: Word);
    destructor Destroy; override;
    class function New(const Filter: WideString; const List: T; const SecondsToExpire: Word): IEntityQueryCached<T>;
  end;

  IEntityQueryCachedList<T> = interface
    ['{BBB46A3D-2C4A-4395-BAD4-73238B55D0D4}']
    function Add(const Filter: WideString; const List: T): Integer;
    function ItemByFilter(const Filter: WideString): T;
    procedure Invalidate;
  end;

  TEntityQueryCachedList<T> = class(TInterfacedObject, IEntityQueryCachedList<T>)
  type
    TQueryList = TList<IEntityQueryCached<T>>;
  strict private
    _List: TQueryList;
    _SecondsToExpire: Word;
  public
    function Add(const Filter: WideString; const List: T): Integer;
    function ItemByFilter(const Filter: WideString): T;
    procedure Invalidate;
    constructor Create(const SecondsToExpire: Word);
    destructor Destroy; override;
    class function New(const SecondsToExpire: Word): IEntityQueryCachedList<T>;
  end;

implementation

{ TEntityCached<T> }

function TEntityCached<T>.Entity: T;
begin
  Result := _Entity;
end;

function TEntityCached<T>.IsExpired: Boolean;
begin
  Result := _ExpirationTime <= Now;
end;

constructor TEntityCached<T>.Create(const Entity: T; const SecondsToExpire: Word);
begin
  _Entity := Entity;
  _ExpirationTime := IncSecond(Now, SecondsToExpire);
end;

class function TEntityCached<T>.New(const Entity: T; const SecondsToExpire: Word): IEntityCached<T>;
begin
  Result := TEntityCached<T>.Create(Entity, SecondsToExpire);
end;

{ TEntityCachedList<T> }

function TEntityCachedList<T>.Add(const Entity: T): Integer;
begin
  Result := _List.Add(TEntityCached<T>.New(Entity, _SecondsToExpire));
end;

function TEntityCachedList<T>.EntityCachedByCode(const Code: WideString): IEntityCached<T>;
var
  Item: IEntityCached<T>;
begin
  Result := nil;
  for Item in _List do
    if _Comparator(Code, Item.Entity) then
      if Item.IsExpired then
      begin
        _List.Remove(Item);
        Break;
      end
      else
        Exit(Item);
end;

function TEntityCachedList<T>.ItemByCode(const Code: WideString): T;
var
  Item: IEntityCached<T>;
begin
  Item := EntityCachedByCode(Code);
  if Assigned(Item) then
    Result := Item.Entity
  else
    Result := Default (T);
end;

function TEntityCachedList<T>.IsAssignedEntity(const Entity: T): Boolean;
var
  CastedObject: TValue;
begin
  Result := False;
  CastedObject := TValue.From<T>(Entity);
  if CastedObject.IsObject then
    Result := CastedObject.AsObject <> nil;
end;

function TEntityCachedList<T>.Update(const Code: WideString; const Entity: T): Boolean;
var
  Item: IEntityCached<T>;
begin
  Item := EntityCachedByCode(Code);
  if Assigned(Item) then
    _List.Remove(Item);
  if IsAssignedEntity(Entity) then
    Add(Entity);
end;

constructor TEntityCachedList<T>.Create(const Comparator: TEntityComparator; const SecondsToExpire: Word);
begin
  _Comparator := Comparator;
  _SecondsToExpire := SecondsToExpire;
  _List := TEntityList.Create;
end;

destructor TEntityCachedList<T>.Destroy;
begin
  _List.Free;
  inherited;
end;

class function TEntityCachedList<T>.New(const Comparator: TEntityComparator; const SecondsToExpire: Word)
  : IEntityCachedList<T>;
begin
  Result := Create(Comparator, SecondsToExpire);
end;

{ TEntityQueryCached }

function TEntityQueryCached<T>.Filter: WideString;
begin
  Result := _Filter;
end;

function TEntityQueryCached<T>.IsExpired: Boolean;
begin
  Result := _ExpirationTime <= Now;
end;

function TEntityQueryCached<T>.List: T;
begin
  Result := _List;
end;

constructor TEntityQueryCached<T>.Create(const Filter: WideString; const List: T; const SecondsToExpire: Word);
begin
  _Filter := Filter;
  _List := List;
  _ExpirationTime := IncSecond(Now, SecondsToExpire);
end;

destructor TEntityQueryCached<T>.Destroy;
var
  CastedObject: TValue;
begin
  CastedObject := TValue.From<T>(_List);
  if CastedObject.IsObject then
    CastedObject.AsObject.Free;
  inherited;
end;

class function TEntityQueryCached<T>.New(const Filter: WideString; const List: T; const SecondsToExpire: Word)
  : IEntityQueryCached<T>;
begin
  Result := TEntityQueryCached<T>.Create(Filter, List, SecondsToExpire);
end;

{ TEntityQueryCachedList }

function TEntityQueryCachedList<T>.Add(const Filter: WideString; const List: T): Integer;
begin
  Result := _List.Add(TEntityQueryCached<T>.New(Filter, List, _SecondsToExpire));
end;

function TEntityQueryCachedList<T>.ItemByFilter(const Filter: WideString): T;
var
  Item: IEntityQueryCached<T>;
begin
  Result := Default (T);
  for Item in _List do
    if SameText(Filter, Item.Filter) then
      if Item.IsExpired then
      begin
        _List.Remove(Item);
        Break;
      end
      else
        Exit(Item.List);
end;

procedure TEntityQueryCachedList<T>.Invalidate;
begin
  _List.Clear;
end;

constructor TEntityQueryCachedList<T>.Create(const SecondsToExpire: Word);
begin
  _List := TQueryList.Create;
  _SecondsToExpire := SecondsToExpire;
end;

destructor TEntityQueryCachedList<T>.Destroy;
begin
  _List.Free;
  inherited;
end;

class function TEntityQueryCachedList<T>.New(const SecondsToExpire: Word): IEntityQueryCachedList<T>;
begin
  Result := TEntityQueryCachedList<T>.Create(SecondsToExpire);
end;

end.
