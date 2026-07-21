#include 'protheus.ch'
#include 'parmtype.ch'

/*/
===============================================================================================================================
Programa----------: FA60TRAN
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 26/08/2019
===============================================================================================================================
Descrição---------: Este programa serve para baixar titulos parcialmente que tenham abatimento automatico
===============================================================================================================================
Uso---------------: Contas a Receber
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFIN
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

user function FA60TRAN()

	Local 	_aArea		:= GetArea(),;
			_aAreaZ18	:= Z18->(getArea()),;
			cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))

	//inserindo integração de boletas
	chkfile('Z18')
	if cAmbiente == '2'
		if reclock('Z18',.T.)
			Z18->Z18_FILIAL	:= xFilial('Z18')
			Z18->Z18_SEQ	:= GetSXENum('Z18','Z18_SEQ')
			Z18->Z18_PREFIX	:= SE1->E1_PREFIXO
			Z18->Z18_NUMERO	:= SE1->E1_NUM
			Z18->Z18_PARCEL	:= SE1->E1_PARCELA
			Z18->Z18_TIPO	:= SE1->E1_TIPO
			Z18->Z18_CLIENT	:= SE1->E1_CLIENTE
			Z18->Z18_LOJA	:= SE1->E1_LOJA
			Z18->Z18_STATUS	:= 'C'		// A CANCELAR
			Z18->Z18_DATA	:= DATE()
			Z18->Z18_HORA	:= TIME()
			Z18->Z18_INT	:= 'N'
			Z18->Z18_PORTAD	:= SE1->E1_PORTADO
			Z18->Z18_AGEDEP	:= SE1->E1_AGEDEP
			Z18->Z18_CONTA	:= SE1->E1_CONTA
			Z18->Z18_NUMBOR	:= SE1->E1_NUMBOR
			Z18->Z18_DTBORD	:= SE1->E1_DATABOR
			Z18->Z18_IDCNAB	:= SE1->E1_IDCNAB
			Z18->Z18_SERORI	:= FSerie(SE1->E1_PREFIXO+SE1->E1_NUM)
			Z18->Z18_DOCORI	:= FNota(SE1->E1_PREFIXO+SE1->E1_NUM)
			Z18->Z18_CODBAR	:= SE1->E1_CODBAR
			Z18->Z18_CODDIG	:= SE1->E1_CODDIG
			Z18->Z18_NUMBCO	:= SE1->E1_NUMBCO
			Z18->Z18_VENCTO	:= SE1->E1_VENCTO
			Z18->Z18_VALOR	:= SE1->E1_VALOR
			CONFIRMSX8()
			Z18->(msUnlock())
		endif
	endif

	restArea(_aAreaZ18)
	restArea(_aArea)

return

static function FNota(pTitulo)
	local	aArea		:= getArea(),;
			aAreaSC5	:= SC5->(getArea())

	local	cNumNota	:= ''

	dbSelectArea('SC5')
	SC5->(dbSetOrder(10))
	SC5->(dbGoTop())
	if (SC5->(dbSeek(xFilial('SC5')+pTitulo)))

		if !SC5->(eof())
			cNumNota	:= SC5->C5_XNFINT 
		endif

	endif

	restArea(aAreaSC5)
	restArea(aArea)

return cNumNota

static function FSerie(pTitulo)
	local	aArea		:= getArea(),;
			aAreaSC5	:= SC5->(getArea())

	local	cSerie		:= ''

	dbSelectArea('SC5')
	SC5->(dbSetOrder(10))
	SC5->(dbGoTop())
	if (SC5->(dbSeek(xFilial('SC5')+pTitulo)))

		if !SC5->(eof())
			cSerie	:= SC5->C5_XSRORIG
		endif

	endif

	restArea(aAreaSC5)
	restArea(aArea)

return cSerie
