{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define the user connection credential settings
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit Credential;

interface

uses
  SysUtils;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the connection credential settings)
  @member(
    User User name to connect
    @return(Text with user)
  )
  @member(
    Password User Password to connect
    @return(Text with Password)
  )
  @member(
    IsValidPassword Checks for a valid passwrod
    @return(@true if password is valid, @false if not)
  )
}
{$ENDREGION}
  ICredential = interface
    ['{804D432F-6705-4873-829F-442020249784}']
    function User: WideString;
    function Password: WideString;
    function IsValidPassword(const Password: WideString): Boolean;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(ICredential))
  @member(User @seealso(ICredential.User))
  @member(Password @seealso(ICredential.Password))
  @member(IsValidPassword @seealso(ICredential.IsValidPassword))
  @member(
    Create Object constructor
    @param(User name to connect)
    @param(Password User Password to connect)
  )
  @member(
    New Creates a new @classname as interface
    @param(User name to connect)
    @param(Password User Password to connect)
  )
  @member(
    NewEmpty Creates a new @classname as interface with empty values
  )
}
{$ENDREGION}

  TCredential = class sealed(TInterfacedObject, ICredential)
  strict private
    _User, _Password: WideString;
  public
    function User: WideString;
    function Password: WideString;
    function IsValidPassword(const Password: WideString): Boolean;
    constructor Create(const User, Password: WideString);
    class function New(const User, Password: WideString): ICredential;
    class function NewEmpty: ICredential;
  end;

implementation

function TCredential.User: WideString;
begin
  Result := _User;
end;

function TCredential.Password: WideString;
begin
  Result := _Password;
end;

constructor TCredential.Create(const User, Password: WideString);
begin
  _User := User;
  _Password := Password;
end;

function TCredential.IsValidPassword(const Password: WideString): Boolean;
begin
  Result := _Password = Password;
end;

class function TCredential.New(const User, Password: WideString): ICredential;
begin
  Result := TCredential.Create(User, Password);
end;

class function TCredential.NewEmpty: ICredential;
begin
  Result := TCredential.Create(EmptyWideStr, EmptyWideStr);
end;

end.
