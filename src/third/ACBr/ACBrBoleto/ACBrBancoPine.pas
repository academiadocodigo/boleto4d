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

unit ACBrBancoPine;

interface

uses
  Classes, Contnrs, SysUtils, ACBrBoleto, ACBrBoletoConversao;

type

  { TACBrBancoPine }

  TACBrBancoPine = class(TACBrBancoClass)
  private
    function TipoOcorrenciaRemessaToCod(const TipoOcorrencia: TACBrTipoOcorrencia): String;
    function EspecieDocToCod(const Especie: String): String;
    function CodToEspecie(const CodEspecie: Integer): String;
    function MontarPosicoesSacador(const ACBrTitulo:TACBrTitulo; const Instrucao94: Boolean): String;
    function MontarRegistroMensagens(const ACBrTitulo:TACBrTitulo; const Instrucao94: Boolean): String;
    function MontarRegistroSacador(const ACBrTitulo:TACBrTitulo): String;
    procedure GerarRegistrosNFe(ACBrTitulo : TACBrTitulo; aRemessa: TStringList);
  protected
    fCorrespondente: Boolean;
    function CalcularNossoNumero(const ACBrTitulo:TACBrTitulo): String; virtual;
    function CalcularCarteira(const ACBrTitulo:TACBrTitulo): String; virtual;
    function LerNossoNumero(const aLinha:String; ACBrTitulo : TACBrTitulo ):String;  virtual;
    function GetLocalPagamento: string;  override;
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
    function CodMotivoRejeicaoToDescricao(const TipoOcorrencia:TACBrTipoOcorrencia; CodMotivo:Integer): String; override;
  end;

implementation

uses {$IFDEF COMPILER6_UP} dateutils {$ELSE} ACBrD5 {$ENDIF},
  StrUtils,
  ACBrUtil, ACBrValidador ;

{ TACBrBancoPine }

function TACBrBancoPine.LerNossoNumero(const aLinha: String; ACBrTitulo : TACBrTitulo): String;
begin
   ACBrTitulo.NossoNumero:= Copy(aLinha, 63, 10);
end;

function TACBrBancoPine.GetLocalPagamento: string;
begin
   if fCorrespondente then
      Result:= ACBrStr('Pag�vel preferencialmente na Rede Bradesco ou Bradesco Expresso')
   else
      Result:= ACBrStr('Canais eletr�nicos, ag�ncias ou correspondentes banc�rios de todo o BRASIL');

end;

function TACBrBancoPine.TipoOcorrenciaRemessaToCod(const TipoOcorrencia: TACBrTipoOcorrencia): String;
begin
   Result := '';

   case TipoOcorrencia of
     toRemessaRegistrar          : Result := '01';
     toRemessaBaixar             : Result := '02';
     toRemessaConcederAbatimento : Result := '04';
     toRemessaCancelarAbatimento : Result := '05';
     toRemessaAlterarVencimento  : Result := '06';
     toRemessaProtestar          : Result := '09';
     toRemessaNaoProtestar       : Result := '10';
     toRemessaSustarProtesto     : Result := '18';
     toRemessaAlterarValorTitulo : Result := '47';
  else
    Result:= '01';
  end;
end;

function TACBrBancoPine.EspecieDocToCod(const Especie: String): String;
var
  wEspecie: String;
begin
   wEspecie:= Trim(Especie);

   case AnsiIndexStr(wEspecie, ['DM', 'NP', 'CH', 'LC', 'RE', 'AS', 'DS', 'CD',
                                'OU']) of

     00: Result:= '01';
     01: Result:= '02';
     02: Result:= '03';
     03: Result:= '04';
     04: Result:= '05';
     05: Result:= '08';
     06: Result:= '12';
     07: Result:= '31';
     08: Result:= '99';
   else
      Result:= wEspecie;
   end;
end;

function TACBrBancoPine.CodToEspecie(const CodEspecie: Integer): String;
begin
   case CodEspecie of
      01: Result:= 'DM';
      02: Result:= 'NP';
      03: Result:= 'CH';
      04: Result:= 'LC';
      05: Result:= 'RE';
      08: Result:= 'AS';
      12: Result:= 'DS';
      31: Result:= 'CD';
   else
      Result:= 'OU';
   end;
end;

function TACBrBancoPine.MontarPosicoesSacador(const ACBrTitulo: TACBrTitulo;
  const Instrucao94: Boolean ): String;
begin
  if Instrucao94 then
  begin
     if ACBrTitulo.Mensagem.Count > 0 then
        Result:= PadRight(ACBrTitulo.Mensagem[0], 40)
     else
        Result:= StringOfChar(' ', 40);
  end
  else
     Result:= PadRight(ACBrTitulo.Sacado.SacadoAvalista.NomeAvalista,40);
end;

function TACBrBancoPine.MontarRegistroMensagens(const ACBrTitulo: TACBrTitulo;
  const Instrucao94: Boolean): String;
var
  I: Integer;
begin
   Result:= '';

   if (Instrucao94) then
      I:= 1
   else
      I:= 0;

   if (Instrucao94) and (I =  ACBrTitulo.Mensagem.Count) then
      exit;

   Result:= '2' + '0' ;
   while (I < 5) and  (I < ACBrTitulo.Mensagem.Count) do
   begin
      Result := Result + PadRight(Copy(ACBrTitulo.Mensagem[I], 1, 69), 69);
      Inc(I);
   end;
   Result:= PadRight(Result, 347)  + StringOfChar(' ', 47);
end;

function TACBrBancoPine.MontarRegistroSacador(const ACBrTitulo: TACBrTitulo
  ): String;
var
  wTipoSacador: String;
begin
  if  ACBrTitulo.Sacado.SacadoAvalista.Pessoa = pFisica then
     wTipoSacador := '01'
  else
     wTipoSacador := '02';

  Result:= '5'       +
           StringOfChar(' ',120)  +
           wTipoSacador           +
           PadLeft(OnlyNumber(ACBrTitulo.Sacado.SacadoAvalista.CNPJCPF), 14, '0') +
           PadRight(ACBrTitulo.Sacado.SacadoAvalista.Logradouro + ' '             +
                    ACBrTitulo.Sacado.SacadoAvalista.Numero + ' '                 +
                    ACBrTitulo.Sacado.SacadoAvalista.Complemento,40)              +
           PadRight(ACBrTitulo.Sacado.SacadoAvalista.Bairro,12)                   +
           PadLeft(ACBrTitulo.Sacado.SacadoAvalista.CEP, 8, '0')                  +
           PadRight(ACBrTitulo.Sacado.SacadoAvalista.Cidade,15)                   +
           PadRight(ACBrTitulo.Sacado.SacadoAvalista.UF,2)                        +
           StringOfChar(' ', 180);
end;

function TACBrBancoPine.CalcularNossoNumero(const ACBrTitulo: TACBrTitulo
  ): String;
begin
  if ACBrTitulo.ACBrBoleto.Cedente.ResponEmissao = tbCliEmite then
     Result:= ACBrTitulo.NossoNumero + CalcularDigitoVerificador(ACBrTitulo)
  else
     Result:= StringOfChar('0',11);

  Result:= Result +
           StringOfChar(' ', 16 ); {74 a  89- Nosso numero e carteira no correspondente}
end;

function TACBrBancoPine.CalcularCarteira(const ACBrTitulo: TACBrTitulo): String;
begin
   if ACBrBanco.ACBrBoleto.Cedente.ResponEmissao = tbCliEmite then
      Result:= 'D'
   else
      Result:= '1';
end;

procedure TACBrBancoPine.GerarRegistrosNFe(ACBrTitulo: TACBrTitulo;
  aRemessa: TStringList);
var
  wQtdRegNFes, J, I, wQtdNFeNaLinha: Integer;
  wLinha, NFeSemDados: String;
  Continua: Boolean;
begin
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
      wQtdNFeNaLinha:= 0;
      while (Continua) and (J < ACBrTitulo.ListaDadosNFe.Count) do
      begin
         wLinha:= wLinha +
                  PadRight(ACBrTitulo.ListaDadosNFe[J].NumNFe,15) +
                  IntToStrZero( round(ACBrTitulo.ListaDadosNFe[J].ValorNFe  * 100 ), 13) +
                  FormatDateTime('ddmmyyyy',ACBrTitulo.ListaDadosNFe[J].EmissaoNFe)      +
                  PadLeft(ACBrTitulo.ListaDadosNFe[J].ChaveNFe, 44, '0');

         Inc(J);
         Inc(wQtdNFeNaLinha);
         Continua:= (J mod 3) <> 0 ;
      end;

      if wQtdNFeNaLinha < 3 then
      begin
         wLinha:= wLinha + NFeSemDados;
         if wQtdNFeNaLinha < 2 then
            wLinha:= wLinha + NFeSemDados;
      end;

      wLinha:= PadRight(wLinha,241) + StringOfChar(' ', 153) +
               IntToStrZero(aRemessa.Count + 1, 6);

      aRemessa.Add(wLinha);
      Inc(I);
   end;
   until (I = wQtdRegNFes) ;
end;

constructor TACBrBancoPine.create(AOwner: TACBrBanco);
begin
   inherited create(AOwner);
   fpNome                   := 'Pine';
   fpNumero                 := 643;
   fpDigito                 := 2;
   fpTamanhoMaximoNossoNum  := 10;
   fpTamanhoAgencia         := 4;
   fpTamanhoConta           := 6;
   fpTamanhoCarteira        := 3;
   fCorrespondente          := False;
end;

function TACBrBancoPine.CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo ): String;
var
  Docto: String;
begin
   Result := '0';
   Docto := ACBrBanco.ACBrBoleto.Cedente.Agencia +
            ACBrTitulo.Carteira +
            ACBrTitulo.NossoNumero;


   Modulo.MultiplicadorInicial := 1;
   Modulo.MultiplicadorFinal   := 2;
   Modulo.MultiplicadorAtual   := 2;
   Modulo.FormulaDigito := frModulo10;
   Modulo.Documento:= Docto;
   Modulo.Calcular;

   Result := IntToStr(Modulo.DigitoFinal);
end;

function TACBrBancoPine.MontarCodigoBarras ( const ACBrTitulo: TACBrTitulo) : String;
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
                      PadLeft(RightStr(Cedente.Operacao,7),7,'0') +
                      ACBrTitulo.NossoNumero +
                      CalcularDigitoVerificador(ACBrTitulo);

      DigitoCodBarras := CalcularDigitoCodigoBarras(CodigoBarras);
   end;
   Result:= IntToStr(Numero) + '9'+ DigitoCodBarras + Copy(CodigoBarras,5,39);

end;

function TACBrBancoPine.MontarCampoNossoNumero (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result:=  ACBrTitulo.NossoNumero + '-' + CalcularDigitoVerificador(ACBrTitulo);
end;

function TACBrBancoPine.MontarCampoCodigoCedente (
   const ACBrTitulo: TACBrTitulo ) : String;
begin
   Result:= ACBrTitulo.ACBrBoleto.Cedente.Agencia + '/' +
            ACBrTitulo.ACBrBoleto.Cedente.CodigoCedente;
end;

procedure TACBrBancoPine.GerarRegistroHeader400(NumeroRemessa : Integer; ARemessa:TStringList);
var
  wLinha: String;
begin
   wLinha:= '0'                                                     +  {1- ID do Registro }
            '1'                                                     +  {2- ID do Arquivo( 1 - Remessa) }
            'REMESSA'                                               +  {3 a 9 - Literal de Remessa }
            '01'                                                    +  {10 a 11 - C�digo do Tipo de Servi�o }
            PadRight('COBRANCA', 15)                                +  {12 a 26 - Descri��o do tipo de servi�o }
            PadRight(ACBrBanco.ACBrBoleto.Cedente.CodigoCedente, 20)   +  {27 a 46 - Codigo da Empresa no Banco }
            PadRight(Copy(ACBrBanco.ACBrBoleto.Cedente.Nome,1, 30), 30)+  {47 a 76 - Nome da Empresa }
            '643'                                                   +  {77 a 79 - C�digo do Banco(643) }
            PadRight('BANCO PINE', 15)                              +  {80 a 94 - Nome do Banco(Pine ) }
            FormatDateTime('ddmmyy',Now)                            +  {95 a 100 - Data de gera��o do arquivo}
            Space(294)                                              +  {101 a 394 - brancos }
            IntToStrZero(1, 6);                                       {395 a 400 - Contador }

   ARemessa.Text:= UpperCase(wLinha);

end;

procedure TACBrBancoPine.GerarRegistroTransacao400(ACBrTitulo :TACBrTitulo; aRemessa: TStringList);
var
  wLinha, wTipoInscricao, wNossoNumero, wMulta, wDiasMulta, wSeuNumero: String;
  wDiasProtesto, wCNPJCedente, wDataDesconto: String;
  wInstrucao94: Boolean;
  wTipoMulta: Char;
begin
   case ACBrBanco.ACBrBoleto.Cedente.TipoInscricao of
     pFisica  : wTipoInscricao:= '01';
     pJuridica: wTipoInscricao:= '02';
   else
     wTipoInscricao:= '02';
   end;

   wCNPJCedente:= OnlyNumber(ACBrBanco.ACBrBoleto.Cedente.CNPJCPF);


   wNossoNumero:= CalcularNossoNumero(ACBrTitulo);

   wDiasMulta:= StringOfChar('0',2);
   if ACBrTitulo.PercentualMulta > 0 then
   begin
      if ACBrTitulo.CodigoMulta = cmValorFixo then
      begin
         wTipoMulta:= '1';
         wMulta    := IntToStrZero(round(ACBrTitulo.PercentualMulta * 100), 13);
      end
      else
      begin
         wTipoMulta:= '2';
         wMulta    := IntToStrZero(round(ACBrTitulo.PercentualMulta * 10000), 13);
      end;

      if ACBrTitulo.DataMulta > 0 then
         wDiasMulta:= IntToStrZero(DaysBetween(ACBrTitulo.Vencimento, ACBrTitulo.DataMulta),2);
   end
   else
   begin
      wTipoMulta:= '0';
      wMulta    := StringOfChar('0',13);
   end;

   wSeuNumero:= PadRight(IfThen(ACBrTitulo.SeuNumero <> '', ACBrTitulo.SeuNumero,
                         ACBrTitulo.NumeroDocumento),10);

   if ACBrTitulo.DataProtesto > 0 then
      wDiasProtesto:=  IntToStrZero(DaysBetween(ACBrTitulo.Vencimento,
                                     ACBrTitulo.DataProtesto),2)
   else
      wDiasProtesto:= '00';

   if (ACBrTitulo.ValorDesconto > 0) and (ACBrTitulo.DataDesconto > 0) then
      wDataDesconto:= FormatDateTime( 'ddmmyy', ACBrTitulo.DataDesconto)
   else
      wDataDesconto:= StringOfChar('0',6);

   wInstrucao94:=  (ACBrTitulo.Instrucao1 = '94') or (ACBrTitulo.Instrucao2 = '94');

   wLinha:= '1'                                                                  + {1- ID Registro }
            wTipoInscricao                                                       + {2 a 3 - Id do Tipo de Inscri��o}
            PadLeft(wCNPJCedente, 14, '0')                                 + {4 a 17 - CNPJ/CPF da Empresa}
            PadRight(ACBrBanco.ACBrBoleto.Cedente.CodigoCedente, 20)             + {18 a 37 - Codigo da Empresa no Banco }
            PadRight(ACBrTitulo.NumeroDocumento,25)                              + {38 a 62 - Id do Titulo na Empresa}
            wNossoNumero                                                   + {63 a 73 - Nosso Numero + DV / 74 a 89 Nosso Numero + Carteira correspondente}
            wTipoMulta                                                     + {90 - C�digo de Multa}
            wMulta                                                         + {91 a 103 - Valor/Percentual de Multa}
            wDiasMulta                                                     + {104 a 105 - Dias para Multa}
            StringOfChar(' ',2)                                            + {106 a 107 - Uso do banco}
            CalcularCarteira(ACBrTitulo)                                   + {108 - C�digo da Carteira - Somente Pine}
            TipoOcorrenciaRemessaToCod(ACBrTitulo.OcorrenciaOriginal.Tipo) + {109 a 110 - C�digo de Ocorrencia}
            wSeuNumero                                                     + {111 a 120 - Seu Numero}
            FormatDateTime( 'ddmmyy', ACBrTitulo.Vencimento)               + {121 a 126 - Data Vencimento}
            IntToStrZero( Round( ACBrTitulo.ValorDocumento * 100 ), 13)    + {127 a 139 - Valo Titulo}
            IntToStr( ACBrTitulo.ACBrBoleto.Banco.Numero)                  + {140 a 142 - Numero do banco}
            StringOfChar('0',5)                                            + {143 a 147 - Zeros}
            EspecieDocToCod(ACBrTitulo.EspecieDoc)                         + {148 a 149 - Especie do Documento}
            IfThen(ACBrTitulo.Aceite = atSim, 'A', 'N')                    + {150 - Aceite}
            FormatDateTime( 'ddmmyy', ACBrTitulo.DataDocumento)            + {151 a 156 - Data Emissao}
            PadLeft(trim(ACBrStr(ACBrTitulo.Instrucao1)), 2, '0')          + {157 a 158 - 1� INSTRU��O}
            PadLeft(trim(ACBrStr(ACBrTitulo.Instrucao2)), 2, '0')          + {159 a 160 - 2� INSTRU��O}
            IntToStrZero( round(ACBrTitulo.ValorMoraJuros * 100 ), 13)     + {161 a 173 - Valor a ser cobrado por dia de atraso}
            wDataDesconto                                                  + {174 a 179 - Data limite para desconto}
            IntToStrZero( round(ACBrTitulo.ValorDesconto * 100 ), 13)      + {180 a 192 - Valor de desconto a ser concedido para pagto antecipado}
            IntToStrZero( round(ACBrTitulo.ValorIOF * 100 ), 13)           + {193 a 205 - Valor IOF}
            IntToStrZero( round(ACBrTitulo.ValorAbatimento * 100 ), 13)    + {206 a 218 - Valor de abatimento a ser concedido}
            IfThen(ACBrTitulo.Sacado.Pessoa = pFisica, '01', '02')         + {219 a 220 - Tipo Inscri��o do Pagaador}
            PadLeft(OnlyNumber(ACBrTitulo.Sacado.CNPJCPF), 14, '0')        + {221 a 234 - CPF/CNPJ do pagador}
            PadRight(ACBrTitulo.Sacado.NomeSacado, 30)                     + {235 a 264 - Nome do pagador}
            StringOfChar(' ', 10)                                          + {265 a 274 - Brancos}
            PadRight(ACBrTitulo.Sacado.Logradouro + ' ' +
                     ACBrTitulo.Sacado.Numero +  ' ' +
                     ACBrTitulo.Sacado.Complemento, 40)                    + {275 a 314 - Rua}
            PadRight(ACBrTitulo.Sacado.Bairro, 12)                         + {315 a 326 - Bairro}
            PadLeft(OnlyNumber(ACBrTitulo.Sacado.CEP), 8)                  + {327 a 334 - CEP}
            PadRight(ACBrTitulo.Sacado.Cidade, 15)                         + {335 a 349 - Cidade}
            ACBrTitulo.Sacado.UF                                           + {350 a 351 - UF}
            MontarPosicoesSacador(ACBrTitulo, wInstrucao94)                + {352 a 391 - Dados Sacador ou Mensagens}
            wDiasProtesto + '0'                                            + {392 a 393 - Dias para protesto + Moeda}
            IntToStrZero(aRemessa.Count + 1, 6);                             {394 a 400 - Sequencial do Registro no arquivo}


   aRemessa.Add(UpperCase(wLinha));

   if ACBrTitulo.Mensagem.Count > 0 then
   begin
      wLinha:= MontarRegistroMensagens(ACBrTitulo, wInstrucao94) + IntToStrZero(aRemessa.Count + 1, 6);
      if wLinha <> '' then
         aRemessa.Add(UpperCase(wLinha));
   end;

   if (not fCorrespondente) and (trim(ACBrTitulo.Sacado.SacadoAvalista.NomeAvalista) <> '') then
   begin
      wLinha:= MontarRegistroSacador(ACBrTitulo) + IntToStrZero(aRemessa.Count + 1,6);
      aRemessa.Add(UpperCase(wLinha));
   end;

   if ACBrTitulo.ListaDadosNFe.Count > 0 then
      GerarRegistrosNFe(ACBrTitulo, aRemessa);

end;

procedure TACBrBancoPine.GerarRegistroTrailler400( ARemessa:TStringList );
var
  wLinha: String;
begin
   wLinha := '9' + Space(393) + IntToStrZero( ARemessa.Count + 1, 6);

   ARemessa.Add(wLinha);
end;

procedure TACBrBancoPine.LerRetorno400(ARetorno: TStringList);
var
  Titulo : TACBrTitulo;
  ContLinha, CodOcorrencia  :Integer;
  CodMotivo, i, MotivoLinha :Integer;
  Linha, rCedente, rCNPJCPF :String;
  rCodEmpresa               :String;
begin
   if (StrToIntDef(copy(ARetorno.Strings[0],77,3),-1) <> 643) then
      raise Exception.Create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                             'n�o � um arquivo de retorno do Banco Pine'));

   rCodEmpresa:= trim(Copy(ARetorno[0],27,20));
   rCedente   := trim(Copy(ARetorno[0],47,30));

   ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0],109,5),0);

   ACBrBanco.ACBrBoleto.DataArquivo := StringToDateTimeDef(Copy(ARetorno[0],95,2)+'/'+
                                                           Copy(ARetorno[0],97,2)+'/'+
                                                           Copy(ARetorno[0],99,2),0, 'DD/MM/YY' );

   case StrToIntDef(Copy(ARetorno[1],2,2),0) of
      1: rCNPJCPF := Copy(ARetorno[1],7,11);
      2: rCNPJCPF := Copy(ARetorno[1],4,14);
   else
     rCNPJCPF := Copy(ARetorno[1],4,14);
   end;

   ValidarDadosRetorno('', '',rCNPJCPF);
   with ACBrBanco.ACBrBoleto do
   begin
      if (not LeCedenteRetorno) and (rCodEmpresa <> trim(Cedente.CodigoCedente)) then
         raise Exception.Create(ACBrStr('C�digo da Empresa do arquivo inv�lido ' + rCodEmpresa + ' c:' + Cedente.CodigoCedente));

      case StrToIntDef(Copy(ARetorno[1],2,2),0) of
         1: Cedente.TipoInscricao:= pFisica;
         2: Cedente.TipoInscricao:= pJuridica;
      else
         Cedente.TipoInscricao := pJuridica;
      end;

      if LeCedenteRetorno then
      begin
         Cedente.CNPJCPF      := rCNPJCPF;
         Cedente.CodigoCedente:= rCodEmpresa;
         Cedente.Nome         := rCedente;
      end;

      ACBrBanco.ACBrBoleto.ListadeBoletos.Clear;
   end;

   for ContLinha := 1 to ARetorno.Count - 2 do
   begin
      Linha := ARetorno[ContLinha] ;

      if Copy(Linha,1,1)<> '1' then
         Continue;

      Titulo := ACBrBanco.ACBrBoleto.CriarTituloNaLista;

      Titulo.NumeroDocumento := copy(Linha, 38, 25);
      Titulo.SeuNumero       := copy(Linha, 117, 10);
      Titulo.Carteira        := Copy(Linha, 83, 3);
      Titulo.EspecieDoc      := CodToEspecie(StrToIntDef(Copy(Linha, 174, 2),0));
      LerNossoNumero(Linha, Titulo);

      case  Linha[108] of
        '1': Titulo.CaracTitulo:= tcSimples;
        '2': Titulo.CaracTitulo:= tcVinculada;
        '3': Titulo.CaracTitulo:= tcCaucionada;
      else
        Titulo.CaracTitulo:= tcDireta;
      end;

      Titulo.ValorDocumento  := StrToFloatDef(Copy(Linha, 153, 13), 0) / 100;
      Titulo.ValorAbatimento := StrToFloatDef(Copy(Linha, 228, 13), 0) / 100;
      Titulo.ValorDesconto   := StrToFloatDef(Copy(Linha, 241, 13), 0) / 100;
      Titulo.ValorPago       := StrToFloatDef(Copy(Linha, 254, 13), 0) / 100;
      Titulo.ValorMoraJuros  := StrToFloatDef(Copy(Linha, 267, 13), 0) / 100;
      Titulo.ValorRecebido   := Titulo.ValorPago + Titulo.ValorMoraJuros;

      if Copy(Linha,147,2) <> '00' then
         Titulo.Vencimento := StringToDateTimeDef( Copy(Linha, 147, 2)+ '/' +
                                                   Copy(Linha, 149, 2)+ '/' +
                                                   Copy(Linha, 151, 2), 0, 'DD/MM/YY' );


      if Copy(Linha,386,2) <> '00' then
         Titulo.DataCredito := StringToDateTimeDef( Copy(Linha, 386, 2)+ '/' +
                                                    Copy(Linha, 388, 2)+ '/' +
                                                    Copy(Linha, 390, 2), 0, 'DD/MM/YY' );


      CodOcorrencia := StrToIntDef(copy(Linha, 109, 2), 0);
      Titulo.OcorrenciaOriginal.Tipo := CodOcorrenciaToTipo(CodOcorrencia);
      Titulo.DataOcorrencia          := StringToDateTimeDef( Copy(Linha, 111, 2)+ '/' +
                                                             Copy(Linha, 113, 2)+ '/' +
                                                             Copy(Linha, 115, 2), 0, 'DD/MM/YY' );

      MotivoLinha := 378;
      if(CodOcorrencia in [03, 15, 16])then
      begin
         for i := 0 to 4 do
         begin
            CodMotivo := StrToIntDef(copy(Linha,MotivoLinha,2),0);
            if CodMotivo > 0 then
            begin
               Titulo.MotivoRejeicaoComando.Add(copy(Linha,MotivoLinha,2));
               Titulo.DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(Titulo.OcorrenciaOriginal.Tipo,CodMotivo));
            end;

            MotivoLinha := MotivoLinha + 2; //Incrementa a coluna dos motivos
         end;
      end;
   end;
end;

function TACBrBancoPine.TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String;
var
  CodOcorrencia: Integer;
begin
   Result := '';
   CodOcorrencia := StrToIntDef(TipoOCorrenciaToCod(TipoOcorrencia),0);

   // Ver oque seria 01 - confirma entrada CIP  /05 Campo Livre Alterado
   // Tarifa Sobre Baixas � M�s Anterior /98 Tarifa Sobre Entradas � M�s Anterior

   case CodOcorrencia of
     01: Result:= 'Confirma Entrada T�tulo na CIP';
     02: Result:= 'Entrada Confirmada';
     03: Result:= 'Entrada Rejeitada';
     05: Result:= 'Campo Livre Alterado';
     06: Result:= 'Liquida��o Normal';
     08: Result:= 'Liquida��o em Cart�rio';
     09: Result:= 'Baixa Autom�tica';
     10: Result:= 'Baixa por ter sido liquidado';
     12: Result:= 'Confirma Abatimento';
     13: Result:= 'Abatimento Cancelado';
     14: Result:= 'Vencimento Alterado';
     15: Result:= 'Baixa Rejeitada';
     16: Result:= 'Instru��o Rejeitada';
     19: Result:= 'Confirma Recebimento de Ordem de Protesto';
     20: Result:= 'Confirma Recebimento de Ordem de Susta��o';
     22: Result:= 'Seu n�mero alterado';
     23: Result:= 'T�tulo enviado para cart�rio';
     24: Result:= 'Confirma recebimento de ordem de n�o protestar';
     28: Result:= 'D�bito de Tarifas/Custas � Correspondentes';
     40: Result:= 'Tarifa de Entrada (debitada na Liquida��o)';
     43: Result:= 'Baixado por ter sido protestado';
     96: Result:= 'Tarifa Sobre Instru��es � M�s anterior';
     97: Result:= 'Tarifa Sobre Baixas � M�s Anterior';
     98: Result:= 'Tarifa Sobre Entradas � M�s Anterior';
   end;
end;

function TACBrBancoPine.CodOcorrenciaToTipo(const CodOcorrencia:
   Integer ) : TACBrTipoOcorrencia;
begin
   Result := toTipoOcorrenciaNenhum;

   // Ver oque seria 01 - confirma entrada CIP  /05 Campo Livre Alterado
   // Tarifa Sobre Baixas � M�s Anterior /98 Tarifa Sobre Entradas � M�s Anterior

   case CodOcorrencia of
      1,2: Result:= toRetornoRegistroConfirmado;
      3: Result:= toRetornoRegistroRecusado;
      6: Result:= toRetornoLiquidado;
      8: Result:= toRetornoLiquidadoEmCartorio;
      9: Result:= toRetornoBaixaAutomatica;
      10:Result:= toRetornoBaixaPorTerSidoLiquidado;
      12:Result:= toRetornoAbatimentoConcedido;
      13:Result:= toRetornoAbatimentoCancelado;
      14:Result:= toRetornoVencimentoAlterado;
      15:Result:= toRetornoBaixaRejeitada;
      16:Result:= toRetornoInstrucaoRejeitada;
      19:Result:= toRetornoRecebimentoInstrucaoProtestar;
      20:Result:= toRetornoRecebimentoInstrucaoSustarProtesto;
      22:Result:= toRetornoAlteracaoSeuNumero;
      23:Result:= toRetornoEncaminhadoACartorio;
      24:Result:=toRetornoRecebimentoInstrucaoNaoProtestar;
      28:Result:= toRetornoTarifaMensalLiquidacoesBancosCorrespCarteira;
      40:Result:= toRetornoTarifaDeRelacaoDasLiquidacoes;
      43:Result:= toRetornoBaixaPorProtesto;
      96:Result:= toRetornoTarifaInstrucao;
      97:Result:= toRetornoTarifaMensalBaixasCarteira;
   end;

end;

function TACBrBancoPine.TipoOCorrenciaToCod(
  const TipoOcorrencia: TACBrTipoOcorrencia): String;
begin
   Result := '';

   // Ver oque seria 01 - confirma entrada CIP  /05 Campo Livre Alterado
   // Tarifa Sobre Baixas � M�s Anterior /98 Tarifa Sobre Entradas � M�s Anterior

   case TipoOcorrencia of
      toRetornoRegistroConfirmado                 : Result := '02';
      toRetornoRegistroRecusado                   : Result := '03';
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
      toRetornoAlteracaoSeuNumero                 : Result := '22';
      toRetornoEncaminhadoACartorio               : Result := '23';
      toRetornoRecebimentoInstrucaoNaoProtestar   : Result := '24';
      toRetornoTarifaMensalLiquidacoesBancosCorrespCarteira : Result := '28';
      toRetornoTarifaDeRelacaoDasLiquidacoes      : Result := '40';
      toRetornoBaixaPorProtesto                   : Result := '43';
      toRetornoTarifaInstrucao                    : Result := '96';
      toRetornoTarifaMensalBaixasCarteira         : Result := '97';
   end;
end;

function TACBrBancoPine.CodMotivoRejeicaoToDescricao(
  const TipoOcorrencia: TACBrTipoOcorrencia; CodMotivo: Integer): String;
begin
   case TipoOcorrencia of
      toRetornoRegistroRecusado:
      case CodMotivo  of
         03: Result := '03-CEP inv�lido � N�o temos cobrador � Cobrador n�o Localizado ';
         04: Result := '04-Sigla do Estado inv�lida ';
         05: Result := '05-Data de Vencimento inv�lida ou fora do prazo m�nimo s';
         06: Result := '06-C�digo do Banco inv�lido ';
         08: Result := '08-Nome do sacado n�o informado ';
         10: Result := '10-Logradouro n�o informado';
         14: Result := '14-Registro em duplicidade';
         19: Result := '19-Data de desconto inv�lida ou maior que a data de vencimento';
         20: Result := '20-Valor de IOF n�o num�rico';
         21: Result := '21-Movimento para t�tulo n�o cadastrado no sistema ';
         22: Result := '22-Valor de desconto + abatimento maior que o valor do t�tulo ';
         25: Result := '25-CNPJ ou CPF do sacado inv�lido (aceito com restri��es) ';
         26: Result := '26-Esp�cie de documento inv�lida ';
         27: Result := '27-Data de emiss�o do t�tulo inv�lida';
         28: Result := '28-Seu n�mero n�o informado';
         29: Result := '29-CEP � igual a espa�o ou zeros; ou n�o num�rico';
         30: Result := '30-Valor do t�tulo n�o num�rico ou inv�lido ';
         36: Result := '36-Valor de perman�ncia (mora) n�o num�rico';
         37: Result := '37-Valor de perman�ncia inconsistente, pois, dentro de um m�s, ser� maior que o valor do t�tulo ';
         38: Result := '38-Valor de desconto/abatimento n�o num�rico ou inv�lido';
         39: Result := '39-Valor de abatimento n�o num�rico';
         42: Result := '42-T�tulo j� existente em nossos registros. Nosso n�mero n�o aceito ';
         43: Result := '43-T�tulo enviado em duplicidade nesse movimento ';
         44: Result := '44-T�tulo zerado ou em branco; ou n�o num�rico na remessa ';
         46: Result := '46-T�tulo enviado fora da faixa de Nosso N�mero, estipulada para o cliente';
         51: Result := '51-Tipo/N�mero de Inscri��o Sacador/Avalista Inv�lido ';
         52: Result := '52-Sacador/Avalista n�o informado';
         53: Result := '53-Prazo de vencimento do t�tulo excede ao da contrata��o';
         54: Result := '54-Banco informado n�o � nosso correspondente 140-142';
         55: Result := '55-Banco correspondente informado n�o cobra este CEP ou n�o possui faixas de CEP cadastradas';
         56: Result := '56-Nosso n�mero no correspondente n�o foi informado';
         57: Result := '57-Remessa contendo duas instru��es incompat�veis � n�o protestar e dias de protesto ou prazo para protesto inv�lido';
         58: Result := '58-Entradas Rejeitadas � Reprovado no Represamento para An�lise';
         60: Result := '60-CNPJ/CPF do sacado inv�lido � t�tulo recusado';
         87: Result := '87-Excede Prazo m�ximo entre emiss�o e vencimento';
      else
        case AnsiIndexStr(IntToStr(CodMotivo),
                          ['AA', 'AB', 'AE', 'AI', 'AJ', 'AL', 'AU', 'AV', 'AX', 'BC',
                           'BD', 'BE', 'BF', 'BG', 'BH', 'CC', 'CD', 'CE', 'CF', 'CG',
                           'CH', 'CJ', 'CK', 'CS', 'DA', 'DB', 'DC', 'DD', 'DE', 'DG',
                           'DH', 'DI', 'DJ', 'DM', 'DN', 'DP', 'DT', 'EB', 'G1', 'G2',
                           'G3', 'G4', 'HA', 'HB', 'HC', 'HD', 'HF', 'HG', 'HH', 'HI',
                           'HJ', 'HK', 'HL', 'HM', 'HN', 'IX', 'JB', 'JC', 'JH', 'JI',
                           'JK', 'JK', 'JS', 'JT', 'KC', 'KD', 'KE', 'ZQ', 'ZR', 'ZS',
                           'ZT', 'ZU']) of
           00: Result := 'AA-Servi�o de cobran�a inv�lido';
           01: Result := 'AB-Servi�o de "0" ou "5" e banco cobrador <> zero';
           02: Result := 'AE-T�tulo n�o possui abatimento ';
           03: Result := 'AI-Nossa carteira inv�lida ';
           04: Result := 'AJ-Modalidade com bancos correspondentes inv�lida ';
           05: Result := 'AL-Sacado impedido de entrar nesta cobran�a ';
           06: Result := 'AU-Data da ocorr�ncia inv�lida ';
           07: Result := 'AV-Valor da tarifa de cobran�a inv�lida ';
           08: Result := 'AX-T�tulo em pagamento parcial';
           09: Result := 'BC-An�lise gerencial-sacado inv�lido p/opera��o cr�dito ';
           10: Result := 'BD-An�lise gerencial-sacado inadimplente ';
           11: Result := 'BE-An�lise gerencial-sacado difere do exigido';
           12: Result := 'BF-An�lise gerencial-vencto excede vencto da opera��o de cr�dito ';
           13: Result := 'BG-An�lise gerencial-sacado com baixa liquidez ';
           14: Result := 'BH-An�lise gerencial-sacado excede concentra��o ';
           15: Result := 'CC-Valor de iof incompat�vel com a esp�cie documento';
           16: Result := 'CD-Efetiva��o de protesto sem agenda v�lida';
           17: Result := 'CE-T�tulo n�o aceito - pessoa f�sica';
           18: Result := 'CF-Excede prazo m�ximo da entrada ao vencimento';
           19: Result := 'CG-T�tulo n�o aceito � por an�lise gerencial';
           20: Result := 'CH-T�tulo em espera � em an�lise pelo banco';
           21: Result := 'CJ-An�lise gerencial-vencto do titulo abaixo przcurto';
           22: Result := 'CK-An�lise gerencial-vencto do titulo abaixo przlongo ';
           23: Result := 'CS-T�tulo rejeitado pela checagem de duplicatas';
           24: Result := 'DA-An�lise gerencial � Entrada de T�tulo Descontado com limite cancelado';
           25: Result := 'DB-An�lise gerencial � Entrada de T�tulo Descontado com limite vencido';
           26: Result := 'DC-An�lise gerencial - cedente com limite cancelado';
           27: Result := 'DD-An�lise gerencial � cedente � sacado e teve seu limite cancelado';
           28: Result := 'An�lise gerencial - apontamento no Serasa';
           29: Result := 'DG-Endere�o sacador/avalista n�o informado';
           30: Result := 'DH-Cep do sacador/avalista n�o informado ';
           31: Result := 'DI-Cidade do sacador/avalista n�o informado ';
           32: Result := 'DJ-Estado do sacador/avalista inv�lido ou n informado ';
           33: Result := 'DM-Cliente sem C�digo de Flash cadastrado no cobrador ';
           34: Result := 'DN-T�tulo Descontado com Prazo ZERO � Recusado ';
           35: Result := 'DP-Data de Refer�ncia menor que a Data de Emiss�o do T�tulo ';
           36: Result := 'DT-Nosso N�mero do Correspondente n�o deve ser informado ';
           37: Result := 'EB-HSBC n�o aceita endere�o de sacado com mais de 38 caracteres ';
           38: Result := 'G1-Endere�o do sacador incompleto ( lei 12.039)';
           39: Result := 'G2-Sacador impedido de movimentar';
           40: Result := 'G3-Concentra��o de cep n�o permitida';
           41: Result := 'G4-Valor do t�tulo n�o permitido';
           42: Result := 'HA-Servi�o e Modalidade Incompat�veis';
           43: Result := 'HB-Inconsist�ncias entre Registros T�tulo e Sacador';
           44: Result := 'HC-Ocorr�ncia n�o dispon�vel';
           45: Result := 'HD-T�tulo com Aceite';
           46: Result := 'HJ-Baixa Liquidez do Sacado ';
           47: Result := 'HG-Sacado Informou que n�o paga Boletos ';
           48: Result := 'HH-Sacado n�o confirmou a Nota Fiscal ';
           49: Result := 'HI-Checagem Pr�via n�o Efetuada';
           50: Result := 'HJ-Sacado desconhece compra e Nota Fiscal ';
           51: Result := 'HK-Compra e Nota Fiscal canceladas pelo sacado';
           52: Result := 'HL-Concentra��o al�m do permitido pela �rea de Cr�dito ';
           53: Result := 'HM-Vencimento acima do permitido pelo �rea de Cr�dito';
           54: Result := 'HN-Excede o prazo limite da opera��o';
           55: Result := 'IX-T�tulo de Cart�o de Cr�dito n�o aceita instru��es';
           56: Result := 'JB-T�tulo de Cart�o de Cr�dito inv�lido para o Produto';
           57: Result := 'JC-Produto somente para Cart�o de Cr�dito';
           58: Result := 'JH-CB Direta com opera��o de Desconto Autom�tico';
           59: Result := 'JI-Esp�cie de Documento incompat�vel para produto de Cart�o de Cr�dito';
           60: Result := 'JK-Produto n�o permite alterar Valor e Vencimento';
           61: Result := 'JQ-T�tulo em Correspondente � Altera��o n�o permitida ';
           62: Result := 'JS-T�tulo possui Desc/Abatim/Mora/Multa ';
           63: Result := 'JT-T�tulo possui Agenda ';
           64: Result := 'KC-T�tulo j� Sustado';
           65: Result := 'KD-Servi�o de Cobran�a n�o permitido para carteira';
           66: Result := 'KE-T�tulo possui caracteres n�o permitidos';
           67: Result := 'ZQ-Sem informa��o da Nota Fiscal Eletr�nica ';
           68: Result := 'ZR-Chave de Acesso NF Rejeitada ';
           69: Result := 'ZS-Chave de Acesso NF Duplicada ';
           70: Result := 'ZT-Quantidade NF excede a quantidade permitida (30) ';
           71: Result := 'ZU-Chave de Acesso NF inv�lida';
        else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
        end;
      end;

      toRetornoBaixaRejeitada :
      case CodMotivo of
         05: Result:= '05-Solicita��o de baixa para t�tulo j� baixado ou liquidado';
         06: Result:= '06-Solicita��o de baixa para t�tulo n�o registrado no sistema';
         08: Result:= '08-Solicita��o de baixa para t�tulo em float';
      else
         Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
      end;
      toRetornoInstrucaoRejeitada:
      case CodMotivo of
         04: Result := '04-Data de vencimento n�o num�rica ou inv�lida';
         05: Result := '05-Data de Vencimento inv�lida ou fora do prazo m�nimo s';
         14: Result := '14-Registro em duplicidade';
         19: Result := '19-Data de desconto inv�lida ou maior que a data de vencimento';
         20: Result := '20-Campo livre n�o informado';
         21: Result := '21-T�tulo n�o registrado no sistema';
         22: Result := '22-T�tulo baixado ou liquidado';
         26: Result := '26-Esp�cie de documento inv�lida ';
         27: Result := '27-Instru��o n�o aceita, por n�o ter sido emitida ordem de protesto ao cart�rio';
         28: Result := '28-T�tulo tem instru��o de cart�rio ativa';
         29: Result := '29-T�tulo n�o tem instru��o de carteira ativa';
         36: Result := '36-Valor de perman�ncia (mora) n�o num�rico';
         37: Result := '37-T�tulo Descontado � Instru��o n�o permitida para a carteira';
         38: Result := '38-Valor do abatimento n�o num�rico ou maior que a soma do valor do t�tulo + perman�ncia + multa';
         39: Result := '39-T�tulo em cart�rio';
         40: Result := '40-Instru��o recusada � Reprovado no Represamento para An�lise';
         44: Result := '44-T�tulo zerado ou em branco; ou n�o num�rico na remessa';
         51: Result := '51-Tipo/N�mero de Inscri��o Sacador/Avalista Inv�lido';
         53: Result := '53-Prazo de vencimento do t�tulo excede ao da contrata��o';
         57: Result := '57-Remessa contendo duas instru��es incompat�veis � n�o protestar e dias de protesto ou prazo para protesto inv�lido.';
         99: Result := '99-Ocorr�ncia desconhecida na remessa.';
      else
         case AnsiIndexStr(IntToStr(CodMotivo),
                           ['AA', 'AB', 'AE', 'AI', 'AJ', 'AL', 'AU', 'AV', 'AX', 'BC',
                            'BD', 'BE', 'BF', 'BG', 'BH', 'CC', 'CD', 'CE', 'CF', 'CG',
                            'CH', 'CJ', 'CK', 'CS', 'DA', 'DB', 'DC', 'DD', 'DE', 'DG',
                            'DH', 'DI', 'DJ', 'DM', 'DN', 'DP', 'DT', 'EB', 'G1', 'G2',
                            'G3', 'G4', 'HA', 'HB', 'HC', 'HD', 'HF', 'HG', 'HH', 'HI',
                            'HJ', 'HK', 'HL', 'HM', 'HN', 'IX', 'JB', 'JC', 'JH', 'JI',
                            'JK', 'JK', 'JS', 'JT', 'KC', 'KD', 'KE', 'ZQ', 'ZR', 'ZS',
                            'ZT', 'ZU']) of
           00: Result := 'AA-Servi�o de cobran�a inv�lido';
           01: Result := 'AE-T�tulo n�o possui abatimento ';
           02: Result := 'AG-Movimento n�o permitido � T�tulo � vista ou contra apresenta��o';
           03: Result := 'AH-Cancelamento de valores inv�lidos';
           04: Result := 'AI-Nossa carteira inv�lida';
           05: Result := 'AK-T�tulo pertence a outro cliente';
           06: Result := 'AU-Data da ocorr�ncia inv�lida';
           07: Result := 'AY-T�tulo deve estar em aberto e vencido para acatar protesto';
           08: Result := 'BA-Banco Correspondente Recebedor n�o � o Cobrador Atual';
           09: Result := 'BB-T�tulo deve estar em cart�rio para baixar';
           10: Result := 'CB-T�tulo possui protesto efetivado/a efetivar hoje';
           11: Result := 'CT-T�tulo j� baixado';
           12: Result := 'CW-T�tulo j� transferido';
           13: Result := 'DO-T�tulo em Preju�zo';
           14: Result := 'IX-T�tulo de Cart�o de Cr�dito n�o aceita instru��es';
           15: Result := 'JK-Produto n�o permite altera��o de valor de t�tulo';
           16: Result := 'JQ-T�tulo em Correspondente � N�o alterar Valor';
           17: Result := 'JS-T�tulo possui Descontos/Abto/Mora/Multa';
           18: Result := 'JT-T�tulo possui Agenda de Protesto/Devolu��o';
         else
           Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
         end;
      end;
   else
      Result:= IntToStrZero(CodMotivo,2) +' - Outros Motivos';
   end;
end;

end.



