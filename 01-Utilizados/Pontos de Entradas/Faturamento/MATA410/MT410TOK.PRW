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
#include 'parmtype.ch'
#include 'topconn.ch'
#include 'prtopdef.ch' 
/*/
===============================================================================================================================
Programa----------: MT410TOK
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 07/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para preencher campos adicionais ao validar pedido de venda
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: <programa>
===============================================================================================================================
/*/

user function MT410TOK()

	local	aArea		as object,;
			cAmbiente	as caractere

	local	lRet		as logical,;
			nOpc		as array,;
			cForm		as caractere

	lRet		:= .T.
	aArea		:= fwGetArea()
	cAmbiente	:= getmv('MV_XLOCAL')
	nOpc		:= paramixb[1]
	cForm		:= funname()

	if alltrim(str(nOpc)) $ '3|4|'
		if cAmbiente == '1'
			lRet:= VldGeral(nOpc,cForm)
		elseif cAmbiente == '2'
			lRet:= VldFiscal(nOpc,cForm)
		endif

	endif

	M->C5_XDESCON	:= posicione('SE4',1,fwxFilial('SE4')+M->C5_CONDPAG,'E4_DESCRI')
	fwRestArea(aArea)

return lRet

static function Comissao(cVend1)

	local	aArea		as array,;
			aAreaSA3	as array

	local	cVend2	as caracter,;
			nVend2	as numeric,;
			nProp1	as numeric

	local	lRet	as logical

	lRet:= .T.

	aArea	:= fwGetArea()
	aAreaSA3:= SA3->(fwGetArea())

	if empty(cVend1)
		u_msgErro('Campo vendedor não preenchido!','[MT410TOK]')
		lRet:= .F.
	else
		dbSelectArea('SA3')
		SA3->(dbSetOrder(1))
		SA3->(dbGoTop())
		if SA3->(dbSeek(fwxFilial('SA3')+cVend1))
			cVend2	:= SA3->A3_GEREN
			nVend2	:= SA3->A3_COMIS
			nProp1	:= SA3->A3_ALEMISS/100
		endif

		M->C5_VEND2		:= cVend2
		M->C5_COMIS2	:= nProp1*nVend2
	endif

	fwRestArea(aAreaSA3)
	fwRestArea(aArea)

return lRet

static function VldFiscal(nOpc,cForm)

	local	lRet		as logical,;
			fFerias		as caractere,;
			cVendedor	as caractere,;
			fVender		as caractere

	local	aItens		as array,;
			nX			as numeric,;
			cItem		as caractere,;
			cProduto	as caractere,;
			nQtdVen		as numeric,;
			cDescProd	as caractere,;
			cReserva	as caractere,;
			fVenda		as caractere,;
			nPesoB		as caractere,;
			nPesoL		as caracter

	aItens		:= {}
	lRet		:= .T.

	if empty(M->C5_VEND1)
		u_msgErro('Campo vendedor não preenchido!','[MT410TOK]')
		lRet:= .F.
		return lRet
	else

		dbSelectArea('SA3')
		SA3->(dbSetOrder(1))
		SA3->(dbGoTop())
		if SA3->(dbSeek(fwxFilial('SA3')+M->C5_VEND1))
			fFerias		:= SA3->A3_XFERIAS
			cVendedor	:= SA3->A3_NOME
			fVender		:= SA3->A3_XBLQVEN
		endif

		//validando se o vendedor esta de ferias
		if fFerias	== 'S'
			if !u_msgPergunta('Vendedor '+alltrim(cVendedor)+' encontra de FÉRIAS!!!...'+CRLF+;
								'Deseja continuar com a gravação?',cForm) = 6
				lRet	:= .F.
				return lRet
			endif
		endif

		if fVender	== 'S'
			if !u_msgPergunta('Vendedor '+alltrim(cVendedor)+' Bloqueado para Vendas!!!...'+CRLF+;
								'Deseja continuar com a gravação?',cForm) = 6
				lRet	:= .F.
				return lRet
			endif
		endif

		if lRet
			aItens:= {}
			nPesoB:= 0
			nPesoL:= 0
			for nX := 1 to Len(aCols)
				if aCols[nX][Len(aHeader)+1] == .F.
					cItem		:= ''
					cProduto	:= ''
					nQtdVen		:= 0
					cDescProd	:= ''
					cReserva	:= ''
					fVenda		:= ''

					cItem		:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_ITEM' })]
					cProduto	:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_PRODUTO' })]
					nQtdVen		:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_QTDVEN' })]
					cDescProd	:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_DESCRI' })]
					cReserva	:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_CONTRAT' })]
					fVenda		:= posicione('SB1',1,xfilial('SB1')+cProduto,'B1_XVENDA')
					nPesoB		+= nQtdVen*posicione('SB1',1,fwXFilial('SB1')+cProduto,'B1_PESBRU')
					nPesoL		+= nQtdVen*posicione('SB1',1,fwXFilial('SB1')+cProduto,'B1_PESO')

					if cReserva == '' .and. !fVenda $ '5|A'
						u_msgErro('Produto Bloqueado para Venda! '+ CRLF +;
								alltrim(cValToChar(cItem))+' - '+alltrim(cValToChar(cProduto))+' - '+alltrim(cDescProd),cForm)
						lRet:= .F.
						return lRet
					endif
					
				endif
			next
			M->C5_PESOL		:= nPesoL
			M->C5_PBRUTO	:= nPesoB
		endif
	endif

return lRet


static function VldGeral(nOpc,cForm)

	local	lRet		as logical,;
			nX			as numeric,;
			lControl	as logical
	
	local	aItens		as array,;
			cNumPed		as caractere,;
			cItem		as caractere,;
			cProduto	as caractere,;
			cDescProd	as caractere,;
			nQtdVen		as numeric,;
			nPrcUnit	as numeric,;
			nPrcVen		as numeric,;
			cReserva	as caractere,;
			fVenda		as caractere,;
			cVendedor	as caractere,;
			fVender		as caractere,;
			nDescItem	as numeric,;
			nDescAut	as numeric,;
			nPrcTab		as numeric,;
			cTabPrc		as caractere,;
			cTPCond		as caractere,;
			cCondPgto	as caractere,;
			cDescCPagto	as caractere,;
			cCliente	as caractere,;
			cLoja		as caractere,;
			cLjVend		as caractere,;
			cRegVen		as caractere,;
			dDtValid	as date,;
			dDtValMax	as date,;
			cGrpVenda	as caractere,;
			cApCondPgto	as caractere,;
			cNumOrc		as caractere,;
			nPesoB		as numeric,;
			nPesoL		as numeric,;
			nDescont	as numeric,;
			cRegCli		as caractere,;
			cTes		as caractere,;
			cFlDup		as caractere,;
			cNumPedCob	as caractere

	nX			:= 0
	aItens		:= {}
	lControl	:= .F.
	cNumPed		:= M->C5_NUM
	cItem		:= ''
	cProduto	:= ''
	nQtdVen		:= 0
	nPrcUnit	:= 0
	nPrcVen		:= 0
	cReserva	:= ''
	fVenda		:= ''
	cVendedor	:= ''
	fVender		:= ''
	nPrcTab		:= 0
	cTabPrc		:= M->C5_TABELA
	cCondPgto	:= M->C5_CONDPAG
	cCliente	:= M->C5_CLIENTE
	cLoja		:= M->C5_LOJACLI
	cLjVend		:= '8'+strZero(val(M->C5_VEND1),3)
	dDtValid	:= M->C5_XDTVAL
	dDtValMax	:= daysum(date(),getMV('MV_XVALORC'))
	cApCondPgto	:= M->C5_XAPCPAG
	cNumOrc		:= M->C5_XNUMORC
	cRegCli		:= posicione('SA1',1,fwxFilial('SA1')+cCliente+cLoja,'A1_REGIAO')

	//é do grupo de administradores, fiscal/contabil ou supervisor de estoque?
	if u_EstaGrp(RetCodUsr(),'000000') .or. u_EstaGrp(RetCodUsr(),'000007') .or. u_EstaGrp(RetCodUsr(),'000014')
		lControl:= .T.
	endif

	if empty(M->C5_VEND1)
		u_msgErro('Campo vendedor não preenchido!','[MT410TOK]')
		lRet:= .F.
		return lRet

	else
		lRet	:= .T.

		//buscando dados do vendedor
		dbSelectArea('SA3')
		SA3->(dbSetOrder(1))
		SA3->(dbGoTop())
		if SA3->(dbSeek(fwxFilial('SA3')+M->C5_VEND1))
			cVendedor	:= SA3->A3_NOME
			fVender		:= SA3->A3_XBLQVEN
			cRegVen		:= SA3->A3_REGIAO
		endif
		nDescAut	:= posicione('ZZ1',1,xFilial('ZZ1')+__CUSERID,'ZZ1_DESCON')
		cTPCond		:= posicione('SE4',1,xFilial('SE4')+cCondPgto,'E4_XAVISTA')
		cDescCPagto	:= posicione('SE4',1,xFilial('SE4')+cCondPgto,'E4_DESCRI')
		nDescont	:= M->C5_DESCONT

		//validando se o vendedor esta bloqueado para vendas
		if lRet .and. fVender	== 'S'
			u_msgErro('Vendedor '+alltrim(cVendedor)+' Bloqueado para Vendas!!!...',cForm)
			lRet	:= .F.
			return lRet
		endif

		//validando a regiao do cliente x vendedores
		if cRegCli != '00' .and. cRegVen != '00' //cliente e vendedores sao de regioes diferente de genericos
			if cRegVen != cRegCli
				u_msgErro('Venda irregular!'+CRLF+'Cliente de outras praças!',cForm)
				lRet	:= .F.
			endif
		endif

		//validando se o vendedor foi alterado
		if lRet .and. alltrim(str(nOpc)) == '4' .and. !Empty(M->C5_TIPO) .and. !Empty(M->C5_VEND1) .and. !Empty(SC5->C5_NOTA) .and. M->C5_TIPO = 'N' .and. M->C5_VEND1 != SC5->C5_VEND1
			u_msgErro('Esse pedido já foi faturado e deve ser cancelado antes de alterar o vendedor',cForm)
			lRet	:= .F.
			return lRet
		endif
			
		//VALIDANDO SE O CLIENTE É CONSUMIDOR A VISTA
		if cCliente $ '99999999|99999998' .and. !cTPCond == 'A'
			u_msgErro('Venda não PERMITIDA para CLIENTE CONSUMIDOR a PRAZO',cForm)
			lRet:= .F.
			return lRet
		endif

		if (cCliente == '99999998' .and. cLoja != cLjVend )
			u_msgErro('Venda não PERMITIDA para OUTROS CONSUMIDORES!...',cForm)
			lRet	:= .F.
			return lRet
		endif

		if cRegVen = '01' .and. cTabPrc <> '001' //araxa 
			u_msgErro('Venda não PERMITIDA!!!...'+CRLF;
						+'Tabela inconsistente.',cForm)
			lRet	:= .F.
			return lRet
		endif

		//orcamento vencimento
		if dDtValid < DDATABASE .or. dDtValid > dDtValMax
			u_msgErro('Data Validade expirado ou inválido! '+dtoc(dDtValid)+CRLF+;
					  'Revisar a data da validade.',cForm)
			lRet	:= .F.
			return lRet
		endif

		if cCondPgto == 'SPG' .and. !lControl
			u_msgErro('Condicao de Pagamento Invalido!!!'+CRLF+;
						'Favor Corrigir!',cForm)
			lRet	:= .F.
			return lRet
		endif

		if nDescont	> 1
			u_msgErro('Desconto (idenização) acima do permitido!',cForm)
			lRet	:= .F.
		endif

		//Tratando a Duplicidade de CODIGO DE PRODUTOS com preco divergentes
		if lRet

			aItems	:= {}
			nPesoB	:= 0
			nPesoL	:= 0
			nMaxDesc:= 0
			for nX := 1 to Len(aCols)
				if aCols[nX][Len(aHeader)+1] == .F.
					cItem		:= ''
					cProduto	:= ''
					cDescProd	:= ''
					nQtdVen		:= 0
					nPrcVen		:= 0
					cReserva	:= ''
					fVenda		:= ''
					nPrcTab		:= 0
					cTes		:= ''
					cFlDup		:= ''
					cNumPedCob	:= ''

					cItem		:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_ITEM' })]
					cProduto	:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_PRODUTO' })]
					cDescProd	:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_DESCRI' })]
					nQtdVen		:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_QTDVEN' })]
					nPrcUnit	:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_PRUNIT' })]
					nPrcVen		:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_PRCVEN' })]
					cReserva	:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(x[2]) == 'C6_CONTRAT' })]
					nDescItem	:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(X[2]) == 'C6_DESCONT' })]
					cTes		:= aCols[nX,ASCAN(aHeader,{|x| ALLTRIM(X[2]) == 'C6_TES' })]

					cFlDup		:= posicione('SF4',1,fwXFilial('SF4')+cTes,'F4_DUPLIC')
					cNumPedCob	:= posicione('ADB',1,fwXFilial('ADB')+cReserva,'ADB_PEDCOB')
					fVenda		:= posicione('SB1',1,fwXFilial('SB1')+cProduto,'B1_XVENDA')
					cGrpVenda	:= posicione('SB1',1,fwXFilial('SB1')+cProduto,'B1_GRUPO')
					nPrcTab		:= posicione('DA1',2,fwXFilial('DA1')+cProduto+cTabPrc,'DA1_PRCVEN')
					nPesoB		+= nQtdVen*posicione('SB1',1,fwXFilial('SB1')+cProduto,'B1_PESBRU')
					nPesoL		+= nQtdVen*posicione('SB1',1,fwXFilial('SB1')+cProduto,'B1_PESO')

					if nMaxDesc < nDescItem
						nMaxDesc:= nDescItem
					endif

					if !empty(cReserva) .and. cNumPed != cNumPedCob .and. cFlDup == 'S'
						u_msgErro('Tes INVÁLIDO para venda por contrato pois gera duplicatas. '+CRLF+;
									'Item: '+cValToChar(cItem)+' - '+cProduto+' - '+cDescProd+CRLF,cForm)
						lRet	:= .F.
						return lRet

					endif

					if !empty(cProduto) .and. empty(cReserva)
					
						if nPrcUnit	!= nPrcTab
							u_msgErro('Preço base divergente com a tabela!!!...'+CRLF;
										+'Item: '+cValToChar(cItem)+ ' - ' +cProduto+CRLF;
										+'Preço Base: '+cValToChar(nPrcTab)+CRLF;
										+'Tabela: '+cTabPrc+' - '+cValToChar(nPrcUnit)+CRLF;
										+'Solução: Reincluir o produto novamente.',cForm)
							lRet	:= .F.
							return lRet
						endif

						if !VldItem(aItens, cProduto, nPrcVen)
							aadd(aItens,{cProduto,nPrcVen})
						else
							if u_msgPergunta('Produto DUPLICADOS com preços DIVERGENTES! '+CRLF+;
											CValToChar(cItem)+' Produto: '+cValToChar(cProduto)+' Valor R$: '+transform(nPrcVen,'@E 999,999,999.99') + '.'+CRLF+;
											'Deseja continuar?',cForm) != 6
								lRet:= .F.
								return lRet
							endif
						endif
						
						if !fVenda $'6|A' 
							u_msgErro('Produto Bloqueado para Venda! '+ CRLF +;
										alltrim(cValToChar(cItem))+' - '+alltrim(cValToChar(cProduto))+' - '+alltrim(cDescProd),cForm)
							lRet:= .F.
							return lRet
						endif

						//VALIDANDO DESCONTOS CONCEDIDOS
						if nDescItem > nDescAut .and. empty(cNumOrc)
							u_msgErro('Desconto acima do permitido...'+CRLF+;
										'Item: '+cValToChar(cItem)+' - '+cProduto+' - '+cDescProd+CRLF+;
										'Desc.: '+cValToChar(nDescItem)+' %',cForm)
							lRet:= .F.
							return lRet
						endif

						//VALIDANDO CONDICAO DE PAGAMENTO
						dbSelectArea('Z00')
						Z00->(dbSetOrder(1))
						Z00->(dbGoTop())
						if !Z00->(dbSeek(xFilial('Z00')+cCondPgto+cGrpVenda))
							if cApCondPgto != 'S'.and. !RetCodUsr()$"000000|000006|000030"
								u_msgErro('Cond.Pagto inválido para o Grupo de Produtos!'+CRLF;
										+'Cond. Pagto: '+alltrim(cCondPgto)+' - '+alltrim(cDescCPagto)+CRLF;
										+'Produto: '+alltrim(cProduto)+' - '+alltrim(cDescProd)+CRLF;
										+'Corrigir condição de pagamento no orçamento.',cForm)
								lRet	:= .F.
								return lRet
							endif
						endif
					endif
				endif
			next

			M->C5_PESOL		:= nPesoL
			M->C5_PBRUTO	:= nPesoB

		endif
		
	endif

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
