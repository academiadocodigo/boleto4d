unit Boleto4D.Attributes.Cedente.WebService;

interface

uses
  Boleto4D.Interfaces;

type
  TBoleto4DAttributesCedenteWebService = class(TInterfacedObject, iBoleto4DAttributesCedenteWebService)
    private
      [weak]
      FParent : iBoleto4DAttributesCedente;
      FClientID : String;
      FClientSecret : String;
      FScope : String;
      FKeyUser : String;
    public
      constructor Create(aParent : iBoleto4DAttributesCedente);
      destructor Destroy; override;
      class function New(aParent : iBoleto4DAttributesCedente) : iBoleto4DAttributesCedenteWebService;
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

implementation

{ TModelServicesBoletoCedenteWebService }

function TBoleto4DAttributesCedenteWebService.&end : iBoleto4DAttributesCedente;
begin
    Result := FParent;
end;

function TBoleto4DAttributesCedenteWebService.ClientID(
  aValue: String): iBoleto4DAttributesCedenteWebService;
begin
  Result := Self;
  FClientID := aValue;
end;

function TBoleto4DAttributesCedenteWebService.ClientID: String;
begin
  Result := FClientID;
end;

function TBoleto4DAttributesCedenteWebService.ClientSecret(
  aValue: String): iBoleto4DAttributesCedenteWebService;
begin
  Result := Self;
  FClientSecret := aValue;
end;

function TBoleto4DAttributesCedenteWebService.ClientSecret: String;
begin
  Result := FClientSecret;
end;

function TBoleto4DAttributesCedenteWebService.KeyUser: String;
begin
  Result := FKeyUser;
end;

function TBoleto4DAttributesCedenteWebService.KeyUser(
  aValue: String): iBoleto4DAttributesCedenteWebService;
begin
  Result := Self;
  FKeyUser := aValue;
end;

constructor TBoleto4DAttributesCedenteWebService.Create(aParent : iBoleto4DAttributesCedente);
begin
  FParent := aParent;
end;

destructor TBoleto4DAttributesCedenteWebService.Destroy;
begin

  inherited;
end;

class function TBoleto4DAttributesCedenteWebService.New(aParent : iBoleto4DAttributesCedente): iBoleto4DAttributesCedenteWebService;
begin
  Result := Self.Create(aParent);
end;

function TBoleto4DAttributesCedenteWebService.Scope(
  aValue: String): iBoleto4DAttributesCedenteWebService;
begin
  Result := Self;
  FScope := aValue;
end;

function TBoleto4DAttributesCedenteWebService.Scope: String;
begin
  Result := FScope;
end;

end.
