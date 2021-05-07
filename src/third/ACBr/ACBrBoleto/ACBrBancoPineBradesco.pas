{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Juliana Tamizou                                 }
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

unit ACBrBancoPineBradesco;

interface

uses
  Classes, Contnrs, SysUtils, ACBrBoleto, ACBrBancoPine, ACBrBoletoConversao;

type


  { TACBrBancoPineBradesco }

  TACBrBancoPineBradesco = class(TACBrBancoPine)
  private
  protected
    function CalcularNossoNumero(const ACBrTitulo:TACBrTitulo): String; override;
    function CalcularCarteira(const ACBrTitulo:TACBrTitulo): String; override;
    function LerNossoNumero(const aLinha:String; ACBrTitulo : TACBrTitulo ):String;  override;
  public
    Constructor create(AOwner: TACBrBanco);
    function CalcularDigitoVerificador(const ACBrTitulo:TACBrTitulo): String; override;
    function MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String; override;
    function MontarCampoNossoNumero(const ACBrTitulo :TACBrTitulo): String; override;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String; override;
  end;

implementation

uses {$IFDEF COMPILER6_UP} dateutils {$ELSE} ACBrD5 {$ENDIF},
  StrUtils,
  ACBrUtil, ACBrValidador ;

{ TACBrBancoPineBradesco }


function TACBrBancoPineBradesco.CalcularNossoNumero(
  const ACBrTitulo: TACBrTitulo): String;
begin
  Result:=  StringOfChar('0', 11); {63 a 73 - Nosso Numero e DV Pine}

  if ACBrTitulo.ACBrBoleto.Cedente.ResponEmissao = tbCliEmite then
     Result:= Result + PadLeft(ACBrTitulo.NossoNumero +
                       CalcularDigitoVerificador(ACBrTitulo),13, '0')
  else
     Result:= Result + StringOfChar('0',13);

  Result:= Result + Space(3);
end;

function TACBrBancoPineBradesco.CalcularCarteira(const ACBrTitulo: TACBrTitulo
  ): String;
begin
  if ACBrBanco.ACBrBoleto.Cedente.ResponEmissao = tbCliEmite then
      Result:= '4'
   else
      Result:= '7';
end;

function TACBrBancoPineBradesco.LerNossoNumero(const aLinha: String;
  ACBrTitulo: TACBrTitulo): String;
begin
  Result:=inherited LerNossoNumero(aLinha, ACBrTitulo);
  ACBrTitulo.NossoNumeroCorrespondente:= Copy(aLinha, 95, TamanhoMaximoNossoNum);
end;

constructor TACBrBancoPineBradesco.create(AOwner: TACBrBanco);
begin
   inherited create(AOwner);
   fpNome                   := 'Bradesco';
   fpNumero                 := 237;
   fpTamanhoMaximoNossoNum  := 11;
   fpTamanhoAgencia         := 4;
   fpTamanhoConta           := 6;
   fpTamanhoCarteira        := 2;
   fCorrespondente          := True;
   fpNumeroCorrespondente   := 643;
end;

function TACBrBancoPineBradesco.CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String;
begin
   Modulo.CalculoPadrao;
   Modulo.MultiplicadorFinal := 7;
   Modulo.Documento := ACBrTitulo.Carteira + ACBrTitulo.NossoNumero;
   Modulo.Calcular;

   if Modulo.ModuloFinal = 1 then
      Result:= 'P'
   else
      Result:= IntToStr(Modulo.DigitoFinal);
end;

function TACBrBancoPineBradesco.MontarCodigoBarras ( const ACBrTitulo: TACBrTitulo) : String;
var
  CodigoBarras, FatorVencimento, DigitoCodBarras:String;
begin
   with ACBrTitulo.ACBrBoleto do
   begin
      FatorVencimento := CalcularFatorVencimento(ACBrTitulo.Vencimento);

      CodigoBarras := IntToStr( Numero )+'9'+ FatorVencimento +
                      IntToStrZero(Round(ACBrTitulo.ValorDocumento*100),10) +
                      PadLeft(OnlyNumber(Cedente.Agencia), fpTamanhoAgencia, '0') +
                      ACBrTitulo.Carteira +
                      ACBrTitulo.NossoNumero +
                      PadLeft(RightStr(Cedente.Conta,7),7,'0') + '0';

      DigitoCodBarras := CalcularDigitoCodigoBarras(CodigoBarras);
   end;

   Result:= IntToStr(Numero) + '9'+ DigitoCodBarras + Copy(CodigoBarras,5,39);
end;

function TACBrBancoPineBradesco.MontarCampoNossoNumero (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result:= ACBrTitulo.Carteira+'/'+ACBrTitulo.NossoNumero+'-'+CalcularDigitoVerificador(ACBrTitulo);
end;

function TACBrBancoPineBradesco.MontarCampoCodigoCedente (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result := ACBrTitulo.ACBrBoleto.Cedente.Agencia+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito+'/'+
             ACBrTitulo.ACBrBoleto.Cedente.Conta+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.ContaDigito;
end;

end.



