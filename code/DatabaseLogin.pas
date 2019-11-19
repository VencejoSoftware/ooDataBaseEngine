unit DatabaseLogin;

interface

uses
  SysUtils,
  Generics.Collections,
  Credential;

type
  TConnectionParameters = class sealed(TDictionary<String, String>)
  public
    class function New: TConnectionParameters;
  end;

  IDatabaseLogin = interface
    ['{0A572E27-28FC-49F6-A979-9F82EB3BEA11}']
    function Credential: ICredential;
    function Parameters: TConnectionParameters;
    function ConnectionString: WideString;
  end;

  TDatabaseLogin = class sealed(TInterfacedObject, IDatabaseLogin)
  strict private
    _Credential: ICredential;
    _Parameters: TConnectionParameters;
  public
    function Credential: ICredential;
    function Parameters: TConnectionParameters;
    function ConnectionString: WideString;
    constructor Create(const Credential: ICredential);
    destructor Destroy; override;
    class function New(const Credential: ICredential): IDatabaseLogin;
  end;

implementation

function TDatabaseLogin.Credential: ICredential;
begin
  Result := _Credential;
end;

function TDatabaseLogin.Parameters: TConnectionParameters;
begin
  Result := _Parameters;
end;

function TDatabaseLogin.ConnectionString: WideString;
const
  ORA_CONNECTION_STRING = 'Provider=OraOLEDB.Oracle;Data Source=%s; User Id=%s; Password=%s';
var
  TNSName: String;
begin
  Result := EmptyStr;
  if _Parameters.Items['ENGINE'] = 'Oracle' then
  begin
    _Parameters.TryGetValue('TNS_NAME', TNSName);
    Result := Format(ORA_CONNECTION_STRING, [TNSName, _Credential.Login, _Credential.Password]);
  end;
end;

constructor TDatabaseLogin.Create(const Credential: ICredential);
begin
  _Credential := Credential;
  _Parameters := TConnectionParameters.New;
end;

destructor TDatabaseLogin.Destroy;
begin
  _Parameters.Free;
  inherited;
end;

class function TDatabaseLogin.New(const Credential: ICredential): IDatabaseLogin;
begin
  Result := TDatabaseLogin.Create(Credential);
end;

{ TConnectionParameters }

class function TConnectionParameters.New: TConnectionParameters;
begin
  Result := TConnectionParameters.Create;
end;

end.
