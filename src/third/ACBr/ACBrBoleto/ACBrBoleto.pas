{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Juliana Tamizou, Andr� Ferreira de Moraes,      }
{ Jos� M S Junior                                                              }
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

unit ACBrBoleto;

interface
uses Classes, Vcl.Graphics, Contnrs, IniFiles,
     {$IFDEF FPC}
       LResources,
     {$ENDIF}
     {$IfNDef MSWINDOWS}
       ACBrConsts,
     {$ENDIF}
     SysUtils, typinfo,
     ACBrBase, ACBrMail, ACBrValidador,
     ACBrDFeSSL, pcnConversao, ACBrBoletoConversao, ACBrBoletoRetorno;

const
  CInstrucaoPagamento = 'Pagar preferencialmente nas agencias do %s';
  CInstrucaoPagamentoLoterica = 'Preferencialmente nas Casas Lot�ricas at� o valor limite';
  CCedente = 'CEDENTE';
  CBanco = 'BANCO';
  CConta = 'CONTA';
  CTitulo = 'TITULO';

  cACBrTipoOcorrenciaDecricao: array[0..309] of String = (
    {Ocorr�ncias para arquivo remessa}
    'Remessa Registrar',
    'Remessa Baixar',
    'Remessa Debitar Em Conta',
    'Remessa Conceder Abatimento',
    'Remessa Cancelar Abatimento',
    'Remessa Conceder Desconto',
    'Remessa Cancelar Desconto',
    'Remessa Alterar Vencimento',
    'Remessa Alterar Vencimento Sustar Protesto',
    'Remessa Protestar',
    'Remessa Sustar Protesto',
    'Remessa Cancelar Instrucao Protesto Baixa',
    'Remessa Cancelar Instrucao Protesto',
    'Remessa Dispensar Juros',
    'Remessa Alterar Nome Endereco Sacado',
    'Remessa Alterar Numero Controle',
    'Remessa Outras Ocorrencias',
    'Remessa Alterar Controle Participante',
    'Remessa Alterar SeuNumero',
    'Remessa Transf Cessao Credito ID Prod10',
    'Remessa Transferencia Carteira',
    'Remessa Dev Transferencia Carteira',
    'Remessa Desagendar Debito Automatico',
    'Remessa Acertar Rateio Credito',
    'Remessa Cancelar Rateio Credito',
    'Remessa Alterar Uso Empresa',
    'Remessa Nao Protestar',
    'Remessa Protesto Fins Falimentares',
    'Remessa Baixa Por Pagto Direto Cedente',
    'Remessa Cancelar Instrucao',
    'Remessa Alterar Venc Sustar Protesto',
    'Remessa Cedente Discorda Sacado',
    'Remessa Cedente Solicita Dispensa Juros',
    'Remessa Outras Alteracoes',
    'Remessa Alterar Modalidade',
    'Remessa Alterar Exclusivo Cliente',
    'Remessa Nao Cobrar Juros Mora',
    'Remessa Cobrar Juros Mora',
    'Remessa Alterar Valor Titulo',
    'Remessa Excluir Sacador Avalista',
    'Remessa Alterar Numero Dias Protesto',
    'Remessa Alterar Prazo Protesto',
    'Remessa Alterar Prazo Devolucao',
    'Remessa Alterar Outros Dados',
    'Remessa Alterar Dados Emissao Bloqueto',
    'Remessa Alterar Protesto Devolucao',
    'Remessa Alterar Devolucao Protesto',
    'Remessa Negativacao Serasa',
    'Remessa Excluir Negativacao Serasa',
    'Remessa Alterar Juros e Mora',
    'Remessa Alterar Valor/Percentual Multa',
    'Remessa Dispensar Cobran�a de Multa',
    'Remessa Alterar Valor/Data de Desconto',
    'Remessa N�o Conceder Desconto',
    'Remessa Alterar Valor de Abatimento',
    'Remessa Alterar Prazo Limite de Recebimento',
    'Remessa Dispensar Prazo Limite de Recebimento',
    'Remessa Alterar n�mero do t�tulo do Benefici�rio',
    'Remessa Alterar Dados Pagador',
    'Remessa Alterar dados Sacador/Avalista',
    'Remessa Recusa Alega��o do Pagador',
    'Remessa Alterar Dados Rateio de Cr�dito',
    'Remessa Pedido de Cancelamento Dados do Rateio de Cr�dito',
    'Remessa Pedido de Desagendamento do D�bito Autom�tico',
    'Remessa Alterar Esp�cie de T�tulo',
    'Remessa Contrato de Cobran�a',
    'Remessa Negativa��o Sem Protesto',
    'Remessa Baixa T�tulo Negativado Sem Protesto',
    'Remessa Alterar Valor M�nimo',
    'Remessa Alterar Valor M�ximo',
    'Remessa Excluir Negativacao Serasa e Baixar',
    'Remessa Pedido de negativa��o',
    'Remessa Excluir negativa��o e baixar',
    'Remessa Excluir negativa��o e manter em carteira',
    'Remessa Sustar Protesto e baixar',
    'Remessa Sustar Protesto e manter em carteira',
    'Remessa Resusa Alega��o do Sacado',
    'Remessa Protestar Automaticamente',
    'Remessa Altera��o de Status Desconto',

    {Ocorr�ncias para arquivo retorno}
    'Retorno Abatimento Cancelado',
    'Retorno Abatimento Concedido',
    'Retorno Acerto Controle Participante',
    'Retorno Acerto Dados Rateio Credito',
    'Retorno Acerto Depositaria',
    'Retorno Aguardando Autorizacao Protesto Edital',
    'Retorno Alegacao DoSacado',
    'Retorno Alteracao Dados Baixa',
    'Retorno Alteracao Dados Nova Entrada',
    'Retorno Alteracao Dados Rejeitados',
    'Retorno Alteracao Data Emissao',
    'Retorno Alteracao Especie',
    'Retorno Alteracao Instrucao',
    'Retorno Alteracao Opcao Devolucao Para Protesto Confirmada',
    'Retorno Alteracao Opcao Protesto Para Devolucao Confirmada',
    'Retorno Alteracao Outros Dados Rejeitada',
    'Retorno Alteracao Reemissao Bloqueto Confirmada',
    'Retorno Alteracao Seu Numero',
    'Retorno Alteracao Uso Cedente',
    'Retorno Alterar Data Desconto',
    'Retorno Alterar Prazo Limite Recebimento',
    'Retorno Alterar Sacador Avalista',
    'Retorno Baixa Automatica',
    'Retorno Baixa Credito CC Atraves Sispag',
    'Retorno Baixa Credito CC Atraves Sispag Sem Titulo Corresp',
    'Retorno Baixado',
    'Retorno Baixado FrancoPagamento',
    'Retorno Baixado InstAgencia',
    'Retorno Baixado Por Devolucao',
    'Retorno Baixado Via Arquivo',
    'Retorno Baixa Liquidado Edital',
    'Retorno Baixa Manual Confirmada',
    'Retorno Baixa Ou Liquidacao Estornada',
    'Retorno Baixa Por Protesto',
    'Retorno Baixa Por Ter Sido Liquidado',
    'Retorno Baixa Rejeitada',
    'Retorno Baixa Simples',
    'Retorno Baixa Solicitada',
    'Retorno Baixa Titulo Negativado Sem Protesto',
    'Retorno Baixa Transferencia Para Desconto',
    'Retorno Cancelamento Dados Rateio',
    'Retorno Cheque Compensado',
    'Retorno Cheque Devolvido',
    'Retorno Cheque Pendente Compensacao',
    'Retorno Cobranca Contratual',
    'Retorno Cobranca Creditar',
    'Retorno Comando Recusado',
    'Retorno Conf Cancelamento Negativacao Expressa Tarifa',
    'Retorno Conf Entrada Negativacao Expressa Tarifa',
    'Retorno Conf Exclusao Entrada Negativacao Expressa Por Liquidacao Tarifa',
    'Retorno Conf Instrucao Transferencia Carteira Modalidade Cobranca',
    'Retorno Confirmacao Alteracao Banco Sacado',
    'Retorno Confirmacao Alteracao Juros Mora',
    'Retorno Confirmacao Email SMS',
    'Retorno Confirmacao Entrada Cobranca Simples',
    'Retorno Confirmacao Exclusao Banco Sacado',
    'Retorno Confirmacao Inclusao Banco Sacado',
    'Retorno Confirmacao Pedido Excl Negativacao',
    'Retorno Confirmacao Receb Pedido Negativacao',
    'Retorno Confirma Recebimento Instrucao NaoNegativar',
    'Retorno Conf Recebimento Inst Cancelamento Negativacao Expressa',
    'Retorno Conf Recebimento Inst Entrada Negativacao Expressa',
    'Retorno Conf Recebimento Inst Exclusao Entrada Negativacao Expressa',
    'Retorno Custas Cartorio',
    'Retorno Custas Cartorio Distribuidor',
    'Retorno Custas Edital',
    'Retorno Custas Irregularidade',
    'Retorno Custas Protesto',
    'Retorno Custas Sustacao',
    'Retorno Custas Sustacao Judicial',
    'Retorno Dados Alterados',
    'Retorno Debito Custas Antecipadas',
    'Retorno Debito Direto Autorizado',
    'Retorno Debito Direto NaoAutorizado',
    'Retorno Debito Em Conta',
    'Retorno Debito Mensal Tarifa Aviso Movimentacao Titulos',
    'Retorno Debito Mensal Tarifas Extrado Posicao',
    'Retorno Debito Mensal Tarifas Manutencao Titulos Vencidos',
    'Retorno Debito Mensal Tarifas Outras Instrucoes',
    'Retorno Debito Mensal Tarifas Outras Ocorrencias',
    'Retorno Debito Mensal Tarifas Protestos',
    'Retorno Debito Mensal Tarifas SustacaoProtestos',
    'Retorno Debito Tarifas',
    'Retorno Desagendamento Debito Automatico',
    'Retorno Desconto Cancelado',
    'Retorno Desconto Concedido',
    'Retorno Desconto Retificado',
    'Retorno Despesa Cartorio',
    'Retorno Despesas Protesto',
    'Retorno Despesas Sustacao Protesto',
    'Retorno Devolvido Pelo Cartorio',
    'Retorno Dispensar Indexador',
    'Retorno Dispensar Prazo Limite Recebimento',
    'Retorno Email SMS Rejeitado',
    'Retorno Emissao Bloqueto Banco Sacado',
    'Retorno Encaminhado A Cartorio',
    'Retorno Endereco Sacado Alterado',
    'Retorno Entrada Bordero Manual',
    'Retorno Entrada Confirmada Rateio Credito',
    'Retorno Entrada Em Cartorio',
    'Retorno Entrada Registrada Aguardando Avaliacao',
    'Retorno Entrada Rejeita CEP Irregular',
    'Retorno Entrada Rejeitada Carne',
    'Retorno Entrada Titulo Banco Sacado Rejeitada',
    'Retorno Equalizacao Vendor',
    'Retorno Estorno Baixa Liquidacao',
    'Retorno Estorno Pagamento',
    'Retorno Estorno Protesto',
    'Retorno Instrucao Cancelada',
    'Retorno Instrucao Negativacao Expressa Rejeitada',
    'Retorno Instrucao Protesto Rejeitada Sustada Ou Pendente',
    'Retorno Instrucao Rejeitada',
    'Retorno IOF Invalido',
    'Retorno Juros Dispensados',
    'Retorno Liquidado',
    'Retorno Liquidado Apos Baixa Ou Nao Registro',
    'Retorno Liquidado Em Cartorio',
    'Retorno Liquidado Parcialmente',
    'Retorno Liquidado PorConta',
    'Retorno Liquidado Saldo Restante',
    'Retorno Liquidado Sem Registro',
    'Retorno Manutencao Banco Sacado Rejeitada',
    'Retorno Manutencao Sacado Rejeitada',
    'Retorno Manutencao Titulo Vencido',
    'Retorno Negativacao Expressa Informacional',
    'Retorno Nome Sacado Alterado',
    'Retorno Ocorrencias Do Sacado',
    'Retorno Outras Ocorrencias',
    'Retorno Outras Tarifas Alteracao',
    'Retorno Pagador DDA',
    'Retorno Prazo Devolucao Alterado',
    'Retorno Prazo Protesto Alterado',
    'Retorno Protestado',
    'Retorno Protesto Imediato Falencia',
    'Retorno Protesto Ou Sustacao Estornado',
    'Retorno Protesto Sustado',
    'Retorno Recebimento Instrucao Alterar Dados',
    'Retorno Recebimento Instrucao Alterar EnderecoSacado',
    'Retorno Recebimento Instrucao Alterar Juros',
    'Retorno Recebimento Instrucao Alterar NomeSacado',
    'Retorno Recebimento Instrucao Alterar Tipo Cobranca',
    'Retorno Recebimento Instrucao Alterar Valor Titulo',
    'Retorno Recebimento Instrucao Alterar Vencimento',
    'Retorno Recebimento Instrucao Baixar',
    'Retorno Recebimento Instrucao Cancelar Abatimento',
    'Retorno Recebimento Instrucao Cancelar Desconto',
    'Retorno Recebimento Instrucao Conceder Abatimento',
    'Retorno Recebimento Instrucao Conceder Desconto',
    'Retorno Recebimento Instrucao Dispensar Juros',
    'Retorno Recebimento Instrucao Nao Protestar',
    'Retorno Recebimento Instrucao Protestar',
    'Retorno Recebimento Instrucao Sustar Protesto',
    'Retorno Reembolso Devolucao Desconto Vendor',
    'Retorno Reembolso Nao Efetuado',
    'Retorno Reembolso Transferencia Desconto Vendor',
    'Retorno Registro Confirmado',
    'Retorno Registro Recusado',
    'Retorno Relacao De Titulos',
    'Retorno Remessa Rejeitada',
    'Retorno Reservado',
    'Retorno Retirado De Cartorio',
    'Retorno Segunda Via Instrumento Protesto',
    'Retorno Segunda Via Instrumento Protesto Cartorio',
    'Retorno Solicitacao Impressao Titulo Confirmada',
    'Retorno Sustacao Envio Cartorio',
    'Retorno Sustado Judicial',
    'Retorno Tarifa Aviso Cobranca',
    'Retorno Tarifa De Manutencao De Titulos Vencidos',
    'Retorno Tarifa De Relacao Das Liquidacoes',
    'Retorno Tarifa Email Cobranca Ativa Eletronica',
    'Retorno Tarifa Emissao Aviso Movimentacao Titulos',
    'Retorno Tarifa Emissao Boleto Envio Duplicata',
    'Retorno Tarifa Extrato Posicao',
    'Retorno Tarifa Instrucao',
    'Retorno Tarifa Mensal Baixas Bancos Corresp Carteira',
    'Retorno Tarifa Mensal Baixas Carteira',
    'Retorno Tarifa Mensal Cancelamento Negativacao Expressa',
    'Retorno Tarifa Mensal Email Cobranca AtivaEletronica',
    'Retorno Tarifa Mensal Emissao Boleto Envio Duplicata',
    'Retorno Tarifa Mensal Exclusao Entrada Negativacao Expressa',
    'Retorno Tarifa Mensal Exclusao Negativacao Expressa Por Liquidacao',
    'Retorno Tarifa Mensal Liquidacoes Bancos Corresp Carteira',
    'Retorno Tarifa Mensal Liquidacoes Carteira',
    'Retorno Tarifa Mensal Por Boleto Ate 03 Envio Cobranca Ativa Eletronica',
    'Retorno Tarifa Mensal Ref Entradas Bancos Corresp Carteira',
    'Retorno Tarifa Mensal SMS Cobranca Ativa Eletronica',
    'Retorno Tarifa Ocorrencias',
    'Retorno Tarifa Por Boleto Ate 03 Envio Cobranca Ativa Eletronica',
    'Retorno Tarifa SMS Cobranca Ativa Eletronica',
    'Retorno Tipo Cobranca Alterado',
    'Retorno Titulo DDA Nao Reconhecido Pagador',
    'Retorno Titulo DDA Reconhecido Pagador',
    'Retorno Titulo DDA Recusado CIP',
    'Retorno Titulo Em Ser',
    'Retorno Titulo Ja Baixado',
    'Retorno Titulo Nao Existe',
    'Retorno Titulo Pagamento Cancelado',
    'Retorno Titulo Pago Em Cheque',
    'Retorno Titulo Sustado Judicialmente',
    'Retorno Transferencia Carteira',
    'Retorno Transferencia Carteira Baixa',
    'Retorno Transferencia Carteira Entrada',
    'Retorno Transferencia Cedente',
    'Retorno Transito Pago Cartorio',
    'Retorno Vencimento Alterado',
    'Retorno Rejeicao Sacado',
    'Retorno Aceite Sacado',
    'Retorno Liquidado On Line',
    'Retorno Estorno Liquidacao OnLine',
    'Retorno Confirmacao Alteracao Valor Nominal',
    'Retorno Confirmacao Alteracao Valor Percentual Minimo Maximo',
    'Tipo Ocorrencia Nenhum',
    'Retorno Confirma��o de Recebimento de Pedido de Negativa��o',
    'Retorno Confirma��o de Recebimento de Pedido de Exclus�o de Negativa��o',
    'Retorno Confirma��o de Entrada de Negativa��o',
    'Retorno Entrada de Negativa��o Rejeitada',
    'Retorno Confirma��o de Exclus�o de Negativa��o',
    'Retorno Exlus�o de Negativa��o Rejeitada',
    'Retorno Exclus�o e Negativa��o por Outros Motivos',
    'Retorno Ocorr�ncia Informacional por Outros Motivos',
    'Retorno Inclus�o de Negativa��o',
    'Retorno Exclus�o de Negativa��o',
    'Retorno Em Transito',
    'Retorno Liquida��o em Condicional em Cart�rio Com Cheque do Pr�prio Devedor',
    'Retorno T�tulo Protestado Sustado Judicialmente em definitivo',
    'Retorno Liquida��o de T�tulo Descontado',
    'Retorno Protesto Em Cart�rio',
    'Retorno Susta��o Solicitada',
    'Retorno T�tulo Utilizado Como Garantia em Opera��o de Desconto',
    'Retorno T�tulo Descont�vel Com Desist�ncia de Garantia em Opera��o de Desconto',
    'Retorno Inten��o de Pagamento'
);

type
  TACBrTipoCobranca =
   (cobNenhum,
    cobBancoDoBrasil,
    cobSantander,
    cobCaixaEconomica,
    cobCaixaSicob,
    cobBradesco,
    cobItau,
    cobBancoMercantil,
    cobSicred,
    cobBancoob,
    cobBanrisul,
    cobBanestes,
    cobHSBC,
    cobBancoDoNordeste,
    cobBRB,
    cobBicBanco,
    cobBradescoSICOOB,
    cobBancoSafra,
    cobSafraBradesco,
    cobBancoCECRED,
    cobBancoDaAmazonia,
    cobBancoDoBrasilSICOOB,
    cobUniprime,
    cobUnicredRS,
    cobBanese,
    cobCrediSIS,
    cobUnicredES,
    cobBancoCresolSCRS,
    cobCitiBank,
    cobBancoABCBrasil,
    cobDaycoval,
    cobUniprimeNortePR,
    cobBancoPine,
    cobBancoPineBradesco,
    cobUnicredSC
    );

  TACBrTitulo = class;
  TACBrBoletoFCClass = class;
  TACBrCedente = class;
  TACBrBanco  = class;
  TACBrBoleto = class;
  TConfiguracoes = class;

  TACBrTipoDesconto = (
    tdNaoConcederDesconto,
    tdValorFixoAteDataInformada,
    tdPercentualAteDataInformada,
    tdValorAntecipacaoDiaCorrido,
    tdValorAntecipacaoDiaUtil,
    tdPercentualSobreValorNominalDiaCorrido,
    tdPercentualSobreValorNominalDiaUtil,
    tdCancelamentoDesconto);

  TACBrLayoutRemessa = (c400, c240);

  {Identifica��o da Distribuicao}
  TACBrIdentDistribuicao = (tbBancoDistribui, tbClienteDistribui);

  {Tipos de ocorr�ncias permitidas no arquivos remessa / retorno}
  TACBrTipoOcorrencia =
  (
    {Ocorr�ncias para arquivo remessa}
    toRemessaRegistrar,
    toRemessaBaixar,
    toRemessaDebitarEmConta,
    toRemessaConcederAbatimento,
    toRemessaCancelarAbatimento,
    toRemessaConcederDesconto,
    toRemessaCancelarDesconto,
    toRemessaAlterarVencimento,
    toRemessaAlterarVencimentoSustarProtesto,
    toRemessaProtestar,
    toRemessaSustarProtesto,
    toRemessaCancelarInstrucaoProtestoBaixa,
    toRemessaCancelarInstrucaoProtesto,
    toRemessaDispensarJuros,
    toRemessaAlterarNomeEnderecoSacado,
    toRemessaAlterarNumeroControle,
    toRemessaOutrasOcorrencias,
    toRemessaAlterarControleParticipante,
    toRemessaAlterarSeuNumero,
    toRemessaTransfCessaoCreditoIDProd10,
    toRemessaTransferenciaCarteira,
    toRemessaDevTransferenciaCarteira,
    toRemessaDesagendarDebitoAutomatico,
    toRemessaAcertarRateioCredito,
    toRemessaCancelarRateioCredito,
    toRemessaAlterarUsoEmpresa,
    toRemessaNaoProtestar,
    toRemessaProtestoFinsFalimentares,
    toRemessaBaixaporPagtoDiretoCedente,
    toRemessaCancelarInstrucao,
    toRemessaAlterarVencSustarProtesto,
    toRemessaCedenteDiscordaSacado,
    toRemessaCedenteSolicitaDispensaJuros,
    toRemessaOutrasAlteracoes,
    toRemessaAlterarModalidade,
    toRemessaAlterarExclusivoCliente,
    toRemessaNaoCobrarJurosMora,
    toRemessaCobrarJurosMora,
    toRemessaAlterarValorTitulo,
    toRemessaExcluirSacadorAvalista,
    toRemessaAlterarNumeroDiasProtesto,
    toRemessaAlterarPrazoProtesto,
    toRemessaAlterarPrazoDevolucao,
    toRemessaAlterarOutrosDados,
    toRemessaAlterarDadosEmissaoBloqueto,
    toRemessaAlterarProtestoDevolucao,
    toRemessaAlterarDevolucaoProtesto,
    toRemessaNegativacaoSerasa,
    toRemessaExcluirNegativacaoSerasa,
    toRemessaAlterarJurosMora,
    toRemessaAlterarMulta,
    toRemessaDispensarMulta,
    toRemessaAlterarDesconto,
    toRemessaNaoConcederDesconto,
    toRemessaAlterarValorAbatimento,
    toRemessaAlterarPrazoLimiteRecebimento,
    toRemessaDispensarPrazoLimiteRecebimento,
    toRemessaAlterarNumeroTituloBeneficiario,
    toRemessaAlterarDadosPagador,
    toRemessaAlterarDadosSacadorAvalista,
    toRemessaRecusaAlegacaoPagador,
    toRemessaAlterarDadosRateioCredito,
    toRemessaPedidoCancelamentoDadosRateioCredito,
    toRemessaPedidoDesagendamentoDebietoAutom,
    toRemessaAlterarEspecieTitulo,
    toRemessaAlterarContratoCobran,
    toRemessaNegativacaoSemProtesto,
    toRemessaBaixaTituloNegativadoSemProtesto,
    toRemessaAlterarValorMinimo,
    toRemessaAlterarValorMaximo,
    toRemessaExcluirNegativacaoSerasaBaixar,
    toRemessaPedidoNegativacao,
    toRemessaExcluirNegativacaoBaixar,
    toRemessaExcluirNegativacaoManterEmCarteira,
    toRemessaSustarProtestoBaixarTitulo,
    toRemessaSustarProtestoManterCarteira,
    toRemessaRecusaAlegacaoSacado,
    toRemessaProtestoAutomatico,
    toRemessaAlterarStatusDesconto,

    {Ocorr�ncias para arquivo retorno}
    toRetornoAbatimentoCancelado,
    toRetornoAbatimentoConcedido,
    toRetornoAcertoControleParticipante,
    toRetornoAcertoDadosRateioCredito,
    toRetornoAcertoDepositaria,
    toRetornoAguardandoAutorizacaoProtestoEdital,
    toRetornoAlegacaoDoSacado,
    toRetornoAlteracaoDadosBaixa,
    toRetornoAlteracaoDadosNovaEntrada,
    toRetornoAlteracaoDadosRejeitados,
    toRetornoAlteracaoDataEmissao,
    toRetornoAlteracaoEspecie,
    toRetornoAlteracaoInstrucao,
    toRetornoAlteracaoOpcaoDevolucaoParaProtestoConfirmada,
    toRetornoAlteracaoOpcaoProtestoParaDevolucaoConfirmada,
    toRetornoAlteracaoOutrosDadosRejeitada,
    toRetornoAlteracaoReemissaoBloquetoConfirmada,
    toRetornoAlteracaoSeuNumero,
    toRetornoAlteracaoUsoCedente,
    toRetornoAlterarDataDesconto,
    toRetornoAlterarPrazoLimiteRecebimento,
    toRetornoAlterarSacadorAvalista,
    toRetornoBaixaAutomatica,
    toRetornoBaixaCreditoCCAtravesSispag,
    toRetornoBaixaCreditoCCAtravesSispagSemTituloCorresp,
    toRetornoBaixado,
    toRetornoBaixadoFrancoPagamento,
    toRetornoBaixadoInstAgencia,
    toRetornoBaixadoPorDevolucao,
    toRetornoBaixadoViaArquivo,
    toRetornoBaixaLiquidadoEdital,
    toRetornoBaixaManualConfirmada,
    toRetornoBaixaOuLiquidacaoEstornada,
    toRetornoBaixaPorProtesto,
    toRetornoBaixaPorTerSidoLiquidado,
    toRetornoBaixaRejeitada,
    toRetornoBaixaSimples,
    toRetornoBaixaSolicitada,
    toRetornoBaixaTituloNegativadoSemProtesto,
    toRetornoBaixaTransferenciaParaDesconto,
    toRetornoCancelamentoDadosRateio,
    toRetornoChequeCompensado,
    toRetornoChequeDevolvido,
    toRetornoChequePendenteCompensacao,
    toRetornoCobrancaContratual,
    toRetornoCobrancaCreditar,
    toRetornoComandoRecusado,
    toRetornoConfCancelamentoNegativacaoExpressaTarifa,
    toRetornoConfEntradaNegativacaoExpressaTarifa,
    toRetornoConfExclusaoEntradaNegativacaoExpressaPorLiquidacaoTarifa,
    toRetornoConfInstrucaoTransferenciaCarteiraModalidadeCobranca,
    toRetornoConfirmacaoAlteracaoBancoSacado,
    toRetornoConfirmacaoAlteracaoJurosMora,
    toRetornoConfirmacaoEmailSMS,
    toRetornoConfirmacaoEntradaCobrancaSimples,
    toRetornoConfirmacaoExclusaoBancoSacado,
    toRetornoConfirmacaoInclusaoBancoSacado,
    toRetornoConfirmacaoPedidoExclNegativacao,
    toRetornoConfirmacaoRecebPedidoNegativacao,
    toRetornoConfirmaRecebimentoInstrucaoNaoNegativar,
    toRetornoConfRecebimentoInstCancelamentoNegativacaoExpressa,
    toRetornoConfRecebimentoInstEntradaNegativacaoExpressa,
    toRetornoConfRecebimentoInstExclusaoEntradaNegativacaoExpressa,
    toRetornoCustasCartorio,
    toRetornoCustasCartorioDistribuidor,
    toRetornoCustasEdital,
    toRetornoCustasIrregularidade,
    toRetornoCustasProtesto,
    toRetornoCustasSustacao,
    toRetornoCustasSustacaoJudicial,
    toRetornoDadosAlterados,
    toRetornoDebitoCustasAntecipadas,
    toRetornoDebitoDiretoAutorizado,
    toRetornoDebitoDiretoNaoAutorizado,
    toRetornoDebitoEmConta,
    toRetornoDebitoMensalTarifaAvisoMovimentacaoTitulos,
    toRetornoDebitoMensalTarifasExtradoPosicao,
    toRetornoDebitoMensalTarifasManutencaoTitulosVencidos,
    toRetornoDebitoMensalTarifasOutrasInstrucoes,
    toRetornoDebitoMensalTarifasOutrasOcorrencias,
    toRetornoDebitoMensalTarifasProtestos,
    toRetornoDebitoMensalTarifasSustacaoProtestos,
    toRetornoDebitoTarifas,
    toRetornoDesagendamentoDebitoAutomatico,
    toRetornoDescontoCancelado,
    toRetornoDescontoConcedido,
    toRetornoDescontoRetificado,
    toRetornoDespesaCartorio,
    toRetornoDespesasProtesto,
    toRetornoDespesasSustacaoProtesto,
    toRetornoDevolvidoPeloCartorio,
    toRetornoDispensarIndexador,
    toRetornoDispensarPrazoLimiteRecebimento,
    toRetornoEmailSMSRejeitado,
    toRetornoEmissaoBloquetoBancoSacado,
    toRetornoEncaminhadoACartorio,
    toRetornoEnderecoSacadoAlterado,
    toRetornoEntradaBorderoManual,
    toRetornoEntradaConfirmadaRateioCredito,
    toRetornoEntradaEmCartorio,
    toRetornoEntradaRegistradaAguardandoAvaliacao,
    toRetornoEntradaRejeitaCEPIrregular,
    toRetornoEntradaRejeitadaCarne,
    toRetornoEntradaTituloBancoSacadoRejeitada,
    toRetornoEqualizacaoVendor,
    toRetornoEstornoBaixaLiquidacao,
    toRetornoEstornoPagamento,
    toRetornoEstornoProtesto,
    toRetornoInstrucaoCancelada,
    toRetornoInstrucaoNegativacaoExpressaRejeitada,
    toRetornoInstrucaoProtestoRejeitadaSustadaOuPendente,
    toRetornoInstrucaoRejeitada,
    toRetornoIOFInvalido,
    toRetornoJurosDispensados,
    toRetornoLiquidado,
    toRetornoLiquidadoAposBaixaOuNaoRegistro,
    toRetornoLiquidadoEmCartorio,
    toRetornoLiquidadoParcialmente,
    toRetornoLiquidadoPorConta,
    toRetornoLiquidadoSaldoRestante,
    toRetornoLiquidadoSemRegistro,
    toRetornoManutencaoBancoSacadoRejeitada,
    toRetornoManutencaoSacadoRejeitada,
    toRetornoManutencaoTituloVencido,
    toRetornoNegativacaoExpressaInformacional,
    toRetornoNomeSacadoAlterado,
    toRetornoOcorrenciasDoSacado,
    toRetornoOutrasOcorrencias,
    toRetornoOutrasTarifasAlteracao,
    toRetornoPagadorDDA,
    toRetornoPrazoDevolucaoAlterado,
    toRetornoPrazoProtestoAlterado,
    toRetornoProtestado,
    toRetornoProtestoImediatoFalencia,
    toRetornoProtestoOuSustacaoEstornado,
    toRetornoProtestoSustado,
    toRetornoRecebimentoInstrucaoAlterarDados,
    toRetornoRecebimentoInstrucaoAlterarEnderecoSacado,
    toRetornoRecebimentoInstrucaoAlterarJuros,
    toRetornoRecebimentoInstrucaoAlterarNomeSacado,
    toRetornoRecebimentoInstrucaoAlterarTipoCobranca,
    toRetornoRecebimentoInstrucaoAlterarValorTitulo,
    toRetornoRecebimentoInstrucaoAlterarVencimento,
    toRetornoRecebimentoInstrucaoBaixar,
    toRetornoRecebimentoInstrucaoCancelarAbatimento,
    toRetornoRecebimentoInstrucaoCancelarDesconto,
    toRetornoRecebimentoInstrucaoConcederAbatimento,
    toRetornoRecebimentoInstrucaoConcederDesconto,
    toRetornoRecebimentoInstrucaoDispensarJuros,
    toRetornoRecebimentoInstrucaoNaoProtestar,
    toRetornoRecebimentoInstrucaoProtestar,
    toRetornoRecebimentoInstrucaoSustarProtesto,
    toRetornoReembolsoDevolucaoDescontoVendor,
    toRetornoReembolsoNaoEfetuado,
    toRetornoReembolsoTransferenciaDescontoVendor,
    toRetornoRegistroConfirmado,
    toRetornoRegistroRecusado,
    toRetornoRelacaoDeTitulos,
    toRetornoRemessaRejeitada,
    toRetornoReservado,
    toRetornoRetiradoDeCartorio,
    toRetornoSegundaViaInstrumentoProtesto,
    toRetornoSegundaViaInstrumentoProtestoCartorio,
    toRetornoSolicitacaoImpressaoTituloConfirmada,
    toRetornoSustacaoEnvioCartorio,
    toRetornoSustadoJudicial,
    toRetornoTarifaAvisoCobranca,
    toRetornoTarifaDeManutencaoDeTitulosVencidos,
    toRetornoTarifaDeRelacaoDasLiquidacoes,
    toRetornoTarifaEmailCobrancaAtivaEletronica,
    toRetornoTarifaEmissaoAvisoMovimentacaoTitulos,
    toRetornoTarifaEmissaoBoletoEnvioDuplicata,
    toRetornoTarifaExtratoPosicao,
    toRetornoTarifaInstrucao,
    toRetornoTarifaMensalBaixasBancosCorrespCarteira,
    toRetornoTarifaMensalBaixasCarteira,
    toRetornoTarifaMensalCancelamentoNegativacaoExpressa,
    toRetornoTarifaMensalEmailCobrancaAtivaEletronica,
    toRetornoTarifaMensalEmissaoBoletoEnvioDuplicata,
    toRetornoTarifaMensalExclusaoEntradaNegativacaoExpressa,
    toRetornoTarifaMensalExclusaoNegativacaoExpressaPorLiquidacao,
    toRetornoTarifaMensalLiquidacoesBancosCorrespCarteira,
    toRetornoTarifaMensalLiquidacoesCarteira,
    toRetornoTarifaMensalPorBoletoAte03EnvioCobrancaAtivaEletronica,
    toRetornoTarifaMensalRefEntradasBancosCorrespCarteira,
    toRetornoTarifaMensalSMSCobrancaAtivaEletronica,
    toRetornoTarifaOcorrencias,
    toRetornoTarifaPorBoletoAte03EnvioCobrancaAtivaEletronica,
    toRetornoTarifaSMSCobrancaAtivaEletronica,
    toRetornoTipoCobrancaAlterado,
    toRetornoTituloDDANaoReconhecidoPagador,
    toRetornoTituloDDAReconhecidoPagador,
    toRetornoTituloDDARecusadoCIP,
    toRetornoTituloEmSer,
    toRetornoTituloJaBaixado,
    toRetornoTituloNaoExiste,
    toRetornoTituloPagamentoCancelado,
    toRetornoTituloPagoEmCheque,
    toRetornoTituloSustadoJudicialmente,
    toRetornoTransferenciaCarteira,
    toRetornoTransferenciaCarteiraBaixa,
    toRetornoTransferenciaCarteiraEntrada,
    toRetornoTransferenciaCedente,
    toRetornoTransitoPagoCartorio,
    toRetornoVencimentoAlterado,
    toRetornoRejeicaoSacado,
    toRetornoAceiteSacado,
    toRetornoLiquidadoOnLine,
    toRetornoEstornoLiquidacaoOnLine,
    toRetornoConfirmacaoAlteracaoValorNominal,
    toRetornoConfirmacaoAlteracaoValorpercentualMinimoMaximo,
    toTipoOcorrenciaNenhum,
    toRetornoConfRecPedidoNegativacao,
    toRetornoConfRecPedidoExclusaoNegativacao,
    toRetornoConfEntradaNegativacao,
    toRetornoEntradaNegativacaoRejeitada,
    toRetornoConfExclusaoNegativacao,
    toRetornoExclusaoNegativacaoRejeitada,
    toRetornoExcusaoNegativacaoOutrosMotivos,
    toRetornoOcorrenciaInfOutrosMotivos,
    toRetornoInclusaoNegativacao,
    toRetornoExclusaoNegativacao,
    toRetornoEmTransito,
    toRetornoLiquidadoEmCartorioEmCondicionalComChequeDoDevedor,
    toRetornoProtestoSustadoDefinitivo,
    toRetornoLiquidadoTituloDescontado,
    toRetornoProtestadoEmCartorio,
    toRetornoSustacaoSolicitada,
    toRetornoTituloDescontado,
    toRetornoTituloDescontavel,
    toRetornoIntensaoPagamento
  );

  //Complemento de instru��o para alterar outros dados
  TACBrComplementoOcorrenciaOutrosDados =
  (
    TCompDesconto,
    TCompJurosDia,
    TCompDescontoDiasAntecipacao,
    TCompDataLimiteDesconto,
    TCompCancelaProtestoAutomatico,
    TCompCarteiraCobranca, //Segundo Manual ainda n�o disponivel
    TCompCancelaNegativacaoAutomatica
  );
  

  {TACBrOcorrencia}
  TACBrOcorrencia = class
  private
     fTipo: TACBrTipoOcorrencia;
     fpAOwner: TACBrTitulo;
     fComplementoOutrosDados: TACBrComplementoOcorrenciaOutrosDados;
     function GetCodigoBanco: String;
     function GetDescricao: String;
  public
     constructor Create(AOwner: TACBrTitulo);
     property Tipo: TACBrTipoOcorrencia read fTipo write fTipo;
     property ComplementoOutrosDados: TACBrComplementoOcorrenciaOutrosDados
      read fComplementoOutrosDados write fComplementoOutrosDados;
     property Descricao  : String  read GetDescricao;
     property CodigoBanco: String  read GetCodigoBanco;
  end;

  { TACBrBancoClass }

  TACBrBancoClass = class
 // private
 //    procedure ErroAbstract( const NomeProcedure : String ) ;
  protected
    fpDigito: Integer;
    fpNome:   String;
    fpNumero: Integer;
    fpModulo: TACBrCalcDigito;
    fpTamanhoAgencia: Integer;
    fpTamanhoCarteira: Integer;
    fpTamanhoConta: Integer;
    fpAOwner: TACBrBanco;
    fpTamanhoMaximoNossoNum: Integer;
    fpTamanhoNumeroDocumento: Integer;
    fpOrientacoesBanco: TStringList;
    fpCodigosMoraAceitos: String;
    fpCodigosGeracaoAceitos: String;
    fpNumeroCorrespondente: Integer;
    fpLayoutVersaoArquivo : Integer; // Vers�o do Hearder do arquivo
    fpLayoutVersaoLote : Integer; // Vers�o do Hearder do Lote
    fpCasasDecimaisMoraJuros: Integer;
    fpModuloMultiplicadorInicial: Integer;
    fpModuloMultiplicadorFinal: Integer;
    fpModuloMultiplicadorAtual: Integer;
    fpCodParametroMovimento: String;
    fpDensidadeGravacao: String;
    fpQtdRegsLote: Integer;
    fpQtdRegsCobranca: Integer;
    fpVlrRegsCobranca: Double;

    function GetLocalPagamento: String; virtual;
    function CalcularFatorVencimento(const DataVencimento: TDateTime): String; virtual;
    function CalcularDigitoCodigoBarras(const CodigoBarras: String): String; virtual;
    function FormatarMoraJurosRemessa(const APosicoes: Integer
       ;const ACBrTitulo: TACBrTitulo):String; Virtual;

    function DefineNumeroDocumentoModulo(const ACBrTitulo: TACBrTitulo): String; virtual;  //Utilizado para m�todo CalculaDigitoVerificador
    function ConverterDigitoModuloFinal(): String; virtual;                                //Utilizado para m�todo CalculaDigitoVerificador
    function DefineCampoLivreCodigoBarras(const ACBrTitulo: TACBrTitulo): String; virtual; //Utilizado para o m�todo MontarCodigoBarras
    procedure ValidaNossoNumeroResponsavel(out ANossoNumero: String;
      out ADigVerificador: String; const ACBrTitulo :TACBrTitulo); virtual;                //Utilizado para validar Nosso n�mero na gera�ao Remessa e Retorno CNAB400
    function MontaInstrucoesCNAB400(const ACBrTitulo :TACBrTitulo; const nRegistro: Integer ): String; virtual;   //Utilizado para Montar Instru��es CNAB 400
    function DefineEspecieDoc(const ACBrTitulo: TACBrTitulo): String; virtual;       //Utilizado para definir Especie na gera��o Remessa
    function DefineTipoSacado(const ACBrTitulo: TACBrTitulo): String; virtual;       //Utilizado para definir Tipo do Sacado na gera��o Remessa
    function DefineTipoSacadoAvalista(const ACBrTitulo: TACBrTitulo): String; virtual;//Utilizado para definir Tipo do Sacado avalista na gera��o Remessa
    function DefineTipoBoleto(const ACBrTitulo: TACBrTitulo): String; virtual;       //Utilizado para definir Tipo do Boleto na Remessa
    function InstrucoesProtesto(const ACBrTitulo: TACBrTitulo): String; virtual;     //Utilizado para definir Instru��es de Protesto para Remessa
    function DefineCaracTitulo(const ACBrTitulo: TACBrTitulo): String; virtual;      //Utilizado para definir caracteristica do t�tulo na remessa
    function DefineCodigoProtesto(const ACBrTitulo: TACBrTitulo): String; virtual;   //Utilizado para definir C�digo Protesto do t�tulo na remessa
    function DefineTipoDiasProtesto(const ACBrTitulo: TACBrTitulo): String; virtual; //Utilizado para definir Tipo de Dias Protesto na remessa
    function DefineAceite(const ACBrTitulo: TACBrTitulo): String; virtual;           //Utilizado para definir o tipo de aceite na gera��o da remessa
    function DefineCodigoMoraJuros(const ACBrTitulo: TACBrTitulo): String; virtual; //Utilizado para definir o C�digo de Mora na Remessa.
    function DefineDataMoraJuros(const ACBrTitulo: TACBrTitulo; AFormat: String = 'ddmmyyyy'): String; virtual;   //Utilizado para definir a Data de Mora Juros na Remessa.
    function DefineCodigoDesconto(const ACBrTitulo: TACBrTitulo): String; virtual;  //Utilizando para definir C�digo de Desconto na Remessa
    function DefineDataDesconto(const ACBrTitulo: TACBrTitulo; AFormat: String = 'ddmmyyyy'): String; virtual;    //Utilizado para definir a Data de Desconto na Remessa
    function DefineCodigoMulta(const ACBrTitulo: TACBrTitulo): String; virtual;     //Utilizado para definir o Codigo Multa na Remessa
    function DefineDataMulta(const ACBrTitulo: TACBrTitulo; AFormat: String = 'ddmmyyyy'): String; virtual;       //Utilizado para definir data multa na Remessa
    function DefineNossoNumeroRetorno(const Retorno: String): String; virtual;      //Define a leitura do Nosso N�mero no Retorno
    function DefineTamanhoContaRemessa: Integer; virtual;                           //Define o tamnhano da Conta para Remessa e Retorno  (pode ser diferente do tamanho padr�o no Boleto)
    function DefinePosicaoNossoNumeroRetorno: Integer; virtual;                     //Define posi��o para leitura de Retorno campo: NossoNumero
    function DefineTamanhoNossoNumeroRetorno: Integer; virtual;                     //Define posi��o para leitura de Retorno campo: NossoNumero
    function DefinePosicaoCarteiraRetorno:Integer; virtual;                         //Define posi��o para leitura de Retorno campo: NumeroDocumento

    function DefineTipoInscricao: String; virtual;                            //Utilizado para definir Tipo de Inscri��o na Remessa
    function DefineResponsEmissao: String; virtual;                           //Utilizado para definir Respons�vel Emiss�o na Remessa
    function DefineCampoConvenio(const ATam: Integer = 20): String; virtual;  //Utilizado para definir campo convenio na Remessa
    function DefineCampoDigitoAgencia: String; virtual;                       //Utilizado para definir Digito da Agencia na Remessa
    function DefineCampoDigitoConta: String; virtual;                         //Utilizado para definir Digito da Conta na Remessa
    function DefineCampoDigitoAgenciaConta: String; virtual;                  //Utilizado para definir Digito da Agencia / Conta na Remessa
    function DefinePosicaoUsoExclusivo: String; virtual;                      //Utilizado para definir Posi��es de uso exclusivo FEBRABAN na Remessa
    function DefineCodBeneficiarioHeader: String; virtual;                    //Utilizado para definir CodBeneficiario no Header da Remessa
    function DefineTipoDocumento: String; virtual;                            //Define o Tipo de Documento na remessa

  public
    Constructor create(AOwner: TACBrBanco);
    Destructor Destroy; override ;

    property ACBrBanco : TACBrBanco      read fpAOwner;
    property Numero    : Integer         read fpNumero;
    property Digito    : Integer         read fpDigito;
    property Nome      : String          read fpNome;
    Property Modulo    : TACBrCalcDigito read fpModulo;
    property TamanhoMaximoNossoNum: Integer    read fpTamanhoMaximoNossoNum;
    property TamanhoNumeroDocumento: Integer   read fpTamanhoNumeroDocumento;
    property TamanhoAgencia  :Integer read fpTamanhoAgencia;
    property TamanhoConta    :Integer read fpTamanhoConta;
    property TamanhoCarteira :Integer read fpTamanhoCarteira;
    property OrientacoesBanco: TStringList read fpOrientacoesBanco;
    property CodigosMoraAceitos: String read fpCodigosMoraAceitos;
    property CodigosGeracaoAceitos: String read fpCodigosGeracaoAceitos;
    property LocalPagamento  : String read GetLocalPagamento;
    property NumeroCorrespondente : Integer read fpNumeroCorrespondente;
    Property LayoutVersaoArquivo  : Integer read fpLayoutVersaoArquivo;
    Property LayoutVersaoLote     : Integer read fpLayoutVersaoLote;
    property CasasDecimaisMoraJuros: Integer read fpCasasDecimaisMoraJuros;
    property ModuloMultiplicadorInicial: Integer read fpModuloMultiplicadorInicial;
    property ModuloMultiplicadorFinal: Integer read fpModuloMultiplicadorFinal;
    property ModuloMultiplicadorAtual: Integer read fpModuloMultiplicadorAtual;
    property CodParametroMovimento: String read fpCodParametroMovimento;
    property DensidadeGravacao: String read fpDensidadeGravacao;
    property QtdRegsLote: Integer read fpQtdRegsLote write fpQtdRegsLote;
    property QtdRegsCobranca: Integer read fpQtdRegsCobranca write fpQtdRegsCobranca;
    property VlrRegsCobranca: Double read fpVlrRegsCobranca write fpVlrRegsCobranca;

    function CalcularDigitoVerificador(const ACBrTitulo : TACBrTitulo): String; virtual;
    function CalcularTamMaximoNossoNumero(const Carteira : String; const NossoNumero : String = ''; const Convenio: String = ''): Integer; virtual;

    function TipoDescontoToString(const AValue: TACBrTipoDesconto):string; virtual;
    function TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String; virtual;
    function CodOcorrenciaToTipo(const CodOcorrencia:Integer): TACBrTipoOcorrencia; virtual;
    function TipoOCorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia): String; virtual;
    function CodMotivoRejeicaoToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia;CodMotivo:Integer): String; overload; virtual;
    function CodMotivoRejeicaoToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia; const CodMotivo: String): String; overload; virtual;

    function CompOcorrenciaOutrosDadosToDescricao(const CompOcorrencia: TACBrComplementoOcorrenciaOutrosDados): String; virtual;
    function CompOcorrenciaOutrosDadosToCodigo(const CompOcorrencia: TACBrComplementoOcorrenciaOutrosDados): String; virtual;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia; virtual;
    function TipoOcorrenciaToCodRemessa(const TipoOcorrencia: TACBrTipoOcorrencia): String; virtual;

    function MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String; virtual;
    function MontarCampoNossoNumero(const ACBrTitulo : TACBrTitulo): String; virtual;
    function MontarLinhaDigitavel(const CodigoBarras: String; ACBrTitulo : TACBrTitulo): String; virtual;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String; virtual;
    function MontarCampoCarteira(const ACBrTitulo: TACBrTitulo): String; virtual;

    procedure GerarRegistroHeader400(NumeroRemessa : Integer; ARemessa:TStringList);  Virtual;
    function GerarRegistroHeader240(NumeroRemessa : Integer): String;    Virtual;
    procedure GerarRegistroTransacao400(ACBrTitulo : TACBrTitulo; aRemessa: TStringList); Virtual;
    function GerarRegistroTransacao240(ACBrTitulo : TACBrTitulo): String; Virtual;
    procedure GerarRegistroTrailler400(ARemessa:TStringList);  Virtual;
    function GerarRegistroTrailler240(ARemessa:TStringList): String;  Virtual;
    Procedure LerRetorno400(ARetorno:TStringList); Virtual;
    Procedure LerRetorno240(ARetorno:TStringList); Virtual;

    function CalcularNomeArquivoRemessa : String; Virtual;
    function ValidarDadosRetorno(const AAgencia, AContaCedente: String; const ACNPJCPF: String= '';
       const AValidaCodCedente: Boolean= False ): Boolean; Virtual;

  end;


  { TACBrBanco }
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(piacbrAllPlatforms)]
  {$ENDIF RTL230_UP}
  TACBrBanco = class(TComponent)
  private
    fACBrBoleto        : TACBrBoleto;
    fNumeroBanco       : Integer;
    fTipoCobranca      : TACBrTipoCobranca;
    fBancoClass        : TACBrBancoClass;
    fLocalPagamento    : String;
    function GetNome   : String;
    function GetDigito : Integer;
    function GetNumero : Integer;
    function GetOrientacoesBanco: TStringList;
    function GetTamanhoAgencia: Integer;
    function GetTamanhoCarteira: Integer;
    function GetTamanhoConta: Integer;
    function GetTamanhoMaximoNossoNum : Integer;
    function GetTamanhoNumeroDocumento : Integer;
    function GetCodigosMoraAceitos: String;
    function GetCodigosGeracaoAceitos: string;
    function GetLocalPagamento: String;
    function GetNumeroCorrespondente: Integer;
    function GetLayoutVersaoArquivo    :Integer;
    function GetLayoutVersaoLote       :Integer;
    function GetCasasDecimaisMoraJuros :Integer;
    function GetDensidadeGravacao : String;

    procedure SetDigito(const AValue: Integer);
    procedure SetNome(const AValue: String);
    procedure SetTipoCobranca(const AValue: TACBrTipoCobranca);
    procedure SetNumero(const AValue: Integer);
    procedure SetTamanhoMaximoNossoNum(Const Avalue:Integer);
    procedure SetOrientacoesBanco(Const Avalue: TStringList);
    procedure SetLocalPagamento(const AValue: String);
    procedure SetNumeroCorrespondente(const AValue: Integer);
    procedure SetLayoutVersaoArquivo(const AValue: Integer);
    procedure SetLayoutVersaoLote(const AValue: Integer);
    procedure SetCasasDecimaisMoraJuros(const AValue: Integer);
    procedure SetDensidadeGravacao(const AValue: String);
  public
    constructor Create( AOwner : TComponent); override;
    destructor Destroy ; override ;

    property ACBrBoleto : TACBrBoleto     read fACBrBoleto;
    property BancoClass : TACBrBancoClass read fBancoClass ;
    property TamanhoAgencia        :Integer read GetTamanhoAgencia;
    property TamanhoConta          :Integer read GetTamanhoConta;
    property TamanhoCarteira       :Integer read GetTamanhoCarteira;
    property CodigosMoraAceitos    :String  read GetCodigosMoraAceitos;
    property CodigosGeracaoAceitos :String  read GetCodigosGeracaoAceitos;
    property TamanhoNumeroDocumento:Integer  read GetTamanhoNumeroDocumento;

    function TipoOcorrenciaToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia): String;
    function CodOcorrenciaToTipo(const CodOcorrencia:Integer): TACBrTipoOcorrencia;
    function TipoOCorrenciaToCod(const TipoOcorrencia: TACBrTipoOcorrencia): String;
    function CodMotivoRejeicaoToDescricao(const TipoOcorrencia: TACBrTipoOcorrencia;CodMotivo:Integer): String;

    function CompOcorrenciaOutrosDadosToDescricao(const CompOcorrencia: TACBrComplementoOcorrenciaOutrosDados): String; virtual;
    function CompOcorrenciaOutrosDadosToCodigo(const CompOcorrencia: TACBrComplementoOcorrenciaOutrosDados): String; virtual;

    function CodOcorrenciaToTipoRemessa(const CodOcorrencia:Integer): TACBrTipoOcorrencia;
    function TipoOcorrenciaToCodRemessa(const TipoOcorrencia: TACBrTipoOcorrencia ): String;
    function CalcularDigitoVerificador(const ACBrTitulo : TACBrTitulo): String;
    function CalcularTamMaximoNossoNumero(const Carteira : String; const NossoNumero : String = ''; const Convenio: String = ''): Integer;

    function MontarCampoCarteira(const ACBrTitulo: TACBrTitulo): String;
    function MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String;
    function MontarCampoNossoNumero(const ACBrTitulo :TACBrTitulo): String;
    function MontarCodigoBarras(const ACBrTitulo : TACBrTitulo): String;
    function MontarLinhaDigitavel(const CodigoBarras: String; ACBrTitulo : TACBrTitulo): String;

    procedure GerarRegistroHeader400(NumeroRemessa : Integer; ARemessa:TStringList);
    function GerarRegistroHeader240(NumeroRemessa : Integer): String;
    procedure GerarRegistroTransacao400(ACBrTitulo : TACBrTitulo;aRemessa: TStringList);
    function GerarRegistroTransacao240(ACBrTitulo : TACBrTitulo): String;
    procedure GerarRegistroTrailler400(ARemessa:TStringList);
    function GerarRegistroTrailler240(ARemessa:TStringList): String;

    procedure LerRetorno400(ARetorno:TStringList);
    procedure LerRetorno240(ARetorno:TStringList);

    function CalcularNomeArquivoRemessa : String;
    function ValidarDadosRetorno(const AAgencia, AContaCedente: String; const ACNPJCPF: String= '';
       const AValidaCodCedente: Boolean= False ): Boolean;
  published
    property Numero    : Integer        read GetNumero  write SetNumero default 0;
    property Digito    : Integer        read GetDigito  write SetDigito stored false;
    property Nome      : String         read GetNome    write SetNome   stored false;
    property TamanhoMaximoNossoNum :Integer read GetTamanhoMaximoNossoNum  write SetTamanhoMaximoNossoNum;
    property TipoCobranca : TACBrTipoCobranca read fTipoCobranca   write SetTipoCobranca;
    property OrientacoesBanco : TStringList read GetOrientacoesBanco write SetOrientacoesBanco;
    property LocalPagamento : String read GetLocalPagamento write SetLocalPagamento;
    property NumeroCorrespondente : Integer read GetNumeroCorrespondente write SetNumeroCorrespondente default 0;
    property LayoutVersaoArquivo  : Integer read GetLayoutVersaoArquivo write SetLayoutVersaoArquivo;
    property LayoutVersaoLote     : Integer read GetLayoutVersaoLote write SetLayoutVersaoLote;
    property CasasDecimaisMoraJuros: Integer read GetCasasDecimaisMoraJuros write SetCasasDecimaisMoraJuros;
    property DensidadeGravacao : string read GetDensidadeGravacao write SetDensidadeGravacao;
  end;

  { TACBrCedenteWS }
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(piacbrAllPlatforms)]
  {$ENDIF RTL230_UP}
  TACBrCedenteWS = class(TComponent)
  private
    FClientID: string;
    FClientSecret: string;
    FKeyUser: string;
    FScope: string;

    procedure SetClientID(const Value: string);
    procedure SetClientSecret(const Value: string);
    procedure SetKeyUser(const Value: string);
    procedure SetScope(const Value: string);

  public
    constructor Create(AOwner: TComponent); override;

  published
    property ClientID: string read fClientID write setClientID;
    property ClientSecret: string read fClientSecret write setClientSecret;
    property KeyUser: string read fKeyUser write setKeyUser;
    property Scope: string read fScope write setScope;

  end;

  { TACBrCedente }
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(piacbrAllPlatforms)]
  {$ENDIF RTL230_UP}
  TACBrCedente = class(TComponent)
  private
    fCodigoTransmissao: String;
    fLogradouro: String;
    fBairro: String;
    fNumeroRes: String;
    fCEP: String;
    fCidade: String;
    fCodigoCedente: String;
    fComplemento: String;
    fTelefone: String;
    fNomeCedente   : String;
    fFantasiaCedente : String;
    fAgencia       : String;
    fAgenciaDigito : String;
    fConta         : String;
    fContaDigito   : String;
    fModalidade    : String;
    fConvenio      : String;
    fTipoDocumento : TACBrTipoDocumento;
    fResponEmissao : TACBrResponEmissao;
    fCaracTitulo:TACBrCaracTitulo;
    fCNPJCPF       : String;
    fTipoInscricao : TACBrPessoaCedente;
    fUF            : String;
    fAcbrBoleto    : TACBrBoleto;
    fTipoCarteira: TACBrTipoCarteira;
    fDigitoVerificadorAgenciaConta: String;
    fCedenteWS: TACBrCedenteWS;
    fIdentDistribuicao: TACBrIdentDistribuicao; 
    fOperacao: string;
    procedure SetAgencia(const AValue: String);
    procedure SetCNPJCPF ( const AValue: String ) ;
    procedure SetConta(const AValue: String);
    procedure SetTipoInscricao ( const AValue: TACBrPessoaCedente ) ;
  public
    constructor Create( AOwner : TComponent ) ; override ;
    destructor Destroy; override;

    property ACBrBoleto  : TACBrBoleto read fACBrBoleto;
  published
    property Nome         : String read fNomeCedente   write fNomeCedente;
    property FantasiaCedente: String read fFantasiaCedente   write fFantasiaCedente;
    property CodigoCedente: String read fCodigoCedente write fCodigoCedente;
    property CodigoTransmissao : String read fCodigoTransmissao write fCodigoTransmissao;
    property Agencia      : String read fAgencia       write SetAgencia;
    property AgenciaDigito: String read fAgenciaDigito write fAgenciaDigito;
    property Conta        : String read fConta         write SetConta;
    property ContaDigito  : String read fContaDigito   write fContaDigito;
    property Modalidade   : String read fModalidade    write fModalidade;
    property Convenio     : String read fConvenio      write fConvenio;
    property TipoDocumento : TACBrTipoDocumento read fTipoDocumento write fTipoDocumento default Tradicional;
    property TipoCarteira : TACBrTipoCarteira read fTipoCarteira write fTipoCarteira default tctSimples;
    property ResponEmissao: TACBrResponEmissao read fResponEmissao  write fResponEmissao default tbCliEmite ;
    property CaracTitulo : TACBrCaracTitulo read fCaracTitulo  write fCaracTitulo default tcSimples;
    property CNPJCPF     : String  read fCNPJCPF  write SetCNPJCPF;
    property TipoInscricao: TACBrPessoaCedente  read fTipoInscricao write  SetTipoInscricao;
    property Logradouro  : String  read fLogradouro  write fLogradouro;
    property NumeroRes   : String  read fNumeroRes   write fNumeroRes;
    property Complemento : String  read fComplemento write fComplemento;
    property Bairro      : String  read fBairro      write fBairro;
    property Cidade      : String  read fCidade      write fCidade;
    property UF          : String  read fUF          write fUF;
    property CEP         : String  read fCEP         write fCEP;
    property Telefone    : String  read fTelefone    write fTelefone;
    property DigitoVerificadorAgenciaConta  : String read fDigitoVerificadorAgenciaConta write fDigitoVerificadorAgenciaConta;
    property CedenteWS: TACBrCedenteWS read fCedenteWS;
    property IdentDistribuicao: TACBrIdentDistribuicao read fIdentDistribuicao  write fIdentDistribuicao default tbClienteDistribui;
    property Operacao: string read fOperacao write fOperacao;
  end;

  { TACBrWebService }
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(piacbrAllPlatforms)]
  {$ENDIF RTL230_UP}
  TACBrWebService = class(TDFeSSL)
  private
    fAmbiente: TpcnTipoAmbiente;
    fOperacao: TOperacao;
    fVersaoDF: String;
  public
    constructor Create(AOwner: TComponent); reintroduce; virtual;
    destructor Destroy; override;

    function Enviar: Boolean; virtual;

  published
    property Ambiente: TpcnTipoAmbiente read fAmbiente write fAmbiente;
    property Operacao: TOperacao read fOperacao write fOperacao;
    property VersaoDF: string read fVersaoDF write fVersaoDF;

  end;

   { TACBrArquivos }
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(piacbrAllPlatforms)]
  {$ENDIF RTL230_UP}
  TACBrArquivos = class(TPersistent)
  private
    fLogRegistro: Boolean;
    fPathGravarRegistro: String;
  public
    Constructor Create;
    procedure Assign(Source: TPersistent); override;

  published
    property LogRegistro: Boolean read fLogRegistro write fLogRegistro;
    property PathGravarRegistro: string read fPathGravarRegistro write fPathGravarRegistro;

  end;

  { TConfiguracoes }
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(piacbrAllPlatforms)]
  {$ENDIF RTL230_UP}
  TConfiguracoes = class(TComponent)
  private
    fArquivos: TACBrArquivos;
    fWebService: TACBrWebService;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Arquivos: TACBrArquivos read fArquivos write fArquivos;
    property WebService: TACBrWebService read fWebService write fWebService;

  end;


  TACBrTituloLiquidacao = class
  private
    fBanco: Integer;
    fAgencia: String;
    fOrigem: String;
    fFormaPagto: String;
  public
    property Banco     : Integer read fBanco      write fBanco;
    property Agencia   : String  read fAgencia    write fAgencia;
    property Origem    : String  read fOrigem     write fOrigem;
    property FormaPagto: String  read fFormaPagto write fFormaPagto;
  end;

  TACBrSacadoAvalista = class
  private
    fTipoPessoa  : TACBrPessoa;

    fNomeAvalista: String;
    fCNPJCPF     : String;
    fLogradouro  : String;
    fNumero      : String;
    fComplemento : String;
    fBairro      : String;
    fCidade      : String;
    fUF          : String;
    fCEP         : String;
    fEmail       : String;
    fFone        : String;
    fInscricaoNr : String;
  public
    property Pessoa      : TACBrPessoa read fTipoPessoa  write fTipoPessoa;
    property NomeAvalista: String  read fNomeAvalista    write fNomeAvalista;
    property CNPJCPF     : String  read fCNPJCPF     write fCNPJCPF;
    property Logradouro  : String  read fLogradouro  write fLogradouro;
    property Numero      : String  read fNumero      write fNumero;
    property Complemento : String  read fComplemento write fComplemento;
    property Bairro      : String  read fBairro      write fBairro;
    property Cidade      : String  read fCidade      write fCidade;
    property UF          : String  read fUF          write fUF;
    property CEP         : String  read fCEP         write fCEP;
    property Email       : String  read fEmail       write fEmail;
    property Fone        : String  read fFone        write fFone;
    property InscricaoNr : String  read fInscricaoNr write fInscricaoNr;
  end;

  { TACBrSacado }

  TACBrSacado = class
  private
    fSacadoAvalista : TACBrSacadoAvalista;
    fTipoPessoa     : TACBrPessoa;
    fNomeSacado  : String;
    fCNPJCPF     : String;
    fLogradouro  : String;
    fNumero      : String;
    fComplemento : String;
    fBairro      : String;
    fCidade      : String;
    fUF          : String;
    fCEP         : String;
    fEmail       : String;
    fFone        : String;
    FMensagem    : String;
    function GetAvalista: String;
    procedure SetAvalista(const AValue: String);
    procedure SetMensagem(const AValue: String);
  public
    constructor Create;
    destructor Destroy; override;

    property Pessoa         : TACBrPessoa         read fTipoPessoa     write fTipoPessoa;
    property SacadoAvalista : TACBrSacadoAvalista read fSacadoAvalista write fSacadoAvalista;

    property Avalista    : String  read GetAvalista write SetAvalista;
    property NomeSacado  : String  read fNomeSacado  write fNomeSacado;
    property CNPJCPF     : String  read fCNPJCPF     write fCNPJCPF;
    property Logradouro  : String  read fLogradouro  write fLogradouro;
    property Numero      : String  read fNumero      write fNumero;
    property Complemento : String  read fComplemento write fComplemento;
    property Bairro      : String  read fBairro      write fBairro;
    property Cidade      : String  read fCidade      write fCidade;
    property UF          : String  read fUF          write fUF;
    property CEP         : String  read fCEP         write fCEP;
    property Email       : String  read fEmail       write fEmail;
    property Fone        : String  read fFone        write fFone;
    property Mensagem    : String  read FMensagem    write SetMensagem;
  end;

  { TACBrDadosNFe }

  TACBrDadosNFe = class
  private
    fChaveNFe: String;
    fEmissaoNFe: TDateTime;
    fNumNFe: String;
    fValorNFe: Currency;
  public

   property NumNFe     : String read fNumNFe write fNumNFe;
   property ValorNFe   : Currency read fValorNFe write fValorNFe;
   property EmissaoNFe : TDateTime read fEmissaoNFe write fEmissaoNFe;
   property ChaveNFe   : String read fChaveNFe write fChaveNFe;
  end;

  { TListadeNFes }

  TACBrListadeNFes = class(TObjectList)
  protected
    procedure SetObject (Index: Integer; Item: TACBrDadosNFe);
    function  GetObject (Index: Integer): TACBrDadosNFe;
    procedure Insert (Index: Integer; Obj: TACBrDadosNFe);
  public
    function Add (Obj: TACBrDadosNFe): Integer;
    property Objects [Index: Integer]: TACBrDadosNFe
      read GetObject write SetObject; default;
  end;

  { TACBrTitulo }

  TACBrTitulo = class
  private
    fInstrucao1        : String;
    fInstrucao2        : String;
    fInstrucao3        : String;
    fLocalPagamento    : String;
    fOcorrenciaOriginal: TACBrOcorrencia;
    fTipoDesconto      : TACBrTipoDesconto;
    fTipoDesconto2     : TACBrTipoDesconto;
    fParcela           : Integer;
    fPercentualMulta   : Double;
    fMultaValorFixo    : Boolean;
    fSeuNumero         : String;
    fTipoDiasProtesto  : TACBrTipoDiasIntrucao;
    fTipoDiasNegativacao: TACBrTipoDiasIntrucao;
    fTipoImpressao     : TACBrTipoImpressao;
    fTotalParcelas     : Integer;
    fValorDescontoAntDia: Currency;
    fVencimento        : TDateTime;
    fDataDocumento     : TDateTime;
    fNumeroDocumento   : String;
    fEspecieDoc        : String;
    fAceite            : TACBrAceiteTitulo;
    fDataProcessamento : TDateTime;
    fNossoNumero       : String;
    fNossoNumeroCorrespondente: String;
    fUsoBanco          : String;
    fCarteira          : String;
    fEspecieMod        : String;
    fValorDocumento    : Currency;
    fMensagem          : TStrings;
    fInformativo       : TStrings;
    fInstrucoes        : TStrings;
    fSacado            : TACBrSacado;
    fLiquidacao        : TACBrTituloLiquidacao;
    fDetalhamento      : TStrings;
    fVerso             : Boolean;
    fArquivoLogoEmp    : String;
    fCompetencia       : string;

    fMotivoRejeicaoComando          : TStrings;
    fDescricaoMotivoRejeicaoComando : TStrings;

    fDataOcorrencia       : TDateTime;
    fDataCredito          : TDateTime;
    fDataAbatimento       : TDateTime;
    fDataDesconto         : TDateTime;
    fDataDesconto2        : TDateTime;
    fDataDesconto3        : TDateTime;
    fDataMoraJuros        : TDateTime;
    fDataMulta            : TDateTime;
    fDataProtesto         : TDateTime;
    fDiasDeProtesto       : Integer;
    fDataNegativacao      : TDateTime;
    fDiasDeNegativacao    : Integer;
    fDataBaixa            : TDateTime;
    fDataLimitePagto      : TDateTime;
    fValorDespesaCobranca : Currency;
    fValorAbatimento      : Currency;
    fValorDesconto        : Currency;
    fValorDesconto2       : Currency;
    fValorDesconto3       : Currency;
    fValorMoraJuros       : Currency;
    fValorIOF             : Currency;
    fValorOutrasDespesas  : Currency;
    fValorOutrosCreditos  : Currency;
    fValorRecebido        : Currency;
    fReferencia           : String;
    fVersao               : String;
    fACBrBoleto           : TACBrBoleto;
    fTextoLivre           : String;
    fCodigoMora           : String;
    fpLinhaDigitada       : String;
    fCodigoLiquidacao     : String;
    fCodigoLiquidacaoDescricao: String;
    fCarteiraEnvio        : TACBrCarteiraEnvio;
    fCodigoNegativacao    : TACBrCodigoNegativacao;
    fCodigoDesconto       : TACBrCodigoDesconto;
    fCodigoMoraJuros      : TACBrCodigoJuros;
    fCodigoMulta          : TACBrCodigoMulta;

    fCodigoGeracao        : String;
    fValorPago            : Currency;
    fCaracTitulo          : TACBrCaracTitulo;
    fListaDadosNFe        : TACBrListadeNFes;
    fTipoPagamento: TTipo_Pagamento;
    fQtdePagamentoParcial: Integer;
    fQtdeParcelas: Integer;
    fValorMinPagamento: Currency;
    fValorMaxPagamento: Currency;
    fPercentualMinPagamento: Currency;
    fPercentualMaxPagamento: Currency;

    procedure SetCarteira(const AValue: String);
    procedure SetCodigoMora(const AValue: String);
    procedure SetDiasDeProtesto(AValue: Integer);
    procedure SetDiasDeNegativacao(AValue: Integer);
    procedure SetNossoNumero ( const AValue: String ) ;
    procedure SetParcela ( const AValue: Integer ) ;
    procedure SetTipoDiasProtesto(AValue: TACBrTipoDiasIntrucao);
    procedure SetTipoDiasNegativacao(AValue: TACBrTipoDiasIntrucao);
    procedure SetTotalParcelas ( const AValue: Integer );
    procedure SetCodigoGeracao (const AValue: String);
    procedure SetDataProtesto(AValue: TDateTime);
    procedure SetDataNegativacao(AValue: TDateTime);
    procedure SetVencimento(AValue: TDateTime);
    procedure setValorDocumento(const AValue: Currency);
    procedure AtualizaDadosProtesto();
    procedure AtualizaDadosNegativacao();
   public
     constructor Create(ACBrBoleto:TACBrBoleto);
     destructor Destroy; override;
     procedure CarregaLogoEmp( const PictureLogo : TPicture );

     procedure Imprimir();
     procedure GerarPDF();
     procedure EnviarEmail(const sPara, sAssunto: String; sMensagem: TStrings;
      EnviaPDF: Boolean; sCC: TStrings = Nil; Anexos: TStrings = Nil);

     property ACBrBoleto        : TACBrBoleto read fACBrBoleto;
     property LocalPagamento    : String      read fLocalPagamento    write fLocalPagamento;
     property Vencimento        : TDateTime   read fVencimento        write SetVencimento;
     property DataDocumento     : TDateTime   read fDataDocumento     write fDataDocumento;
     property NumeroDocumento   : String      read fNumeroDocumento   write fNumeroDocumento ;
     property EspecieDoc        : String      read fEspecieDoc        write fEspecieDoc;
     property Aceite            : TACBrAceiteTitulo   read fAceite           write fAceite      default atNao;
     property DataProcessamento : TDateTime   read fDataProcessamento write fDataProcessamento;
     property NossoNumero       : String      read fNossoNumero       write SetNossoNumero;
     property NossoNumeroCorrespondente : String  read fNossoNumeroCorrespondente write fNossoNumeroCorrespondente;
     property UsoBanco          : String      read fUsoBanco          write fUsoBanco;
     property Carteira          : String      read fCarteira          write SetCarteira;
     property CarteiraEnvio     : TACBrCarteiraEnvio read fCarteiraEnvio write fCarteiraEnvio default tceCedente;
     property CodigoDesconto    : TACBrCodigoDesconto    read fCodigoDesconto    write fCodigoDesconto;
     property CodigoMoraJuros   : TACBrCodigoJuros       read fCodigoMoraJuros   write fCodigoMoraJuros default cjIsento;
     property CodigoMulta       : TACBrCodigoMulta       read fCodigoMulta       write fCodigoMulta;
     property CodigoNegativacao : TACBrCodigoNegativacao read fCodigoNegativacao write fCodigoNegativacao default cnNaoProtestar;

     property EspecieMod        : String      read fEspecieMod        write fEspecieMod;
     property ValorDocumento    : Currency    read fValorDocumento    write setValorDocumento;
     property Mensagem          : TStrings    read fMensagem          write fMensagem;
     property Informativo       : TStrings    read fInformativo       write fInformativo;
     property Instrucao1        : String      read fInstrucao1        write fInstrucao1;
     property Instrucao2        : String      read fInstrucao2        write fInstrucao2;
     property Instrucao3        : String      read fInstrucao3        write fInstrucao3;
     property Sacado            : TACBrSacado read fSacado            write fSacado;
     property Parcela           :Integer      read fParcela           write SetParcela default 1;
     property TotalParcelas     :Integer      read fTotalParcelas     write SetTotalParcelas default 1;
     property CodigoLiquidacao  : String      read fCodigoLiquidacao  write fCodigoLiquidacao;
     property CodigoLiquidacaoDescricao : String read fCodigoLiquidacaoDescricao write fCodigoLiquidacaoDescricao;
     property Detalhamento      : TStrings    read fDetalhamento      write fDetalhamento;
     property Verso             : Boolean     read fVerso             write fVerso default False;
     property ArquivoLogoEmp    : String      read fArquivoLogoEmp    write fArquivoLogoEmp;
     property Competencia       : string      read fCompetencia       write fCompetencia;

     property OcorrenciaOriginal : TACBrOcorrencia read  fOcorrenciaOriginal write fOcorrenciaOriginal;
     property TipoDesconto       : TACBrTipoDesconto read fTipoDesconto write fTipoDesconto;
     property TipoDesconto2      : TACBrTipoDesconto read fTipoDesconto2 write fTipoDesconto2;

     property MotivoRejeicaoComando          : TStrings    read fMotivoRejeicaoComando  write fMotivoRejeicaoComando;
     property DescricaoMotivoRejeicaoComando : TStrings    read fDescricaoMotivoRejeicaoComando  write fDescricaoMotivoRejeicaoComando;

     property DataOcorrencia                 : TDateTime read fDataOcorrencia    write fDataOcorrencia;
     property DataCredito                    : TDateTime read fDataCredito       write fDataCredito;
     property DataAbatimento                 : TDateTime read fDataAbatimento    write fDataAbatimento;
     property DataDesconto                   : TDateTime read fDataDesconto      write fDataDesconto;
     property DataDesconto2                  : TDateTime read fDataDesconto2     write fDataDesconto2;
     property DataDesconto3                  : TDateTime read fDataDesconto3     write fDataDesconto3;
     property DataMoraJuros                  : TDateTime read fDataMoraJuros     write fDataMoraJuros;
     property DataMulta                      : TDateTime read fDataMulta         write fDataMulta;
     property DataProtesto                   : TDateTime read fDataProtesto      write SetDataProtesto;
     property DiasDeProtesto                 : Integer   read fDiasDeProtesto    write SetDiasDeProtesto;
     property DataNegativacao                : TDateTime read fDataNegativacao   write SetDataNegativacao;
     property DiasDeNegativacao              : Integer   read fDiasDeNegativacao write SetDiasDeNegativacao;
     property DataBaixa                      : TDateTime read fDataBaixa         write fDataBaixa;
     property DataLimitePagto                : TDateTime read fDataLimitePagto   write fDataLimitePagto;

     property ValorDespesaCobranca : Currency read fValorDespesaCobranca  write fValorDespesaCobranca;
     property ValorAbatimento      : Currency read fValorAbatimento       write fValorAbatimento;
     property ValorDesconto        : Currency read fValorDesconto         write fValorDesconto;
     property ValorDesconto2       : Currency read fValorDesconto2        write fValorDesconto2;
     property ValorDesconto3       : Currency read fValorDesconto3        write fValorDesconto3;
     property ValorMoraJuros       : Currency read fValorMoraJuros        write fValorMoraJuros;
     property ValorIOF             : Currency read fValorIOF              write fValorIOF;
     property ValorOutrasDespesas  : Currency read fValorOutrasDespesas   write fValorOutrasDespesas;
     property ValorOutrosCreditos  : Currency read fValorOutrosCreditos   write fValorOutrosCreditos;
     property ValorPago            : Currency read fValorPago             write fValorPago;
     property ValorRecebido        : Currency read fValorRecebido         write fValorRecebido;
     property Referencia           : String   read fReferencia            write fReferencia;
     property Versao               : String   read fVersao                write fVersao;
     property SeuNumero            : String   read fSeuNumero             write fSeuNumero;
     property PercentualMulta      : Double   read fPercentualMulta       write fPercentualMulta;
     property MultaValorFixo       : Boolean   read fMultaValorFixo       write fMultaValorFixo;
     property ValorDescontoAntDia  : Currency read fValorDescontoAntDia  write  fValorDescontoAntDia;
     property TextoLivre : String read fTextoLivre write fTextoLivre;
     property CodigoMora : String read fCodigoMora write SetCodigoMora;
     property TipoDiasProtesto     : TACBrTipoDiasIntrucao read fTipoDiasProtesto write SetTipoDiasProtesto;
     property TipoDiasNegativacao  : TACBrTipoDiasIntrucao read fTipoDiasNegativacao write SetTipoDiasNegativacao;
     property TipoImpressao        : TACBrTipoImpressao read fTipoImpressao write fTipoImpressao;
     property LinhaDigitada : String read fpLinhaDigitada;
     property CodigoGeracao: String read fCodigoGeracao write SetCodigoGeracao;
     property Liquidacao: TACBrTituloLiquidacao read fLiquidacao write fLiquidacao;
     property CaracTitulo: TACBrCaracTitulo read fCaracTitulo  write fCaracTitulo default tcSimples;

     property TipoPagamento: TTipo_Pagamento read fTipoPagamento write fTipoPagamento default tpNao_Aceita_Valor_Divergente;
     property QtdePagamentoParcial: integer read fQtdePagamentoParcial write fQtdePagamentoParcial;
     property QtdeParcelas: integer read fQtdeParcelas write fQtdeParcelas;
     property ValorMinPagamento: currency read fValorMinPagamento write fValorMinPagamento;
     property ValorMaxPagamento: currency read fValorMaxPagamento write fValorMaxPagamento;
     property PercentualMinPagamento: currency read fPercentualMinPagamento write fPercentualMinPagamento;
     property PercentualMaxPagamento: currency read fPercentualMaxPagamento write fPercentualMaxPagamento;
     property ListaDadosNFe : TACBrListadeNFes read fListaDadosNFe;

     function CriarNFeNaLista: TACBrDadosNFe;
   end;

  { TListadeBoletos }
  TListadeBoletos = class(TObjectList)
  protected
    procedure SetObject (Index: Integer; Item: TACBrTitulo);
    function  GetObject (Index: Integer): TACBrTitulo;
    procedure Insert (Index: Integer; Obj: TACBrTitulo);
  public
    function Add (Obj: TACBrTitulo): Integer;
    property Objects [Index: Integer]: TACBrTitulo
      read GetObject write SetObject; default;
  end;
  {TACBrTipoOcorrenciaRemessa}
  TACBrOcorrenciaRemessa = Record
    Tipo     : TACBrTipoOcorrencia;
    Descricao: String;
  end;

  TACBrOcorrenciasRemessa =  Array of TACBrOcorrenciaRemessa;

  { TACBrBoleto }
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(piacbrAllPlatforms)]
  {$ENDIF RTL230_UP}

 TACBrBoleto = class( TACBrComponent )
  private
    fBanco: TACBrBanco;
    fACBrBoletoFC: TACBrBoletoFCClass;
    fDirArqRemessa: String;
    fDirArqRetorno: String;
    fLayoutRemessa: TACBrLayoutRemessa;
    fImprimirMensagemPadrao: boolean;
    fListadeBoletos : TListadeBoletos;
    fCedente        : TACBrCedente;
    FMAIL: TACBrMail;
    fNomeArqRemessa: String;
    fNomeArqRetorno: String;
    fNumeroArquivo : integer;     {N�mero seq�encial do arquivo remessa ou retorno}
    fDataArquivo : TDateTime;     {Data da gera��o do arquivo remessa ou retorno}
    fDataCreditoLanc : TDateTime; {Data de cr�dito dos lan�amentos do arquivo retorno}
    fLeCedenteRetorno: boolean;
    fHomologacao: Boolean;
    fRemoveAcentosArqRemessa: Boolean;
    fLerNossoNumeroCompleto: Boolean;
    fConfiguracoes: TConfiguracoes;
    fListaRetornoWeb: TListaRetEnvio;
    procedure SetACBrBoletoFC(const Value: TACBrBoletoFCClass);
    procedure SetMAIL(AValue: TACBrMail);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ListadeBoletos : TListadeBoletos read fListadeBoletos write fListadeBoletos ;
    property ListaRetornoWeb: TListaRetEnvio read fListaRetornoWeb write fListaRetornoWeb;

    function CriarTituloNaLista: TACBrTitulo;
    function CriarRetornoWebNaLista: TRetEnvio;

    procedure Imprimir;

    procedure GerarPDF;
    procedure GerarHTML;
    procedure GerarJPG;

    procedure EnviarEmail(const sPara, sAssunto: String; sMensagem: TStrings;
      EnviaPDF: Boolean; sCC: TStrings = Nil; Anexos: TStrings = Nil);

    procedure AdicionarMensagensPadroes(Titulo : TACBrTitulo; AStringList: TStrings);

    function GerarRemessa(NumeroRemessa : Integer) : String;
    function GerarRemessaStream(NumeroRemessa : Integer; Stream:TStream) : String;
    procedure LerRetorno(AStream : TStream = Nil);
    procedure ChecarDadosObrigatorios;

    function EnviarBoleto: boolean;

    function GetOcorrenciasRemessa() : TACBrOcorrenciasRemessa;
    function GetTipoCobranca(NumeroBanco: Integer; Carteira: String = ''): TACBrTipoCobranca;
    function LerArqIni(const AIniBoletos: String): Boolean;
    function GravarArqIni(DirIniRetorno: string; const NomeArquivo: String): String;
    procedure GravarIniRetornoWeb(DirRetorno: String; const NomeArquivo: String);

  published
    property MAIL  : TACBrMail read FMAIL write SetMAIL;

    property Homologacao    : Boolean            read fHomologacao            write fHomologacao default False;
    property Banco          : TACBrBanco         read fBanco                  write fBanco;
    property Cedente        : TACBrCedente       read fCedente                write fCedente ;
    property NomeArqRemessa : String             read fNomeArqRemessa         write fNomeArqRemessa;
    property DirArqRemessa  : String             read fDirArqRemessa          write fDirArqRemessa;
    property NomeArqRetorno : String             read fNomeArqRetorno         write fNomeArqRetorno;
    property DirArqRetorno  : String             read fDirArqRetorno          write fDirArqRetorno;
    property NumeroArquivo  : integer            read fNumeroArquivo          write fNumeroArquivo;
    property DataArquivo    : TDateTime          read fDataArquivo            write fDataArquivo;
    property DataCreditoLanc: TDateTime          read fDataCreditoLanc        write fDataCreditoLanc;
    property LeCedenteRetorno :boolean           read fLeCedenteRetorno       write fLeCedenteRetorno default false;
    property LayoutRemessa  : TACBrLayoutRemessa read fLayoutRemessa          write fLayoutRemessa default c400;
    property ImprimirMensagemPadrao : Boolean    read fImprimirMensagemPadrao write fImprimirMensagemPadrao default True;
    property ACBrBoletoFC : TACBrBoletoFCClass   read fACBrBoletoFC           write SetACBrBoletoFC;
    property RemoveAcentosArqRemessa: Boolean    read fRemoveAcentosArqRemessa write fRemoveAcentosArqRemessa default False;
    property LerNossoNumeroCompleto : Boolean    read fLerNossoNumeroCompleto write fLerNossoNumeroCompleto default False;
    property Configuracoes: TConfiguracoes       read fConfiguracoes          write fConfiguracoes;
  end;

 {TACBrBoletoFCClass}
 TACBrBoletoFCFiltro = (fiNenhum, fiPDF, fiHTML, fiJPG) ;

 TACBrBoletoFCOnObterLogo = procedure( const PictureLogo : TPicture; const NumeroBanco: Integer ) of object ;
  {$IFDEF RTL230_UP}
  [ComponentPlatformsAttribute(piacbrAllPlatforms)]
  {$ENDIF RTL230_UP}
 TACBrBoletoFCClass = class(TACBrComponent)
  private
    fDirLogo         : String;
    fFiltro          : TACBrBoletoFCFiltro;
    fLayOut          : TACBrBolLayOut;
    fMostrarPreview  : Boolean;
    fMostrarProgresso: Boolean;
    fMostrarSetup    : Boolean;
    fNomeArquivo     : String;
    fPathNomeArquivo : String;
    fNumCopias       : Integer;
    fPrinterName     : String;
    fOnObterLogo     : TACBrBoletoFCOnObterLogo ;
    fSoftwareHouse   : String;
    FPdfSenha        : string;
    FTituloPreview   : string;
    FAlterarEscalaPadrao: Boolean;
    FNovaEscala: Integer;
    FIndiceImprimirIndividual: Integer;
    FCalcularNomeArquivoPDFIndividual: Boolean;
    function ComponentStateDesigning: Boolean;
    function GetArquivoLogo: String;
    function GetDirLogo: String;
    function GetNomeArquivo: String;
    function GetIndiceImprimirIndividual: Integer;
    function GetNomeArquivoPdfIndividual(const ANomeArquivo: String; const AIndex: Integer): String;
    procedure SetACBrBoleto(const Value: TACBrBoleto);
    procedure SetDirLogo(const AValue: String);
    procedure SetNomeArquivo(const AValue: String);
    procedure SetPdfSenha(const Value: string);
    procedure SetTituloPreview(const Value: string);
    procedure SetIndiceImprimirIndividual(const Value: Integer);
  protected
    fACBrBoleto : TACBrBoleto;
    procedure SetNumCopias(AValue: Integer);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function TituloRelatorio: String;
  public

    Constructor Create(AOwner: TComponent); override;

    procedure Imprimir; virtual;
    procedure GerarPDF; virtual;
    procedure GerarHTML; virtual;
    procedure GerarJPG; virtual;

    procedure CarregaLogo( const PictureLogo : TPicture; const NumeroBanco: Integer ) ;

    property ArquivoLogo : String read GetArquivoLogo;
    property IndiceImprimirIndividual: Integer read GetIndiceImprimirIndividual  write SetIndiceImprimirIndividual   default -1;

  published
    property OnObterLogo     : TACBrBoletoFCOnObterLogo read fOnObterLogo write fOnObterLogo ;
    property ACBrBoleto      : TACBrBoleto     read fACBrBoleto       write SetACBrBoleto stored False;
    property LayOut          : TACBrBolLayOut  read fLayOut           write fLayOut           default lPadrao;
    property MostrarPreview  : Boolean         read fMostrarPreview   write fMostrarPreview   default True ;
    property MostrarSetup    : Boolean         read fMostrarSetup     write fMostrarSetup     default True ;
    property MostrarProgresso: Boolean         read fMostrarProgresso write fMostrarProgresso default True ;
    property NumCopias       : Integer         read fNumCopias        write SetNumCopias      default 1;
    property Filtro          : TACBrBoletoFCFiltro read fFiltro       write fFiltro           default fiNenhum ;
    property SoftwareHouse   : String          read fSoftwareHouse    write fSoftwareHouse;
    property PrinterName     : String          read fPrinterName      write fPrinterName;
    property DirLogo         : String          read GetDirLogo        write SetDirLogo;
    property NomeArquivo     : String          read GetNomeArquivo    write SetNomeArquivo ;
    property CalcularNomeArquivoPDFIndividual: Boolean        read FCalcularNomeArquivoPDFIndividual write FCalcularNomeArquivoPDFIndividual default True ;
    property PdfSenha        : string          read FPdfSenha         write SetPdfSenha;
    property AlterarEscalaPadrao: Boolean      read FAlterarEscalaPadrao write FAlterarEscalaPadrao default False;
    property NovaEscala      : Integer         read FNovaEscala       write FNovaEscala        default 96;
    property TituloPreview   : string          read FTituloPreview    write SetTituloPreview;
  end;


implementation

Uses Vcl.Forms, Math, dateutils, strutils,  ACBrBoletoWS,
     ACBrUtil, ACBrBancoBradesco, ACBrBancoBrasil, ACBrBancoAmazonia, ACBrBancoBanestes,
     ACBrBancoItau, ACBrBancoSicredi, ACBrBancoMercantil, ACBrBancoCaixa, ACBrBancoBanrisul,
     ACBrBancoSantander, ACBrBancoBancoob, ACBrBancoCaixaSICOB, ACBrBancoHSBC,
     ACBrBancoNordeste , ACBrBancoBRB, ACBrBancoBic, ACBrBancoBradescoSICOOB,
     ACBrBancoSafra, ACBrBancoSafraBradesco, ACBrBancoCecred, ACBrBancoBrasilSicoob,
     ACBrUniprime, ACBrBancoUnicredRS, ACBrBancoBanese, ACBrBancoCredisis, ACBrBancoUnicredES,
     ACBrBancoCresol, ACBrBancoCitiBank, ACBrBancoABCBrasil, ACBrBancoDaycoval, ACBrUniprimeNortePR,
     ACBrBancoPine, ACBrBancoPineBradesco, ACBrBancoUnicredSC;

{ TACBrArquivos }

constructor TACBrArquivos.Create;
begin
  fLogRegistro:= False;
  fPathGravarRegistro:= '';
end;

procedure TACBrArquivos.Assign(Source: TPersistent);
begin
  if Source is TACBrArquivos then
  begin
    fLogRegistro := TACBrArquivos(Source).LogRegistro;
    fPathGravarRegistro := TACBrArquivos(Source).PathGravarRegistro;
  end
  else
    inherited Assign(Source);
end;

{ TConfiguracoes }

constructor TConfiguracoes.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fArquivos := TACBrArquivos.Create;
  fWebService := TACBrWebService.Create(Self);
end;

destructor TConfiguracoes.Destroy;
begin
  fArquivos.Free;
  fWebService.Free;
  inherited Destroy;
end;

{ TListadeNFes }

function TACBrListadeNFes.GetObject(Index: Integer): TACBrDadosNFe;
begin
   Result := inherited GetItem(Index) as TACBrDadosNFe ;
end;

procedure TACBrListadeNFes.SetObject(Index: Integer; Item: TACBrDadosNFe);
begin
   inherited SetItem (Index, Item) ;
end;

procedure TACBrListadeNFes.Insert(Index: Integer; Obj: TACBrDadosNFe);
begin
   inherited Insert(Index, Obj);
end;

function TACBrListadeNFes.Add(Obj: TACBrDadosNFe): Integer;
begin
   Result := inherited Add(Obj) ;
end;

{$IFNDEF FPC}
   {$R ACBrBoleto.dcr}
{$ENDIF}

function TACBrBancoClass.TipoDescontoToString(const AValue: TACBrTipoDesconto):string;
begin
  Result := '0';
  case AValue of
     tdNaoConcederDesconto : Result := '0';
     tdValorFixoAteDataInformada : Result := '1';
     tdPercentualAteDataInformada : Result := '2';
     tdValorAntecipacaoDiaCorrido : Result := '3';
     tdValorAntecipacaoDiaUtil : Result := '4';
     tdPercentualSobreValorNominalDiaCorrido : Result := '5';
     tdPercentualSobreValorNominalDiaUtil : Result := '6';
     tdCancelamentoDesconto : Result := '7';
  end;
end;


{ TACBrWebService }

constructor TACBrWebService.Create(AOwner: TComponent);
begin
  inherited Create;
  fAmbiente := taHomologacao;
  fOperacao := tpInclui;
  fVersaoDF := '1.2';
  SSLHttpLib:= httpOpenSSL;
end;

destructor TACBrWebService.Destroy;
begin
  inherited Destroy;
end;

function TACBrWebService.Enviar: Boolean;
begin
  Raise Exception.Create(ACBrStr('M�todo Enviar n�o ' +
            'implementado no ACBrBoleto!'));
end;

{ TACBrCedenteWS }

procedure TACBrCedenteWS.SetClientID(const Value: string);
begin
   if FClientID = Value then
     Exit;
   FClientID := Value;
end;

procedure TACBrCedenteWS.SetClientSecret(const Value: string);
begin
   if FClientSecret = Value then
     Exit;
   FClientSecret := Value;
end;

procedure TACBrCedenteWS.SetKeyUser(const Value: string);
begin
   if FKeyUser = Value then
     Exit;
   FKeyUser := Value;
end;

procedure TACBrCedenteWS.SetScope(const Value: string);
begin
   if FScope = Value then
     Exit;
   FScope := Value;
end;

constructor TACBrCedenteWS.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FClientID := '';
  FClientSecret := '';
  FKeyUser := '';
end;

{ TACBrCedente }
procedure TACBrCedente.SetCNPJCPF ( const AValue: String ) ;
var
  ACBrVal: TACBrValidador;
  ADocto: String;
begin
   if fCNPJCPF = AValue then
     Exit;

   ADocto := OnlyNumber(AValue);
   if EstaVazio(ADocto) then
   begin
      fCNPJCPF:= ADocto;
      Exit;
   end;

   ACBrVal := TACBrValidador.Create(Self);
   try
     with ACBrVal do
     begin
       if TipoInscricao = pFisica then
       begin
         TipoDocto := docCPF;
         Documento := RightStr(ADocto,11);
       end
       else
       begin
         TipoDocto := docCNPJ;
         Documento := RightStr(ADocto,14);
       end;

       IgnorarChar := './-';
       RaiseExcept := True;
       Validar;    // Dispara Exception se Documento estiver errado

       fCNPJCPF := Formatar;
     end;
   finally
     ACBrVal.Free;
   end;
end;

procedure TACBrCedente.SetConta(const AValue: String);
var
  aConta: Integer;
begin
   if fConta = AValue then
      exit;

   fConta:= AValue;
   aConta:= StrToIntDef(trim(AValue),0);

   if aConta = 0 then
      exit;

   fConta:= IntToStrZero(aConta, ACBrBoleto.Banco.TamanhoConta );
end;

procedure TACBrCedente.SetAgencia(const AValue: String);
var  aAgencia: Integer;
begin
   if fAgencia = AValue then
      exit;

   fAgencia:= AValue;

   aAgencia:= StrToIntDef(trim(AValue),0);

   if aAgencia = 0 then
      exit;

   fAgencia:= IntToStrZero(aAgencia, ACBrBoleto.Banco.TamanhoAgencia );
end;

procedure TACBrCedente.SetTipoInscricao ( const AValue: TACBrPessoaCedente ) ;
begin
   if fTipoInscricao = AValue then
      exit;

   fTipoInscricao := AValue;
end;

constructor TACBrCedente.Create( AOwner : TComponent );
begin
	inherited Create(AOwner);

	fNomeCedente   := '';
	fAgencia       := '';
	fAgenciaDigito := '';
	fConta         := '';
	fContaDigito   := '';
	fModalidade    := '';
	fConvenio      := '';
	fCNPJCPF       := '';
	fDigitoVerificadorAgenciaConta:= '';
	fResponEmissao := tbCliEmite;
	fIdentDistribuicao := tbClienteDistribui;
	fCaracTitulo   := tcSimples;
	fTipoInscricao := pJuridica;
	fAcbrBoleto    := TACBrBoleto(AOwner);
	fTipoDocumento := Tradicional;

	fCedenteWS := TACBrCedenteWS.Create(self);
	fCedenteWS.Name := 'CedenteWS';
  {$IFDEF COMPILER6_UP}
  fCedenteWS.SetSubComponent(True);
  {$ENDIF}
end;

destructor TACBrCedente.Destroy;
begin
  inherited;
end;

{ TACBrSacado }

function TACBrSacado.GetAvalista: String;
begin
  Result:= Self.SacadoAvalista.NomeAvalista;
end;

procedure TACBrSacado.SetAvalista(const AValue: String);
begin
   if Self.SacadoAvalista.NomeAvalista = AValue then
     Exit;

   Self.SacadoAvalista.NomeAvalista:= AValue;
end;

procedure TACBrSacado.SetMensagem(const AValue: String);
begin
  FMensagem := AValue;
end;

constructor TACBrSacado.Create;
begin
   fSacadoAvalista := TACBrSacadoAvalista.Create;
end;

destructor TACBrSacado.Destroy;
begin
   fSacadoAvalista.Free;
  inherited;
end;

procedure TACBrTitulo.SetNossoNumero ( const AValue: String ) ;
var
   wTamNossoNumero: Integer;
   wNossoNumero: String;
begin
   wNossoNumero:= OnlyNumber(AValue);
   with ACBrBoleto.Banco do
   begin
      wTamNossoNumero:= CalcularTamMaximoNossoNumero(Carteira, wNossoNumero,
                                                     ACBrBoleto.Cedente.Convenio);

      if Length(trim(wNossoNumero)) > wTamNossoNumero then
         raise Exception.Create( ACBrStr('Tamanho M�ximo do Nosso N�mero �: '+ IntToStr(wTamNossoNumero) ));

      fNossoNumero := PadLeft(wNossoNumero,wTamNossoNumero,'0');
   end;
end;

procedure TACBrTitulo.SetCarteira(const AValue: String);
var
  aCarteira: Integer;
begin
   if fCarteira = AValue then
      exit;

   with ACBrBoleto.Banco do
   begin
      aCarteira:= StrToIntDef(trim(AValue),0);

      fCarteira:=  AValue;

      if aCarteira < 1 then
         exit;

      fCarteira:= IntToStrZero(aCarteira,TamanhoCarteira);

   end;
end;

procedure TACBrTitulo.SetCodigoMora(const AValue: String);
begin
  if fCodigoMora = AValue then
      exit;

  if Pos(AValue,ACBrBoleto.Banco.CodigosMoraAceitos) = 0 then
     raise Exception.Create( ACBrStr('C�digo de Mora/Juros informado n�o � permitido ' +
                                     'para este banco!') );

  fCodigoMora := AValue;
end;

procedure TACBrTitulo.SetDiasDeProtesto(AValue: Integer);
begin
  if (fDiasDeProtesto = AValue) then
    Exit;

  fDiasDeProtesto := AValue;
  fDataProtesto := 0;
  AtualizaDadosProtesto();
end;

procedure TACBrTitulo.SetDiasDeNegativacao(AValue: Integer);
begin
  if (fDiasDeNegativacao = AValue) then
    Exit;

  fDiasDeNegativacao := AValue;
  fDataNegativacao := 0;
  AtualizaDadosNegativacao();
end;

procedure TACBrTitulo.SetCodigoGeracao(const AValue: String);
begin
  if fCodigoGeracao = AValue then
    Exit;

  if Pos(AValue,ACBrBoleto.Banco.CodigosGeracaoAceitos) = 0 then
     raise Exception.Create( ACBrStr('C�digo de Gera��o Inv�lido!') );

  fCodigoGeracao := AValue;
end;

procedure TACBrTitulo.SetDataProtesto(AValue: TDateTime);
begin
  if (fDataProtesto = AValue) then
    Exit;

   if (fTipoDiasProtesto = diUteis) then
     fDataProtesto:= IncWorkingDay(AValue,0)
   else
     fDataProtesto := Avalue;

  fDiasDeProtesto := 0;
  AtualizaDadosProtesto();
end;

procedure TACBrTitulo.SetDataNegativacao(AValue: TDateTime);
begin
  if (fDataNegativacao = AValue) then
    Exit;

   if (fTipoDiasNegativacao = diUteis) then
     fDataNegativacao:= IncWorkingDay(AValue,0)
   else
     fDataNegativacao := Avalue;

  fDiasDeNegativacao := 0;
  AtualizaDadosNegativacao();
end;

procedure TACBrTitulo.SetVencimento(AValue: TDateTime);
begin
  if (fVencimento = AValue) then
    Exit;

  fVencimento := AValue;
  AtualizaDadosProtesto();
  AtualizaDadosNegativacao();
end;

procedure TACBrTitulo.SetTipoDiasProtesto(AValue: TACBrTipoDiasIntrucao);
begin
  if fTipoDiasProtesto = AValue then
    Exit;

  fTipoDiasProtesto := AValue;
  if fDiasDeProtesto > 0 then
    fDataProtesto := 0;

  AtualizaDadosProtesto();
end;

procedure TACBrTitulo.SetTipoDiasNegativacao(AValue: TACBrTipoDiasIntrucao);
begin
  if fTipoDiasNegativacao = AValue then
    Exit;

  fTipoDiasNegativacao := AValue;
  if fDiasDeNegativacao > 0 then
    fDataNegativacao := 0;

  AtualizaDadosNegativacao();
end;

procedure TACBrTitulo.AtualizaDadosProtesto;
begin
  if fVencimento <= 0 then
    Exit;

  if (fDataProtesto > 0) then
  begin
    if (fTipoDiasProtesto = diUteis) then
      fDiasDeProtesto := WorkingDaysBetween(fVencimento, fDataProtesto)
    else
      fDiasDeProtesto := DaysBetween(fVencimento, fDataProtesto);
  end
  else if (fDiasDeProtesto > 0) then
  begin
    if (fTipoDiasProtesto = diUteis) then
      fDataProtesto := IncWorkingDay(fVencimento,fDiasDeProtesto)
    else
      fDataProtesto := IncDay(fVencimento,fDiasDeProtesto);
  end;
end;

procedure TACBrTitulo.AtualizaDadosNegativacao;
begin
  if fVencimento <= 0 then
    Exit;

  if (fDataNegativacao > 0) then
  begin
    if (fTipoDiasNegativacao = diUteis) then
      fDiasDeNegativacao := WorkingDaysBetween(fVencimento, fDataNegativacao)
    else
      fDiasDeNegativacao := DaysBetween(fVencimento, fDataNegativacao);
  end
  else if (fDiasDeNegativacao > 0) then
  begin
    if (fTipoDiasNegativacao = diUteis) then
      fDataNegativacao := IncWorkingDay(fVencimento,fDiasDeNegativacao)
    else
      fDataNegativacao := IncDay(fVencimento,fDiasDeNegativacao);
  end;
end;

procedure TACBrTitulo.SetParcela ( const AValue: Integer ) ;
begin
  if Assigned(ACBrBoleto.ACBrBoletoFC) then
    if (AValue > TotalParcelas) and (ACBrBoleto.ACBrBoletoFC.LayOut = lCarne) then
       raise Exception.Create( ACBrStr('Numero da Parcela Atual deve ser menor ' +
                                       'que o Total de Parcelas do Carn�') );
   fParcela := AValue;
end;

procedure TACBrTitulo.SetTotalParcelas ( const AValue: Integer ) ;
begin
  if Assigned(ACBrBoleto.ACBrBoletoFC) then
    if (AValue < Parcela) and (ACBrBoleto.ACBrBoletoFC.LayOut = lCarne) then
      raise Exception.Create( ACBrStr('Numero da Parcela Atual deve ser menor ou igual ' +
                                      'o Total de Parcelas do Carn�') );
   fTotalParcelas := AValue;
end;

{ TACBrTitulo }

procedure TACBrTitulo.CarregaLogoEmp(const PictureLogo: TPicture);
begin
  if FileExists( ArquivoLogoEmp ) then
    PictureLogo.LoadFromFile( ArquivoLogoEmp );
end;

procedure TACBrTitulo.Imprimir();
begin
  if not Assigned(ACBrBoleto.ACBrBoletoFC) then
    raise Exception.Create( ACBrStr('Nenhum componente "ACBrBoletoFC" associado' ) );

  if (fACBrBoleto.ListadeBoletos.Count <= 0)  then
    raise Exception.Create( ACBrStr('Nenhum T�tulo encontrado na Lista de Boletos' ) ) ;

  ACBrBoleto.ACBrBoletoFC.IndiceImprimirIndividual :=  fACBrBoleto.ListadeBoletos.IndexOf(Self);
  try
    ACBrBoleto.Imprimir;
  finally
    ACBrBoleto.ACBrBoletoFC.IndiceImprimirIndividual:= -1;

  end;

end;

procedure TACBrTitulo.GerarPDF();
begin
  if not Assigned(ACBrBoleto.ACBrBoletoFC) then
    raise Exception.Create( ACBrStr('Nenhum componente "ACBrBoletoFC" associado' ) ) ;

  if (fACBrBoleto.ListadeBoletos.Count <= 0)  then
    raise Exception.Create( ACBrStr('Nenhum T�tulo encontrado na Lista de Boletos' ) ) ;

  ACBrBoleto.ACBrBoletoFC.IndiceImprimirIndividual :=  fACBrBoleto.ListadeBoletos.IndexOf(Self);
  try
    ACBrBoleto.GerarPDF;
  finally
    ACBrBoleto.ACBrBoletoFC.IndiceImprimirIndividual:= -1;

  end;

end;

procedure TACBrTitulo.EnviarEmail(const sPara, sAssunto: String;
  sMensagem: TStrings; EnviaPDF: Boolean; sCC: TStrings; Anexos: TStrings);
begin
  if not Assigned(ACBrBoleto.ACBrBoletoFC) then
    raise Exception.Create( ACBrStr('Nenhum componente "ACBrBoletoFC" associado' ) );

  if (fACBrBoleto.ListadeBoletos.Count <= 0)  then
    raise Exception.Create( ACBrStr('Nenhum T�tulo encontrado na Lista de Boletos' ) ) ;

  if not Assigned(ACBrBoleto.MAIL) then
    raise Exception.Create( ACBrStr('Nenhum componente "ACBrMail" associado' ) );

  ACBrBoleto.ACBrBoletoFC.IndiceImprimirIndividual :=  fACBrBoleto.ListadeBoletos.IndexOf(Self);
  try
    ACBrBoleto.EnviarEmail(sPara, sAssunto, sMensagem, EnviaPDF, sCC, Anexos);
  finally
    ACBrBoleto.ACBrBoletoFC.IndiceImprimirIndividual:= -1;

  end;

end;

function TACBrTitulo.CriarNFeNaLista: TACBrDadosNFe;
var
  I: Integer;
begin
   I      := fListaDadosNFe.Add(TACBrDadosNFe.Create);
   Result := fListaDadosNFe[I];
end;

constructor TACBrTitulo.Create(ACBrBoleto:TACBrBoleto);
begin
   inherited Create;

   fACBrBoleto        := ACBrBoleto;
   fLocalPagamento    := ACBrBoleto.Banco.LocalPagamento;
   fVencimento        := 0;
   fDataDocumento     := 0;
   fNumeroDocumento   := '';
   fEspecieDoc        := 'DM';
   fAceite            := atNao;
   fDataProcessamento := now;
   fNossoNumero       := '';
   fNossoNumeroCorrespondente:= '';
   fUsoBanco          := '';
   fCarteira          := '';
   fEspecieMod        := '';
   fValorDocumento    := 0;
   fInstrucao1        := '';
   fInstrucao2        := '';
   fInstrucao3        := '';
   fMensagem          := TStringList.Create;
   fDetalhamento      := TStringList.Create;
   fInformativo       := TStringList.Create;
   fInstrucoes        := TStringList.Create;
   fSacado            := TACBrSacado.Create;
   fLiquidacao        := TACBrTituloLiquidacao.Create;

   fOcorrenciaOriginal:= TACBrOcorrencia.Create(Self);
   fMotivoRejeicaoComando          := TStringList.Create;
   fDescricaoMotivoRejeicaoComando := TStringList.Create;

   fDataOcorrencia       := 0;
   fDataCredito          := 0;
   fDataAbatimento       := 0;
   fDataDesconto         := 0;
   fDataDesconto2        := 0;
   fDataDesconto3        := 0;
   fDataMoraJuros        := 0;
   fDataMulta            := 0;
   fDataProtesto         := 0;
   fDiasDeProtesto       := 0;
   fDataNegativacao      := 0;
   fDiasDeNegativacao    := 0;
   fDataBaixa            := 0;
   fDataLimitePagto      := 0;
   fValorDespesaCobranca := 0;
   fValorAbatimento      := 0;
   fValorDesconto        := 0;
   fValorDesconto2       := 0;
   fValorDesconto3       := 0;
   fValorMoraJuros       := 0;
   fValorIOF             := 0;
   fValorOutrasDespesas  := 0;
   fValorOutrosCreditos  := 0;
   fValorRecebido        := 0;
   fValorDescontoAntDia  := 0;
   fPercentualMulta      := 0;
   fMultaValorFixo       := false;
   fReferencia           := '';
   fVersao               := '';
   fTipoImpressao        := tipNormal;
   fTipoDesconto         := tdNaoConcederDesconto ;
   fTipoDesconto2        := tdNaoConcederDesconto ;

   fCodigoMora    := '';
   fCodigoGeracao := '2';
   fCaracTitulo   := fACBrBoleto.Cedente.CaracTitulo;

   if ACBrBoleto.Cedente.ResponEmissao = tbCliEmite then
     fCarteiraEnvio := tceCedente
   else
     fCarteiraEnvio := tceBanco;

   fListaDadosNFe := TACBrListadeNFes.Create(true);
end;

destructor TACBrTitulo.Destroy;
begin
   fMensagem.Free;
   fDetalhamento.Free;
   fInformativo.Free;
   fSacado.Free;
   fLiquidacao.Free;
   fInstrucoes.Free;
   fOcorrenciaOriginal.Free;
   fMotivoRejeicaoComando.Free;
   fDescricaoMotivoRejeicaoComando.Free;

   fListaDadosNFe.Free;

   inherited;
end;

procedure TACBrBoleto.SetACBrBoletoFC ( const Value: TACBrBoletoFCClass ) ;
Var OldValue: TACBrBoletoFCClass;
begin
   if Value <> fACBrBoletoFC then
   begin
      if Assigned(fACBrBoletoFC) then
         fACBrBoletoFC.RemoveFreeNotification(Self);

      OldValue      := fACBrBoletoFC ;   // Usa outra variavel para evitar Loop Infinito
      fACBrBoletoFC := Value;            // na remo��o da associa��o dos componentes

      if Assigned(OldValue) then
         if Assigned(OldValue.ACBrBoleto) then
            OldValue.ACBrBoleto := nil ;

      if Value <> nil then
      begin
         Value.FreeNotification(self);
         Value.ACBrBoleto := self ;
      end ;
   end ;
end;

procedure TACBrBoleto.SetMAIL(AValue: TACBrMail);
begin
  if AValue <> FMAIL then
  begin
    if Assigned(FMAIL) then
      FMAIL.RemoveFreeNotification(Self);

    FMAIL := AValue;

    if AValue <> nil then
      AValue.FreeNotification(self);
  end;
end;

procedure TACBrBoleto.Notification ( AComponent: TComponent;
   Operation: TOperation ) ;
begin
   inherited Notification ( AComponent, Operation ) ;

   if (Operation = opRemove) then
   begin
     if (fACBrBoletoFC <> nil) and (AComponent is TACBrBoletoFCClass) then
       fACBrBoletoFC := nil ;

     if (FMAIL <> nil) and (AComponent is TACBrMail) then
       FMAIL := nil;
   end;
end;

procedure TACBrTitulo.setValorDocumento(const AValue: Currency);
begin
  // O arredondamento � com objetivo de remover as diferen�as em arredondamentos posteriores,
  //    que causa uma diferen�a entre o valor do documento e a linha digit�vel.
  // Veja: https://www.projetoacbr.com.br/forum/topic/48941-erro-ao-gerar-boleto-linha-digitav�l-diferente-do-valor-do-boleto-sicoob
  fValorDocumento := RoundABNT(AValue, 2);
end;

{ TACBrBoleto }

constructor TACBrBoleto.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);

   fACBrBoletoFC           := nil;
   FMAIL                   := nil;
   fImprimirMensagemPadrao := True;

   fListadeBoletos := TListadeBoletos.Create(true);
   fListaRetornoWeb := TListaRetEnvio.Create(True);

   fBanco := TACBrBanco.Create(self);
   fBanco.Name := 'Banco';
   {$IFDEF COMPILER6_UP}
    fBanco.SetSubComponent(True);   // Ajustando como SubComponente para aparecer no ObjectInspector
   {$ENDIF}

   fCedente      := TACBrCedente.Create(self);
   fCedente.Name := 'Cedente';
   {$IFDEF COMPILER6_UP}
    fCedente.SetSubComponent(True);   // Ajustando como SubComponente para aparecer no ObjectInspector
   {$ENDIF}

   fConfiguracoes      := TConfiguracoes.Create(self);
   fConfiguracoes.Name := 'Configuracoes';
   {$IFDEF COMPILER6_UP}
   fConfiguracoes.SetSubComponent(True);   // Ajustando como SubComponente para aparecer no ObjectInspector
   {$ENDIF}
end;

destructor TACBrBoleto.Destroy;
begin
   fListadeBoletos.Free;
   fCedente.Free;
   fBanco.Free;
   fConfiguracoes.Free;
   fListaRetornoWeb.Free;

   inherited;
end;

function TACBrBoleto.CriarTituloNaLista: TACBrTitulo;
var
   I : Integer;
begin
   I      := fListadeBoletos.Add(TACBrTitulo.Create(Self));
   Result := fListadeBoletos[I];
end;

function TACBrBoleto.CriarRetornoWebNaLista: TRetEnvio;
var
  I: integer;
begin
  I := fListaRetornoWeb.Add(TRetEnvio.Create);
  Result := fListaRetornoWeb[I];
end;

procedure TACBrBoleto.Imprimir;
begin
   if not Assigned(ACBrBoletoFC) then
      raise Exception.Create( ACBrStr('Nenhum componente "ACBrBoletoFC" associado' ) ) ;

   if Banco.Numero = 0 then
      raise Exception.Create( ACBrStr('Banco n�o definido, impossivel listar boleto') );

   ChecarDadosObrigatorios;

   ACBrBoletoFC.Imprimir;
end;

procedure TACBrBoleto.GerarPDF;
begin
   if not Assigned(ACBrBoletoFC) then
      raise Exception.Create( ACBrStr('Nenhum componente "ACBrBoletoFC" associado' ) ) ;

   ChecarDadosObrigatorios;

   ACBrBoletoFC.GerarPDF;
end;

procedure TACBrBoleto.GerarHTML;
begin
   if not Assigned(ACBrBoletoFC) then
      raise Exception.Create( ACBrStr('Nenhum componente "ACBrBoletoFC" associado' ) );

   ChecarDadosObrigatorios;

   ACBrBoletoFC.GerarHTML;
end;

procedure TACBrBoleto.GerarJPG;
begin
   if not Assigned(ACBrBoletoFC) then
      raise Exception.Create( ACBrStr('Nenhum componente "ACBrBoletoFC" associado' ) ) ;

   ChecarDadosObrigatorios;

   ACBrBoletoFC.GerarJPG;
end;

procedure TACBrBoleto.EnviarEmail(const sPara, sAssunto: String;
  sMensagem: TStrings; EnviaPDF: Boolean; sCC: TStrings; Anexos: TStrings);
var
  i: Integer;
  EMails: TStringList;
  sDelimiter: Char;
begin
  if not Assigned(FMAIL) then
    raise Exception.Create( ACBrStr('Componente ACBrMail n�o associado') );

  FMAIL.Clear;

  EMails := TStringList.Create;
  try
    if Pos( ';', sPara) > 0 then
       sDelimiter := ';'
    else
       sDelimiter := ',';
    QuebrarLinha( sPara, EMails, '"', sDelimiter);

    for i := 0 to EMails.Count -1 do
       FMAIL.AddAddress( EMails[i] );
  finally
    EMails.Free;
  end;

  FMAIL.Subject := sAssunto;

  if Assigned(sMensagem) then
  begin
    if FMAIL.IsHTML then
      FMAIL.Body.Assign(sMensagem);

    FMAIL.AltBody.Text := (StripHTML(sMensagem.Text));
  end;

  FMAIL.ClearAttachments;
  if (EnviaPDF) then
  begin
    GerarPDF;
    if ACBrBoletoFC.IndiceImprimirIndividual >= 0 then
        FMAIL.AddAttachment( ACBrBoletoFC.GetNomeArquivoPdfIndividual(ACBrBoletoFC.NomeArquivo, ACBrBoletoFC.IndiceImprimirIndividual)  ,
                        ExtractFileName( ACBrBoletoFC.GetNomeArquivoPdfIndividual(ACBrBoletoFC.NomeArquivo, ACBrBoletoFC.IndiceImprimirIndividual)) )

    else
      FMAIL.AddAttachment(ACBrBoletoFC.NomeArquivo,
                        ExtractFileName(ACBrBoletoFC.NomeArquivo) );
  end
  else
  begin
    GerarHTML;
    FMAIL.AddAttachment(ACBrBoletoFC.NomeArquivo,
                        ExtractFileName(ACBrBoletoFC.NomeArquivo));
  end;

  if Assigned(sCC) then
  begin
    for i := 0 to sCC.Count - 1 do
      FMAIL.AddCC(sCC[i]);
  end;

  if Assigned(Anexos) then
  begin
    for i := 0 to Anexos.Count - 1 do
      FMAIL.AddAttachment(Anexos[i],ExtractFileName(Anexos[i]));
  end;

  FMAIL.Send;
end;

procedure TACBrBoleto.AdicionarMensagensPadroes(Titulo: TACBrTitulo;
  AStringList: TStrings);
begin
   if not ImprimirMensagemPadrao  then
      exit;

   with Titulo do
   begin
      if DataProtesto <> 0 then
      begin
         if TipoDiasProtesto = diCorridos then
            AStringList.Add(ACBrStr('Protestar em ' + IntToStr(DaysBetween(Vencimento, DataProtesto))+ ' dias corridos ap�s o vencimento'))
         else
            AStringList.Add(ACBrStr('Protestar no '+IntToStr(max(DiasDeProtesto,1)) + '� dia �til ap�s o vencimento'));
      end;
      if DataNegativacao <> 0 then
      begin
         if TipoDiasNegativacao = diCorridos then
            AStringList.Add(ACBrStr('Negativar em ' + IntToStr(DaysBetween(Vencimento, DataNegativacao))+ ' dias corridos ap�s o vencimento'))
         else
            AStringList.Add(ACBrStr('Negativar no '+IntToStr(max(DiasDeNegativacao,1)) + '� dia �til ap�s o vencimento'));
      end;

      if ValorAbatimento <> 0 then
      begin
         if DataAbatimento <> 0 then
            AStringList.Add(ACBrStr('Conceder abatimento de ' +
                             FormatCurr('R$ #,##0.00',ValorAbatimento) +
                             ' para pagamento ate ' + FormatDateTime('dd/mm/yyyy',DataAbatimento)))
         else
            AStringList.Add(ACBrStr('Conceder abatimento de ' +
                             FormatCurr('R$ #,##0.00',ValorAbatimento)));
      end;

      if ValorDesconto <> 0 then
      begin
         if DataDesconto <> 0 then
            AStringList.Add(ACBrStr('Conceder desconto de '                       +
                             FormatCurr('R$ #,##0.00',ValorDesconto)       +
                             ' para pagamento at� ' +
                             FormatDateTime('dd/mm/yyyy',DataDesconto)))
         else
            AStringList.Add(ACBrStr('Conceder desconto de '                 +
                             FormatCurr('R$ #,##0.00',ValorDesconto) +
                             ' por dia de antecipa�ao'));
      end;

      if ValorDesconto2 <> 0 then
      begin
        if DataDesconto2 <> 0 then
          AStringList.Add(ACBrStr('Conceder desconto de '                       +
                           FormatCurr('R$ #,##0.00',ValorDesconto2)       +
                           ' para pagamento at� ' +
                           FormatDateTime('dd/mm/yyyy', DataDesconto2)))
        else
          AStringList.Add(ACBrStr('Conceder desconto de '                 +
                           FormatCurr('R$ #,##0.00',ValorDesconto2) +
                           ' por dia de antecipa�ao'));
      end;

      if ValorMoraJuros <> 0 then
      begin
         if DataMoraJuros <> 0 then
            AStringList.Add(ACBrStr('Cobrar juros de '                        +
                            ifthen(((CodigoMoraJuros in [cjTaxaMensal, cjValorMensal]) or (CodigoMora = '2') or (CodigoMora = 'B')), FloatToStr(ValorMoraJuros) + '% ao m�s',
                                   FormatCurr('R$ #,##0.00 por dia',ValorMoraJuros))         +
                             ' de atraso para pagamento '+
                             ifthen(Vencimento = DataMoraJuros, 'ap�s o vencimento.',
                                    'a partir de '+FormatDateTime('dd/mm/yyyy',DataMoraJuros))))
         else
            AStringList.Add(ACBrStr('Cobrar juros de '                +
                                    ifthen(((CodigoMoraJuros in [cjTaxaMensal, cjValorMensal]) or (CodigoMora = '2') or (CodigoMora = 'B')), FloatToStr(ValorMoraJuros) + '% ao m�s',
                                           FormatCurr('R$ #,##0.00 por dia',ValorMoraJuros))         +
                             ' de atraso'));
      end;

      if PercentualMulta <> 0 then
      begin
        if DataMulta <> 0 then
          AStringList.Add(ACBrStr('Cobrar multa de ' + FormatCurr('R$ #,##0.00',
            IfThen(MultaValorFixo, PercentualMulta, TruncTo((ValorDocumento*( 1+ PercentualMulta/100)-ValorDocumento),2)  )) +
                         ' para pagamento'+ IfThen(DataMulta = Vencimento, ' ap�s o vencimento.',
                                                   ' a partir de '+ FormatDateTime('dd/mm/yyyy',DataMulta))))
        else
          AStringList.Add(ACBrStr('Multa de ' + FormatCurr('R$ #,##0.00',
            IfThen(MultaValorFixo, PercentualMulta, TruncTo((ValorDocumento*( 1+ PercentualMulta/100)-ValorDocumento),2)  )) +
                         ' ap�s o vencimento.'));
      end;
      if DataLimitePagto <> 0 then
      begin
        if DataLimitePagto > Vencimento then
          AStringList.Add(ACBrStr('N�o Receber ap�s ' + IntToStr(DaysBetween(Vencimento, DataLimitePagto))+ ' dias'))
        else
          AStringList.Add(ACBrStr('N�o Receber ap�s o Vencimento'));
      end;
   end;
end;

{ TListadeBoletos }

procedure TListadeBoletos.SetObject ( Index: Integer; Item: TACBrTitulo ) ;
begin
   inherited SetItem (Index, Item) ;
end;

function TListadeBoletos.GetObject ( Index: Integer ) : TACBrTitulo;
begin
   Result := inherited GetItem(Index) as TACBrTitulo ;
end;

procedure TListadeBoletos.Insert ( Index: Integer; Obj: TACBrTitulo ) ;
begin
   inherited Insert(Index, Obj);
end;

function TListadeBoletos.Add ( Obj: TACBrTitulo ) : Integer;
begin
   Result := inherited Add(Obj) ;
end;

{ TACBrBanco }

constructor TACBrBanco.Create ( AOwner: TComponent ) ;
begin
   inherited Create ( AOwner ) ;

   if not (AOwner is TACBrBoleto) then
      raise Exception.Create(ACBrStr('Aowner deve ser do tipo TACBrBoleto'));

   fACBrBoleto  := TACBrBoleto(AOwner);
   fNumeroBanco := 0;

   fBancoClass := TACBrBancoClass.create(Self);
end;

destructor TACBrBanco.Destroy ;
begin
   fBancoClass.Free;
   inherited ;
end ;

function TACBrBanco.GetNome: String;
begin
   Result:= ACBrStr(fBancoClass.Nome);
end;

function TACBrBanco.GetDigito: Integer;
begin
   Result := fBancoClass.Digito;
end;

function TACBrBanco.GetNumero: Integer;
begin
  Result:=  BancoClass.Numero ;
end;

function TACBrBanco.GetOrientacoesBanco: TStringList;
begin
  Result:= BancoClass.OrientacoesBanco;
end;

function TACBrBanco.GetTamanhoAgencia: Integer;
begin
  Result:= BancoClass.TamanhoAgencia;
end;

function TACBrBanco.GetTamanhoCarteira: Integer;
begin
  Result:= BancoClass.TamanhoCarteira;
end;

function TACBrBanco.GetTamanhoConta: Integer;
begin
   Result:= BancoClass.TamanhoConta;
end;

function TACBrBanco.GetTamanhoMaximoNossoNum: Integer;
begin
   Result := BancoClass.TamanhoMaximoNossoNum;
end;

function TACBrBanco.GetTamanhoNumeroDocumento: Integer;
begin
  Result:= BancoClass.TamanhoNumeroDocumento;
end;

function TACBrBanco.GetCodigosMoraAceitos: String;
begin
  Result := BancoClass.CodigosMoraAceitos;
end;

function TACBrBanco.GetCodigosGeracaoAceitos: string;
begin
  Result := BancoClass.CodigosGeracaoAceitos;
end;

function TACBrBanco.GetLocalPagamento: String;
begin
   if fLocalPagamento = '' then
      if not (csDesigning in fACBrBoleto.ComponentState) then
         fLocalPagamento := fBancoClass.LocalPagamento;

   Result := fLocalPagamento;
end;

function TACBrBanco.GetNumeroCorrespondente: Integer;
begin
  Result:=  BancoClass.NumeroCorrespondente ;
end;

function TACBrBanco.GetLayoutVersaoArquivo: Integer;
begin
  Result:=  BancoClass.LayoutVersaoArquivo;
end;

function TACBrBanco.GetLayoutVersaoLote: Integer;
begin
  Result:=  BancoClass.LayoutVersaoLote;
end;

function TACBrBanco.GetCasasDecimaisMoraJuros: Integer;
begin
  Result:=  BancoClass.CasasDecimaisMoraJuros;
end;

function TACBrBanco.GetDensidadeGravacao: String;
begin
  Result:=  BancoClass.DensidadeGravacao;
end;

procedure TACBrBanco.SetDigito(const AValue: Integer);
begin
  {Apenas para aparecer no ObjectInspector do D7}
end;

procedure TACBrBanco.SetNome(const AValue: String);
begin
  {Apenas para aparecer no ObjectInspector do D7}
end;

procedure TACBrBanco.SetNumero(const AValue: Integer);
begin
  {Apenas para aparecer no ObjectInspector do D7}
end;

procedure TACBrBanco.SetLocalPagamento(const AValue: String);
begin
  fLocalPagamento := TrimRight(AValue);
end;

procedure TACBrBanco.SetNumeroCorrespondente(const AValue: Integer);
begin
  {Apenas para aparecer no ObjectInspector do D7}
end;

procedure TACBrBanco.SetLayoutVersaoArquivo(const AValue: Integer);
begin
  BancoClass.fpLayoutVersaoArquivo:= AValue;
end;

procedure TACBrBanco.SetLayoutVersaoLote(const AValue: Integer);
begin
  BancoClass.fpLayoutVersaoLote:= AValue;
end;

procedure TACBrBanco.SetCasasDecimaisMoraJuros(const AValue: Integer);
begin
  BancoClass.fpCasasDecimaisMoraJuros:= AValue;
end;

procedure TACBrBanco.SetDensidadeGravacao(const AValue: String);
begin
  BancoClass.fpDensidadeGravacao:= AValue;
end;

procedure TACBrBanco.SetTamanhoMaximoNossoNum(const Avalue: Integer);
begin
  {Altera o tamanho maximo do Nosso Numero} 
  BancoClass.fpTamanhoMaximoNossoNum := AValue;
end;

procedure TACBrBanco.SetOrientacoesBanco(const Avalue: TStringList);
begin
   BancoClass.fpOrientacoesBanco.Text := AValue.Text;
end;

procedure TACBrBanco.SetTipoCobranca(const AValue: TACBrTipoCobranca);
begin
   if fTipoCobranca = AValue then
      exit;

   if fLocalPagamento = fBancoClass.LocalPagamento then   //Usando valor Default
      fLocalPagamento := '';

   fBancoClass.Free;

   case AValue of
     cobBancoDoBrasil       : fBancoClass := TACBrBancoBrasil.create(Self);         {001}
     cobBancoDoBrasilSICOOB : fBancoClass := TACBrBancoBrasilSICOOB.Create(Self);   {001}
     cobBancoDaAmazonia     : fBancoClass := TACBrBancoAmazonia.create(Self);       {003}
     cobBancoDoNordeste     : fBancoClass := TACBrBancoNordeste.create(Self);       {004}
     cobBanestes            : fBancoClass := TACBrBancoBanestes.create(Self);       {021}
     cobSantander           : fBancoClass := TACBrBancoSantander.create(Self);      {033,353,008}
     cobBanrisul            : fBancoClass := TACBrBanrisul.create(Self);            {041}
     cobBRB                 : fBancoClass := TACBrBancoBRB.create(Self);            {070}
     cobUnicredRS           : fBancoClass := TACbrBancoUnicredRS.Create(Self);      {091}
     cobBancoCECRED         : fBancoClass := TACBrBancoCecred.Create(Self);         {085}
     cobCrediSIS            : fBancoClass := TACBrBancoCrediSIS.Create(Self);       {097}
     cobUniprime            : fBancoClass := TACBrUniprime.create(Self);            {099}
     cobCaixaEconomica      : fBancoClass := TACBrCaixaEconomica.create(Self);      {104}
     cobCaixaSicob          : fBancoClass := TACBrCaixaEconomicaSICOB.create(Self); {104}
     cobUnicredES           : fBancoClass := TACBrBancoUnicredES.create(Self);      {136}
     cobBradesco            : fBancoClass := TACBrBancoBradesco.create(Self);       {237}
     cobItau                : fBancoClass := TACBrBancoItau.Create(Self);           {341}
     cobBancoMercantil      : fBancoClass := TACBrBancoMercantil.create(Self);      {389}
     cobSicred              : fBancoClass := TACBrBancoSicredi.Create(Self);        {748}
     cobBancoob             : fBancoClass := TACBrBancoob.create(Self);             {756}
     cobHSBC                : fBancoClass := TACBrBancoHSBC.create(Self);           {399}
     cobBicBanco            : fBancoClass := TACBrBancoBic.create(Self);            {237}
     cobBradescoSICOOB      : fBancoClass := TAcbrBancoBradescoSICOOB.create(Self); {237}
     cobBancoSafra          : fBancoClass := TACBrBancoSafra.create(Self);          {422}
     cobSafraBradesco       : fBancoClass := TACBrBancoSafraBradesco.Create(Self);  {422 + 237}
     cobBanese              : fBancoClass := TACBrBancoBanese.Create(Self);         {047}
     cobBancoCresolSCRS     : fBancoClass := TACBrBancoCresol.create(Self);         {133 + 237}
     cobCitiBank            : fBancoClass := TACBrBancoCitiBank.Create(Self);       {745}
     cobBancoABCBrasil      : fBancoClass := TACBrBancoABCBrasil.Create(Self);      {246}
     cobDaycoval            : fBancoClass := TACBrBancoDaycoval.Create(Self);       {745}
     cobUniprimeNortePR     : fBancoClass := TACBrUniprimeNortePR.Create(Self);     {084}
     cobBancoPine           : fBancoClass := TACBrBancoPine.create(Self);
     cobBancoPineBradesco   : fBancoClass := TACBrBancoPineBradesco.create(Self);   {643 + 237}
     cobUnicredSC           : fBancoClass := TACBrBancoUnicredSC.Create(Self);      {136 + 237}
   else
     fBancoClass := TACBrBancoClass.create(Self);
   end;

   fTipoCobranca := AValue;
end;

function TACBrBanco.TipoOcorrenciaToDescricao( const TipoOcorrencia: TACBrTipoOcorrencia
   ) : String;
begin
   Result:= BancoClass.TipoOcorrenciaToDescricao(TipoOCorrencia);
end;

function TACBrBanco.CodOcorrenciaToTipo(const CodOcorrencia: Integer ) : TACBrTipoOcorrencia;
begin
   Result:= BancoClass.CodOcorrenciaToTipo(CodOcorrencia);
end;

function TACBrBanco.TipoOCorrenciaToCod (
   const TipoOcorrencia: TACBrTipoOcorrencia ) : String;
begin
   Result:= BancoClass.TipoOCorrenciaToCod(TipoOcorrencia);
end;

function TACBrBanco.CompOcorrenciaOutrosDadosToDescricao(
  const CompOcorrencia: TACBrComplementoOcorrenciaOutrosDados): String;
begin
  Result:= BancoClass.CompOcorrenciaOutrosDadosToDescricao(CompOcorrencia);
end;

function TACBrBanco.CompOcorrenciaOutrosDadosToCodigo(
  const CompOcorrencia: TACBrComplementoOcorrenciaOutrosDados): String;
begin
  Result:= BancoClass.CompOcorrenciaOutrosDadosToCodigo(CompOcorrencia);
end;

function TACBrBanco.CodMotivoRejeicaoToDescricao( const TipoOcorrencia:
   TACBrTipoOcorrencia;CodMotivo: Integer) : String;
begin
  Result:= BancoClass.CodMotivoRejeicaoToDescricao(TipoOcorrencia,CodMotivo);
end;

function TACBrBanco.CodOcorrenciaToTipoRemessa(const CodOcorrencia: Integer ) : TACBrTipoOcorrencia;
begin
   Result:= fBancoClass.CodOcorrenciaToTipoRemessa(CodOcorrencia);
end;

function TACBrBanco.TipoOcorrenciaToCodRemessa(const TipoOcorrencia: TACBrTipoOcorrencia ) : String;
begin
   Result:= fBancoClass.TipoOcorrenciaToCodRemessa(TipoOcorrencia);
end;

function TACBrBanco.CalcularDigitoVerificador ( const ACBrTitulo: TACBrTitulo
   ) : String;
begin
   Result:=  BancoClass.CalcularDigitoVerificador(ACBrTitulo);
end;

function TACBrBanco.CalcularTamMaximoNossoNumero(const Carteira: String; const NossoNumero : String = ''; const Convenio: String = ''): Integer;
begin
  Result:= BancoClass.CalcularTamMaximoNossoNumero(Carteira, NossoNumero, Convenio);
end;

function TACBrBanco.MontarCampoCarteira(const ACBrTitulo: TACBrTitulo): String;
begin
  Result:= BancoClass.MontarCampoCarteira(ACBrTitulo);
end;

function TACBrBanco.MontarCampoNossoNumero ( const ACBrTitulo: TACBrTitulo
   ) : String;
begin
   Result:= BancoClass.MontarCampoNossoNumero(ACBrTitulo);
end;

function TACBrBanco.MontarCodigoBarras ( const ACBrTitulo: TACBrTitulo) : String;
begin
   Result:= BancoClass.MontarCodigoBarras(ACBrTitulo);
end;

function TACBrBanco.MontarLinhaDigitavel ( const CodigoBarras:String; ACBrTitulo : TACBrTitulo) : String;
begin
   Result:= BancoClass.MontarLinhaDigitavel(CodigoBarras, ACBrTitulo);
end;

procedure TACBrBanco.GerarRegistroHeader400(NumeroRemessa: Integer; ARemessa:TStringList);
begin
  BancoClass.GerarRegistroHeader400( NumeroRemessa, ARemessa );
end;

function TACBrBanco.GerarRegistroHeader240(NumeroRemessa: Integer): String;
begin
  Result :=  BancoClass.GerarRegistroHeader240( NumeroRemessa );
end;

procedure TACBrBanco.GerarRegistroTransacao400(ACBrTitulo: TACBrTitulo; aRemessa: TStringList);
begin
  BancoClass.GerarRegistroTransacao400( ACBrTitulo, aRemessa );
end;

function TACBrBanco.GerarRegistroTransacao240(ACBrTitulo: TACBrTitulo): String;
begin
  Result := BancoClass.GerarRegistroTransacao240( ACBrTitulo );
end;

procedure TACBrBanco.GerarRegistroTrailler400(ARemessa: TStringList);
begin
  BancoClass.GerarRegistroTrailler400( ARemessa );
end;

function TACBrBanco.GerarRegistroTrailler240(ARemessa: TStringList): String;
begin
 Result :=  BancoClass.GerarRegistroTrailler240( ARemessa );
end;

procedure TACBrBanco.LerRetorno400(ARetorno: TStringList);
begin
   BancoClass.LerRetorno400(ARetorno);
end;

procedure TACBrBanco.LerRetorno240(ARetorno: TStringList);
begin
   BancoClass.LerRetorno240(ARetorno);
end;

function TACBrBanco.CalcularNomeArquivoRemessa : String;
begin
  Result:= BancoClass.CalcularNomeArquivoRemessa ;
end;

function TACBrBanco.ValidarDadosRetorno(const AAgencia, AContaCedente: String; const ACNPJCPF: String= '';
       const AValidaCodCedente: Boolean= False ): Boolean;
begin
  Result:= BancoClass.ValidarDadosRetorno(AAgencia, AContaCedente, ACNPJCPF, AValidaCodCedente) ;
end;

function TACBrBanco.MontarCampoCodigoCedente(
  const ACBrTitulo: TACBrTitulo): String;
begin
  Result:= BancoClass.MontarCampoCodigoCedente(ACBrTitulo);
end;


{ TACBrBancoClass }

constructor TACBrBancoClass.create(AOwner: TACBrBanco);
begin
   inherited create;

   fpAOwner                := AOwner;
   fpDigito                := 0;
   fpNome                  := 'N�o definido';
   fpNumero                := 0;
   fpTamanhoMaximoNossoNum := 10;
   fpTamanhoAgencia        := 4;
   fpTamanhoConta          := 10;
   fpTamanhoNumeroDocumento:= 15;
   fpCodigosMoraAceitos    := '12';
   fpCodigosGeracaoAceitos := '0123456789';
   fpNumeroCorrespondente  := 0;
   fpLayoutVersaoArquivo   := 0;
   fpLayoutVersaoLote      := 0;
   fpCasasDecimaisMoraJuros:= 2;
   fpModuloMultiplicadorInicial:= 0;
   fpModuloMultiplicadorFinal:= 0;
   fpModuloMultiplicadorAtual:=0;
   fpCodParametroMovimento  := '';
   fpDensidadeGravacao      := '';
   fpQtdRegsLote            := 0;
   fpQtdRegsCobranca        := 0;
   fpVlrRegsCobranca        := 0;
   fpModulo                := TACBrCalcDigito.Create;
   fpOrientacoesBanco      := TStringList.Create;
end;

destructor TACBrBancoClass.Destroy;
begin
   fpModulo.Free;
   fpOrientacoesBanco.Free;
   Inherited Destroy;
end;

procedure TACBrBancoClass.GerarRegistroHeader400(NumeroRemessa: Integer;
  ARemessa: TStringList);
var
  wLinha: String;
begin
  //ErroAbstract('GerarRemessa400');

  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    wLinha:= '0'                                                +  { ID do Registro }
             '1'                                                +  { ID do Arquivo( 1 - Remessa) }
             'REMESSA'                                          +  { Literal de Remessa }
             '01'                                               +  { C�digo do Tipo de Servi�o }
             PadRight('COBRANCA', 15)                           +  { Descri��o do tipo de servi�o }
             PadLeft(CodigoCedente, 20, '0')                    +  { Codigo da Empresa no Banco }
             PadRight(Nome, 30)                                 +  { Nome da Empresa }
             IntToStrZero(fpNumero, 3)                          +  { C�digo do Banco 091 }
             PadRight(fpNome, 15)                               +  { Nome do Banco(091 - Unicred ) }
             FormatDateTime('ddmmyy',Now)                       +  { Data de gera��o do arquivo }
             Space(07)                                          +  { brancos }
             PadLeft(fpCodParametroMovimento, 3 )               +  { C�d. Par�m. Movto da Unicred }
             IntToStrZero(NumeroRemessa, 7)                     +  { Nr. Sequencial de Remessa  }
             Space(277)                                         +  { brancos }
             IntToStrZero(1, 6);                                   { Nr. Sequencial de Remessa + brancos + Contador }

    ARemessa.Add(UpperCase(wLinha));
  end;

end;

function TACBrBancoClass.GerarRegistroHeader240 ( NumeroRemessa: Integer ) : String;
var
  ListHeader: TStringList;
  ACodBeneficiario: String;
begin
  Result := '';
  //ErroAbstract('GerarRemessa240');

  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    if (Length( ContaDigito)  > 1) and (trim(DigitoVerificadorAgenciaConta) = '')  then
      DigitoVerificadorAgenciaConta:=  copy(ContaDigito,length(ContaDigito ),1) ;
  end;
  ACodBeneficiario:= trim(DefineCodBeneficiarioHeader);

  ListHeader:= TStringList.Create;
  try
    with ACBrBanco.ACBrBoleto.Cedente do
    begin

      { GERAR REGISTRO-HEADER DO ARQUIVO }
      ListHeader.Add(IntToStrZero(fpNumero, 3)         + //1 a 3 - C�digo do banco
      '0000'                                           + //4 a 7 - Lote de servi�o
      '0'                                              + //8 - Tipo de registro - Registro header de arquivo
      PadRight('', 9, ' ')                             + //9 a 17 Uso exclusivo FEBRABAN/CNAB
      DefineTipoInscricao                              + //18 - Tipo de inscri��o do cedente
      PadLeft(OnlyNumber(CNPJCPF), 14, '0')            + //19 a 32 -N�mero de inscri��o do cedente
      DefineCampoConvenio(20)                          + //33 a 52 - C�digo do conv�nio no banco-Alfa
      PadLeft(OnlyNumber(Agencia), 5, '0')             + //53 a 57 - C�digo da ag�ncia do cedente-Numero
      DefineCampoDigitoAgencia                         + //58 - D�gito da ag�ncia do cedente -Alfa
      ifthen(ACodBeneficiario <> '',
             Padleft(ACodBeneficiario,14,'0') ,
             Padleft(Conta, 12 , '0')                  + //59-70 - N�mero da Conta Corrente -Numero
             DefineCampoDigitoConta                    + //71-71 -D�gito Verificador da Conta -Alfa
             DefineCampoDigitoAgenciaConta )           + //72 a 72 - D�gito Verificador da Conta
      PadRight(nome, 30, ' ')                          + //73 102 - Nome da Empresa-Alfa
      PadRight(fpNome, 30, ' ')                        + //103 a 132 -Nome do banco-Alfa
      PadRight('', 10, ' ')                            + //133 a 142 - Uso exclusivo FEBRABAN/CNAB  -Alfa
      '1'                                              + //143 - C�digo de Remessa (1) / Retorno (2)
      FormatDateTime('ddmmyyyy', Now)                  + //144 a 151 - Data do de gera��o do arquivo
      FormatDateTime('hhmmss', Now)                    + //152 a 157 - Hora de gera��o do arquivo
      PadLeft(IntToStr(NumeroRemessa), 6, '0')         + //158 a 163 - N�mero seq�encial do arquivo
      PadLeft(IntToStr(fpLayoutVersaoArquivo), 3, '0') + //164 a 166 - N�mero da vers�o do layout do arquivo
      PadLeft(fpDensidadeGravacao, 5, '0')             + //167 a 171 - Densidade de grava��o do arquivo (BPI)  fixo 06250
      DefinePosicaoUsoExclusivo                        ); // 172 a 240 - Uso Exclusivo FEBRABAN / CNAB

      { GERAR REGISTRO HEADER DO LOTE }

      ListHeader.Add(IntToStrZero(fpNumero, 3)   + //1 a 3 - C�digo do banco
      '0001'                                     + //4 a 7 - Lote de servi�o
      '1'                                        + //8 - Tipo de registro - Registro header de arquivo
      'R'                                        + //9 - Tipo de opera��o 'R'
      '01'                                       + //10 a 11 - Tipo de servi�o: 01 (Cobran�a)
      '  '                                       + //12 a 13 - Uso Exclusivo FEBRABAN/CNAB /Alfa
      PadLeft(IntToStr(fpLayoutVersaoLote), 3, '0') + //14 a 16 - N�mero da vers�o do layout do lote
      ' '                                        + //17 - Uso exclusivo FEBRABAN/CNAB
      DefineTipoInscricao                        + //18 - Tipo de inscri��o do cedente
      PadLeft(OnlyNumber(CNPJCPF), 15, '0')      + //19 a 33 -N�mero de inscri��o do cedente
      DefineCampoConvenio(20)                    + //33 a 52 - C�digo do conv�nio no banco-Alfa
      Padleft(Agencia, 5, '0')                   + //54 a 58 - Ag�ncia Mantenedora da Conta
      DefineCampoDigitoAgencia                   + //59 - D�gito da ag�ncia do cedente
      ifthen(ACodBeneficiario <> '',
             Padleft(ACodBeneficiario,14,'0') ,
             Padleft(Conta, 12 , '0')            + //60 -71 N�mero da Conta Corrente
             DefineCampoDigitoConta              + //72 a 72 - D�gito Verificador da Conta
             DefineCampoDigitoAgenciaConta )     + //73 a 73 - D�gito Verificador da Ag/Conta
      PadRight(Nome, 30, ' ')                    + //74 a 103 - Nome do cedente
      PadRight('', 40, ' ')                      + //104 a 143 - Mensagem 1
      PadRight('', 40, ' ')                      + //144 a 183 - Mensagen 2
      PadLeft(IntToStr(NumeroRemessa), 8, '0')   + //184 a 191 - N�mero seq�encial do registro no lote
      FormatDateTime('ddmmyyyy', date)           +// 192 a 199 Data de Grava��o Remessa/Retorno
      Padleft('0', 8 , '0')                      + //200 -207 Data do Cr�dito
      PadRight('', 33, ' '));                      //208 a 240 - Uso exclusivo FEBRABAN/CNAB

    end;

    Result := RemoverQuebraLinhaFinal(ListHeader.Text);
  finally
    ListHeader.Free;
  end;

end;

procedure TACBrBancoClass.GerarRegistroTrailler400( ARemessa: TStringList);
var
  wLinha: String;
begin
  wLinha := '9' + Space(393)                     +  { ID Registro }
            IntToStrZero( ARemessa.Count + 1, 6);   { Contador de Registros }
  ARemessa.Add(UpperCase(wLinha));
end;

function TACBrBancoClass.MontarCampoCodigoCedente(const ACBrTitulo: TACBrTitulo): String;
begin
  Result := ACBrTitulo.ACBrBoleto.Cedente.Agencia+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.AgenciaDigito+'/'+
             ACBrTitulo.ACBrBoleto.Cedente.Conta+'-'+
             ACBrTitulo.ACBrBoleto.Cedente.ContaDigito;
end;

function TACBrBancoClass.MontarCampoCarteira(const ACBrTitulo: TACBrTitulo): String;
begin
  Result := ACBrTitulo.Carteira;
end;


function TACBrBancoClass.GerarRegistroTrailler240 ( ARemessa: TStringList) : String;
var
  ListTrailler: TStringList;
begin
  Result:= '';

  if (fpQtdRegsLote = 0) then
    fpQtdRegsLote := 3 * ( ARemessa.Count - 1 ); //Corresponde a qtd linhas da remessa * qdt Segmentos do arquivo (3 � o padr�o)

  {REGISTRO TRAILER DO LOTE}

  ListTrailler:= TStringList.Create;
  try
    ListTrailler.Add(IntToStrZero(fpNumero, 3)                          + //C�digo do Banco na Compensa��o 1 3 3 - Num G001
             '0001'                                                     + //Lote Lote de Servi�o 4 7 4 - Num *G002
             '5'                                                        + //Tipo de Registro 8 8 1 - Num �5� *G003
             Space(9)                                                   + //CNAB Uso Exclusivo FEBRABAN/CNAB 9 17 9 - Alfa Brancos G004
             IntToStrZero((fpQtdRegsLote + 2 ), 6)                      + //Qtde de Registros Quantidade de Registros no Lote 18 23 6 - Num *G057
             IntToStrZero((fpQtdRegsCobranca), 6)                       + //Quantidade de T�tulos em Cobran�a 24 29 6 - Num *C070  INFORMAR ZERO SEGUNDO O BANCO
             IntToStrZero( round( fpVlrRegsCobranca * 100), 17)         + //Valor Total dosT�tulos em Carteiras 30 46 15 2 Num *C071     //ZERO SEGUNDO O BANCO
             PadRight('', 6, '0')                                       + //Quantidade de T�tulos em Cobran�a 47 52 6 - Num *C070
             PadRight('',17, '0')                                       + //Valor Total dosT�tulos em Carteiras 53 69 15 2 Num *C071
             PadRight('',6,  '0')                                       + //Quantidade de T�tulos em Cobran�a 70 75 6 - Num *C070
             PadRight('',17, '0')                                       + //Quantidade de T�tulos em Carteiras 76 92 15 2 Num *C071
             PadRight('',6,  '0')                                       + //Quantidade de T�tulos em Cobran�a 93 98 6 - Nim *C070
             PadRight('',17, '0')                                       + //Valor Total dosT�tulos em Carteiras 99 115 15 2 Num *C071
             PadRight('',8, ' ')                                        + //N�mero do Aviso de Lan�amento 116 123 8 - Alfa *C072
             PadRight('',117,' '))                                      ; //Uso Exclusivo FEBRABAN/CNAB 124 240 117 - Alfa Brancos G004

    {GERAR REGISTRO TRAILER DO ARQUIVO}

    ListTrailler.Add(IntToStrZero(fpNumero, 3)                          + //C�digo do banco
             '9999'                                                     + //Lote de servi�o
             '9'                                                        + //Tipo do registro: Registro trailer do arquivo
             PadRight('',9,' ')                                         + //Uso exclusivo FEBRABAN/CNAB}
             '000001'                                                   + //Quantidade de lotes do arquivo (Registros P,Q,R, header e trailer do lote e do arquivo)
             IntToStrZero((fpQtdRegsLote + 4), 6)                       + //Quantidade de registros do arquivo, inclusive este registro que est� sendo criado agora}
             Padleft('0',6,'0')                                         + //Uso exclusivo FEBRABAN/CNAB}
             PadRight('',205,' '));                                       //Uso exclusivo FEBRABAN/CNAB}

    Result := RemoverQuebraLinhaFinal(ListTrailler.Text);

  finally
    fpQtdRegsLote      := 0;
    fpQtdRegsCobranca  := 0;
    fpVlrRegsCobranca  := 0;
    ListTrailler.Free;
  end;

end;

procedure TACBrBancoClass.LerRetorno400(ARetorno: TStringList);
var
  Titulo : TACBrTitulo;
  ContLinha, CodOcorrencia  :Integer;
  CodMotivo, i, MotivoLinha :Integer;
  CodMotivo_19, rAgencia    :String;
  rConta, rDigitoConta      :String;
  Linha, rCedente, rCNPJCPF :String;
  rCodEmpresa               :String;
begin
  //ErroAbstract('LerRetorno400');

  //Utiliza o layout padr�o para leitura de retorno CNAB400
  if StrToIntDef(copy(ARetorno.Strings[0],77,3),-1) <> Numero then
    raise Exception.Create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                             'n�o � um arquivo de retorno do '+ Nome));

  rCodEmpresa:= trim(Copy(ARetorno[0],27,20));
  rCedente   := trim(Copy(ARetorno[0],47,30));

  // A leitura dever� ser feita a partir da posi��o 26 devido ao fato de n�o existirem ag�ncias banc�rias com mais de 4 (quatro) algarismos.
  rAgencia := trim(Copy(ARetorno[1], 26, ACBrBanco.TamanhoAgencia));
  rConta   := trim(Copy(ARetorno[1], 30, DefineTamanhoContaRemessa));

  rDigitoConta := Copy(ARetorno[1], 30 + DefineTamanhoContaRemessa ,1);

  ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0],109,5),0);

  if (StrToIntDef( Copy(ARetorno[0], 95, 6 ), 0) > 0) then
    ACBrBanco.ACBrBoleto.DataArquivo := StringToDateTimeDef(Copy(ARetorno[0],95,2)+'/'+
                                                            Copy(ARetorno[0],97,2)+'/'+
                                                            Copy(ARetorno[0],99,2),0, 'DD/MM/YY' );

  if (StrToIntDef( Copy(ARetorno[0], 380, 6 ), 0) > 0) then
    ACBrBanco.ACBrBoleto.DataCreditoLanc := StringToDateTimeDef(Copy(ARetorno[0],380,2)+'/'+
                                                                Copy(ARetorno[0],382,2)+'/'+
                                                                Copy(ARetorno[0],384,2),0, 'DD/MM/YY' );

  case StrToIntDef(Copy(ARetorno[1],2,2),0) of
     11: rCNPJCPF := Copy(ARetorno[1],7,11);
     14: rCNPJCPF := Copy(ARetorno[1],4,14);
  else
    rCNPJCPF := Copy(ARetorno[1],4,14);
  end;

  ValidarDadosRetorno(rAgencia, rConta);
  with ACBrBanco.ACBrBoleto do
  begin
    if (not LeCedenteRetorno) and (rCodEmpresa <> PadLeft(Cedente.CodigoCedente, 20, '0')) then
       raise Exception.Create(ACBrStr('C�digo da Empresa do arquivo inv�lido'));

    case StrToIntDef(Copy(ARetorno[1],2,2),0) of
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

       Cedente.CodigoCedente:= rCodEmpresa;
       Cedente.Nome         := rCedente;
       Cedente.Agencia      := rAgencia;
       Cedente.AgenciaDigito:= '0';
       Cedente.Conta        := rConta;
       Cedente.ContaDigito  := rDigitoConta;
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
        NumeroDocumento             := copy(Linha,117,10);
        OcorrenciaOriginal.Tipo     := CodOcorrenciaToTipo(StrToIntDef(
                                       copy(Linha,109,2),0));

        CodOcorrencia := StrToIntDef(IfThen(copy(Linha,109,2) = '  ','00',copy(Linha,109,2)),0);

        //-|Se a ocorrencia for igual a 19 - Confirma��o de Receb. de Protesto
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
              CodMotivo := StrToInt(IfThen(copy(Linha,MotivoLinha,2) = '  ','00',copy(Linha,MotivoLinha,2)));

              {Se for o primeiro motivo}
              if (i = 0) then
               begin
                 {Somente estas ocorrencias possuem motivos 00}
                 if(CodOcorrencia in [02, 06, 09, 10, 15, 17])then
                  begin
                    MotivoRejeicaoComando.Add(IfThen(copy(Linha,MotivoLinha,2) = '  ','00',copy(Linha,MotivoLinha,2)));
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
                       MotivoRejeicaoComando.Add(IfThen(copy(Linha,MotivoLinha,2) = '  ','00',copy(Linha,MotivoLinha,2)));
                       DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo,CodMotivo));
                     end;
                  end;
               end
              else
               begin
                 //Apos o 1� motivo os 00 significam que n�o existe mais motivo
                 if CodMotivo <> 0 then
                 begin
                    MotivoRejeicaoComando.Add(IfThen(copy(Linha,MotivoLinha,2) = '  ','00',copy(Linha,MotivoLinha,2)));
                    DescricaoMotivoRejeicaoComando.Add(CodMotivoRejeicaoToDescricao(OcorrenciaOriginal.Tipo,CodMotivo));
                 end;
               end;

              MotivoLinha := MotivoLinha + 2; //Incrementa a coluna dos motivos
           end;
         end;

        if (StrToIntDef(Copy(Linha,111,6),0) > 0) then
          DataOcorrencia := StringToDateTimeDef( Copy(Linha,111,2)+'/'+
                                               Copy(Linha,113,2)+'/'+
                                               Copy(Linha,115,2),0, 'DD/MM/YY' );
        if (StrToIntDef(Copy(Linha,147,6),0) > 0) then
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
        ValorPago            := StrToFloatDef(Copy(Linha,254,13),0)/100;
        NossoNumero          := DefineNossoNumeroRetorno(Linha);
        Carteira             := Copy(Linha,DefinePosicaoCarteiraRetorno,3);
        ValorDespesaCobranca := StrToFloatDef(Copy(Linha,176,13),0)/100;
        ValorOutrasDespesas  := StrToFloatDef(Copy(Linha,189,13),0)/100;

        // informa��es do local de pagamento
        Liquidacao.Banco      := StrToIntDef(Copy(Linha,166,3), -1);
        Liquidacao.Agencia    := Copy(Linha,169,4);
        Liquidacao.Origem     := '';

        if (StrToIntDef(Copy(Linha,296,6),0) > 0) then
           DataCredito:= StringToDateTimeDef( Copy(Linha,296,2)+'/'+
                                              Copy(Linha,298,2)+'/'+
                                              Copy(Linha,300,2),0, 'DD/MM/YY' );
     end;
  end;

end;

procedure TACBrBancoClass.LerRetorno240(ARetorno: TStringList);
var
  Titulo: TACBrTitulo;
  TempData, Linha, rCedente, rCNPJCPF: String;
  ContLinha : Integer;
  idxMotivo: Integer;
  rConvenioCedente: String;
  ACodBeneficiario: String;
begin
  //ErroAbstract('LerRetorno240');

  // Verifica se o arquivo pertence ao banco
  if StrToIntDef(copy(ARetorno.Strings[0], 1, 3),-1) <> Numero then
     raise Exception.create(ACBrStr(ACBrBanco.ACBrBoleto.NomeArqRetorno +
                            'n�o' + '� um arquivo de retorno do ' + Nome));

  ACBrBanco.ACBrBoleto.DataArquivo := StringToDateTimeDef(Copy(ARetorno[0],144,2)+'/'+
                                                          Copy(ARetorno[0],146,2)+'/'+
                                                          Copy(ARetorno[0],148,4),0, 'DD/MM/YYYY' );

  ACBrBanco.ACBrBoleto.NumeroArquivo := StrToIntDef(Copy(ARetorno[0],158,6),0);

  rCedente         := trim(copy(ARetorno[0], 73, 30));
  rCNPJCPF         := OnlyNumber( copy(ARetorno[0], 19, 14) );
  rConvenioCedente := Trim(Copy(ARetorno[0], 33, 20));

  ValidarDadosRetorno('', '', rCNPJCPF);
  with ACBrBanco.ACBrBoleto do
  begin

     if LeCedenteRetorno then
     begin
       ACodBeneficiario:= trim(DefineCodBeneficiarioHeader);
       Cedente.Nome     := rCedente;
       Cedente.CNPJCPF  := rCNPJCPF;
       Cedente.Convenio := rConvenioCedente;
       Cedente.Agencia       := trim(copy(ARetorno[0], 53, 5));
       Cedente.AgenciaDigito := trim(copy(ARetorno[0], 58, 1));
       if (ACodBeneficiario <> '') then
         Cedente.CodigoCedente := trim(copy(ARetorno[0], 59, 14))
       else
       begin
         Cedente.Conta         := trim(copy(ARetorno[0], 59, 12));
         Cedente.ContaDigito   := trim(copy(ARetorno[0], 71, 1));
       end;

       if (StrToIntDef(copy(ARetorno[0], 18, 1), 0) = 1) then
         Cedente.TipoInscricao := pFisica
       else
         Cedente.TipoInscricao := pJuridica;

     end;

     ACBrBanco.ACBrBoleto.ListadeBoletos.Clear;
  end;

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
          SeuNumero := copy(Linha, 106, 25);
          NumeroDocumento := copy(Linha, 59, fpTamanhoNumeroDocumento);
          Carteira := copy(Linha, DefinePosicaoCarteiraRetorno, TamanhoCarteira);

          case strtoint(copy(Linha, 58, 1)) of
            1: CaracTitulo := tcSimples;
            2: CaracTitulo := tcVinculada;
            3: CaracTitulo := tcCaucionada;
            4: CaracTitulo := tcDescontada;
            5: CaracTitulo := tcVendor;
          end;

           TempData := copy(Linha, 74, 2) + '/'+copy(Linha, 76, 2)+'/'+copy(Linha, 78, 4);
           if TempData <> '00/00/0000' then
              Vencimento := StringToDateTimeDef(TempData, 0, 'DDMMYYYY');

           ValorDocumento := StrToFloatDef(copy(Linha, 82, 15), 0) / 100;
           NossoNumero    := DefineNossoNumeroRetorno(Linha);
           ValorDespesaCobranca := StrToFloatDef(copy(Linha, 199, 15), 0) / 100;

           OcorrenciaOriginal.Tipo := CodOcorrenciaToTipo(StrToIntDef(copy(Linha, 16, 2), 0));

           IdxMotivo := 214;

           while (IdxMotivo < 223) do
           begin
              if (trim(Copy(Linha, IdxMotivo, 2)) <> '')  and (trim(Copy(Linha, IdxMotivo, 2)) <> '00') then
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
           ValorOutrosCreditos := StrToFloatDef(copy(Linha, 123, 15), 0) / 100;
           ValorOutrasDespesas := StrToFloatDef(copy(Linha, 108, 15), 0) / 100;
           ValorRecebido       := StrToFloatDef(copy(Linha, 78, 15), 0) / 100;

           TempData            := copy(Linha, 138, 2)+'/'+copy(Linha, 140, 2)+'/'+copy(Linha, 142, 4);
           if TempData <> '00/00/0000' then
               DataOcorrencia  := StringToDateTimeDef(TempData, 0, 'DDMMYYYY');

           TempData := copy(Linha, 146, 2)+'/'+copy(Linha, 148, 2)+'/'+copy(Linha, 150, 4);
           if TempData <> '00/00/0000' then
               DataCredito     := StringToDateTimeDef(TempData, 0, 'DDMMYYYY');
        end;
     end;

  end;

end;

procedure TACBrBancoClass.GerarRegistroTransacao400(  ACBrTitulo: TACBrTitulo; aRemessa: TStringList);
begin
  { M�todo implementado apenas para evitar Warnings de compila��o (poderia ser abstrato)
    Voc� de fazer "override" desse m�todo em todas as classes filhas de TACBrBancoClass }

end;

function TACBrBancoClass.GerarRegistroTransacao240 ( ACBrTitulo: TACBrTitulo
   ) : String;
begin
   Result:= '';
end;

function TACBrBancoClass.CalcularDigitoVerificador(const ACBrTitulo :TACBrTitulo ): String;
begin
  Result:= '';

  Modulo.CalculoPadrao;

  if fpModuloMultiplicadorInicial > 0 then
    Modulo.MultiplicadorInicial := fpModuloMultiplicadorInicial;
  if fpModuloMultiplicadorFinal > 0 then
    Modulo.MultiplicadorFinal := fpModuloMultiplicadorFinal;
  if fpModuloMultiplicadorAtual > 0 then
    Modulo.MultiplicadorAtual := fpModuloMultiplicadorAtual;

  Modulo.Documento := DefineNumeroDocumentoModulo(ACBrTitulo);

  Modulo.Calcular;

  Result := ConverterDigitoModuloFinal();

end;

function TACBrBancoClass.CalcularTamMaximoNossoNumero(
  const Carteira: String; const NossoNumero : String = ''; const Convenio: String = ''): Integer;
begin
  Result := ACBrBanco.TamanhoMaximoNossoNum;
end;

function TACBrBancoClass.TipoOcorrenciaToDescricao(
  const TipoOcorrencia : TACBrTipoOcorrencia) : String ;
begin
  Result := '';
end ;

function TACBrBancoClass.CodOcorrenciaToTipo(const CodOcorrencia : Integer
  ) : TACBrTipoOcorrencia ;
begin
  Result := toRemessaRegistrar;
end ;

function TACBrBancoClass.TipoOCorrenciaToCod(
  const TipoOcorrencia : TACBrTipoOcorrencia) : String ;
begin
  Result := '';
end ;

function TACBrBancoClass.CodMotivoRejeicaoToDescricao(
  const TipoOcorrencia : TACBrTipoOcorrencia ; CodMotivo : Integer) : String ;
begin
  Result := '';
end ;

function TACBrBancoClass.CompOcorrenciaOutrosDadosToDescricao(
  const CompOcorrencia: TACBrComplementoOcorrenciaOutrosDados): String;
begin
  Result := '';
end;

function TACBrBancoClass.CompOcorrenciaOutrosDadosToCodigo(
  const CompOcorrencia: TACBrComplementoOcorrenciaOutrosDados): String;
begin
  Result := '';
end;

function TACBrBancoClass.CodMotivoRejeicaoToDescricao(
const TipoOcorrencia: TACBrTipoOcorrencia; const CodMotivo: String): String;
begin
  Result := '';
end;

function TACBrBancoClass.CodOcorrenciaToTipoRemessa(const CodOcorrencia : Integer
  ) : TACBrTipoOcorrencia ;
begin
  Result := toRemessaRegistrar;
end ;

function TACBrBancoClass.TipoOcorrenciaToCodRemessa(const TipoOcorrencia : TACBrTipoOcorrencia
  ) : String ;
begin
  Result := '01';
end ;

{
 function TACBrBancoClass.GetNumero: Integer;
begin
   Result:= ACBrBanco.Numero;
end;
}

(*
procedure TACBrBancoClass.ErroAbstract(const NomeProcedure: String);
begin
   raise Exception.Create(Format(ACBrStr('Fun��o %s n�o implementada '+
                                         ' para o banco %s') + sLineBreak +
                                         'Ajude no desenvolvimento do ACBrECF. '+ sLineBreak+
                                         'Acesse nosso Forum em: http://acbr.sf.net/',[NomeProcedure,Nome])) ;
end; *)

function TACBrBancoClass.GetLocalPagamento: String;
begin
  Result := Format(ACBrStr(CInstrucaoPagamento), [fpNome] );
end;

function TACBrBancoClass.CalcularFatorVencimento(const DataVencimento: TDateTime
  ): String;
begin
   {** Padr�o para vencimentos at� 21/02/2025 **}
   //Result := IntToStrZero( Max(Trunc(DataVencimento - EncodeDate(1997,10,07)),0),4 );

  {** Padr�o com suporte a datas superiores a 21/02/2025
      http://www.abbc.org.br/images/content/manual%20operacional.pdf **}
   if DataVencimento = 0 then
      Result := '0000'
   else
      Result := IntToStrZero(Max((Trunc(DataVencimento) -
                                  Trunc(EncodeDate(2000,07,03))) mod 9000 + 1000, 0), 4);
end;

function TACBrBancoClass.CalcularDigitoCodigoBarras (
   const CodigoBarras: String ) : String;
begin
   Modulo.CalculoPadrao;
   Modulo.Documento := CodigoBarras;
   Modulo.Calcular;

   if (Modulo.DigitoFinal = 0) or (Modulo.DigitoFinal > 9) then
      Result := '1'
   else
      Result := IntToStr(Modulo.DigitoFinal);
end;

function TACBrBancoClass.CalcularNomeArquivoRemessa : String;
var
  Sequencia :Integer;
  NomeFixo, NomeArq: String;
begin
   Sequencia := 0;

   with ACBrBanco.ACBrBoleto do
   begin
      if NomeArqRemessa = '' then
       begin
         NomeFixo := DirArqRemessa + PathDelim + 'cb' + FormatDateTime( 'ddmm', Now );

         repeat
            Inc( Sequencia );
            NomeArq := NomeFixo + IntToStrZero( Sequencia, 2 ) + '.rem'
         until not FileExists( NomeArq ) ;

         Result := NomeArq;
       end
      else
         Result := DirArqRemessa + PathDelim + NomeArqRemessa ;
   end;
end;

function TACBrBancoClass.ValidarDadosRetorno(const AAgencia, AContaCedente: String;
   const ACNPJCPF: String= ''; const AValidaCodCedente: Boolean= False ): Boolean;
begin
  try
    With ACBrBanco.ACBrBoleto do
    begin
      if NaoEstaVazio(ACNPJCPF) then
        if (not LeCedenteRetorno) and (ACNPJCPF <> OnlyNumber(Cedente.CNPJCPF)) then
          raise Exception.CreateFmt(ACBrStr('CNPJ\CPF: %s do arquivo n�o corresponde aos dados do Cedente!'), [ACNPJCPF]);

      if NaoEstaVazio(AContaCedente) then
      begin
        if not AValidaCodCedente then
        begin
          if (not LeCedenteRetorno) and
             ((AAgencia <> OnlyNumber(Cedente.Agencia)) or
              (AContaCedente <> RightStr(OnlyNumber( Cedente.Conta  ),Length(AContaCedente)))
             ) then
            raise Exception.CreateFmt(ACBrStr('Agencia: %s \ Conta: %s do arquivo n�o correspondem aos dados do Cedente!')
                  ,[AAgencia,AContaCedente]);
        end
        else
        begin
          if (not LeCedenteRetorno) and
             ((StrToIntDef(AAgencia,0) <> StrToIntDef(OnlyNumber(Cedente.Agencia),0)) or
              (StrToIntDef(AContaCedente,0) <> StrToIntDef(OnlyNumber( Cedente.CodigoCedente),0))
             ) then
            raise Exception.CreateFmt(ACBrStr('Agencia: %s \ Conta: %s do arquivo n�o correspondem aos dados do Cedente!')
                  ,[AAgencia,AContaCedente]);
        end;
      end;
    end;
  except
    {$IFNDEF COMPILER23_UP}
     Result := False;
    {$ENDIF}
    raise;
  end;

  Result := True;
end;

function TACBrBancoClass.FormatarMoraJurosRemessa(const APosicoes: Integer
   ;const ACBrTitulo: TACBrTitulo): String;
var
  Multiplicador: integer;
begin
  Multiplicador:=  StrToIntDef('1' + IntToStrZero(0, fpCasasDecimaisMoraJuros), 100);
  Result :=  IntToStrZero(round(ACBrTitulo.ValorMoraJuros * Multiplicador ), APosicoes) ;
end;

function TACBrBancoClass.DefineNumeroDocumentoModulo(
  const ACBrTitulo: TACBrTitulo): String;
begin
  Result := ACBrTitulo.Carteira + ACBrTitulo.NossoNumero;
end;

function TACBrBancoClass.ConverterDigitoModuloFinal(): String;
begin
    Result:= IntToStr(Modulo.DigitoFinal);
end;

function TACBrBancoClass.DefineCampoLivreCodigoBarras(
  const ACBrTitulo: TACBrTitulo): String;
begin
  Result := '';
end;

procedure TACBrBancoClass.ValidaNossoNumeroResponsavel(out
  ANossoNumero: String; out ADigVerificador: String;
  const ACBrTitulo: TACBrTitulo);
begin
  ANossoNumero:= '0';
  ADigVerificador:= '0';

  if (ACBrTitulo.ACBrBoleto.Cedente.ResponEmissao = tbBancoEmite) then
  begin
    ANossoNumero := StringOfChar('0', CalcularTamMaximoNossoNumero(ACBrTitulo.Carteira, ACBrTitulo.NossoNumero) );
    ADigVerificador := '0';
  end
  else
  begin
    ANossoNumero := ACBrTitulo.NossoNumero;
    ADigVerificador := CalcularDigitoVerificador(ACBrTitulo);
    if (ANossoNumero = EmptyStr) then
      ADigVerificador := '0';
  end;
end;

function TACBrBancoClass.MontaInstrucoesCNAB400(const ACBrTitulo: TACBrTitulo;
  const nRegistro: Integer): String;
var
  lNossoNumero, lDigNossoNumero: String;
begin
  Result := '';
  ValidaNossoNumeroResponsavel(lNossoNumero, lDigNossoNumero, ACBrTitulo);

  with ACBrTitulo, ACBrBoleto do
  begin

     {Primeira instru��o vai no registro 1}
     if Mensagem.Count <= 1 then
     begin
        Result := '';
        Exit;
     end;
     Result := '2'               +                                         // IDENTIFICA��O DO LAYOUT PARA O REGISTRO
               Copy(PadRight(TiraAcentos(Mensagem[1]), 80, ' '), 1, 80);                // CONTE�DO DA 1� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO

     if Mensagem.Count >= 3 then
        Result := Result +
                  Copy(PadRight(TiraAcentos(Mensagem[2]), 80, ' '), 1, 80)              // CONTE�DO DA 2� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO
     else
        Result := Result + PadRight('', 80, ' ');                          // CONTE�DO DO RESTANTE DAS LINHAS

     if Mensagem.Count >= 4 then
        Result := Result +
                  Copy(PadRight(TiraAcentos(Mensagem[3]), 80, ' '), 1, 80)              // CONTE�DO DA 3� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO
     else
        Result := Result + PadRight('', 80, ' ');                          // CONTE�DO DO RESTANTE DAS LINHAS

     if Mensagem.Count >= 5 then
        Result := Result +
                  Copy(PadRight(TiraAcentos(Mensagem[4]), 80, ' '), 1, 80)              // CONTE�DO DA 4� LINHA DE IMPRESS�O DA �REA "INSTRU��ES� DO BOLETO
     else
        Result := Result + PadRight('', 80, ' ');                          // CONTE�DO DO RESTANTE DAS LINHAS


     Result := Result                                              +
               PadLeft('', 6,  '0')                                +       // 322 a 327 - Data limite para concess�o de Desconto 2
               PadLeft('', 13, '0')                                +       // 328 a 340 - Valor do Desconto 2
               PadLeft('', 6,  '0')                                +       // 341 a 346 - Data limite para concess�o de Desconto 3
               PadLeft('', 13, '0')                                +       // 347 a 359 - Valor do Desconto 3
               space(7)                                            +       // 360 a 366 - Reserva
               IntToStrZero(StrToIntDef(trim(Carteira), 0), 3)                         +
               IntToStrZero(StrToIntDef(OnlyNumber(ACBrBoleto.Cedente.Agencia), 0), 5) +
               IntToStrZero(StrToIntDef(OnlyNumber(ACBrBoleto.Cedente.Conta)  , 0), 7) +
               Cedente.ContaDigito                                                     +
               lNossoNumero + lDigNossoNumero                                          +
               IntToStrZero( nRegistro + 1, 6);                            // N� SEQ�ENCIAL DO REGISTRO NO ARQUIVO
  end;

end;

function TACBrBancoClass.DefineEspecieDoc(const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo do
  begin
    if ACBrBanco.ACBrBoleto.LayoutRemessa = c240 then
    begin
      if AnsiSameText(EspecieDoc, 'CH') then
        Result := '01'
      else
      if AnsiSameText(EspecieDoc, 'DM') then
        Result := '02'
      else
      if AnsiSameText(EspecieDoc, 'DMI') then
        Result := '03'
      else
      if AnsiSameText(EspecieDoc, 'DS') then
        Result := '04'
      else
      if AnsiSameText(EspecieDoc, 'DSI') then
        Result := '05'
      else
      if AnsiSameText(EspecieDoc, 'DR') then
        Result := '06'
      else
      if AnsiSameText(EspecieDoc, 'LC') then
        Result := '07'
      else
      if AnsiSameText(EspecieDoc, 'NCC') then
        Result := '08'
      else
      if AnsiSameText(EspecieDoc, 'NCE') then
        Result := '09'
      else
      if AnsiSameText(EspecieDoc, 'NCI') then
        Result := '10'
      else
      if AnsiSameText(EspecieDoc, 'NCR') then
        Result := '11'
      else
      if AnsiSameText(EspecieDoc, 'NP') then
        Result := '12'
      else
      if AnsiSameText(EspecieDoc, 'NPR') then
        Result := '13'
      else
      if AnsiSameText(EspecieDoc, 'TM') then
        Result := '14'
      else
      if AnsiSameText(EspecieDoc, 'TS') then
        Result := '15'
      else
      if AnsiSameText(EspecieDoc, 'NS') then
        Result := '16'
      else
      if AnsiSameText(EspecieDoc, 'RC') then
        Result := '17'
      else
      if AnsiSameText(EspecieDoc, 'FAT') then
        Result := '18'
      else
      if AnsiSameText(EspecieDoc, 'ND') then
        Result := '19'
      else
      if AnsiSameText(EspecieDoc, 'AP') then
        Result := '20'
      else
      if AnsiSameText(EspecieDoc, 'ME') then
        Result := '21'
      else
      if AnsiSameText(EspecieDoc, 'PC') then
        Result := '22'
      else
      if AnsiSameText(EspecieDoc, 'NF') then
        Result := '23'
      else
      if AnsiSameText(EspecieDoc, 'DD') then
        Result := '24'
      else
      if AnsiSameText(EspecieDoc, 'CPR') then
        Result := '25'
      else
        Result := '99';
    end
    else
    begin
      if AnsiSameText(EspecieDoc,'DM') then
         Result:= '01'
      else if AnsiSameText(EspecieDoc, 'NP') then
         Result:= '02'
      else if AnsiSameText(EspecieDoc, 'NS') then
         Result:= '03'
      else if AnsiSameText(EspecieDoc, 'CS') then
         Result:= '04'
      else if AnsiSameText(EspecieDoc, 'REC') then
         Result:= '05'
      else if AnsiSameText(EspecieDoc, 'LC') then
         Result:= '10'
      else if AnsiSameText(EspecieDoc, 'ND') then
         Result:= '11'
      else if AnsiSameText(EspecieDoc, 'DS') then
         Result:= '12'
      else if AnsiSameText(EspecieDoc, 'OU') then
         Result:= '99'
      else
         Result := EspecieDoc;

    end;
  end;

end;

function TACBrBancoClass.DefineTipoSacado(const ACBrTitulo: TACBrTitulo
  ): String;
begin
  with ACBrTitulo do
  begin
    case Sacado.Pessoa of
        pFisica   : Result := '01';
        pJuridica : Result := '02';
     else
        Result := '99';
     end;

  end;
end;

function TACBrBancoClass.DefineTipoSacadoAvalista(const ACBrTitulo: TACBrTitulo
  ): String;
begin
  with ACBrTitulo do
  begin
    case Sacado.SacadoAvalista.Pessoa of
        pFisica   : Result := '1';
        pJuridica : Result := '2';
        pOutras   : Result := '9';
     else
        Result := '0';
     end;
  end;
end;

function TACBrBancoClass.DefineTipoBoleto(const ACBrTitulo: TACBrTitulo
  ): String;
begin
  with ACBrTitulo do
  begin
    if CarteiraEnvio = tceCedente then
      Result := '2'
    else
      Result := '1';
  end;

end;

function TACBrBancoClass.DefineTipoInscricao: String;
begin
  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    case TipoInscricao of
        pFisica  : Result := '1';
      else
        Result := '2';
    end;
  end;

end;

function TACBrBancoClass.DefineResponsEmissao: String;
begin
  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    case ACBrBoleto.Cedente.ResponEmissao of
       tbBancoEmite      : Result := '1';
       tbBancoReemite    : Result := '4';
       tbBancoNaoReemite : Result := '5';
    else
         Result :=  '2';
    end;
  end;

end;

function TACBrBancoClass.DefineCaracTitulo(const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo do
  begin
    case CaracTitulo of
      tcVinculada   : Result :='2';
      tcCaucionada  : Result :='3';
      tcDescontada  : Result :='4';
      tcVendor      : Result :='5';
    else
        Result := '1';
    end;
  end;

end;

function TACBrBancoClass.DefineCodigoProtesto(const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo do
  begin
    case CodigoNegativacao of
        cnNenhum           :  Result := '0';
        cnProtestarCorrido :  Result := '1';
        cnProtestarUteis   :  Result := '2';
        cnNaoProtestar     :  Result := '3';
        cnNegativar        :  Result := '7';
        cnNaoNegativar     :  Result := '8';
       else
        Result := '0';
      end;
  end;
end;

function TACBrBancoClass.DefineTipoDiasProtesto(const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo do
  begin
    case TipoDiasProtesto of
       diCorridos       : Result := '1';
       diUteis          : Result := '2';
    else
       Result := '3';
    end;
  end;

end;

function TACBrBancoClass.DefineAceite(const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo do
  begin
    case Aceite of
         atSim :  Result := 'A';
       else
         Result := 'N';
    end;
  end;

end;

function TACBrBancoClass.DefineCodigoMoraJuros(const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo do
  begin
    if (CodigoMora <> '') then
      Result := CodigoMora
    else
    begin
      if (ValorMoraJuros > 0) then
      begin
        case CodigoMoraJuros of
          cjTaxaMensal, cjValorMensal   : Result := '2';
        else
          Result := '1';
        end;
      end
      else
        Result := '3';
    end
  end;

end;

function TACBrBancoClass.DefineDataMoraJuros(const ACBrTitulo: TACBrTitulo; AFormat: String): String;
begin
  with ACBrTitulo do
  begin
    if (ValorMoraJuros > 0) then
    begin
      if DataMoraJuros > 0 then
        Result := FormatDateTime(AFormat, DataMoraJuros)
      else
        Result := PadRight('', Length(AFormat), '0');
    end
    else
      Result := PadRight('', Length(AFormat), '0');
  end;

end;

function TACBrBancoClass.DefineCodigoDesconto(const ACBrTitulo: TACBrTitulo
  ): String;
begin
  with ACBrTitulo do
  begin
    if (ValorDesconto > 0) then
    begin
      case TipoDesconto of
         tdValorFixoAteDataInformada : Result := '1';
         tdPercentualAteDataInformada: Result := '2';
        else
          Result := '1';
      end;
    end
    else
      Result := '0';

  end;

end;

function TACBrBancoClass.DefineDataDesconto(const ACBrTitulo: TACBrTitulo; AFormat: String): String;
begin
  with ACBrTitulo do
  begin
    if (ValorDesconto > 0) then
    begin
      if (DataDesconto > 0) then
        Result := FormatDateTime(AFormat, DataDesconto)
      else
        Result := PadRight('', Length(AFormat), '0');
    end
    else
      Result := PadRight('', Length(AFormat), '0');

  end;

end;

function TACBrBancoClass.DefineCodigoMulta(const ACBrTitulo: TACBrTitulo): String;
begin
  with ACBrTitulo do
  begin
    if (PercentualMulta > 0) then
      Result := '2'
    else
      Result := '0';
  end;
end;

function TACBrBancoClass.DefineDataMulta(const ACBrTitulo: TACBrTitulo; AFormat: String): String;
begin
  with ACBrTitulo do
  begin
    if (PercentualMulta > 0) then
      Result :=  IfThen(DataMulta > 0,FormatDateTime(AFormat, DataMulta),FormatDateTime(AFormat, Vencimento + 1))
    else
      Result := PadRight('', Length(AFormat), '0');
  end;
end;

function TACBrBancoClass.DefineTipoDocumento: String;
begin
  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    case TipoDocumento of
      Tradicional: Result := '1';
      Escritural: Result := '2';
    else
      Result := '1';
    end;
  end;

end;

function TACBrBancoClass.DefineCampoDigitoConta: String;
begin
  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    Result :=  PadLeft(ContaDigito, 1, '0');
  end;

end;

function TACBrBancoClass.DefineCampoDigitoAgenciaConta: String;
begin
  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    Result :=  PadLeft(DigitoVerificadorAgenciaConta, 1, ' ');
  end;
end;

function TACBrBancoClass.DefinePosicaoUsoExclusivo: String;
begin
  Result := Space(20)                                        + // 172 a 191 - Uso reservado do banco
            PadRight('REMESSA-PRODUCAO', 20, ' ')            + // 192 a 211 - Uso reservado da empresa
            PadRight('', 29, ' ');                            // 212 a 240 - Uso Exclusivo FEBRABAN / CNAB
end;

function TACBrBancoClass.DefineCodBeneficiarioHeader: String;
begin
  //Por Default n�o informa beneficiario no Header
  Result:= '';
end;

function TACBrBancoClass.DefineCampoConvenio(const ATam: Integer): String;
begin
  Result := PadLeft(ACBrBanco.ACBrBoleto.Cedente.Convenio, ATam, '0');
end;

function TACBrBancoClass.DefineCampoDigitoAgencia: String;
begin
  with ACBrBanco.ACBrBoleto.Cedente do
  begin
    Result :=  PadLeft(AgenciaDigito, 1, '0');
  end;

end;

function TACBrBancoClass.DefineTamanhoContaRemessa: Integer;
begin
  Result:= ACBrBanco.TamanhoConta;
end;

function TACBrBancoClass.DefinePosicaoNossoNumeroRetorno: Integer;
begin
  if ACBrBanco.ACBrBoleto.LayoutRemessa = c240 then
    Result := 46
  else
    Result := 71;
end;

function TACBrBancoClass.DefineTamanhoNossoNumeroRetorno: Integer;
begin
  Result := TamanhoMaximoNossoNum;
end;

function TACBrBancoClass.DefinePosicaoCarteiraRetorno: Integer;
begin
  if ACBrBanco.ACBrBoleto.LayoutRemessa = c240 then
    Result := 39
  else
    Result := 22;
end;

function TACBrBancoClass.DefineNossoNumeroRetorno(const Retorno: String): String;
begin
  if ACBrBanco.ACBrBoleto.LerNossoNumeroCompleto then
    Result := Copy(Retorno,DefinePosicaoNossoNumeroRetorno,TamanhoMaximoNossoNum)
  else
    Result := Copy(Retorno,DefinePosicaoNossoNumeroRetorno,DefineTamanhoNossoNumeroRetorno);

end;

function TACBrBancoClass.InstrucoesProtesto(const ACBrTitulo: TACBrTitulo): String;
begin
  {Intru��es}
  with ACBrTitulo do
  begin
    if ((DataProtesto > 0) and (DataProtesto > Vencimento)) then
      Result := IfThen(PadLeft(trim(Instrucao1),2,'0') = '00','06',PadLeft(trim(Instrucao1),2,'0'))
                 + IntToStrZero(DaysBetween(DataProtesto,Vencimento),2)
    else if TipoOcorrenciaToCodRemessa(OcorrenciaOriginal.Tipo) = '31' then
      Result := '9999'
    else if ((DataBaixa > 0) and (DataBaixa > Vencimento)) then
      Result := PadLeft(trim(Instrucao2),2,'0') + IntToStrZero(DaysBetween(DataBaixa,Vencimento),2)
    else
      Result := PadLeft(trim(Instrucao1),2,'0') + PadLeft(trim(Instrucao2),2,'0');
  end;

end;

function TACBrBancoClass.MontarCodigoBarras ( const ACBrTitulo: TACBrTitulo) : String;
var
  sCodigoBarras   : String;
  sFatorVencimento: String;
  sDigitoCodBarras: String;
begin
  with ACBrTitulo.ACBrBoleto do
  begin
    sFatorVencimento := CalcularFatorVencimento(ACBrTitulo.Vencimento);

    sCodigoBarras :=     IntToStrZero(Numero, 3) +                                              { Institui��o Financ }
                         '9' +                                                                  { C�d. Moeda = Real }
                         sFatorVencimento +                                                     { Fator Vencimento }
                         IntToStrZero(Round(ACBrTitulo.ValorDocumento * 100), 10) +             { Valor Nominal }
                         DefineCampoLivreCodigoBarras(ACBrTitulo);                              { Campo Livre}

    sDigitoCodBarras := CalcularDigitoCodigoBarras(sCodigoBarras);
  end;

  { Insere o digito verificador calculado no c�digo de barras }
  Result := copy( sCodigoBarras, 1, 4) + sDigitoCodBarras + Copy(sCodigoBarras, 5, 39);

end;

function TACBrBancoClass.MontarCampoNossoNumero ( const ACBrTitulo: TACBrTitulo
   ) : String;
begin
   Result:= ACBrTitulo.NossoNumero;
end;

function TACBrBancoClass.MontarLinhaDigitavel (const CodigoBarras: String; ACBrTitulo : TACBrTitulo): String;
var
  Campo1, Campo2, Campo3, Campo4, Campo5: String;
begin
   fpModulo.FormulaDigito        := frModulo10;
   fpModulo.MultiplicadorInicial := 1;
   fpModulo.MultiplicadorFinal   := 2;
   fpModulo.MultiplicadorAtual   := 2;


  {Campo 1(C�digo Banco,Tipo de Moeda,5 primeiro digitos do Campo Livre) }
   fpModulo.Documento := Copy(CodigoBarras,1,3)+'9'+Copy(CodigoBarras,20,5);
   fpModulo.Calcular;

   Campo1 := copy( fpModulo.Documento, 1, 5) + '.' +
             copy( fpModulo.Documento, 6, 4) +
             IntToStr( fpModulo.DigitoFinal );

  {Campo 2(6� a 15� posi��es do campo Livre)}
   fpModulo.Documento:= copy( CodigoBarras, 25, 10);
   fpModulo.Calcular;

   Campo2 := Copy( fpModulo.Documento, 1, 5) + '.' +
             Copy( fpModulo.Documento, 6, 5) +
             IntToStr( fpModulo.DigitoFinal );

  {Campo 3 (16� a 25� posi��es do campo Livre)}
   fpModulo.Documento:= copy( CodigoBarras, 35, 10);
   fpModulo.Calcular;

   Campo3 := Copy( fpModulo.Documento, 1, 5) + '.' +
             Copy( fpModulo.Documento, 6, 5) +
             IntToStr( fpModulo.DigitoFinal );

  {Campo 4 (Digito Verificador Nosso Numero)}
   Campo4 := Copy( CodigoBarras, 5, 1);

  {Campo 5 (Fator de Vencimento e Valor do Documento)}
   Campo5 := Copy( CodigoBarras, 6, 14);

   Result := Campo1+' '+Campo2+' '+Campo3+' '+Campo4+' '+Campo5;
end;

function TACBrBoleto.GerarRemessa( NumeroRemessa : Integer ) : String;
var
   Stream:TMemoryStream;
begin
   Result:= '';
   if ListadeBoletos.Count < 1 then
      raise Exception.Create(ACBrStr('Lista de Boletos est� vazia'));

   ChecarDadosObrigatorios;

   if not DirectoryExists( DirArqRemessa ) then
      ForceDirectories( DirArqRemessa );

   if not DirectoryExists( DirArqRemessa ) then
      raise Exception.Create( ACBrStr('Diret�rio inv�lido:' + sLineBreak + DirArqRemessa) );

   Stream:= TMemoryStream.Create;
  try
    Result:= GerarRemessaStream(NumeroRemessa, Stream);
    if Result <> '' then
      Stream.SaveToFile(Result);
  finally
    Stream.Free;
  end;

end;

function TACBrBoleto.GerarRemessaStream(NumeroRemessa: Integer;
  Stream: TStream): String;
var
   SLRemessa   : TStringList;
   ContTitulos : Integer;
   NomeArq     : String ;
begin
   Result:= '';
   if ListadeBoletos.Count < 1 then
      raise Exception.Create(ACBrStr('Lista de Boletos est� vazia'));

   ChecarDadosObrigatorios;


   if ( NomeArqRemessa = '' ) then
      NomeArq := Banco.CalcularNomeArquivoRemessa
   else
      NomeArq := DirArqRemessa + PathDelim + NomeArqRemessa;

   SLRemessa := TStringList.Create;
   try
      {$IfNDef MSWINDOWS}
      SLRemessa.LineBreak := CRLF;
      {$EndIf}

      if LayoutRemessa = c400 then
      begin
         Banco.GerarRegistroHeader400( NumeroRemessa, SLRemessa );

         for ContTitulos:= 0 to ListadeBoletos.Count-1 do
            Banco.GerarRegistroTransacao400( ListadeBoletos[ContTitulos], SLRemessa);

         Banco.GerarRegistroTrailler400( SLRemessa );

      end
      else
      begin
        SLRemessa.Add( Banco.GerarRegistroHeader240( NumeroRemessa ) );

         for ContTitulos:= 0 to ListadeBoletos.Count-1 do
             SLRemessa.Add( Banco.GerarRegistroTransacao240( ListadeBoletos[ContTitulos] ) );

         SLRemessa.Add( Banco.GerarRegistroTrailler240( SLRemessa ) );
      end;

      if RemoveAcentosArqRemessa then
        SLRemessa.Text := TiraAcentos(SLRemessa.Text)
      else
        SLRemessa.Text := NativeStringToAnsi(SLRemessa.Text);

      SLRemessa.SaveToStream( Stream );
      Result:= NomeArq;
   finally
      SLRemessa.Free;
   end;
end;

procedure TACBrBoleto.LerRetorno(AStream: TStream);
var
  SlRetorno: TStringList;
  NomeArq  , BancoRetorno: String;
begin
   SlRetorno:= TStringList.Create;
   try
     Self.ListadeBoletos.Clear;

     if not Assigned(AStream) then 
     begin
       if NomeArqRetorno = '' then
         raise Exception.Create(ACBrStr('NomeArqRetorno deve ser informado.'));

       if not FileExists(NomeArqRetorno) then
         NomeArq := IncludeTrailingPathDelimiter(fDirArqRetorno) + NomeArqRetorno
       else
         NomeArq := NomeArqRetorno;

       if not FilesExists( NomeArq ) then
         raise Exception.Create(ACBrStr('Arquivo n�o encontrado:'+sLineBreak+NomeArq));

       SlRetorno.LoadFromFile( NomeArq );
     end
     else
     begin
       AStream.Position := 0;
       SlRetorno.LoadFromStream(AStream);
     end;

     if SlRetorno.Count < 1 then
        raise exception.Create(ACBrStr('O Arquivo de Retorno:'+sLineBreak+
                                       NomeArq + sLineBreak+
                                       'est� vazio.'+sLineBreak+
                                       ' N�o h� dados para processar'));

     case Length(SlRetorno.Strings[0]) of
        240 :
          begin
            if Copy(SlRetorno.Strings[0],143,1) <> '2' then
              Raise Exception.Create( ACBrStr( NomeArq + sLineBreak +
                'N�o � um arquivo de Retorno de cobran�a com layout CNAB240') );

            BancoRetorno  := Copy(SlRetorno.Strings[0],0,3);
            LayoutRemessa := c240 ;
          end;

        400 :
          begin
             if (Copy(SlRetorno.Strings[0],1,9) <> '02RETORNO')   then
               Raise Exception.Create( ACBrStr( NomeArq + sLineBreak +
                 'N�o � um arquivo de Retorno de cobran�a com layout CNAB400'));

             BancoRetorno  := Copy(SlRetorno.Strings[0],77,3);
             LayoutRemessa := c400 ;
          end;
        else
          raise Exception.Create( ACBrStr( NomeArq + sLineBreak+
            'N�o � um arquivo de  Retorno de cobran�a CNAB240 ou CNAB400'));
     end;

     if ( IntToStrZero(Banco.Numero, 3) <> BancoRetorno )
        and ( IntToStrZero(Banco.NumeroCorrespondente, 3) <> BancoRetorno )  then
       if LeCedenteRetorno then
         Banco.TipoCobranca := GetTipoCobranca( StrToIntDef(BancoRetorno, 0))
       else
         raise Exception.Create( ACBrStr( 'Arquivo de retorno de banco diferente do Cedente'));

     if LayoutRemessa = c240 then
        Banco.LerRetorno240(SlRetorno)
     else
        Banco.LerRetorno400(SlRetorno);

   finally
     SlRetorno.Free;
   end;
end;

procedure TACBrBoleto.ChecarDadosObrigatorios;
begin
  if Cedente.Nome = '' then
    Raise Exception.Create(ACBrStr('Nome do cedente n�o informado'));
  if Cedente.Conta = '' then
    Raise Exception.Create(ACBrStr('Conta n�o informada'));
  if (Cedente.ContaDigito = '') and (not (Banco.TipoCobranca in [cobBanestes,cobBanese, cobCitiBank])) then
    Raise Exception.Create(ACBrStr('D�gito da conta n�o informado'));
  if Cedente.Agencia = '' then
    Raise Exception.Create(ACBrStr('Ag�ncia n�o informada'));
  if (Cedente.AgenciaDigito = '') and (not (Banco.TipoCobranca in [cobBanestes, cobBanese,
     cobBanrisul, cobItau, cobCaixaEconomica, cobCaixaSicob, cobCitiBank])) then
    Raise Exception.Create(ACBrStr('D�gito da ag�ncia n�o informado'));
end;

function TACBrBoleto.EnviarBoleto: boolean;
var
  RemessaWS: TBoletoWS;
begin
  if ListadeBoletos.Count < 1 then
    raise Exception.Create(ACBrStr('Lista de Boletos est� vazia'));

  ChecarDadosObrigatorios;

  //Instancia classe para Registro Boleto WebService
  RemessaWS := TBoletoWS.Create(Self);
  try
    ListaRetornoWeb.Clear;
    try
      Result:= RemessaWS.Enviar;
      //Grava Lista de Retorno
      if Configuracoes.Arquivos.LogRegistro then
        GravarIniRetornoWeb( Configuracoes.Arquivos.PathGravarRegistro , 'ret' + FormatDateTime('ddmmyyhhnn',Now) + '.txt' );

    Except
      on E:Exception do
      begin
        if ( ( RemessaWS.RetornoBanco.CodRetorno = 0 ) and
             ( Trim( RemessaWS.RetornoBanco.Msg ) = '' ) ) then
          raise Exception.Create(ACBrStr('Erro: ' + E.Message))
        else
          raise Exception.Create(ACBrStr('Erro: ' + IntToStr(RemessaWS.RetornoBanco.CodRetorno) + sLineBreak +
                                 RemessaWS.RetornoBanco.Msg + sLineBreak));
      end;
    end;

  finally
    RemessaWS.Free;
  end;
end;

function TACBrBoleto.GetOcorrenciasRemessa(): TACBrOcorrenciasRemessa;
var I: Integer;
begin
  SetLength(Result, 77);

  for I:= 1 to 48 do
  begin
    Result[I-1].Tipo := TACBrTipoOcorrencia(I-1);
    Result[I-1].descricao := cACBrTipoOcorrenciaDecricao[I-1];
  end;
end;

function TACBrBoleto.GetTipoCobranca(NumeroBanco: Integer; Carteira: String = ''): TACBrTipoCobranca;
begin
  case NumeroBanco of
    001: Result := cobBancoDoBrasil;
    003: Result := cobBancoDaAmazonia;
    004: Result := cobBancoDoNordeste;
    008,033,353: Result := cobSantander;
    021: Result := cobBanestes;
    041: Result := cobBanrisul;
    070: Result := cobBRB;
    091: Result := cobUnicredRS;
    097: Result := cobCrediSIS;
    099: Result := cobUniprime;
    104: Result := cobCaixaEconomica;
    136: Result := cobUnicredES;
    237: Result := cobBradesco;
    341: Result := cobItau;
    389: Result := cobBancoMercantil;
    748: Result := cobSicred;
    756: Result := cobBancoob;
    399: Result := cobHSBC;
    422: Result := cobBancoSafra;
    085: Result := cobBancoCECRED;
    047: Result := cobBanese;
    745: Result := cobCitiBank;
    246: Result := cobBancoABCBrasil;
    707: Result := cobDaycoval;
    084: Result := cobUniprimeNortePR;
    643: begin
          if StrToInt(Carteira) = 9 then
             Result := cobBancoPineBradesco
           else
             Result := cobBancoPine;
         end;
  else
    raise Exception.Create('Erro ao configurar o tipo de cobran�a.'+
      sLineBreak+'N�mero do Banco inv�lido: '+IntToStr(NumeroBanco));
  end;
end;

function TACBrBoleto.LerArqIni(const AIniBoletos: String): Boolean;
var
  IniBoletos : TMemIniFile ;
  Titulo : TACBrTitulo;
  NFe : TACBrDadosNFe;
  wTipoInscricao, wRespEmissao, wLayoutBoleto: Integer;
  wNumeroBanco, wIndiceACBr, wCNAB, wNumeroCorrespondente,
  wVersaoLote, wVersaoArquivo: Integer;
  wLocalPagto, MemFormatada, MemDetalhamento: String;
  Sessao, sFim: String;
  I, N: Integer;
begin
  Result   := False;

  IniBoletos := TMemIniFile.Create('');
  try
    LerIniArquivoOuString(AIniBoletos, IniBoletos);

    with Self.Cedente do
    begin
      //Cedente
      if IniBoletos.SectionExists('Cedente') then
      begin
        wTipoInscricao := IniBoletos.ReadInteger(CCedente,'TipoPessoa',2);
        try
           Cedente.TipoInscricao := TACBrPessoa( wTipoInscricao ) ;
        except
           Cedente.TipoInscricao := pJuridica ;
        end ;

        Nome          := IniBoletos.ReadString(CCedente,'Nome',Nome);
        CNPJCPF       := IniBoletos.ReadString(CCedente,'CNPJCPF',CNPJCPF);
        Logradouro    := IniBoletos.ReadString(CCedente,'Logradouro',Logradouro);
        NumeroRes     := IniBoletos.ReadString(CCedente,'Numero',NumeroRes);
        Bairro        := IniBoletos.ReadString(CCedente,'Bairro',Bairro);
        Cidade        := IniBoletos.ReadString(CCedente,'Cidade',Cidade);
        CEP           := IniBoletos.ReadString(CCedente,'CEP',CEP);
        Complemento   := IniBoletos.ReadString(CCedente,'Complemento',Complemento);
        UF            := IniBoletos.ReadString(CCedente,'UF',UF);
        Telefone      := IniBoletos.ReadString(CCedente,'Telefone',Telefone);
        CodigoCedente := IniBoletos.ReadString(CCedente,'CodigoCedente',CodigoCedente);
        Modalidade    := IniBoletos.ReadString(CCedente,'MODALIDADE',Modalidade);
        CodigoTransmissao:= IniBoletos.ReadString(CCedente,'CODTRANSMISSAO',CodigoTransmissao);
        Convenio      := IniBoletos.ReadString(CCedente,'CONVENIO',Convenio);
        CaracTitulo  := TACBrCaracTitulo(IniBoletos.ReadInteger(CCedente,'CaracTitulo',Integer(CaracTitulo) ));
        TipoCarteira := TACBrTipoCarteira(IniBoletos.ReadInteger(CCedente,'TipoCarteira', Integer(TipoCarteira) ));
        TipoDocumento:= TACBrTipoDocumento(IniBoletos.ReadInteger(CCedente,'TipoDocumento', Integer(TipoDocumento) ) + 1 );
        if Assigned(Self.ACBrBoletoFC) then
        begin
          wLayoutBoleto:= IniBoletos.ReadInteger(CCedente,'LAYOUTBOL', Integer(Self.ACBrBoletoFC.LayOut) );
          Self.ACBrBoletoFC.LayOut  := TACBrBolLayOut(wLayoutBoleto);
        end;
        wRespEmissao := IniBoletos.ReadInteger(CCedente,'RespEmis', Integer(ResponEmissao) );
        try
          ResponEmissao := TACBrResponEmissao( wRespEmissao );
        except
          ResponEmissao := tbCliEmite ;
        end ;

        Result   := True;
      end;

      //Banco
      if IniBoletos.SectionExists('Banco') then
      begin
        wNumeroBanco := IniBoletos.ReadInteger(CBanco,'Numero', 0 );
        wIndiceACBr  := IniBoletos.ReadInteger(CBanco,'IndiceACBr', IniBoletos.ReadInteger(CBanco,'TipoCobranca', 0 ) );
        wCNAB        := IniBoletos.ReadInteger(CBanco,'CNAB', Integer(LayoutRemessa) );
        wNumeroCorrespondente  := IniBoletos.ReadInteger(CBanco,'NumeroCorrespondente', 0 );
        wVersaoArquivo := IniBoletos.ReadInteger(CBanco,'VersaoArquivo', 0 );
        wVersaoLote := IniBoletos.ReadInteger(CBanco,'VersaoLote', 0 );

        if ( wCNAB = 0 ) then
           LayoutRemessa := c240
        else
           LayoutRemessa := c400;

        if ( wIndiceACBr > 0 ) then
          Banco.TipoCobranca:= TACBrTipoCobranca(wIndiceACBr)
        else if ( wNumeroBanco > 0 ) then
          Banco.TipoCobranca := GetTipoCobranca(wNumeroBanco);

        if (trim(Banco.Nome) = 'N�o definido') then
           raise exception.Create('Banco n�o definido ou n�o '+
                                  'implementado no ACBrBoleto!');

        if ( wNumeroCorrespondente > 0 ) then
          Banco.NumeroCorrespondente:= wNumeroCorrespondente;

        if ( wVersaoArquivo > 0 ) then
          Banco.LayoutVersaoArquivo:= wVersaoArquivo;

        if ( wVersaoLote > 0 ) then
          Banco.LayoutVersaoLote:= wVersaoLote;

        Result := True;
      end;

      //Conta
      if IniBoletos.SectionExists('Conta') then
      begin
        Conta         := IniBoletos.ReadString(CConta,'Conta', Conta);
        ContaDigito   := IniBoletos.ReadString(CConta,'DigitoConta', ContaDigito);
        Agencia       := IniBoletos.ReadString(CConta,'Agencia', Agencia);
        AgenciaDigito := IniBoletos.ReadString(CConta,'DigitoAgencia', AgenciaDigito);
        DigitoVerificadorAgenciaConta := IniBoletos.ReadString(CConta,'DigitoVerificadorAgenciaConta',
                                      DigitoVerificadorAgenciaConta );

        Result := True;
      end;

    end;

    if (IniBoletos.SectionExists('Titulo')) or (IniBoletos.SectionExists('Titulo1')) then
    begin
      with Self do
      begin
        //Titulo
        if (trim(Banco.Nome) = 'N�o definido') then
                raise exception.Create('Banco n�o definido ou n�o '+
                                       'implementado no ACBrBoleto!');

        I := 1 ;
        while true do
        begin
          Sessao := 'Titulo' + IntToStr(I);
          sFim   := IniBoletos.ReadString(Sessao,'NumeroDocumento','FIM');

          if (sFim = 'FIM') and (Sessao = 'Titulo1')  then
          begin
            Sessao := 'Titulo';
            sFim   := IniBoletos.ReadString(Sessao,'NumeroDocumento','FIM');
          end;

          if (sFim = 'FIM')  then
            break ;

          Titulo := CriarTituloNaLista;

          MemFormatada := IniBoletos.ReadString(Sessao,'Mensagem','') ;
          MemFormatada := StringReplace( MemFormatada,'|',sLineBreak, [rfReplaceAll] );

          MemDetalhamento := IniBoletos.ReadString(Sessao,'Detalhamento','') ;
          MemDetalhamento := StringReplace( MemDetalhamento,'|',sLineBreak, [rfReplaceAll] );
          with Titulo do
          begin
            Aceite        := TACBrAceiteTitulo(IniBoletos.ReadInteger(Sessao,'Aceite',1));
//            Sacado.Pessoa := TACBrPessoa( IniBoletos.ReadInteger(Sessao,'Sacado.Pessoa',2) );
            Sacado.Pessoa := TACBrPessoa( IniBoletos.ReadInteger(Sessao,'Sacado.Pessoa',2) );
            OcorrenciaOriginal.Tipo := TACBrTipoOcorrencia(
                  IniBoletos.ReadInteger(Sessao,'OcorrenciaOriginal.TipoOcorrencia',0) ) ;
            TipoDiasProtesto := TACBrTipoDiasIntrucao(IniBoletos.ReadInteger(Sessao,'TipoDiasProtesto',0));
            TipoDiasNegativacao := TACBrTipoDiasIntrucao(IniBoletos.ReadInteger(Sessao,'TipoDiasNegativacao',0));
            TipoImpressao := TACBrTipoImpressao(IniBoletos.ReadInteger(Sessao,'TipoImpressao',1));
            TipoDesconto := TACBrTipoDesconto(IniBoletos.ReadInteger(Sessao,'TipoDesconto',0));
            TipoDesconto2 := TACBrTipoDesconto(IniBoletos.ReadInteger(Sessao,'TipoDesconto2',0));
            CarteiraEnvio:= TACBrCarteiraEnvio(IniBoletos.ReadInteger(Sessao,'CarteiraEnvio', 0));
            MultaValorFixo := IniBoletos.ReadBool(Sessao,'MultaValorFixo',False);

            wLocalPagto := IniBoletos.ReadString(Sessao,'LocalPagamento','');

            Vencimento          := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'Vencimento','')), now);
            DataDocumento       := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataDocumento','')),now);
            DataProcessamento   := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataProcessamento','')),now);
            DataAbatimento      := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataAbatimento','')),0);
            DataDesconto        := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataDesconto','')),0);
            DataMoraJuros       := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataMoraJuros','')),0);
  	    DataMulta           := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataMulta','')),0);
            DiasDeProtesto      := IniBoletos.ReadInteger(Sessao,'DiasDeProtesto',0);
            if (DiasDeProtesto = 0) then
              DataProtesto      := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataProtesto','')),0);
            DiasDeNegativacao   := IniBoletos.ReadInteger(Sessao,'DiasDeNegativacao',0);
            if (DiasDeNegativacao = 0) then
              DataNegativacao   := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataNegativacao','')),0);
            DataBaixa           := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataBaixa','')),0);
            DataLimitePagto     := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'DataLimitePagto','')),0);
            LocalPagamento      := IfThen(Trim(wLocalPagto) <> '',wLocalPagto,LocalPagamento);
            NumeroDocumento     := IniBoletos.ReadString(Sessao,'NumeroDocumento',NumeroDocumento);
            EspecieDoc          := IniBoletos.ReadString(Sessao,'Especie',EspecieDoc);
            Carteira            := trim(IniBoletos.ReadString(Sessao,'Carteira',''));
            NossoNumero         := IniBoletos.ReadString(Sessao,'NossoNumero','');
            ValorDocumento      := IniBoletos.ReadFloat(Sessao,'ValorDocumento',ValorDocumento);
            Sacado.NomeSacado   := IniBoletos.ReadString(Sessao,'Sacado.NomeSacado','');
            Sacado.CNPJCPF      := OnlyNumber(IniBoletos.ReadString(Sessao,'Sacado.CNPJCPF',''));
            Sacado.Logradouro   := IniBoletos.ReadString(Sessao,'Sacado.Logradouro','');
            Sacado.Numero       := IniBoletos.ReadString(Sessao,'Sacado.Numero','');
            Sacado.Bairro       := IniBoletos.ReadString(Sessao,'Sacado.Bairro','');
            Sacado.Complemento  := IniBoletos.ReadString(Sessao,'Sacado.Complemento','');
            Sacado.Cidade       := IniBoletos.ReadString(Sessao,'Sacado.Cidade','');
            Sacado.UF           := IniBoletos.ReadString(Sessao,'Sacado.UF','');
            Sacado.CEP          := OnlyNumber(IniBoletos.ReadString(Sessao,'Sacado.CEP',''));
            Sacado.Email        := IniBoletos.ReadString(Sessao,'Sacado.Email',Sacado.Email);
            EspecieMod          := IniBoletos.ReadString(Sessao,'EspecieMod',EspecieMod);
            Mensagem.Text       := MemFormatada;
            Detalhamento.Text   := MemDetalhamento;
            Instrucao1          := PadLeft(IniBoletos.ReadString(Sessao,'Instrucao1',Instrucao1),2);
            Instrucao2          := PadLeft(IniBoletos.ReadString(Sessao,'Instrucao2',Instrucao2),2);
            TotalParcelas       := IniBoletos.ReadInteger(Sessao,'TotalParcelas',TotalParcelas);
            Parcela             := IniBoletos.ReadInteger(Sessao,'Parcela',Parcela);
            ValorAbatimento     := IniBoletos.ReadFloat(Sessao,'ValorAbatimento',ValorAbatimento);
            ValorDesconto       := IniBoletos.ReadFloat(Sessao,'ValorDesconto',ValorDesconto);
            ValorMoraJuros      := IniBoletos.ReadFloat(Sessao,'ValorMoraJuros',ValorMoraJuros);
            ValorIOF            := IniBoletos.ReadFloat(Sessao,'ValorIOF',ValorIOF);
            ValorOutrasDespesas := IniBoletos.ReadFloat(Sessao,'ValorOutrasDespesas',ValorOutrasDespesas);
            SeuNumero           := IniBoletos.ReadString(Sessao,'SeuNumero',SeuNumero);
            PercentualMulta     := IniBoletos.ReadFloat(Sessao,'PercentualMulta',PercentualMulta);
            CodigoMora          := IniBoletos.ReadString(Sessao,'CodigoMora','1');
            CodigoMoraJuros     := TACBrCodigoJuros(IniBoletos.ReadInteger(Sessao,'CodigoMoraJuros', 2 ));
            CodigoGeracao       := IniBoletos.ReadString(Sessao,'CodigoGeracao','2');
            Competencia         := IniBoletos.ReadString(Sessao,'Competencia', Competencia);
            ArquivoLogoEmp      := IniBoletos.ReadString(Sessao,'ArquivoLogoEmp', ArquivoLogoEmp);
            Verso               := IniBoletos.ReadBool(Sessao,'Verso', False);
            Sacado.SacadoAvalista.Pessoa        := TACBrPessoa( IniBoletos.ReadInteger(Sessao,'Sacado.SacadoAvalista.Pessoa',2) );
            Sacado.SacadoAvalista.NomeAvalista  := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.NomeAvalista','');
            Sacado.SacadoAvalista.CNPJCPF       := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.CNPJCPF','');
            Sacado.SacadoAvalista.Logradouro    := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.Logradouro','');
            Sacado.SacadoAvalista.Numero        := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.Numero','');
            Sacado.SacadoAvalista.Complemento   := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.Complemento','');
            Sacado.SacadoAvalista.Bairro        := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.Bairro','');
            Sacado.SacadoAvalista.Cidade        := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.Cidade','');
            Sacado.SacadoAvalista.UF            := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.UF','');
            Sacado.SacadoAvalista.CEP           := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.CEP','');
            Sacado.SacadoAvalista.Email         := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.Email','');
            Sacado.SacadoAvalista.Fone          := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.Fone','');
            Sacado.SacadoAvalista.InscricaoNr   := IniBoletos.ReadString(Sessao,'Sacado.SacadoAvalista.InscricaoNr','');

            //Apenas banco Pine
            if (IniBoletos.SectionExists('NFe1') ) then
            begin
              with Self do
              begin
                N := 1 ;
                while true do
                begin
                  Sessao := 'NFe' + IntToStr(N);
                  sFim   := IniBoletos.ReadString(Sessao,'ChaveNFe','FIM');

                  if (sFim = 'FIM') or (Length(sFim) <= 0) then
                    break ;

                  NFe := CriarNFeNaLista;
                  NFe.NumNFe := IniBoletos.ReadString(Sessao,'NumNFe','');
                  NFe.ValorNFe := IniBoletos.ReadFloat(Sessao,'ValorNFe',0);
                  NFe.EmissaoNFe := StrToDateDef(Trim(IniBoletos.ReadString(Sessao,'EmissaoNFe','')), 0);
                  NFe.ChaveNFe := sFim;

                  Inc(N);
                end;
              end;
            end;

          end;
          inc(I);
          Result := True;
        end;
      end;
    end;

  finally
    IniBoletos.free;
  end;

end;

function TACBrBoleto.GravarArqIni(DirIniRetorno: string; const NomeArquivo: String): String;
var
  IniRetorno: TMemIniFile;
  SL: TStringList;
  wSessao: String;
  I: Integer;
  J: Integer;
begin
  Result:= '';
  if Pos(PathDelim,DirIniRetorno) <> Length(DirIniRetorno) then
     DirIniRetorno:= DirIniRetorno + PathDelim;

  IniRetorno:= TMemIniFile.Create(DirIniRetorno + IfThen( EstaVazio(NomeArquivo), 'Retorno.ini', NomeArquivo ) );
  try
    with Self do
    begin
       IniRetorno.WriteString(CCedente,'Nome',Cedente.Nome);
       IniRetorno.WriteString(CCedente,'CNPJCPF',Cedente.CNPJCPF);
       IniRetorno.WriteString(CCedente,'CodigoCedente',Cedente. CodigoCedente);
       IniRetorno.WriteString(CCedente,'MODALIDADE',Cedente.Modalidade);
       IniRetorno.WriteString(CCedente,'CODTRANSMISSAO',Cedente.CodigoTransmissao);
       IniRetorno.WriteString(CCedente,'CONVENIO',Cedente.Convenio);

       IniRetorno.WriteInteger(CBanco,'Numero',Banco.Numero);
       IniRetorno.WriteInteger(CBanco,'IndiceACBr',Integer(Banco.TipoCobranca));
       IniRetorno.WriteInteger(CBanco,'NumeroCorrespondente',Banco.NumeroCorrespondente);
       IniRetorno.WriteInteger(CBanco,'VersaoArquivo',Banco.LayoutVersaoArquivo);
       IniRetorno.WriteInteger(CBanco,'VersaoLote',Banco.LayoutVersaoLote);

       IniRetorno.WriteString(CConta,'Conta',Cedente.Conta);
       IniRetorno.WriteString(CConta,'DigitoConta',Cedente.ContaDigito);
       IniRetorno.WriteString(CConta,'Agencia',Cedente.Agencia);
       IniRetorno.WriteString(CConta,'DigitoAgencia',Cedente.AgenciaDigito);
       IniRetorno.WriteString(CConta,'DigitoVerificadorAgenciaConta',Cedente.DigitoVerificadorAgenciaConta);

       for I:= 0 to ListadeBoletos.Count - 1 do
       begin
         wSessao:= 'Titulo'+ IntToStr(I+1);
         IniRetorno.WriteString(wSessao,'Sacado.Nome', ListadeBoletos[I].Sacado.NomeSacado);
         IniRetorno.WriteString(wSessao,'Sacado.CNPJCPF', ListadeBoletos[I].Sacado.CNPJCPF);
         IniRetorno.WriteString(wSessao,'Vencimento',DateToStr(ListadeBoletos[I].Vencimento));
         IniRetorno.WriteString(wSessao,'DataDocumento',DateToStr(ListadeBoletos[I].DataDocumento));
         IniRetorno.WriteString(wSessao,'NumeroDocumento',ListadeBoletos[I].NumeroDocumento);
         IniRetorno.WriteString(wSessao,'DataProcessamento',DateToStr(ListadeBoletos[I].DataProcessamento));
         IniRetorno.WriteString(wSessao,'NossoNumero',ListadeBoletos[I].NossoNumero);
         IniRetorno.WriteString(wSessao,'Carteira',ListadeBoletos[I].Carteira);
         IniRetorno.WriteFloat(wSessao,'ValorDocumento',ListadeBoletos[I].ValorDocumento);
         IniRetorno.WriteString(wSessao,'DataOcorrencia',DateToStr(ListadeBoletos[I].DataOcorrencia));
         IniRetorno.WriteString(wSessao,'DataCredito',DateToStr(ListadeBoletos[I].DataCredito));
         IniRetorno.WriteString(wSessao,'DataBaixa',DateToStr(ListadeBoletos[I].DataBaixa));
         IniRetorno.WriteString(wSessao,'DataMoraJuros',DateToStr(ListadeBoletos[I].DataMoraJuros));
         IniRetorno.WriteFloat(wSessao,'ValorDespesaCobranca',ListadeBoletos[I].ValorDespesaCobranca);
         IniRetorno.WriteFloat(wSessao,'ValorAbatimento',ListadeBoletos[I].ValorAbatimento);
         IniRetorno.WriteFloat(wSessao,'ValorDesconto',ListadeBoletos[I].ValorDesconto);
         IniRetorno.WriteFloat(wSessao,'ValorMoraJuros',ListadeBoletos[I].ValorMoraJuros);
         IniRetorno.WriteFloat(wSessao,'ValorIOF',ListadeBoletos[I].ValorIOF);
         IniRetorno.WriteFloat(wSessao,'ValorOutrasDespesas',ListadeBoletos[I].ValorOutrasDespesas);
         IniRetorno.WriteFloat(wSessao,'ValorOutrosCreditos',ListadeBoletos[I].ValorOutrosCreditos);
         IniRetorno.WriteFloat(wSessao,'ValorRecebido',ListadeBoletos[I].ValorRecebido);
         IniRetorno.WriteString(wSessao,'SeuNumero',ListadeBoletos[I].SeuNumero);
         IniRetorno.WriteString(wSessao,'CodTipoOcorrencia',
                                GetEnumName( TypeInfo(TACBrTipoOcorrencia),
                                             Integer(ListadeBoletos[I].OcorrenciaOriginal.Tipo)));
         IniRetorno.WriteString(wSessao,'DescricaoTipoOcorrencia',ListadeBoletos[I].OcorrenciaOriginal.Descricao);

         for J:= 0 to ListadeBoletos[I].DescricaoMotivoRejeicaoComando.Count-1 do
            IniRetorno.WriteString(wSessao,'MotivoRejeicao' + IntToStr(I+1),
                                   ListadeBoletos[I].DescricaoMotivoRejeicaoComando[J]);
       end;

    end;

    SL:= TStringList.Create;
    try
      IniRetorno.GetStrings(SL);
      Result:= SL.Text;
    finally
      SL.Free;
    end;

  finally
    IniRetorno.Free;
  end;

end;

procedure TACBrBoleto.GravarIniRetornoWeb(DirRetorno: string;
  const NomeArquivo: string);
var
  IniRetorno: TMemIniFile;
  wSessao: string;
  i, j: integer;
begin
  if EstaVazio(DirRetorno) then
    DirRetorno:= PathWithDelim(ApplicationPath);
  try
    if not DirectoryExists(DirRetorno) then
      ForceDirectories(DirRetorno);

  Except
    raise Exception.Create(ACBrStr('Diret�rio inv�lido:' +
      sLineBreak + DirRetorno));
  end;

  IniRetorno := TMemIniFile.Create(PathWithDelim(DirRetorno) + IfThen(
    EstaVazio(NomeArquivo), 'Retorno_Registro.ini', NomeArquivo));
  try
    if ListaRetornoWeb.Count > 0 then
    begin
      for i := 0 to ListaRetornoWeb.Count - 1 do
      begin
        wSessao := 'REGISTRO' + IntToStr(i + 1);
        IniRetorno.WriteString(wSessao, 'Cod_Retorno',ListaRetornoWeb[i].CodRetorno);
        IniRetorno.WriteString(wSessao, 'Msg_Retorno',ListaRetornoWeb[i].MsgRetorno);
        IniRetorno.WriteString(wSessao, 'Ori_Retorno',ListaRetornoWeb[i].OriRetorno);

        for j:= 0 to ListaRetornoWeb[i].ListaRejeicao.Count -1 do
        begin
          wSessao := 'REJEICAO' + IntToStr(j + 1);
          IniRetorno.WriteString(wSessao, 'Campo', ListaRetornoWeb[i].ListaRejeicao[j].Campo);
          IniRetorno.WriteString(wSessao, 'Mensagem', ListaRetornoWeb[i].ListaRejeicao[j].Mensagem);
          IniRetorno.WriteString(wSessao, 'Valor', ListaRetornoWeb[i].ListaRejeicao[j].Valor);
        end;

        wSessao := 'HEADER';
        IniRetorno.WriteString(wSessao, 'Versao',ListaRetornoWeb[i].Header.Versao);
        IniRetorno.WriteString(wSessao, 'Autenticacao',ListaRetornoWeb[i].Header.Autenticacao);
        IniRetorno.WriteString(wSessao, 'Usuario_Servico',ListaRetornoWeb[i].Header.Usuario_Servico);
        IniRetorno.WriteString(wSessao, 'Usuario',ListaRetornoWeb[i].Header.Usuario);
        IniRetorno.WriteString(wSessao, 'Operacao', TipoOperacaoToStr(ListaRetornoWeb[i].Header.Operacao));
        IniRetorno.WriteInteger(wSessao, 'Indice',ListaRetornoWeb[i].Header.Indice);
        IniRetorno.WriteString(wSessao, 'Sistema_Origem',ListaRetornoWeb[i].Header.Sistema_Origem);
        IniRetorno.WriteInteger(wSessao, 'Agencia',ListaRetornoWeb[i].Header.Agencia);
        IniRetorno.WriteString(wSessao, 'ID_Origem',ListaRetornoWeb[i].Header.Id_Origem);
        IniRetorno.WriteDateTime(wSessao, 'Data_Hora',ListaRetornoWeb[i].Header.Data_Hora);
        IniRetorno.WriteString(wSessao, 'ID_Processo',ListaRetornoWeb[i].Header.Id_Processo);

        wSessao := 'DADOS';
        IniRetorno.WriteString(wSessao, 'Excessao',ListaRetornoWeb[i].DadosRet.Excecao);

        wSessao := 'CONTROLE_NEGOCIAL';
        IniRetorno.WriteString(wSessao, 'Origem_Retorno',ListaRetornoWeb[i].DadosRet.ControleNegocial.OriRetorno);
        IniRetorno.WriteString(wSessao, 'NSU',ListaRetornoWeb[i].DadosRet.ControleNegocial.NSU);
        IniRetorno.WriteString(wSessao, 'Cod_Retorno',ListaRetornoWeb[i].DadosRet.ControleNegocial.CodRetorno);
        IniRetorno.WriteString(wSessao, 'Msg_Retorno',ListaRetornoWeb[i].DadosRet.ControleNegocial.Retorno);

        wSessao := 'COMPROVANTE';
        IniRetorno.WriteDate(wSessao, 'Data',ListaRetornoWeb[i].DadosRet.Comprovante.Data);
        IniRetorno.WriteString(wSessao, 'Hora',ListaRetornoWeb[i].DadosRet.Comprovante.Hora);

        wSessao := 'ID_BOLETO';
        IniRetorno.WriteString(wSessao, 'Codigo_Barras',ListaRetornoWeb[i].DadosRet.IDBoleto.CodBarras);
        IniRetorno.WriteString(wSessao, 'Linha_Digitavel',ListaRetornoWeb[i].DadosRet.IDBoleto.LinhaDig);
        IniRetorno.WriteString(wSessao, 'Nosso_Numero',ListaRetornoWeb[i].DadosRet.IDBoleto.NossoNum);
        IniRetorno.WriteString(wSessao, 'URL',ListaRetornoWeb[i].DadosRet.IDBoleto.URL);

        if NaoEstaVazio(ListaRetornoWeb[i].DadosRet.TituloRet.NumeroDocumento) then
        begin
          wSessao := 'CONSULTA_BOLETO';
          IniRetorno.WriteString(wSessao, 'Numero_Documento',ListaRetornoWeb[i].DadosRet.TituloRet.NumeroDocumento);
          IniRetorno.WriteDate(wSessao, 'Data_Vencimento',ListaRetornoWeb[i].DadosRet.TituloRet.Vencimento);
          IniRetorno.WriteFloat(wSessao, 'Valor',ListaRetornoWeb[i].DadosRet.TituloRet.ValorDocumento);

        end;

        if NaoEstaVazio(ListaRetornoWeb[i].DadosRet.TituloRet.CodBarras) then
        begin
          wSessao := 'TITULO_RETORNO';

          IniRetorno.WriteDate(wSessao, 'vencimento_titulo',ListaRetornoWeb[i].DadosRet.TituloRet.Vencimento);
          IniRetorno.WriteString(wSessao, 'tipo_carteira_titulo',ListaRetornoWeb[i].DadosRet.TituloRet.Carteira);
          IniRetorno.WriteString(wSessao, 'nosso_numero',ListaRetornoWeb[i].DadosRet.TituloRet.NossoNumero);
          IniRetorno.WriteString(wSessao, 'seu_numero',ListaRetornoWeb[i].DadosRet.TituloRet.SeuNumero);
          IniRetorno.WriteString(wSessao, 'especie',ListaRetornoWeb[i].DadosRet.TituloRet.EspecieDoc);
          IniRetorno.WriteString(wSessao, 'codigo_barras',ListaRetornoWeb[i].DadosRet.TituloRet.CodBarras);
          IniRetorno.WriteString(wSessao, 'numero_linha_digitavel',ListaRetornoWeb[i].DadosRet.TituloRet.LinhaDig);
          IniRetorno.WriteString(wSessao, 'local_pagamento',ListaRetornoWeb[i].DadosRet.TituloRet.Mensagem.Text);
          IniRetorno.WriteDate(wSessao, 'data_processamento',ListaRetornoWeb[i].DadosRet.TituloRet.DataProcessamento);
          IniRetorno.WriteDate(wSessao, 'data_emissao',ListaRetornoWeb[i].DadosRet.TituloRet.DataDocumento);
          IniRetorno.WriteString(wSessao, 'uso_banco',ListaRetornoWeb[i].DadosRet.TituloRet.UsoBanco);
          IniRetorno.WriteFloat(wSessao, 'valor_titulo',ListaRetornoWeb[i].DadosRet.TituloRet.ValorDocumento);
          IniRetorno.WriteFloat(wSessao, 'valor_desconto',ListaRetornoWeb[i].DadosRet.TituloRet.ValorDesconto);
          IniRetorno.WriteFloat(wSessao, 'valor_outra_deducao',ListaRetornoWeb[i].DadosRet.TituloRet.ValorDespesaCobranca);
          IniRetorno.WriteFloat(wSessao, 'valor_juro_multa',ListaRetornoWeb[i].DadosRet.TituloRet.ValorMoraJuros);
          IniRetorno.WriteFloat(wSessao, 'valor_outro_acrescimo',ListaRetornoWeb[i].DadosRet.TituloRet.ValorOutrosCreditos);
          IniRetorno.WriteFloat(wSessao, 'valor_total_cobrado',ListaRetornoWeb[i].DadosRet.TituloRet.ValorPago);
          IniRetorno.WriteString(wSessao, 'texto_informacao_cliente_beneficiario',ListaRetornoWeb[i].DadosRet.TituloRet.Informativo.Text);

        end;


      end;
    end;

  finally
    IniRetorno.Free;
  end;

end;

{ TACBrBoletoFCClass }

constructor TACBrBoletoFCClass.Create ( AOwner: TComponent ) ;
begin
  inherited Create ( AOwner ) ;

  fACBrBoleto          := nil;
  fLayOut              := lPadrao;
  fNumCopias           := 1;
  fMostrarPreview      := True;
  fMostrarSetup        := True;
  fMostrarProgresso    := True;
  fFiltro              := fiNenhum;
  fNomeArquivo         := '' ;
  fPathNomeArquivo     := '' ;
  fPrinterName         := '' ;
  FAlterarEscalaPadrao := False;
  FNovaEscala          := 96;
  FIndiceImprimirIndividual := -1;
  FCalcularNomeArquivoPDFIndividual := True;

end;

procedure TACBrBoletoFCClass.Notification ( AComponent: TComponent;
   Operation: TOperation ) ;
begin
   inherited Notification ( AComponent, Operation ) ;

   if (Operation = opRemove) and (fACBrBoleto <> nil) and (AComponent is TACBrBoleto) then
      fACBrBoleto := nil ;
end;

function TACBrBoletoFCClass.TituloRelatorio: String;
begin
  Result := 'Boleto - '+ACBrBoleto.Banco.Nome+
            ' Ag:'+ACBrBoleto.Cedente.Agencia+'-'+ACBrBoleto.Cedente.AgenciaDigito+
            ' Conta:'+ACBrBoleto.Cedente.Conta+'-'+ACBrBoleto.Cedente.ContaDigito;
end;

procedure TACBrBoletoFCClass.CarregaLogo(const PictureLogo : TPicture; const NumeroBanco: Integer ) ;
begin
  if Assigned( fOnObterLogo ) then
     fOnObterLogo( PictureLogo, NumeroBanco)
  else
   begin
     if FileExists( ArquivoLogo ) then
        PictureLogo.LoadFromFile( ArquivoLogo );
   end ;
end ;

procedure TACBrBoletoFCClass.SetACBrBoleto ( const Value: TACBrBoleto ) ;
  Var OldValue : TACBrBoleto ;
begin
  if Value <> fACBrBoleto then
  begin
    if Assigned(fACBrBoleto) then
        fACBrBoleto.RemoveFreeNotification(Self);

     OldValue    := fACBrBoleto ;   // Usa outra variavel para evitar Loop Infinito
     fACBrBoleto := Value;          // na remo��o da associa��o dos componentes

     if Assigned(OldValue) then
        if Assigned(OldValue.ACBrBoletoFC) then
           OldValue.ACBrBoletoFC := nil ;

     if Value <> nil then
     begin
        Value.FreeNotification(self);
        Value.ACBrBoletoFC := self ;
     end ;
  end ;

end;

procedure TACBrBoletoFCClass.SetDirLogo(const AValue: String);
begin
  fDirLogo := PathWithoutDelim( Trim(AValue) );
end;

procedure TACBrBoletoFCClass.SetNomeArquivo(const AValue: String);
begin
  fNomeArquivo := Trim(AValue);
  fPathNomeArquivo := '';
end;

function TACBrBoletoFCClass.GetArquivoLogo: String;
begin
   Result := PathWithDelim(DirLogo) + IntToStrZero( ACBrBoleto.Banco.Numero, 3)+'.bmp';
end;

function TACBrBoletoFCClass.ComponentStateDesigning: Boolean;
begin
  Result := (csDesigning in Self.ComponentState);

  if not Result then
    if Assigned(fACBrBoleto) then
      Result := (csDesigning in fACBrBoleto.ComponentState);
end;

function TACBrBoletoFCClass.GetDirLogo: String;
begin
  if (fDirLogo = '') then
    if not ComponentStateDesigning then
      fDirLogo := ApplicationPath + 'Logos' ;

  Result := fDirLogo ;
end;

function TACBrBoletoFCClass.GetNomeArquivo: String;
var
  wPath, wFile: String;
begin
  if ComponentStateDesigning then
    Result := fNomeArquivo
  else
  begin
    if (fPathNomeArquivo = '') then
    begin
      wPath := ExtractFilePath(fNomeArquivo);
      if (wPath = '') then
        wPath := ApplicationPath;

      wFile := ExtractFileName(fNomeArquivo);
      if (wFile = '') then
        wFile := 'boleto';

      fPathNomeArquivo := trim(PathWithDelim(wPath) + wFile);
    end;

    Result := fPathNomeArquivo;
  end;
end;

function TACBrBoletoFCClass.GetIndiceImprimirIndividual: Integer;
begin
   Result := FIndiceImprimirIndividual;
end;

function TACBrBoletoFCClass.GetNomeArquivoPdfIndividual(const ANomeArquivo: String;
         const AIndex: Integer): String;
var
  lNumDocumento: String;
begin
  lNumDocumento := OnlyNumber(ACBrBoleto.ListadeBoletos[AIndex].NumeroDocumento);
  if ANomeArquivo = '' then
    Result := PathWithDelim( ApplicationPath ) + ChangeFileExt(lNumDocumento, '.pdf')
  else
    Result := ChangeFileExt( ChangeFileExt(ANomeArquivo,'') + '_' + lNumDocumento, '.pdf');
end;

procedure TACBrBoletoFCClass.SetNumCopias ( AValue: Integer ) ;
begin
  fNumCopias := max( 1, Avalue);
end;

procedure TACBrBoletoFCClass.SetPdfSenha(const Value: string);
begin
  FPdfSenha := Value;
end;

procedure TACBrBoletoFCClass.SetTituloPreview(const Value: string);
begin
  if Value <> FTituloPreview then
    FTituloPreview := Value;
end;

procedure TACBrBoletoFCClass.SetIndiceImprimirIndividual(const Value: Integer);
begin
  if Value <> FIndiceImprimirIndividual then
    FIndiceImprimirIndividual:= Value;
end;

procedure TACBrBoletoFCClass.Imprimir;
begin
   if not Assigned(fACBrBoleto) then
      raise Exception.Create(ACBrStr('Componente n�o est� associado a ACBrBoleto'));

   if fACBrBoleto.ListadeBoletos.Count < 1 then
      raise Exception.Create(ACBrStr('Lista de Boletos est� vazia'));
end;

procedure TACBrBoletoFCClass.GerarPDF;
var
   FiltroAntigo         : TACBrBoletoFCFiltro;
   MostrarPreviewAntigo : Boolean;
   MostrarSetupAntigo   : Boolean;
   PrinterNameAntigo    : String;
   NomeArquivoAntigo    : String;
begin
   if NomeArquivo = '' then
      raise Exception.Create( ACBrStr('NomeArquivo n�o especificado')) ;

   if not Assigned(fACBrBoleto) then
       raise Exception.Create(ACBrStr('Componente n�o est� associado a ACBrBoleto'));

   FiltroAntigo         := Filtro;
   MostrarPreviewAntigo := MostrarPreview;
   MostrarSetupAntigo   := MostrarSetup;
   PrinterNameAntigo    := PrinterName;
   NomeArquivoAntigo    := NomeArquivo;
   try
     Filtro         := fiPDF;
     MostrarPreview := false;
     MostrarSetup   := false;
     PrinterName    := '';

     if fACBrBoleto.ListadeBoletos.Count < 1 then
       raise Exception.Create(ACBrStr('Lista de Boletos est� vazia'));

     if (FIndiceImprimirIndividual >= 0) and (FCalcularNomeArquivoPDFIndividual) then
     begin
       fPathNomeArquivo:= '';
       NomeArquivo := GetNomeArquivoPdfIndividual(NomeArquivoAntigo, FIndiceImprimirIndividual);
       Imprimir;
       NomeArquivo:= NomeArquivoAntigo;

     end
     else
     begin
       NomeArquivo := ChangeFileExt(NomeArquivo, '.pdf');
       Imprimir;
     end;

   finally
     Filtro         := FiltroAntigo;
     MostrarPreview := MostrarPreviewAntigo;
     MostrarSetup   := MostrarSetupAntigo;
     PrinterName    := PrinterNameAntigo;
   end;
end;

procedure TACBrBoletoFCClass.GerarHTML;
var
   FiltroAntigo         : TACBrBoletoFCFiltro;
   MostrarPreviewAntigo : Boolean;
   MostrarSetupAntigo   : Boolean;
   PrinterNameAntigo    : String;
begin
   if NomeArquivo = '' then
      raise Exception.Create( ACBrStr('NomeArquivo n�o especificado')) ;

   NomeArquivo := ChangeFileExt(NomeArquivo, '.html');

   FiltroAntigo         := Filtro;
   MostrarPreviewAntigo := MostrarPreview;
   MostrarSetupAntigo   := MostrarSetup;
   PrinterNameAntigo    := PrinterName;
   try
     Filtro         := fiHTML;
     MostrarPreview := false;
     MostrarSetup   := false;
     PrinterName    := '';
     Imprimir;
   finally
     Filtro         := FiltroAntigo;
     MostrarPreview := MostrarPreviewAntigo;
     MostrarSetup   := MostrarSetupAntigo;
     PrinterName    := PrinterNameAntigo;
   end;
end;

procedure TACBrBoletoFCClass.GerarJPG;
var
   FiltroAntigo         : TACBrBoletoFCFiltro;
   MostrarPreviewAntigo : Boolean;
   MostrarSetupAntigo   : Boolean;
   PrinterNameAntigo    : String;
begin
   if NomeArquivo = '' then
      raise Exception.Create( ACBrStr('NomeArquivo n�o especificado')) ;

   NomeArquivo := ChangeFileExt(NomeArquivo, '.jpg');

   FiltroAntigo         := Filtro;
   MostrarPreviewAntigo := MostrarPreview;
   MostrarSetupAntigo   := MostrarSetup;
   PrinterNameAntigo    := PrinterName;
   try
     Filtro         := fiJPG;
     MostrarPreview := false;
     MostrarSetup   := false;
     PrinterName    := '';
     Imprimir;
   finally
     Filtro         := FiltroAntigo;
     MostrarPreview := MostrarPreviewAntigo;
     MostrarSetup   := MostrarSetupAntigo;
     PrinterName    := PrinterNameAntigo;
   end;
end;

{ TACBrOcorrencia }

function TACBrOcorrencia.GetCodigoBanco: String;
begin
   Result:= fpAowner.AcbrBoleto.Banco.TipoOCorrenciaToCod(Tipo);
end;

function TACBrOcorrencia.GetDescricao: String;
begin
   //if Tipo <> 0 then
      Result:= fpAowner.ACBrBoleto.Banco.TipoOcorrenciaToDescricao(Tipo)
   //else
   //   Result:= '';
end;

constructor TACBrOcorrencia.Create(AOwner: TACBrTitulo);
begin
   fTipo := toRemessaRegistrar;
   fpAOwner:= AOwner;
end;



{$ifdef FPC}
initialization
   {$I ACBrBoleto.lrs}
{$endif}

end.

