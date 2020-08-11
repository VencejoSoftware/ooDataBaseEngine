{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define an succeded execution result wich return a dataset
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit DatasetExecution;

interface

uses
  DB,
  Statement,
  ExecutionResult;

type
{$REGION 'documentation'}
{
  @abstract(Object to define an succeded execution result wich return a dataset)
  @member(
    Dataset Object with data struct of the execution
    @return(TDataset with rows)
  )
}
{$ENDREGION}
  IDatasetExecution = interface(IExecutionResult)
    ['{0A35A650-34E6-4E0E-A9E4-5EA5858DF3E2}']
    function Dataset: TDataSet;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IExecutionResult))
  @member(Statement @seealso(IExecutionResult.Statement))
  @member(Failed @seealso(IExecutionResult.Failed))
  @member(Dataset @seealso(IExecutionResult.Dataset))
  @member(
    Create Object constructor
    @param(Statement Statement text)
    @param(Dataset Data struct object)
  )
  @member(
    New Create a new @classname as interface
    @param(Statement Statement text)
    @param(Dataset Data struct object)
  )
}
{$ENDREGION}

  TDatasetExecution = class sealed(TInterfacedObject, IDatasetExecution)
  strict private
    _Statement: IStatement;
    _Dataset: TDataSet;
  public
    function Statement: IStatement;
    function Failed: Boolean;
    function Dataset: TDataSet;
    constructor Create(const Statement: IStatement; const Dataset: TDataSet);
    destructor Destroy; override;
    class function New(const Statement: IStatement; const Dataset: TDataSet): IDatasetExecution;
  end;

implementation

function TDatasetExecution.Statement: IStatement;
begin
  Result := _Statement;
end;

function TDatasetExecution.Failed: Boolean;
begin
  Result := False;
end;

function TDatasetExecution.Dataset: TDataSet;
begin
  Result := _Dataset;
end;

constructor TDatasetExecution.Create(const Statement: IStatement; const Dataset: TDataSet);
begin
  _Statement := Statement;
  _Dataset := Dataset;
end;

destructor TDatasetExecution.Destroy;
begin
  if Assigned(_Dataset) then
  begin
    if _Dataset.Active then
      _Dataset.Close;
    _Dataset.Free;
  end;
  inherited;
end;

class function TDatasetExecution.New(const Statement: IStatement; const Dataset: TDataSet): IDatasetExecution;
begin
  Result := TDatasetExecution.Create(Statement, Dataset);
end;

end.
