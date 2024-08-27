unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ViaCepWS, Vcl.StdCtrls, Vcl.Mask, System.JSON,
  Xml.XMLDoc, Xml.XMLIntf, Vcl.ExtCtrls, uController.Endereco, uInterface.Endereco,
  uModel.Endereco, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  Datasnap.DBClient, System.Generics.Collections;

type
  TfrmMain = class(TForm)
    ListarTodos: TButton;
    ViaCepWS: TViaCepWS;
    EdCep: TLabeledEdit;
    edEstado: TLabeledEdit;
    EdCidade: TLabeledEdit;
    EdLogradouro: TLabeledEdit;
    btBuscarCep: TButton;
    btBuscaCep: TButton;
    RgFormato: TRadioGroup;
    PgResponse: TPageControl;
    TsDados: TTabSheet;
    TsGrid: TTabSheet;
    mmResult: TMemo;
    GdDados: TDBGrid;
    cdsDados: TClientDataSet;
    dsDados: TDataSource;
    BtDeletar: TButton;
    procedure ListarTodosClick(Sender: TObject);
    procedure btBuscarCepClick(Sender: TObject);
    procedure JSONToDataSet(JSONString: string; DataSet: TDataSet);
    procedure btBuscaCepClick(Sender: TObject);
    procedure BtDeletarClick(Sender: TObject);
  private
    procedure PrintResult(LEnderecoController: IEnderecoRepository; LEndereco: IEndereco);
    procedure ViaCepEnderecoToInterface(var LEndereco: IEndereco; const AIndex : integer = 0);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses uConexao;

procedure TfrmMain.btBuscaCepClick(Sender: TObject);
var LEnderecoController: IEnderecoRepository;
    LEnderecoLista : TArray<IEndereco>;
    LEndereco : IEndereco;
    LUF, LCidade, LLogradouro : String;
    indexEndereco : integer;
begin
  LUf := Trim(EdEstado.Text);
  if LUf = EmptyStr then
  begin
    raise Exception.Create('Informe um estado válido');
  end;

  LCidade := Trim(EdCidade.Text);
  if LCidade = EmptyStr then
  begin
    raise Exception.Create('Informe uma cidade válida');
  end;

  LLogradouro := Trim(EdLogradouro.Text);
  if LLogradouro = EmptyStr then
  begin
    raise Exception.Create('Informe um logradouro válido');
  end;

  mmResult.Clear;
  LEnderecoController := TDBEnderecoRepository.Create(TDatabaseConnection.GetInstance.GetFDConnection);
  LEnderecoLista := LEnderecoController.GetByEndereco(LUF, LCidade, LLogradouro);
  if not Assigned(LEnderecoLista) then
  begin
    // Busca Via WS
    ViaCepWs.EnderecoConsulta.Estado := LUf;
    ViaCepWs.EnderecoConsulta.Cidade := LCidade;
    ViaCepWs.EnderecoConsulta.Logradouro := LLogradouro;
    ViaCepWS.FormatoConsulta := TFormatoConsulta(rgFormato.ItemIndex);

    if ViaCepWs.BuscarDadosEndereco then
    begin
      for indexEndereco := 0 to ViaCepWs.EnderecosResposta.Count -1 do
      begin
        LEndereco := TEndereco.Create();
        ViaCepEnderecoToInterface(LEndereco, indexEndereco);
        LEnderecoController.Add(LEndereco);
      end;
    end;
  end
  else
  begin
    if MessageDlg(Format('Encontrada cidade: %s - %s. '+SLineBreak+
                         'Deseja atualizar essas informações?', [LEnderecoLista[0].Localidade, LEnderecoLista[0].UF]),
       TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0 ) = mrYes then
    begin
      // Busca Via WS
      ViaCepWs.EnderecoConsulta.Estado := LUf;
      ViaCepWs.EnderecoConsulta.Cidade := LCidade;
      ViaCepWs.EnderecoConsulta.Logradouro := LLogradouro;
      ViaCepWS.FormatoConsulta := TFormatoConsulta(rgFormato.ItemIndex);

      if ViaCepWs.BuscarDadosEndereco then
      begin
        for indexEndereco := 0 to ViaCepWs.EnderecosResposta.Count -1 do
        begin
          LEndereco := TEndereco.Create();
          ViaCepEnderecoToInterface(LEndereco, indexEndereco);
          LEnderecoController.Update(LEndereco);
        end;
      end;
    end;
  end;

  PrintResult(LEnderecoController, LEndereco);

end;

procedure TfrmMain.JSONToDataSet(JSONString: string; DataSet: TDataSet);
var
  JSONArray: TJSONArray;
  JSONObj: TJSONObject;
  JSONPair: TJSONPair;
  i: Integer;
begin
  // Limpar o DataSet antes de usar
  DataSet.Close;
  DataSet.FieldDefs.Clear;
  DataSet.Fields.Clear;

  // Criar JSON Array a partir da string JSON
  JSONArray := TJSONObject.ParseJSONValue(JSONString) as TJSONArray;
  try
    // Definir os campos do DataSet de acordo com a estrutura do JSON
    if JSONArray.Count > 0 then
    begin
      JSONObj := JSONArray.Items[0] as TJSONObject;
      for JSONPair in JSONObj do
      begin
        // Adicionar uma definição de campo de string para cada par JSON (Chave:Valor)
        DataSet.FieldDefs.Add(JSONPair.JsonString.Value, ftString, 20);
      end;
    end;

    // Criar a estrutura interna de dados
    (DataSet as TClientDataSet).CreateDataSet;

    // Preencher o DataSet com os dados do JSON
    for i := 0 to JSONArray.Count - 1 do
    begin
      DataSet.Append;
      JSONObj := JSONArray.Items[i] as TJSONObject;
      for JSONPair in JSONObj do
      begin
        DataSet.FieldByName(JSONPair.JsonString.Value).AsString := JSONPair.JsonValue.Value;
      end;
      DataSet.Post;
    end;
  finally
    JSONArray.Free;
  end;
end;

procedure TfrmMain.PrintResult(LEnderecoController: IEnderecoRepository; LEndereco: IEndereco);
var
  LEnderecoJson: TJSONObject;
begin
  PgResponse.ActivePage := TsDados;
  case rgFormato.ItemIndex of
    0:
      try
        LEnderecoJson := LEnderecoController.ToJson(LEndereco);
        mmResult.Lines.Add(LEnderecoJson.ToString);
      finally
        LEnderecoJson.Free;
      end;
    1:
      mmResult.Lines.Add(LEnderecoController.ToXml(LEndereco).Xml.Text);
  end;
end;

procedure TfrmMain.ViaCepEnderecoToInterface(var LEndereco: IEndereco; const AIndex : integer = 0);
begin
  LEndereco.Cep := ViaCepWs.EnderecosResposta[AIndex].Cep;
  LEndereco.Logradouro := ViaCepWs.EnderecosResposta[AIndex].Logradouro;
  LEndereco.Complemento := ViaCepWs.EnderecosResposta[AIndex].Complemento;
  LEndereco.Bairro := ViaCepWs.EnderecosResposta[AIndex].Bairro;
  LEndereco.Localidade := ViaCepWs.EnderecosResposta[AIndex].Cidade;
  LEndereco.UF := ViaCepWs.EnderecosResposta[AIndex].Estado;
end;

procedure TfrmMain.ListarTodosClick(Sender: TObject);
var LEnderecoController: IEnderecoRepository;
    LEndereco : IEndereco;
    LListaJson : TJSONArray;
    LListaXml : IXmlDocument;
    LNohXml : IXMLNode;
begin
  LEnderecoController := TDBEnderecoRepository.Create(TDatabaseConnection.GetInstance.GetFDConnection);

  mmResult.Clear;
  try
    LListaJson := TJSONArray.Create;
    for LEndereco in LEnderecoController.GetAll do
      LListaJson.Add(LEnderecoController.ToJson(LEndereco));

    if LListaJson.Size = 0 then
      exit;

    mmResult.Lines.Text := LListaJson.ToString;
    PgResponse.ActivePage := TsGrid;
    JSONToDataSet(mmResult.Lines.Text, cdsDados);
  finally
    LListaJson.Free;
  end;
end;

procedure TfrmMain.btBuscarCepClick(Sender: TObject);
var LEnderecoController: IEnderecoRepository;
    LEndereco : IEndereco;
    LCep : String;
    indexEndereco : integer;
begin
  LCep := Trim(EdCep.Text);
  if LCep = EmptyStr then
  begin
    raise Exception.Create('Informe um cep válido');
    exit;
  end;

  mmResult.Clear;
  LEnderecoController := TDBEnderecoRepository.Create(TDatabaseConnection.GetInstance.GetFDConnection);
  LEndereco := TEndereco(LEnderecoController.GetByCEP(LCep));
  if not Assigned(LEndereco) then
  begin
    // Busca Via WS
    ViaCepWs.EnderecoConsulta.Cep := LCep;
    ViaCepWS.FormatoConsulta := TFormatoConsulta(rgFormato.ItemIndex);

    if ViaCepWs.BuscarDadosEndereco then
    begin
      for indexEndereco := 0 to ViaCepWs.EnderecosResposta.Count - 1 do
      begin
        LEndereco := TEndereco.Create();
        ViaCepEnderecoToInterface(LEndereco, indexEndereco);
        LEnderecoController.Add(LEndereco);
      end;
    end;
  end
  else
  begin
    if MessageDlg(Format('Encontrada cidade: %s - %s. '+SLineBreak+
                         '%s'+SLineBreak+
                         'Deseja atualizar essas informações?', [LEndereco.Localidade, LEndereco.UF, LEndereco.Logradouro]),
       TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0 ) = mrYes then
    begin
      // Busca Via WS
      ViaCepWs.EnderecoConsulta.Cep := LCep;
      ViaCepWS.FormatoConsulta := TFormatoConsulta(rgFormato.ItemIndex);

      if ViaCepWs.BuscarDadosEndereco then
      begin
        for indexEndereco := 0 to ViaCepWs.EnderecosResposta.Count - 1 do
        begin
          LEndereco := TEndereco.Create();
          ViaCepEnderecoToInterface(LEndereco, indexEndereco);
          LEnderecoController.Update(LEndereco);
        end;
      end;
    end;
  end;

  PrintResult(LEnderecoController, LEndereco);
end;

procedure TfrmMain.BtDeletarClick(Sender: TObject);
var LEnderecoController: IEnderecoRepository;
    LEndereco : IEndereco;
begin
  LEnderecoController := TDBEnderecoRepository.Create(TDatabaseConnection.GetInstance.GetFDConnection);
  for LEndereco in LEnderecoController.GetAll do
    LEnderecoController.Delete(LEndereco);
  showmessage('Deletados');
end;

end.
