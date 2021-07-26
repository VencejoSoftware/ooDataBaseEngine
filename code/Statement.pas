{$REGION 'documentation'}
{
  Copyright (c) 2021, Vencejo Software
  Distributed under the terms of the Modified BSD License
  The full license is distributed with this software
}
{
  Execution statement object
  @created(18/09/2018)
  @author Vencejo Software <www.vencejosoft.com>
}
{$ENDREGION}
unit Statement;

interface

uses
  SysUtils, StrUtils, Types,
  DB,
  IterableList;

type
{$REGION 'documentation'}
{
  Enum for statement kind
  @value Unknown General statement kind
  @value Start Start a new transaction
  @value Commit Commit active transaction
  @value RollBack Rollback active transaction
}
{$ENDREGION}
  TStatementKind = (Unknown, Start, Commit, RollBack);
{$REGION 'documentation'}
{
  @abstract(Type for array of transaction syntaxs)
}
{$ENDREGION}
  TTransactionStatementSyntax = array [TStatementKind] of WideString;

{$REGION 'documentation'}
{
  @abstract(Statement parse)
  @member(
    Syntax Statement syntax to execute
    @return(String with syntax)
  )
  @member(
    HasBindParameters Defines if the statement has bindable variables to parse
    @return(@true if has bindable variables, @false if not)
  )
  @member(
    Kind Evaluate the statement to deteremine if is a transaction context statement
    @return(Kind Transaction action kind)
  )
  @member(
    ResolveBindParameters Set bindable paramters before execute statement. Only called when HasBindParameters = @true
    @param(Parameters Prepared parameter collections)
  )
}
{$ENDREGION}

  IStatement = interface
    ['{C7FE4239-D95E-498B-85C1-10058EBE5BA9}']
    function Syntax: WideString;
    function HasBindParameters: Boolean;
    function Kind: TStatementKind;
    procedure ResolveBindParameters(const Parameters: TParams);
  end;

{$REGION 'documentation'}
{
  @abstract(Callback event to resolve bindable parameters)
  @param(Statement @link(IStatement Statement object))
  @param(Parameters Prepared parameter collections)
}
{$ENDREGION}

  TOnStatementResolveBindParameters = reference to procedure(const Statement: IStatement; const Parameters: TParams);

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IStatement))
  @member(Syntax @seealso(IStatement.Syntax))
  @member(HasBindParameters @seealso(IStatement.HasBindParameters))
  @member(Kind @seealso(IStatement.Kind))
  @member(ResolveBindParameters @seealso(IStatement.ResolveBindParameters))
  @member(
  SanitizeEOLStatement Checks the end of line delimiter character
    @param(Statement Statement Statement)
    @return(Statement text)
  )
  @member(
    Create Object constructor
    @param(Syntax Statement syntax text)
    @param(OnStatementResolveBindParameters Callback event to set bindable parameters)
  )
  @member(
    New Creates a new @classname as interface
    @param(Syntax Statement syntax text)
    @param(OnStatementResolveBindParameters Callback event to set bindable parameters)
  )
}
{$ENDREGION}

  TStatement = class sealed(TInterfacedObject, IStatement)
  const
    STATEMENT_DELIMITER = ';';
    TRANSACTION_SYNTAX: TTransactionStatementSyntax = ('', 'BEGIN TRANSACTION', 'COMMIT', 'ROLLBACK');
  strict private
    _Syntax: WideString;
    _TransactionStatementSyntax: TTransactionStatementSyntax;
    _OnStatementResolveBindParameters: TOnStatementResolveBindParameters;
  private
    function SanitizeEOLStatement(const Syntax: WideString): WideString;
  public
    function Syntax: WideString;
    function HasBindParameters: Boolean;
    function Kind: TStatementKind;
    procedure ResolveBindParameters(const Parameters: TParams);
    constructor Create(const Syntax: WideString;
      const OnStatementResolveBindParameters: TOnStatementResolveBindParameters);
    class function New(const Syntax: WideString;
      const OnStatementResolveBindParameters: TOnStatementResolveBindParameters = nil): IStatement;
  end;

{$REGION 'documentation'}
{
  @abstract(Object to define an statement list)
  @member(
  LoadFromText Load items statment from text
    @param(Text Text content delimited)
    @param(StatementSeparator Delimited of statement, by default ";")
  )
}
{$ENDREGION}

  IStatementList = interface(IIterableList<IStatement>)
    ['{F05B8F43-D6C6-4606-95E3-CEE1B2B18165}']
    procedure LoadFromText(const Text: WideString; const StatementSeparator: WideString = TStatement.STATEMENT_DELIMITER);
  end;

{$REGION 'documentation'}
{
  @abstract(Implementation of @link(IStatementList))
  @member(LoadFromText @seealso(IStatementList.LoadFromText))
  @member(
    ResolveBlockOfCode Resolve code blocks of SQL
    @param(Text Text content delimited)
    @param(StatementSeparator Delimited of statement, by default ";")
  )
  @member(
    New Creates a new @classname as interface)
  @member(
    NewByArray Creates a new @classname as interface using an initial parameter list
    @param(Statements Array of @link(IStatement Statement objects))
  )
}
{$ENDREGION}

  TStatementList = class sealed(TIterableList<IStatement>, IStatementList)
  private
    function ResolveBlockOfCode(const ArrayItems: TStringDynArray; var CurrentIndex: Integer;
      const StatementSeparator: WideString): String;
  public
    procedure LoadFromText(const Text: WideString; const StatementSeparator: WideString = TStatement.STATEMENT_DELIMITER);
    class function New: IStatementList;
    class function NewByArray(const Statements: Array of IStatement): IStatementList;
  end;

implementation

function TStatement.Syntax: WideString;
begin
  Result := _Syntax;
end;

function TStatement.HasBindParameters: Boolean;
begin
  Result := Assigned(_OnStatementResolveBindParameters);
end;

function TStatement.SanitizeEOLStatement(const Syntax: WideString): WideString;
begin
  Result := Syntax;
  if RightStr(Result, 1) <> STATEMENT_DELIMITER then
    Result := Result + STATEMENT_DELIMITER;
end;

function TStatement.Kind: TStatementKind;
var
  Kind: TStatementKind;
begin
  Result := Unknown;
  for Kind := Low(TStatementKind) to High(TStatementKind) do
    if Pos(_TransactionStatementSyntax[Kind], _Syntax) > 0 then
      Exit(Kind);
end;

procedure TStatement.ResolveBindParameters(const Parameters: TParams);
begin
  if HasBindParameters then
    _OnStatementResolveBindParameters(Self, Parameters);
end;

constructor TStatement.Create(const Syntax: WideString;
  const OnStatementResolveBindParameters: TOnStatementResolveBindParameters);
begin
  _Syntax := SanitizeEOLStatement(Trim(Syntax));
  _TransactionStatementSyntax := TRANSACTION_SYNTAX;
  _OnStatementResolveBindParameters := OnStatementResolveBindParameters;
end;

class function TStatement.New(const Syntax: WideString;
  const OnStatementResolveBindParameters: TOnStatementResolveBindParameters): IStatement;
begin
  Result := TStatement.Create(Syntax, OnStatementResolveBindParameters);
end;

{ TStatementList }

function TStatementList.ResolveBlockOfCode(const ArrayItems: TStringDynArray; var CurrentIndex: Integer;
  const StatementSeparator: WideString): String;
const
  START_BLOCK = '--START-BLOCK';
  END_BLOCK = '--END-BLOCK';
var
  SQL: String;
begin
  Result := EmptyStr;
  SQL := Trim(ArrayItems[CurrentIndex]);
  if SameText(SQL, START_BLOCK) then
  begin
    while CurrentIndex <= High(ArrayItems) do
    begin
      Inc(CurrentIndex);
      SQL := ArrayItems[CurrentIndex];
      if SameText(Trim(SQL), END_BLOCK) then
        Exit(Trim(Result))
      else
        Result := Result + SQL + StatementSeparator;
    end;
  end
  else if Length(SQL) > 0 then
    Result := SQL + StatementSeparator;
end;

procedure TStatementList.LoadFromText(const Text: WideString; const StatementSeparator: WideString);
var
  ArrayItems: TStringDynArray;
  i: Integer;
  SQL: String;
begin
  Clear;
  ArrayItems := SplitString(Text, StatementSeparator);
  i := 0;
  while i <= High(ArrayItems) do
  begin
    SQL := ResolveBlockOfCode(ArrayItems, i, StatementSeparator);
    if Length(SQL) > 0 then
      Add(TStatement.New(SQL));
    Inc(i);
  end;
end;

class function TStatementList.New: IStatementList;
begin
  Result := TStatementList.Create;
end;

class function TStatementList.NewByArray(const Statements: array of IStatement): IStatementList;
var
  Statement: IStatement;
begin
  Result := TStatementList.Create;
  for Statement in Statements do
    Result.Add(Statement);
end;

end.
