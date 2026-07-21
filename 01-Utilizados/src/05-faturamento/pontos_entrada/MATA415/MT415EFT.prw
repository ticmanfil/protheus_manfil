#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch' 
/*/
===============================================================================================================================
Programa----------: MT415EFT
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 05/03/2025
===============================================================================================================================
Descrição---------: Este programa serve para Validação da efetivação ou não do Orçamento em questão
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

user function MT415EFT()

	local	aArea		as object,;
			aSCK		as object

    local   lRet    	as logical,;
			cForm		as caractere,;
			dData		as date,;
			cRegCli		as caractere,;
			cRegVen		as caractere,;
			cGrupo		as caractere,;
			cAVista		as caractere,;
			cTabela		as caractere,;
			vTotal		as numeric

    aArea	:= getArea()
	aSCK	:= SCK->(getArea())

	lRet		:= .T.
	cForm		:= '[MT415EFT] - Efetivando Orçamento'
	dData		:= DDATABASE
	cRegCli		:= posicione('SA1',1,xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,'A1_REGIAO')
	cRegVen		:= posicione('SA3',1,xFilial('SA3')+SCJ->CJ_XVEND,'A3_REGIAO')
	//cVendedor	:= posicione('SA3',1,xFilial('SA3')+M->C5_VEND1,'A3_NOME')
	//fFerias		:= posicione('SA3',1,xFilial('SA3')+SCJ->CJ_XVEND,'A3_XFERIAS')
	//fVender		:= posicione('SA3',1,xFilial('SA3')+SCJ->CJ_XVEND,'A3_XBLQVEN')
	cGrupo		:= ''
	cAVista		:= posicione('SE4',1,xFilial('SE4')+SCJ->CJ_CONDPAG,'E4_XAVISTA')
	cTabela		:= SCJ->CJ_TABELA
	vTotal		:= SCJ->CJ_XVLTOT

	//validacao do consumidor não identificado
	if (SCJ->CJ_CLIENTE == '99999999' .or. SCJ->CJ_CLIENTE == '99999998') .and. !cAVista $ 'A'
		u_msgErro('Venda não PERMITIDA para CLIENTE CONSUMIDOR a PRAZO!...')
		lRet	:= .F.

	elseif (SCJ->CJ_CLIENTE == '99999998' .and. SCJ->CJ_LOJA != '8'+strZero(val(SCJ->CJ_XVEND),3) )
		u_msgErro('Venda não PERMITIDA para OUTROS CONSUMIDORES!...')
		lRet	:= .F.
	
	endif

	if cRegVen = '01' .and. cTabela <> '001' //araxa 
		u_msgErro('Venda não PERMITIDA!!!...'+CRLF+'Tabela inconsistente.')
		lRet	:= .F.
	endif

	//orcamento vencimento
	if SCJ->CJ_VALIDA < DDATABASE
		u_msgErro('Data Validade do Orçamento expirado! '+dtoc(SCJ->CJ_VALIDA)+'! Gerar um novo Orcamento.',cForm)
		lRet	:= .F.
	endif

	//validando a regiao do cliente x vendedores
	if cRegCli != '00' .and. cRegVen != '00' //cliente e vendedores sao de regioes diferente de genericos
		if cRegVen != cRegCli
			u_msgErro('Venda irregular!'+CRLF+'Cliente de outras praças!',cForm)
			lRet	:= .F.
		endif
	endif

	//validando condição pagto negociada
	if lRet .and. SCJ->CJ_CONDPAG == '999'
		if SCJ->CJ_PARC1 = 0
			u_msgErro('Condicao de Pagamento NEGOCIADA está sem parcelas!'+CRLF+;
						'Preencher os campos venctos e parcelas antes de efetivar.',cForm)
			lRet	:= .F.

		elseif SCJ->CJ_PARC1+SCJ->CJ_PARC2+SCJ->CJ_PARC3+SCJ->CJ_PARC4 != vTotal 
			u_msgErro('Erro na validação Condicao de Pagamento NEGOCIADA!'+CRLF;
						+'Soma das parcelas divergente do valor total.'+CRLF;
						+'Parcelas: '+TransForm(SCJ->CJ_PARC1+SCJ->CJ_PARC2+SCJ->CJ_PARC3+SCJ->CJ_PARC4,'@E 999,999.99')+' Orç.: '+TransForm(vTotal,'@E 999,999.99'),cForm)
			lRet	:= .F.

		endif
	endif
	
	if dtos(SCJ->CJ_EMISSAO) < '20250809' //data de corte das mundancas das unidades com a segunda base
		dbSelectArea('SCK')
		SCK->(dbSetOrder(1))
		SCK->(dbSeek(xFilial('SCK')+SCJ->CJ_NUM))
		while !SCK->(Eof()) .and. SCK->CK_NUM == SCJ->CJ_NUM
			if SCK->CK_UM <> SCK->CK_XSEGUM
				u_msgErro('Esse orçamento não podera ser efetivado!'+CRLF;
						+'Produtos passiveis de impacto devido as unidades.'+CRLF;
						+'Produto: '+alltrim(SCK->CK_PRODUTO)+' - '+alltrim(SCK->CK_DESCRI)+CRLF;
						+'Refaça este orçamento com nova data.',cForm)
				lRet	:= .F.
			endif

			dbSelectArea('SCK')
			SCK->(dbSkip())
		enddo
	endif

	//demais validações para os vendedores em gerais
	if lRet .and. !RetCodUsr()$"000000|000006|000030"	//administrador, luciene e marcinho

		if SCJ->CJ_CONDPAG == 'SPG'
			u_msgErro('Condicao de Pagamento Invalido!!!'+CRLF+;
					'Favor Corrigir!',cForm)
			lRet	:= .F.
		endif

		dbSelectArea('SCK')
		SCK->(dbSetOrder(1))
		SCK->(dbSeek(xFilial('SCK')+SCJ->CJ_NUM))
		while !SCK->(Eof()) .and. SCK->CK_NUM == SCJ->CJ_NUM
			cGrupo	:= posicione('SB1',1,xFilial('SB1')+SCK->CK_PRODUTO,'B1_GRUPO')
			dbSelectArea('Z00')
			Z00->(dbSetOrder(1))
			Z00->(dbGoTop())
			if !Z00->(dbSeek(xFilial('Z00')+SCJ->CJ_CONDPAG+cGrupo))
					u_msgErro('Cond.Pagto inválido para o Grupo de Produtos!'+CRLF;
							+'Cond. Pagto: '+SCJ->CJ_CONDPAG+' - '+SCJ->CJ_XDESCON+CRLF;
							+'Produto: '+alltrim(SCK->CK_PRODUTO)+' - '+alltrim(SCK->CK_DESCRI)+CRLF;
							+'Corrigir condição de pagamento no orçamento.',cForm)
					lRet	:= .F.
			endif
			Z00->(dbCloseArea())

			dbSelectArea('SCK')
			SCK->(dbSkip())
		enddo

	endif

	if lRet
		lRet:= pPesqDados(vTotal)
	else
		u_msgErro('Efetivação abordado!!!...',cForm)
	endif

	restArea(aSCK)
	restArea(aArea)

return lRet

static function pPesqDados(vTotal)

	local	aArea		as object,;
			aAreaSA1	as object

	local	lRet	as logical,;
			nOpca	as caractere

	local oGet01, oGet02, oGet03, oGet04, oGet05, oGet06, oGet07
	
	private oDlg

	public	aItems		as array,;
			cTipoEnt	as caractere,;
			cDtEnt		as date,;
			cUFEnt		as caractere,;
			cCodMunEnt	as caractere,;
			cMunEnt		as caractere,;
			cEndEnt		as caractere,;
			cCAdm		as caractere,;
			aCAdm		as array,;
			cQtdVias	as caractere,;
			aQtdVias	as array,;
			cFormaPgto	as caractere,;
			cForm		as caractere

	aArea		:= getArea()
	aAreaSA1	:= SA1->(getArea())

	lRet		:= .F.
	cFormaPgto	:= posicione('SE4',1,xFilial('SE4')+SCJ->CJ_CONDPAG,'E4_FORMA')
	cForm		:= 'MT415EFT'
	nOpca		:= ''
	
	//tela para buscar dados adicionais
	aItems		:= {'','A=Almox','E=Entrega','R=Retira'}
	cTipoEnt	:= ' '+replicate(' ',TAMSX3('C5_FLENT')[1])
	cDtEnt		:= daysum(DDATABASE,1)
	cUFEnt		:= ' '+replicate(' ',TAMSX3('C5_XUFE')[1])
	cCodMunEnt	:= ' '+replicate(' ',TAMSX3('C5_XCDMUNE')[1])
	cMunEnt		:= ' '+replicate(' ',TAMSX3('C5_XMUNE')[1])
	cEndEnt		:= ' '+replicate(' ',TAMSX3('C5_XENDE')[1]+TAMSX3('C5_XBAIRRE')[1])
	cCAdm		:= ' '+replicate(' ',TAMSX3('C5_XADM')[1])
	aCAdm		:= {}
	cQtdVias	:= ' '
	aQtdVias	:= {'2','3'}

	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	SA1->(dbGoTop())
	if SA1->(dbSeek(xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
		cUFEnt		:= SA1->A1_ESTE
		cCodMunEnt	:= SA1->A1_CODMUNE
		cMunEnt		:= SA1->A1_MUNE
		cEndEnt		:= alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRROE)+replicate(' ',TAMSX3('A1_ENDENT')[1]+TAMSX3('A1_BAIRRO')[1]-LEN(alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRRO)))
	endif

	if !empty(cFormaPgto) .and. !cFormaPgto $ 'R$ CH'

		//Preencher o combo ADM FINANCEIRA de acordo com a forma de pagamento
		if select('TB1') > 0
			TB1->(dbCloseArea())
		endif
		cQry	:= "select AE_COD, SAE.AE_DESC from "+retsqlname('SAE')+" as SAE where SAE.D_E_L_E_T_ = '' and SAE.AE_TIPO = '"+cFormaPgto+"' order by SAE.AE_GRPFRT"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TB1", .T., .F. )
		
		aCAdm	:= {}
		aadd(aCAdm,'')
		//aCAdm	:= aadd(aCAdm,'')
		while !TB1->(eof())
		
			aadd(aCAdm,alltrim(TB1->AE_COD)+'='+alltrim(TB1->AE_DESC))
			TB1->(dbSkip())
		enddo
		TB1->(dbCloseArea())
	endif

	SetPrvt('oDlg1','oSay1','oSay2','oSay3','oSay4','oSay5','oSay6','oSBtnOk','oSBtnCan','oMGet1')
	
	DEFINE MSDIALOG oDlg TITLE '['+cForm+']-Dados Adcionais' From 0,0 TO 250,530 PIXEL
	
	@ 010,004 SAY OemToansi('Tipo de Entrega:') SIZE 052, 008 OF oDlg PIXEL
	@ 010,060 COMBOBOX oGet01 VAR cTipoEnt ITEMS aItems SIZE 052,008 VALID XVALID(1) OF oDlg PIXEL

	@ 010,150 SAY OemToAnsi('Data da Entrega:') SIZE 073,008 OF oDlg PIXEL
	@ 010,200 MSGET oGet02 VAR cDtEnt SIZE 052,008 VALID !Vazio() OF oDlg PIXEL
	
	@ 025,004 SAY OemToAnsi('UF Entrega:') SIZE 073,008 OF oDlg PIXEL
	@ 025,060 MSGET oGet03 VAR cUFEnt SIZE 032,008 F3 '12' VALID XVALID(3) WHEN cTipoEnt $ 'E|P' PICTURE '@!' OF oDlg PIXEL
	
	@ 025,150 SAY OemToAnsi('Cód.Município:') SIZE 073,008 OF oDlg PIXEL
	@ 025,200 MSGET oGet04 VAR cCodMunEnt F3 'CC2SCJ' SIZE 052,008 VALID XVALID(4) WHEN cTipoEnt $ 'E|P' OF oDlg PIXEL
	
	@ 040,004 SAY OemToAnsi('Mun.Entrega:') SIZE 073,008 OF oDlg PIXEL
	@ 040,060 MSGET oGet05 VAR cMunEnt SIZE 200,008 WHEN .F. PICTURE '@!' OF oDlg PIXEL

	@ 055,004 SAY OemToAnsi('End.Entrega e Outros:') SIZE 073,008 OF oDlg PIXEL
	@ 055,060 MSGET oGet06 VAR cEndEnt SIZE 200,008 WHEN .T. PICTURE '@!' OF oDlg PIXEL
	
	if len(aCAdm)>0
		@ 070,004 SAY OemToansi('Adm. Cartao:') SIZE 052, 008 OF oDlg PIXEL
		@ 070,060 COMBOBOX oGet07 VAR cCAdm ITEMS aCAdm VALID XVALID(7) SIZE 200,008 OF oDlg PIXEL
	endif

	@ 085,004 SAY OemToansi('Qtd Vias: ') SIZE 052, 008 OF oDlg PIXEL
	@ 085,060 COMBOBOX oGet08 VAR cQtdVias ITEMS aQtdVias SIZE 052,008 VALID XVALID(8) OF oDlg PIXEL

	DEFINE SBUTTON FROM 100, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
	DEFINE SBUTTON FROM 100, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED	

	//if lConfirma
	if nOpca == '1'

		if alltrim(cTipoEnt) == 'E' .and. vTotal < 500 .and. SCJ->CJ_FRETE < 20 .and. cUFEnt == 'MG' .and. cCodMunEnt == '04007' .and. !RetCodUsr()$"000000 0000006 0000030"
			u_msgErro('Venda inválida!'+chr(10)+(chr(13)+'Valor frete menor que R$ 20,00.'), cForm)
			lRet:= .F.
		else
			lRet:= .T.
		endif

	else
		lRet:= .F.
	endif
		

	restArea(aAreaSA1)
	restarea(aArea)

return lRet

static function XVALID(pCampo)

	local lRet	:= .T.

	if pCampo == 1	//TIPO DE ENTREGA
		if alltrim(cTipoEnt) == 'A'			//ALMOXARIFADO
			cUFEnt		:= ''
			cCodMunEnt	:= ''
			cMunEnt		:= ''
			cEndEnt		:= ' '+replicate(' ',TAMSX3('C5_XENDE')[1]+TAMSX3('C5_XBAIRRE')[1])
			lRet	:= .T.

		elseif alltrim(cTipoEnt) == 'R'		//RETIRA
			cUFEnt		:= ''
			cCodMunEnt	:= ''
			cMunEnt		:= ''
			cEndEnt		:= ' '+replicate(' ',TAMSX3('C5_XENDE')[1]+TAMSX3('C5_XBAIRRE')[1])
			lRet	:= .T.

		elseif alltrim(cTipoEnt) == 'E'		//ENTREGA
			dbSelectArea('SA1')
			SA1->(dbSetOrder(1))
			SA1->(dbGoTop())
			if SA1->(dbSeek(xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
				cUFEnt		:= SA1->A1_ESTE
				cCodMunEnt	:= SA1->A1_CODMUNE
				cMunEnt		:= SA1->A1_MUNE
				cEndEnt		:= alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRROE)+replicate(' ',TAMSX3('A1_ENDENT')[1]+TAMSX3('A1_BAIRRO')[1]-LEN(alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRROE)))
			endif
			lRet	:= .T.

		elseif empty(cTipoEnt)
			apMsgAlert('Tipo de entrega inválido. Favor preencher corretamente!',cForm)
			lRet:= .F.
		endif

	elseif pCampo == 3	//ESTADO
		if alltrim(cTipoEnt) $ 'E|P'
			if empty(cUFent)
				apMsgAlert('UF Inválido!',cForm)
				lRet:= .F.
			else
				if alltrim(cUFent) != ''
					if RecLock('SCJ',.F.)
						SCJ->CJ_XUFENT	:= cUFent
						SCJ->(msUnlock())
					endif
				endif
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

return	lRet
