{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Juliana Tamizou, Jos� M S Junior                }
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

unit ACBrBancoUnicredSC;

interface

uses
  Classes, SysUtils, ACBrBoleto, ACBrBancoUnicredRS, ACBrBoletoConversao;

type

  { TACBrBancoUnicredSC }

  TACBrBancoUnicredSC = class(TACBrBancoUnicredRS)
  protected
    function DefineEspecieDoc(const ACBrTitulo: TACBrTitulo): String; override;
    function DefineCampoLivreCodigoBarras(const ACBrTitulo: TACBrTitulo):String; override;

  public
    Constructor create(AOwner: TACBrBanco);
    procedure GerarRegistroTransacao400(ACBrTitulo : TACBrTitulo; aRemessa: TStringList); override;

  end;

implementation

uses {$IFDEF COMPILER6_UP} dateutils {$ELSE} ACBrD5 {$ENDIF},
  StrUtils, ACBrUtil ;

{ TACBrBancoUnicredSC }

constructor TACBrBancoUnicredSC.create(AOwner: TACBrBanco);
begin
   inherited create(AOwner);
   fpDigito                 := 2;
   fpNome                   := 'BRADESCO';
   fpNumero                 := 237;
   fpTamanhoMaximoNossoNum  := 11;
   fpTamanhoAgencia         := 4;
   fpTamanhoConta           := 7;
   fpTamanhoCarteira        := 3;
   fpCodParametroMovimento  := 'MX';
   fpModuloMultiplicadorFinal := 7;

end;

function TACBrBancoUnicredSC.DefineEspecieDoc(const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo do
  begin
    if trim(EspecieDoc) = 'DM' then
       Result:= '01'
    else if trim(EspecieDoc) = 'NP' then
       Result:= '02'
    else if trim(EspecieDoc) = 'NS' then
       Result:= '03'
    else if trim(EspecieDoc) = 'CS' then
       Result:= '04'
    else if trim(EspecieDoc) = 'REC' then
       Result:= '05'
    else if trim(EspecieDoc) = 'LC' then
       Result:= '10'
    else if trim(EspecieDoc) = 'ND' then
       Result:= '11'
    else if trim(EspecieDoc) = 'DS' then
       Result:= '12'
    else if trim(EspecieDoc) = 'OU' then
       Result:= '99'
    else
       Result := EspecieDoc;
  end;

end;

function TACBrBancoUnicredSC.DefineCampoLivreCodigoBarras(
  const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo.ACBrBoleto do
  begin
    Result := PadLeft(OnlyNumber(Cedente.Agencia), fpTamanhoAgencia, '0') +{20-23: Campo Livre 1 - Ag�ncia }
              PadLeft(copy(ACBrTitulo.Carteira,2,2),2,'0') +               {24-25: Carteira }
              PadLeft(ACBrTitulo.NossoNumero,11,'0') +                     {26-36: Campo Livre 3 - Nosso N�m }
              PadLeft(RightStr(Cedente.Conta,7),7,'0')+                    {37-43: Conta do Benifici�rio}
              '0';                                                         {44-44: Zero}
  end;
end;

procedure TACBrBancoUnicredSC.GerarRegistroTransacao400(ACBrTitulo :TACBrTitulo; aRemessa: TStringList);
var
  sDigitoNossoNumero, sOcorrencia, sEspecie, sAgencia : String;
  sProtesto, sTipoSacado, sMensagemCedente, sConta    : String;
  sLinha, sNossoNumero : String;
begin
   with ACBrTitulo do
   begin
     ValidaNossoNumeroResponsavel(sNossoNumero, sDigitoNossoNumero, ACBrTitulo);
     sAgencia      := IntToStrZero(StrToIntDef(OnlyNumber(ACBrBoleto.Cedente.Agencia), 0), 4);
     sConta        := IntToStrZero(StrToIntDef(OnlyNumber(ACBrBoleto.Cedente.Conta)  , 0), 7);

     {Pegando C�digo da Ocorrencia}
     sOcorrencia:= TipoOcorrenciaToCodRemessa(OcorrenciaOriginal.Tipo);

     {Pegando Especie}
     sEspecie:= DefineEspecieDoc(ACBrTitulo);

     {Pegando campo Intru��es}
      sProtesto:= InstrucoesProtesto(ACBrTitulo);

     {Pegando Tipo de Sacado}
      sTipoSacado := DefineTipoSacado(ACBrTitulo);

     with ACBrBoleto do
     begin
       if Mensagem.Text <> '' then
          sMensagemCedente:= Mensagem[0];

       sLinha:= '1'                                                     + {001-001: ID Registro }
                space(19)                                               + {002-020: Espa�o Vazio - Caso d�bito autom�tico deve preenxer}
                '0'                                                     + {021-021: Fixar Zero}
                '009'                                                   + {022-024: Fixar �009� (Cobran�a Registrado)}
                '0'                                                     + {025-025: Fixar Zero}
                sAgencia                                                + {026-029: Ag�ncia }
                PadLeft(sConta, 07, '0')                                + {030-036: Conta Corrente }
                Cedente.ContaDigito                                     + {037-037: Conta Corrente D�gito }
                PadRight(SeuNumero, 25, ' ')                            + {038-062: Numero Controle do Participante }
                '000'                                                   + {063-065: Espa�o Vazio - caso d�bito autom�tico preenxer com 237}

                IfThen(PercentualMulta > 0, '2', '0')                   + {066-066: Indica��o de multa}
                IfThen(PercentualMulta > 0,
                                  IntToStrZero(Round(PercentualMulta * 100), 4),
                                  PadRight('', 4, '0')) +                 {067-070: Percentual da multa }
                PadLeft(sNossoNumero, 11, '0')                          + {071-081: Nosso N�mero }
                PadLeft(sDigitoNossoNumero, 1, '0')                     + {082-082: Digito Verificador do Nosso N�mero }
                IntToStrZero( round( ValorDescontoAntDia * 100), 10)    + {083-092: Desconto bonifica��o por dia}
                '2'                                                     + {093-093: Quem emite o boleto}
                ' '                                                     + {094-094: Identifica��o se emite boleto para d�bito autom�tico}
                Space(10)                                               + {095-104: Identifica��o da opera��o no banco}
                ' '                                                     + {105-105: Indicador Rateio de Credito }
                '2'                                                     + {106-106: N�o emite aviso de  D�bito Autom�tico em Conta Corrente}
                Space(2)                                                + {107-108: Quantidade poss�veis de pagamento}
                sOcorrencia                                             + {109-110: Ocorr�ncia}
                PadRight(NumeroDocumento, 10)                           + {111-120: N�mero DOcumento }
                FormatDateTime('ddmmyy', Vencimento)                    + {121-126: Vencimento }
                IntToStrZero(Round(ValorDocumento * 100 ), 13)          + {127-139: Valor do T�tulo }
                '000'                                                   + {140-142: Banco Encarregado da Cobran�a}
                '00000'                                                 + {143-147: Ag�ncia Deposit�ria}
                sEspecie                                                + {148-149: Especie}
                'N'                                                     + {150-150: Aceite, Sempre com 'N'}
                FormatDateTime('ddmmyy', DataDocumento)                 + {151-156: Data de Emiss�o }
                sProtesto                                               + {157-158:159-160 Protesto-Quantidade de dias }
                IntToStrZero(Round(ValorMoraJuros * 100), 13)           + {161-173: Valor por dia de Atraso }
                IfThen(DataDesconto < 0, '000000',
                       FormatDateTime('ddmmyy', DataDesconto))          + {174-179: Data Limite Desconto }
                IntToStrZero(Round(ValorDesconto * 100), 13)            + {180-192: Valor Desconto }
                IntToStrZero( round( ValorIOF * 100 ), 13)              + {193-205: Valor IOF }
                IntToStrZero(Round(ValorAbatimento * 100), 13)          + {206-218: Valor Abatimento }
                sTipoSacado                                             + {219-220: Tipo Inscri��o Sacado }
                PadLeft(OnlyNumber(Sacado.CNPJCPF), 14, '0')            + {221-234: N�m. Incri��o Sacado }
                PadRight(Sacado.NomeSacado, 40, ' ')                    + {235-274: Nome do Sacado }
                PadRight(Sacado.Logradouro + ' ' + Sacado.Numero, 40)   + {275-314: Endere�o do Sacado }
                PadRight(sMensagemCedente, 12)                          + {315-326: 1� Mensagem}
                PadRight(Sacado.CEP, 8, ' ')                            + {327-334: CEP do Sacado }
                PadRight(Sacado.Bairro, 20, ' ')                        + {335-354: Bairro do Sacado }
                PadRight(Sacado.Cidade, 38, ' ')                        + {355-392: Cidade do Sacado }
                PadRight(Sacado.UF, 2, ' ')                             + {393-394: UF Cidade do Sacado }
                IntToStrZero(aRemessa.Count + 1, 6);                      {395-400: N�m Sequencial arquivo }

       aRemessa.Add(UpperCase(sLinha));

       sLinha := MontaInstrucoesCNAB400(ACBrTitulo, aRemessa.Count );
       if not(sLinha = EmptyStr) then
         aRemessa.Add(UpperCase(sLinha));
     end;
   end;

end;

end.


