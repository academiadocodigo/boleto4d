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

unit ACBrBancoDaycoval;

interface

uses
  Classes, SysUtils, Contnrs, ACBrBoleto, ACBrBoletoConversao;

type
  { TACBrBancoDaycoval }

  TACBrBancoDaycoval = class(TACBrBancoClass)
  protected
  private
    procedure GerarRegistrosNFe(ACBrTitulo : TACBrTitulo; aRemessa: TStringList);
  public
    Constructor create(AOwner: TACBrBanco);
    function CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String; override ;
    function MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String; override;
    function MontarCampoNossoNumero ( const ACBrTitulo: TACBrTitulo) : String; override;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String; override;

    procedure GerarRegistroHeader400(NumeroRemessa : Integer; aRemessa: TStringList); override;
    procedure GerarRegistroTransacao400(ACBrTitulo : TACBrTitulo; aRemessa: TStringList); override;
    procedure GerarRegistroTrailler400(ARemessa : TStringList);  override;

    Procedure LerRetorno400(ARetorno:TStringList); override;

    function TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia) : String; override;
    function CodOcorrenciaToTipo(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
    function TipoOCorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia):String; override;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
    function CalcularNomeArquivoRemessa : String; override;
   end;

implementation

uses
  {$IFDEF COMPILER6_UP} dateutils {$ELSE} ACBrD5 {$ENDIF},
  StrUtils, Variants,
  ACBrValidador, ACBrUtil;

{ TACBrBancoDaycoval }

function CodMotivoRejeicaoToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia; const CodMotivo: String): String;
begin
  case TipoOcorrencia of
    toRetornoRegistroRecusado :
    begin
      if ( CodMotivo = '03' ) then Result := '03-CEP inv�lido � N�o temos cobrador � Cobrador n�o Localizado'
      else
      if ( CodMotivo = '04' ) then Result := '04-Sigla do Estado inv�lida'
      else
      if ( CodMotivo = '05' ) then Result := '05-Data de Vencimento inv�lida ou fora do prazo m�nimo'
      else
      if ( CodMotivo = '06' ) then Result := '06-C�digo do Banco inv�lido'
      else
      if ( CodMotivo = '08' ) then Result := '08-Nome do sacado n�o informado'
      else
      if ( CodMotivo = '10' ) then Result := '10-Logradouro n�o informado'
      else
      if ( CodMotivo = '14' ) then Result := '14-Registro em duplicidade'
      else
      if ( CodMotivo = '19' ) then Result := '19-Data de desconto inv�lida ou maior que a data de vencimento'
      else
      if ( CodMotivo = '20' ) then Result := '20-Valor de IOF n�o num�rico'
      else
      if ( CodMotivo = '22' ) then Result := '22-Valor de desconto + abatimento maior que o valor do t�tulo'
      else
      if ( CodMotivo = '25' ) then Result := '25-CNPJ ou CPF do sacado inv�lido (aceito com restri��es)'
      else
      if ( CodMotivo = '26' ) then Result := '26-Esp�cies de documento inv�lida (difere de 01...10,13 e 99)'
      else
      if ( CodMotivo = '27' ) then Result := '27-Data de emiss�o do t�tulo inv�lida'
      else
      if ( CodMotivo = '28' ) then Result := '28-Seu n�mero n�o informado'
      else
      if ( CodMotivo = '29' ) then Result := '29-CEP � igual a espa�o ou zeros; ou n�o num�rico'
      else
      if ( CodMotivo = '30' ) then Result := '30-Valor do t�tulo n�o num�rico ou inv�lido'
      else
      if ( CodMotivo = '36' ) then Result := '36-Valor de perman�ncia n�o num�rico'
      else
      if ( CodMotivo = '15' ) then Result := '15-37'
      else
      if ( CodMotivo = 'Va' ) then Result := 'Valor -or de perman�ncia inconsistente, pois, dentro de um m�s, ser� maior que o valor do t�tulo'
      else
      if ( CodMotivo = '38' ) then Result := '38-Valor de desconto/abatimento n�o num�rico ou inv�lido'
      else
      if ( CodMotivo = '39' ) then Result := '39-Valor de abatimento n�o num�rico'
      else
      if ( CodMotivo = '42' ) then Result := '42-T�tulo j� existente em nossos registros. Nosso n�mero n�o aceito'
      else
      if ( CodMotivo = '43' ) then Result := '43-T�tulo enviado em duplicidade nesse movimento'
      else
      if ( CodMotivo = '44' ) then Result := '44-T�tulo zerado ou em branco; ou n�o num�rico na remessa'
      else
      if ( CodMotivo = '46' ) then Result := '46-T�tulo enviado fora da faixa de Nosso N�mero, estipulada para o cliente.'
      else
      if ( CodMotivo = '51' ) then Result := '51-Tipo/N�mero de Inscri��o Sacador/Avalista Inv�lido'
      else
      if ( CodMotivo = '53' ) then Result := '53-Prazo de vencimento do t�tulo excede ao da contrata��o'
      else
      if ( CodMotivo = '54' ) then Result := '54-Banco informado n�o � nosso correspondente 140-142'
      else
      if ( CodMotivo = '55' ) then Result := '55-Banco correspondente informado n�o cobra este CEP ou n�o possui faixas de CEP cadastradas'
      else
      if ( CodMotivo = '56' ) then Result := '56-Nosso n�mero no correspondente n�o foi informado'
      else
      if ( CodMotivo = '57' ) then Result := '57-Remessa contendo duas instru��es incompat�veis � n�o protestar e dias de protesto ou prazo para protesto inv�lido.'
      else
      if ( CodMotivo = '58' ) then Result := '58-Entradas Rejeitadas � Reprovado no Represamento para An�lise'
      else
      if ( CodMotivo = '60' ) then Result := '60-CNPJ/CPF do sacado inv�lido � t�tulo recusado'
      else
      if ( CodMotivo = '87' ) then Result := '87-Excede Prazo m�ximo entre emiss�o e vencimento'
      else
      if ( CodMotivo = '99' ) then Result := '99-T�tulo n�o acatado pelo banco � entrar em contato Gerente da conta'
      else
      if ( CodMotivo = 'AE' ) then Result := 'AE-T�tulo n�o possui abatimento'
      else
      if ( CodMotivo = 'AG' ) then Result := 'AG-Movimento n�o permitido � T�tulo � vista ou contra apresenta��o'
      else
      if ( CodMotivo = 'AK' ) then Result := 'AK-T�tulo pertence a outro cliente'
      else
      if ( CodMotivo = 'AL' ) then Result := 'AL-Sacado impedido de entrar nesta cobran�a'
      else
      if ( CodMotivo = 'AY' ) then Result := 'AY-T�tulo deve estar em aberto e vencido para acatar protesto'
      else
      if ( CodMotivo = 'BC' ) then Result := 'BC-An�lise gerencial-sacado inv�lido p/opera��o cr�dito'
      else
      if ( CodMotivo = 'BD' ) then Result := 'BD-An�lise gerencial-sacado inadimplente'
      else
      if ( CodMotivo = 'BE' ) then Result := 'BE-An�lise gerencial-sacado difere do exigido'
      else
      if ( CodMotivo = 'BF' ) then Result := 'BF-An�lise gerencial-vencto excede vencto da opera��o de cr�dito'
      else
      if ( CodMotivo = 'BG' ) then Result := 'BG-An�lise gerencial-sacado com baixa liquidez'
      else
      if ( CodMotivo = 'BH' ) then Result := 'BH-An�lise gerencial-sacado excede concentra��o'
      else
      if ( CodMotivo = 'CB' ) then Result := 'CB-T�tulo possui protesto efetivado/a efetivar hoje'
      else
      if ( CodMotivo = 'CC' ) then Result := 'CC-Valor de iof incompat�vel com a esp�cie documento'
      else
      if ( CodMotivo = 'CD' ) then Result := 'CD-Efetiva��o de protesto sem agenda v�lida'
      else
      if ( CodMotivo = 'CE' ) then Result := 'CE-T�tulo n�o aceito - pessoa f�sica'
      else
      if ( CodMotivo = 'CF' ) then Result := 'CF-Excede prazo m�ximo da entrada ao vencimento'
      else
      if ( CodMotivo = 'CG' ) then Result := 'CG-T�tulo n�o aceito � por an�lise gerencial'
      else
      if ( CodMotivo = 'CH' ) then Result := 'CH-T�tulo em espera � em an�lise pelo banco'
      else
      if ( CodMotivo = 'CJ' ) then Result := 'CJ-An�lise gerencial-vencto do titulo abaixo przcurto'
      else
      if ( CodMotivo = 'CK' ) then Result := 'CK-An�lise gerencial-vencto do titulo abaixo przlongo'
      else
      if ( CodMotivo = 'CS' ) then Result := 'CS-T�tulo rejeitado pela checagem de duplicatas'
      else
      if ( CodMotivo = 'CT' ) then Result := 'CT-T�tulo j� baixado'
      else
      if ( CodMotivo = 'DA' ) then Result := 'DA-An�lise gerencial � Entrada de T�tulo Descontado com limite cancelado'
      else
      if ( CodMotivo = 'DB' ) then Result := 'DB-An�lise gerencial � Entrada de T�tulo Descontado com limite vencido'
      else
      if ( CodMotivo = 'DC' ) then Result := 'DC-An�lise gerencial - cedente com limite cancelado'
      else
      if ( CodMotivo = 'DD' ) then Result := 'DD-An�lise gerencial � cedente � sacado e teve seu limite cancelado'
      else
      if ( CodMotivo = 'DE' ) then Result := 'DE-An�lise gerencial - apontamento no Serasa'
      else
      if ( CodMotivo = 'DG' ) then Result := 'DG-Endere�o sacador/avalista n�o informado'
      else
      if ( CodMotivo = 'DH' ) then Result := 'DH-Cep do sacador/avalista n�o informado'
      else
      if ( CodMotivo = 'DI' ) then Result := 'DI-Cidade do sacador/avalista n�o informado'
      else
      if ( CodMotivo = 'DJ' ) then Result := 'DJ-Estado do sacador/avalista inv�lido ou n informado'
      else
      if ( CodMotivo = 'DM' ) then Result := 'DM-Cliente sem C�digo de Flash cadastrado no cobrador'
      else
      if ( CodMotivo = 'DN' ) then Result := 'DN-T�tulo Descontado com Prazo ZERO � Recusado'
      else
      if ( CodMotivo = 'DO' ) then Result := 'DO-T�tulo em Preju�zo'
      else
      if ( CodMotivo = 'DP' ) then Result := 'DP-Data de Refer�ncia menor que a Data de Emiss�o do T�tulo'
      else
      if ( CodMotivo = 'DT' ) then Result := 'DT-Nosso N�mero do Correspondente n�o deve ser informado'
      else
      if ( CodMotivo = 'EB' ) then Result := 'EB-HSBC n�o aceita endere�o de sacado com mais de 38 caracteres'
      else
        Result := CodMotivo + '-Motivo desconhecido';
    end;
    toRetornoBaixaRejeitada :
    begin
      if ( CodMotivo = '05' ) then Result := '05-Solicita��o de baixa para t�tulo j� baixado ou liquidado'
      else
      if ( CodMotivo = '06' ) then Result := '06-Solicita��o de baixa para t�tulo n�o registrado no sistema'
      else
      if ( CodMotivo = '08' ) then Result := '08-Solicita��o de baixa para t�tulo em float'
      else
        Result := CodMotivo + '-Motivo desconhecido';
    end;
    toRetornoInstrucaoRejeitada :
    begin
      if ( CodMotivo = '04' ) then Result := '04-Data de Vencimento n�o num�rica ou inv�lida'
      else
      if ( CodMotivo = '14' ) then Result := '14-Registro em duplicidade'
      else
      if ( CodMotivo = '20' ) then Result := '20-Campo livre informado'
      else
      if ( CodMotivo = '21' ) then Result := '21-T�tulo n�o registrado no sistema'
      else
      if ( CodMotivo = '22' ) then Result := '22-T�tulo baixada ou liquidado'
      else
      if ( CodMotivo = '27' ) then Result := '27-Instru��o n�o aceita, p�r n�o ter sido emitida ordem de protesto ao cart�rio'
      else
      if ( CodMotivo = '28' ) then Result := '28-T�tulo tem instru��o de cart�rio ativa'
      else
      if ( CodMotivo = '29' ) then Result := '29-T�tulo n�o tem instru��o de cart�rio ativa'
      else
      if ( CodMotivo = '30' ) then Result := '30-Existe instru��o de n�o protestar, ativa para o t�tulo'
      else
      if ( CodMotivo = '37' ) then Result := '37-T�tulo Descontado Instru��o n�o permitida para a carteira'
      else
      if ( CodMotivo = '38' ) then Result := '38-Valor do abatimento n�o num�rico ou maior que a soma do valor do t�tulo + perman�ncia + multa'
      else
      if ( CodMotivo = '49' ) then Result := '49-T�tulo em cart�rio'
      else
      if ( CodMotivo = '40' ) then Result := '40-Instru��o recusada - cobran�a vinculada / caucionada'
      else
      if ( CodMotivo = '99' ) then Result := '99-Ocorr�ncia desconhecida na remessa'
      else
        Result := CodMotivo + '-Motivo desconhecido';
    end;
  end;
end;

constructor TACBrBancoDaycoval.create(AOwner: TACBrBanco);
begin
   inherited create(AOwner);
   fpDigito                := 2;
   fpNome                  := 'Banco Daycoval';
   fpNumero                := 707;
   fpTamanhoMaximoNossoNum := 10;
   fpTamanhoAgencia        := 4;
   fpTamanhoConta          := 7;
   fpTamanhoCarteira       := 3;
end;

function TACBrBancoDaycoval.CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String;
var
  Docto: String;
begin
   Result := '0';
   Docto := '';

   with ACBrTitulo do
   begin
      if MatchText( Carteira , ['116','117','119','134','135','136','104',
      '147','105','112','212','166','113','126','131','145','150','168']) then
            Docto := Carteira + PadLeft(NossoNumero,TamanhoMaximoNossoNum,'0')
         else
            Docto := ACBrBoleto.Cedente.Agencia +
                     Carteira + PadLeft(ACBrTitulo.NossoNumero,TamanhoMaximoNossoNum,'0')
   end;

   Modulo.MultiplicadorInicial := 1;
   Modulo.MultiplicadorFinal   := 2;
   Modulo.MultiplicadorAtual   := 2;
   Modulo.FormulaDigito := frModulo10;
   Modulo.Documento:= Docto;
   Modulo.Calcular;
   Result := IntToStr(Modulo.DigitoFinal);

end;

function TACBrBancoDaycoval.MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String;
var
  CodigoBarras, FatorVencimento, DigitoCodBarras :String;
  ANossoNumero, aAgenciaCC : string;
begin
  {Codigo de Barras}
  with ACBrTitulo.ACBrBoleto do
  begin
     FatorVencimento := CalcularFatorVencimento(ACBrTitulo.Vencimento);

     ANossoNumero := PadLeft(ACBrTitulo.NossoNumero,10,'0') +
                     CalcularDigitoVerificador(ACBrTitulo);

     aAgenciaCC   := Cedente.Agencia +
                     Cedente.Conta   +
                     Cedente.ContaDigito;

     aAgenciaCC:= OnlyNumber(aAgenciaCC);

     CodigoBarras := IntToStr( Numero ) +
                     '9' +
                     FatorVencimento +
                     IntToStrZero(Round(ACBrTitulo.ValorDocumento * 100), 10) +
                     Cedente.Agencia +
                     ACBrTitulo.Carteira +
                     Cedente.Operacao +
                     ANossoNumero;

     DigitoCodBarras := CalcularDigitoCodigoBarras(CodigoBarras);
  end;

  Result:= copy( CodigoBarras, 1, 4) + DigitoCodBarras + copy( CodigoBarras, 5, 39) ;
end;

function TACBrBancoDaycoval.MontarCampoNossoNumero ( const ACBrTitulo: TACBrTitulo
   ) : String;
var
  NossoNr: String;
begin
  with ACBrTitulo do
  begin
    NossoNr := Carteira + PadLeft(NossoNumero,TamanhoMaximoNossoNum,'0');
  end;

  Insert('/',NossoNr,4);  Insert('-',NossoNr,15);
  Result := NossoNr + CalcularDigitoVerificador(ACBrTitulo);
end;

function TACBrBancoDaycoval.MontarCampoCodigoCedente (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result := ACBrTitulo.ACBrBoleto.Cedente.Agencia + '-' + ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito +'/'+
             ACBrTitulo.ACBrBoleto.Cedente.Conta    +'-'+
             ACBrTitulo.ACBrBoleto.Cedente.ContaDigito;
end;

procedure TACBrBancoDaycoval.GerarRegistroHeader400(
  NumeroRemessa: Integer; aRemessa: TStringList);
var
  wLinha: String;
begin
  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    wLinha :=
      '0' +                             // C�digo do registro: 0 - Header
      '1' +                             // C�digo do arquivo: 1 - Remessa
      'REMESSA' +                       // Identifica��o do arquivo
      '01' +                            // C�digo do servi�o
      PadRight('COBRANCA',15) +         // Identifica��o do servi�o
      PadRight(CodigoCedente, 20) +     // C�digo da empresa no banco
      //Space(8) +                        // Brancos
      PadRight(Nome, 30) +              // Nome da empresa
      '707' +                           // C�digo do banco: 707 = Banco Daycoval
      PadRight('BANCO DAYCOVAL', 15) +  // Nome do banco
      FormatDateTime('ddmmyy', Now) +   // Data de grava��o
      Space(294) +                      // Brancos
      IntToStrZero(1, 6);               // N�mero sequencial do registro

    ARemessa.Text:= ARemessa.Text + UpperCase(wLinha);
  end;
end;

procedure TACBrBancoDaycoval.GerarRegistrosNFe(ACBrTitulo: TACBrTitulo;  aRemessa: TStringList);
var
  wQtdRegNFes, J, I: Integer;
  wLinha, NFeSemDados: String;
  Continua: Boolean;
begin  // Obrigatorio o envio da linha referente a nota fiscal 
  NFeSemDados:= StringOfChar(' ',15) + StringOfChar('0', 65);
  wQtdRegNFes:= trunc(ACBrTitulo.ListaDadosNFe.Count / 3);

  if (ACBrTitulo.ListaDadosNFe.Count mod 3) <> 0 then
     Inc(wQtdRegNFes);

  J:= 0;
  I:= 0;
  repeat
   begin
      Continua:=  true;

      wLinha:= '4';
      while (Continua) and (J < ACBrTitulo.ListaDadosNFe.Count) do
      begin
         wLinha:= wLinha +
                  PadRight(ACBrTitulo.ListaDadosNFe[J].NumNFe,15) +
                  IntToStrZero( round(ACBrTitulo.ListaDadosNFe[J].ValorNFe  * 100 ), 13) +
                  FormatDateTime('ddmmyyyy',ACBrTitulo.ListaDadosNFe[J].EmissaoNFe)      +
                  PadLeft(ACBrTitulo.ListaDadosNFe[J].ChaveNFe, 44, '0');

         Inc(J);
         Continua:= (J mod 3) <> 0 ;
      end;
	  
      wLinha:= PadRight(wLinha,81) + StringOfChar(' ', 313) +  IntToStrZero(aRemessa.Count + 1, 6);
      aRemessa.Add(wLinha);
      Inc(I);
   end;
  until (I = wQtdRegNFes) ;
end;

procedure TACBrBancoDaycoval.GerarRegistroTransacao400( ACBrTitulo: TACBrTitulo; aRemessa: TStringList);
var
  ATipoOcorrencia, AEspecieDoc, ACodigoRemessa : String;
  DiasProtesto, TipoSacado, ATipoAceite: String;
  wLinha: String;
begin
  with ACBrTitulo do
  begin
    // Definindo o c�digo da ocorr�ncia.
    case OcorrenciaOriginal.Tipo of
      toRemessaBaixar            : ATipoOcorrencia := '02'; // Pedido de baixa
      toRemessaConcederAbatimento: ATipoOcorrencia := '04'; // Concess�o de abatimento
      toRemessaCancelarAbatimento: ATipoOcorrencia := '05'; // Cancelamento de abatimento concedido
      toRemessaAlterarVencimento : ATipoOcorrencia := '06'; // Altera��o de vencimento
      toRemessaAlterarUsoEmpresa : ATipoOcorrencia := '07'; // Altera��o "Uso Exclusivo do Cliente"
      toRemessaAlterarSeuNumero  : ATipoOcorrencia := '08'; // Altera��o de "Seu N�mero"
      toRemessaProtestar         : ATipoOcorrencia := '09'; // Pedido de protesto
      toRemessaNaoProtestar      : ATipoOcorrencia := '10'; // N�o protestar
      toRemessaDispensarJuros    : ATipoOcorrencia := '11'; // N�o cobrar juros de mora
    else
      ATipoOcorrencia := '01'; // Remessa
    end;

    // Definindo a esp�cie do t�tulo.
    if AnsiSameText(EspecieDoc, 'DM') then
      AEspecieDoc := '01'
    else if AnsiSameText(EspecieDoc, 'NP') then
      AEspecieDoc := '02'
    else if AnsiSameText(EspecieDoc, 'NS') then
      AEspecieDoc := '03'
    else if AnsiSameText(EspecieDoc, 'RC') then
      AEspecieDoc := '05'
    else if AnsiSameText(EspecieDoc, 'DS') then
      AEspecieDoc := '09'
    else
      AEspecieDoc := EspecieDoc;

    if (DataProtesto > 0) and (DataProtesto > Vencimento) then
      DiasProtesto := IntToStrZero(DaysBetween(DataProtesto,Vencimento), 2)
    else
      DiasProtesto := '00';

    // Definindo o tipo de inscri��o do sacado.
    case Sacado.Pessoa of
      pFisica  : TipoSacado := '01';
      pJuridica: TipoSacado := '02';
    else
      TipoSacado := '03';
    end;

    // Conforme manual o aceite deve ser sempre 'N'
    ATipoAceite := 'N';

    // C�digo de Remessa Fixo 6
    ACodigoRemessa := '6';

    with ACBrBoleto do
    begin
      wLinha :=
        '1' +                                                        // 1 - C�digo do registro: 1 - Transa��o
        TipoSacado +                                                 // 2 a 3 - Tipo de inscri��o da empresa: 01 = CPF; 02 = CNPJ
        PadLeft(OnlyNumber(Cedente.CNPJCPF), 14, '0') +              // 4 a 17 - N�mero de inscri��o
        PadRight(Cedente.CodigoCedente, 20) +                        // 18 a 37 - C�digo da empresa no banco
        PadRight(SeuNumero, 25) +                                    // 38 a 62 - Identifica��o do t�tulo na empresa
        Copy(PadLeft(NossoNumero,TamanhoMaximoNossoNum,'0'), 3, 8) + // 63 a 70 - Nosso n�mero
        Space(13) +                                                  // 71 a 83 - Brancos
        Space(24) +                                                  // 84 a 107 - Brancos
        ACodigoRemessa +                                             // 108 - C�digo da Remessa
        ATipoOcorrencia +                                            // 109 a 110 - C�digo da ocorr�ncia
        PadLeft(RightStr(SeuNumero,10), 10, ' ') +                   // 111 a 120 - Identifica��o do t�tulo na empresa
        FormatDateTime('ddmmyy', Vencimento) +                       // 121 a 126 - Data de vencimento do t�tulo
        IntToStrZero(Round(ValorDocumento * 100), 13) +              // 127 a 139 - Valor nominal do t�tulo
        '707' +                                                      // 140 a 142 - Banco encarregado da cobran�a: 707 = Banco Daycoval
        '00000' +                                                    // 143 a 147 - Ag�ncia encarregada da cobran�a + digito
        AEspecieDoc +                                                // 148 a 149 - Esp�cie do t�tulo
        ATipoAceite +                                                // 150 - Identifica��o de aceite do t�tulo: A = Aceito; N = N�o aceito
        FormatDateTime('ddmmyy', DataDocumento) +                    // 151 a 156 - Data de emiss�o do t�tulo
        PadLeft('', 2, '0') +                                        // 157 a 158 - zeros
        PadLeft('', 2, '0') +                                        // 159 a 160 - zeros
        PadLeft('', 13, '0') +                                       // 161 a 173 - zeros
        IfThen(DataDesconto > 0,
          FormatDateTime('ddmmyy', DataDesconto), '000000') +        // 174 a 179 - Data limite para desconto
        IntToStrZero(Round(ValorDesconto * 100), 13) +               // 180 a 192 - Valor do desconto
        PadLeft('', 13, '0') +                                       // 193 a 205 - ZEROS
        PadLeft('', 13, '0') +                                       // 206 a 218 - Para ocorr�ncia 01: Manter zeros -Para ocorr�ncia 04: Informar valor a ser concedido para abatimento.
        TipoSacado +                                                 // 219 a 220 - Tipo de inscri��o do sacado: 01 � CPF; 02 � CGC
        PadLeft(OnlyNumber(Sacado.CNPJCPF), 14, '0') +               // 221 a 234 - N�mero de inscri��o do sacado
        PadRight(Sacado.NomeSacado, 30, ' ') +                       // 235 a 264 - Nome do sacado
        Space(10) +                                                  // 265 a 274 - Brancos
        PadRight(Sacado.Logradouro + ' ' + Sacado.Numero + ' ' + Sacado.Complemento, 40, ' ') +     // 275 a 314 - Endere�o do sacado
        PadRight(Sacado.Bairro, 12, ' ') +                           // 315 a 326 - Bairro do sacado
        PadRight(OnlyNumber(Sacado.CEP), 8, '0') +                   // 327 a 334 - CEP do sacado
        PadRight(Sacado.Cidade, 15, ' ') +                           // 335 a 349 - Cidade do sacado
        PadRight(Sacado.UF, 2, ' ') +                                // 350 a 351 - UF do sacado
        PadRight(Sacado.SacadoAvalista.NomeAvalista,30) +            // 352 a 381 - Nome do sacador avalista
        Space(4) +                                                   // 382 a 385 - Brancos
        Space(6) +                                                   // 386 a 391 - Brancos
        PadLeft('', 2, '0') +                                        // 392 a 393 - zeros
        '0' ;                                                        // 394 - Moeda 0=Moeda nacional atual 3=Dolar

      wLinha := wLinha + IntToStrZero(ARemessa.Count + 1, 6);        // 395 a 400 - N�mero sequencial do registro

      ARemessa.Text := ARemessa.Text + UpperCase(wLinha);
    end;
  end;

  if ACBrTitulo.ListaDadosNFe.Count > 0 then  //Informa��es da nota fiscal 
    GerarRegistrosNFe(ACBrTitulo, aRemessa);
end;

procedure TACBrBancoDaycoval.GerarRegistroTrailler400(
  ARemessa: TStringList);
var
  wLinha: String;
begin
  wLinha :=
    '9' +                                // C�digo do registro: 9 - Trailler
    Space(393) +                         // Brancos
    IntToStrZero(ARemessa.Count + 1, 6); // N�mero sequencial do registro

  ARemessa.Text := ARemessa.Text + UpperCase(wLinha);
end;

procedure TACBrBancoDaycoval.LerRetorno400(ARetorno: TStringList);
var
  Titulo: TACBrTitulo;
  ContLinha: Integer;
  CodMotivo: String;
  Linha, rCedente, rCNPJCPF: String;
  rCodEmpresa: String;
begin
  // Foi necess�rio utilizar o n�mero e nome do Banco Daycoval
  fpNumero := 707;
  fpNome   := 'Banco Daycoval';

  if StrToIntDef(Copy(ARetorno.Strings[0], 77, 3), -1) <> Numero then
    raise Exception.Create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
      ' n�o � um arquivo de retorno do ' + Nome));

  rCodEmpresa  := Trim(Copy(ARetorno[0], 27, 20));
  rCedente     := Trim(Copy(ARetorno[0], 47, 30));

  ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0], 109, 5), 0);

  ACBrBanco.ACBrBoleto.DataArquivo :=
    StringToDateTimeDef(
      Copy(ARetorno[0], 95, 2) + '/' +
      Copy(ARetorno[0], 97, 2) + '/' +
      Copy(ARetorno[0], 99, 2), 0, 'dd/mm/yy');

  case StrToIntDef(Copy(ARetorno[1], 2, 2), 0) of
    1: rCNPJCPF := Copy(ARetorno[1], 7, 11);
    2: rCNPJCPF := Copy(ARetorno[1], 4, 14);
  else
    rCNPJCPF := Copy(ARetorno[1], 4, 14);
  end;

  with ACBrBanco.ACBrBoleto do
  begin
    if (not LeCedenteRetorno) and (rCodEmpresa <> PadLeft(Cedente.CodigoCedente, 20, '0')) then
      raise Exception.Create(ACBrStr('C�digo da Empresa do arquivo inv�lido.'));

    case StrToIntDef(Copy(ARetorno[1], 2, 2), 0) of
      1: Cedente.TipoInscricao:= pFisica;
      2: Cedente.TipoInscricao:= pJuridica;
    else
      Cedente.TipoInscricao:= pJuridica;
    end;

    if LeCedenteRetorno then
    begin
      Cedente.CNPJCPF       := rCNPJCPF;
      Cedente.CodigoCedente := rCodEmpresa;
      Cedente.Nome          := rCedente;
    end;

    ACBrBanco.ACBrBoleto.ListadeBoletos.Clear;
  end;

  for ContLinha := 1 to ARetorno.Count - 2 do
  begin
    Linha := ARetorno[ContLinha];

    if Copy(Linha, 1, 1) <> '1' then
      Continue;

    Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;

    with Titulo do
    begin
      SeuNumero               := Copy(Linha, 38, 25);
      NumeroDocumento         := Copy(Linha, 117, 10);
      OcorrenciaOriginal.Tipo := CodOcorrenciaToTipo(StrToIntDef(Copy(Linha, 109, 2), 0));

      CodMotivo := Trim(Copy(Linha, 378, 2));

      if ( CodMotivo <> '' ) then
      begin
        MotivoRejeicaoComando.Add(CodMotivo);
        DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo, CodMotivo));
      end;

      DataOcorrencia :=
        StringToDateTimeDef(
          Copy(Linha, 111, 2) + '/' +
          Copy(Linha, 113, 2) + '/'+
          Copy(Linha, 115, 2), 0, 'dd/mm/yy');

      if Copy(Linha, 147, 2) <> '00' then
        Vencimento :=
          StringToDateTimeDef(
            Copy(Linha, 147, 2) + '/' +
            Copy(Linha, 149, 2) + '/'+
            Copy(Linha, 151, 2), 0, 'dd/mm/yy');

      ValorDocumento       := StrToFloatDef(Copy(Linha, 153, 13), 0) / 100;
      ValorIOF             := StrToFloatDef(Copy(Linha, 215, 13), 0) / 100;
      ValorAbatimento      := StrToFloatDef(Copy(Linha, 228, 13), 0) / 100;
      ValorDesconto        := StrToFloatDef(Copy(Linha, 241, 13), 0) / 100;
      ValorMoraJuros       := StrToFloatDef(Copy(Linha, 267, 13), 0) / 100;
      ValorRecebido        := StrToFloatDef(Copy(Linha, 254, 13), 0) / 100;
      NossoNumero          := Copy(Linha, 63, TamanhoMaximoNossoNum);
      Carteira             := Copy(Linha, 108, 1);
      ValorDespesaCobranca := StrToFloatDef(Copy(Linha, 176, 13), 0) / 100;

    end;
  end;
end;

function TACBrBancoDaycoval.TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String;
var
  CodOcorrencia: Integer;
begin
  CodOcorrencia := StrToIntDef(TipoOCorrenciaToCod(TipoOcorrencia), 0);

  case CodOcorrencia of
    02: Result := '02 Entrada Confirmada';
    03: Result := '03 Entrada Rejeitada';
    05: Result := '05 Campo Livre Alterado';
    06: Result := '06 Liquida��o Normal';
    08: Result := '08 Liquida��o em Cart�rio';
    09: Result := '09 Baixa Autom�tica';
    10: Result := '10 Baixa p�r ter sido liquidado';
    12: Result := '12 Confirma Abatimento';
    13: Result := '13 Abatimento Cancelado';
    14: Result := '14 Vencimento Alterado';
    15: Result := '15 Baixa Rejeitada';
    16: Result := '16 Instru��o Rejeitada';
    19: Result := '19 Confirma Recebimento de Ordem de Protesto';
    20: Result := '20 Confirma Recebimento de Ordem de Susta��o';
    22: Result := '22 Seu N�mero Alterado';
    23: Result := '23 T�tulo enviado para Cart�rio';
    24: Result := '24 Confirma recebimento de ordem de n�o protestar';
    28: Result := '28 D�bito de tarifas/custas � Correspondentes';
    40: Result := '40 Tarifa de entrada (debitada na liquida��o)';
    43: Result := '43 Baixado por ter sido protestado';
    96: Result := '96 Tarifa sobre instru��es � M�s anterior';
    97: Result := '97 Tarifa sobre baixas � M�s anterior';
    98: Result := '98 Tarifa sobre entradas � M�s anterior';
    99: Result := '99 Tarifa sobre instru��o de protesto/susta��o � m�s anterior';
  else
    Result := IntToStr(CodOcorrencia)+' Ocorr�ncia desconhecida';
  end;
end;

function TACBrBancoDaycoval.CalcularNomeArquivoRemessa: String;
var
  Sequencia :Integer;
  NomeFixo, NomeArq: String;
begin
   Sequencia := 0;

   with ACBrBanco.ACBrBoleto do
   begin
      if NomeArqRemessa = '' then
       begin
         NomeFixo := DirArqRemessa + PathDelim + '2HQ' + FormatDateTime( 'ddmm', Now );

         repeat
            Inc( Sequencia );
            NomeArq := NomeFixo + IntToStr( Sequencia ) + '.txt'
         until not FileExists( NomeArq ) ;

         Result := NomeArq;
       end
      else
         Result := DirArqRemessa + PathDelim + NomeArqRemessa ;
   end;
end;

function TACBrBancoDaycoval.CodOcorrenciaToTipo(
  const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02: Result := toRetornoRegistroConfirmado;
    03: Result := toRetornoRegistroRecusado;
    05: Result := toRetornoAlteracaoSeuNumero;
    06: Result := toRetornoLiquidado;
    08: Result := toRetornoLiquidadoEmCartorio;
    09: Result := toRetornoBaixaAutomatica;
    10: Result := toRetornoBaixaPorTerSidoLiquidado;
    12: Result := toRetornoAbatimentoConcedido;
    13: Result := toRetornoAbatimentoCancelado;
    14: Result := toRetornoVencimentoAlterado;
    15: Result := toRetornoBaixaRejeitada;
    16: Result := toRetornoInstrucaoRejeitada;
    19: Result := toRetornoRecebimentoInstrucaoProtestar;
    20: Result := toRetornoRecebimentoInstrucaoSustarProtesto;
    22: Result := toRetornoAlteracaoSeuNumero;
    23: Result := toRetornoEncaminhadoACartorio;
    24: Result := toRetornoRecebimentoInstrucaoNaoProtestar;
    28: Result := toRetornoDebitoTarifas;
    40: Result := toRetornoDebitoTarifas;
    43: Result := toRetornoProtestado;
    96: Result := toRetornoDebitoTarifas;
    97: Result := toRetornoDebitoTarifas;
    98: Result := toRetornoDebitoTarifas;
    99: Result := toRetornoDebitoTarifas;
  else
    Result := toRetornoOutrasOcorrencias;
  end;
end;

function TACBrBancoDaycoval.TipoOCorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia): String;
begin
  case TipoOcorrencia of
    toRetornoRegistroConfirmado                 : Result := '02';
    toRetornoRegistroRecusado                   : Result := '03';
    toRetornoAlteracaoSeuNumero                 : Result := '05';
    toRetornoLiquidado                          : Result := '06';
    toRetornoLiquidadoEmCartorio                : Result := '08';
    toRetornoBaixaAutomatica                    : Result := '09';
    toRetornoBaixaPorTerSidoLiquidado           : Result := '10';
    toRetornoAbatimentoConcedido                : Result := '12';
    toRetornoAbatimentoCancelado                : Result := '13';
    toRetornoVencimentoAlterado                 : Result := '14';
    toRetornoBaixaRejeitada                     : Result := '15';
    toRetornoInstrucaoRejeitada                 : Result := '16';
    toRetornoRecebimentoInstrucaoProtestar      : Result := '19';
    toRetornoRecebimentoInstrucaoSustarProtesto : Result := '20';
    toRetornoEncaminhadoACartorio               : Result := '23';
    toRetornoRecebimentoInstrucaoNaoProtestar   : Result := '24';
    toRetornoDebitoTarifas                      : Result := '28';
    toRetornoProtestado                         : Result := '43';
  else
    Result := '02';
  end;
end;

function TACBrBancoDaycoval.CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02 : Result:= toRemessaBaixar;                          {Pedido de Baixa}
    04 : Result:= toRemessaConcederAbatimento;              {Concess�o de Abatimento}
    05 : Result:= toRemessaCancelarAbatimento;              {Cancelamento de Abatimento concedido}
    06 : Result:= toRemessaAlterarVencimento;               {Altera��o de vencimento}
    07 : Result:= toRemessaAlterarUsoEmpresa;               {Altera��o do uso Da Empresa}
    08 : Result:= toRemessaAlterarSeuNumero;                {Altera��o do seu N�mero}
    09 : Result:= toRemessaProtestar;                       {Protestar (emite aviso ao sacado ap�s xx dias do vencimento, e envia ao cart�rio ap�s 5 dias �teis)}
    10 : Result:= toRemessaCancelarInstrucaoProtesto;       {Sustar Protesto}
    11 : Result:= toRemessaProtestoFinsFalimentares;        {Protesto para fins Falimentares}
    18 : Result:= toRemessaCancelarInstrucaoProtestoBaixa;  {Sustar protesto e baixar}
    30 : Result:= toRemessaExcluirSacadorAvalista;          {Exclus�o de Sacador Avalista}
    31 : Result:= toRemessaOutrasAlteracoes;                {Altera��o de Outros Dados}
    34 : Result:= toRemessaBaixaporPagtoDiretoCedente;      {Baixa por ter sido pago Diretamente ao Cedente}
    35 : Result:= toRemessaCancelarInstrucao;               {Cancelamento de Instru��o}
    37 : Result:= toRemessaAlterarVencimentoSustarProtesto; {Altera��o do Vencimento e Sustar Protesto}
    38 : Result:= toRemessaCedenteDiscordaSacado;           {Cedente n�o Concorda com Alega��o do Sacado }
    47 : Result:= toRemessaCedenteSolicitaDispensaJuros;    {Cedente Solicita Dispensa de Juros}
  else
     Result:= toRemessaRegistrar;                           {Remessa}
  end;
end;

end.
