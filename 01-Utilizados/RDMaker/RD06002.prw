#include 'protheus.ch'
#include 'topconn.ch'
/*/
===============================================================================================================================
Programa----------: RD06002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para gerar os bordero em conjunto com o PE M460FIM
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
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
user function RD06002()

	Local _aArea		:= GetArea()
	Local _aAreaSE1		:= SE1->(GetArea())
	Local _aAreaSC5		:= SC5->(GetArea())
	Local _aAreaSEA		:= SEA->(GetArea())
	Local _aAreaSAE		:= SAE->(GetArea())
	Local _aAreaSA6		:= SA6->(GetArea())
	Local _aAreaZ18		:= Z18->(getArea())
	Local cFuncao		:= FunName()
	
	Local _cNumDoc		:= ""
	Local _cSerie		:= ""
	Local _cCliente		:= ""
	Local _cCliLoja		:= ""
	Local _cParcela		:= ""
	//Local _cTipo		:= ""
	
	Local _cChvSA6		:= Alltrim(GetMv("CO_BOLETO")) //Retorna banco+agencia+conta para geração de boleto
//	Local _cChvSA6		:= '3410944 010735'	//Alltrim(GetMv("CO_BOLETO")) //Retorna banco+agencia+conta para geração de boleto
	
	//Local _cNatureza	:= "RECEBIMENT"
	Local _cNumBord		:= ""
	Local _cBanco		:= ""
	Local _cAgenc		:= ""
	Local _cConta		:= ""
	Local _dDataBord	:= dtos(DDATABASE)
	Local _nTipo		:= "1"
	
	local cTitulo		:= ""

	private	cSeqInt		:= ''
	
	if cFuncao == "MATA410"
		_cNumDoc	:= SC5->C5_NOTA
		_cSerie		:= SC5->C5_SERIE
		_cCliente	:= SC5->C5_CLIENTE
		_cCliLoja	:= SC5->C5_LOJACLI
		//_cTipo		:= "NF"
		cTitulo	+= xFilial('SE1') +_cSerie + _cNumDoc + _cCliente + _cCliLoja + '|'
	elseif cFuncao == "LOJA701"
		_cNumDoc	:= SC5->C5_NOTA
		_cSerie		:= SC5->C5_SERIE
		_cCliente	:= SC5->C5_CLIENTE
		_cCliLoja	:= SC5->C5_LOJACLI
		//_cTipo		:= "NF"
		cTitulo	+= xFilial('SE1') +_cSerie + _cNumDoc + _cCliente + _cCliLoja + '|'
	elseif cFuncao == "MATA461"
		_cNumDoc	:= SC5->C5_NOTA
		_cSerie		:= SC5->C5_SERIE
		_cCliente	:= SC5->C5_CLIENTE
		_cCliLoja	:= SC5->C5_LOJACLI
		//_cTipo		:= "NF"
		cTitulo	+= xFilial('SE1') +_cSerie + _cNumDoc + _cCliente + _cCliLoja + '|'
	elseif cFuncao == "MV05002"
		_cNumDoc	:= SF2->F2_DOC
		_cSerie		:= SF2->F2_SERIE
		_cCliente	:= SF2->F2_CLIENTE
		_cCliLoja	:= SF2->F2_LOJA
		//_cTipo		:= "NF"
		cTitulo	+= xFilial('SE1') +_cSerie + _cNumDoc + _cCliente + _cCliLoja + '|'
	elseif cFuncao == "FINA280"
		_cNumDoc	:= SE1->E1_NUM
		_cSerie		:= SE1->E1_PREFIXO
		_cCliente	:= SE1->E1_CLIENTE
		_cCliLoja	:= SE1->E1_LOJA
		//_cTipo		:= SE1->E1_TIPO                                    
		cTitulo	+= xFilial('SE1') +_cSerie + _cNumDoc + _cCliente + _cCliLoja + '|'
	elseif cFuncao == "FINA740"
		_cNumDoc	:= SE1->E1_NUM
		_cSerie		:= SE1->E1_PREFIXO
		_cCliente	:= SE1->E1_CLIENTE
		_cCliLoja	:= SE1->E1_LOJA
		_cParcela	:= SE1->E1_PARCELA
		cTitulo	+= xFilial('SE1') +_cSerie + _cNumDoc + _cCliente + _cCliLoja + _cParcela + '|'
	elseif cFuncao == "FINA460"
		_cNumDoc	:= SE1->E1_NUM
		_cSerie		:= SE1->E1_PREFIXO
		_cCliente	:= SE1->E1_CLIENTE
		_cCliLoja	:= SE1->E1_LOJA
		//_cTipo		:= SE1->E1_TIPO
		cTitulo	+= xFilial('SE1') +_cSerie + _cNumDoc + _cCliente + _cCliLoja + '|'
	else
		Alert('Programa '+alltrim(FunName())+' não previsto para usar este RDMAKE.'+chr(10)+chr(13);
				+'Favor informe ao administrador do sistema.'+chr(10)+chr(13);
				+'Essa ação será ABORTADA.')
	endif
	

	If Select("TB01")<>0
		TB01->(DbCloseArea())
	EndIf
	
	cQuery:="SELECT R_E_C_N_O_, E1_NUMBOR FROM "+RetSqlName("SE1")+" "
	cQuery+="WHERE "
	cQuery+="E1_NUM 	= '"+_cNumDoc+"' AND "
	cQuery+="E1_PREFIXO	= '"+_cSerie+"' AND "
	//cQuery+="E1_TIPO 	= '"+_cTipo+"' AND "
	cQuery+="E1_FILORIG	= '"+xFilial("SE1")+"' AND "
	//cQuery+="E1_NUMBOR	!= ' '	AND "
	cQuery+="E1_VENCTO	> '"+_dDataBord+"'	AND "
	cQuery+="D_E_L_E_T_	<> '*' "
	IF FunName()=="FINA740"
		cQuery+=" AND E1_PARCELA ='" +SE1->E1_PARCELA+"' "
	EndIf

	TcQuery ChangeQuery(cQuery) New Alias "TB01"
	TB01->(GetArea())
	if !EMPTY(alltrim(TB01->E1_NUMBOR))// != " "
		TB01->(DbCloseArea())
		U_RD06003(cFuncao,cTitulo)
		return
	else
		TB01->(DbCloseArea())
		
		dbSelectArea("SA6")
		dbSetOrder(1)
		If SA6->(dbSeek(xFilial("SA6")+_cChvSA6))
			_cBanco	:= SA6->A6_COD
			_cAgenc	:= SA6->A6_AGENCIA
			_cConta	:= SA6->A6_NUMCON
		Else
			xMagHelpFis("INFORMAÇÃO",;
			"Não foi encontrado no cadastro de banco o registro com a chave: " + _cChvSA6,;
			" O boleto não será gerado automaticamente.",;
			"Verifique no configurador o preenchimento do parâmetro CO_BOLETO.")
			Return
		EndIf
	
	
		If Select ("TSE1") <> 0
			TSE1->(dbCloseArea())
		EndIf
		
		cQuery:="SELECT R_E_C_N_O_, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_EMISSAO, E1_VALOR, E1_PARCELA FROM "+RetSqlName("SE1")+" "
		cQuery+="WHERE "
		cQuery+="E1_NUM 	= '"+_cNumDoc+"' AND "
		cQuery+="E1_PREFIXO	= '"+_cSerie+"' AND "
		//cQuery+="E1_TIPO 	= '"+_cTipo+"' AND "
		cQuery+="E1_FILORIG	= '"+xFilial("SE1")+"' AND "
		cQuery+="E1_VENCTO	> '"+_dDataBord+"'	AND "
		cQuery+="D_E_L_E_T_	<> '*' "
		IF FunName()=="FINA740"
			cQuery+=" AND E1_PARCELA ='" +SE1->E1_PARCELA+"' "
		EndIf
		cQuery+="ORDER BY E1_PARCELA"
	
		TcQuery ChangeQuery(cQuery) New Alias "TSE1"
	
		IF !EMPTY(_cBanco)
			_cNumBord	:= u_PrxBordero(_cChvSA6)
		ENDIF
	
		TSE1->(GetArea())
		
		Begin Transaction
	
		While !TSE1->(EOF())
		
			DBSELECTAREA("SE1")
			DBGOTO(TSE1->R_E_C_N_O_)
			RecLock("SE1",.F.)
			IF !EMPTY(_cBanco)
				SE1->E1_PORTADO	:= _cBanco
				SE1->E1_AGEDEP	:= _cAgenc
				SE1->E1_CONTA	:= _cConta
				SE1->E1_SITUACA	:= _nTipo
				SE1->E1_NUMBOR	:= _cNumBord
				SE1->E1_DATABOR	:= stod(_dDataBord)
			ENDIF
			MsUnLock()
	
			IF !EMPTY(_cBanco)
				dbSelectArea("SEA")
				dbSetOrder(1)   //EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA
				SEA->(dbGoTop())
				
				
				If SEA->(dbSeek(xFilial("SEA") + _cNumBord + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA))
					RecLock("SEA",.F.)
					SEA->EA_PORTADO	:= SE1->E1_PORTADO
					SEA->EA_AGEDEP	:= SE1->E1_AGEDEP
					SEA->EA_NUMBOR	:= _cNumBord
					SEA->EA_DATABOR	:= stod(_dDataBord)
					SEA->EA_TIPO	:= SE1->E1_TIPO
					SEA->EA_CART	:= "R"	//VERIFICAR
					SEA->EA_FORNECE	:= "" 	//VERIFICAR
					SEA->EA_LOJA	:= ""	//VERIFICAR
					SEA->EA_NUMCON	:= SE1->E1_CONTA
					SEA->EA_MODELO	:= ""	//VERIFICAR
					SEA->EA_TIPOPAG	:= ""	//VERIFICAR
					//SEA->EA_TRANSF	:= SE1->E1_TRANSF	//VERIFICAR
					SEA->EA_SITUACA	:= SE1->E1_SITUACA
					SEA->EA_SITUANT	:= "0" //VERIFICAR
					SEA->EA_SALDO	:= SE1->E1_SALDO
					SEA->EA_OCORR	:= SE1->E1_OCORREN
					SEA->EA_FILORIG	:= SE1->E1_FILORIG
					SEA->EA_PORTANT	:= ""	//VERIFICAR
					SEA->EA_AGEANT	:= ""	//VERIFICAR
					SEA->EA_CONTANT	:= ""	//VERIFICAR
					SEA->EA_DEBITO	:= SE1->E1_DEBITO
					SEA->EA_CCD		:= SE1->E1_CCD
					SEA->EA_ITEMD	:= SE1->E1_ITEMD
					SEA->EA_CLVLDB	:= SE1->E1_CLVLDB
					SEA->EA_CREDIT	:= SE1->E1_CREDIT
					SEA->EA_CCC		:= SE1->E1_CCC
					SEA->EA_ITEMC	:= SE1->E1_ITEMC
					SEA->EA_CLVLCR	:= SE1->E1_CLVLCR
					MsUnLock()
					
				Else
					RecLock("SEA",.T.)
					SEA->EA_FILIAL	:= XFILIAL("SEA")
					SEA->EA_PREFIXO	:= SE1->E1_PREFIXO
					SEA->EA_NUM		:= SE1->E1_NUM
					SEA->EA_PARCELA	:= SE1->E1_PARCELA
					SEA->EA_PORTADO	:= SE1->E1_PORTADO
					SEA->EA_AGEDEP	:= SE1->E1_AGEDEP
					SEA->EA_NUMBOR	:= _cNumBord
					SEA->EA_DATABOR	:= stod(_dDataBord)
					SEA->EA_TIPO	:= SE1->E1_TIPO
					SEA->EA_CART	:= "R"	//VERIFICAR
					SEA->EA_FORNECE	:= "" 	//VERIFICAR
					SEA->EA_LOJA	:= ""	//VERIFICAR
					SEA->EA_NUMCON	:= SE1->E1_CONTA
					SEA->EA_MODELO	:= ""	//VERIFICAR
					SEA->EA_TIPOPAG	:= ""	//VERIFICAR
					SEA->EA_TRANSF	:= SE1->E1_TRANSF	//VERIFICAR
					SEA->EA_SITUACA	:= SE1->E1_SITUACA
					SEA->EA_SITUANT	:= "0" //VERIFICAR
					SEA->EA_SALDO	:= SE1->E1_SALDO
					SEA->EA_OCORR	:= SE1->E1_OCORREN
					SEA->EA_FILORIG	:= SE1->E1_FILORIG
					SEA->EA_PORTANT	:= ""	//VERIFICAR
					SEA->EA_AGEANT	:= ""	//VERIFICAR
					SEA->EA_CONTANT	:= ""	//VERIFICAR
					SEA->EA_DEBITO	:= SE1->E1_DEBITO
					SEA->EA_CCD		:= SE1->E1_CCD
					SEA->EA_ITEMD	:= SE1->E1_ITEMD
					SEA->EA_CLVLDB	:= SE1->E1_CLVLDB
					SEA->EA_CREDIT	:= SE1->E1_CREDIT
					SEA->EA_CCC		:= SE1->E1_CCC
					SEA->EA_ITEMC	:= SE1->E1_ITEMC
					SEA->EA_CLVLCR	:= SE1->E1_CLVLCR
					MsUnLock()
					
				ENDIF

			endif

			TSE1->(dbSkip())
		ENDDO
		TSE1->(dbCloseArea())
		End Transaction
	
		if !EMPTY(_cBanco)
			U_RD06003(cFuncao,cTitulo)
		endif
	
	Endif

	restArea(_aAreaZ18)
	restArea(_aAreaSE1)
	restArea(_aAreaSC5)
	restArea(_aAreaSEA)
	restArea(_aAreaSAE)
	restArea(_aAreaSA6)
	restArea(_aArea)

return