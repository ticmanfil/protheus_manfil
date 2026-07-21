/*/
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
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'prtopdef.ch' 
/*/
===============================================================================================================================
Programa----------: M410PVNF
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/10/2025
===============================================================================================================================
Descrição---------: Este programa serve para preencher Executado antes da rotina de geração de NF's (MA410PVNFS())
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: <programa>
===============================================================================================================================
/*/
user function M410PVNF()

    local   lContinua   as logical,;
			cAmbiente	as caractere

	lContinua	:= .T.
	cAmbiente	:= getMV('MV_XLOCAL')

	if cAmbiente == '1'
		lContinua:= ValidProd(SC5->C5_NUM)
		if lContinua
			if empty(SC5->C5_XNUMPAR) .and. empty(SC5->C5_NOTA)
				lContinua   := pPesqDados()
			endif
		endif
	endif

return lContinua

static function pPesqDados()

	local	aArea		as array,;
			aAreaSA1	as array

	local	lRet	as logical,;
			nOpca	as caracter,;
            cForm	as caracter

	local oGet01, oGet02, oGet03, oGet04, oGet05, oGet06, oGet07
	
	local   aQtdVias	as array,;
            aCAdm		as array,;
            aItems		as array

    local	nValor		as numeric,;
            nFrete		as numeric,;
			cTipoEnt	as caracter,;
			cUFEnt		as caracter,;
			cCodMunEnt	as caracter,;
			cMunEnt		as caracter,;
			cEndEnt		as caracter,;
			cCAdm		as caracter,;
			cQtdVias	as caracter,;
			cFormaPgto	as caracter,;
			cCondPagto	as caracter,;
			lNota		as logical,;
			cBoleto		as caracter

	local	cQry		as caracter

	private oDlg

	public	cDtEnt		as date

	aArea		:= fwGetArea()
	aAreaSA1	:= SA1->(fwGetArea())
	
	lRet		:= .T.
	cForm		:= 'M410PVNF'
	nOpca		:= ''
	
	//tela para buscar dados adicionais
	aItems		:= {'','A=Almox','E=Entrega','R=Retira'}
	aCAdm		:= {}
	aQtdVias	:= {'2','3'}

	cTipoEnt	:= SC5->C5_FLENT
	cDtEnt		:= SC5->C5_FECENT
	cUFEnt		:= SC5->C5_XESTE
	cCodMunEnt	:= SC5->C5_XCDMUNE
	cMunEnt		:= SC5->C5_XMUNE
	cEndEnt		:= SC5->C5_XENDE
	cCAdm		:= SC5->C5_XADM
	cQtdVias	:= SC5->C5_XVIAS
    nValor      := SC5->C5_XVLTOT
    nFrete      := SC5->C5_FRETE
	cCondPagto	:= SC5->C5_CONDPAG
    cFormaPgto  := posicione('SE4',1,fwxFilial('SE4')+cCondPagto,'E4_FORMA')
	lNota		:= posicione('SA1',1,fwxFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'A1_XNF')
	cBoleto		:= iif(lNota,'T','F')

	if !empty(cFormaPgto) .and. !cFormaPgto $ 'R$ CH'

		if select('TB1') > 0
			TB1->(dbCloseArea())
		endif

		//Preencher o combo ADM FINANCEIRA de acordo com a forma de pagamento
		cQry:= "select AE_COD, AE_DESC from "+retsqlname('SAE')+" where D_E_L_E_T_ = '' and AE_TIPO = '"+cFormaPgto+"' "
		if cBoleto == 'F'
			cQry+= "and AE_XFAT = '" + cBoleto + "' "
		endif
		cQry+= "order by AE_GRPFRT"

		tcQuery cQry new alias 'TB1'
		
		aCAdm:= {}
		aadd(aCAdm,'')
		while !TB1->(eof())
			aadd(aCAdm,alltrim(TB1->AE_COD)+'='+alltrim(TB1->AE_DESC))
			TB1->(dbSkip())
		enddo
		TB1->(dbCloseArea())
	else
		cCAdm:= ''
	endif

	SetPrvt('oDlg1','oSay1','oSay2','oSay3','oSay4','oSay5','oSay6','oSBtnOk','oSBtnCan','oMGet1')
	
	DEFINE MSDIALOG oDlg TITLE '['+cForm+']-Dados Adcionais' From 0,0 TO 250,530 PIXEL
	
	@ 010,004 SAY OemToansi('Tipo de Entrega:') SIZE 052, 008 OF oDlg PIXEL
	@ 010,060 COMBOBOX oGet01 VAR cTipoEnt ITEMS aItems SIZE 052,008 VALID XVALID(1,@cTipoEnt,@cUFEnt,@cCodMunEnt,@cMunEnt,@cEndEnt,@cQtdVias,@CCADM,@cForm) OF oDlg PIXEL

	@ 010,150 SAY OemToAnsi('Data da Entrega:') SIZE 073,008 OF oDlg PIXEL
	@ 010,200 MSGET oGet02 VAR cDtEnt SIZE 052,008 VALID !Vazio() OF oDlg PIXEL
	
	@ 025,004 SAY OemToAnsi('UF Entrega:') SIZE 073,008 OF oDlg PIXEL
	@ 025,060 MSGET oGet03 VAR cUFEnt SIZE 032,008 F3 '12' VALID XVALID(3,@cTipoEnt,@cUFEnt,@cCodMunEnt,@cMunEnt,@cEndEnt,@cQtdVias,@CCADM,@cForm) WHEN cTipoEnt $ 'E|P' PICTURE '@!' OF oDlg PIXEL
	
	@ 025,150 SAY OemToAnsi('Cód.Município:') SIZE 073,008 OF oDlg PIXEL
	@ 025,200 MSGET oGet04 VAR cCodMunEnt F3 'CC2' SIZE 052,008 VALID XVALID(4,@cTipoEnt,@cUFEnt,@cCodMunEnt,@cMunEnt,@cEndEnt,@cQtdVias,@CCADM,@cForm) WHEN cTipoEnt $ 'E|P' OF oDlg PIXEL
	
	@ 040,004 SAY OemToAnsi('Mun.Entrega:') SIZE 073,008 OF oDlg PIXEL
	@ 040,060 MSGET oGet05 VAR cMunEnt SIZE 200,008 WHEN .F. PICTURE '@!' OF oDlg PIXEL

	@ 055,004 SAY OemToAnsi('End.Entrega e Outros:') SIZE 073,008 OF oDlg PIXEL
	@ 055,060 MSGET oGet06 VAR cEndEnt SIZE 200,008 WHEN .T. VALID XVALID(6,@cTipoEnt,@cUFEnt,@cCodMunEnt,@cMunEnt,@cEndEnt,@cQtdVias,@CCADM,@cForm) PICTURE '@!' OF oDlg PIXEL
	
	if len(aCAdm)>0
		@ 070,004 SAY OemToansi('Adm. Cartao:') SIZE 052, 008 OF oDlg PIXEL
		@ 070,060 COMBOBOX oGet07 VAR cCAdm ITEMS aCAdm VALID XVALID(7,@cTipoEnt,@cUFEnt,@cCodMunEnt,@cMunEnt,@cEndEnt,@cQtdVias,@CCADM,@cForm) SIZE 200,008 OF oDlg PIXEL
	endif

	@ 085,004 SAY OemToansi('Qtd Vias: ') SIZE 052, 008 OF oDlg PIXEL
	@ 085,060 COMBOBOX oGet08 VAR cQtdVias ITEMS aQtdVias SIZE 052,008 VALID XVALID(8,@cTipoEnt,@cUFEnt,@cCodMunEnt,@cMunEnt,@cEndEnt,@cQtdVias,@CCADM,@cForm) OF oDlg PIXEL

	DEFINE SBUTTON FROM 100, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
	DEFINE SBUTTON FROM 100, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED	

	//if lConfirma
	if nOpca == '1'

		lRet:= .T.

		if alltrim(cTipoEnt) == 'E' .and. nValor < 500 .and. nFrete < 20 .and. cUFEnt == 'MG' .and. cCodMunEnt == '04007' .and. !RetCodUsr()$"000000 0000006 0000030"
			u_msgErro('Frete inválido!!!'+CRLF;
					+'Valor frete menor que R$ 20,00.')
			lRet:= .F.

		elseif cTipoEnt != 'E' .and. nFrete > 0
			u_msgErro('Valor do frete inválido!'+CRLF+;
						'Corrigir o valor do frete.',cForm)
			lRet	:= .F.

		elseif nfrete > 0 .and. nfrete < 20
			u_msgErro('Valor do frete abaixo do permitido!'+CRLF+;
						'Valor mínimo R$ 20,00',cForm)
			lRet	:= .F.
			
		elseif nfrete != int(nfrete)
			u_msgErro('Valor do frete deve ser inteiro!'+CRLF+;
						'Corrigir o valor do frete.',cForm)
			lRet	:= .F.

		endif

		if lRet .and. empty(cEndEnt) .and. cTipoEnt = 'E'
			u_msgErro('Campo endereço não preenchido')
			lRet:= .F.
		endif

		if lRet .and. empty(cCAdm)
			u_msgErro('Campo administradora do cartão não preenchido')
			lRet:= .F.
		endif

	else
		lRet:= .F.
	endif

	if lRet
		if RecLock('SC5',.F.)
			SC5->C5_FLENT	:= cTipoEnt
			SC5->C5_FECENT	:= cDtEnt
			SC5->C5_XESTE	:= cUFent
			SC5->C5_XCDMUNE	:= cCodMunEnt
			SC5->C5_XMUNE	:= cMunEnt
			SC5->C5_XENDE	:= cEndEnt
			SC5->C5_XADM	:= cCAdm
			SC5->C5_XVIAS	:= cQtdVias
			SCJ->(msUnlock())
		endif
	endif

	fwRestArea(aAreaSA1)
	fwRestArea(aArea)

return lRet

static function XVALID(pCampo,cTipoEnt,cUFEnt,cCodMunEnt,cMunEnt,cEndEnt,cQtdVias,CCADM,cForm)

	local lRet	:= .T.

	Local 	aArea		as array,;
			aAreaSA1	as array

	aArea		:= fwGetArea()
	aAreaSA1	:= SA1->(fwGetArea())

	if pCampo == 1	//TIPO DE ENTREGA
		if alltrim(cTipoEnt) $ 'A|R'			//ALMOXARIFADO | RETIRA
			cUFEnt		:= ''
			cCodMunEnt	:= ''
			cMunEnt		:= ''
			cEndEnt		:= ' '+replicate(' ',TAMSX3('C5_XENDE')[1]+TAMSX3('C5_XBAIRRE')[1])
			lRet	:= .T.

		elseif alltrim(cTipoEnt) $ 'E'
			if empty(cEndEnt) .or. alltrim(cEndEnt) == ''
				dbSelectArea('SA1')
				SA1->(dbSetOrder(1))
				SA1->(dbGoTop())
				if SA1->(dbSeek(fwxFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
					cUFEnt		:= SA1->A1_ESTE
					cCodMunEnt	:= SA1->A1_CODMUNE
					cMunEnt		:= posicione('CC2',1,fwxFilial('CC2')+cUFEnt+cCodMunEnt,'CC2_MUN')
					cEndEnt		:= SA1->A1_ENDENT + ' - ' + SA1->A1_BAIRROE
				endif
			endif
			//SA1->(dbCloseArea())
			lRet	:= .T.

		elseif empty(cTipoEnt) .or. alltrim(cTipoEnt) == ''
			apMsgAlert('Tipo de entrega inválido. Favor preencher corretamente!',cForm)
			lRet:= .F.
		endif

	elseif pCampo == 3	//ESTADO
		if alltrim(cTipoEnt) $ 'E|P'
			if empty(cUFent)
				apMsgAlert('UF Inválido!',cForm)
				lRet:= .F.
			endif
		endif
	elseif pCampo == 4	//COD MUNICIPIO
		if alltrim(cTipoEnt) $ 'E|P'
			if empty(cCodMunEnt)
				apMsgAlert('Código do Município Inválido!',cForm)
				lRet:= .F.
			else
				dbSelectArea('CC2')
				CC2->(dbSetOrder(1))
				CC2->(dbGoTop())
				if CC2->(dbSeek(xFilial('CC2')+cUFEnt+cCodMunEnt))
					cUFEnt		:= CC2->CC2_EST
					cCodMunEnt	:= CC2->CC2_CODMUN 
					cMunEnt		:= CC2->CC2_MUN
				endif
                CC2->(dbCloseArea())
			endif
		endif

	elseif pCampo == 7
		if empty(cCAdm)
			apMsgAlert('Operadora do Cartao Invalido!',cForm)
			lRet:= .F.
		endif

	elseif pCampo == 8
		if empty(cQtdVias)
			apMsgAlert('Qtd de Vias Invalido!',cForm)
			lRet:= .F.
		endif

	endif

	fwRestArea(aAreaSA1)
	fwRestArea(aArea)

return lRet

static function ValidProd(cNumPed)

	local	aArea		as array,;
			aAreaSC6	as array

	local	lRet		as logical

	local	dDtValid		as date,;
			nQtdItens		as numeric,;
			cTpCondPagto	as caractere,;
			cFormPagto		as caractere,;
			cCondPagto		as caractere,;
			cDescPagto		as caractere,;
			cDesFormPagto	as caractere

	aArea		:= fwGetArea()
	aAreaSC6	:= SC6->(fwGetArea())

	lRet			:= .T.
	dDtValid		:= SC5->C5_XDTVAL
	cCondPagto		:= SC5->C5_CONDPAG
	cTpCondPagto	:= posicione('SE4',1,fwxFilial('SE4')+cCondPagto,'E4_FORMA')
	cDescPagto		:= posicione('SE4',1,fwxFilial('SE4')+cCondPagto,'E4_DESCRI')
	cFormPagto		:= SC5->C5_XADM
	cDesFormPagto	:= posicione('SAE',1,fwxFilial('SAE')+cFormPagto,'AE_DESC')

	//orcamento vencimento
	if dDtValid < DATE()
		u_msgErro('Data Validade do Orçamento expirado! '+dtoc(dDtValid)+'! Gerar um novo Orcamento.')
		lRet	:= .F.
	endif

	//verificar se a quantidade de itens é superior a 23 itens
	dbSelectArea('SC6')
	SC6->(dbSetOrder(1))
	SC6->(dbGoTop())
	if SC6->(dbSeek(xFilial('SC6')+cNumPed))
		nQtdItens:= 0
		do while !SC6->(eof()) .and. SC6->C6_NUM == cNumPed
			nQtdItens:= nQtdItens + 1
			SC6->(dbSkip())
		enddo
	endif
	SC6->(dbCloseArea())

	if nQtdItens>30
		u_msgErro('Quantidade de itens superior a 30 itens!!!...',cForm)
		lRet:= .F.
	endif

	fwRestArea(aAreaSC6)
	fwRestArea(aArea)

return lRet
