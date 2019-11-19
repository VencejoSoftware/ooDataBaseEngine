unit DatabaseValueFormat;

interface

uses
  SysUtils;

type
  IDatabaseDateFormat = interface
    function Apply(const Value: TDateTime): String;
  end;

  TSQLDatabaseDateFormat = class sealed(TInterfacedObject, IDatabaseDateFormat)
  public
    function Apply(const Value: TDateTime): String;
    class function New: IDatabaseDateFormat;
  end;

implementation

function TSQLDatabaseDateFormat.Apply(const Value: TDateTime): String;
begin
  Result := QuotedStr(FormatDateTime('mm/dd/yyyy hh:mm:ss', Value));
end;

class function TSQLDatabaseDateFormat.New: IDatabaseDateFormat;
begin
  Result := TSQLDatabaseDateFormat.Create;
end;

end.
