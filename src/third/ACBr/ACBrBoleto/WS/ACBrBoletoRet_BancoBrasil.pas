{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:  Jos� M S Junior                                }
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

unit ACBrBoletoRet_BancoBrasil;

interface

uses
  Classes, SysUtils, ACBrBoleto, ACBrBoletoWS, ACBrBoletoRetorno,
  ACBrUtil, DateUtils, pcnConversao;

type

{ TRetornoEnvio_BancoBrasil }

  TRetornoEnvio_BancoBrasil = class(TRetornoEnvioSOAP)
  private

  public
    constructor Create(ABoletoWS: TACBrBoleto); override;
    destructor  Destroy; Override;
    function LerRetorno: Boolean;override;
    function RetornoEnvio: Boolean; override;

  end;

  const
  C_URL_Retorno = ' xmlns:ns0="http://www.tibco.com/schemas/bws_registro_cbr/Recursos/XSD/Schema.xsd"';

implementation

uses
  ACBrBoletoConversao;

{ TRetornoEnvio_BancoBrasil }

constructor TRetornoEnvio_BancoBrasil.Create(ABoletoWS: TACBrBoleto);
begin
  inherited Create(ABoletoWS);
end;

destructor TRetornoEnvio_BancoBrasil.Destroy;
begin
  inherited Destroy;
end;

function TRetornoEnvio_BancoBrasil.LerRetorno: Boolean;
var
    RetornoBB: TRetEnvio;
    lXML: String;
begin
    Result := True;

    lXML:= StringReplace(Leitor.Arquivo, 'ns0:', '', [rfReplaceAll]) ;
    lXML:= StringReplace(lXML, C_URL_Retorno, '', [rfReplaceAll]) ;
    Leitor.Arquivo := lXML;
    Leitor.Grupo := Leitor.Arquivo;

    RetornoBB:= ACBrBoleto.CriarRetornoWebNaLista;
    try
      with RetornoBB do
      begin
        if leitor.rExtrai(1, 'resposta') <> '' then
        begin

          CodRetorno := Leitor.rCampo(tcStr, 'codigoRetornoPrograma');
          OriRetorno := Leitor.rCampo(tcStr, 'nomeProgramaErro');
          MsgRetorno := Leitor.rCampo(tcStr, 'textoMensagemErro');

          with DadosRet do
          begin
            Excecao := Leitor.rCampo(tcStr, 'numeroPosicaoErroPrograma');

            with ControleNegocial do
            begin
              OriRetorno := Leitor.rCampo(tcStr, 'codigoCliente');
              CodRetorno := Leitor.rCampo(tcStr, 'numeroContratoCobranca');
              NSU        := Leitor.rCampo(tcStr, '');

            end;

            DadosRet.IDBoleto.CodBarras := Leitor.rCampo(tcStr, 'codigoBarraNumerico');
            DadosRet.IDBoleto.LinhaDig  := Leitor.rCampo(tcStr, 'linhaDigitavel');
            DadosRet.IDBoleto.NossoNum  := Leitor.rCampo(tcStr, 'textoNumeroTITULOCobrancaBb');

          end;
        end;
      end;
    except
      Result := False;
    end;

  end;

function TRetornoEnvio_BancoBrasil.RetornoEnvio: Boolean;
var
  lRetornoWS: String;
begin

  lRetornoWS := RetWS;
  RetWS := SeparaDados(lRetornoWS, 'SOAP-ENV:Body');

  Result:=inherited RetornoEnvio;

end;

end.

