/*/
===============================================================================================================================
Programa----------: RD05013
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/07/2024
===============================================================================================================================
Descrição---------: Este programa serve para mostrar o GRID com os custos dos produtos pela analise do Silvio
===============================================================================================================================
Uso---------------: No orcamentos (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|           | 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/

#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'
#include 'prtopdef.ch'

user function RD05013(_cFilial, cNumOrc, cCliente)
	
	local	aObjects	:= {},;
			aPosObj		:= {},;
			aSizeAut  	:= MsAdvSize(),;
			nOpc 		:= GD_UPDATE,; //GD_INSERT + GD_UPDATE + GD_DELETE 
			oDlg,oSay1,	oButton2
	
	local 	cPerg		:= 'RD05013',;
			cTpCusto	as caracter

	AjustaSX1(cPerg)

	if Pergunte(cPerg,.T.)
		if mv_par01 = 1
			cTpCusto:= 'M'
		elseif mv_par01 = 2
			cTpCusto:= 'P'
		elseif mv_par01 = 3
			cTpCusto:= 'S'
		endif
	endif

	private	aHeader	:= {},;
			aCols	:= {},;
			cTitulo	:= ''
			
	mnHeader()
	mnDados(_cFilial, cNumOrc, 1, cTpCusto)
	
	cTitulo	:= '[RD05013] - ORÇAMENTO POR CUSTO SILVIO - '+alltrim(cNumOrc)+' - '+cCliente

	aadd( aObjects, { 343, 200, .T., .T. } ) //Browse
	aadd( aObjects, { 280, 007, .T., .F. } ) //Linha horizontal
	aadd( aObjects, { 040, 010, .F., .F. } ) //Botao
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7]  ,00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	oBrw:= MsNewGetDados():New(aPosObj[1,2],aPosObj[1,1] -30,aPosObj[1,3],aPosObj[1,4],nOpc, 'AllwaysTrue', 'AllwaysTrue','' ,{'DESCONTO'},6, 999, 'AllwaysTrue', '',  'AllwaysTrue', oDlg  ,aHeader, aCols, {||  GChange(), oBrw:Refresh() })

	oBrw:oBrowse:bChange := { ||  GChange() }

	oBrw:SetArray(aCols)
	oBrw:Refresh(.T.)
	oBrw:oBrowse:lUseDefaultColors := .F. // Desabilita cor padrao das linhas

	oBrw:SetEditLine(.T.)

	//oBrw:bDelOk:={||AlterDados(2)}

	//Linha horizontal
//	@ 203, 005 SAY oSay1 PROMPT Repl("-",3000) SIZE 280, 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL
	@ aPosObj[2,1], aPosObj[2,2] SAY oSay1 PROMPT Repl("_",aPosObj[1,4]) SIZE aPosObj[1,4], 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL

	@ aPosObj[3,1], aPosObj[1,4] - 40 BUTTON oButton2 PROMPT "Sair" SIZE 040, 010 OF oDlg ACTION oDlg:End() PIXEL
	@ aPosObj[3,1], aPosObj[1,4] - 150 BUTTON oButton1 PROMPT "Confirmar" SIZE 070, 010 OF oDlg ACTION MsAguarde({|| bSalvar(oDlg, _cFilial, cNumOrc, cTitulo)},'Orçamentos','Aguarde, gravando registros...',.F.)  PIXEL
//	@ aPosObj[3,1], aPosObj[1,4] - 480 SAY oSay1 PROMPT "Custo Fabricacao: "+transform(nCFab*100,'@E 999.99')+"% - Desp. Fixa: "+transform(nCFix*100,'@E 999.99')+"%" SIZE 200, 010 OF oDlg PIXEL
//	@ aPosObj[3,1], aPosObj[1,4] - 260 BUTTON oButton1 PROMPT "Alterar Parmetros" SIZE 100, 010 OF oDlg ACTION MsAguarde({|| bAlMargem(_cFilial, cNumOrc, cPerg)},'Orçamento','Aguarde, atualizando parametros...',.F.)  PIXEL
	@ aPosObj[3,1], aPosObj[1,4] - 260 BUTTON oButton1 PROMPT "Exp. p/ Excel" SIZE 100, 010 OF oDlg ACTION MsAguarde({|| bExpExcel(oDlg, _cFilial, cNumOrc)},'Orçamento','Aguarde, exportando para excel...',.F.)  PIXEL
//	@ aPosObj[3,1], aPosObj[1,4] - 480 BUTTON oButton1 PROMPT "Recarga Custo" SIZE 100, 010 OF oDlg ACTION MsAguarde({|| mnDados(_cFilial, cNumOrc)},'Orçamento','Aguarde, recarregando custo...',.F.)  PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

return

static function mnDados(_cFilial, cNumOrc, opcao, cTpCusto)
	local 	cQuery			as char,;
			nvLinha			as numeric,;
			nLinha			as numeric			

	local	nMarg			as numeric,;
			nCFab			as numeric,;
			nCFix			as numeric,;
			nIss			as numeric,;
			cTipoProd		as char,;
			nCusto			as numeric,;
			nIndCusto		as numeric,;
			nPrcVenda		as numeric,;
			nMrkPrev		as numeric,;
			nVendaTotal		as numeric,;
			nDesconto		as numeric,;
			nDescontoUnit	as numeric,;
			nVendaLiq		as numeric,;
			nMrkOcorrido	as numeric,;
			nDescontoTotal	as numeric,;
			nVendaLiqTotal	as numeric,;
			nVendaLiqUnit	as numeric,;
			nLucroUnit		as numeric,;
			nMrgLucroAp		as numeric

	local	nTotalLucro		as numeric,;
			nTotalVendasLiq	as numeric,;
			nTotalMargem	as numeric,;
			nTCusto			as numeric,;
			nTCFabCFixo		as numeric,;
			nTCustoLiq		as numeric
	
	if opcao != 1
		oBrw:refresh(.T.)
	endif

	if select('TB01') <> 0
		dbSelectArea('TB01')
		TB01->(dbCloseArea())
	endif
	
	cQuery	:= 'exec dbo.PR_RD05013 @FILIAL = '+chr(39)+_cFilial+chr(39)+', @NUMORC = '+chr(39)+cNumOrc+chr(39)+', @TPCUSTO = '+char(39)+cTpCusto+char(39)
	
	TCQUERY cQuery NEW ALIAS 'TB01'
	
	dbSelectArea('TB01')
	TB01->(dbGoTop())

	nvLinha		:= 0
	nLinha		:= 0
	aCols		:= {}

	nTotalLucro		:= 0
	nTotalVendasLiq	:= 0
	nTotalMargem	:= 0
	nTCusto			:= 0
	nTCFabCFixo		:= 0
	nTCustoLiq		:= 0

	while TB01->(!eof())
		nvLinha	:= len(aCols)+1
		aadd(aCols,array((len(aHeader)+1)))
		aCols[nvLinha][len(aHeader)+1]	:= .F.
		nLinha:= len(aCols)

		//Calculo dos indicadores
		cTipoProd		:= TB01->B1_TIPO
		nCusto			:= TB01->B1_CUSTO
		nCFab			:= iif(cTipoProd=='PA',getmv('MV_XCFAB'),0)
		nCFix			:= getmv('MV_XDFIXA')
		nIss			:= iif(cTipoProd=='SV',getmv('MV_ALIQISS')/100,0)
		//nMarg			:= TB01->B1_XMLUCRO/100
		//nIndCusto		:= nCFab+nCFix+nMarg
		//nPrcVenda		:= nCusto / (1-nIndCusto)
		nPrcVenda		:= TB01->CK_PRUNIT
		nMarg			:= 1-nCFab-nCFix-nIss-(nCusto/nPrcVenda)
		nIndCusto		:= nCFab+nCFix+nMarg+nIss
		nMrkPrev		:= ((nPrcVenda / nCusto)-1)
		nVendaTotal		:= nPrcVenda*TB01->CK_QTDVEN
		nDesconto		:= TB01->CK_DESCONT/100
		nDescontoUnit	:= nPrcVenda*nDesconto
		nVendaLiq		:= nPrcVenda-nDescontoUnit
		nMrkOcorrido	:= ((nVendaLiq / nCusto)-1)
		nDescontoTotal	:= nDescontoUnit*TB01->CK_QTDVEN
		nVendaLiqTotal	:= nVendaTotal-nDescontoTotal
		nVendaLiqUnit	:= nVendaLiqTotal/TB01->CK_QTDVEN
		nLucroUnit		:= nVendaLiqUnit-nCusto-(nPrcVenda*nCFab)-(nPrcVenda*nCFix)-(nPrcVenda*nIss)
		nMrgLucroAp		:= nLucroUnit/nVendaLiqUnit

		//Somando os totais
		nTotalLucro		+= nLucroUnit*TB01->CK_QTDVEN
		nTotalVendasLiq	+= nVendaLiqTotal
		nTCusto			+= nCusto*TB01->CK_QTDVEN
		nTCFabCFixo		:= nTotalVendasLiq - nTotalLucro - nTCusto
		nTCustoLiq		:= nTCusto+nTCFabCFixo

		//Preenchendo grido com os indicadores calculados
		/*01*/aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_ITEM'})]			:= TB01->CK_ITEM
		/*02*/aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_PRODUTO'})]		:= TB01->CK_PRODUTO
		/*03*/aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_DESCRI'})]			:= TB01->CK_DESCRI
		/*04*/aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='TIPOPROD'})]			:= cTipoProd
		/*05*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_QTDVEN'})]			:= TB01->CK_QTDVEN
		/*06*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_UM'})]				:= TB01->CK_UM
		/*07*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFIL'})]			:= nCusto
		/*08*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFILTOTAL'})]		:= nCusto*TB01->CK_QTDVEN
		/*09*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CFAB'})]				:= nCFab*100
		/*10*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CFIXO'})]				:= nCFix*100
		/*11*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CISS'})]				:= nIss*100
		/*12*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MLUCRO'})]			:= nMarg*100
		/*13*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='INDCUSTO'})]			:= nIndCusto*100
		/*14*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PVENDA'})]			:= nPrcVenda
		/*15*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MKPREVISTO'})]		:= nMrkPrev*100
		/*16*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDATOTAL'})]		:= nVendaTotal
		/*17*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DESCONTO'})]			:= nDesconto*100
		/*18*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DESCONTOUNIT'})]		:= nDescontoUnit
		/*19*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDALIQUIDA'})]		:= nVendaLiq
		/*20*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MKOCORRIDO'})]		:= nMrkOcorrido*100
		/*21*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DESCONTOTOTAL'})]		:= nDescontoTotal
		/*22*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDALIQTOTAL'})]		:= nVendaLiqTotal
		/*23*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDAUNITLIQ'})]		:= nVendaLiqUnit
		/*24*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='LUCROCDESC'})]		:= nLucroUnit
		/*25*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MLCDESCONTO'})]		:= nMrgLucroAp*100
		/*26*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='LTOTALCDESCONTO'})]	:= nLucroUnit*TB01->CK_QTDVEN
		/*27*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XUNSVEN'})]		:= TB01->CK_XUNSVEN
		/*28*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_XSEGUM'})]			:= TB01->CK_XSEGUM

		TB01->(dbSkip())
	enddo
	TB01->(dbCloseArea())

	//LINHA TOTALIZADOR
	nTotalMargem	:= nTotalLucro/nTotalVendasLiq

	nvLinha	:= len(aCols)+1
	aadd(aCols,array((len(aHeader)+1)))
	aCols[nvLinha][len(aHeader)+1]	:= .F.
	nLinha:= len(aCols)
	nvLinha	:= len(aCols)+1
	aadd(aCols,array((len(aHeader)+1)))
	aCols[nvLinha][len(aHeader)+1]	:= .F.
	nLinha:= len(aCols)

	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_DESCRI'})]		:= 'Custo Compra Total do Orçamento (R$):'
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_QTDVEN'})]		:= round(nTCusto,2)

	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFIL'})]			:= 'Total da Venda (R$):'
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFILTOTAL'})]	:= round(nTotalVendasLiq,2)

	nvLinha	:= len(aCols)+1
	aadd(aCols,array((len(aHeader)+1)))
	aCols[nvLinha][len(aHeader)+1]	:= .F.
	nLinha:= len(aCols)

	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_DESCRI'})]		:= 'Custo de Fabricação Total + D.Fixas e Variáveis Totais (R$):'
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_QTDVEN'})]		:= round(nTCFabCFixo,2)

	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFIL'})]			:= 'Lucro Total (R$):'
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFILTOTAL'})]	:= round(nTotalLucro,2)

	nvLinha	:= len(aCols)+1
	aadd(aCols,array((len(aHeader)+1)))
	aCols[nvLinha][len(aHeader)+1]	:= .F.
	nLinha:= len(aCols)

	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_DESCRI'})]		:= 'Soma Custo Compra + CFab + DFix + DVar (R$):'
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_QTDVEN'})]		:= round(nTCustoLiq,2)

	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFIL'})]			:= 'M L da Venda (%):'
	aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFILTOTAL'})]	:= round(nTotalMargem,2)

	if opcao != 1
		oBrw:SetArray(aCols)
		oBrw:refresh(.T.)
	endif
	
return


static function mnHeader()
	if empty(aHeader)
	/*01*/	aadd(aHeader,{u_ux3Titulo('CK_ITEM')		,'CK_ITEM'			, x3Picture('CK_ITEM')			, tamSx3('CK_ITEM')[1]			, tamSx3('CK_ITEM')[2]			, '', '', 'C', '', 'V'})
	/*02*/	aadd(aHeader,{u_ux3Titulo('CK_PRODUTO')		,'CK_PRODUTO'		, x3Picture('CK_PRODUTO')		, tamSx3('CK_PRODUTO')[1]		, tamSx3('CK_PRODUTO')[2]		, '', '', 'C', '', 'V'})
	/*03*/	aadd(aHeader,{u_ux3Titulo('CK_DESCRI')		,'CK_DESCRI'		, x3Picture('CK_DESCRI')		, tamSx3('CK_DESCRI')[1]		, tamSx3('CK_DESCRI')[2]		, '', '', 'C', '', 'V'})
	/*04*/	aadd(aHeader,{'TIPO'						,'TIPOPROD'			, x3Picture('B1_TIPO')			, tamSx3('B1_TIPO')[1]			, tamSx3('B1_TIPO')[2]			, '', '', 'C', '', 'V'})
	/*05*/	aadd(aHeader,{u_ux3Titulo('CK_QTDVEN')		,'CK_QTDVEN'		, x3Picture('CK_QTDVEN')		, tamSx3('CK_QTDVEN')[1]		, tamSx3('CK_QTDVEN')[2]		, '', '', 'N', '', 'V'})
	/*06*/	aadd(aHeader,{u_ux3Titulo('CK_UM')			,'CK_UM'			, x3Picture('CK_UM')			, tamSx3('CK_UM')[1]			, tamSx3('CK_UM')[2]			, '', '', 'C', '', 'V'})
	/*07*/	aadd(aHeader,{'CUSTO COMPRA UNITÁRIO'		,'CMANFIL'			, ''							, 16, 6, '', '', 'N', '', 'V'})
	/*08*/	aadd(aHeader,{'CUSTO COMPRA TOTAL'			,'CMANFILTOTAL'		, '@E 999,999,999.999999'		, 16, 6, '', '', 'N', '', 'V'})
	/*09*/	aadd(aHeader,{'C.FABRICACAO(%)'				,'CFAB'				, '@E 999.99'					,  5, 2, '', '', 'N', '', 'V'})
	/*10*/	aadd(aHeader,{'C.FIXO(%)'					,'CFIXO'			, '@E 999.99'					,  5, 2, '', '', 'N', '', 'V'})
	/*11*/	aadd(aHeader,{'ISS(%)'						,'CISS'				, '@E 999.99'					,  5, 2, '', '', 'N', '', 'V'})
	/*12*/	aadd(aHeader,{'M.LUCRO (%)'					,'MLUCRO'			, '@E 999.99'					,  5, 2, '', '', 'N', '', 'V'})
	/*13*/	aadd(aHeader,{'ÍNDICE CUSTOS + DESP. (%)'	,'INDCUSTO'			, '@E 999.99'					,  5, 2, '', '', 'N', '', 'V'})
	/*14*/	aadd(aHeader,{'PREÇO VENDA'					,'PVENDA'			, '@E 999,999,999.99'			, 12, 2, '', '', 'N', '', 'V'})
	/*15*/	aadd(aHeader,{'MARKUP PREVISTO (%)'			,'MKPREVISTO'		, '@E 999.99'					,  5, 2, '', '', 'N', '', 'V'})
	/*16*/	aadd(aHeader,{'VENDA TOTAL'					,'VENDATOTAL'		, '@E 999,999,999.99'			, 12, 2, '', '', 'N', '', 'V'})
	/*17*/	aadd(aHeader,{'DESCONTO (%)'				,'DESCONTO'			, '@E 999.99'					,  5, 2, '', '', 'N', '', 'V'})
	/*18*/	aadd(aHeader,{'DESCONTO UNIT.'				,'DESCONTOUNIT'		, '@E 999,999,999.99'			, 12, 2, '', '', 'N', '', 'V'})
	/*19*/	aadd(aHeader,{'VENDA UNIT. LÍQUIDA'			,'VENDALIQUIDA'		, '@E 999,999,999.99'			, 12, 2, '', '', 'N', '', 'V'})
	/*20*/	aadd(aHeader,{'MARKUP OCORRIDO (%)'			,'MKOCORRIDO'		, '@E 999.99'					,  5, 2, '', '', 'N', '', 'V'})
	/*21*/	aadd(aHeader,{'DESCONTO TOTAL'				,'DESCONTOTOTAL'	, '@E 999,999,999.99'			, 12, 2, '', '', 'N', '', 'V'})
	/*22*/	aadd(aHeader,{'VENDA TOTAL LÍQUIDA'			,'VENDALIQTOTAL'	, '@E 999,999,999.99'			, 12, 2, '', '', 'N', '', 'V'})
	/*23*/	aadd(aHeader,{'VENDA UNIT. LÍQUIDA'			,'VENDAUNITLIQ'		, '@E 999,999,999.99'			, 12, 2, '', '', 'N', '', 'V'})
	/*24*/	aadd(aHeader,{'LUCRO UNIT. C/DESC. '		,'LUCROCDESC'		, '@E 999.99'					, 12, 2, '', '', 'N', '', 'V'})
	/*25*/	aadd(aHeader,{'M.L. C/DESC. (%)'			,'MLCDESCONTO'		, '@E 999.99'					,  5, 2, '', '', 'N', '', 'V'})
	/*26*/	aadd(aHeader,{'LUCRO TOTAL C/DESC.'			,'LTOTALCDESCONTO'	, '@E 999,999,999.99'			, 12, 2, '', '', 'N', '', 'V'})
	/*27*/	aadd(aHeader,{u_ux3Titulo('CK_XUNSVEN')		,'CK_XUNSVEN'		, x3Picture('CK_XUNSVEN')		, tamSx3('CK_XUNSVEN')[1]		, tamSx3('CK_XUNSVEN')[2]		, '', '', 'N', '', 'V'})
	/*28*/	aadd(aHeader,{u_ux3Titulo('CK_XSEGUM')		,'CK_XSEGUM'		, x3Picture('CK_XSEGUM')		, tamSx3('CK_XSEGUM')[1]		, tamSx3('CK_XSEGUM')[2]		, '', '', 'C', '', 'V'})

	endif

return

static function bExpExcel(oDlg, _cFilial, cNumOrc)

    Local aArea      := FWGetArea()

    Local 	aCabec	as array,;
			aDados	as array

	local	nI			as numeric,;
			nContTotal	as numeric
     
	aCabec		:= {}
	aDados		:= {}
	nContTotal	:= 0

    //Exemplo #1 - Exporta um Array
    aCabec := {'ITEM', 'COD PRODUTO', 'PRODUTO', 'TIPO', 'QTD VENDA', 'UNID', 'CUSTO COMPRA UNITÁRIO','CUSTO COMPRA TOTAL',;
				'C.FABRICACAO(%)','C.FIXO(%)', 'ISS(%)','M.LUCRO (%)','ÍNDICE CUSTOS + DESP. (%)','PREÇO VENDA','MARKUP PREVISTO (%)',;
				'VENDA TOTAL','DESCONTO (%)','DESCONTO UNIT.','VENDA UNIT. LÍQUIDA','MARKUP OCORRIDO (%)',;
				'DESCONTO TOTAL','VENDA TOTAL LÍQUIDA','VENDA UNIT. LÍQUIDA','LUCRO UNIT. C/DESC. ','M.L. C/DESC. (%)','LUCRO TOTAL C/DESC.',;
				'QTD 2ª UNID','2ª UNID'}

 	for nI := 1 to len(oBrw:aCols)
		//Calculo dos indicadores
		aadd(aDados,{oBrw:aCols[nI][01],oBrw:aCols[nI][02],oBrw:aCols[nI][03],oBrw:aCols[nI][04],oBrw:aCols[nI][05],;
					 oBrw:aCols[nI][06],oBrw:aCols[nI][07],oBrw:aCols[nI][08],oBrw:aCols[nI][09],oBrw:aCols[nI][10],;
					 oBrw:aCols[nI][11],oBrw:aCols[nI][12],oBrw:aCols[nI][13],oBrw:aCols[nI][14],oBrw:aCols[nI][15],;
					 oBrw:aCols[nI][16],oBrw:aCols[nI][17],oBrw:aCols[nI][18],oBrw:aCols[nI][19],oBrw:aCols[nI][20],;
					 oBrw:aCols[nI][21],oBrw:aCols[nI][22],oBrw:aCols[nI][23],oBrw:aCols[nI][24],oBrw:aCols[nI][25],;
					 oBrw:aCols[nI][26],oBrw:aCols[nI][27],oBrw:aCols[nI][28]})
			
	next nI
	oBrw:Refresh()
 
    DlgToExcel({ {"ARRAY", cTitulo, aCabec, aDados} })
    FWRestArea(aArea)

return .T.

static function bSlvExp(oDlg, _cFilial, cNumOrc)

	local 	nI			:= 0,;
			lRet		:= .T.
	
	lMsErroAuto	:= .F.
	begin transaction

		if RecLock('SCJ',.F.)
			SCJ->CJ_DESCONT	:= 0
			SCJ->(MsUnlock())
		endif

		dbSelectArea('SCK')
		SCK->(dbSetOrder(1))
	    for nI := 1 to len(oBrw:aCols)-1
	    	if SCK->(dbSeek(xFilial('SCK')+cNumOrc+oBrw:aCols[nI][01]))
				if RecLock('SCK',.F.)
					SCK->CK_XCUSTO 	:= oBrw:aCols[nI][07]
					SCK->CK_XCUSTOT	:= oBrw:aCols[nI][08]
					SCK->CK_PRCVEN	:= oBrw:aCols[nI][21]
					SCK->CK_DESCONT	:= oBrw:aCols[nI][15]
					SCK->CK_VALDESC	:= oBrw:aCols[nI][19]
					SCK->(msUnlock())
				endif
			endif
		next nI
			
		if lMsErroAuto
			disarmtransaction()
			MostraErro()
			lRet	:= .F.

		endif
	end transaction

return lRet

static function bSalvar(oDlg, _cFilial, cNumOrc, cTitulo)

	u_msgInformacao('Rotina em desenvolvimento','[RD05013]')

return

static function fRecalcula()
	local	nI				as numeric

	local	cTipoProd		as char,;
			nQtd			as numeric,;
			nCusto			as numeric,;
			nMarg			as numeric,;
			nCFab			as numeric,;
			nCFix			as numeric,;
			nIss			as numeric,;
			nIndCusto		as numeric,;
			nPrcVenda		as numeric,;
			nMrkPrev		as numeric,;
			nVendaTotal		as numeric,;
			nDesconto		as numeric,;
			nDescontoUnit	as numeric,;
			nVendaLiq		as numeric,;
			nMrkOcorrido	as numeric,;
			nDescontoTotal	as numeric,;
			nVendaLiqTotal	as numeric,;
			nVendaLiqUnit	as numeric,;
			nLucroUnit		as numeric,;
			nMrgLucroAp		as numeric

	local	nTotalLucro		as numeric,;
			nTotalVendasLiq	as numeric,;
			nTotalMargem	as numeric,;
			nContTotal		as numeric,;
			nTCusto			as numeric,;
			nTCFabCFixo		as numeric,;
			nTCustoLiq		as numeric

	nTotalLucro		:= 0
	nTotalVendasLiq	:= 0
	nTotalMargem	:= 0
	nContTotal		:= 0
	nTCusto			:= 0
	nTCFabCFixo		:= 0
	nTCustoLiq		:= 0

	for nI := 1 to len(oBrw:aCols)
		//Calculo dos indicadores
		if oBrw:aCols[nI][01] <> nil
			cTipoProd		:= oBrw:aCols[nI][04]
			nQtd			:= oBrw:aCols[nI][05]
			nCusto			:= oBrw:aCols[nI][07]
			nCFab			:= oBrw:aCols[nI][09]/100
			nCFix			:= oBrw:aCols[nI][10]/100
			nIss			:= oBrw:aCols[nI][11]/100
			nMarg			:= oBrw:aCols[nI][12]/100
			nIndCusto		:= oBrw:aCols[nI][13]/100
			nPrcVenda		:= oBrw:aCols[nI][14]
			nMrkPrev		:= oBrw:aCols[nI][15]/100
			nVendaTotal		:= oBrw:aCols[nI][16]
			nDesconto		:= oBrw:aCols[nI][17]/100
			nDescontoUnit	:= nPrcVenda*nDesconto
			nVendaLiq		:= nPrcVenda-nDescontoUnit
			nMrkOcorrido	:= ((nVendaLiq / nCusto)-1)
			nDescontoTotal	:= nDescontoUnit*nQtd
			nVendaLiqTotal	:= nVendaTotal-nDescontoTotal
			nVendaLiqUnit	:= nVendaLiqTotal/nQtd
			nLucroUnit		:= nVendaLiqUnit-nCusto-(nPrcVenda*nCFab)-(nPrcVenda*nCFix)-(nPrcVenda*nIss)
			nMrgLucroAp		:= nLucroUnit/nVendaLiqUnit

			//Somando os totais
			nTotalLucro		+= nLucroUnit*nQtd
			nTotalVendasLiq	+= nVendaLiqTotal
			nTCusto			+= nCusto*nQtd
			nTCFabCFixo		:= nTotalVendasLiq - nTotalLucro - nTCusto
			nTCustoLiq		:= nTCusto+nTCFabCFixo

			//	/*01*/aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_ITEM'})]			:= TB01->CK_ITEM
			//	/*02*/aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_PRODUTO'})]		:= TB01->CK_PRODUTO
			//	/*03*/aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_DESCRI'})]			:= TB01->CK_DESCRI
			//	/*04*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='TIPOPROD'})]			:= TB01->TIPOPROD
			//	/*05*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_QTDVEN'})]			:= TB01->CK_QTDVEN
			//	/*06*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CK_UM'})]				:= TB01->CK_UM
			//oBrw:aCols[nI][07]	:= nCusto			//	/*06*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFIL'})]			:= nCusto
			//oBrw:aCols[nI][08]	:= nCusto*nQtd		//	/*07*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CMANFILTOTAL'})]		:= nCusto*TB01->CK_QTDVEN
			//oBrw:aCols[nI][09]	:= nCFab*100		//	/*08*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MLUCRO'})]			:= nMarg*100
			//oBrw:aCols[nI][10]	:= nCFix*100		//	/*08*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MLUCRO'})]			:= nMarg*100
			//oBrw:aCols[nI][11]	:= nIss*100			//	/*08*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MLUCRO'})]			:= nMarg*100
			//oBrw:aCols[nI][12]	:= nMarg*100		//	/*08*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MLUCRO'})]			:= nMarg*100
			//oBrw:aCols[nI][13]	:= nIndCusto*100	//	/*09*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='INDCUSTO'})]			:= nIndCusto*100
			//oBrw:aCols[nI][14]	:= nPrcVenda		//	/*10*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PVENDA'})]			:= nPrcVenda
			//oBrw:aCols[nI][15]	:= nMrkPrev*100		//	/*11*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MKPREVISTO'})]		:= nMrkPrev*100
			//oBrw:aCols[nI][16]	:= nVendaTotal		//	/*12*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDATOTAL'})]		:= nVendaTotal
			oBrw:aCols[nI][17]	:= nDesconto*100	//	/*13*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DESCONTO'})]			:= nDesconto*100
			oBrw:aCols[nI][18]	:= nDescontoUnit	//	/*14*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DESCONTOUNIT'})]		:= nDescontoUnit
			oBrw:aCols[nI][19]	:= nVendaLiq		//	/*15*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDALIQUIDA'})]		:= nVendaLiq
			oBrw:aCols[nI][20]	:= nMrkOcorrido*100	//	/*16*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MKOCORRIDO'})]		:= nMrkOcorrido*100
			oBrw:aCols[nI][21]	:= nDescontoTotal	//	/*17*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='DESCONTOTOTAL'})]		:= nDescontoTotal
			oBrw:aCols[nI][22]	:= nVendaLiqTotal	//	/*18*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDALIQTOTAL'})]		:= nVendaLiqTotal
			oBrw:aCols[nI][23]	:= nVendaLiqUnit	//	/*19*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='VENDAUNITLIQ'})]		:= nVendaLiqUnit
			oBrw:aCols[nI][24]	:= nLucroUnit		//	/*20*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='LUCROCDESC'})]		:= nLucroUnit
			oBrw:aCols[nI][25]	:= nMrgLucroAp*100	//	/*21*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='MLCDESCONTO'})]		:= nMrgLucroAp*100
			oBrw:aCols[nI][26]	:= nLucroUnit*nQtd	//	/*22*/aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='LTOTALCDESCONTO'})]	:= nLucroUnit*TB01->CK_QTDVEN
		
		else
			nTotalMargem	:= nTotalLucro/nTotalVendasLiq

			if nContTotal = 1
				oBrw:aCols[nI][05]	:= round(nTCusto,2)
				oBrw:aCols[nI][08]	:= round(nTotalVendasLiq,2)

			elseif nContTotal = 2
				oBrw:aCols[nI][05]	:= round(nTCFabCFixo,2)
				oBrw:aCols[nI][08]	:= round(nTotalLucro,2)

			elseif nContTotal = 3
				oBrw:aCols[nI][05]	:= round(nTCustoLiq,2)
				oBrw:aCols[nI][08]	:= round(nTotalMargem*100,2)

			endif 
			nContTotal += 1
		
		endif

	next nI
	oBrw:Refresh()

return

static function GChange()
	fRecalcula()
return

static function fTotal()
	local 	nI			:= 0,;
			nTotal		:= 0
			
	for nI := 1 to len(oBrw:aCols)
		if nI != len(oBrw:aCols)
			nTotal	+= oBrw:aCols[nI][12]
		endif
	next nI

return nTotal
	
static function fValid(oDlgD, nVlTBrut, nIndeniz, nVlTLiq, oGet02, oGet03)

	nVlTLiq	:= nVlTBrut - nIndeniz

	oGet02:refresh()
	oGet03:refresh()
	//oDlgD:refresh()

return .T.

static function fValSalva()
	local	nI		:= 0,;
			lRet	:= .T.

    for nI := 1 to len(oBrw:aCols)-1
    	if oBrw:aCols[nI][13] = 0
    		apMsgAlerta('O item '+cValToChar(oBrw:aCols[nI][01])+' está com VALOR TOTAL ZERADO!!!...'+chr(13)+chr(10)+'Favor corregir.',cTitulo)
    		lRet	:= .F.
		endif
	next nI

return lRet


static function ajustaSx1(cPerg)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Tipo Custo:'			, /*cPerSpa		*/ 'Tipo Custo:'			, /*cPerEng		*/ 'Tipo Custo:'			, ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 1						, /*nDecimal	*/ 0						, /*nPresel		*/ 1						, ;
				/*cGSC		*/ ''						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par01'				, ;
				/*cDef01	*/ 'M=Manfil'				, /*cDefSpa1	*/ 'M=Manfil'				, /*cDefEng1	*/ 'M=Manfil'				, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ 'P=Protheus'	 			, /*cDefSpa2	*/ 'P=Protheus'				, /*cDefEng2	*/ 'P=Protheus'				, ; 
				/*cDef03	*/ 'S=Standart'				, /*cDefSpa3	*/ 'S=Standart'				, /*cDefEng3	*/ 'S=Standart'				, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 
return
