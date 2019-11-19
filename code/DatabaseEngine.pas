unit DatabaseEngine;

interface

uses
  DB,
  DatabaseLogin;

const
  NULL = 'NULL';

type
  IDatabaseEngine = interface
    ['{911CC81E-2051-4531-B758-6BDB7E04F55E}']
    function Connect(const Login: IDatabaseLogin): Boolean;
    function Disconnect: Boolean;
    function IsConnected: Boolean;
    function OpenDataset(const Script: String): TDataset;
    function Execute(const Script: String): Boolean;
    function ExecuteReturning(const Script: String): TDataset;
  end;

implementation

end.
