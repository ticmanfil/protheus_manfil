#include 'protheus.ch'
#include 'topconn.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: A415TDOK
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para Validacao do preco de produto de acordo com o desconto permitido
===============================================================================================================================
Uso---------------: orcamento de pedidos de venda (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: <programa>
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor		|	Data	|										Motivo																
----------------:-----------:-----------------------------------------------------------------------------------------------------------:
RENATO FUZESSY	|28/07/2028 | 																										
----------------:-----------:-----------------------------------------------------------------------------------------------------------:
				|			|																											
=====================================================================================================================================
/*/
user function A415TDOK()
	
	//parametros de controle
	Local 	_lRet 		:= .T.,;
			cAmbiente	:= Alltrim(GetMv("MV_XLOCAL")),;
			_cUsuario 	:= M->__CUSERID

	//parametros de filtro
	Local 	_aArea		:= GetArea(),;
			_aSB1		:= SB1->(getArea()),;
			_aSE4		:= SE4->(getArea())

	//variaveis diversas
	Local 	_nDesc		:= 0,;
			_nPreco		:= 0,;
			_qtditem	:= 0,;
			_cTabPreco	:= M->CJ_TABELA,;
			_cCliente	:= M->CJ_CLIENTE,;
			_cCondPag	:= M->CJ_CONDPAG,;
			aItens		:= {},;
			cTPCond		:= ''

	DbSelectArea("ZZ1")
	DbSetorder(1)
	if DbSeek(xFilial("ZZ1")+_cUsuario)
		_nDesc	:= ZZ1->ZZ1_DESCON
	
	else
		_nDesc	:= 0

	endif
	ZZ1->(DbCloseArea())

	//Alert(xFilial("SCK")+"-"+cValToChar(SCJ->CJ_NUM)+"-"+cValToChar(SCJ->CJ_CLIENTE)+"-"+cValToChar(SCJ->CJ_LOJA)+" Lim.Desc.: "+cValToChar(_nDesc))

	//VALIDANDO O PRECO ATUAL COM A TABELA DE PRECO
	_qtditem	:= 0
	DbSelectArea("TMP1")
	TMP1->(DbGoTop())
	while TMP1->(!Eof())
		//BUSCANDO O PRECO ATUAL DO PRODUTO
		dbSelectArea("DA1")
		DA1->(dbSetorder(2))
		If dbSeek(xFilial("DA1")+TMP1->CK_PRODUTO+_cTabPreco)
			_nPreco	:= DA1->DA1_PRCVEN
		
		Else
			_nPreco	:= 0

		EndIf
		//DA1->(DbCloseArea())
		                        		
		If TMP1->CK_PRUNIT != _nPreco .and. !RetCodUsr()$"000000"
			_lRet:= .F.
			Alert("Preco base divergente com a tabela!!!... "+ Chr(13) + Chr(10) +"Item: "+cValToChar(TMP1->CK_ITEM)+ " - " +TMP1->CK_DESCRI+ Chr(13) + Chr(10) +" Preco Base: "+cValToChar(_nPreco)+" Tabela: "+cValToChar(TMP1->CK_PRUNIT) + Chr(13) + Chr(10) +" Solucao: Reincluir o produto novamente." )
			return
		EndIf
		
		if !TMP1->CK_FLAG
			_qtditem ++
		endif
		
		//Tratando a Duplicidade de CODIGO DE PRODUTOS com preco divergentes
		if !TMP1->CK_FLAG
			if !VldItem(aItens, TMP1->CK_PRODUTO,TMP1->CK_PRCVEN)
				aadd(aItens,{TMP1->CK_PRODUTO,TMP1->CK_PRCVEN})
			else
				u_msgErro('Produto DUPLICADOS com preços DIVERGENTES! Item: '+cValToChar(TMP1->CK_ITEM)+' Produto: '+cValToChar(TMP1->CK_PRODUTO)+' Valor R$: '+transform(TMP1->CK_PRCVEN,'@E 999,999,999.99'),'[M415TDOK] - Validação Orçamento')
				_lRet:= .F.
				return
			endif
		endif

		dbSelectArea('SB1')
		SB1->(dbSetOrder(1))
		SB1->(dbGoTop())
		if (SB1->(dbSeek(xFilial('SB1')+TMP1->CK_PRODUTO)))
			if (cAmbiente == '1' .and. !SB1->B1_XVENDA $'6|A') // SE AMBIENTE FOR GERENCIA E VENDA DIFERENTE 6-VENDAS 6 e A-AMBAS BLOQUEAR
				u_msgErro('Produto Bloqueado para Venda! '+ Chr(13) + Chr(10) +alltrim(cValToChar(TMP1->CK_ITEM))+' - '+alltrim(cValToChar(TMP1->CK_PRODUTO))+' - '+alltrim(TMP1->CK_DESCRI),'[M415TDOK] - Validando Bloqueio de Produto')
				_lRet:= .F.
				return
			endif
		endif

		TMP1->(dbSkip())
	enddo
	
	//TRATANDO A QUANTIDADE DE ITENS
	if _qtditem	> 23
		u_msgErro('Quantidade de ITENS superior a 23 itens! '+ Chr(13) + Chr(10) +'! Favor excluir os itens excedentes e fazer um novo orçamento.','[M415TDOK] - ')
		_lRet:= .F.
		return
	endif
		
	//VALIDANDO OS DESCONTOS CONCEDIDOS
	dbSelectArea('TMP1')
	TMP1->(DbGoTop())
	while TMP1->(!Eof())
		if TMP1->CK_DESCONT > _nDesc
			_lRet:= .F.
			Alert("Desconto acima do permitido!!!... Item: "+cValToChar(TMP1->CK_ITEM)+" Desc.: "+cValToChar(TMP1->CK_DESCONT)+"%")
		endif
		TMP1->(dbSkip())
	enddo

	//VALIDANDO SE É O CONSUMIDOR NAO IDENTIFICADO
	dbSelectArea('SE4')
	SE4->(dbSetOrder(1))
	SE4->(dbGoTop())
	if (SE4->(dbSeek(xFilial('SE4')+_cCondPag)))
		cTPCond	:= SE4->E4_XAVISTA
	endif
	SE4->(dbCloseArea())

    if _cCliente $ '99999999|99999998' .and. !cTPCond == 'A'
    	u_msgErro('Venda não PERMITIDA para CLIENTE CONSUMIDOR a PRAZO!...')
		_lRet	:= .F.
    endif

	restArea(_aSE4)
	restArea(_aSB1)
	restArea(_aArea)

return _lRet


static function AltCli(cCodCli, cLoja)
	local	cQry	:= '',;
			lRet	:= .F.

    cQry	:= "select SCJ.CJ_CLIENTE, SCJ.CJ_LOJA	"
	cQry	+= "from "+RetSQLName('SCJ')+" as SCJ	"
	cQry	+= "where SCJ.D_E_L_E_T_ = ''			"
	cQry	+= "and SCJ.CJ_FILIAL = '"+FWxFilial('SCJ')+"' and SCJ.CJ_CLIENTE = '"+cCodCli+"' and SCJ.CJ_LOJA = '"+cLoja+"'	"

    cQry	:= ChangeQuery(cQry)
    TCQuery cQry New Alias "QRY"
         
    QRY->(dbGoTop())
    if QRY->CJ_CLIENTE != cCodCli .or. QRY->CJ_LOJA != cLoja
    	lRet	:= .T.
    endif
    
    QRY->(DbCloseArea())

return lRet

static function AltValor(cNumOrc,nValor)
	local	cQry	:= '',;
			lRet	:= .F.

    cQry	:= "select SCK.CK_VALOR	"
	cQry	+= "from "+RetSQLName('SCK')+" as SCK	"
	cQry	+= "where SCK.D_E_L_E_T_ = ''			"
	cQry	+= "and SCK.CK_FILIAL = '"+FWxFilial('SCK')+"' and SCK.CK_NUM = '"+cNumOrc+"'	"

    cQry	:= ChangeQuery(cQry)
    TCQuery cQry New Alias "QRY"
         
    QRY->(dbGoTop())
    if QRY->CK_VALOR != nValor
    	lRet	:= .T.
    endif
    
    QRY->(DbCloseArea())

return lRet

static function VldItem(aItens, cPrd, nVlUnit)
	local	lRet	:= .F.,;
			nPos	:= 0,;
			nVal	:= 0
	
	nPos	:= ascan(aItens, {|x| alltrim(upper(x[1])) == alltrim(upper(cPrd))})
	if nPos = 0
		lRet	:= .F.
	else
		nVal	:= aItens[nPos][2]
		if nVal	= nVlUnit
			lRet	:= .F.
		else
			lRet	:= .T.
		endif
	endif
	
return lRet


static function MEstoq(cTes)

	local 	lRet		:= .F.

	local 	aArea		:= getArea(),;
			aAreaSF4	:= SF4->(getArea())

	dbSelectArea('SF4')
	SF4->(dbSetOrder(1))
	SF4->(dbGoTop())
	if (SF4->(dbSeek(xFilial('SF4')+cTes)))
		if SF4->F4_ESTOQUE = 'S'
			lRet	:= .T.
		endif
	endif
	SF4->(dbCloseArea())

	restArea(aAreaSF4)
	restArea(aArea)

return lRet
