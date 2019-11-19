unit DBConnection;

interface

uses
  DB;

type
  IDBConnection = interface
    ['{4C474C4C-F641-414C-9B8E-E1F0D6E2039D}']
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
  end;

implementation

end.
