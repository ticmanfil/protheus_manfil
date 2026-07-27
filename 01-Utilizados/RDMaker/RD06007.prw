#include 'protheus.ch'
#include 'rwmake.ch' 
#include 'topconn.ch'
#include 'TbiCode.ch'
#include 'report.ch'
/*/
===============================================================================================================================
Programa----------: RD06007
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/03/2019
===============================================================================================================================
DescriÃ§Ã£o---------: Este programa serve para gerar os BOLETOS gerados pela MV05002
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
user function RD06007(cFuncao, aTitulo)

	local	nX			:= 0,;
			cQry		:= '',;
			cTitulo		:= ''
			
	//Variaveis do Bancor receptor
	local	_cBanco		:= '',;
			_cAgenc		:= '',;
			_cConta		:= '',;	
			cChvSA6		:= alltrim(getMV('CO_BOLETO')),; //Retorna banco+agencia+conta para geraÃ§Ã£o de boleto
			_cNumBord	:= '',;
			_dDataBord	:= dtos(DDATABASE),;
			_TpOper		:= 'I'

	private	cSeqInt		:= ''
	
	//01.00 - Buscandos Dados do Banco ser Gerado o Bordero
	dbSelectArea('SA6')
	SA6->(dbSetOrder(1))
	SA6->(dbGoTop())
	if SA6->(dbSeek(xFilial('SA6')+cChvSA6))
		_cBanco	:= SA6->A6_COD
		_cAgenc	:= SA6->A6_AGENCIA
		_cConta	:= SA6->A6_NUMCON
	else
		apMsgInfo("INFORMAÇÃO",;
					"Não foi encontrado no cadastro de banco o registro com a chave: " + cChvSA6,;
					" O boleto não serÃ¡ gerado automaticamente.",;
					"Verifique no configurador o preenchimento do parÃ¢metro CO_BOLETO.")
		return
	endif
		
	//02.00 - Gerando Bordero
	//02.01 - selectionando os titulos a serem gerados o bordero		
	for nX:= 1 to len(aTitulo)
		cTitulo	+= aTitulo[nX][1] + aTitulo[nX][2] + aTitulo[nX][3] + aTitulo[nX][4] + aTitulo[nX][5] + aTitulo[nX][9] + '|'
	next nX

	if select('TMPTIT')
		TMPTIT->(dbCloseArea())
	endif
	
	cQry	:= 'exec dbo.PR_RD06007 @TITULOS = ' +chr(39)+ cTitulo+chr(39)
	
	//dbUseArea(.T.,'TOPCONN',cQry,'TMPTIT',.F.,.T.)
	tcQuery cQry new alias 'TMPTIT'
	
	//02.02 - Gerando Bordero		
	TMPTIT->(GetArea())
	
	begin transaction
	
		while !TMPTIT->(eof())
		
			_cNumBord	:= u_PrxBordero()
		
			//2.02.01 - Gravando no SE1
			dbSelectArea('SE1')
			dbGoTo(TMPTIT->R_E_C_N_O_)
			RecLock('SE1',.F.)
				SE1->E1_PORTADO	:= _cBanco
				SE1->E1_AGEDEP	:= _cAgenc
				SE1->E1_CONTA	:= _cConta
				SE1->E1_SITUACA	:= '1'
				SE1->E1_NUMBOR	:= _cNumBord
				SE1->E1_DATABOR	:= stod(_dDataBord)
			SE1->(MsUnLock())
	
			//2.02.02 - Gravando na SEA
			dbSelectArea('SEA')
			SEA->(dbSetOrder(1))   //EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA
			SEA->(dbGoTop())
			if SEA->(dbSeek(xFilial('SEA') + _cNumBord + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA))
				if SEA->EA_TRANSF == 'S'
					_TpOper:= 'I'
				else
					_TpOper:= 'A'
				end

			else
				_TpOper:= 'I'

			endif

			if _TpOper == 'A'
				RecLock('SEA',.F.)
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
					SEA->EA_SALDO	:= 0.00 //SE1->E1_SALDO
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
					//REGRA PARA BOLETA ONLINE
					SEA->EA_ESPECIE	:= '01'
					SEA->EA_SUBCTA	:= '001'
					SEA->EA_BORAPI	:= 'S'
				SEA->(MsUnLock())
			else
				RecLock('SEA',.T.)
				SEA->EA_FILIAL	:= XFILIAL('SEA')
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
				SEA->EA_SALDO	:= 0	//SE1->E1_SALDO
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
				//REGRA PARA BOLETA ONLINE
				SEA->EA_ESPECIE	:= '01'
				SEA->EA_SUBCTA	:= '001'
				SEA->EA_BORAPI	:= 'S'
				SEA->(MsUnLock())
			endif

			TMPTIT->(dbSkip())
			
		enddo 
	
	end transaction
	TMPTIT->(dbCloseArea())

	//03.00 - imprimir boleto
	//cNomePDF:=u_RD06003(cFuncao,cTitulo,plViewPDF,pLocal)

	u_msgInforma('Boleto gerado com sucesso!!!!')
	
return

