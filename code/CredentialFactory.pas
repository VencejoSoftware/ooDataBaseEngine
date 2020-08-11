{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object factory to build Credential objects
  @created(15/04/2020)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit CredentialFactory;

interface

uses
  DataStorage,
  Credential, CryptedCredential,
  KeyCipher;

type
{$REGION 'documentation'}
{
  @abstract(Object factory to build @link(ICredential Credential objects))
  @member(
    Build Construct a new @link(ICredential Credential object)
    @param(ObjectName Object name identifier)
    @param(DataStorage @link(IDataStorage DataStorage object to access external data))
    @return(@link(ICredential Credential object))
  )
}
{$ENDREGION}
  ICredentialFactory = interface
    ['{F4E653B3-4FCB-428E-9D2B-7D31C231B02C}']
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): ICredential;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(ICredentialFactory))
  @member(Build @seealso(ICredentialFactory.Build))
  @member(
    Create Object constructor
    @param(Cipher Encoder/decoder for sensible data. If assigned to nil then skip cryptographic)
  )
  @member(
    New Create a new @classname as interface
    @param(Cipher Encoder/decoder for sensible data. If assigned to nil then skip cryptographic)
  )
}
{$ENDREGION}

  TCredentialFactory = class sealed(TInterfacedObject, ICredentialFactory)
  strict private
    _Cipher: IKeyCipher;
  public
    function Build(const ObjectName: WideString; const DataStorage: IDataStorage): ICredential;
    constructor Create(const Cipher: IKeyCipher);
    class function New(const Cipher: IKeyCipher): ICredentialFactory;
  end;

implementation

function TCredentialFactory.Build(const ObjectName: WideString; const DataStorage: IDataStorage): ICredential;
var
  User, Password: WideString;
begin
  User := DataStorage.ReadString(ObjectName, 'credential.user');
  Password := DataStorage.ReadString(ObjectName, 'credential.password');
  if (Length(User) > 0) or (Length(Password) > 0) then
    if Assigned(_Cipher) then
      Result := TCryptedCredential.New(User, Password, _Cipher, True)
    else
      Result := TCredential.New(User, Password)
  else
    Result := nil;
end;

constructor TCredentialFactory.Create(const Cipher: IKeyCipher);
begin
  _Cipher := Cipher;
end;

class function TCredentialFactory.New(const Cipher: IKeyCipher): ICredentialFactory;
begin
  Result := TCredentialFactory.Create(Cipher);
end;

end.
