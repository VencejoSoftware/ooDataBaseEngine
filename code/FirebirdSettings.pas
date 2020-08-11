{$REGION 'documentation'}
{
  Copyright (c) 2020, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Object to define the Firebird connection settings
  @created(22/12/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit FirebirdSettings;

interface

uses
  SysUtils,
  Credential,
  Server,
  ConnectionSettings,
  FirebirdTransactionSettings;

type
{$REGION 'documentation'}
{
  @abstract(Object to define the settings for a Firebird connection)
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
    TransactionSettings Default transaction settings
    @return(@link(IFirebirdTransactionSettings Transaction options))
  )
}
{$ENDREGION}
  IFirebirdSettings = interface(IConnectionSettings)
    ['{C42828F4-1EBB-49AB-84D9-9DBB2C5570B7}']
    function Collation: WideString;
    function Dialect: Byte;
    function Version: WideString;
    function TransactionSettings: IFirebirdTransactionSettings;
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IFirebirdSettings))
  @member(Credential @seealso(IConnectionSettings.Credential))
  @member(StorageName @seealso(IConnectionSettings.StorageName))
  @member(LibraryPath @seealso(IConnectionSettings.LibraryPath))
  @member(Server @seealso(IConnectionSettings.Server))
  @member(Collation @seealso(IFirebirdSettings.Collation))
  @member(Dialect @seealso(IFirebirdSettings.Dialect))
  @member(Version @seealso(IFirebirdSettings.Version))
  @member(TransactionSettings @seealso(IFirebirdSettings.TransactionSettings))
  @member(
    Create Object constructor
    @param(Settings @link(IConnectionSettings Object with base connection settings))
    @param(Collation Text with collation charset)
    @param(Dialect Kind of syntax dialect)
    @param(Version Driver version of database)
  )
  @member(
    New Create a new @classname as interface
    @param(Settings @link(IConnectionSettings Object with base connection settings))
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

  TFirebirdSettings = class sealed(TInterfacedObject, IFirebirdSettings)
  strict private
    _ConnectionSettings: IConnectionSettings;
    _Collation, _Version: WideString;
    _Dialect: Byte;
    _TransactionSettings: IFirebirdTransactionSettings;
  public
    function Credential: ICredential;
    function StorageName: WideString;
    function LibraryPath: WideString;
    function Server: IServer;
    function Collation: WideString;
    function Dialect: Byte;
    function Version: WideString;
    function TransactionSettings: IFirebirdTransactionSettings;
    constructor Create(const ConnectionSettings: IConnectionSettings; const Collation, Version: WideString;
      const Dialect: Byte; const TransactionSettings: IFirebirdTransactionSettings);
    class function New(const ConnectionSettings: IConnectionSettings; const Collation: WideString;
      const Version: WideString; const Dialect: Byte; const TransactionSettings: IFirebirdTransactionSettings)
      : IFirebirdSettings;
    class function NewEmbedded(const DatabasePath, LibraryPath: WideString; const Collation: WideString = 'ISO8859_1';
      const Version: WideString = 'firebird-2.5'; const Dialect: Byte = 3;
      const TransactionSettings: IFirebirdTransactionSettings = nil): IFirebirdSettings;
  end;

implementation

function TFirebirdSettings.Credential: ICredential;
begin
  Result := _ConnectionSettings.Credential;
end;

function TFirebirdSettings.StorageName: WideString;
begin
  Result := _ConnectionSettings.StorageName;
end;

function TFirebirdSettings.LibraryPath: WideString;
begin
  Result := _ConnectionSettings.LibraryPath;
end;

function TFirebirdSettings.Server: IServer;
begin
  Result := _ConnectionSettings.Server;
end;

function TFirebirdSettings.Collation: WideString;
begin
  Result := _Collation;
end;

function TFirebirdSettings.Dialect: Byte;
begin
  Result := _Dialect;
end;

function TFirebirdSettings.Version: WideString;
begin
  Result := _Version;
end;

function TFirebirdSettings.TransactionSettings: IFirebirdTransactionSettings;
begin
  Result := _TransactionSettings;
end;

constructor TFirebirdSettings.Create(const ConnectionSettings: IConnectionSettings;
  const Collation, Version: WideString; const Dialect: Byte; const TransactionSettings: IFirebirdTransactionSettings);
begin
  _ConnectionSettings := ConnectionSettings;
  _Collation := Collation;
  _Version := Version;
  _Dialect := Dialect;
  _TransactionSettings := TransactionSettings;
end;

class function TFirebirdSettings.New(const ConnectionSettings: IConnectionSettings;
  const Collation, Version: WideString; const Dialect: Byte; const TransactionSettings: IFirebirdTransactionSettings)
  : IFirebirdSettings;
begin
  Result := TFirebirdSettings.Create(ConnectionSettings, Collation, Version, Dialect, TransactionSettings);
end;

class function TFirebirdSettings.NewEmbedded(const DatabasePath, LibraryPath, Collation, Version: WideString;
  const Dialect: Byte; const TransactionSettings: IFirebirdTransactionSettings): IFirebirdSettings;
begin
  Result := TFirebirdSettings.Create(TConnectionSettings.New(TCredential.New('sysdba', 'masterkey'),
    ExpandFileName(DatabasePath), LibraryPath, nil), Collation, Version, Dialect, TransactionSettings);
end;

end.
