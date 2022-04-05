{$REGION 'documentation'}
{
  Copyright (c) 2021, Vencejo Software
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
  SysUtils,
  Statement,
  ExecutionResult;

type
{$REGION 'documentation'}
{
  @abstract(Object to define an execution exception)
  @member(
    ErrorCode Returns the error code
    @return(Integer with error code)
  )
  @member(
    ErrorText Fail message description
    @return(Text message)
  )
  @member(
    Statement Statement executed
    @return(Text statement)
  )
}
{$ENDREGION}
  EDatabaseFailed = class sealed(Exception)
  strict private
    _Statement: WideString;
    _ErrorCode: NativeInt;
    _ErrorText: WideString;
  public
    function ErrorCode: NativeInt;
    function ErrorText: WideString;
    function Statement: WideString;
    constructor Create(const ErrorCode: NativeInt; const ErrorText, Statement: WideString);
  end;

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
    function ToException: EDatabaseFailed;
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
    _Statement: IStatement;
    _ErrorCode: NativeInt;
    _Message: WideString;
  public
    function Statement: IStatement;
    function Failed: Boolean;
    function ErrorCode: NativeInt;
    function Message: WideString;
    function ToException: EDatabaseFailed;
    constructor Create(const Statement: IStatement; const ErrorCode: NativeInt; const Message: WideString);
    class function New(const Statement: IStatement; const ErrorCode: NativeInt; const Message: WideString)
      : IFailedExecution;
  end;

implementation

function TFailedExecution.Statement: IStatement;
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

function TFailedExecution.ToException: EDatabaseFailed;
begin
  Result := EDatabaseFailed.Create(_ErrorCode, Trim(_Message), Trim(_Statement.Syntax));
end;

constructor TFailedExecution.Create(const Statement: IStatement; const ErrorCode: NativeInt; const Message: WideString);
begin
  _Statement := Statement;
  _ErrorCode := ErrorCode;
  _Message := Message;
end;

class function TFailedExecution.New(const Statement: IStatement; const ErrorCode: NativeInt; const Message: WideString)
  : IFailedExecution;
begin
  Result := TFailedExecution.Create(Statement, ErrorCode, Message);
end;

{ EDatabaseFailed }

function EDatabaseFailed.ErrorCode: NativeInt;
begin
  Result := _ErrorCode;
end;

function EDatabaseFailed.ErrorText: WideString;
begin
  Result := _ErrorText;
end;

function EDatabaseFailed.Statement: WideString;
begin
  Result := _Statement;
end;

constructor EDatabaseFailed.Create(const ErrorCode: NativeInt; const ErrorText, Statement: WideString);
begin
  inherited Create(Format('%d|"%s"|Executed="%s"', [ErrorCode, ErrorText, Statement]));
  _ErrorCode := ErrorCode;
  _ErrorText := ErrorText;
  _Statement := Statement;
end;

end.
