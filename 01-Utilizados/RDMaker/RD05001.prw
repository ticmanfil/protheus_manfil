#include 'protheus.CH'
#include 'tbiconn.ch' 
#include 'topconn.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: RD05001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 13/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para Efetivar um Orcamento
===============================================================================================================================
Uso---------------: No Orcamento (faturamento)
===============================================================================================================================
Parametros--------: cIdEnt	= '000001'
					cVal1	= .F.
					cVal2	= .F.
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
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

user function RD05001()

	local 	aArea     	:= GetArea(),;
			aAreaSA1	:= SA1->(GetArea()),;
			aAreaSA3	:= SA3->(getArea()),;
			aAreaSE4	:= SE4->(getArea()),;
			aAreaSAE	:= SAE->(getArea())
			
	local	lRet		:= .T.,;
			dData		:= DDATABASE,;
			vTotal		:= U_UVlOrc(SCJ->CJ_NUM,'O'),;
			cGrupo		:= '',;
			nOpca		:= '',;
			cQry		:= '',;
			cFormaPgto	:= '',;
			cAVista		:= ''
	
	//tela
	local oGet01, oGet02, oGet03, oGet04, oGet05, oGet06, oGet07
	
	private cForm		:= '[RD05001] - Efetivando Orçamento'
	
	private oDlg

			//aItems		:= {'','A=Almox','E=Entrega','R=Retira','D=Ent.Direta','P=Ent.Parcial'},;
	private	aItems		:= {'','A=Almox','E=Entrega','R=Retira'},;
			cTipoEnt	:= ' '+replicate(' ',TAMSX3('C5_FLENT')[1]),;
			cDtEnt		:= daysum(DDATABASE,1) ,;
			cUFEnt		:= ' '+replicate(' ',TAMSX3('C5_XUFE')[1]),;
			cCodMunEnt	:= ' '+replicate(' ',TAMSX3('C5_XCDMUNE')[1]),;
			cMunEnt		:= ' '+replicate(' ',TAMSX3('C5_XMUNE')[1]),;
			cEndEnt		:= ' '+replicate(' ',TAMSX3('C5_XENDE')[1]+TAMSX3('C5_XBAIRRE')[1]),;
			cCAdm		:= ' '+replicate(' ',TAMSX3('C5_XADM')[1]),;
			aCAdm		:= {},;
			cQtdVias	:= ' ',;
			aQtdVias	:= {'','2','3'}
	
	//Preenchendo os campos de enderecos de acordo com seu cadastro
	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	SA1->(dbGoTop())
	if SA1->(dbSeek(xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
		cUFEnt		:= SA1->A1_ESTE
		cCodMunEnt	:= SA1->A1_CODMUNE
		cMunEnt		:= SA1->A1_MUNE
		cEndEnt		:= alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRROE)+replicate(' ',TAMSX3('A1_ENDENT')[1]+TAMSX3('A1_BAIRRO')[1]-LEN(alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRRO)))
	endif
	
	dbSelectArea('SE4')
	SE4->(dbSetOrder(1))
	SE4->(dbGoTop())
	if SE4->(dbSeek(xFilial('SE4')+SCJ->CJ_CONDPAG))
		cFormaPgto:= SE4->E4_FORMA
		cAVista:= SE4->E4_XAVISTA
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
	
	dbSelectArea('SCJ')
	//Valida ambiente
	if SCJ->CJ_STATUS != 'A'
		apMsgAlert('Orçamento já BAIXADO e não poderá mas ser EFETIVADO!',cForm)
		lRet	:= .F.
//		return (lRet)
	endif

	if SCJ->CJ_VALIDA < dData
		apMsgAlert('Data Validade do Orçamento expirado! '+DTOC(SCJ->CJ_VALIDA)+'! Gerar um novo Orcamento.',cForm)
		lRet	:= .F.
	endif
	
	if SCJ->CJ_CONDPAG == '999'
		if SCJ->CJ_PARC1 = 0
			apMsgAlert('Condicao de Pagamento NEGOCIADA está sem parcelas!'+chr(10)+chr(13)+'Preencher os campos venctos e parcelas antes de efetivar.',cForm)
			lRet	:= .F.
		elseif SCJ->CJ_PARC1+SCJ->CJ_PARC2+SCJ->CJ_PARC3+SCJ->CJ_PARC4 != vTotal 
			apMsgAlert('Erro na validação Condicao de Pagamento NEGOCIADA!'+chr(10)+chr(13);
						+'Soma das parcelas divergente do valor total.'+chr(10)+chr(13);
						+'Parcelas: '+TransForm(SCJ->CJ_PARC1+SCJ->CJ_PARC2+SCJ->CJ_PARC3+SCJ->CJ_PARC4,'@E 999,999.99')+' Orç.: '+TransForm(vTotal,'@E 999,999.99'),cForm)
			lRet	:= .F.
		endif
	endif
	
	//VALIDANDO SE É O CONSUMIDOR NAO IDENTIFICADO
	if (SCJ->CJ_CLIENTE == '99999999' .or. SCJ->CJ_CLIENTE == '99999998') .and. !cAVista $ 'A'
		u_msgErro('Venda não PERMITIDA para CLIENTE CONSUMIDOR a PRAZO!...')
		lRet	:= .F.
	endif

	if (SCJ->CJ_CLIENTE == '99999998' .and. SCJ->CJ_LOJA != '8'+strZero(val(SCJ->CJ_XVEND),3) )
		u_msgErro('Venda não PERMITIDA para OUTROS CONSUMIDORES!...')
		lRet	:= .F.
	endif

	dbSelectArea('SA1')
	SA1->(dbSetOrder(1))
	SA1->(dbGoTop())
	if SA1->(dbSeek(xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
		dbSelectArea('SA3')
		SA3->(dbSetOrder(1))
		SA3->(dbGoTop())
		if SA3->(dbSeek(xFilial('SA3')+SCJ->CJ_XVEND))
			if SA1->A1_REGIAO != '00'
				if SA3->A3_REGIAO != '00'
					if SA3->A3_REGIAO != SA1->A1_REGIAO 
						apMsgAlert('Venda irregular!'+chr(13)+'Cliente de outras praças!',cForm)
						lRet	:= .F.
					endif					
				endif				
			endif			
		endif
	endif

	dbSelectArea('SA3')
	SA3->(dbSetOrder(1))
	SA3->(dbGoTop())
	if SA3->(MsSeek(xFilial('SA3')+SCJ->CJ_XVEND))
		if SA3->A3_XFERIAS	== 'S'
			if !u_msgPergunta('Vendedor '+alltrim(SA3->A3_NOME)+' encontra de FÉRIAS e será alterado para o Vendedor Padrao!!!...','['+cForm+']')
				_lRet	:= .F.
			endif
		endif
	endif

	//VALIDANDO CONDICAO PAGTO
	//a regra é: não efetivar orcamentos cujo a condicao de pagamento esteja cadadastrado na Z00 para a COND PAGTO escolhido
	if !RetCodUsr()$"000000|000006|000030"                

		if SCJ->CJ_CONDPAG == 'SPG'
			apMsgAlert('Condicao de Pagamento Invalido'+CRLF+'',cForm)
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
					if retCodUsr() == '000000'
						if u_msgPergunta('Cond.Pagto inválido para o Grupo de Produtos!'+chr(10)+chr(13);
										+'Cond. Pagto: '+SCJ->CJ_CONDPAG+' - '+SCJ->CJ_XDESCON+chr(10)+chr(13);
										+'Produto: '+alltrim(SCK->CK_PRODUTO)+' - '+alltrim(SCK->CK_DESCRI)+chr(10)+chr(13);
										+'Deseja continuar com a EFETIVAÇÃO.',cForm)	!= 6 
							lRet	:= .F.
						endif
					else
						apMsgAlert('Cond.Pagto inválido para o Grupo de Produtos!'+chr(10)+chr(13);
								+'Cond. Pagto: '+SCJ->CJ_CONDPAG+' - '+SCJ->CJ_XDESCON+chr(10)+chr(13);
								+'Produto: '+alltrim(SCK->CK_PRODUTO)+' - '+alltrim(SCK->CK_DESCRI)+chr(10)+chr(13);
								+'Corrigir condição de pagamento no orçamento.',cForm)
						lRet	:= .F.
					endif
			endif
			Z00->(dbCloseArea())

			dbSelectArea('SCK')
			SCK->(dbSkip())
		enddo
	endif

	//VALIDANDO AS VENDAS FEITO PELO FLUIG 
	if SCJ->CJ_XFLUIG == 'S'
		if SCJ->CJ_XAPROVA == 'S'
			if SCJ->CJ_XFLDESC == 'S'
				apMsgAlert('Este ORÇAMENTO está aguardando APROVAÇÃO DE DESCONTO!'+chr(10)+chr(13);
						+'E não pode ser EFETIVADO.'+chr(10)+chr(13);
						+'Favor solicitar a GERENCIA.',cForm)
				lRet	:= .F.
			endif
		else
			apMsgAlert('Este ORÇAMENTO não está LIBERADO PARA FATURAMENTO!'+chr(10)+chr(13);
					+'E não pode ser EFETIVADO.',cForm)
			lRet	:= .F.
		endif
	endif
	
	
	//VALIDANDO OS USUÁRIOS QUE PODEM EFETIVAR ORCAMENTOS
/*	if RetCodUsr()$"000077"		//Luana                        
		apMsgAlert('Usuário não autorizado a efetivar. Procurar a gerência!!!...',cForm)
		lRet	:= .F.
	endif
*/

	if !lRet
		apMsgInfo('Efetivação CANCELADO!',cForm)
		return lRet
	else
	
		SetPrvt('oDlg1','oSay1','oSay2','oSay3','oSay4','oSay5','oSay6','oSBtnOk','oSBtnCan','oMGet1')
		
		DEFINE MSDIALOG oDlg TITLE '[RD05001]-Efetivar Orçamento' From 0,0 TO 250,530 PIXEL
		
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
		
			FSalva()
			
		endif
	endif
	
	RestArea(aArea)
	SA1->(RestArea(aAreaSA1))
	SA3->(restArea(aAreaSA3))
	SE4->(restArea(aAreaSE4))
	SAE->(restArea(aAreaSAE))
	
return

static function FSalva()

	local 	aCabec		as array,;
			aItens		as array,;
			aLinha		as array,;
			lRet		as logical,;
			vTotal		as numeric,;
			cForm		as caractere,;
			cNumPed		as caractere,;
			nComis		as numeric,;
			cAdminDesc	as caractere

	aCabec	:= {}
	aItens	:= {}
	aLinha	:= {}
	lRet	:= .T.
	vTotal	:= U_UVlOrc(SCJ->CJ_NUM,'O')
	cForm	:= '[RD05001] - Efetivando Orçamento'
	cNumPed	:= ''
	nComis	:= 0
	cAdminDesc	:= ''

	if alltrim(cTipoEnt) == 'E' .and. vTotal < 500 .and. SCJ->CJ_FRETE < 20 .and. cUFEnt == 'MG' .and. cCodMunEnt == '04007' .and. !RetCodUsr()$"000000 0000006 0000030"
		u_msgErro('Venda inválida!'+chr(10)+(chr(13)+'Valor frete menor que R$ 20,00.'), cForm)
	
	elseif !VldGer()
		u_msgErro('Formulario invalido!'+chr(10)+(chr(13)+'Favor revisar os campos.'), cForm)
	
	else
	
		cNumPed		:= getsx8num('SC5','C5_NUM')
		aCabec		:= {}
		aItens		:= {}
		aLinha		:= {}
		nComis		:= posicione('SA3',1,xFilial('SA3')+SCJ->CJ_XVEND,'A3_COMIS')
		cAdminDesc	:= posicione('SAE',1,xFilial('SAE')+cCAdm,'AE_DESC')

		//aadd(aCabec,{'C5_NUM'		,cNumPed						, nil})
		aadd(aCabec,{'C5_TIPO'		,'N'							, nil})
		aadd(aCabec,{'C5_CLIENTE'	,SCJ->CJ_CLIENTE				, nil})
		aadd(aCabec,{'C5_LOJACLI'	,SCJ->CJ_LOJA					, nil})
		aadd(aCabec,{'C5_XCLIENT'	,ALLTRIM(SA1->A1_NOME)					, nil})
		aadd(aCabec,{'C5_XNOMCON'	,SCJ->CJ_XNOMCLI				, nil})
		aadd(aCabec,{'C5_CLIENT'	,SCJ->CJ_CLIENT					, nil})
		aadd(aCabec,{'C5_LOJAENT'	,SCJ->CJ_LOJAENT				, nil})
		aadd(aCabec,{'C5_TIPOCLI'	,SCJ->CJ_TIPOCLI				, nil})
		aadd(aCabec,{'C5_TABELA'	,SCJ->CJ_TABELA					, nil})
		aadd(aCabec,{'C5_VEND1'		,SCJ->CJ_XVEND					, nil})
		aadd(aCabec,{'C5_XNVEND1'	,SCJ->CJ_XNOMVEN				, nil})
		aadd(aCabec,{'C5_COMIS1'	,nComis							, nil})
		aadd(aCabec,{'C5_CONDPAG'	,SCJ->CJ_CONDPAG				, nil})
		aadd(aCabec,{'C5_XDESCON'	,SCJ->CJ_XDESCON				, nil})
		aadd(aCabec,{'C5_MOEDA'		,SCJ->CJ_MOEDA					, nil})
		aadd(aCabec,{'C5_TPFRETE'	,SCJ->CJ_TPFRETE				, nil})
		aadd(aCabec,{'C5_FRETE'		,SCJ->CJ_FRETE					, nil})
		aadd(aCabec,{'C5_TPLIB'		,SCJ->CJ_TIPLIB					, nil})
		aadd(aCabec,{'C5_TPCARGA'	,SCJ->CJ_TPCARGA				, nil})
		aadd(aCabec,{'C5_DESCONT'	,SCJ->CJ_DESCONT				, nil})
		aadd(aCabec,{'C5_XNUMORC'	,SCJ->CJ_NUM					, nil})
		aadd(aCabec,{'C5_XOBS'		,SCJ->CJ_XOBS					, nil})
		aadd(aCabec,{'C5_DATA1'		,SCJ->CJ_DATA1+SCJ->CJ_DESCONT	, nil})
		if SCJ->CJ_CONDPAG == '999'
			aadd(aCabec,{'C5_PARC1'	,SCJ->CJ_PARC1+SCJ->CJ_DESCONT	, nil})
		else
			aadd(aCabec,{'C5_PARC1'	,SCJ->CJ_PARC1					, nil})
		endif
		aadd(aCabec,{'C5_DATA2'		,SCJ->CJ_DATA2					, nil})
		aadd(aCabec,{'C5_PARC2'		,SCJ->CJ_PARC2					, nil})
		aadd(aCabec,{'C5_DATA3'		,SCJ->CJ_DATA3					, nil})
		aadd(aCabec,{'C5_PARC3'		,SCJ->CJ_PARC3					, nil})
		aadd(aCabec,{'C5_DATA4'		,SCJ->CJ_DATA4					, nil})
		aadd(aCabec,{'C5_PARC4'		,SCJ->CJ_PARC4					, nil})
		aadd(aCabec,{'C5_FLENT'		,alltrim(cTipoEnt)				, nil})
		if alltrim(cTipoEnt) == 'A'
			aadd(aCabec,{'C5_XENDE'		,'ALMOXARIFADO - '+alltrim(cEndEnt)	, nil})
			aadd(aCabec,{'C5_TPCARGA'	,'2'	, nil})
		elseif alltrim(cTipoEnt) == 'E'
			aadd(aCabec,{'C5_XESTE'		,alltrim(cUFEnt)			, nil})
			aadd(aCabec,{'C5_XCDMUNE'	,alltrim(cCodMunEnt)		, nil})
			aadd(aCabec,{'C5_XMUNE'		,alltrim(cMunEnt)			, nil})
			aadd(aCabec,{'C5_XENDE'		,alltrim(cEndEnt)			, nil})
			aadd(aCabec,{'C5_TPCARGA'	,'1'						, nil})
		elseif alltrim(cTipoEnt) == 'R'
			aadd(aCabec,{'C5_XENDE'		,'RETIRA - '+alltrim(cEndEnt)	, nil})
			aadd(aCabec,{'C5_TPCARGA'	,'2'						, nil})
		endif
		if len(aCAdm)>0
			aadd(aCabec,{'C5_XADM'	,cCAdm							, nil})
			aadd(aCabec,{'C5_XDADM'	,cAdminDesc						, nil})
		endif
		aadd(aCabec,{'C5_XVIAS'		,alltrim(cQtdVias)				, nil})

		/*INICIO DOS ITENS*/
		nX	:= StrZero(0,2)
		SCK->(dbselectarea('SCK'))
		SCK->(dbsetorder(1))
		SCK->(dbGoTop())
		SCK->(dbseek(xfilial('SCK') + SCJ->CJ_NUM))
		while !SCK->(eof()).and.(SCK->CK_FILIAL == xfilial('SCK').and.SCK->CK_NUM == SCJ->CJ_NUM)
			//IncProc()
			aLinha	:= {}
			nX		:= Soma1(nX)
			aadd(aLinha,{"C6_ITEM"		,nX					,Nil})
			aadd(aLinha,{"C6_PRODUTO"	,SCK->CK_PRODUTO	,Nil})
			aadd(aLinha,{"C6_QTDVEN"	,SCK->CK_QTDVEN		,Nil})
			aadd(aLinha,{"C6_PRCVEN"	,SCK->CK_PRCVEN		,Nil})
			aadd(aLinha,{"C6_PRUNIT"	,SCK->CK_PRUNIT		,Nil})
			aadd(aLinha,{"C6_TES"		,SCK->CK_TES		,Nil})
			aadd(aLinha,{"C6_ENTREG"	,cDtEnt				,Nil})
			aadd(aItens,aLinha)
			
			dbSelectArea('SCK')
			SCK->(dbskip())
		enddo

		lMsErroAuto	:= .F.
	
		//Ordena os campos para ficar igual no dicionário
		aCabec := FWVetByDic(aCabec, 'SC5')

		MsExecAuto({|a, b, c| MATA410(a, b, c)}, aCabec, aItens, 3)
		if lMsErroAuto
			RollBackSX8()
			MostraErro()
			lRet:= .F.
			return lRet

		else
			ConfirmSX8()
			RecLock('SCJ',.F.)
			SCJ->CJ_STATUS	:= 'B' //altera para Baixado
			MsUnLock()
		
			//Corrigindo condicao 999
			if SCJ->CJ_CONDPAG == '999'
				if Select('SC5') > 0
					SC5->(dbCloseArea())
				endif
				dbSelectArea('SC5')
				SC5->(dbSetOrder(1))
				SC5->(dbSeek(XFILIAL('SC5')+cNumPed))
				if RecLock('SC5',.F.)
					SC5->C5_PARC1	:= SCJ->CJ_PARC1
					SC5->(MsUnLock())
				endif
			endif
			u_msgInforma('Pedido de Venda gerado com sucesso! '+cNumPed,cForm)
		endif
	endif
return

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
//			cEndEnt	:= ' '+replicate(' ',TAMSX3('C5_XENDE')[1]+TAMSX3('C5_XBAIRRE')[1])
			lRet	:= .T.
		elseif alltrim(cTipoEnt) == 'E'		//ENTREGA
			dbSelectArea('SA1')
			SA1->(dbSetOrder(1))
			SA1->(dbGoTop())
			if SA1->(dbSeek(xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
				cUFEnt		:= SA1->A1_ESTE
				cCodMunEnt	:= SA1->A1_CODMUNE
				cMunEnt		:= SA1->A1_MUNE
				cEndEnt		:= alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRROE)+replicate(' ',TAMSX3('A1_ENDENT')[1]+TAMSX3('A1_BAIRRO')[1]-LEN(alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRRO)))
			endif
			lRet	:= .T.
		elseif alltrim(cTipoEnt) == 'P'
			dbSelectArea('SA1')
			SA1->(dbSetOrder(1))
			SA1->(dbGoTop())
			if SA1->(dbSeek(xFilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
				cUFEnt		:= SA1->A1_ESTE
				cCodMunEnt	:= SA1->A1_CODMUNE
				cMunEnt		:= SA1->A1_MUNE
				cEndEnt		:= alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRROE)+replicate(' ',TAMSX3('A1_ENDENT')[1]+TAMSX3('A1_BAIRRO')[1]-LEN(alltrim(SA1->A1_ENDENT)+' - '+alltrim(SA1->A1_BAIRRO)))
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

static function VldGer()

	local lRet	:= .T.

	if empty(cTipoEnt)
		apMsgAlert('Tipo de entrega inválido. Favor preencher corretamente!',cForm)
		lRet	:= .F.

	elseif alltrim(cTipoEnt) $ 'E|P' .and. empty(cUFEnt)
		apMsgAlert('UF Entrega inválido. Favor preencher corretamente!',cForm)
		lRet	:= .F.

	elseif alltrim(cTipoEnt) $ 'E|P' .and. empty(cCodMunEnt) 
		apMsgAlert('Código Município inválido. Favor preencher corretamente!',cForm)
		lRet	:= .F.

	elseif alltrim(cTipoEnt) $ 'E|P' .and. empty(cMunEnt)
		apMsgAlert('Município Entrega inválido. Favor preencher corretamente!',cForm)
		lRet	:= .F.
*/
	elseif empty(cCAdm)
		if len(aCAdm)>0
			apMsgAlert('Adm. Cartão inválido. Favor preencher corretamente!',cForm)
			lRet	:= .F.
		endif

	endif

return	lRet

static function FSlavaCtr()

	local	lRet		:= .T.
	
	local	cNumCTR		:= '',;
			dEmissao	:= stod('  /  /    '),;
			cCodCli		:= '',;
			cLjCli		:= '',;
			cNomCli		:= '',;
			cCondPgto	:= '',;
			cDescPgto	:= '',;
			cTabela		:= '',;
			cVend		:= '',;
			cNomVend	:= '',;
			nComis		:= 0,;
			cMoeda		:= '',;
			cFilent		:= '',;
			cTipLib		:= '',;
			cStatus		:= '',;
			mObs,;
			cOrca		:= ''
			
	local	cItem		:= 0

	//Preencher as Variaveis
	begin transaction

		cNumCTR		:= GETSX8NUM("ADA","ADA_NUMCTR")                                                                                                   
		dEmissao	:= DDATABASE
		cCodCli		:= SCJ->CJ_CLIENTE
		cLjCli		:= SCJ->CJ_LOJA
		cNomCli		:= SA1->A1_NOME
		cCondPgto	:= SCJ->CJ_CONDPAG
		cDescPgto	:= SCJ->CJ_XDESCON
		cTabela		:= GETMV("MV_TABPAD")                                                                                                              
		cVend		:= SCJ->CJ_XVEND
		cNomVend	:= SCJ->CJ_XNOMVEN
		nComis		:= 0	// VER COM SERÁ PREENCHIDO
		cMoeda		:= SCJ->CJ_MOEDA
		cFilent		:= SCJ->CJ_FILIAL
		cTipLib		:= SCJ->CJ_TIPLIB
		cStatus		:= 'A'
		mObs		:= SCJ->CJ_XOBS
		cOrca		:= SCJ->CJ_NUM
	
		if recLock('ADA',.T.)
			ADA->ADA_FILIAL	:= XFILIAL('ADA')
			ADA->ADA_NUMCTR	:= cNumCTR
			ADA->ADA_EMISSA	:= dEmissao
			ADA->ADA_CODCLI	:= cCodCli
			ADA->ADA_LOJCLI	:= cLjCli
			//ADA->ADA_NOMCLI	:= cNomCli
			ADA->ADA_CONDPG	:= cCondPgto
			ADA->ADA_XDSCPG	:= cDescPgto
			ADA->ADA_TABELA	:= cTabela
			ADA->ADA_VEND1	:= cVend
			ADA->ADA_XNVEN1	:= cNomVend
			//ADA->ADA_COMIS1	:= nComis
			ADA->ADA_MOEDA	:= cMoeda
			//ADA->ADA_FILENT	:= cFilent
			ADA->ADA_TIPLIB	:= cTipLib
			ADA->ADA_STATUS	:= cStatus
			ADA->ADA_XOBS	:= mObs
			ADA->ADA_XNORC	:= cOrca
			ADA->(msUnlock())
		endif

		//item do orcamento
		SCK->(dbselectarea('SCK'))
		SCK->(dbsetorder(1))
		SCK->(dbGoTop())
		SCK->(dbseek(xfilial('SCK') + SCJ->CJ_NUM))
		while !SCK->(eof()).and.(SCK->CK_FILIAL == xfilial('SCK').and.SCK->CK_NUM == SCJ->CJ_NUM)
		
			cItem	+= 1

			if recLock('ADB',.T.)
				ADB->ADB_FILIAL		:= XFILIAL('ADB')
				ADB->ADB_NUMCTR		:= cNumCTR
				ADB->ADB_ITEM		:= strZero(cItem,2)
				ADB->ADB_CODPRO		:= SCK->CK_PRODUTO
				ADB->ADB_DESPRO		:= posicione('SB1',1,XFILIAL('SB1')+SCK->CK_PRODUTO,'B1_DESC')
				ADB->ADB_UM			:= posicione('SB1',1,XFILIAL('SB1')+SCK->CK_PRODUTO,'B1_UM')
				ADB->ADB_QUANT		:= SCK->CK_QTDVEN
				ADB->ADB_PRCVEN		:= SCK->CK_PRCVEN
				ADB->ADB_TOTAL		:= SCK->CK_QTDVEN*SCK->CK_PRCVEN
				ADB->ADB_TES		:= '524'
				ADB->ADB_TESCOB		:= SCK->CK_TES
				ADB->ADB_LOCAL		:= posicione('SB1',1,XFILIAL('SB1')+SCK->CK_PRODUTO,'B1_LOCPAD')
				ADB->ADB_PRUNIT		:= SCK->CK_PRUNIT
				ADB->ADB_SEGUM		:= posicione('SB1',1,XFILIAL('SB1')+SCK->CK_PRODUTO,'B1_SEGUM')
				ADB->ADB_UNSVEN		:= convUM(SCK->CK_PRODUTO,SCK->CK_QTDVEN,0,2)	//convUM(<COD.PRODUTO>,<QTD 1ª UNID>,<QTD 2ª UNID>,<QUAL RETORNO (1 = 1ª UNID, 2 = 2ª UNID)>)
				ADB->ADB_CODCLI		:= SCJ->CJ_CLIENTE
				ADB->ADB_LOJCLI		:= SCJ->CJ_LOJA

				ADB->(msUnlock())
			endif
			
			SCK->(dbskip())
		enddo

		//altera o orcamento para baixado
		if recLock('SCJ',.F.)
			SCJ->CJ_STATUS	:= 'B'
			SCJ->(msUnlock())
		endif
	
		lMsErroAuto	:= .F.

		if lMsErroAuto
			RollBackSX8()
			MostraErro()
			lRet	:= .F.
		else
			ConfirmSX8()
		endif

	end transaction
	
return lRet
