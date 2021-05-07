{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:  Andr� Ferreira de Moraes                       }
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

unit ACBrDFeHttpWinApi;

interface

uses
  Classes, SysUtils,
  ACBrDFeSSL, ACBrWinReqRespClass, ACBrWinHTTPReqResp, ACBrWinINetReqResp;

type

  { TDFeHttpWinHttp }

  TDFeHttpWinHttp = class(TDFeSSLHttpClass)
  private
    FWinHTTPReqResp: TACBrWinReqResp;

  protected
    procedure ConfigConnection; override;
    function GetLastErrorDesc: String; override;

  public
    constructor Create(ADFeSSL: TDFeSSL); override;
    destructor Destroy; override;

    procedure Execute; override;
    procedure Abortar; override;
  end;


implementation

uses
  typinfo,
  ACBrDFeException, ACBrConsts,
  synautil;

{ TDFeHttpWinHttp }

constructor TDFeHttpWinHttp.Create(ADFeSSL: TDFeSSL);
begin
  inherited Create(ADFeSSL);

  if ADFeSSL.SSLHttpLib = httpWinINet then
    FWinHTTPReqResp := TACBrWinINetReqResp.Create
  else
    FWinHTTPReqResp := TACBrWinHTTPReqResp.Create;
end;

destructor TDFeHttpWinHttp.Destroy;
begin
  FWinHTTPReqResp.Free;
  inherited Destroy;
end;

procedure TDFeHttpWinHttp.Execute;
begin
  inherited;

  // Enviando, dispara exceptions no caso de erro //
  try
    FWinHTTPReqResp.Execute(DataResp);
    HeaderResp.Text := FWinHTTPReqResp.HeaderResp.Text;
  finally
    FpHTTPResultCode := FWinHTTPReqResp.HttpResultCode;
    FpInternalErrorCode := FWinHTTPReqResp.InternalErrorCode;
  end;

  // DEBUG //
  //DataResp.SaveToFile('c:\temp\ReqResp.xml');
end;

procedure TDFeHttpWinHttp.Abortar;
begin
  FWinHTTPReqResp.Abortar;
end;

procedure TDFeHttpWinHttp.ConfigConnection;
begin
  inherited;

  FWinHTTPReqResp.Clear;

  // Proxy //
  FWinHTTPReqResp.ProxyHost := FpDFeSSL.ProxyHost;
  FWinHTTPReqResp.ProxyPort := FpDFeSSL.ProxyPort;
  FWinHTTPReqResp.ProxyUser := FpDFeSSL.ProxyUser;
  FWinHTTPReqResp.ProxyPass := FpDFeSSL.ProxyPass;

  // Header //
  FWinHTTPReqResp.Url := URL;
  FWinHTTPReqResp.Method := Method;
  FWinHTTPReqResp.MimeType := MimeType;
  FWinHTTPReqResp.SOAPAction := SoapAction;
  if HeaderReq.Count > 0 then
    FWinHTTPReqResp.HeaderReq.AddStrings(HeaderReq);

  // SSL e Certificado //
  if FpDFeSSL.UseCertificateHTTP then
    FWinHTTPReqResp.CertContext := FpDFeSSL.CertContextWinApi
  else
    FWinHTTPReqResp.CertContext := Nil;

  FWinHTTPReqResp.SSLType := FpDFeSSL.SSLType;

  // TimeOut //
  FWinHTTPReqResp.TimeOut := FpDFeSSL.TimeOut;

  // Document //
  if (DataReq.Size > 0) then
  begin
    DataReq.Position := 0;
    FWinHTTPReqResp.Data := ReadStrFromStream(DataReq, DataReq.Size);
  end;
end;

function TDFeHttpWinHttp.GetLastErrorDesc: String;
begin
  Result := FWinHTTPReqResp.GetWinInetError(FpInternalErrorCode);
end;

end.

