{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Database login object
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit DatabaseLogin;

interface

uses
  SysUtils,
  ConnectionParam;

type
{$REGION 'documentation'}
{
  @abstract(Connection login object)
  Connection parameter object
  @member(User Login user)
  @member(Password User login password)
  @member(Parameters @link(IConnectionParamList List of parameters))
}
{$ENDREGION}
  IDatabaseLogin = interface
    ['{0A572E27-28FC-49F6-A979-9F82EB3BEA11}']
    function User: WideString;
    function Password: WideString;
    function Parameters: IConnectionParamList;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IDatabaseLogin))
  @member(User @seealso(IDatabaseLogin.User))
  @member(Password @seealso(IDatabaseLogin.Password))
  @member(Parameters @seealso(IDatabaseLogin.Parameters))
  @member(
    Create Object constructor
    @param(User Login user)
    @param(Password User login password)
  )
  @member(
    New Create a new @classname as interface
    @param(User Login user)
    @param(Password User login password)
  )
}
{$ENDREGION}

  TDatabaseLogin = class sealed(TInterfacedObject, IDatabaseLogin)
  strict private
    _User, _Password: WideString;
    _Parameters: IConnectionParamList;
  public
    function User: WideString;
    function Password: WideString;
    function Parameters: IConnectionParamList;
    constructor Create(const User, Password: WideString);
    class function New(const User, Password: WideString): IDatabaseLogin;
  end;

implementation

function TDatabaseLogin.User: WideString;
begin
  Result := _User;
end;

function TDatabaseLogin.Password: WideString;
begin
  Result := _Password;
end;

function TDatabaseLogin.Parameters: IConnectionParamList;
begin
  Result := _Parameters;
end;

constructor TDatabaseLogin.Create(const User, Password: WideString);
begin
  _User := User;
  _Password := Password;
  _Parameters := TConnectionParamList.New;
end;

class function TDatabaseLogin.New(const User, Password: WideString): IDatabaseLogin;
begin
  Result := TDatabaseLogin.Create(User, Password);
end;

end.
