{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Andr� Ferreira de Moraes                        }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
{       Rua Coronel Aureliano de Camargo, 963 - Tatu� - SP - 18270-170         }
{******************************************************************************}

{$I ACBr.inc}

unit ACBrDFeCapicom;

interface

uses
  Classes, SysUtils,
  ACBrDFeSSL, ACBrDFeWinCrypt,
  ACBrCAPICOM_TLB,
  Windows, ActiveX, ComObj;

type
  { TDFeCapicom }

  TDFeCapicom = class(TDFeWinCrypt)
  private
    FCertificado: ICertificate2;
    FCertStoreMem: IStore3;

    function GetCNPJFromExtensions: String;
  protected
    procedure CarregarCertificadoDeArquivoPFX; override;
    procedure CarregarCertificadoDeNumeroSerie; override;
    procedure LerInfoCertificadoCarregado; override;
  public
    constructor Create(ADFeSSL: TDFeSSL); override;
    destructor Destroy; override;

    function SelecionarCertificado: String; override;
    procedure DescarregarCertificado; override;

    property Certificado: ICertificate2 read FCertificado;
    property Store: IStore3 read FCertStoreMem;
  end;

implementation

uses
  typinfo,
  ACBrUtil, ACBrDFeException;

{ TDFeCapicom }

constructor TDFeCapicom.Create(ADFeSSL: TDFeSSL);
begin
  inherited Create(ADFeSSL);
  FCertificado := nil;
  FCertStoreMem := nil;
  FpStore := nil;
end;

destructor TDFeCapicom.Destroy;
begin
  DescarregarCertificado;

  inherited Destroy;
end;

function TDFeCapicom.SelecionarCertificado: String;
var
  Store_temp: IStore3;
  Certs: ICertificates2;
  Certs2: ICertificates2;
  Cert: ICertificate2;
begin
  Store_temp := CoStore.Create;
  Store_temp.Open(Integer(FpDFeSSL.StoreLocation), WideString(FpDFeSSL.StoreName), CAPICOM_STORE_OPEN_READ_ONLY);

  Certs := Store_temp.Certificates as ICertificates2;
  Certs2 := Certs.Select('Certificado(s) Digital(is) dispon�vel(is)',
    'Selecione o Certificado Digital para uso no aplicativo', False);

  if (Certs2.Count > 0) then
  begin
    Cert := IInterface(Certs2.Item[1]) as ICertificate2;
    FpDFeSSL.NumeroSerie := String(Cert.SerialNumber);
    CarregarCertificado;
    Result := FpDadosCertificado.NumeroSerie;
  end
  else
    Result := '';
end;

procedure TDFeCapicom.DescarregarCertificado;
begin
  inherited DescarregarCertificado;

  FCertificado := nil;
  if Assigned(FCertStoreMem) then
    FCertStoreMem.Close;

  FCertStoreMem := Nil;
end;

function TDFeCapicom.GetCNPJFromExtensions: String;
var
  i, j, p: Integer;
  AExtension: IExtension;
  Propriedades, Propriedade: String;
  Lista: TStringList;
begin
  Result := '';
  i := 1;

  while (Result = '') and (i <= FCertificado.Extensions.Count) do
  begin
    AExtension := IInterface(FCertificado.Extensions.Item[i]) as IExtension;
    Propriedades := String(AExtension.EncodedData.Format(True));

    if (Pos('2.16.76.1.3.3', Propriedades) > 0) then
    begin
      Lista := TStringList.Create;
      try
        Lista.Text := Propriedades;
        for j := 0 to Lista.Count - 1 do
        begin
          Propriedade := Lista.Strings[j];
          if (Pos('2.16.76.1.3.3', Propriedade) > 0) then
          begin
            p := Pos('=', Propriedade);
            Propriedade := copy(Propriedade, p + 1, Length(Propriedade));
            Result := OnlyNumber(HexToAsciiDef(RemoveString(' ', Propriedade),' '));
            break;
          end;
        end;
      finally
        Lista.Free;
      end;
    end;

    AExtension := nil;
    Inc(i);
  end;
end;

procedure TDFeCapicom.CarregarCertificadoDeArquivoPFX;
var
  ResultInitialize: HRESULT;
  Inicializado: Boolean;
  KeyLocation: Integer;
begin
  inherited CarregarCertificadoDeArquivoPFX;

  ResultInitialize := CoInitialize(nil);
  if (ResultInitialize = E_FAIL) then
    raise EACBrDFeException.Create('Erro ao inicializar biblioteca COM');

  Inicializado := (ResultInitialize in [ S_OK, S_FALSE ]);
  try
    FCertificado := CoCertificate.Create;

    KeyLocation := CAPICOM_CURRENT_USER_KEY;
    if Integer(FpDFeSSL.StoreLocation) = CAPICOM_LOCAL_MACHINE_STORE then
      KeyLocation := CAPICOM_LOCAL_MACHINE_KEY;

    FCertificado.Load( WideString(FpDFeSSL.ArquivoPFX), WideString(FpDFeSSL.Senha),
                       CAPICOM_KEY_STORAGE_DEFAULT, KeyLocation);

  finally
    if Inicializado then
      CoUninitialize;
  end;
end;

procedure TDFeCapicom.CarregarCertificadoDeNumeroSerie;
var
  ResultInitialize: HRESULT;
  Inicializado: Boolean;
  Store_temp: IStore3;
  Certs: ICertificates2;
  Cert: ICertificate2;
  i: Integer;
begin
  inherited CarregarCertificadoDeNumeroSerie;

  ResultInitialize := CoInitialize(nil);
  if (ResultInitialize = E_FAIL) then
    raise EACBrDFeException.Create('Erro ao inicializar biblioteca COM');

  Inicializado := (ResultInitialize in [ S_OK, S_FALSE ]);
  try
    // Lendo lista de Certificados //
    Store_temp := CoStore.Create;
    try
      Store_temp.Open(Integer(FpDFeSSL.StoreLocation), WideString(FpDFeSSL.StoreName), CAPICOM_STORE_OPEN_READ_ONLY);
      FCertificado := nil;
      Certs := Store_temp.Certificates as ICertificates2;

      // Verificando se "FpDFeSSL.NumeroSerie" est� na lista de certificados encontrados //;
      for i := 1 to Certs.Count do
      begin
        Cert := IInterface(Certs.Item[i]) as ICertificate2;
        if String(Cert.SerialNumber) = FpDFeSSL.NumeroSerie then
        begin
          FCertificado := Cert;
          Break;
        end;
      end;
    finally
      Store_temp.Close;
    end;
  finally
    if Inicializado then
      CoUninitialize;
  end;
end;

procedure TDFeCapicom.LerInfoCertificadoCarregado;
begin
  // N�o Achou ? //
  if FCertificado = nil then
    raise EACBrDFeException.Create('Certificado Digital n�o Carregado!');

  // Salvando propriedades do Certificado //
  with FpDadosCertificado do
  begin
    NumeroSerie := String(FCertificado.SerialNumber);
    SubjectName := String(FCertificado.SubjectName);
    if CNPJ = '' then
      CNPJ := GetCNPJFromExtensions;

    DataVenc   := FCertificado.ValidToDate;
    IssuerName := String(FCertificado.IssuerName);
    if FCertificado.PrivateKey.IsHardwareDevice then
      Tipo := tpcA3
    else
      Tipo := tpcA1;
  end;

  // Criando mem�ria de Store de Certificados para o ACBr, e adicionado certificado lido nela //
  if FCertStoreMem = nil then
  begin
    FCertStoreMem := CoStore.Create;
    FCertStoreMem.Open(CAPICOM_MEMORY_STORE, CACBR_STORE_NAME, CAPICOM_STORE_OPEN_READ_ONLY);
    FCertStoreMem.Add(FCertificado);
  end;
end;

end.

