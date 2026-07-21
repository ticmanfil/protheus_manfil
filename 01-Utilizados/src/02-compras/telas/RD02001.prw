/*/
===============================================================================================================================
Programa----------: RD02001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 20/09/2024
===============================================================================================================================
Descrição---------: Este programa serve para fazer AMARRACAO FORNECEDOR x PRODUTOS
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
#include 'prtopdef.ch'
#include 'rwmake.ch'
#include 'tbiconn.ch'

user function RD02001(oTmpTable,oTmpSubTab)
	
	local   cAlias		as char

    local	aObjects	:= {},;
			aPosObj		:= {},;
			aSizeAut  	:= MsAdvSize(),;
			nOpc 		:= GD_UPDATE,;
			oDlg,;
			oSay1,;
			oButton2,;
			cTitulo		as char,;
			oBrw		as object

	local	aHeader as array,;
			aCols	as array

    //INICIANDO AS VARIAVEIS
   	cAlias:= oTmpTable:GetAlias()
    aHeader := {}
    aCols   := {}

	mmCabecalho(@oTmpTable,@oTmpSubTab,@aHeader,@aCols)
    mnDados(@oTmpTable,@oTmpSubTab,@aHeader,@aCols)
	
	cTitulo	:= '[RD02001] - '+upper(alltrim((cAlias)->FORNECEDOR))+' - '+alltrim((cAlias)->CNPJ)

	aadd( aObjects, { 343, 200, .T., .T. } ) //Browse
	aadd( aObjects, { 280, 007, .T., .F. } ) //Linha horizontal
	aadd( aObjects, { 040, 010, .F., .F. } ) //Botao
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7]  ,00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	oBrw:= MsNewGetDados():New(aPosObj[1,2],aPosObj[1,1] -30,aPosObj[1,3],aPosObj[1,4],nOpc, 'AllwaysTrue', 'AllwaysTrue','', {'CODPROD'}, , 999,'u_RD02001FLDOK', '', 'AllwaysTrue',oDlg,aHeader,aCols,{||  GChange(@oBrw), oBrw:Refresh()} )
//	oBrw:= MsNewGetDados():New(aPosObj[1,2],aPosObj[1,1] -30,aPosObj[1,3],aPosObj[1,4],nOpc, 'AllwaysTrue', 'AllwaysTrue','', {'CODPROD'}, , 999,'AllwaysTrue', '', 'AllwaysTrue',oDlg,aHeader,aCols,{||  GChange(@oBrw), oBrw:Refresh() } )
	oBrw:oBrowse:bChange := { ||  GChange(@oBrw) }

//	MsNewGetDados(): AddAction ( [ cCampo], [ bAction] ) --> lRet
//	oBrw:oBrowse:bOk := { ||  RD02001Fok(@oBrw) }

	oBrw:SetArray(aCols)
	oBrw:Refresh(.T.)
	oBrw:oBrowse:lUseDefaultColors := .F. // Desabilita cor padrao das linhas

	oBrw:SetEditLine(.T.)

	//oBrw:bDelOk:={||AlterDados(2)}

	//Linha horizontal
	//@ 203, 005 SAY oSay1 PROMPT Repl("_",295) SIZE 280, 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL
	@ aPosObj[2,1], aPosObj[2,2] SAY oSay1 PROMPT Repl("_",aPosObj[1,4]) SIZE aPosObj[1,4], 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL

	@ aPosObj[3,1], aPosObj[1,4] - 40 BUTTON oButton2 PROMPT "Sair" SIZE 040, 010 OF oDlg ACTION oDlg:End() PIXEL
	@ aPosObj[3,1], aPosObj[1,4] - 150 BUTTON oButton1 PROMPT "Confirmar" SIZE 070, 010 OF oDlg ACTION msAguarde({|| bSalvar(@oBrw,@oTmpTable,@oTmpSubTab)},'Amarração Fornecedor x Produtos','Aguarde, gravando registros...',.F.)  PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

return

static function mmCabecalho(oTmpTable,oTmpSubTab,aHeader,aCols)
    local   cAlias  	as char,;
			cAliasSub	as char

    cAlias:= oTmpTable:GetAlias()
	cAliasSub:= oTmpSubTab:GetAlias()

	if empty(aHeader)
		aadd(aHeader,{'Cod. Produto Fornecedor', 'CODPRODFOR', '', tamSx3('B1_COD')[1], tamSx3('B1_COD')[2], '', '', 'C', '', 'V'})
		aadd(aHeader,{'Produto Fornecedor', 'PRODFOR', '', tamSx3('B1_DESC')[1], tamSx3('B1_DESC')[2], '', '', 'C', '', 'V'})
		aadd(aHeader,{'Unid. Fornecedor','UMFOR', '', tamSx3('B1_UM')[1]	, tamSx3('B1_UM')[2]	, '', '', 'C', '', 'V'})
		aadd(aHeader,{'Cod. Produto', 'CODPROD', '', tamSx3('B1_COD')[1], tamSx3('B1_COD')[2], '', '', 'C', 'PRO', 'V'})
		aadd(aHeader,{'Produto', 'PROD', '', tamSx3('B1_DESC')[1], tamSx3('B1_DESC')[2], '', '', 'C', '', 'V'})
		aadd(aHeader,{'Unid.','UM', '', tamSx3('B1_UM')[1]	, tamSx3('B1_UM')[2]	, '', '', 'C', '', 'V'})

	endif
return

static function mnDados(oTmpTable,oTmpSubTab,aHeader,aCols)
    local   cAlias  	as char,;
			cAliasSub	as char
	
	local	nvLinha		as numeric,;
			nLinha		as numeric

	local	cCodProd	as char,;
			cProduto	as char,;
			cUnidade	as char

    cAlias:= oTmpTable:GetAlias()
	cAliasSub:= oTmpSubTab:GetAlias()

	(cAliasSub)->(dbGoTop())
	while !(cAliasSub)->(eof()) 
		if (cAlias)->CNPJ == (cAliasSub)->CNPJ

			cCodProd:= posicione('SA5',14,fwxfilial('SA5')+alltrim((cAliasSub)->CNPJ)+(cAliasSub)->CODPRODFOR,'A5_PRODUTO')
			cProduto:= posicione('SB1',1,fwxfilial('SB1')+cCodProd,'B1_DESC')
			cUnidade:= posicione('SB1',1,fwxfilial('SB1')+cCodProd,'B1_UM')

			nvLinha	:= len(aCols)+1
			aadd(aCols,array((len(aHeader)+1)))
			aCols[nvLinha][len(aHeader)+1]	:= .F.
			nLinha:= len(aCols)
			aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CODPRODFOR'})]	:= (cAliasSub)->CODPRODFOR
			aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PRODFOR'})]		:= (cAliasSub)->PRODFOR
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='UMFOR'})]		:= (cAliasSub)->UMFOR
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='CODPROD'})]		:= cCodProd
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='PROD'})]		:= cProduto
			aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='UM'})]			:= cUnidade
		endif
		(cAliasSub)->(dbSkip())
	enddo

return

user function RD02001FLDOK(oBrw)

	apMsgStop('FieldOk')

	//oBrw:

/*
	local	nX			as numeric,;
			cProduto	as char,;
			cUnidade	as char

	for nX:= 1 to len(oBrw:aCols)
		cProduto:= posicione('SB1',1,fwxFilial('SB1')+oBrw:aCols[nX][4],'B1_DESC')
		cUnidade:= posicione('SB1',1,fwxFilial('SB1')+oBrw:aCols[nX][4],'B1_UM')
		oBrw:aCols[nX][5]:= cProduto
		oBrw:aCols[nX][6]:= cUnidade
	next nX

	oBrw:refresh()
*/
return

static function GChange(oBrw)
	local	nX			as numeric,;
			cProduto	as char,;
			cUnidade	as char

	for nX:= 1 to len(oBrw:aCols)
		cProduto:= posicione('SB1',1,fwxFilial('SB1')+oBrw:aCols[nX][4],'B1_DESC')
		cUnidade:= posicione('SB1',1,fwxFilial('SB1')+oBrw:aCols[nX][4],'B1_UM')
		oBrw:aCols[nX][5]:= cProduto
		oBrw:aCols[nX][6]:= cUnidade
	next nX

	oBrw:refresh()

	//apMsgAlerta('Movimentando-se')
return

static function bSalvar(oBrw,oTmpTable,oTmpSubTab)

	local	cAlias		as char,;
			cAliasSub	as char,;
			nX			as numeric

	local	cCNPJ		as char,;
			cCodFor		as char,;
			cLojaFor	as char,;
			cNomeFor	as char,;
			cCodProdFor	as char,;
			cCodProd	as char,;
			cProd		as char

	cAlias:= oTmpTable:GetAlias()
	cAliasSub:= oTmpSubTab:GetAlias()

	//buscando o fornecedor
	cCNPJ:= (cAlias)->CNPJ
	cCodFor	:= posicione('SA2',3,fwxFilial('SA2')+cCNPJ,'A2_COD')
	cLojaFor:= posicione('SA2',3,fwxFilial('SA2')+cCNPJ,'A2_LOJA')
	cNomeFor:= posicione('SA2',3,fwxFilial('SA2')+cCNPJ,'A2_NOME')

	for nX:= 1 to len(oBrw:aCols)

		cCodProdFor	:= oBrw:aCols[nX][1]
		cCodProd	:= oBrw:aCols[nX][4]
		cProd		:= oBrw:aCols[nX][5]

		dbSelectArea('SA5')
		SA5->(dbSetOrder(1))
		SA5->(dbGoTop())
		if !SA5->(dbSeek(fwxFilial('SA5')+cCodFor+cLojaFor+cCodProd))
			inclui(cCodFor,cLojaFor,cNomeFor,cCodProd,cProd,cCodProdFor)
		else
			altera(cCodFor,cLojaFor,cNomeFor,cCodProd,cProd,cCodProdFor)
		endif
	next nX

return

static function Inclui(cCodFor,cLojaFor,cNomeFor,cCodProd,cProd,cCodProdFor)

	local	oModel		as object,;
			nOpc		as numeric,;
			aLog		as object,;
			cMensLog	as char,;
			nX			as numeric

	nOpc:= 3

//	cCodProdFor:= strzero(val(cCodProdFor),tamSx3('A5_CODPRF')[1])

	oModel:= fwLoadModel('MATA061')
	oModel:setOperation(nOpc)	//incluindo
	oModel:Activate()

	//Cabeçalho
	oModel:SetValue('MdFieldSA5','A5_PRODUTO', cCodProd)
	oModel:SetValue('MdFieldSA5','A5_NOMPROD', cProd)
	
	//Grid
	oModel:SetValue('MdGridSA5','A5_FORNECE', cCodFor)
	oModel:SetValue('MdGridSA5','A5_LOJA'	, cLojaFor)
	oModel:SetValue('MdGridSA5','A5_NOMEFOR', cNomeFor)
	oModel:SetValue('MdGridSA5','A5_CODPRF'	, cCodProdFor)
	
	//Nova linha na Grid
	//oModel:GetModel("MdGridSA5"):AddLine()
	
	if oModel:VldData()
		oModel:CommitData()
	else
		aLog := oModel:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
		cMensLog := ''

		//laco para gravar em string cLog conteudo do array aLog
		for nX := 1 to Len(aLog)
			if !empty(aLog[nX])
				cMensLog += alltrim(aLog[nX]) + chr(13)+chr(10)
			endIf

		next nX

		lMsErroAuto := .T. //seta variavel private como erro
		autoGRLog(cMensLog) //grava log para exibir com funcao mostraerro
		mostraErro()

	endif

	oModel:DeActivate()
	oModel:Destroy()

return

static function Altera(cCodFor,cLojaFor,cNomeFor,cCodProd,cProd,cCodProdFor)

	local	nOpc		as numeric,;
			aLog		as object,;
			cMensLog	as char,;
			nX			as numeric,;
			lFind		as logical

	local	oModel		as object,;
			oGridMod	as object

	nOpc:= 4

	oModel      := FWLoadModel('MATA061')
	oGridMod    := oModel:GetModel("MdGridSA5")
	
	oModel:SetOperation(nOpc)
	oModel:Activate()

	lFind := oGridMod:SeekLine({{"A5_FORNECE",cCodFor},{"A5_LOJA",cLojaFor},{"A5_PRODUTO",cCodProd}})

	if lFind
		oModel:SetValue('MdGridSA5','A5_FORNECE', cCodFor)
		oModel:SetValue('MdGridSA5','A5_LOJA'	, cLojaFor)
		oModel:SetValue('MdGridSA5','A5_NOMEFOR', cNomeFor)
		oModel:SetValue('MdGridSA5','A5_CODPRF'	, cCodFor)
	endif

	if oModel:VldData()
		oModel:CommitData()
	else
		aLog := oModel:GetErrorMessage() //Recupera o erro do model quando nao passou no VldData
		cMensLog := ''

		//laco para gravar em string cLog conteudo do array aLog
		for nX := 1 to Len(aLog)
			if !empty(aLog[nX])
				cMensLog += alltrim(aLog[nX]) + chr(13)+chr(10)
			endIf

		next nX

		lMsErroAuto := .T. //seta variavel private como erro
		autoGRLog(cMensLog) //grava log para exibir com funcao mostraerro
		mostraErro()

	endif

	oModel:DeActivate()
	oModel:Destroy()
 
return
