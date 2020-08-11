{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database engine connection for firebird
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FirebirdEngine;

interface

uses
  SysUtils,
  ZDbcIntfs,
  ConnectionSettings, FirebirdSettings,
  DatabaseEngine,
  ZeosDatabaseEngine;

type
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseEngine))
  Firebird database engine
  @member(Connect @seealso(IDatabaseEngine.Connect))
  @member(New Create a new @classname as interface)
}
{$ENDREGION}
  TFirebirdEngine = class sealed(TZeosEngine)
  public
    function Connect(const Settings: IConnectionSettings; const PasswordKey: WideString = ''): Boolean; override;
    class function New: IDatabaseEngine;
  end;

implementation

function TFirebirdEngine.Connect(const Settings: IConnectionSettings; const PasswordKey: WideString = ''): Boolean;
var
  FirebirdSettings: IFirebirdSettings;
begin
  inherited Connect(Settings, PasswordKey);
  FirebirdSettings := (Settings as IFirebirdSettings);
  Database.Protocol := FirebirdSettings.Version;
  Database.Properties.Values['dialect'] := IntToStr(FirebirdSettings.Dialect);
  Database.ClientCodepage := FirebirdSettings.Collation;
  Database.Properties.Add('lc_ctype=' + FirebirdSettings.Collation);
  Database.Properties.Add('Codepage=' + FirebirdSettings.Collation);
  Database.Properties.Add('isc_tpb_concurrency');
  Database.Properties.Add('isc_tpb_nowait');
  Database.Properties.Add('isc_tpb_read_committed');
  Database.Properties.Add('isc_tpb_rec_version');
  Database.Properties.Add('isc_tpb_read');
  Database.Properties.Add('isc_tpb_write');
  Database.TransactIsolationLevel := TZTransactIsolationLevel.tiReadCommitted;
  Database.AutoCommit := False;
  Database.Connect;
  Database.Password := EmptyWideStr;
  Result := IsConnected;
end;

class function TFirebirdEngine.New: IDatabaseEngine;
begin
  Result := TFirebirdEngine.Create;
end;

end.
