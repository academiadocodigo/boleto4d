unit Boleto4D.Attributes.Report;

interface

uses
  Boleto4D.Interfaces;

type
  TBoleto4DAttributesReport = class(TInterfacedObject, iBoleto4DAttributesReport)
    private
      [weak]
      FParent : iBoleto4D;
      FConfig : iBoleto4DAttributesReportConfig;
    public
      constructor Create(aParent : iBoleto4D);
      destructor Destroy; override;
      class function New(aParent : iBoleto4D) : iBoleto4DAttributesReport;
      function Config : iBoleto4DAttributesReportConfig;
      function &End : iBoleto4D;
  end;

implementation

uses
  Boleto4D.Attributes.Report.Config;

{ TModelServicesBoletoReport }

function TBoleto4DAttributesReport.&end : iBoleto4D;
begin
    Result := FParent;
end;

function TBoleto4DAttributesReport.Config: iBoleto4DAttributesReportConfig;
begin
  Result := FConfig;
end;

constructor TBoleto4DAttributesReport.Create(aParent : iBoleto4D);
begin
  FParent := aParent;
  FConfig := TBoleto4DAttributesReportConfig.New(Self);
end;

destructor TBoleto4DAttributesReport.Destroy;
begin

  inherited;
end;

class function TBoleto4DAttributesReport.New(aParent : iBoleto4D): iBoleto4DAttributesReport;
begin
  Result := Self.Create(aParent);
end;

end.
