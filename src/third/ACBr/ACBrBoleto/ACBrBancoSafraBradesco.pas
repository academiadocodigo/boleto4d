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

unit ACBrBancoSafraBradesco;

interface

uses
  Classes, SysUtils,
  ACBrBoleto, ACBrBoletoConversao;

type
  TACBrBancoSafraBradesco = class(TACBrBancoClass)
  private
  protected
    FNumeroRemessa: Integer;
  public
    constructor Create(AOwner: TACBrBanco);
    function CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo): String; override;
    function MontarCodigoBarras(const ACBrTitulo: TACBrTitulo): String; override;
    function MontarCampoNossoNumero(const ACBrTitulo: TACBrTitulo): String; override;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String; override;
    procedure GerarRegistroHeader400(NumeroRemessa: Integer; ARemessa: TStringList); override;
    procedure GerarRegistroTransacao400(ACBrTitulo: TACBrTitulo; ARemessa: TStringList); override;
    procedure GerarRegistroTrailler400(ARemessa: TStringList); override;
    procedure LerRetorno400(ARetorno: TStringList); override;

    function TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String; override;
    function CodOcorrenciaToTipo(const CodOcorrencia: Integer): TACBrTipoOcorrencia; override;
    function TipoOCorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia): String; override;
    function CodMotivoRejeicaoToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia; CodMotivo: Integer): String; override;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia; override;
  end;

implementation

uses
  {$IFDEF COMPILER6_UP} DateUtils {$ELSE} ACBrD5 {$ENDIF},
  StrUtils,
  ACBrUtil;

var
  aTotal: Extended;
  aCount: Integer;

{ TACBrBancoSafraBradesco }

constructor TACBrBancoSafraBradesco.Create(AOwner: TACBrBanco);
begin
  inherited Create(AOwner);

  fpDigito                := 2;
  fpNome                  := 'Banco Safra';
  fpNumero                := 237;
  fpTamanhoMaximoNossoNum := 9;
  fpTamanhoAgencia        := 4;
  fpTamanhoConta          := 7;
  fpTamanhoCarteira       := 2;
  fpNumeroCorrespondente  := 422;
end;

function TACBrBancoSafraBradesco.CalcularDigitoVerificador(const ACBrTitulo: TACBrTitulo): String;
begin
  Modulo.CalculoPadrao;
  Modulo.MultiplicadorFinal := 7;
  Modulo.Documento := ACBrTitulo.Carteira + FormatDateTime('YY', Date) + ACBrTitulo.NossoNumero;
  Modulo.Calcular;

  if Modulo.ModuloFinal = 1 then
    Result := 'P'
  else
    Result := IntToStr(Modulo.DigitoFinal);
end;

function TACBrBancoSafraBradesco.MontarCodigoBarras(const ACBrTitulo: TACBrTitulo): String;
var
  CodigoBarras, FatorVencimento, DigitoCodBarras: String;
begin
  with ACBrTitulo.ACBrBoleto do
  begin
    FatorVencimento := CalcularFatorVencimento(ACBrTitulo.Vencimento);

    CodigoBarras :=
      IntToStr(Numero) + '9' + FatorVencimento +
      IntToStrZero(Round(ACBrTitulo.ValorDocumento * 100), 10) +
      PadLeft(OnlyNumber(Cedente.Agencia), 4, '0') +
      ACBrTitulo.Carteira +
      FormatDateTime('YY', Date) +
      ACBrTitulo.NossoNumero +
      PadLeft(RightStr(Cedente.Conta, 7), 7, '0') + '0';

    DigitoCodBarras := CalcularDigitoCodigoBarras(CodigoBarras);
  end;

  Result := IntToStr(Numero) + '9' + DigitoCodBarras + Copy(CodigoBarras, 5, 39);
end;

function TACBrBancoSafraBradesco.MontarCampoNossoNumero(const ACBrTitulo: TACBrTitulo): String;
begin
  Result:= ACBrTitulo.Carteira + '/' + FormatDateTime('YY', Date) + ' ' +
           ACBrTitulo.NossoNumero + '-' + CalcularDigitoVerificador(ACBrTitulo);
end;

function TACBrBancoSafraBradesco.MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String;
begin
  Result :=
    ACBrTitulo.ACBrBoleto.Cedente.Agencia + '-' +
    ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito + '/' +
    ACBrTitulo.ACBrBoleto.Cedente.Conta + '-' +
    ACBrTitulo.ACBrBoleto.Cedente.ContaDigito;
end;

procedure TACBrBancoSafraBradesco.GerarRegistroHeader400(NumeroRemessa: Integer; ARemessa: TStringList);
var
  wLinha: String;
begin
  aTotal := 0;
  aCount := 0;
  FNumeroRemessa := NumeroRemessa;

  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    wLinha :=
      '0' +                             // {001-001} C�digo do registro: 0 - Header
      '1' +                             // {002-002} C�digo do arquivo: 1 - Remessa
      'REMESSA' +                       // {003-009} Identifica��o do arquivo
      '01' +                            // {010-011} C�digo do servi�o
      'COBRANCA' +                      // {012-019} Identifica��o do servi�o
      Space(7) +                        // {020-026} Brancos
      PadLeft(CodigoCedente, 14, '0') + // {027-040} C�digo da empresa no banco
      Space(6) +                        // {041-046} Brancos
      PadRight(Nome, 30) +              // {047-076} Nome da empresa
      '422' +                           // {077-079} C�digo do banco: 422 = Banco Safra
      PadRight('BANCO SAFRA', 11) +     // {080-090} Nome do banco
      Space(4) +                        // {091-094} Brancos
      FormatDateTime('ddmmyy', Now) +   // {095-100} Data de grava��o
      Space(291) +                      // {101-391} Brancos
      IntToStrZero(FNumeroRemessa, 3) + // {392-394} N�mero sequencial da remessa
      IntToStrZero(1, 6);               // {395-400} N�mero sequencial do registro

    ARemessa.Text:= ARemessa.Text + UpperCase(wLinha);
  end;
end;

procedure TACBrBancoSafraBradesco.GerarRegistroTransacao400(ACBrTitulo: TACBrTitulo; ARemessa: TStringList);
var
  ATipoOcorrencia, AEspecieDoc: String;
  DiasProtesto, TipoSacado, ATipoAceite, ACaracTitulo: String;
  wLinha: String;
begin
  with ACBrTitulo do
  begin
    case OcorrenciaOriginal.Tipo of
      toRemessaBaixar                   : ATipoOcorrencia := '02'; // Pedido de baixa
      toRemessaConcederAbatimento       : ATipoOcorrencia := '04'; // Concess�o de abatimento
      toRemessaCancelarAbatimento       : ATipoOcorrencia := '05'; // Cancelamento de abatimento concedido
      toRemessaAlterarVencimento        : ATipoOcorrencia := '06'; // Altera��o de vencimento
      toRemessaAlterarUsoEmpresa        : ATipoOcorrencia := '07'; // Altera��o "Uso Exclusivo do Cliente"
      toRemessaAlterarSeuNumero         : ATipoOcorrencia := '08'; // Altera��o de "Seu N�mero"
      toRemessaProtestar                : ATipoOcorrencia := '09'; // Pedido de protesto
      toRemessaNaoProtestar             : ATipoOcorrencia := '10'; // N�o protestar
      toRemessaDispensarJuros           : ATipoOcorrencia := '11'; // N�o cobrar juros de mora
      toRemessaCobrarJurosMora          : ATipoOcorrencia := '16'; // Cobrar juros de mora
      toRemessaAlterarValorTitulo       : ATipoOcorrencia := '31'; // Alteracao do valor do titulo

    else
      ATipoOcorrencia := '01'; // Remessa
    end;

    // Definindo a esp�cie do t�tulo.
    if AnsiSameText(EspecieDoc, 'DM') then
      AEspecieDoc := '01'
    else
    if AnsiSameText(EspecieDoc, 'NP') then
      AEspecieDoc := '02'
    else
    if AnsiSameText(EspecieDoc, 'NS') then
      AEspecieDoc := '03'
    else
    if AnsiSameText(EspecieDoc, 'RC') then
      AEspecieDoc := '05'
    else
    if AnsiSameText(EspecieDoc, 'DS') then
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

    // Definindo o aceite do t�tulo.
    case Aceite of
      atSim: ATipoAceite := 'A';
      atNao: ATipoAceite := 'N';
    end;

    case CaracTitulo of
      tcSimples:    ACaracTitulo := '1';
      tcVinculada:  ACaracTitulo := '2';
    end;

    with ACBrBoleto do
    begin
      wLinha :=
        '1' +                                                        // {001-001} C�digo do registro: 1 - Transa��o
        TipoSacado +                                                 // {002-003} Tipo de inscri��o da empresa: 01 = CPF; 02 = CNPJ
        PadLeft(OnlyNumber(Cedente.CNPJCPF), 14, '0') +              // {004-017} N�mero de inscri��o
        PadLeft(Cedente.CodigoCedente, 14, '0') +                    // {018-031} C�digo da empresa no banco
        Space(6) +                                                   // {032-037} Brancos
        Space(25) +                                                  // {038-062} Uso exclusivo da empresa
        NossoNumero +                                                // {063-071} Nosso n�mero (j� contendo o d�gito do nosso n�mero)
        Space(30) +                                                  // {072-101} Brancos
        '0' +                                                        // {102-102} C�digo IOF: 0 = Isento; 1 = 2%
        '00' +                                                       // {103-104} C�digo da moeda: 00 = Real
        Space(1) +                                                   // {105-105} Brancos
        IfThen(AnsiSameText(Instrucao2, '10'), DiasProtesto, '00') + // {106-107} Instru��o 3: N�mero de dias para protesto.
        ACaracTitulo +                                               // {108-108} C�digo da carteira - Tipo : 1 - COBRAN�A SIMPLES / 2 - COBRAN�A VINCULADA
        ATipoOcorrencia +                                            // {109-110} C�digo da ocorr�ncia
        PadRight(SeuNumero, 10, ' ') +                               // {111-120} Identifica��o do t�tulo na empresa
        FormatDateTime('ddmmyy', Vencimento) +                       // {121-126} Data de vencimento do t�tulo
        IntToStrZero(Round(ValorDocumento * 100), 13) +              // {127-139} Valor nominal do t�tulo
        '237' +                                                      // {140-142} Banco encarregado da cobran�a: "422" Ou �341� Ou �237�
        PadRight(Cedente.Agencia + Cedente.AgenciaDigito, 5, '0') +  // {143-147} Ag�ncia encarregada da cobran�a
        AEspecieDoc +                                                // {148-149} Esp�cie do t�tulo
        ATipoAceite +                                                // {150-150} Identifica��o de aceite do t�tulo: A = Aceito; N = N�o aceito
        FormatDateTime('ddmmyy', DataDocumento) +                    // {151-156} Data de emiss�o do t�tulo
        PadLeft(Instrucao1, 2, '0') +                                // {157-158} Primeira instru��o de cobran�a
        PadLeft(Instrucao2, 2, '0') +                                // {159-160} Segunda instru��o de cobran�a
        IntToStrZero(Round(ValorMoraJuros * 100), 13) +              // {161-173} Juros de mora por dia de atraso
        IfThen(DataDesconto > 0,
          FormatDateTime('ddmmyy', DataDesconto), '000000') +        // {174-179} Data limite para desconto
        IntToStrZero(Round(ValorDesconto * 100), 13) +               // {180-192} Valor do desconto
        StringOfChar('0', 13) +                                      // {193-205} Valor do IOF
        IfThen(DataMulta > 0,
          FormatDateTime('DDMMYY', DataMulta), '000000') +           // {206-211} Data da multa
        IntToStrZero(Round(PercentualMulta * 100), 4)        +       // {212-215} % Multa
        IntToStrZero(Round(ValorAbatimento * 100), 3)        +       // {216-218} Valor do abatimento concedido ou cancelado / multa
        TipoSacado +                                                 // {219-220} Tipo de inscri��o do sacado
        PadLeft(OnlyNumber(Sacado.CNPJCPF), 14, '0') +               // {221-234} N�mero de inscri��o do sacado
        PadRight(Sacado.NomeSacado, 40, ' ') +                       // {235-274} Nome do sacado
        PadRight(Sacado.Logradouro + ' ' + Sacado.Numero, 40, ' ') + // {275-314} Endere�o do sacado
        PadRight(Sacado.Bairro, 10, ' ') +                           // {315-324} Bairro do sacado
        Space(2) +                                                   // {325-326} Brancos
        PadRight(OnlyNumber(Sacado.CEP), 8, '0') +                   // {327-334} CEP do sacado
        PadRight(Sacado.Cidade, 15, ' ') +                           // {335-349} Cidade do sacado
        PadRight(Sacado.UF, 2, ' ') +                                // {350-351} UF do sacado
        PadRight(Sacado.SacadoAvalista.NomeAvalista,30) +            // {352-381} Nome do sacador avalista
        Space(7) +                                                   // {382-388} Brancos
        '422' +                                                      // {389-391} Banco emitente do boleto: 422 = Banco Safra
        IntToStrZero(FNumeroRemessa, 3);                             // {392-394} N�mero sequencial da remessa

      wLinha := wLinha + IntToStrZero(ARemessa.Count + 1, 6);        // {395-400} N�mero sequencial do registro
      aTotal := aTotal + ValorDocumento;
      Inc(aCount);

      ARemessa.Text := ARemessa.Text + UpperCase(wLinha);
    end;
  end;
end;

procedure TACBrBancoSafraBradesco.GerarRegistroTrailler400(ARemessa: TStringList);
var
  wLinha: String;
begin
  wLinha :=
    '9' +                                         // {001-001} C�digo do registro: 9 - Trailler
    Space(367) +                                  // {002-368} Brancos
    PadLeft(IntToStr(aCount), 8, '0')           + // {369-376} Quantidade de t�tulos no arquivo
    FormatCurr('000000000000000', aTotal * 100) + // {377-391} Valor total dos t�tulos
    IntToStrZero(FNumeroRemessa, 3)             + // {392-394} N�mero sequencial da remessa
    IntToStrZero(ARemessa.Count + 1, 6);          // {395-400} N�mero sequencial do registro

  ARemessa.Text := ARemessa.Text + UpperCase(wLinha);
end;

procedure TACBrBancoSafraBradesco.LerRetorno400(ARetorno: TStringList);
var
  Titulo: TACBrTitulo;
  ContLinha: Integer;
  CodMotivo: Integer;
  rAgencia: String;
  rConta, rDigitoConta: String;
  Linha, rCedente, rCNPJCPF: String;
  rCodEmpresa: String;
begin
  if StrToIntDef(Copy(ARetorno.Strings[0], 77, 3), -1) <> NumeroCorrespondente then
    raise Exception.Create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
      ' n�o � um arquivo de retorno do ' + Nome));

  rCodEmpresa  := Trim(Copy(ARetorno[0], 27, 14));
  rCedente     := Trim(Copy(ARetorno[0], 47, 30));
  rAgencia     := Trim(Copy(ARetorno[0], 27, ACBrBanco.TamanhoAgencia));
  rConta       := Trim(Copy(ARetorno[0], 32, ACBrBanco.TamanhoConta));
  rDigitoConta := Trim(Copy(ARetorno[0], 40, 1));

  ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0], 392, 3), 0);

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

  ValidarDadosRetorno(rAgencia, rConta);
  with ACBrBanco.ACBrBoleto do
  begin
    if (not LeCedenteRetorno) and (rCodEmpresa <> PadLeft(Cedente.CodigoCedente, 14, '0')) then
      raise Exception.Create(ACBrStr('C�digo da Empresa do arquivo inv�lido.'));

    case StrToIntDef(Copy(ARetorno[1], 2, 2), 0) of
      1: Cedente.TipoInscricao := pFisica;
      2: Cedente.TipoInscricao := pJuridica;
    else
      Cedente.TipoInscricao := pJuridica;
    end;

    if LeCedenteRetorno then
    begin
      Cedente.CNPJCPF       := rCNPJCPF;
      Cedente.CodigoCedente := rCodEmpresa;
      Cedente.Nome          := rCedente;
      Cedente.Agencia       := rAgencia;
      Cedente.Conta         := rConta;
      Cedente.ContaDigito   := rDigitoConta;
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
      CodMotivo               := StrToIntDef(Copy(Linha, 105, 3), 0);

      if CodMotivo > 0 then
      begin
        MotivoRejeicaoComando.Add(Copy(Linha, 105, 3));
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
      ValorOutrosCreditos  := StrToFloatDef(Copy(Linha, 280, 13), 0) / 100;
      ValorRecebido        := StrToFloatDef(Copy(Linha, 254, 13), 0) / 100;
      NossoNumero          := Copy(Linha, 63, 9);
      Carteira             := Copy(Linha, 108, 1);
      ValorDespesaCobranca := StrToFloatDef(Copy(Linha, 176, 13), 0) / 100;
      ValorOutrasDespesas  := StrToFloatDef(Copy(Linha, 189, 13), 0) / 100;

      if StrToIntDef(Copy(Linha, 296, 6), 0) <> 0 then
        DataCredito :=
          StringToDateTimeDef(
            Copy(Linha, 296, 2) + '/' +
            Copy(Linha, 298, 2) + '/' +
            Copy(Linha, 300, 2), 0, 'dd/mm/yy');
    end;
  end;
end;

function TACBrBancoSafraBradesco.TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String;
var
  CodOcorrencia: Integer;
begin
  CodOcorrencia := StrToIntDef(TipoOCorrenciaToCod(TipoOcorrencia), 0);

  case CodOcorrencia of
    02: Result := '02-Entrada Confirmada';
    03: Result := '03-Entrada Rejeitada';
    04: Result := '04-Transferencia de Carteira (Entrada)';
    05: Result := '05-Transferencia de Carteira (Baixa)';
    06: Result := '06-Liquidacao Normal';
    07: Result := '07-Liquidacao Parcial';
    09: Result := '09-Baixado Automaticamente';
    10: Result := '10-Baixado Conforme Instrucoes';
    11: Result := '11-Titulos em Ser (Para Arquivo Mensal)';
    12: Result := '12-Abatimento Concedido';
    13: Result := '13-Abatimento Cancelado';
    14: Result := '14-Vencimento Alterado';
    15: Result := '15-Liquidacao em Cartorio';
    16: Result := '16-Baixado por Entrega Franco de Pagamento';
    17: Result := '17-Entrada por Bordero Manual';
    18: Result := '18-Alteracao de Uso do Cedente';
    19: Result := '19-Confirmacao de Instrucao de Protesto';
    20: Result := '20-Confirmacao de Instrucao de Sustacao de Protesto';
    21: Result := '21-Transferencia de Cedente';
    23: Result := '23-Titulo Enviado a Cartorio';
    40: Result := '40-Baixa de Titulo Protestado';
    41: Result := '41-Liquidacao de Titulo Baixado';
    42: Result := '42-Titulo Retirado do Cartorio';
    43: Result := '43-Despesa de Cartorio';
    44: Result := '44-Aceite do Titulo DDA pelo Sacado';
    45: Result := '45-Nao Aceite do Titulo DDA pelo Sacado';
    51: Result := '51-Valor do Titulo Alterado';
    52: Result := '52-Acerto de Data de Emissao';
    53: Result := '53-Acerto de Cod. Especie Docto';
    54: Result := '54-Alteracao de Seu Numero';
    60: Result := '60-Equalizacao Vendor';
    77: Result := '77-Alt. Instr. Cobr. - Juros;';
  end;
end;

function TACBrBancoSafraBradesco.CodOcorrenciaToTipo(const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02: Result := toRetornoRegistroConfirmado;
    03: Result := toRetornoRegistroRecusado;
    06: Result := toRetornoLiquidado;
    07: Result := toRetornoLiquidadoParcialmente;
    09: Result := toRetornoBaixaAutomatica;
    10: Result := toRetornoBaixadoInstAgencia;
    11: Result := toRetornoTituloEmSer;
    12: Result := toRetornoAbatimentoConcedido;
    13: Result := toRetornoAbatimentoCancelado;
    14: Result := toRetornoVencimentoAlterado;
    15: Result := toRetornoLiquidadoEmCartorio;
    16: Result := toRetornoBaixadoFrancoPagamento;
    19: Result := toRetornoRecebimentoInstrucaoProtestar;
    20: Result := toRetornoRecebimentoInstrucaoSustarProtesto;
    23: Result := toRetornoEncaminhadoACartorio;
    40: Result := toRetornoBaixaPorProtesto;
    41: Result := toRetornoLiquidadoAposBaixaOuNaoRegistro;
    42: Result := toRetornoRetiradoDeCartorio;
    43: Result := toRetornoDespesasProtesto;
  else
    Result := toRetornoOutrasOcorrencias;
  end;
end;

function TACBrBancoSafraBradesco.CodOcorrenciaToTipoRemessa(const CodOcorrencia: Integer): TACBrTipoOcorrencia;
begin
  case CodOcorrencia of
    02 : Result:= toRemessaBaixar;                          {Pedido de Baixa}
    04 : Result:= toRemessaConcederAbatimento;              {Concess�o de Abatimento}
    05 : Result:= toRemessaCancelarAbatimento;              {Cancelamento de Abatimento concedido}
    06 : Result:= toRemessaAlterarVencimento;               {Altera��o de vencimento}
    07 : Result:= toRemessaAlterarUsoEmpresa;               {Altera��o "Uso Exclusivo do Cliente"}
    08 : Result:= toRemessaAlterarSeuNumero;                {Altera��o de "Seu N�mero"}
    09 : Result:= toRemessaProtestar;                       {Pedido de protesto}
    10 : Result:= toRemessaNaoProtestar;                    {N�o Protestar}
    11 : Result:= toRemessaDispensarJuros;                  {N�o Cobrar Juros de Mora}
  else
     Result:= toRemessaRegistrar;                           {Remessa}
  end;
end;

function TACBrBancoSafraBradesco.TipoOcorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia): String;
begin
  case TipoOcorrencia of
    toRetornoRegistroConfirmado                : Result := '02';
    toRetornoRegistroRecusado                  : Result := '03';
    toRetornoLiquidado                         : Result := '06';
    toRetornoLiquidadoParcialmente             : Result := '07';
    toRetornoBaixaAutomatica                   : Result := '09';
    toRetornoBaixadoInstAgencia                : Result := '10';
    toRetornoTituloEmSer                       : Result := '11';
    toRetornoAbatimentoConcedido               : Result := '12';
    toRetornoAbatimentoCancelado               : Result := '13';
    toRetornoVencimentoAlterado                : Result := '14';
    toRetornoLiquidadoEmCartorio               : Result := '15';
    toRetornoBaixadoFrancoPagamento            : Result := '16';
    toRetornoRecebimentoInstrucaoProtestar     : Result := '19';
    toRetornoRecebimentoInstrucaoSustarProtesto: Result := '20';
    toRetornoEncaminhadoACartorio              : Result := '23';
    toRetornoBaixaPorProtesto                  : Result := '40';
    toRetornoLiquidadoAposBaixaOuNaoRegistro   : Result := '41';
    toRetornoRetiradoDeCartorio                : Result := '42';
    toRetornoDespesasProtesto                  : Result := '43';
  else
    Result := '02';
  end;
end;

function TACBrBancoSafraBradesco.CodMotivoRejeicaoToDescricao(
  const TipoOcorrencia: TACBrTipoOcorrencia; CodMotivo: Integer): String;
begin
  case CodMotivo of
    001: Result := '001-Moeda Invalida';
    002: Result := '002-Moeda Invalida Para Carteira';
    003: Result := '003-Carteira Tres Invalida Para Tipo de Moeda';
    004: Result := '004-Tipo de IOF Invalido Para Cobranca de Seguros';
    005: Result := '005-Tipo de IOF Invalido Para Valor de IOF (Seguros)';
    006: Result := '006-Valor de IOF Invalido (Seguros)';
    007: Result := '007-CEP Nao Corresponde UF';
    008: Result := '008-Valor Juros ao Dia Maior que 5% do Valor do Titulo';
    010: Result := '010-Seu Numero - Nao Numerico Para Cheque';
    009: Result := '009-Uso Exclusivo Nao Numerico Para Cobranca Express';
    011: Result := '011-Nosso Numero Fora da Faixa';
    012: Result := '012-CEP de Cidade Inexistente';
    013: Result := '013-CEP Fora de Faixa da Cidade';
    014: Result := '014-UF Invalida Para CEP da Cidade';
    015: Result := '015-CEP Zerado';
    016: Result := '016-CEP Nao Consta na Tabela Safra';
    017: Result := '017-CEP Nao Consta na Tabela Banco Correspondente';
    018: Result := '018-Dados do Cheque Nao Numerico';
    019: Result := '019-Protesto Impraticavel';
    020: Result := '020-Primeira Instrucao de Cobranca Invalida';
    021: Result := '021-Segunda Instrucao de Cobranca Invalida';
    022: Result := '022-Segunda Instr. (10) e Terceira Instr. Invalida';
    023: Result := '023-Terceira Instrucao de Cobranca Invalida';
    024: Result := '024-Digito Verificador C1 Invalido';
    025: Result := '025-Digito Verificador C2 Invalido';
    026: Result := '026-Codigo de Operacao/Ocorrencia Invalido';
    027: Result := '027-Operacao Invalida Para o Cliente';
    028: Result := '028-Nosso Numero Nao Numerico ou Zerado';
    029: Result := '029-Nosso Numero Com Digito de Controle Errado';
    030: Result := '030-Valor do Abatimento Nao Numerico ou Zerado';
    031: Result := '031-Seu Numero em Branco';
    032: Result := '032-Codigo da Carteira Invalido';
    033: Result := '033-Digito Verificador C3 Invalido';
    034: Result := '034-Codigo do Titulo Invalido';
    035: Result := '035-Data de Movimento Invalida';
    036: Result := '036-Data de Emissao Invalida';
    037: Result := '037-Data de Vencimento Invalida';
    038: Result := '038-Depositaria Invalida';
    039: Result := '039-Depositaria Invalida Para o Cliente';
    040: Result := '040-Depositaria Nao Cadastrada no Banco';
    041: Result := '041-Codigo de Aceite Invalido';
    042: Result := '042-Especie de Titulo Invalido';
    043: Result := '043-Instrucao de Cobranca Invalida';
    044: Result := '044-Valor do Titulo Nao Numerico ou Zerado';
    045: Result := '045-Data de Operacao Invalida';
    046: Result := '046-Valor de Juros Nao Numerico ou Zerado';
    047: Result := '047-Data Limite Para Desconto Invalida';
    048: Result := '048-Valor do Desconto Invalido';
    049: Result := '049-Valor IOF Nao Numerico ou Zerado (Seguros)';
    050: Result := '050-Abatimento Com Valor Para Operacao "01" (Entrada de T�tulo)';
    051: Result := '051-Codigo de Inscricao do Sacado Invalido';
    052: Result := '052-Codigo de Inscricao / Numero de Inscricao do Sacado Invalido';
    053: Result := '053-Numero de Inscricao do Sacado Nao Numerico ou Digito Errado';
    054: Result := '054-Nome do Sacado em Branco';
    055: Result := '055-Endereco do Sacado em Branco';
    056: Result := '056-Cliente Nao Recadastrado';
    057: Result := '057-Cliente Bloqueado (Quando Operacao de Desconto e Cliente Sem Numero de Bordero Disponivel)';
    058: Result := '058-Processo de Cartorio Invalido';
    059: Result := '059-Estado do Sacado Invalido';
    060: Result := '060-CEP / Endereco Divergem do Correio';
    061: Result := '061-Instrucao Agendada Para Agencia';
    062: Result := '062-Operacao Invalida Para a Carteira';
    063: Result := '063-Carteira Invalida Para Cobranca Direta';
    064: Result := '064-Titulo Inexistente (TFC)';
    065: Result := '065-Operacao / Titulo Ja Existente';
    066: Result := '066-Titulo Ja Existe (TFC)';
    067: Result := '067-Data de Vencimento Invalida Para Protesto';
    068: Result := '068-CEP do Sacado Nao Consta na Tabela';
    069: Result := '069-Praca Nao Atendida Pelo Servico Cartorio';
    070: Result := '070-Agencia Invalida';
    071: Result := '071-Cliente Nao Cadastrado';
    072: Result := '072-Titulo Ja Existe (COB)';
    073: Result := '073-Taxa Operacao Nao Numerica ou Zerada (VENDOR)';
    074: Result := '074-Titulo Fora de Sequencia';
    075: Result := '075-Taxa de Operacao Zerada (VENDOR)';
    076: Result := '076-Equalizacao Nao Numerica ou Invalida (VENDOR)';
    077: Result := '077-Taxa Negociada Nao Numerica ou Zerada (VENDOR)';
    078: Result := '078-Titulo Inexistente (COB)';
    079: Result := '079-Operacao Nao Concluida';
    080: Result := '080-Titulo Ja Baixado';
    081: Result := '081-Titulo Nao Descontado';
    082: Result := '082-Intervalo Entre Data de Operacao e Data Vcto Menor Que Um Dia';
    083: Result := '083-Prorrogacao / Alteracao de Vencimento Invalida';
    084: Result := '084-Movimento Igual ao Cadastro de Existencia do Cob';
    085: Result := '085-Codigo Operacao Com PCB Invalido (Operacao Invalida Para Carteira)';
    086: Result := '086-Abatimento Maior Que Valor do Titulo';
    087: Result := '087-Alteracao de Cartorio Invalida';
    088: Result := '088-Titulo Recusado Como Garantia (Sacado / Novo / Exclusivo Alcada Comite)';
    089: Result := '089-Alteracao de Data de Protesto Invalida';
    090: Result := '090-Modalidade de Vendor Invalido';
    091: Result := '091-PCB Cto Invalida';
    092: Result := '092-Data de Operacao Cto Invalida';
    093: Result := '093-Baixa de Titulo de Outra Agencia';
    094: Result := '094-Entrada Titulo Cobranca Direta Invalida';
    095: Result := '095-Baixa Titulo Cobranca Direta Invalida';
    096: Result := '096-Valor do Titulo Invalido';
    097: Result := '097-Moeda Invalida Para Banco Correspondente';
    098: Result := '098-PCB do TFC Divergem da PCB do COB';
    099: Result := '099-Inclusao de Terceira Moeda Invalida';
    115: Result := '115-Especie Doc Invalido Para Modal/Ramo de Atividade (Reservador Cto)';
  else
    Result := IntToStrZero(CodMotivo, 3) + ' - Outros Motivos';
  end;
end;

end.
