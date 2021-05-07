{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Robson da Motta                                 }
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

unit ACBrBancoBrasilSicoob;

interface

uses
  Classes, SysUtils, ACBrBoleto, Contnrs, ACBrBoletoConversao,
  {$IFDEF COMPILER6_UP} DateUtils {$ELSE} ACBrD5, FileCtrl {$ENDIF};

const
  CACBrBancoBrasilSICOOB_Versao = '0.0.1';

type
  { TACBrBancoBrasilSICOOB}

  TACBrBancoBrasilSICOOB = class(TACBrBancoClass)
   protected
   private
    function FormataNossoNumero(const ACBrTitulo :TACBrTitulo): String;
   public
    Constructor create(AOwner: TACBrBanco);
    function CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String; override;
    function MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String; override;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String; override;
    function MontarCampoNossoNumero(const ACBrTitulo :TACBrTitulo): String; override;

    function GerarRegistroHeader240(NumeroRemessa : Integer): String; override;
    function GerarRegistroTransacao240(ACBrTitulo : TACBrTitulo): String; override;
    function GerarRegistroTrailler240(ARemessa : TStringList): String;  override;


    function TipoOcorrenciaToDescricao(
      const TipoOcorrencia: TACBrTipoOcorrencia) : String; override;
    function CodOcorrenciaToTipo(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
    function TipoOCorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia):String; override;
    procedure LerRetorno240(ARetorno: TStringList); override;
    function CodMotivoRejeicaoToDescricao(
      const TipoOcorrencia: TACBrTipoOcorrencia; CodMotivo: Integer): String; override;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
   end;

implementation


uses StrUtils, ACBrUtil, Variants, ACBrValidador;


constructor TACBrBancoBrasilSICOOB.create(AOwner: TACBrBanco);
begin
   inherited create(AOwner);
   fpDigito := 9;
   fpNome   := 'Banco do Brasil';
   fpNumero := 1;
   fpTamanhoMaximoNossoNum := 7;
   fpTamanhoConta   := 8;
   fpTamanhoAgencia := 4;
   fpTamanhoCarteira:= 2;
   fpNumeroCorrespondente:= 756;
end;

function TACBrBancoBrasilSICOOB.CalcularDigitoVerificador(
  const ACBrTitulo: TACBrTitulo ): String;
begin
   Result := '0';

   Modulo.CalculoPadrao;
   Modulo.MultiplicadorFinal   := 2;
   Modulo.MultiplicadorInicial := 9;
   Modulo.Documento := FormataNossoNumero(ACBrTitulo);
   Modulo.Calcular;

   if Modulo.ModuloFinal = 10 then
     Result := '0'
   else if  Modulo.ModuloFinal> 10 then
     Result:= '1'
   else
     Result:= IntToStr(Modulo.ModuloFinal);
end;

function TACBrBancoBrasilSICOOB.FormataNossoNumero(const ACBrTitulo :TACBrTitulo): String;
begin
  Result :=   PadLeft(ACBrBanco.ACBrBoleto.Cedente.Convenio, 10, '0') +
              ACBrTitulo.NossoNumero;

end;


function TACBrBancoBrasilSICOOB.MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String;
var
  CodigoBarras, FatorVencimento, DigitoCodBarras: String;
begin

   {Codigo de Barras}
   with ACBrTitulo.ACBrBoleto do
   begin
      FatorVencimento := CalcularFatorVencimento(ACBrTitulo.Vencimento);
      CodigoBarras := IntToStrZero(Banco.Numero, 3) +
                      '9' +
                      FatorVencimento +
                      IntToStrZero(Round(ACBrTitulo.ValorDocumento * 100), 10) +
                      PadLeft('0', 6, '0') +
                      ACBrTitulo.ACBrBoleto.Cedente.Convenio +
                      ACBrTitulo.NossoNumero +
                      PadRight(ACBrTitulo.Carteira, fpTamanhoCarteira, '0');

      DigitoCodBarras := CalcularDigitoCodigoBarras(CodigoBarras);
   end;

   Result:= copy( CodigoBarras, 1, 4) + DigitoCodBarras + copy( CodigoBarras, 5, 44) ;

end;

function TACBrBancoBrasilSICOOB.MontarCampoCodigoCedente (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result := ACBrTitulo.ACBrBoleto.Cedente.Agencia+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito+'/'+
             IntToStrZero(StrToIntDef(ACBrTitulo.ACBrBoleto.Cedente.Conta,0),8)+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.ContaDigito;
end;

function TACBrBancoBrasilSICOOB.MontarCampoNossoNumero (const ACBrTitulo: TACBrTitulo ) : String;
var
  ANossoNumero: String;
begin
   ANossoNumero := FormataNossoNumero(ACBrTitulo);
   Result:= ANossoNumero;
end;

function TACBrBancoBrasilSICOOB.TipoOCorrenciaToCod (
   const TipoOcorrencia: TACBrTipoOcorrencia ) : String;
begin
  case TipoOcorrencia of
    toRetornoRegistroConfirmado                         : Result := '02';
    toRetornoComandoRecusado                            : Result := '03';
    toRetornoLiquidadoSemRegistro                       : Result := '05';
    toRetornoLiquidado                                  : Result := '06';
    toRetornoLiquidadoPorConta                          : Result := '07';
    toRetornoBaixado                                    : Result := '09';
    toRetornoBaixaSolicitada                            : Result := '10';
    toRetornoTituloEmSer                                : Result := '11';
    toRetornoAbatimentoConcedido                        : Result := '12';
    toRetornoAbatimentoCancelado                        : Result := '13';
    toRetornoVencimentoAlterado                         : Result := '14';
    toRetornoLiquidadoEmCartorio                        : Result := '15';
    toRetornoRecebimentoInstrucaoProtestar              : Result := '19';
    toRetornoDebitoEmConta                              : Result := '20';
    toRetornoRecebimentoInstrucaoAlterarNomeSacado      : Result := '21';
    toRetornoRecebimentoInstrucaoAlterarEnderecoSacado  : Result := '22';
    toRetornoEncaminhadoACartorio                       : Result := '23';
    toRetornoProtestoSustado                            : Result := '24';
    toRetornoJurosDispensados                           : Result := '25';
    toRetornoManutencaoTituloVencido                    : Result := '28';
    toRetornoDescontoConcedido                          : Result := '31';
    toRetornoDescontoCancelado                          : Result := '32';
    toRetornoAcertoControleParticipante                 : Result := '41';
    toRetornoTituloPagoEmCheque                         : Result := '46';
    toRetornoTipoCobrancaAlterado                       : Result := '72';
    toRetornoDespesasProtesto                           : Result := '96';
    toRetornoDespesasSustacaoProtesto                   : Result := '97';
    toRetornoDebitoCustasAntecipadas                    : Result := '98';
  else
    Result := '02';
  end;
end;

function TACBrBancoBrasilSICOOB.TipoOcorrenciaToDescricao(
   const TipoOcorrencia: TACBrTipoOcorrencia): String;
var
 CodOcorrencia: Integer;
begin

  CodOcorrencia := StrToIntDef(TipoOCorrenciaToCod(TipoOcorrencia),0);

  Case CodOcorrencia of
   {Segundo manual t�cnico CNAB400 Abril/2012 BB pag.20 os comandos s�o os seguintes:}
   02: Result:='02-Confirma��o de Entrada de T�tulo' ;
   03: Result:='03-Comando recusado' ;
   05: Result:='05-Liquidado sem registro' ;
   06: Result:='06-Liquida��o Normal' ;
   07: Result:='07-Liquida��o por Conta' ;
   08: Result:='08-Liquida��o por Saldo' ;
   09: Result:='09-Baixa de T�tulo' ;
   10: Result:='10-Baixa Solicitada' ;
   11: Result:='11-Titulos em Ser' ;
   12: Result:='12-Abatimento Concedido' ;
   13: Result:='13-Abatimento Cancelado' ;
   14: Result:='14-Altera��o de Vencimento do Titulo' ;
   15: Result:='15-Liquida��o em Cart�rio' ;
   16: Result:='16-Confirma��o de altera��o de juros de mora' ;
   19: Result:='19-Confirma��o de recebimento de instru��es para protesto' ;
   20: Result:='20-D�bito em Conta' ;
   21: Result:='21-Altera��o do Nome do Sacado' ;
   22: Result:='22-Altera��o do Endere�o do Sacado' ;
   23: Result:='23-Indica��o de encaminhamento a cart�rio' ;
   24: Result:='24-Sustar Protesto' ;
   25: Result:='25-Dispensar Juros' ;
   26: Result:='26-Altera��o do n�mero do t�tulo dado pelo Cedente (Seu n�mero) - 10 e 15 posi��es' ;
   28: Result:='28-Manuten��o de titulo vencido' ;
   31: Result:='31-Conceder desconto' ;
   32: Result:='32-N�o conceder desconto' ;
   33: Result:='33-Retificar desconto' ;
   34: Result:='34-Alterar data para desconto' ;
   35: Result:='35-Cobrar multa' ;
   36: Result:='36-Dispensar multa' ;
   37: Result:='37-Dispensar indexador' ;
   38: Result:='38-Dispensar prazo limite para recebimento' ;
   39: Result:='39-Alterar prazo limite para recebimento' ;
   41: Result:='41-Altera��o do n�mero do controle do participante (25 posi��es)' ;
   42: Result:='42-Altera��o do n�mero do documento do sacado (CNPJ/CPF)' ;
   44: Result:='44-T�tulo pago com cheque devolvido' ;
   46: Result:='46-T�tulo pago com cheque, aguardando compensa��o' ;
   72: Result:='72-Altera��o de tipo de cobran�a' ;
   96: Result:='96-Despesas de Protesto' ;
   97: Result:='97-Despesas de Susta��o de Protesto' ;
   98: Result:='98-D�bito de Custas Antecipadas' ;
  end;
end;

function TACBrBancoBrasilSICOOB.CodOcorrenciaToTipo(const CodOcorrencia:
   Integer ) : TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02: Result := toRetornoRegistroConfirmado;
    03: Result := toRetornoComandoRecusado;
    05: Result := toRetornoLiquidadoSemRegistro;
    06: Result := toRetornoLiquidado;
    07: Result := toRetornoLiquidadoPorConta;
    09: Result := toRetornoBaixado;
    10: Result := toRetornoBaixaSolicitada;
    11: Result := toRetornoTituloEmSer;
    12: Result := toRetornoAbatimentoConcedido;
    13: Result := toRetornoAbatimentoCancelado;
    14: Result := toRetornoVencimentoAlterado;
    15: Result := toRetornoLiquidadoEmCartorio;
    19: Result := toRetornoRecebimentoInstrucaoProtestar;
    21: Result := toRetornoRecebimentoInstrucaoAlterarNomeSacado;
    22: Result := toRetornoRecebimentoInstrucaoAlterarEnderecoSacado;
    23: Result := toRetornoEncaminhadoACartorio;
    24: Result := toRetornoProtestoSustado;
    25: Result := toRetornoJurosDispensados;
    28: Result := toRetornoManutencaoTituloVencido;
    31: Result := toRetornoDescontoConcedido;
    96: Result := toRetornoDespesasProtesto;
    97: Result := toRetornoDespesasSustacaoProtesto;
    98: Result := toRetornoDebitoCustasAntecipadas;
  else
    Result := toRetornoOutrasOcorrencias;
  end;
end;

function TACBrBancoBrasilSICOOB.CodOcorrenciaToTipoRemessa(const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02 : Result:= toRemessaBaixar;                          {Pedido de Baixa}
    04 : Result:= toRemessaConcederAbatimento;              {Concess�o de Abatimento}
    05 : Result:= toRemessaCancelarAbatimento;              {Cancelamento de Abatimento concedido}
    06 : Result:= toRemessaAlterarVencimento;               {Altera��o de vencimento}
    07 : Result:= toRemessaConcederDesconto;                {Concess�o de Desconto}
    08 : Result:= toRemessaCancelarDesconto;                {N�o conceder desconto}
    09 : Result:= toRemessaProtestar;                       {Pedido de protesto}
    10 : Result:= toRemessaCancelarInstrucaoProtestoBaixa;  {Sustar protesto e baixar}
    31 : Result:= toRemessaOutrasOcorrencias;               {Altera��o de Outros Dados}
  else
     Result:= toRemessaRegistrar;                           {Remessa}
  end;
end;

function TACBrBancoBrasilSICOOB.CodMotivoRejeicaoToDescricao(
   const TipoOcorrencia: TACBrTipoOcorrencia; CodMotivo: Integer): String;
begin
  case TipoOcorrencia of
    toRetornoRegistroConfirmado: //02 (Entrada)
      case CodMotivo of
        00: Result:='00-Por meio magn�tico';
        11: Result:='11-Por via convencional';
        16: Result:='16-Por altera��o do c�digo do cedente';
        17: Result:='17-Por altera��o da varia��o';
        18: Result:='18-Por altera��o de carteira';
      end;

     toRetornoComandoRecusado: //03 (Recusado)
      case CodMotivo of
        01: Result := '01 � C�digo do banco inv�lido' ;
        02: Result := '02 � C�digo do registro detalhe inv�lido' ;
        03: Result := '03 � C�digo do segmento inv�lido' ;
        04: Result := '04 � C�digo do movimento n�o permitido para carteira' ;
        05: Result := '05 � C�digo de movimento inv�lido' ;
        06: Result := '06 � Tipo / n�mero de inscri��o do Beneficiario inv�lidos' ;
        07: Result := '07 � Ag�ncia / c�digo / dv inv�lido' ;
        08: Result := '08 � Nosso n�mero inv�lido' ;
        09: Result := '09 � Nosso n�mero duplicado' ;
        10: Result := '10 � Carteira inv�lida' ;
        11: Result := '11 � Forma de cadastramento do t�tulo inv�lido' ;
        12: Result := '12 � Tipo de documento inv�lido' ;
        13: Result := '13 � Identifica��o da emiss�o do bloqueto inv�lida' ;
        14: Result := '14 - Identifica��o da distribui��o do bloqueto inv�lida' ;
        15: Result := '15 � Caracter�sticas da cobran�a incompat�veis' ;
        16: Result := '16 � Data de vencimento inv�lida' ;
        17: Result := '17 � Data de vencimento anterior a data de emiss�o' ;
        18: Result := '18 � Vencimento fora do prazo de opera��o' ;
        19: Result := '19 � T�tulo a cargo de Bancos Correspondentes com vencimento inferior' ;
        20: Result := '20 � Valor do t�tulo inv�lido' ;
        21: Result := '21 � Esp�cie do t�tulo inv�lido' ;
        22: Result := '22 � Esp�cie n�o permitida para a carteira' ;
        23: Result := '23 � Aceite inv�lido' ;
        24: Result := '24 � Data da emiss�o inv�lida' ;
        25: Result := '25 � Data da emiss�o posterior a data' ;
        26: Result := '26 � C�digo de juros de mora inv�lido' ;
        27: Result := '27 � Valor / taxa de juros de mora inv�lido' ;
        28: Result := '28 � C�digo do desconto inv�lido' ;
        29: Result := '29 � Valor do desconto maior ou igual ao valor do t�tulo' ;
        30: Result := '30 � Desconto a conceder n�o confere' ;
        31: Result := '31 � Concess�o de desconto � j� existe desconto anterior' ;
        32: Result := '32 � Valor do IOF inv�lido' ;
        33: Result := '33 � Valor do abatimento inv�lido' ;
        34: Result := '34 � Valor do abatimento maior ou igual ao valor do t�tulo' ;
        35: Result := '35 � Abatimento a conceder n�o confere' ;
        36: Result := '36 � Concess�o de abatimento � j� existe abatimento anterior' ;
        37: Result := '37 � C�digo para protesto inv�lido' ;
        38: Result := '38 � Prazo para protesto inv�lido' ;
        39: Result := '39 � Pedido de protesto n�o permitido para o t�tulo' ;
        40: Result := '40 � T�tulo com ordem de protesto emitida' ;
        41: Result := '41 � Pedido de cancelamento / susta��o para t�tulo sem instru��o de protesto' ;
        42: Result := '42 � C�digo para baixa / devolu��o inv�lido' ;
        43: Result := '43 � Prazo para baixa / devolu��o inv�lido' ;
        44: Result := '44 � C�digo da moeda inv�lido' ;
        45: Result := '45 � Nome do Pagador n�o informado' ;
        46: Result := '46 � Tipo / n�mero de inscri��o do Pagador inv�lido' ;
        47: Result := '47 � Endere�o do Pagador n�o informado' ;
        48: Result := '48 � CEP inv�lido' ;
        49: Result := '49 � CEP sem pra�a de cobran�a / n�o localizado' ;
        50: Result := '50 � CEP referente a um Banco Correspondente' ;
        51: Result := '51 � CEP incompat�vel com a unidade da federa��o' ;
        52: Result := '52 � Unidade da federa��o inv�lida' ;
        53: Result := '53 � Tipo / n�mero de inscri��o do Sacador / avalista inv�lidos' ;
        54: Result := '54 � Sacador / Avalista n�o informado' ;
        55: Result := '55 � Nosso n�mero no Banco Correspondente n�o informado' ;
        56: Result := '56 � C�digo do Banco Correspondente n�o informado' ;
        57: Result := '57 � C�digo da multa inv�lido' ;
        58: Result := '58 � Data da multa inv�lida' ;
        59: Result := '59 � Valor / percentual da multa inv�lido' ;
        60: Result := '60 � Movimento para t�tulo n�o cadastrado' ;
        61: Result := '61 � Altera��o da ag�ncia cobradora / dv inv�lida' ;
        62: Result := '62 � Tipo de impress�o inv�lido' ;
        63: Result := '63 � Entrada para o t�tulo j� cadastrado' ;
        64: Result := '64 � N�mero da linha inv�lido' ;
        65: Result := '65 � C�digo do banco para d�bito inv�lido' ;
        66: Result := '66 � Ag�ncia / conta / dv para d�bito inv�lido' ;
        67: Result := '67 � Dados para d�bito incompat�vel com a identifica��o da emiss�o do bloqueto' ;
        88: Result := '88 � Arquivo em duplicidade' ;
        99: Result := '99 � Contrato inexistente' ;
      end;
    toRetornoLiquidado,
    toRetornoLiquidadoEmCartorio:   // Comandos 06 e 15 posi��es 109/110 
      case CodMotivo of
        01: Result:='01-Liquida��o normal';
        09: Result:='09-Liquida��o em cart�rio';
      end;

    toRetornoBaixado, toRetornoBaixaSolicitada:  // 09 ou 10 (Baixa)
      case CodMotivo of
        00: Result:='00-Solicitada pelo cliente';
        15: Result:='15-Protestado';
        90: Result:='90-Baixa autom�tica';
      end;
  end;
end;

function TACBrBancoBrasilSICOOB.GerarRegistroHeader240(
  NumeroRemessa: Integer): String;
begin
   with ACBrBanco.ACBrBoleto.Cedente do
   begin
     Result:= IntToStr(ACBrBanco.NumeroCorrespondente)           + //001 a 003 - C�digo do banco SICOOB
              '0000'                                             + //004 a 007 - Lote de servi�o
              '1'                                                + //008 - Tipo de registro - Registro header de arquivo
              'R'                                                + //009 - Tipo de opera��o R = Remessa
              PadLeft('0', 7, '0')                               + //010 a 016 - Zeros
              Space(2)                                           + //017 a 018 - Brancos
              OnlyNumber(Agencia)                                + //019 a 022 - N�mero da Cooperativa/Agencia
              PadLeft(CodigoTransmissao, 7, '0')                 + //023 a 029 - C�digo de Cobran�a  - oc 81437 utilizado esse codigotransmissao para obter o tipocobranca do cadastro da conta
              PadLeft((OnlyNumber(Conta) + ContaDigito), 11,'0' )+ //030 a 040 - Conta corrente com DV
              Space(30)                                          + //041 a 070 - Brancos
              TiraAcentos(UpperCase(PadRight(Nome, 30, ' ')))    + //071 a 100 - Nome da Empresa
              Space(80)                                          + //101 a 180 - Brancos
              PadLeft(IntToStr(NumeroRemessa), 8, '0')           + //181 a 188 - N�mero da remessa
              FormatDateTime('ddmmyyyy', Now)                    + //189 a 196 - Data do de gera��o do arquivo
              PadLeft('0', 11, '0')                              + //197 a 207 - Zeros
              Space(33);                                           //208 � 240 - Filler
   end;
end;

function TACBrBancoBrasilSICOOB.GerarRegistroTrailler240(
  ARemessa: TStringList): String;
var
  i             : Integer;
  vTotalTitulos : Currency;
  sValorTitulos : String;
begin

  vTotalTitulos := 0;
  for i:= 0 to ACBrBanco.ACBrBoleto.ListadeBoletos.Count - 1 do
    vTotalTitulos := vTotalTitulos + ACBrBanco.ACBrBoleto.ListadeBoletos[i].ValorDocumento;

  sValorTitulos := IntToStr(Round(vTotalTitulos * 100));
  Result:= '0000000'                           + //001 a 007 - Zeros
           '5'                                 + //008 a 008 - Registro Trailler do Lote
           Space(9)                            + //009 a 017 - Brancos
           IntToStrZero(ARemessa.Count * 2,6)  + //018 a 023 - Quantidade de registros do lote
           PadLeft(sValorTitulos,17,'0')       + //024 a 040 - Valor total dos titulos
           PadLeft('0', 6, '0')                + //041 a 046 - Zeros
           Space(194);                           //047 - 240 - Brancos
end;

function TACBrBancoBrasilSICOOB.GerarRegistroTransacao240(
  ACBrTitulo: TACBrTitulo): String;
var
  ATipoOcorrencia, ATipoInscricao, ANossoNumero, ATipoMora, AEndereco : String;
  AValorCEP, ADiasProtesto, TipoAvalista : String;
  wLinhaP, wLinhaQ : String;
  indice           : Integer;
  AValorMora       : Double;
begin
  {Pegando C�digo da Ocorrencia}
  case ACBrTitulo.OcorrenciaOriginal.Tipo of
     toRemessaRegistrar                      : ATipoOcorrencia := '01'; {Entrada de T�tulos}
     toRemessaBaixar                         : ATipoOcorrencia := '02'; {Pedido de Baixa}
     toRemessaConcederAbatimento             : ATipoOcorrencia := '04'; {Concess�o de Abatimento}
     toRemessaCancelarAbatimento             : ATipoOcorrencia := '05'; {Cancelamento de Abatimento concedido}
     toRemessaAlterarVencimento              : ATipoOcorrencia := '06'; {Altera��o de vencimento}
     toRemessaConcederDesconto               : ATipoOcorrencia := '07'; {Concess�o de Desconto}
     toRemessaCancelarDesconto               : ATipoOcorrencia := '08'; {N�o conceder desconto}
     toRemessaProtestar                      : ATipoOcorrencia := '09'; {Pedido de protesto}
     toRemessaCancelarInstrucaoProtestoBaixa : ATipoOcorrencia := '10'; {Sustar protesto e baixar}
     toRemessaOutrasOcorrencias              : ATipoOcorrencia := '31'; {Altera��o de Outros Dados}
  else
     ATipoOcorrencia := '01';                                           {Remessa}
  end;

  { Pegando o tipo de EspecieDoc }
  if ACBrTitulo.EspecieDoc = 'DM' then
     ACBrTitulo.EspecieDoc   := '02'
  else if ACBrTitulo.EspecieDoc = 'LC' then
     ACBrTitulo.EspecieDoc   := '07'
  else if ACBrTitulo.EspecieDoc = 'RC' then
     ACBrTitulo.EspecieDoc   := '17'
  else if ACBrTitulo.EspecieDoc = 'NP' then
     ACBrTitulo.EspecieDoc   := '12'
  else if ACBrTitulo.EspecieDoc = 'NS' then
     ACBrTitulo.EspecieDoc   := '20'
  else if ACBrTitulo.EspecieDoc = 'ND' then
     ACBrTitulo.EspecieDoc   := '19'
  else if ACBrTitulo.EspecieDoc = 'DS' then
     ACBrTitulo.EspecieDoc   := '04';
//  else
//     ACBrTitulo.EspecieDoc := ACBrTitulo.EspecieDoc;

  ANossoNumero := FormataNossoNumero(ACBrTitulo);

  AValorMora := 0;
  if (ACBrTitulo.PercentualMulta > 0) then
  begin
    ATipoMora := '3';
    AValorMora := ACBrTitulo.PercentualMulta;
  end
  else
  begin
    if (ACBrTitulo.ValorMoraJuros > 0) then
    begin
      ATipoMora := '2';
      AValorMora := ACBrTitulo.ValorMoraJuros;
    end
    else
      ATipoMora := '1';
  end;

  ADiasProtesto := IntToStrZero((DaysBetween(ACBrTitulo.DataProtesto,ACBrTitulo.Vencimento)), 2);
  indice := (2 * ACBrTitulo.ACBrBoleto.ListadeBoletos.IndexOf(ACBrTitulo));

  //Inicia Segmento P
  wLinhaP:= '0000000'                                               +  // 001 a 007 - ZEROS
            '3'                                                     +  // 008       - Fixo 3
            IntToStrZero(indice +1, 5)                              +  // 009 a 013 - N�mero sequencial do registro
            'P'                                                     +  // 014       - Fixo P
            ' '                                                     +  // 015       - Brancos
            ATipoOcorrencia                                         +  // 016 a 017 - C�digo da Instru��o
            Space(23)                                               +  // 018 a 040 - Brancos
            ANossoNumero                                            +  // 041 a 057 - Nosso n�mero
            '9'                                                     +  // 058       - Carteira com registro
            ACBrTitulo.EspecieDoc                                   +  // 059 a 060 - Tipo de Documento
            '2'                                                     +  // 061       - 2 = Beneficiario emite
            ' '                                                     +  // 062       - Branco
            PadLeft(ACBrTitulo.SeuNumero , 15, ' ')                 +  // 063 a 077 - Seu N�mero
            FormatDateTime('ddmmyyyy',ACBrTitulo.Vencimento)        +  // 078 a 085 - Data de vencimento
            IntToStrZero(Round(ACBrTitulo.ValorDocumento * 100),15) +  // 086 a 100 - Valor do Documento
            '000000'                                                +  // 100 a 106 - Zeros
            IfThen( ACBrTitulo.Aceite = atSim, 'A', 'N')            +  // 107       - Aceite (S ou N)
            '  '                                                    +  // 108 a 109 - Brancos
            FormatDateTime('ddmmyyyy',ACBrTitulo.DataProcessamento) +  // 110 a 117 - Data de emiss�o
            ATipoMora                                               +  // 118 a 118 - Tipo de Mora
            IntToStrZero( Round( AValorMora * 100 ), 15)            +  // 119 a 133 - Valor do Juros/Mora
            '000000000'                                             +  // 134 a 142 - Zeros
            IfThen((ACBrTitulo.ValorDesconto > 0),
                FormatDateTime('ddmmyyyy',ACBrTitulo.DataDesconto),
                '00000000')                                         +  // 143 a 150 - Data limite do desconto
            IntToStrZero(Round(ACBrTitulo.ValorDesconto * 100), 15) +  // 151 a 165 - Valor do Desconto
            Space(15)                                               +  // 166 a 180 - Filler (Brancos)
            IntToStrZero(Round(ACBrTitulo.ValorAbatimento * 100),15)+  // 181 a 195 - Valor do Abatimento
            PadLeft(ACBrTitulo.NumeroDocumento , 25, ' ')           +  // 196 a 220 - Uso da empresa
            IfThen((ADiasProtesto = '00'),'0','1')                  +  // 221       - Tipo de Protesto
            ADiasProtesto                                           +  // 222 a 223 - Dias do protesto
            '0000'                                                  +  // 224 a 227 - Zeros
            '09'                                                    +  // 228 a 229 - C�digo da Moeda
            PadLeft('', 10, '0')                                    +  // 230 a 239 - N�mero do contrato de opera��o de cr�dito
            '0';


  AEndereco := ACBrTitulo.Sacado.Logradouro + ', ' +  ACBrTitulo.Sacado.Numero;

  if ACBrTitulo.Sacado.Complemento <> '' then
   AEndereco := AEndereco + ', ' + ACBrTitulo.Sacado.Complemento;

  AValorCEP := OnlyNumber(ACBrTitulo.Sacado.CEP);

//  ATipoInscricao := IfThen((ACBrTitulo.Sacado.Pessoa = pFisica),'01','02');
  ATipoInscricao := IfThen((ACBrTitulo.Sacado.Pessoa = pFisica),'01','02');

  {Avalista}
  case ACBrTitulo.Sacado.SacadoAvalista.Pessoa of
    pFisica:   TipoAvalista := '01';
    pJuridica: TipoAvalista := '02';
  else
    TipoAvalista := '09';
  end;

  //Inicia Segmento Q
  wLinhaQ := '0000000'                                                     +  // 001 a 007 - ZEROS
             '3'                                                           +  // 008       - Registro detalhe (fixo 3)
             IntToStrZero(indice + 2, 5)                                   +  // 009 a 013 - N�mero sequencia do registro no lote
             'Q'                                                           +  // 014       - C�digo do Segmento (Q)
             ' '                                                           +  // 015       - Brancos
             ATipoOcorrencia                                               +  // 016 a 017 - C�digo da instru��o (igual a o seg. P posi��o 016-017)
             ATipoInscricao                                                +  // 018 a 019 - Tipo de Incri��o (01= f�sica; 02=jur�dica)
             PadLeft(OnlyNumber(ACBrTitulo.Sacado.CNPJCPF),14,'0')         +  // 020 a 033 - N�mero da inscri��o do pagador
             PadLeft(ACBrTitulo.Sacado.NomeSacado, 40, ' ')                +  // 034 a 073 - Nome do Pagador
             PadLeft(AEndereco, 40, ' ')                                   +  // 074 a 113 - Endere�o do Pagador
             PadLeft(ACBrTitulo.Sacado.Bairro, 15, ' ')                    +  // 114 a 128 - Bairro
             AValorCEP                                                     +  // 129 a 136 - CEP (Prefixo + Sufixo do CEP)
             PadLeft(ACBrTitulo.Sacado.Cidade, 15, ' ')                    +  // 137 a 151 - Cidade
             PadLeft(ACBrTitulo.Sacado.UF, 2, ' ')                         +  // 152 a 153 - Unidade Federativa
             TipoAvalista                                                  +  // 154 a 155 - Tipo de Inscri��o Sacado
             PadRight(ACBrTitulo.Sacado.SacadoAvalista.CNPJCPF, 14, '0')   +  // 155 a 169 - N�mero de inscri��o Sacado
             PadRight(ACBrTitulo.Sacado.SacadoAvalista.NomeAvalista,40,' ')+  // 170 a 209 - Nome do sacador/avalista
             Space(31);                                                       // 210 a 240 - Filler (Brancos)

  Result := wLinhaP + sLineBreak + wLinhaQ;
end;

procedure TACBrBancoBrasilSICOOB.LerRetorno240(ARetorno: TStringList);
var
  Titulo: TACBrTitulo;
  TempData, Linha, rCedente, rCNPJCPF  : String;
  ContLinha, idxMotivo                 : Integer;
begin
   // informa��o do Header
   // Verifica se o arquivo pertence ao banco
   if StrToIntDef(copy(ARetorno.Strings[0], 1, 3),-1) <> ACBrBanco.NumeroCorrespondente then
      raise Exception.create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                             'n�o' + '� um arquivo de retorno do ' + Nome));

   ACBrBanco.ACBrBoleto.DataArquivo := StringToDateTimeDef(Copy(ARetorno[0],189,2)+'/'+
                                                           Copy(ARetorno[0],191,2)+'/'+
                                                           Copy(ARetorno[0],193,4),0, 'DD/MM/YYYY' );

   ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0],158,6),0);

   rCedente := trim(copy(ARetorno[0], 71, 30));
   rCNPJCPF := OnlyNumber( copy(ARetorno[1], 136, 14) );

   ValidarDadosRetorno('', '', rCNPJCPF);
   with ACBrBanco.ACBrBoleto do
   begin

      Cedente.Nome := rCedente;
      Cedente.CNPJCPF := rCNPJCPF;

      case StrToIntDef(copy(ARetorno[1], 134, 2), 0) of
        01:
          Cedente.TipoInscricao := pFisica;
        else
          Cedente.TipoInscricao := pJuridica;
      end;

      ACBrBanco.ACBrBoleto.ListadeBoletos.Clear;
   end;

   ACBrBanco.TamanhoMaximoNossoNum := 20;

   for ContLinha := 1 to ARetorno.Count - 2 do
   begin
      Linha := ARetorno[ContLinha];

      if copy(Linha, 8, 1) <> '3' then // verifica se o registro (linha) � um registro detalhe (segmento J)
         Continue;

      Titulo := nil;

      if copy(Linha, 14, 1) = 'T' then // se for segmento T cria um novo titulo
         Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;

      if Assigned(Titulo) then
      with Titulo do
      begin
         if copy(Linha, 14, 1) = 'T' then
         begin
           SeuNumero := copy(Linha, 106, 25);
           NumeroDocumento := copy(Linha, 60, 15);
           Carteira := copy(Linha, 58, 2);

           TempData := copy(Linha, 75, 2) + '/'+copy(Linha, 77, 2)+'/'+copy(Linha, 79, 4);
           if TempData<>'00/00/0000' then
             Vencimento := StringToDateTimeDef(TempData, 0, 'DDMMYY');

           ValorDocumento := StrToFloatDef(copy(Linha, 83, 15), 0) / 100;

           NossoNumero := copy(Linha, 38, 20);
           ValorDespesaCobranca := StrToFloatDef(copy(Linha, 200, 15), 0) / 100;

           OcorrenciaOriginal.Tipo := CodOcorrenciaToTipo(StrToIntDef(copy(Linha, 16, 2), 0));

           IdxMotivo := 215;

           while (IdxMotivo < 225) do
           begin
             if (trim(Copy(Linha, IdxMotivo, 2)) <> '') then
             begin
                MotivoRejeicaoComando.Add(Copy(Linha, IdxMotivo, 2));
                DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(
                OcorrenciaOriginal.Tipo, StrToIntDef(Copy(Linha, IdxMotivo, 2), 0)));
             end;
             Inc(IdxMotivo, 2);
           end;
         end
         else // segmento U
         begin
           ValorIOF := StrToFloatDef(copy(Linha, 18, 15), 0) / 100;
           ValorAbatimento := StrToFloatDef(copy(Linha, 48, 15), 0) / 100;
           ValorDesconto := StrToFloatDef(copy(Linha, 33, 15), 0) / 100;
           ValorMoraJuros := StrToFloatDef(copy(Linha, 18, 15), 0) / 100;
           ValorOutrosCreditos := StrToFloatDef(copy(Linha, 123, 15), 0) / 100;
           ValorRecebido := StrToFloatDef(copy(Linha, 63, 15), 0) / 100;
           TempData := copy(Linha, 138, 2)+'/'+copy(Linha, 140, 2)+'/'+copy(Linha, 142, 4);

           if TempData<>'00/00/0000' then
             DataOcorrencia := StringToDateTimeDef(TempData, 0, 'DDMMYY');

           TempData := copy(Linha, 146, 2)+'/'+copy(Linha, 148, 2)+'/'+copy(Linha, 150, 4);

           if TempData<>'00/00/0000' then
             DataCredito := StringToDateTimeDef(TempData, 0, 'DDMMYYYY');
         end;
      end;
   end;
end;

end.
