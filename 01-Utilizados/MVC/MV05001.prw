#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: MV05001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 18/12/2018
===============================================================================================================================
Descrição---------: Este programa serve para CONTROLAR AS SITUACOES DOS PEDIDOS DE VENDAS
===============================================================================================================================
Uso---------------: Faturamento e Logistica
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
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
user function MV05001()

	local oBrowse
	local cFiltroTela	:= ' 1=1 ' 
	
	private cCadastro 	:= '[MV05001] - Controle de Situação de Pedidos'
	
	/* FWmBrowse */
	oBrowse:= FWmBrowse():New()
	oBrowse:SetDescription( cCadastro )
	oBrowse:DisableDetails()
	oBrowse:SetAlias( 'SF2' )
	oBrowse:SetMenuDef( 'MV05001' ) // Define de que fonte vem os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// Exibicao do botao Sair  
	oBrowse:SetFilterDefault(cFiltroTela) //Filtros da rotina
	
	/* Legendas */ 
	oBrowse:AddLegend( "F2_XSTNOTA == '01' "	, "BR_VERDE"		, "01 - Faturado",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '02' "	, "BR_BRANCO"		, "02 - Guarita",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '03' "	, "BR_LARANJA"		, "03 - Corte e Dobra",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '04' "	, "BR_MARRON"		, "04 - Armação",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '05' "	, "BR_VIOLETA"		, "05 - Telha",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '06' "	, "BR_CINZA"		, "06 - Retira",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '07' "	, "BR_PRETO"		, "07 - Expedicao",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '08' "	, "BR_MARRON_OCEAN"	, "08 - Saiu para Entregar",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '09' "	, "BR_AZUL"			, "09 - Entregue",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '10' "	, "BR_AZUL"			, "10 - Entregue Parcial",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '11' "	, "BR_VERMELHO"		, "11 - Devolução",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '12' "	, "BR_AZUL"			, "12 - Entrega Direta",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '13' "	, "BR_PRETO_0"		, "13 - Aguardando Reserva",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '14' "	, "BR_PRETO_1"		, "14 - Almoxarifado",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '15' "	, "BR_PRETO_3"		, "15 - Carga",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '16' "	, "BR_CANCEL"		, "16 - Cancela Carga",,.F. )

	/*BR_MARRON_OCEAN*/
	oBrowse:AddLegend( "F2_XSTNOTA == '17' "	, "BR_PINK"			, "17 - Retorno Carga",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '18' "	, "BR_CANCEL"		, "18 - Canc. Saiu p/Entrega",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '19' "	, "BR_CANCEL"		, "19 - Canc. Retorno de Carga",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '20' "	, "BR_CANCEL"		, "20 - Canc. Proc. Entrega",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '21' "	, "BR_LARANJA"		, "21 - Corte e Dobra Parcial",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '22' "	, "BR_MARRON"		, "22 - Armação Parcial",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '23' "	, "BR_VIOLETA"		, "23 - Telha Parcial",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '24' "	, "BR_AMARELO"		, "24 - Corte e Dobra Finalizado",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '25' "	, "BR_AMARELO"		, "25 - Armacao Finalizado",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '26' "	, "BR_AMARELO"		, "26 - Telha Finalizado",,.F. )
	oBrowse:AddLegend( "F2_XSTNOTA == '27' "	, "BR_VERMELHO"		, "27 - Situacao Reaberto",,.F. )

	oBrowse:Activate()      
	
return


/*CRIAR MODELO DE DADOS*/
static function ModelDef

	local oModel
	
	/* Carregar a estrutura de dados */
	local oStrSF2	:= FWFormStruct(1,'SF2', { |cCampo| VerCmpP('SF2',cCampo) })
	local oStrZ03	:= FWFormStruct(1,'Z03', { |cCampo| VerCmpP('Z03',cCampo) })
	local oStrZ07	:= FWFormStruct(1,'Z07')
	
	/* Definir propriedades da estrutura de dados */
	Criagat(oStrSF2,oStrZ03,oStrZ07)
	SetPropM(oStrSF2,oStrZ03,oStrZ07)
	
	/* Definir modelo de dados */
	oModel	:= MPFormModel():New('MV05001_MVC', /*bPreValidacao*/, /*bPosValidacao*/,{|oModel| MV05001GRV(oModel) }/*bCommit*/, /*bCancel*/ )
	
	
	/* editar propriedades do modelo de dados */
	oModel:addFields('FIELD_SF2',,oStrSF2)
	oModel:addGrid('GRID_Z03','FIELD_SF2' ,oStrZ03, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:addGrid('GRID_Z07','GRID_Z03' ,oStrZ07, , , /*bLinePre*/, {|oModel, nLine, cAction, cField| MV05001LOK(oModel, nLine, cAction, cField)}/*bPreVal*/, /*bPosVal*/, {|oModelGrid| MV05001_BLOAD_Z07(oModelGrid)}/*BLoad*/ )

	/*Relacao entre as Estrutura*/
	oModel:SetRelation('GRID_Z03',{{'Z03_FILIAL','xFilial("SF2")'}, {'Z03_SERIE', 'F2_SERIE'}, {'Z03_NOTA', 'F2_DOC'}}, Z03->(IndexKey(1)))
	oModel:SetRelation('GRID_Z07',{{'Z07_FILIAL','xFilial("Z03")'}, {'Z07_SERIE', 'Z03_SERIE'}, {'Z07_NOTA', 'Z03_NOTA'}, {'Z07_ITEM', 'Z03_ITEM'}}, Z07->(IndexKey(1)))
	
	oModel:setDescription('[MV05001] - Controle de Situação de Pedidos')
	oModel:GetModel('GRID_Z03'):setDescription('[MV05001] - Pedidos Faturados')
	oModel:GetModel('GRID_Z07'):setDescription('[MV05001] - Situações Pedidos')
	
	/*Liga o controle de não repetição de linha*/
	oModel:GetModel('GRID_Z03'):setUniqueLine({'Z03_ITEM'})
	oModel:GetModel('GRID_Z07'):setUniqueLine({'Z07_ITEMST'})
	
	/* Indica que é opcional ter dados nas Grids permitindo salvar a grid vazia*/
	oModel:GetModel( 'GRID_Z03' ):SetOptional(.F.)
	oModel:GetModel( 'GRID_Z07' ):SetOptional(.F.)

	/*Definicao da Chave Primaria*/
	oModel:SetPrimaryKey({'F2_FILIAL', 'F2_SERIE', 'F2_DOC'})
	
return oModel


/*CRIAR VIEWDEF DO MODELO DE DADOS*/
static function ViewDef()

	/*Importar modelo de dados */
	local oModel	:= FWLoadModel('MV05001')	//nome do fonte que esta criado a estrutura de dados
	
	/*Cria estrutura de dados da Viewdef*/
	//criar a estrutura de dados da camada de visualização 
	Local oStrSF2 	:= FWFormStruct(2,'SF2' , { |cCampo| VerCmpP('SF2',cCampo) } )
	local oStrZ03	:= FWFormStruct(2,'Z03', { |cCampo| VerCmpP('Z03',cCampo) })	
	local oStrZ07	:= FWFormStruct(2,'Z07')
	local oView		:= FWFormView():New()
	
	/*Definir propriedades da Viewdef*/
	setPropV(oStrSF2,oStrZ03,oStrZ07)		//setar propriedade da estrutura
	RemoveFld(oStrSF2,oStrZ03,oStrZ07)		//remocao de campos da estrutura
	
	/*Define qual modelo de dados sera utilizado pela View*/
	oView:SetModel(oModel)

	/* Construir ViewDef*/
	oView:AddField('VIEW_SF2', oStrSF2, 'FIELD_SF2' )
	oView:AddGrid('VIEW_Z03', oStrZ03, 'GRID_Z03' )
	oView:AddGrid('VIEW_Z07', oStrZ07, 'GRID_Z07' )
	
	/*Define campos que terao auto incremento*/
	oView:addIncrementField('VIEW_Z03','Z03_ITEM')
	oView:addIncrementField('VIEW_Z07','Z07_ITEMST')
	
	/*Gerar Box de Visualizacao*/
	oView:CreateHorizontalBox('SUPERIOR', 50)  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateHorizontalBox('INFERIOR', 50)  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateVerticalBox('ESQUERDO', 40, 'INFERIOR')  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateVerticalBox('DIREITO', 60, 'INFERIOR')  			// <nome do box>, <%que vai ocupar na tela>
	
	/*Relacionar box com a Estrutura*/
	oView:SetOwnerView('VIEW_SF2', 'SUPERIOR')			//
	oView:SetOwnerView('VIEW_Z03', 'ESQUERDO')			//
	oView:SetOwnerView('VIEW_Z07', 'DIREITO')			//

return oView


/*CRIAR MENU DA ROTINA*/
static function MenuDef()

	local aRotina	as array
	
	aRotina	:= {}

	aadd(aRotina,{'Alterar'				, 'VIEWDEF.MV05001', 0, 4, 0, nil})
	aadd(aRotina,{'Mapa de Producao'	, 'U_RD05006()', 0, 8, 0, nil})
	aadd(aRotina,{'Acerta Peso'			, 'U_RD05011(.T.)', 0, 8, 0, nil})
	aadd(aRotina,{'Imprimir'			, 'VIEWDEF.MV05001', 0, 8, 0, nil})
	
return aRotina


/*Remove campos da estrutura*/
static function RemoveFld(oStrSF2,oStrZ03,oStrZ07)

	oStrSF2:RemoveField('SF2_CLIENT')

	oStrZ03:RemoveField('Z03_SERIE')
	oStrZ03:RemoveField('Z03_NOTA')
	oStrZ03:RemoveField('Z03_STOCOR')
	oStrZ03:RemoveField('Z03_DSTOCO')
	oStrZ03:RemoveField('Z03_ADMIN')
	oStrZ03:RemoveField('Z03_OBSV')

	oStrZ07:RemoveField('Z07_SERIE')
	oStrZ07:RemoveField('Z07_NOTA')
	oStrZ07:RemoveField('Z07_ITEM')

return

/*Seta propriedades da estrutura de dados*/
static function SetPropM(oStrSF2,oStrZ03,oStrZ07)

	oStrZ07:SetProperty('Z07_SITUAC', MODEL_FIELD_VALID, {|| _validadata()})
	//oStrZ07:SetProperty('Z07_DSCSIT', MODEL_FIELD_INIT, {|| posicione('Z04',1,fwxFilial('Z04')+M->Z07_SITUAC,'Z04_STATUS')})

return

static function setPropV(oStrSF2, oStrZ03, oStrZ07)
	
//	oStrSF2:setProperty('F2_XNOMECL', MVC_VIEW_INIBROW, 'posicione("SA1",1,XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NREDUZ")' )
	oStrSF2:setProperty('*', MVC_VIEW_CANCHANGE, .F. )

	oStrZ03:setProperty('Z03_ITEM', MVC_VIEW_CANCHANGE, .F. )
	oStrZ07:setProperty('Z07_ITEMST', MVC_VIEW_CANCHANGE, .F. )
	// Inicializa a descrição da situação com lookup em Z04 ao abrir/entrar na linha
	//oStrZ07:setProperty('Z07_DSCSIT', MVC_VIEW_INIBROW, 'posicione("Z04",1,FWXFILIAL("Z04")+M->Z07_SITUAC,"Z04_STATUS")'  )

return

/*Funcaopara validar data */
static function _validadata()

	local _lRet		:= .T.
	local oModel	:= FWModelActive()
	//local oView		:= FWViewActive()
	local oModelZ07	:= oModel:GetModel('GRID_Z07')
	
	local cSituacao	:= oModelZ07:getValue('Z07_SITUAC')	//&(readvar())
//	local _dDataAtu	:= DDATABASE


	if cSituacao $ '08|09|12|15|17'
		_lRet	:= .F.
		help(,,'Help',,'Situação Invalida', 1, 0)
	endif
		
return _lRet


/*Nao permite deletar linhas na alteracao*/
static function COMP023LPRE(oModelGrid, nLinha, cAcao, cCampo)

	local 	cCodSituacao	as char,;
			cSituacao		as char,;
			lCancela		as logical,;
			lAdmin			as logical

	cCodSituacao	:= oModelZ07:getValue('Z07_SITUAC')
	cSituacao		:= posicione('Z04',1,xFilial('Z04')+cCodSituacao,'Z04_STATUS')
	lCancela		:= posicione('Z04',1,xFilial('Z04')+cCodSituacao,'Z04_FLCANC')
	lAdmin			:= u_EstaGrp(RetCodUsr(),'000000')	//Grupo de Administradores

	if !lAdmin
		if cCodSituacao $ '|08|09|10|11|12|16|17|18|19|20|27|99|' //ENTREGUE|ENTREGUE PARCIAL|DEVOLVIDO|ENTREGAR DIRETO|
//		if lCancela //nao permite inlcuir, alterar ou excluir linhas com situação bloquedo cancelamento
			if cAcao == 'SETVALUE' .and. nOperation == 4	//alterando uma linha
				lRet	:= .F.
				help(,,'Help',,'Não é permitido alterar situação de um pedido já '+alltrim(cSituacao)+'.', 1, 0)
			
			elseif cAcao == 'ADDLINE' .and. nOperation == 4	//adicionando uma nova linha
				lRet	:= .F.
				help(,,'Help',,'Não é permitido incluir situação de um pedido já '+alltrim(cSituacao)+'.', 1, 0)
			
			elseif cAcao == 'DELETE' .AND. nOperation == 4	//deletando uma linha
				lRet	:= .F.
				help(,,'Help',,'Não é permitido apagar linha com situação já '+alltrim(cSituacao)+'.', 1, 0)
			
			endif
		endif
	endif

return .T.

static function CriaGat(oStrSF2,oStrZ03,oStrZ07) 

	Local _aGatillho := {}
	Local _iGat
	
	/* Gatilhos Z03*/
	_aGatillho := {}
	aAdd(_aGatillho	,FwStruTrigger('Z03_STNOTA' 	,'Z03_DSTNOT' ,'Z04->Z04_STATUS',.T.,'Z04',1 ,'xFilial("Z04")+M->Z03_STNOTA'))
	aAdd(_aGatillho	,FwStruTrigger('Z03_STOCOR' 	,'Z03_DSTOCO' ,'Z05->Z05_STATUS',.T.,'Z05',1 ,'xFilial("Z05")+M->Z03_STOCOR'))
//	aAdd(_aGatillho	,FwStruTrigger('Z03_MOTORI','Z03_NOMMOT' ,'DA4->DA4_NREDUZ',.T.,'DA4',1 ,'xFilial("DA4")+M->Z03_MOTORI'))
	
	For _iGat := 1 to Len(_aGatillho)
		oStrZ03:AddTrigger( _aGatillho[_iGat][1], _aGatillho[_iGat][2], _aGatillho[_iGat][3], _aGatillho[_iGat][4] )
	Next _iGat
	
	/* Gatilhos Z07*/
	_aGatillho := {}
//	aAdd(_aGatillho	,FwStruTrigger('Z07_SITUAC', 'Z07_DSCSIT', 'Z04->Z04_STATUS',.T.,'Z04',1 ,'xFilial("Z04")+M->Z07_SITUAC'))

	For _iGat := 1 to Len(_aGatillho)
		oStrZ07:AddTrigger( _aGatillho[_iGat][1], _aGatillho[_iGat][2], _aGatillho[_iGat][3], _aGatillho[_iGat][4] )
	Next _iGat
return


/*Mostrar Campos em Tela */
static function VerCmpP(cTab, cCampo , cTipo)

	Local 	_lRet		as logical,;
			_cCampos	as char

	_lRet:= .F.

	if cTab == 'SF2'
		_cCampos:= 'F2_DOC|F2_SERIE|F2_CLIENTE|F2_LOJA|F2_EMISSAO|F2_PLIQUI|F2_PBRUTO|F2_VEND1|F2_HORA|F2_XNOMECL|F2_VEND1|F2_XVEND1|F2_XSTNOTA|F2_XDSTNOT|F2_XTOTAL'
	elseif cTab == 'Z03'
		_cCampos:= 'Z03_FILIAL|Z03_ITEM|Z03_CARGA|Z03_SEQCAR|Z03_STNOTA|Z03_DSTNOT|Z03_SERIE|Z03_NOTA|Z03_MOTORI|Z03_CONFER'
	endif

	If Alltrim(cCampo) $ _cCampos
		_lRet := .T.
	EndIf

return _lRet  


/*Botao customizado*/
static function _botao()

	local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	
	FWExecView('Inclusao por FWExecView','AMVC003', MODEL_OPERATION_INSERT, , { || .T. }, ,15,aButtons )

return

static function FClass(oModelGrid, nLine, cAction, cField)

	local _lRet	:= .T.
	
	local oModel	:= oModelGrid:getModel()
	local oModelSF2	:= oModel:getModel('FIELD_SF2')
	local oModelZ03	:= oModel:getModel('GRID_Z03')
	local oModelZ07	:= oModel:getModel('GRID_Z07')
	
	local _nLinZ03	:= oModelZ03:NLINE
	local _nLinZ07	:= oModelZ07:NLINE
	
	local _aSave	:= FwSaveRows()
	
	local cCodigo	:= ''
	
	local cCodAnt	:= ''

	local _n
	
	for _n:= 1 to oModelZ07:Length()
		oModelZ07:Goline(_n)

		if !oModelZ07:IsDeleted()
			if (_n == _nLinZ07) 
				if !(cAction	== 'DELETE')
					cCodigo	:= oModelZ07:getValue('Z07_SITUAC')
					//cDesc	:= oModelZ07:getValue('Z07_DSCSIT')
				endif
			else
				cCodigo	:= oModelZ07:getValue('Z07_SITUAC')
				//cDesc	:= oModelZ07:getValue('Z07_DSCSIT')
			endif
		endif
		
		cCodAnt	:= cCodigo
		
	next _n
	
	//cDesc	:= posicione('Z04',1,fwxFilial('Z04')+cCodigo,'Z04_STATUS')
	//oModelZ07:setValue('Z07_DSCSIT',cDesc)
	oModelSF2:SetValue('F2_XSTNOTA',cCodigo)
	//oModelSF2:SetValue('F2_XDSTNOT',cDesc)
	oModelZ03:SetValue('Z03_STNOTA',cCodigo)
	//oModelZ03:SetValue('Z03_DSTNOT',cDesc)
	
	FwRestRows(_aSave)
	
	oModelZ03:goLine(_nLinZ03)
	oModelZ07:goLine(_nLinZ07)

return _lRet

/* BLoad para GRID_Z07: inicializa Z07_DSCSIT para linhas existentes */
static function MV05001_BLOAD_Z07(oModelGrid)
	local _lRet := .T.
	local _n
	local cSit := ''
	local cDesc := ''
	for _n := 1 to oModelGrid:Length()
		oModelGrid:Goline(_n)
		if !oModelGrid:IsDeleted()
			cSit := oModelGrid:getValue('Z07_SITUAC')
			if !empty(alltrim(cSit))
				cDesc := posicione('Z04',1,fwxFilial('Z04')+cSit,'Z04_STATUS')
				if !empty(alltrim(cDesc))
					oModelGrid:SetValue('Z07_DSCSIT', cDesc)
				endif
			endif
		endif
	next
	return _lRet

/*Ponte de Entrada MV05001LOK*/
static function MV05001LOK(oModelGrid, nLine, cAction, cField)
	local _lRet	:= .T.

	_lRet	:= FClass(oModelGrid, nLine, cAction, cField)
	
return _lRet

static function MV05001LPRE(oModelGrid, nLine, cAction, cField)
	local _lRet	:= .T.

	_lRet	:= FClass(oModelGrid, nLine, cAction, cField)

	u_msgErro('Estou passando pelo MV05001LPRE')

return _lRet

static function MV05001GRV(oModel)
	local lRet

	local	aArea	:= getArea(),;
			aZ04	:= Z04->(getArea()),;
			cCodSit	:= '',;
			cSerie	as caracter,;
			cDoc	as caracter,;
			cItem	as caracter

	/*Aqui podemos chamar funções antes do Commit Padrão.*/ 
	if FValidaSit(oModel) 

		/*Aqui temos a chamada da funcao padrão de gravação do MVC.*/ 	// http://tdn.totvs.com/display/framework/FWFormCommit 
		lRet := FWFormCommit( oModel /*[ oModel ]*/,; 
									/*[ bBefore ]*/,; 
									/*[ bAfter ]*/,; 
									/*[ bAfterSTTS ]*/,; 
									/*[ bInTTS ]*/,; 
									/*[ bABeforeTTS ]*/,; 
									/*[ bIntegEAI ] */ ) 
		
		/* Aqui podemos chamar funções depois do Commit Padrão, verificando sempre se o commit foi realizado. */ 
		/*if lRet
		//	__FazAlgoDepoisCommit() 
		if u_msgPergunta('Enviar e-mail com posição do chamado?','[MV00001] - ENVIANDO EMAIL AGUARDE')
			EnviaEmail()
		endif
		
		endif
		*/

		dbSelectArea('Z07')
		Z07->(dbSetOrder(1))
		Z07->(dbGoTop())
		if Z07->(dbSeek(+fwxFilial('Z03')+SF2->F2_SERIE+SF2->F2_DOC))
			while !Z07->(eof()) .and. Z07->Z07_SERIE == SF2->F2_SERIE .and. Z07->Z07_NOTA == SF2->F2_DOC
				cCodSit	:= Z07->Z07_SITUAC
				Z07->(dbSkip())
			enddo
		endif

		if select('Z03') > 0
			Z03->(dbCloseArea())
		endif
		dbSelectArea('Z03')
		Z03->(dbSetOrder(1))
		Z03->(dbGoTop())
		if Z03->(dbSeek(+fwxFilial('Z03')+SF2->F2_SERIE+SF2->F2_DOC))
			while !Z03->(eof()) .and. Z03->Z03_SERIE == SF2->F2_SERIE .and. Z03->Z03_NOTA == SF2->F2_DOC
				cSerie	:= Z03->Z03_SERIE
				cDoc	:= Z03->Z03_NOTA
				cItem	:= Z03->Z03_ITEM
				Z03->(dbSkip())
			enddo
			Z03->(dbGoTop())
			if Z03->(dbSeek(+fwxFilial('Z03')+cSerie+cDoc+cItem))
				if recLock('Z03',.F.)
					Z03->Z03_STNOTA	:= cCodSit
					msUnLock()
				endif
			endif
		endif

		if RecLock('SF2',.F.)
			SF2->F2_XSTNOTA	:= cCodSit
			msUnLock()
		endif

		restArea(aZ04)
		restArea(aArea)
	endif

return lRet

static function FValidaSit(oModel)
	local	lRet as logical
	
	local 	oModelZ07	as object

	local	cCodUser	as caracter

	oModelZ07	:= oModel:getModel('GRID_Z07')

	ccodUser	:= RetCodUsr()

	lRet	:= .F.

	if !oModelz07:isDeleted() .and. oModelZ07:getValue('Z07_SITUAC') == '27'	//Reaberto
		if u_msgPergunta('Atenção! Você está prestes a reabrir um pedido. Deseja continuar?','[MV05001] - REABRIR PEDIDO') = 6
			if u_EstaGrp(cCodUser,'000000')	//Grupo de Administradores
				lRet	:= .T.
			else
				u_msgInformacao('Apenas usuários do grupo de administradores podem reabrir um pedido.','[MV05001] - REABRIR PEDIDO')
				lRet	:= .F.
			endif
		else
			lRet	:= .F.
		endif
	else
		lRet	:= .T.
	endif
	
return lRet

static function ajustaSx1(cPerg)

	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(     cPerg,"01","Vendedor?", "Vendedor?", "Vendedor?", "mv_ch1","C",06,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")

return
