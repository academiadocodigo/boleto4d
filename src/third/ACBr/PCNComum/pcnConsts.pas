{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Italo Jurisato Junior                           }
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

{*******************************************************************************
|* Historico
|*
|* 17/08/2016: Italo Jurisato Junior
|*  - Criado uma Unit especifica para as constantes usadas pelos componentes
|*    que geram DF-e
*******************************************************************************}

{$I ACBr.inc}

unit pcnConsts;

interface

uses
  SysUtils;

const
  CODIGO_BRASIL = 1058;

  ERR_MSG_MAIOR = 'Tamanho maior que o m�ximo permitido';
  ERR_MSG_MENOR = 'Tamanho menor que o m�nimo permitido';
  ERR_MSG_VAZIO = 'Nenhum valor informado';
  ERR_MSG_INVALIDO = 'Conte�do inv�lido';
  ERR_MSG_MAXIMO_DECIMAIS = 'Numero m�ximo de casas decimais permitidas';
  ERR_MSG_MAIOR_MAXIMO = 'N�mero de ocorr�ncias maior que o m�ximo permitido - M�ximo ';
  ERR_MSG_GERAR_CHAVE = 'Erro ao gerar a chave da DFe!';
  ERR_MSG_FINAL_MENOR_INICIAL = 'O numero final n�o pode ser menor que o inicial';
  ERR_MSG_ARQUIVO_NAO_ENCONTRADO = 'Arquivo n�o encontrado';
  ERR_MSG_SOMENTE_UM = 'Somente um campo deve ser preenchido';
  ERR_MSG_MENOR_MINIMO = 'N�mero de ocorr�ncias menor que o m�nimo permitido - M�nimo ';

  XML_V01           = '?xml version="1.0"?';
  ENCODING_UTF8     = '?xml version="1.0" encoding="UTF-8"?';
  ENCODING_UTF8_STD = '?xml version="1.0" encoding="UTF-8" standalone="no"?';

  NAME_SPACE = 'xmlns="http://www.portalfiscal.inf.br/nfe"';

  DSC_CHAVE = 'Chave do DFe';
  DSC_ULTNSU = '�ltimo NSU recebido pela Empresa';
  DSC_NSU = 'NSU espec�fico';
  DSC_NNF = 'N�mero do Documento Fiscal';
  DSC_NATOP = 'Descri��o da Natureza da Opera��o';
  DSC_INDPAG = 'Indicador da forma de pagamento';
  DSC_TPIMP = 'Formato de Impress�o do Documento Auxiliar';
  DSC_TPEMIS = 'Forma de Emiss�o do DF-e';
  DSC_PROCEMI = 'Processo de emiss�o do DF-e';
  DSC_VERPROC = 'Vers�o do Processo de emiss�o do DF-e';
  DSC_DHCONT = 'Data e Hora de entrada em contingencia';
  DSC_XJUSTCONT = 'Justificativa de entrada em contingencia';
  DSC_IEST = 'Inscri��o Estadual do Substituto tribut�rio';
  DSC_XFANT = 'Nome de Fantasia';
  DSC_FONE = 'Telefone';
  DSC_EMAIL = 'Endere�o de Email';
  DSC_CMUN = 'C�digo do Munic�pio';
  DSC_CPAIS = 'C�digo do Pa�s';
  DSC_XPAIS = 'Nome do Pa�s';
  DSC_OBSCONT = 'Observa��es de interesse do contribuite';
  DSC_ISUF = 'Inscri��o na SUFRAMA';
  DSC_INFADFISCO = 'Informa��es adicionais de interesse do Fisco';
  DSC_PREDBC = 'Percentual da Redu��o de BC';
  DSC_VIR = 'Valor do IR';
  DSC_VINSS = 'Valor do INSS';
  DSC_VCSLL = 'Valor do CSLL';
  DSC_VNF = 'Valor Total do DF-e';
  DSC_VBCICMS = 'BC do ICMS';
  DSC_VBCST = 'Valor da BC do ICMS ST';
  DSC_VST = 'Valor TOTAL Icms substitui��o Tribut�ria';
  DSC_NLACRE = 'N�mero dos Lacres';
  DSC_REFNFE = 'Chave de acesso das NF-e referenciadas';
  DSC_TPNF = 'Tipo do Documento Fiscal';
  DSC_RENAVAM = 'RENAVAM';
  DSC_PLACA = 'Placa do Ve�culo';
  DSC_TPVEIC = 'Tipo de Ve�culo';
  DSC_VAFRMM = 'Valor da AFRMM';
  DSC_VFRETE = 'Valor Total do Frete';
  DSC_VAGAO = 'Identifica��o do vag�o';
  DSC_CHASSI = 'N�mero do chassi';
  DSC_CCOR = 'Cor do Ve�culo';
  DSC_XCOR = 'Descri��o da Cor';
  DSC_CMOD = 'Modelo do Ve�culo';
  DSC_NFAT = 'N�mero da fatura';
  DSC_VORIG = 'Valor Original da Fatura';
  DSC_VLIQ = 'Valor L�quido da Fatura';
  DSC_NDUP = 'N�mero da duplicata';
  DSC_DVENC = 'Data de vencimento';
  DSC_VDUP = 'Valor da duplicata';
  DSC_XSERV = 'Descri��o do servi�o';
  DSC_ANO = 'Ano';
  DSC_NNFINI = 'Numero inicial';
  DSC_NNFFIN = 'Numero final';
  DSC_XJUST = 'Justificativa';
  DSC_NREC = 'Numero do recibo';
  DSC_NSERIE = 'N�mero de s�rie';
  DSC_NPROT = 'Numero do protocolo';
  DSC_CNAE = 'Classifica��o Nacional de Atividades Econ�micas';
  DSC_QTDE = 'Quantidade';
  DSC_QTDEITENS = 'Quantidade de Itens na lista';
  DSC_INDISS = 'Indicador da Exigibilidade do ISS';
  DSC_VDESCINCOND = 'Valor Desconto Incondicionado';
  DSC_VDESCCOND = 'Valor Desconto Condicionado';
  DSC_INDISSRET = 'Indicador de ISS Retido';
  DSC_VISSRET = 'Valor Reten��o ISS';
  DSC_NPROCESSO = 'N�mero do Processo';
  DSC_TPAG = 'Forma de Pagamento';
  DSC_INDINCENTIVO = 'Indicador de Incentivo Fiscal';

  DSC_CNPJ = 'CNPJ(MF)';
  DSC_CPF = 'CPF';
  DSC_CUF = 'C�digo do UF (Unidade da Federa��o)';
  DSC_CNF = 'N�mero da Nota Fiscal Eletr�nica';
  DSC_MOD = 'Modelo';
  DSC_SERIE = 'S�rie do Documento Fiscal';
  DSC_DEMI = 'Data de emiss�o';
  DSC_CDV = 'Digito Verificador';
  DSC_TPAMB = 'Identifica��o do Ambiente';
  DSC_XNOME = 'Raz�o Social ou Nome';
  DSC_IE = 'Inscri��o Estadual';
  DSC_IM = 'Inscri��o Municipal';
  DSC_XLGR = 'Logradouro';
  DSC_NRO = 'N�mero';
  DSC_XCPL = 'Complemento (Endere�o)';
  DSC_XBAIRRO = 'Bairro';
  DSC_XMUN = 'Nome do Munic�pio';
  DSC_CEP = 'CEP';
  DSC_UF = 'Sigla da UF';
  DSC_INFADPROD = 'Informa��es adicionais do Produto';
  DSC_NITEM = 'Numero do item';
  DSC_CPROD = 'C�digo do produto ou servi�o';
  DSC_CEAN = 'C�digo de Barra do Item';
  DSC_XPROD = 'Descri��o do Produto ou Servi�o';
  DSC_NCM = 'C�digo NCM';
  DSC_CEST = 'C�digo Identificador da Substitu��o Tribut�ria';
  DSC_CFOP = 'CFOP';
  DSC_UCOM = 'Unidade Comercial';
  DSC_QCOM = 'Quantidade Comercial';
  DSC_VUNCOM = 'Valor Unit�rio de Comercializa��o';
  DSC_VPROD = 'Valor Total Bruto dos Produtos ou Servi�os';
  DSC_NITEMPED = 'Item do Pedido de Compra da DI � adi��o';
  DSC_VDESC = 'Valor do desconto';
  DSC_VOUTRO = 'Outras Despesas Acess�rias';
  DSC_XTEXTO = 'Conte�do do Campo';
  DSC_ORIG = 'Origem da mercadoria';
  DSC_CST = 'C�digo da situa��o tribut�ria ';
  DSC_PICMS = 'Al�quota do imposto';
  DSC_VICMS = 'Valor do ICMS';
  DSC_CSOSN = 'C�digo de Situa��o da Opera��o � Simples Nacional';
  DSC_VBC = 'Valor da BC do ICMS';
  DSC_PPIS = 'Al�quota do PIS (em percentual)';
  DSC_VPIS = 'Valor do PIS';
  DSC_QBCPROD = 'BC da CIDE';
  DSC_VALIQPROD = 'Valor da al�quota (em reais)';
  DSC_PCOFINS = 'Al�quota da COFINS (em percentual)';
  DSC_VCOFINS = 'Valor do COFINS';
  DSC_PISOUTR = 'Grupo PIS outras opera��es';
  DSC_VBCISS = 'Valor da Base de C�lculo do ISSQN';
  DSC_VALIQ = 'Al�quota';
  DSC_VISSQN = 'Valor do Imposto sobre Servi�o de Qualquer Natureza';
  DSC_CMUNFG = 'C�digo do Munic�pio FG';
  DSC_CLISTSERV = 'Lista Presta��o de Servi�os';
  DSC_VISS = 'Valor do Imposto sobre Servi�o';
  DSC_INFCPL = 'Informa��es complementares de interesse do contribuinte';
  DSC_OBSFISCO = 'Observa��es de interesse do fisco';
  DSC_XCAMPO = 'Identifica��o do Campo';

  DSC_MODAL  = 'Tipo de Modal';
  DSC_RNTRC  = 'Registro Nacional de Transportadores Rodovi�rios de Carga';
  DSC_TPPROP = 'Tipo de Propriet�rio';
  DSC_TPROD  = 'Tipo de Rodado';
  DSC_TPCAR  = 'Tipo de Carroceria';
  DSC_REFCTE = 'Chave de acesso do CT-e referenciado';
  DSC_QTDRAT = 'Quantidade Rateada';
  DSC_VDOC   = 'Valor do documento';
  DSC_CUNID  = 'C�digo da unidade de medida';
  DSC_LACR   = 'Grupo de lacres';
  DSC_CHCTE  = 'Chave do CTe';
  DSC_LOTA   = 'Indicador de lota��o';
  DSC_VVALEPED  = 'Valor do Vale-Pedagio';

  DSC_RESPSEG  = 'Respons�vel pelo Seguro';
  DSC_XSEG     = 'Nome da Seguradora';
  DSC_NAPOL    = 'N�mero da Ap�lice';
  DSC_NAVER    = 'N�mero da Averba��o';
  DSC_INFSEG   = 'Informa��es de seguro da carga';
  DSC_UFPER    = 'Sigla da UF do percurso do ve�culo';

  DSC_NONU      = 'N�mero ONU/UN';
  DSC_XNOMEAE   = 'Nome apropriado para embarque do produto';
  DSC_XCLARISCO = 'Classe e Risco secund�rio';
  DSC_GREMB     = 'Grupo de Embalagem';
  DSC_QTOTPROD  = 'Quantidade total por produto';
  DSC_QVOLTIPO  = 'Quantidade e tipo de volumes';

  DSC_TPUNIDTRANSP = 'Tipo de Unidade de Transporte';
  DSC_IDUNIDTRANSP = 'Identifica��o da Unidade de Transporte';
  DSC_TPUNIDCARGA  = 'Tipo de Unidade de Carga';
  DSC_IDUNIDCARGA  = 'Identifica��o da Unidade de Carga';

  DSC_TPNAV     = 'Tipo de Navega��o';
  DSC_IRIN      = 'Irin do navio sempre dever� ser informado';

  DSC_AUTXML   = 'Autorizados para download do XML do DF-e';
  DSC_XCONTATO = 'Nome do Contato';

  DSC_DigestValue = 'Digest Value';
  DSC_SignatureValue = 'Signature Value';
  DSC_X509Certificate = 'X509 Certificate';

  DSC_VPAG = 'Valor do Pagamento';
  DSC_TPINTEGRA = 'Tipo de Integra��o para pagamento';
  DSC_TBAND = 'Bandeira da Operadora de Cart�o';
  DSC_CAUT = 'N�mero da Autoriza��o';

  DSC_IDCSRT = 'Identificador CSRT - C�digo de Seguran�a do Respons�vel T�cnico';
  DSC_HASHCSRT = 'Hash do CSRT - C�digo de Seguran�a do Respons�vel T�cnico';

  //CFe - Cupom Fiscal Eletr�nico - SAT
  DSC_VDESCSUBTOT = 'Valor de Desconto sobre Subtotal';
  DSC_VACRESSUBTOT = 'Valor de Acr�scimo sobre Subtotal';
  DSC_VPISST = 'Valor do PIS ST';
  DSC_VCOFINSST = 'Valor do COFINS ST';
  DSC_VCFE = 'Valor Total do CF-e';
  DSC_VCFELEI12741 = 'Valor aproximado dos tributos do CFe-SAT � Lei 12741/12.';
  DSC_VDEDUCISS = 'Valor das dedu��es para ISSQN';
  DSC_CSERVTRIBMUN = 'Codigo de tributa��o pelo ISSQN do municipio';
  DSC_CNATOP = 'Natureza da Opera��o de ISSQN';
  DSC_INDINCFISC = 'Indicador de Incentivo Fiscal do ISSQN';
  DSC_COFINSST = 'Grupo de COFINS Substitui��o Tribut�ria';
  DSC_REGTRIB = 'C�digo de Regime Tribut�rio';
  DSC_REGISSQN = 'Regime Especial de Tributa��o do ISSQN';
  DSC_RATISSQN = 'Indicador de rateio do Desconto sobre subtotal entre itens sujeitos � tributa��o pelo ISSQN.';
  DSC_NCFE = 'N�mero do Cupom Fiscal Eletronico';
  DSC_HEMI = 'Hora de emiss�o';
  DSC_SIGNAC = 'Assinatura do Aplicativo Comercial';
  DSC_QRCODE = 'Assinatura Digital para uso em QRCODE';
  DSC_MP = 'Grupo de informa��es sobre Pagamento do CFe';
  DSC_CMP = 'C�digo do Meio de Pagamento';
  DSC_VMP = 'Valor do Meio de Pagamento';
  DSC_CADMC = 'Credenciadora de cart�o de d�bito ou cr�dito';
  DSC_VTROCO = 'Valor do troco';
  DSC_VITEM = 'Valor l�quido do Item';
  DSC_VRATDESC = 'Rateio do desconto sobre subtotal';
  DSC_VRATACR = 'Rateio do acr�scimo sobre subtotal';
  DSC_NUMEROCAIXA = 'N�mero do Caixa ao qual o SAT est� conectado';
  DSC_VITEM12741 = 'Valor aproximado dos tributos do Produto ou servi�o � Lei 12741/12';
  DSC_NSERIESAT = 'N�mero de s�rie do equipamento SAT';
  DSC_DHINICIAL = 'Data e hora incial';
  DSC_DHFINAL = 'Data e Hora Final';
  DSC_CHAVESEGURANCA = 'Chave de seguran�a';

implementation

end.

