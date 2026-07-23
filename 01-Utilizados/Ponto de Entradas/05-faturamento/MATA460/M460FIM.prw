#include 'protheus.ch'
#include 'tbiconn.ch'
#include "rwmake.CH"
#include "topconn.ch"
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: M460FIM
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 21/08/2018
===============================================================================================================================
Descrição---------: Este PE é executado apos a conclusao do faturamento (geração doc de saida)
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor		|	Data	|										Motivo																
----------------:-----------:-------------------------------------------------------------------------------------------------------:
RENATO FUZESSY	|31.10.2018	| INSERIR REGISTRO NA Z03 e Z07 - CONTROLE DE ENTREGAS PARA OS PEDIDOS DE VENDAS FATURADOS																							
----------------:-----------:-------------------------------------------------------------------------------------------------------:
RENATO FUZESSY	|21.01.2019	| ENIVAR EMAIL COM A AUDITORIA DA REIMPRESSAO DO PEDIDO DE VENDA																							
----------------:-----------:-------------------------------------------------------------------------------------------------------:
RENATO FUZESSY	|28.05.2024	| OTIMIZAR ROTINA DE CONTROLE DE SITUAÇÃO DOS PEDIDOS  DE VENDAS 																							
----------------:-----------:-------------------------------------------------------------------------------------------------------:
				|			|																											
=====================================================================================================================================
/*/

user function M460FIM()

	local 	aArea		as character,;
			aAreaSC5	as character,;
			aAreaSF2	as character,;
			aAreaSE1	as character

	local 	cAmbiente	as caracter,;
			cTipoEnt	as caracter
			
	local	cDAdm		as caracter,;
			cTpAdm		as caracter,;
			cImp		as caracter

	local	nValor		as numeric,;
			cTpVend		as caracter

	aArea		:= fwgetArea()
	aAreaSC5	:= SC5->(fwgetArea())
	aAreaSF2	:= SF2->(fwgetArea())
	aAreaSE1	:= SE1->(fwgetArea())

	cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))
	cTipoEnt	:= SC5->C5_FLENT
	cDAdm		:= ''
	CTpAdm		:= ''
	cImp		:= GetMv("MV_XPRVEN")
	nValor		:= U_xVlNota(SF2->F2_SERIE,SF2->F2_DOC)
	cTpVend		:= posicione('SA3',1,fwxFilial('SA3')+SF2->F2_VEND1,'A3_TIPO')

	//atualizando o valor total apurado no faturamento para o campo C5_XVLTOT do SC5, para que seja possível a conferência do valor total do pedido com o valor total do faturamento, e também para que seja possível a impressão do valor total no relatório de conferência de faturamento (RD06010)
	if reclock("SC5",.F.)
		SC5->C5_XVLTOT	:= nValor
		SC5->(msunlock())
	endif

	//atualizando o campo F2_XREGVEN para controlar a regiãodo vendedor no BI
	if reclock('SF2',.F.)
		if empty(cTpVend)
			SF2->F2_XREGVEN	:= 'O'
		else
			SF2->F2_XREGVEN	:= cTpVend
		endif
		SF2->(msunlock())
	endif

	if cAmbiente == '1'

		//TRATAMENTO PARA VENDAS DE CARTAO
		if empty(SC5->C5_XIMP) .or. !SC5->C5_XIMP == 'S'
			if !empty(SC5->C5_XADM)
				cDAdm	:= BuscaDADM(SC5->C5_XADM)
				cTpAdm	:= BuscaTipo(SC5->C5_XADM)
				E1ECARTAO(SC5->C5_XADM,cDAdm,cTpAdm)
			else
				cTpAdm	:= BuscaTpE4(SC5->C5_CONDPAG)
				E1NECARTAO(cTpAdm)
			endif
		endif

		//imprimindo Pedido de Venda
		U_ImpPedVen(SC5->C5_NUM,,cImp,SC5->C5_XVIAS)
		cTipoEnt:= SC5->C5_FLENT
		
		//CONTROLE DE PEDIDOS INTERNOS
		u_MovSitPed(SF2->F2_SERIE, SF2->F2_DOC, '01', dDataBase, time())	// FATURADO
		if cTipoEnt	== 'D'
			u_MovSitPed(SF2->F2_SERIE, SF2->F2_DOC, '12', dDataBase, time())	// ENTREGA DIRETO
		endif
	 
	elseif cAmbiente == '2'
		dbSelectArea('Z50')
		Z50->(dbSetOrder(3))
		Z50->(dbGoTop())
		if Z50->(dbSeek(FWxFilial('Z50')+SC5->C5_NUM))
			while !Z50->(EOF()) .and. Z50->Z50_NUMPED == SC5->C5_NUM
				if recLock('Z50',.F.)
					Z50->Z50_SERIE	:= SF2->F2_SERIE
					Z50->Z50_NFISCA	:= SF2->F2_DOC
					Z50->(msUnlock())
				endif
				Z50->(dbSkip())
			end
		endif
		dbSelectArea('SC5')
		if SC5->C5_XGERBOL == 'S'
			U_RD06010(FunName(), .T., .T.)
		end
	endif

	fwrestArea(aAreaSE1)
	fwrestArea(aAreaSF2)
	fwrestArea(aAreaSC5)
	fwrestArea(aArea)

return

static function BuscaDAdm(pCodigo)
	
	local	aArea		:= getArea(),;
			aAreaSAE	:= SAE->(getArea())

	local 	cDAdmin	:= ''
	
	dbSelectArea('SAE')
	SAE->(dbSetOrder(1))
	SAE->(dbGoTop())
	if SAE->(dbSeek(xFilial('SAE')+pCodigo))
		cDAdmin	:= SAE->AE_DESC
	endif
	
	restArea(aAreaSAE)
	restArea(aArea)

return cDAdmin

static function BuscaTipo(pCodigo)
	
	local	aArea		:= getArea(),;
			aAreaSAE	:= SAE->(getArea())

	local 	cTipo	:= ''
	
	dbSelectArea('SAE')
	SAE->(dbSetOrder(1))
	SAE->(dbGoTop())
	if SAE->(dbSeek(xFilial('SAE')+pCodigo))
		cTipo	:= SAE->AE_TIPO
	endif
	
	restArea(aAreaSAE)
	restArea(aArea)

return cTipo

static function E1ECARTAO(cCAdm,cDAdm,cTpAdm)
	local	aArea		:= getArea(),;
			aAreaSE1	:= SE1->(getArea()),;
			aAreaSF2	:= SF2->(getArea())

	dbSelectArea('SE1')
	SE1->(dbSetOrder(1))
	SE1->(dbGoTop())
	SE1->(dbSeek(xFilial('SE1')+SF2->F2_SERIE+SF2->F2_DOC))
	while !SE1->(eof()) .and. SE1->E1_PREFIXO == SF2->F2_SERIE .and. SE1->E1_NUM == SF2->F2_DOC
		if recLock('SE1',.F.)
			SE1->E1_XFORMA	:= cTpAdm
			SE1->E1_XCPGTO	:= SC5->C5_CONDPAG
			SE1->E1_XDPGTO	:= SC5->C5_XDESCON
			SE1->E1_XQTPARC	:= len(condicao(100,SC5->C5_CONDPAG))
//			SE1->E1_XTXADM	:= 0
//			SE1->E1_XTXFF1	:= 0
//			SE1->E1_XTXFF2	:= 0
			SE1->E1_XCADM	:= cCAdm
			SE1->E1_XDADM	:= cDAdm
			SE1->E1_XFORMA	:= cTpAdm
			SE1->(msUnlock())
		endif
		SE1->(dbSkip())
	enddo
	
	restArea(aAreaSF2)
	restArea(aAreaSE1)
	restArea(aArea)
return

static function E1NECARTAO(cTpAdm)
	local	aArea		:= getArea(),;
			aAreaSE1	:= SE1->(getArea()),;
			aAreaSF2	:= SF2->(getArea())

	dbSelectArea('SE1')
	SE1->(dbSetOrder(1))
	SE1->(dbGoTop())
	SE1->(dbSeek(xFilial('SE1')+SF2->F2_SERIE+SF2->F2_DOC))
	while !SE1->(eof()) .and. SE1->E1_PREFIXO == SF2->F2_SERIE .and. SE1->E1_NUM == SF2->F2_DOC
		if recLock('SE1',.F.)
			SE1->E1_XCPGTO	:= SC5->C5_CONDPAG
			SE1->E1_XDPGTO	:= SC5->C5_XDESCON
			SE1->E1_XQTPARC	:= len(condicao(100,SC5->C5_CONDPAG))
			SE1->E1_XFORMA	:= cTpAdm
			SE1->(msUnlock())
		endif
		SE1->(dbSkip())
	enddo
	
	restArea(aAreaSF2)
	restArea(aAreaSE1)
	restArea(aArea)
return

static function BuscaTpE4(pCodigo)
	
	local	aArea		:= getArea(),;
			aAreaSE4	:= SE4->(getArea())

	local 	cTipo	:= ''
	
	dbSelectArea('SE4')
	SE4->(dbSetOrder(1))
	SE4->(dbGoTop())
	if SAE->(dbSeek(xFilial('SE4')+pCodigo))
		cTipo	:= SE4->E4_FORMA
	endif
	
	restArea(aAreaSE4)
	restArea(aArea)

return cTipo

