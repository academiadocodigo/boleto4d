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

unit ACBrBoletoRet_Itau;

interface

uses
  Classes, SysUtils, ACBrBoleto,ACBrBoletoWS, ACBrBoletoRetorno,
  Jsons,
  ACBrUtil, DateUtils, pcnConversao;

type

{ TRetornoEnvio_Itau }

 TRetornoEnvio_Itau = class(TRetornoEnvioREST)
  private

  public
    constructor Create(ABoletoWS: TACBrBoleto); override;
    destructor  Destroy; Override;
    function LerRetorno: Boolean;override;
    function RetornoEnvio: Boolean; override;

  end;

implementation

uses
  ACBrBoletoConversao;

{ TRetornoEnvio }

constructor TRetornoEnvio_Itau.Create(ABoletoWS: TACBrBoleto);
begin
  inherited Create(ABoletoWS);

end;

destructor TRetornoEnvio_Itau.Destroy;
begin
  inherited Destroy;
end;

function TRetornoEnvio_Itau.LerRetorno: Boolean;
var
  RetornoItau: TRetEnvio;
  AJson: TJson;
  AJSonRejeicao: TJsonObject;
  ARejeicao: TRejeicao;
  AJSonResp: TJsonArray;
  I: Integer;
begin
  Result := True;

  if RetWS <> '' then
  begin
    RetornoItau:= ACBrBoleto.CriarRetornoWebNaLista;
    try
      with RetornoItau do
      begin

        AJSon := TJson.Create;
        try
          AJSon.Parse(RetWS);
          if (AJson.Values['codigo'].AsString <> '') or (AJson.Values['mensagem'].AsString <> '') then
          begin
            CodRetorno := AJson.Values['codigo'].AsString;
            OriRetorno := AJson.Values['mensagem'].AsString;
            AJSonResp := AJson.Values['campos'].AsArray;
            For I := 0 to AJSonResp.Count-1 do
            begin
              AJSonRejeicao := AJSonResp[I].AsObject;

              ARejeicao := CriarRejeicaoLista;
              ARejeicao.Campo := AJSonRejeicao.Values['campo'].AsString;
              ARejeicao.Mensagem := AJSonRejeicao.Values['mensagem'].AsString;
              ARejeicao.Valor := AJSonRejeicao.Values['valor'].AsString;
            end;
          end
          else
          begin
            with AJson.Values['pagador'].AsObject do
            begin
              DadosRet.TituloRet.Sacado.CNPJCPF        := Values['cpf_cnpj_pagador'].AsString;
              DadosRet.TituloRet.Sacado.NomeSacado     := Values['nome_razao_social_pagador'].AsString;
              if (DadosRet.TituloRet.Sacado.NomeSacado = '') then
                DadosRet.TituloRet.Sacado.NomeSacado   := Values['nome_razao_social_pagador'].AsString;

              DadosRet.TituloRet.Sacado.Logradouro := Values['logradouro_pagador'].AsString;
              DadosRet.TituloRet.Sacado.Bairro     := Values['bairro_pagador'].AsString;
              DadosRet.TituloRet.Sacado.Cidade     := Values['cidade_pagador'].AsString;
              DadosRet.TituloRet.Sacado.UF         := Values['uf_pagador'].AsString;
              DadosRet.TituloRet.Sacado.Cep        := Values['cep_pagador'].AsString;
            end;

            with AJson.Values['sacador_avalista'].AsObject do
            begin
               DadosRet.TituloRet.SacadoAvalista.CNPJCPF := Values['cpf_cnpj_sacador_avalista'].AsString;
               DadosRet.TituloRet.SacadoAvalista.NomeAvalista := Values['nome_razao_social_sacador_avalista'].AsString;
               if DadosRet.TituloRet.SacadoAvalista.NomeAvalista = '' then
                 DadosRet.TituloRet.SacadoAvalista.NomeAvalista  := Values['nome_razao_social_sacador_avalista'].AsString;
            end;

            DadosRet.IDBoleto.CodBarras := AJson.Values['codigo_barras'].AsString;
            DadosRet.IDBoleto.LinhaDig  := AJson.Values['numero_linha_digitavel'].AsString;
            DadosRet.IDBoleto.NossoNum  := AJson.Values['nosso_numero'].AsString;

            DadosRet.TituloRet.Vencimento:= StringToDateTimeDef(AJson.Values['vencimento_titulo'].AsString, 0, 'yyyy-mm-dd');
            DadosRet.TituloRet.Carteira:= AJson.Values['tipo_carteira_titulo'].AsString;
            DadosRet.TituloRet.NossoNumero:= AJson.Values['nosso_numero'].AsString;
            DadosRet.TituloRet.SeuNumero:= AJson.Values['seu_numero'].AsString;
            DadosRet.TituloRet.EspecieDoc:= AJson.Values['especie'].AsString;
            DadosRet.TituloRet.CodBarras:= AJson.Values['codigo_barras'].AsString;
            DadosRet.TituloRet.LinhaDig:= AJson.Values['numero_linha_digitavel'].AsString;
            DadosRet.TituloRet.Mensagem.Add(AJson.Values['local_pagamento'].AsString);
            DadosRet.TituloRet.DataProcessamento:= StringToDateTimeDef(AJson.Values['data_processamento'].AsString, 0, 'yyyy-mm-dd');
            DadosRet.TituloRet.DataDocumento:=  StringToDateTimeDef(AJson.Values['data_emissao'].AsString, 0, 'yyyy-mm-dd');
            DadosRet.TituloRet.UsoBanco:= AJson.Values['uso_banco'].AsString;
            DadosRet.TituloRet.ValorDocumento:= StrToFloatDef( AJson.Values['valor_titulo'].AsString, 0);
            DadosRet.TituloRet.ValorDesconto:= StrToFloatDef( AJson.Values['valor_desconto'].AsString, 0);
            DadosRet.TituloRet.ValorDespesaCobranca:= StrToFloatDef( AJson.Values['valor_outra_deducao'].AsString, 0);
            DadosRet.TituloRet.ValorMoraJuros := StrToFloatDef( AJson.Values['valor_juro_multa'].AsString, 0);
            DadosRet.TituloRet.ValorOutrosCreditos:= StrToFloatDef( AJson.Values['valor_outro_acrescimo'].AsString, 0);
            DadosRet.TituloRet.ValorPago:= StrToFloatDef(  AJson.Values['valor_total_cobrado'].AsString, 0);
            DadosRet.TituloRet.Informativo.Add( AJson.Values['texto_informacao_cliente_beneficiario'].AsString );
            MsgRetorno:= AJson.Values['codigo_mensagem_erro'].AsString;

          end;

        finally
          AJson.free;
        end;

      end;
    except
      Result := False;
    end;

  end;

end;

function TRetornoEnvio_Itau.RetornoEnvio: Boolean;
begin

  Result:=inherited RetornoEnvio;

end;

end.

