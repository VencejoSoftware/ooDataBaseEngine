{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define an succeded execution result
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit SuccededExecution;

interface

uses
  ExecutionResult;

type
{$REGION 'documentation'}
{
  @abstract(Object to define an succeded execution result)
  @member(
    AffectedRows Amount of affected rows with the execution
    @return(Integer with affected rows)
  )
}
{$ENDREGION}
  ISuccededExecution = interface(IExecutionResult)
    ['{8331F82D-E9A5-42FC-8062-0B996AD306A2}']
    function AffectedRows: NativeUInt;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IFailedExecution))
  @member(Statement @seealso(IExecutionResult.Statement))
  @member(Failed @seealso(IExecutionResult.Failed))
  @member(AffectedRows @seealso(ISuccededExecution.AffectedRows))
  @member(
    Create Object constructor
    @param(Statement Statement text)
    @param(AffectedRows Amount of affected rows)
  )
  @member(
    New Create a new @classname as interface
    @param(Statement Statement text)
    @param(AffectedRows Amount of affected rows)
  )
}
{$ENDREGION}

  TSuccededExecution = class sealed(TInterfacedObject, ISuccededExecution)
  strict private
    _Statement: WideString;
    _AffectedRows: NativeUInt;
  public
    function Statement: WideString;
    function Failed: Boolean;
    function AffectedRows: NativeUInt;
    constructor Create(const Statement: WideString; const AffectedRows: NativeUInt);
    class function New(const Statement: WideString; const AffectedRows: NativeUInt): ISuccededExecution;
  end;

implementation

function TSuccededExecution.Statement: WideString;
begin
  Result := _Statement;
end;

function TSuccededExecution.Failed: Boolean;
begin
  Result := False;
end;

function TSuccededExecution.AffectedRows: NativeUInt;
begin
  Result := _AffectedRows;
end;

constructor TSuccededExecution.Create(const Statement: WideString; const AffectedRows: NativeUInt);
begin
  _Statement := Statement;
  _AffectedRows := AffectedRows;
end;

class function TSuccededExecution.New(const Statement: WideString; const AffectedRows: NativeUInt): ISuccededExecution;
begin
  Result := TSuccededExecution.Create(Statement, AffectedRows);
end;

end.
