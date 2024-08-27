unit uController.Endereco;

interface

uses
  FireDAC.Comp.Client, FireDAC.DApt, FireDAC.Stan.Param, uInterface.Endereco, System.SysUtils,
  System.Generics.Collections, uModel.Endereco, System.Json, Xml.XMLDoc, Xml.XMLIntf;

type
  TDBEnderecoRepository = class(TInterfacedObject, IEnderecoRepository)
  private
    FConnection: TFDConnection;
    function MapQueryToEndereco(Query: TFDQuery): IEndereco;
  public
    constructor Create(AConnection: TFDConnection);
    function GetByCEP(const ACEP: string): IEndereco;
    function GetByEndereco(const AEstado, ACidade, ALogradouro: string): TArray<IEndereco>;
    function GetByCodigo(const ACodigo: integer): IEndereco;
    procedure Add(const AEndereco: IEndereco);
    procedure Update(const AEndereco: IEndereco);
    procedure Delete(const AEndereco: IEndereco);
    function GetAll: TArray<IEndereco>;
    function ToXml(const AEndereco: IEndereco) : IXMLDocument;
    function ToJson(const AEndereco: IEndereco) : TJSONObject;
  end;

implementation

{ TDBEnderecoRepository }

constructor TDBEnderecoRepository.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

function TDBEnderecoRepository.MapQueryToEndereco(Query: TFDQuery): IEndereco;
begin
  Result := TEndereco.Create;
  Result.Codigo := Query.FieldByName('Codigo').AsInteger;
  Result.CEP := Query.FieldByName('CEP').AsString;
  Result.Logradouro := Query.FieldByName('Logradouro').AsString;
  Result.Complemento := Query.FieldByName('Complemento').AsString;
  Result.Bairro := Query.FieldByName('Bairro').AsString;
  Result.Localidade := Query.FieldByName('Localidade').AsString;
  Result.UF := Query.FieldByName('UF').AsString;
end;

function TDBEnderecoRepository.ToJson(const AEndereco: IEndereco): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('Codigo', TJSONNumber.Create(AEndereco.Codigo));
  Result.AddPair('CEP', AEndereco.CEP);
  Result.AddPair('Logradouro', AEndereco.Logradouro);
  Result.AddPair('Complemento', AEndereco.Complemento);
  Result.AddPair('Bairro', AEndereco.Bairro);
  Result.AddPair('Localidade', AEndereco.Localidade);
  Result.AddPair('UF', AEndereco.UF);
end;

function TDBEnderecoRepository.ToXml(const AEndereco: IEndereco): IXMLDocument;
var
  RootNode, EnderecoNode: IXMLNode;
begin
  Result := TXMLDocument.Create(nil);
  Result.Active := True;
  Result.Options := [doNodeAutoIndent];
  RootNode := Result.AddChild('Endereco');

  EnderecoNode := RootNode.AddChild('Codigo');
  EnderecoNode.Text := IntToStr(AEndereco.Codigo);

  EnderecoNode := RootNode.AddChild('CEP');
  EnderecoNode.Text := AEndereco.Cep;

  EnderecoNode := RootNode.AddChild('Logradouro');
  EnderecoNode.Text := AEndereco.Logradouro;

  EnderecoNode := RootNode.AddChild('Complemento');
  EnderecoNode.Text := AEndereco.Complemento;

  EnderecoNode := RootNode.AddChild('Bairro');
  EnderecoNode.Text := AEndereco.Bairro;

  EnderecoNode := RootNode.AddChild('Localidade');
  EnderecoNode.Text := AEndereco.Localidade;

  EnderecoNode := RootNode.AddChild('UF');
  EnderecoNode.Text := AEndereco.UF;
end;

function TDBEnderecoRepository.GetByCEP(const ACEP: string): IEndereco;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM Enderecos WHERE CEP = :CEP';
    Query.ParamByName('CEP').AsString := ACEP;
    Query.Open;

    if not Query.IsEmpty then
      Result := MapQueryToEndereco(Query);
  finally
    Query.Free;
  end;
end;

function TDBEnderecoRepository.GetByCodigo(const ACodigo: integer): IEndereco;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM Enderecos WHERE Codigo = :CODIGO';
    Query.ParamByName('CODIGO').AsInteger := ACodigo;
    Query.Open;

    if not Query.IsEmpty then
      Result := MapQueryToEndereco(Query);
  finally
    Query.Free;
  end;
end;

function TDBEnderecoRepository.GetByEndereco(const AEstado, ACidade, ALogradouro: string): TArray<IEndereco>;
var
  Query: TFDQuery;
  EnderecoList: TList<IEndereco>;
begin
  Result := nil;
  EnderecoList := TList<IEndereco>.Create;
  try
    Query := TFDQuery.Create(nil);
    Query.Connection := FConnection;
    try
      Query.SQL.Add('SELECT * FROM Enderecos ');
      Query.SQL.Add('WHERE UF = '+QuotedStr(AEstado));
      Query.SQL.Add('  AND LOCALIDADE LIKE '+QuotedStr('%'+ACidade+'%'));
      Query.SQL.Add('  AND LOGRADOURO LIKE '+QuotedStr('%'+ALogradouro+'%'));
      Query.Open;

      while not Query.Eof do
      begin
        EnderecoList.Add(MapQueryToEndereco(Query));
        Query.Next;
      end;
    finally
      Query.Free;
    end;

    Result := EnderecoList.ToArray;
  finally
    EnderecoList.Free;
  end;
end;

procedure TDBEnderecoRepository.Add(const AEndereco: IEndereco);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'INSERT INTO Enderecos (Codigo, CEP, Logradouro, Complemento, Bairro, Localidade, UF) ' +
                      'VALUES ((Select coalesce(max(codigo),0) + 1 from Enderecos), :CEP, :Logradouro, :Complemento, :Bairro, :Localidade, :UF)';
    Query.ParamByName('CEP').AsString := AEndereco.CEP;
    Query.ParamByName('Logradouro').AsString := AEndereco.Logradouro;
    Query.ParamByName('Complemento').AsString := AEndereco.Complemento;
    Query.ParamByName('Bairro').AsString := AEndereco.Bairro;
    Query.ParamByName('Localidade').AsString := AEndereco.Localidade;
    Query.ParamByName('UF').AsString := AEndereco.UF;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TDBEnderecoRepository.Update(const AEndereco: IEndereco);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'UPDATE Enderecos SET Logradouro = :Logradouro, Complemento = :Complemento, ' +
                      'Bairro = :Bairro, Localidade = :Localidade, UF = :UF ' +
                      'WHERE CEP = :CEP';
    Query.ParamByName('CEP').AsString := AEndereco.CEP;
    Query.ParamByName('Logradouro').AsString := AEndereco.Logradouro;
    Query.ParamByName('Complemento').AsString := AEndereco.Complemento;
    Query.ParamByName('Bairro').AsString := AEndereco.Bairro;
    Query.ParamByName('Localidade').AsString := AEndereco.Localidade;
    Query.ParamByName('UF').AsString := AEndereco.UF;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TDBEnderecoRepository.Delete(const AEndereco: IEndereco);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  Query.Connection := FConnection;
  try
    Query.SQL.Text := 'DELETE FROM Enderecos WHERE CEP = '+QuotedStr(AEndereco.Cep);
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TDBEnderecoRepository.GetAll: TArray<IEndereco>;
var
  Query: TFDQuery;
  EnderecoList: TList<IEndereco>;
begin
  EnderecoList := TList<IEndereco>.Create;
  try
    Query := TFDQuery.Create(nil);
    Query.Connection := FConnection;
    try
      Query.SQL.Text := 'SELECT * FROM Enderecos';
      Query.Open;

      while not Query.Eof do
      begin
        EnderecoList.Add(MapQueryToEndereco(Query));
        Query.Next;
      end;
    finally
      Query.Free;
    end;

    Result := EnderecoList.ToArray;
  finally
    EnderecoList.Free;
  end;
end;

end.

