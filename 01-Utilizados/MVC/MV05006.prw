#include 'prtopdef.ch'
#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'totvs.ch'
#include 'xmlxfun.ch'
#include 'tbiconn.ch'

/*/
===============================================================================================================================
Programa----------: MV05006
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 24/10/2024
===============================================================================================================================
Descrição---------: Este programa serve para CONSULTAR OS PEDIDOS DE VENDA IMPORTADOS
===============================================================================================================================
Uso---------------: MATA410 - Pedido de Vendas
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
user function MV05006()

	local   oBrowse     as object

    local   oTmp        as object,;
            cTmp        as char,;
            aColumns    as object

    Local   cFontUti    as char,;
            oFontAno    as object,;
            oFontSub    as object,;
            oFontSubN   as object,;
            oFontBtn    as object

    local oDlgGrp,oPanGrid

	private cCadastro 	:= '[MV05006] - Consulta de Pedidos Integrados'

    /* Iniciando as variavels de controle */
    cFontUti    := "Tahoma"
    oFontAno    := TFont():New(cFontUti,,-38)
    oFontSub    := TFont():New(cFontUti,,-20)
    oFontSubN   := TFont():New(cFontUti,,-20,,.T.)
    oFontBtn    := TFont():New(cFontUti,,-14)

    aTamanho    := MsAdvSize()
    nJanLarg    := aTamanho[5]
    nJanAltu    := aTamanho[6]

    oTmp:= nil
    cTmp:= ''
    aColumns:= {}

    /* Iniciando tabela temporária */
    cTmp:=  FCriaTMP(@oTmp)
    PreencheDados(@oTmp)
    aColumns:= FCriaColunas()

    dbSelectArea('SC5')
    SC5->(dbSetOrder(1))
    SC5->(dbGoTop())
    SC5->(dbSeek(FWxFilial('SC5')+(cTmp)->NUMPED))

    dbSelectArea('SC6')
    SC6->(dbSetOrder(1))
    SC6->(dbGoTop())
    SC6->(dbSeek(FWxFilial('SC6')+(cTmp)->NUMPED))

    DEFINE MSDIALOG oDlgGrp TITLE cCadastro FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

        //Botões
        @ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar"       SIZE 050, 018 OF oDlgGrp ACTION (oDlgGrp:End()) PIXEL
        //@ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnLege  PROMPT "Importar"     SIZE 050, 018 OF oDlgGrp ACTION (U_MV05005A(@oTmpPedidos)) PIXEL

        //Dados
        @ 033, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "" OF oDlgGrp COLOR 0, 16777215 PIXEL
        oGrpDad:oFont := oFontBtn
        oPanGrid:= tPanel():New(034, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13),     (nJanAltu/2 - 45))

        /* FWmBrowse */
        oBrowse:= FWmBrowse():New()

        oBrowse:SetAlias(cTmp)                
        oBrowse:SetDescription(cCadastro)
        oBrowse:SetTemporary(.T.)
        oBrowse:SetColumns(aColumns)

        oBrowse:SetIgnoreARotina(.T.)
        oBrowse:SetMenuDef('MV05006')

        oBrowse:DisableReport()
        oBrowse:DisableConfig()
        oBrowse:DisableFilter()
        oBrowse:DisableLocate()
        oBrowse:DisableSaveConfig()
        oBrowse:DisableSeek()
        oBrowse:DisableDetails()

        oBrowse:SetOwner(oPanGrid)

        oBrowse:Activate()      

    ACTIVATE MsDialog oDlgGrp CENTERED
	
return

static function MenuDef()

    local aRot	as array

	aRot:= {}
//	add option aRot title 'Liquidar' action 'U_MV06002A()' operation 8 access 0
//	add option aRot title 'Refresh' action 'U_MV06002B()' operation 8 access 0

return (aclone(aRot))

/* CONSTROI ESTRUTURA PARA APRESENTAR NA TELA */
static function Estrutura()
    local   aStruct as array

    aStruct:= {}

    aadd(aStruct, { 'ITEM'      , 'C'		                            , 2		                                    , 0, ''  })
    aadd(aStruct, { 'NUMPED'    , GetSx3Cache('C5_NUM','X3_TIPO')		, GetSx3Cache('C5_NUM','X3_TAMANHO')		, GetSx3Cache('C5_NUM','X3_DECIMAL')    , GetSx3Cache('C5_NUM','X3_PICTURE') })
    aadd(aStruct, { 'SERIE'     , GetSx3Cache('F2_SERIE','X3_TIPO')		, GetSx3Cache('F2_SERIE','X3_TAMANHO')		, GetSx3Cache('F2_SERIE','X3_DECIMAL')  , GetSx3Cache('F2_SERIE','X3_PICTURE') })
    aadd(aStruct, { 'NFISCA'    , GetSx3Cache('F2_DOC','X3_TIPO')		, GetSx3Cache('F2_DOC','X3_TAMANHO')		, GetSx3Cache('F2_DOC','X3_DECIMAL')    , GetSx3Cache('F2_DOC','X3_PICTURE') })
    aadd(aStruct, { 'EMISSAO'   , GetSx3Cache('F2_EMISSAO','X3_TIPO')	, GetSx3Cache('F2_EMISSAO','X3_TAMANHO')	, GetSx3Cache('F2_EMISSAO','X3_DECIMAL'), GetSx3Cache('F2_EMISSAO','X3_PICTURE') })
    aadd(aStruct, { 'VALOR'     , GetSx3Cache('F2_VALBRUT','X3_TIPO')	, GetSx3Cache('F2_VALBRUT','X3_TAMANHO')	, GetSx3Cache('F2_VALBRUT','X3_DECIMAL'), GetSx3Cache('F2_VALBRUT','X3_PICTURE') })
    aadd(aStruct, { 'CODCLI'    , GetSx3Cache('F2_CLIENTE','X3_TIPO')	, GetSx3Cache('F2_CLIENTE','X3_TAMANHO')	, GetSx3Cache('F2_CLIENTE','X3_DECIMAL'), GetSx3Cache('F2_CLIENTE','X3_PICTURE') })
    aadd(aStruct, { 'LOJA'      , GetSx3Cache('F2_LOJA','X3_TIPO')		, GetSx3Cache('F2_LOJA','X3_TAMANHO')		, GetSx3Cache('F2_LOJA','X3_DECIMAL')   , GetSx3Cache('F2_LOJA','X3_PICTURE') })
    aadd(aStruct, { 'CLIENTE'   , GetSx3Cache('A1_NOME','X3_TIPO')		, GetSx3Cache('A1_NOME','X3_TAMANHO')		, GetSx3Cache('A1_NOME','X3_DECIMAL')   , GetSx3Cache('A1_NOME','X3_PICTURE') })

return aStruct

static function FCriaTMP(oTmp)
 
	local	cAliasTmp	as char,;
			aFields		as array

	cAliasTmp	:= 'tmp'+FWTimeStamp(1)
	aFields		:= Estrutura()

    oTmp:= FWTemporaryTable():New(cAliasTmp)
    oTmp:SetFields( aFields )
    oTmp:addIndex('01', {'ITEM'} )

	oTmp:Create()
 
return oTmp:GetAlias()

static function FCriaColunas()

	local	nX			as numeric,;
			aColumns	as array,;
			aStruct		as array
     
	nX       := 0 
	aColumns := {}
	aStruct  := Estrutura()

    for nX := 1 To Len(aStruct)
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStruct[nX][1])
        aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
        aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
        aColumns[Len(aColumns)]:SetPicture(aStruct[nX][5])              
    next nX

return aColumns

static function AbreQry(pSerie,pDoc,pTipo)

    local   cQry    as char

    pSerie:= pSerie
    pDoc:= StrZero(val(pDoc),9)

    cQry    := 'exec PR_MV05006 @pTipo = '+char(39)+cValToChar(pTipo)+char(39)+', @pSerie = '+char(39)+pSerie+char(39)+', @pNumDoc = '+char(39)+pDoc+char(39)+''

    TCQUERY cQry NEW ALIAS 'TB01'

return

static function PreencheDados(oTmp)
	local	cAlias		as char,;
			cError		as char,;
			cWarning	as char,;
            cPerg       as char,;
            nX          as char

	//Iniciando as variaveis
	cAlias:= oTmp:GetAlias()
	cError:= ''
	cWarning:= ''
    cPerg:= 'MV05006'

	pAjustaSx1(cPerg)

	if Pergunte(cPerg,.T.)
        AbreQry(mv_par02,mv_par01,mv_par03)

        //Limpando a tabela temporaria
        dbSelectArea(cAlias)
        (cAlias)->(dbGoTop())
        while !(cAlias)->(eof())
            (cAlias)->(Delete())
            (cAlias)->(dbSkip())
        enddo
        pack

        nX:= '00'
        while !TB01->(eof())
            nX:= Soma1(nX)

            if RecLock(cAlias,.T.)
                (cAlias)->ITEM      := nX
                (cAlias)->NUMPED    := TB01->Z50_NUMPED
                (cAlias)->SERIE     := TB01->F2_SERIE
                (cAlias)->NFISCA    := TB01->F2_DOC
                (cAlias)->EMISSAO   := stod(TB01->F2_EMISSAO)
                (cAlias)->VALOR     := TB01->VALOR
                (cAlias)->CODCLI    := TB01->F2_CLIENTE
                (cAlias)->LOJA      := TB01->F2_LOJA
                (cAlias)->CLIENTE   := TB01->A1_NOME
                (cAlias)->(msunlock())
            endif
            TB01->(dbSkip())

        enddo
        TB01->(dbCloseArea())

    endif

return nil

/*Demais Funções*/
static function pAjustaSx1(cPerg)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Num Doc:'			    , /*cPerSpa		*/ 'Num Doc:'			    , /*cPerEng		*/ 'Num Doc:'			    , ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'E'						, 											  ;
				/*nTamanho	*/ 9						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 							, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par01'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '02'						, 											  ;
				/*cPergunt	*/ 'Série:'			        , /*cPerSpa		*/ 'Série:' 			    , /*cPerEng		*/ 'Série:'		    	    , ;
				/*cVar		*/ 'mv_ch2'					, /*cTipo 		*/ 'E'						, 											  ;
				/*nTamanho	*/ 3						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 							, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par02'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '03'						, 											  ;
				/*cPergunt	*/ 'Tipo:'			        , /*cPerSpa		*/ 'Tipo:' 			        , /*cPerEng		*/ 'Tipo:'		    	    , ;
				/*cVar		*/ 'mv_ch3'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 1						, /*nDecimal	*/ 0						, /*nPresel		*/ 1						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 							, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par03'				, ;
				/*cDef01	*/ '1 - Nota Fiscal'		, /*cDefSpa1	*/ '1 - Nota Fiscal'		, /*cDefEng1	*/ '1 - Nota Fiscal'		, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ '2 - Doc (Ger)  '		, /*cDefSpa2	*/ '2 - Doc (Ger)  '		, /*cDefEng2	*/ '2 - Doc (Ger)  '		, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

return
