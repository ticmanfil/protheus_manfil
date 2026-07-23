#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'colors.ch'
#include 'rptdef.ch'
#include 'fwprintsetup.ch'
#include 'topconn.ch'

//Alinhamentos horizontais
#define PADHL 0
#define PADHR 1
#define PADHC 2
#define PADHJ 3

//Alinhamentos verticais
#define PADVC 0
#define PADVS 1
#define PADVI 2


/*/
===============================================================================================================================
Programa----------: RL05001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 10/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para IMPRIMIR O PEDIDO DE VENDA PADHRao MANFIL
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
===============================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
Renato Fuzes| 04/09/2018| Incluido impressao de retira qdo o pedido for do tipo R senao continua imprimindo o endereco de entrega																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
Renato Fuzes| 10/01/2019| Considerar a data e hora da impressao do servidor e nao a data que foi logado no sistema																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/
user function RL05001(pNumPed,pNumDoc,pImp,pQtdVias,pSerie)

	local	lImprimiu	as logical

	local	x			as numeric

	default pNumped	:= SC5->C5_NUM,;
			pNumDoc := SC5->C5_NOTA,;
			pImp    := ''
			pSerie	:= SC5->C5_SERIE

	lImprimiu := .F.

	for x:=1 to val(pQtdVias)
		lImprimiu := imprimir(pNumPed,pNumDoc,pImp,x,@lImprimiu,pSerie)
		if !lImprimiu
			exit
		endif
	endfor

return lImprimiu

static function imprimir(pNumPed,pNumDoc,pImp,pVia,lImprimiu,pSerie)
	local	cArquivo	as char

	cArquivo:= 'pedido' + alltrim(pNumPed) + '_' + cValToChar(pVia) + '_' + dtos(date()) + '_' + StrTran(time(),':','-')

	processa({|| ImpVia(cArquivo,pNumPed,pNumDoc,pImp,pVia,@lImprimiu,pSerie)},'Imprindo pedido (' + alltrim(pNumPed) + ') via ' + alltrim(cValToChar(pVia)),'')
	
return lImprimiu

static function MontaTMP(pNumDoc,pSerie)
	local	cQry		as char

	if select('TMP')<>0
		TMP->(dbCloseArea())
	endif

	cQry := 'exec PR_RL05001 @FILIAL = "'+fwxFilial('SD2')+'", @NUMDOC = "'+pNumDoc+'", @SERIE = "'+pSerie+'"'
	tcquery cQry new alias 'TMP'

	dbSelectArea('TMP')
	TMP->(dbGoTop())

return nil

static function MontaTMP1(pNumDoc,pSerie)
	local	cQry		as char

	if select('TMP1')<>0
		TMP1->(dbCloseArea())
	endif

	cQry := 'exec PR_RL05001P @FILIAL = "'+fwxFilial('SE1')+'", @NUMDOC = "'+pNumDoc+'", @SERIE = "'+pSerie+'"'
	tcquery cQry new alias 'TMP1'

	dbSelectArea('TMP1')
	TMP1->(dbGoTop())

return nil

static function ImpVia(cArquivo,pNumPed,pNumDoc,pImp,pVia,lImprimiu,pSerie)

	local	oPrinter	as object,;
			oFont12		as object

	local	nLinBox		as numeric,;
			nColIni		as numeric,;
			nColFim		as numeric,;
			nEspaco		as numeric

	/*			FWMSPrinter():New(
								cFilePrintert ,
								IMP_PDF, 
								lAdjustToLegacy, 
								cPathInServer, 
								lDisabeSetup , 
								lTReport, 
								@oPrintSetup, 
								cPrinter, 
								lServer, 
								lPDFAsPNG, 
								lRaw, 
								lViewPDF, 
								nQtdCopy )
	*/
	//if u_estaGrp(__CUSERID,'000000')	// o usuário logado é do grupo de administrador?
	//	oPrinter:= fwmsPrinter():New(;
	//							cArquivo;		//no do arquivo a ser gerado
	//							,IMP_PDF;		//tipo de impressão, pode ser IMP_PDF, IMP_SPOOL
	//							,.F.;			//ajustar para legados, se for .T. ajusta a impressão para ficar igual a impressão feita pelos legados, se for .F. utiliza o framework de impressão do protheus
	//							,getTempPath();	//caminho onde o arquivo será salvo, pode ser um caminho local ou de rede, ex: 'C:\temp' ou '\\servidor\pasta'
	//							,.T.;			//desabilitar tela de configuração da impressão, se for .T. a tela de configuração não será exibida e a impressão será feita com as configurações PADHRão do sistema, se for .F. a tela de configuração será exibida para o usuário escolher as opções de impressão
	//							,.F.;			//imprimir relatório de teste, se for .T. o framework de impressão do protheus irá imprimir um relatório de teste para verificar se a configuração da impressão está correta, se for .F. a impressão será feita normalmente
	//							,;				//objeto do tipo FWPrintSetup para configurar a impressão, se for passado um objeto do tipo FWPrintSetup o framework de impressão do protheus irá utilizar as configurações definidas no objeto, se for .F. o framework de impressão do protheus irá utilizar as configurações PADHRão do sistema
	//							,pImp;			//nome da impressora, se for passado o nome de uma impressora instalada no sistema a impressão será feita nessa impressora, se for .F. a impressão será feita na impressora PADHRão do sistema
	//							,.F.;			//imprimir no servidor, se for .T. a impressão será feita no servidor onde o protheus está instalado, se for .F. a impressão será feita na máquina do usuário que está executando o processo de impressão
	//							,.F.;			//gerar PDF como PNG, se for .T. o framework de impressão do protheus irá gerar o arquivo PDF como um arquivo PNG, se for .F. o arquivo será gerado no formato PDF
	//							,.F.;			//imprimir em modo RAW, se for .T. a impressão será feita em modo RAW, se for .F. a impressão será feita em modo normal
	//							,.T.;			//visualizar PDF após a geração, se for .T. o framework de impressão do protheus irá abrir o arquivo PDF gerado para visualização, se for .F. o arquivo PDF será gerado mas não será aberto para visualização
	//							,1;				//quantidade de vias a serem impressas, se for passado um valor numérico o framework de impressão do protheus irá imprimir a quantidade de vias especificada, se for .F. a impressão será feita com a quantidade de vias definida nas configurações da impressora
	//							)
	//else
		oPrinter:= fwmsPrinter():New(;
								cArquivo;		//no do arquivo a ser gerado
								,IMP_SPOOL;		//tipo de impressão, pode ser IMP_PDF, IMP_SPOOL
								,.F.;			//ajustar para legados, se for .T. ajusta a impressão para ficar igual a impressão feita pelos legados, se for .F. utiliza o framework de impressão do protheus
								,getTempPath();	//caminho onde o arquivo será salvo, pode ser um caminho local ou de rede, ex: 'C:\temp' ou '\\servidor\pasta'
								,.T.;			//desabilitar tela de configuração da impressão, se for .T. a tela de configuração não será exibida e a impressão será feita com as configurações PADHRão do sistema, se for .F. a tela de configuração será exibida para o usuário escolher as opções de impressão
								,.F.;			//imprimir relatório de teste, se for .T. o framework de impressão do protheus irá imprimir um relatório de teste para verificar se a configuração da impressão está correta, se for .F. a impressão será feita normalmente
								,;				//objeto do tipo FWPrintSetup para configurar a impressão, se for passado um objeto do tipo FWPrintSetup o framework de impressão do protheus irá utilizar as configurações definidas no objeto, se for .F. o framework de impressão do protheus irá utilizar as configurações PADHRão do sistema
								,pImp;			//nome da impressora, se for passado o nome de uma impressora instalada no sistema a impressão será feita nessa impressora, se for .F. a impressão será feita na impressora PADHRão do sistema
								,.F.;			//imprimir no servidor, se for .T. a impressão será feita no servidor onde o protheus está instalado, se for .F. a impressão será feita na máquina do usuário que está executando o processo de impressão
								,.F.;			//gerar PDF como PNG, se for .T. o framework de impressão do protheus irá gerar o arquivo PDF como um arquivo PNG, se for .F. o arquivo será gerado no formato PDF
								,.F.;			//imprimir em modo RAW, se for .T. a impressão será feita em modo RAW, se for .F. a impressão será feita em modo normal
								,.F.;			//visualizar PDF após a geração, se for .T. o framework de impressão do protheus irá abrir o arquivo PDF gerado para visualização, se for .F. o arquivo PDF será gerado mas não será aberto para visualização
								,1;				//quantidade de vias a serem impressas, se for passado um valor numérico o framework de impressão do protheus irá imprimir a quantidade de vias especificada, se for .F. a impressão será feita com a quantidade de vias definida nas configurações da impressora
								)
	//endif
	oPrinter:SetPortrait()				//formato retrato
	oPrinter:setPaperSize(9) 			//A4
//	oPrinter:setMargin(60,60,60,60)		//margem de 1 cm em cada lado
	oPrinter:setMargin(60,00,60,00)		//margem de 1 cm em cada lado (nEsquerda, nSuperior, nDireita, nInferior )

	//definir a fonte a ser utilizada na impressão
	oFont12	:= TFontEx():New(oPrinter,'Arial',12,12,.F.,.T.,.F.)
	oPrinter:setFont(oFont12:oFont)		//fonte Arial, tamanho 12, normal

	//Busca dados para impressao
	MontaTMP(pNumDoc,pSerie)
	MontaTMP1(pNumDoc,pSerie)

	nLinBox := 020
	nColIni := 010
	nColFim := 560
	nEspaco := 006

	oPrinter:StartPage()

	if pVia = 1
		ImpCabec(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpItens(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpParecelas(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpCanhoto(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpNP(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
	
	elseif pVia = 2
		ImpCabec(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpItens(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpParecelas(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpCanhoto(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
	
	elseif pVia = 3
		ImpCabec(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpItens(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpParecelas(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)
		ImpCanhoto(@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco,pVia)

	endif

	oPrinter:EndPage()
//	lImprimiu	:= oPrinter:Print()
	lImprimiu	:= oPrinter:Preview()

	if oPrinter # nil
		freeobj(oPrinter)
	endif
	oPrinter:= nil

return lImprimiu

static function ImpCabec(oPrinter,nLinBox,nColIni,nColFim,nEspaco,pVia)

	local	cNumNF		as char,;
			cNumPed		as char,;
			cPessoa		as char,;
			cCGC		as char,;
			cInscr		as char,;
			cCliente	as char,;
			cConsumidor	as char,;
			cEmail		as char,;
			cTelefone	as char,;
			cCelular	as char,;
			cDtEmissao	as char

	local	cEndereco	as char,;
			cCodMun		as char,;
			cMunic		as char,;
			cBairro		as char,;
			cCep		as char,;
			cUF			as char,;
			cQtdVias	as char,;
			cImpresso	as char

	local	cEndEntr1	as char,;
			cEndEntr2	as char

	local	cTexto		as char,;
			nLinAtual	as numeric

	local	oFont05		as object,;
			oFont07		as object,;
			oFont08N	as object,;
			oFont13N	as object,;
			oFont16N	as object,;
			oBrush		as object

	oFont05 	:= TFontEx():New(oPrinter,"Arial",05,05,.F.,.T.,.F.)
	oFont07		:= TFontEx():New(oPrinter,"Arial",07,07,.F.,.T.,.F.)
	oFont08N 	:= TFontEx():New(oPrinter,"Arial",08,08,.T.,.T.,.F.)
	oFont13N 	:= TFontEx():New(oPrinter,"Arial",13,13,.T.,.T.,.F.)
	oFont16N 	:= TFontEx():New(oPrinter,"Arial",16,16,.T.,.T.,.F.)

	oBrush   	:= TBrush():New( , CLR_HGRAY)

	//dados do cliente
	cPessoa		:= alltrim(TMP->PESSOA)
	cCGC		:= iif(alltrim(cPessoa) == 'J', transform(alltrim(TMP->CGC),'@R NN.NNN.NNN/NNNN-99'), transform(alltrim(TMP->CGC),'@R NNN.NNN.NNN-99'))
	cInscr		:= alltrim(TMP->INSCRICAO)
	cCliente	:= alltrim(TMP->CLIENTE) + ' - ' + alltrim(TMP->CODCLI) + '-' + alltrim(TMP->LOJA)
	cConsumidor	:= alltrim(TMP->NCONSU)
	cEmail		:= alltrim(TMP->EMAIL)
	cTelefone	:= alltrim(TMP->TELEFONE)
	cCelular	:= alltrim(TMP->CELULAR)

	//dados do endereço e informações de entrega
	cNumPed		:= alltrim(TMP->NUMPED)
	cNumNF		:= alltrim(TMP->NF)+'-'+alltrim(TMP->SERIE)
	cEndereco	:= alltrim(TMP->ENDERECO)
	cCodMun		:= alltrim(TMP->CODMUN)
	cMunic		:= alltrim(TMP->MUNICIPIO)
	cBairro		:= alltrim(TMP->BAIRRO)
	cCep		:= transform(alltrim(TMP->CEP),'@R 99999-999')
	cUF			:= alltrim(TMP->UF)
	cQtdVias	:= alltrim(TMP->QTDVIAS)
	cImpresso	:= alltrim(TMP->IMPRESSO)
	cDtEmissao	:= TMP->DTEMISSAO

	///dados de entrega
	cEndEntr1	:= substring(alltrim(TMP->ENDENT),1,80)
	cEndEntr2	:= substring(alltrim(TMP->ENDENT),81,80)

	nLinBox += 000

	//01 - IMPRIMIR NUMERO DO DOC DE SAIDA E VIA DE IMPRESSAO
	oPrinter:box(nLinBox, nColIni, nLinBox + 23, nColFim) // caixa cidade e numero da nota
	if pVia != 3
		oPrinter:line(nLinBox,240,nLinBox+23,240) // linha horizontal separando cidade e numero da nota
		oPrinter:fillRect({nLinBox+1, nColFim-150, nLinBox+22, nColFim-1}, oBrush, '-2') //Caixa da Via

		cTexto		:= 'ARAXÁ-MG:       '+cDtEmissao
		oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont08N:oFont, 240, 23, , PADHC, PADVC)

		cTexto		:= 'Nº:   ' + cNumNF
		oPrinter:sayAlign(nLinBox, nColIni+241, cTexto, oFont13N:oFont, 170, 23, ,PADHC, PADVC)

		cTexto		:= 'Nº Pedido: ' + cNumPed
		oPrinter:sayAlign(nLinBox, nColIni+241, cTexto, oFont05:oFont, 170, 23, , PADHC, PADVI)

		cTexto		:= cValToChar(pVia)+'º VIA'
		oPrinter:sayAlign(nLinBox, nColFim-150, cTexto, oFont16N:oFont, 150, 23, CLR_WHITE, PADHC, PADVC)

	else
		oPrinter:line(nLinBox,nColFim-150,nLinBox+23,nColFim-150) //Caixa da Via

		cTexto		:= 'RESUMO DO PEDIDO DE VENDA - Nº: ' + cNumNF
		oPrinter:sayAlign(nLinBox, nColIni+1 , cTexto, oFont08N:oFont, 360, 23, ,PADHC, PADVC)

		cTexto		:= 'Nº Pedido: '+cNumPed
		oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont05:oFont, 360, 23, , PADHC, PADVI)

		cTexto		:= cValToChar(pVia)+'º VIA'+' - CLIENTE'
		oPrinter:sayAlign(nLinBox, nColFim-150, cTexto, oFont16N:oFont, 150, 23, , PADHC, PADVC)

	endif

	//02 - IMPRIMIR DADOS DO CLIENTE E DEMAIS INFORMAÇÕES
	nLinBox	:= nLinBox + 23
	nLinAtual := nLinBox

	//imprimir a data e hora da impressão e o nome do usuário que imprimiu o documento
	if cImpresso != 'S'
		cTexto:= 'Impressão: ' + cUserName + ' ' + dtoc(date()) + ' ' + substr(time(),1,8) + ' - Vias: ' + alltrim(cQtdVias)
	else
		cTexto:= 'Reimpressão: ' + cUserName + ' ' + dtoc(date()) + ' ' + substr(time(),1,8) + ' - Vias: ' + alltrim(cQtdVias)
	endif
	oPrinter:say(nLinAtual+=4,nColFim-151,cTexto,oFont05:oFont)

	oPrinter:box(nLinAtual+=1, nColIni, nLinAtual+100, nColFim) // caixa endereço

	//codigo de barras
	cTexto:= cNumNF
	oPrinter:code128(nLinAtual+=2,nColFim-140,cTexto,1,30,.F.)

	//dados do cliente
	cTexto:= iif(alltrim(cPessoa) == 'J', 'CNPJ: ', 'CPF: ')
	oPrinter:say(nLinAtual+=5,nColIni+1,cTexto,oFont07:oFont)
	cTexto:= cCGC
	oPrinter:say(nLinAtual,nColIni+37,cTexto,oFont08N:oFont)

	cTexto:= 'Inscrição Estadual: '
	oPrinter:say(nLinAtual,nColIni+150,cTexto,oFont07:oFont)
	cTexto:= cInscr
	oPrinter:say(nLinAtual,nColIni+215,cTexto,oFont08N:oFont)

	cTexto:= 'Data Faturamento: '
	oPrinter:say(nLinAtual,nColIni+300,cTexto,oFont07:oFont)
	cTexto:= cDtEmissao
	oPrinter:say(nLinAtual,nColIni+365,cTexto,oFont08N:oFont)

	cTexto:= 'Cliente: '
	oPrinter:say(nLinAtual+=12,nColIni+1,cTexto,oFont07:oFont)
	cTexto:= cCliente
	oPrinter:say(nLinAtual,nColIni+37,cTexto,oFont08N:oFont)
	cTexto:= cConsumidor
	oPrinter:say(nLinAtual+=12,nColIni+37,cTexto,oFont08N:oFont)

	cTexto:= 'Endereço: '
	oPrinter:say(nLinAtual+=12,nColIni+1,cTexto,oFont07:oFont)
	cTexto:= cEndereco + ' - ' + cBairro + ' - ' + cMunic + ' - ' + cUF + ' - ' + cCep
	oPrinter:say(nLinAtual,nColIni+37,cTexto,oFont08N:oFont)

	cTexto:= 'E-mail: '
	oPrinter:say(nLinAtual+=12,nColIni+1,cTexto,oFont07:oFont)
	cTexto:= alltrim(cEmail)
	oPrinter:say(nLinAtual,nColIni+37,cTexto,oFont08N:oFont)

	//03 - IMPRIMIR DADOS DE ENTREGA
	cTexto:= 'Local de Entrega: '
	oPrinter:say(nLinAtual+=12,nColIni+1,cTexto,oFont07:oFont)
	cTexto:= cEndEntr1
	oPrinter:say(nLinAtual+=12,nColIni+37,cTexto,oFont08N:oFont)
	cTexto:= cEndEntr2
	oPrinter:say(nLinAtual+12,nColIni+37,cTexto,oFont08N:oFont)

	cTexto:= 'Telefone: '
	oPrinter:say(nLinAtual,nColIni+420,cTexto,oFont07:oFont)
	cTexto:= alltrim(cTelefone)
	oPrinter:say(nLinAtual,nColIni+455,cTexto,oFont08N:oFont)

	cTexto:= 'Celular: '
	oPrinter:say(nLinAtual+=12,nColIni+420,cTexto,oFont07:oFont)
	cTexto:= alltrim(cCelular)
	oPrinter:say(nLinAtual,nColIni+455,cTexto,oFont08N:oFont)

return nil

static function ImpItens(oPrinter,nLinBox,nColIni,nColFim,nEspaco,pVia)

	local	cTexto		as char

	local	oFont05		as object,;
			oFont07		as object,;
			oFont07N	as object,;
			oFont08		as object,;
			oFont24N	as object,;
			oBrush		as object

	local	cVendedor	as char,;
			cRegiao		as char,;
			nID			as numeric,;
			cCodProd	as char,;
			nQtd		as decimal,;
			cUM			as char,;
			cDescricao	as char,;
			nVlrUnit	as decimal,;
			nDesconto	as decimal,;
			nVlrTot		as decimal

	local	nTPeso		as decimal,;
			nTValorProd	as decimal,;
			nTValor		as decimal,;
			nTDesconto	as decimal,;
			nTFrete		as decimal,;
			nTICMSRet	as decimal,;
			nTIpi		as decimal,;
			nLargProd	as decimal

	local	nPosicaoMsg	as char,;
			nQtdItens	as numeric

	oFont05 	:= TFontEx():New(oPrinter,"Arial",05,05,.F.,.T.,.F.)
	oFont07		:= TFontEx():New(oPrinter,"Arial",07,07,.F.,.T.,.F.)
	oFont07N	:= TFontEx():New(oPrinter,"Arial",07,07,.T.,.T.,.F.)
	oFont08		:= TFontEx():New(oPrinter,"Arial",08,08,.F.,.T.,.F.)
	oFont24N	:= TFontEx():New(oPrinter,"Arial",24,24,.T.,.T.,.F.)

	oBrush  := TBrush():New( , CLR_HGRAY)

	nLinBox	+= 102

	//quantidade de itens maximo no pedido de venda
	nQtdItens := 31

	//tamanho da descricao do produto para caber dentro do espaço reservado para a descrição no layout, caso a descrição seja maior que esse tamanho, ela será truncada e não irá imprimir o nome completo do produto
	nLargProd := 60

	cVendedor	:= alltrim(TMP->VENDEDOR)
	cRegiao		:= alltrim(TMP->REGIAO)
	nID			:= 0
	nTPeso		:= 0.00
	nTIPI		:= 0.00
	nTICMSRet	:= 0.00
	nTValor		:= 0.00
	nTDesconto	:= 0.00
	nTValorProd	:= 0.00
	nTFrete		:= 0.00
	nTISSRet	:= 0.00

	//cabecalho dos itens dos produtos vendidos
	oPrinter:box(nLinBox, nColIni, nLinBox + 300, nColFim)

	//Mensagem de Carregamento Invalido para a segunda e terceira via
	if pVia = 2 .or. pVia = 3
		nPosicaoMsg	:= nLinBox + 135
		cTexto	:= '*** VIA INVÁLIDA PARA CARREGAMENTO ***'
		oPrinter:sayAlign(nPosicaoMsg, nColIni, cTexto, oFont24N:oFont, nColFim,,,2,PADHC)
	endif

	if pVia != 3
		//linha das colunas dos itens
		oPrinter:line(nLinBox,nColIni+38,nLinBox+300,nColIni+38)
		oPrinter:line(nLinBox,nColIni+51,nLinBox+300,nColIni+51)
		oPrinter:line(nLinBox,nColIni+105,nLinBox+300,nColIni+105)
		oPrinter:line(nLinBox,nColIni+135,nLinBox+300,nColIni+135)
		oPrinter:line(nLinBox,nColIni+429,nLinBox+300,nColIni+429)
		oPrinter:line(nLinBox,nColIni+467,nLinBox+300,nColIni+467)
		oPrinter:line(nLinBox,nColIni+507,nLinBox+300,nColIni+507)

		//titulos das colunas dos itens
		cTexto:= 'CÓDIGO'
		oPrinter:say(nLinBox+=8,nColIni+5,cTexto,oFont07:oFont)
		cTexto:= 'BX'
		oPrinter:say(nLinBox,nColIni+41,cTexto,oFont07:oFont)
		cTexto:= 'QTD.'
		oPrinter:say(nLinBox,nColIni+64,cTexto,oFont07:oFont)
		cTexto:= 'UNID.'
		oPrinter:say(nLinBox,nColIni+111,cTexto,oFont07:oFont)
		cTexto:= 'DESCRIÇÃO DAS MERCADORIAS'
		oPrinter:say(nLinBox,nColIni+206,cTexto,oFont07:oFont)
		cTexto:= 'VLR. UNIT.'
		oPrinter:say(nLinBox,nColIni+431,cTexto,oFont07:oFont)
		cTexto:= 'VLR. DESC.'
		oPrinter:say(nLinBox,nColIni+469,cTexto,oFont07:oFont)
		cTexto:= 'VLR. TOTAL'
		oPrinter:say(nLinBox,nColIni+509,cTexto,oFont07:oFont)

		//linha horizontal abaixo do cabeçalho dos itens
		oPrinter:line(nLinBox+=5,nColIni,nLinBox,nColFim)

		//imprimir os itens do pedido de venda
		//nLinBox += 6
		while !TMP->(eof()) .and. nID <= nQtdItens	//imprime no máximo 35 itens por via, se tiver mais que isso, o restante será impresso na próxima via
			nID			+= 1
			cCodProd 	:= alltrim(TMP->PROD)
			nQtd		:= TMP->QTD
			cUM			:= alltrim(TMP->UM)
			cDescricao 	:= alltrim(TMP->DESCRICAO)
			nVlrUnit 	:= TMP->VLRUNIT
			nDesconto 	:= TMP->DESCONTO
			nVlrTot		:= TMP->VLRTOT - nDesconto

			nTPeso		+= TMP->PESO
			nTValorProd	+= TMP->VLRTOT
			nTDesconto	+= nDesconto
			nTFrete		+= TMP->FRETE
			nTICMSRet	+= TMP->ICMSRET
			nTIPI		+= TMP->IPI
			if TMP->RECISS == '1'
				nTISSRet	+= TMP->VALISS
			endif

			nTValor		:= nTValorProd + nTFrete + nTIPI + nTICMSRet - nTDesconto

			cTexto	:= cCodProd
			oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont08:oFont, 040, , , PADHL, )
			
			cTexto	:= '__'
			oPrinter:sayAlign(nLinBox, nColIni+36, cTexto, oFont08:oFont, 020, , , PADHC, )

			cTexto	:= transform(nQtd, '@E 999,999,999.99')
			oPrinter:sayAlign(nLinBox, nColIni+59, cTexto, oFont08:oFont, 044, , , PADHR, )
			
			cTexto	:= cUM
			oPrinter:sayAlign(nLinBox, nColIni+110, cTexto, oFont08:oFont, 025, , , PADHC, )
			
			cTexto	:= cDescricao
			oPrinter:sayAlign(nLinBox, nColIni+138, cTexto, oFont08:oFont, 300, , , PADHL, )
			
			cTexto	:= transform(nVlrUnit, '@E 999,999,999.99')
			oPrinter:sayAlign(nLinBox, nColIni+417, cTexto, oFont08:oFont, 040, , , PADHR, )
			
			cTexto	:= transform(nDesconto, '@E 999,999,999.99')
			oPrinter:sayAlign(nLinBox, nColIni+465, cTexto, oFont08:oFont, 040, , , PADHR, )
			
			cTexto	:= transform(nVlrTot, '@E 999,999,999.99')
			oPrinter:sayAlign(nLinBox, nColIni+507, cTexto, oFont08:oFont, 040, , , PADHR, )
			
			if len(alltrim(TMP->DESCRICAO)) > nLargProd
				nLinBox += 16
				nID		+= 1
			else
				nLinBox += 8
			endif
			TMP->(dbSkip())
		end

	else
		if cRegiao = 'E'
			//linha das colunas dos itens
			oPrinter:line(nLinBox,nColIni+38,nLinBox+300,nColIni+38)
			oPrinter:line(nLinBox,nColIni+105,nLinBox+300,nColIni+105)
			oPrinter:line(nLinBox,nColIni+135,nLinBox+300,nColIni+135)
			oPrinter:line(nLinBox,nColIni+509,nLinBox+300,nColIni+509)

			//titulos das colunas dos itens
			cTexto:= 'CÓDIGO'
			oPrinter:say(nLinBox+=8,nColIni+5,cTexto,oFont07:oFont)

			cTexto:= 'QTD.'
			oPrinter:say(nLinBox,nColIni+64,cTexto,oFont07:oFont)

			cTexto:= 'UNID.'
			oPrinter:say(nLinBox,nColIni+111,cTexto,oFont07:oFont)

			cTexto:= 'DESCRIÇÃO DAS MERCADORIAS'
			oPrinter:say(nLinBox,nColIni+206,cTexto,oFont07:oFont)

			cTexto:= 'VLR. TOTAL'
			oPrinter:say(nLinBox,nColIni+509,cTexto,oFont07:oFont)

			//linha horizontal abaixo do cabeçalho dos itens
			oPrinter:line(nLinBox+=5,nColIni,nLinBox,nColFim)

			//imprimir os itens do pedido de venda
			//nLinBox += 6
			while !TMP->(eof()) .and. nID <= nQtdItens	//imprime no máximo 35 itens por via, se tiver mais que isso, o restante será impresso na próxima via
				nID			+= 1
				cCodProd 	:= alltrim(TMP->PROD)
				nQtd		:= TMP->QTD
				cUM			:= alltrim(TMP->UM)
				cDescricao 	:= alltrim(TMP->DESCRICAO)
				nVlrUnit 	:= TMP->VLRUNIT
				nDesconto 	:= TMP->DESCONTO
				nVlrTot		:= TMP->VLRTOT - nDesconto

				nTPeso		+= TMP->PESO
				nTValorProd	+= TMP->VLRTOT
				nTDesconto	+= nDesconto
				nTFrete		+= TMP->FRETE
				nTICMSRet	+= TMP->ICMSRET
				nTIPI		+= TMP->IPI
				if TMP->RECISS == '1'
					nTISSRet	+= TMP->VALISS
				endif

				nTValor		:= nTValorProd + nTFrete + nTIPI + nTICMSRet - nTDesconto

				cTexto	:= cCodProd
				oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont07:oFont, 040, , , PADHL, )
				
				cTexto	:= transform(nQtd, '@E 999,999,999.99')
				oPrinter:sayAlign(nLinBox, nColIni+59, cTexto, oFont07:oFont, 044, , , PADHR, )
				
				cTexto	:= cUM
				oPrinter:sayAlign(nLinBox, nColIni+110, cTexto, oFont07:oFont, 025, , , PADHC, )
				
				cTexto	:= cDescricao
				oPrinter:sayAlign(nLinBox, nColIni+138, cTexto, oFont07:oFont, 300, , , PADHL, )
				
				cTexto	:= transform(nVlrTot, '@E 999,999,999.99')
				oPrinter:sayAlign(nLinBox, nColIni+507, cTexto, oFont07:oFont, 040, , , PADHR, )
				
				nLinBox += 8
				TMP->(dbSkip())
			end
		else
			//linha das colunas dos itens
			oPrinter:line(nLinBox,nColIni+38,nLinBox+300,nColIni+38)

			//titulos das colunas dos itens
			cTexto:= 'CÓDIGO'
			oPrinter:say(nLinBox+=8,nColIni+5,cTexto,oFont07:oFont)

			cTexto:= 'DESCRIÇÃO DAS MERCADORIAS'
			oPrinter:say(nLinBox,nColIni+43,cTexto,oFont07:oFont)

			//linha horizontal abaixo do cabeçalho dos itens
			oPrinter:line(nLinBox+=5,nColIni,nLinBox,nColFim)

			//imprimir os itens do pedido de venda
			//nLinBox += 6
			while !TMP->(eof()) .and. nID <= nQtdItens	//imprime no máximo 35 itens por via, se tiver mais que isso, o restante será impresso na próxima via
				nID			+= 1
				cCodProd 	:= alltrim(TMP->PROD)
				nQtd		:= TMP->QTD
				cUM			:= alltrim(TMP->UM)
				cDescricao 	:= alltrim(TMP->DESCRICAO)
				nVlrUnit 	:= TMP->VLRUNIT
				nDesconto 	:= TMP->DESCONTO
				nVlrTot		:= TMP->VLRTOT - nDesconto

				nTPeso		+= TMP->PESO
				nTValorProd	+= TMP->VLRTOT
				nTDesconto	+= nDesconto
				nTFrete		+= TMP->FRETE
				nTICMSRet	+= TMP->ICMSRET
				nTIPI		+= TMP->IPI
				if TMP->RECISS == '1'
					nTISSRet	+= TMP->VALISS
				endif

				nTValor		:= nTValorProd + nTFrete + nTIPI + nTICMSRet - nTDesconto

				cTexto	:= cCodProd
				oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont07:oFont, 040, , , PADHL, )
				
				cTexto	:= cDescricao
				oPrinter:sayAlign(nLinBox, nColIni+43, cTexto, oFont07:oFont, 300, , , PADHL, )
				
				nLinBox += 8
				TMP->(dbSkip())
			end

		endif

	endif

	//corrigindo o espaço entre o último item e o total do pedido, para o caso de ter poucos itens na impressão
	if nID <= nQtdItens
		nLinBox += (nQtdItens - nID) * 8
	endif

	//imprimir o total do pedido
	//caixa de box do totalizados do pedido
	oPrinter:box(nLinBox+=7, nColIni, nLinBox+37, nColFim)
	oPrinter:line(nLinBox, nColIni+108, nLinBox+24, nColIni+108)
	oPrinter:line(nLinBox, nColIni+208, nLinBox+24, nColIni+208)
	oPrinter:line(nLinBox, nColIni+308, nLinBox+24, nColIni+308)
	oPrinter:line(nLinBox, nColIni+408, nLinBox+37, nColIni+408)

	//imprimir o total do peso, frete, desconto, iss retido, icms retido, ipi e valor total do pedido
	cTexto	:= 'Peso Total:'
	oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont07:oFont, 050, , , PADHL, )
	cTexto	:= transform(nTPeso, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColIni+46, cTexto, oFont07N:oFont, 040, , , PADHR, )

	cTexto	:= 'Frete:'
	oPrinter:sayAlign(nLinBox, nColIni+110, cTexto, oFont07:oFont, 040, , , PADHL, )
	cTexto	:= transform(nTFrete, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColIni+150, cTexto, oFont07N:oFont, 040, , , PADHR, )

	cTexto	:= 'Outros:'
	oPrinter:sayAlign(nLinBox, nColIni+210, cTexto, oFont07:oFont, 040, , , PADHL, )
	cTexto	:= transform(0, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColIni+250, cTexto, oFont07N:oFont, 040, , , PADHR, )

	cTexto	:= 'Outros:'
	oPrinter:sayAlign(nLinBox, nColIni+310, cTexto, oFont07:oFont, 040, , , PADHL, )
	cTexto	:= transform(0, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColIni+350, cTexto, oFont07N:oFont, 040, , , PADHR, )

	cTexto	:= 'Valor Produtos:'
	oPrinter:sayAlign(nLinBox, nColIni+410, cTexto, oFont07:oFont, 050, , , PADHL, )
	cTexto	:= transform(nTValorProd, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColFim-81, cTexto, oFont07N:oFont, 080, , , PADHR, )

	//Segunda linha do totalizador dos itens
	oPrinter:line(nLinBox+=12, nColIni, nLinBox, nColFim)

	cTexto	:= 'ICMS Retido:'
	oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont07:oFont, 050, , , PADHL, )
	cTexto	:= transform(nTICMSRet, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColIni+46, cTexto, oFont07N:oFont, 040, , , PADHR, )

	cTexto	:= 'ISS Retido:'
	oPrinter:sayAlign(nLinBox, nColIni+110, cTexto, oFont07:oFont, 040, , , PADHL, )
	cTexto	:= transform(nTISSRet, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColIni+150, cTexto, oFont07N:oFont, 040, , , PADHR, )

	cTexto	:= 'IPI:'
	oPrinter:sayAlign(nLinBox, nColIni+210, cTexto, oFont07:oFont, 040, , , PADHL, )
	cTexto	:= transform(nTIPI, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColIni+250, cTexto, oFont07N:oFont, 040, , , PADHR, )

	cTexto	:= 'Outros:'
	oPrinter:sayAlign(nLinBox, nColIni+310, cTexto, oFont07:oFont, 040, , , PADHL, )
	cTexto	:= transform(0, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColIni+350, cTexto, oFont07N:oFont, 040, , , PADHR, )

	cTexto	:= 'Desconto:'
	oPrinter:sayAlign(nLinBox, nColIni+410, cTexto, oFont07:oFont, 050, , , PADHL, )
	cTexto	:= transform(nTDesconto, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColFim-81, cTexto, oFont07N:oFont, 080, , , PADHR, )

	//Terceira linha do totalizador dos itens
	oPrinter:line(nLinBox+=12, nColIni, nLinBox, nColFim)
	
	cTexto	:= 'Vendedor:'
	oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont07:oFont, 050, , , PADHL, )
	cTexto	:= alltrim(cVendedor)
	oPrinter:sayAlign(nLinBox, nColIni+36, cTexto, oFont07N:oFont, 245, , , PADHL, )

	cTexto	:= 'Valor Total:'
	oPrinter:sayAlign(nLinBox, nColIni+410, cTexto, oFont07:oFont, 050, , , PADHL, )
	cTexto	:= transform(nTValor, '@E 999,999,999.99')
	oPrinter:sayAlign(nLinBox, nColFim-81, cTexto, oFont07N:oFont, 080, , , PADHR, )
	
return nil

static function ImpParecelas(oPrinter,nLinBox,nColIni,nColFim,nEspaco,pVia)

	local	cTexto		as char

	local	oFont07		as object,;
			oFont07N	as object,;
			oBrush		as object

	local	nTamBoxParc	as numeric,;
			nLinObs		as numeric,;
			nRecuo		as numeric

	Local	cMemo		as char,;
			Xi			as numeric,;
			nTParcelas	as numeric


	oFont07		:= TFontEx():New(oPrinter,'Arial',07,07,.F.,.T.,.F.)
	oFont07N	:= TFontEx():New(oPrinter,'Arial',07,07,.T.,.T.,.F.)

	oBrush  := TBrush():New( , CLR_HGRAY)

	nLinBox	+= 12

	nRecuo	:= 142

	//caixa de observacoes e condicao de pagamentos
	TMP->(dbGoTop())
	TMP1->(dbGoTop())

	cMemo	:= SC5->C5_XOBS

	nTamBoxParc	:= nLinBox+150
	oPrinter:box(nLinBox,nColIni,nTamBoxParc,nColFim)
	oPrinter:line(nLinBox,nColFim-nRecuo,nTamBoxParc,nColFim-nRecuo)
//	oPrinter:line(nLinBox,nColIni+408,nTamBoxParc,nColIni+408)

	cTexto:= 'OBSERVAÇÕES'
	oPrinter:sayAlign(nLinBox+2,nColIni,cTexto, oFont07N:oFont, nColFim-(nRecuo+1), , , PADHC,)

	cTexto:= 'Cond. Pagto: ' + alltrim(TMP->PGTO) + ' - ' + alltrim(TMP->CONDPAGTO)
	oPrinter:sayAlign(nLinBox,nColIni+410,cTexto,oFont07N:oFont, nColFim-(nColIni+408), , , PADHL,)

	//Caixa de Observação
	oPrinter:fillRect({nLinBox+=12, nColIni+1, nLinBox+28, nColFim-(nRecuo+3)}, oBrush, '-2')
	cTexto:= 'Confira a mercadoria no ato da Entrega. Troca de mercadorias somente 07 dias após entrega. A descarga deverá ser realizada por conta do cliente. RESPONSABILIZAMOS PELOS ITENS DESTE PEDIDO PELO PRAZO DE 15 DIAS. Não aceitamos reclamações posteriores.'
	oPrinter:sayAlign(nLinBox,nColIni+3,cTexto,oFont07:oFont, nColFim-(nRecuo+14), 58, CLR_WHITE, PADHJ,)

	oPrinter:line(nLinBox+=12, nColIni+408, nLinBox, nColFim)

	//caixa das parcelas do financeiro
	cTexto:= 'Adm. Financeira: ' + alltrim(TMP1->FINANCEIRA)
	oPrinter:sayAlign(nLinBox,nColIni+410,cTexto,oFont07:oFont, nColFim-(nColIni+408), , , PADHL,)

	//printar o campo de observacao
	nLinBox += 12
	nLinObs	:= nLinBox
	for Xi := 1 to mlCount(cMemo,137)
		if !empty(mlCount(cMemo,137))
			if !empty(memoLine(cMemo,137,Xi))
				oPrinter:sayAlign(nLinObs+=8,nColIni+2,OemToAnsi(memoLine(cMemo,137,Xi)),oFont07:oFont, 407, 60, , PADHJ, )
			endif
		endif
	next Xi

	oPrinter:line(nLinBox+=12, nColIni+408, nLinBox, nColFim)

	//caixa das parcelas do financeiro
	cTexto:= 'Num/Parc.'
	oPrinter:sayAlign(nLinBox,nColIni+419,cTexto,oFont07:oFont, 40, , , PADHL,)

	cTexto:= 'Vencto.'
	oPrinter:sayAlign(nLinBox,nColIni+474,cTexto,oFont07:oFont, 40, , , PADHL,)

	cTexto:= 'Valor'
	oPrinter:sayAlign(nLinBox,nColIni+524,cTexto,oFont07:oFont, 40, , , PADHL,)

	//divisao das colunas referente as parcelas
	oPrinter:line(nLinBox, nColIni+460, nTamBoxParc, nColIni+460)
	oPrinter:line(nLinBox, nColIni+510, nTamBoxParc, nColIni+510)
	oPrinter:line(nLinBox+=12, nColIni+408, nLinBox, nColFim)

	nTParcelas	:= 0
	while !TMP1->(eof())
		nTParcelas	+= TMP1->VALOR

		cTexto:= iif(empty(TMP1->PARCELA),alltrim(TMP1->NUMTIT),alltrim(TMP1->NUMTIT) + '-' +alltrim(TMP1->PARCELA))
		oPrinter:sayAlign(nLinBox,nColIni+409,cTexto,oFont07:oFont, 50, , , PADHC)

		cTexto:= dtoc(TMP1->VENCTO)
		oPrinter:sayAlign(nLinBox,nColIni+463,cTexto,oFont07:oFont, 40, , , PADHC)

		cTexto:= transform(TMP1->VALOR, '@E 999,999,999.99')
		oPrinter:sayAlign(nLinBox,nColFim-51,cTexto,oFont07:oFont, 50, , , PADHR)

		nLinBox += 8
		TMP1->(dbSkip())
	end

	//Restabelecendo a linha atual apos construção da caixa das parcelas
	nLinBox	:= nTamBoxParc

return nil

static function ImpCanhoto(oPrinter,nLinBox,nColIni,nColFim,nEspaco,pVia)

	local	cTexto		as char

	local	oFont07		as object,;
			oFont07N	as object,;
			oFont24N	as object,;
			oBrush		as object

	local	cNumDoc		as char

	oFont07		:= TFontEx():New(oPrinter,'Arial',07,07,.F.,.T.,.F.)
	oFont07N	:= TFontEx():New(oPrinter,'Arial',07,07,.T.,.T.,.F.)
	oFont24N	:= TFontEx():New(oPrinter,'Arial',24,24,.T.,.T.,.F.)

	oBrush  := TBrush():New( , CLR_HGRAY)

	cNumDoc	:= alltrim(TMP->NF)+'-'+alltrim(TMP->SERIE)

	nLinBox+=6

	//caixa do conhoto
	oPrinter:box(nLinBox, nColIni, nLinBox + 36, nColFim) // caixa cidade e numero da nota

	cTexto	:= 'COMPROVANTE DE ENTREGA - '+cNumDoc
	oPrinter:sayAlign(nLinBox,nColIni+1,cTexto,oFont07N:oFont,nColFim-1, , ,PADHC)

	if pVia = 1
		cTexto	:= 'Data:: ____/____/________'
		oPrinter:sayAlign(nLinBox+=24,nColIni+1,cTexto,oFont07:oFont, 160, , ,PADHL)

		cTexto	:= 'Conferido por: ___________________________'
		oPrinter:sayAlign(nLinBox,nColIni+193,cTexto,oFont07:oFont, 160, , ,PADHL)

		cTexto	:= 'Motorista por: ___________________________'
		oPrinter:sayAlign(nLinBox,nColIni+393,cTexto,oFont07:oFont, 160, , ,PADHL)

	elseif pVia = 2 .or. pVia = 3
		cTexto	:= '*** VIA INVÁLIDA PARA CARREGAMENTO ***'
		oPrinter:sayAlign(nLinBox+=12, nColIni, cTexto, oFont24N:oFont, nColFim,,,2,PADHC)

	endif

return nil

static function ImpNP(oPrinter,nLinBox,nColIni,nColFim,nEspaco,pVia)

	local	cTexto		as char

	local	oFont07		as object
	local	nBaseProm	as numeric

	oFont07		:= TFontEx():New(oPrinter,'Arial',07,07,.F.,.T.,.F.)

	nLinBox+=18
	nBaseProm	:= nLinBox + 162

	//caixa do conhoto
	oPrinter:box(nLinBox, nColIni, nBaseProm, nColFim) 			//caixa da promissoria
	oPrinter:line(nLinBox, nColIni+15, nBaseProm, nColIni+15)	//primeira barra da promissoria
	oPrinter:line(nLinBox, nColIni+30, nBaseProm, nColIni+30)	//segunda barra da promissoria

	cTexto	:= 'Nº '
	oPrinter:say(nLinBox+=12,nColIni+40,cTexto,oFont07:oFont)
	oPrinter:box(nLinBox-11,nColIni+50,nLinBox+4,nColIni+110)	//caixa do n. promissoria

	cTexto	:= 'Vencimento                                               de                                                de '
	oPrinter:say(nLinBox,nColIni+145,cTexto,oFont07:oFont)

	cTexto	:= 'R$ '
	oPrinter:say(nLinBox,nColIni+450,cTexto,oFont07:oFont)
	oPrinter:box(nLinBox-11,nColIni+470,nLinBox+4,nColFim-5)	//caixa valor da promissoria
	
	cTexto	:= 'Ao(s)'
	oPrinter:say(nLinBox+=12,nColIni+40,cTexto,oFont07:oFont)

	cTexto	:= 'pagarei(emos) por esta única via de NOTA DE PROMISSÓRIA'
	oPrinter:sayAlign(nLinBox+=12,nColFim-255,cTexto,oFont07:oFont, 250, , , PADHR)

	cTexto	:= 'à                                                                                                                                             CPF/CNPJ'
	oPrinter:say(nLinBox+=24,nColIni+40,cTexto,oFont07:oFont)

	cTexto	:= 'ou, à sua ordem a quantia de'
	oPrinter:say(nLinBox+=18,nColIni+40,cTexto,oFont07:oFont)
	oPrinter:box(nLinBox-11,nColIni+145,nLinBox+4,nColFim-5)	//caixa da ordem da quantia
	nLinBox+=18
	oPrinter:box(nLinBox-11,nColIni+40,nLinBox+4,nColFim-5)	//continua da caixa da ordem da quantia

	cTexto	:= 'Pagável em:'
	oPrinter:say(nLinBox+=12,nColIni+40,cTexto,oFont07:oFont)

	cTexto	:= 'Emitente..:'
	oPrinter:say(nLinBox+=12,nColIni+40,cTexto,oFont07:oFont)

	cTexto	:= 'CPF/CNPJ..:'
	oPrinter:say(nLinBox+=12,nColIni+40,cTexto,oFont07:oFont)

	cTexto	:= 'Endereço..:'
	oPrinter:say(nLinBox+=12,nColIni+40,cTexto,oFont07:oFont)

	cTexto	:= '_______________________________'
	oPrinter:sayAlign(nLinBox,nColFim-165,cTexto,oFont07:oFont, 160, , , PADHC)
	
	cTexto	:= 'Assinatura do Emitente'
	oPrinter:sayAlign(nLinBox+=8,nColFim-165,cTexto,oFont07:oFont, 160, , , PADHC)

return nil
