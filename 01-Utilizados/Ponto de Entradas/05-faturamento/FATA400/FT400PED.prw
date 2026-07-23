#include 'protheus.ch'
#include 'parmtype.ch'

user function FT400PED()

	local	cNumPedPri	as char,;
			cFlent		as char,;
			cTpCarga	as char,;
			cEst		as char,;
			cCodMuni	as char,;
			cMunicipio	as char,;
			cEndEnt		as char

	cNumPedPri:= posicione("ADB",1,xFilial("ADB")+ADA->ADA_NUMCTR,"ADB_PEDCOB")
	beginsql alias 'TB1'
		select C5_FLENT, C5_TPCARGA, C5_XESTE, C5_XCDMUNE, C5_XMUNE, C5_XENDE from %table:SC5% SC5 where SC5.%notdel% and SC5.C5_FILIAL = %xfilial:SC5% and SC5.C5_NUM = %exp:cNumPedPri%
	endsql
	
	dbSelectArea('TB1')
	TB1->(dbGoTop())
		cFlent		:= TB1->C5_FLENT
		cTpCarga	:= TB1->C5_TPCARGA
		cEst		:= TB1->C5_XESTE
		cCodMuni	:= TB1->C5_XCDMUNE
		cMunicipio	:= TB1->C5_XMUNE
		cEndEnt		:= TB1->C5_XENDE
	TB1->(dbCloseArea())	
	
	C5_XCLIENT	:= Posicione("SA1",1,xFilial("SA1")+ADA->ADA_CODCLI+ADA->ADA_LOJCLI,"A1_NOME")     
	C5_XNOMCON	:= Posicione("SA1",1,xFilial("SA1")+ADA->ADA_CODCLI+ADA->ADA_LOJCLI,"A1_NOME")     
	C5_XNVEND1	:= ADA->ADA_XNVEN1
	C5_XDESCON	:= ADA->ADA_XDSCPG
	C5_XOBS		:= ADA->ADA_XOBS
	C5_XNUMPAR	:= ADA->ADA_NUMCTR
	C5_FLENT	:= cFlent
	C5_TPCARGA	:= cTpCarga
	C5_XESTE	:= cEst
	C5_XCDMUNE	:= cCodMuni
	C5_XMUNE	:= cMunicipio
	C5_XENDE	:= cEndEnt

return
