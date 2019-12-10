{$REGION 'documentation'}
{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define an failed execution result
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FailedExecution;

interface

uses
  ExecutionResult;

type
{$REGION 'documentation'}
{
  @abstract(Object to define an failed execution result)
  @member(
    ErrorCode Returns the error code
    @return(Integer with error code)
  )
  @member(
    Message Fail message description
    @return(Text message)
  )
}
{$ENDREGION}
  IFailedExecution = interface(IExecutionResult)
    ['{4270D9CD-06DE-4E08-9448-7AE82E111CB0}']
    function ErrorCode: NativeInt;
    function Message: WideString;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IFailedExecution))
  @member(Statement @seealso(IExecutionResult.Statement))
  @member(Failed @seealso(IExecutionResult.Failed))
  @member(ErrorCode @seealso(IFailedExecution.ErrorCode))
  @member(Message @seealso(IFailedExecution.Message))
  @member(
    Create Object constructor
    @param(Statement Statement text)
    @param(ErrorCode Fail error code)
    @param(Message Fail text description)
  )
  @member(
    New Create a new @classname as interface
    @param(Statement Statement text)
    @param(ErrorCode Fail error code)
    @param(Message Fail text description)
  )
}
{$ENDREGION}

  TFailedExecution = class sealed(TInterfacedObject, IFailedExecution)
  strict private
    _Statement: WideString;
    _ErrorCode: NativeInt;
    _Message: WideString;
  public
    function Statement: WideString;
    function Failed: Boolean;
    function ErrorCode: NativeInt;
    function Message: WideString;
    constructor Create(const Statement: WideString; const ErrorCode: NativeInt; const Message: WideString);
    class function New(const Statement: WideString; const ErrorCode: NativeInt; const Message: WideString)
      : IFailedExecution;
  end;

implementation

function TFailedExecution.Statement: WideString;
begin
  Result := _Statement;
end;

function TFailedExecution.Failed: Boolean;
begin
  Result := True;
end;

function TFailedExecution.ErrorCode: NativeInt;
begin
  Result := _ErrorCode;
end;

function TFailedExecution.Message: WideString;
begin
  Result := _Message;
end;

constructor TFailedExecution.Create(const Statement: WideString; const ErrorCode: NativeInt; const Message: WideString);
begin
  _Statement := Statement;
  _ErrorCode := ErrorCode;
  _Message := Message;
end;

class function TFailedExecution.New(const Statement: WideString; const ErrorCode: NativeInt; const Message: WideString)
  : IFailedExecution;
begin
  Result := TFailedExecution.Create(Statement, ErrorCode, Message);
end;

end.
