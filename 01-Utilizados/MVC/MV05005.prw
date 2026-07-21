#include 'prtopdef.ch'
#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'totvs.ch'
#include 'xmlxfun.ch'
#include 'tbiconn.ch'

/*/
===============================================================================================================================
Programa----------: MV02001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 02/10/2024
===============================================================================================================================
Descrição---------: Este programa serve para REALIZAR A NOVA IMPORTAÇÃO DO PEDIDO DE VENDA NO FISCAL
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
user function MV05005()

    local   oBrw         as object,;
            aColumns    as array,;
            oTmpPedidos as object,;
            cTmpPedidos as char

    Local   cFontUti    as char,;
            oFontAno    as object,;
            oFontSub    as object,;
            oFontSubN   as object,;
            oFontBtn    as object

    local oDlgGrp,oPanGrid

    //Tamanho da janela
    local   aTamanho    as object,;
            nJanLarg    as numeric,;
            nJanAltu    as numeric
    
    private cTitulo     as char

    //iniciando as variaveis
    cTitulo     := '[MV05005] - Importação de Pedidos de Vendas'
    oBrowse     := nil
    aColumns    := {}
    oTmpPedidos := nil
    cTmpPedidos := ''

    cFontUti    := "Tahoma"
    oFontAno    := TFont():New(cFontUti,,-38)
    oFontSub    := TFont():New(cFontUti,,-20)
    oFontSubN   := TFont():New(cFontUti,,-20,,.T.)
    oFontBtn    := TFont():New(cFontUti,,-14)

    aTamanho    := MsAdvSize()
    nJanLarg    := aTamanho[5]
    nJanAltu    := aTamanho[6]

    //construi as tabelas temporarias
    cTmpPedidos:= CriaTemp(@oTmpPedidos)

    PreencheDados(@oTmpPedidos)

    aColumns:= BuscaColums(@oTmpPedidos)

    DEFINE MSDIALOG oDlgGrp TITLE cTitulo FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

        //Botões
        //@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnFech  PROMPT "Fechar"       SIZE 050, 018 OF oDlgGrp ACTION (oDlgGrp:End()) PIXEL
        //@ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnLege  PROMPT "Importar"     SIZE 050, 018 OF oDlgGrp ACTION (U_MV05005A(@oTmpPedidos)) PIXEL
  
        //Dados
        @ 006, 003 GROUP oGrpDad TO (nJanAltu/2-003), (nJanLarg/2-003) PROMPT "" OF oDlgGrp COLOR 0, 16777215 PIXEL
        oGrpDad:oFont := oFontBtn
        oPanGrid:= tPanel():New(009, 006, "", oDlgGrp, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13),     (nJanAltu/2 - 45))
  
        oBrw:= FWMarkBrowse():New()
        oBrw:SetAlias(cTmpPedidos)
        oBrw:SetTemporary(.T.)
        oBrw:SetFieldMark('OK')
        oBrw:SetSemaphore(.T.)
        oBrw:SetIgnoreARotina(.T.)
        oBrw:SetMenuDef('MV05005')
        //oBrw:SetFieldFilter(aColumns)

        oBrw:SetDescription(cTitulo)
        oBrw:SetColumns(aColumns)

        //oBrw:DisableFilter()
        //oBrw:DisableConfig()
        //oBrw:DisableReport()
        //oBrw:DisableSeek()
        oBrw:DisableSaveConfig()
        oBrw:DisableDetails()
        oBrw:DisableReport()
        oBrw:ForceQuitButton()

        oBrw:addButton('Importar', {|| U_MV05005A(@oTmpPedidos,@oBrw,@oDlgGrp) }, nil, 3, nil, [ lNeedFind], [ nRealOpc], [ cOperatId], [ cToolBar])

        oBrw:SetOwner(oPanGrid)
        oBrw:Activate()
    ACTIVATE MsDialog oDlgGrp CENTERED

    //fechando formulario
    oTmpPedidos:Delete()
    oBrw:deActivate()

    FreeObj(oTmpPedidos)
    FreeObj(oBrw)

return

static function BuscaEstrutura()

    local   aCampos as array

    aCampos:= {}

    aadd(aCampos,{'SERIE'       , getSx3cache('F2_SERIE','X3_TIPO')     , getSx3cache('F2_SERIE','X3_TAMANHO')      , getSx3cache('F2_SERIE','X3_DECIMAL')      , getSx3cache('F2_SERIE','X3_PICTURE')      })
    aadd(aCampos,{'DOCUMENTO'   , getSx3cache('F2_DOC','X3_TIPO')       , getSx3cache('F2_DOC','X3_TAMANHO')        , getSx3cache('F2_DOC','X3_DECIMAL')        , getSx3cache('F2_DOC','X3_PICTURE')        })
    aadd(aCampos,{'EMISSAO'     , getSx3cache('F2_EMISSAO','X3_TIPO')   , getSx3cache('F2_EMISSAO','X3_TAMANHO')    , getSx3cache('F2_EMISSAO','X3_DECIMAL')    , getSx3cache('F2_EMISSAO','X3_PICTURE')    })
    aadd(aCampos,{'CODCLIENTE'  , getSx3cache('F2_CLIENTE','X3_TIPO')   , getSx3cache('F2_CLIENTE','X3_TAMANHO')    , getSx3cache('F2_CLIENTE','X3_DECIMAL')    , getSx3cache('F2_CLIENTE','X3_PICTURE')    })
    aadd(aCampos,{'LOJA'        , getSx3cache('F2_LOJA','X3_TIPO')      , getSx3cache('F2_LOJA','X3_TAMANHO')       , getSx3cache('F2_LOJA','X3_DECIMAL')       , getSx3cache('F2_LOJA','X3_PICTURE')       })
    aadd(aCampos,{'CLIENTE'     , getSx3cache('A1_NOME','X3_TIPO')      , getSx3cache('A1_NOME','X3_TAMANHO')       , getSx3cache('A1_NOME','X3_DECIMAL')       , getSx3cache('A1_NOME','X3_PICTURE')       })
    aadd(aCampos,{'VALOR'       , getSx3cache('F2_VALBRUT','X3_TIPO')   , getSx3cache('F2_VALBRUT','X3_TAMANHO')    , getSx3cache('F2_VALBRUT','X3_DECIMAL')    , getSx3cache('F2_VALBRUT','X3_PICTURE')    })
    aadd(aCampos,{'ESTADO'      , getSx3cache('F2_EST','X3_TIPO')       , getSx3cache('F2_EST','X3_TAMANHO')        , getSx3cache('F2_EST','X3_DECIMAL')        , getSx3cache('F2_EST','X3_PICTURE')        })
    aadd(aCampos,{'OK'          , getSx3cache('F2_OK','X3_TIPO')        , getSx3cache('F2_OK','X3_TAMANHO')         , getSx3cache('F2_OK','X3_DECIMAL')         , getSx3cache('F2_OK','X3_PICTURE')         })
    
return aCampos

static function CriaTemp(oTmp)

    local   cAlias  as char,;
            aFields as array

    //iniciando as variaveis
    cAlias  := 'tmp'+FWTimeStamp(1)
    aFields := BuscaEstrutura()

    oTmp:= FWTemporaryTable():New(cAlias)
    oTmp:SetFields(aFields)
    oTmp:addIndex('01',{'SERIE','DOCUMENTO'})
    oTmp:Create()

return oTmp:GetAlias()

static function PreencheDados(oTmp)

    local   cAlias  as char,;
            cQry    as char,;
            cPerg   as char,;
            dData   as char,;
            cNumDoc as char,;
            cSerie  as char,;
            cCodCli as char

    cAlias  := oTmp:getAlias()
    cPerg   := 'MV05005'

	pAjustaSX1(cPerg)

	if Pergunte(cPerg,.T.)
        dData   := iif(empty(dtos(mv_par01)),'',dtos(mv_par01))
        cNumDoc := iif(empty(mv_par02),'',strzero(val(mv_par02),9))
        cSerie  := iif(empty(mv_par03),'',mv_par03)
        cCodCli := iif(empty(mv_par04),'',mv_par04)

        cQry    := 'exec PR_MV05005 @pDATA = '+char(39)+dData+char(39)+', @pNumDoc = '+char(39)+cNumDoc+char(39)+', @pSerie = '+char(39)+cSerie+char(39)+', @pCliente = '+char(39)+cCodCli+char(39)+''

        //Limpando a tabela temporaria
        dbSelectArea(cAlias)
        (cAlias)->(dbGoTop())
        while !(cAlias)->(eof())
            (cAlias)->(Delete())
            (cAlias)->(dbSkip())
        enddo
        pack
        
        //Preenchendo com novos dados
        TCQUERY cQry NEW ALIAS 'TB01'
        dbSelectArea('TB01')
        while !TB01->(eof())
            if TB01->F2_VALBRUT > 0
                if RecLock(cAlias,.T.)
                    (cAlias)->SERIE     := TB01->F2_SERIE
                    (cAlias)->DOCUMENTO := TB01->F2_DOC
                    (cAlias)->EMISSAO   := stod(TB01->F2_EMISSAO)
                    (cAlias)->CODCLIENTE:= TB01->F2_CLIENTE
                    (cAlias)->LOJA      := TB01->F2_LOJA
                    (cAlias)->CLIENTE   := TB01->F2_XCLIENTE
                    (cAlias)->VALOR     := TB01->F2_VALBRUT
                    (cAlias)->ESTADO    := TB01->F2_EST
                    (cAlias)->(msunlock())
                endif
            endif
            TB01->(dbSkip())

        enddo
        TB01->(dbCloseArea())

    endif

return

static function BuscaColums(oTmp)

    local   nX          as numeric,;
            aColumns    as array,;
            aStruct     as array

    //iniciando as variaveis
    nX          := 0
    aColumns    := {}
    aStruct     := BuscaEstrutura()

    for nX := 1 To Len(aStruct)
        aadd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStruct[nX][1])
        aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
        aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
        aColumns[Len(aColumns)]:SetPicture(aStruct[nX][5])
    next nX

return aColumns

user function MV05005A(oTmp,oBrw,oDlgGrp)

    local   aArea       as object

    local   cAlias      as char,;
            cmark       as object,;
            aPedidos    as array,;
            nTotal      as numeric,;
            lOk         as logical

    aArea:= getArea()

    cAlias:= oTmp:getAlias()
    cmark:= oBrw:mark()
    aPedidos:= {}
    nTotal:= 0
    lOk:= .F.

    dbSelectArea((cAlias))
    (cAlias)->(dbGoTop())
    while !(cAlias)->(eof())
        if oBrw:IsMark(cmark)
            aadd(aPedidos,{(cAlias)->CODCLIENTE,(cAlias)->LOJA,(cAlias)->SERIE,(cAlias)->DOCUMENTO,(cAlias)->CLIENTE,(cAlias)->ESTADO,'X'})
            nTotal+= (cAlias)->VALOR
        endif
        (cAlias)->(dbSkip())
    enddo
    (cAlias)->(dbGoTop())

    if !empty(aPedidos)
        if u_msgPergunta('Foram selecionado(s) '+cvaltochar(len(aPedidos))+' pedidos. Total R$ '+transform(nTotal,'@E 999,999,999.99')+CRLF+;
                        'Deseja integra?',cTitulo) = 6
            FWMsgRun(,{|| lOk:= u_FIntPed(aPedidos)},'Processando','Integrando registros...')
            if lOk
                u_msgInforma('Pedido integrado com sucesso!','[MV05005] - Importando Pedidos')
                oDlgGrp:End()
            else
                u_msgErro('Erro ao integrar PEDIDOS!','[MV05005] - Importando Pedidos')
            endif
        endif
    else
        u_msgInforma('Seleciona pedidos antes de importar! ')
    endif

    restArea(aArea)

	dbSelectArea('SC5')
    SC5->(dbCloseArea())
    dbSelectArea('SC5')
	SC5->(dbSetOrder(1))
	SC5->(dbGoBottom())

return

static function pAjustaSx1(cPerg)

//	local lRet

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Data mínima:'			, /*cPerSpa		*/ 'Data mínima:'			, /*cPerEng		*/ 'Data mínima:'			, ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'D'						, 											  ;
				/*nTamanho	*/ 8						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
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
				/*cPergunt	*/ 'Num Doc:'			    , /*cPerSpa		*/ 'Num Doc:'			    , /*cPerEng		*/ 'Num Doc:'			    , ;
				/*cVar		*/ 'mv_ch2'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 9						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
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
				/*cPergunt	*/ 'Série:'			        , /*cPerSpa		*/ 'Série:' 			    , /*cPerEng		*/ 'Série:'		    	    , ;
				/*cVar		*/ 'mv_ch3'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 3						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 							, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par03'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '04'						, 											  ;
				/*cPergunt	*/ 'Cod Cliente:'	        , /*cPerSpa		*/ 'Cod Cliente:' 		    , /*cPerEng		*/ 'Cod Cliente:'		    , ;
				/*cVar		*/ 'mv_ch4'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 3						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 							, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par04'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

return
