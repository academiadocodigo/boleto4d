unit Boleto4D.Attributes.Banco;

interface

uses
  Boleto4D.Interfaces;

type
  TBoleto4DAttributesBanco = class(TInterfacedObject, iBoleto4DAttributesBanco)
    private
      [weak]
      FParent : iBoleto4D;
      FNumero : Integer;
      FTipoCobranca : Integer;
    public
      constructor Create(aParent : iBoleto4D);
      destructor Destroy; override;
      class function New(aParent : iBoleto4D) : iBoleto4DAttributesBanco;
      function Numero ( aValue : Integer ) : iBoleto4DAttributesBanco; overload;
      function Numero : Integer; overload;
      function TipoCobranca ( aValue : Integer ) : iBoleto4DAttributesBanco; overload;
      function TipoCobranca : Integer; overload;
      function &End : iBoleto4D;
  end;

implementation

{ TModelServicesBoletoBanco }

function TBoleto4DAttributesBanco.&end : iBoleto4D;
begin
    Result := FParent;
end;

constructor TBoleto4DAttributesBanco.Create(aParent : iBoleto4D);
begin
  FParent := aParent;
end;

destructor TBoleto4DAttributesBanco.Destroy;
begin

  inherited;
end;

class function TBoleto4DAttributesBanco.New(aParent : iBoleto4D): iBoleto4DAttributesBanco;
begin
  Result := Self.Create(aParent);
end;

function TBoleto4DAttributesBanco.Numero(
  aValue: Integer): iBoleto4DAttributesBanco;
begin
  Result := Self;
  FNumero := aValue;
end;

function TBoleto4DAttributesBanco.Numero: Integer;
begin
  Result := FNumero;
end;

function TBoleto4DAttributesBanco.TipoCobranca(
  aValue: Integer): iBoleto4DAttributesBanco;
begin
  Result := Self;
  FTipoCobranca := aValue;
end;

function TBoleto4DAttributesBanco.TipoCobranca: Integer;
begin
  Result := FTipoCobranca;
end;

end.
