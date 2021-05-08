unit Boleto4D;

interface

uses
  Boleto4D.Interfaces,
  Boleto4D.Components.Interfaces;

type
  TBoleto4D = class(TInterfacedObject, iBoleto4D)
    private
      FReport : iBoleto4DAttributesReport;
      FBanco : iBoleto4DAttributesBanco;
      FCedente : iBoleto4DAttributesCedente;
      FConfig : iBoleto4DAttributesConfig;
      FTitulo : iBoleto4DAttributesTitulo;
      FComponent : iBoleto4DComponent;
    public
      constructor Create;
      destructor Destroy; override;
      class function New : iBoleto4D;
      function Banco : iBoleto4DAttributesBanco;
      function Cedente : iBoleto4DAttributesCedente;
      function Config : iBoleto4DAttributesConfig;
      function Report : iBoleto4DAttributesReport;
      function Titulo : iBoleto4DAttributesTitulo;
      function GerarPDF : iBoleto4D;
      function GerarRemessa( aValue : Integer ) : iBoleto4D;
      function EnviarBoleto : iBoleto4D;
      function Retorno : String;
      function NomeArquivo : String;
  end;

var
  _Boleto4D : TBoleto4D;

implementation

uses
  Boleto4D.Attributes.Report,
  Boleto4D.Attributes.Banco,
  Boleto4D.Attributes.Cedente,
  Boleto4D.Attributes.Config,
  Boleto4D.Attributes.Titulo,
  Boleto4D.Components.ACBrBoleto;

{ TModelServicesBoleto }

function TBoleto4D.EnviarBoleto: iBoleto4D;
begin
  Result := Self;
  FComponent.EnviarBoleto;
end;

function TBoleto4D.GerarPDF: iBoleto4D;
begin
  Result := Self;
  FComponent.LerConfiguracoes(Self);
  FComponent.CriarTitulo(Self);
  FComponent.GerarPDF;
end;

function TBoleto4D.GerarRemessa(aValue: Integer): iBoleto4D;
begin
  Result := Self;
  FComponent.GerarRemessa(aValue);
end;

function TBoleto4D.Banco: iBoleto4DAttributesBanco;
begin
  Result := FBanco;
end;

function TBoleto4D.Cedente: iBoleto4DAttributesCedente;
begin
  Result := FCedente;
end;

function TBoleto4D.Config: iBoleto4DAttributesConfig;
begin
  Result := FConfig;
end;

constructor TBoleto4D.Create;
begin
  FReport := TBoleto4DAttributesReport.New(Self);
  FBanco := TBoleto4DAttributesBanco.New(Self);
  FCedente := TBoleto4DAttributesCedente.New(Self);
  FConfig := TBoleto4DAttributesConfig.New(Self);
  FTitulo := TBoleto4DAttributesTitulo.New(Self);
  FComponent := TBoleto4DComponentsACBrBoleto.New;
end;

destructor TBoleto4D.Destroy;
begin

  inherited;
end;

class function TBoleto4D.New: iBoleto4D;
begin
  if not Assigned(_Boleto4D) then
    _Boleto4D := Self.Create;

  Result := _Boleto4D;
end;

function TBoleto4D.NomeArquivo: String;
begin
  Result := FComponent.NomeArquivo;
end;

function TBoleto4D.Report: iBoleto4DAttributesReport;
begin
  Result := FReport;
end;

function TBoleto4D.Retorno: String;
begin
  Result := FComponent.RetornoWeb;
end;

function TBoleto4D.Titulo: iBoleto4DAttributesTitulo;
begin
  Result := FTitulo;
end;

end.
