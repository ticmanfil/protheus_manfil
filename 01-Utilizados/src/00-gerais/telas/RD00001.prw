#include 'protheus.ch'
#include 'topconn.ch'
#include 'apwebsrv.ch'
#include 'apwebex.ch'
#include 'ap5mail.ch'
#include 'totvs.ch'
#include 'RPTDEF.ch'
#include 'FWPrintSetup.ch'
#include 'apwebsrv.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: RD00001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa server para ajuntar funções genericas utilizados em outros programas
===============================================================================================================================
Uso---------------: Em todos rdmakes
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Gernericos
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Configurador
===============================================================================================================================
/*/
User Function RD00001()

Return

/*/
===============================================================================================================================
					INDICE
===============================================================================================================================

	EXECQRY					-> funcao para executar uma query
	FIMPOSTOS				-> FUNCAO PARA CALCULAR OS IMPOSTOS DE ACORDO COM A TES DO PRODUTO
	UVlOrc					-> Valor total do orcamento
	xVlNota					-> Valor total do doc. saida
	A000004					-> valor total do pedido no cabecalho
	VlTotalADA				-> valor total de contratos
	UChvNFE					-> busca a chave NFE do fiscal
	TemCHV					-> verifia se tem chave ou nao
	UEstoque				-> retorna o estoque atual por de um local
	UEEstrutura				-> verifica se existe ou nao estrutura para um determinado produto
	UxPutSx1				-> Adaptação da função padrão PutSX1 e PutSX1Help
	UValDescont				-> validar o valor da indenizacao 
	URegiao					-> regionalizar os clientes de acordo com suas cidade
	UPROXCODB1				-> proximo codigo do produto disponivel na SB1
	EnvMail					-> enviar email
	msgPergunta				-> Pergunta
	msgInforma				-> Informa ao usuário
	msgErro					-> Retorna erro ao usuario
	UgeraCSV				-> Exportar para o Excel
	UX3Titulo				-> retornar o titulo do campo informado
	UPROXCOD				-> proximo codigo GERANILIZADO
	UX5Descr				-> retornar a descricao de uma tabela SX5
	VldHora					-> validar se uma hora é valida
	LOJACLI					-> proxima loja valida para o cliente
	TEMBOLETO				-> verifica se tem boleto ou nao
	PrxBordero				-> retornar o proximo num bordero disponivel
	Emails					-> retornar os emails do grupo informado
	User					-> retornar os USERID do grupo informado
	ITCONTAB				-> cria conta contabil para cadastro de cliente e fornecedor
	EnvSefazS				-> rotina para enviar nota para o SEFAZ
	DIVERSOS FONTES PARA IMPRESSAO DE RELATORIO
	Cbc, Rdp, SaltaFolha, Orienta, TamPag, QuantLin, AltCar, Expande, Reduz, Negrito, 15Cpi, L8PolOn, DoubleStroke, Super, ConvData
	EstaGrp(cGrupos)		-> verifica se esta no grupo de usuario desejado ou nao
	DCONTRATO				-> Busca informação do contrato de parceria
	xGetIdEnt				-> Obeter o codigo da entidade
	ImpDanfe				-> imprimir DANFE customizado
	MskPF					-> formata cnpj ou cpf de acordo com o tipo de pessoa
	ValPeso					-> validar se foi preenchido o peso do produto
	CriarTabela				-> Criar Tabelas
	SelImp					-> Selecionar a Impressora a Imprimir
	ImpPedVen				-> Imprimir Pedido de Venda
	MovSitPed				-> Faz as devidas movimentações estatus do doc de saida (Controle Sit Pedido de Venda)
	SERIEORIG				-> Retorno a serie e numero da nota fiscal de cobranca
	NOTAORIG				-> Retorno a serie e numero da nota fiscal de cobranca
	TEMNFORI				-> Retorno RESERVA
	PRXSEQCAR				-> Proxima sequencia de carga do dia disponivel
	NFFISCA					-> Retorna  serie ou numero da nota fiscal emitida
	TABGENERICA				-> Bucas dados da tabela generica MANFIL
	CriaTabela				-> Criar tabela em tempo de execução
	ValDesconto				-> Valida percentual de desconto
	NTEncerrada				-> Verifica se a nota esta encerrado
	BscTit					-> Busca dados do titulos referenciado na FK's
	Conv2Unid				-> Converter para 2ª unidade
	Conv1Unid				-> Converter para 1ª unidade
	Stamps					-> criar os campos S_T_A_M_P e I_N_S_D_T não estão sendo criados no banco de dados
	AltParam				-> Alterar o valor de um parametro de ambiente
	DescParam				-> Descrever um parametro de ambiente
	PesqProc				-> Consulta uma tabela por procedure

/*/

/*/
===============================================================================================================================
Programa----------: ExecQry
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 15/09/2023
===============================================================================================================================
Descrição---------: Função que executa uma query e já exibe um log em tela em caso de falha
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: cQuery	=> Caractere, Query SQL que será executada no banco
					lFinal	=> Lógico, Define se irá encerrar o sistema em caso de falha
===============================================================================================================================
Retorno-----------: lDeuCerto	=> Lógico, .T. se a query foi executada com sucesso ou .F. se não
===============================================================================================================================
EXEMPLO-----------: u_ExecQry("UPDATE TABELA SET CAMPO = 'AAAA'")
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user Function ExecQry(cQuery, lFinal)
    Local 	aArea     := FWGetArea()

    Local 	lDeuCerto := .F.,;
			cMensagem := ""
    
	Default cQuery  := "",;
			lFinal  := .F.
 
    //Executa a clausula SQL
    If TCSqlExec(cQuery) < 0
         
        //Caso não esteja rodando via job / ws, monta a mensagem e exibe
        If ! IsBlind()
            cMensagem := "Falha na atualização do Banco de Dados!" + CRLF + CRLF
            cMensagem += "/* ==== Query: ===== */" + CRLF
            cMensagem += cQuery + CRLF + CRLF
            cMensagem += "/* ==== Mensagem: ===== */" + CRLF
            cMensagem += TCSQLError()
            ShowLog(cMensagem)
        EndIf
 
        //Se for para abortar o sistema, será exibido uma mensagem
        If lFinal
            Final("ExecQry: Falha na operação. Contate o Administrador.")
        EndIf
 
    //Se deu tudo certo, altera a flag de retorno
    Else
        lDeuCerto := .T.
    EndIf
 
    FWRestArea(aArea)  

return lDeuCerto

/*/
===============================================================================================================================
Programa----------: FIMPOSTOS
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 03/08/2023
===============================================================================================================================
Descrição---------: Este programa serve para CALCULAR OS IMPOSTOS
===============================================================================================================================
Uso---------------: ORCAMENTO (faturamento)
===============================================================================================================================
Parametros--------: cCliente	-> Codigo Cliente/Fornecedor
					cLoja		-> Loja do Cliente/Fornecedor
					cTipo		-> Tipo do Cliente/Fornecedor
					cProduto	-> Codigo do Produto
					cTes		-> TES
					nQtd		-> quantidade 
					nPrc		-> Preco de Venda
					nValor		-> Valor da Mercadoria
===============================================================================================================================
Retorno-----------: aImposto
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function FIMPOSTOS(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor,nQtdItem,nFrete,nDespesa,nSeguro)

	local 	aImp := {},;
			i
	
	for i := 1 to 62
		AAdd(aImp,0)
	next
	
	// -------------------------------------------------------------------
	// Realiza os calculos necessários
	// -------------------------------------------------------------------
	MaFisIni(cCliente,;										// 01- Codigo Cliente/Fornecedor
			 cLoja,;										// 02- Loja do Cliente/Fornecedor
			 "C",;											// 03- C: Cliente / F: Fornecedor
			 "N",;											// 04- Tipo da NF
			 cTipo,;										// 05- Tipo do Cliente/Fornecedor
			 MaFisRelImp("MTR700",{"SC5","SC6"}),;			// 06- Relacao de Impostos que suportados no arquivo
			 ,;												// 07- Tipo de complemento
			 ,;												// 08- Permite incluir impostos no rodape (.T./.F.)
			 "SB1",;										// 09- Alias do cadastro de Produtos - ("SBI" para Front Loja)
			 "MTR700")										// 10- Nome da rotina que esta utilizando a funcao
	
	// -------------------------------------------------------------------
	// Monta o retorno para a MaFisRet
	// -------------------------------------------------------------------
	MaFisAdd(cProduto,cTes,nQtd,nPrc,0,"","",0,nFrete/nQtdItem,nDespesa/nQtdItem,nSeguro/nQtdItem,0,nValor,0)
	
	// -------------------------------------------------------------------
	// Monta um array com os valores necessários
	// -------------------------------------------------------------------
	aImp[01] := cProduto
	aImp[02] := cTes
	aImp[03] := "ICM"							//03 ICMS
	aImp[04] := MaFisRet(1,"IT_BASEICM")		//04 Base do ICMS
	aImp[05] := MaFisRet(1,"IT_ALIQICM")		//05 Aliquota do ICMS
	aImp[06] := MaFisRet(1,"IT_VALICM")			//06 Valor do ICMS
	aImp[07] := "IPI"							//07 IPI
	aImp[08] := MaFisRet(1,"IT_BASEIPI")		//08 Base do IPI
	aImp[09] := MaFisRet(1,"IT_ALIQIPI")		//09 Aliquota do IPI
	aImp[10] := MaFisRet(1,"IT_VALIPI")			//10 Valor do IPI
	aImp[11] := "PIS"							//11 PIS/PASEP
	aImp[12] := MaFisRet(1,"IT_BASEPIS")		//12 Base do PIS
	aImp[13] := MaFisRet(1,"IT_ALIQPIS")		//13 Aliquota do PIS
	aImp[14] := MaFisRet(1,"IT_VALPIS")			//14 Valor do PIS
	aImp[15] := "COF"							//15 COFINS
	aImp[16] := MaFisRet(1,"IT_BASECOF")		//16 Base do COFINS
	aImp[17] := MaFisRet(1,"IT_ALIQCOF")		//17 Aliquota COFINS
	aImp[18] := MaFisRet(1,"IT_VALCOF")			//18 Valor do COFINS
	aImp[19] := "ISS"							//19 ISS
	aImp[20] := MaFisRet(1,"IT_BASEISS")		//20 Base do ISS
	aImp[21] := MaFisRet(1,"IT_ALIQISS")		//21 Aliquota ISS
	aImp[22] := MaFisRet(1,"IT_VALISS")			//22 Valor do ISS
	aImp[23] := "IRR"							//23 IRRF
	aImp[24] := MaFisRet(1,"IT_BASEIRR")		//24 Base do IRRF
	aImp[25] := MaFisRet(1,"IT_ALIQIRR")		//25 Aliquota IRRF
	aImp[26] := MaFisRet(1,"IT_VALIRR")			//26 Valor do IRRF
	aImp[27] := "INS"							//27 INSS
	aImp[28] := MaFisRet(1,"IT_BASEINS")		//28 Base do INSS
	aImp[29] := MaFisRet(1,"IT_ALIQINS")		//29 Aliquota INSS
	aImp[30] := MaFisRet(1,"IT_VALINS")			//30 Valor do INSS
	aImp[31] := "CSL"							//31 CSLL
	aImp[32] := MaFisRet(1,"IT_BASECSL")		//32 Base do CSLL
	aImp[33] := MaFisRet(1,"IT_ALIQCSL")		//33 Aliquota CSLL
	aImp[34] := MaFisRet(1,"IT_VALCSL")			//34 Valor do CSLL
	aImp[35] := "PS2"							//35 PIS/Pasep - Via Apuração
	aImp[36] := MaFisRet(1,"IT_BASEPS2")		//36 Base do PS2 (PIS/Pasep - Via Apuração)
	aImp[37] := MaFisRet(1,"IT_ALIQPS2")		//37 Aliquota PS2 (PIS/Pasep - Via Apuração)
	aImp[38] := MaFisRet(1,"IT_VALPS2")			//38 Valor do PS2 (PIS/Pasep - Via Apuração)
	aImp[39] := "CF2"							//39 COFINS - Via Apuração
	aImp[40] := MaFisRet(1,"IT_BASECF2")		//40 Base do CF2 (COFINS - Via Apuração)
	aImp[41] := MaFisRet(1,"IT_ALIQCF2")		//41 Aliquota CF2 (COFINS - Via Apuração)
	aImp[42] := MaFisRet(1,"IT_VALCF2")			//42 Valor do CF2 (COFINS - Via Apuração)
	aImp[43] := "ICC"							//43 ICMS Complementar
	aImp[44] := MaFisRet(1,"IT_ALIQCMP")		//44 Base do ICMS Complementar
	aImp[45] := MaFisRet(1,"IT_ALIQCMP")		//45 Aliquota do ICMS Complementar
	aImp[46] := MaFisRet(1,"IT_VALCMP")			//46 Valor do do ICMS Complementar
	aImp[47] := "ICA"							//47 ICMS ref. Frete Autonomo
	aImp[48] := MaFisRet(1,"IT_BASEICA")		//48 Base do ICMS ref. Frete Autonomo
	aImp[49] := 0								//49 Aliquota do ICMS ref. Frete Autonomo
	aImp[50] := MaFisRet(1,"IT_VALICA")			//50 Valor do ICMS ref. Frete Autonomo
	aImp[51] := "TST"							//51 ICMS ref. Frete Autonomo ST
	aImp[52] := MaFisRet(1,"IT_BASETST")		//52 Base do ICMS ref. Frete Autonomo ST
	aImp[53] := MaFisRet(1,"IT_ALIQTST")		//53 Aliquota do ICMS ref. Frete Autonomo ST
	aImp[54] := MaFisRet(1,"IT_VALTST")			//54 Valor do ICMS ref. Frete Autonomo ST
	aImp[55] := MaFisRet(1,"IT_BASESOL")		//55 Base do ICMS ST
	aImp[56] := MaFisRet(1,"IT_ALIQSOL")		//56 Aliquota do ICMS ST
	aImp[57] := MaFisRet(1,"IT_VALSOL")			//57 Valor do ICMS ST
	aImp[58] := MaFisRet(1,"IT_DESCONTO")		//58 Valor do Desconto
	aImp[59] := MaFisRet(1,"IT_FRETE")			//59 Valor do Frete
	aImp[60] := MaFisRet(1,"IT_SEGURO")			//60 Valor do Seguro
	aImp[61] := MaFisRet(1,"IT_DESPESA")		//61 Valor das Despesas
	aImp[62] := MaFisRet(1,"IT_VALMERC")		//62 Valor da Mercadoria
/*	aImp[10] := MaFisRet(1,"IT_DESCZF")		//Valor de Desconto da Zona Franca de Manaus
	aImp[14] := MaFisRet(1,"IT_BASESOL")	//Base do ICMS Solidario
	aImp[15] := MaFisRet(1,"IT_ALIQSOL")	//Aliquota do ICMS Solidario
	aImp[16] := MaFisRet(1,"IT_MARGEM")		//Margem de lucro para calculo da Base do ICMS Sol.*/
	
//	MaFisSave()
	MaFisEnd()
return aImp
/*
// -------------------------------------------------------------------
// Campos utilizados para retorno dos impostos calculado
// -------------------------------------------------------------------
IT_GRPTRIB				//Grupo de Tributacao
IT_EXCECAO				//Array da EXCECAO Fiscal
IT_ALIQICM				//Aliquota de ICMS
IT_ICMS					//Array contendo os valores de ICMS
IT_BASEICM				//Valor da Base de ICMS
IT_VALICM				//Valor do ICMS Normal
IT_BASESOL				//Base do ICMS Solidario
IT_ALIQSOL				//Aliquota do ICMS Solidario
IT_VALSOL				//Valor do ICMS Solidario
IT_MARGEM				//Margem de lucro para calculo da Base do ICMS Sol.
IT_BICMORI				//Valor original da Base de ICMS
IT_ALIQCMP				//Aliquota para calculo do ICMS Complementar
IT_VALCMP				//Valor do ICMS Complementar do item
IT_BASEICA				//Base do ICMS sobre o frete autonomo
IT_VALICA				//Valor do ICMS sobre o frete autonomo
IT_DEDICM				//Valor do ICMS a ser deduzido
IT_VLCSOL				//Valor do ICMS Solidario calculado sem o credito aplicado
IT_PAUTIC				//Valor da Pauta do ICMS Proprio
IT_PAUTST				//Valor da Pauta do ICMS-ST
IT_PREDIC				//%Redução da Base do ICMS
IT_PREDST				//%Redução da Base do ICMS-ST
IT_MVACMP				//Margem do complementar
IT_PREDCMP				//%Redução da Base do ICMS-CMP
IT_ALIQIPI				//Aliquota de IPI
IT_IPI					//Array contendo os valores de IPI
IT_BASEIPI				//Valor da Base do IPI
IT_VALIPI				//Valor do IPI
IT_BIPIORI				//Valor da Base Original do IPI
IT_PREDIPI				//%Redução da Base do IPI
IT_PAUTIPI				//Valor da Pauta do IPI
IT_NFORI				//Numero da NF Original
IT_SERORI				//Serie da NF Original
IT_RECORI				//RecNo da NF Original (SD1/SD2)
IT_DESCONTO				//Valor do Desconto
IT_FRETE				//Valor do Frete
IT_DESPESA				//Valor das Despesas Acessorias
IT_SEGURO				//Valor do Seguro
IT_AUTONOMO				//Valor do Frete Autonomo
IT_VALMERC				//Valor da mercadoria
IT_PRODUTO				//Codigo do Produto
IT_TES					//Codigo da TES
IT_TOTAL				//Valor Total do Item
IT_CF					//Codigo Fiscal de Operacao
IT_FUNRURAL				//Aliquota para calculo do Funrural
IT_PERFUN				//Valor do Funrural do item
IT_DELETED				//Flag de controle para itens deletados
IT_LIVRO				//Array contendo o Demonstrativo Fiscal do Item
IT_ISS					//Array contendo os valores de ISS
IT_ALIQISS				//Aliquota de ISS do item
IT_BASEISS				//Base de Calculo do ISS
IT_VALISS				//Valor do ISS do item
IT_CODISS				//Codigo do ISS
IT_CALCISS				//Flag de controle para calculo do ISS
IT_RATEIOISS			//Flag de controle para calculo do ISS
IT_CFPS					//Codigo Fiscal de Prestacao de Servico
IT_PREDISS				//Redução da base de calculo do ISS
IT_VALISORI				//Valor do ISS do item sem aplicar o arredondamento
IT_IR					//Array contendo os valores do Imposto de renda
IT_BASEIRR				//Base do Imposto de Renda do item
IT_REDIR				//Percentual de Reducao da Base de calculo do IR
IT_ALIQIRR				//Aliquota de Calculo do IR do Item
IT_VALIRR				//Valor do IR do Item
IT_INSS					//Array contendo os valores de INSS
IT_BASEINS				//Base de calculo do INSS
IT_REDINSS				//Percentual de Reducao da Base de Calculo do INSS
IT_ALIQINS				//Aliquota de Calculo do INSS
IT_VALINS				//Valor do INSS
IT_ACINSS				//Acumulo INSS
IT_VALEMB				//Valor da embalagem
IT_BASEIMP				//Array contendo as Bases de Impostos Variaveis
IT_BASEIV1				//Base de Impostos Variaveis 1
IT_BASEIV2				//Base de Impostos Variaveis 2
IT_BASEIV3				//Base de Impostos Variaveis 3
IT_BASEIV4				//Base de Impostos Variaveis 4
IT_BASEIV5				//Base de Impostos Variaveis 5
IT_BASEIV6				//Base de Impostos Variaveis 6
IT_BASEIV7				//Base de Impostos Variaveis 7
IT_BASEIV8				//Base de Impostos Variaveis 8
IT_BASEIV9				//Base de Impostos Variaveis 9
IT_ALIQIMP				//Array contendo as Aliquotas de Impostos Variaveis
IT_ALIQIV1				//Aliquota de Impostos Variaveis 1
IT_ALIQIV2				//Aliquota de Impostos Variaveis 2
IT_ALIQIV3				//Aliquota de Impostos Variaveis 3
IT_ALIQIV4				//Aliquota de Impostos Variaveis 4
IT_ALIQIV5				//Aliquota de Impostos Variaveis 5
IT_ALIQIV6				//Aliquota de Impostos Variaveis 6
IT_ALIQIV7				//Aliquota de Impostos Variaveis 7
IT_ALIQIV8				//Aliquota de Impostos Variaveis 8
IT_ALIQIV9				//Aliquota de Impostos Variaveis 9
IT_VALIMP				//Array contendo os valores de Impostos Agentina/Chile/Etc.
IT_VALIV1				//Valor do Imposto Variavel 1
IT_VALIV2				//Valor do Imposto Variavel 2
IT_VALIV3				//Valor do Imposto Variavel 3
IT_VALIV4				//Valor do Imposto Variavel 4
IT_VALIV5				//Valor do Imposto Variavel 5
IT_VALIV6				//Valor do Imposto Variavel 6
IT_VALIV7				//Valor do Imposto Variavel 7
IT_VALIV8				//Valor do Imposto Variavel 8
IT_VALIV9				//Valor do Imposto Variavel 9
IT_BASEDUP				//Base das duplicatas geradas no financeiro
IT_DESCZF				//Valor do desconto da Zona Franca do item
IT_DESCIV				//Array contendo a descricao dos Impostos Variaveis
IT_DESCIV1				//Array contendo a Descricao dos IV 1
IT_DESCIV2				//Array contendo a Descricao dos IV 2
IT_DESCIV3				//Array contendo a Descricao dos IV 3
IT_DESCIV4				//Array contendo a Descricao dos IV 4
IT_DESCIV5				//Array contendo a Descricao dos IV 5
IT_DESCIV6				//Array contendo a Descricao dos IV 6
IT_DESCIV7				//Array contendo a Descricao dos IV 7
IT_DESCIV8				//Array contendo a Descricao dos IV 8
IT_DESCIV9				//Array contendo a Descricao dos IV 9
IT_QUANT				//Quantidade do Item
IT_PRCUNI				//Preco Unitario do Item
IT_VIPIBICM				//Valor do IPI Incidente na Base de ICMS
IT_PESO					//Peso da mercadoria do item
IT_ICMFRETE				//Valor do ICMS Relativo ao Frete
IT_BSFRETE				//Base do ICMS Relativo ao Frete
IT_BASECOF				//Base de calculo do COFINS
IT_ALIQCOF				//Aliquota de calculo do COFINS
IT_VALCOF				//Valor do COFINS
IT_BASECSL				//Base de calculo do CSLL
IT_ALIQCSL				//Aliquota de calculo do CSLL
IT_VALCSL				//Valor do CSLL
IT_BASEPIS				//Base de calculo do PIS
IT_ALIQPIS				//Aliquota de calculo do PIS
IT_VALPIS				//Valor do PIS
IT_RECNOSB1				//RecNo do SB1
IT_RECNOSF4				//RecNo do SF4
IT_VNAGREG				//Valor da Mercadoria nao agregada.
IT_TIPONF				//Tipo da nota fiscal
IT_REMITO				//Remito
IT_BASEPS2				//Base de calculo do PIS 2
IT_ALIQPS2				//Aliquota de calculo do PIS 2
IT_VALPS2				//Valor do PIS 2
IT_BASECF2				//Base de calculo do COFINS 2
IT_ALIQCF2				//Aliquota de calculo do COFINS 2
IT_VALCF2				//Valor do COFINS 2
IT_ABVLINSS				//Abatimento da base do INSS em valor 
IT_ABVLISS				//Abatimento da base do ISS em valor 
IT_REDISS				//Percentual de reducao de base do ISS ( opcional, utilizar normalmente TS_BASEISS ) 
IT_ICMSDIF				//Valor do ICMS diferido
IT_DESCZFPIS			//Desconto do PIS
IT_DESCZFCOF			//Desconto do Cofins
IT_BASEAFRMM			//Base de calculo do AFRMM ( Item )
IT_ALIQAFRMM			//Aliquota de calculo do AFRMM ( Item )
IT_VALAFRMM				//Valor do AFRMM ( Item )
IT_PIS252				//Decreto 252 de 15/06/2005 - PIS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
IT_COF252				//Decreto 252 de 15/06/2005 - COFINS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
IT_CRDZFM				//Credito Presumido - Zona Franca de Manaus
IT_CNAE					//Codigo da Atividade Economica da Prestacao de Servicos
IT_ITEM					//Numero Item
IT_SEST					//Array contendo os valores do SEST
IT_BASESES				//Base de calculo do SEST
IT_ALIQSES				//Aliquota de calculo do SEST
IT_VALSES				//Valor do INSS
IT_BASEPS3				//Base de calculo do PIS Subst. Tributaria
IT_ALIQPS3				//Aliquota de calculo do PIS Subst. Tributaria
IT_VALPS3				//Valor do PIS Subst. Tributaria
IT_BASECF3				//Base de calculo da COFINS Subst. Tributaria
IT_ALIQCF3				//Aliquota de calculo da COFINS Subst. Tributaria
IT_VALCF3				//Valor da COFINS Subst. Tributaria
IT_VLR_FRT				//Valor do Frete de Pauta
IT_BASEFET				//Base do Fethab   
IT_ALIQFET				//Aliquota do Fethab
IT_VALFET				//Valor do Fethab   
IT_ABSCINS				//Abatimento do Valor do INSS em Valor - SubContratada
IT_SPED					//SPED
IT_ABMATISS				//Abatimento da base do ISS em valor referente a material utilizado 
IT_RGESPST				//Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
IT_PRFDSUL				//Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
IT_UFERMS				//Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
IT_VALFDS				//Valor do Fundersul - Mato Grosso do Sul
IT_ESTCRED				//Valor do Estorno de Credito/Debito
IT_CODIF				//Codigo de autorizacao CODIF - Combustiveis
IT_BASETST				//Base do ICMS de transporte Substituicao Tributaria
IT_ALIQTST				//Aliquota do ICMS de transporte Substituicao Tributaria
IT_VALTST				//Valor do ICMS de transporte Substituicao Tributaria
IT_CRPRSIM				//Valor Crédito Presumido Simples Nacional - SC, nas aquisições de fornecedores que se enquadram no simples
IT_VALANTI				//Valor Antecipacao ICMS                       
IT_DESNTRB				//Despesas Acessorias nao tributadas - Portugal
IT_TARA					//Tara - despesas com embalagem do transporte - Portugal
IT_PROVENT				//Provincia de entrega
IT_VALFECP				//Valor do FECP
IT_VFECPST				//Valor do FECP ST
IT_ALIQFECP				//Aliquota FECP
IT_CRPRESC				//Credito Presumido SC 
IT_DESCPRO				//Valor do desconto total proporcionalizado
IT_ANFORI2				//IVA Ajustado
IT_UFORI				//UF Original da Nota de Entrada para o calculo do IVA Ajustado( Opcional )
IT_ALQORI				//Aliquota Original da Nota de Entrada para o calculo do IVA Ajustado ( Opcional )
IT_PROPOR				//Quantidade proporcional na venda para o calculo do IVA Ajustado( Opcional )
IT_ALQPROR				//Aliquota proporcional na venda para o calculo do IVA Ajustado( Opcional )
IT_ANFII				//Array contendo os valores do Imposto de Importação
IT_ALIQII				//Aliquota do Imposto de Importação
IT_VALII				//Valor do Imposto de Importação (Digitado direto na Nota Fiscal)
IT_PAUTPIS				//Valor da Pauta do PIS
IT_PAUTCOF				//Valor da Pauta do Cofins
IT_ALIQDIF				//Aliquota interna do estado para calculo do Diferencial de aliquota do Simples Nacional
IT_CLASFIS				//Valor do Imposto de Importação (Digitado direto na Nota Fiscal)
IT_VLRISC				//Valor do imposto ISC (Localizado Peru) por unidade  "PER"
IT_CRPREPE				//Credito Presumido - Art. 6 Decreto  n28.247
IT_CRPREMG				//Credito Presumido MG 
IT_SLDDEP				//Valor de desconto de depedendente fornecedor
*/

/*/
===============================================================================================================================
Programa----------: UVlOrc
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 03/08/2023
===============================================================================================================================
Descrição---------: Este programa serve para totalizar o valor do orcamento no cabecalho
===============================================================================================================================
Uso---------------: ORCAMENTO (faturamento)
===============================================================================================================================
Parametros--------: cNumPed = numero do pedido de venda a 
					cTipo = 'P' Pedido de venda ou 'O' Orcamento
===============================================================================================================================
Retorno-----------: valor total do pedido
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function UVlOrc(pNum,pTipo)

	local	cCliente	:= '',;	//-> Codigo Cliente/Fornecedor
			cLoja		:= '',;	//-> Loja do Cliente/Fornecedor
			cTipo		:= '',;	//-> Tipo do Cliente/Fornecedor
			cPessoa		:= '',;	//-> Pessoa
			cProduto	:= '',;	//-> Codigo do Produto
			cTes		:= '',;	//-> TES
			nQtd		:= 0,;	//-> quantidade 
			nPrc		:= 0,;	//-> Preco de Venda
			nValor		:= 0,;	//-> Valor da Mercadoria
			nFrete		:= 0,;	//-> Valor do Frete
			nDespesa	:= 0,;	//-> Valor do Despesa
			nSeguro		:= 0,;	//-> Valor do Seguro
			nQtdItem	:= 0,;	//-> Qtd de item
			aImposto	:= {},;	//-> Impostos Calculados
			cCondPagto	:= '',;	//-> Cod. Cond. Pagto
			nAcresFin	:= 0,;	//-> Acrescimo Financeiro
			nVlTotal	:= 0.00	//-> valor total para o retorno
			
	local	cQuery		:= ''

	default pTipo:= 'O'

	cQuery:= 'exec PR_ORCFAT @FILIAL = "'+xFilial('SCK')+'", @NUM = "'+pNum+'", @TIPO = "'+pTipo+'"'
	if select('TRB1') <> 0
		dbSelectArea('TRB1')
		TRB1->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS 'TRB1'
	
	dbSelectArea('TRB1')
	TRB1->(dbGoTop())
	while !TRB1->(eof())
		nQtdItem++
		TRB1->(dbSkip())
	enddo
	
	TRB1->(dbGoTop())
		cCliente	:= TRB1->CODCLI
		cLoja		:= TRB1->LOJA
		nFrete		:= TRB1->FRETE
		nDespesa	:= TRB1->DESPESA
		nSeguro		:= TRB1->SEGURO
		nArrend		:= TRB1->ARREND
		cCondPagto	:= TRB1->CONDPAG
		cTipo		:= TRB1->TIPO
		cPessoa		:= TRB1->PESSOA
		nAcresFin	:= TRB1->JRS

	TRB1->(dbGoTop())
	while !TRB1->(eof())
		cProduto	:= TRB1->PROD
		cTes		:= TRB1->TES
		nQtd		:= TRB1->QTD 
		nPrc		:= TRB1->VLRUNITBRUTO
		nValor		:= TRB1->VLRTOT

		aImposto	:= U_FIMPOSTOS(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor,nQtdItem,nFrete,nDespesa,nSeguro)

		nVlTotal	+= aImposto[62];	//val merc
						+aImposto[57] 	//ICMSOLID
						
		TRB1->(dbSkip())
	enddo
	TRB1->(dbCloseArea())

	if !empty(aImposto)
		nVlTotal	+= aImposto[59]
	endif
	
	nVlTotal	-= nArrend
	nVlTotal	+= noround(nVlTotal*nAcresFin,2)

return nVlTotal

/*/
===============================================================================================================================
Programa----------: xVlNota
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 11/12/2023
===============================================================================================================================
Descrição---------: Este programa serve para totalizar o valor do doc. de saida no cabecalho
===============================================================================================================================
Uso---------------: Notas Fiscal (faturamento)
===============================================================================================================================
Parametros--------: cSerie = Serie da Nota
					cNumNota = numero do doc de saida
===============================================================================================================================
Retorno-----------: valor total do doc de saida
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function xVlNota(pSerie,pNumNota)

	local	nVlTotal	:= 0.00	//-> valor total para o retorno
			
	local	cQuery		:= ''

	cQuery:= 'exec PR_VLDOCSAIDA @FILIAL = "'+xFilial('SE1')+'", @SERIE = "'+pSerie+'", @NUMNOTA = "'+pNumnota+'"'
	if select('TRB1') <> 0
		dbSelectArea('TRB1')
		TRB1->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS 'TRB1'
	
	dbSelectArea('TRB1')
	TRB1->(dbGoTop())
	if !TRB1->(eof())
		nVlTotal	:= TRB1->VALOR
	endif
	
	if select('TRB1') <> 0
		dbSelectArea('TRB1')
		TRB1->(dbCloseArea())
	endif

return nVlTotal

/*/
===============================================================================================================================
Programa----------: UVlTotalADA
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 10/04/2019
===============================================================================================================================
Descrição---------: Este programa serve para totalizar OS CONTRATOS
===============================================================================================================================
Uso---------------: CONTATOS (faturamento)
===============================================================================================================================
Parametros--------: cNum = numero do CONTRATO DE VENDA
===============================================================================================================================
Retorno-----------: valor total do CONTRATO
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function VlTotalADA(cNum)

    Local aArea     := GetArea()
    Local aAreaADA	:= ADA->(GetArea())
    Local cQryIte   := ''
    Local nValNota	:= 0
    
    default cNum	:= ADA->ADA_NUMCTR
    
    cQryIte := " select [ADB_TOTAL] = sum(ADB_TOTAL) from "+RetSQLName('ADB')+" as ADB where D_E_L_E_T_ = '' and ADB_FILIAL = '"+FWxFilial('ADB')+"' and ADB_NUMCTR = '"+cNum+"' "
    cQryIte := ChangeQuery(cQryIte)
    TCQuery cQryIte New Alias "QRY_ITE"
         
    QRY_ITE->(DbGoTop())
    While ! QRY_ITE->(EoF())
	   nValNota	+= QRY_ITE->ADB_TOTAL
       QRY_ITE->(DbSkip())
    EndDo
    QRY_ITE->(DbCloseArea())
    
    RestArea(aAreaADA)
    RestArea(aArea)
    

return nValNota

/*/
===============================================================================================================================
Programa----------: DTENTREGA
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 13/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para totalizar dos orcamentos de vendas no cabecalho
===============================================================================================================================
Uso---------------: No orcamento (faturamento)
===============================================================================================================================
Parametros--------: cNumPed = numero do pedido de venda a totalizar
===============================================================================================================================
Retorno-----------: valor total do orcamento
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function DTENTREGA(cSerie,cNota)

    Local aArea     := GetArea()
//    Local aAreaSCJ	:= SF2->(GetArea())
    Local cQryIte   := ''
    Local dDtEntreg	:= 0

    Default cSerie	:= SF2->F2_SERIE
    default cNota	:= SF2->F2_DOC
    
    cQryIte := " select [C6_ENTREG] = max(C6_ENTREG) from "+RetSQLName('SC6')+" as SC6 where D_E_L_E_T_ = '' and SC6.C6_FILIAL = '"+FWxFilial('SC6')+"' and SC6.C6_SERIE = '"+cSerie+"' and SC6.C6_NOTA = '"+cNota+"' "
    cQryIte := ChangeQuery(cQryIte)
    TCQuery cQryIte New Alias "QRY_ITE"
         
    QRY_ITE->(DbGoTop())
    if ! QRY_ITE->(EoF())
	   dDtEntreg	:= QRY_ITE->C6_ENTREG 
       QRY_ITE->(DbSkip())
    endif
    QRY_ITE->(DbCloseArea())
   
 //   RestArea(aAreaSCJ)
    RestArea(aArea)

return dDtEntreg

/*/
===============================================================================================================================
Programa----------: EFLUIG
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 13/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para totalizar dos orcamentos de vendas no cabecalho
===============================================================================================================================
Uso---------------: No orcamento (faturamento)
===============================================================================================================================
Parametros--------: cNumPed = numero do pedido de venda a totalizar
===============================================================================================================================
Retorno-----------: valor total do orcamento
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function EFLUIG(cNumPed)

    Local aArea     := GetArea()
    Local cQryIte   := ''
    Local cRet		:= ''

    default cNumped	:= SC5->C5_NUM
    
    cQryIte := " select CJ_XFLUIG from "+RetSQLName('SC5')+" as SC5 inner join "+RetSQLName('SCJ')+" as SCJ on SCJ.D_E_L_E_T_ = '' and SCJ.CJ_FILIAL = '"+FWxFilial('SCJ')+"' and SCJ.CJ_NUM = SC5.C5_XNUMORC where SC5.D_E_L_E_T_ = '' and SC5.C5_FILIAL = '"+FWxFilial('SC5')+"' and SC5.C5_NUM = '"+cNumPed+"' "
    cQryIte := ChangeQuery(cQryIte)
    TCQuery cQryIte New Alias "QRY_ITE"
         
    QRY_ITE->(DbGoTop())
    if ! QRY_ITE->(EoF())
	   cRet	:= QRY_ITE->CJ_XFLUIG 
    endif
    QRY_ITE->(DbCloseArea())
   
    RestArea(aArea)

return cRet

/*/
===============================================================================================================================
Programa----------: UChvNFE
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve retorna a chave nfe da nota
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: cNota	= numero da nota fiscal
					cSerie	= serie da nota fiscal
===============================================================================================================================
Retorno-----------: cChvNfe	= chave da nota fiscal
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
User Function UChvNFE(cNota, cSerie)
//	Local aArea     := GetArea()
//    Local aAreaC5   := SC5->(GetArea())
//    Local aAreaF2   := SF2->(GetArea())
    Local cQry		:= ""
    Local cChvNfe	:= ""

    Default cNota	:= SC5->C5_NOTA
    Default cSerie	:= SC5->C5_SERIE
     
    cQry := " SELECT DOC_CHV "
    cQry += " FROM "
    cQry += "    TSS_FIS..SPED050 "
    cQry += " WHERE "
    cQry += "    	NFE_ID 	= '"+cSerie+cNota+"' "
    cQry += "    AND STATUS = '6' "
    cQry += "    AND D_E_L_E_T_	 	= ' ' "
    cQry := ChangeQuery(cQry)
    TCQuery cQry New Alias "TB01"
         
    TB01->(DbGoTop())
    if ! TB01->(EoF()) .and. TB01->DOC_CHV != ""
    	cChvNfe	:= TB01->DOC_CHV
    endif
    TB01->(dbCloseArea())
   
//    RestArea(aAreaF2)
//    RestArea(aAreaC5)
//    RestArea(aArea)
Return cChvNfe



/*/
===============================================================================================================================
Programa----------: TemCHV
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve retorna a chave nfe da nota
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: cNota	= numero da nota fiscal
					cSerie	= serie da nota fiscal
===============================================================================================================================
Retorno-----------: cChvNfe	= chave da nota fiscal
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
User Function TemCHV(cNota, cSerie)
//	Local aArea     := GetArea()
//    Local aAreaC5   := SC5->(GetArea())
//    Local aAreaF2   := SF2->(GetArea())
    Local cQry		:= ""
    Local lRet	:= .F.

    Default cNota	:= SC5->C5_NOTA
    Default cSerie	:= SC5->C5_SERIE
     
    cQry := " SELECT DOC_CHV "
    cQry += " FROM "
    cQry += "    TSS_FIS..SPED050 "
    cQry += " WHERE "
    cQry += "    	NFE_ID 	= '"+cSerie+cNota+"' "
    cQry += "    AND STATUS = '6' "
    cQry += "    AND D_E_L_E_T_	 	= ' ' "
    cQry := ChangeQuery(cQry)
    TCQuery cQry New Alias "TB01"
         
    TB01->(DbGoTop())
    if empty(TB01->DOC_CHV)
    	lRet	:= .T.
    endif
    TB01->(dbCloseArea())
   
//    RestArea(aAreaF2)
//    RestArea(aAreaC5)
//    RestArea(aArea)
Return lRet

/*/
===============================================================================================================================
Programa----------: UEstoque
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para totalizar o estoque de um determinado local
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: cProduto	= o produto a consultar
					cLocal		= local do estoque a consultar
===============================================================================================================================
Retorno-----------: nSaldo		= saldo do produto no local pesquisado
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user Function UEstoque(cProduto, cLocal, cOrig, cUnid)
    local	aArea		as string,;
			aAreaSB2	as string,;
			nSld		as numeric,;
			cTipConv	as string,;
			nConv		as numeric

	default cOrig	:= ''
	default cLocal	:= '01'
	default cUnid	:= 1

	if cOrig=='O'
		if empty(cProduto)
			cProduto	:= SCJ->CJ_PRODUTO
			cLocal		:= SCJ->CJ_LOCAL
		endif
		if empty(cLocal)
			cLocal	:= SCJ->CJ_LOCAL
		endif
		
	elseif cOrig=='P'
		if empty(cProduto)
			cProduto	:= SC6->C6_PRODUTO
			cLocal		:= SC6->C6_LOCAL
		endif
		if empty(cLocal)
			cLocal	:= SC6->C6_LOCAL
		endif
	endif

	aArea	:= getArea()
	AAreaSB2:= SB2->(getArea())
	nSld	:= 0

	if alltrim(cProduto) != ''
		dbSelectArea('SB2')
		SB2->(dbSetOrder(1))
		SB2->(dbGoTop())
		if (SB2->(DbSeek(FWxFilial('SB2')+cProduto+cLocal)))
			nSld:= SaldoSB2()
		endif
	else
		nSld:= 0
	endif

	if cUnid = 2
		cTipConv	:= posicione('SB1',1,FWxFilial('SB1')+cProduto,'B1_TIPCONV')
		nConv		:= posicione('SB1',1,FWxFilial('SB1')+cProduto,'B1_CONV')
		nSld		:= iif(cTipConv = 'M', nSld * nConv, nSld / nConv)
	endif

	restArea(aAreaSB2)
	restArea(aArea)

return nSld

/*/
===============================================================================================================================
Programa----------: UEEstrutura
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para verificar se existe ou nao estrutura para o produto
===============================================================================================================================
Uso---------------: Na abertura de novas OP's
===============================================================================================================================
Parametros--------: _pProduto	= produto a ser verificado
===============================================================================================================================
Retorno-----------: _lRet	= Falso/Verdadeiro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function UEEstrutura(_pProduto)

	local _lRet		:= .f.
	local _Query	:= ""
	
	_Query:="	select 1 from "+RetSqlName("SG1")+" where D_E_L_E_T_ = '' and G1_FILIAL = '"+xFilial("SG1")+"' and G1_COD = '"+_pProduto+"'	"
	
	_Query:= ChangeQuery(_Query)
	
	If select("TB1") > 1
		TB1->(dbCloseArea())
	EndIf
	
	TCQuery _Query New Alias "TB1"
	
	If !TB1->(EOF())
		_lRet:= .t.
	EndIf
	
	If !_lRet
		Alert("Produto sem estrutura!!!... Revisar cadastro.")
	EndIf

Return _lRet

/*/
===============================================================================================================================
Programa----------: UValDescont
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 21/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para validar o valor da indenizacao
===============================================================================================================================
Uso---------------: MATA410
===============================================================================================================================
Parametros--------: _lRet	=> Libera ou nao o desconto
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGFAT
===============================================================================================================================
/*/
user function UValDescont(_vDesc)

	Local _lRet := .T.

	if 1 < _vDesc
		Alert("Arredondamento acima do permitido!!!!...")
		_lRet	:= .F.
	EndIf

return _lRet

/*/
===============================================================================================================================
Programa----------: URegiao
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 24/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para regionalizar os clientes de acordo com suas cidade
===============================================================================================================================
Uso---------------: MATA030
===============================================================================================================================
Parametros--------: _pCodMun - codigo do municipio a sere considerado
===============================================================================================================================
Retorno-----------: _cRet	=> Libera ou nao o desconto
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGFAT
===============================================================================================================================
/*/

user function URegiao(_pCodMun)

	local _cRet	:= "01"

	_cRet:= posicione('Z02',1,fwXFilial('Z02')+_pCodMun,'Z02_REGIAO')

return _cRet


/*/
===============================================================================================================================
Programa----------: PROXCODB1
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 17/09/2018
===============================================================================================================================
Descrição---------: Este programa serve para retornar o proximo codigo do produto
===============================================================================================================================
Uso---------------: RDMAKE
===============================================================================================================================
Parametros--------: sem parametros
===============================================================================================================================
Retorno-----------: _cCodPro = proximo codigo do produto disponivel
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: GERAL
===============================================================================================================================
/*/
user function UPROXCODB1()

	Local _cCodPro := ""
	Local _cArea := GetArea()
	Local _cQuery := ""
	
	_cQuery := " SELECT MAX(B1_COD) AS CODIGO "
	_cQuery += " FROM " + RetSqlName("SB1")
	_cQuery += " WHERE B1_GRUPO = '" + M->B1_GRUPO + "'" 
	_cQuery += " AND   D_E_L_E_T_ = ' '"
	
	TcQuery _cQuery New Alias "TRB"
	dbSelectArea("TRB")
	dbGoTop()
	If !TRB->(EOF())
		_cCodPro :=  M->B1_GRUPO + Strzero(Val(Right(Alltrim(TRB->CODIGO),3))+1,3)
	Else 
		_cCodPro :=  M->B1_GRUPO + "001"
	Endif
	
	dbSelectArea("TRB")
	TRB->(dbCloseArea())
	
	While !MayIUseCode("B1_COD"+xFilial("SB1")+_cCodPro)
		_cCodPro := Soma1(_cCodPro)
	EndDo             
	
	RestArea(_cArea)

return(_cCodPro)


/*/
===============================================================================================================================
Programa----------: EnvMail
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 27/09/2018
===============================================================================================================================
Descrição---------: Este programa serve para enviar email
===============================================================================================================================
Uso---------------: geral
===============================================================================================================================
Parametros--------: cNumPed = numero do pedido de venda a totalizar
					nTipo = 1 - Browser do Pedido de Venda ou 2 - Detalhe do Pedido de venda
===============================================================================================================================
Retorno-----------: valor total do pedido
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function EnvMail(cMailDe,cMailPara,cMailCopia,cMailCopiaOculta,cAssunto,cCorpo,cAnexo,_lReturn)

	local cServer 			:= getMV('MV_RELSERV') //endereço SMTP
	//local lAutentic 		:= getMV('MV_RELAUTH') //utilize em caso de necessidade de autenticação
	local cAccount 			:= getmv('MV_RELACNT') //conta
	local cPassword 		:= getMV('MV_RELAPSW') //senha
	LOcal cQL 				:= CHR(13) + CHR(10)
	local cRemoteip 		:= Getclientip()
	local cRemoteComputer 	:= GetComputerName()
	local lConectou 		:= .f.
	local lRet				:= .F.
	local sMensagem			:= ' '
	
	if Empty(cMailDe)
		cMailDe	:= cAccount
	endif
	
	if empty(cMailPara)
		cMailPara	:= usrRetMail(retCodUsr())
	endif
	
	// conecta com o servidor de e-mail
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou
	
	lRet	:= mailAuth(cAccount, cPassword)
	
	If lConectou .and. lRet

		cCorpo += cQL + cQL + '==========================================================='
		cCorpo += cQL + ' Enviado por: ' + cUsername
		cCorpo += cQL + ' Computador: ' + cRemoteComputer
		cCorpo += cQL + ' IP: ' + cRemoteip
		cCorpo += cQL + '==========================================================='
		
//		SendMail( < cFrom >, < cTo >, [ cSubject ], [ cBody ], [ cCC ], [ cBCC ], [ aAttach ], [ nNumAttach ], [ nPriority ] )
		SEND MAIL FROM cMailDe TO cMailPara CC cMailCopia BCC cMailCopiaOculta SUBJECT cAssunto BODY cCorpo ATTACHMENT cAnexo RESULT lEnviado
//		SEND MAIL FROM cMailDe TO cMailPara CC cMailCopia BCC cMailCopiaOculta SUBJECT cAssunto BODY cCorpo FORMAT TEXT RESULT lEnviado
		if !lEnviado
			get mail error sMensagem
//			u_msgErro('ALERTA: Não foi possivel enviar a mensagem!!!'+ CRLF + sMensagem,'[RD000000]') //, pois ocorreu o seguinte erro: ” + sMensagem + “.”)
//		else
//			alert('E-mail transmitido com sucesso para ' + cMailPara +'!')
		endif
	else
//			u_msgErro('Não foi possivel executar sua solicitação, pois não houve resposta do servidor de e-mail.'+cQL+cQL+'Informe ao Administrador do Sistema!','[RD000000]')
		return .f.
	endif
	
	DISCONNECT SMTP SERVER Result lDisConectou

return lEnviado


/*/
===============================================================================================================================
Programa----------: msgPergunta
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 27/11/2018
===============================================================================================================================
Descrição---------: Este programa serve para PERGUNTAR ao usuario
===============================================================================================================================
Uso---------------: geral
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: lRet -> .T. ou .F.
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Geral
===============================================================================================================================
/*/
user function msgPergunta(pPergunta, pForm)

/*
IDOK                  1
IDCANCEL              2
IDYES                 6
IDNO                  7
*/
	local lRet	:= .F.
	
	lRet	:= messageBox(pPergunta,pForm,4)

return lRet

user function msgInforma(pMsg, pForm)

	local lRet	:= .F.
	
	lRet	:= messageBox(pMsg,pForm,32)

return lRet


user function msgErro(pMsg, pForm)

	local lRet	:= .F.
	
	pMsg	:= '<b>Atenção</b><br>'+pMsg+'<br><br><font color="#FF0000">Contate o Administrador</font>'
	
	lRet	:= messageBox(pMsg,pForm,16)

return lRet


user function geraCSV(_cAlias,_cFiltro,aHeader,cForm)
                
	local cDirDocs  := MsDocPath()
	local cArquivo 	:= CriaTrab(,.F.)
	local cPath		:= AllTrim(GetTempPath())
	local oExcelApp
	local nHandle
	local cCrLf 	:= Chr(13) + Chr(10)
	local nX
	local _ni
	//local _cArq		:= ""
	local lRet		:= .T.
	local _uValor	:= ''
		
	_cFiltro := iif(_cFiltro==NIL, "",_cFiltro)
		
	if !empty(_cFiltro)
			(_cAlias)->(dbsetfilter({|| &(_cFiltro)} , _cFiltro))
	endif
		
	nHandle := MsfCreate(cDirDocs+""+cArquivo+".CSV",0)
		
	If nHandle > 0
			
			// Grava o cabecalho do arquivo
			aEval(aHeader, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aHeader), ";", "") ) } )
			fWrite(nHandle, cCrLf ) // Pula linha
			
			(_cAlias)->(dbgotop())
			while (_cAlias)->(!eof())
				
				for _ni := 1 to len(aHeader)
					
					_uValor := ""
					
					if aHeader[_ni,8] == "D" // Trata campos data
						_uValor := dtoc(&(_cAlias + "->" + aHeader[_ni,2]))
					elseif aHeader[_ni,8] == "N" // Trata campos numericos
						_uValor := transform(&(_cAlias + "->" + aHeader[_ni,2]),aHeader[_ni,3])
					elseif aHeader[_ni,8] == "C" // Trata campos caracter
						_uValor := &(_cAlias + "->" + aHeader[_ni,2])
					endif
					
					if _ni <> len(aHeader)
						fWrite(nHandle, _uValor + ";" )
					endif
					
				next _ni
				
				fWrite(nHandle, cCrLf )
				
				(_cAlias)->(dbskip())
				
			enddo
			
			fClose(nHandle)
			CpyS2T( cDirDocs+""+cArquivo+".CSV" , cPath, .T. )
			
			If ! ApOleClient( 'MsExcel' )
				U_msgInforma('MsExcel nao instalado',cForm)
				lRet	:= .F.
				Return lRet
			EndIf
			
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) // Abre uma planilha
			oExcelApp:SetVisible(.T.)
	Else
			U_msgErro('Falha na criação do arquivo',cForm)
			lRet	:= .F.
	Endif
		
	(_cAlias)->(dbclearfil())
		
return lRet



/*/
===============================================================================================================================
Programa----------: UX3Titulo
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 30/12/2018
===============================================================================================================================
Descrição---------: Este programa serve para retornar com o titulod o campo na SX3
===============================================================================================================================
Uso---------------: geral
===============================================================================================================================
Parametros--------: cCampo	-> nome do campo a ser pesquisado
===============================================================================================================================
Retorno-----------: lRet -> titulo do campo informado
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Geral
===============================================================================================================================
/*/
user function UX3Titulo(cCampo)
	local cTitulo	:= ''

	dbSelectArea('SX3')
	SX3->( dbSetOrder(2) )
	SX3->( dbSeek( cCampo ) )
	
	cTitulo:= x3Titulo()
 
return cTitulo


/*/
===============================================================================================================================
Programa----------: UPROXCOD
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 17/09/2018
===============================================================================================================================
Descrição---------: Este programa serve para retornar o proximo codigo DAS TABELAS GENERICAS
===============================================================================================================================
Uso---------------: GERAL
===============================================================================================================================
Parametros--------: sem parametros
===============================================================================================================================
Retorno-----------: _cCodPro = proximo codigo disponivel
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: GERAL
===============================================================================================================================
/*/
user function PROXSEQ(pcAlias,pcCmpInc,pcTamInc,pcCmp01,pcVal01)

	local	cCod	as string,;
			aArea	as array,;
			cQry	as string

	cCod	:= ''
	aArea	:= FWGetArea()	
	cQry	:= ''

	cQry := " SELECT ISNULL(MAX("+pcCmpInc+"),0) AS CODIGO "
	cQry += " FROM " + RetSqlName(pcAlias)
	cQry += " WHERE D_E_L_E_T_ = ' ' "

	if !Empty(pcCmp01)
		cQry += " AND "+pcCmp01+" = '"+pcVal01+"' "
	endif
	
	TcQuery cQry New Alias "TRB"
	dbSelectArea('TRB')
	TRB->(dbGoTop())
	if !TRB->(eof()) .and. !val(TRB->CODIGO) = 0
		cCod	:= Strzero(val(TRB->CODIGO)+1,tamsx3(pcCmpInc)[1])
	else 
		cCod	:= cValToChar(pcVal01)+strZero(1,pcTamInc)
	endif
	TRB->(dbCloseArea())
	
	while !MayIUseCode(pcCmpInc+xFilial(pcAlias)+cCod)
		cCod := Soma1(cCod)
	EndDo             
	
	FWRestArea(aArea)

return(cCod)


/*/
===============================================================================================================================
Programa----------: UX5Descr
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 30/12/2018
===============================================================================================================================
Descrição---------: Este programa serve para retornar com o titulod o campo na SX3
===============================================================================================================================
Uso---------------: geral
===============================================================================================================================
Parametros--------: cCampo	-> nome do campo a ser pesquisado
===============================================================================================================================
Retorno-----------: lRet -> titulo do campo informado
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Geral
===============================================================================================================================
/*/
user function UX5Descr(cPesq)
	local cDescri	:= ''

	dbSelectArea('SX5')
	SX5->( dbSetOrder(1) )
	SX5->( dbSeek( cPesq ) )
	
	cDescri:= x5Descri()
 
return cDescri

/*/
===============================================================================================================================
Programa----------: VldHora
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 04/02/2018
===============================================================================================================================
Descrição---------: Este programa serve para validar uma hora valida
===============================================================================================================================
Uso---------------: geral
===============================================================================================================================
Parametros--------: cHora	-> hora a ser validado
===============================================================================================================================
Retorno-----------: .T. OU .F.
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Guarita
===============================================================================================================================
/*/
user function VldHora(cHora) 

	If Val(Subs(cHora, 1, 2)) < 0 .Or. Val(Subs(cHora, 1, 2)) > 23 .Or.; 
	     Val(Subs(cHora, 4, 2)) < 0 .Or. Val(Subs(cHora, 1, 2)) > 59 
	     Return .F. 
	EndIf 

return .T. 


/*/
===============================================================================================================================
Programa----------: xSitPedido
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 16/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para retornar Situacao atual do pedido de venda
===============================================================================================================================
Uso---------------: geral
===============================================================================================================================
Parametros--------: cCampo	-> nome do campo a ser pesquisado
===============================================================================================================================
Retorno-----------: lRet -> titulo do campo informado
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Geral
===============================================================================================================================
/*/
user function xSitPedido(nOpcao,cSerie,cNota)
	
	/*
		nOpcao =>> 1 = Todo o historico
		nOpcao =>> 2 = Posicao atual
	*/
	
	local	cQry	:= '',;
			cReg	:= ''
	
	cQry	:= 'exec PR_RD00001A @FILIAL = '+chr(39)+xFilial('Z07')+chr(39)+', @SERIE = '+chr(39)+cSerie+chr(39)+', @NUMNOTA = '+chr(39)+cNota+chr(39)+', @NOPCAO = '+cValToChar(nOpcao)+' '
	
	if select('TMPRD01') != 0
		dbSelectArea('TMPRD01')
		TMPRD01->(dbCloseArea())
	endif
	
	tcQuery cQry new alias 'TMPRD01'
	
	dbSelectArea('TMPRD01')
	TMPRD01->(dbGoTop())
	if TMPRD01->(!eof())
		cReg	:= TMPRD01->Z07_DSCSIT
	else
		cReg	:= ''
	endif
	
return cReg



/*/
===============================================================================================================================
Programa----------: PROXPARC
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 27/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para retornar o proximo parcela de um titulo (usado na liquidacao)
===============================================================================================================================
Uso---------------: FINA460
===============================================================================================================================
Parametros--------: PREFIXO, NUMERO TITULO E TIPO
===============================================================================================================================
Retorno-----------: cParcela = <proxima parcela disponivel>
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
===============================================================================================================================
/*/
user function PROXPARC(cPrefixo, cNumTit, cTipo)
			
	local 	cQry 		:= '',;
			cParcela	:= ''
	
	cNumTit	:= strZero(val(cNumTit),tamsx3('E1_NUM')[1])
	cQry 	:= "select max(E1_PARCELA) as PARCELA from "+ RetSqlName('SE1')+" where D_E_L_E_T_ = ' ' and E1_PREFIXO = '"+cPrefixo+"' and E1_NUM = '"+cNumTit+"' and E1_TIPO = '"+cTipo+"'"
	
	cQry	:= changeQuery(cQry)
	
	TcQuery cQry New Alias 'TBTMP1'
	dbSelectArea('TBTMP1')
	TBTMP1->(dbGoTop())
	if empty(TBTMP1->PARCELA)
		cParcela	:= StrZero(1,tamsx3('E1_PARCELA')[1])
	else 
		cParcela	:= Soma1(TBTMP1->PARCELA)//Strzero(val(TBTMP1->PARCELA)+1,tamsx3('E1_PARCELA')[1])
	endif
	
	dbSelectArea('TBTMP1')
	TBTMP1->(dbCloseArea())
	
return( cParcela )

user function LOJACLI(cPessoa,cCGC)
			
	local 	cQry 	:= '',;
			cCodigo	:= '',;
			cLoja	:= ''
			
	cCodigo	:= substr(cCGC,1,8)
	
	if cPessoa == 'F'
		cLoja	:= substr(cCGC,8,4)
	else
		cLoja	:= substr(cCGC,9,4)
	endif
	
	if Select('TBTMP1')
		TBTMP1->(dbCloseArea())
	endif
	
	if cPessoa == 'F'
		cQry 	:= "select A1_COD, max(A1_LOJA) as A1_LOJA from "+ RetSqlName('SA1')+" where D_E_L_E_T_ = ' ' and A1_COD = '"+cCodigo+"' group by A1_COD "
	else
		cQry 	:= "select A1_COD, max(A1_LOJA) as A1_LOJA from "+ RetSqlName('SA1')+" where D_E_L_E_T_ = ' ' and A1_COD = '"+cCodigo+"' and A1_LOJA = '"+cLoja+"' group by A1_COD "
	endif
	cQry	:= changeQuery(cQry)
	TcQuery cQry New Alias 'TBTMP1'
	dbSelectArea('TBTMP1')
	TBTMP1->(dbGoTop())
	if !empty(TBTMP1->A1_COD)
		if cPessoa == 'F'
			cLoja	:= Soma1(TBTMP1->A1_LOJA)
		else
			apMsgInfo('CGC já existe cadastrado!!!..."'+CRLF+'Favor usar outro CNPJ.')
			cLoja	:= ''
		endif
	endif

	dbSelectArea('TBTMP1')
	TBTMP1->(dbCloseArea())
	
return( cLoja )


user function LOJAFOR(cPessoa,cCGC)
			
	local 	cQry 	:= '',;
			cCodigo	:= '',;
			cLoja	:= ''
			
	cCodigo	:= substr(cCGC,1,8)
	
	if cPessoa == 'F'
		cLoja	:= substr(cCGC,8,4)
	else
		cLoja	:= substr(cCGC,9,4)
	endif
	
	if Select('TBTMP1')
		TBTMP1->(dbCloseArea())
	endif
	
	if cPessoa == 'F'
		cQry 	:= "select A2_COD, max(A2_LOJA) as A2_LOJA from "+ RetSqlName('SA2')+" where D_E_L_E_T_ = ' ' and A2_COD = '"+cCodigo+"' group by A2_COD "
	else
		cQry 	:= "select A2_COD, max(A2_LOJA) as A2_LOJA from "+ RetSqlName('SA2')+" where D_E_L_E_T_ = ' ' and A2_COD = '"+cCodigo+"' and A2_LOJA = '"+cLoja+"' group by A2_COD "
	endif
	cQry	:= changeQuery(cQry)
	TcQuery cQry New Alias 'TBTMP1'
	dbSelectArea('TBTMP1')
	TBTMP1->(dbGoTop())
	if !empty(TBTMP1->A2_COD)
		if cPessoa == 'F'
			cLoja	:= Soma1(TBTMP1->A2_LOJA)
		else
			apMsgInfo('CGC já existe cadastrado!!!..."'+CRLF+'Favor usar outro CNPJ.')
			cLoja	:= ''
		endif
	endif

	dbSelectArea('TBTMP1')
	TBTMP1->(dbCloseArea())
	
return( cLoja )

/*/
===============================================================================================================================
Programa----------: PROXPARC
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 27/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para retornar o proximo parcela de um titulo (usado na liquidacao)
===============================================================================================================================
Uso---------------: FINA460
===============================================================================================================================
Parametros--------: PREFIXO, NUMERO TITULO E TIPO
===============================================================================================================================
Retorno-----------: cParcela = <proxima parcela disponivel>
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
===============================================================================================================================
/*/
user function TEMBOLETO(cPrefixo, cNumTit, cTipo)
			
	local 	cQry	:= '',;
			cTem	:= 'N'
	
	cNumTit	:= strZero(val(cNumTit),tamsx3('E1_NUM')[1])
	cQry 	:= "select top 1 E1_NUMBOR from TOTVSFIS..SE1010 where D_E_L_E_T_ = ' ' and E1_PREFIXO = '"+cPrefixo+"' and E1_NUM = '"+cNumTit+"' and E1_TIPO = '"+cTipo+"' and E1_NUMBOR != ''"
	
	cQry	:= changeQuery(cQry)
	
	TcQuery cQry New Alias 'TBTMP1'
	dbSelectArea('TBTMP1')
	TBTMP1->(dbGoTop())
	if !empty(TBTMP1->E1_NUMBOR)
		cTem	:= 'S'
	endif
	
	dbSelectArea('TBTMP1')
	TBTMP1->(dbCloseArea())
	
return( cTem )


/*/
===============================================================================================================================
Programa----------: PrxBordero
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/03/2019
===============================================================================================================================
Descrição---------: Este programa serve para retornar o proximo num bordero disponivel
===============================================================================================================================
Uso---------------: FINA460
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: cNumBordero ==> numero bordero
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
===============================================================================================================================
/*/
user function PrxBordero(_cChvSA6)

	local cNumBord	:= getmv('MV_NUMBORR')

	dbSelectArea('SEA')
	SEA->(dbSetOrder(1))   //EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA
	SEA->(dbGoTop())
		
	if SEA->(dbSeek(xFilial('SEA') + cNumBord))
		if (SEA->EA_DATABOR != dDataBase) .OR. (SEA->EA_TRANSF == 'S')
			cNumBord := Soma1(cNumBord) //Atualiza o numero do borderô a cada dia ou a cada transferência
		endif
	endif

	putMV('MV_NUMBORR',cNumBord) //Atualiza numero de bordero no parametro
	
return( cNumBord )

                         
/*/
===============================================================================================================================
Programa----------: Emails
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/05/2019
===============================================================================================================================
Descrição---------: Este programa serve para retornar os emails do grupo informado
===============================================================================================================================
Uso---------------: AUDITORIAS
===============================================================================================================================
Parametros--------: cGrupos	==> Os codigos dos usuarios dos grupos
===============================================================================================================================
Retorno-----------: cEmail ==> lista dos emails dos usuarios do grupo informado
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
===============================================================================================================================
/*/
user function Emails(cGrupos)

	local 	cEmail		as caracter,;
			aGroup		as array,;
			aAllusers	as array,;
			x			as numeric,;
			y			as numeric
	
	cEmail		:= ''
	aGroup		:= {}
	aAllusers	:= FWSFALLUSERS()

	/*	retorno FWSFALLUSERS()
	[n][1] Id da tabela de usuários
	[n][2] Id do usuário
	[n][3] Login do Usuário
	[n][4] Nome do usuário
	[n][5] email do usuário
	[n][6] departamento do usuário
	[n][7] cargo do usuário
	*/

	for x := 1 To Len(aAllusers)
		aGroup	:= {}
		aGroup	:= usrRetGrp(,aAllusers[x][2])
		
		for y := 1 to len(aGroup)
			if aGroup[y] $ cGrupos	// groupo de supervisor de estoque
				if !empty(alltrim(aAllusers[x][5]))
				    if empty(cEmail)
				    	cEmail	:= alltrim(aAllusers[x][5])
				    else
				    	cEmail	+= ';' + alltrim(aAllusers[x][5])
				    endif
				endif
			endif
			
		next y

	next x
	
return cEmail

/*/
===============================================================================================================================
Programa----------: User
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/05/2019
===============================================================================================================================
Descrição---------: Este programa serve para retornar os User do grupo informado
===============================================================================================================================
Uso---------------: AUDITORIAS
===============================================================================================================================
Parametros--------: cGrupos	==> Os codigos dos usuarios dos grupos
===============================================================================================================================
Retorno-----------: User ==> lista dos usuarios do grupo informado
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
===============================================================================================================================
/*/
user function User(cGrupos)

	local 	aUserID		:= {},;
			aGroup		:= {},;
			aAllusers	:= FWSFALLUSERS(),;
			x,;
			y

	/*	retorno FWSFALLUSERS()
	[n][1] Id da tabela de usuários
	[n][2] Id do usuário
	[n][3] Login do Usuário
	[n][4] Nome do usuário
	[n][5] email do usuário
	[n][6] departamento do usuário
	[n][7] cargo do usuário
	*/
	for x := 1 To Len(aAllusers)
		aGroup	:= {}
		aGroup	:= usrRetGrp(,aAllusers[x][2])
		
		for y := 1 to len(aGroup)
			if aGroup[y] $ cGrupos	// groupo de supervisor de estoque
				if !empty(alltrim(aAllusers[x][2]))
				    aadd(aUserID,aAllusers[x][2])
				endif
			endif
		next y
	next x
	
return aUserID

/*/
===============================================================================================================================
Programa----------: ITCONTAB
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 17/05/2019
===============================================================================================================================
Descrição---------: Este programa serve para CADASTRAR ITEM CONTABIL
===============================================================================================================================
Uso---------------: AUDITORIAS
===============================================================================================================================
Parametros--------: cCodigo	==> codigo de cadastro
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: CADASTRO
===============================================================================================================================
/*/
user function ITCONTAB(cCodigo)

	local	_aArea	:= getArea(),;
			cNome	:= ''
	
	if empty(cCodigo)
		return nil
	endif

	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial('SA1')+cCodigo))
	if found()
		cNome	:= ''
	endif

	restArea(_aArea)
return nil


user function EnvSefazS( _cSerie, _cDoc )

	Local cURL := ""
	Local lOk := .T.
	Local oWs
	Local cAmbiente
	Local cIdEnt:= U_xGetIdEnt()
	
	oWs := WsSpedCfgNFe():New()
	cURL := PadR(GetMv("MV_SPEDURL"),250)
	If CTIsReady()
	
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT := cIdEnt
	oWS:nAmbiente := 0
	oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	lOk := oWS:CFGAMBIENTE()
	cAmbiente := oWS:cCfgAmbienteResult
	cAmbiente := Substr(cAmbiente,1,1)
	AutoNfeEnv(cEmpAnt, cEmpAnt, "0", cAmbiente, _cSerie, _cDoc, _cDoc )
	Endif
	
return


/*/
===============================================================================================================================
Programa----------: Cbc, Rdp, SaltaFolha, Orienta, TamPag, QuantLin, AltCar, Expande, Reduz, Negrito, 15Cpi, L8PolOn, DoubleStroke, Super, ConvData
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 25/07/2019
===============================================================================================================================
Descrição---------: DIVERSOS PROGRAMAS PARA IMPRESSAO DE RELATORIOS
===============================================================================================================================
Uso---------------: RELATORIOS
===============================================================================================================================
Parametros--------: cCodigo	==> codigo de cadastro
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: DIVERSOS SETORES QUE USAM RELATORIO CUSTOMIZADOS
===============================================================================================================================
/*/

User Function Cbc(cEmp,cNum,cTit,cCab1,cCab2,cDesc,cTam,cNome)
	if aReturn[5] == 1
		Cabec(cTit,cCab1,cCab2,cNome,cTam,15)
		
		nLin := If(Empty(cCab2),7,8)
		
		if !Empty(cCbcRef) ; nLin++ ; endif
	elseif aReturn[5] == 3
		@000,000 PSay U_TamPag(66)+U_Reduz(0)
		
		Do Case
			Case cEmp == "01"
				@001,000 PSay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T A"+U_Expande(0)+U_AltCar(12)
			Case cEmp == "02"
				@001,000 PSay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"A T F"+U_Expande(0)+U_AltCar(12)
			Otherwise
				@001,000 PSay U_AltCar(24)+U_Expande(5)+U_Negrito(.T.)+"TESTE"+U_Expande(0)+U_AltCar(12)
		EndCase
		
		@001,014 PSay U_Expande(5)+Padc(AllTrim(MemoLine(cTit,22,1)),22)
		
		If !Empty(cNum)
			@001,031 PSay "N§ "+cNum+U_Expande(0)
		Else
			@001,031 PSay " "+U_Expande(0)
		EndIf
		
		Do Case
			Case cEmp == "01"
				@002,000 PSay U_Reduz(5)+"INDUSTRIA   MECANICA"+U_Reduz(0)
			Case cEmp == "02"
				@002,000 PSay U_Reduz(5)+"ESTRUTURAS METALICAS"+U_Reduz(0)
			Otherwise
				@002,000 PSay U_Reduz(5)+"TESTE DESENVOLVIMENT"+U_Reduz(0)
		EndCase
		
		if Len(cTit) > 22
			@002,014 PSay U_Expande(5)+Padc(AllTrim(MemoLine(cTit,22,2)),22)+U_Expande(0)
			@002,051 PSay U_Reduz(5)+"Emissao: "+U_ConvData(DToS(Date()))+U_Reduz(0)
		else
			@002,081 PSay U_Reduz(5)+"Emissao: "+U_ConvData(DToS(Date()))+U_Reduz(0)
		endif
		
		@003,000 PSay U_15Cpi(.T.)
		
		nLin := 003
		
		if !Empty(cDesc)
			@++nLin,000 psay cDesc
			@++nLin,000 psay Replicate("=",136)
		endif
		
		@++nLin,000 psay If(!Empty(cCab1),cCab1,"")
		
		if !Empty(cCab2)
			@++nLin,000 psay cCab2
		endif
		
		@++nLin,000 psay Replicate("-",136)
		
		nLin++
	endif
Return

User Function Rdp(nPag,cLeg,cTam)	
	if aReturn[5] == 1
//		Roda(nPag,cRodaTxt,cTam)
	elseif aReturn[5] == 3
		@059,000 PSay U_15Cpi(.T.)
		@059,000 PSay cLeg
		@060,000 PSay Replicate("=",136)
		@061,000 PSay "Fonte: ..\"+FunName()+".PRW"
		@061,128 PSay "Pag. "+StrZero(nPag,3)
	endif
Return

User Function SaltaFolha(nSalto,cCbc1,cCbc2)
	local lRet := .F.
//	local nQtdPag := If(aReturn[5] == 1,65,55)
//	nSalto := IIf(Empty(nSalto),55,nSalto)
	
/*	if Empty(nSalto)
		nSalto := IIf(aReturn[5] == 1,60,55)
	endif*/
	
/*	if nLin >= nSalto
		U_Rdp(nRdpPag,cRdpLeg,Tamanho)
		U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
		
		nRdpPag++
	endif*/
	
	if aReturn[5] == 1
		nSalto := IIf(Empty(nSalto),65,nSalto)
		
		if nLin >= nSalto
			U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
			
			nLin++
			nRdpPag++
			lRet := .T.
		endif
	else
		nSalto := IIf(Empty(nSalto),55,nSalto)
		
		if nLin >= nSalto
			U_Rdp(nRdpPag,cRdpLeg,Tamanho)
			U_Cbc(cEmpAnt,cCbcNum,cDesc1,Cabec1,Cabec2,cCbcRef,Tamanho,wnrel)
			
			nLin++
			nRdpPag++
			lRet := .T.
		endif
	endif
Return lRet

User Function Orienta()
	Return (Chr(027)+Chr(038)+Chr(108)+Chr(049)+Chr(079))
Return Nil

User Function TamPap(PAPEL)
	Do Case
		Case PAPEL = "CARTA"
			Return (Chr(027)+"C")+Ltrim(Str(66,3,0))
		Case PAPEL = "OFICIO"
			Return (Chr(027)+"C")+Ltrim(Str(84,3,0))
		Case PAPEL = "A4"
			Return (Chr(027)+"C")+Ltrim(Str(70,3,0))
		Case PAPEL = "ENVELOPE"
			Return (Chr(027)+"C")+Ltrim(Str(16,3,0))
	EndCase
Return Nil

User Function TamPag(QuantLin)
	Return (Chr(27)+"C"+Chr(QuantLin))
Return Nil

User Function QuantLin(QuantL)
	Return (Chr(27)+Ltrim(Str(8-QuantL,2,0)))
Return Nil

User Function AltCar(Altura)
	If Altura=24
		Return (Chr(27)+"w"+Chr(1))
	Else
		Return (Chr(27)+"w"+Chr(0))
	EndIf
Return Nil

User Function Expande(nNum)
	Do Case
		Case nNum = 5
			Return (Chr(27)+Chr(87)+Chr(49))
		Case nNum = 6
			Return (Chr(27)+"!"+Chr(33))
		Case nNum = 8
			Return (Chr(27)+"!"+Chr(36))
		Case nNum = 10
			Return (Chr(27)+"!"+Chr(37))
		Otherwise
			Return (Chr(27)+"!"+Chr(0))
	EndCase
Return Nil

User Function Reduz(nReduz)
	Return (Chr(27)+"!"+Chr(nReduz))
Return Nil

User Function Negrito(lNeg)
	If lNeg == .T.
		Return (Chr(27)+Chr(69))
	Else
		Return (Chr(27)+Chr(70))
	EndIf
Return Nil

User Function 15Cpi(lCpi)
	If lCpi == .T.
		Return Chr(15)
	Else
		Return Chr(18)
	EndIf
Return Nil

User Function L8PolOn(lPol)
	If lPol == .T.
		Return Chr(27)+Chr(48)
//		Return Chr(27)+"0"
	Else
		Return Chr(27)+"2"
	EndIf
Return Nil

User Function DoubleStroke()
	Return Chr(27)+"G"
Return Nil

User Function Super()
	Return Chr(15)+Chr(27)+'M'
Return Nil


user function ConvData(cData,cMskAno)
	local cRet := " "
	
	if !Empty(cData)
		if Empty(cMskAno)
			cRet := Right(cData,2)+"/"+SubStr(cData,5,2)+"/"+Left(cData,4)
		else
			cRet := Right(cData,2)+"/"+SubStr(cData,5,2)+"/"+Right(Left(cData,4),Len(cMskAno))
		endif
	endif
return cRet



/*/
===============================================================================================================================
Programa----------: EstaGrp
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 26/08/2019
===============================================================================================================================
Descrição---------: Este programa serve para retornar se o usuario atual esta no grupo ou nao
===============================================================================================================================
Uso---------------: AUDITORIAS
===============================================================================================================================
Parametros--------: cGrupos	==> Os codigos dos usuarios dos grupos
===============================================================================================================================
Retorno-----------: .F./.T> ==> retorna se pertence ou nao no grupo
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: GERAL
===============================================================================================================================
/*/
user function EstaGrp(pCodUsr,cGrupos)

	local 	aGroup		:= {},;
			aAllusers	:= FWSFALLUSERS(),;
			lRet		:= .F.,;
			x,;
			y

	/*	retorno FWSFALLUSERS()
	[n][1] Id da tabela de usuários
	[n][2] Id do usuário
	[n][3] Login do Usuário
	[n][4] Nome do usuário
	[n][5] email do usuário
	[n][6] departamento do usuário
	[n][7] cargo do usuário
	*/
	for x := 1 To Len(aAllusers)
		
		if aAllusers[x][2] == pCodUsr
			aGroup	:= {}
			aGroup	:= usrRetGrp(,aAllusers[x][2])
		
			for y := 1 to len(aGroup)
				if aGroup[y] $ cGrupos
					lRet	:= .T.
				endif
			next y
		endif
	next x
	
return lRet


/*/
===============================================================================================================================
Programa----------: DCONTRATO
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 18/11/2019
===============================================================================================================================
Descrição---------: Este programa serve para consultar os dados do contrato de parceria
===============================================================================================================================
Uso---------------: CRM
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
===============================================================================================================================
/*/
user function DCONTRATO(pNumCTR,pCol,pdtbase)

	local	cRet

	default pdtbase	= DDATABASE

	if select('TB01')<>0
		TB01->(dbCloseArea())
	endif

	beginsql alias 'TB01'
		column C5_EMISSAO as Date
		//column ENTREGUE as Numeric
		//column RESERVA as Numeric
		//column SALDO as Numeric

		SELECT	
			 ADA.ADA_FILIAL
			,ADA.ADA_NUMCTR
			,ADA.ADA_EMISSA
			,ADA.ADA_CODCLI
			,ADA.ADA_LOJCLI
			,SA1.A1_NOME
			,SC5.C5_SERIE
			,SC5.C5_NOTA
			,SC5.C5_EMISSAO
			,SC5.C5_PESOL
			,isnull(sum(TBENT.C5_PESOL),0)		as ENTREGUE
			,isnull(sum(TBRES.C5_PESOL),0)		as RESERVA
			,SC5.C5_PESOL
				-isnull(sum(TBENT.C5_PESOL),0)
				-isnull(sum(TBRES.C5_PESOL),0)	as SALDO
			,isnull(count(TBENT.R_E_C_N_O_),0)	as QTDENT
			,isnull(count(TBRES.R_E_C_N_O_),0)	as QTDRES
			,isnull(count(TBENT.R_E_C_N_O_),0)
				+isnull(count(TBRES.R_E_C_N_O_),0)	as TOTALENT
		
		FROM
			%table:ADA%	ADA
		
			inner join %table:SA%	 SA1
				on	SA1.%notDel% 
				and SA1.A1_COD		= ADA.ADA_CODCLI
				and SA1.A1_LOJA		= ADA.ADA_LOJCLI
		
			inner join	(	select ADB.ADB_FILIAL, ADB.ADB_NUMCTR, min(ADB.ADB_PEDCOB) as ADB_PEDCOB
							from
								%table:ADB%	 ADB
							where
									ADB.%notDel% 
							group by ADB.ADB_FILIAL, ADB.ADB_NUMCTR	) as ADB
				on	ADB.ADB_FILIAL	= ADA.ADA_FILIAL
				and ADB.ADB_NUMCTR	= ADA.ADA_NUMCTR
		
			left join %table:SC5%	 SC5
				on	SC5.%notDel% 
				and SC5.C5_FILIAL	= ADB.ADB_FILIAL
				and SC5.C5_NUM		= ADB.ADB_PEDCOB
		
			left join (	select distinct SC6.C6_FILIAL, SC6.C6_CONTRAT, SC6.C6_NUM, SC5.C5_SERIE, SC5.C5_NOTA, SC5.C5_PESOL, SC5.C5_EMISSAO, SC5.R_E_C_N_O_
						from
							%table:SC6%	SC6
							inner join %table:SC5%	SC5
								on	SC5.%notDel% 
								and SC5.C5_FILIAL	= SC6.C6_FILIAL
								and SC5.C5_NUM		= SC6.C6_NUM
								and SC5.C5_NOTA		!= ''
						where
								SC6.%notDel% 
							and SC6.C6_FILIAL	= '0101'
							and SC6.C6_CONTRAT	!= ''
							and substring(SC5.C5_EMISSAO,1,6)	< substring(convert(varchar,%exp:pdtbase%,112),1,6)	)	as TBENT
				on	TBENT.C6_FILIAL		= ADB.ADB_FILIAL
				and TBENT.C6_CONTRAT	= ADB.ADB_NUMCTR
				and TBENT.C6_NUM		!= ADB.ADB_PEDCOB
		
			left join (	select distinct SC6.C6_FILIAL, SC6.C6_CONTRAT, SC6.C6_NUM, SC5.C5_SERIE, SC5.C5_NOTA, SC5.C5_PESOL, SC5.C5_EMISSAO, SC5.R_E_C_N_O_
						from
							%table:SC6%	SC6
							inner join %table:SC5%	SC5
								on	SC5.%notDel% 
								and SC5.C5_FILIAL	= SC6.C6_FILIAL
								and SC5.C5_NUM		= SC6.C6_NUM
								and SC5.C5_NOTA		!= ''
						where
								SC6.%notDel% 
							and SC6.C6_FILIAL	= '0101'
							and SC6.C6_CONTRAT	!= ''
							and substring(SC5.C5_EMISSAO,1,6)	= substring(convert(varchar,%exp:pdtbase%,112),1,6)	)	as TBRES
				on	TBENT.C6_FILIAL		= ADB.ADB_FILIAL
				and TBENT.C6_CONTRAT	= ADB.ADB_NUMCTR
				and TBENT.C6_NUM		!= ADB.ADB_PEDCOB
		
		WHERE
				ADA.%notDel%
			and ADA.ADA_NUMCTR	= %exp:pNumCTR%
		
		GROUP BY
			 ADA.ADA_FILIAL
			,ADA.ADA_NUMCTR
			,ADA.ADA_EMISSA
			,ADA.ADA_CODCLI
			,ADA.ADA_LOJCLI
			,SA1.A1_NOME
			,SC5.C5_SERIE
			,SC5.C5_NOTA
			,SC5.C5_EMISSAO
			,SC5.C5_PESOL
	endsql

	dbSelectArea('TB01')
	TB01->(dbGoTop())
	
	if pCol = 1	//NUMPEDIDO COB
		cRet	:= TB01->(C5_SERIE)+TB01->(C5_NOTA)
	elseif pCol = 2	//PESOLIQ
		cRet	:= TB01->(C5_PESOL)
	elseif pCol = 3	//ENTREGUE
		cRet	:= TB01->(ENTREGUE)
	elseif pCol = 4	//RESERVA
		cRet	:= TB01->(RESERVA)
	elseif pCol = 5	//SALDO
		cRet	:= TB01->(SALDO)
	elseif pCol = 6	//QTDENT
		cRet	:= TB01->(QTDENT)
	elseif pCol = 7	//QTDRES
		cRet	:= TB01->(QTDRES)
	elseif pCol = 8	//TOTALENT
		cRet	:= TB01->(TOTALENT)
	endif

return cRet


user function FPedPrin(cNumCont)

	local 	cRet		:= '',;
	 		cNumPed		:= '',;
	 		aArea		:= getArea(),;
	 		aAreaADB	:= ADB->(getArea()),;
	 		aAreaSD2	:= SD2->(getArea())
	
	dbSelectArea('ADB')
	ADB->(dbSetOrder(1))
	ADB->(dbGoTop())
	if ADB->(dbSeek(xFilial('ADB')+cNumCont))
		cNumPed	:= ADB->ADB_PEDCOB
	endif
	ADB->(dbCloseArea())
	
	dbSelectArea('SD2')
	SD2->(dbSetOrder(8))
	SD2->(dbGoTop())
	if SD2->(dbSeek(xFilial('SD2')+cNumPed))
		cRet	:= SD2->D2_DOC
	endif
	SD2->(dbCloseArea())
	
	restArea(aAreaSD2)
	restArea(aAreaADB)
	restArea(aArea)
	
return cRet


user function FPedPesl(cNumCont,cProd)

	local 	nRet		:= 0,;
	 		cNumPed		:= '',;
	 		aArea		:= getArea(),;
	 		aAreaADB	:= ADB->(getArea()),;
	 		aAreaSD2	:= SD2->(getArea())
	 		
	 default cProd	:= ''
	
	dbSelectArea('ADB')
	ADB->(dbSetOrder(1))
	ADB->(dbGoTop())
	if ADB->(dbSeek(xFilial('ADB')+cNumCont))
		cNumPed	:= ADB->ADB_PEDCOB
	endif
	ADB->(dbCloseArea())
	
	dbSelectArea('SD2')
	SD2->(dbSetOrder(8))
	SD2->(dbGoTop())
	SD2->(dbSeek(xFilial('SD2')+cNumPed))
	while !SD2->(eof()) .and. SD2->D2_PEDIDO == cNumPed
				
		if !empty(cProd) .and. SD2->D2_COD == cProd .and. U_EParc(cNumPed,cProd)
			if !empty(SD2->D2_CODISS)
				nRet	+= SD2->D2_QUANT
			else
				nRet	+= SD2->D2_QUANT*SD2->D2_PESO
			endif
		elseif empty(cProd) .and. U_EParc(cNumPed,SD2->D2_COD)
			if !empty(SD2->D2_CODISS)
				nRet	+= SD2->D2_QUANT
			else
				nRet	+= SD2->D2_QUANT*SD2->D2_PESO
			endif
		endif
		SD2->(dbSkip())
	enddo
	SD2->(dbCloseArea())

	restArea(aAreaSD2)
	restArea(aAreaADB)
	restArea(aArea)
	
return nRet

user function EParc(cNumPed,cProd)

	local 	lRet		:= .F.,;
	 		aArea		:= getArea(),;
	 		aAreaSC6	:= SC6->(getArea())
	 		
	dbSelectArea('SC6')
	SC6->(dbSetOrder(2))
	SC6->(dbGoTop())
	SC6->(dbSeek(xFilial('SC6')+cProd+cNumPed))
	while !SC6->(eof()) .and. SC6->C6_PRODUTO == cProd .and. SC6->C6_NUM == cNumPed
	 	if !empty(SC6->C6_CONTRAT)
	 		lRet	:= .T.
	 	endif
		SC6->(dbSkip())
	enddo
	SC6->(dbCloseArea())
	
	restArea(aAreaSC6)
	restArea(aArea)
	
return lRet

user function FPedEnt(cNumCont,cProd)

	local 	nRet		:= 0,;
			cNumPed		:= '',;
	 		aDoc		:= {},;
	 		cDocant		:= '',;
	 		_XI			:= 0,;
	 		aArea		:= getArea(),;
	 		aAreaSC6	:= SC6->(getArea()),;
	 		aAreaSD2	:= SD2->(getArea()),;
	 		aAreaSF2	:= SF2->(getArea())

	 default cProd	:= ''

	//busca o pedido principal
	dbSelectArea('ADB')
	ADB->(dbSetOrder(1))
	ADB->(dbGoTop())
	if ADB->(dbSeek(xFilial('ADB')+cNumCont))
		cNumPed	:= ADB->ADB_PEDCOB
	endif
	ADB->(dbCloseArea())

	//selecionas as notas emitidas exceto a nota principal
	dbSelectArea('SC6')
	SC6->(dbSetOrder(16))
	SC6->(dbGoTop())
	SC6->(dbSeek(xFilial('SC6')+cNumCont))
	while !SC6->(eof()) .and. SC6->C6_CONTRAT == cNumCont
		if SC6->C6_NUM != cNumPed
			if cDocant != SC6->C6_NOTA+SC6->C6_SERIE
				cDocant	:= SC6->C6_NOTA+SC6->C6_SERIE
				aadd(aDoc,cDocant)
			endif
		endif
		SC6->(dbSkip())
	enddo
	SC6->(dbCloseArea())
	
	asort(aDoc)
	
	if !empty(aDoc)
		dbSelectArea('SD2')
		SD2->(dbSetOrder(3))
		SD2->(dbGoTop())
		for _XI := 1 to len(aDoc)
			SD2->(dbSeek(xFilial('SD2')+aDoc[_XI]))
			while !SD2->(eof()) .and. SD2->D2_DOC+SD2->D2_SERIE == +aDoc[_XI]
				if !empty(cProd) .and. SD2->D2_COD == cProd .and. U_EParc(cNumPed,cProd)
					if !empty(SD2->D2_CODISS)
						nRet	+= SD2->D2_QUANT
					else
						nRet	+= SD2->D2_QUANT*SD2->D2_PESO
					endif
				elseif empty(cProd) .and. U_EParc(cNumPed,SD2->D2_COD)
					if !empty(SD2->D2_CODISS)
						nRet	+= SD2->D2_QUANT
					else
						nRet	+= SD2->D2_QUANT*SD2->D2_PESO
					endif
				endif
				SD2->(dbSkip())
			enddo
		next _XI
		SD2->(dbCloseArea())
	endif

	restArea(aAreaSC6)
	restArea(aAreaSD2)
	restArea(aAreaSF2)
	restArea(aArea)
	
return nRet

user function FPedSal(cNumCont,cProd)

	local nRet	:= 0
	
	 default cProd	:= ''

	nRet	:= U_FPedPesl(cNumCont,cProd) - U_FPedEnt(cNumCont,cProd)
	
return nRet

User Function zLeBalanca(cMarca)
    Local nPesoRet
    Local cPorta    := ""
    Local cVelocid  := ""
    Local cParidade := ""
    Local cBits     := ""
    Local cStopBits := ""
	Local cBStop	:= ""
    Local cFluxo    := ""
    Local nTempo    := ""
    Local cConfig   := ""
    Local lRet      := .T.
    Local nH        := 0
    Local cBuffer   := ""
    Local nPosFim   := 0
    Local nPosIni   := 0
    Local nX        := 0
    Local cPesoLido := ""
    local nAux
    Default cMarca  := ""
     
    //Se houver marca
    If ! Empty(cMarca)
        cMarca := Upper(Alltrim(cMarca))
         
        //Pegando a porta padrão da balança
        cPorta    := SuperGetMV("MV_X_PORTA",.F.,"COM1")
         
        //Modelo Confiança
        If (cMarca=="CONFIANCA")
            cVelocid  := SuperGetMV("MV_X_VELOC", .F., "9600")   //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F., "n")      //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F., "8")      //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F., "1")      //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F., "")       //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F., 5)        //Tempo
             
        //Jundiaí
        ElseIf (cMarca == "JUNDIAI")
            cVelocid  := SuperGetMV("MV_X_VELOC", .F., "9600")   //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F., "n")      //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F., "8")      //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F., "0")      //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F., "")       //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F., 5)        //Tempo
             
        //Toledo
        ElseIf (cMarca == "TOLEDO")
            cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"4800")    //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F.,"N")       //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo
         
        //Líder
        ElseIf (cMarca == "LIDER")
            cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"4800")    //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F.,"N")       //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo
         
        //Qualquer balança que utilize porta serial
        Else
            cVelocid  := SuperGetMV("MV_X_VELOC", .F.,"9600")    //Velocidade
            cParidade := SuperGetMV("MV_X_PARID", .F.,"n")       //Paridade
            cBits     := SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
            cStopBits := SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
            cFluxo    := SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
            nTempo    := SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo
        EndIf
         
        //Se a marca da balança for LIDER
        If cMarca == "LIDER"
            //Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
            cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits
                 
            //Guarda resultado se houve abertura da porta
            lRet := MSOpenPort(@nH,cConfig)
             
            //Se não conseguir abrir a porta, mostra mensagem e finaliza
            If !lRet
                MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
                        "<br><b>Porta:</b> "        +cPorta+;
                        "<br><b>Velocidade:</b> "    +cVelocid+;
                        "<br><b>Paridade:</b> "        +cParidade+;
                        "<br><b>Bits:</b> "            +cBits+;
                        "<br><b>Stop Bits:</b> "    +cStopBits,"Atenção")
                             
            Else
                //Realiza a leitura
                For nX := 1 To 50
                    //Obtendo o tempo de espera antes de iniciar a leitura da balança    
                    Sleep(nTempo)
                    MSRead(nH,@cBuffer)
                     
                    //Se a linha retornada for igual ao tamanho limite, encerra o laço
                    If Len(AllTrim(cBuffer)) == MAX_BUFFER
                        Exit
                    EndIf
                Next nX    
                 
                //Verifica onde começa o "E" e diminui 1 caracter
                nPosFim := At("E", cBuffer) - 1
                 
                //Obtendo apenas o peso da balança
                cPesoLido := StrTran(AllTrim(SubStr(cBuffer,2,nPosFim)),".","")
            EndIf
             
            //Encerra a conexão com a porta
            MSClosePort(nH,cConfig)
         
        //Se for a Toledo
        ElseIf cMarca == "TOLEDO"
            //Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
            cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits
             
            //Guarda resultado se houve abertura da porta
            lRet := MSOpenPort(@nH,cConfig)
            lOk  := .T.
             
            //Se não conseguir abrir a porta, tenta mais uma vez, remapeando
            If ! lRet
                //Força o fechamento e abertura da porta novamente
                WaitRun("NET USE "+cPorta+": /DELETE")
                WaitRun("NET USE "+cPorta+" ")
                 
                lOk := MSOpenPort(@nH,cConfig)
                 
                If !lOk
                    MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
                            "<br><b>Porta:</b> "        +cPorta+;
                            "<br><b>Velocidade:</b> "    +cVelocid+;
                            "<br><b>Paridade:</b> "        +cParidade+;
                            "<br><b>Bits:</b> "            +cBits+;
                            "<br><b>Stop Bits:</b> "    +cStopBits,"Atenção")
                EndIf
            EndIf
             
        //Se for a Toledo
        ElseIf cMarca == "JUNDIAI"
            //Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
            cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits
             
            //Guarda resultado se houve abertura da porta
            lRet := MSOpenPort(@nH,cConfig)
            lOk  := .T.
             
            //Se não conseguir abrir a porta, tenta mais uma vez, remapeando
            If ! lRet
                //Força o fechamento e abertura da porta novamente
                WaitRun("NET USE "+cPorta+": /DELETE")
                WaitRun("NET USE "+cPorta+" ")
                 
                lOk := MSOpenPort(@nH,cConfig)
                 
                If !lOk
                    MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
                            "<br><b>Porta:</b> "        +cPorta+;
                            "<br><b>Velocidade:</b> "    +cVelocid+;
                            "<br><b>Paridade:</b> "        +cParidade+;
                            "<br><b>Bits:</b> "            +cBits+;
                            "<br><b>Stop Bits:</b> "    +cStopBits,"Atenção")
                EndIf
            EndIf

            If lOk
                //Inicializa balança
                MsWrite(nH,CHR(5))
                nTaman := 16
                 
                //Realiza a leitura
                For nX := 1 To 50
                    //Obtendo o tempo de espera antes de iniciar a leitura da balança e realiza a leitura    
                    Sleep(nTempo)
                    MSRead(nH,@cBuffer)
                     
                    //Obtendo os caracteres inciais
                    cBuffer := AllTrim(SubStr(AllTrim(cBuffer),1,nTaman))
                     
                    //Se a linha retornada for igual ao tamanho limite
                    If Len(AllTrim(cBuffer)) >= nTaman
                        Exit
                    EndIf
                Next nX    
                 
                 
                //Verifica onde começa o "q" e soma 2 espaços
                nPosIni := At("q",cBuffer)+2
     
                //Obtendo apenas o peso da balança
                cPesoLido := SubStr(cBuffer,nPosIni,nPosIni+3)
            EndIf
             
            //Encerra a conexão com a porta
            MSClosePort(nH,cConfig)
        EndIf    
         
        //Converte o peso obtido para inteiro e o atribui a variavel de retorno
        nPesoRet := Val(cPesoLido)
         
    //Outras balanças
    Else
        //Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
        cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits
     
        //Guarda resultado se houve abertura da porta
        lRet := msOpenPort(@nH,cConfig)
     
        //Se não conseguir abrir a porta, mostra mensagem e finaliza
        If(!lRet)
            //Se for barra, tentar na confiança, depois na jundiai
            MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
                    "<br><b>Porta:</b> "        +cBPorta+;
                    "<br><b>Velocidade:</b> "    +cBVeloc+;
                    "<br><b>Paridade:</b> "        +cBParid+;
                    "<br><b>Bits:</b> "            +cBBits+;
                    "<br><b>Stop Bits:</b> "    +cBStop,"Atenção")
            cLido := 0
        EndIf
     
        //Se estiver OK
        If lRet
            If (cMarca == "JUNDIAI" .Or. cMarca == "CONFIANCA")
                //Mandando mensagem para a porta COM
                msWrite(nH,Chr(5))
                Sleep(nTempo)
     
                //Pegando o tempo final
                cSegNor:=Time()
                cSegAcr:=SubStr(Time(),1,5)+":"+cValToChar(Val(SubStr(Time(),7,2)) + nTempo)
     
                If (cMarca == "JUNDIAI")
                    //Enquanto os tempos forem diferentes
                    While(cSegNor != cSegAcr)
                        //Lendo os dados
                        msRead(nH,@cBuffer)
     
                        //Se não estiver em branco
                        if(!Empty(cBuffer))
                            cLido := Alltrim(cBuffer)
                        EndIf
     
                        //Atualizando o tempo
                        cSegNor:=SubStr(cSegNor,1,5)+":"+cValToChar(Val(SubStr(cSegNor,7,2)) + 1)
                    EndDo
                     
                //Senão, se for confiança, enquanto o tamanho for menor, ler o conteúdo
                ElseIf (cMarca == "CONFIANCA")
                    cLido := ''
                    nCont := 1
                     
                    //Enquanto os tempos forem diferentes
                    While(Len(cLido) < 16)
                        //Lendo os dados
                        msRead(nH,@cBuffer)
                        Sleep(200)
     
                        //Somando o valor lido com o buffer
                        cLido += cBuffer
     
                        //Aumentando o contador
                        nCont++
                        If nCont >= 30
                            If MsgYesNo('Houve <b>30 tentativas</b> de ler o peso, deseja parar?','Atenção')
                                cLido:=Space(17)
                                Exit
                            Else
                                nCont := 1
                            EndIf
                        EndIf
     
                    EndDo
                EndIf
     
                cLido   := Upper(cLido)
                nPosFim := (At('K',cLido) - 1)
 
                //Pegando a Posição Inicial
                For nAux:=1 To Len(cLido)
                    //Se o caracter atual estiver contido no intervalo de 0 a 9 e ponto
                    If(SubStr(cLido,nAux,1) $ '0123456789.')
                        nPosIni:=nAux
                        Exit
                    EndIf
                Next
                 
                nPesoRet := Val(cLido)
            EndIf
        EndIf
         
        msClosePort(nH,cConfig)
    EndIf
     
Return nPesoRet


user function xGetIdEnt(lConsulta)

	local	aArea  := GetArea(),;
			cIdEnt := "",;
			oWs,;
			cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)

	dbSelectArea("SM0")
	dbSetOrder(1)
	dbSeek(cEmpAnt + cFilAnt)
	
	oWS 						:= WsSPEDAdm():New()
	oWS:cUSERTOKEN 				:= "TOTVS"
		
	oWS:oWSEMPRESA:cCNPJ       	:= IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
	oWS:oWSEMPRESA:cCPF        	:= IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cIE         	:= SM0->M0_INSC
	oWS:oWSEMPRESA:cIM         	:= SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       	:= SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   	:= SM0->M0_NOME
	oWS:oWSEMPRESA:cENDERECO   	:= FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        	:= FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      	:= FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         	:= SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        	:= SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    	:= SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   	:= "1058"
	oWS:oWSEMPRESA:cBAIRRO     	:= SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        	:= SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     	:= Nil
	oWS:oWSEMPRESA:cCP         	:= Nil
	oWS:oWSEMPRESA:cDDD        	:= Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       	:= AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX        	:= AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL      	:= UsrRetMail(RetCodUsr())
	oWS:oWSEMPRESA:cNIRE       	:= SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       	:= SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        	:= IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  	:= ""
	oWS:oWSEMPRESA:cID_MATRIZ  	:= ""
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL 					:= AllTrim(cURL)+"/SPEDADM.apw"
	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else             
		if lConsulta
			//Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{""},3)
		endif
	EndIf
	
	restArea(aArea)
	
return(cIdEnt)    


user function ImpDanfe(_pcNf,_pcSerie,pViewPDF,pLPergunta)

	local 	cIdEnt,;
			cChv,;
			oDanfe,;
			cFilePrint,;
			oSetup,;
			aDevice		:= {},;
			cSession	:= GetPrinterSession()
			
	local	aArea		:= getArea(),;
			aAreaSF2	:= SF2->(getArea())

	private	cPerg       := "PRGLT304",;
			_lEntrada	:= .F.,;
			cDevice		:= ""
			
	default pViewPDF	:= .T.
	default pLCustom	:= .T.

	cIdEnt		:= U_xGetIdEnt()
	cChv		:= U_UChvNFE(_pcNf, _pcSerie)
	//cFilePrint	:= "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
	cFilePrint	:= "DANFE_"+cIdEnt+cChv
	cDevice		:= "PDF"	//"PDF" //"SPOOL"

	aadd(aDevice,"DISCO") // 1
	aadd(aDevice,"SPOOL") // 2
	aadd(aDevice,"EMAIL") // 3
	aadd(aDevice,"EXCEL") // 4
	aadd(aDevice,"HTML" ) // 5
	aadd(aDevice,"PDF"  ) // 6

	MV_PAR01	:= _pcNf
	MV_PAR02	:= _pcNf
	MV_PAR03	:= _pcSerie
	MV_PAR04	:= if(_lEntrada, 1, 2 )
	MV_PAR05	:= 2
	MV_PAR06	:= 2
	MV_PAR07	:= SToD('19000101')
	MV_PAR08	:= SToD('99991231')

	//pergunte("NFSIGW",.F.)

	nLocal			:= 2
	nOrientation 	:= 1

	nPrintType		:= aScan(aDevice,{|x| x == cDevice })
	lAdjustToLegacy	:= .F. // Inibe legado de resoluÃ§Ã£o com a TMSPrinter
	lDisableSetup	:= .T. //

	oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,pViewPDF)
	oDanfe:cPathPDF := "C:\TEMP\"

	nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
	oSetup := FWPrintSetup():New(nFlags, "DANFE")

	// ----------------------------------------------
	// Define saida
	// ----------------------------------------------
	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
	oSetup:SetPropert(PD_ORIENTATION , nOrientation)
	oSetup:SetPropert(PD_DESTINATION , nLocal)
	oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
	oSetup:SetPropert(PD_PAPERSIZE   , 2)
	
	oSetup:AOPTIONS[4]	:= 1	//qtd de copia desejada
	oSetup:AOPTIONS[6]	:= "C:\TEMP\"//Seta como sugestao duas copias do DANFE
	oSetup:CQTDCOPIA	:= '01'
	//oSetup:SetorderParms(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07,MV_PAR08)

	WritePrivateProfileString( cSession, "LOCAL", If( oSetup:GetProperty( PD_DESTINATION ) == 1, "SERVER", "CLIENT" ), .T. )
	WritePrivateProfileString( cSession, "PRINTTYPE", If( oSetup:GetProperty( PD_DESTINATION ) == 1, "SPOOL", "PDF" ), .T. )
	WritePrivateProfileString( cSession, "ORIENTATION", If( oSetup:GetProperty( PD_DESTINATION ) == 1, "PORTRAIT", "LANDSCAPE" ), .T. )

/*
	WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
	WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
	WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
*/	
	dbSelectArea('SF2')
	SF2->(dbSetOrder(1))
	SF2->(dbGoTop())
	SF2->(dbSeek(xFilial('SF2')+_pcNf+_pcSerie))

	if SF2->F2_FIMP == 'S'
		if oSetup:GetProperty(PD_ORIENTATION) == 1
			//Para que seja possivel imprimir no DANFE a impressao de acordo com o numero de copias fornecidas
			oDanfe:NQTDCOPIES:= Val(oSetup:CQTDCOPIA)
			u_PrtNfeSef(cIdEnt,,,oDanfe, oSetup, cFilePrint,.F.,0,pLCustom)
		else
			u_DANFE_P1(cIdEnt,,,oDanfe, oSetup)
		endif
	endif
	
	FreeObj(oDANFE)
	oDanfe	:= Nil
	oSetup	:= Nil
	
	restArea(aAreaSF2)
	restArea(aArea)

return(cFilePrint)



/*/
===============================================================================================================================
Programa----------: MskPF
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 22/05/2020
===============================================================================================================================
Descrição---------: Este programa serve para formata cnpj ou cpf de acordo com o tipo de pessoa
===============================================================================================================================
Uso---------------: No orcamento (faturamento)
===============================================================================================================================
Parametros--------: cNumPed = numero do pedido de venda a totalizar
===============================================================================================================================
Retorno-----------: valor total do orcamento
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function MskPF()

	local	aArea	as object,;
			cQryIte	as char,;
			cRet	as char

	aArea	:= GetArea()
	cQryIte	:= ''
	cRet	:= ''

//user function MskPF(cTipo)
  //  if cTipo == 'F'
	//	cRet	:= '@R 999.999.999-99'
	//elseif cTipo == 'J'
	//	
	//	cRet	:= '@R 99.999.999/9999-99'
	//endif
    
    cQryIte := " select CJ_XFLUIG from "+RetSQLName('SC5')+" as SC5 inner join "+RetSQLName('SCJ')+" as SCJ on SCJ.D_E_L_E_T_ = '' and SCJ.CJ_FILIAL = '"+FWxFilial('SCJ')+"' and SCJ.CJ_NUM = SC5.C5_XNUMORC where SC5.D_E_L_E_T_ = '' and SC5.C5_FILIAL = '"+FWxFilial('SC5')+"' and SC5.C5_NUM = '"+cNumPed+"' "
    cQryIte := ChangeQuery(cQryIte)
    TCQuery cQryIte New Alias "QRY_ITE"
         
    QRY_ITE->(DbGoTop())
    if ! QRY_ITE->(EoF())
	   cRet	:= QRY_ITE->CJ_XFLUIG 
    endif
    QRY_ITE->(DbCloseArea())
   
    RestArea(aArea)

return cRet

/*/
===============================================================================================================================
Programa----------: ValPeso
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 25/04/2022
===============================================================================================================================
Descrição---------: Este programa serve para validar se o peso foi preenchido corretamente
===============================================================================================================================
Uso---------------: NO ESTOQUE
===============================================================================================================================
Parametros--------: _pTipo = tipo do produto cadastrado
					_pPeso = peso 
===============================================================================================================================
Retorno-----------: _lRet = continua ou não
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
===============================================================================================================================
/*/
user function ValPeso(_pTipo,_pPeso)
	local _lRet	:= .F.
	if !_pTipo=="SV" .and. _pPeso > 0
		_lRet	:= .T.
	end
return _lRet


user function CriarTabela(_pTabela)
	local lRet	:= .F.
	
	lRet := CHKFILE(_pTabela)

return lRet

/*/
===============================================================================================================================
Programa----------: SelImp
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 02/02/2024
===============================================================================================================================
Descrição---------: Funcao para selecionar impressora a ser impresso
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: pTitulo -> Nome da função que esta fazendo a chamada da funcao
===============================================================================================================================
Retorno-----------: <sem retorno>
===============================================================================================================================
EXEMPLO-----------: 
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function SelImp(pTitulo)
	local 	cImp		as char,;
			cSelImp		as char,;
			aItems		as array

	local 	oDlg		as object,;
			oGet01		as object

	default	pTitulo:= '['+FunName()+']'

 	cImp	:= ''
	cSelImp	:= ''
	aItems	:= {}
	pTitulo	:= pTitulo+' - Selecionar Impressora'

	aadd(aItems,getmv('MV_XPRADM')+'=Administrativo')
	aadd(aItems,getmv('MV_XPRFAT')+'=Faturamento')
	aadd(aItems,getmv('MV_XPRPRO')+'=Producao')
	aadd(aItems,getmv('MV_XPRVEN')+"=Vendas")

	if u_estaGrp(__CUSERID,'000000')	// o usuário logado é do grupo de administrador?
		aadd(aItems,getmv('MV_XPRGER')+'=Administrador')
	endif

	SetPrvt('oDlg1','oSay1','oSBtnOk','oSBtnCan','oMGet1')
	
	DEFINE MSDIALOG oDlg TITLE pTitulo From 0,0 TO 250,530 PIXEL
	
	@ 010,004 SAY OemToansi('Impressora:') SIZE 052, 008 OF oDlg PIXEL
	@ 010,060 COMBOBOX oGet01 VAR cSelImp ITEMS aItems SIZE 156,008 OF oDlg PIXEL

	DEFINE SBUTTON FROM 100, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
	DEFINE SBUTTON FROM 100, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED	

	if nOpca == '1'
		cImp:= alltrim(cSelImp)
	endif

return cImp

/*/
===============================================================================================================================
Programa----------: ImpPedVen
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 02/02/2024
===============================================================================================================================
Descrição---------: Funcao para imprimir o pedido de venda
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: pTitulo -> Nome da função que esta fazendo a chamada da funcao
===============================================================================================================================
Retorno-----------: <sem retorno>
===============================================================================================================================
EXEMPLO-----------: 
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function ImpPedVen(pNumPed,pTitulo,pImp,pQtdVias)

	local 	fAdm		as logical,;
			lImp		as logical,;
			cQry		as char

	local	cNumCrt		as char,;
			cXImp		as char,;
			cNumped		as char,;
			cSerie		as char,;
			cNumNota	as char,;
			cUser		as char,;
			aPedidos	as array,;
			aItens		as array,;
			nX			as numeric,;
			cTerceiro	as char
	
	default pTitulo 	:= '['+funname()+'] - Imprimindo Pedido de Venda'
	default pImp 		:= GetMv("MV_XPRVEN")
	default pQtdVias 	:= '3'

	fAdm:= u_estaGrp(__CUSERID,'000000')	// o usuário logado é do grupo de administrador?

	if select('TMP')<>0
		TMP->(dbCloseArea())
	endif

    cQry := " exec dbo.PR_IMPPEDIDO @filial = '"+fwxFilial('SC5')+"', @numped = '"+pNumPed+"' "
    tcquery cQry new alias 'TMP'
         
	aPedidos:= {}
	while ! TMP->(eof())
		aItens 		:= {}
		cNumped		:= TMP->NUMPED
		cNumCrt		:= TMP->NUMCONTRAT
		cXImp		:= iif(empty(TMP->IMPRESSO),'N',TMP->IMPRESSO)
		cSerie		:= TMP->SERIE
		cNumNota	:= TMP->NOTA
		cUser		:= CUSERNAME
		cTerceiro	:= TMP->FLTERCEIRO

		aadd(aItens, cNumped)
		aadd(aItens, cNumCrt)
		aadd(aItens, cXImp)
		aadd(aItens, cSerie)
		aadd(aItens, cNumNota)
		aadd(aItens, cUser)
		aadd(aItens, cTerceiro)

		aadd(aPedidos,aItens)

		TMP->(dbSkip())
	enddo	
	TMP->(dbCloseArea())

	for nX := 1 to len(aPedidos)
		cNumped		:= aPedidos[nX][1]
		cNumCrt		:= aPedidos[nX][2]
		cXImp		:= aPedidos[nX][3]
		cSerie		:= aPedidos[nX][4]
		cNumNota	:= aPedidos[nX][5]
		cUser		:= aPedidos[nX][6]
		cTerceiro	:= aPedidos[nX][7]

		if alltrim(cNumCrt) != '' .and. cXImp == 'N'
			if U_msgPergunta('Pedido de RESERVA. Deseja Imprimir?',pTitulo) = 6 // 6=SIM
				lImp:= .T.
			else
				lImp:= .F.
			endif
		else
			if alltrim(cXImp) == 'N'
				lImp:= .T.
			else
				if fAdm .or. RetCodUsr()$"0000006/0000030" //luciene.queiroz,marcio.reginaldo
					if U_msgPergunta('Pedido já Impresso ('+alltrim(cXImp)+').'+CRLF;
									+'Deseja Imprimir novamente?',pTitulo) = 6 // 6=SIM
						lImp:= .T.
					else
						lImp:= .F.
					endif
				else
					lImp:= .F.
					U_msgErro('Pedido já Impresso!',pTitulo)
				endif
			endif
		endif

		if lImp
			if alltrim(cNumCrt) != '' .or. fAdm .or. cSerie == 'XTR'
				pImp:= U_SelImp(pTitulo)
			endif

			if alltrim(pImp) != ''
				if alltrim(cNumCrt) <> '' //verificando se é reserva
					lImp:= U_RL05009(cNumPed,cNumNota,pImp)
				
				elseif alltrim(cTerceiro) == 'R'	//é remessa para terceiro
					lImp:= U_RL05017(cNumPed,cNumNota,pImp,pQtdVias,cSerie)
				
				else
					lImp:= U_RL05001(cNumPed,cNumNota,pImp,pQtdVias)
				
				endif

				if lImp
					cQry:= 'exec dbo.PR_RD00001_IMPPEDVEN @pFilial ="'+xFilial('SC5')+'", @pNumPed = "'+cNumPed+'", @pSerie = "'+cSerie+'", @pNumNota = "'+cNumNota+'", @pUserName = "'+cUser+'"'
					u_ExecQry(cQry,.T.)

					if cXImp == 'R'
						EnviaEmail()
					endif
				endif

			else
				U_msgErro('Impressora não selecionado. PEDIDO NAO IMPRESSO!!!!',pTitulo)
			endif

		else
			U_msgErro('Impressão abordado.',pTitulo)
		endif
	
	next nX

return lImp

static function EnviaEmail()

	local	_cTo			:= lower(AllTrim(GetMv('MV_RELACNT'))),;
			_cFrom			:= alltrim(getMV('MV_XAUDITO')),;
			_cCopia			:= ' ',;
			_cCopiaOculta	:= ' ',;
			_cAssunto		:= ' ',;
			_cMensagem		:= ' ',;
			_lReturn		:= .F.

	_cAssunto	:= OemToAnsi('[AUDIT-MANFIL] Pedido Reimpresso: '+alltrim(SF2->F2_SERIE+SF2->F2_DOC)+' - '+allTrim(SC5->C5_XCLIENT)+' - '+alltrim(SF2->F2_CLIENTE)+'-'+alltrim(SF2->F2_LOJA))
	_cMensagem	:= OemToAnsi('Pedido abaixo foi REIMPRESSO: ') + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Filial......: ') + SF2->F2_FILIAL + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Num.Pedido..: ') + SC5->C5_NUM +chr(10)+'Num.Nota..: '+SF2->F2_SERIE+SF2->F2_DOC+chr(10)+'Data Emissao..: '+dtos(SF2->F2_EMISSAO) + CRLF + CRLF
	_cMensagem	+= OemToAnsi('Cliente: ') + allTrim(SC5->C5_XCLIENT)+' - '+alltrim(SC5->C5_CLIENTE)+'-'+alltrim(SC5->C5_LOJACLI) + CRLF + CRLF
	_cMensagem	+= CRLF + CRLF 
	_cMensagem	+= OemToAnsi('TIC - Manfil      ') + CRLF
	_cMensagem	+= OemToAnsi('Tecnologia, Informação e Comunicação') + CRLF

	Processa({ || U_EnvMail(_cTo,_cFrom,_cCopia,_cCopiaOculta,_cAssunto,_cMensagem,'',_lReturn)},'[M460FIM] - ENVIANDO EMAIL AGUARDE')

return

/*/
===============================================================================================================================
Programa----------: MovSitPed
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 28/05/2024
===============================================================================================================================
Descrição---------: Faz as devidas movimentações estatus do doc de saida (Controle Sit Pedido de Venda)
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: P_Serie -> Serie do doc de saida
					P_Doc	-> Numero do documento de saida
					P_CodSit	-> Cod da Situacao que será alterada
===============================================================================================================================
Retorno-----------: <sem retorno>
===============================================================================================================================
EXEMPLO-----------: 
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function MovSitPed(P_Serie, P_Doc, P_CodSit, P_Data, P_Hora, P_Carga, P_SeqCarga)

	local	cQry	as char,;
			lFlag	as logical

	default P_Carga:= ''
	default P_SeqCarga:= ''

	cQry:= 'exec dbo.PR_MOVSITPED @FILIAL = '+char(39)+xFilial('Z04')+char(39)+', @SERIE = '+char(39)+P_Serie+char(39)+', @DOC = '+char(39)+P_Doc+char(39)+', @SITUAC = '+char(39)+P_CodSit+char(39)+', @USER = '+char(39)+CUSERNAME+char(39)+', @DATA = '+char(39)+dToS(P_Data)+char(39)+', @HORA = '+char(39)+P_Hora+char(39)+', @CARGA = '+char(39)+P_Carga+char(39)+', @SEQCAR = '+char(39)+P_SeqCarga+char(39)+''
	u_ExecQry(cQry,.F.)

	lFlag	:= posicione('Z04',1,FWxFilial('Z04')+P_CodSit,'Z04_ALVEND')

	if lFlag
		EnvEmailSitPed(P_Doc,P_Serie,P_CodSit)
	end

return .T.

static function EnvEmailSitPed(pDoc,pSerie,pSit)

	local	aArea			as object,;
			aAreaSD2		as object,;
			lReturn			as logical

	local	cVend			as char,;
			cCodLjCliente	as char,;
			cCliente		as char,;
			cNumPed			as char,;
			dDtEmissao		as date,;
			nValor			as numeric,;
			cSituacao		as char

	local	cTo				as char,;
			cFrom			as char,;
			cCopia			as char,;
			cCopiaOculta	as char,;
			cAssunto		as char,;
			cMensagem		as char

	aArea			:= getArea()
	aAreaSD2		:= SD2->(getArea())
	lReturn			:= .F.

	dbSelectArea('SD2')
	SD2->(dbSetOrder(1))
	SD2->(DbGoTop())
	SD2->(dbSeek(FWxFilial('SD2')+pDoc+pSerie))
	cVend			:= posicione('SF2',1,FWxFilial('SF2')+pDoc+pSerie,'F2_VEND1')
	cCodLjCliente	:= SD2->D2_CLIENTE+SD2->D2_LOJA
	cNumPed			:= SD2->D2_PEDIDO
	dDtEmissao		:= SD2->D2_EMISSAO
	nValor			:= u_xVlNota(pSerie,pDoc)
	cCliente		:= posicione('SC5',1,FWxFilial('SC5')+cNumPed,'C5_XNOMCON')

	cTo				:= lower(AllTrim(GetMv('MV_RELACNT')))
	cFrom			:= posicione('SA3',1,FWxFilial('SA3')+cVend,'A3_EMAIL')
	cCopia			:= ''
	cCopiaOculta	:= ''
	cAssunto		:= ''
	cMensagem		:= ''
	lReturn			:= .F.

	cSituacao		:= posicione('Z04',1,FWxFilial('Z04')+pSit,'Z04_STATUS')

	cAssunto	:= OemToAnsi('[AUDIT-MANFIL] Atualizado Situaçao de Pedidos: '+alltrim(pSerie+pDoc)+' - '+allTrim(cCliente)+' - '+alltrim(cCodLjCliente))
	cMensagem	:= OemToAnsi('Situação: '+pSit+' - '+alltrim(cSituacao)) + CRLF + CRLF
	cMensagem	+= OemToAnsi('Num.Nota..: '+pSerie+pDoc+chr(10)+'Data Emissao..: '+dtos(dDtEmissao)) + CRLF + CRLF
	cMensagem	+= OemToAnsi('Cliente: ') + allTrim(cCliente)+' - '+alltrim(cCodLjCliente) + CRLF + CRLF
	cMensagem	+= OemToAnsi('Valor: R$ ') + transform(nValor,'@E 999,999,999,999,999.99') + CRLF + CRLF
	cMensagem	+= CRLF + CRLF 
	cMensagem	+= OemToAnsi('TIC - Manfil      ') + CRLF
	cMensagem	+= OemToAnsi('Tecnologia, Informação e Comunicação') + CRLF

	U_EnvMail(cTo,cFrom,cCopia,cCopiaOculta,cAssunto,cMensagem,'',lReturn)

//	Processa({ || U_EnvMail(cTo,cFrom,cCopia,cCopiaOculta,cAssunto,cMensagem,'',lReturn)},'[RD00001] - ENVIANDO EMAIL AGUARDE')

	restArea(aAreaSD2)
	RestArea(aArea)

return .t.

/*/
===============================================================================================================================
Programa----------: NOTAORIG
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 20/06/2024
===============================================================================================================================
Descrição---------: Retorno a serie e numero da nota fiscal de cobranca
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: pNota 	-> Serie do doc de saida
					pSerie	-> Numero do documento de saida
===============================================================================================================================
Retorno-----------: <sem retorno>
===============================================================================================================================
EXEMPLO-----------: 
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function SERIEORIG(pNota, pSerie)

	local 	cRet	:= '',;
			cQry	:= ''
	
	cQry	:= 'exec dbo.PR_RD39001 @SERIE = '+char(39)+pSerie+char(39)+', @NOTA = '+char(39)+pNota+char(39)+''

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TB1') <> 0
		dbSelectArea('TB1')
		TB1->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQry NEW ALIAS 'TB1'
	
	dbSelectArea('TB1')
	TB1->(dbGoTop())
	cRet:= TB1->D2_SERIE
	TB1->(dbCloseArea())

return cRet


/*/
===============================================================================================================================
Programa----------: NOTAORIG
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 20/06/2024
===============================================================================================================================
Descrição---------: Retorno a serie e numero da nota fiscal de cobranca
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: pNota 	-> Serie do doc de saida
					pSerie	-> Numero do documento de saida
===============================================================================================================================
Retorno-----------: <sem retorno>
===============================================================================================================================
EXEMPLO-----------: 
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function NOTAORIG(pNota, pSerie)

	local 	cRet	:= '',;
			cQry	:= ''
	
	cQry	:= 'exec dbo.PR_RD39001 @SERIE = '+ char(39)+pSerie+char(39)+', @NOTA = '+char(39)+pNota+char(39)+''

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TB1') <> 0
		dbSelectArea('TB1')
		TB1->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQry NEW ALIAS 'TB1'
	
	dbSelectArea('TB1')
	TB1->(dbGoTop())
	cRet:= TB1->D2_DOC
	TB1->(dbCloseArea())

return cRet

/*/
===============================================================================================================================
Programa----------: TEMNFORI
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 23/06/2024
===============================================================================================================================
Descrição---------: Retorno SE TEM RESERVA
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: pNota 	-> Serie do doc de saida
					pSerie	-> Numero do documento de saida
===============================================================================================================================
Retorno-----------: <sem retorno>
===============================================================================================================================
EXEMPLO-----------: 
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function TEMNFORI(pNota, pSerie)

	local 	cRet	:= '',;
			cQry	:= ''
	
	cQry	:= 'exec dbo.PR_RD39001 @SERIE = '+ char(39)+pSerie+char(39)+', @NOTA = '+char(39)+pNota+char(39)+''

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TB1') <> 0
		dbSelectArea('TB1')
		TB1->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQry NEW ALIAS 'TB1'
	
	dbSelectArea('TB1')
	TB1->(dbGoTop())
	cRet:= TB1->D2_DOC
	TB1->(dbCloseArea())
	if !empty(cRet)
		cRet:= 'RS'
	endif

return cRet


user function UltKM(cVeiculo)

	local 	cQry	as char,;
			lRet	as numeric

	lRet:= 0

	cQry:= 'select top 1 DAK_XKMRET				'
	cQry+= 'from DAK010							'
	cQry+= 'where								'
	cQry+= '	D_E_L_E_T_	= '+char(39)+''+char(39)+''	
	cQry+= '	and DAK_CAMINH	= '+char(39)+cVeiculo+char(39)+''
	cQry+= '	and DAK_XKMRET	!= '+char(39)+''+char(39)+''
	cQry+= 'order by							'
	cQry+= 'DAK_XDTRET desc						'
	
	TcQuery cQry New Alias "TRB"
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	if !TRB->(EOF())
		lRet	:= TRB->DAK_XKMRET
	endif
	dbSelectArea('TRB')
	TRB->(dbCloseArea())

return lRet


/*/
===============================================================================================================================
Programa----------: PRXSEQCAR
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 03/07/2024
===============================================================================================================================
Descrição---------: Este programa serve para retornar o proximo SEQ DE CARGA
===============================================================================================================================
Uso---------------: MV39001
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: cNumBordero ==> numero bordero
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
===============================================================================================================================
/*/
user function PRXSEQCAR(pCod)

	local 	cSeqCar	as char,;
			cCodigo	as char

	local	aArea		:= getArea(),;
			aAreaDAK	:= DAK->(getArea())
	
	cCodigo	:= substring(getmv('MV_XSEQCAR'),1,6)
	cSeqCar	:= substring(getmv('MV_XSEQCAR'),7,2)

	if cCodigo == pCod
		cSeqCar := Soma1(cSeqCar) 
	else
		cSeqCar := '01'
	end
	DAK->(dbCloseArea())

	putMV('MV_XSEQCAR',pCod+cSeqCar) //Atualiza numero de bordero no parametro
	
	restArea(aAreaDAK)
	restArea(aArea)

return cSeqCar


/*/
===============================================================================================================================
Programa----------: NFFISCA
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 08/07/2024
===============================================================================================================================
Descrição---------: Retorno a serie e numero da nota fiscal gerado para o pedido de venda
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: pNota 	-> Serie do doc de saida
					pSerie	-> Numero do documento de saida
===============================================================================================================================
Retorno-----------: <sem retorno>
===============================================================================================================================
EXEMPLO-----------: 
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function NFFISCA(pNota, pSerie, pTipo)

	local 	cRet	:= '',;
			cQry	:= ''
	
	cQry	:= 'exec dbo.PR_MV39001T @SERIE = '+char(39)+pSerie+char(39)+', @NOTA = '+char(39)+pNota+char(39)+', @TIPO = '+cValToChar(pTipo)+''

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TB1') <> 0
		dbSelectArea('TB1')
		TB1->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQry NEW ALIAS 'TB1'
	
	dbSelectArea('TB1')
	TB1->(dbGoTop())
	cRet:= TB1->RET
	TB1->(dbCloseArea())

return cRet


/*/
===============================================================================================================================
Programa----------: NFFISCA
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 08/07/2024
===============================================================================================================================
Descrição---------: Retorno a serie e numero da nota fiscal gerado para o pedido de venda
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: pNota 	-> Serie do doc de saida
					pSerie	-> Numero do documento de saida
===============================================================================================================================
Retorno-----------: <sem retorno>
===============================================================================================================================
EXEMPLO-----------: 
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function TABGENERICA(pTabela)
	local	cQry	as char

	cQry:= 'exec TABGERNERCIA @TABELA = '+char(39)+pTabela+char(39)

	u_ExecQry(cQry,.T.)
	
return

/*/
===============================================================================================================================
Programa----------: CEPInfo
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 25/09/2023
===============================================================================================================================
Descrição---------: Função que executa uma query e já exibe um log em tela em caso de falha
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: cQuery	=> Caractere, Query SQL que será executada no banco
					lFinal	=> Lógico, Define se irá encerrar o sistema em caso de falha
===============================================================================================================================
Retorno-----------: lDeuCerto	=> Lógico, .T. se a query foi executada com sucesso ou .F. se não
===============================================================================================================================
EXEMPLO-----------: u_ExecQry("UPDATE TABELA SET CAMPO = 'AAAA'")
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
#DEFINE STR0001 "Informe o CEP"
#DEFINE STR0002 "Consulta de CEP"
#DEFINE STR0003  "UF"
#DEFINE STR0004 "Cidade"
#DEFINE STR0005  "Bairro"
#DEFINE STR0006 "Tipo de Logradouro"
#DEFINE STR0007 "Logradouro"
#DEFINE STR0008 "Resultado da Consulta"
#DEFINE STR0009 "CEP"
#DEFINE STR0010 "Mensagem"
#DEFINE STR0011 "Consultar Novo CEP?"
#DEFINE STR0012 "Consultando CEP"
#DEFINE STR0013 "Aguarde..."

/*/
 Funcao: CEPInfo
 Autor: Marinaldo de Jesus
 Data: 20/09/2010
 Uso: Consulta de CEP
 Obs.: Exemplo de Consumo do WEB Service u_wsCEPInfo para Consulta de CEP ao site da Republica Virtual
/*/

User Function CEPInfo()

 Local aPerg   := {}
 Local aResult  := {}
 
 Local bCEPSearch
 
 Local cXML

 Local cError  := ""
 Local cWarning  := ""

 Local cUF
 Local cCidade
 Local cBairro
 Local cMensagem
 Local cResultado
 Local cLogradouro
 Local cTpLogradouro

 Local oWSCEP
 Local oXML

 BEGIN SEQUENCE
 
  aAdd( aPerg , { 1 , STR0002 , Space(8) , "99999999" , ".T." , "" , ".T." , 8 , .T. } ) //"Informe o CEP"
  IF ParamBox( @aPerg , STR0002 , NIL , NIL , NIL , .T. )
   
   bCEPSearch := { ||           ; 
        oWSCEP   := WSU_WSCEPINFO():New(), ;
        oWSCEP:cCEP := MV_PAR01,    ;
        oWSCEP:CEPSEARCH()      ;
         } 

   MsgRun( STR0013 , STR0012 , bCEPSearch ) //"Aguarde"###"Consultando CEP"

   cXML  := oWSCEP:cCEPSEARCHRESULT
   oXML  := XmlParser( cXML , "_" , @cError , @cWarning )
 
   cResultado := oXml:_WebServiceCep:_Resultado:Text
   cMensagem := oXml:_WebServiceCep:_Resultado_Txt:Text
 
   IF ( cResultado == "1" )
 
    cUF    := oXml:_WebServiceCep:_UF:Text
    cCidade   := oXml:_WebServiceCep:_Cidade:Text
    cBairro   := oXml:_WebServiceCep:_Bairro:Text
    cLogradouro  := oXml:_WebServiceCep:_Logradouro:Text
    cTpLogradouro := oXml:_WebServiceCep:_Tipo_Logradouro:Text

    aAdd( aResult , { 1 , STR0009 , MV_PAR01  , "99999999" , ".T." , "" , ".F." , 08 , .F. } ) //"CEP"
    aAdd( aResult , { 1 , STR0003 , cUF      , "@"   , ".T." , "" , ".F." , 04  , .F. } ) //"UF"
    aAdd( aResult , { 1 , STR0004 , cCidade   , "@"   , ".T." , "" , ".F." , 100 , .F. } ) //"Cidade"
    aAdd( aResult , { 1 , STR0005 , cBairro   , "@"     , ".T." , "" , ".F." , 100 , .F. } ) //"Bairro"
    aAdd( aResult , { 1 , STR0006 , cTpLogradouro , "@"     , ".T." , "" , ".F." , 100 , .F. } ) //"Tipo de Logradouro"
    aAdd( aResult , { 1 , STR0007 , cLogradouro  , "@"   , ".T." , "" , ".F." , 100 , .F. } ) //"Logradouro"

   Else
   
    aAdd( aResult , { 1 , STR0009 , MV_PAR01  , "99999999"  , ".T." , "" , ".F." , 08 , .F. } ) //"CEP"
 
   EndIF

   ParamBox( @aResult , STR0008 + " : " + cMensagem , NIL , NIL , NIL , .T. ) //"Resultado da Consulta"


   IF !( MsgNoYes( "Consultar Novo CEP?" , ProcName() ) )
    BREAK
   EndIF
 
   U_CEPInfo()
 
  EndIF

 END SEQUENCE

Return( MBrChgLoop( .F. ) )


/*/
===============================================================================================================================
Programa----------: CriaTabela
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 11/10/2024
===============================================================================================================================
Descrição---------: Função que cria tabela em tempo de execucao
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: cTabela -> nome da tabela a ser criado ('Z50')
===============================================================================================================================
Retorno-----------: lRet	=> Lógico, .T. se a query foi executada com sucesso ou .F. se não
===============================================================================================================================
EXEMPLO-----------: u_CriaTabela('Z50')
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function CriaTabela(cTab)

	local	cArq    as char

    cArq:= cTab+'010'
    CheckFile(cTab,cArq)
	//chkfile(cTab,.F.)

return

/*/
===============================================================================================================================
Programa----------: NTEncerrada
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 31/10/2024
===============================================================================================================================
Descrição---------: Função que Verifica se a nota esta encerrado
===============================================================================================================================
Uso---------------: FATURAMENTO
===============================================================================================================================
Parametros--------: pStNota -> Situacao da nota atual
===============================================================================================================================
Retorno-----------: lRet	=> Lógico, .T. se esta encerrado ou .F. se não
===============================================================================================================================
EXEMPLO-----------: u_CriaTabela('Z50')
===============================================================================================================================
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODO SISTEMA
===============================================================================================================================
/*/
user function NTEncerrada(pStNota)

	local	lRet    	as logical,;
			cSituacao	as  char

	lRet		:= posicione('Z04',1,xFilial('Z04')+pStNota,'Z04_FLFINA')
	cSituacao	:= posicione('Z04',1,xFilial('Z04')+pStNota,'Z04_STATUS')

	//lRet:= iif(pStNota $ '09',.T.,.F.)
	
	if lRet
		help(,,'Help',,'Não é permitido alterar situação de um pedido já '+alltrim(cSituacao)+'.', 1, 0)
	endif
	
return lRet


User Function zGerDanfe(cNota, cSerie, pViewPDF, pXML, cPasta)

	Local aArea     := GetArea()
	Local cIdent    := ""
	Local cArquivo  := ""
	Local oDanfe    := Nil
	Local lEnd      := .F.
	Local nTamNota  := TamSX3('F2_DOC')[1]
	Local nTamSerie := TamSX3('F2_SERIE')[1]
	Local dDataDe   := sToD("19000101")
	Local dDataAt   := Date()

	Private PixelX
	Private PixelY
	Private nConsNeg
	Private nConsTex
	Private oRetNF
	Private nColAux

	Default cNota   := ""
	Default cSerie  := ""
	Default pXML	:= .F.
	Default cPasta  := GetTempPath()
       
    //Se existir nota
	If ! Empty(cNota)
		//Pega o IDENT da empresa
		cIdent	:= RetIdEnti()
		//cChv	:= U_UChvNFE(cNota, cSerie)

		//Se o último caracter da pasta não for barra, será barra para integridade
		If SubStr(cPasta, Len(cPasta), 1) != "\"
			cPasta += "\"
		EndIf
			
		//Gera o XML da Nota
		//cArquivo := cNota + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
		cArquivo := 'danfe_' + cSerie + cNota + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
		if pXML
			u_zSpedXML(cNota, cSerie, cPasta + cArquivo  + ".xml", .F.)
		end

		//Define as perguntas da DANFE
		Pergunte("NFSIGW",.F.)
		MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
		MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
		MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
		MV_PAR04 := 2                          //NF de Saida
		MV_PAR05 := 1                          //Frente e Verso = Sim
		MV_PAR06 := 2                          //DANFE simplificado = Nao
		MV_PAR07 := dDataDe                    //Data De
		MV_PAR08 := dDataAt                    //Data Até
			
		//Cria a Danfe
		oDanfe := FWMSPrinter():New(cArquivo,IMP_PDF,.F., ,.T.)
			
		//Propriedades da DANFE
		oDanfe:SetResolution(78)
		oDanfe:SetPortrait()
		oDanfe:SetPaperSize(DMPAPER_A4)
		oDanfe:SetMargin(60, 60, 60, 60)
			
		//Força a impressão em PDF
		oDanfe:nDevice  := 6
		oDanfe:cPathPDF := cPasta                
		oDanfe:lServer  := .F.
		oDanfe:lViewPDF := pViewPDF
			
		//Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
		PixelX    := oDanfe:nLogPixelX()
		PixelY    := oDanfe:nLogPixelY()
		nConsNeg  := 0.4
		nConsTex  := 0.5
		oRetNF    := Nil
		nColAux   := 0
			
		//Chamando a impressão da danfe no RDMAKE
		RptStatus({|lEnd| u_DanfeProc(@oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")
		oDanfe:Print()

		FreeObj(oDanfe)
		oDanfe := Nil
	endIf
		
	RestArea(aArea)
Return cArquivo

User Function zSpedXML(cDocumento, cSerie, cArqXML, lMostra)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := RetIdEnti()
    Local cTextoXML    := ""
    Default cDocumento := ""
    Default cSerie     := ""
    Default cArqXML    := GetTempPath()+"arquivo_"+cSerie+cDocumento+".xml"
    Default lMostra    := .F.
        
    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                        
                //Senão, pega o xml normal (foi alterado abaixo conforme dica do Jorge Alberto)
                Else
                    cTextoXML := '<?xml version="1.0" encoding="UTF-8"?>'
                    cTextoXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
                    cTextoXML += '</nfeProc>'
                EndIf
                    
                //Gera o arquivo
                MemoWrite(cArqXML, cTextoXML)
                    
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                If lMostra
                    Aviso("zSpedXML", cTextoXML, {"Ok"}, 3)
                EndIf
                    
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("zSpedXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                    
                If lMostra
                    Aviso("zSpedXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
            
        //Senão, houve erros na classe
        Else
            ConOut("zSpedXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
                
            If lMostra
                Aviso("zSpedXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return


static function ValPed(aPedidos)

	local   lRet        as logical,;
			cMsg        as char,;
			cLocal      as char,;
			nX          as numeric,;
			cNumNota    as char,;
			cSerie      as char,;
			cCliente    as char,;
			cCodCli     as char,;
			cLojaCli    as char,;
			cEstado     as char

	//Iniciando as variaveis
	lRet        := .T.
	cMsg        := ''
	cLocal      := getmv('MV_XLOCAL')
	nX          := 0
	cNumNota    := ''
	cSerie      := ''
	cCliente    := ''
	cCodCli     := ''
	cLojaCli    := ''
	cEstado     := ''

	for nX := 1 to len(aPedidos)
		lRet        := .T.
		cCodCli     := aPedidos[nX][1]
		cLojaCli    := aPedidos[nX][2]
		cNumNota    := aPedidos[nX][4]
		cSerie      := aPedidos[nX][3]
		cCliente    := alltrim(aPedidos[nX][5])
		cEstado     := aPedidos[nX][6]

		cMsg+= strzero(nX,3)+' ==>> '+cSerie+cNumNota +' - '+cCliente+CRLF+CRLF

		/* VERIFICANDO SE O PEDIDO JA FOI IMPORTADO */
		dbSelectArea('Z50')
		Z50->(dbSetOrder(2))
		Z50->(dbGoTop())
		if (Z50->(dbSeek(FWxFilial('Z50')+cSerie+cNumNota)))
			if u_msgPergunta('Pedido já integrado ' + cSerie+cNumNota +' - '+cCliente + '!' + CRLF +;
							'Deseja INTEGRAR novamente?', '[RD000001] - Importação Pedidos') = 7
				lRet:= .F.
				cMsg+= '** PEDIDO DE VENDA rejeitado pelo OPERADOR - pedido já integrado **' +CRLF+CRLF
			else
				lRet:= .T.
			endif
		endif

		/* Checando os alertas ao operador */
		if lRet

			//cliente fora do estado
			if cEstado != getmv('MV_ESTADO')
				cMsg    += '* CLIENTE fora do ESTADO ('+alltrim(cEstado)+')'+CRLF+CRLF
			endif

			dbSelectArea('SA1')
			SA1->(dbSetOrder(1))
			SA1->(dbGoTop())
			if SA1->(dbSeek(FWxFilial('SA1')+cCodCli+cLojaCli))
				//cliente é um revendedor
				if SA1->A1_CODSEG == '000004' .and. SA1->A1_TIPO == 'S'
					cMsg+= '* CLIENTE É UM REVENDEDOR e está sujeito a RETENÇÃO ICMS ST portanto a COBRANÇA extra. Para os sub-grupos:'+CRLF;
						+'- 7001 - Telhas de Aço MA - ICMS ST 15,90%'+CRLF;
						+'- 7002 - Colunas Prontas MA - ICMS ST 12,30%'+CRLF;
						+'- 7101 - Vergalhões MA 50/60 - ICMS ST 4,20%'+CRLF;
						+'- 7115 - Treliças MA - ICMS ST 15,90%'+CRLF;
						+'- 7116 - Telas/Paineis MA - ICMS ST 12,30%'+CRLF;
						+'- 7117 - Malhas Pop MA - ICMS ST 12,30%'+CRLF+CRLF

				//cliente é um fazendeiro
				elseif SA1->A1_CODSEG == '000005'
					cMsg+= '* CLIENTE É UM FAZENDEIRO!'+CRLF+CRLF

				//cliente requer faturamento
				elseif !cCodCli $ '99999998|99999999' .and. cLocal == '1' .and. SA1->A1_XNF .and. FunName() $ 'MATA415|LOJA701'
					cMsg+= '* Cliente requer FATURAMENTO'+CRLF+CRLF
				elseif !cCodCli $ '99999998|99999999' .and. cLocal == '2' .and. !SA1->A1_XNF
					cMsg+= '* Cliente NÃO requer FATURAMENTO'+CRLF+CRLF

				elseif SA1->A1_XCERTIF
					cMsg+= '* Cliente requer CERTIFICADO DE QUALIDADE DO FORNECEDOR, com as informações na nota fiscal'+CRLF+CRLF

				//cliente exige pedido de compra autorizado
				elseif SA1->A1_XPED
					if cLocal == '1'
						cMsg+= '* Cliente requer ATENÇÃO'+CRLF+CRLF
					elseif cLocal == '2'
						cMsg+= '* Cliente requer PEDIDO DE COMPRA'+CRLF+CRLF
					endif
				
				elseif SA1->A1_XRA .and. FunName() == 'MATA415|LOJA701'
					cMsg+= '* Aceito somente com RECEBIMENTO ANTECIPADO'+CRLF+CRLF

				elseif SA1->A1_XCONTAB
					cMsg+= '* Será necessário a liberção da venda pelo CONTADOR'+CRLF+CRLF

				endif

			endif
			SA1->(dbCloseArea())

		endif

		aPedidos[nX][7]:= iif(lRet,'S','N')

	next nX 

	if !Empty(cMsg)
		DEFINE MSDIALOG oDlg TITLE "Validação Cliente" From 000,000 TO 350,400 Pixel
		@ 005,005 GET oMemo VAR cMsg MEMO SIZE 150,150 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		DEFINE SBUTTON FROM 005,165 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTER
	endif

return lRet

static function QImpPed(aPedidos)

    local   nX          as numeric,;
            lRet        as logical,;
            cNumNota    as char

    nX:= 0
    lRet:= .F.
    cNumNota:= ''

    for nX:= 1 to len(aPedidos)
        if aPedidos[nX][7] != 'N'
            if !empty(cNumNota)
                cNumNota+= '|'
            endif
            cNumNota+= aPedidos[nX][3]+aPedidos[nX][4]
        endif
    next nX

	if select('T01') > 0
		T01->(dbCloseArea())
	endif

	cQry := 'exec dbo.PR_MV05005A @FILIAL = "'+FWxFilial('SC5')+'", @NOTAS = "'+cNumNota+'"'

	tcquery cQry new alias 'T01'

	dbSelectArea('T01')
	T01->(dbGoTop())

	if T01->(eof())
        lRet:= .F.
		u_msgErro('Notas não encontrado!!!')
	else
        lRet:= .T.
    endif

return lRet

user function FIntPed(aPedidos)

	local   lRet        as logical

	local   aCabec      as array,;
			aLinha      as array,;
			aItens      as array,;
			cNumPed     as char,;
			cCodPgto    as char,;
			cCondPagto  as char,;
			cNumNotaAnt as char,;
			cSerieAnt   as char,;
			nItem       as numeric
			
	//iniciando as variaveis
	lRet:= .F.
	cNumPed:= ''
	cCodPgto:= ''
	cCondPagto:= ''
	cNumNotaAnt:= ''
	cSerieAnt:= ''

	if ValPed(@aPedidos)

		QImpPed(aPedidos)       // Abre a query novamente para poder considerar somente os pedidos validados

		aCabec := {}
		aItens := {}
		cNumPed:= getsx8num('SC5','C5_NUM')

		dbSelectArea('T01')
		T01->(dbGoTop())

		if T01->F2_COND == '999'
			cCodPgto:= '101'
		else
			cCodPgto:= T01->F2_COND
		endif
		cCondPagto:= posicione('SE4',1,FWxFilial('SE4')+cCodPgto,'E4_DESCRI')

		// Cabecalho
		aadd(aCabec,{'C5_NUM'       ,cNumPed                    ,nil})
		aadd(aCabec,{'C5_TIPO'		,'N'						,nil}) // Tipo de Pedido
		aadd(aCabec,{'C5_CLIENTE'	,T01->A1_COD    			,nil}) // Codigo do Cliente
		aadd(aCabec,{'C5_LOJACLI'	,T01->A1_LOJA               ,nil}) // Loja do Cliente
		aadd(aCabec,{'C5_XCLIENT'	,T01->A1_NREDUZ    			,nil}) // Codigo do Cliente
		aadd(aCabec,{'C5_XNOMCON'	,T01->A1_NREDUZ             ,nil}) // Loja do Cliente
		aadd(aCabec,{'C5_VEND1'		,T01->F2_VEND1				,nil}) // Vendedor 1
		aadd(aCabec,{'C5_XNVEND1'	,alltrim(T01->A3_NREDUZ)	,nil}) // Nome do Vendedor 1
		aadd(aCabec,{'C5_CONDPAG'	,cCodPgto				    ,nil}) // Condicao de pagamanto
		aadd(aCabec,{'C5_XDESCON'	,alltrim(cCondPagto)	    ,nil}) // Desc. Cond. Pagamento
		aadd(aCabec,{'C5_TPFRETE'	,T01->F2_TPFRETE			,nil})
		aadd(aCabec,{'C5_FRETE'	    ,T01->F2_FRETE			    ,nil})
		aadd(aCabec,{'C5_XVLTOT'    ,T01->C5_XVLTOT			    ,nil})
		nItem:= 0
		nTotal:= 0
		while !T01->(Eof())
			aLinha := {}
			nItem+=1
			aadd(aLinha,{'C6_ITEM'		,strZero(nItem,2)		,Nil})
			aadd(aLinha,{'C6_PRODUTO'	,T01->D2_COD    		,Nil})
			aadd(aLinha,{'C6_QTDVEN'	,T01->D2_QUANT			,Nil})
			aadd(aLinha,{'C6_PRCVEN'	,T01->D2_PRCVEN			,Nil})
			aadd(aLinha,{'C6_PRUNIT'	,T01->D2_PRCVEN			,Nil})
			aadd(aLinha,{'C6_DESCONT'	,0						,Nil})
			aadd(aLinha,{'C6_VALDESC'	,0						,Nil})
			aadd(aLinha,{'C6_OPER'		,T01->B1_XOPOER			,Nil})
			aadd(aItens,aLinha)

			if T01->F2_SERIE+T01->F2_DOC <> cSerieAnt+cNumNotaAnt
				if RecLock('Z50',.T.)
					Z50->Z50_FILIAL := FWxFilial('Z50')
					Z50->Z50_NUMPED := cNumPed
					Z50->Z50_SERINT := T01->F2_SERIE
					Z50->Z50_NFINT  := T01->F2_DOC
					Z50->(msUnlock())
				endif
			endif
			cNumNotaAnt:= T01->F2_DOC
			cSerieAnt:= T01->F2_SERIE

			T01->(dbSkip())
		enddo
		
		lMsErroAuto	:= .F.
		MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 3)

		if lMsErroAuto
			RollBackSX8()
			MostraErro()

			lRet	:= .F.
			T01->(dbCloseArea())
			return (lRet)

		else
			ConfirmSx8()
			lRet:= .T.

		endif

	endif
	Z50->(dbCloseArea())
	T01->(dbCloseArea())

return lRet


/*/
===============================================================================================================================
Programa----------: BscTit
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 15/07/2025
===============================================================================================================================
Descrição---------: Este programa serve retorna a chave do titulo na FK's
===============================================================================================================================
Uso---------------: FINANCEIRO
===============================================================================================================================
Parametros--------: RECNO
===============================================================================================================================
Retorno-----------: cChave =>> numero do titulo
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Financeiro
===============================================================================================================================
/*/
user Function BscTit(pRecno)

	local	cQry	as string,;
			cChave	as string

	cQry:= 'select FK7_CHAVE from FK7010 where FK7_IDDOC in (select FK1_IDDOC from FK1010 where FK1_IDFK1 in (select E5_IDORIG from SE5010 where R_E_C_N_O_ = '+cValToChar(pRecno)+'))'
    cQry := ChangeQuery(cQry)
    TCQuery cQry New Alias "TB01"
         
    TB01->(DbGoTop())
    if ! TB01->(EoF()) .and. !empty(TB01->FK7_CHAVE)
    	cChave	:= TB01->FK7_CHAVE
    endif
    TB01->(dbCloseArea())
   
return cChave

/*/
===============================================================================================================================
Programa----------: Conv2Unid
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 24/09/2025
===============================================================================================================================
Descrição---------: Este programa serve Converter para 1ª unidade
===============================================================================================================================
Uso---------------: FATURAMENTO
===============================================================================================================================
Parametros--------: RECNO
===============================================================================================================================
Retorno-----------: Segunda unidade
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Financeiro
===============================================================================================================================
/*/
user Function Conv2Unid(cProduto,nPrcVenda)

	local	nPrc		as float

	local	aArea		as object,;
			aAreaSB1	as object

	nPrc	:= 0

	aArea		:= getArea()
	aAreaSB1	:= SB1->(getArea())

	dbSelectArea('SB1')
	SB1->(dbSetOrder(1))
	SB1->(dbGoTop())
	if SB1->(dbSeek(xFilial('SB1')+cProduto))
		nPrc:= iif(SB1->B1_TIPCONV = 'M', nPrcVenda * SB1->B1_CONV, nPrcVenda / SB1->B1_CONV)
	endif
	SB1->(dbCloseArea())

	FWRestArea(aAreaSB1)
	FWRestArea(aArea)

return nPrc

/*/
===============================================================================================================================
Programa----------: Conv1Unid
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 03/10/2025
===============================================================================================================================
Descrição---------: Este programa serve Converter para 2ª unidade
===============================================================================================================================
Uso---------------: FATURAMENTO
===============================================================================================================================
Parametros--------: RECNO
===============================================================================================================================
Retorno-----------: Segunda unidade
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Financeiro
===============================================================================================================================
/*/
user Function Conv1Unid(cProduto,nPrcSegum)

	local	nPrc		as float

	local	aArea		as object,;
			aAreaSB1	as object

	nPrc	:= 0

	aArea		:= getArea()
	aAreaSB1	:= SB1->(getArea())

	dbSelectArea('SB1')
	SB1->(dbSetOrder(1))
	SB1->(dbGoTop())
	if SB1->(dbSeek(xFilial('SB1')+cProduto))
		nPrc:= iif(SB1->B1_TIPCONV = 'D', nPrcSegum * SB1->B1_CONV, nPrcSegum / SB1->B1_CONV)
	endif
	SB1->(dbCloseArea())

	FWRestArea(aAreaSB1)
	FWRestArea(aArea)

return nPrc

/*/
===============================================================================================================================
Programa----------: Stamps
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 16/06/2026
===============================================================================================================================
Descrição---------: Este programa serve para criar os campos S_T_A_M_P e I_N_S_D_T não estão sendo criados no banco de dados
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: cTabela -> nome da tabela a ser verificada
===============================================================================================================================
Retorno-----------: .T. -> Se os campos existem ou foram criados com sucesso / .F. se houve falha
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODAA EMPRESA
===============================================================================================================================
/*/
user Function Stamps(cTabela)

	local	lRet	as logical

	lRet:= .F.

	tClink()
	
	tCConfig('SETUSERROWSTAMP=ON')
	tCConfig('SETAUTOSTAMP=ON')

	tcRefresh(cTabela)

	tCConfig('SETUSERROWSTAMP=OFF')
	tCConfig('SETAUTOSTAMP=OFF')

	TcUnlink()

return lRet


/*/
===============================================================================================================================
Programa----------: AltParam
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 16/06/2026
===============================================================================================================================
Descrição---------: Este programa serve para alterar um parametro do sistema
===============================================================================================================================
Uso---------------: TODO SISTEMA
===============================================================================================================================
Parametros--------: pParametr -> nome do parametro a ser alterado
===============================================================================================================================
Retorno-----------: 
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TODAA EMPRESA
===============================================================================================================================
/*/
user function AltParam(pParametro)

	local	oDlg		as object,;
			oButton1	as object,;
			oButton2 	as object,;
			oSay1 		as object,;
			oGet1 		as object

	local	nOpcao		as numeric,;
			cDescr		as caracter,;
			cTipo		as caracter,;
			vGet1		as variant,;
			cPicture	as caracter

	DescParam(pParametro, @cDescr, @cTipo, @vGet1, @cPicture)

	SetPrvt('oDlg1','oSay1','oSBtnOk','oSBtnCan','oMGet1')

	define msdialog oDlg title 'Alterar Parametro: '+pParametro from 000,000 to 145,360 colors 0,16777215 pixel
		@003,004 say oSay1 prompt @cDescr size 292,030 of oDlg colors 0,16777215 pixel

		if cTipo $ 'C|N|D'
			@024,004 msget oGet1 var vGet1 picture cPicture size 090,008 of oDlg PIXEL
		
		elseif cTipo == 'L'
			@024,004 checkbox oGet1 var vGet1 prompt 'Ativo (.T.)' size 052,008 of oDlg PIXEL
		
		endif

		@036,075 button oButton1 prompt "Confirmar" size 037,012 of oDlg action (oDlg:End(),nOpcao := 1) pixel
		@036,114 button oButton2 prompt "Cancelar" size 037,012 of oDlg action (oDlg:End(),nOpcao := 2) pixel
	activate msdialog oDlg

	if nOpcao = 1
		putmv(pParametro, vGet1)
		u_msgInforma('Parâmetro alterado com sucesso!','')
	endif

return

/*/
===============================================================================================================================
Programa----------: DescParam
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 30/12/2018
===============================================================================================================================
Descrição---------: Este programa serve para retornar com o titulod o campo na SX3
===============================================================================================================================
Uso---------------: geral
===============================================================================================================================
Parametros--------: cCampo	-> nome do campo a ser pesquisado
===============================================================================================================================
Retorno-----------: lRet -> titulo do campo informado
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Geral
===============================================================================================================================
/*/
static function DescParam(pParam, pDescr, pTipo, pConteudo, pPicture)

	local cValorAtual := GetMv(pParam)

	dbSelectArea('SX6')
	SX6->(dbSetOrder(1))
	SX6->(dbGoTop())
	if (SX6->(dbSeek(fwxFilial('SX6')+pParam)))	
		pDescr		:= SX6->X6_DESCRIC+CRLF+;
						SX6->X6_DESC1+CRLF+;
						SX6->X6_DESC2
		pTipo		:= SX6->X6_TIPO

		if pTipo == 'C'
			pConteudo	:= iif(Empty(cValorAtual), SX6->X6_CONTEUD, cValorAtual)
			pPicture	:= '@!'
		
		elseif pTipo == 'N'
			pConteudo	:= iif(Empty(cValorAtual), nVal(SX6->X6_CONTEUD), nVal(cValorAtual))
			pPicture	:= '@E 999,999,999.99'
		
		elseif pTipo == 'D'
			pConteudo	:= iif(Empty(cValorAtual), ctod(SX6->X6_CONTEUD), ctod(cValorAtual))
			pPicture	:= '@D 99/99/9999'
		
		elseif pTipo == 'L'
			pConteudo	:= iif(Empty(cValorAtual), SX6->X6_CONTEUD, cValorAtual)
			pPicture	:= ''

		endif
	
	else
		pConteudo := cValorAtual
	
	endif
 
return nil

/*/
===============================================================================================================================
Programa----------: PesqProc
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 10/07/2026
===============================================================================================================================
Descrição---------: Este programa serve para Consultar uma tabela por procedure
===============================================================================================================================
Uso---------------: geral
===============================================================================================================================
Parametros--------: cAlias		-> nome do Objeto tabela a se usado
					cProcedure	-> nome da procedure a ser pesquisa
					cWhere		-> clausula where e ser aplicado
===============================================================================================================================
Retorno-----------: nil
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Geral
===============================================================================================================================
/*/
user function PesqProc(cAlias,cProcedure,cWhere)
	local cQry as char

	if select((cAlias)) <> 0
		(cAlias)->(dbCloseArea())
	endif

    cQry := "exec dbo."+cProcedure+" "+cWhere"
    tcquery cQry new alias (cAlias)

return
