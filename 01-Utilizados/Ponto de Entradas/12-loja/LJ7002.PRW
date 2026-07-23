#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Topconn.ch"
/*/
===============================================================================================================================
Programa----------: LJ7002 
Autor-------------: RENATO FUZESSY
Data da Criacao---: 08/07/2019
===============================================================================================================================
Descrição---------: Permite alterar a SERIE e NUM NOTA FISCAL na SC5
===============================================================================================================================
Uso---------------: loja701
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: Sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: CONTROLE DE LOJAS
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

User Function LJ7002() 

	local 	_aArea:= getArea()

/*	Private lDanfe		:= .T.
	Private lBolet		:= .F.
	Private lViewPDF	:= .F.
*/
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+SL1->L1_XPEDIDO))
	while !eof() .and. SC6->C6_NUM == SL1->L1_XPEDIDO
	
		RecLock("SC6", .F.)	
			SC6->C6_SERIE 	:= SL1->L1_SERIE
			SC6->C6_NOTA	:= SL1->L1_DOC
		MsUnLock() 
		
		SC6->(dbSkip())
	enddo
	SC6->(dbCloseArea())
	
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial("SC5")+SL1->L1_XPEDIDO))
	while !eof() .and. SC5->C5_NUM == SL1->L1_XPEDIDO
	
		RecLock("SC5", .F.)	
			SC5->C5_SERIE 	:= SL1->L1_SERIE
			SC5->C5_NOTA	:= SL1->L1_DOC
		MsUnLock() 
		
		SC5->(dbSkip())
	enddo
	SC5->(dbCloseArea())

	dbSelectArea('Z50')
	Z50->(dbSetOrder(3))
	Z50->(dbGoTop())
	if Z50->(dbSeek(FWxFilial('Z50')+SL1->L1_XPEDIDO))
		while !Z50->(EOF()) .and. Z50->Z50_NUMPED == SL1->L1_XPEDIDO
			if recLock('Z50',.F.)
				Z50->Z50_SERIE	:= SL1->L1_SERIE
				Z50->Z50_NFISCA	:= SL1->L1_DOC
				Z50->(msUnlock())
			endif
			Z50->(dbSkip())
		end
	endif
	Z50->(dbCloseArea())

	//enviando o email para o cliente
//	lViewPDF	:= .F.
//	lDanfe		:= .T.
//	U_FATWS001(SL1->L1_DOC,SL1->L1_SERIE,SL1->L1_CLIENTE,SL1->L1_LOJA,SL1->L1_SERIE,lViewPDF)

	RestArea(_aArea)
		
return
