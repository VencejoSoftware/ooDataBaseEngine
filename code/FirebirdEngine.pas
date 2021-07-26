{$REGION 'documentation'}
{
  Copyright (c) 2021, Vencejo Software
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
  ConnectionSetting, FirebirdSetting,
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
    function Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean; override;
    class function New: IDatabaseEngine;
  end;

implementation

function TFirebirdEngine.Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean;
var
  FirebirdSetting: IFirebirdSetting;
begin
  inherited Connect(Setting, PasswordKey);
  FirebirdSetting := (Setting as IFirebirdSetting);
  Database.Protocol := FirebirdSetting.Version;
  Database.Properties.Values['dialect'] := IntToStr(FirebirdSetting.Dialect);
  Database.ClientCodepage := FirebirdSetting.Collation;
  Database.Properties.Add('lc_ctype=' + FirebirdSetting.Collation);
  Database.Properties.Add('Codepage=' + FirebirdSetting.Collation);
  Database.Properties.Add('isc_tpb_concurrency');
  Database.Properties.Add('isc_tpb_nowait');
  Database.Properties.Add('isc_tpb_read_committed');
  Database.Properties.Add('isc_tpb_rec_version');
  Database.Properties.Add('isc_tpb_read');
  Database.Properties.Add('isc_tpb_write');
  Database.TransactIsolationLevel := TZTransactIsolationLevel.tiReadCommitted;
  Database.Connect;
  Database.Password := EmptyWideStr;
  Result := IsConnected;
end;

class function TFirebirdEngine.New: IDatabaseEngine;
begin
  Result := TFirebirdEngine.Create;
end;

end.
