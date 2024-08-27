unit uInterface.Endereco;

interface

uses Xml.XMLDoc, Xml.XMLIntf, System.Json;

type
  IEndereco = interface(IInterface)
    ['{0E1072EB-3083-4D07-9035-2F81ECAC2A15}']
    function GetCodigo: Integer;
    function GetCEP: string;
    function GetLogradouro: string;
    function GetComplemento: string;
    function GetBairro: string;
    function GetLocalidade: string;
    function GetUF: string;

    procedure SetCodigo(const Value: Integer);
    procedure SetCEP(const Value: string);
    procedure SetLogradouro(const Value: string);
    procedure SetComplemento(const Value: string);
    procedure SetBairro(const Value: string);
    procedure SetLocalidade(const Value: string);
    procedure SetUF(const Value: string);

    property Codigo: Integer read GetCodigo write SetCodigo;
    property CEP: string read GetCEP write SetCEP;
    property Logradouro: string read GetLogradouro write SetLogradouro;
    property Complemento: string read GetComplemento write SetComplemento;
    property Bairro: string read GetBairro write SetBairro;
    property Localidade: string read GetLocalidade write SetLocalidade;
    property UF: string read GetUF write SetUF;
  end;

  IEnderecoRepository = interface
    ['{E958120F-8AE0-4C91-A167-C79BF6E9E6AD}']
    function GetByCEP(const ACEP: string): IEndereco;
    function GetByEndereco(const AEstado, ACidade, ALogradouro: string): TArray<IEndereco>;
    function GetByCodigo(const ACodigo: integer): IEndereco;
    procedure Add(const AEndereco : IEndereco);
    procedure Update(const AEndereco : IEndereco);
    procedure Delete(const AEndereco : IEndereco);
    function GetAll: TArray<IEndereco>;
    function ToXml(const AEndereco: IEndereco) : IXMLDocument;
    function ToJson(const AEndereco: IEndereco) : TJSONObject;
  end;


implementation

end.
