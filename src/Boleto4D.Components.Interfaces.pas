unit Boleto4D.Components.Interfaces;

interface

uses
  ACBrBoleto,
  ACBrBoletoFCFortesFr,
  Boleto4D.Interfaces;

type
  iBoleto4DComponent = interface
    ['{B206DD12-4D59-48BA-A4D8-C739C8354D8A}']
    function CriarTitulo ( aValue : iBoleto4D) : iBoleto4DComponent;
    function EnviarBoleto : iBoleto4DComponent;
    function GerarHTML : String;
    function GerarPDF : iBoleto4DComponent;
    function GerarRemessa ( aValue : Integer ) : iBoleto4DComponent;
    function LerConfiguracoes ( aValue : iBoleto4D ) : iBoleto4DComponent;
    function NomeArquivo : String;
    function NomeArquivoRemessa ( aValue : String ) : iBoleto4DComponent; overload;
    function NomeArquivoRemessa : String; overload;
    function RetornoWeb : String;
  end;

implementation

end.
