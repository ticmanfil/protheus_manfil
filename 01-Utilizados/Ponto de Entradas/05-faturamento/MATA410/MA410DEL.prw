#include 'protheus.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: A410EXC 
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 30/10/2018
===============================================================================================================================
Descrição---------: Este programa serve para REABRIR O ORCAMENTO já efetivado
===============================================================================================================================
Uso---------------: MATA410 - PEDIDO DE VENDA
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: .T. ou .F.
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

user function MA410DEL()

	local   cAmbiente	as char,;
            lRet		as logical,;
	        cForm		as char
	
	private lMsErroAuto as logical

	/* INICIANDO AS VARIAVEIS */
    cAmbiente	:= alltrim(getmv("MV_XLOCAL"))
	lRet		:= .F.
	cForm		:= 'MA410DEL'
	
	lMsErroAuto	:= .F.

	if cAmbiente == '1' .and. empty(SC5->C5_XNUMORC)
        lRet    := CancelaPV(SC5->C5_NUM,SC5->C5_VEND1,SC5->C5_XVLTOT,SC5->C5_PESOL,C5_EMISSAO)

    elseif cAmbiente == '1' .and. !empty(SC5->C5_XNUMORC)
        begin transaction
            dbSelectArea('SCJ') 
            SCJ->(dbSetOrder(1))
            SCJ->(dbGoTop())
            
            if SCJ->(dbSeek(fwXFilial('SCJ')+SC5->C5_XNUMORC))
                lRet	:= U_RD05005('PV',SCJ->CJ_NUM, SCJ->CJ_XMOT, SCJ->CJ_STATUS)
                if lRet
                    RecLock('SCJ',.F.)
                    SCJ->CJ_STATUS	:= 'C'
                    MsUnLock()
                else
                    u_msgErro('Erro alterar o STATUS do ORÇAMENTO!','['+cForm+']')
                    disarmTransaction()
                endif
            endif

            if !lMsErroAuto
                lRet	:= .T.
            else
                u_msgErro('Erro alterar o STATUS do ORÇAMENTO!','['+cForm+']')
                MostraErro()
                disarmTransaction()
            endif
        end transaction

    elseif cAmbiente == '2'
        if (SC5->C5_XLOJA == 'S')
            lRet:= .F.
            u_msgErro('Pedido de Venda LOJA!'+CRLF+'Antes de EXCLUIR deve retira-lo.','['+cForm+']')
        else
            //excluindo integracao da nota
            dbSelectArea('Z50')
            Z50->(dbSetOrder(3))
            Z50->(dbGoTop())
            if Z50->(dbSeek(FWxFilial('Z50')+SC5->C5_NUM))
                while !Z50->(eof()) .and. Z50->Z50_NUMPED == SC5->C5_NUM
                    if RecLock('Z50',.F.)
                        Z50->(dbDelete())
                        Z50->(MsUnLock())
                    endif
                    Z50->(dbSkip())
                end
            endif
            Z50->(dbCloseArea())
            lRet:= .T.

        endif

	else
		lRet	:= .T.

	endif 

return lRet

static function CancelaPV(cNumPed,cVend,nValor,nPeso,dDtEmissao)

    local   lRet    as logical

	local 	oGet01,;
			oGet02

    local   cCodMot as caracter,;
            cMotivo as caracter,;
            cTpVend as caracter

    lRet    := .F.
    cCodMot := space(tamsx3('MBQ_CODVEP')[1])
    cMotivo := space(tamsx3('MBQ_DSCVEP')[1])
    cTpVend := posicione('SA3',1,fwxFilial('SA3')+cVend,'A3_TIPO')

    SetPrvt('oDlg1','oSay1','oSBtnOk','oSBtnCan')

    DEFINE MSDIALOG oDlg TITLE '[ma410del]-Cancelando Orçamento' From 0,0 TO 175,530 PIXEL

    @ 010,004 SAY OemToansi('Motivo de Cancelamento:') SIZE 052, 008 OF oDlg PIXEL
    @ 010,060 MSGET oGet01 VAR cCodMot F3 'MBQ' SIZE 032,008 PICTURE X3PICTURE('Z51_CODMOT') VALID XVALID(1,@cCodMot,@cMotivo) OF oDlg PIXEL
    @ 010,095 MSGET oGet02 VAR cMotivo SIZE 165,008 PICTURE '@!' WHEN .F. OF oDlg PIXEL

    DEFINE SBUTTON FROM 70, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
    DEFINE SBUTTON FROM 70, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg

    ACTIVATE MSDIALOG oDlg CENTERED	

    if nOpca == '1'

        u_CriaTabela('Z51')
        
        if RecLock('Z51',.T.)
            Z51->Z51_CODMOT	:= cCodMot
            Z51->Z51_DATA	:= Date()
            Z51->Z51_USR	:= CUSERNAME
            Z51->Z51_NUMPED := cNumPed
            Z51->Z51_SEQ    := GETSX8NUM("Z51","Z51_SEQ")
            Z51->Z51_REGVEN := cTpVend
            Z51->Z51_VALOR  := nValor
            Z51->Z51_PESO   := nPeso
            Z51->Z51_VEND   := cVend
            Z51->Z51_EMISSA := dDtEmissao
            msUnLock()
        endif

        lMsErroAuto	:= .F.

        if lMsErroAuto
            MostraErro()
            lRet	:= .F.

        else
            pEnviaAudit(alltrim(cCodMot)+' - '+alltrim(cMotivo))
            lRet	:= .T.
        
        endif

    else
        lRet	:= .F.

    endif

return lRet

static function XVALID(pCampo,cCodMot,cMotivo)

	local lRet	:= .F.

	if pCampo == 1
		if alltrim(cCodMot) == '000' .and. retCodUsr() != '000000'
			U_msgErro('Motivo permitido somente para ADMINISTRADOR'+CRLF+;
                        'Ação será cancelado.','[ma410del]')
			lRet	:= .F.

		else
            cMotivo := posicione('MBQ',1,fwXFilial('MBQ')+cCodMot,'MBQ_DSCVEP')
			lRet	:= .T.
		
		endif
	
	endif

return	lRet

static function pEnviaAudit(pMotivo)

	local lRet		:= .F.
	local VlOrcam	:= SC5->C5_XVLTOT
	
	//variaveis para composicao do email auditoria
	local cPara		:= alltrim(posicione('SA3',1,xfilial('SA3')+SC5->C5_VEND1,'A3_EMAIL'))
	local cCliente	:= alltrim(posicione('SA1',1,xfilial('SA1')+SC5->C5_CLIENTE_CLIENTE+SC5->C5_LOJACLI,'A1_NREDUZ'))
	local cAssunto	:= '[Totvs] Orçamento Cancelado/Excluído '+alltrim(SC5->C5_NUM)+' - '+alltrim(cCliente)+' R$ '+transform(VlOrcam,x3Picture('C5_XVLTOT'))
	local cCorpo	:= ''
	
	cCorpo	:= 'O orçamento abaixo foi CANCELADO/EXCLUÍDO conforme dados abaixo:'+CRLF+CRLF
	cCorpo	+= 'Num. Orçamento.: '+alltrim(SC5->C5_NUM)+CRLF+CRLF
	cCorpo	+= 'Data Emissão...: '+dtoc(SC5->C5_EMISSAO)+CRLF+CRLF
	cCorpo	+= 'Cliente........: '+alltrim(cCliente)+CRLF+CRLF
	cCorpo	+= 'Valor..........: R$ '+transform(VlOrcam,x3Picture('CJ_XVLTOT'))+CRLF+CRLF
	cCorpo	+= 'Motivo.........: '+alltrim(pMotivo)

	lRet	:= U_EnvMail(	 /*cMailDe			*/ '';
							,/*cMailPara		*/ cPara;
							,/*cMailCopia		*/ '';
							,/*cMailCopiaOculta	*/ '';
							,/*cAssunto			*/ cAssunto;
							,/*cCorpo			*/ cCorpo;
							,/*cAnexo			*/ '';
							,/*_lReturn			*/ .F.)

return lRet
