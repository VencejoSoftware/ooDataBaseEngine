{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit ConnectionParam_test;

interface

uses
  Classes, SysUtils,
  ConnectionParam,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TConnectionParamTest = class sealed(TTestCase)
  published
    procedure KeyIsALPHA;
    procedure EmptyKeyRaiseError;
    procedure ValueIs1234;
  end;

  TConnectionParamListTest = class sealed(TTestCase)
  strict private
    _List: IConnectionParamList;
  public
    procedure SetUp; override;
  published
    procedure ParseContentReturn4Items;
    procedure ExistKeyCasedItem1ReturnFalse;
    procedure ExistKeyItem1ReturnTrue;
    procedure ItemByEndOfIsOk;
    procedure TryGetValueItem2ReturnAlpha;
    procedure TryGetValueItemGhostReturnFalse;
  end;

implementation

{ TConnectionParamTest }
procedure TConnectionParamTest.KeyIsALPHA;
begin
  CheckEquals('Alpha', TConnectionParam.New('Alpha', EmptyStr).Key);
end;

procedure TConnectionParamTest.EmptyKeyRaiseError;
var
  Failed: Boolean;
begin
  Failed := False;
  try
    TConnectionParam.New(EmptyStr, EmptyStr);
  except
    on E: EConnectionParam do
    begin
      CheckEquals('Key can not be empty', E.Message);
      Failed := True;
    end;
  end;
  CheckTrue(Failed);
end;

procedure TConnectionParamTest.ValueIs1234;
begin
  CheckEquals('1234', TConnectionParam.New('Alpha', '1234').Value);
end;

{ TConnectionParamListTest }

procedure TConnectionParamListTest.ParseContentReturn4Items;
begin
  CheckEquals(4, _List.Count);
end;

procedure TConnectionParamListTest.ExistKeyItem1ReturnTrue;
begin
  CheckTrue(_List.ExistKey('ITEM1'));
end;

procedure TConnectionParamListTest.ExistKeyCasedItem1ReturnFalse;
begin
  CheckFalse(_List.ExistKey('item1'));
end;

procedure TConnectionParamListTest.ItemByEndOfIsOk;
var
  Item: IConnectionParam;
begin
  Item := _List.ItemByKey('enOf');
  CheckEquals('enOf', Item.Key);
  CheckEquals('finis!', Item.Value);
end;

procedure TConnectionParamListTest.TryGetValueItem2ReturnAlpha;
var
  Value: WideString;
begin
  CheckTrue(_List.TryGetValue('Item2', Value));
  CheckEquals('alpha', Value);
end;

procedure TConnectionParamListTest.TryGetValueItemGhostReturnFalse;
var
  Value: WideString;
begin
  CheckFalse(_List.TryGetValue('ItemGhost', Value));
end;

procedure TConnectionParamListTest.SetUp;
begin
  inherited;
  _List := TConnectionParamList.NewFromContent('ITEM1=123|Item2=alpha|item3=|enOf=finis!', '|', '=');
end;

initialization

RegisterTests('ConnectionParam test', [TConnectionParamTest {$IFNDEF FPC}.Suite {$ENDIF}, TConnectionParamListTest
{$IFNDEF FPC}.Suite{$ENDIF}]);

end.
