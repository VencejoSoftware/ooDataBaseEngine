unit DataBaseScript;

interface

type
  TDataBaseScripttKind = (DDL, DML);

  IDataBaseScript = interface
    ['{347C598A-55E1-4798-8DD2-08A2E1DD92E8}']
    function Kind: TDataBaseScripttKind;
    function Code: String;
  end;

implementation

end.
