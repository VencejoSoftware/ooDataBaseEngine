{$REGION 'documentation'}
{
  Copyright (c) 2021, Vencejo Software
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
  SysUtils,
  ConnectionSetting,
  ExecutionResult,
  Statement;

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
  @abstract(Class for database engine exceptions)
}
{$ENDREGION}
  EDatabaseEngine = class(Exception)
  end;

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
    @param(Login @link(IConnectionSetting Connection Setting object))
    @param(PasswordKey Key to reveal encrypted password)
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
    Execute Run a statement to alter data or database struct
    @param(Statement @link(IStatement Query to execute))
    @param(UseGlobalTransaction Defines is the execution run into the global transaction or create an isolate one)
    @return(link(@IExecutionResult Execution result object))
  )
  @member(
    ExecuteReturning Run a statement to alter or read data and wait for returned data
    @param(Statement @link(IStatement Query to execute))
    @param(CommitData Defines if the execution uses a transaction to data commit)
    @param(UseGlobalTransaction Defines is the execution run into the global transaction or create an isolate one)
    @return(link(@IExecutionResult Execution result object))
  )
  @member(
    ExecuteScript Execute a script directly to the database
    @param(StatementList @link(IStatementList Query list to execute))
    @param(SkipErrors If @true then ignore execution exceptions)
    @return(link(@IExecutionResultList Execution result list object))
  )
}
{$ENDREGION}

  IDatabaseEngine = interface
    ['{911CC81E-2051-4531-B758-6BDB7E04F55E}']
    function InTransaction: Boolean;
    function BeginTransaction: Boolean;
    function CommitTransaction: Boolean;
    function RollbackTransaction: Boolean;
    function Connect(const Setting: IConnectionSetting; const PasswordKey: WideString = ''): Boolean;
    function Disconnect: Boolean;
    function IsConnected: Boolean;
    function Execute(const Statement: IStatement; const UseGlobalTransaction: Boolean = False): IExecutionResult;
    function ExecuteReturning(const Statement: IStatement; const CommitData: Boolean = False;
      const UseGlobalTransaction: Boolean = False): IExecutionResult;
    function ExecuteScript(const StatementList: IStatementList; const SkipErrors: Boolean = False)
      : IExecutionResultList;
  end;

implementation

end.
