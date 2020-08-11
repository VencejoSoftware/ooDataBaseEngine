{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Credential object with encryption capabilities
  @created(15/04/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit CryptedCredential;

interface

uses
  SysUtils,
  Cipher, KeyCipher,
  Credential;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the connection encrypted credential settings)
  @member(
    RevealPassword Reveal password without encryption
    @param(RevealKey Key to uncrypt password)
    @return(Text with uncrypted password)
  )
}
{$ENDREGION}
  ICryptedCredential = interface(ICredential)
    ['{B39EF3ED-90CE-4CB9-B617-52BE607CBCC1}']
    function RevealPassword(const RevealKey: WideString): WideString;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(ICryptedCredential))
  @member(User @seealso(ICredential.User))
  @member(Password @seealso(ICredential.Password))
  @member(IsValidPassword @seealso(ICredential.IsValidPassword))
  @member(RevealPassword @seealso(ICryptedCredential.RevealPassword))
  @member(
    Create Object constructor
    @param(User name to connect)
    @param(Password User Password to connect)
    @param(Cipher @link(ICipher Cipher object))
    @param(IsEncoded If @true then not encrypt password, else execute encryption over password)
  )
  @member(
    New Creates a new @classname as interface
    @param(User name to connect)
    @param(Password User Password to connect)
    @param(Cipher @link(ICipher Cipher object))
    @param(IsEncoded If @true then not encrypt password, else execute encryption over password)  )
}
{$ENDREGION}

  TCryptedCredential = class sealed(TInterfacedObject, ICryptedCredential)
  strict private
    _Cipher: IKeyCipher;
    _User, _Password: WideString;
  public
    function User: WideString;
    function Password: WideString;
    function RevealPassword(const RevealKey: WideString): WideString;
    function IsValidPassword(const Password: WideString): Boolean;
    constructor Create(const User, Password: WideString; const Cipher: IKeyCipher; const IsEncoded: Boolean);
    class function New(const User, Password: WideString; const Cipher: IKeyCipher; const IsEncoded: Boolean = False)
      : ICryptedCredential;
  end;

implementation

function TCryptedCredential.User: WideString;
begin
  Result := _User;
end;

function TCryptedCredential.Password: WideString;
begin
  Result := _Password;
end;

function TCryptedCredential.RevealPassword(const RevealKey: WideString): WideString;
begin
  if _Cipher.IsValidKey(RevealKey) then
    Result := _Cipher.Decode(_Password)
  else
    raise ECipher.Create('Invalid Reveal Key');
end;

function TCryptedCredential.IsValidPassword(const Password: WideString): Boolean;
begin
  Result := _Cipher.Encode(Password) = _Password;
end;

constructor TCryptedCredential.Create(const User, Password: WideString; const Cipher: IKeyCipher;
  const IsEncoded: Boolean);
begin
  _Cipher := Cipher;
  _User := User;
  if IsEncoded then
    _Password := Password
  else
    _Password := _Cipher.Encode(Password);
end;

class function TCryptedCredential.New(const User, Password: WideString; const Cipher: IKeyCipher;
  const IsEncoded: Boolean): ICryptedCredential;
begin
  Result := TCryptedCredential.Create(User, Password, Cipher, IsEncoded);
end;

end.
