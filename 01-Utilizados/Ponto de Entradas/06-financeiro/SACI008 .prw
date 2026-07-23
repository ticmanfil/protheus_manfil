#include 'protheus.ch'
#include 'parmtype.ch'

user function SACI008 ()
    local 	aArea 		:= GetArea(),;
    		aAreaSE1 	:= SE1->(GetArea()),;
    		aAreaSE5	:= SE5->(GetArea())
     

	local	cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))

	local	lRet		:= .T.,;
			nOpca		:= '',;
			cQry		:= ''//,;
			//cFormaPgto	:= ''
	
	//tela
	local oGet01, oGet02, oGet03, oGet04, oGet05, oGet06, oGet07
	
	private cForm		:= '[SACI008] - Dados Adicionais Cartão'
	
	private oDlg

	if cAmbiente == '1' .and. CBANCO == 'RED'
		private	cCAdm		:= SE1->E1_XCADM,;
				aCAdm		:= {},;
				cCV			:= ' '+replicate(' ',TAMSX3('E5_DOCUMEN')[1])

	
		//cFormaPgto:= SE1->E1_XFORMA

		//Preencher o combo ADM FINANCEIRA de acordo com a forma de pagamento
		if select('TB1') > 0
			TB1->(dbCloseArea('TB1'))
		endif
		cQry	:= "select AE_COD, SAE.AE_DESC from "+retsqlname('SAE')+" as SAE where SAE.D_E_L_E_T_ = '' and SAE.AE_TIPO in ('CC','CD') order by SAE.AE_GRPFRT"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TB1", .T., .F. )
		
		aCAdm	:= {}
		while !TB1->(eof())
			aadd(aCAdm,alltrim(TB1->AE_COD)+'='+alltrim(TB1->AE_DESC))
			TB1->(dbSkip())
		enddo
		TB1->(dbCloseArea())

		SetPrvt('oDlg1','oSay1','oSay2','oSay3','oSay4','oSay5','oSay6','oSBtnOk','oSBtnCan','oMGet1')
		
		DEFINE MSDIALOG oDlg TITLE cForm From 0,0 TO 200,530 PIXEL
		
		@ 010,004 SAY OemToansi('Adm. Cartão:') SIZE 052, 008 OF oDlg PIXEL
		@ 010,060 COMBOBOX oGet01 VAR cCAdm ITEMS aCAdm SIZE 200,008 VALID XVALID(1) OF oDlg PIXEL
		
		@ 025,004 SAY OemToAnsi('CV/Comprov. Venda.:') SIZE 073,008 OF oDlg PIXEL
		@ 025,060 MSGET oGet02 VAR cCV SIZE 200,008 PICTURE '@!' VALID XVALID(2) OF oDlg PIXEL

		//@ 040,004 SAY OemToAnsi('NSU/Num.Autorizacao:') SIZE 073,008 OF oDlg PIXEL
		//@ 040,060 MSGET oGet03 VAR cNSU SIZE 200,008 PICTURE '@!' VALID XVALID(3) OF oDlg PIXEL
		
		DEFINE SBUTTON FROM 85, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
		DEFINE SBUTTON FROM 85, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		if nOpca == '1'
			if xValid(1)
				if xValid(2)
					FSalva()
					lRet	:= .T.
				else
					lRet	:= .F.
				endif
			else
				lRet	:= .F.
			endif

		elseif nOpca == '2'
			lRet	:= .F.

		endif

	endif
	
    RestArea(aAreaSE5)
    RestArea(aAreaSE1)
    RestArea(aArea)
return

static function FSalva()
    local 	aArea 		:= GetArea(),;
    		aAreaSE1 	:= SE1->(GetArea()),;
    		aAreaSE5	:= SE5->(GetArea())

    dbSelectArea('SE5')
    SE5->(dbSetOrder(7))
    SE5->(dbGoTop())
    SE5->(dbSeek(xFilial('SE5')+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA))
    while !SE5->(eof()) .and.  SE1->E1_PREFIXO == SE5->E5_PREFIXO .and. SE1->E1_NUM == SE5->E5_NUMERO .and. SE1->E1_PARCELA == SE5->E5_PARCELA .and. SE1->E1_TIPO == SE5->E5_TIPO .and. SE1->E1_CLIENTE == SE5->E5_CLIFOR .and. SE1->E1_LOJA == SE5->E5_LOJA
    	if SE5->E5_RECPAG == 'R' .and. SE5->E5_TIPODOC == 'VL' .and. SE5->E5_BANCO == CBANCO .and. empty(SE5->E5_DOCUMEN)
    		if recLock('SE5',.F.)
    			SE5->E5_DOCUMEN	:= alltrim(cCV)
    			SE5->(msUnlock())
    		endif
    	endif
    	SE5->(dbSkip())
    enddo 

    RestArea(aAreaSE5)
    RestArea(aAreaSE1)
    RestArea(aArea)
return

static function XVALID(pCampo)

	local lRet	:= .T.

	if pCampo == 1	//CADM
		if empty (alltrim(cCAdm))
			u_msgInforma('Campo Adm. Cartão obrigatório!',cForm)
			lRet:= .F.
		endif

	elseif pCampo == 2	//Comp Venda
		if empty(alltrim(cCV))
			u_msgInforma('Campo CV/Comprov. Venda obrigatório!',cForm)
			lRet:= .F.
		endif

	endif

return lRet
