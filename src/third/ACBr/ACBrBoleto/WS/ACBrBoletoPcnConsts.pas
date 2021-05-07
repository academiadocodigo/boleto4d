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

unit ACBrBoletoPcnConsts;

interface

uses
  SysUtils;

const
  DSC_USUARIO_SERVICO = 'Autentica��o: nome do Usu�rio Servi�o WebService';
  DSC_AUTENTICACAO = 'Autentica��o do usu�rio';
  DSC_KEYUSER = 'Key User C�digo Chave Usu�rio';
  DSC_VERSAODF = 'Vers�o do Servi�o WebService';
  DSC_TIPO_SERVICO = 'Tipo do Servi�o WebServico';
  DSC_SISTEMA_ORIGEM = 'C�digo Sistema de Origem WebService';
  DSC_AGENCIA = 'N�mero da Ag�ncia';
  DSC_DATA_HORA = 'Data Hora de Envio Remessa';
  DSC_CODIGO_CEDENTE = 'C�digo do Cedente';
  DSC_CONVENIO = 'N�mero do Convenio';
  DSC_CARTEIRA = 'N�mero da Carteira';
  DSC_VARIACAO_CARTEIRA = 'N�mero da varia��o de Carteira';
  DSC_MODALIDADE = 'Modalidade do T�tulo';
  DSC_CODIGO_MODALIDADE = 'Codigo Modalidade Titulo';
  DSC_NOSSO_NUMERO = 'Nosso N�mero';
  DSC_NUMERO_DOCUMENTO = 'N�mero do Documento';
  DSC_DATA_VENCIMENTO = 'Vencimento T�tulo';
  DSC_VALOR_DOCUMENTO = 'Valor do T�tulo';
  DSC_TIPO_ESPECIE = 'Tipo Especie';
  DSC_ACEITE = 'Aceite';
  DSC_DATA_DOCUMENTO = 'Data Documento';
  DSC_VALOR_ABATIMENTO = 'Valor Abatimento';
  DSC_VALOR_IOF = 'Valor IOF';
  DSC_MOEDA = 'C�digo Moeda';
  DSC_CODIGO_MORA_JUROS = 'C�digo Mora Juros';
  DSC_DATA_MORA_JUROS = 'Data Mora Juros';
  DSC_VALOR_MORA_JUROS = 'Valor Mora Juros';
  DSC_CODIGO_NEGATIVACAO = 'C�digo Negativa��o';
  DSC_DIAS_PROTESTO = 'N�mero Dias Protesto';
  DSC_NOME_SACADO = 'Nome do Sacado';
  DSC_LOGRADOURO = 'Logradouro do Sacado';
  DSC_BAIRRO = 'Bairro do Sacado';
  DSC_CIDADE = 'Cidade do Sacado';
  DSC_UF = 'UF do Sacado';
  DSC_CEP = 'CEP do Sacado';
  DSC_FONE = 'Fone do Sacado';
  DSC_NOME_AVALISTA = 'Nome Avalista';
  DSC_DATA_MULTA = 'Data Multa';
  DSC_PERCENTUAL_MULTA = 'Percentual Multa';
  DSC_TIPO_DESCONTO = 'Tipo Desconto';
  DSC_DATA_DESCONTO = 'Data Desconto';
  DSC_VALOR_DESCONTO = 'Valor Desconto';
  DSC_DATA_DESCONTO2 = 'Data Desconto2';
  DSC_VALOR_DESCONTO2 = 'Valor Desconto2';
  DSC_MENSAGEM = 'Mensagem';
  DSC_INSTRUCAO1 = 'Instru��o 1';
  DSC_INSTRUCAO2 = 'Instru��o 2';
  DSC_INSTRUCAO3 = 'Instru��o 3';
  DSC_QTDE_PAGAMENTO_PARCIAL = 'Qtde Pagamento Parcial';
  DSC_TIPO_PAGAMENTO = 'Tipo de Pagamento';
  DSC_VALOR_MIN_PAGAMENTO = 'Valor Min Pagamento';
  DSC_VALOR_MAX_PAGAMENTO = 'Valor Max Pagamento';
  DSC_PERCENTUAL_MIN_PAGAMENTO = 'Percentual Min Pagamento';
  DSC_PERCENTUAL_MAX_PAGAMENTO = 'Percentual Max Pagamento';
  DSC_CANAL_SOLICITACAO = 'Canal de Solicita��o do Servi�o';

implementation

end.
