unit uModel.Endereco;

interface

uses uInterface.Endereco, System.Generics.Collections, System.SysUtils;

type
  TEndereco = class(TInterfacedObject, IEndereco)
  private
    FCodigo: integer;
    FCEP: string;
    FLogradouro: string;
    FComplemento: string;
    FBairro: string;
    FLocalidade: string;
    FUF: string;
  public
    function GetCodigo: integer;
    function GetCEP: string;
    function GetLogradouro: string;
    function GetComplemento: string;
    function GetBairro: string;
    function GetLocalidade: string;
    function GetUF: string;

    procedure SetCodigo(const Value: integer);
    procedure SetCEP(const Value: string);
    procedure SetLogradouro(const Value: string);
    procedure SetComplemento(const Value: string);
    procedure SetBairro(const Value: string);
    procedure SetLocalidade(const Value: string);
    procedure SetUF(const Value: string);
  end;

implementation

{ TEndereco }

function TEndereco.GetBairro: string;
begin
  Result := FBairro;
end;

function TEndereco.GetCEP: string;
begin
  Result := FCep;
end;

function TEndereco.GetCodigo: integer;
begin
  Result := FCodigo;
end;

function TEndereco.GetComplemento: string;
begin
  Result := FComplemento
end;

function TEndereco.GetLocalidade: string;
begin
  Result := FLocalidade;
end;

function TEndereco.GetLogradouro: string;
begin
  Result := FLogradouro;
end;

function TEndereco.GetUF: string;
begin
  Result := FUF;
end;

procedure TEndereco.SetBairro(const Value: string);
begin
  FBairro := Value;
end;

procedure TEndereco.SetCEP(const Value: string);
var
  I: Integer;
  Resultado: string;
begin
  Resultado := '';
  for I := 1 to Length(Value) do
  begin
    if Value[I] in ['0'..'9'] then
      Resultado := Resultado + Value[I];
  end;
  FCep := Resultado;
end;

procedure TEndereco.SetCodigo(const Value: integer);
begin
  FCodigo := Value;
end;

procedure TEndereco.SetComplemento(const Value: string);
begin
  FComplemento := Value;
end;

procedure TEndereco.SetLocalidade(const Value: string);
begin
  FLocalidade := Value;
end;

procedure TEndereco.SetLogradouro(const Value: string);
begin
  FLogradouro := Value;
end;

procedure TEndereco.SetUF(const Value: string);
begin
  FUF := Value;
end;

end.

