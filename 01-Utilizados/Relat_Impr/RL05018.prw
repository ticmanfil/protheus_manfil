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
Programa----------: RL05018
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 08/07/2026
===============================================================================================================================
Descrição---------: Este programa serve para IMPRIMIR O RETORNO DE REMESSA A TERCEIRO
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
===============================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------:
			| 			| 
------------:-----------:-----------------------------------------------------------------------------------------------------:
			| 			| 
------------:-----------:-----------------------------------------------------------------------------------------------------:
			| 			| 
===============================================================================================================================
/*/
user function RL05018(cNumDoc,cSerie)

	local	lImprimiu	as logical

	lImprimiu := .F.

	processa({|| Imprimir(@lImprimiu,cNumDoc,cSerie)},'Imprindo guia RETORNO DE REMESSA','')

return lImprimiu

static function MontaTMP(cAlias,cNumDoc,cSerie)

	cAlias:= 'TMP'
	U_PesqProc(@cAlias, 'PR_RL05018', '@NUMNOTA = "'+cNumDoc+'", @SERIE = "'+cSerie+'"')

	dbSelectArea((cAlias))
	(cAlias)->(dbGoTop())

return nil

static function Imprimir(lImprimiu,cNumDoc,cSerie)

	local	oPrinter	as object,;
			oFont12		as object

	local	nLinBox		as numeric,;
			nColIni		as numeric,;
			nColFim		as numeric,;
			nEspaco		as numeric

	local	cArquivo	as char,;
			cImp		as char

	local	cAlias		as char

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

	cArquivo:= 'retorno_remessa_' + dtos(date()) + '_' + StrTran(time(),':','-')

	cImp:= U_SelImp('RL05018 - Retorno de Remessa')

	oPrinter:= fwmsPrinter():New(;
							cArquivo;		//no do arquivo a ser gerado
							,IMP_SPOOL;		//tipo de impressão, pode ser IMP_PDF, IMP_SPOOL
							,.F.;			//ajustar para legados, se for .T. ajusta a impressão para ficar igual a impressão feita pelos legados, se for .F. utiliza o framework de impressão do protheus
							,getTempPath();	//caminho onde o arquivo será salvo, pode ser um caminho local ou de rede, ex: 'C:\temp' ou '\\servidor\pasta'
							,.T.;			//desabilitar tela de configuração da impressão, se for .T. a tela de configuração não será exibida e a impressão será feita com as configurações PADHRão do sistema, se for .F. a tela de configuração será exibida para o usuário escolher as opções de impressão
							,.F.;			//imprimir relatório de teste, se for .T. o framework de impressão do protheus irá imprimir um relatório de teste para verificar se a configuração da impressão está correta, se for .F. a impressão será feita normalmente
							,;				//objeto do tipo FWPrintSetup para configurar a impressão, se for passado um objeto do tipo FWPrintSetup o framework de impressão do protheus irá utilizar as configurações definidas no objeto, se for .F. o framework de impressão do protheus irá utilizar as configurações PADHRão do sistema
							,cImp;			//nome da impressora, se for passado o nome de uma impressora instalada no sistema a impressão será feita nessa impressora, se for .F. a impressão será feita na impressora PADHRão do sistema
							,.F.;			//imprimir no servidor, se for .T. a impressão será feita no servidor onde o protheus está instalado, se for .F. a impressão será feita na máquina do usuário que está executando o processo de impressão
							,.F.;			//gerar PDF como PNG, se for .T. o framework de impressão do protheus irá gerar o arquivo PDF como um arquivo PNG, se for .F. o arquivo será gerado no formato PDF
							,.F.;			//imprimir em modo RAW, se for .T. a impressão será feita em modo RAW, se for .F. a impressão será feita em modo normal
							,.F.;			//visualizar PDF após a geração, se for .T. o framework de impressão do protheus irá abrir o arquivo PDF gerado para visualização, se for .F. o arquivo PDF será gerado mas não será aberto para visualização
							,1;				//quantidade de vias a serem impressas, se for passado um valor numérico o framework de impressão do protheus irá imprimir a quantidade de vias especificada, se for .F. a impressão será feita com a quantidade de vias definida nas configurações da impressora
							)
	oPrinter:SetPortrait()				//formato retrato
	oPrinter:setPaperSize(9) 			//A4
	oPrinter:setMargin(60,00,60,00)		//margem de 1 cm lado direito e esquerdo (nEsquerda, nSuperior, nDireita, nInferior )

	//definir a fonte a ser utilizada na impressão
	oFont12	:= TFontEx():New(oPrinter,'Arial',12,12,.F.,.T.,.F.)
	oPrinter:setFont(oFont12:oFont)		//fonte Arial, tamanho 12, normal

	//Busca dados para impressao
	MontaTMP(@cAlias,cNumDoc,cSerie)

	nLinBox := 010
	nColIni := 010
	nColFim := 560
	nEspaco := 006

	oPrinter:StartPage()

	ImpCabec(@cAlias,@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco)
	ImpItens(@cAlias,@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco)
	ImpParcelas(@cAlias,@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco)
	ImpCanhoto(@cAlias,@oPrinter,@nLinBox,@nColIni,@nColFim,@nEspaco)

	(cAlias)->(dbCloseArea())

	oPrinter:EndPage()
	lImprimiu:= oPrinter:Preview()

	if oPrinter # nil
		freeobj(oPrinter)
	endif
	oPrinter:= nil

return lImprimiu

static function ImpCabec(cAlias,oPrinter,nLinBox,nColIni,nColFim,nEspaco,pVia)

	local	cCGC		as char,;
			cInscr		as char,;
			cCliente	as char

	local	cEndereco	as char,;
			cMunic		as char,;
			cBairro		as char,;
			cCep		as char,;
			cUF			as char,;
			cEmail		as char,;
			cTelefone	as char,;
			cCelular	as char

	local	cEndEntr1	as char,;
			cEndEntr2	as char

	local	cNumDoc		as char,;
			cSerie		as char,;
			cDtEmissao	as char

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
	cCGC		:= transform(alltrim((cAlias)->CGC_FIL),'@R NN.NNN.NNN/NNNN-99')
	cInscr		:= alltrim((cAlias)->INSC_FIL)
	cCliente	:= alltrim((cAlias)->EMITENTE)
	cEmail		:= alltrim((cAlias)->EMAIL_FIL)
	cTelefone	:= alltrim((cAlias)->TEL_FIL)
	cCelular	:= alltrim((cAlias)->CEL_FIL)

	//dados do endereço e informações de entrega
	cEndereco	:= alltrim((cAlias)->END_FIL)
	cMunic		:= alltrim((cAlias)->MUN_FIL)
	cBairro		:= alltrim((cAlias)->BAI_FIL)
	cCep		:= transform(alltrim((cAlias)->CEP_FIL),'@R 99999-999')
	cUF			:= alltrim((cAlias)->UF_FIL)

	//dados de entrega
	cEndEntr1	:= substring(alltrim((cAlias)->ENDENT_FIL),1,80)
	cEndEntr2	:= substring(alltrim((cAlias)->ENDENT_FIL),81,80)

	//dados do pedido de remessa
	cNumDoc		:= (cAlias)->NUMDOC
	cSerie		:= (cAlias)->SERIE
	cDtEmissao	:= (cAlias)->DTEMISSAO

	nLinBox += 000

	//01 - IMPRIMIR NUMERO DO DOC DE SAIDA E VIA DE IMPRESSAO
	oPrinter:box(nLinBox, nColIni, nLinBox + 23, nColFim) // caixa cidade e numero da nota

	oPrinter:line(nLinBox,nColFim-150,nLinBox+23,nColFim-150) //Caixa da Via

	cTexto		:= 'RETORNO DE MERCADORIA TERCEIRO - Nº: '+cNumDoc+' - '+cSerie
	oPrinter:sayAlign(nLinBox, nColIni+1 , cTexto, oFont08N:oFont, 360, 23, ,PADHC, PADVC)

	cTexto		:= 'VIA ÚNICA'
	oPrinter:sayAlign(nLinBox, nColFim-150, cTexto, oFont16N:oFont, 150, 23, , PADHC, PADVC)

	//02 - IMPRIMIR DADOS DA MANFIL
	nLinBox	:= nLinBox + 23
	nLinAtual := nLinBox

	oPrinter:box(nLinAtual+=5, nColIni, nLinAtual+100, nColFim) // caixa endereço

	//dados da manfil
	cTexto:= 'CNPJ: '
	oPrinter:say(nLinAtual+=7,nColIni+1,cTexto,oFont07:oFont)
	cTexto:= cCGC
	oPrinter:say(nLinAtual,nColIni+37,cTexto,oFont08N:oFont)

	cTexto:= 'Inscrição Estadual: '
	oPrinter:say(nLinAtual,nColIni+150,cTexto,oFont07:oFont)
	cTexto:= cInscr
	oPrinter:say(nLinAtual,nColIni+215,cTexto,oFont08N:oFont)

	cTexto:= 'Data Pré-Nota: '
	oPrinter:say(nLinAtual,nColIni+300,cTexto,oFont07:oFont)
	cTexto:= cDtEmissao
	oPrinter:say(nLinAtual,nColIni+365,cTexto,oFont08N:oFont)

	cTexto:= 'Cliente: '
	oPrinter:say(nLinAtual+=12,nColIni+1,cTexto,oFont07:oFont)
	cTexto:= cCliente
	oPrinter:say(nLinAtual,nColIni+37,cTexto,oFont08N:oFont)

	cTexto:= 'Endereço: '
	oPrinter:say(nLinAtual+=24,nColIni+1,cTexto,oFont07:oFont)
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

static function ImpItens(cAlias,oPrinter,nLinBox,nColIni,nColFim,nEspaco,pVia)

	local	cTexto		as char

	local	oFont05		as object,;
			oFont07		as object,;
			oFont07N	as object,;
			oFont08		as object,;
			oFont24N	as object

	local	nQtdItens	as numeric,;
			nTamCol		as numeric

	local	nID			as numeric,;
			cCodProd 	as char,;
			cUM			as char,;
			cDescricao 	as char

	oFont05 	:= TFontEx():New(oPrinter,"Arial",05,05,.F.,.T.,.F.)
	oFont07		:= TFontEx():New(oPrinter,"Arial",07,07,.F.,.T.,.F.)
	oFont07N	:= TFontEx():New(oPrinter,"Arial",07,07,.T.,.T.,.F.)
	oFont08		:= TFontEx():New(oPrinter,"Arial",08,08,.F.,.T.,.F.)
	oFont24N	:= TFontEx():New(oPrinter,"Arial",24,24,.T.,.T.,.F.)

	nLinBox	+= 102

	//quantidade de itens maximo no pedido de venda
	nQtdItens 	:= 26
	nTamCol		:= 18 * nQtdItens

	//iniciando as variais dos itens
	nID			:= 0
	cCodProd 	:= ''
	cUM			:= ''
	cDescricao 	:= ''
	
	//cabecalho dos itens dos produtos
	oPrinter:box(nLinBox, nColIni, nLinBox+nTamCol, nColFim)

	//linha das colunas dos itens
	oPrinter:line(nLinBox,nColIni+038,nLinBox+nTamCol,nColIni+038)
	oPrinter:line(nLinBox,nColIni+105,nLinBox+nTamCol,nColIni+105)
	oPrinter:line(nLinBox,nColIni+135,nLinBox+nTamCol,nColIni+135)
	oPrinter:line(nLinBox,nColIni+509,nLinBox+nTamCol,nColIni+509)

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

	//preencher com os itens da pre nota
	(cAlias)->(dbGoTop())
	while !(cAlias)->(eof())
		nID			+= 1
		cCodProd 	:= alltrim((cAlias)->CODPROD)
		cUM			:= alltrim((cAlias)->UM)
		cDescricao 	:= alltrim((cAlias)->PRODUTO)

		cTexto	:= cCodProd
		oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont07:oFont, 040, , , PADHL, )
		
		cTexto	:= ''	//vamos deixar o campo de unidade em branco para ser preenchido pelo conferente
		oPrinter:sayAlign(nLinBox, nColIni+110, cTexto, oFont07:oFont, 025, , , PADHC, )
		
		cTexto	:= cDescricao
		oPrinter:sayAlign(nLinBox, nColIni+138, cTexto, oFont07:oFont, 300, , , PADHL, )
		
		//linha horizontal abaixo dos itens
		oPrinter:line(nLinBox+10,nColIni,nLinBox+10,nColFim)

		nLinBox += 16
		(cAlias)->(dbSkip())

	enddo

	//saltando o espaco para os itens de acordo com a quantidade de produtos que cabem no espaco destinado
	if nID <= nQtdItens
		nLinBox += (nQtdItens - nID) * 16
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

	cTexto	:= 'Frete:'
	oPrinter:sayAlign(nLinBox, nColIni+110, cTexto, oFont07:oFont, 040, , , PADHL, )

	cTexto	:= 'Outros:'
	oPrinter:sayAlign(nLinBox, nColIni+210, cTexto, oFont07:oFont, 040, , , PADHL, )

	cTexto	:= 'Outros:'
	oPrinter:sayAlign(nLinBox, nColIni+310, cTexto, oFont07:oFont, 040, , , PADHL, )

	cTexto	:= 'Valor Produtos:'
	oPrinter:sayAlign(nLinBox, nColIni+410, cTexto, oFont07:oFont, 050, , , PADHL, )

	//Segunda linha do totalizador dos itens
	oPrinter:line(nLinBox+=12, nColIni, nLinBox, nColFim)

	cTexto	:= 'ICMS Retido:'
	oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont07:oFont, 050, , , PADHL, )

	cTexto	:= 'ISS Retido:'
	oPrinter:sayAlign(nLinBox, nColIni+110, cTexto, oFont07:oFont, 040, , , PADHL, )

	cTexto	:= 'IPI:'
	oPrinter:sayAlign(nLinBox, nColIni+210, cTexto, oFont07:oFont, 040, , , PADHL, )

	cTexto	:= 'Outros:'
	oPrinter:sayAlign(nLinBox, nColIni+310, cTexto, oFont07:oFont, 040, , , PADHL, )

	cTexto	:= 'Desconto:'
	oPrinter:sayAlign(nLinBox, nColIni+410, cTexto, oFont07:oFont, 050, , , PADHL, )

	//Terceira linha do totalizador dos itens
	oPrinter:line(nLinBox+=12, nColIni, nLinBox, nColFim)
	
	cTexto	:= 'Vendedor:'
	oPrinter:sayAlign(nLinBox, nColIni+1, cTexto, oFont07:oFont, 050, , , PADHL, )

	cTexto	:= 'Valor Total:'
	oPrinter:sayAlign(nLinBox, nColIni+410, cTexto, oFont07:oFont, 050, , , PADHL, )
	
return nil

static function ImpParcelas(cAlias,oPrinter,nLinBox,nColIni,nColFim,nEspaco,pVia)

	local	cTexto		as char

	local	oFont07		as object,;
			oFont07N	as object,;
			oBrush		as object

	local	nTamBoxParc	as numeric,;
			nRecuo		as numeric


	oFont07		:= TFontEx():New(oPrinter,'Arial',07,07,.F.,.T.,.F.)
	oFont07N	:= TFontEx():New(oPrinter,'Arial',07,07,.T.,.T.,.F.)

	oBrush  := TBrush():New( , CLR_HGRAY)

	nLinBox		+= 12
	nRecuo		:= 142
	nTamBoxParc	:= nLinBox+150

	oPrinter:box(nLinBox,nColIni,nTamBoxParc,nColFim)
	oPrinter:line(nLinBox,nColFim-nRecuo,nTamBoxParc,nColFim-nRecuo)

	cTexto:= 'OBSERVAÇÕES'
	oPrinter:sayAlign(nLinBox+2,nColIni,cTexto, oFont07N:oFont, nColFim-(nRecuo+1), , , PADHC,)

	cTexto:= 'Cond. Pagto: '
	oPrinter:sayAlign(nLinBox+= 12,nColIni+410,cTexto,oFont07N:oFont, nColFim-(nColIni+408), , , PADHL,)

	oPrinter:line(nLinBox+=12, nColIni+408, nLinBox, nColFim)

	//caixa das parcelas do financeiro
	cTexto:= 'Adm. Financeira: '
	oPrinter:sayAlign(nLinBox,nColIni+410,cTexto,oFont07:oFont, nColFim-(nColIni+408), , , PADHL,)

	oPrinter:line(nLinBox+=24, nColIni+408, nLinBox, nColFim)

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

	//Restabelecendo a linha atual apos construção da caixa das parcelas
	nLinBox	:= nTamBoxParc

return nil

static function ImpCanhoto(cAlias,oPrinter,nLinBox,nColIni,nColFim,nEspaco,pVia)

	local	cTexto		as char

	local	oFont07		as object,;
			oFont07N	as object,;
			oFont24N	as object,;
			oBrush		as object

	local	cNumDoc		as char,;
			cSerie		as char

	oFont07		:= TFontEx():New(oPrinter,'Arial',07,07,.F.,.T.,.F.)
	oFont07N	:= TFontEx():New(oPrinter,'Arial',07,07,.T.,.T.,.F.)
	oFont24N	:= TFontEx():New(oPrinter,'Arial',24,24,.T.,.T.,.F.)

	oBrush  := TBrush():New( , CLR_HGRAY)

	(cAlias)->(dbGoTop())
	cNumDoc	:= (cAlias)->NUMDOC
	cSerie	:= (cAlias)->SERIE

	//caixa do conhoto
	oPrinter:box(nLinBox+=12, nColIni, nLinBox + 36, nColFim) // caixa cidade e numero da nota

	cTexto	:= 'COMPROVANTE DE RETORNO DE MERCADORIA TERCEIRO - '+cNumDoc+' - '+cSerie
	oPrinter:sayAlign(nLinBox,nColIni+1,cTexto,oFont07N:oFont,nColFim-1, , ,PADHC)

	cTexto	:= 'Data:: ____/____/________'
	oPrinter:sayAlign(nLinBox+=24,nColIni+1,cTexto,oFont07:oFont, 160, , ,PADHL)

	cTexto	:= 'Conferido por: ___________________________'
	oPrinter:sayAlign(nLinBox,nColIni+090,cTexto,oFont07:oFont, 160, , ,PADHL)

	cTexto	:= 'Motorista por: ___________________________'
	oPrinter:sayAlign(nLinBox,nColIni+250,cTexto,oFont07:oFont, 160, , ,PADHL)

	cTexto	:= 'Manfil: ___________________________'
	oPrinter:sayAlign(nLinBox,nColIni+410,cTexto,oFont07:oFont, 160, , ,PADHL)

return nil
