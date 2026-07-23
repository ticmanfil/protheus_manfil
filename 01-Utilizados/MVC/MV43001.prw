#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'

/*/
===============================================================================================================================
Programa----------: MV43001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 04/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para CADASTRAR ENTRADAS E SAIDAS DE VEICULOS NO PATIO MANFIL
===============================================================================================================================
Uso---------------: FATURAMENTO
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: PRODUCAO
===============================================================================================================================
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

user function MV43001()

	//Local oMainWnd
	Local oBrowse  
	local cFiltroTela	:= ''	//'1=1'

	//local cPerg		:= 'MV43001'
	
	private cCadastro 	:= '[MV43001] - Controle de E/S Veículo'
	
	/* FWmBrowse */
	oBrowse:= FWmBrowse():New()
	oBrowse:SetDescription( cCadastro )
	oBrowse:DisableDetails()
	oBrowse:SetAlias( 'Z11' )
	oBrowse:SetMenuDef( 'MV43001' ) // Define de que fonte vem os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// Exibicao do botao Sair  
	oBrowse:SetFilterDefault(cFiltroTela) //Filtros da rotina
	
	oBrowse:Activate()      
	
return


/*CRIAR MODELO DE DADOS*/
static function ModelDef

	local oModel
	
	/* Carregar a estrutura de dados */
	local oStrZ11	:= FWFormStruct(1,'Z11')	//1 ou 2
//	local oStrZ11	:= FWFormStruct(1,'Z11', { |cCampo| VerCampo(cCampo) })	//1 ou 2
	
	/* Definir propriedades da estrutura de dados */
	Criagat(oStrZ11)
	SetPropM(oStrZ11)
	
	/* Definir modelo de dados */
	oModel	:= MPFormModel():New('MV43001_MVC', /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )
	
	/* editar propriedades do modelo de dados */
	oModel:addFields('FIELD_Z11',,oStrZ11)

	oModel:setDescription(cCadastro)
	
	/*Definicao da Chave Primaria*/
	oModel:SetPrimaryKey({'Z11_FILIAL', 'Z11_SEQ'})
	
return oModel


/*CRIAR VIEWDEF DO MODELO DE DADOS*/
static function ViewDef()

	/*Importar modelo de dados */
	local oModel	:= FWLoadModel('MV43001')	//nome do fonte que esta criado a estrutura de dados
	
	/*Cria estrutura de dados da Viewdef*/
	Local oStrZ11 	:= FWFormStruct(2,'Z11')
//	Local oStrZ11 	:= FWFormStruct(2,'Z11', { |cCampo| VerCampo(cCampo) })
	local oView		:= FWFormView():New()
	
	/*Define qual modelo de dados sera utilizado pela View*/
	oView:SetModel(oModel)

	/* Construir ViewDef*/
	oView:AddField('VIEW_Z11', oStrZ11, 'FIELD_Z11' )
	
	/*Gerar Box de Visualizacao*/
	oView:CreateHorizontalBox('PRINCIPAL', 100)  			// <nome do box>, <%que vai ocupar na tela>
	
	/*Relacionar box com a Estrutura*/
	oView:SetOwnerView('VIEW_Z11', 'PRINCIPAL')			//

return oView


/*CRIAR MENU DA ROTINA*/
static function MenuDef()

	local aRotina	:= {}
	
	aadd(aRotina,{'Visualizar'	, 'VIEWDEF.MV43001', 0, 2, 0, nil})
	aadd(aRotina,{'Saída'		, 'VIEWDEF.MV43001', 0, 3, 0, nil})
	aadd(aRotina,{'Entrada'		, 'VIEWDEF.MV43001', 0, 4, 0, nil})
	aadd(aRotina,{'Cancelar'	, 'VIEWDEF.MV43001', 0, 5, 0, nil})
	aadd(aRotina,{'Imprimir'	, 'U_FIMP(.T.)', 0, 8, 0, nil})
	
return aRotina

/*Seta propriedades da estrutura de dados*/
static function SetPropM(oStrZ11)
	local	nTara	:= 0,;
			nKmIni	:= 0,;
			nPesoB	:= 0,;
			nPesoL	:= 0
	
	oStrZ11:SetProperty('Z11_VEICUL', MODEL_FIELD_VALID, {||_validadata()})
	oStrZ11:SetProperty('Z11_KMINI'	, MODEL_FIELD_VALID, {||_validadata()})
	oStrZ11:SetProperty('Z11_DTSAID', MODEL_FIELD_VALID, {||_validadata()})
	oStrZ11:SetProperty('Z11_HRSAID', MODEL_FIELD_VALID, {||_validadata()})
	oStrZ11:SetProperty('Z11_KMFINA', MODEL_FIELD_VALID, {||_validadata()})
	oStrZ11:SetProperty('Z11_DTENTR', MODEL_FIELD_VALID, {||_validadata()})
	oStrZ11:SetProperty('Z11_HRENTR', MODEL_FIELD_VALID, {||_validadata()})

	if type('cCarga') != 'U'
		if !empty(cCarga)
			nTara	:= posicione('DA3',3,xFilial('DA3')+cPlaca,'DA3_TARA')
			nKmIni	:= U_MV43001KMI(cPlaca)
			nPesoB	:= nPeso+nTara
			nPesoL	:= nPeso

			oStrZ11:SetProperty('Z11_VEICUL', MODEL_FIELD_INIT, {||cPlaca})
			oStrZ11:SetProperty('Z11_MOTORI', MODEL_FIELD_INIT, {||cCodMoto})
			oStrZ11:SetProperty('Z11_NOMMOT', MODEL_FIELD_INIT, {||cNMoto})
			oStrZ11:SetProperty('Z11_PESO', MODEL_FIELD_INIT, {||nPesoB})
			oStrZ11:SetProperty('Z11_TARA', MODEL_FIELD_INIT, {||nTara})
			oStrZ11:SetProperty('Z11_KMINI', MODEL_FIELD_INIT, {||nKmIni})
			oStrZ11:SetProperty('Z11_PESLIQ', MODEL_FIELD_INIT, {||nPesoL})
			oStrZ11:SetProperty('Z11_CARGA', MODEL_FIELD_INIT, {||cCarga})
			oStrZ11:SetProperty('Z11_SEQCAR', MODEL_FIELD_INIT, {||cSeqCarga})

		endif
	endif

return

/*Funcao para validar data */
static function _validadata()

	local _lRet			:= .T.
	local oModel		:= FWModelActive()
	//local oView			:= FWViewActive()
	local oModelZ11		:= oModel:GetModel('FIELD_Z11')
	local cMsg			:= ''
	
	local 	cVeiculo	:= oModelZ11:getValue('Z11_VEICUL'),;
			nKmIni		:= oModelZ11:getValue('Z11_KMINI'),;
			cDtIni		:= oModelZ11:getValue('Z11_DTSAID'),;
			cHrIni		:= oModelZ11:getValue('Z11_HRSAID'),;
			nKmFin		:= oModelZ11:getValue('Z11_KMFINA'),;
			cDtFin		:= oModelZ11:getValue('Z11_DTENTR'),;
			cHrFin		:= oModelZ11:getValue('Z11_HRENTR'),;
			nKmIniAtual	:= 0
	
	nKmIniAtual	:= u_MV43001KMI(cVeiculo)
	
	if !empty(cVeiculo) .and. !ExVeiculo(cVeiculo)
		u_msgErro('Veiculo '+alltrim(cVeiculo)+' não CADASTRADO!'+CRLF+' Solicite o cadastro ao ADMINISTRADOR.',cCadastro)
		return .F.
	else
		if inclui .and. !empty(cVeiculo) .and. EmTransito(cVeiculo)
			u_msgErro('Veiculo encontra-se em TRANSITO!'+CRLF+' Faça a entrada dele antes de continuar.',cCadastro)
			return .F.
		else
			if inclui .and. !empty(cVeiculo) .and. !empty(nKmIni) .and. nKmIni != 0 .and. nKmIniAtual != nKmIni                                                                                                      
				if !u_msgPergunta('O KM inicial ('+alltrim(cValToChar(nKmIni))+') nao corresponde a ultima movimentação ('+alltrim(cValToChar(nKmIniAtual))+')!'+CRLF+' Deseja continuar?',cCadastro)
					return .F.
				endif
			endif

			if !empty(cHrIni) .and. !u_VldHora(alltrim(cHrIni))
				_lRet	:= .F.
				cMsg	+= CRLF + 'Hora de Saída não é válido!'
			endif
	
			if !empty(cHrFin) .and. !u_VldHora(alltrim(cHrFin))
				_lRet	:= .F.
				cMsg	+= CRLF + 'Hora de Entrada não é válido!'
			endif
	
			if !empty(cHrIni) .and. len(alltrim(cHrIni)) < 6
				_lRet	:= .F.
				cMsg	+= CRLF + 'Hora de Saída com tamanho válido!'
			endif
	
			if !empty(cHrFin) .and. len(alltrim(cHrFin)) < 6
				_lRet	:= .F.
				cMsg	+= CRLF + 'Hora de Entrada com tamanho válido!'
			endif
	
			if !empty(cDtIni) .and. !empty(cDtFin) .and. cDtIni > cDtFin
				_lRet	:= .F.
				cMsg	+= CRLF + 'DATA de ENTRADA não pode ser menor que a DATA de SAIDA!'
			endif
	
			if !empty(cDtIni) .and. cDtIni > DDATABASE
				_lRet	:= .F.
				cMsg	+= CRLF + 'DATA de ENTRADA maior que a DATA BASE!'
			endif

			if !empty(cDtFin) .and. cDtFin > DDATABASE
				_lRet	:= .F.
				cMsg	+= CRLF + 'DATA de SAIDA maior que a DATA BASE!'
			endif

	/*		if !empty(cDtIni) .and. !empty(cDtFin) .and. !empty(cHrIni) .and. !empty(cHrFin)
				if cDtIni = cDtFin .and. cHrIni < cHrFin
					_lRet	:= .F.
					cMsg	+= CRLF + 'HORA de ENTRADA não pode ser menor que a HORA de SAIDA!'
				endif
			endif
	*/

			if !empty(nKmIni) .and. !empty(nKmFin) .and. nKmIni > nKmFin 
				_lRet	:= .F.
				cMsg	+= CRLF + 'KM FINAL não pode ser menor que a KM INICIAL!'
			endif
	
			if !empty(nKmIni) .and. !empty(nKmFin) .and. nKmFin - nKmIni > 5000 
				_lRet	:= .F.
				cMsg	+= CRLF + 'DISTANCIA percorrida superior a 5.000 KM!'
			endif

			if	!_lRet
				help(,,'Help',,cMsg, 1, 0)
			endif
			
		endif
	endif
	
return _lRet

static function CriaGat(oStrZ11) 

	Local _aGatillho := {}
	Local _iGat
	
	/* Gatilhos Z11*/
	_aGatillho := {}
	aAdd(_aGatillho	,FwStruTrigger('Z11_MOTORI' 	,'Z11_NOMMOT' 	,'DA4->DA4_NOME',.T.,'DA4',1 ,'XFILIAL("DA4")+M->Z11_MOTORI'))                                                                                                 
	aAdd(_aGatillho	,FwStruTrigger('Z11_VEICUL' 	,'Z11_TARA' 	,'DA3->DA3_TARA',.T.,'DA3',3 ,'XFILIAL("DA3")+M->Z11_VEICUL'))
	aAdd(_aGatillho	,FwStruTrigger('Z11_VEICUL' 	,'Z11_KMINI' 	,'U_MV43001KMI(M->Z11_VEICUL)',.F.))
	//aAdd(_aGatillho	,FwStruTrigger('Z11_KMINI' 	,'Z11_KMINI' 	,'KMINICIAL(M->Z11_VEICUL)',.F.))
	aAdd(_aGatillho	,FwStruTrigger('Z11_DTSAID' 	,'Z11_SEQ'	 	,'U_PROXSEQ("Z11","Z11_SEQ",2,"Z11_DTSAID",DTOS(M->Z11_DTSAID))',.F.))
	aAdd(_aGatillho	,FwStruTrigger('Z11_KMFINA' 	,'Z11_DTENTR' 	,'DDATABASE',.F.))
	aAdd(_aGatillho	,FwStruTrigger('Z11_KMFINA' 	,'Z11_HRENTR' 	,'TIME()',.F.))
	aAdd(_aGatillho	,FwStruTrigger('Z11_PESO' 		,'Z11_PESLIQ' 	,'M->Z11_PESO-M->Z11_TARA',.F.))
	aAdd(_aGatillho	,FwStruTrigger('Z11_TARA' 		,'Z11_PESLIQ' 	,'M->Z11_PESO-M->Z11_TARA',.F.))
	 
	For _iGat := 1 to Len(_aGatillho)
		oStrZ11:AddTrigger( _aGatillho[_iGat][1], _aGatillho[_iGat][2], _aGatillho[_iGat][3], _aGatillho[_iGat][4] )
	Next _iGat
	
return

static function EmTransito(cVeiculo)

	local 	_cQuery	:= '',;
			lRet	:= .F.

	_cQuery := " SELECT TOP 1 Z11_KMFINA  "
	_cQuery += " FROM " + RetSqlName('Z11')
	_cQuery += " WHERE D_E_L_E_T_ = ' ' "
	_cQuery += " AND Z11_VEICUL = '"+cVeiculo+"' "
	_cQuery += " AND Z11_KMFINA = '' "
	_cQuery += " ORDER BY Z11_VEICUL, Z11_DTSAID DESC, Z11_KMFINA DESC"
	
	TcQuery _cQuery New Alias "TRB"
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	if !TRB->(EOF())
		lRet	:= .T.
	else
		lRet	:= .F.
	endif
	dbSelectArea('TRB')
	TRB->(dbCloseArea())
	
return lRet

static function ExVeiculo(cVeiculo)

	local 	_cQuery	:= '',;
			lRet	:= .F.

	_cQuery := " SELECT TOP 1 DA3_COD  "
	_cQuery += " FROM " + RetSqlName('DA3')
	_cQuery += " WHERE D_E_L_E_T_ = ' ' "
	_cQuery += " AND DA3_PLACA = '"+cVeiculo+"' "
	
	TcQuery _cQuery New Alias "TRB"
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	lRet	:= !TRB->(EOF())
	dbSelectArea('TRB')
	TRB->(dbCloseArea())
	
return lRet

user function MV43001KMI(cVeiculo)

	local 	cKM		:= 0,;
			_cQuery	:= ''

	_cQuery := " SELECT TOP 1 Z11_KMFINA  "
	_cQuery += " FROM " + RetSqlName('Z11')
	_cQuery += " WHERE D_E_L_E_T_ = ' ' "
	_cQuery += " AND Z11_VEICUL = '"+cVeiculo+"' "
	_cQuery += " AND Z11_KMFINA != '' "
	//_cQuery	+= " AND Z11_DTENTR <= '"+dtos(dData)+"'"
	_cQuery += " ORDER BY Z11_DTENTR DESC, Z11_KMFINA DESC"
	
	TcQuery _cQuery New Alias "TRB"
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	if !TRB->(EOF())
		cKM	:= TRB->Z11_KMFINA
	else
		cKM	:= 0
	endif
	dbSelectArea('TRB')
	TRB->(dbCloseArea())
	
return cKm
