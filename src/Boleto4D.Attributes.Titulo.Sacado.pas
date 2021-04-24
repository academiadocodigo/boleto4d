unit Boleto4D.Attributes.Titulo.Sacado;

interface

uses
  Boleto4D.Interfaces;

type
  TBoleto4DAttributesTituloSacado = class(TInterfacedObject, iBoleto4DAttributesTituloSacado)
    private
      [weak]
      FParent : iBoleto4DAttributesTitulo;
      FNome : String;
      FCNPJCPF : String;
      FLogradouro : String;
      FNumero : String;
      FBairro : String;
      FCidade : String;
      FUF : String;
      FCEP : String;
    public
      constructor Create(aParent : iBoleto4DAttributesTitulo);
      destructor Destroy; override;
      class function New(aParent : iBoleto4DAttributesTitulo) : iBoleto4DAttributesTituloSacado;
      function Nome ( aValue : String ) : iBoleto4DAttributesTituloSacado; overload;
      function Nome : String; overload;
      function CNPJCPF ( aValue : String ) : iBoleto4DAttributesTituloSacado; overload;
      function CNPJCPF : String; overload;
      function Logradouro ( aValue : String ) : iBoleto4DAttributesTituloSacado; overload;
      function Logradouro : String; overload;
      function Numero ( aValue : String ) : iBoleto4DAttributesTituloSacado; overload;
      function Numero : String; overload;
      function Bairro ( aValue : String ) : iBoleto4DAttributesTituloSacado; overload;
      function Bairro : String; overload;
      function Cidade ( aValue : String ) : iBoleto4DAttributesTituloSacado; overload;
      function Cidade : String; overload;
      function UF ( aValue : String  ) : iBoleto4DAttributesTituloSacado; overload;
      function UF : String; overload;
      function CEP ( aValue : String ) : iBoleto4DAttributesTituloSacado; overload;
      function CEP : String; overload;
      function &End : iBoleto4DAttributesTitulo;
  end;

implementation

{ TModelServicesBoletoTituloSacado }

function TBoleto4DAttributesTituloSacado.&end : iBoleto4DAttributesTitulo;
begin
    Result := FParent;
end;

function TBoleto4DAttributesTituloSacado.Logradouro: String;
begin
  Result := FLogradouro;
end;

function TBoleto4DAttributesTituloSacado.Bairro(
  aValue: String): iBoleto4DAttributesTituloSacado;
begin
  Result := Self;
  FBairro := aValue;
end;

function TBoleto4DAttributesTituloSacado.Bairro: String;
begin
  Result := FBairro;
end;

function TBoleto4DAttributesTituloSacado.CEP(
  aValue: String): iBoleto4DAttributesTituloSacado;
begin
  Result := Self;
  FCEP := aValue;
end;

function TBoleto4DAttributesTituloSacado.CEP: String;
begin
  Result := FCEP;
end;

function TBoleto4DAttributesTituloSacado.Cidade(
  aValue: String): iBoleto4DAttributesTituloSacado;
begin
  Result := Self;
  FCidade := aValue;
end;

function TBoleto4DAttributesTituloSacado.Cidade: String;
begin
  Result := FCidade;
end;

function TBoleto4DAttributesTituloSacado.CNPJCPF(
  aValue: String): iBoleto4DAttributesTituloSacado;
begin
  Result := Self;
  FCNPJCPF := aValue;
end;

function TBoleto4DAttributesTituloSacado.CNPJCPF: String;
begin
  Result := FCNPJCPF;
end;

function TBoleto4DAttributesTituloSacado.Logradouro(
  aValue: String): iBoleto4DAttributesTituloSacado;
begin
  Result := Self;
  FLogradouro := aValue;
end;

constructor TBoleto4DAttributesTituloSacado.Create(aParent : iBoleto4DAttributesTitulo);
begin
  FParent := aParent;
end;

destructor TBoleto4DAttributesTituloSacado.Destroy;
begin

  inherited;
end;

class function TBoleto4DAttributesTituloSacado.New(aParent : iBoleto4DAttributesTitulo): iBoleto4DAttributesTituloSacado;
begin
  Result := Self.Create(aParent);
end;

function TBoleto4DAttributesTituloSacado.Nome: String;
begin
  Result := FNome;
end;

function TBoleto4DAttributesTituloSacado.Nome(
  aValue: String): iBoleto4DAttributesTituloSacado;
begin
  Result := Self;
  FNome := aValue;
end;

function TBoleto4DAttributesTituloSacado.Numero: String;
begin
  Result := FNumero;
end;

function TBoleto4DAttributesTituloSacado.Numero(
  aValue: String): iBoleto4DAttributesTituloSacado;
begin
  Result := Self;
  FNumero := aValue;
end;

function TBoleto4DAttributesTituloSacado.UF(
  aValue: String): iBoleto4DAttributesTituloSacado;
begin
  Result := Self;
  FUF := aValue;
end;

function TBoleto4DAttributesTituloSacado.UF: String;
begin
  Result := FUF;
end;

end.
