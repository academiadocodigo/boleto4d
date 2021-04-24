unit Boleto4D.Attributes.Config.WebService;

interface

uses
  Boleto4D.Interfaces;

type
  TBoleto4DAttributesConfigWebService = class(TInterfacedObject, iBoleto4DAttributesConfigWebService)
    private
      [weak]
      FParent : iBoleto4DAttributesConfig;
      FAmbiente : Integer;
      FOperacao : Integer;
      FSSLCryptLib : Integer;
      FSSLHttpLib : Integer;
      FSSLType : Integer;
      FStoreName : String;
      FTimeOut : Integer;
      FUseCertificateHTTP : Boolean;
      FVersaoDF : String;
    public
      constructor Create(aParent : iBoleto4DAttributesConfig);
      destructor Destroy; override;
      class function New(aParent : iBoleto4DAttributesConfig) : iBoleto4DAttributesConfigWebService;
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

implementation

{ TModelServicesBoletoConfigWebService }

function TBoleto4DAttributesConfigWebService.&end : iBoleto4DAttributesConfig;
begin
    Result := FParent;
end;

function TBoleto4DAttributesConfigWebService.Ambiente(
  aValue: Integer): iBoleto4DAttributesConfigWebService;
begin
  Result := Self;
  FAmbiente := aValue;
end;

function TBoleto4DAttributesConfigWebService.Ambiente: Integer;
begin
  Result := FAmbiente;
end;

constructor TBoleto4DAttributesConfigWebService.Create(aParent : iBoleto4DAttributesConfig);
begin
  FParent := aParent;
end;

destructor TBoleto4DAttributesConfigWebService.Destroy;
begin

  inherited;
end;

class function TBoleto4DAttributesConfigWebService.New(aParent : iBoleto4DAttributesConfig): iBoleto4DAttributesConfigWebService;
begin
  Result := Self.Create(aParent);
end;

function TBoleto4DAttributesConfigWebService.Operacao(
  aValue: Integer): iBoleto4DAttributesConfigWebService;
begin
  Result := Self;
  FOperacao := aValue;
end;

function TBoleto4DAttributesConfigWebService.Operacao: Integer;
begin
  Result := FOperacao;
end;

function TBoleto4DAttributesConfigWebService.SSLCryptLib: Integer;
begin
  Result := FSSLCryptLib;
end;

function TBoleto4DAttributesConfigWebService.SSLCryptLib(
  aValue: Integer): iBoleto4DAttributesConfigWebService;
begin
  Result := Self;
  FSSLCryptLib := aValue;
end;

function TBoleto4DAttributesConfigWebService.SSLHttpLib(
  aValue: Integer): iBoleto4DAttributesConfigWebService;
begin
  Result := Self;
  FSSLHttpLib := aValue;
end;

function TBoleto4DAttributesConfigWebService.SSLHttpLib: Integer;
begin
  Result := FSSLHttpLib;
end;

function TBoleto4DAttributesConfigWebService.SSLType: Integer;
begin
  Result := FSSLType;
end;

function TBoleto4DAttributesConfigWebService.SSLType(
  aValue: Integer): iBoleto4DAttributesConfigWebService;
begin
  Result := Self;
  FSSLType := aValue;
end;

function TBoleto4DAttributesConfigWebService.StoreName(
  aValue: String): iBoleto4DAttributesConfigWebService;
begin
  Result := Self;
  FStoreName := aValue;
end;

function TBoleto4DAttributesConfigWebService.StoreName: String;
begin
  Result := FStoreName;
end;

function TBoleto4DAttributesConfigWebService.TimeOut: Integer;
begin
  Result := FTimeOut;
end;

function TBoleto4DAttributesConfigWebService.TimeOut(
  aValue: Integer): iBoleto4DAttributesConfigWebService;
begin
  Result := Self;
  FTimeOut := aValue;
end;

function TBoleto4DAttributesConfigWebService.UseCertificateHTTP(
  aValue: Boolean): iBoleto4DAttributesConfigWebService;
begin
  Result := Self;
  FUseCertificateHTTP := aValue;
end;

function TBoleto4DAttributesConfigWebService.UseCertificateHTTP: Boolean;
begin
  Result := FUseCertificateHTTP;
end;

function TBoleto4DAttributesConfigWebService.VersaoDF(
  aValue: String): iBoleto4DAttributesConfigWebService;
begin
  Result := Self;
  FVersaoDF := aValue;
end;

function TBoleto4DAttributesConfigWebService.VersaoDF: String;
begin
  Result := FVersaoDF;
end;

end.
