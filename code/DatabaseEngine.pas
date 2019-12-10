{$REGION 'documentation'}
{
  Copyright (c) 2019, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database engine object
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit DatabaseEngine;

interface

uses
  DatabaseLogin,
  ExecutionResult;

const
{$REGION 'documentation'}
{
  @abstract(NULL text value for SQL)
}
{$ENDREGION}
  NULL = 'NULL';

type
{$REGION 'documentation'}
{
  @abstract(Database engine object)
  Object to encapsulate basic methods to acces, alter and get data from SQL based databases
  @member(
    InTransaction Checks for an active global transaction
    @return(@true if exists an active global transaction, @false if not)
  )
  @member(
    BeginTransaction Start the global transaction
    @return(@true if can start a new transaction, @false if fail)
  )
  @member(
    CommitTransaction Commits all chnages of the global transaction
    @return(@true if committing data is done, @false if fail)
  )
  @member(
    RollbackTransaction Rollback all chnages of the global transaction
    @return(@true if rollbacking data is done, @false if fail)
  )
  @member(
    Connect Try to login into database
    @param(Login @link(ILogin Login object))
    @return(@true if connection is done, @false if fail)
  )
  @member(
    Disconnect Try to disconnect from the database
    @return(@true if disconnection is done, @false if fail)
  )
  @member(
    IsConnected Checks if is currently connected to database
    @return(@true if is connected, @false if not)
  )
  @member(
    OpenDataset Open and return a new dataset based in a query
    @param(Statement Statement query to run)
    @return(link(@IExecutionResult Execution result object))
  )
  @member(
    Execute Run a statement to alter data or database struct
    @param(Statement Statement query to run)
    @param(UseGlobalTransaction Defines is the execution run into the global transaction or create an isolate one)
    @return(link(@IExecutionResult Execution result object))
  )
  @member(
    ExecuteReturning Run a statement to alter data or database struct and wait for data returning
    @param(Statement Statement query to run)
    @param(UseGlobalTransaction Defines is the execution run into the global transaction or create an isolate one)
    @return(link(@IExecutionResult Execution result object))
  )
}
{$ENDREGION}
  IDatabaseEngine = interface
    ['{911CC81E-2051-4531-B758-6BDB7E04F55E}']
    function InTransaction: Boolean;
    function BeginTransaction: Boolean;
    function CommitTransaction: Boolean;
    function RollbackTransaction: Boolean;
    function Connect(const Login: IDatabaseLogin): Boolean;
    function Disconnect: Boolean;
    function IsConnected: Boolean;
    function OpenDataset(const Statement: WideString): IExecutionResult;
    function Execute(const Statement: WideString; const UseGlobalTransaction: Boolean = False): IExecutionResult;
    function ExecuteReturning(const Statement: WideString; const UseGlobalTransaction: Boolean = False)
      : IExecutionResult;
  end;

implementation

end.
