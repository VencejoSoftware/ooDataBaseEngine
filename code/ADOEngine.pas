unit ADOEngine;

interface

uses
  ActiveX,
  SysUtils,
  DB,
  ADODB,
  DatabaseLogin,
  DatabaseEngine;

type
  TADOEngine = class sealed(TInterfacedObject, IDatabaseEngine)
  strict private
    _Connection: TADOConnection;
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

function TADOEngine.Connect(const Login: IDatabaseLogin): Boolean;
begin
  _Connection.ConnectionString := Login.ConnectionString;
  _Connection.Connected := True;
  Result := _Connection.Connected;
end;

function TADOEngine.Disconnect: Boolean;
begin
  _Connection.Connected := False;
  Result := _Connection.Connected;
end;

function TADOEngine.IsConnected: Boolean;
begin
  Result := _Connection.Connected;
end;

function TADOEngine.OpenDataset(const Script: String): TDataset;
var
  Dataset: TADODataSet;
begin
  Dataset := TADODataSet.Create(_Connection);
  Dataset.Connection := _Connection;
  Dataset.CommandText := Script;
  Result := Dataset;
  Dataset.Open;
end;

function TADOEngine.Execute(const Script: String): Boolean;
var
  Command: TADOCommand;
begin
  _Connection.BeginTrans;
  try
    Command := TADOCommand.Create(_Connection);
    try
      Command.Connection := _Connection;
      Command.CommandText := Script;
      Command.CommandType := TCommandType.cmdText;
      Command.Execute;
      _Connection.CommitTrans;
      Result := True;
    finally
      Command.Free;
    end;
  except
    on E: Exception do
    begin
      _Connection.RollbackTrans;
      raise;
    end;
  end;
end;

function TADOEngine.ExecuteReturning(const Script: String): TDataset;
begin
  Result := nil;
end;

constructor TADOEngine.Create;
begin
  CoInitialize(nil);
  _Connection := TADOConnection.Create(nil);
  _Connection.LoginPrompt := False;
end;

destructor TADOEngine.Destroy;
begin
  Disconnect;
  _Connection.Free;
  CoUninitialize;
  inherited;
end;

class function TADOEngine.New: IDatabaseEngine;
begin
  Result := TADOEngine.Create;
end;

end.
