unit Boleto4D.Attributes.Cedente;

interface

uses
  Boleto4D.Interfaces;

type
  TBoleto4DAttributesCedente = class(TInterfacedObject, iBoleto4DAttributesCedente)
    private
      [weak]
      FParent : iBoleto4D;
      FAgencia : String;
      FAgenciaDigito : String;
      FCodigoCedente : String;
      FConta : String;
      FContaDigito : String;
      FTipoInscrição : Integer;
      FWebService : iBoleto4DAttributesCedenteWebService;
      FFantasia : String;
      FNome : String;
      FCNPJCPF : String;
      FLogradouro : String;
      FBairro : String;
      FCidade : String;
      FCEP : String;
      FTelefone : String;
    public
      constructor Create(aParent : iBoleto4D);
      destructor Destroy; override;
      class function New(aParent : iBoleto4D) : iBoleto4DAttributesCedente;
      function Fantasia ( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function Fantasia : String; overload;
      function Nome ( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function Nome : String; overload;
      function CNPJCPF ( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function CNPJCPF : String; overload;
      function Logradouro ( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function Logradouro : String; overload;
      function Bairro ( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function Bairro : String; overload;
      function Cidade ( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function Cidade : String; overload;
      function CEP ( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function CEP : String; overload;
      function Telefone ( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function Telefone : String; overload;
      function Agencia( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function Agencia : String; overload;
      function AgenciaDigito( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function AgenciaDigito : String; overload;
      function CodigoCedente( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function CodigoCedente : String; overload;
      function Conta( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function Conta : String; overload;
      function ContaDigito( aValue : String ) : iBoleto4DAttributesCedente; overload;
      function ContaDigito : String; overload;
      function TipoInscricao( aValue : Integer) : iBoleto4DAttributesCedente; overload;
      function TipoInscricao : Integer; overload;
      function WebService : iBoleto4DAttributesCedenteWebService;
      function &End : iBoleto4D;
  end;

implementation

uses
  Boleto4D.Attributes.Cedente.WebService;

{ TModelServicesBoletoCedente }

function TBoleto4DAttributesCedente.&end : iBoleto4D;
begin
    Result := FParent;
end;

function TBoleto4DAttributesCedente.Fantasia: String;
begin
  Result := FFantasia;
end;

function TBoleto4DAttributesCedente.Fantasia(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FFantasia := aValue;
end;

function TBoleto4DAttributesCedente.Logradouro(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FLogradouro := aValue;
end;

function TBoleto4DAttributesCedente.Logradouro: String;
begin
  Result := FLogradouro;
end;

function TBoleto4DAttributesCedente.Agencia: String;
begin
  Result := FAgencia;
end;

function TBoleto4DAttributesCedente.Agencia(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FAgencia := aValue;
end;

function TBoleto4DAttributesCedente.AgenciaDigito: String;
begin
  Result := FAgenciaDigito;
end;

function TBoleto4DAttributesCedente.Bairro: String;
begin
  Result := FBairro;
end;

function TBoleto4DAttributesCedente.Bairro(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FBairro := aValue;
end;

function TBoleto4DAttributesCedente.AgenciaDigito(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FAgenciaDigito := aValue;
end;

function TBoleto4DAttributesCedente.CodigoCedente(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FCodigoCedente := aValue;
end;

function TBoleto4DAttributesCedente.CEP: String;
begin
  Result := FCEP;
end;

function TBoleto4DAttributesCedente.CEP(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FCEP := aValue;
end;

function TBoleto4DAttributesCedente.Cidade: String;
begin
  Result := FCidade;
end;

function TBoleto4DAttributesCedente.Cidade(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FCidade := aValue;
end;

function TBoleto4DAttributesCedente.CNPJCPF: String;
begin
  Result := FCNPJCPF;
end;

function TBoleto4DAttributesCedente.CNPJCPF(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FCNPJCPF := aValue;
end;

function TBoleto4DAttributesCedente.CodigoCedente: String;
begin
  Result := FCodigoCedente;
end;

function TBoleto4DAttributesCedente.Conta: String;
begin
  Result := FConta;
end;

function TBoleto4DAttributesCedente.Conta(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FConta := aValue;
end;

function TBoleto4DAttributesCedente.ContaDigito: String;
begin
  Result := FContaDigito;
end;

function TBoleto4DAttributesCedente.ContaDigito(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FContaDigito := aValue;
end;

constructor TBoleto4DAttributesCedente.Create(aParent : iBoleto4D);
begin
  FParent := aParent;
  FWebService := TBoleto4DAttributesCedenteWebService.New(Self);
end;

destructor TBoleto4DAttributesCedente.Destroy;
begin

  inherited;
end;

class function TBoleto4DAttributesCedente.New(aParent : iBoleto4D): iBoleto4DAttributesCedente;
begin
  Result := Self.Create(aParent);
end;

function TBoleto4DAttributesCedente.Nome: String;
begin
  Result := FNome;
end;

function TBoleto4DAttributesCedente.Nome(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FNome := aValue;
end;

function TBoleto4DAttributesCedente.Telefone(
  aValue: String): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FTelefone := aValue;
end;

function TBoleto4DAttributesCedente.Telefone: String;
begin
  Result := FTelefone;
end;

function TBoleto4DAttributesCedente.TipoInscricao: Integer;
begin
  Result := FTipoInscrição;
end;

function TBoleto4DAttributesCedente.WebService: iBoleto4DAttributesCedenteWebService;
begin
  Result := FWebService;
end;

function TBoleto4DAttributesCedente.TipoInscricao(
  aValue: Integer): iBoleto4DAttributesCedente;
begin
  Result := Self;
  FTipoInscrição := aValue;
end;

end.
