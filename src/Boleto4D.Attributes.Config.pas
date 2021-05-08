unit Boleto4D.Attributes.Config;

interface

uses
  Boleto4D.Interfaces;

type
  TBoleto4DAttributesConfig = class(TInterfacedObject, iBoleto4DAttributesConfig)
    private
      [weak]
      FParent : iBoleto4D;
      FLayoutRemessa : Integer;
      FWebService : iBoleto4DAttributesConfigWebService;
      FDirArqRemessa : String;
      FNomeArqRemessa : String;
    public
      constructor Create(aParent : iBoleto4D);
      destructor Destroy; override;
      class function New(aParent : iBoleto4D) : iBoleto4DAttributesConfig;
      function DirArqRemessa ( aValue : String ) : iBoleto4DAttributesConfig; overload;
      function DirArqRemessa : String; overload;
      function LayoutRemessa (aValue : Integer ) : iBoleto4DAttributesConfig; overload;
      function LayoutRemessa : Integer; overload;
      function NomeArquivoRemessa : String; overload;
      function NomeArquivoRemessa ( aValue : String ) : iBoleto4DAttributesConfig; overload;
      function WebService : iBoleto4DAttributesConfigWebService;
      function &End : iBoleto4D;
  end;

implementation

uses
  Boleto4D.Attributes.Config.WebService;

{ TModelServicesBoletoConfig }

function TBoleto4DAttributesConfig.&end : iBoleto4D;
begin
    Result := FParent;
end;

function TBoleto4DAttributesConfig.LayoutRemessa: Integer;
begin
  Result := FLayoutRemessa;
end;

function TBoleto4DAttributesConfig.LayoutRemessa(
  aValue: Integer): iBoleto4DAttributesConfig;
begin
  Result := Self;
  FLayoutRemessa := aValue;
end;

constructor TBoleto4DAttributesConfig.Create(aParent : iBoleto4D);
begin
  FParent := aParent;
  FWebService := TBoleto4DAttributesConfigWebService.New(Self);
end;

destructor TBoleto4DAttributesConfig.Destroy;
begin

  inherited;
end;

function TBoleto4DAttributesConfig.DirArqRemessa: String;
begin
  Result := FDirArqRemessa;
end;

function TBoleto4DAttributesConfig.DirArqRemessa(
  aValue: String): iBoleto4DAttributesConfig;
begin
  Result := Self;
  FDirArqRemessa := aValue;
end;

class function TBoleto4DAttributesConfig.New(aParent : iBoleto4D): iBoleto4DAttributesConfig;
begin
  Result := Self.Create(aParent);
end;

function TBoleto4DAttributesConfig.NomeArquivoRemessa(
  aValue: String): iBoleto4DAttributesConfig;
begin
  Result := Self;
  FNomeArqRemessa := aValue;
end;

function TBoleto4DAttributesConfig.NomeArquivoRemessa: String;
begin
  Result := FNomeArqRemessa;
end;

function TBoleto4DAttributesConfig.WebService: iBoleto4DAttributesConfigWebService;
begin
  Result := FWebService;
end;

end.
