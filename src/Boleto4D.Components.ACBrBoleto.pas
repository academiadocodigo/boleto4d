unit Boleto4D.Components.ACBrBoleto;

interface

uses
  ACBrBoleto,
  ACBrBoletoFCFortesFr,
  Boleto4D.Components.Interfaces,
  Boleto4D.Interfaces;

type
  TBoleto4DComponentsACBrBoleto = class(TInterfacedObject, iBoleto4DComponent)
    private
      FComponent : TACBrBoleto;
      FReport : TACBrBoletoFCFortes;
      FTitulo : TACBrTitulo;
    public
      constructor Create;
      destructor Destroy; override;
      class function New : iBoleto4DComponent;
      function CriarTitulo ( aValue : iBoleto4D) : iBoleto4DComponent;
      function EnviarBoleto : iBoleto4DComponent;
      function GerarHTML : String;
      function GerarPDF : iBoleto4DComponent;
      function GerarRemessa ( aValue : Integer ) : iBoleto4DComponent;
      function LerConfiguracoes ( aValue : iBoleto4D ) : iBoleto4DComponent;
      function NomeArquivo : String;
      function NomeArquivoRemessa : String; overload;
      function NomeArquivoRemessa ( aValue : String ) : iBoleto4DComponent; overload;
      function RetornoWeb : String;
  end;

implementation

uses
  ACBrBoletoConversao, pcnConversao, ACBrDFeSSL, blcksock, REST.Json,
  System.AnsiStrings;

{ TComponentsACBrBoleto }

constructor TBoleto4DComponentsACBrBoleto.Create;
begin
  FComponent := TACBrBoleto.Create(nil);
  FReport := TACBrBoletoFCFortes.Create(nil);
  FComponent.ACBrBoletoFC := FReport;
  FReport.ACBrBoleto := FComponent;
end;

function TBoleto4DComponentsACBrBoleto.CriarTitulo( aValue : iBoleto4D) : iBoleto4DComponent;
begin
  Result := Self;
  FTitulo := FComponent.CriarTituloNaLista;
  FTitulo.Vencimento        := aValue.Titulo.Vencimento;
  FTitulo.DataDocumento     := aValue.Titulo.DataDocumento;
  FTitulo.NumeroDocumento   := aValue.Titulo.NumeroDocumento;
  FTitulo.EspecieDoc        := aValue.Titulo.EspecieDoc;
  FTitulo.Aceite            := TACBrAceiteTitulo(aValue.Titulo.Aceite);
  FTitulo.DataProcessamento := aValue.Titulo.DataProcessamento;
  FTitulo.Carteira          := aValue.Titulo.Carteira;
  FTitulo.NossoNumero       := aValue.Titulo.NossoNumero;
  FTitulo.ValorDocumento    := aValue.Titulo.ValorDocumento;
  FTitulo.ValorAbatimento   := aValue.Titulo.ValorAbatimento;
  FTitulo.LocalPagamento    := aValue.Titulo.LocalPagamento;
  FTitulo.ValorMoraJuros    := aValue.Titulo.ValorMoraJuros;
  FTitulo.ValorDesconto     := aValue.Titulo.ValorDesconto;
  FTitulo.DataMoraJuros     := aValue.Titulo.DataMoraJuros;
  FTitulo.DataDesconto      := aValue.Titulo.DataDesconto;
  FTitulo.DataAbatimento    := aValue.Titulo.DataAbatimento;
  FTitulo.DataProtesto      := aValue.Titulo.DataProtesto;
  FTitulo.PercentualMulta   := aValue.Titulo.PercentualMulta;
  FTitulo.OcorrenciaOriginal.Tipo := TACBrTipoOcorrencia(aValue.Titulo.OcorrencuaOriginalTipo);
  FTitulo.Instrucao1        := aValue.Titulo.Instrucao1;
  FTitulo.Instrucao2        := aValue.Titulo.Instrucao2;
  FTitulo.QtdePagamentoParcial := aValue.Titulo.QtdePagamentoParcial;
  FTitulo.TipoPagamento:= TTipo_Pagamento(aValue.Titulo.TipoPagamento);
  FTitulo.PercentualMinPagamento:= aValue.Titulo.PercentualMinPagamento;
  FTitulo.PercentualMaxPagamento:= aValue.Titulo.PercentualMaxPagamento;
  FTitulo.ValorMinPagamento:= aValue.Titulo.ValorMinPagamento;
  FTitulo.ValorMaxPagamento:= aValue.Titulo.ValorMaxPagamento;
  FTitulo.Sacado.NomeSacado := aValue.Titulo.Sacado.Nome;
  FTitulo.Sacado.CNPJCPF    := aValue.Titulo.Sacado.CNPJCPF;
  FTitulo.Sacado.Logradouro := aValue.Titulo.Sacado.Logradouro;
  FTitulo.Sacado.Numero     := aValue.Titulo.Sacado.Numero;
  FTitulo.Sacado.Bairro     := aValue.Titulo.Sacado.Bairro;
  FTitulo.Sacado.Cidade     := aValue.Titulo.Sacado.Cidade;
  FTitulo.Sacado.UF         := aValue.Titulo.Sacado.UF;
  FTitulo.Sacado.CEP        := aValue.Titulo.Sacado.CEP;
end;

destructor TBoleto4DComponentsACBrBoleto.Destroy;
begin
  FReport.DisposeOf;
  FComponent.DisposeOf;
  inherited;
end;

function TBoleto4DComponentsACBrBoleto.EnviarBoleto: iBoleto4DComponent;
begin
  Result := Self;
  FComponent.EnviarBoleto;
end;

function TBoleto4DComponentsACBrBoleto.GerarHTML: String;
begin
  //Result := FComponent.GerarHTML;
end;

function TBoleto4DComponentsACBrBoleto.GerarPDF: iBoleto4DComponent;
begin
  FComponent.GerarPDF;
end;

function TBoleto4DComponentsACBrBoleto.GerarRemessa(
  aValue: Integer): iBoleto4DComponent;
begin
  Result := Self;
  FComponent.GerarRemessa(aValue);
end;

function TBoleto4DComponentsACBrBoleto.LerConfiguracoes(
  aValue: iBoleto4D): iBoleto4DComponent;
begin
  Result := Self;
  FReport.DirLogo := aValue.Report.Config.DirLogo;
  FReport.MostrarSetup := aValue.Report.Config.MostrarSetup;
  FReport.MostrarPreview := aValue.Report.Config.MostrarPreview;
  FReport.MostrarProgresso := aValue.Report.Config.MostrarProgresso;
  FReport.NomeArquivo := aValue.Report.Config.NomeArquivo;
  FReport.SoftwareHouse := aValue.Report.Config.SoftwareHouse;
  FComponent.Banco.Numero := aValue.Banco.Numero;
  FComponent.Banco.TipoCobranca := TACBrTipoCobranca(aValue.Banco.TipoCobranca);
  FComponent.Cedente.Agencia := aValue.Cedente.Agencia;
  FComponent.Cedente.AgenciaDigito := aValue.Cedente.AgenciaDigito;
  FComponent.Cedente.CodigoCedente := aValue.Cedente.CodigoCedente;
  FComponent.Cedente.Conta := aValue.Cedente.Conta;
  FComponent.Cedente.ContaDigito := aValue.Cedente.ContaDigito;
  FComponent.Cedente.TipoInscricao := TACBrPessoaCedente(aValue.Cedente.TipoInscricao);
  FComponent.LayoutRemessa := TACBrLayoutRemessa(aValue.Config.LayoutRemessa);
  FComponent.DirArqRemessa := aValue.Config.DirArqRemessa;
  FComponent.Configuracoes.WebService.Ambiente := Tpcntipoambiente(aValue.Config.WebService.Ambiente);
  FComponent.Configuracoes.WebService.Operacao := TOperacao(aValue.Config.WebService.Operacao);
  FComponent.Configuracoes.WebService.SSLCryptLib := TSSLCryptLib(aValue.Config.WebService.SSLCryptLib);
  FComponent.Configuracoes.WebService.SSLHttpLib := TSSLHttpLib(aValue.Config.WebService.SSLHttpLib);
  FComponent.Configuracoes.WebService.SSLType := TSSLType(aValue.Config.WebService.SSLType);
  FComponent.Configuracoes.WebService.StoreName := aValue.Config.WebService.StoreName;
  FComponent.Configuracoes.WebService.TimeOut := aValue.Config.WebService.TimeOut;
  FComponent.Configuracoes.WebService.UseCertificateHTTP := aValue.Config.WebService.UseCertificateHTTP;
  FComponent.Configuracoes.WebService.VersaoDF := aValue.Config.WebService.VersaoDF;
  FComponent.Cedente.CedenteWS.ClientID:= aValue.Cedente.WebService.ClientID;
  FComponent.Cedente.CedenteWS.ClientSecret:= aValue.Cedente.WebService.ClientSecret;
  FComponent.Cedente.CedenteWS.Scope:= aValue.Cedente.WebService.Scope;
  FComponent.Cedente.CedenteWS.KeyUser:= aValue.Cedente.WebService.KeyUser;
  FComponent.Cedente.FantasiaCedente := aValue.Cedente.Fantasia;
  FComponent.Cedente.Nome := aValue.Cedente.Nome;
  FComponent.Cedente.CNPJCPF := aValue.Cedente.CNPJCPF;
  FComponent.Cedente.Logradouro := aValue.Cedente.Logradouro;
  FComponent.Cedente.Bairro := aValue.Cedente.Bairro;
  FComponent.Cedente.Cidade := aValue.Cedente.Cidade;
  FComponent.Cedente.CEP := aValue.Cedente.CEP;
  FComponent.Cedente.Telefone := aValue.Cedente.Telefone;
end;

class function TBoleto4DComponentsACBrBoleto.New: iBoleto4DComponent;
begin
  Result := Self.Create;
end;

function TBoleto4DComponentsACBrBoleto.NomeArquivo: String;
begin
  Result := FReport.NomeArquivo;
end;

function TBoleto4DComponentsACBrBoleto.NomeArquivoRemessa(
  aValue: String): iBoleto4DComponent;
begin
  Result := Self;
  FComponent.NomeArqRemessa := aValue;
end;

function TBoleto4DComponentsACBrBoleto.NomeArquivoRemessa: String;
begin
  Result := FComponent.NomeArqRemessa;
end;

function TBoleto4DComponentsACBrBoleto.RetornoWeb: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Pred(FComponent.ListaRetornoWeb.Count) do
    Result := Result + TJSON.ObjectToJsonstring(FComponent.ListaRetornoWeb.Objects[I]);
end;

end.
