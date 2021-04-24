unit Boleto4D.Attributes.Report.Config;

interface

uses
  Boleto4D.Interfaces;

type
  TBoleto4DAttributesReportConfig = class(TInterfacedObject, iBoleto4DAttributesReportConfig)
    private
      [weak]
      FParent : iBoleto4DAttributesReport;
      FDirLogo : String;
      FMostrarSetup : Boolean;
      FMostrarPreview : Boolean;
      FMostrarProgresso : Boolean;
      FNomeArquivo : String;
      FSoftwareHouse : String;
    public
      constructor Create(aParent : iBoleto4DAttributesReport);
      destructor Destroy; override;
      class function New(aParent : iBoleto4DAttributesReport) : iBoleto4DAttributesReportConfig;
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

implementation

{ TModelServicesBoletoReportConfig }

function TBoleto4DAttributesReportConfig.&end : iBoleto4DAttributesReport;
begin
    Result := FParent;
end;

function TBoleto4DAttributesReportConfig.MostrarPreview(
  aValue: Boolean): iBoleto4DAttributesReportConfig;
begin
  Result := Self;
  FMostrarPreview := aValue;
end;

function TBoleto4DAttributesReportConfig.MostrarPreview: Boolean;
begin
  Result := FMostrarPreview;
end;

function TBoleto4DAttributesReportConfig.MostrarProgresso: Boolean;
begin
  Result := FMostrarProgresso;
end;

function TBoleto4DAttributesReportConfig.MostrarProgresso(
  aValue: Boolean): iBoleto4DAttributesReportConfig;
begin
  Result := Self;
  FMostrarProgresso := aValue;
end;

function TBoleto4DAttributesReportConfig.MostrarSetup(
  aValue: Boolean): iBoleto4DAttributesReportConfig;
begin
  Result := Self;
  FMostrarSetup := aValue;
end;

function TBoleto4DAttributesReportConfig.MostrarSetup: Boolean;
begin
  Result := FMostrarSetup;
end;

constructor TBoleto4DAttributesReportConfig.Create(aParent : iBoleto4DAttributesReport);
begin
  FParent := aParent;
end;

destructor TBoleto4DAttributesReportConfig.Destroy;
begin

  inherited;
end;

function TBoleto4DAttributesReportConfig.DirLogo(
  aValue: String): iBoleto4DAttributesReportConfig;
begin
  Result := Self;
  FDirLogo := aValue;
end;

function TBoleto4DAttributesReportConfig.DirLogo: String;
begin
  Result := FDirLogo;
end;

class function TBoleto4DAttributesReportConfig.New(aParent : iBoleto4DAttributesReport): iBoleto4DAttributesReportConfig;
begin
  Result := Self.Create(aParent);
end;

function TBoleto4DAttributesReportConfig.NomeArquivo: String;
begin
  Result := FNomeArquivo;
end;

function TBoleto4DAttributesReportConfig.NomeArquivo(
  aValue: String): iBoleto4DAttributesReportConfig;
begin
  Result := Self;
  FNomeArquivo := aValue;
end;

function TBoleto4DAttributesReportConfig.SoftwareHouse: String;
begin
  Result := FSoftwareHouse;
end;

function TBoleto4DAttributesReportConfig.SoftwareHouse(
  aValue: String): iBoleto4DAttributesReportConfig;
begin
  Result := Self;
  FSoftwareHouse := aValue;
end;

end.
