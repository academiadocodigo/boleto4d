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

unit ACBrDFeHttpIndy;

interface

uses
  Classes, SysUtils,
  {$IF CompilerVersion >= 33}System.Net.HttpClient,{$IFEND}
  ACBrDFeSSL,
  SoapHTTPClient, SOAPHTTPTrans;

const
  INTERNET_OPTION_CLIENT_CERT_CONTEXT = 84;

type
  { TDFeDelphiSoap }

  { TDFeHttpIndy }

  TDFeHttpIndy = class(TDFeSSLHttpClass)
  private
    FIndyReqResp: THTTPReqResp;
    FMimeType: String;
  {$IF CompilerVersion >= 33}
    procedure OnBeforePost(const HTTPReqResp: THTTPReqResp; Client: THTTPClient);
  {$ELSE}
    procedure OnBeforePost(const HTTPReqResp: THTTPReqResp; ARequest: Pointer);
  {$IFEND}
  protected
    procedure ConfigConnection; override;

  public
    constructor Create(ADFeSSL: TDFeSSL); override;
    destructor Destroy; override;

    procedure Execute; override;
    procedure Abortar; override;
  end;

implementation

uses
  strutils, WinInet, SOAPConst,
  ACBr_WinCrypt, ACBrDFeException, ACBRConsts,
  synautil;

{ TDFeDelphiSoap }

constructor TDFeHttpIndy.Create(ADFeSSL: TDFeSSL);
begin
  inherited Create(ADFeSSL);

  FIndyReqResp := THTTPReqResp.Create(nil);
end;

destructor TDFeHttpIndy.Destroy;
begin
  FIndyReqResp.Free;

  inherited Destroy;
end;

procedure TDFeHttpIndy.Execute;
begin
  inherited;

  // Enviando, dispara exceptions no caso de erro //
  try
    DataReq.Position := 0;
    FIndyReqResp.Execute(DataReq, DataResp);
  finally
    FpInternalErrorCode := GetLastError;
    // Indy n�o tem mapeamento para HttpResultCode
    if DataResp.Size > 0 then
      FpHTTPResultCode := 200
    else
      FpHTTPResultCode := 0;
  end;

  // DEBUG //
  //DataResp.SaveToFile('c:\temp\ReqResp.xml');
end;

procedure TDFeHttpIndy.Abortar;
begin
  FreeAndNil( FIndyReqResp );
  FIndyReqResp := THTTPReqResp.Create(nil);
end;

procedure TDFeHttpIndy.ConfigConnection;
begin
  inherited;

  // Proxy //
  if (FpDFeSSL.ProxyHost <> '') then
  begin
    FIndyReqResp.Proxy := FpDFeSSL.ProxyHost + ':' + FpDFeSSL.ProxyPort;
    FIndyReqResp.UserName := FpDFeSSL.ProxyUser;
    FIndyReqResp.Password := FpDFeSSL.ProxyPass;
  end;

  // Header //
  FIndyReqResp.URL := URL;
  //FIndyReqResp.Method := Method;
  FIndyReqResp.UseUTF8InHeader := True;
  FMimeType := MimeType;
  FIndyReqResp.SoapAction := SoapAction;
  //Headers.Insert(0, UpperCase(Method) + ' ' + URL + ' HTTP/1.0');
  //if Headers.Count > 0 then
  //  FIndyReqResp.Headers.AddStrings(Headers);

  // SSL e Certificado //

  // TimeOut //
  FIndyReqResp.ConnectTimeout := FpDFeSSL.TimeOut;
  FIndyReqResp.ReceiveTimeout := FpDFeSSL.TimeOut;
  {$IF CompilerVersion < 33}
    //NOTA: N�o existe a propriedade SendTimeout em Soap.SOAPHTTPTrans (Delphi 10.3.1)
    //No Delphi 10.3 SendTimeout = ReceiveTimeout
    FIndyReqResp.SendTimeout := FpDFeSSL.TimeOut;
  {$IFEND}

  FIndyReqResp.OnBeforePost := OnBeforePost;
end;

{$IF CompilerVersion >= 33}
//Client: THTTPClient requer a unit System.Net.HttpClient
procedure TDFeHttpIndy.OnBeforePost(const HTTPReqResp: THTTPReqResp;
  Client: THTTPClient);
var
  ContentHeader: String;
begin
  with FpDFeSSL do
  begin
    if (UseCertificateHTTP) then
    begin
      if not InternetSetOption(Client, INTERNET_OPTION_CLIENT_CERT_CONTEXT,
        PCCERT_CONTEXT(FpDFeSSL.CertContextWinApi), SizeOf(CERT_CONTEXT)) then
        raise EACBrDFeException.Create('Erro ao ajustar INTERNET_OPTION_CLIENT_CERT_CONTEXT: ' +
                                       IntToStr(GetLastError));
    end;

    if (trim(ProxyUser) <> '') then
    begin
      if not InternetSetOption(Client, INTERNET_OPTION_PROXY_USERNAME,
        PChar(ProxyUser), Length(ProxyUser)) then
        raise EACBrDFeException.Create('Erro ao ajustar INTERNET_OPTION_PROXY_USERNAME: ' +
                                       IntToStr(GetLastError));

      if (trim(ProxyPass) <> '') then
        if not InternetSetOption(Client, INTERNET_OPTION_PROXY_PASSWORD,
          PChar(ProxyPass), Length(ProxyPass)) then
          raise EACBrDFeException.Create('Erro ao ajustar INTERNET_OPTION_PROXY_PASSWORD: ' +
                                         IntToStr(GetLastError));
    end;

    if (FMimeType <> '') then
    begin
      ContentHeader := Format(ContentTypeTemplate, [FMimeType]);
      HttpAddRequestHeaders(Client, PChar(ContentHeader), Length(ContentHeader),
                              HTTP_ADDREQ_FLAG_REPLACE);

    end;
  end;
  //N�o existe este m�todo CheckContentType em Soap.SOAPHTTPTrans (D10.3.1)
  //FIndyReqResp.CheckContentType;
end;

{$ELSE}

procedure TDFeHttpIndy.OnBeforePost(const HTTPReqResp: THTTPReqResp;
  ARequest: Pointer);
var
  ContentHeader: String;
  SecurityFlags, FlagsLen: Cardinal;
begin
  with FpDFeSSL do
  begin
    if (UseCertificateHTTP) then
    begin
      if not InternetSetOption(ARequest, INTERNET_OPTION_CLIENT_CERT_CONTEXT,
        PCCERT_CONTEXT(FpDFeSSL.CertContextWinApi), SizeOf(CERT_CONTEXT)) then
        raise EACBrDFeException.Create('Erro ao ajustar INTERNET_OPTION_CLIENT_CERT_CONTEXT: ' +
                                       IntToStr(GetLastError));
    end;

    SecurityFlags := 0;
    FlagsLen := SizeOf(SecurityFlags);
    // Query actual Flags
    if InternetQueryOption( ARequest,
                            INTERNET_OPTION_SECURITY_FLAGS,
                            @SecurityFlags, FlagsLen ) then
    begin
      SecurityFlags := SecurityFlags or
                       SECURITY_FLAG_IGNORE_REVOCATION or
                       SECURITY_FLAG_IGNORE_UNKNOWN_CA or
                       SECURITY_FLAG_IGNORE_CERT_CN_INVALID or
                       SECURITY_FLAG_IGNORE_CERT_DATE_INVALID or
                       SECURITY_FLAG_IGNORE_WRONG_USAGE;
      if not InternetSetOption( ARequest,
                                INTERNET_OPTION_SECURITY_FLAGS,
                                @SecurityFlags, FlagsLen ) then
        raise EACBrDFeException.Create('Erro ao ajustar INTERNET_OPTION_SECURITY_FLAGS: ' +
                                       IntToStr(GetLastError));
    end;

    if trim(ProxyUser) <> '' then
    begin
      if not InternetSetOption(ARequest, INTERNET_OPTION_PROXY_USERNAME,
        PChar(ProxyUser), Length(ProxyUser)) then
        raise EACBrDFeException.Create('Erro ao ajustar INTERNET_OPTION_PROXY_USERNAME: ' +
                                       IntToStr(GetLastError));

      if trim(ProxyPass) <> '' then
        if not InternetSetOption(ARequest, INTERNET_OPTION_PROXY_PASSWORD,
          PChar(ProxyPass), Length(ProxyPass)) then
          raise EACBrDFeException.Create('Erro ao ajustar INTERNET_OPTION_PROXY_PASSWORD: ' +
                                         IntToStr(GetLastError));
    end;

    if (FMimeType <> '') then
    begin
      ContentHeader := Format(ContentTypeTemplate, [FMimeType]);
      HttpAddRequestHeaders(ARequest, PChar(ContentHeader), Length(ContentHeader),
                            HTTP_ADDREQ_FLAG_REPLACE);
    end;
  end;

  FIndyReqResp.CheckContentType;
end;
{$IFEND}

end.


