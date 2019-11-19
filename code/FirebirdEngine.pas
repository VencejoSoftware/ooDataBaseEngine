unit FirebirdEngine;

interface

uses
  SysUtils, StrUtils,
  DB,
  uib, uibdataset, uiblib, uibase,
  DatabaseLogin,
  DatabaseEngine;

type
  TFirebirdEngine = class sealed(TInterfacedObject, IDatabaseEngine)
  strict private
    _Database: TUIBDatabase;
  public
    function Connect(const Login: IDatabaseLogin): Boolean;
    function Disconnect: Boolean;
    function IsConnected: Boolean;
    function OpenDataset(const Script: String): TDataset;
    function Execute(const Script: String): Boolean;
    function ExecuteReturning(const Script: String): TDataset;
    constructor Create;
    destructor Destroy; override;
    class function New: IDatabaseEngine;
  end;

implementation

function TFirebirdEngine.Connect(const Login: IDatabaseLogin): Boolean;
var
  Charset, Dialect, DBPath: String;
begin
  _Database.LibraryName := Login.Parameters.Items['LIB_PATH'];
  _Database.Params.Clear;
  _Database.UserName := Login.Credential.Login;
  _Database.PassWord := Login.Credential.PassWord;
  if Login.Parameters.TryGetValue('CHARSET', Charset) then
  begin
    _Database.Params.Append(Format('DEFAULT CHARACTER SET %s', [Charset]));
    _Database.Params.Append(Format('SET NAMES %s', [Charset]));
    _Database.Params.Append(Format('lc_ctype=%s', [Charset]));
  end;
  if Login.Parameters.TryGetValue('DIALECT', Dialect) then
  begin
    _Database.Params.Append(Format('sql_dialect=%s', [Dialect]));
    _Database.SQLDialect := StrToInt(Dialect);
  end;
  if Login.Parameters.TryGetValue('DB_PATH', DBPath) then
  begin
    _Database.DatabaseName := DBPath;
  end;
  _Database.Connected := True;
  Result := _Database.Connected;
end;

function TFirebirdEngine.IsConnected: Boolean;
begin
  Result := _Database.Connected;
end;

function TFirebirdEngine.Disconnect: Boolean;
begin
  _Database.Connected := False;
  Result := not _Database.Connected;
end;

function TFirebirdEngine.OpenDataset(const Script: String): TDataset;
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

function TFirebirdEngine.Execute(const Script: String): Boolean;
var
  Transaction: TUIBTransaction;
  ScriptExecute: TUIBScript;
begin
  Result := False;
  Transaction := TUIBTransaction.Create(_Database);
  try
    Transaction.Database := _Database;
    Transaction.Options := [tpConcurrency, tpWait, tpWrite];
    Transaction.StartTransaction;
    try
      ScriptExecute := TUIBScript.Create(_Database);
      try
        ScriptExecute.Database := _Database;
        ScriptExecute.Transaction := Transaction;
        if RightStr(Script, 1) <> ';' then
          ScriptExecute.Script.Text := Script + ';'
        else
          ScriptExecute.Script.Text := Script;
        ScriptExecute.ExecuteScript;
        Result := True;
      finally
        ScriptExecute.Free;
      end;
    except
      Transaction.RollBack;
    end;
  finally
    Transaction.Free;
  end;
end;

function TFirebirdEngine.ExecuteReturning(const Script: String): TDataset;
var
  Dataset: TUIBDataSet;
  Transaction: TUIBTransaction;
begin
  Dataset := TUIBDataSet.Create(_Database);
  Transaction := TUIBTransaction.Create(Dataset);
  Transaction.Database := _Database;
  Transaction.Options := [tpConcurrency, tpWait, tpWrite];
  Dataset.Database := Transaction.Database;
  Dataset.Transaction := Transaction;
  Dataset.SQL.Text := Script;
  Transaction.StartTransaction;
  try
    Dataset.Open;
    Transaction.Commit;
    Dataset.First;
  except
    Transaction.RollBack;
  end;
  Result := Dataset;
end;

constructor TFirebirdEngine.Create;
begin
  _Database := TUIBDatabase.Create(nil);
end;

destructor TFirebirdEngine.Destroy;
begin
  Disconnect;
  _Database.Free;
  inherited;
end;

class function TFirebirdEngine.New: IDatabaseEngine;
begin
  Result := TFirebirdEngine.Create;
end;

end.
