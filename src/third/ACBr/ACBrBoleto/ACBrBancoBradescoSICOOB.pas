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

unit ACBrBancoBradescoSICOOB;

interface

uses
  Classes, SysUtils,
  ACBrBoleto, ACBrBoletoConversao;

type

  { TACBrBancoBradescoSICOOB }

  TACBrBancoBradescoSICOOB = class(TACBrBancoClass)
  private
    function FormataNossoNumero(const ACBrTitulo :TACBrTitulo): String;
  protected
    function CalcularFatorVencimento(const DataVencimento: TDateTime): String; override;
  public
    Constructor create(AOwner: TACBrBanco);
    function CalcularTamMaximoNossoNumero(const Carteira : String; const NossoNumero : String = ''; const Convenio: String = ''): Integer; override;
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
    function CodMotivoRejeicaoToDescricao(const TipoOcorrencia:TACBrTipoOcorrencia; CodMotivo:Integer): String; override;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
  end;

implementation

uses
  {$IFDEF COMPILER6_UP} dateutils {$ELSE} ACBrD5 {$ENDIF},
  StrUtils,
  ACBrUtil;

{ TACBrBancoBradescoSICOOB }

constructor TACBrBancoBradescoSICOOB.create(AOwner: TACBrBanco);
begin
   inherited create(AOwner);
   fpDigito                := 2;
   fpNome                  := 'Bradesco';
   fpNumero                := 237;
   fpTamanhoMaximoNossoNum := 6;
   fpTamanhoAgencia        := 4;
   fpTamanhoConta          := 7;
   fpTamanhoCarteira       := 2;
   fpNumeroCorrespondente  := 756;
end;

function TACBrBancoBradescoSICOOB.CalcularFatorVencimento(
  const DataVencimento: TDateTime): String;
begin
  Result := IntToStr( Trunc(DataVencimento - EncodeDate(2000,07,03)) + 1000);
end;

function TACBrBancoBradescoSICOOB.CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String;
begin
   Modulo.CalculoPadrao;
   Modulo.MultiplicadorInicial := 2;
   Modulo.MultiplicadorFinal   := 7;
   Modulo.Documento := '9' + FormataNossoNumero( ACBrTitulo );
   Modulo.Calcular;

   if Modulo.ModuloFinal = 1 then
      Result:= 'P'
   else
      Result:= IntToStr(Modulo.DigitoFinal);
end;

function TACBrBancoBradescoSICOOB.MontarCodigoBarras ( const ACBrTitulo: TACBrTitulo) : String;
var
  NossoNumero, CodigoBarras, FatorVencimento, DigitoCodBarras:String;
begin
   with ACBrTitulo.ACBrBoleto do
   begin
      FatorVencimento := CalcularFatorVencimento(ACBrTitulo.Vencimento);
      NossoNumero := MontarCampoNossoNumero(ACBrTitulo);
      
      CodigoBarras := IntToStr( Numero )+'9'+ PadLeft(OnlyNumber(FatorVencimento),4,'0') +
                      IntToStrZero(Round(ACBrTitulo.ValorDocumento*100),10) +
                      PadLeft(OnlyNumber(Cedente.Agencia),4,'0') +
                      PadLeft(OnlyNumber(ACBrTitulo.Carteira),2,'0') +
                      PadLeft(NossoNumero,11,'0') +
                      PadLeft(RightStr(Cedente.Conta,7),7,'0') +
                      '0';

      DigitoCodBarras := CalcularDigitoCodigoBarras(CodigoBarras);
   end;

   Result:= IntToStr(Numero) + '9'+ DigitoCodBarras + Copy(CodigoBarras,5,Length(CodigoBarras));
end;

function TACBrBancoBradescoSICOOB.MontarCampoNossoNumero (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result:=  FormatDateTime('yy',ACBrTitulo.DataDocumento)+
             PadLeft( ACBrTitulo.ACBrBoleto.Cedente.Convenio, 3, '0')+
             ACBrTitulo.NossoNumero+
             CalcularDigitoVerificador(ACBrTitulo);
end;

function TACBrBancoBradescoSICOOB.MontarCampoCodigoCedente (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result := ACBrTitulo.ACBrBoleto.Cedente.Agencia+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito+'/'+
             ACBrTitulo.ACBrBoleto.Cedente.Conta+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.ContaDigito;
end;

procedure TACBrBancoBradescoSICOOB.GerarRegistroHeader400(NumeroRemessa : Integer; ARemessa:TStringList);
var
  wLinha: String;
begin
   with ACBrBanco.ACBrBoleto.Cedente do
   begin
      wLinha:= '0'                                             + // ID do Registro
               '1'                                             + // ID do Arquivo( 1 - Remessa)
               'REMESSA'                                       + // Literal de Remessa
               '01'                                            + // C�digo do Tipo de Servi�o
               PadRight( 'COBRANCA', 15 )                          + // Descri��o do tipo de servi�o
               PadLeft( Agencia + AgenciaDigito, 13, '0')         + // C�digo da Cooperativa
               PadLeft( CodigoCedente, 7, '0')                    + // C�digo de Cobran�a
               PadRight( Nome, 30)                                 + // Nome da Empresa
               IntToStrZero( ACBrBanco.NumeroCorrespondente, 3  ) + PadRight('BANCOOB', 15)   + // C�digo e Nome do Banco(756 - Sicoob)
               FormatDateTime('ddmmyy',Now)  + Space(08)       + // Data de gera��o do arquivo + brancos
               'SX'                                            + // Identifica��o do Sistema
               IntToStrZero(NumeroRemessa,7) + Space(277)      + // Nr. Sequencial de Remessa + brancos
               IntToStrZero(1,6);                                // Nr. Sequencial de Remessa + brancos + Contador

      ARemessa.Text:= ARemessa.Text + UpperCase(wLinha);
   end;
end;

procedure TACBrBancoBradescoSICOOB.GerarRegistroTransacao400(ACBrTitulo :TACBrTitulo; aRemessa: TStringList);
var
  aNossoNumero, aDigitoNossoNumero, aOcorrencia, aEspecie, aCarteira, aProtesto,
  aTipoSacado, aMensagemCedente,
  wLinha : String;
  TipoBoleto : Char;
  aTipoSacador: String;

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

        if Mensagem.Count > 2 then
           Result := Result +
                     Copy(PadRight(Mensagem[2], 80, ' '), 1, 80)              // CONTE�DO DA 2� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO
        else
           Result := Result + PadRight('', 80, ' ');                          // CONTE�DO DO RESTANTE DAS LINHAS

        if Mensagem.Count > 3 then
           Result := Result +
                     Copy(PadRight(Mensagem[3], 80, ' '), 1, 80)              // CONTE�DO DA 3� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO
        else
           Result := Result + PadRight('', 80, ' ');                          // CONTE�DO DO RESTANTE DAS LINHAS

        if Mensagem.Count > 4 then
           Result := Result +
                     Copy(PadRight(Mensagem[4], 80, ' '), 1, 80)              // CONTE�DO DA 4� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO
        else
           Result := Result + PadRight('', 80, ' ');                          // CONTE�DO DO RESTANTE DAS LINHAS


        Result := Result                                              +  // Identifica��o do Registro + Mensagem
                  space(45)                                           +  // Brancos
                  aCarteira                                           +  // Carteira
                  StringOfChar( '0', 25)                              +  // ZEROS
                  IntToStrZero( aRemessa.Count + 2, 6)                ;  // N� SEQ�ENCIAL DO REGISTRO NO ARQUIVO
     end;
  end;

begin

   with ACBrTitulo do
   begin
      aNossoNumero := MontarCampoNossoNumero(ACBrTitulo);
      aDigitoNossoNumero := CalcularDigitoVerificador(ACBrTitulo);
      aCarteira:= IntToStrZero(StrToIntDef(trim(Carteira),0), 3);

      {Pegando C�digo da Ocorrencia}
      case OcorrenciaOriginal.Tipo of
         toRemessaBaixar                         : aOcorrencia := '02'; {Pedido de Baixa}
         toRemessaConcederAbatimento             : aOcorrencia := '04'; {Concess�o de Abatimento}
         toRemessaCancelarAbatimento             : aOcorrencia := '05'; {Cancelamento de Abatimento concedido}
         toRemessaAlterarVencimento              : aOcorrencia := '06'; {Altera��o de vencimento}
         toRemessaAlterarNumeroControle          : aOcorrencia := '08'; {Altera��o de seu n�mero}
         toRemessaProtestar                      : aOcorrencia := '09'; {Pedido de protesto}
         toRemessaCancelarInstrucaoProtestoBaixa : aOcorrencia := '18'; {Sustar protesto e baixar}
         toRemessaCancelarInstrucaoProtesto      : aOcorrencia := '19'; {Sustar protesto e manter na carteira}
         toRemessaOutrasOcorrencias              : aOcorrencia := '31'; {Altera��o de Outros Dados}
      else
         aOcorrencia := '01';                                           {Remessa}
      end;

      {Pegando Tipo de Boleto}
      case ACBrBoleto.Cedente.ResponEmissao of
         tbCliEmite : TipoBoleto := '2';
      else
         TipoBoleto := '1';
         if aNossoNumero = EmptyStr then
           aDigitoNossoNumero := '0';
      end;

      {Pegando Especie}
      if trim(EspecieDoc) = 'DM' then
         aEspecie:= '01'
      else if trim(EspecieDoc) = 'NP' then
         aEspecie:= '02'
      else if trim(EspecieDoc) = 'NS' then
         aEspecie:= '03'
      else if trim(EspecieDoc) = 'CS' then
         aEspecie:= '04'
      else if trim(EspecieDoc) = 'ND' then
         aEspecie:= '11'
      else if trim(EspecieDoc) = 'DS' then
         aEspecie:= '12'
      else if trim(EspecieDoc) = 'OU' then
         aEspecie:= '99'
      else
         aEspecie := EspecieDoc;

      {Pegando campo Intru��es}
      if (DataProtesto > 0) and (DataProtesto > Vencimento) then
         aProtesto := '06' + IntToStrZero(DaysBetween(DataProtesto,Vencimento),2)
      else if aOcorrencia = '31' then
         aProtesto := '9999'
      else
         aProtesto := PadLeft(trim(Instrucao1),2,'0') + PadLeft(trim(Instrucao2),2,'0');

      {Pegando Tipo de Sacado}
      case Sacado.Pessoa of
         pFisica   : aTipoSacado := '01';
         pJuridica : aTipoSacado := '02';
      else
         aTipoSacado := '00';
      end;

      {Pegando Tipo de Sacador Avalista}
      case Sacado.SacadoAvalista.Pessoa of
         pFisica   : aTipoSacador := '01';
         pJuridica : aTipoSacador := '02';
      else
         aTipoSacador := '00';
      end;

      with ACBrBoleto do
      begin
         if Mensagem.Text <> '' then
            aMensagemCedente:= Mensagem[0];

         wLinha:= '1'                                                        + // ID Registro
                  StringOfChar( '0', 19)                                     + // Dados p/ D�bito Autom�tico
                  PadLeft( Cedente.Agencia + Cedente.AgenciaDigito, 10, '0') + // C�digo da Cooperativa
                  PadLeft( Cedente.CodigoCedente, 7, '0')                    + // C�digo de Cobran�a
                  PadRight( SeuNumero, 25, ' ')                              + // N�mero de Controle de Participantes
                  StringOfChar( '0', 8)                                      + // ZEROS
                  PadRight(aNossoNumero , 11, '0')                           + // Nosso N�mero
                  aDigitoNossoNumero                                         + // Digito Verificador do Nosso N�mero
                  IntToStrZero( round( ValorDescontoAntDia * 100), 10)       + // Desconto bonifica��o por dia
                  TipoBoleto + 'N' + Space(14)                               + // Tipo Boleto(Quem emite) + 'N'= Nao registrar p/ D�bito autom�tico
                  aOcorrencia                                                + // Identifica��o da Instru��o
                  PadRight( NumeroDocumento,  10)                            + // N�mero do Documento
                  FormatDateTime( 'ddmmyy', Vencimento)                      + // Data do Vencimento do T�tulo
                  IntToStrZero( Round( ValorDocumento * 100 ), 13)           + // Valor do T�tulo
                  StringOfChar('0',8) + PadRight(aEspecie,2) + 'N'           + // Zeros + Especie do documento + Idntifica��o(valor fixo N)
                  FormatDateTime( 'ddmmyy', DataDocumento )                  + // Data de Emiss�o
                  aProtesto                                                  + // 1� Instru��o + 2� Instru��o
                  IntToStrZero( round(ValorMoraJuros * 100 ), 13)            + // Valor a ser cobrado por dia de Atraso
                  IfThen(DataDesconto < EncodeDate(2000,01,01),'000000',
                         FormatDateTime( 'ddmmyy', DataDesconto))            + // Data Limite para Concess�o de Desconto
                  IntToStrZero( round( ValorDesconto * 100 ), 13)            + // Valor do Desconto
                  StringOfChar('0',13)                                       + // Zeros
                  IntToStrZero( round( ValorAbatimento * 100 ), 13)          + // Valor do Abatimento a ser concedido ou cancelado
                  aTipoSacado + PadLeft(OnlyNumber(Sacado.CNPJCPF),14,'0')   + // Tipo de inscri��o do sacado + N�mero de inscri��o do sacado
                  PadRight( Sacado.NomeSacado, 40, ' ')                      + // Nome do Sacado
                  PadRight( Sacado.Logradouro + ' ' + Sacado.Numero + ' ' +
                            Sacado.Bairro + ' ' + Sacado.Cidade + ' '     +
                            Sacado.UF, 40)                                   + // Endere�o Completo
                  PadRight(aMensagemCedente, 12)                             + // 1� Mensagem
                  PadRight( Sacado.CEP, 8 )                                  + // CEP
                  space(1)                                                   + // Branco
                  PadLeft(OnlyNumber(Sacado.SacadoAvalista.CNPJCPF),14,'0')  + // Inscri��o do Sacador / Avalista
                  aTipoSacador                                               + // Tipo do Documento do Sacador / Avalista
                  PadRight( Sacado.SacadoAvalista.NomeAvalista , 43, ' ');     // Sacador / Avalista


         wLinha := wLinha + IntToStrZero(aRemessa.Count + 1, 6); // N� SEQ�ENCIAL DO REGISTRO NO ARQUIVO
         wLinha := wLinha + DoMontaInstrucoes1;

         aRemessa.Text:= aRemessa.Text + UpperCase(wLinha);
      end;
   end;
end;

procedure TACBrBancoBradescoSICOOB.GerarRegistroTrailler400( ARemessa:TStringList );
var
  wLinha: String;
begin
   wLinha := '9' + Space(393)                     + // ID Registro
             IntToStrZero( ARemessa.Count + 1, 6);  // Contador de Registros

   ARemessa.Text:= ARemessa.Text + UpperCase(wLinha);
end;

Procedure TACBrBancoBradescoSICOOB.LerRetorno400 ( ARetorno: TStringList );
var
  Titulo : TACBrTitulo;
  ContLinha, CodOcorrencia  :Integer;
  CodMotivo, i, MotivoLinha :Integer;
  CodMotivo_19, rAgencia, rDigitoAgencia :String;
  rConta, rDigitoConta      :String;
  Linha, rCedente, rCNPJCPF :String;
begin
   if ( StrToIntDef(copy(ARetorno.Strings[0],77,3),-1) <> ACBrBanco.NumeroCorrespondente ) then
      raise Exception.Create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                             'n�o � um arquivo de retorno do '+ Nome));

   rCedente := trim(Copy(ARetorno[0],47,30));

   rAgencia := trim(Copy(ARetorno[0], 101, ACBrBanco.TamanhoAgencia));
   rConta   := trim(Copy(ARetorno[0], 106, ACBrBanco.TamanhoConta));

   rDigitoAgencia := Copy(ARetorno[0],105,1);
   rDigitoConta   := Copy(ARetorno[0],113,1);

   ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0],109,5),0);

   ACBrBanco.ACBrBoleto.DataArquivo := StringToDateTimeDef(Copy(ARetorno[0],95,2)+'/'+            //|
                                                           Copy(ARetorno[0],97,2)+'/'+            //|Implementado por Carlos Fitl - 27/12/2010
                                                           Copy(ARetorno[0],99,2),0, 'DD/MM/YY' );//|

   rCNPJCPF := Copy(ARetorno[1],4,14);

   ValidarDadosRetorno(rAgencia, rConta, rCNPJCPF);
   with ACBrBanco.ACBrBoleto do
   begin

      Cedente.Nome         := rCedente;
      Cedente.CNPJCPF      := rCNPJCPF;
      Cedente.Agencia      := rAgencia;
      Cedente.AgenciaDigito:= rDigitoAgencia;
      Cedente.Conta        := rConta;
      Cedente.ContaDigito  := rDigitoConta;

      case StrToIntDef(Copy(ARetorno[1],2,2),0) of
         01: Cedente.TipoInscricao:= pFisica;
         02: Cedente.TipoInscricao:= pJuridica;
      else
         Cedente.TipoInscricao := pJuridica;
      end;

      ACBrBanco.ACBrBoleto.ListadeBoletos.Clear;
   end;

   for ContLinha := 1 to ARetorno.Count - 2 do
   begin
      Linha := ARetorno[ContLinha] ;

      if Copy(Linha,1,1)<> '1' then
         Continue;

      Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;

      with Titulo do
      begin
         SeuNumero                   := copy(Linha,38,25);
         NumeroDocumento             := copy(Linha,71,12);
         OcorrenciaOriginal.Tipo     := CodOcorrenciaToTipo(StrToIntDef(
                                        copy(Linha,109,2),0));

         CodOcorrencia := StrToIntDef(IfThen(copy(Linha,109,2) = '00','00',copy(Linha,109,2)),0);

         //-|Se a ocorrencia for igual a 19 � Confirma��o de Instru��o de Protesto
         //-|Verifica o motivo na posi��o 295 - A = Aceite , D = Desprezado
         if(CodOcorrencia = 19)then
          begin
            CodMotivo_19:= copy(Linha,295,1);
            if(CodMotivo_19 = 'A')then
             begin
               MotivoRejeicaoComando.Add(copy(Linha,295,1));
               DescricaoMotivoRejeicaoComando.Add('A - Aceito');
             end
            else
             begin
               MotivoRejeicaoComando.Add(copy(Linha,295,1));
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
         NumeroDocumento := Copy(Linha,117,10);

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
         Carteira             := Copy(Linha,108,1);
         NossoNumero          := Copy(Linha,76,6);
         ValorDespesaCobranca := StrToFloatDef(Copy(Linha,176,13),0)/100;
         ValorOutrasDespesas  := StrToFloatDef(Copy(Linha,189,13),0)/100;

         if StrToIntDef(Copy(Linha,296,6),0) <> 0 then
            DataCredito:= StringToDateTimeDef( Copy(Linha,296,2)+'/'+
                                               Copy(Linha,298,2)+'/'+
                                               Copy(Linha,300,2),0, 'DD/MM/YY' );
      end;
   end;
end;

function TACBrBancoBradescoSICOOB.TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String;
var
  CodOcorrencia: Integer;
begin
   CodOcorrencia := StrToIntDef(TipoOCorrenciaToCod(TipoOcorrencia),0);

   case CodOcorrencia of
     02: Result:='02-Entrada Confirmada' ;
     03: Result:='03-Entrada Rejeitada' ;
     06: Result:='06-Liquida��o normal' ;
     09: Result:='09-Baixado Automaticamente via Arquivo' ;
     10: Result:='10-Baixado conforme instru��es da Ag�ncia' ;
     11: Result:='11-Em Ser - Arquivo de T�tulos pendentes' ;
     12: Result:='12-Abatimento Concedido' ;
     13: Result:='13-Abatimento Cancelado' ;
     14: Result:='14-Vencimento Alterado' ;
     15: Result:='15-Liquida��o em Cart�rio' ;
     16: Result:='16-Titulo Pago em Cheque - Vinculado';
     17: Result:='17-Liquida��o ap�s baixa ou T�tulo n�o registrado' ;
     18: Result:='18-Acerto de Deposit�ria' ;
     19: Result:='19-Confirma��o Recebimento Instru��o de Protesto' ;
     20: Result:='20-Confirma��o Recebimento Instru��o Susta��o de Protesto' ;
     21: Result:='21-Acerto do Controle do Participante' ;
     22: Result:='22-Titulo com Pagamento Cancelado';
     23: Result:='23-Entrada do T�tulo em Cart�rio' ;
     24: Result:='24-Entrada rejeitada por CEP Irregular' ;
     27: Result:='27-Baixa Rejeitada' ;
     28: Result:='28-D�bito de tarifas/custas' ;
     30: Result:='30-Altera��o de Outros Dados Rejeitados' ;
     32: Result:='32-Instru��o Rejeitada' ;
     33: Result:='33-Confirma��o Pedido Altera��o Outros Dados' ;
     34: Result:='34-Retirado de Cart�rio e Manuten��o Carteira' ;
     35: Result:='35-Desagendamento do d�bito autom�tico' ;
     68: Result:='68-Acerto dos dados do rateio de Cr�dito' ;
     69: Result:='69-Cancelamento dos dados do rateio' ;
   end;
end;

function TACBrBancoBradescoSICOOB.CodOcorrenciaToTipo(const CodOcorrencia:
   Integer ) : TACBrTipoOcorrencia;
begin
   case CodOcorrencia of
      02: Result := toRetornoRegistroConfirmado;
      03: Result := toRetornoRegistroRecusado;
      06: Result := toRetornoLiquidado;
      09: Result := toRetornoBaixadoViaArquivo;
      10: Result := toRetornoBaixadoInstAgencia;
      11: Result := toRetornoTituloEmSer;
      12: Result := toRetornoAbatimentoConcedido;
      13: Result := toRetornoAbatimentoCancelado;
      14: Result := toRetornoVencimentoAlterado;
      15: Result := toRetornoLiquidadoEmCartorio;
      16: Result := toRetornoTituloPagoEmCheque;
      17: Result := toRetornoLiquidadoAposBaixaouNaoRegistro;
      18: Result := toRetornoAcertoDepositaria;
      19: Result := toRetornoRecebimentoInstrucaoProtestar;
      20: Result := toRetornoRecebimentoInstrucaoSustarProtesto;
      21: Result := toRetornoAcertoControleParticipante;
      22: Result := toRetornoTituloPagamentoCancelado;
      23: Result := toRetornoEncaminhadoACartorio;
      24: Result := toRetornoEntradaRejeitaCEPIrregular;
      27: Result := toRetornoBaixaRejeitada;
      28: Result := toRetornoDebitoTarifas;
      30: Result := toRetornoAlteracaoOutrosDadosRejeitada;
      32: Result := toRetornoComandoRecusado;
      33: Result := toRetornoRecebimentoInstrucaoAlterarDados;
      34: Result := toRetornoRetiradoDeCartorio;
      35: Result := toRetornoDesagendamentoDebitoAutomatico;
      99: Result := toRetornoRegistroRecusado;
   else
      Result := toRetornoOutrasOcorrencias;
   end;
end;

function TACBrBancoBradescoSICOOB.CodOcorrenciaToTipoRemessa(const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02 : Result:= toRemessaBaixar;                          {Pedido de Baixa}
    04 : Result:= toRemessaConcederAbatimento;              {Concess�o de Abatimento}
    05 : Result:= toRemessaCancelarAbatimento;              {Cancelamento de Abatimento concedido}
    06 : Result:= toRemessaAlterarVencimento;               {Altera��o de vencimento}
    08 : Result:= toRemessaAlterarNumeroControle;           {Altera��o de seu n�mero}
    09 : Result:= toRemessaProtestar;                       {Pedido de protesto}
    18 : Result:= toRemessaCancelarInstrucaoProtestoBaixa;  {Sustar protesto e baixar}
    19 : Result:= toRemessaCancelarInstrucaoProtesto;       {Sustar protesto e manter na carteira}
    31 : Result:= toRemessaOutrasOcorrencias;               {Altera��o de Outros Dados}
  else
     Result:= toRemessaRegistrar;                           {Remessa}
  end;
end;

function TACBrBancoBradescoSICOOB.TipoOcorrenciaToCod ( const TipoOcorrencia: TACBrTipoOcorrencia ) : String;
begin
  case TipoOcorrencia of
    toRetornoRegistroConfirmado                : Result := '02';
    toRetornoRegistroRecusado                  : Result := '03';
    toRetornoLiquidado                         : Result := '06';
    toRetornoBaixadoViaArquivo                 : Result := '09';
    toRetornoBaixadoInstAgencia                : Result := '10';
    toRetornoTituloEmSer                       : Result := '11';
    toRetornoAbatimentoConcedido               : Result := '12';
    toRetornoAbatimentoCancelado               : Result := '13';
    toRetornoVencimentoAlterado                : Result := '14';
    toRetornoLiquidadoEmCartorio               : Result := '15';
    toRetornoTituloPagoEmCheque                : Result := '16';
    toRetornoLiquidadoAposBaixaouNaoRegistro   : Result := '17';
    toRetornoAcertoDepositaria                 : Result := '18';
    toRetornoRecebimentoInstrucaoProtestar     : Result := '19';
    toRetornoRecebimentoInstrucaoSustarProtesto: Result := '20';
    toRetornoAcertoControleParticipante        : Result := '21';
    toRetornoTituloPagamentoCancelado          : Result := '22';
    toRetornoEncaminhadoACartorio              : Result := '23';
    toRetornoEntradaRejeitaCEPIrregular        : Result := '24';
    toRetornoBaixaRejeitada                    : Result := '27';
    toRetornoDebitoTarifas                     : Result := '28';
    toRetornoAlteracaoOutrosDadosRejeitada     : Result := '30';
    toRetornoComandoRecusado                   : Result := '32';
    { DONE -oJacinto -cAjuste : Acrescentar a ocorr�ncia correta referente ao c�digo. }
    toRetornoRecebimentoInstrucaoAlterarDados  : Result := '33';
    { DONE -oJacinto -cAjuste : Acrescentar a ocorr�ncia correta referente ao c�digo. }
    toRetornoRetiradoDeCartorio                : Result := '34';
    toRetornoDesagendamentoDebitoAutomatico    : Result := '35';
  else
    Result := '02';
  end;
end;

function TACBrBancoBradescoSICOOB.COdMotivoRejeicaoToDescricao( const TipoOcorrencia:TACBrTipoOcorrencia ;CodMotivo: Integer) : String;
begin
   case TipoOcorrencia of
      toRetornoRegistroConfirmado:
      case CodMotivo  of
         00: Result := '00-Ocorrencia aceita';
         17: Result := '17-Data de vencimento anterior a data de emiss�o';
         21: Result := '21-Esp�cie do T�tulo inv�lido';
         24: Result := '24-Data da emiss�o inv�lida';
         38: Result := '38-Prazo para protesto inv�lido';
         39: Result := '39-Pedido para protesto n�o permitido para t�tulo';
         43: Result := '43-Prazo para baixa e devolu��o inv�lido';
         45: Result := '45-Nome do Sacado inv�lido';
         46: Result := '46-Tipo/num. de inscri��o do Sacado inv�lidos';
         47: Result := '47-Endere�o do Sacado n�o informado';
         48: Result := '48-CEP invalido';
         50: Result := '50-CEP referente a Banco correspondente';
         53: Result := '53-N� de inscri��o do Sacador/avalista inv�lidos (CPF/CNPJ)';
         54: Result := '54-Sacador/avalista n�o informado';
         67: Result := '67-D�bito autom�tico agendado';
         68: Result := '68-D�bito n�o agendado - erro nos dados de remessa';
         69: Result := '69-D�bito n�o agendado - Sacado n�o consta no cadastro de autorizante';
         70: Result := '70-D�bito n�o agendado - Cedente n�o autorizado pelo Sacado';
         71: Result := '71-D�bito n�o agendado - Cedente n�o participa da modalidade de d�bito autom�tico';
         72: Result := '72-D�bito n�o agendado - C�digo de moeda diferente de R$';
         73: Result := '73-D�bito n�o agendado - Data de vencimento inv�lida';
         75: Result := '75-D�bito n�o agendado - Tipo do n�mero de inscri��o do sacado debitado inv�lido';
         86: Result := '86-Seu n�mero do documento inv�lido';
      else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;
      toRetornoRegistroRecusado:
      case CodMotivo of
         02: Result:= '02-Codigo do registro detalhe invalido';
         03: Result:= '03-Codigo da Ocorrencia Invalida';
         04: Result:= '04-Codigo da Ocorrencia nao permitida para a carteira';
         05: Result:= '05-Codigo de Ocorrencia nao numerico';
         07: Result:= 'Agencia\Conta\Digito invalido';
         08: Result:= 'Nosso numero invalido';
         09: Result:= 'Nosso numero duplicado';
         10: Result:= 'Carteira invalida';
         16: Result:= 'Data de vencimento invalida';
         18: Result:= 'Vencimento fora do prazo de operacao';
         20: Result:= 'Valor do titulo invalido';
         21: Result:= 'Especie do titulo invalida';
         22: Result:= 'Especie nao permitida para a carteira';
         24: Result:= 'Data de emissao invalida';
         38: Result:= 'Prazo para protesto invalido';
         44: Result:= 'Agencia cedente nao prevista';
         50: Result:= 'CEP irregular - Banco correspondente';
         63: Result:= 'Entrada para titulo ja cadastrado';
         68: Result:= 'Debito nao agendado - Erro nos dados da remessa';
         69: Result:= 'Debito nao agendado - Sacado nao consta no cadastro de autorizante';
         70: Result:= 'Debito nao agendado - Cedente nao autorizado pelo sacado';
         71: Result:= 'Debito nao agendado - Cedente nao participa de debito automatico';
         72: Result:= 'Debito nao agendado - Codigo de moeda diferente de R$';
         73: Result:= 'Debito nao agendado - Data de vencimento invalida';
         74: Result:= 'Debito nao agendado - Conforme seu pedido titulo nao registrado';
         75: Result:= 'Debito nao agendado - Tipo de numero de inscricao de debitado invalido';
      else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;
      toRetornoBaixadoViaArquivo:
      case CodMotivo of
         10: Result:= '10=Baixa comandada pelo cliente';
      else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;
      toRetornoBaixadoInstAgencia:
         case CodMotivo of
            00: Result:= '00-Baixa Comandada';
            14: Result:= '14-Titulo protestado';
            15: Result:= '15-Titulo excluido';
         else
            Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
         end;

      toRetornoEntradaRejeitaCEPIrregular:
      case CodMotivo of
         48: Result:= '48-CEP invalido';
      else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;

      toRetornoBaixaRejeitada:
      case CodMotivo of
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
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;

      toRetornoDebitoTarifas:
      case CodMotivo of
         03: Result:= '03-Tarifa de susta��o';
         04: Result:= '04-Tarifa de protesto';
         08: Result:= '08-Custas de protesto';
      else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;

      toRetornoALteracaoOutrosDadosRejeitada:
      case CodMotivo of
         01: Result:= '01-C�digo do Banco inv�lido';
         04: Result:= '04-C�digo de ocorr�ncia n�o permitido para a carteira';
         05: Result:= '05-C�digo da ocorr�ncia n�o num�rico';
         08: Result:= '08-Nosso n�mero inv�lido';
         15: Result:= '15-Caracter�stica da cobran�a incompat�vel';
         16: Result:= '16-Data de vencimento inv�lido';
         17: Result:= '17-Data de vencimento anterior a data de emiss�o';
         18: Result:= '18-Vencimento fora do prazo de opera��o';
         24: Result:= '24-Data de emiss�o Inv�lida';
         29: Result:= '29-Valor do desconto maior/igual ao valor do T�tulo';
         30: Result:= '30-Desconto a conceder n�o confere';
         31: Result:= '31-Concess�o de desconto j� existente ( Desconto anterior )';
         33: Result:= '33-Valor do abatimento inv�lido';
         34: Result:= '34-Valor do abatimento maior/igual ao valor do T�tulo';
         38: Result:= '38-Prazo para protesto inv�lido';
         39: Result:= '39-Pedido de protesto n�o permitido para o T�tulo';
         40: Result:= '40-T�tulo com ordem de protesto emitido';
         42: Result:= '42-C�digo para baixa/devolu��o inv�lido';
         60: Result:= '60-Movimento para T�tulo n�o cadastrado';
         85: Result:= '85-T�tulo com Pagamento Vinculado.';
      else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;

      toRetornoComandoRecusado:
      case CodMotivo of
         01 : Result:= '01-C�digo do Banco inv�lido';
         02 : Result:= '02-C�digo do registro detalhe inv�lido';
         04 : Result:= '04-C�digo de ocorr�ncia n�o permitido para a carteira';
         05 : Result:= '05-C�digo de ocorr�ncia n�o num�rico';
         07 : Result:= '07-Ag�ncia/Conta/d�gito inv�lidos';
         08 : Result:= '08-Nosso n�mero inv�lido';
         10 : Result:= '10-Carteira inv�lida';
         15 : Result:= '15-Caracter�sticas da cobran�a incompat�veis';
         16 : Result:= '16-Data de vencimento inv�lida';
         17 : Result:= '17-Data de vencimento anterior a data de emiss�o';
         18 : Result:= '18-Vencimento fora do prazo de opera��o';
         20 : Result:= '20-Valor do t�tulo inv�lido';
         21 : Result:= '21-Esp�cie do T�tulo inv�lida';
         22 : Result:= '22-Esp�cie n�o permitida para a carteira';
         24 : Result:= '24-Data de emiss�o inv�lida';
         28 : Result:= '28-C�digo de desconto via Telebradesco inv�lido';
         29 : Result:= '29-Valor do desconto maior/igual ao valor do T�tulo';
         30 : Result:= '30-Desconto a conceder n�o confere';
         31 : Result:= '31-Concess�o de desconto - J� existe desconto anterior';
         33 : Result:= '33-Valor do abatimento inv�lido';
         34 : Result:= '34-Valor do abatimento maior/igual ao valor do T�tulo';
         36 : Result:= '36-Concess�o abatimento - J� existe abatimento anterior';
         38 : Result:= '38-Prazo para protesto inv�lido';
         39 : Result:= '39-Pedido de protesto n�o permitido para o T�tulo';
         40 : Result:= '40-T�tulo com ordem de protesto emitido';
         41 : Result:= '41-Pedido cancelamento/susta��o para T�tulo sem instru��o de protesto';
         42 : Result:= '42-C�digo para baixa/devolu��o inv�lido';
         45 : Result:= '45-Nome do Sacado n�o informado';
         46 : Result:= '46-Tipo/n�mero de inscri��o do Sacado inv�lidos';
         47 : Result:= '47-Endere�o do Sacado n�o informado';
         48 : Result:= '48-CEP Inv�lido';
         50 : Result:= '50-CEP referente a um Banco correspondente';
         53 : Result:= '53-Tipo de inscri��o do sacador avalista inv�lidos';
         60 : Result:= '60-Movimento para T�tulo n�o cadastrado';
         85 : Result:= '85-T�tulo com pagamento vinculado';
         86 : Result:= '86-Seu n�mero inv�lido';
      else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;

      toRetornoDesagendamentoDebitoAutomatico:
      case CodMotivo of
         81 : Result:= '81-Tentativas esgotadas, baixado';
         82 : Result:= '82-Tentativas esgotadas, pendente';
      else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;
   else
      Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
   end;
end;

function TACBrBancoBradescoSICOOB.CalcularTamMaximoNossoNumero(
  const Carteira: String; const NossoNumero: String; const Convenio: String): Integer;
begin
  Result := ACBrBanco.TamanhoMaximoNossoNum;
end;

function TACBrBancoBradescoSICOOB.FormataNossoNumero(
  const ACBrTitulo: TACBrTitulo): String;
begin
  Result:=  FormatDateTime('yy',ACBrTitulo.DataDocumento)+
             PadLeft( ACBrTitulo.ACBrBoleto.Cedente.Convenio, 3, '0')+
             ACBrTitulo.NossoNumero;
end;

end.


