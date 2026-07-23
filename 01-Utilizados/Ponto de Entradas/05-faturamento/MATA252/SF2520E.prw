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

/*/
===============================================================================================================================
Programa----------: SF2520E
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 30/10/2018
===============================================================================================================================
Descrição---------: Este programa serve para excluir OS PEDIDOS DE VENDA para CONTROLE DE ENTREGA
===============================================================================================================================
Uso---------------: MATA520 - EXCLUSAO DE NOTAS DE SAIDA
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: .T. ou .F.
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
===============================================================================================================================
/*/

user function SF2520E()

	local	cAmbiente	as caractere,;
			cForm		as caractere,;
			cNumPedido	as caractere,;
			cSitNota	as caractere,;
			cDscSitNota	as caractere,;
			lCancel		as logical
	
	private lMsErroAuto	as logical

	cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))
	cForm		:= 'SF2520E'
	lMsErroAuto	:= .F.
	cNumPedido	:= posicione('SD2',3,fwxFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE,'D2_PEDIDO')

	if cAmbiente == '1'
		cSitNota	:= SF2->F2_XSTNOTA
		cDscSitNota	:= posicione('Z04',1,fwxFilial('Z04')+cSitNota,'Z04_STATUS')
		lCancel		:= posicione('Z04',1,fwxFilial('Z04')+cSitNota,'Z04_FLCANC')

		//Validando a data de cancelamento
		if ddataBase != date()
			U_msgErro('A data do sistema ' + cValtoChar(ddataBase) + ' é diferente da data atual ' + cValtoChar(date()) + ', por favor verifique!','['+cForm+']')
			pEnviaAudit('Data do sistema diferente da data atual')
		endif

		//Validando se o pedido está em situação passivel de cancelamento
		if lCancel
			U_msgErro('O pedido ' + cNumPedido + ' está com situação ' + cDscSitNota + ' não passível de cancelamento!'+CRLF;
				+'Por favor verifique!','['+cForm+']')
			pEnviaAudit('Situação do pedido não permite cancelamento '+cDscSitNota)
		endif		

/*		elseif SF2->F2_EMISSAO != date()
			U_msgErro('A data de emissão do pedido é diferente da data atual, por favor verifique!','['+cForm+']')
			return lRet
		endif
*/
		//inserindo controle de entregas
		begin transaction
			
			dbSelectArea('Z07') 
			Z07->(dbSetOrder(1))
			Z07->(dbGoTop())
			Z07->(dbSeek(xFilial('Z07')+SF2->F2_SERIE+SF2->F2_DOC))
			while (Z07->Z07_SERIE == SF2->F2_SERIE .and. Z07->Z07_NOTA == SF2->F2_DOC)
				RecLock('Z07',.F.)
					Z07->(dbDelete())
				MsUnLock()
				Z07->(dbSkip())
			enddo

			dbSelectArea('Z03') 
			Z03->(dbSetOrder(1))
			Z03->(dbGoTop())
			Z03->(dbSeek(xFilial('Z03')+SF2->F2_SERIE+SF2->F2_DOC))
			while (Z03->Z03_SERIE == SF2->F2_SERIE .and. Z03->Z03_NOTA == SF2->F2_DOC)
				RecLock('Z03',.F.)
					Z03->(dbDelete())
				MsUnLock()
				Z03->(dbSkip())
			enddo
			Z03->(dbCloseArea())

			dbSelectArea('SC5') 
			SC5->(dbSetOrder(1))
			SC5->(dbGoTop())
			if SC5->(dbSeek(xFilial('SC5')+cNumPedido))
				RecLock('SC5',.F.)
					SC5->C5_XIMP	:= ''
					SC5->C5_XUSERIM	:= ''
					SC5->C5_DTIMP	:= ctod('')
					SC5->C5_HRIMP	:= ''
				MsUnLock()
			endif

			if lMsErroAuto
				disarmTransaction()
				u_msgErro('Erro ao processar a exclusão do pedido nos controles de entrega','['+cForm+']')
				pEnviaAudit('Erro ao processar a exclusão do pedido nos controles de entrega')
				MostraErro()
			endif

		end transaction

	endif 

return

static function pEnviaAudit(pMotivo)

	local	cPara		as caractere,;
			cAssunto	as caractere,;
			cCorpo		as caractere,;
			nValor		as numeric,;
			cDoc		as caractere,;
			cNumPed		as caractere,;
			dDtEmissao	as date

	nValor		:= SF2->F2_VALBRUT
	cDoc		:= SF2->F2_SERIE + '-' + SF2->F2_DOC
	cNumPed		:= posicione('SD2',3,fwxFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE,'D2_PEDIDO')
	dDtEmissao	:= SF2->F2_EMISSAO

	//variaveis para composicao do email auditoria
	cPara		:= 'renato.filho@manfil.com.br' //u_emails('000000')	//email do grupo de administradores
	cCliente	:= alltrim(posicione('SA1',1,xfilial('SA1')+SF2->F2_CLIENTE+SF2->F2_LOJA,'A1_NREDUZ'))
	cAssunto	:= '[AUDIT-PROTHEUS] Doc. Saida Exluido Indevidamente '+alltrim(cDoc)+' - '+alltrim(cCliente)+' R$ '+transform(nValor,x3Picture('F2_VLBRUT'))
	cCorpo		:= ''
	
	cCorpo	:= 'O Doc. Saída abaixo foi CANCELADO/EXCLUÍDO indevidamente:'+CRLF+CRLF
	cCorpo	+= 'Num. Pedido....: '+alltrim(cNumPed)+CRLF+CRLF
	cCorpo	+= 'Num. Doc. Saída: '+alltrim(cDoc)+CRLF+CRLF
	cCorpo	+= 'Data Emissão...: '+dtoc(dDtEmissao)+CRLF+CRLF
	cCorpo	+= 'Cliente........: '+alltrim(cCliente)+CRLF+CRLF
	cCorpo	+= 'Valor..........: R$ '+transform(nValor,x3Picture('F2_VLBRUT'))+CRLF+CRLF
	cCorpo	+= 'Motivo.........: '+alltrim(pMotivo)

	lRet	:= U_EnvMail(	 /*cMailDe			*/ '';
							,/*cMailPara		*/ cPara;
							,/*cMailCopia		*/ '';
							,/*cMailCopiaOculta	*/ '';
							,/*cAssunto			*/ cAssunto;
							,/*cCorpo			*/ cCorpo;
							,/*cAnexo			*/ '';
							,/*_lReturn			*/ .F.)

return
