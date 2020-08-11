{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database value format object
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit DatabaseValueFormat;

interface

uses
  SysUtils;

type
{$REGION 'documentation'}
{
  @abstract(Connection engine parameter object)
  Object to format datetime value to database format
  @member(
    Apply Parse datetime value and build with format
    @param(Value Datatime value)
    @return(Formatted datetime)
  )
}
{$ENDREGION}
  IDatabaseDateFormat = interface
    function Apply(const Value: TDateTime): WideString;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseDateFormat))
  Basic datetime format with format mm/dd/yyyy hh:mm:ss, using typically for firebird databases
  @member(Apply @seealso(IDatabaseDateFormat.Apply))
  @member(
    IsOnlyDate Checks if value has only date part (not time)
    @return(@true if only has the "date" part, @false if is a full datetime)
  )
  @member(New Create a new @classname as interface)
}
{$ENDREGION}

  TSQLDatabaseDateFormat = class sealed(TInterfacedObject, IDatabaseDateFormat)
  private
    function IsOnlyDate(const Value: TDateTime): Boolean;
  public
    function Apply(const Value: TDateTime): WideString;
    class function New: IDatabaseDateFormat;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseDateFormat))
  Oracle datetime format
  @member(Apply @seealso(IDatabaseDateFormat.Apply))
  @member(
    IsOnlyDate Checks if value has only date part (not time)
    @return(@true if only has the "date" part, @false if is a full datetime)
  )
  @member(New Create a new @classname as interface)
}
{$ENDREGION}

  TOracleDatabaseDateFormat = class sealed(TInterfacedObject, IDatabaseDateFormat)
  private
    function IsOnlyDate(const Value: TDateTime): Boolean;
  public
    function Apply(const Value: TDateTime): WideString;
    class function New: IDatabaseDateFormat;
  end;

implementation

{ TSQLDatabaseDateFormat }

function TSQLDatabaseDateFormat.IsOnlyDate(const Value: TDateTime): Boolean;
begin
  Result := Frac(Value) = 0;
end;

function TSQLDatabaseDateFormat.Apply(const Value: TDateTime): WideString;
const
  FORMAT_DATE = 'MM/DD/YYYY';
  FORMAT_TIME = 'HH:NN:SS';
  FORMAT_DATETIME = FORMAT_DATE + ' ' + FORMAT_TIME;
  FORMAT: array [Boolean] of string = (FORMAT_DATETIME, FORMAT_DATE);
begin
  Result := QuotedStr(FormatDateTime(FORMAT[IsOnlyDate(Value)], Value));
end;

class function TSQLDatabaseDateFormat.New: IDatabaseDateFormat;
begin
  Result := TSQLDatabaseDateFormat.Create;
end;

{ TOracleDatabaseDateFormat }

function TOracleDatabaseDateFormat.IsOnlyDate(const Value: TDateTime): Boolean;
begin
  Result := Frac(Value) = 0;
end;

function TOracleDatabaseDateFormat.Apply(const Value: TDateTime): WideString;
const
  FORMAT_DATE = 'DD/MM/YYYY';
  FORMAT_TIME = 'HH:NN:SS';
  FORMAT_DATETIME = FORMAT_DATE + ' ' + FORMAT_TIME;
  ORACLE_FORMAT_TIME = 'HH24:MI:SS';
  ORACLE_FORMAT_DATETIME = FORMAT_DATE + ORACLE_FORMAT_TIME;
begin
  if IsOnlyDate(Value) then
    Result := FORMAT('TO_DATE(%s, %s)', [QuotedStr(FormatDateTime(FORMAT_DATE, Value)), QuotedStr(FORMAT_DATE)])
  else
    Result := FORMAT('TO_DATE(%s, %s)', [QuotedStr(FormatDateTime(FORMAT_DATETIME, Value)),
      QuotedStr(ORACLE_FORMAT_DATETIME)]);
end;

class function TOracleDatabaseDateFormat.New: IDatabaseDateFormat;
begin
  Result := TOracleDatabaseDateFormat.Create;
end;

end.
