{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
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

unit ACBrDFeUtil;

interface

uses
  Classes, StrUtils, SysUtils, synacode, synautil,
  {IniFiles,} ACBrDFeSSL, ACBrIBGE, pcnAuxiliar;

function FormatarNumeroDocumentoFiscal(AValue: String): String;
function FormatarNumeroDocumentoFiscalNFSe(AValue: String): String;

function GerarCodigoNumerico(numero: integer): integer;
function GerarCodigoDFe(AnDF: Integer): integer;

function GerarChaveAcesso(AUF: Integer; ADataEmissao: TDateTime; const ACNPJ:String;
                          ASerie, ANumero, AtpEmi, ACodigo: Integer; AModelo: Integer = 55): String;
function FormatarChaveAcesso(AValue: String): String;

function ValidaUFCidade(const UF, Cidade: integer): Boolean; overload;
procedure ValidaUFCidade(const UF, Cidade: integer; const AMensagem: String); overload;
function ValidaDIDSI(AValue: String): Boolean;
function ValidaDIRE(const AValue: String): Boolean;
function ValidaRE(const AValue: String): Boolean;
function ValidaDrawback(AValue: String): Boolean;
function ValidaSUFRAMA(AValue: String): Boolean;
function ValidaRECOPI(AValue: String): Boolean;
function ValidaNVE(const AValue: string): Boolean;

function XmlEstaAssinado(const AXML: String): Boolean;
function SignatureElement(const URI: String; AddX509Data: Boolean;
    const IdSignature: String = ''; const Digest: TSSLDgst = dgstSHA1): String;
function EncontrarURI(const AXML: String; docElement: String = ''; IdAttr: String = ''): String;
function ObterNomeMunicipio(const AxUF: String; const AcMun: Integer;
                              const APathArqMun: String): String;
function ObterCodigoMunicipio(const AxMun, AxUF, APathArqMun: String ): Integer;

function CalcularHashCSRT(const ACSRT, AChave: String): string;
function CalcularHashDados(const ADados: TStream; AChave: String): string;
function CalcularHashArquivo(const APathArquivo: String; AChave: String): string;

function ObterDFeXML(const AXML, Grupo, NameSpace: String): String;

var
  ACBrIBGE1: TACBrIBGE;

implementation

uses
  Variants, DateUtils,
  ACBrDFeException, ACBrUtil, ACBrValidador;

function FormatarNumeroDocumentoFiscal(AValue: String): String;
begin
  AValue := Poem_Zeros(AValue, 9);
  Result := copy(AValue, 1, 3) + '.' + copy(AValue, 4, 3) + '.' + copy(AValue, 7, 3);
end;

function FormatarNumeroDocumentoFiscalNFSe(AValue: String): String;
begin
  AValue := Poem_Zeros(AValue, 15);
  Result := copy(AValue, 1, 4) + '.' + copy(AValue, 5, 12);
end;

function ValidaUFCidade(const UF, Cidade: integer): Boolean;
begin
  Result := (Copy(IntToStr(UF), 1, 2) = Copy(IntToStr(Cidade), 1, 2));
end;

procedure ValidaUFCidade(const UF, Cidade: integer; const AMensagem: String);
begin
  if not (ValidaUFCidade(UF, Cidade)) then
    raise EACBrDFeException.Create(AMensagem);
end;

function GerarCodigoNumerico(numero: integer): integer;
var
  s: string;
  i, j, k: integer;
begin
  // Essa fun��o gera um c�digo numerico atrav�z de calculos realizados sobre o parametro numero
  s := intToStr(numero);
  for i := 1 to 9 do
    s := s + intToStr(numero);
  for i := 1 to 9 do
  begin
    k := 0;
    for j := 1 to 9 do
      k := k + StrToInt(s[j]) * (j + 1);
    s := IntToStr((k mod 11)) + s;
  end;
  Result := StrToInt(copy(s, 1, 8));
end;

function GerarCodigoDFe(AnDF: Integer): integer;
var
 ACodigo: Integer;
begin
  Repeat
    ACodigo := Random(99999999);
  Until ValidarCodigoDFe(ACodigo, AnDF);

  Result := ACodigo;
end;

function GerarChaveAcesso(AUF: Integer; ADataEmissao: TDateTime; const ACNPJ: String;
                          ASerie, ANumero, AtpEmi, ACodigo: Integer; AModelo: Integer): String;
var
  vUF, vDataEmissao, vSerie, vNumero, vCodigo, vModelo, vCNPJ, vtpEmi: String;
begin
  // Se o usuario informar 0 ou -1; o c�digo numerico sera gerado de maneira aleat�ria //
  if ACodigo = -1 then
    ACodigo := 0;

  if ACodigo = 0 then
    ACodigo := GerarCodigoDFe(ANumero);

  // Se o usuario informar um c�digo inferior ou igual a -2 a chave ser� gerada
  // com o c�digo igual a zero, mas poder� n�o ser autorizada pela SEFAZ.
  if ACodigo <= -2 then
    ACodigo := 0;

  vUF          := Poem_Zeros(AUF, 2);
  vDataEmissao := FormatDateTime('YYMM', ADataEmissao);
  vCNPJ        := PadLeft(OnlyNumber(ACNPJ), 14, '0');
  vModelo      := Poem_Zeros(AModelo, 2);
  vSerie       := Poem_Zeros(ASerie, 3);
  vNumero      := Poem_Zeros(ANumero, 9);
  vtpEmi       := Poem_Zeros(AtpEmi, 1);
  vCodigo      := Poem_Zeros(ACodigo, 8);

  Result := vUF + vDataEmissao + vCNPJ + vModelo + vSerie + vNumero + vtpEmi + vCodigo;
  Result := Result + Modulo11(Result);
end;

function FormatarChaveAcesso(AValue: String): String;
var
  I: Integer;
begin
  AValue := OnlyNumber(AValue);
  I := 1;
  Result := '';
  while I < Length(AValue) do
  begin
    Result := Result+copy(AValue,I,4)+' ';
    Inc( I, 4);
  end;

  Result := Trim(Result);
end;

function ValidaDIDSI(AValue: String): Boolean;
var
  ano: integer;
  sValue: String;
begin
  // AValue = TAANNNNNNND
  // Onde: T Identifica o tipo de documento ( 2 = DI e 4 = DSI )
  //       AA Ano corrente da gera��o do documento
  //       NNNNNNN N�mero sequencial dentro do Ano ( 7 ou 8 d�gitos )
  //       D D�gito Verificador, M�dulo 11, Pesos de 2 a 9
  AValue := OnlyNumber(AValue);
  ano := StrToInt(Copy(IntToStr(YearOf(Date)), 3, 2));

  if (length(AValue) < 11) or (length(AValue) > 12) then
    Result := False
  else if (copy(Avalue, 1, 1) <> '2') and (copy(Avalue, 1, 1) <> '4') then
    Result := False
  else if not ((StrToInt(copy(Avalue, 2, 2)) >= ano - 1) and
    (StrToInt(copy(Avalue, 2, 2)) <= ano + 1)) then
    Result := False
  else
  begin
    sValue := copy(AValue, 1, length(AValue) - 1);
    Result := copy(AValue, length(AValue), 1) = Modulo11(sValue);
  end;
end;

function ValidaDIRE(const AValue: String): Boolean;
var
  AnoData, AnoValue: integer;
begin
  // AValue = AANNNNNNNNNN
  // Onde: AA AnoData corrente da gera��o do documento
  //       NNNNNNNNNN N�mero sequencial dentro do AnoData ( 10 d�gitos )

  Result := StrIsNumber(AValue) and (Length(AValue) = 12);

  if Result then
  begin
    AnoData  := StrToInt(Copy(IntToStr(YearOf(Date)), 3, 2));
    AnoValue := StrToInt(Copy(AValue, 1, 2));

    Result := (AnoValue >= (AnoData - 1)) and (AnoValue <= (AnoData + 1));
  end;
end;

function ValidaRE(const AValue: String): Boolean;
var
  AnoData, AnoValue, SerieRE: integer;
begin
  // AValue = AANNNNNNNSSS
  // Onde: AA AnoData corrente da gera��o do documento
  //       NNNNNNN N�mero sequencial dentro do AnoData ( 7 d�gitos )
  //       SSS Serie do RE (001, 002, ...)

  if (AValue = '000000000000') or (AValue = '') then
  begin
    // Deve aceitar doze zeros, pois h� casos onde a RE � gerada somente depois
    // http://normas.receita.fazenda.gov.br/sijut2consulta/link.action?idAto=81446&visao=anotado
    // No link acima diz que o DUE substitui o RE.
    Result := True;
  end
  else
  begin
    Result := StrIsNumber(AValue) and (Length(AValue) = 12);

    if Result then
    begin
      AnoData  := StrToInt(Copy(IntToStr(YearOf(Date)), 3, 2));
      AnoValue := StrToInt(Copy(AValue,  1, 2));
      SerieRE  := StrToInt(Copy(AValue, 10, 3));

      Result := ((AnoValue >= (AnoData - 1)) and (AnoValue <= (AnoData + 1))) and
                ((SerieRE >= 1) and (SerieRE <= 999));
    end;
  end;
end;

function ValidaDrawback(AValue: String): Boolean;
var
  ano: integer;
begin
  // AValue = AAAANNNNNND
  // Onde: AAAA Ano corrente do registro
  //       NNNNNN N�mero sequencial dentro do Ano ( 6 d�gitos )
  //       D D�gito Verificador, M�dulo 11, Pesos de 2 a 9
  AValue := OnlyNumber(AValue);
  ano := StrToInt(Copy(IntToStr(YearOf(Date)), 3, 2));
  if length(AValue) = 11 then
    AValue := copy(AValue, 3, 9);

  if length(AValue) <> 9 then
    Result := False
  else if not ((StrToInt(copy(Avalue, 1, 2)) >= ano - 2) and
    (StrToInt(copy(Avalue, 1, 2)) <= ano + 2)) then
    Result := False
  else
    Result := copy(AValue, 9, 1) = Modulo11(copy(AValue, 1, 8));
end;

function ValidaSUFRAMA(AValue: String): Boolean;
var
  SS, LL: integer;
begin
  // AValue = SSNNNNLLD
  // Onde: SS C�digo do setor de atividade da empresa ( 01, 02, 10, 11, 20 e 60 )
  //       NNNN N�mero sequencial ( 4 d�gitos )
  //       LL C�digo da localidade da Unidade Administrativa da Suframa ( 01 = Manaus, 10 = Boa Vista e 30 = Porto Velho )
  //       D D�gito Verificador, M�dulo 11, Pesos de 2 a 9
  AValue := OnlyNumber(AValue);
  if length(AValue) < 9 then
    AValue := '0' + AValue;
  if length(AValue) <> 9 then
    Result := False
  else
  begin
    SS := StrToInt(copy(Avalue, 1, 2));
    LL := StrToInt(copy(Avalue, 7, 2));
    if not (SS in [01, 02, 10, 11, 20, 60]) then
      Result := False
    else if not (LL in [01, 10, 30]) then
      Result := False
    else
      Result := copy(AValue, 9, 1) = Modulo11(copy(AValue, 1, 8));
  end;
end;

function ValidaRECOPI(AValue: String): Boolean;
begin
  // AValue = aaaammddhhmmssffffDD
  // Onde: aaaammdd Ano/Mes/Dia da autoriza��o
  //       hhmmssffff Hora/Minuto/Segundo da autoriza��o com mais 4 digitos da fra��o de segundo
  //       DD D�gitos Verificadores, M�dulo 11, Pesos de 1 a 18 e de 1 a 19
  AValue := OnlyNumber(AValue);
  if length(AValue) <> 20 then
    Result := False
  else if copy(AValue, 19, 1) <> Modulo11(copy(AValue, 1, 18), 1, 18) then
    Result := False
  else
    Result := copy(AValue, 20, 1) = Modulo11(copy(AValue, 1, 19), 1, 19);
end;

function ValidaNVE(const AValue: string): Boolean;
begin
  //TODO: A NVE (Nomenclatura de Valor Aduaneiro e Estat�stica) � baseada no NCM,
  // mas formada de 2 letras (atributos) e 4 n�meros (especifica��es). Ex: AA0001
  Result := ( (Length(AValue) = 6) and ( CharIsAlpha(AValue[1]) and
                                         CharIsAlpha(AValue[2]) and
                                         CharIsNum(AValue[3])   and
                                         CharIsNum(AValue[4])   and
                                         CharIsNum(AValue[5])   and
                                         CharIsNum(AValue[6]) ));
end;

function XmlEstaAssinado(const AXML: String): Boolean;
begin
  Result := (pos('<signature', lowercase(AXML)) > 0);
end;

function SignatureElement(const URI: String; AddX509Data: Boolean;
  const IdSignature: String; const Digest: TSSLDgst): String;
var
  MethodAlgorithm, DigestAlgorithm: String;
begin
  case Digest of
    dgstSHA256:
      begin
        MethodAlgorithm := 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256';
        DigestAlgorithm := 'http://www.w3.org/2001/04/xmlenc#sha256';
      end;
    dgstSHA512:
      begin
        MethodAlgorithm := 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha512';
        DigestAlgorithm := 'http://www.w3.org/2001/04/xmlenc#sha512';
      end;
    else
      begin
        MethodAlgorithm := 'http://www.w3.org/2000/09/xmldsig#rsa-sha1';
        DigestAlgorithm := 'http://www.w3.org/2000/09/xmldsig#sha1';
      end;
  end;

  {(*}
  Result :=
  '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#"' + IdSignature + '>' +
    '<SignedInfo>' +
      '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />' +
      '<SignatureMethod Algorithm="'+MethodAlgorithm+'" />' +
      '<Reference URI="' + IfThen(URI = '', '', '#' + URI) + '">' +
        '<Transforms>' +
          '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />' +
          '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />' +
        '</Transforms>' +
        '<DigestMethod Algorithm="'+DigestAlgorithm+'" />' +
        '<DigestValue></DigestValue>' +
      '</Reference>' +
    '</SignedInfo>' +
    '<SignatureValue></SignatureValue>' +
    '<KeyInfo>' +
    IfThen(AddX509Data,
      '<X509Data>' +
        '<X509Certificate></X509Certificate>'+
      '</X509Data>',
      '')+
    '</KeyInfo>'+
  '</Signature>';
  {*)}
end;

function EncontrarURI(const AXML: String; docElement: String; IdAttr: String
  ): String;
var
  I, J: integer;
begin
  Result := '';
  if (IdAttr = '') then
    IdAttr := 'Id';

  if (docElement <> '') then
    I := Pos('<'+docElement, AXML)
  else
    I := 1;

  I := PosEx(IdAttr+'=', AXML, I);
  if I = 0 then       // XML n�o tem URI
    Exit;

  I := PosEx('"', AXML, I + 2);
  if I = 0 then
    raise EACBrDFeException.Create('N�o encontrei inicio do URI: aspas inicial');

  J := PosEx('"', AXML, I + 1);
  if J = 0 then
    raise EACBrDFeException.Create('N�o encontrei inicio do URI: aspas final');

  Result := copy(AXML, I + 1, J - I - 1);
end;

function GetACBrIBGE(const APathArqMun: String): TACBrIBGE;
var
  AfileName, PathArqMun: String;
begin
  if not Assigned(ACBrIBGE1) then
    ACBrIBGE1 := TACBrIBGE.Create(Nil);

  Result := ACBrIBGE1;
  AfileName := ExtractFileName(ACBrIBGE1.CacheArquivo);
  if (AfileName = '') then
    AfileName := 'ACBrIBGE.txt';

  if EstaVazio(APathArqMun) then
    PathArqMun := ApplicationPath
  else
    PathArqMun := APathArqMun;

  Result.CacheArquivo := PathWithDelim(PathArqMun) + AfileName ;
end;

function ObterNomeMunicipio(const AxUF: String; const AcMun: Integer;
  const APathArqMun: String): String;
begin
  result := '';
  if (GetACBrIBGE(APathArqMun) = Nil) then
    Exit;

  if (ACBrIBGE1.BuscarPorCodigo(AcMun) > 0) then
    Result := ACBrIBGE1.Cidades[0].Municipio;
end;

function ObterCodigoMunicipio(const AxMun, AxUF, APathArqMun: String): Integer;
begin
  result := 0;
  if (GetACBrIBGE(APathArqMun) = Nil) then
    Exit;

  if (ACBrIBGE1.BuscarPorNome(AxMun, AxUF) > 0) then
    Result := ACBrIBGE1.Cidades[0].CodMunicipio;
end;

function CalcularHashCSRT(const ACSRT, AChave: String): string;
begin
  Result := EncodeBase64(SHA1(ACSRT + AChave));
end;

function CalcularHashDados(const ADados: TStream; AChave: String): string;
var
  sAux: AnsiString;
begin
  if (ADados.Size = 0) then
    raise EACBrDFeException.Create('Dados n�o especificados');

  ADados.Position := 0;
  sAux := ReadStrFromStream(ADados, ADados.Size);
  sAux := EncodeBase64(sAux);

  Result := EncodeBase64(SHA1(AnsiString(AChave) + sAux));
end;

function CalcularHashArquivo(const APathArquivo: String; AChave: String
  ): string;
var
  FS: TFileStream;
begin
  if (APathArquivo = '') then
    raise EACBrDFeException.Create('Path Arquivo n�o especificados');

  if not FileExists(APathArquivo) then
    raise EACBrDFeException.Create('Arquivo:  '+APathArquivo+'n�o encontrado');

  FS := TFileStream.Create(APathArquivo, fmOpenRead);
  try
    Result := CalcularHashDados(FS, AChave);
  finally
    FS.Free;
  end;
end;

function ObterDFeXML(const AXML, Grupo, NameSpace: String): String;
var
  DeclaracaoXML: String;
begin
  DeclaracaoXML := ObtemDeclaracaoXML(AXML);

  Result := RetornarConteudoEntre(AXML, '<' + Grupo + ' xmlns', '</' + Grupo + '>');

  if not EstaVazio(Result) then
    Result := '<' + Grupo + ' xmlns' + Result + '</' + Grupo + '>'
  else
  begin
    Result := LerTagXML(AXML, Grupo);
    if not EstaVazio(Result) then
      Result := '<' + Grupo + ' xmlns="' + NameSpace +'">' +
                Result + '</' + Grupo + '>'
  end;

  if not EstaVazio(Result) then
    Result := DeclaracaoXML + Result;
end;

initialization
  Randomize;
  ACBrIBGE1 := Nil;

finalization;
  if Assigned(ACBrIBGE1) then
    FreeAndNil(ACBrIBGE1);

end.

