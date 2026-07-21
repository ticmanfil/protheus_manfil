#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: MV02002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 24/09/2024
===============================================================================================================================
Descrição---------: Este programa serve para FAZER AS AMARRAÇÕES FORNECEDOR X PRODUTOS
===============================================================================================================================
Uso---------------: COMXCOL - Importador XML
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
user function MV02002()

//	Local oMainWnd
//	Local aCoors := FWGetDialogSize( oMainWnd )
//	Local oPanel, oFWLayer, oBrowse  
	local oBrowse
	local cFiltroTela	:= ' A2_COD == "'+SA2->A2_COD+'" AND A2_LOJA == "'+SA2->A2_LOJA+'" '

//	private oDlgPrinc
	private cCadastro 	:= '[MV02002] - Amarração Fornecedor x Produtos'
	
//	Define MsDialog oDlgPrinc Title cCadastro From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
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
	oBrowse:SetAlias( 'SA2' )
	oBrowse:SetMenuDef( 'MV02002' ) // Define de que fonte vem os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// Exibicao do botao Sair  
	oBrowse:SetFilterDefault(cFiltroTela) //Filtros da rotina
	
	oBrowse:Activate()      
	
//	Activate MsDialog oDlgPrinc Center

return


/*CRIAR MODELO DE DADOS*/
static function ModelDef

	local oModel
	
	/* Carregar a estrutura de dados */
	local oStrSA2	:= FWFormStruct(1,'SA2', { |cCampo| VerCmpP('SA2',cCampo) })
	local oStrSA5	:= FWFormStruct(1,'SA5', { |cCampo| VerCmpP('SA5',cCampo) })
	
	/* Definir propriedades da estrutura de dados */
	Criagat(oStrSA2,oStrSA5)
	SetPropM(oStrSA2,oStrSA5)
	
	/* Definir modelo de dados */
	oModel	:= MPFormModel():New('MV02002_MVC', /*bPreValidacao*/, /*bPosValidacao*/,{|oModel| MV02002GRV(oModel) }/*bCommit*/, /*bCancel*/ )
	
	
	/* editar propriedades do modelo de dados */
	oModel:addFields('FIELD_SA2',,oStrSA2)
	oModel:addGrid('GRID_SA5','FIELD_SA2' ,oStrSA5, , , /*bLinePre*/, {|oModel, nLine, cAction, cField| MV02002LOK(oModel, nLine, cAction, cField)}/*bPreVal*/, /*bPosVal*/,/*BLoad*/ )

	/*Relacao entre as Estrutura*/
	oModel:SetRelation('GRID_SA5',{{'A5_FILIAL','xFilial("SA5")'}, {'A5_FORNECE', 'A2_COD'}, {'A5_LOJA', 'A2_LOJA'}}, SA5->(IndexKey(14)))
	
	oModel:setDescription('[MV02002] - Amarração Fornecedor x Produtos')
	oModel:GetModel('GRID_SA5'):setDescription('[MV02002] - Produtos')
	
	/* Indica que é opcional ter dados nas Grids permitindo salvar a grid vazia*/
	oModel:GetModel( 'GRID_SA5' ):SetOptional(.F.)

	/*Definicao da Chave Primaria*/
	oModel:SetPrimaryKey({'A2_FILIAL', 'A2_COD', 'A2_LOJA'})
	
return oModel


/*CRIAR VIEWDEF DO MODELO DE DADOS*/
static function ViewDef()

	/*Importar modelo de dados */
	local oModel	:= FWLoadModel('MV02002')	//nome do fonte que esta criado a estrutura de dados
	
	/*Cria estrutura de dados da Viewdef*/
	//criar a estrutura de dados da camada de visualização 
	Local oStrSA2 	:= FWFormStruct(2,'SA2', { |cCampo| VerCmpP('SA2',cCampo) })
	local oStrSA5	:= FWFormStruct(2,'SA5', { |cCampo| VerCmpP('SA5',cCampo) })	
	local oView		:= FWFormView():New()
	
	/*Definir propriedades da Viewdef*/
	setPropV(oStrSA2,oStrSA5)		//setar propriedade da estrutura
	//RemoveFld(oStrSF2,oStrZ03,oStrZ07)		//remocao de campos da estrutura
	
	/*Define qual modelo de dados sera utilizado pela View*/
	oView:SetModel(oModel)

	/* Construir ViewDef*/
	oView:AddField('VIEW_SA2', oStrSA2, 'FIELD_SA2' )
	oView:AddGrid('VIEW_SA5', oStrSA5, 'GRID_SA5' )
	
	/*Gerar Box de Visualizacao*/
	oView:CreateHorizontalBox('SUPERIOR', 50)  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateHorizontalBox('INFERIOR', 50)  			// <nome do box>, <%que vai ocupar na tela>
	
	/*Relacionar box com a Estrutura*/
	oView:SetOwnerView('VIEW_SA2', 'SUPERIOR')			//
	oView:SetOwnerView('VIEW_SA5', 'INFERIOR')			//
	
return oView


/*CRIAR MENU DA ROTINA*/
static function MenuDef()

	local aRotina	:= {}
	
//	aadd(aRotina,{'Visualizar'			, 'VIEWDEF.MV05001', 0, 2, 0, nil})
//	aadd(aRotina,{'Incluir'				, 'VIEWDEF.MV05001', 0, 3, 0, nil})
	aadd(aRotina,{'Alterar'				, 'VIEWDEF.MV02002', 0, 4, 0, nil})
//	aadd(aRotina,{'Excluir'				, 'VIEWDEF.MV05001', 0, 5, 0, nil})
	aadd(aRotina,{'Mapa de Producao'	, 'U_RD05006()', 0, 8, 0, nil})
	aadd(aRotina,{'Acerta Peso'			, 'U_RD05011(.T.)', 0, 8, 0, nil})
	aadd(aRotina,{'Imprimir'			, 'VIEWDEF.MV02002', 0, 8, 0, nil})
	
return aRotina


/*Remove campos da estrutura*/
static function RemoveFld(oStrSA2,oStrSA5)

	u_msgInformation('RemovFld')
//	oStrSF2:RemoveField('SF2_CLIENT')

return

/*Seta propriedades da estrutura de dados*/
static function SetPropM(oStrSA2,oStrSA5)

	oStrSA5:SetProperty('A5_PRODUTO', MODEL_FIELD_VALID, {||_validadata()})

	oStrSA5:setProperty('*'	,MODEL_FIELD_WHEN,{||.T.})
//	oStrSA5:setProperty('A5_CODPRF'	,MODEL_FIELD_WHEN,{||.F.})
//	oStrSA5:setProperty('A5_PRODUTO',MODEL_FIELD_WHEN,{||.T.})
//	oStrSA5:setProperty('A5_NOMPROD',MODEL_FIELD_WHEN,{||.F.})

return

static function setPropV(oStrSA2,oStrSA5)
	
	oStrSA2:setProperty('*', MVC_VIEW_CANCHANGE, .F. )

	oStrSA5:setProperty('*', MVC_VIEW_CANCHANGE, .T. )

//	oStrSA5:setProperty('A5_CODPRF' , MVC_VIEW_CANCHANGE, {||.F.} )
//	oStrSA5:setProperty('A5_PRODUTO', MVC_VIEW_CANCHANGE, {||.T.} )
//	oStrSA5:setProperty('A5_NOMPROD', MVC_VIEW_CANCHANGE, {||.F.} )

	oStrSA5:setProperty('A5_CODPRF'	,MVC_VIEW_ORDEM,'01')
	oStrSA5:setProperty('A5_PRODUTO',MVC_VIEW_ORDEM,'02')
	oStrSA5:setProperty('A5_NOMPROD',MVC_VIEW_ORDEM,'03')

return

/*Funcaopara validar data */
static function _validadata()

	local _lRet		:= .T.
	local oModel	:= FWModelActive()
	//local oView		:= FWViewActive()
	local oModelSA5	:= oModel:GetModel('GRID_SA5')
	
	local cCodProd	:= oModelSA5:getValue('A5_PRODUTO')	//&(readvar())

	u_msgInformation('Passei pela funcao _validadata '+cCodProd)
	
return _lRet


/*Nao permite deletar linhas na alteracao*/
static function COMP023LPRE(oModelGrid, nLinha, cAcao, cCampo)

	local lRet			:= .T.
	local oModel		:= oModelGrid:getModel()
	local oModelSA5		:= oModel:getModel('GRID_SA5')
	//local nOperation	:= oModel:getOperation()
	
	local 	cCodProd	as char

	cCodProd	:= oModelSA5:getValue('A5_PRODUTO')

return lRet

static function CriaGat(oStrSA2,oStrSA5) 

	Local _aGatillho := {}
	Local _iGat
	
	/* Gatilhos Z03*/
	_aGatillho := {}
//	aAdd(_aGatillho	,FwStruTrigger('Z03_STNOTA' 	,'Z03_DSTNOT' ,'Z04->Z04_STATUS',.T.,'Z04',1 ,'xFilial("Z04")+M->Z03_STNOTA'))
//	aAdd(_aGatillho	,FwStruTrigger('Z03_STOCOR' 	,'Z03_DSTOCO' ,'Z05->Z05_STATUS',.T.,'Z05',1 ,'xFilial("Z05")+M->Z03_STOCOR'))
//	aAdd(_aGatillho	,FwStruTrigger('Z03_MOTORI' 	,'Z03_NOMMOT' ,'DA4->DA4_NREDUZ',.T.,'DA4',1 ,'xFilial("DA4")+M->Z03_MOTORI'))
	
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
Static Function VerCmpP(cTab, cCampo , cTipo)

	Local 	_lRet		as logical,;
			_cCampos	as char

	_lRet:= .F.

	if cTab == 'SA2'
		_cCampos:= 'A2_COD|A2_LOJA|A2_NOME'

	elseif cTab == 'SA5'
		_cCampos:= 'A5_CODPRF|A5_PRODUTO|A5_NOMPROD|A5_REFGRD'

	endif

	If Alltrim(cCampo) $ _cCampos
		_lRet := .T.
	EndIf

Return _lRet  


static function FClass(oModelGrid, nLine, cAction, cField)

	local _lRet	:= .T.
	
	local oModel	:= oModelGrid:getModel()
	//local oModelSA2	:= oModel:getModel('FIELD_SA2')
	local oModelSA5	:= oModel:getModel('GRID_SA5')
	
	local _nLinSA5	:= oModelSA5:NLINE
	
	local _aSave	:= FwSaveRows()
	
	local cCodigo	:= ''
	
	local cCodAnt	:= ''

	local _n
	
	for _n:= 1 to oModelSA5:Length()
		oModelSA5:Goline(_n)

		if !oModelSA5:IsDeleted()
			if (_n == _nLinSA5) 
				if !(cAction	== 'DELETE')
					cCodigo	:= oModelSA5:getValue('A5_PRODUTO')
					cDesc	:= oModelSA5:getValue('A5_NOMPROD')
				endif
			else
				cCodigo	:= oModelSA5:getValue('A5_PRODUTO')
				cDesc	:= oModelSA5:getValue('A5_NOMPROD')
			endif
		endif
		
		cCodAnt	:= cCodigo
		
	next _n
	
	FwRestRows(_aSave)
	
	oModelSA5:goLine(_nLinSA5)

return _lRet

/*Ponte de Entrada MV05001LOK*/
static function MV02002LOK(oModelGrid, nLine, cAction, cField)
	local _lRet	:= .T.

	_lRet	:= FClass(oModelGrid, nLine, cAction, cField)
	
	u_msgErro('Estou passando pelo MV02002LOK')

return _lRet

static function MV02002LPRE(oModelGrid, nLine, cAction, cField)
	local _lRet	:= .T.

	_lRet	:= FClass(oModelGrid, nLine, cAction, cField)

	u_msgErro('Estou passando pelo MV02002LPRE')

return _lRet

static function MV02002GRV(oModel)
	local lRet

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
	endif

return lRet

static function FValidaSit(oModel)
	local	lRet	:= .T.
	
	u_msgErro('Estou passando pelo FValidaSit')

return lRet
