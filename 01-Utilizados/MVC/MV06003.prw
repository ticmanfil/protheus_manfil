#include 'prtopdef.ch'
#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'totvs.ch'
#include 'xmlxfun.ch'
#include 'tbiconn.ch'

/*/
===============================================================================================================================
Programa----------: MV06003
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 31/10/2024
===============================================================================================================================
Descrição---------: Este programa serve para CONSULTAR OS TITULOS NAO INTEGRADOS DO FISCAL
===============================================================================================================================
Uso---------------: FIN740 - CONTAS A RECEBER
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
user function MV06003()

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

	private cCadastro 	:= '[MV06003] - Consulta Contas a Receber Integrados'

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

    DEFINE MSDIALOG oDlgGrp TITLE cCadastro FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

        //Botões
        @ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar"       SIZE 050, 018 OF oDlgGrp ACTION (oDlgGrp:End()) PIXEL
        @ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnLege  PROMPT "Localizar"    SIZE 050, 018 OF oDlgGrp ACTION (MV06003A(@oTmp), oDlgGrp:End()) PIXEL

        //Dados
        @ 033, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "" OF oDlgGrp COLOR 0, 16777215 PIXEL
        oGrpDad:oFont := oFontBtn
        oPanGrid:= tPanel():New(035, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13),     (nJanAltu/2 - 45))

        /* FWmBrowse */
        oBrowse:= FWmBrowse():New()

        oBrowse:SetAlias(cTmp)                
        oBrowse:SetDescription(cCadastro)
        oBrowse:SetTemporary(.T.)
        oBrowse:SetColumns(aColumns)

        oBrowse:SetIgnoreARotina(.T.)
        oBrowse:SetMenuDef('MV06003')

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
	
    dbSelectArea('SE1')
    SE1->(dbSetOrder(1))
    SE1->(dbGoTop())
    SE1->(dbSeek(FWxFilial('SE1')+(cTmp)->SERIE+(cTmp)->NFISCA))

    oTmp:Delete()
    oBrowse:DeActivate()
    FreeObj(oTmp)
    FreeObj(oBrowse)

return

static function MenuDef()

    local aRot	as array

	aRot:= {}
	//add option aRot title 'Localizar' action 'MV06003A()' operation 8 access 0

return (aclone(aRot))

/* CONSTROI ESTRUTURA PARA APRESENTAR NA TELA */
static function Estrutura()
    local   aStruct as array

    aStruct:= {}

    aadd(aStruct, { 'SERIE'     , GetSx3Cache('F2_SERIE','X3_TIPO')		, GetSx3Cache('F2_SERIE','X3_TAMANHO')		, GetSx3Cache('F2_SERIE','X3_DECIMAL')  , GetSx3Cache('F2_SERIE','X3_PICTURE') })
    aadd(aStruct, { 'NFISCA'    , GetSx3Cache('F2_DOC','X3_TIPO')		, GetSx3Cache('F2_DOC','X3_TAMANHO')		, GetSx3Cache('F2_DOC','X3_DECIMAL')    , GetSx3Cache('F2_DOC','X3_PICTURE') })

return aStruct

static function FCriaTMP(oTmp)
 
	local	cAliasTmp	as char,;
			aFields		as array

	cAliasTmp	:= 'tmp'+FWTimeStamp(1)
	aFields		:= Estrutura()

    oTmp:= FWTemporaryTable():New(cAliasTmp)
    oTmp:SetFields( aFields )
    oTmp:addIndex('01', {'SERIE','NFISCA'} )

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

static function AbreQry(pIDCnab)

    local   cQry    as char

    cQry    := 'exec PR_MV06003 @P_NUMBCO = '+char(39)+pIDCnab+char(39)+''

    TCQUERY cQry NEW ALIAS 'TB01'

return

static function PreencheDados(oTmp)
	local	cAlias		as char,;
            cPerg       as char

	//Iniciando as variaveis
	cAlias  := oTmp:GetAlias()
    cPerg   := 'MV06003'

	pAjustaSx1(cPerg)

	if Pergunte(cPerg,.T.)

        AbreQry(mv_par01)

        //Limpando a tabela temporaria
        dbSelectArea(cAlias)
        (cAlias)->(dbGoTop())
        while !(cAlias)->(eof())
            (cAlias)->(Delete())
            (cAlias)->(dbSkip())
        enddo
        pack

        while !TB01->(eof())
            if RecLock(cAlias,.T.)
                (cAlias)->SERIE     := TB01->Z50_SERIE
                (cAlias)->NFISCA    := TB01->Z50_NFISCA
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
				/*cPergunt	*/ 'IDCnab:'			    , /*cPerSpa		*/ 'IDCnab:'			    , /*cPerEng		*/ 'IDCnab:'			    , ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 15						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
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

return

static function MV06003A(oTmp)
    local   cAlias  as char

    cAlias  := oTmp:GetAlias()
    
    dbSelectArea('SE1')
    SE1->(dbSetOrder(1))
    SE1->(dbGoTop())
    SE1->(dbSeek(xFilial('SE1')+(cAlias)->SERIE+(cAlias)->NFISCA))

return
