#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'

/*/
===============================================================================================================================
Programa----------: MV09002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 05/06/2019
===============================================================================================================================
Descrição---------: Este programa serve para Cadastrar os Grupos Tributados do cadastro de produtos
===============================================================================================================================
Uso---------------: FISCAL
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FISCAL
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

user function MV09002()

//	Local oMainWnd
	//Local aCoors := FWGetDialogSize( oMainWnd )
	//Local oPanel, oFWLayer, oBrowse
	local oBrowse  
	local cFiltroTela	:= 'X5_TABELA == "01"'
	//private oDlgPrinc
	private cCadastro 	:= '[MV09002] - Acerto Seq Nota'
	
	//Define MsDialog oDlgPrinc Title cCadastro From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	/* Cria o conteiner onde são colocados os browses */
//	oFWLayer := FWLayer():New()
//	oFWLayer:Init( oDlgPrinc, .F., .T. )
	
	/* Define Painel Principal */
//	oFWLayer:AddLine( 'FULL', 100, .F. )// Cria uma "linha" com 100% da tela
//	oFWLayer:AddCollumn( 'ALL', 100, .T., 'FULL' )// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
//	oPanel := oFWLayer:GetColPanel( 'ALL', 'FULL' )// Pego o objeto desse do container
	
	/* FWmBrowse */
	oBrowse:= FWmBrowse():New()
//	oBrowse:SetOwner( oPanel ) // Aqui se associa o browse ao componente de tela
	oBrowse:SetDescription( cCadastro )
	oBrowse:DisableDetails()
	oBrowse:SetAlias( 'SX5' )
	oBrowse:SetMenuDef( 'MV09002' ) // Define de que fonte vem os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// Exibicao do botao Sair  
	oBrowse:SetFilterDefault(cFiltroTela) //Filtros da rotina
//	oBrowse:SetOnlyFields( { 'ZF0_TIPO' , 'ZF0_ANO' , 'ZF0_PERIOD' , 'ZF0_DATADE', 'ZF0_DATAAT' } ) 
	
	/* Legendas */ 
//	oBrowse:AddLegend( "F2_XSTNOTA == '01' "	, "BR_VERDE"		, "01 - Faturado" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '02' "	, "BR_BRANCO"		, "02 - Guarita" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '03' "	, "BR_LARANJA"		, "03 - Corte e Dobra" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '04' "	, "BR_MARRON"		, "04 - Armação" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '05' "	, "BR_MARRON OCEAN"	, "05 - Telha" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '06' "	, "BR_CINZA"		, "06 - Retira" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '07' "	, "BR_PRETO"		, "07 - Expedicao" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '08' "	, "BR_MARRON_OCEAN"	, "08 - Saiu para Entregar" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '09' "	, "BR_AZUL"			, "09 - Entregue" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '10' "	, "BR_AMARELO"		, "10 - Entregue Parcial" )
//	oBrowse:AddLegend( "F2_XSTNOTA == '11' "	, "BR_VERMELHO"		, "11 - Devolução" )

	oBrowse:Activate()      
	
//	Activate MsDialog oDlgPrinc Center

return


/*CRIAR MODELO DE DADOS*/
static function ModelDef

	local oModel
	
	/* Carregar a estrutura de dados */
	local oStrSX5	:= FWFormStruct(1,'SX5')	//1 ou 2
//	local oStrSX51	:= FWFormStruct(1,'SX5')	//1 ou 2
	
	/* Definir propriedades da estrutura de dados */
//	Criagat(oStrSX5,oStrSX51)
	SetPropM(oStrSX5)
	
	/* Definir modelo de dados */
	oModel	:= MPFormModel():New('MV09002_MVC', /*bPreValidacao*/, /*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )
	
	/* editar propriedades do modelo de dados */
	oModel:addFields('FIELD_SX5',,oStrSX5)
//	oModel:addGrid('GRID_SX51','FIELD_SX5' ,oStrSX51, { |oMdlG,nLine,cAcao,cCampo| COMP023LPRE( oMdlG, nLine, cAcao, cCampo ) } /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	/*Relacao entre as Estrutura*/
//	oModel:SetRelation('GRID_SX51',{{'X5_FILIAL','xFilial("SX5")'}, {'X5_TABELA', 'X5_CHAVE'}}, SX5->(IndexKey(1)))
	
	oModel:setDescription('[MV09002] - Cad. Grp. Tributado')
//	oModel:GetModel('GRID_SX51'):setDescription('[MV09002] - Itens')
	
	/*Liga o controle de não repetição de linha*/
	//oModel:GetModel('GRID_SX51'):setUniqueLine({'X5_CHAVE'})
	
	/* Valida propriedades de Insert, Update e Delete de Linhas na Grid*/
	//oModel:GetModel( 'GRID_ZAB' ):SetNoInsertLine()
	//oModel:GetModel( 'GRID_ZAB' ):SetNoUpdateLine()
	//oModel:GetModel( 'GRID_ZAB' ):SetNoDeleteLine()
	
	/* Seta quantidade máxima de linhas na Grid */
	//oModel:GetModel( 'GRID_ZAB' ):SetMaxLine(3)

	/* Indica que é opcional ter dados nas Grids permitindo salvar a grid vazia*/
//	oModel:GetModel( 'GRID_SX51' ):SetOptional(.F.)

	/* Define que o modelo de dados não será gravado, apenas usado para consulta */
//	oModel:GetModel("FIELD_SX5"):SetOnlyQuery(.T.)

	/*Definicao da Chave Primaria*/
	oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE'})
	
return oModel


/*CRIAR VIEWDEF DO MODELO DE DADOS*/
static function ViewDef()

	/*Importar modelo de dados */
	local oModel	:= FWLoadModel('MV09002')	//nome do fonte que esta criado a estrutura de dados
	
	/*Cria estrutura de dados da Viewdef*/
	Local oStrSX5 	:= FWFormStruct(2,'SX5')
	local oView		:= FWFormView():New()
	
	/*Definir propriedades da Viewdef*/
	//setPropV(oStrSX5)		//setar propriedade da estrutura
	RemoveFld(oStrSX5)		//remocao de campos da estrutura
	
	/*Define qual modelo de dados sera utilizado pela View*/
	oView:SetModel(oModel)

	/* Construir ViewDef*/
	oView:AddField('VIEW_SX5', oStrSX5, 'FIELD_SX5')
	
	/*Define campos que terao auto incremento*/
//	oView:addIncrementField('VIEW_SX51','X5_CHAVE')
	
	/*Incluir BOTOES customizados*/
//	oView:addUserButton('Botão Customizado', 'CLIPS', {|oView| _botao()})
	
	/*Gerar Box de Visualizacao*/
	oView:CreateHorizontalBox('SUPERIOR', 100)  			// <nome do box>, <%que vai ocupar na tela>
//	oView:CreateHorizontalBox('INFERIOR', 70)  			// <nome do box>, <%que vai ocupar na tela>
	
	/*Relacionar box com a Estrutura*/
	oView:SetOwnerView('VIEW_SX5', 'SUPERIOR')			//
//	oView:SetOwnerView('VIEW_SX51', 'INFERIOR')			//
	
return oView


/*CRIAR MENU DA ROTINA*/
static function MenuDef()

	local aRotina	:= {}
	
	aadd(aRotina,{'Visualizar'	, 'VIEWDEF.MV09002', 0, 2, 0, nil})
	aadd(aRotina,{'Incluir'		, 'VIEWDEF.MV09002', 0, 3, 0, nil})
	aadd(aRotina,{'Alterar'		, 'VIEWDEF.MV09002', 0, 4, 0, nil})
	aadd(aRotina,{'Excluir'		, 'VIEWDEF.MV09002', 0, 5, 0, nil})
//	aadd(aRotina,{'Imprimir'	, 'VIEWDEF.MV09002', 0, 8, 0, nil})
	
return aRotina


/*Remove campos da estrutura*/
static function RemoveFld(oStrSX5)

	oStrSX5:RemoveField('X5_TABELA')

return

/*Seta propriedades da estrutura de dados*/
static function SetPropM(oStrSX5)

    oStrSX5:SetProperty('X5_TABELA',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                       //Modo de Edição
    oStrSX5:SetProperty('X5_TABELA',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  '"01"'))                     //Ini Padrão
    oStrSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    'iif(INCLUI, .T., .F.)'))     //Modo de Edição
//    oStrSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'u_zSX5Chv()'))               //Validação de Campo
    oStrSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório
    oStrSX5:SetProperty('X5_DESCRI',   MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigatório

return

static function setPropV(oStrSX5)

	oStrSX5:setProperty('*', MVC_VIEW_CANCHANGE, .F. )
	
return

/*Funcaopara validar data */
static function _validadata()

	local _lRet		:= .T.
/*
	local oModel	:= FWModelActive()
	local oView		:= FWViewActive()
	local oModelZAB	:= oModel:GetModel('GRID_ZAB')
	
	local _dData	:= oModelZAB:getValue('ZAB_DATA')	//&(readvar())
	local _dDataAtu	:= DDATABASE

	if _dData > _dDataAtu
		_lRet	:= .F.
		help(,,'Help',,'Data inválida.', 1, 0)
	endif
*/		
return _lRet


/*Nao permite deletar linhas na alteracao*/
static function COMP023LPRE(oModelGrid, nLinha, cAcao, cCampo)

	local lRet			:= .T.
	local oModel		:= oModelGrid:getModel()
	local nOperation	:= oModel:getOperation()
	
	if cAcao == 'DELETE' .AND. nOperation == 3
		lRet	:= .F.
		help(,,'Help',,'Não é permitido apagar linha na alteração.'+CRLF+;
						'Você esta na linha ' +alltrim(str(nLinha)), 1, 0)
	endif
return lRet


/*Mostrar Campos em Tela */
Static Function VerCampo( cCampo , cTipo)

	Local _lRet		:= .F.

Return _lRet  


/*Botao customizado*/
static function _botao()

	local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	
	FWExecView('Inclusao por FWExecView','AMVC003', MODEL_OPERATION_INSERT, , { || .T. }, ,15,aButtons )

return

/*Ponte de Entrada MV00001LOK*/
static function MV00001LOK(oModelGrid, nLine, cAction, cField)

	local _lRet	:= .T.
	
	local oModel	:= oModelGrid:getModel()
	local oModelSF2	:= oModel:getModel('FIELD_SF2')
	local oModelZ03	:= oModel:getModel('GRID_Z03')
	local oModelZ07	:= oModel:getModel('GRID_Z07')
	
	local _nLinZ07	:= oModelZ07:NLINE
	local _nLinZ03	:= oModelZ03:NLINE
	
	local _aSave	:= FwSaveRows()
	
	local cCodigo	:= ''
	local cDescr	:= ''
	
	for _n:= 1 to oModelZ07:Length()
		oModelZ07:Goline(_n)

		if !oModelZ07:IsDeleted()
			if (_n == _nLinZ07) 
				if !(cAction	== 'DELETE')
					cCodigo	:= oModelZ07:getValue('Z07_SITUAC')
					cDesc	:= oModelZ07:getValue('Z07_DSCSIT')
				endif
			else
				cCodigo	:= oModelZ07:getValue('Z07_SITUAC')
				cDesc	:= oModelZ07:getValue('Z07_DSCSIT')
			endif
		endif
		
	next _n
	
	oModelSF2:SetValue('F2_XSTNOTA',cCodigo)
	oModelZ03:SetValue('Z03_STNOTA',cCodigo)
	oModelZ03:SetValue('Z03_DSTNOT',cDesc)
	
	FwRestRows(_aSave)
	
	oModelZ03:goLine(_nLinZ03)
	oModelZ07:goLine(_nLinZ07)
	
return _lRet

