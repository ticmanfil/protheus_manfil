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

#include 'totvs.ch'
#include 'restful.ch'
#include 'topconn.ch'

/*/
===============================================================================================================================
Programa----------: CARDVENDAS
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 13/03/2026
===============================================================================================================================
Descrição---------: Este programa server para criar um card de vendas para o dashboard customizados a ser usado pelos
					vendedores
===============================================================================================================================
Uso---------------: FIN900
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Gernericos
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: BACKOFFICE
===============================================================================================================================
/*/
wsrestful CardsVendas description 'Cards de Vendas'
	wsdata 	Fields		as string   optional
	wsdata 	Order		as string   optional
	wsdata 	Page		as integer  optional
	wsdata 	PageSize	as integer  optional

	wsmethod POST itemsDetails;
		description 'Carrega os Itens Utilizados para Montagem do Painel';
		wssyntax '/cards/itemsDetails/{Order, Page, PageSize, Fields}';
		path '/cards/itemsDetails';
		produces application_json

	wsmethod GET cardFilter;
		description 'Disponibiliza os campos que poderão ser utilizados no filtro do Card';
		wssyntax '/cards/cardFilter/';
		path '/cards/cardFilter';
		produces application_json
	
	wsmethod GET cardInfo;
		description 'Carrega as informações do Painel';
		wssyntax '/cards/cardInfo/';
		path '/cards/cardInfo';
		produces application_json

	wsmethod GET fieldsInfo;
		description 'Carrega os campos que podem que ser utilizados';
		wssyntax '/cards/fieldsInfo/';
		path '/cards/fieldsInfo';
		produces application_json

endwsrestful

///===============================================================================================================================
//							METODO RESPONSAVEL POR CARREGAR OS ITENS PARA MONTAGEM DO PAINEL
///===============================================================================================================================
wsmethod POST itemsDetails;
	wsreceive orders, page, pageSize, fields;
	wsservice CardsVendas

	local 	lRet as logical

	Local	aHeaders 	as array,;
			aRet 		as array,;
			cError		as character

	Local	oCoreDash	as object,;
			aFilters	as array,;
			nQtdFilters	as integer,;
			cFilter		as character,;
			nX			as integer,;
			cBody		as character,;
			oBody		as object,;
			oJDetails	as object,;
			cCampos		as character

	//variaveis de retorno
	lRet	:= .T.

	//Iniciando as variaveis
	oCoreDash	:= CoreDashboard():New()
	aHeaders	:= {}
	aRet		:= {}
	cError		:= 'Erro de Requisição'
	aFilters	:= {}
	nQtdFilters	:= 0
	cFilter		:= ''
	nX			:= 0
	cBody		:= DecodeUtf8(self:GetContent())
	oBody		:= JsonObject():New()
	oJDetails	:= JsonObject():New()
	cCampos		:= ''

	self:SetContentType('application/json')

	if !Empty(cBody)
		oBody:formJson(cBody)
		if valType(oBody['detailFilter']) == 'A'
			oJDetails	:= oBody['detailFilter']
		endif
	endif

	if len(oJDetails) = 0
		aHeaders 	:= RetHeaders('SA1')
		oCoreDash:setFields(dePara('SA1'))
		oCoreDash:setApiQstring(self:aQueryString())
		aFilters	:= oCoreDash:GetApiFilters()
		nQtdFilters	:= len(aFilters)
		if nQtdFilters > 0
			for nX = 1 to nQtdFilters
				cFilter += ' AND ' + aFilters[nX][1]
			next
		endif
		
		//chama a função responsável por montar a expressão SQL
		aRet	:= MntQuery(,cFilter + " AND (SA1.A1_RISCO = 'A' OR SA1.A1_RISCO = 'B' OR SA1.A1_RISCO = 'C')",,"SA1")
	
	elseif len(oJDetails) = 1
		aHeaders	:= retHeader('SC5')
		oCoreDash:setFields(dePara('SC5'))
		oCoreDash:setApiQstring(self:aQueryString())
		aFilters	:= oCoreDash:GetApiFilters()
		nQtdFilters	:= len(aFilters)
		if nQtdFilters > 0
			for nX = 1 to nQtdFilters
				cFilter += ' AND ' + aFilters[nX][1]
			next
		endif

		cFilter	:= " AND SC5.C5_CLIENTE = '" + oJDetails[1]['code'] + "'"
		cCampos	:= 'SC5.C5_NUM, SC5.C5_TIPO, SC5.C5_CONDPAG, SC5.C5_EMISSAO'
		aRet	:=  MntQuery(cCampos,cFilter,,'SC5')

	endif

	//Define a Query padrão utilizada no servico
	oCoreDash:SetQuery(aRet[1])
	oCoreDash:setWhere(aRet[2])
	if len(aRet) >= 3
		oCoreDash:setGroupBy(aRet[3])
	endif

	oCoreDash:BuildJson()
	lRet	:= valType(oCoreDash:getJsonObject()['items']) == 'A'

	if lRet
		oCoreDash:setPOHeaders(aHeaders)
		self:setResponse(oCoreDash:ToObjectJson())
	else
		setRestFault(500, encodeUtf8(cError))
	endif

	oCoreDash:Destroy()

	aSize(aRet,0)
	aSize(aHeaders,0)

return lRet

//===============================================================================================================================
//							FUNÇÃO RESPONSAVEL POR MONTAR A QUERY DE ACORDO COM O TIPO DE DADO SOLICITADO
//===============================================================================================================================
static function MntQuery(cCampos, cFilter, cGroupBy, cTabela)
	Local 	cQry	as character,;
			cWhere	as character,;
			cGroup	as character
	
	default cTabela	:= 'SA1',;
			cCampos	:= 'SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_NREDUZ, SA1.A1_RISCO'

	if cTabela == 'SA1'
        cQuery := " SELECT " + cCampos + " FROM " + RetSqlName("SA1") + " SA1 "
        cWhere := " SA1.R_E_C_N_O_ <= 1000 AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'" + cFiltro
        cWhere += " AND SA1.D_E_L_E_T_ = ' ' "
    
	elseif cTabela == "SC5"
        cQuery := " SELECT " + cCampos + " FROM " + RetSqlName("SC5") + " SC5 "
        cWhere := " SC5.C5_FILIAL = '" + xFilial("SC5") + "'" + cFiltro
        cWhere += " AND SC5.D_E_L_E_T_ = ' ' "

	endif

return (cQry, cWhere, cGroup)

//===============================================================================================================================
//							FUNÇÃO RESPONSAVEL POR RETORNAR OS CAMPOS DE ACORDO COM A TABELA SOLICITADA
//===============================================================================================================================
static function dePara(cTabela)
	local	aCampos	as array

	default cTabela := 'SA1'

	if cTabela == 'SA1'
		aCampos := {;
					{'code', 'A1_COD'},;
					{'store', 'A1_LOJA'},;
					{'name', 'A1_NOME'},;
					{'nred', 'A1_NREDUZ'},;
					{'risk', 'A1_RISCO'};
					}
	
	elseif cTabela == 'SC5'
		aCampos := {;
					{'num', 'C5_NUM'},;
					{'type', 'C5_TIPO'},;
					{'cond', 'C5_CONDPAG'},;
					{'emission', 'C5_EMISSAO'};
					}
	
	endif
return aCampos

//===============================================================================================================================
//					METODO RESPONSAVEL POR CARREGAR OS DADOS QUE PODEM SER UTILIZADOS PELO CARD
//===============================================================================================================================
wsmethod get CardInfo;
	wsRestFul CardsVendas

	local	aFilters	as array,;
			cWhere		as character,;
			nFiltros	as integer,;
			oCoreDash	as object,;
			oResponse	as object

	oCoreDash	:= CoreDashboard():New()
	oResponse	:= JsonObject():New()
	aFilters	:= {}
	cWhere		:= ''
	nFiltros	:= 0

	oCoreDash:setFields(dePara())
	oCoreDash:setApiQstring(self:aQueryString())
	aFilters	:= oCoreDash:GetApiFilters()

	for nFiltros  = 1 to len(aFilters)
		cWhere += ' AND ' + aFilters[nFiltros][1]
	next

	retCardInfo(@oResponse, cWhere)
	self:setResponse(encodeUtf8(FwJsonSerializer(oResponse,.T.,.T.)))

	oResponse:= nil
	FreeObj(oResponse)
	
	oCoreDash:Destroy()
	FreeObj(oCoreDash)

return .T.

//===============================================================================================================================
//					FUNÇÃO RESPONSAVEL POR RETORNAR AS INFORMAÇÕES DO CARD DE ACORDO COM O FILTRO SOLICITADO
//===============================================================================================================================
static function retCardInfo(oResponse, cApiFilter)

	local	oItems	as object,;
			aItems	as array

	default cApiFilter := ''

	oItems:= JsonObject():New()

	oItems['risco_a']	:= retRisco(" AND SA1.A1_RISCO = 'A' " + cApiFilter)
	oItems['risco_b']	:= retRisco(" AND SA1.A1_RISCO = 'B' " + cApiFilter)
	oItems['risco_c']	:= retRisco(" AND SA1.A1_RISCO = 'C' " + cApiFilter)
	aadd(aItems, oItems)

	oResponse['hasNext']	:= 'false'
	oResponse['items']		:= aItems

return nil

//===============================================================================================================================
//					FUNÇÃO RESPONSAVEL POR RETORNAR A QUANTIDADE DE REGISTROS DE ACORDO COM O RISCO E FILTRO SOLICITADO
//===============================================================================================================================
static function retRisco(cFiltro)
	local	aQry	as array,;
			cQry	as character,;
			cTemp	as character,;
			nRet	as integer

	aQry	:= MntQuery('COUNT(*) AS TOTAL_REGISTRO', cFiltro,,'SA1')
	cTemp	:= getNextAlias()

	cQry	:= aQry[1] + ' WHERE ' + aQry[2] 
	
	tcQuery cQry new alias cTemp

	nRet	:= (cTemp)->TOTAL_REGISTRO
	
	(cTemp)->(dbCloseArea())

return nRet

//===============================================================================================================================
//					METODO RESPONSAVEL POR RETORNAR OS CAMPOS QUE PODEM SER UTILIZADOS PARA FILTRAGEM DO CARD
//===============================================================================================================================
wsmethod get cardFilter;
	wsService CardsVendas

	local	aFields		as array,;
			aCoreDash	as object,;
			oResponse	as object

	aFields		:= {}
	oCoreDash	:= CoreDashboard():New()
	oResponse	:= JsonObject():New()

	aFields	:={;
			{'code', 'Código do Cliente'},;
			{'store', 'Loja'},;
			{'name', 'Nome do Cliente'},;
			{'nred', 'Número de Redução'},;
			{'risk', 'Risco'};
			}
	
	oResponse['items']	:= oCoreDash:setPOHeader(aFields)
	self:setResponse(encodeUtf8(oReponse:ToJson()))
	
return .T.

//===============================================================================================================================
//					FUNÇÃO RESPONSAVEL POR RETORNAR O HEADER DE ACORDO COM A TABELA SOLICITADA
//===============================================================================================================================
static function retHeader(cTabela)
	local	aHeader	as array

	default cTabela := 'SA1'

	if cTabela == 'SA1'
		aHeader	:= {;
					{'cod'		, 'Código'		, 'link',,,.T.},;
					{'store'	, 'Loja'		,,,,.T.},;
					{'name'		, 'Nome'		,,,,.T.},;
					{'nred'		, 'N.Redução'	,,,,.T.},;
					{'risk'		, 'Risco'		,,,,.T.};
					}

	elseif cTabela == 'SC5'
		aHeader	:= {;
					{'num'		, 'Número'		,,,,.T.},;
					{'type'		, 'Tipo'		,,,,.T.},;
					{'cond'		, 'Cond.Pagto'	,,,,.T.},;
					{'emission'	, 'Emissão'		,,,,.T.};
					}
	endif
return aHeader
