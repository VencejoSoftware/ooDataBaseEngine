{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define an execution result
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit ExecutionResult;

interface

uses
  IterableList;

type
{$REGION 'documentation'}
{
  @abstract(Object to define an execution result)
  @member(
    Statement Return the executed statement
    @return(Statement text)
  )
  @member(
    Failed Defines if the execution runned ok
    @return(@true If execution success, @false if not)
  )
}
{$ENDREGION}
  IExecutionResult = interface
    ['{5608735A-89BC-4343-8147-30B031D3449D}']
    function Statement: WideString;
    function Failed: Boolean;
  end;

{$REGION 'documentation'}
{
  @abstract(Object to define an execution result list)
  @member(
    Failed Defines if the execution of all items runned ok
    @return(@true If all executions success, @false if not)
  )
}
{$ENDREGION}

  IExecutionResultList = interface(IIterableList<IExecutionResult>)
    ['{8071BF8D-D7E8-4144-98B0-260A97A78C0D}']
    function Failed: Boolean;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IExecutionResultList))
  @member(Failed @seealso(IExecutionResultList.Failed))
  @member(
    New Create a new @classname as interface
  )
}
{$ENDREGION}

  TExecutionResultList = class sealed(TIterableList<IExecutionResult>, IExecutionResultList)
  public
    function Failed: Boolean;
    class function New: IExecutionResultList;
  end;

implementation

function TExecutionResultList.Failed: Boolean;
var
  Item: IExecutionResult;
begin
  Result := False;
  for Item in Self do
    if Item.Failed then
      Exit(True);
end;

class function TExecutionResultList.New: IExecutionResultList;
begin
  Result := TExecutionResultList.Create;
end;

end.
