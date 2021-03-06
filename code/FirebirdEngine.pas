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
  SysUtils, StrUtils,
  DB,
  ZConnection, ZDataset, ZDbcIntfs, ZSqlProcessor, ZScriptParser, ZClasses,
  DatabaseLogin,
  ExecutionResult, FailedExecution, SuccededExecution, DatasetExecution,
  DatabaseEngine;

type
{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseEngine))
  Firebird database connection
  @member(InTransaction @seealso(IDatabaseEngine.InTransaction))
  @member(BeginTransaction @seealso(IDatabaseEngine.BeginTransaction))
  @member(CommitTransaction @seealso(IDatabaseEngine.CommitTransaction))
  @member(RollbackTransaction @seealso(IDatabaseEngine.RollbackTransaction))
  @member(Connect @seealso(IDatabaseEngine.Connect))
  @member(Disconnect @seealso(IDatabaseEngine.Disconnect))
  @member(IsConnected @seealso(IDatabaseEngine.IsConnected))
  @member(OpenDataset @seealso(IDatabaseEngine.OpenDataset))
  @member(Execute @seealso(IDatabaseEngine.Execute))
  @member(ExecuteReturning @seealso(IDatabaseEngine.ExecuteReturning))
  @member(ExecuteScript @seealso(IDatabaseEngine.ExecuteScript))
  @member(
    SanitizeEOLStatement Checks for end of char delimiter (';') and appends if not exist
    @return(Statement text with ';' end of char)
  )
  @member(Create Object constructor)
  @member(Destroy Object destructor)
  @member(New Create a new @classname as interface)
}
{$ENDREGION}
  TFirebirdEngine = class sealed(TInterfacedObject, IDatabaseEngine)
  const
    STATEMENT_DELIMITER = ';';
  strict private
    _Database: TZConnection;
  private
    function SanitizeEOLStatement(const Statement: WideString): WideString;
  public
    function InTransaction: Boolean;
    function BeginTransaction: Boolean;
    function CommitTransaction: Boolean;
    function RollbackTransaction: Boolean;
    function Connect(const Login: IDatabaseLogin): Boolean;
    function Disconnect: Boolean;
    function IsConnected: Boolean;
    function OpenDataset(const Statement: WideString): IExecutionResult;
    function Execute(const Statement: WideString; const UseGlobalTransaction: Boolean): IExecutionResult;
    function ExecuteReturning(const Statement: WideString; const UseGlobalTransaction: Boolean): IExecutionResult;
    function ExecuteScript(const StatementList: array of WideString): IExecutionResult;
    constructor Create;
    destructor Destroy; override;
    class function New: IDatabaseEngine;
  end;

implementation

function TFirebirdEngine.InTransaction: Boolean;
begin
  Result := _Database.InTransaction;
end;

function TFirebirdEngine.BeginTransaction: Boolean;
begin
  if not InTransaction then
    _Database.StartTransaction;
  Result := True;
end;

function TFirebirdEngine.CommitTransaction: Boolean;
begin
  if InTransaction then
    _Database.Commit;
  Result := True;
end;

function TFirebirdEngine.RollbackTransaction: Boolean;
begin
  if InTransaction then
    _Database.RollBack;
  Result := True;
end;

function TFirebirdEngine.Connect(const Login: IDatabaseLogin): Boolean;
var
  Charset, Dialect, DBPath, ServerHostName, Port: WideString;
begin
  _Database.Protocol := 'firebird';
  _Database.User := Login.User;
  _Database.Password := Login.Password;
  _Database.LibraryLocation := Login.Parameters.ItemByKey('LIB_PATH').Value;
  _Database.TransactIsolationLevel := tiReadCommitted;
  if Login.Parameters.TryGetValue('DB_PATH', DBPath) then
    _Database.Database := DBPath;
  if Login.Parameters.TryGetValue('host', ServerHostName) then
    _Database.HostName := ServerHostName;
  if Login.Parameters.TryGetValue('port', Port) then
    _Database.Port := StrToInt(Port);
  _Database.Properties.Clear;
  if Login.Parameters.TryGetValue('DIALECT', Dialect) then
    _Database.Properties.Values['dialect'] := Dialect;
  if Login.Parameters.TryGetValue('CHARSET', Charset) then
  begin
    _Database.ClientCodepage := Charset;
    _Database.Properties.Add('lc_ctype=' + Charset);
    _Database.Properties.Add('Codepage=' + Charset);
    _Database.Properties.Add('isc_tpb_concurrency');
    _Database.Properties.Add('isc_tpb_nowait');
  end;
  _Database.Connect;
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

function TFirebirdEngine.OpenDataset(const Statement: WideString): IExecutionResult;
var
  Dataset: TZquery;
begin
  Dataset := TZquery.Create(_Database);
  try
    Dataset.Connection := _Database;
    Dataset.SQL.Text := Statement;
    Dataset.Open;
    Result := TDatasetExecution.New(Statement, Dataset);
  except
    on E: Exception do
    begin
      Dataset.Free;
      Result := TFailedExecution.New(Statement, 0, E.Message);
    end;
  end;
end;

function TFirebirdEngine.Execute(const Statement: WideString; const UseGlobalTransaction: Boolean): IExecutionResult;
var
  AffectedRows: Integer;
begin
  if not UseGlobalTransaction then
    BeginTransaction;
  try
    if _Database.ExecuteDirect(Statement, AffectedRows) then
    begin
      if not UseGlobalTransaction then
        CommitTransaction;
      Result := TSuccededExecution.New(Statement, AffectedRows);
    end;
  except
    on E: Exception do
    begin
      if not UseGlobalTransaction then
        RollbackTransaction;
      Result := TFailedExecution.New(Statement, 0, E.Message);
    end;
  end;
end;

function TFirebirdEngine.ExecuteReturning(const Statement: WideString; const UseGlobalTransaction: Boolean)
  : IExecutionResult;
var
  Dataset: TZquery;
begin
  Dataset := TZquery.Create(_Database);
  try
    Dataset.Connection := _Database;
    Dataset.SQL.Text := Statement;
    if not UseGlobalTransaction then
      BeginTransaction;
    Dataset.Open;
    if not UseGlobalTransaction then
      CommitTransaction;
    Dataset.First;
    Result := TDatasetExecution.New(Statement, Dataset);
  except
    on E: Exception do
    begin
      if not UseGlobalTransaction then
        RollbackTransaction;
      Dataset.Free;
      Result := TFailedExecution.New(Statement, 0, E.Message);
    end;
  end;
end;

function TFirebirdEngine.SanitizeEOLStatement(const Statement: WideString): WideString;
begin
  Result := Statement;
  if RightStr(Result, 1) <> STATEMENT_DELIMITER then
    Result := Result + STATEMENT_DELIMITER;
end;

function TFirebirdEngine.ExecuteScript(const StatementList: array of WideString): IExecutionResult;
var
  SQLProcessor: TZSQLProcessor;
  Statement: WideString;
begin
  SQLProcessor := TZSQLProcessor.Create(_Database);
  try
    SQLProcessor.Connection := _Database;
    SQLProcessor.Delimiter := STATEMENT_DELIMITER;
    SQLProcessor.ParamCheck := False;
    SQLProcessor.DelimiterType := dtSetTerm;
    for Statement in StatementList do
      SQLProcessor.Script.Append(SanitizeEOLStatement(Statement));
    try
      SQLProcessor.Execute;
      Result := TSuccededExecution.New(Statement, SQLProcessor.StatementCount);
    except
      on E: EZSQLException do
        Result := TFailedExecution.New(Statement, E.ErrorCode, E.Message);
      on E: Exception do
        Result := TFailedExecution.New(Statement, 0, E.Message);
    end;
  finally
    SQLProcessor.Free;
  end;
end;

constructor TFirebirdEngine.Create;
begin
  _Database := TZConnection.Create(nil);
end;

destructor TFirebirdEngine.Destroy;
begin
  if IsConnected and InTransaction then
    RollbackTransaction;
  Disconnect;
  _Database.Free;
  inherited;
end;

class function TFirebirdEngine.New: IDatabaseEngine;
begin
  Result := TFirebirdEngine.Create;
end;

end.
