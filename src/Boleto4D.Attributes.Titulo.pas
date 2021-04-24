unit Boleto4D.Attributes.Titulo;

interface

uses
  Boleto4D.Interfaces;

type
  TBoleto4DAttributesTitulo = class(TInterfacedObject, iBoleto4DAttributesTitulo)
    private
      [weak]
      FParent : iBoleto4D;
      FVencimento : TDate;
      FDataDocumento : TDate;
      FNumeroDocumento : String;
      FEspecieDoc : String;
      FAceite : Integer;
      FDataProcessamento : TDate;
      FCarteira : String;
      FNossoNumero : String;
      FValorDocumento : Currency;
      FValorAbatimento : Currency;
      FLocalPagamento : String;
      FValorMoraJuros : Currency;
      FValorDesconto : Currency;
      FDataMoraJuros : TDate;
      FDataDesconto : TDate;
      FDataAbatimento : TDate;
      FDataProtesto : TDate;
      FPercentualMulta : Currency;
      FOcorrencuaOriginalTipo : Integer;
      FInstrucao1 : String;
      FInstrucao2 : String;
      FQtdePagamentoParcial : Integer;
      FTipoPagamento : Integer;
      FPercentualMinPagamento : Currency;
      FPercentualMaxPagamento : Currency;
      FValorMinPagamento : Currency;
      FValorMaxPagamento : Currency;
      FSacado : iBoleto4DAttributesTituloSacado;
    public
      constructor Create(aParent : iBoleto4D);
      destructor Destroy; override;
      class function New(aParent : iBoleto4D) : iBoleto4DAttributesTitulo;
      function NovoTitulo : iBoleto4DAttributesTitulo;
      function Vencimento ( aValue : TDate ) : iBoleto4DAttributesTitulo; overload;
      function Vencimento : TDate; overload;
      function DataDocumento ( aValue : TDate ) : iBoleto4DAttributesTitulo; overload;
      function DataDocumento : TDate; overload;
      function NumeroDocumento ( aValue : String ) : iBoleto4DAttributesTitulo; overload;
      function NumeroDocumento : String; overload;
      function EspecieDoc ( aValue : String ) : iBoleto4DAttributesTitulo; overload;
      function EspecieDoc : String; overload;
      function Aceite ( aValue : Integer ) : iBoleto4DAttributesTitulo; overload;
      function Aceite : Integer; overload;
      function DataProcessamento ( aValue : TDate ) : iBoleto4DAttributesTitulo; overload;
      function DataProcessamento : TDate; overload;
      function Carteira ( aValue : String ) : iBoleto4DAttributesTitulo; overload;
      function Carteira : String; overload;
      function NossoNumero ( aValue : String ) : iBoleto4DAttributesTitulo; overload;
      function NossoNumero : String; overload;
      function ValorDocumento ( aValue : Currency ) : iBoleto4DAttributesTitulo; overload;
      function ValorDocumento : Currency; overload;
      function ValorAbatimento ( aValue : Currency ) : iBoleto4DAttributesTitulo; overload;
      function ValorAbatimento : Currency; overload;
      function LocalPagamento ( aValue : String ) : iBoleto4DAttributesTitulo; overload;
      function LocalPagamento : String; overload;
      function ValorMoraJuros ( aValue : Currency ) : iBoleto4DAttributesTitulo; overload;
      function ValorMoraJuros : Currency; overload;
      function ValorDesconto ( aValue : Currency ) : iBoleto4DAttributesTitulo; overload;
      function ValorDesconto : Currency; overload;
      function DataMoraJuros ( aValue : TDate ) : iBoleto4DAttributesTitulo; overload;
      function DataMoraJuros : TDate; overload;
      function DataDesconto ( aValue : TDate ) : iBoleto4DAttributesTitulo; overload;
      function DataDesconto : TDate; overload;
      function DataAbatimento ( aValue : TDate ) : iBoleto4DAttributesTitulo; overload;
      function DataAbatimento : TDate; overload;
      function DataProtesto ( aValue : TDate ) : iBoleto4DAttributesTitulo; overload;
      function DataProtesto : TDate; overload;
      function PercentualMulta ( aValue : Currency ) : iBoleto4DAttributesTitulo; overload;
      function PercentualMulta : Currency; overload;
      function OcorrenciaOriginalTipo ( aValue : Integer ) : iBoleto4DAttributesTitulo; overload;
      function OcorrencuaOriginalTipo : Integer; overload;
      function Instrucao1 ( aValue : String ) : iBoleto4DAttributesTitulo; overload;
      function Instrucao1 : String; overload;
      function Instrucao2 ( aValue : String ) : iBoleto4DAttributesTitulo; overload;
      function Instrucao2 : String; overload;
      function QtdePagamentoParcial ( aValue : Integer ) : iBoleto4DAttributesTitulo; overload;
      function QtdePagamentoParcial : Integer; overload;
      function TipoPagamento ( aValue : Integer ) : iBoleto4DAttributesTitulo; overload;
      function TipoPagamento : Integer; overload;
      function PercentualMinPagamento ( aValue : Currency ) : iBoleto4DAttributesTitulo; overload;
      function PercentualMinPagamento : Currency; overload;
      function PercentualMaxPagamento ( aValue : Currency ) : iBoleto4DAttributesTitulo; overload;
      function PercentualMaxPagamento : Currency; overload;
      function ValorMinPagamento ( aValue : Currency ) : iBoleto4DAttributesTitulo; overload;
      function ValorMinPagamento : Currency; overload;
      function ValorMaxPagamento ( aValue : Currency ) : iBoleto4DAttributesTitulo; overload;
      function ValorMaxPagamento : Currency; overload;
      function Sacado : iBoleto4DAttributesTituloSacado;
      function &End : iBoleto4D;
  end;

implementation

uses
  Boleto4D.Attributes.Titulo.Sacado;

{ TModelServicesBoletoTitulo }

function TBoleto4DAttributesTitulo.&end : iBoleto4D;
begin
    Result := FParent;
end;

function TBoleto4DAttributesTitulo.Aceite: Integer;
begin
  Result := FAceite;
end;

function TBoleto4DAttributesTitulo.Aceite(
  aValue: Integer): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FAceite := aValue;
end;

function TBoleto4DAttributesTitulo.Carteira(
  aValue: String): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FCarteira := aValue;
end;

function TBoleto4DAttributesTitulo.Carteira: String;
begin
  Result := FCarteira;
end;

function TBoleto4DAttributesTitulo.EspecieDoc: String;
begin
  Result := FEspecieDoc;
end;

function TBoleto4DAttributesTitulo.EspecieDoc(
  aValue: String): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FEspecieDoc := aValue;
end;

function TBoleto4DAttributesTitulo.Instrucao1: String;
begin
  Result := FInstrucao1;
end;

function TBoleto4DAttributesTitulo.Instrucao1(
  aValue: String): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FInstrucao1 := aValue;
end;

function TBoleto4DAttributesTitulo.Instrucao2(
  aValue: String): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FInstrucao2 := aValue;
end;

function TBoleto4DAttributesTitulo.Instrucao2: String;
begin
  Result := FInstrucao2;
end;

function TBoleto4DAttributesTitulo.LocalPagamento(
  aValue: String): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FLocalPagamento := aValue;
end;

function TBoleto4DAttributesTitulo.LocalPagamento: String;
begin
  Result := FLocalPagamento;
end;

constructor TBoleto4DAttributesTitulo.Create(aParent : iBoleto4D);
begin
  FParent := aParent;
  FSacado := TBoleto4DAttributesTituloSacado.New(Self);
end;

function TBoleto4DAttributesTitulo.DataAbatimento(
  aValue: TDate): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FDataAbatimento := aValue;
end;

function TBoleto4DAttributesTitulo.DataAbatimento: TDate;
begin
  Result := FDataAbatimento;
end;

function TBoleto4DAttributesTitulo.DataDesconto: TDate;
begin
  Result := FDataDesconto;
end;

function TBoleto4DAttributesTitulo.DataDesconto(
  aValue: TDate): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FDataDesconto := aValue;
end;

function TBoleto4DAttributesTitulo.DataDocumento(
  aValue: TDate): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FDataDocumento := aValue;
end;

function TBoleto4DAttributesTitulo.DataDocumento: TDate;
begin
  Result := FDataDocumento;
end;

function TBoleto4DAttributesTitulo.DataMoraJuros(
  aValue: TDate): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FDataMoraJuros := aValue;
end;

function TBoleto4DAttributesTitulo.DataMoraJuros: TDate;
begin
  Result := FDataMoraJuros;
end;

function TBoleto4DAttributesTitulo.DataProcessamento: TDate;
begin
  Result := FDataProcessamento;
end;

function TBoleto4DAttributesTitulo.DataProcessamento(
  aValue: TDate): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FDataProcessamento := aValue;
end;

function TBoleto4DAttributesTitulo.DataProtesto: TDate;
begin
  Result := FDataProtesto;
end;

function TBoleto4DAttributesTitulo.DataProtesto(
  aValue: TDate): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FDataProtesto := aValue;
end;

destructor TBoleto4DAttributesTitulo.Destroy;
begin

  inherited;
end;

class function TBoleto4DAttributesTitulo.New(aParent : iBoleto4D): iBoleto4DAttributesTitulo;
begin
  Result := Self.Create(aParent);
end;

function TBoleto4DAttributesTitulo.NossoNumero: String;
begin
  Result := FNossoNumero;
end;

function TBoleto4DAttributesTitulo.NovoTitulo: iBoleto4DAttributesTitulo;
begin
  Result := Self;
end;

function TBoleto4DAttributesTitulo.NossoNumero(
  aValue: String): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FNossoNumero := aValue;
end;

function TBoleto4DAttributesTitulo.NumeroDocumento: String;
begin
  Result := FNumeroDocumento;
end;

function TBoleto4DAttributesTitulo.NumeroDocumento(
  aValue: String): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FNumeroDocumento := aValue;
end;

function TBoleto4DAttributesTitulo.OcorrenciaOriginalTipo(
  aValue: Integer): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FOcorrencuaOriginalTipo := aValue;
end;

function TBoleto4DAttributesTitulo.OcorrencuaOriginalTipo: Integer;
begin
  Result := FOcorrencuaOriginalTipo;
end;

function TBoleto4DAttributesTitulo.PercentualMaxPagamento: Currency;
begin
  Result := FPercentualMaxPagamento;
end;

function TBoleto4DAttributesTitulo.PercentualMaxPagamento(
  aValue: Currency): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FPercentualMaxPagamento := aValue;
end;

function TBoleto4DAttributesTitulo.PercentualMinPagamento(
  aValue: Currency): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FPercentualMinPagamento := aValue;
end;

function TBoleto4DAttributesTitulo.PercentualMinPagamento: Currency;
begin
  Result := FPercentualMinPagamento;
end;

function TBoleto4DAttributesTitulo.PercentualMulta: Currency;
begin
  Result := FPercentualMulta;
end;

function TBoleto4DAttributesTitulo.PercentualMulta(
  aValue: Currency): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FPercentualMulta := aValue;
end;

function TBoleto4DAttributesTitulo.QtdePagamentoParcial: Integer;
begin
  Result := FQtdePagamentoParcial;
end;

function TBoleto4DAttributesTitulo.Sacado: iBoleto4DAttributesTituloSacado;
begin
  Result := FSacado;
end;

function TBoleto4DAttributesTitulo.QtdePagamentoParcial(
  aValue: Integer): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FQtdePagamentoParcial := aValue;
end;

function TBoleto4DAttributesTitulo.TipoPagamento(
  aValue: Integer): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FTipoPagamento := aValue;
end;

function TBoleto4DAttributesTitulo.TipoPagamento: Integer;
begin
  Result := FTipoPagamento;
end;

function TBoleto4DAttributesTitulo.ValorAbatimento(
  aValue: Currency): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FValorAbatimento := aValue;
end;

function TBoleto4DAttributesTitulo.ValorAbatimento: Currency;
begin
  Result := FValorAbatimento;
end;

function TBoleto4DAttributesTitulo.ValorDesconto: Currency;
begin
  Result := FValorDesconto;
end;

function TBoleto4DAttributesTitulo.ValorDesconto(
  aValue: Currency): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FValorDesconto := aValue;
end;

function TBoleto4DAttributesTitulo.ValorDocumento: Currency;
begin
  Result := FValorDocumento;
end;

function TBoleto4DAttributesTitulo.ValorDocumento(
  aValue: Currency): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FValorDocumento := aValue;
end;

function TBoleto4DAttributesTitulo.ValorMaxPagamento(
  aValue: Currency): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FValorMaxPagamento := aValue;
end;

function TBoleto4DAttributesTitulo.ValorMaxPagamento: Currency;
begin
  Result := FValorMaxPagamento;
end;

function TBoleto4DAttributesTitulo.ValorMinPagamento(
  aValue: Currency): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FValorMinPagamento := aValue;
end;

function TBoleto4DAttributesTitulo.ValorMinPagamento: Currency;
begin
  Result := FValorMinPagamento;
end;

function TBoleto4DAttributesTitulo.ValorMoraJuros(
  aValue: Currency): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FValorMoraJuros := aValue;
end;

function TBoleto4DAttributesTitulo.ValorMoraJuros: Currency;
begin
  Result := FValorMoraJuros;
end;

function TBoleto4DAttributesTitulo.Vencimento: TDate;
begin
  Result := FVencimento;
end;

function TBoleto4DAttributesTitulo.Vencimento(
  aValue: TDate): iBoleto4DAttributesTitulo;
begin
  Result := Self;
  FVencimento := aValue;
end;

end.
