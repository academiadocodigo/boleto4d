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

unit ACBrBancoCecred;

interface

uses
  Classes, SysUtils, Contnrs, ACBrBoleto, ACBrBoletoConversao;

const
  CACBrBancoCecred_Versao = '0.0.1';

type
  { TACBrBancoCecred}

  TACBrBancoCecred = class(TACBrBancoClass)
  private
    fValorTotalDocs : Double;
    fDataProtestoNegativacao : TDateTime;
    fDiasProtestoNegativacao : String;
    function FormataNossoNumero(const ACBrTitulo :TACBrTitulo): String;
  protected
    fCountRegR:Integer;
    procedure DefineDataProtestoNegativacao(const ACBrTitulo: TACBrTitulo);
    function DefineCodigoProtesto(const ACBrTitulo: TACBrTitulo): String; override;
  public
    Constructor create(AOwner: TACBrBanco);
    function CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String; override;
    function MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String; override;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String; override;
    function MontarCampoNossoNumero(const ACBrTitulo :TACBrTitulo): String; override;

    function GerarRegistroHeader240(NumeroRemessa : Integer): String;    override;
    procedure GerarRegistroHeader400(NumeroRemessa : Integer; aRemessa:TStringList); override;

    function GerarRegistroTransacao240(ACBrTitulo : TACBrTitulo): String; override;
    procedure GerarRegistroTransacao400(ACBrTitulo : TACBrTitulo; aRemessa: TStringList); override;

    function GerarRegistroTrailler240(ARemessa:TStringList): String;  override;
    procedure GerarRegistroTrailler400(ARemessa : TStringList); override;

    function TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia) : String; override;
    function CodOcorrenciaToTipo(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
    function TipoOCorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia):String; override;
    procedure LerRetorno240(ARetorno:TStringList); override;
    procedure LerRetorno400(ARetorno: TStringList); override;
    function CodMotivoRejeicaoToDescricao(
      const TipoOcorrencia: TACBrTipoOcorrencia; CodMotivo: Integer): String; override;

    function CalcularTamMaximoNossoNumero(const Carteira : String; const NossoNumero : String = ''; const Convenio: String = ''): Integer; override;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;

    property DataProtestoNegativacao : TDateTime read  fDataProtestoNegativacao ;
    property DiasProtestoNegativacao : String read fDiasProtestoNegativacao ;
  end;

implementation

uses
  {$IFDEF COMPILER6_UP} DateUtils {$ELSE} ACBrD5, FileCtrl {$ENDIF},
  StrUtils, Variants,
  ACBrValidador, ACBrUtil, math;

constructor TACBrBancoCecred.create(AOwner: TACBrBanco);
begin
   inherited create(AOwner);
   fDataProtestoNegativacao:=0;
   fDiasProtestoNegativacao:='';
   fpDigito                := 1;
   fpNome                  := 'Banco Cecred';
   fpNumero                := 085;
   fpTamanhoMaximoNossoNum := 17;
   fpTamanhoConta          := 8;
   fpTamanhoAgencia        := 4;
   fpTamanhoCarteira       := 2;
   fValorTotalDocs         := 0;
   fpLayoutVersaoArquivo   := 87;
   fpLayoutVersaoLote      := 45;

end;

function TACBrBancoCecred.CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String;
begin
   Result := '0';

   Modulo.CalculoPadrao;
   Modulo.MultiplicadorFinal   := 2;
   Modulo.MultiplicadorInicial := 9;
   Modulo.Documento := FormataNossoNumero(ACBrTitulo);
   Modulo.Calcular;

   if Modulo.ModuloFinal >= 10 then
      Result:= '1'
   else
      Result:= IntToStr(Modulo.ModuloFinal);
end;

function TACBrBancoCecred.CalcularTamMaximoNossoNumero(
  const Carteira: String; const NossoNumero : String = ''; const Convenio: String = ''): Integer;
begin
   Result := 17;

   if (ACBrBanco.ACBrBoleto.Cedente.Conta = '') then
      raise Exception.Create(ACBrStr('Banco Cecred requer que a Conta '+
                                     'seja informada.'));

end;

function TACBrBancoCecred.FormataNossoNumero(const ACBrTitulo :TACBrTitulo): String;
var
  ANossoNumero : String;
  AConta : String;
begin


   with ACBrTitulo do
   begin


      AConta    := IntToStr(StrToInt64(OnlyNumber(ACBrBoleto.Cedente.Conta + ACBrBoleto.Cedente.ContaDigito)));
      ANossoNumero := IntToStr(StrToInt64(OnlyNumber(NossoNumero)));

      ANossoNumero := PadLeft(AConta, 8, '0') + PadLeft(ANossoNumero, 9, '0')
   end;
   Result := ANossoNumero;
end;

procedure TACBrBancoCecred.DefineDataProtestoNegativacao(
  const ACBrTitulo: TACBrTitulo);
var
  ACodProtesto: String;
begin

  with ACBrTitulo do
  begin
    ACodProtesto :=  DefineCodigoProtesto(ACBrTitulo);
    if ACodProtesto = '1' then
    begin
      fDataProtestoNegativacao := DataProtesto;
      fDiasProtestoNegativacao := IntToStr(DiasDeProtesto);
    end
    else
    if ACodProtesto = '2' then
    begin
      fDataProtestoNegativacao := DataNegativacao;
      fDiasProtestoNegativacao := IntToStr(DiasDeNegativacao);
    end
    else
    begin
      fDataProtestoNegativacao := 0;
      fDiasProtestoNegativacao := '3';
    end;

  end;

end;

function TACBrBancoCecred.DefineCodigoProtesto(const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo do
  begin
    case CodigoNegativacao of
       cnProtestarCorrido, cnProtestarUteis : Result := '1';
       cnNegativar                          : Result := '2';
       cnNaoProtestar,cnNaoNegativar        : Result := '3';
      else
       Result := '3';
    end;

  end;
end;


function TACBrBancoCecred.MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String;
var
  CodigoBarras: String;
  FatorVencimento: String;
  DigitoCodBarras: String;
  ANossoNumero: String;
  AConvenio: String;
begin
   AConvenio    := IntToStr(StrToInt64Def(OnlyNumber(ACBrTitulo.ACBrBoleto.Cedente.Convenio),0));
   ANossoNumero := IntToStrZero(StrToIntDef(OnlyNumber(ACBrTitulo.NossoNumero),0),9);

   {Codigo de Barras}
   with ACBrTitulo.ACBrBoleto do
   begin
      FatorVencimento := CalcularFatorVencimento(ACBrTitulo.Vencimento);
      CodigoBarras := IntToStrZero(Banco.Numero, 3) +
                      '9' +
                      FatorVencimento +
                      IntToStrZero(Round(ACBrTitulo.ValorDocumento * 100), 10) +
                      PadLeft(AConvenio, 6, '0') +
                      IntToStrZero(StrToIntDef(OnlyNumber(Cedente.Conta + Cedente.ContaDigito),0),8) +
                      ANossoNumero +
                      PadRight(ACBrTitulo.Carteira, fpTamanhoCarteira, '0');

      DigitoCodBarras := CalcularDigitoCodigoBarras(CodigoBarras);
   end;

   Result:= copy( CodigoBarras, 1, 4) + DigitoCodBarras + copy( CodigoBarras, 5, 44) ;
end;

function TACBrBancoCecred.MontarCampoCodigoCedente (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result := ACBrTitulo.ACBrBoleto.Cedente.Agencia+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito+'/'+
             IntToStrZero(StrToIntDef(ACBrTitulo.ACBrBoleto.Cedente.Conta,0),8)+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.ContaDigito;
end;

function TACBrBancoCecred.MontarCampoNossoNumero (const ACBrTitulo: TACBrTitulo ) : String;
var
  ANossoNumero: String;
begin
   ANossoNumero := FormataNossoNumero(ACBrTitulo);
   Result:= ANossoNumero

end;

function TACBrBancoCecred.GerarRegistroHeader240(
  NumeroRemessa: Integer): String;
var
  ATipoInscricao, aConta, aAgencia: String;

begin
  fCountRegR := 0;

  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    case TipoInscricao of
      pFisica  : ATipoInscricao := '1';
      pJuridica: ATipoInscricao := '2';
    else
      ATipoInscricao := '1';
    end;

    aAgencia    := PadLeft(OnlyNumber(Agencia), 5, '0');
    aConta      := PadLeft(OnlyNumber(Conta), 12, '0');

    // GERAR REGISTRO-HEADER DO ARQUIVO
    Result:= IntToStrZero(ACBrBanco.Numero, 3)               + // 1 a 3 - C�digo da cooperativa
             '0000'                                          + // 4 a 7 - Lote de servi�o
             '0'                                             + // 8 - Tipo de registro - Registro header de arquivo
             StringOfChar(' ', 9)                            + // 9 a 17 Uso exclusivo FEBRABAN/CNAB
             ATipoInscricao                                  + // 18 - Tipo de inscri��o do cedente
             PadLeft(OnlyNumber(CNPJCPF), 14, '0')           + // 19 a 32 -N�mero de inscri��o do cedente
             PadRight(Convenio, 20, ' ')                     + // 33 a 52 - C�digo do conv�nio
             aAgencia                                        + // 53 a 57 - C�digo da ag�ncia do cedente
             PadRight(AgenciaDigito, 1 , '0')                + // 58 - D�gito da ag�ncia do cedente
             aConta                                          + // 59 a 70 - N�mero da conta do cedente
             PadRight(ContaDigito, 1, '0')                   + // 71 - D�gito da conta do cedente
             PadRight(DigitoVerificadorAgenciaConta, 1, ' ') + // 72 - D�gito verificador da ag�ncia / conta
             TiraAcentos(UpperCase(PadRight(Nome, 30, ' '))) + // 73 a 102 - Nome do cedente
             PadRight('CEDRED', 30, ' ')                     + // 103 a 132 - Nome da cooperativa
             StringOfChar(' ', 10)                           + // 133 a 142 - Uso exclusivo FEBRABAN/CNAB
             '1'                                             + // 143 - C�digo de Remessa (1) / Retorno (2)
             FormatDateTime('ddmmyyyy', Now)                 + // 144 a 151 - Data do de gera��o do arquivo
             FormatDateTime('hhmmss', Now)                   + // 152 a 157 - Hora de gera��o do arquivo
             PadLeft(IntToStr(NumeroRemessa), 6, '0')        + // 158 a 163 - N�mero seq�encial do arquivo
             PadLeft(IntToStr(fpLayoutVersaoArquivo) , 3, '0')+ // 164 a 166 - N�mero da vers�o do layout do arquivo
             StringOfChar('0', 5)                            + // 167 a 171 - Densidade de grava��o do arquivo (BPI)
             StringOfChar(' ', 20)                           + // 172 a 191 - Uso reservado da cooperativa
             StringOfChar(' ', 20)                           + // 192 a 211 - Uso reservado da empresa
             StringOfChar(' ', 29);                            // 212 a 240 - Uso exclusivo FEBRABAN/CNAB

    // GERAR REGISTRO HEADER DO LOTE
    Result:= Result + #13#10 +
             IntToStrZero(ACBrBanco.Numero, 3)               + // 1 a 3 - C�digo da cooperativa
             '0001'                                          + // 4 a 7 - Lote de servi�o
             '1'                                             + // 8 - Tipo de registro - Registro Header de Lote
             'R'                                             + // 9 - Tipo de opera��o: R (Remessa) ou T (Retorno)
             '01'                                            + // 10 a 11 - Tipo de servi�o: 01 (Cobran�a)
             '  '                                            + // 12 a 13 - Uso exclusivo FEBRABAN/CNAB
             PadLeft(IntToStr(fpLayoutVersaoLote), 3, '0')   + // 14 a 16 - N�mero da vers�o do layout do lote
             ' '                                             + // 17 - Uso exclusivo FEBRABAN/CNAB
             ATipoInscricao                                  + // 18 - Tipo de inscri��o do cedente
             PadLeft(OnlyNumber(CNPJCPF), 15, '0')           + // 19 a 33 -N�mero de inscri��o do cedente
             PadRight(Convenio, 20, ' ')                     + // 34 a 43 - C�digo do conv�nio
             aAgencia                                        + // 54 a 58 - C�digo da ag�ncia do cedente
             PadRight(AgenciaDigito, 1 , '0')                + // 59 - D�gito da ag�ncia do cedente
             aConta                                          + // 60 a 71 - N�mero da conta do cedente
             PadRight(ContaDigito, 1, '0')                   + // 72 - D�gito da conta do cedente
             PadRight(DigitoVerificadorAgenciaConta, 1, ' ') + // 73 - D�gito verificador da ag�ncia / conta
             PadRight(Nome, 30, ' ')                         + // 74 a 103 - Nome do cedente
             StringOfChar(' ', 40)                           + // 104 a 143 - Mensagem 1 para todos os boletos do lote
             StringOfChar(' ', 40)                           + // 144 a 183 - Mensagem 2 para todos os boletos do lote
             PadLeft(IntToStr(NumeroRemessa), 8, '0')        + // 184 a 191 - N�mero do arquivo
             FormatDateTime('ddmmyyyy', Now)                 + // 192 a 199 - Data de gera��o do arquivo
             StringOfChar('0', 8)                            + // 200 a 207 - Data do cr�dito - S� para arquivo retorno
             StringOfChar(' ', 33);                            // 208 a 240 - Uso exclusivo FEBRABAN/CNAB
  end;
end;


procedure TACBrBancoCecred.GerarRegistroHeader400(NumeroRemessa: Integer; aRemessa:TStringList);
var
  aAgencia: String;
  aConta: String;
  aConvenio : String;
  wLinha: String;
begin

   with ACBrBanco.ACBrBoleto.Cedente do
   begin
      aAgencia:= IntToStrZero(StrToIntDef(OnlyNumber(Agencia),0),4);
      aConta  := IntToStrZero(StrToIntDef(OnlyNumber(Conta),0),8);
      aConvenio := IntToStrZero(StrToIntDef(OnlyNumber(Convenio),0),7);

      wLinha:= '0'                            + // ID do Registro
               '1'                            + // ID do Arquivo( 1 - Remessa)
               'REMESSA'                      + // Literal de Remessa
               '01'                           + // C�digo do Tipo de Servi�o
               'COBRANCA'                     + // Descri��o do tipo de servi�o
               Space(7)                       + // Brancos
               aAgencia                       + // Prefixo da ag�ncia/ onde esta cadastrado o convenente lider do cedente
               PadRight( AgenciaDigito, 1, ' ')   + // DV-prefixo da ag�ncia
               aConta                         + // Codigo do cedente/nr. da conta corrente que est� cadastro o convenio lider do cedente
               PadRight( ContaDigito, 1, ' ')     + // DV-c�digo do cedente
               '000000'                       + // Complemento
               PadRight( Nome, 30)                + // Nome da Empresa
               PadRight( '085CECRED',18,' ')      + // Identificador do Banco
               FormatDateTime('ddmmyy',Now)   + // Data de gera��o do arquivo
               IntToStrZero(NumeroRemessa,7)  + // Numero Remessa
               Space(22)                      + // Brancos
               aConvenio                      + // Nr. Conv�nio
               space(258)                     + // Brancos
               IntToStrZero(1,6);               // Nr. Sequencial do registro-informar 000001

      aRemessa.Text:= aRemessa.Text + UpperCase(wLinha);
   end;
end;

function TACBrBancoCecred.GerarRegistroTransacao240(ACBrTitulo: TACBrTitulo): String;
var
  ATipoOcorrencia, ATipoBoleto : String;
  ADataMoraJuros, ADataDesconto: String;
  ANossoNumero, ATipoAceite    : String;
  aAgencia, aConta             : String;
  aCodJuros, aCodDesc          : String;
  aCodMulta, aValorMulta       : String;
  ACodigoNegativacao           : String;
  ACaracTitulo  : Char;
begin
  with ACBrTitulo do
  begin
    ANossoNumero := FormataNossoNumero(ACBrTitulo);
    aAgencia     := PadLeft(ACBrBoleto.Cedente.Agencia, 5, '0');
    aConta       := PadLeft(ACBrBoleto.Cedente.Conta, 12, '0');

    // Zerando o valor/percentual de multa, se tiver ser� calculado depois
    aValorMulta  := PadRight('', 15, '0');

   //Pegando o Tipo de Ocorrencia
    case OcorrenciaOriginal.Tipo of
      toRemessaBaixar                         : ATipoOcorrencia := '02';   // Pedido de Baixa
      toRemessaConcederAbatimento             : ATipoOcorrencia := '04';   // Concess�o de Abatimento
      toRemessaCancelarAbatimento             : ATipoOcorrencia := '05';   // Cancelamento de Abatimento
      toRemessaAlterarVencimento              : ATipoOcorrencia := '06';   // Altera��o de Vencimento
      toRemessaConcederDesconto               : ATipoOcorrencia := '07';   // Concess�o de Desconto
      toRemessaCancelarDesconto               : ATipoOcorrencia := '08';   // Cancelamento de Desconto
      toRemessaProtestar                      : ATipoOcorrencia := '09';   // Protesto
      toRemessaCancelarInstrucaoProtestoBaixa : ATipoOcorrencia := '10';   // Sustar Protesto e Baixar T�tulo
      toRemessaCancelarInstrucaoProtesto      : ATipoOcorrencia := '11';   // Sustar Protesto e Manter em Carteira
      toRemessaAlterarNomeEnderecoSacado      : ATipoOcorrencia := '31';   // Altera��o de outros dados (Somente endere�o do pagador)
                                                                           //�41� = Cancelar instru��o autom�tica de protesto
                                                                           //�90� = Alterar tipo de emiss�o - Cooperativa/EE
      toRemessaNegativacaoSerasa              : ATipoOcorrencia := '93';   // Inclus�o Negativa��o via Serasa
      toRemessaExcluirNegativacaoSerasa       : ATipoOcorrencia := '94';   // Exclus�o Negativa��o via Serasa
    else
      ATipoOcorrencia := '01';                                             // Entrada de T�tulos
    end;

    // Pegando o tipo de EspecieDoc
    if EspecieDoc = 'DM' then
      EspecieDoc   := '02'
    else
      EspecieDoc   := '04'; //DS

    // Pegando o Aceite do Titulo
    case Aceite of
      atSim :  ATipoAceite := 'A';
      atNao :  ATipoAceite := 'N';
    else
      ATipoAceite := 'N';
    end;

    if CodigoMoraJuros = cjValorDia then
      aCodJuros := '1'
    else if CodigoMoraJuros = cjTaxaMensal then
      aCodJuros := '2'
    else
      aCodJuros := '3';// isento

    if CodigoDesconto = cdSemDesconto then
      aCodDesc := '0'
    else
      aCodDesc := '1'; // Valor Fixo At� a Data Informada

    {C�digo de Protesto/Negativa��o }
    ACodigoNegativacao := DefineCodigoProtesto(ACBrTitulo);
    DefineDataProtestoNegativacao(ACBrTitulo);

    if CodigoMulta = cmValorFixo then
    begin
      aCodMulta := '1';
      if PercentualMulta > 0 then
        aValorMulta := IntToStrZero(Round(ValorDocumento*(PercentualMulta/100)*100), 15);
    end
    else
    begin
      aCodMulta := '2'; //Percentual
      if PercentualMulta > 0 then
        aValorMulta := IntToStrZero(Round(PercentualMulta * 100), 15);
    end;

    //Pegando Tipo de Boleto
    case ACBrBoleto.Cedente.ResponEmissao of
      tbCliEmite        : ATipoBoleto := '2' + '2';
      tbBancoEmite      : ATipoBoleto := '1' + '1';
      tbBancoReemite    : ATipoBoleto := '4' + '1';
      tbBancoNaoReemite : ATipoBoleto := '5' + '2';
    end;

    ACaracTitulo := '1';
    case CaracTitulo of
      tcSimples     : ACaracTitulo  := '1';
      tcVinculada   : ACaracTitulo  := '2';
      tcCaucionada  : ACaracTitulo  := '3';
      tcDescontada  : ACaracTitulo  := '4';
    end;

    //Mora Juros
    if (ValorMoraJuros > 0) and (DataMoraJuros > 0) then
      ADataMoraJuros := FormatDateTime('ddmmyyyy', DataMoraJuros)
    else
    begin
      aCodJuros := '3';// isento ;
      ADataMoraJuros := PadRight('', 8, '0');
    end;

    //Descontos
    if (ValorDesconto > 0) and (DataDesconto > 0) then
      ADataDesconto := FormatDateTime('ddmmyyyy', DataDesconto)
    else
      ADataDesconto := PadRight('', 8, '0');

    fValorTotalDocs:= fValorTotalDocs  + ValorDocumento;

    //SEGMENTO P
    Result:= IntToStrZero(ACBrBanco.Numero, 3)                                         + // 1 a 3 - C�digo do banco
             '0001'                                                                    + // 4 a 7 - Lote de servi�o
             '3'                                                                       + // 8 - Tipo do registro: Registro detalhe
             IntToStrZero((3 * ACBrBoleto.ListadeBoletos.IndexOf(ACBrTitulo)) + 1 , 5) + // 9 a 13 - N�mero seq�encial do registro no lote - Cada t�tulo tem 2 registros (P e Q)
             'P'                                                                       + // 14 - C�digo do segmento do registro detalhe
             ' '                                                                       + // 15 - Uso exclusivo FEBRABAN/CNAB: Branco
             ATipoOcorrencia                                                           + // 16 a 17 - C�digo de movimento
             aAgencia                                                                  + // 18 a 22 - Ag�ncia mantenedora da conta
             PadRight(ACBrBoleto.Cedente.AgenciaDigito, 1 , '0')                       + // 23 -D�gito verificador da ag�ncia
             aConta                                                                    + // 24 a 35 - N�mero da conta corrente
             PadRight(ACBrBoleto.Cedente.ContaDigito, 1, '0')                          + // 36 - D�gito verificador da conta
             ' '                                                                       + // 37 - D�gito verificador da ag�ncia / conta
             PadRight(ANossoNumero, 20, ' ')                                           + // 38 a 57 - Identifica��o do t�tulo na cooperativa
             ACaracTitulo                                                              + // 58 - Codigo carteira fixo 1
             '1'                                                                       + // 59 - Forma de cadastramento do t�tulo no banco: com cadastramento fixo 1
             '1'                                                                       + // 60 - Tipo de documento: Tradicional fixo 1
             ATipoBoleto                                                               + // 61 a 62 - Quem emite e quem distribui o boleto?
             PadRight(NumeroDocumento, 15, ' ')                                        + // 63 a 77 - N�mero que identifica o t�tulo na empresa
             FormatDateTime('ddmmyyyy', Vencimento)                                    + // 78 a 85 - Data de vencimento do t�tulo
             IntToStrZero( round( ValorDocumento * 100), 15)                           + // 86 a 100 - Valor nominal do t�tulo
             '00000 '                                                                  + // 101 a 106 - Ag�ncia cobradora + dv
             PadRight(EspecieDoc, 2)                                                   + // 107 a 108 - Esp�cie do documento
             ATipoAceite                                                               + // 109 - Identifica��o de t�tulo Aceito / N�o aceito
             FormatDateTime('ddmmyyyy', DataDocumento)                                 + // 110 a 117 - Data da emiss�o do documento
             aCodJuros                                                                 + // 118 - C�digo de juros de mora: Valor por dia   ('1' = Valor por Dia  '2' = Taxa Mensal '3' = Isento)
             ADataMoraJuros                                                            + // 119 a 126 - Data a partir da qual ser�o cobrados juros
             IfThen(ValorMoraJuros > 0,
                    IntToStrZero(round(ValorMoraJuros * 100), 15),
                    PadRight('', 15, '0'))                                             + // 127 a 141 - Valor de juros de mora por dia
             aCodDesc                                                                  + // 142 - C�digo de desconto: 1 - Valor fixo at� a data informada  0 - Sem desconto
             IfThen(ValorDesconto > 0,
                    IfThen(DataDesconto > 0, ADataDesconto,'00000000'), '00000000')    + // 143 a 150 - Data do desconto
             IfThen(ValorDesconto > 0, IntToStrZero( round(ValorDesconto * 100), 15),
                    PadRight('', 15, '0'))                                             + // 151 a 165 - Valor do desconto a ser concedido
             IntToStrZero( round(ValorIOF * 100), 15)                                  + // 166 a 180 - Valor do IOF a ser recolhido
             IntToStrZero( round(ValorAbatimento * 100), 15)                           + // 181 a 195 - Valor do abatimento
             PadRight(SeuNumero, 25, ' ')                                              + // 196 a 220 - Identifica��o do t�tulo na empresa
             ACodigoNegativacao                                                        + // 221 - C�digo para negativacao
             IfThen((DataProtestoNegativacao <> 0) and
                       (DataProtestoNegativacao > Vencimento),
                        PadLeft(DiasProtestoNegativacao , 2, '0'), '00')               + //222 a 223 - Prazo para protesto
             '2'                                                                       + // 224 - Codigo para Baixa/Devolucao
             StringOfChar(' ', 3)                                                      + // 225 a 227 - N�mero de dias para Baixa/Devolucao
             '09'                                                                      + // 228 a 229 - C�digo da moeda: Real
             StringOfChar('0', 10)                                                     + // 230 a 239 - Numero do contrato da op. de credito
             ' ';                                                                        // 240 - Uso exclusivo FEBRABAN/CNAB

    //SEGMENTO Q
    Result:= Result + #13#10 +
             IntToStrZero(ACBrBanco.Numero, 3)                                        + // 1 a 3 - C�digo do banco
             '0001'                                                                   + // 4 a 7 - N�mero do lote
             '3'                                                                      + // 8 - Tipo do registro: Registro detalhe
             IntToStrZero((3 * ACBrBoleto.ListadeBoletos.IndexOf(ACBrTitulo)) + 2 ,5) + // 9 a 13 - N�mero seq�encial do registro no lote - Cada t�tulo tem 2 registros (P e Q)
             'Q'                                                                      + // 14 - C�digo do segmento do registro detalhe
             ' '                                                                      + // 15 - Uso exclusivo FEBRABAN/CNAB: Branco
             ATipoOcorrencia                                                          + // 16 a 17 - Codigo de movimento remessa
             IfThen(Sacado.Pessoa = pJuridica,'2','1')                                + // 18 - Tipo inscricao
             PadLeft(OnlyNumber(Sacado.CNPJCPF), 15, '0')                             + // 19 a 33 - N�mero de Inscri��o
             PadRight(Sacado.NomeSacado, 40, ' ')                                     + // 34 a 73 - Nome sacado
             PadRight(Sacado.Logradouro + ' ' + Sacado.Numero + ' '+
                      Sacado.Complemento , 40, ' ')                                   + // 74 a 113 - Endereco sacado
             PadRight(Sacado.Bairro, 15, ' ')                                         + // 114 a 118 - Bairro sacado
             PadLeft(OnlyNumber(Sacado.CEP), 8, '0')                                  + // 129 a 136 - Cep sacado
             PadRight(Sacado.Cidade, 15, ' ')                                         + // 137 a 151 - Cidade sacado
             PadRight(Sacado.UF, 2, ' ')                                              + // 152 a 153 - Unidade da Federa��o
             '0'                                                                      + // 154 - Tipo de inscri��o: N�o informado
             StringOfChar('0', 15)                                                    + // 155 a 169 - N�mero de inscri��o
             StringOfChar(' ', 40)                                                    + // 170 a 209 - Nome do sacador/avalista
             StringOfChar('0', 3)                                                     + // 210 a 212 - C�d. Bco. Corresp. na Compensa��o
             StringOfChar(' ', 20)                                                    + // 213 a 232 - Nosso N� no banco correspondente
             StringOfChar(' ', 8);                                                      // 233 a 240 - Uso exclusivo FEBRABAN/CNAB

    //SEGMENTO R
    if (PercentualMulta > 0) then
    begin
      Inc(fCountRegR);
      Result:= Result + #13#10 +
               IntToStrZero(ACBrBanco.Numero, 3)                                       + // 1 a 3 - C�digo do banco
               '0001'                                                                  + // 4 a 7 - N�mero do lote
               '3'                                                                     + // 8 a 8 - Tipo do registro: Registro detalhe
               IntToStrZero((3 * ACBrBoleto.ListadeBoletos.IndexOf(ACBrTitulo))+ 3 ,5) + // 9 a 13 - N�mero seq�encial do registro no lote - Cada t�tulo tem 2 registros (P e Q)
               'R'                                                                     + // 14 a 14 - C�digo do segmento do registro detalhe
               ' '                                                                     + // 15 a 15 - Uso exclusivo FEBRABAN/CNAB: Branco
               ATipoOcorrencia                                                         + // 16 a 17 - Tipo Ocorrencia
               '0'                                                                     + // 18 - C�d deconto 2
               StringOfChar('0', 8)                                                    + // 19 a 26 - Data do desconto 2
               StringOfChar('0', 15)                                                   + // 27 a 41 - Valor/Percentual de desconto 2
               '0'                                                                     + // 42 - C�d deconto 3
               StringOfChar('0', 8)                                                    + // 43 a 50 - Data do desconto 3
               StringOfChar('0', 15)                                                   + // 51 a 65 - Valor/Percentual de desconto 3
               aCodMulta                                                               + // 66 a 66 - Codigo Multa (1-Valor fixo / 2-Percentual)
               IfThen((PercentualMulta > 0),
                       FormatDateTime('ddmmyyyy', DataMoraJuros), '00000000')          + // 67 a 74 - Data Multa (se nao informar ser� a partir do vcto)
               aValorMulta                                                             + // 75 a 89 - valor/Percentual de multa dependando do cod da multa. Informar zeros se n�o cobrar
               StringOfChar(' ', 10)                                                   + // 90 a 99 - Informacao ao sacado
               StringOfChar(' ', 40)                                                   + // 100 a 139 - Mensagem 3
               StringOfChar(' ', 40)                                                   + // 140 a 179 - Mensagem 4
               StringOfChar(' ', 20)                                                   + // 180 a 199 - Uso exclusivo FEBRABAN/CNAB: Branco
               StringOfChar('0', 8)                                                    + // 200 - 207 - C�d ocor. do sacado
               StringOfChar('0', 3)                                                    + // 208 a 210 - C�d do Banco na Conta do D�bito
               StringOfChar('0', 5)                                                    + // 211 a 215 - C�d da Ag�ncia do D�bito
               ' '                                                                     + // 216 - Digito Conta Ag�ncia do D�bito
               StringOfChar('0', 12)                                                   + // 217 a 228 - Conta Corrente para D�bito
               ' '                                                                     + // 229 - Digito Conta D�bito
               ' '                                                                     + // 230 - Digito ag/conta debito
               '0'                                                                     + // 231 - Aviso para d�bito autom�tico
               StringOfChar(' ', 9);                                                     // 232 a 240 - Uso exclusivo FEBRABAN/CNAB: Branco
    end;
  end;
end;


procedure TACBrBancoCecred.GerarRegistroTransacao400(ACBrTitulo: TACBrTitulo; aRemessa: TStringList);
var
  ANossoNumero: String;
  ATipoOcorrencia: String;
  AInstrucao: String;
  ATipoSacado: String;
  ATipoCendente: String;
  ATipoAceite: String;
  ATipoEspecieDoc: String;
  AMensagem: String;
  DiasProtesto: String;
  aAgencia: String;
  aConta: String;
  aModalidade: String;
  wLinha: String;
  aTipoCobranca: String;
begin

   with ACBrTitulo do
   begin
      ANossoNumero := FormataNossoNumero(ACBrTitulo);
      aAgencia:= IntToStrZero(StrToIntDef(OnlyNumber(ACBrBoleto.Cedente.Agencia),0),4);
      aConta  := IntToStrZero(StrToIntDef(OnlyNumber(ACBrBoleto.Cedente.Conta),0),8);
      aModalidade := IntToStrZero(StrToIntDef(trim(ACBrBoleto.Cedente.Modalidade),0),3);
       
      {Pegando C�digo da Ocorrencia}
      case OcorrenciaOriginal.Tipo of
         toRemessaBaixar                         : ATipoOcorrencia := '02'; {Pedido de Baixa}
         toRemessaConcederAbatimento             : ATipoOcorrencia := '04'; {Concess�o de Abatimento}
         toRemessaCancelarAbatimento             : ATipoOcorrencia := '05'; {Cancelamento de Abatimento concedido}
         toRemessaAlterarVencimento              : ATipoOcorrencia := '06'; {Altera��o de vencimento}
         toRemessaAlterarControleParticipante    : ATipoOcorrencia := '07'; {Altera��o do n�mero de controle do participante}
         toRemessaAlterarNumeroControle          : ATipoOcorrencia := '08'; {Altera��o de seu n�mero}
         toRemessaProtestar                      : ATipoOcorrencia := '09'; {Pedido de protesto}
         toRemessaCancelarInstrucaoProtestoBaixa : ATipoOcorrencia := '10'; {Sustar protesto e baixar}
         toRemessaCancelarInstrucaoProtesto      : ATipoOcorrencia := '10'; {Sustar protesto e manter na carteira}
         toRemessaDispensarJuros                 : ATipoOcorrencia := '11'; {Instru��o para dispensar juros}
         toRemessaAlterarNomeEnderecoSacado      : ATipoOcorrencia := '12'; {Altera��o de nome e endere�o do Sacado}
         toRemessaOutrasOcorrencias              : ATipoOcorrencia := '31'; {Conceder desconto}
         toRemessaCancelarDesconto               : ATipoOcorrencia := '32'; {N�o conceder desconto}
      else
         ATipoOcorrencia := '01';                                           {Registro de t�tulos}
      end;

      { Pegando o Aceite do Titulo }
      case Aceite of
         atSim :  ATipoAceite := 'A';
         atNao :  ATipoAceite := 'N';
      end;

      { Pegando o tipo de EspecieDoc }
      if EspecieDoc = 'DM' then
         ATipoEspecieDoc   := '01'
      else if EspecieDoc = 'NP' then
         ATipoEspecieDoc   := '02'
      else if EspecieDoc = 'NS' then
         ATipoEspecieDoc   := '03'
      else if EspecieDoc = 'RC' then
         ATipoEspecieDoc   := '05'
      else if EspecieDoc = 'LC' then 
         ATipoEspecieDoc   := '08'
      else if EspecieDoc = 'DS' then
         ATipoEspecieDoc   := '12'
      else if EspecieDoc = 'ND' then
         ATipoEspecieDoc   := '13'; 

      { Pegando Tipo de Cobran�a}
      case StrToInt(ACBrTitulo.Carteira) of
        11,17 :
          case CaracTitulo of
            tcSimples: aTipoCobranca:='     ';
            tcDescontada: aTipoCobranca:='04DSC';
            tcVendor: aTipoCobranca:='08VDR';
            tcVinculada: aTipoCobranca:='02VIN';
          else
            aTipoCobranca:='     ';
          end;
      else
        aTipoCobranca:='     ';
      end;

      {Intru��es - Protesto}
      if (aTipoOcorrencia = '01') or (aTipoOcorrencia = '09') then
      begin
        if (DataProtesto > 0) and (DataProtesto > Vencimento) then
        begin
          AInstrucao   := '06'; // Protestar em xx dias corridos
          DiasProtesto := IntToStr(DaysBetween(DataProtesto, Vencimento))  
        end;        
      end
      else if ATipoOcorrencia = '02' then // 02-Pedido de Baixa      
        AInstrucao := '44';


      {Pegando Tipo de Sacado}
      case Sacado.Pessoa of
         pFisica   : ATipoSacado := '01';
         pJuridica : ATipoSacado := '02';
      else
         ATipoSacado := '00';
      end;

      {Pegando Tipo de Cedente}
      case ACBrBoleto.Cedente.TipoInscricao of
         pFisica   : ATipoCendente := '01';
         pJuridica : ATipoCendente := '02';
      end;

      AMensagem   := '';
      if Mensagem.Text <> '' then
         AMensagem   := Mensagem.Strings[0];


      with ACBrBoleto do
      begin
         wLinha:= '7' +                                                         // 001 a 001 - ID Registro
                  ATipoCendente +                                               // 002 a 003 - Tipo de inscri��o da empresa 01-CPF / 02-CNPJ
                  PadLeft(OnlyNumber(Cedente.CNPJCPF),14,'0') +                 // 004 a 017 - Inscri��o da empresa
                  aAgencia +                                                    // 018 a 021 - Prefixo da ag�ncia
                  PadRight( Cedente.AgenciaDigito, 1)  +                        // 022 a 022 - DV-prefixo da agencia
                  aConta +                                                      // 023 a 030 - C�digo do cendete/nr. conta corrente da empresa
                  PadRight( Cedente.ContaDigito, 1)  +                          // 031 a 031 - DV-c�digo do cedente
                  PadLeft(OnlyNumber(Cedente.Convenio),7,'0') +                 // 032 a 038 - N�mero do conv�nio
                  PadRight( SeuNumero, 25 ) +                                   // 039 a 063 - N�mero de Controle do Participante
                  PadLeft( ANossoNumero, 17, '0') +                             // 064 a 080 - Nosso n�mero
                  '0000' +                                                      // 081 a 084 - Zeros
                  '   ' +                                                       // 085 a 087 - Complemento do Registro: �Brancos�
                  ' ' +                                                         // 088 a 088 - Indic. Mensagem ou Sac.Avalista
                  '   ' +                                                       // 089 a 091 - Prefixo do t�tulo �Brancos�
                  aModalidade +                                                 // 092 a 094 - Varia��o da carteira
                  IntToStrZero(0,7) +                                           // 095 a 101 - Zero + Zeros
                  aTipoCobranca +                                               // 102 a 106 - Tipo de cobran�a
                  Carteira +                                                    // 107 a 108 - Carteira
                  ATipoOcorrencia +                                             // 109 a 110 - Ocorr�ncia "Comando"
                  PadRight( NumeroDocumento, 10, ' ') +                         // 111 a 120 - Seu N�mero - Nr. titulo dado pelo cedente
                  FormatDateTime( 'ddmmyy', Vencimento ) +                      // 121 a 126 - Data de vencimento
                  IntToStrZero( Round( ValorDocumento * 100 ), 13) +            // 127 a 139 - Valor do titulo
                  '085' + '0000' + ' ' +                                        // 140 a 147 - Numero do Banco - 085 + Prefixo da ag�ncia cobradora + DV-pref. ag�ncia cobradora
                  PadLeft(ATipoEspecieDoc, 2, '0') +                            // 148 a 149 - Especie de titulo
                  ATipoAceite +                                                 // 150 a 150 - Aceite
                  FormatDateTime( 'ddmmyy', DataDocumento ) +                   // 151 a 156 - Data de Emiss�o
                  PadLeft(AInstrucao, 2, '0') +                                 // 157 a 158 - Instru��o codificada (c�d. Protesto)
                  '  ' +                                                        // 159 a 160 - Brancos
                  IntToStrZero( round(ValorMoraJuros * 100 ), 13) +             // 161 a 173 - Juros de mora por dia
                  IntToStrZero(0,6) +                                           // 174 a 179 - Zeros
                  IntToStrZero( round( ValorDesconto * 100), 13) +              // 180 a 192 - Valor do desconto
                  IntToStrZero(0,13) +                                          // 193 a 205 - Zeros
                  IntToStrZero( round( ValorAbatimento * 100 ), 13) +           // 206 a 218 - Valor do abatimento permitido
                  ATipoSacado +                                                 // 219 a 220 - Tipo de inscricao do sacado
                  PadLeft(OnlyNumber(Sacado.CNPJCPF),14,'0') +                  // 221 a 234 - CNPJ ou CPF do sacado
                  PadRight( Sacado.NomeSacado, 37) +                            // 235 a 271 - Nome do sacado
                  '   '  +                                                      // 272 a 274 - Brancos
                  PadRight(trim(Sacado.Logradouro) + ', ' +
                    trim(Sacado.Numero), 40) +                                  // 275 a 314 - Endere�o do sacado
                  PadRight(trim(Sacado.Bairro), 12) +                           // 315 a 326 - Bairro do Sacado
                  PadLeft( OnlyNumber(Sacado.CEP), 8 ) +                        // 327 a 334 - CEP do endere�o do sacado
                  PadRight( trim(Sacado.Cidade), 15) +                          // 335 a 349 - Cidade do sacado
                  PadRight( Sacado.UF, 2 ) +                                    // 350 a 351 - UF da cidade do sacado
                  PadRight( AMensagem, 40) +                                    // 352 a 391 - Observa��es
                  IfThen( DiasProtesto <> EmptyStr,
                          PadLeft(DiasProtesto ,2,'0'),
                          Space(2)) +                                           // 392 a 393 - N�mero de dias para protesto (deixar em branco se n�o houver instru��o de protesto)
                  ' ' +                                                         // 394 a 394 - Branco
                  IntToStrZero( aRemessa.Count + 1, 6 );                        // 395 a 400 - Sequencial de Registro 

         if PercentualMulta > 0 then
           wLinha:= wLinha + sLineBreak +
                  '5' +                                                         //Tipo Registro
                  '99' +                                                        //Tipo de Servi�o (Cobran�a de Multa)
                  IfThen(PercentualMulta > 0, '2','9') +                        //Cod. Multa 2- Percentual 9-Sem Multa
                  IfThen(PercentualMulta > 0,
                         FormatDateTime('ddmmyy', DataMoraJuros),
                                        '000000') +                             //Data Multa
                  IntToStrZero( round( PercentualMulta * 100), 12) +            //Perc. Multa
                  Space(372) +                                                  //Brancos
                  IntToStrZero(aRemessa.Count + 2 ,6);

         aRemessa.Text := aRemessa.Text + UpperCase(wLinha);
      end;
   end;
end;

function TACBrBancoCecred.GerarRegistroTrailler240(ARemessa: TStringList): String;
var
  wQTDTitulos : Integer;
begin
  wQTDTitulos := ARemessa.Count - 1;

  //REGISTRO TRAILER DO LOTE
  Result:= IntToStrZero(ACBrBanco.Numero, 3)                          + // 1 a 3 - C�digo do banco
           '0001'                                                     + // 4 a 7 - N�mero do lote
           '5'                                                        + // 8 - Tipo do registro: Registro trailer do lote
           Space(9)                                                   + // 9 - 17 - Uso exclusivo FEBRABAN/CNAB
           IntToStrZero((3 * wQTDTitulos + 2), 6)                     + // 18 a 23 - Quantidade de Registro no Lote
           IntToStrZero((wQTDTitulos), 6)                             + // 24 a 29 - Quantidade t�tulos em cobran�a - Cobr. Simples
           IntToStrZero( round( fValorTotalDocs * 100), 17)           + // 30 a 46 - Valor dos t�tulos em carteiras - Cobr. Simples
           PadRight('', 6, '0')                                       + // 47 a 52 - Quantidade t�tulos em cobran�a - Cobr. Vinculada
           PadRight('',17, '0')                                       + // 53 a 69 - Valor dos t�tulos em carteiras - Cobr. Vinculada
           PadRight('', 6, '0')                                       + // 70 a 75 - Quantidade t�tulos em cobran�a - Cobr. Caucionada
           PadRight('',17, '0')                                       + // 76 a 92 - Valor dos t�tulos em carteiras - Cobr. Caucionada
           PadRight('', 6, '0')                                       + // 93 a 98 - Quantidade t�tulos em cobran�a - Cobr. Descontada
           PadRight('',17, '0')                                       + // 99 a 115 - Valor dos t�tulos em carteiras - Cobr. Descontada
           Space(8)                                                   + // 116 a 123 - Numero do Aviso de lan�amento
           PadRight('',117,' ');                                        // 124 a 240 - Uso exclusivo FEBRABAN/CNAB

  //GERAR REGISTRO TRAILER DO ARQUIVO
  Result:= Result + #13#10 +
           IntToStrZero(ACBrBanco.Numero, 3)                          + // 1 a 3 - C�digo do banco
           '9999'                                                     + // 4 a 4 - Lote de servi�o
           '9'                                                        + // 8 - Tipo do registro: Registro trailer do arquivo
           space(9)                                                   + // 9 a 17 - Uso exclusivo FEBRABAN/CNAB
           '000001'                                                   + // 18 a 23 - Quantidade de lotes do arquivo
           IntToStrZero((wQTDTitulos * 2) + fCountRegR + 4, 6)        + // 24 a 29 - Quantidade de registros do arquivo
           PadRight('', 6, '0')                                       + // 30 a 35 - Qtde de contas concil
           space(205);                                                  // 36 a 240 - Uso exclusivo FEBRABAN/CNAB
end;

procedure TACBrBancoCecred.GerarRegistroTrailler400(
  ARemessa: TStringList);
var
  wLinha: String;
begin
   wLinha := '9' + Space(393)                     + // ID Registro
             IntToStrZero(ARemessa.Count + 1, 6);  // Contador de Registros

   ARemessa.Text:= ARemessa.Text + UpperCase(wLinha);
end;

function TACBrBancoCecred.TipoOCorrenciaToCod (
   const TipoOcorrencia: TACBrTipoOcorrencia ) : String;
begin
  Result := '';

  if (ACBrBanco.ACBrBoleto.LayoutRemessa = c240) then
  begin
    case TipoOcorrencia of
      toRetornoRegistroRecusado                                : Result := '03';
      toRetornoTransferenciaCarteiraEntrada                    : Result := '04';
      toRetornoTransferenciaCarteiraBaixa                      : Result := '05';
      toRetornoRecebimentoInstrucaoConcederDesconto            : Result := '07';
      toRetornoRecebimentoInstrucaoCancelarDesconto            : Result := '08';
      toRetornoRecebimentoInstrucaoSustarProtesto              : Result := '20';
      toRetornoRetiradoDeCartorio                              : Result := '24';
      toRetornoBaixaPorProtesto                                : Result := '25';
      toRetornoInstrucaoRejeitada                              : Result := '26';
      toRetornoAlteracaoUsoCedente                             : Result := '27';
      toRetornoDebitoTarifas                                   : Result := '28';
      toRetornoAlteracaoOutrosDadosRejeitada                   : Result := '30';
      toRetornoRecebimentoInstrucaoAlterarNomeSacado           : Result := '42';
      toRetornoProtestoOuSustacaoEstornado                     : Result := '46';
    end;
  end
  else
  begin
    case TipoOcorrencia of
      toRetornoComandoRecusado                                 : Result := '03';
      toRetornoLiquidadoPorConta                               : Result := '07';
      toRetornoLiquidadoSaldoRestante                          : Result := '08';
      toRetornoBaixaSolicitada                                 : Result := '10';
      toRetornoLiquidadoEmCartorio                             : Result := '15';
      toRetornoConfirmacaoAlteracaoJurosMora                   : Result := '16';
      toRetornoRecebimentoInstrucaoAlterarNomeSacado           : Result := '21';
      toRetornoRecebimentoInstrucaoAlterarEnderecoSacado       : Result := '22';
      toRetornoProtestoSustado                                 : Result := '24';
      toRetornoJurosDispensados                                : Result := '25';
      toRetornoAlteracaoSeuNumero                              : Result := '26';
      toRetornoManutencaoTituloVencido                         : Result := '28';
      toRetornoDescontoConcedido                               : Result := '31';
      toRetornoDespesasProtesto                                : Result := '96';
      toRetornoDespesasSustacaoProtesto                        : Result := '97';
      toRetornoDebitoCustasAntecipadas                         : Result := '98';
    end;
  end;

  if (Result <> '') then
    Exit;

  case TipoOcorrencia of
    toRetornoRegistroConfirmado                                : Result := '02';
    toRetornoLiquidado                                         : Result := '06';
    toRetornoBaixado                                           : Result := '09';
    toRetornoTituloEmSer                                       : Result := '11';
    toRetornoAbatimentoConcedido                               : Result := '12';
    toRetornoAbatimentoCancelado                               : Result := '13';
    toRetornoVencimentoAlterado                                : Result := '14';
    toRetornoLiquidadoAposBaixaOuNaoRegistro                   : Result := '17';
    toRetornoRecebimentoInstrucaoProtestar                     : Result := '19';
    toRetornoEncaminhadoACartorio                              : Result := '23';
  else
    Result := '02';
  end;
end;

function TACBrBancoCecred.TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String;
var
 CodOcorrencia: Integer;
begin
  Result := '';
  CodOcorrencia := StrToIntDef(TipoOCorrenciaToCod(TipoOcorrencia),0);

  if (ACBrBanco.ACBrBoleto.LayoutRemessa = c240) then
  begin
    case CodOcorrencia of
      03: Result := '03-Entrada Rejeitada';
      04: Result := '04-Transfer�ncia de Carteira/Entrada';
      05: Result := '05-Transfer�ncia de Carteira/Baixa';
      07: Result := '07-Confirma��o do Recebimento da Instru��o de Desconto';
      08: Result := '08-Confirma��o do Recebimento do Cancelamento do Desconto';
      20: Result := '20-Confirma��o Recebimento Instru��o de Susta��o/Cancelamento de Protesto';
      24: Result := '24-Retirada de Cart�rio e Manuten��o em Carteira';
      25: Result := '25-Protestado e Baixado';
      26: Result := '26-Instru��o Rejeitada';
      27: Result := '27-Confirma��o do Pedido de Altera��o de Outros Dados';
      28: Result := '28-D�bito de Tarifas/Custas';
      30: Result := '30-Altera��o de Dados Rejeitada';
      42: Result := '42-Confirma��o da Altera��o dos dados do Sacado';
      46: Result := '46-Instru��o para Cancelar Protesto Confirmada';
    end;
  end
  else
  begin
    case CodOcorrencia of
      03: Result := '03-Comando Recusado';
      07: Result := '07-Liquida��o por Conta';
      08: Result := '08-Liquida��o por Saldo';
      10: Result := '10-Baixa Solicitada';
      15: Result := '15-Liquida��o em Cart�rio';
      16: Result := '16-Confirma��o de Altera��o de Juros de Mora';
      21: Result := '21-Altera��o do Nome do Sacado';
      22: Result := '22-Altera��o do Endere�o do Sacado';
      24: Result := '24-Sustar Protesto';
      25: Result := '25-Dispensar Juros';
      26: Result := '26-Altera��o do N�mero do T�tulo dado pelo Cedente';
      28: Result := '28-Manuten��o de titulo Vencido';
      31: Result := '31-Conceder Desconto';
      96: Result := '96-Despesas de Protesto';
      97: Result := '97-Despesas de Susta��o de Protesto';
      98: Result := '98-D�bito de Custas Antecipadas';
    end;
  end;

  if (Result <> '') then
  Exit;

  case CodOcorrencia of
    02: Result := '02-Confirma��o de Entrada de T�tulo';
    06: Result := '06-Liquida��o Normal';
    09: Result := '09-Baixa de T�tulo';
    11: Result := '11-Titulos em Ser';
    12: Result := '12-Abatimento Concedido';
    13: Result := '13-Abatimento Cancelado';
    14: Result := '14-Altera��o de Vencimento do Titulo';
    17: Result := '17�Liquida��o ap�s Baixa ou Liquida��o de T�tulo n�o Registrado';
    19: Result := '19-Confirma��o de Recebimento de Instru��es para Protesto';
    23: Result := '23-Indica��o de Encaminhamento a Cart�rio';
  end;
end;

function TACBrBancoCecred.CodOcorrenciaToTipo(const CodOcorrencia:
   Integer ) : TACBrTipoOcorrencia;
begin
  Result := toTipoOcorrenciaNenhum;

  if (ACBrBanco.ACBrBoleto.LayoutRemessa = c240) then
  begin
    case CodOcorrencia of
      03: Result := toRetornoRegistroRecusado;
      04: Result := toRetornoTransferenciaCarteiraEntrada;
      05: Result := toRetornoTransferenciaCarteiraBaixa;
      07: Result := toRetornoRecebimentoInstrucaoConcederDesconto;
      08: Result := toRetornoRecebimentoInstrucaoCancelarDesconto;
      20: Result := toRetornoRecebimentoInstrucaoSustarProtesto;
      24: Result := toRetornoRetiradoDeCartorio;
      25: Result := toRetornoBaixaPorProtesto;
      26: Result := toRetornoInstrucaoRejeitada;
      27: Result := toRetornoAlteracaoUsoCedente;
      28: Result := toRetornoDebitoTarifas;
      30: Result := toRetornoAlteracaoOutrosDadosRejeitada;
      42: Result := toRetornoRecebimentoInstrucaoAlterarNomeSacado;
      46: Result := toRetornoProtestoOuSustacaoEstornado;
    end;
  end
  else
  begin
    case CodOcorrencia of
      03: Result := toRetornoComandoRecusado;
      07: Result := toRetornoLiquidadoPorConta;
      08: Result := toRetornoLiquidadoSaldoRestante;
      10: Result := toRetornoBaixaSolicitada;
      15: Result := toRetornoLiquidadoEmCartorio;
      16: Result := toRetornoConfirmacaoAlteracaoJurosMora;
      21: Result := toRetornoRecebimentoInstrucaoAlterarNomeSacado;
      22: Result := toRetornoRecebimentoInstrucaoAlterarEnderecoSacado;
      24: Result := toRetornoProtestoSustado;
      25: Result := toRetornoJurosDispensados;
      26: Result := toRetornoAlteracaoSeuNumero;
      28: Result := toRetornoManutencaoTituloVencido;
      31: Result := toRetornoDescontoConcedido;
      96: Result := toRetornoDespesasProtesto;
      97: Result := toRetornoDespesasSustacaoProtesto;
      98: Result := toRetornoDebitoCustasAntecipadas;
    end;
  end;

  if (Result <> toTipoOcorrenciaNenhum) then
    Exit;

  case CodOcorrencia of
    02: Result := toRetornoRegistroConfirmado;
    06: Result := toRetornoLiquidado;
    09: Result := toRetornoBaixado;
    11: Result := toRetornoTituloEmSer;
    12: Result := toRetornoAbatimentoConcedido;
    13: Result := toRetornoAbatimentoCancelado;
    14: Result := toRetornoVencimentoAlterado;
    17: Result := toRetornoLiquidadoAposBaixaOuNaoRegistro;
    19: Result := toRetornoRecebimentoInstrucaoProtestar;
    23: Result := toRetornoEncaminhadoACartorio;
  else
    Result := toRetornoOutrasOcorrencias;
  end;
end;

function TACBrBancoCecred.CodOcorrenciaToTipoRemessa(const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02 : Result:= toRemessaBaixar;                          {Pedido de Baixa}
    04 : Result:= toRemessaConcederAbatimento;              {Concess�o de Abatimento}
    05 : Result:= toRemessaCancelarAbatimento;              {Cancelamento de Abatimento concedido}
    06 : Result:= toRemessaAlterarVencimento;               {Altera��o de vencimento}
    07 : Result:= toRemessaAlterarControleParticipante;     {Altera��o do controle do participante}
    08 : Result:= toRemessaAlterarNumeroControle;           {Altera��o de seu n�mero}
    09 : Result:= toRemessaProtestar;                       {Pedido de protesto}
    10 : Result:= toRemessaCancelarInstrucaoProtestoBaixa;  {Sustar protesto e baixar}
    11 : Result:= toRemessaDispensarJuros;                  {Instru��o para dispensar juros}
    12 : Result:= toRemessaAlterarNomeEnderecoSacado;       {Altera��o de nome e endere�o do Sacado}
    31 : Result:= toRemessaOutrasOcorrencias;               {Altera��o de Outros Dados}
    32 : Result:= toRemessaCancelarDesconto;                {N�o conceder desconto}
  else
     Result:= toRemessaRegistrar;                           {Remessa}
  end;
end;

function TACBrBancoCecred.CodMotivoRejeicaoToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia; CodMotivo: Integer): String;
begin
  case TipoOcorrencia of
    toRetornoComandoRecusado: //03 (Recusado)
      case CodMotivo of
        01: Result:='01-Identifica��o inv�lida' ;
        04: Result:='04-Valor do desconto inv�lido' ;
        05: Result:='05-Esp�cie de t�tulo inv�lida para carteira' ;
        08: Result:='08-Valor do t�tulo/ap�lice inv�lido' ;
        09: Result:='09-Data de vencimento inv�lida' ;
        18: Result:='18-Endere�o do sacado n�o localizado ou incompleto' ;
        24: Result:='24-Valor do abatimento inv�lido' ;
        27: Result:='27-Nome do sacado/cedente inv�lido ou n�o informado' ;
        28: Result:='28-Data do novo vencimento inv�lida' ;
        30: Result:='30-Registro de t�tulo j� liquidado' ;
        36: Result:='36-Dias para fichamento de protesto inv�lido' ;
        37: Result:='37-Data de emiss�o do t�tulo inv�lida' ;
        38: Result:='38-Data do vencimento anterior a data da emiss�o do t�tulo' ;
        39: Result:='39-Comando de altera��o indevido para a carteira' ;
        41: Result:='41-Abatimento n�o permitido' ;
        42: Result:='42-CEP/UF inv�lido/n�o compat�veis (ECT)' ;
        52: Result:='52-Abatimento igual ou maior que o valor do t�tulo' ;
        68: Result:='68-C�digo/Data/Percentual de multa inv�lido' ;
        69: Result:='69-Valor/Percentual de juros inv�lido' ;
        80: Result:='80-Nosso n�mero inv�lido' ;
        81: Result:='81-Data para concess�o do desconto inv�lida' ;
        82: Result:='82-CEP do sacado inv�lido' ;
        84: Result:='84-T�tulo n�o localizado na existencia' ;
        99: Result:='99-Outros motivos' ;
      end;

    toRetornoLiquidado,
    toRetornoLiquidadoEmCartorio:   // Comandos 06 e 15 posi��es 109/110 
      case CodMotivo of
        01: Result:='01-Liquida��o normal';
        09: Result:='09-Liquida��o em cart�rio';
      end;
    toRetornoRegistroConfirmado: //02 (Entrada)
      case CodMotivo of
        00: Result:='00-Por meio magn�tico';
        50: Result:='50-Sacado DDA';
      end;
    toRetornoBaixado, toRetornoBaixaSolicitada:  // 09 ou 10 (Baixa)
      case CodMotivo of
        00: Result:='00-Solicitada pelo cliente';
        15: Result:='15-Protestado';
        90: Result:='90-Baixa autom�tica';
      end;
  end;
end;

procedure TACBrBancoCecred.LerRetorno240(ARetorno: TStringList);
var
  Titulo: TACBrTitulo;
  TempData, Linha, rCedente, rCNPJCPF, rConta: String;
  ContLinha : Integer;
  idxMotivo: Integer;
begin
   // informa��o do Header
   // Verifica se o arquivo pertence ao banco
   if StrToIntDef(copy(ARetorno.Strings[0], 1, 3),-1) <> Numero then
     raise Exception.create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                            'n�o' + '� um arquivo de retorno do ' + Nome));

   ACBrBanco.ACBrBoleto.DataArquivo := StringToDateTimeDef(Copy(ARetorno[0],144,2)+'/'+
                                                           Copy(ARetorno[0],146,2)+'/'+
                                                           Copy(ARetorno[0],148,4),0, 'DD/MM/YYYY' );

   ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0],158,6),0);

   rCedente := trim(copy(ARetorno[0], 73, 30));
   rCNPJCPF := OnlyNumber( copy(ARetorno[0], 19, 14) );
   rConta := OnlyNumber( copy(ARetorno[0], 60, 11) ); //OnlyNumber( copy(ARetorno[0], 67, 4) );

   ValidarDadosRetorno('', '', rCNPJCPF);
   with ACBrBanco.ACBrBoleto do
   begin
     if LeCedenteRetorno then
     begin
       Cedente.Nome    := rCedente;
       Cedente.CNPJCPF := rCNPJCPF;
       Cedente.Conta   := rConta;

       if StrToIntDef(copy(ARetorno[0], 18, 1), 0) = 1 then
         Cedente.TipoInscricao := pFisica
       else
         Cedente.TipoInscricao := pJuridica;
     end;

     ACBrBanco.ACBrBoleto.ListadeBoletos.Clear;
   end;

   ACBrBanco.TamanhoMaximoNossoNum := 20;

   Linha := '';
   Titulo := nil;

   for ContLinha := 1 to ARetorno.Count - 2 do
   begin
     Linha := ARetorno[ContLinha];

     if copy(Linha, 8, 1) <> '3' then // verifica se o registro (linha) � um registro detalhe (segmento J)
       Continue;

     if copy(Linha, 14, 1) = 'T' then // se for segmento T cria um novo titulo
       Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;

     if Assigned(Titulo) then
     with Titulo do
     begin
       if copy(Linha, 14, 1) = 'T' then
       begin
         SeuNumero       := copy(Linha, 106, 25);
         NumeroDocumento := copy(Linha, 59, 15);
         Carteira        := copy(Linha, 58, 1);

         TempData := copy(Linha, 74, 2) + '/'+copy(Linha, 76, 2)+'/'+copy(Linha, 78, 4);
         if TempData<>'00/00/0000' then
           Vencimento := StringToDateTimeDef(TempData, 0, 'DDMMYY');

         ValorDocumento       := StrToFloatDef(copy(Linha, 82, 15), 0) / 100;
         NossoNumero          := copy(Linha, 38, 20);
         ValorDespesaCobranca := StrToFloatDef(copy(Linha, 199, 15), 0) / 100;

         OcorrenciaOriginal.Tipo := CodOcorrenciaToTipo(StrToIntDef(copy(Linha, 16, 2), 0));

         IdxMotivo := 214;

         while (IdxMotivo < 223) do
         begin
           if (trim(Copy(Linha, IdxMotivo, 2)) <> '') then
           begin
             MotivoRejeicaoComando.Add(Copy(Linha, IdxMotivo, 2));
             DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo, StrToIntDef(Copy(Linha, IdxMotivo, 2), 0)));
           end;
           Inc(IdxMotivo, 2);
         end;
       end
       else // segmento U
       begin
         ValorIOF            := StrToFloatDef(copy(Linha, 63, 15), 0) / 100;
         ValorAbatimento     := StrToFloatDef(copy(Linha, 48, 15), 0) / 100;
         ValorDesconto       := StrToFloatDef(copy(Linha, 33, 15), 0) / 100;
         ValorMoraJuros      := StrToFloatDef(copy(Linha, 18, 15), 0) / 100;
         ValorOutrosCreditos := StrToFloatDef(copy(Linha, 108, 15), 0) / 100;
         ValorRecebido       := StrToFloatDef(copy(Linha, 78, 15), 0) / 100;

         TempData := copy(Linha, 138, 2)+'/'+copy(Linha, 140, 2)+'/'+copy(Linha, 142, 4);
         if TempData <> '00/00/0000' then
           DataOcorrencia := StringToDateTimeDef(TempData, 0, 'DDMMYY');

         TempData := copy(Linha, 146, 2)+'/'+copy(Linha, 148, 2)+'/'+copy(Linha, 150, 4);
         if TempData<>'00/00/0000' then
           DataCredito := StringToDateTimeDef(TempData, 0, 'DDMMYYYY');
       end;
     end;
   end;

   ACBrBanco.TamanhoMaximoNossoNum := 10;
end;

procedure TACBrBancoCecred.LerRetorno400(ARetorno: TStringList);
var
  Titulo : TACBrTitulo;
  ContLinha, CodOcorrencia, CodMotivo, MotivoLinha : Integer;
  rAgencia, rDigitoAgencia, rConta :String;
  rDigitoConta, rCodigoCedente     :String;
  Linha, rCedente                  :String;
begin
   fpTamanhoMaximoNossoNum := 17;

   if StrToIntDef(copy(ARetorno.Strings[0],77,3),-1) <> Numero then
      raise Exception.Create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                             'n�o � um arquivo de retorno do '+ Nome));

   rCedente      := trim(Copy(ARetorno[0],47,30));
   rAgencia      := trim(Copy(ARetorno[0],27,4));
   rDigitoAgencia:= Copy(ARetorno[0],31,1);
   rConta        := trim(Copy(ARetorno[0],32,8));
   rDigitoConta  := Copy(ARetorno[0],40,1);

   rCodigoCedente:= Copy(ARetorno[0],41,6);


   ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0],41,6),0);

   ACBrBanco.ACBrBoleto.DataArquivo   := StringToDateTimeDef(Copy(ARetorno[0],95,2)+'/'+
                                                             Copy(ARetorno[0],97,2)+'/'+
                                                             Copy(ARetorno[0],99,2),0, 'DD/MM/YY' );

   ValidarDadosRetorno(rAgencia, rConta);
   with ACBrBanco.ACBrBoleto do
   begin
      Cedente.Nome         := rCedente;
      Cedente.Agencia      := rAgencia;
      Cedente.AgenciaDigito:= rDigitoAgencia;
      Cedente.Conta        := rConta;
      Cedente.ContaDigito  := rDigitoConta;
      Cedente.CodigoCedente:= rCodigoCedente;

      ACBrBanco.ACBrBoleto.ListadeBoletos.Clear;
   end;

   ACBrBanco.TamanhoMaximoNossoNum := fpTamanhoMaximoNossoNum;

   for ContLinha := 1 to ARetorno.Count - 2 do
   begin
      Linha := ARetorno[ContLinha] ;

      if (Copy(Linha,1,1) <> '7') then
         Continue;

      Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;

      with Titulo do
      begin
         SeuNumero                   := copy(Linha,39,25);
         NumeroDocumento             := copy(Linha,117,10);
         OcorrenciaOriginal.Tipo     := CodOcorrenciaToTipo(StrToIntDef(
                                        copy(Linha,109,2),0));

         CodOcorrencia := StrToIntDef(IfThen(copy(Linha,109,2) = '00','00',copy(Linha,109,2)),0);

         if (CodOcorrencia = 5) or
            (CodOcorrencia = 6) or
            (CodOcorrencia = 7) or
            (CodOcorrencia = 8) or
            (CodOcorrencia = 15) or
            (CodOcorrencia = 46) then
         begin
           CodigoLiquidacao := copy(Linha,109,2);
           CodigoLiquidacaoDescricao := TipoOcorrenciaToDescricao(OcorrenciaOriginal.Tipo);
         end;


         if(CodOcorrencia >= 2) and ((CodOcorrencia <= 10)) then
         begin
           MotivoLinha:= 81;
           CodMotivo:= StrToInt(IfThen(copy(Linha,MotivoLinha,2) = '00','00',copy(Linha,MotivoLinha,2)));
           MotivoRejeicaoComando.Add(copy(Linha,MotivoLinha,2));
           DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo,CodMotivo));
         end;

         DataOcorrencia := StringToDateTimeDef( Copy(Linha,111,2)+'/'+
                                                Copy(Linha,113,2)+'/'+
                                                Copy(Linha,115,2),0, 'DD/MM/YY' );

         Vencimento := StringToDateTimeDef( Copy(Linha,147,2)+'/'+
                                            Copy(Linha,149,2)+'/'+
                                            Copy(Linha,151,2),0, 'DD/MM/YY' );

         ValorDocumento       := StrToFloatDef(Copy(Linha,153,13),0)/100;
         ValorIOF             := StrToFloatDef(Copy(Linha,215,13),0)/100;
         ValorAbatimento      := StrToFloatDef(Copy(Linha,228,13),0)/100;
         ValorDesconto        := StrToFloatDef(Copy(Linha,241,13),0)/100;
         ValorRecebido        := StrToFloatDef(Copy(Linha,306,13),0)/100;
         ValorMoraJuros       := StrToFloatDef(Copy(Linha,267,13),0)/100;
         ValorOutrosCreditos  := StrToFloatDef(Copy(Linha,280,13),0)/100;
         NossoNumero          := Copy(Linha,64,17);
         Carteira             := Copy(Linha,107,2);
         ValorDespesaCobranca := StrToFloatDef(Copy(Linha,182,07),0)/100;
         ValorOutrasDespesas  := StrToFloatDef(Copy(Linha,189,13),0)/100;

         if StrToIntDef(Copy(Linha,176,6),0) <> 0 then
            DataCredito:= StringToDateTimeDef( Copy(Linha,176,2)+'/'+
                                               Copy(Linha,178,2)+'/'+
                                               Copy(Linha,180,2),0, 'DD/MM/YY' );
      end;
   end;

   fpTamanhoMaximoNossoNum := 17;
end;


end.
