unit Boleto4D.Components.Interfaces;

interface

uses
  ACBrBoleto,
  ACBrBoletoFCFortesFr,
  Boleto4D.Interfaces;

type
  iBoleto4DComponent = interface
    ['{B206DD12-4D59-48BA-A4D8-C739C8354D8A}']
    function LerConfiguracoes ( aValue : iBoleto4D ) : iBoleto4DComponent;
    function CriarTitulo ( aValue : iBoleto4D) : iBoleto4DComponent;
    function GerarPDF : iBoleto4DComponent;
    function GerarHTML : String;
    function EnviarBoleto : iBoleto4DComponent;
    function RetornoWeb : String;
    function NomeArquivo : String;
  end;

implementation

end.
