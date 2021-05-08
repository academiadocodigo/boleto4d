unit Boleto4D.Interfaces;

interface

type
  iBoleto4D = interface;
  iBoleto4DAttributesReport = interface;
  iBoleto4DAttributesReportConfig = interface;
  iBoleto4DAttributesBanco = interface;
  iBoleto4DAttributesCedente = interface;
  iBoleto4DAttributesConfig = interface;
  iBoleto4DAttributesConfigWebService = interface;
  iBoleto4DAttributesCedenteWebService = interface;
  iBoleto4DAttributesTitulo = interface;
  iBoleto4DAttributesTituloSacado = interface;

  iBoleto4D = interface
    ['{FF62CEE5-6214-466B-8E91-CA5596C6C942}']
    function Report : iBoleto4DAttributesReport;
    function Banco : iBoleto4DAttributesBanco;
    function Cedente : iBoleto4DAttributesCedente;
    function Config : iBoleto4DAttributesConfig;
    function Titulo : iBoleto4DAttributesTitulo;
    function GerarPDF : iBoleto4D;
    function GerarRemessa( aValue : Integer ) : iBoleto4D;
    function EnviarBoleto : iBoleto4D;
    function Retorno : String;
    function NomeArquivo : String;

  end;

  iBoleto4DAttributesConfig = interface
    ['{2428D847-151B-4D31-B8D0-7B9D3ACA70D2}']
    function DirArqRemessa ( aValue : String ) : iBoleto4DAttributesConfig; overload;
    function DirArqRemessa : String; overload;
    function NomeArquivoRemessa : String; overload;
    function NomeArquivoRemessa ( aValue : String ) : iBoleto4DAttributesConfig; overload;
    function LayoutRemessa (aValue : Integer ) : iBoleto4DAttributesConfig; overload;
    function LayoutRemessa : Integer; overload;
    function WebService : iBoleto4DAttributesConfigWebService;
    function &End : iBoleto4D;
  end;

  iBoleto4DAttributesConfigWebService = interface
    ['{59860C2B-4AD4-4596-B39A-B71C291D305D}']
    function Ambiente (aValue : Integer ) : iBoleto4DAttributesConfigWebService; overload;
    function Ambiente : Integer; overload;
    function Operacao (aValue : Integer ) : iBoleto4DAttributesConfigWebService; overload;
    function Operacao : Integer; overload;
    function SSLCryptLib ( aValue : Integer ) : iBoleto4DAttributesConfigWebService; overload;
    function SSLCryptLib : Integer; overload;
    function SSLHttpLib ( aValue : Integer ) : iBoleto4DAttributesConfigWebService; overload;
    function SSLHttpLib : Integer; overload;
    function SSLType ( aValue : Integer ) : iBoleto4DAttributesConfigWebService; overload;
    function SSLType : Integer; overload;
    function StoreName ( aValue : String ) : iBoleto4DAttributesConfigWebService; overload;
    function StoreName : String; overload;
    function TimeOut ( aValue : Integer ) : iBoleto4DAttributesConfigWebService; overload;
    function TimeOut : Integer; overload;
    function UseCertificateHTTP ( aValue : Boolean ) : iBoleto4DAttributesConfigWebService; overload;
    function UseCertificateHTTP : Boolean; overload;
    function VersaoDF ( aValue : String ) : iBoleto4DAttributesConfigWebService; overload;
    function VersaoDF : String; overload;
    function &End : iBoleto4DAttributesConfig;
  end;

  iBoleto4DAttributesCedente = interface
    ['{9BFB728D-1588-4C70-9A69-32D6EC64807B}']
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
    function WebService : iBoleto4DAttributesCedenteWebService;
    function &End : iBoleto4D;
  end;

  iBoleto4DAttributesCedenteWebService = interface
    ['{C4BA2D57-60B0-48CA-A396-711C77D725B7}']
    function ClientID( aValue : String ) : iBoleto4DAttributesCedenteWebService; overload;
    function ClientID : String; overload;
    function ClientSecret ( aValue : String ) : iBoleto4DAttributesCedenteWebService; overload;
    function ClientSecret : String; overload;
    function Scope ( aValue : String ) : iBoleto4DAttributesCedenteWebService; overload;
    function Scope : String; overload;
    function KeyUser ( aValue : String ) : iBoleto4DAttributesCedenteWebService; overload;
    function KeyUser : String; overload;
    function &End : iBoleto4DAttributesCedente;
  end;

  iBoleto4DAttributesBanco = interface
    ['{AB8F5020-DD15-4609-8B03-99F46428AFC4}']
    function Numero ( aValue : Integer ) : iBoleto4DAttributesBanco; overload;
    function Numero : Integer; overload;
    function TipoCobranca ( aValue : Integer ) : iBoleto4DAttributesBanco; overload;
    function TipoCobranca : Integer; overload;
    function &End : iBoleto4D;
  end;

  iBoleto4DAttributesReport = interface
    ['{53A5D80C-4361-486A-8E84-F5ADB95CA522}']
    function Config : iBoleto4DAttributesReportConfig;
    function &End : iBoleto4D;
  end;

  iBoleto4DAttributesReportConfig = interface
    ['{D42B1D40-EB9C-4DDB-8430-3109251BB590}']
    function &End : iBoleto4DAttributesReport;
    function DirLogo (aValue : String ) : iBoleto4DAttributesReportConfig; overload;
    function DirLogo : String; overload;
    function MostrarSetup ( aValue : Boolean ) : iBoleto4DAttributesReportConfig; overload;
    function MostrarSetup : Boolean; overload;
    function MostrarPreview ( aValue : Boolean ) : iBoleto4DAttributesReportConfig; overload;
    function MostrarPreview : Boolean; overload;
    function MostrarProgresso ( aValue : Boolean ) : iBoleto4DAttributesReportConfig; overload;
    function MostrarProgresso : Boolean; overload;
    function NomeArquivo( aValue : String ) : iBoleto4DAttributesReportConfig; overload;
    function NomeArquivo : String; overload;
    function SoftwareHouse ( aValue : String ) : iBoleto4DAttributesReportConfig; overload;
    function SoftwareHouse : String; overload;
  end;

  iBoleto4DAttributesTitulo = interface
    ['{73A82698-C6CD-457F-A116-0B900453C751}']
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

  iBoleto4DAttributesTituloSacado = interface
    ['{A469F397-539A-42ED-BDDB-01DBAF902C0E}']
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

end.
