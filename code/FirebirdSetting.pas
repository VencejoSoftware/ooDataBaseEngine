{$REGION 'documentation'}
{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define the Firebird connection settings
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FirebirdSetting;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSetting,
  FirebirdTransactionSetting;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the Setting for a Firebird connection)
  @member(
    Collation Connection collation charset
    @return(Text with collation charset)
  )
  @member(
    Dialect Syntax dialect
    @return(Kind of syntax dialect)
  )
  @member(
    Version Driver version of database
    @return(Text with driver version of database)
  )
  @member(
    TransactionSetting Default transaction Setting
    @return(@link(IFirebirdTransactionSetting Transaction options))
  )
}
{$ENDREGION}
  IFirebirdSetting = interface(IConnectionSetting)
    ['{C42828F4-1EBB-49AB-84D9-9DBB2C5570B7}']
    function Collation: WideString;
    function Dialect: Byte;
    function Version: WideString;
    function TransactionSetting: IFirebirdTransactionSetting;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IFirebirdSetting))
  @member(Credential @seealso(IConnectionSetting.Credential))
  @member(StorageName @seealso(IConnectionSetting.StorageName))
  @member(LibraryPath @seealso(IConnectionSetting.LibraryPath))
  @member(Server @seealso(IConnectionSetting.Server))
  @member(Collation @seealso(IFirebirdSetting.Collation))
  @member(Dialect @seealso(IFirebirdSetting.Dialect))
  @member(Version @seealso(IFirebirdSetting.Version))
  @member(TransactionSetting @seealso(IFirebirdSetting.TransactionSetting))
  @member(
    Create Object constructor
    @param(Setting @link(IConnectionSetting Object with base connection Setting))
    @param(Collation Text with collation charset)
    @param(Dialect Kind of syntax dialect)
    @param(Version Driver version of database)
  )
  @member(
    New Create a new @classname as interface
    @param(Setting @link(IConnectionSetting Object with base connection Setting))
    @param(Collation Text with collation charset)
    @param(Dialect Kind of syntax dialect)
    @param(Version Driver version of database)
  )
  @member(
    NewEmbedded Create a new @classname as interface using embedded firebird database
    @param(DatabasePath Database file path)
    @param(LibraryPath Firebird client library path)
    @param(Collation Text with collation charset)
    @param(Dialect Kind of syntax dialect)
    @param(Version Driver version of database)
  )
}
{$ENDREGION}

  TFirebirdSetting = class sealed(TInterfacedObject, IFirebirdSetting)
  strict private
    _ConnectionSetting: IConnectionSetting;
    _Collation, _Version: WideString;
    _Dialect: Byte;
    _TransactionSetting: IFirebirdTransactionSetting;
  public
    function Credential: ICredential;
    function StorageName: WideString;
    function LibraryPath: WideString;
    function Server: IServer;
    function Collation: WideString;
    function Dialect: Byte;
    function Version: WideString;
    function TransactionSetting: IFirebirdTransactionSetting;
    constructor Create(const ConnectionSetting: IConnectionSetting; const Collation, Version: WideString;
      const Dialect: Byte; const TransactionSetting: IFirebirdTransactionSetting);
    class function New(const ConnectionSetting: IConnectionSetting; const Collation: WideString;
      const Version: WideString; const Dialect: Byte; const TransactionSetting: IFirebirdTransactionSetting)
      : IFirebirdSetting;
    class function NewEmbedded(const DatabasePath, LibraryPath: WideString; const Collation: WideString = 'ISO8859_1';
      const Version: WideString = 'firebird-2.5'; const Dialect: Byte = 3;
      const TransactionSetting: IFirebirdTransactionSetting = nil): IFirebirdSetting;
  end;

implementation

function TFirebirdSetting.Credential: ICredential;
begin
  Result := _ConnectionSetting.Credential;
end;

function TFirebirdSetting.StorageName: WideString;
begin
  Result := _ConnectionSetting.StorageName;
end;

function TFirebirdSetting.LibraryPath: WideString;
begin
  Result := _ConnectionSetting.LibraryPath;
end;

function TFirebirdSetting.Server: IServer;
begin
  Result := _ConnectionSetting.Server;
end;

function TFirebirdSetting.Collation: WideString;
begin
  Result := _Collation;
end;

function TFirebirdSetting.Dialect: Byte;
begin
  Result := _Dialect;
end;

function TFirebirdSetting.Version: WideString;
begin
  Result := _Version;
end;

function TFirebirdSetting.TransactionSetting: IFirebirdTransactionSetting;
begin
  Result := _TransactionSetting;
end;

constructor TFirebirdSetting.Create(const ConnectionSetting: IConnectionSetting; const Collation, Version: WideString;
  const Dialect: Byte; const TransactionSetting: IFirebirdTransactionSetting);
begin
  _ConnectionSetting := ConnectionSetting;
  _Collation := Collation;
  _Version := Version;
  _Dialect := Dialect;
  _TransactionSetting := TransactionSetting;
end;

class function TFirebirdSetting.New(const ConnectionSetting: IConnectionSetting; const Collation, Version: WideString;
  const Dialect: Byte; const TransactionSetting: IFirebirdTransactionSetting): IFirebirdSetting;
begin
  Result := TFirebirdSetting.Create(ConnectionSetting, Collation, Version, Dialect, TransactionSetting);
end;

class function TFirebirdSetting.NewEmbedded(const DatabasePath, LibraryPath, Collation, Version: WideString;
  const Dialect: Byte; const TransactionSetting: IFirebirdTransactionSetting): IFirebirdSetting;
begin
  Result := TFirebirdSetting.Create(TConnectionSetting.New(TCredential.New('sysdba', 'masterkey'),
    ExpandFileName(DatabasePath), LibraryPath, nil), Collation, Version, Dialect, TransactionSetting);
end;

end.
