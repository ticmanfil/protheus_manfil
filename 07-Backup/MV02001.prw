#include 'prtopdef.ch'
#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'totvs.ch'
#include 'xmlxfun.ch'

/*/
===============================================================================================================================
Programa----------: MV02001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/09/2024
===============================================================================================================================
Descrição---------: Este programa serve para FAZER AS AMARRAÇÕES FORNECEDOR X PRODUTOS
===============================================================================================================================
Uso---------------: COMXCOL - Importador XML
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
===============================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|           | 																										
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/
user function MV02001()

	local	oBrowse		as object,;
			aArea,;
			oTmpTable	as object,;
			cTmpTable	as char,;
			aColumns	as object,;
			oTmpSubTab	as object,;
			cTmpSubTab	as char,;
			aColumnsSub	as object

	private	cCadastro 	as char
			
	cCadastro:= '[MV02001] - Amarração FORNECEDOR x PRODUTOS'

	aArea		:= getArea()
	oTmpTable	:= nil
	cTmpTable	:= ''
	aColumns	:= {}

	//construindo a tabela temporario dos fornecedores
	cTmpTable	:= fBuildTmp(@oTmpTable,1)
	cTmpSubTab	:= fBuildTmp(@oTmpSubTab,2)
	PreencheDados(@oTmpTable,@oTmpSubTab)

    //Constrói estrutura das colunas do FWMarkBrowse
    aColumns := fBuildColumns(1)
	aColumnsSub:= fBuildColumns(2)
     
    //Criando o FWMarkBrowse
    oBrowse:= FWmBrowse():New()
    oBrowse:SetAlias(cTmpTable)                
    oBrowse:SetDescription(cCadastro)
    oBrowse:DisableReport()
    oBrowse:SetTemporary(.T.)
    oBrowse:SetColumns(aColumns)
//	oBrowse:DisableDetails()

	//oBrowse:addbutton("Detalhe",{|| bDetalhe(@oTmpTable,@oTmpSubTab)  },,2,,.F.)
	oBrowse:addbutton('Amarrações',{|| bAmarracoes(@oTmpTable,@oTmpSubTab)  },,2,,.F.)

    //Ativando a janela
    oBrowse:Activate()
         
    oTmpTable:Delete()
    oBrowse:DeActivate()
    FreeObj(oTmpTable)
    FreeObj(oBrowse)
    restArea(aArea)

return

/* CRIANDO A ESTUTURA DAS TABELAS TEMPORARIA */
static function fBuildTmp(oTmpTable,pTipo)
 
	local	cAliasTmp	as char,;
			aFields		as array

	WaitAMinute()
	cAliasTmp	:= 'ZMARC_'+FWTimeStamp(1)
	aFields		:= {}

	//Monta estrutura de campos da temporária
	if pTipo = 1	//cabecalho
		aadd(aFields, { 'CNPJ'			, GetSx3Cache('A2_CGC','X3_TIPO')		, GetSx3Cache('A2_CGC','X3_TAMANHO')		, GetSx3Cache('A2_CGC','X3_DECIMAL') })
		aadd(aFields, { 'FORNECEDOR'	, GetSx3Cache('A2_NOME','X3_TIPO')		, GetSx3Cache('A2_NOME','X3_TAMANHO')		, GetSx3Cache('A2_NOME','X3_DECIMAL') })
		aadd(aFields, { 'CODERRO'		, GetSx3Cache('CKO_CODERR','X3_TIPO')	, GetSx3Cache('CKO_CODERR','X3_TAMANHO')	, GetSx3Cache('CKO_CODERR','X3_DECIMAL') })
			
		oTmpTable:= FWTemporaryTable():New(cAliasTmp)
		oTmpTable:SetFields( aFields )
		oTmpTable:addIndex('01', {'FORNECEDOR'} )

	elseif pTipo = 2	//itens
		aadd(aFields, { 'CNPJ'			, GetSx3Cache('A2_CGC','X3_TIPO')		, GetSx3Cache('A2_CGC','X3_TAMANHO')		, GetSx3Cache('A2_CGC','X3_DECIMAL') })
		aadd(aFields, { 'CODPRODFOR'	, GetSx3Cache('B1_COD','X3_TIPO')		, GetSx3Cache('B1_COD','X3_TAMANHO')	, GetSx3Cache('B1_COD','X3_DECIMAL') })
		aadd(aFields, { 'PRODFOR'		, GetSx3Cache('B1_DESC','X3_TIPO')		, GetSx3Cache('B1_DESC','X3_TAMANHO')	, GetSx3Cache('B1_DESC','X3_DECIMAL') })
		aadd(aFields, { 'UMFOR'			, GetSx3Cache('B1_UM','X3_TIPO')		, GetSx3Cache('B1_UM','X3_TAMANHO')		, GetSx3Cache('B1_UM','X3_DECIMAL') })
		aadd(aFields, { 'CODPROD'		, GetSx3Cache('B1_COD','X3_TIPO')		, GetSx3Cache('B1_COD','X3_TAMANHO')	, GetSx3Cache('B1_COD','X3_DECIMAL') })
		aadd(aFields, { 'PROD'			, GetSx3Cache('B1_DESC','X3_TIPO')		, GetSx3Cache('B1_DESC','X3_TAMANHO')	, GetSx3Cache('B1_DESC','X3_DECIMAL') })
		aadd(aFields, { 'UM'			, GetSx3Cache('B1_UM','X3_TIPO')		, GetSx3Cache('B1_UM','X3_TAMANHO')		, GetSx3Cache('B1_UM','X3_DECIMAL') })
			
		oTmpTable:= FWTemporaryTable():New(cAliasTmp)
		oTmpTable:SetFields( aFields )
		oTmpTable:AddIndex('01', {'CNPJ','CODPRODFOR'} )

	endif
	
	oTmpTable:Create()
 
return oTmpTable:GetAlias()

/* ALIMENTANDO DADOS DO FORNECEDOR */
static function PreencheDados(oTmpTable,oTmpSubTab)
	local	cAlias		as char,;
			cAliasSub	as char,;
			oXML		as object,;
			cXML		as char,;
			cError		as char,;
			cWarning	as char

	local	aXml		as array,;
			aFornecedor	as array,;
			aProdutos	as array,;
			nX			as numeric,;
			aXmlItem	as array,;
			aAuxItem	as array,;
			aItens		as array,;
			cCNPJ		as char,;
			cPesqFor	as char,;
			cCodProdFor	as char,;
			cCodProd	as char,;
			cProduto	as char,;
			cUnidade	as char

	//Iniciando as variaveis
	cAlias:= oTmpTable:GetAlias()
	cAliasSub:= oTmpSubTab:GetAlias()
	cError:= ''
	cWarning:= ''

	aXml		:= {}
	aFornecedor	:= {}
	aProdutos	:= {}
	nPos		:= 0
	nX			:= 0
	aXmlItem	:= {}
	aAuxItem	:= {}
	aItens		:= {}

	dbSelectArea('CKO')
	CKO->(dbSetOrder(1))
	CKO->(dbGoTop())
	while !CKO->(eof()) .and. CKO_CODEDI == '109'
		if alltrim(CKO->CKO_CODERR) <> ''

			cXML:= CKO->CKO_XMLRET

			oXML:= XmlParser(cXML,'_',@cError,@cWarning)
			if oXML == nil .or. len(cError) > 0 .or. len(cWarning) > 0
				msErro('Erro ao gerar o XML: '+cError+' - '+cWarning)
			else
				aXml:= {}
				cCNPJ:= alltrim(oXML:_NFEPROC:_NFe:_infNFe:_emit:_CNPJ:TEXT)
				cPesqFor:= substr(cCNPJ,1,12)
				aadd(aXml,cCNPJ)
				aadd(aXml,upper(alltrim(oXML:_NFEPROC:_NFe:_infNFe:_emit:_XNome:TEXT)))
				aadd(aXml,alltrim(CKO->CKO_MSGERR))
				if !Exists(1,aFornecedor,aXml[1])
					aadd(aFornecedor,aXml)
				endif

				if valtype(oXML:_NFEPROC:_NFe:_infNFe:_det) == 'A'
					for nX:= 1 to len(oXML:_NFEPROC:_NFe:_infNFe:_det)
						aXmlItem:= {}
						cCodProdFor:= ''
						cCodProd:= ''
						cProduto:= ''
						cUnidade:= ''
						cCodProdFor:= alltrim(oXML:_NFEPROC:_NFe:_infNFe:_det[nX]:_Prod:_cProd:TEXT)
						cCodProd:= posicione('SA5',14,fwxFilial('SA5')+cPesqFor+cCodProdFor,'A5_PRODUTO')
						cProduto:= posicione('SB1',1,fwxFilial('SB1')+cCodProd,'B1_DESC')
						cUnidade:= posicione('SB1',1,fwxFilial('SB1')+cCodProd,'B1_UM')
						aadd(aXmlItem,alltrim(oXML:_NFEPROC:_NFe:_infNFe:_emit:_CNPJ:TEXT))
						aadd(aXmlItem,cCodProdFor)
						aadd(aXmlItem,alltrim(oXML:_NFEPROC:_NFe:_infNFe:_det[nX]:_Prod:_xProd:TEXT))
						aadd(aXmlItem,alltrim(oXML:_NFEPROC:_NFe:_infNFe:_det[nX]:_Prod:_uCom:TEXT))
						aadd(aXmlItem,cCodProd)
						aadd(aXmlItem,cProduto)
						aadd(aXmlItem,cUnidade)
						if !Exists(2,aItens,aXmlItem[1]+aXmlItem[2])
							aadd(aItens,aXmlItem)
						endif
					next nX
				else
					aXmlItem:= {}
					cCodProdFor:= ''
					cCodProd:= ''
					cProduto:= ''
					cUnidade:= ''
					cCodProdFor:= cValToChar(val(oXML:_NFEPROC:_NFe:_infNFe:_det:_Prod:_cProd:TEXT))
					cCodProd:= posicione('SA5',14,fwxFilial('SA5')+cCNPJ+cCodProdFor,'A5_PRODUTO')
					cProduto:= posicione('SB1',1,fwxFilial('SB1')+cCodProd,'B1_DESC')
					cUnidade:= posicione('SB1',1,fwxFilial('SB1')+cCodProd,'B1_UM')
					aadd(aXmlItem,alltrim(oXML:_NFEPROC:_NFe:_infNFe:_emit:_CNPJ:TEXT))
					aadd(aXmlItem,cCodProdFor)
					aadd(aXmlItem,alltrim(oXML:_NFEPROC:_NFe:_infNFe:_det:_Prod:_xProd:TEXT))
					aadd(aXmlItem,alltrim(oXML:_NFEPROC:_NFe:_infNFe:_det:_Prod:_uCom:TEXT))
					aadd(aXmlItem,cCodProd)
					aadd(aXmlItem,cProduto)
					aadd(aXmlItem,cUnidade)
					if !Exists(2,aItens,aXmlItem[1]+aXmlItem[2])
						aadd(aItens,aXmlItem)
					endif
				endif

			endif
			oXML:= nil
		endif
		CKO->(dbSkip())
	enddo

	for nX:= 1 to len (aFornecedor)
		if RecLock(cAlias,.T.)
			(cAlias)->CNPJ			:= aFornecedor[nX][1]
			(cAlias)->FORNECEDOR	:= aFornecedor[nX][2]
			(cAlias)->CODERRO		:= aFornecedor[nX][3]
			(cAlias)->(msUnlock())
		endif
	next nX

	for nX:= 1 to len (aItens)
		if RecLock(cAliasSub,.T.)
			(cAliasSub)->CNPJ		:= aItens[nX][1]
			(cAliasSub)->CODPRODFOR	:= aItens[nX][2]
			(cAliasSub)->PRODFOR	:= aItens[nX][3]
			(cAliasSub)->UMFOR		:= aItens[nX][4]
			(cAliasSub)->CODPROD	:= aItens[nX][5]
			(cAliasSub)->PROD		:= aItens[nX][6]
			(cAliasSub)->UM			:= aItens[nX][7]
			(cAliasSub)->(msUnlock())
		endif
	next nX

return nil

/* CONSTROI ESTRUTURA PARA APRESENTAR NA TELA */
static function fBuildColumns(pTipo)

	local	nX			as numeric,;
			aColumns	as array,;
			aStruct		as array
     
	nX       := 0 
	aColumns := {}
	aStruct  := {}

	if pTipo = 1	//cabecalho
		//Monta estrutura de campos da temporária
		aadd(aStruct, { 'CNPJ'			, GetSx3Cache('A2_CGC','X3_TIPO')		, GetSx3Cache('A2_CGC','X3_TAMANHO')		, GetSx3Cache('A2_CGC','X3_DECIMAL') })
		aadd(aStruct, { 'FORNECEDOR'	, GetSx3Cache('A2_NOME','X3_TIPO')		, GetSx3Cache('A2_NOME','X3_TAMANHO')		, GetSx3Cache('A2_NOME','X3_DECIMAL') })
		aadd(aStruct, { 'CODERRO'		, GetSx3Cache('CKO_CODERR','X3_TIPO')	, GetSx3Cache('CKO_CODERR','X3_TAMANHO')	, GetSx3Cache('CKO_CODERR','X3_DECIMAL') })

		for nX := 1 To Len(aStruct)
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(aStruct[nX][1])
			aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
			aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])              
		next nX

	elseif pTipo = 2	//itens
		aadd(aStruct, { 'CNPJ'			, GetSx3Cache('A2_CGC','X3_TIPO')		, GetSx3Cache('A2_CGC','X3_TAMANHO')	, GetSx3Cache('A2_CGC','X3_DECIMAL') })
		aadd(aStruct, { 'CODPRODFOR'	, GetSx3Cache('B1_COD','X3_TIPO')		, GetSx3Cache('B1_COD','X3_TAMANHO')	, GetSx3Cache('B1_COD','X3_DECIMAL') })
		aadd(aStruct, { 'PRODFOR'		, GetSx3Cache('B1_DESC','X3_TIPO')		, GetSx3Cache('B1_DESC','X3_TAMANHO')	, GetSx3Cache('B1_DESC','X3_DECIMAL') })
		aadd(aStruct, { 'UMFOR'			, GetSx3Cache('B1_UM','X3_TIPO')		, GetSx3Cache('B1_UM','X3_TAMANHO')		, GetSx3Cache('B1_UM','X3_DECIMAL') })
		aadd(aStruct, { 'CODPROD'		, GetSx3Cache('B1_COD','X3_TIPO')		, GetSx3Cache('B1_COD','X3_TAMANHO')	, GetSx3Cache('B1_COD','X3_DECIMAL') })
		aadd(aStruct, { 'PROD'			, GetSx3Cache('B1_DESC','X3_TIPO')		, GetSx3Cache('B1_DESC','X3_TAMANHO')	, GetSx3Cache('B1_DESC','X3_DECIMAL') })
		aadd(aStruct, { 'UM'			, GetSx3Cache('B1_UM','X3_TIPO')		, GetSx3Cache('B1_UM','X3_TAMANHO')		, GetSx3Cache('B1_UM','X3_DECIMAL') })
			
		for nX := 1 To Len(aStruct)
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(aStruct[nX][1])
			aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
			aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])              
		next nX

	endif

return aColumns

static function bDetalhe(oTmpTable,oTmpSubTab)
	//u_msgInformation('Botão detalhe')
	U_RD02001(@oTmpTable,@oTmpSubTab)
return

static function Exists(pTp,paFonte,pPesquisar)
	local	lRet	as logical,;
			nX		as numeric

	//iniciando as variaveis
	nX:= 0
	lRet:= .F.

	if pTp = 1	//pesquisa simples
		for nX:= 1 to len(paFonte)
			if alltrim(paFonte[nX][1]) == alltrim(pPesquisar)
				lRet:= .T.
				exit
			endif
		next nX

	elseif pTp = 2 //pesquisa em segundo nivel
		for nX:= 1 to len(paFonte)
			if alltrim(paFonte[nX][1])+alltrim(paFonte[nX][2]) == alltrim(pPesquisar)
				lRet:= .T.
				exit
			endif
		next nX

	endif

return lRet

static function bAmarracoes(oTmpTable,oTmpSubTab)
	local	aArea			as array,;
			aAreaSA2		as array,;
			aAreaSA5		as array,;
			cAliasTmp		as char,;
			cAliasTmpSub	as char,;
			cCNPJ			as char,;
			cCodFor			as char,;
			cLojafor		as char,;
			cNomeFor		as char,;
			cNReduzFor		as char

	aArea			:= getArea()
	aAreaSA2		:= SA2->(getArea())
	aAreaSA5		:= SA5->(getArea())
	cAliasTmp		:= oTmpTable:GetAlias()
	cAliasTmpSub	:= oTmpSubTab:GetAlias()

	cCNPJ		:= (cAliasTmp)->CNPJ
	cCodFor		:= posicione('SA2',3,FWxFilial('SA2')+cCNPJ,'A2_COD')
	clojaFor	:= posicione('SA2',3,FWxFilial('SA2')+cCNPJ,'A2_LOJA')
	cNomeFor	:= posicione('SA2',3,FWxFilial('SA2')+cCNPJ,'A2_NOME')
	cNReduzFor	:= posicione('SA2',3,FWxFilial('SA2')+cCNPJ,'A2_NREDUZ')

	//PREENCHER NA SA5 TODOS OS PRODUTOS DO FORNECEDOR SELECIONADO
	dbSelectArea(cAliasTmpSub)
	(cAliasTmpSub)->(dbSetOrder(1))
	(cAliasTmpSub)->(dbGoTop())
	if (cAliasTmpSub)->(dbSeek(cCNPJ))
		while !(cAliasTmpSub)->(eof()) .and. (cAliasTmpSub)->CNPJ == cCNPJ
			dbSelectArea('SA5')
			SA5->(dbSetOrder(14))
			SA5->(dbGoTop())
			if !SA5->(dbSeek(fwxFilial('SA5')+cCodFor+clojaFor+(cAliasTmpSub)->CODPRODFOR))
				if RecLock('SA5',.T.)
					SA5->A5_FILIAL	:= FWxFilial('SA5')
					SA5->A5_FORNECE	:= cCodFor
					SA5->A5_LOJA	:= cLojafor
					SA5->A5_NOMEFOR	:= cNomeFor
					SA5->A5_CODPRF	:= (cAliasTmpSub)->CODPRODFOR
					SA5->(msUnlock())
				endif
			endif

			(cAliasTmpSub)->(dbSkip())
		enddo
	endif
	
	dbSelectArea('SA2')
	SA2->(dbSetOrder(1))
	SA2->(dbGoTop())
	SA2->(dbSeek(fwxFilial('SA2')+cCNPJ))

	FWExecView('Amarrações Fornecedor x Produtos','MV02002', MODEL_OPERATION_UPDATE,, { || .T. },,30 )

	SA5->(dbCloseArea())
	SA2->(dbCloseArea())

	restArea(aAreaSA5)
	restArea(aAreaSA2)
	restArea(aArea)

return 
