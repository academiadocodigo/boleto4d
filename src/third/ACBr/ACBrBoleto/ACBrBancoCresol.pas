{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Lucas R L Reis                                  }
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

unit ACBrBancoCresol;

interface

uses
  Classes, Contnrs, SysUtils, ACBrBoleto, ACBrBoletoConversao;

type

  { TACBrBancoCresol }

  TACBrBancoCresol = class(TACBrBancoClass)
  private
  protected
  public
    Constructor create(AOwner: TACBrBanco);
    function CalcularDigitoVerificador(const ACBrTitulo:TACBrTitulo): String; override;
    function MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String; override;
    function MontarCampoNossoNumero(const ACBrTitulo :TACBrTitulo): String; override;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String; override;
    procedure GerarRegistroHeader400(NumeroRemessa : Integer; ARemessa:TStringList); override;
    procedure GerarRegistroTransacao400(ACBrTitulo : TACBrTitulo; aRemessa: TStringList); override;
    procedure GerarRegistroTrailler400(ARemessa:TStringList);  override;
    Procedure LerRetorno400(ARetorno:TStringList); override;

    function TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia) : String; override;
    function CodOcorrenciaToTipo(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
    function TipoOCorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia):String; override;
    function CodMotivoRejeicaoToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia; const CodMotivo:String): String; override;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
  end;

implementation

uses {$IFDEF COMPILER6_UP} dateutils {$ELSE} ACBrD5 {$ENDIF},
  StrUtils,
  ACBrUtil ;

{ TACBrBancoCresol }

constructor TACBrBancoCresol.create(AOwner: TACBrBanco);
begin
   inherited create(AOwner);
   fpDigito                 := 2;
   fpNome                   := 'Bradesco';
   fpNumero                 := 237;
   fpNumeroCorrespondente   := 133;
   fpTamanhoMaximoNossoNum  := 11;   
   fpTamanhoAgencia         := 5;
   fpTamanhoConta           := 7;
   fpTamanhoCarteira        := 2;
end;

function TACBrBancoCresol.CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String;
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

function TACBrBancoCresol.MontarCodigoBarras ( const ACBrTitulo: TACBrTitulo) : String;
var
  CodigoBarras, FatorVencimento, DigitoCodBarras:String;
begin
   with ACBrTitulo.ACBrBoleto do
   begin
      FatorVencimento := CalcularFatorVencimento(ACBrTitulo.Vencimento);

      CodigoBarras := IntToStr(Numero) + '9' + FatorVencimento +
                      IntToStrZero(Round(ACBrTitulo.ValorDocumento * 100), 10) +
                      IntToStrZero(StrToIntDef(Cedente.Agencia,0),4) +
                      ACBrTitulo.Carteira +
                      ACBrTitulo.NossoNumero +
                      PadLeft(RightStr(Cedente.Conta, 7), 7, '0') + '0';

      DigitoCodBarras := CalcularDigitoCodigoBarras(CodigoBarras);
   end;

   Result:= IntToStr(Numero) + '9' + DigitoCodBarras + Copy(CodigoBarras, 5, 39);
end;

function TACBrBancoCresol.MontarCampoNossoNumero (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result:= ACBrTitulo.Carteira + '/' + ACBrTitulo.NossoNumero + '-' + CalcularDigitoVerificador(ACBrTitulo);
end;

function TACBrBancoCresol.MontarCampoCodigoCedente (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result := IntToStrZero(StrToIntDef(ACBrTitulo.ACBrBoleto.Cedente.Agencia,0),4) + '-' +
             ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito + '/' +
             ACBrTitulo.ACBrBoleto.Cedente.Conta + '-' +
             ACBrTitulo.ACBrBoleto.Cedente.ContaDigito;
end;

procedure TACBrBancoCresol.GerarRegistroHeader400(NumeroRemessa : Integer; ARemessa:TStringList);
var
  wLinha: String;
begin
   with ACBrBanco.ACBrBoleto.Cedente do
   begin
      wLinha:= '0'                                             + // ID do Registro
               '1'                                             + // ID do Arquivo( 1 - Remessa)
               'REMESSA'                                       + // Literal de Remessa
               '01'                                            + // C�digo do Tipo de Servi�o
               PadRight( 'COBRANCA', 15 )                      + // Descri��o do tipo de servi�o
               PadLeft( Convenio, 20, '0')                     + // Codigo da Empresa no Banco
               PadLeft( Copy(Nome,1,30) , 30)                  + // Nome da Empresa                                17/04/2020
               IntToStr( Numero )+ PadRight('BRADESCO', 15)    + // C�digo e Nome do Banco(237 - Bradesco)
               FormatDateTime('DDMMYY',Now)                    + // Data de gera��o do arquivo                     17/04/2020
               Space(08) + Space(02)                           + // brancos
               IntToStrZero(NumeroRemessa, 7) + Space(277)     + // Nr. Sequencial de Remessa + brancos
               IntToStrZero(1, 6);                               // Nr. Sequencial de Remessa + brancos + Contador

      ARemessa.Text:= ARemessa.Text + UpperCase(wLinha);
   end;
end;

procedure TACBrBancoCresol.GerarRegistroTransacao400(ACBrTitulo :TACBrTitulo; aRemessa: TStringList);
var
  DigitoNossoNumero, Ocorrencia, aEspecie, aAgencia :String;
  TipoSacado, MensagemCedente, aConta     :String;
  aCarteira, wLinha, ANossoNumero: String;
  TipoBoleto :Char;
  aPercMulta: Double;

  function DoMontaInstrucoes1: string;
  begin
     Result := '';
     with ACBrTitulo, ACBrBoleto do
     begin

        {Primeira instru��o vai no registro 1}
        if Mensagem.Count <= 1 then
        begin
           Result := '';
           Exit;
        end;

        Result := sLineBreak +
                  '2'               +                                    // IDENTIFICA��O DO LAYOUT PARA O REGISTRO
                  Copy(PadRight(Mensagem[1], 80, ' '), 1, 80);               // CONTE�DO DA 1� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO

        if Mensagem.Count >= 3 then
           Result := Result +
                     Copy(PadRight(Mensagem[2], 80, ' '), 1, 80)              // CONTE�DO DA 2� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO
        else
           Result := Result + PadRight('', 80, ' ');                          // CONTE�DO DO RESTANTE DAS LINHAS

        if Mensagem.Count >= 4 then
           Result := Result +
                     Copy(PadRight(Mensagem[3], 80, ' '), 1, 80)              // CONTE�DO DA 3� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO
        else
           Result := Result + PadRight('', 80, ' ');                          // CONTE�DO DO RESTANTE DAS LINHAS

        if Mensagem.Count >= 5 then
           Result := Result +
                     Copy(PadRight(Mensagem[4], 80, ' '), 1, 80)              // CONTE�DO DA 4� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO
        else
           Result := Result + PadRight('', 80, ' ');                          // CONTE�DO DO RESTANTE DAS LINHAS


        Result := Result                                              +       // 001 a 321 - Mensagens
                  PadLeft('', 6,  '0')                                +       // 322 a 327 - Data limite para concess�o de Desconto 2
                  PadLeft('', 13, '0')                                +       // 328 a 340 - Valor do Desconto 2
                  PadLeft('', 6,  '0')                                +       // 341 a 346 - Data limite para concess�o de Desconto 3
                  PadLeft('', 13, '0')                                +       // 347 a 359 - Valor do Desconto 3
                  space(7)                                            +       // 360 a 366 - Reserva
                  aCarteira                                           +
                  aAgencia                                            +
                  aConta                                              +
                  Cedente.ContaDigito                                 +
                  ANossoNumero + DigitoNossoNumero                    +
                  IntToStrZero( aRemessa.Count + 2, 6);                  // N� SEQ�ENCIAL DO REGISTRO NO ARQUIVO
     end;
  end;

begin
   with ACBrTitulo do
   begin
      ANossoNumero := PadLeft(OnlyNumber(ACBrTitulo.NossoNumero), 11, '0');

      if (ACBrBoleto.Cedente.ResponEmissao = tbBancoEmite) and (StrToInt64Def(ANossoNumero, 0) = 0) then
        DigitoNossoNumero := '0'
      else
      begin
        ANossoNumero      := ACBrTitulo.NossoNumero;
        DigitoNossoNumero := CalcularDigitoVerificador(ACBrTitulo);
      end;

      aAgencia := IntToStrZero(StrToIntDef(OnlyNumber(ACBrBoleto.Cedente.Agencia), 0), fpTamanhoAgencia);
      aConta   := IntToStrZero(StrToIntDef(OnlyNumber(ACBrBoleto.Cedente.Conta), 0), fpTamanhoConta);
      aCarteira:= IntToStrZero(StrToIntDef(trim(Carteira), 0), 3);

      {Pegando C�digo da Ocorrencia}
      case OcorrenciaOriginal.Tipo of
         toRemessaBaixar                         : Ocorrencia := '02'; {Pedido de Baixa}
         toRemessaProtestoFinsFalimentares       : Ocorrencia := '03'; {Pedido de Protesto Falimentar}
         toRemessaConcederAbatimento             : Ocorrencia := '04'; {Concess�o de Abatimento}
         toRemessaCancelarAbatimento             : Ocorrencia := '05'; {Cancelamento de Abatimento concedido}
         toRemessaAlterarVencimento              : Ocorrencia := '06'; {Altera��o de vencimento}
         toRemessaAlterarControleParticipante    : Ocorrencia := '07'; {Altera��o do controle do participante}
         toRemessaAlterarNumeroControle          : Ocorrencia := '08'; {Altera��o de seu n�mero}
         toRemessaProtestar                      : Ocorrencia := '09'; {Pedido de protesto}
         toRemessaCancelarInstrucaoProtestoBaixa : Ocorrencia := '10'; {Sustar protesto e baixar}
         toRemessaCancelarInstrucaoProtesto      : Ocorrencia := '11'; {Sustar protesto e manter na carteira}
         toRemessaAlterarValorTitulo             : Ocorrencia := '20'; {Altera��o de valor}
         toRemessaTransferenciaCarteira          : Ocorrencia := '23'; {Transfer�ncia entre carteiras}
         toRemessaDevTransferenciaCarteira       : Ocorrencia := '24'; {Dev. Transfer�ncia entre carteiras}
         toRemessaOutrasOcorrencias              : Ocorrencia := '31'; {Altera��o de Outros Dados}
      else
         Ocorrencia := '01';                                           {Remessa}
      end;

      {Pegando Tipo de Boleto}
      if CarteiraEnvio = tceCedente then
         TipoBoleto := '2'
      else 
         TipoBoleto := '1'; 

      if NossoNumero = EmptyStr then
        DigitoNossoNumero := '0';

      {Pegando Especie}

      if trim(EspecieDoc) = 'CH' then
         aEspecie:= '01'   // cheque
      else if trim(EspecieDoc) = 'DM' then
         aEspecie:= '02'   // Duplicata mercantil
      else if trim(EspecieDoc) = 'DS' then
         aEspecie:= '04'  // Duplicata de servi�o
      else if trim(EspecieDoc) = 'DR' then
         aEspecie:= '06'  // Duplicata rural
      else if trim(EspecieDoc) = 'LC' then
         aEspecie:= '07'  // Letra de cambio
      else if trim(EspecieDoc) = 'NP' then
         aEspecie:= '12'   // Nota promissoria
      else if trim(EspecieDoc) = 'RC' then
         aEspecie:= '17'    // Recibo
      else if trim(EspecieDoc) = 'ND' then
         aEspecie:= '19'   // Nota de d�bito
      else if trim(EspecieDoc) = 'WR' then
         aEspecie:= '26'  // Warrant
      else if trim(EspecieDoc) = 'DE' then
         aEspecie:= '27'  // Divida ativa de estado
      else if trim(EspecieDoc) = 'DAM' then
         aEspecie:= '28'  // Divida ativa municipio
      else if trim(EspecieDoc) = 'DU' then
         aEspecie:= '29'  // Divida ativa da uniao
      else if trim(EspecieDoc) = 'EC' then
         aEspecie:= '30'  // Encargos condominiais
      else if trim(EspecieDoc) = 'OU' then
         aEspecie:= '99'   // Outros
      else
         aEspecie := EspecieDoc;

      {Pegando Tipo de Sacado}
      case Sacado.Pessoa of
         pFisica   : TipoSacado := '01';
         pJuridica : TipoSacado := '02';
      else
         TipoSacado := '99';
      end;
      { Converte valor em moeda para percentual, pois o arquivo s� permite % }
      if MultaValorFixo then
        if ValorDocumento > 0 then
          aPercMulta := (PercentualMulta / ValorDocumento) * 100
        else
          aPercMulta := 0
      else
        aPercMulta := PercentualMulta;

      with ACBrBoleto do
      begin
         if Mensagem.Text <> '' then
            MensagemCedente:= Mensagem[0];

                  wLinha := '1'                                           +  // 001 a 001 - ID Registro
                  Space(19)                                               +  // 002 a 020 - Dados p/ D�bito Autom�tico
                  '0' + aCarteira                                         +  // Carteira
                  aAgencia                                                +  // Agencia
                  aConta                                                  +  // Conta
                  Cedente.ContaDigito                                     +  // D�gito
                  PadRight( SeuNumero,25,' ') + Space(03)                 +  // 038 a 062 - Numero de Controle do Participante + // 063 a 065 - C�digo do Banco
                  IfThen( PercentualMulta > 0, '2', '0')                  +  // 066 a 066 - Indica se exite Multa ou n�o
                  IntToStrZero( round( aPercMulta * 100 ), 4)             +  // 067 a 070 - Percentual de Multa formatado com 2 casas decimais
                  ANossoNumero + DigitoNossoNumero                        +  // 071 a 082 - Identifica��o do Titulo + Digito de auto conferencia de n�mero banc�rio
                  Space(10)                                               +  // 083 a 092 - Desconto Bonifica��o por dia
                  TipoBoleto + ' ' + Space(10)                            +  // 093 a 104 - Tipo Boleto(Quem emite) + Identifica��o se emite boleto para d�bito autom�tico +  Identifica��o Opera��o do Banco
                  ' ' + '2' + '  ' + Ocorrencia                           +  // 105 a 110 - Ind. Rateio de Credito + Aviso de Debito Aut.: 2=N�o emite aviso + BRANCO + Ocorr�ncia
                  PadRight(NumeroDocumento,  10)                          +  // 111 a 120 - Numero Documento
                  FormatDateTime('ddmmyy', Vencimento)                    +  // 121 a 126 - Data Vencimento
                  IntToStrZero( Round( ValorDocumento * 100 ), 13)        +  // 127 a 139 - Valo Titulo
                  Space(08) + PadRight(aEspecie, 2) + ' '                 +  // 140 a 150 - Zeros + Especie do documento + Idntifica��o(valor fixo N)
                  FormatDateTime( 'ddmmyy', DataDocumento )               +  // 151 a 156 - Data de Emiss�o
                  Space(04)                                               +  // 157 a 160 - Instrucoes
                  IntToStrZero( round(ValorMoraJuros * 100 ), 13)         +  // 161 a 173 - Valor a ser cobrado por dia de atraso
                  IfThen(DataDesconto < EncodeDate(2000,01,01),'000000',
                         FormatDateTime( 'ddmmyy', DataDesconto))         +  // 174 a 179 - Data limite para concess�o desconto
                  IntToStrZero( round( ValorDesconto * 100 ), 13)         +  // 180 a 192 - Valor Desconto
                  IntToStrZero( round( ValorIOF * 100 ), 13)              +  // 193 a 205 - Valor IOF
                  IntToStrZero( round( ValorAbatimento * 100 ), 13)       +  // 206 a 218 - Valor Abatimento
                  TipoSacado                                              +  // 219 a 220 - Tipo Inscricao
                  PadLeft(OnlyNumber(Sacado.CNPJCPF), 14, '0')            +  // 221 a 234 - Tipo de Inscri��o + N�mero de Inscri��o do Pagador
                  PadRight( Sacado.NomeSacado, 40, ' ')                   +  // 235 a 274 - Nome do Pagador
                  PadRight(Sacado.Logradouro + ' ' + Sacado.Numero + ' '  +
                    Sacado.Bairro + ' ' + Sacado.Cidade + ' '             +
                    Sacado.UF, 40)                                        +
                  space(12) + PadRight( Sacado.CEP, 8 )                   +  // 315 a 334 - 1� Mensagem + CEP
                  Space(60);                                                 // 335 a 394 - 2� Mensagem

         wLinha:= wLinha + IntToStrZero(aRemessa.Count + 1, 6); // N� SEQ�ENCIAL DO REGISTRO NO ARQUIVO
         wLinha := wLinha + DoMontaInstrucoes1;

         aRemessa.Text:= aRemessa.Text + UpperCase(wLinha);
      end;
   end;
end;

procedure TACBrBancoCresol.GerarRegistroTrailler400( ARemessa:TStringList );
var
  wLinha: String;
begin
   wLinha := '9' + Space(393)                     + // ID Registro
             IntToStrZero( ARemessa.Count + 1, 6);  // Contador de Registros

   ARemessa.Text:= ARemessa.Text + UpperCase(wLinha);
end;

Procedure TACBrBancoCresol.LerRetorno400 ( ARetorno: TStringList );
var
  Titulo : TACBrTitulo;
  ContLinha, CodOcorrencia  :Integer;
  CodMotivo, i, MotivoLinha :Integer;
  CodMotivo_19, rAgencia    :String;
  rConta, rDigitoConta      :String;
  Linha, rCedente, rCNPJCPF :String;
  rCodConvenio              :String;
begin
   if StrToIntDef(copy(ARetorno.Strings[0], 77, 3), -1) <> Numero then
      raise Exception.Create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                             'n�o � um arquivo de retorno do '+ Nome));

   rCodConvenio := trim(Copy(ARetorno[0], 27, 20)); 
   rCedente   := trim(Copy(ARetorno[0], 47, 30));

   rAgencia := trim(Copy(ARetorno[1], 25, ACBrBanco.TamanhoAgencia));
   rConta   := trim(Copy(ARetorno[1], 30, ACBrBanco.TamanhoConta));

   rDigitoConta := Copy(ARetorno[1], 37, 1);

   ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0], 109, 5), 0);

   ACBrBanco.ACBrBoleto.DataArquivo := StringToDateTimeDef(Copy(ARetorno[0], 95, 2) + '/' +            //|
                                                           Copy(ARetorno[0], 97, 2) + '/' +            //|Implementado por Carlos Fitl - 27/12/2010
                                                           Copy(ARetorno[0], 99, 2), 0, 'DD/MM/YY' );  //|

   ACBrBanco.ACBrBoleto.DataCreditoLanc := StringToDateTimeDef(Copy(ARetorno[0], 380, 2) + '/' +            //|
                                                               Copy(ARetorno[0], 382, 2) + '/' +            //|Implementado por Carlos Fitl - 27/12/2010
                                                               Copy(ARetorno[0], 384, 2), 0, 'DD/MM/YY' );  //|

   case StrToIntDef(Copy(ARetorno[1], 2, 2), 0) of
      11: rCNPJCPF := Copy(ARetorno[1], 7, 11);
      14: rCNPJCPF := Copy(ARetorno[1], 4, 14);
   else
     rCNPJCPF := Copy(ARetorno[1], 4, 14);
   end;

   ValidarDadosRetorno(rAgencia, rConta);

   with ACBrBanco.ACBrBoleto do
   begin

      if (not LeCedenteRetorno) and (rCodConvenio <> PadLeft(OnlyNumber(Cedente.Convenio),20,'0')) then 
         raise Exception.Create(ACBrStr('C�digo da Empresa do arquivo inv�lido'));

      case StrToIntDef(Copy(ARetorno[1], 2, 2), 0) of
         11: Cedente.TipoInscricao:= pFisica;
         14: Cedente.TipoInscricao:= pJuridica;
      else
         Cedente.TipoInscricao := pJuridica;
      end;

      if LeCedenteRetorno then
      begin
         try
           Cedente.CNPJCPF := rCNPJCPF;
         except
           // Retorno quando � CPF est� vindo errado por isso ignora erro na atribui��o
         end;

         Cedente.Nome         := rCedente;
         Cedente.Agencia      := rAgencia;
         Cedente.AgenciaDigito := '0';
         Cedente.Conta        := rConta;
         Cedente.ContaDigito  := rDigitoConta;
      end;

      ACBrBanco.ACBrBoleto.ListadeBoletos.Clear;
   end;

   for ContLinha := 1 to ARetorno.Count - 2 do
   begin
      Linha := ARetorno[ContLinha] ;

      if Copy(Linha, 1, 1) <> '1' then
         Continue;

      Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;

      with Titulo do
      begin
         SeuNumero                   := copy(Linha, 38, 25);
         NumeroDocumento             := copy(Linha, 117, 10);
         OcorrenciaOriginal.Tipo     := CodOcorrenciaToTipo(StrToIntDef(
                                        copy(Linha, 109, 2), 0));

         CodOcorrencia := StrToIntDef(IfThen(copy(Linha, 109, 2) = '00', '00', copy(Linha, 109, 2)), 0);

         //-|Se a ocorrencia for igual a 19 - Confirma��o de Receb. de Protesto
         //-|Verifica o motivo na posi��o 295 - A = Aceite , D = Desprezado
         if(CodOcorrencia = 19)then
          begin
            CodMotivo_19:= copy(Linha, 295, 1);
            if(CodMotivo_19 = 'A')then
             begin
               MotivoRejeicaoComando.Add(copy(Linha, 295, 1));
               DescricaoMotivoRejeicaoComando.Add('A - Aceito');
             end
            else
             begin
               MotivoRejeicaoComando.Add(copy(Linha, 295, 1));
               DescricaoMotivoRejeicaoComando.Add('D - Desprezado');
             end;
          end
         else
          begin
            MotivoLinha := 319;
            for i := 0 to 4 do
            begin
               CodMotivo := StrToInt(IfThen(copy(Linha,MotivoLinha,2) = '00','00',copy(Linha,MotivoLinha,2)));

               {Se for o primeiro motivo}
               if (i = 0) then
                begin
                  {Somente estas ocorrencias possuem motivos 00}
                  if(CodOcorrencia in [02, 06, 09, 10, 15, 17])then
                   begin
                     MotivoRejeicaoComando.Add(IfThen(copy(Linha,MotivoLinha,2) = '00','00',copy(Linha,MotivoLinha,2)));
                     DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo,CodMotivo));
                   end
                  else
                   begin
                     if(CodMotivo = 0)then
                      begin
                        MotivoRejeicaoComando.Add('00');
                        DescricaoMotivoRejeicaoComando.Add('Sem Motivo');
                      end
                     else
                      begin
                        MotivoRejeicaoComando.Add(IfThen(copy(Linha,MotivoLinha,2) = '00','00',copy(Linha,MotivoLinha,2)));
                        DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo,CodMotivo));
                      end;
                   end;
                end
               else
                begin
                  //Apos o 1� motivo os 00 significam que n�o existe mais motivo
                  if CodMotivo <> 0 then
                  begin
                     MotivoRejeicaoComando.Add(IfThen(copy(Linha,MotivoLinha,2) = '00','00',copy(Linha,MotivoLinha,2)));
                     DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo,CodMotivo));
                  end;
                end;

               MotivoLinha := MotivoLinha + 2; //Incrementa a coluna dos motivos
            end;
          end;

         DataOcorrencia := StringToDateTimeDef( Copy(Linha,111,2)+'/'+
                                                Copy(Linha,113,2)+'/'+
                                                Copy(Linha,115,2),0, 'DD/MM/YY' );
         if Copy(Linha,147,2)<>'00' then
            Vencimento := StringToDateTimeDef( Copy(Linha,147,2)+'/'+
                                               Copy(Linha,149,2)+'/'+
                                               Copy(Linha,151,2),0, 'DD/MM/YY' );

         ValorDocumento       := StrToFloatDef(Copy(Linha,153,13),0)/100;
         ValorIOF             := StrToFloatDef(Copy(Linha,215,13),0)/100;
         ValorAbatimento      := StrToFloatDef(Copy(Linha,228,13),0)/100;
         ValorDesconto        := StrToFloatDef(Copy(Linha,241,13),0)/100;
         ValorMoraJuros       := StrToFloatDef(Copy(Linha,267,13),0)/100;
         ValorOutrosCreditos  := StrToFloatDef(Copy(Linha,280,13),0)/100;
         ValorRecebido        := StrToFloatDef(Copy(Linha,254,13),0)/100;
         NossoNumero          := Copy(Linha, 71, 11);
         Carteira             := Copy(Linha, 22, 3);
         ValorDespesaCobranca := StrToFloatDef(Copy(Linha,176,13),0)/100;
         ValorOutrasDespesas  := StrToFloatDef(Copy(Linha,189,13),0)/100;

         if StrToIntDef(Copy(Linha,296,6),0) <> 0 then
            DataCredito:= StringToDateTimeDef( Copy(Linha,296,2)+'/'+
                                               Copy(Linha,298,2)+'/'+
                                               Copy(Linha,300,2),0, 'DD/MM/YY' );
      end;
   end;
end;

function TACBrBancoCresol.TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String;
var
  CodOcorrencia: Integer;
begin
  Result := '';
  CodOcorrencia := StrToIntDef(TipoOCorrenciaToCod(TipoOcorrencia),0);

  if (ACBrBanco.ACBrBoleto.LayoutRemessa = c240) then
  begin
    case CodOcorrencia of
      04: Result := '04-Transfer�ncia de Carteira/Entrada';
      05: Result := '05-Transfer�ncia de Carteira/Baixa';
      07: Result := '07-Confirma��o do Recebimento da Instru��o de Desconto';
      08: Result := '08-Confirma��o do Recebimento do Cancelamento do Desconto';
      15: Result := '15-Franco de Pagamento';
      24: Result := '24-Retirada de Cart�rio e Manuten��o em Carteira';
      25: Result := '25-Protestado e Baixado';
      26: Result := '26-Instru��o Rejeitada';
      27: Result := '27-Confirma��o do Pedido de Altera��o de Outros Dados';
      33: Result := '33-Confirma��o da Altera��o dos Dados do Rateio de Cr�dito';
      34: Result := '34-Confirma��o do Cancelamento dos Dados do Rateio de Cr�dito';
      36: Result := '36-Confirma��o de Envio de E-mail/SMS';
      37: Result := '37-Envio de E-mail/SMS Rejeitado';
      38: Result := '38-Confirma��o de Altera��o do Prazo Limite de Recebimento';
      39: Result := '39-Confirma��o de Dispensa de Prazo Limite de Recebimento';
      40: Result := '40-Confirma��o da Altera��o do N�mero do T�tulo Dado pelo Beneficiario';
      41: Result := '41-Confirma��o da Altera��o do N�mero Controle do Participante';
      42: Result := '42-Confirma��o da Altera��o dos Dados do Pagador';
      43: Result := '43-Confirma��o da Altera��o dos Dados do Sacador/Avalista';
      44: Result := '44-T�tulo Pago com Cheque Devolvido';
      45: Result := '45-T�tulo Pago com Cheque Compensado';
      46: Result := '46-Instru��o para Cancelar Protesto Confirmada';
      47: Result := '47-Instru��o para Protesto para Fins Falimentares Confirmada';
      48: Result := '48-Confirma��o de Instru��o de Transfer�ncia de Carteira/Modalidade de Cobran�a';
      49: Result := '49-Altera��o de Contrato de Cobran�a';
      50: Result := '50-T�tulo Pago com Cheque Pendente de Liquida��o';
      51: Result := '51-T�tulo DDA Reconhecido pelo Pagador';
      52: Result := '52-T�tulo DDA n�o Reconhecido pelo Pagador';
      53: Result := '53-T�tulo DDA recusado pela CIP';
      54: Result := '54-Confirma��o da Instru��o de Baixa de T�tulo Negativado sem Protesto';
    end;
  end
  else
  begin
    case CodOcorrencia of
      10: Result := '10-Baixado Conforme Instru��es da Ag�ncia';
      15: Result := '15-Liquida��o em Cart�rio';
      16: Result := '16-Titulo Pago em Cheque - Vinculado';
      18: Result := '18-Acerto de Deposit�ria';
      21: Result := '21-Acerto do Controle do Participante';
      22: Result := '22-Titulo com Pagamento Cancelado';
      24: Result := '24-Entrada Rejeitada por CEP Irregular';
      25: Result := '25-Confirma��o Recebimento Instru��o de Protesto Falimentar';
      27: Result := '27-Baixa Rejeitada';
      32: Result := '32-Instru��o Rejeitada';
      33: Result := '33-Confirma��o Pedido Altera��o Outros Dados';
      34: Result := '34-Retirado de Cart�rio e Manuten��o Carteira';
      40: Result := '40-Estorno de Pagamento';
      55: Result := '55-Sustado Judicial';
      68: Result := '68-Acerto dos Dados do Rateio de Cr�dito';
      69: Result := '69-Cancelamento dos Dados do Rateio';
      74: Result := '74-Confirma��o Pedido de Exclus�o de Negatativa��o';
    end;
  end;

  if (Result <> '') then
    Exit;

  case CodOcorrencia of
    02: Result := '02-Entrada Confirmada';
    03: Result := '03-Entrada Rejeitada';
    06: Result := '06-Liquida��o Normal';
    09: Result := '09-Baixado Automaticamente via Arquivo';
    11: Result := '11-Em Ser - Arquivo de T�tulos Pendentes';
    12: Result := '12-Abatimento Concedido';
    13: Result := '13-Abatimento Cancelado';
    14: Result := '14-Vencimento Alterado';
    17: Result := '17-Liquida��o ap�s baixa ou T�tulo n�o registrado';
    19: Result := '19-Confirma��o Recebimento Instru��o de Protesto';
    20: Result := '20-Confirma��o Recebimento Instru��o Susta��o de Protesto';
    23: Result := '23-Entrada do T�tulo em Cart�rio';
    28: Result := '28-D�bito de tarifas/custas';
    29: Result := '29-Ocorr�ncias do Pagador';
    30: Result := '30-Altera��o de Outros Dados Rejeitados';
    35: Result := '35-Desagendamento do d�bito autom�tico';
    73: Result := '73-Confirma��o Recebimento Pedido de Negativa��o';
  end;
end;

function TACBrBancoCresol.CodOcorrenciaToTipo(const CodOcorrencia:
   Integer ) : TACBrTipoOcorrencia;
begin
  Result := toTipoOcorrenciaNenhum;

  if (ACBrBanco.ACBrBoleto.LayoutRemessa = c240) then
  begin
    case CodOcorrencia of
      04: Result := toRetornoTransferenciaCarteiraEntrada;
      05: Result := toRetornoTransferenciaCarteiraBaixa;
      07: Result := toRetornoRecebimentoInstrucaoConcederDesconto;
      08: Result := toRetornoRecebimentoInstrucaoCancelarDesconto;
      15: Result := toRetornoBaixadoFrancoPagamento;
      24: Result := toRetornoRetiradoDeCartorio;
      25: Result := toRetornoBaixaPorProtesto;
      26: Result := toRetornoComandoRecusado;
      27: Result := toRetornoRecebimentoInstrucaoAlterarDados;
      33: Result := toRetornoAcertoDadosRateioCredito;
      34: Result := toRetornoCancelamentoDadosRateio;
      36: Result := toRetornoConfirmacaoEmailSMS;
      37: Result := toRetornoEmailSMSRejeitado;
      38: Result := toRetornoAlterarPrazoLimiteRecebimento;
      39: Result := toRetornoDispensarPrazoLimiteRecebimento;
      40: Result := toRetornoAlteracaoSeuNumero;
      41: Result := toRetornoAcertoControleParticipante;
      42: Result := toRetornoRecebimentoInstrucaoAlterarNomeSacado;
      43: Result := toRetornoAlterarSacadorAvalista;
      44: Result := toRetornoChequeDevolvido;
      45: Result := toRetornoChequeCompensado;
      46: Result := toRetornoRecebimentoInstrucaoSustarProtesto;
      47: Result := toRetornoProtestoImediatoFalencia;
      48: Result := toRemessaTransferenciaCarteira;
      49: Result := toRetornoTipoCobrancaAlterado;
      50: Result := toRetornoChequePendenteCompensacao;
      51: Result := toRetornoTituloDDAReconhecidoPagador;
      52: Result := toRetornoTituloDDANaoReconhecidoPagador;
      53: Result := toRetornoTituloDDARecusadoCIP;
      54: Result := toRetornoBaixaTituloNegativadoSemProtesto;
    end;
  end
  else
  begin
    case CodOcorrencia of
      10: Result := toRetornoBaixadoInstAgencia;
      15: Result := toRetornoLiquidadoEmCartorio;
      16: Result := toRetornoTituloPagoEmCheque;
      18: Result := toRetornoAcertoDepositaria;
      21: Result := toRetornoAcertoControleParticipante;
      22: Result := toRetornoTituloPagamentoCancelado;
      24: Result := toRetornoEntradaRejeitaCEPIrregular;
      25: Result := toRetornoProtestoImediatoFalencia;
      27: Result := toRetornoBaixaRejeitada;
      32: Result := toRetornoComandoRecusado;
      33: Result := toRetornoRecebimentoInstrucaoAlterarDados;
      34: Result := toRetornoRetiradoDeCartorio;
      40: Result := toRetornoEstornoPagamento;
      55: Result := toRetornoTituloSustadoJudicialmente;
      68: Result := toRetornoAcertoDadosRateioCredito;
      69: Result := toRetornoCancelamentoDadosRateio;
      74: Result := toRetornoConfirmacaoPedidoExclNegativacao;
    end;
  end;

  if (Result <> toTipoOcorrenciaNenhum) then
    Exit;

  case CodOcorrencia of
    02: Result := toRetornoRegistroConfirmado;
    03: Result := toRetornoRegistroRecusado;
    06: Result := toRetornoLiquidado;
    09: Result := toRetornoBaixadoViaArquivo;
    11: Result := toRetornoTituloEmSer;
    12: Result := toRetornoAbatimentoConcedido;
    13: Result := toRetornoAbatimentoCancelado;
    14: Result := toRetornoVencimentoAlterado;
    17: Result := toRetornoLiquidadoAposBaixaouNaoRegistro;
    19: Result := toRetornoRecebimentoInstrucaoProtestar;
    20: Result := toRetornoRecebimentoInstrucaoSustarProtesto;
    23: Result := toRetornoEncaminhadoACartorio;
    28: Result := toRetornoDebitoTarifas;
    29: Result := toRetornoOcorrenciasdoSacado;
    30: Result := toRetornoAlteracaoOutrosDadosRejeitada;
    35: Result := toRetornoDesagendamentoDebitoAutomatico;
    73: Result := toRetornoConfirmacaoRecebPedidoNegativacao;
  else
    Result := toRetornoOutrasOcorrencias;
  end;
end;

function TACBrBancoCresol.TipoOcorrenciaToCod ( const TipoOcorrencia: TACBrTipoOcorrencia ) : String;
begin
  Result := '';

  if (ACBrBanco.ACBrBoleto.LayoutRemessa = c240) then
  begin
    case TipoOcorrencia of
      toRetornoTransferenciaCarteiraEntrada                 : Result := '04';
      toRetornoTransferenciaCarteiraBaixa                   : Result := '05';
      toRetornoRecebimentoInstrucaoConcederDesconto         : Result := '07';
      toRetornoRecebimentoInstrucaoCancelarDesconto         : Result := '08';
      toRetornoBaixadoFrancoPagamento                       : Result := '15';
      toRetornoRetiradoDeCartorio                           : Result := '24';
      toRetornoBaixaPorProtesto                             : Result := '25';
      toRetornoComandoRecusado                              : Result := '26';
      toRetornoRecebimentoInstrucaoAlterarDados             : Result := '27';
      toRetornoAcertoDadosRateioCredito                     : Result := '33';
      toRetornoCancelamentoDadosRateio                      : Result := '34';
      toRetornoConfirmacaoEmailSMS                          : Result := '36';
      toRetornoEmailSMSRejeitado                            : Result := '37';
      toRetornoAlterarPrazoLimiteRecebimento                : Result := '38';
      toRetornoDispensarPrazoLimiteRecebimento              : Result := '39';
      toRetornoAlteracaoSeuNumero                           : Result := '40';
      toRetornoAcertoControleParticipante                   : Result := '41';
      toRetornoRecebimentoInstrucaoAlterarNomeSacado        : Result := '42';
      toRetornoAlterarSacadorAvalista                       : Result := '43';
      toRetornoChequeDevolvido                              : Result := '44';
      toRetornoChequeCompensado                             : Result := '45';
      toRetornoRecebimentoInstrucaoSustarProtesto           : Result := '46';
      toRetornoProtestoImediatoFalencia                     : Result := '47';
      toRemessaTransferenciaCarteira                        : Result := '48';
      toRetornoTipoCobrancaAlterado                         : Result := '49';
      toRetornoChequePendenteCompensacao                    : Result := '50';
      toRetornoTituloDDAReconhecidoPagador                  : Result := '51';
      toRetornoTituloDDANaoReconhecidoPagador               : Result := '52';
      toRetornoTituloDDARecusadoCIP                         : Result := '53';
      toRetornoBaixaTituloNegativadoSemProtesto             : Result := '54';
    end;
  end
  else
  begin
    case TipoOcorrencia of
      toRetornoBaixadoInstAgencia                           : Result := '10';
      toRetornoLiquidadoEmCartorio                          : Result := '15';
      toRetornoTituloPagoEmCheque                           : Result := '16';
      toRetornoAcertoDepositaria                            : Result := '18';
      toRetornoAcertoControleParticipante                   : Result := '21';
      toRetornoTituloPagamentoCancelado                     : Result := '22';
      toRetornoEntradaRejeitaCEPIrregular                   : Result := '24';
      toRetornoProtestoImediatoFalencia                     : Result := '25';
      toRetornoBaixaRejeitada                               : Result := '27';
      toRetornoComandoRecusado                              : Result := '32';
      toRetornoRecebimentoInstrucaoAlterarDados             : Result := '33';
      toRetornoRetiradoDeCartorio                           : Result := '34';
      toRetornoEstornoPagamento                             : Result := '40';
      toRetornoTituloSustadoJudicialmente                   : Result := '55';
      toRetornoAcertoDadosRateioCredito                     : Result := '68';
      toRetornoCancelamentoDadosRateio                      : Result := '69';
      toRetornoConfirmacaoPedidoExclNegativacao             : Result := '74';
    end;
  end;

  if (Result <> '') then
    Exit;

  case TipoOcorrencia of
    toRetornoRegistroConfirmado                             : Result := '02';
    toRetornoRegistroRecusado                               : Result := '03';
    toRetornoLiquidado                                      : Result := '06';
    toRetornoBaixadoViaArquivo                              : Result := '09';
    toRetornoTituloEmSer                                    : Result := '11';
    toRetornoAbatimentoConcedido                            : Result := '12';
    toRetornoAbatimentoCancelado                            : Result := '13';
    toRetornoVencimentoAlterado                             : Result := '14';
    toRetornoLiquidadoAposBaixaouNaoRegistro                : Result := '17';
    toRetornoRecebimentoInstrucaoProtestar                  : Result := '19';
    toRetornoRecebimentoInstrucaoSustarProtesto             : Result := '20';
    toRetornoEncaminhadoACartorio                           : Result := '23';
    toRetornoDebitoTarifas                                  : Result := '28';
    toRetornoOcorrenciasdoSacado                            : Result := '29';
    toRetornoAlteracaoOutrosDadosRejeitada                  : Result := '30';
    toRetornoDesagendamentoDebitoAutomatico                 : Result := '35';
    toRetornoConfirmacaoRecebPedidoNegativacao              : Result := '73';
  else
    Result := '02';
  end;
end;

function TACBrBancoCresol.CodMotivoRejeicaoToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia; const CodMotivo:String): String;
begin
  Result := '';
  case TipoOcorrencia of
    toRetornoRegistroConfirmado: //02
      case StrToIntDef(CodMotivo,-1)  of
        00: Result := '00-Ocorr�ncia aceita, entrada confirmada';
      else
        Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoRegistroRecusado, // 03
    toRetornoComandoRecusado,  // 26
    toRetornoALteracaoOutrosDadosRejeitada, // 30
    toRetornoAlteracaoDadosRejeitados, // 30
    toRetornoInstrucaoRejeitada : // 32
      case AnsiIndexStr(CodMotivo,
                       ['A1', 'A2', 'A3', 'A4', 'A5', 'A6', 'A7', 'A8', 'A9', 'B1']) of
          00: Result:= 'A1-Rejei��o da altera��o do n�mero controle do participante';
          01: Result:= 'A2-Rejei��o da altera��o dos dados do sacado';
          02: Result:= 'A3-Rejei��o da altera��o dos dados do sacador/avalista';
          03: Result:= 'A4-Sacado DDA';
          04: Result:= 'A5-Registro Rejeitado - T�tulo j� Liquidado';
          05: Result:= 'A6-C�digo do Convenente Inv�lido ou Encerrado';
          06: Result:= 'A7-T�tulo se j� encontra na situa��o Pretendida';
          07: Result:= 'A8-Valor do Abatimento inv�lido para cancelamento';
          08: Result:= 'A9-N�o autoriza pagamento parcial';
          09: Result:= 'B1-Autoriza recebimento parcial';
      else
        case StrToIntDef(CodMotivo,-1) of
          01: Result:= '01-C�digo do Banco Inv�lido';
          02: Result:= '02-C�digo do Registro Detalhe Inv�lido';
          03: Result:= '03-C�digo do Segmento Inv�lido';
          04: Result:= '04-C�digo de Movimento N�o Permitido para Carteira';
          05: Result:= '05-C�digo de Movimento Inv�lido';
          06: Result:= '06-Tipo/N�mero de Inscri��o do Cedente Inv�lidos';
          07: Result:= '07-Ag�ncia/Conta/DV Inv�lido';
          08: Result:= '08-Nosso N�mero Inv�lido';
          09: Result:= '09-Nosso N�mero Duplicado';
          10: Result:= '10-Carteira Inv�lida';
          11: Result:= '11-Forma de Cadastramento do T�tulo Inv�lido';
          12: Result:= '12-Tipo de Documento Inv�lido';
          13: Result:= '13-Identifica��o de Emiss�o do Bloqueto Inv�lida';
          14: Result:= '14-Identifica��o da Distribui��o do Bloqueto Inv�lida';
          15: Result:= '15-Caracter�sticas da Cobran�a Incompat�veis';
          16: Result:= '16-Data de Vencimento Inv�lida';
          17: Result:= '17-Data de Vencimento Anterior a Data de Emiss�o';
          18: Result:= '18-Vencimento Fora do Prazo de Opera��o';
          19: Result:= '19-T�tulo a Cargo de Bancos Correspondentes com Vencimento Inferior a XX Dias';
          20: Result:= '20-Valor do T�tulo Inv�lido';
          21: Result:= '21-Esp�cie do T�tulo Inv�lida';
          22: Result:= '22-Esp�cie do T�tulo N�o Permitida para a Carteira';
          23: Result:= '23-Aceite Inv�lido';
          24: Result:= '24-Data de Emiss�o Inv�lida';
          25: Result:= '25-Data da Emiss�o Posterior a Data de Entrada';
          26: Result:= '26-C�digo de Juros de Mora Inv�lido';
          27: Result:= '27-Valor/Taxa de Juros de Mora Inv�lido';
          28: Result:= '28-C�digo do Desconto Inv�lido';
          29: Result:= '29-Valor do Desconto Maior ou Igual ao Valor do T�tulo';
          30: Result:= '30-Desconto a Conceder N�o Confere';
          31: Result:= '31-Concess�o de Desconto - J� Existe Desconto Anterior';
          32: Result:= '32-Valor do IOF Inv�lido';
          33: Result:= '33-Valor do Abatimento Inv�lido';
          34: Result:= '34-Valor do Abatimento Maior ou Igual ao Valor do T�tulo';
          35: Result:= '35-Valor a Conceder N�o Confere';
          36: Result:= '36-Concess�o de Abatimento - J� Existe Abatimento Anterior';
          37: Result:= '37-C�digo para Protesto Inv�lido';
          38: Result:= '38-Prazo para Protesto Inv�lido';
          39: Result:= '39-Pedido de Protesto N�o Permitido para o T�tulo';
          40: Result:= '40-T�tulo com Ordem de Protesto Emitida';
          41: Result:= '41-Pedido de Cancelamento/Susta��o para T�tulos sem Instru��o de Protesto';
          42: Result:= '42-C�digo para Baixa/Devolu��o Inv�lido';
          43: Result:= '43-Prazo para Baixa/Devolu��o Inv�lida';
          44: Result:= '44-C�digo da Moeda Inv�lido';
          45: Result:= '45-Nome do Sacado N�o Informado';
          46: Result:= '46-Tipo/N�mero de Inscri��o do Sacado Inv�lido';
          47: Result:= '47-Endere�o do Sacado N�o Informado';
          48: Result:= '48-CEP Inv�lido';
          49: Result:= '49-CEP Sem Pra�a de Cobran�a (N�o Localizado)';
          50: Result:= '50-CEP Referente a um Banco Correspondente';
          51: Result:= '51-CEP imcompat�vel com a Unidade da Federa��o';
          52: Result:= '52-Registro de T�tulo j� liquidado Cart. 17';
          53: Result:= '53-Tipo/N�mero de Inscri��o do Sacador/Avalista Inv�lidos';
          54: Result:= '54-Sacador/Avalista N�o Informado';
          55: Result:= '55-Nosso N�mero no Banco Correspondente N�o Informado';
          56: Result:= '56-C�digo do Banco Correspondente N�o Informado';
          57: Result:= '57-C�digo da Multa Inv�lido';
          58: Result:= '58-Data da Multa Inv�lida';
          59: Result:= '59-Valor/Percentual da Multa Inv�lido';
          60: Result:= '60-Movimento para T�tulo N�o Cadastrado';
          61: Result:= '61-Altera��o da Ag�ncia Cobradora/DV Inv�lida';
          62: Result:= '62-Tipo de Impress�o Inv�lido';
          63: Result:= '63-Entrada para T�tulo j� Cadastrado';
          64: Result:= '64-N�mero da Linha Inv�lido';
          65: Result:= '65-C�digo do Banco para D�bito Inv�lido';
          66: Result:= '66-Ag�ncia/Conta/DV para D�bito Inv�lido';
          67: Result:= '67-Dados para D�bito incompat�vel com a Identifica��o da Emiss�o do Bloqueto';
          68: Result:= '68-D�bito Autom�tico Agendado';
          69: Result:= '69-D�bito N�o Agendado - Erro nos Dados da Remessa';
          70: Result:= '70-D�bito N�o Agendado - Sacado N�o Consta do Cadastro de Autorizante';
          71: Result:= '71-D�bito N�o Agendado - Cedente N�o Autorizado pelo Sacado';
          72: Result:= '72-D�bito N�o Agendado - Cedente N�o Participa da Modalidade D�bito Autom�tico';
          73: Result:= '73-D�bito N�o Agendado - C�digo de Moeda Diferente de Reao (R$)';
          74: Result:= '74-D�bito N�o Agendado - Data Vencimento Inv�lida';
          75: Result:= '75-D�bito N�o Agendado, Conforme seu Pedido, T�tulo N�o Registrado';
          76: Result:= '76-D�bito N�o Agendado, Tipo/Num. Inscri��o do Debitado, Inv�lido';
          77: Result:= '77-Transfer�ncia para Desconto N�o Permitida para a Cateira do T�tulo';
          78: Result:= '78-Data Inferior ou Igual ao Vencimento para D�bito Autom�tico';
          79: Result:= '79-Data Juros de Mora Inv�lido';
          80: Result:= '80-Data do Desconto Inv�lida';
          81: Result:= '81-Tentativas de D�bito Esgotadas - Baixado';
          82: Result:= '82-Tentativas de D�bito Esgotadas - Pendente';
          83: Result:= '83-Limite Excedido';
          84: Result:= '84-N�mero Autoriza��o Inexistente';
          85: Result:= '85-T�tulo com Pagamento Vinculado';
          86: Result:= '86-Seu N�mero Inv�lido';
          87: Result:= '87-e-mail/SMS enviado';
          88: Result:= '88-e-mail Lido';
          89: Result:= '89-e-mail/SMS devolvido - endere�o de e-mail ou n�mero do celular incorreto';
          90: Result:= '90-e-mail devolvido - caixa postal cheia';
          91: Result:= '91-e-mail/n�mero do celular do sacado n�o informado';
          92: Result:= '92-Sacado optante por Bloqueto Eletr�nico - e-mail n�o enviado';
          93: Result:= '93-C�digo para emiss�o de bloqueto n�o permite envio de e-mail';
          94: Result:= '94-C�digo da Carteira inv�lido para envio e-mail';
          95: Result:= '95-Contrato n�o permite o envio de e-mail';
          96: Result:= '96-N�mero de contrato inv�lido';
          97: Result:= '97-Rejei��o da altera��o do prazo limite de recebimento';
          98: Result:= '98-Rejei��o de dispensa de prazo limite de recebimento';
          99: Result:= '99-Rejei��o da altera��o do n�mero do t�tulo dado pelo cedente';
        else
          Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
        end;
      end;

    toRetornoLiquidado,  // 06
    toRetornoBaixadoViaArquivo,  // 09
    toRetornoLiquidadoAposBaixaouNaoRegistro : // 17
        case StrToIntDef(CodMotivo,-1) of
          00: Result:= '00-Ocorr�ncia aceita, liquida��o normal';
          01: Result:= '01-Por Saldo';
          02: Result:= '02-Por Conta';
          03: Result:= '03-Liquida��o no Guich� de Caixa em Dinheiro';
          04: Result:= '04-Compensa��o Eletr�nica';
          05: Result:= '05-Compensa��o Convencional';
          06: Result:= '06-Por Meio Eletr�nico';
          07: Result:= '07-Ap�s Feriado Local';
          08: Result:= '08-Em Cart�rio';
          09: Result:= '09-Comandada Banco';
          10: Result:= '10-Comandada Cliente Arquivo';
          11: Result:= '11-Comandada Cliente On-line';
          12: Result:= '12-Decurso Prazo - Cliente';
          13: Result:= '13-Decurso Prazo - Banco';
          14: Result:= '14-Protestado';
          15: Result:= '15-T�tulo Exclu�do';
          30: Result:= '30-Liquida��o no Guich� de Caixa em Cheque';
          31: Result:= '31-Liquida��o em banco correspondente';
          32: Result:= '32-Liquida��o Terminal de Auto-Atendimento';
          33: Result:= '33-Liquida��o na Internet (Home banking)';
          34: Result:= '34-Liqudado Office Banking';
          35: Result:= '35-Liquidado Correspondente em Dinheiro';
          36: Result:= '36-Liquidado Correspondente em Cheque';
          37: Result:= '37-Liquidado por meio de Central de Atendimento (Telefone)';
        else
           Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
        end;

    toRetornoBaixadoInstAgencia: //10
      case StrToIntDef(CodMotivo,-1) of
        00: Result:= '00-Baixado conforme instrucoes na agencia';
        14: Result:= '14-Titulo protestado';
        15: Result:= '15-Titulo excluido';
        16: Result:= '16-Titulo baixado pelo banco por decurso de prazo';
        20: Result:= '20-Titulo baixado e transferido para desconto';
      else
        Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoAbatimentoConcedido: //12
      case StrToIntDef(CodMotivo,-1) of
        00: Result:= '00-Ocorr�ncia aceita, abatimento concedido';
      else
        Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoAbatimentoCancelado: //13
      case StrToIntDef(CodMotivo,-1) of
        00: Result:= '00-Ocorr�ncia aceita, abatimento cancelado';
      else
        Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoVencimentoAlterado: //14
      case StrToIntDef(CodMotivo,-1) of
        00: Result:= '00-Ocorr�ncia aceita, vencimento alterado';
      else
        Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoLiquidadoEmCartorio: //15
      case StrToIntDef(CodMotivo,-1) of
        00: Result:= '00-Ocorr�ncia aceita, liquida��o em cart�rio';
      else
        Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoRecebimentoInstrucaoProtestar: //19
      case AnsiIndexStr(CodMotivo,['A', 'D']) of
        0: Result:= 'A-Aceito';
        1: Result:= 'D-Desprezado';
      else
        Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoRecebimentoInstrucaoSustarProtesto: //20
        case StrToIntDef(CodMotivo,-1) of
          00: Result:= '00-Ocorr�ncia aceita, susta��o de protesto';
        else
           Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
        end;

    toRetornoEntradaEmCartorio: //23
      case AnsiIndexStr(CodMotivo,['G2', 'G3', 'G4', 'G6', 'G7']) of
        0: Result:= 'G2-T�tulo aceito: sem a assinatura do sacado';
        1: Result:= 'G3-T�tulo aceito: rasurado ou rasgado';
        2: Result:= 'G4-T�tulo aceito: falta t�tulo(ag�ncia cedente dever� envi�-lo)';
        3: Result:= 'G6-T�tulo aceito: sem endosso ou cedente irregular';
        4: Result:= 'G7-T�tulo aceito: valor por extenso diferente do valor num�rico';
      else
        Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoEntradaRejeitaCEPIrregular: //24
      case StrToIntDef(CodMotivo,-1) of
        48: Result:= '48-CEP irregular';
      else
        Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoBaixaRejeitada: //27
        case StrToIntDef(CodMotivo,-1) of
          00: Result:= '00-Ocorr�ncia aceita, baixa rejeitada';
          04: Result:= '04-Codigo de ocorrencia nao permitido para a carteira';
          07: Result:= '07-Agencia\Conta\Digito invalidos';
          08: Result:= '08-Nosso numero invalido';
          10: Result:= '10-Carteira invalida';
          15: Result:= '15-Carteira\Agencia\Conta\NossoNumero invalidos';
          40: Result:= '40-Titulo com ordem de protesto emitido';
          42: Result:= '42-Codigo para baixa/devolucao via Telebradesco invalido';
          60: Result:= '60-Movimento para titulo nao cadastrado';
          77: Result:= '70-Transferencia para desconto nao permitido para a carteira';
          85: Result:= '85-Titulo com pagamento vinculado';
        else
           Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
        end;

    toRetornoDebitoTarifas: //28
        case StrToIntDef(CodMotivo,-1) of
            01: Result:= '01-Tarifa de Extrato de Posi��o';
            02: Result:= '02-Tarifa de Manuten��o de T�tulo Vencido';
            03: Result:= '03-Tarifa de Susta��o';
            04: Result:= '04-Tarifa de Protesto';
            05: Result:= '05-Tarifa de Outras Instru��es';
            06: Result:= '06-Tarifa de Outras Ocorr�ncias';
            07: Result:= '07-Tarifa de Envio de Duplicata ao Sacado';
            08: Result:= '08-Custas de Protesto';
            09: Result:= '09-Custas de Susta��o de Protesto';
            10: Result:= '10-Custas de Cart�rio Distribuidor';
            11: Result:= '11-Custas de Edital';
            12: Result:= '12-Tarifa Sobre Devolu��o de T�tulo Vencido';
            13: Result:= '13-Tarifa Sobre Registro Cobrada na Baixa/Liquida��o';
            14: Result:= '14-Tarifa Sobre Reapresenta��o Autom�tica';
            15: Result:= '15-Tarifa Sobre Rateio de Cr�dito';
            16: Result:= '16-Tarifa Sobre Informa��es Via Fax';
            17: Result:= '17-Tarifa Sobre Prorroga��o de Vencimento';
            18: Result:= '18-Tarifa Sobre Altera��o de Abatimento/Desconto';
            19: Result:= '19-Tarifa Sobre Arquivo mensal (Em Ser)';
            20: Result:= '20-Tarifa Sobre Emiss�o de Bloqueto Pr�-Emitido pelo Banco';
        else
          Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
        end;

    toRetornoOcorrenciasdoSacado: //29
      case AnsiIndexStr(CodMotivo,['M2']) of
        0 : Result:= 'M2-N�o reconhecimento da d�vida pelo sacado';
      else
        case StrToIntDef(CodMotivo,-1) of
          78 : Result:= '78-Sacado alega que faturamento e indevido';
          116: Result:= '116-Sacado aceita/reconhece o faturamento';
        else
          Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
        end;
      end;

      toRetornoDesagendamentoDebitoAutomatico:
      case StrToIntDef(CodMotivo,-1) of
         81 : Result:= '81-Tentativas esgotadas, baixado';
         82 : Result:= '82-Tentativas esgotadas, pendente';
         83 : Result:= '83-Cancelado pelo Sacado e Mantido Pendente, conforme negocia��o';
         84 : Result:= '84-Cancelado pelo sacado e baixado, conforme negocia��o';
      else
         Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
      end;

    toRetornoEntradaNegativacaoRejeitada,
    toRetornoExclusaoNegativacaoRejeitada: //81 e 83
       if CodMotivo = 'S1' then
          Result:= 'S1 � Rejeitado pela empresa de negativa��o parceira.'
       else
          Result:= PadLeft(CodMotivo,2,'0') +' - Motivos n�o identificados';

    toRetornoExcusaoNegativacaoOutrosMotivos://84;
       case AnsiIndexStr(CodMotivo, ['N1', 'N2', 'N3','N4','N5']) of
         0 : Result:= 'N1-Decurso de Prazo';
         1 : Result:= 'N2-Determina��o Judicial';
         2 : Result:= 'N3-Solicita��o de Empresa Conveniada';
         3 : Result:= 'N4-Devolu��o de Comunicado pelos Correios';
         4 : Result:= 'N5-Diversos';
       else
         Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
       end;
    toRetornoOcorrenciaInfOutrosMotivos: //85'
      case AnsiIndexStr(CodMotivo, ['N4','N5']) of
         0 : Result:= 'N4-Devolu��o de Comunicado pelos Correios';
         1 : Result:= 'N5-Diversos';
       else
         Result:= PadLeft(CodMotivo,2,'0') +' - Outros Motivos';
       end;

  else
    Result:= PadLeft(CodMotivo,2,'0') +' - Motivos n�o identificados';
  end;

end;

function TACBrBancoCresol.CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02 : Result:= toRemessaBaixar;                          {Pedido de Baixa}
    03 : Result:= toRemessaProtestoFinsFalimentares;        {Pedido de Protesto Falimentar}
    04 : Result:= toRemessaConcederAbatimento;              {Concess�o de Abatimento}
    05 : Result:= toRemessaCancelarAbatimento;              {Cancelamento de Abatimento concedido}
    06 : Result:= toRemessaAlterarVencimento;               {Altera��o de vencimento}
    07 : Result:= toRemessaAlterarControleParticipante;     {Altera��o do controle do participante}
    08 : Result:= toRemessaAlterarNumeroControle;           {Altera��o de seu n�mero}
    09 : Result:= toRemessaProtestar;                       {Pedido de protesto}
    10 : Result:= toRemessaCancelarInstrucaoProtestoBaixa;  {Sustar protesto e baixar}
    11 : Result:= toRemessaCancelarInstrucaoProtesto;       {Sustar protesto e manter na carteira}
    22 : Result:= toRemessaTransfCessaoCreditoIDProd10;     {Transfer�ncia Cess�o cr�dito ID. Prod.10}
    23 : Result:= toRemessaTransferenciaCarteira;           {Transfer�ncia entre Carteiras}
    24 : Result:= toRemessaDevTransferenciaCarteira;        {Dev. Transfer�ncia entre Carteiras}
    31 : Result:= toRemessaOutrasOcorrencias;               {Altera��o de Outros Dados}
    68 : Result:= toRemessaAcertarRateioCredito;            {Acerto nos dados do rateio de Cr�dito}
    69 : Result:= toRemessaCancelarRateioCredito;           {Cancelamento do rateio de cr�dito.}
  else
     Result:= toRemessaRegistrar;                           {Remessa}
  end;
end;

end.


