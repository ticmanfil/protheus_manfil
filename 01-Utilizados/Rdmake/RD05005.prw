#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: RD05005
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 05/01/2019
===============================================================================================================================
Descrição---------: Este programa serve para categorizar o motivo de cancelamento do orcamento
===============================================================================================================================
Uso---------------: MATA415 - ORCAMENTO
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
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
user function RD05005(pLocal, pNumOrc, pCodMotPerda, pStatus)

	local 	lRet			:= .F.,;
			nOpca			:= ' '

	local 	oGet01,;
			oGet02,;
			oGet03

	local 	cNumORC			:= pNumOrc,;
			cStatus			:= pStatus,;
			cLocal			:= pLocal,;
			lContinue		:= .F.

	private	cCodMotPerda	:= pCodMotPerda,;
			cMotPerda		:= space(tamsx3('MBQ_DSCVEP')[1]),;
			nVlPerda		:= 0.00
	
	if alltrim(cCodMotPerda) != ''
		cMotPerda	:= posicione('MBQ',1,xfilial('MBQ')+alltrim(pCodMotPerda),'MBQ_DSCVEP')
	else
		cMotPerda	:= ''
	endif                                                                     
	
	if cLocal == 'ORC'
		if !cStatus $ '|A|D|' .and. !retCodUsr() == '000000'
			U_msgErro('Orçamento já BAIXADO!'+chr(13)+'Ação será cancelado.','[RD05005]')
			lRet	:= .F.

		else
			dbSelectArea('SC6')
			SC6->(dbSetOrder(19))
			SC6->(dbGoTop())
			if SC6->(dbSeek(XFILIAL('SC6')+cNumORC))
				U_msgErro('Existe Pedido de Venda para Este Orçamento!! ('+alltrim(SC5->C5_NUM)+')'+CRLF+'Ação será cancelado.','[RD05005]')
				lRet	:= .F.
		
			else
				lContinue	:= .T.
			endif
			SC5->(dbCloseArea())
		endif	
	elseif cLocal == 'PV'
		lContinue	:= .T.
	endif

	if lContinue
		SetPrvt('oDlg1','oSay1','oSBtnOk','oSBtnCan')
		
		DEFINE MSDIALOG oDlg TITLE '[RD05005]-Catalogando Motivo de Canc/Exc de Orçamento' From 0,0 TO 175,530 PIXEL
		
		@ 010,004 SAY OemToansi('Motivo de Canc/Exc:') SIZE 052, 008 OF oDlg PIXEL
		@ 010,060 MSGET oGet01 VAR cCodMotPerda F3 'MBQ' SIZE 032,008 PICTURE X3PICTURE('CJ_XMOT') VALID XVALID(1) OF oDlg PIXEL
		@ 010,095 MSGET oGet02 VAR cMotPerda SIZE 165,008 PICTURE X3PICTURE('CJ_XDSCMOT') WHEN .F. OF oDlg PIXEL

		@ 025,004 SAY OemToansi('Vl. Concorrente:') SIZE 052, 008 OF oDlg PIXEL
		@ 025,060 MSGET oGet03 VAR nVlPerda SIZE 052,008 PICTURE X3PICTURE('CJ_XVLPERD') OF oDlg PIXEL
				
		DEFINE SBUTTON FROM 70, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
		DEFINE SBUTTON FROM 70, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED	
	
		if nOpca == '1'
			
			if RecLock('SCJ',.F.)
				SCJ->CJ_XMOT	:= cCodMotPerda
				SCJ->CJ_XDTCANC	:= DDATABASE
				SCJ->CJ_XUSRCAN	:= CUSERNAME
				SCJ->CJ_XVLPERD	:= nVlPerda
				msUnLock()
			endif

			lMsErroAuto	:= .F.
		
			if lMsErroAuto
				MostraErro()
				lRet	:= .F.

			else
				pEnviaAudit(alltrim(cCodMotPerda)+' - '+alltrim(cMotPerda))
				lRet	:= .T.
			
			endif
		
		else
			lRet	:= .F.
		
		endif

	endif
return lRet

static function XVALID(pCampo)

	local lRet	:= .F.

	if pCampo == 1
		if alltrim(cCodMotPerda) == '000' .and. retCodUsr() != '000000'
			U_msgErro('Motivo permitido somente para ADMINISTRADOR'+chr(13)+'Ação será cancelado.','[RD05005]')
			lRet	:= .F.

		else
			dbSelectArea('MBQ')
			MBQ->(dbGoTop())
			MBQ->(dbSetOrder(1))
			if (MBQ->(dbSeek(xFilial('MBQ')+cCodMotPerda)))
				cMotPerda	:= MBQ->MBQ_DSCVEP
				lRet		:= .T.
		
			endif
			MBQ->(dbCloseArea())
		
		endif
	
	endif

return	lRet

static function pEnviaAudit(pMotivo)

	local lRet		:= .F.
	local VlOrcam	:= U_UVlOrc(SCJ->CJ_NUM)
	
	//variaveis para composicao do email auditoria
	local cPara		:= alltrim(posicione('SA3',1,xfilial('SA3')+SCJ->CJ_XVEND,'A3_EMAIL'))
	local cCliente	:= alltrim(posicione('SA1',1,xfilial('SA1')+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,'A1_NREDUZ'))
	local cAssunto	:= '[INF-PROTHEUS] Orçamento Cancelado/Excluído '+alltrim(SCJ->CJ_NUM)+' - '+alltrim(cCliente)+' R$ '+transform(VlOrcam,x3Picture('CJ_XVLTOT'))
	local cCorpo	:= ''
	
	cCorpo	:= 'O orçamento abaixo foi CANCELADO/EXCLUÍDO conforme dados abaixo:'+chr(13)+chr(10)+chr(13)+chr(10)
	cCorpo	+= 'Num. Orçamento.: '+alltrim(SCJ->CJ_NUM)+chr(13)+chr(10)+chr(13)+chr(10)
	cCorpo	+= 'Data Emissão...: '+dtoc(SCJ->CJ_EMISSAO)+chr(13)+chr(10)+chr(13)+chr(10)
	cCorpo	+= 'Cliente........: '+alltrim(cCliente)+chr(13)+chr(10)+chr(13)+chr(10)
	cCorpo	+= 'Valor..........: R$ '+transform(VlOrcam,x3Picture('CJ_XVLTOT'))+chr(13)+chr(10)+chr(13)+chr(10)
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
