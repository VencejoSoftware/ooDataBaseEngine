unit FirebirdConnection;

interface

uses
  SysUtils, StrUtils,
  DB,
  uib, uibdataset, uiblib, uibase,
  DBConnection, FirebirdConnectionConfig;

type
  TFirebirdConnection = class sealed(TInterfacedObject, IDBConnection)
  strict private
    _Database: TUIBDatabase;
    _AlterTransaction: TUIBTransaction;
  private
    function ExecuteWithTransaction(const Script: String; const Transaction: TUIBTransaction): Boolean;
  public
    function InTransaction: Boolean;
    function BeginTransaction: Boolean;
    function CommitTransaction: Boolean;
    function RollbackTransaction: Boolean;
    function OpenDataset(const Script: String): TDataset;
    function Execute(const Script: String): Boolean;
    function ExecuteInTransaction(const Script: String): Boolean;
    function Connect: Boolean;
    function Disconnect: Boolean;
    function IsConnected: Boolean;
    constructor Create(const Config: IFirebirdConnectionConfig);
    destructor Destroy; override;
    class function New(const Config: IFirebirdConnectionConfig): IDBConnection;
  end;

implementation

function TFirebirdConnection.InTransaction: Boolean;
begin
  Result := _AlterTransaction.InTransaction;
end;

function TFirebirdConnection.BeginTransaction: Boolean;
begin
  _AlterTransaction.StartTransaction;
  Result := True;
end;

function TFirebirdConnection.CommitTransaction: Boolean;
begin
  _AlterTransaction.Commit;
  Result := True;
end;

function TFirebirdConnection.RollbackTransaction: Boolean;
begin
  if InTransaction then
    _AlterTransaction.RollBack;
  Result := True;
end;

function TFirebirdConnection.OpenDataset(const Script: String): TDataset;
var
  Dataset: TUIBDataSet;
  Transaction: TUIBTransaction;
begin
  Dataset := TUIBDataSet.Create(_Database);
  Transaction := TUIBTransaction.Create(Dataset);
  Transaction.Database := _Database;
  Transaction.Options := [tpRead, tpNowait, tpReadCommitted, tpRecVersion];
  Dataset.Database := Transaction.Database;
  Dataset.Transaction := Transaction;
  Dataset.SQL.Text := Script;
  Dataset.Open;
  Result := Dataset;
end;

function TFirebirdConnection.ExecuteWithTransaction(const Script: String; const Transaction: TUIBTransaction): Boolean;
var
  ScriptExecute: TUIBScript;
begin
  ScriptExecute := TUIBScript.Create(_Database);
  try
    ScriptExecute.Database := _Database;
    ScriptExecute.Transaction := Transaction;
    ScriptExecute.Script.Text := Script;
    if RightStr(Trim(ScriptExecute.Script.Text), 1) <> ';' then
      ScriptExecute.Script.Text := ScriptExecute.Script.Text + ';';
    ScriptExecute.ExecuteScript;
    Result := True;
  finally
    ScriptExecute.Free;
  end;
end;

function TFirebirdConnection.Execute(const Script: String): Boolean;
var
  Transaction: TUIBTransaction;
begin
  Result := False;
  Transaction := TUIBTransaction.Create(_Database);
  try
    Transaction.Database := _Database;
    Transaction.Options := _AlterTransaction.Options;
    Transaction.StartTransaction;
    try
      Result := ExecuteWithTransaction(Script, Transaction);
      Result := True;
    except
      Transaction.RollBack;
    end;
  finally
    Transaction.Free;
  end;
end;

function TFirebirdConnection.ExecuteInTransaction(const Script: String): Boolean;
begin
  Result := ExecuteWithTransaction(Script, _AlterTransaction);
end;

function TFirebirdConnection.Connect: Boolean;
begin
  _Database.Connected := True;
  Result := _Database.Connected;
end;

function TFirebirdConnection.Disconnect: Boolean;
begin
  _Database.Connected := False;
  Result := not _Database.Connected;
end;

function TFirebirdConnection.IsConnected: Boolean;
begin
  Result := _Database.Connected;
end;

constructor TFirebirdConnection.Create(const Config: IFirebirdConnectionConfig);
begin
  _Database := TUIBDatabase.Create(nil);
  _AlterTransaction := TUIBTransaction.Create(_Database);
  _AlterTransaction.Database := _Database;
  _AlterTransaction.Options := [tpConcurrency, tpWait, tpWrite];
  _Database.Params.Clear;
  _Database.Params.Append(Format('sql_dialect=%d', [Config.Dialect]));
  _Database.Params.Append(Format('DEFAULT CHARACTER SET %s', [Config.Charset]));
  _Database.Params.Append(Format('SET NAMES %s', [Config.Charset]));
  _Database.Params.Append(Format('lc_ctype=%s', [Config.Charset]));
  if FileExists(Config.LibraryPath) then
    _Database.LibraryName := Config.LibraryPath
  else
    _Database.LibraryName := IncludeTrailingPathDelimiter(Config.LibraryPath) + 'fbclient' + {$IFDEF CPUX64} '64' +
{$ENDIF}'.dll';
  _Database.UserName := Config.User;
  _Database.PassWord := Config.Pass;
  _Database.Role := Config.Role;
  _Database.DatabaseName := Config.Path;
  _Database.SQLDialect := Config.Dialect;
end;

destructor TFirebirdConnection.Destroy;
begin
  if InTransaction then
    RollbackTransaction;
  Disconnect;
  _AlterTransaction.Free;
  _Database.Free;
  inherited;
end;

class function TFirebirdConnection.New(const Config: IFirebirdConnectionConfig): IDBConnection;
begin
  Result := TFirebirdConnection.Create(Config);
end;

end.
