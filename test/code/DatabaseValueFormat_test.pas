{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
unit DatabaseValueFormat_test;

interface

uses
  Classes, SysUtils,
  DatabaseValueFormat,
{$IFDEF FPC}
  fpcunit, testregistry
{$ELSE}
  TestFramework
{$ENDIF};

type
  TSQLDatabaseDateFormatTest = class sealed(TTestCase)
  published
    procedure Date10_11_19ReturnText;
    procedure Date10_11_19_23_22_21_20ReturnText;
  end;

  TOracleDatabaseDateFormatTest = class sealed(TTestCase)
  published
    procedure Date10_11_19ReturnText;
    procedure Date10_11_19_23_22_21_20ReturnText;
  end;

implementation

{ TSQLDatabaseDateFormatTest }

procedure TSQLDatabaseDateFormatTest.Date10_11_19ReturnText;
var
  DateTime: TDateTime;
begin
  DateTime := EncodeDate(2019, 11, 10);
  CheckEquals(QuotedStr('11/10/2019'), TSQLDatabaseDateFormat.New.Apply(DateTime));
end;

procedure TSQLDatabaseDateFormatTest.Date10_11_19_23_22_21_20ReturnText;
var
  DateTime: TDateTime;
begin
  DateTime := EncodeDate(2019, 11, 10) + EncodeTime(23, 22, 21, 20);
  CheckEquals(QuotedStr('11/10/2019 23:22:21'), TSQLDatabaseDateFormat.New.Apply(DateTime));
end;

{ TOracleDatabaseDateFormatTest }

procedure TOracleDatabaseDateFormatTest.Date10_11_19ReturnText;
var
  DateTime: TDateTime;
begin
  DateTime := EncodeDate(2019, 11, 10);
  CheckEquals(QuotedStr('11/10/2019'), TSQLDatabaseDateFormat.New.Apply(DateTime));
end;

procedure TOracleDatabaseDateFormatTest.Date10_11_19_23_22_21_20ReturnText;
var
  DateTime: TDateTime;
begin
  DateTime := EncodeDate(2019, 11, 10) + EncodeTime(23, 22, 21, 20);
  CheckEquals('TO_DATE(''10/11/2019 23:22:21'', ''DD/MM/YYYYHH24:MI:SS'')',
    TOracleDatabaseDateFormat.New.Apply(DateTime));
end;

initialization

RegisterTests('DatabaseValueFormat test', [TSQLDatabaseDateFormatTest {$IFNDEF FPC}.Suite
{$ENDIF}, TOracleDatabaseDateFormatTest{$IFNDEF FPC}.Suite {$ENDIF}]);

end.
