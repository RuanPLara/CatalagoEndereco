unit ViaCepWS;

interface

uses
  System.SysUtils, System.Classes, IdHTTP, IdSSLOpenSSL, System.JSON, Xml.XMLIntf,
  Xml.XMLDoc, System.Generics.Collections, IdURI;

type
  TEndereco = class(TPersistent)
  private
    FLogradouro: string;
    FBairro: string;
    FCidade: string;
    FEstado: string;
    FCEP: string;
    FComplemento: string;
    FDDD: string;
    FSiafi: string;
    FIcbe: string;
    FGia: string;
    FUnidade: string;
    procedure SetComplemento(const Value: string);
  published
    property Logradouro: string read FLogradouro write FLogradouro;
    property Complemento: string read FComplemento write SetComplemento;
    property Bairro: string read FBairro write FBairro;
    property Cidade: string read FCidade write FCidade;
    property Estado: string read FEstado write FEstado;
    property CEP: string read FCEP write FCEP;
    property DDD: string read FDDD write FDDD;
    property Siafi: string read FSiafi write FSiafi;
    property Icbe: string read FIcbe write FIcbe;
    property Gia: string read FGia write FGia;
    property Unidade: string read FUnidade write FUnidade;
  end;

  TFormatoConsulta = (fcJSON, fcXML);

  TViaCepWS = class(TComponent)
  private
    FEnderecosResposta: TObjectList<TEndereco>;
    FIdHTTP: TIdHTTP;
    FSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
    FFormatoConsulta: TFormatoConsulta;
    FEnderecoConsulta: TEndereco;
    procedure SetEnderecosResposta(const Value: TObjectList<TEndereco>);
    function ProcessarResposta(const Response: string): Boolean;
    procedure SetEnderecoConsulta(const Value: TEndereco);
    procedure ParseJSONToEndereco(JSONObj: TJSONObject; Endereco: TEndereco);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function BuscarPorEndereco(var Endereco: TEndereco): Boolean;
    function BuscarCEP: Boolean;
  published
    property EnderecosResposta: TObjectList<TEndereco> read FEnderecosResposta write SetEnderecosResposta;
    property EnderecoConsulta: TEndereco read FEnderecoConsulta write SetEnderecoConsulta;
    property FormatoConsulta: TFormatoConsulta read FFormatoConsulta write FFormatoConsulta default fcJSON;
    function BuscarDadosEndereco: Boolean;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Client', [TViaCepWS]);
end;

{ TViaCepWS }

constructor TViaCepWS.Create(AOwner: TComponent);
begin
  inherited;
  FEnderecosResposta := TObjectList<TEndereco>.Create;
  FEnderecoConsulta := TEndereco.Create;
  FIdHTTP := TIdHTTP.Create(nil);
  FSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  FIdHttp.IOHandler := FSSLHandler;
  FSSLHandler.SSLOptions.SSLVersions := [sslvSSLv23];
end;

destructor TViaCepWS.Destroy;
begin
  FEnderecosResposta.Free;
  FEnderecoConsulta.Free;
  FIdHTTP.Free;
  FSSLHandler.Free;
  inherited;
end;

procedure TViaCepWS.SetEnderecoConsulta(const Value: TEndereco);
begin
  FEnderecoConsulta := Value;
end;

procedure TViaCepWS.SetEnderecosResposta(const Value: TObjectList<TEndereco>);
begin
  FEnderecosResposta := Value;
end;

procedure TViaCepWS.ParseJSONToEndereco(JSONObj: TJSONObject; Endereco: TEndereco);
begin
  Endereco.Logradouro := JSONObj.GetValue<string>('logradouro', '');
  Endereco.Complemento := JSONObj.GetValue<string>('complemento', '');
  Endereco.Bairro := JSONObj.GetValue<string>('bairro', '');
  Endereco.Cidade := JSONObj.GetValue<string>('localidade', '');
  Endereco.Estado := JSONObj.GetValue<string>('uf', '');
  Endereco.CEP := JSONObj.GetValue<string>('cep', '');
  Endereco.DDD := JSONObj.GetValue<string>('ddd', '');
  Endereco.Siafi := JSONObj.GetValue<string>('siafi', '');
  Endereco.Icbe := JSONObj.GetValue<string>('ibge', '');
  Endereco.Gia := JSONObj.GetValue<string>('gia', '');
  Endereco.Unidade := JSONObj.GetValue<string>('unidade', '');
end;

function TViaCepWS.ProcessarResposta(const Response: string): Boolean;
var
  JSONValue: TJSONValue;
  JSONArray: TJSONArray;
  JSONObject: TJSONObject;
  XMLDoc: IXMLDocument;
  Endereco: TEndereco;

  Procedure ProcessarJSON(const JSONObj: TJSONObject);
  begin
    Endereco := TEndereco.Create;
    try
      ParseJSONToEndereco(JSONObj, Endereco);
      FEnderecosResposta.Add(Endereco);
    except
      Endereco.Free;
      raise Exception.Create('Erro ao processar o JSON.');
    end;
  end;

  Procedure ProcessarXML(const Node: IXMLNode);
  var
    ChildNode: IXMLNode;
  begin
    Endereco := TEndereco.Create;
    try
      ChildNode := Node.ChildNodes.FindNode('logradouro');
      if Assigned(ChildNode) then
        Endereco.Logradouro := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('complemento');
      if Assigned(ChildNode) then
        Endereco.Complemento := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('bairro');
      if Assigned(ChildNode) then
        Endereco.Bairro := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('localidade');
      if Assigned(ChildNode) then
        Endereco.Cidade := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('uf');
      if Assigned(ChildNode) then
        Endereco.Estado := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('cep');
      if Assigned(ChildNode) then
        Endereco.CEP := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('ddd');
      if Assigned(ChildNode) then
        Endereco.DDD := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('siafi');
      if Assigned(ChildNode) then
        Endereco.Siafi := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('ibge');
      if Assigned(ChildNode) then
        Endereco.Icbe := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('gia');
      if Assigned(ChildNode) then
        Endereco.Gia := ChildNode.Text;
      ChildNode := Node.ChildNodes.FindNode('unidade');
      if Assigned(ChildNode) then
        Endereco.Unidade := ChildNode.Text;

      FEnderecosResposta.Add(Endereco);
    except
      Endereco.Free;
      raise Exception.Create('Erro ao processar o XML.');
    end;
  end;

begin
  Result := False;
  FEnderecosResposta.Clear;
  try
    case FFormatoConsulta of
      fcJSON:
        begin
          JSONValue := TJSONObject.ParseJSONValue(Response);
          try
            if JSONValue is TJSONArray then
            begin
              JSONArray := JSONValue as TJSONArray;
              for var I := 0 to JSONArray.Count - 1 do
              begin
                JSONObject := JSONArray.Items[I] as TJSONObject;
                ProcessarJSON(JSONObject);
              end;
            end
            else if JSONValue is TJSONObject then
            begin
              JSONObject := JSONValue as TJSONObject;
              ProcessarJSON(JSONObject);
            end;
            Result := FEnderecosResposta.Count > 0;
          finally
            JSONValue.Free;
          end;
        end;
      fcXML:
        begin
          XMLDoc := LoadXMLData(Response);
          try
            if Assigned(XMLDoc) and Assigned(XMLDoc.DocumentElement) then
            begin
              for var I := 0 to XMLDoc.DocumentElement.ChildNodes.Count - 1 do
                ProcessarXML(XMLDoc.DocumentElement.ChildNodes[I]);
              Result := FEnderecosResposta.Count > 0;
            end;
          finally
            XMLDoc := nil;
          end;
        end;
    end;
  except
    on E: Exception do
      raise Exception.Create('Erro ao processar a resposta: ' + E.Message);
  end;
end;

function TViaCepWS.BuscarCEP: Boolean;
var
  Response: string;
  URL: string;
begin
  Result := False;
  try
    URL := 'https://viacep.com.br/ws/' + FEnderecoConsulta.CEP;
    case FFormatoConsulta of
      fcJSON: URL := URL + '/json/';
      fcXML: URL := URL + '/xml/';
    end;
    Response := FIdHTTP.Get(URL);
    Result := ProcessarResposta(Response);
  except
    on E: Exception do
      raise Exception.Create('Erro ao buscar o CEP: ' + E.Message);
  end;
end;

function TViaCepWS.BuscarDadosEndereco: Boolean;
begin
  Self.FEnderecosResposta.Clear;

  if not FEnderecoConsulta.CEP.IsEmpty then
    Result := BuscarCEP
  else
    Result := BuscarPorEndereco(FEnderecoConsulta);

  Self.FEnderecoConsulta.Free;
  Self.FEnderecoConsulta := TEndereco.Create;
end;

function TViaCepWS.BuscarPorEndereco(var Endereco: TEndereco): Boolean;
var
  Response: string;
  URL: string;
begin
  Result := False;
  try
    URL := Format('https://viacep.com.br/ws/%s/%s/%s', [Endereco.Estado,
                                                        Endereco.Cidade,
                                                        Endereco.Logradouro]);
    case FFormatoConsulta of
      fcJSON: URL := URL + '/json/';
      fcXML: URL := URL + '/xml/';
    end;

    URL := TIdURI.URLEncode(Url);

    Response := FIdHTTP.Get(URL);
    Result := ProcessarResposta(Response);
  except
    on E: Exception do
      raise Exception.Create('Erro ao buscar o endere�o: ' + E.Message);
  end;
end;

{ TEndereco }

procedure TEndereco.SetComplemento(const Value: string);
begin
  FComplemento := Value;
end;

end.

