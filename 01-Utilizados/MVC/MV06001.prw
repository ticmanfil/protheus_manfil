#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: MV06001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 28/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para CONCILIAR VENDAS CARTAO REDE
===============================================================================================================================
Uso---------------: SIGAFIN
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: ADMINISTRATIVO FINANCEIRO
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
user function MV06001()

	local oBrowse
	local cFiltroTela	:= ''	//'1=1'

	private	cPerg		:= 'MV06001'
	
/*	private	cTipo		:= '',;
			cArq		:= '',;
			cDtIni		:= DDATABASE,;
			cDtFin		:= DDATABASE,;
			cBanco		:= '',;
			cAgencia	:= '',;
			cConta		:= ''

*/	private cCadastro 	:= '[MV06001] - Conciliação Recebimento de Cartão'
	
	/* FWmBrowse */
	oBrowse:= FWmBrowse():New()
	oBrowse:SetDescription( cCadastro )
	oBrowse:DisableDetails()
	oBrowse:SetAlias( 'Z15' )
	oBrowse:SetMenuDef( 'MV06001' ) // Define de que fonte vem os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// Exibicao do botao Sair  
	oBrowse:SetFilterDefault(cFiltroTela) //Filtros da rotina
//	oBrowse:SetOnlyFields( { 'ZF0_TIPO' , 'ZF0_ANO' , 'ZF0_PERIOD' , 'ZF0_DATADE', 'ZF0_DATAAT' } )
 	//oBrowse:addButton('Mapa da Produção', u_RD39001(), nil, 8, nil, [ lNeedFind], [ nRealOpc], [ cOperatId], [ cToolBar])
	
	/* Legendas */ 
	oBrowse:AddLegend( "Z15_STATUS == '1' "	, "BR_BRANCO"		, "01 - A Conciliar",,.F. )
	oBrowse:AddLegend( "Z15_STATUS == '2' "	, "BR_VERDE"		, "02 - Conciliado",,.F. )
	oBrowse:AddLegend( "Z15_STATUS == '3' "	, "BR_AZUL"			, "03 - Parcialmente Conciliado",,.F. )
	oBrowse:AddLegend( "Z15_STATUS == '4' "	, "BR_PRETO"		, "04 - Transf. ITAU",,.F. )

	oBrowse:Activate()      
	
return


/*CRIAR MODELO DE DADOS*/
static function ModelDef

	local oModel
	
	/* Carregar a estrutura de dados */
	local oStrZ15	:= FWFormStruct(1,'Z15', { |cCampo| VerCampo1(cCampo) })
	local oStrZ16	:= FWFormStruct(1,'Z16')	//, { |cCampo| VerCampo2(cCampo) })
	local oStrSE5	:= FWFormStruct(1,'SE5', { |cCampo| VerCampo3(cCampo) })
	local oStrZ15R	:= FWFormStruct(1,'Z15', { |cCampo| VerCampo4(cCampo) })
	local oStrZ15M	:= FWFormStruct(1,'Z15', { |cCampo| VerCampo5(cCampo) })
	
	/* Montar Consulta da SE1 */
//	local bLoad	:= {|oModelGrid, lCopy| TT001(oModelGrid, lCopy)}
	
	/* Definir propriedades da estrutura de dados */
	addFieldM(oStrZ15, oStrZ16, oStrSE5)
	//Criagat(oStrZ15, oStrZ16, oStrSE5)
//	SetPropM(oStrZ15, oStrZ16, oStrSE5)
	
	/* Definir modelo de dados */
//	oModel	:= MPFormModel():New('MV06001_MVC', /*bPreValidacao*/, /*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )
	oModel	:= MPFormModel():New('MV06001_MVC', /*bPreValidacao*/, /*bPosValidacao*/,{|oModel| MV06001GRV(oModel) }/*bCommit*/, /*bCancel*/ )
	
	
	/* editar propriedades do modelo de dados */
	oModel:addFields('FIELD_Z15',,oStrZ15)
	oModel:addGrid('GRID_Z16','FIELD_Z15' ,oStrZ16, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:addGrid('GRID_SE5','FIELD_Z15' ,oStrSE5, , /*bLinePre*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
//	oModel:addGrid('GRID_SE5','FIELD_Z15' ,oStrSE5, , /*bLinePre*/,{|oModel, nLine, cAction, cField| MV06001LOK(oModel, nLine, cAction, cField)}/*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:addFields('FIELD_Z15R','FIELD_Z15',oStrZ15R)
	oModel:addFields('FIELD_Z15M','FIELD_Z15',oStrZ15M)

	/*Relacao entre as Estrutura*/
	oModel:SetRelation('GRID_Z16',{{'Z16_FILIAL','xFilial("Z16")'}, {'Z16_IDCONC', 'Z15_IDCONC'}}, Z16->(IndexKey(1)))
	oModel:SetRelation('GRID_SE5',{{'E5_FILIAL','xFilial("SE5")'}, {'E5_BANCO', 'Z15_BANCO'}, {'E5_AGENCIA', 'Z15_AGENCI'}, {'E5_CONTA', 'Z15_CONTA'}}, SE5->(IndexKey(10)))
	oModel:SetRelation('FIELD_Z15R',{{'Z15_FILIAL','xFilial("Z15")'}, {'Z15_IDCONC', 'Z15_IDCONC'}}, Z15->(IndexKey(1)))
	oModel:SetRelation('FIELD_Z15M',{{'Z15_FILIAL','xFilial("Z15")'}, {'Z15_IDCONC', 'Z15_IDCONC'}}, Z15->(IndexKey(1)))
	
	oModel:setDescription('[MV06001] - Conciliação Recebimento de Cartão')
	oModel:GetModel('GRID_Z16'):setDescription('Financeira')
	oModel:GetModel('GRID_SE5'):setDescription('Manfil')
	oModel:GetModel('FIELD_Z15R'):setDescription('Totais')
	oModel:GetModel('FIELD_Z15M'):setDescription('Totais Conciliados')
	
	/*Liga o controle de não repetição de linha*/
	//oModel:GetModel('GRID_Z14'):setUniqueLine({'Z03_ITEM'})
	//oModel:GetModel('GRID_SE1'):setUniqueLine({'Z07_ITEMST'})
	
	/* Valida propriedades de Insert, Update e Delete de Linhas na Grid*/
	oModel:GetModel( 'GRID_SE5' ):SetNoInsertLine()
	//oModel:GetModel( 'GRID_SE1' ):SetNoUpdateLine()
	oModel:GetModel( 'GRID_SE5' ):SetNoDeleteLine()
	
	/* Seta quantidade máxima de linhas na Grid */
	//oModel:GetModel( 'GRID_ZAB' ):SetMaxLine(3)

	/* Indica que é opcional ter dados nas Grids permitindo salvar a grid vazia*/
	oModel:GetModel( 'GRID_Z16' ):SetOptional(.F.)
	oModel:GetModel( 'GRID_SE5' ):SetOptional(.T.)

	/* Define que o modelo de dados não será gravado, apenas usado para consulta */
//	oModel:GetModel("FIELD_SF2"):SetOnlyQuery(.T.)

	/*Definicao da Chave Primaria*/
//	oModel:SetPrimaryKey({})
	oModel:SetPrimaryKey({'Z15_FILIAL', 'Z15_IDCONC'})

	/*Define um filtro adicional*/
//	oModel:GetModel('GRID_SE5'):SetLoadFilter(," ((E5_TIPODOC = '' and E5_TIPO = '' ) OR E5_TIPODOC IN ('VL','RA')) AND E5_DTCANBX = '' AND E5_RECPAG = 'R' AND (E5_XIDCONC = '"+Z15_IDCONC+"' OR E5_XIDCONC = '') AND E5_VENCTO <= '"+dtos(DDATABASE)+"'")
	oModel:GetModel('GRID_SE5'):SetLoadFilter(," E5_TIPODOC IN ('VL','RA') AND E5_DTCANBX = '' AND E5_RECPAG = 'R' AND (E5_XIDCONC = '"+Z15_IDCONC+"' OR E5_XIDCONC = '') AND E5_VENCTO <= '"+dtos(DDATABASE)+"' AND E5_RECONC = 'x'")
return oModel


/*CRIAR VIEWDEF DO MODELO DE DADOS*/
static function ViewDef()

	/*Importar modelo de dados */
	local oModel	:= FWLoadModel('MV06001')	//nome do fonte que esta criado a estrutura de dados
	
	/*Cria estrutura de dados da Viewdef*/
	local oStrZ15	:= FWFormStruct(2,'Z15', { |cCampo| VerCampo1(cCampo) })
	local oStrZ16	:= FWFormStruct(2,'Z16')	//, { |cCampo| VerCampo2(cCampo) })
	local oStrSE5	:= FWFormStruct(2,'SE5', { |cCampo| VerCampo3(cCampo) })
	local oStrZ15R	:= FWFormStruct(2,'Z15', { |cCampo| VerCampo4(cCampo) })
	local oStrZ15M	:= FWFormStruct(2,'Z15', { |cCampo| VerCampo5(cCampo) })
	local oView		:= FWFormView():New()
	
	/*Definir propriedades da Viewdef*/
	addFieldV(oStrZ15, oStrZ16, oStrSE5, oStrZ15R, oStrZ15M)	//adiciona campos virtuais
	setPropV(oStrZ15, oStrZ16, oStrSE5, oStrZ15R, oStrZ15M)		//setar propriedade da estrutura
	RemoveFld(oStrZ15, oStrZ16, oStrSE5, oStrZ15R, oStrZ15M)	//remocao de campos da estrutura
	
	/*Define qual modelo de dados sera utilizado pela View*/
	oView:SetModel(oModel)

	/* Construir ViewDef*/
	oView:AddField('VIEW_Z15', oStrZ15, 'FIELD_Z15' )
	oView:AddGrid('VIEW_Z16', oStrZ16, 'GRID_Z16' )
	oView:AddGrid('VIEW_SE5', oStrSE5, 'GRID_SE5' )
	oView:AddField('VIEW_Z15R', oStrZ15R, 'FIELD_Z15R' )
	oView:AddField('VIEW_Z15M', oStrZ15M, 'FIELD_Z15M' )

	/* Define os filtros para o grid */
	oView:SetViewProperty('VIEW_Z16', "ENABLENEWGRID") 					//Define que o grid deve usar como interface visual o browse (FWBrowse)
	oView:SetViewProperty('VIEW_Z16', "GRIDFILTER"		, {.T.})  		//Habilita Filtro no Grid
	oView:SetViewProperty('VIEW_Z16', "GRIDSEEK"		, {.T.})   		//Habilita Localizar no Grid

	oView:SetViewProperty('VIEW_SE5', "ENABLENEWGRID") 					//Define que o grid deve usar como interface visual o browse (FWBrowse)
	oView:SetViewProperty('VIEW_SE5', "GRIDFILTER"		, {.T.})  		//Habilita Filtro no Grid
	oView:SetViewProperty('VIEW_SE5', "GRIDSEEK"		, {.T.})   		//Habilita Localizar no Grid
	oView:SetViewProperty('VIEW_SE5', "GRIDDOUBLECLICK"	, {{|oFormulario,cFieldName,nLineGrid,nLineModel| iif(Alltrim(cFieldName) == "E5_LEGEND",TT002(),iif(alltrim(cFieldName) == 'E5_DATA', TT003(),.T.))}})	//Qdo der double click
	//oView:SetViewProperty('VIEW_SE5', "GRIDDOUBLECLICK"	, {{|oFormulario,cFieldName,nLineGrid,nLineModel| iif(Alltrim(cFieldName) == "E5_LEGEND",TT002(),.T.)}})	//Qdo der double click

	/*Mostrar Titulo dos Componentes*/
	oView:EnableTitleView('VIEW_Z16')
	oView:EnableTitleView('VIEW_SE5')
	oView:EnableTitleView('VIEW_Z15R')
	oView:EnableTitleView('VIEW_Z15M')
	
	/*Incluir BOTOES customizados*/
	//oView:addUserButton('Pagar Taxa', 'CLIPS', {|oView| FPagar(1)})
//	oView:addUserButton('Transferência', 'CLIPS', {|oView| FPagar(5)})
	
	/*Gerar Box de Visualizacao*/
	oView:CreateHorizontalBox('SUPERIOR', 25)  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateHorizontalBox('MEIO', 55)  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateHorizontalBox('INFERIOR', 20)  			// <nome do box>, <%que vai ocupar na tela>
	
	oView:CreateVerticalBox('ESQUERDO', 50, 'MEIO')  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateVerticalBox('DIREITO', 50, 'MEIO')  			// <nome do box>, <%que vai ocupar na tela>
	
	oView:CreateVerticalBox('INFESQ', 50, 'INFERIOR')  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateVerticalBox('INFDIR', 50, 'INFERIOR')  			// <nome do box>, <%que vai ocupar na tela>

	/*Relacionar box com a Estrutura*/
	oView:SetOwnerView('VIEW_Z15', 'SUPERIOR')			//
	oView:SetOwnerView('VIEW_Z16', 'ESQUERDO')			//
	oView:SetOwnerView('VIEW_SE5', 'DIREITO')			//
	oView:SetOwnerView('VIEW_Z15R', 'INFESQ')			//
	oView:SetOwnerView('VIEW_Z15M', 'INFDIR')			//
	
return oView


/*CRIAR MENU DA ROTINA*/
static function MenuDef()

	local aRotina	:= {}
	
	aadd(aRotina,{'Visualizar'				, 'VIEWDEF.MV06001', 0, 2, 0, nil})
//	aadd(aRotina,{'Incluir'					, 'VIEWDEF.MV06001', 0, 3, 0, nil})
	aadd(aRotina,{'Alterar'					, 'VIEWDEF.MV06001', 0, 4, 0, nil})
//	aadd(aRotina,{'Excluir'					, 'VIEWDEF.MV06001', 0, 5, 0, nil})
//	aadd(aRotina,{'Imprimir'				, 'VIEWDEF.MV06001', 0, 8, 0, nil})
	aadd(aRotina,{'Tx Vendas'				, 'U_MV06001B(1)', 0, 8, 0, nil})	
	aadd(aRotina,{'Imp.Arquivo'				, 'U_RD06008(cPerg)', 0, 8, 0, nil})
	aadd(aRotina,{'Transferência'			, 'U_MV06001B(5)', 0, 8, 0, nil})	
	aadd(aRotina,{'Estorna Transferência'	, 'U_MV06001B(6)', 0, 8, 0, nil})	
	aadd(aRotina,{'Resumo'				, 'U_RD06009', 0, 8, 0, nil})	
	aadd(aRotina,{'Extrato Bancario'	, 'FINR470', 0, 8, 0, nil})	
	aadd(aRotina,{'Excluir Conciliacao'	, 'U_MV06001A', 0, 8, 0, nil})	
	
return aRotina


/*Remove campos da estrutura*/
static function RemoveFld(oStrZ15, oStrZ16, oStrSE5, oStrZ15R, oStrZ15M)

	oStrZ15:removeField('Z15_VLLIQ')
	
	oStrZ15R:RemoveField('Z15_QTVENA')
	oStrZ15R:RemoveField('Z15_VLBRUA')
	oStrZ15R:RemoveField('Z15_VLLIQA')

	oStrZ15M:RemoveField('Z15_QTVEN')
	oStrZ15M:RemoveField('Z15_VLBRUT')
	oStrZ15M:RemoveField('Z15_VLLIQ')

return

/*Adiciona campos virtuais*/
static function addFieldM(oStrZ15, oStrZ16, oStrSE5)

	//Z16
	oStrZ16:addField(;
		AllTrim('') , ; 			// [01] C Titulo do campo
		AllTrim('') , ; 			// [02] C ToolTip do campo
		'Z16_LEGEND' , ;            // [03] C identificador (ID) do Field
		'C' , ;                     // [04] C Tipo do campo
		50 , ;                      // [05] N Tamanho do campo
		0 , ;                       // [06] N Decimal do campo
		NIL , ;                     // [07] B Code-block de validação do campo
		NIL , ;                     // [08] B Code-block de validação When do campo
		NIL , ;                     // [09] A Lista de valores permitido do campo
		NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
		{ || iif(Z16->Z16_STATUS == '1', "BR_BRANCO",iif(Z16->Z16_STATUS == '2',"BR_VERDE",iif(Z16->Z16_STATUS == '3',"BR_AZUL","BR_PRETO"))) } , ;  		// [11] B Code-block de inicializacao do campo
		NIL , ;                     // [12] L Indica se trata de um campo chave
		NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
		.T. )                       // [14] L Indica se o campo é virtual

	//SE5
	oStrSE5:addField(;
		AllTrim('') , ; 			// [01] C Titulo do campo
		AllTrim('') , ; 			// [02] C ToolTip do campo
		'E5_LEGEND' , ;            // [03] C identificador (ID) do Field
		'C' , ;                     // [04] C Tipo do campo
		50 , ;                      // [05] N Tamanho do campo
		0 , ;                       // [06] N Decimal do campo
		NIL , ;	  					                   	// [07] B Code-block de validação do campo
		{||.F.} , ;                    					// [08] B Code-block de validação When do campo
		NIL , ;                     // [09] A Lista de valores permitido do campo
		NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
		{ || iif(empty(SE5->E5_XIDCONC), "BR_BRANCO","BR_VERDE") } , ;  		// [11] B Code-block de inicializacao do campo
		NIL , ;                     // [12] L Indica se trata de um campo chave
		NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
		.T. )                       // [14] L Indica se o campo é virtual

	oStrSE5:addField(;
		AllTrim('') , ; 			// [01] C Titulo do campo
		AllTrim('') , ; 			// [02] C ToolTip do campo
		'E5_TITULO' , ;            	// [03] C identificador (ID) do Field
		'C' , ;                     // [04] C Tipo do campo
		100 , ;                     // [05] N Tamanho do campo
		0 , ;                       // [06] N Decimal do campo
		NIL , ;	  					// [07] B Code-block de validação do campo
		{||.F.} , ;                 // [08] B Code-block de validação When do campo
		NIL , ;                     // [09] A Lista de valores permitido do campo
		NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
		{ || U_BscTit(SE5->(RecNo())) } , ;// [11] B Code-block de inicializacao do campo
		NIL , ;                     // [12] L Indica se trata de um campo chave
		NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
		.T. )                       // [14] L Indica se o campo é virtual

return

/*Seta propriedades da estrutura de dados*/
static function SetPropM(oStrZ15, oStrZ16, oStrSE5)

	oStrZ15:SetProperty('Z15_DATA'		, MODEL_FIELD_INIT, {|| DDATABASE})

return

static function addFieldV(oStrZ15, oStrZ16, oStrSE5, oStrZ15R, oStrZ15M)

	//Z16
	oStrZ16:AddField( ;            		// Ord. Tipo Desc.
		'Z16_LEGEND'                   	, ;   	// [01]  C   Nome do Campo
		"00"                         	, ;     // [02]  C   Ordem
		AllTrim( ''    )         		, ;     // [03]  C   Titulo do campo
		AllTrim( '' )       			, ;     // [04]  C   Descricao do campo
		{ 'Legenda' } 					, ;     // [05]  A   Array com Help
		'C'                             , ;     // [06]  C   Tipo do campo
		'@BMP'                			, ;     // [07]  C   Picture
		NIL                             , ;     // [08]  B   Bloco de Picture Var
		''                              , ;     // [09]  C   Consulta F3
		.T.                             , ;     // [10]  L   Indica se o campo é alteravel
		NIL                             , ;     // [11]  C   Pasta do campo
		NIL                             , ;     // [12]  C   Agrupamento do campo
		NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
		NIL                             , ;     // [15]  C   Inicializador de Browse
		.T.                             , ;     // [16]  L   Indica se o campo é virtual
		NIL                             , ;     // [17]  C   Picture Variavel
		NIL                             )       // [18]  L   Indica pulo de linha após o campo

	//SE5
	oStrSE5:AddField( ;            		// Ord. Tipo Desc.
		'E5_LEGEND'                   	, ;   	// [01]  C   Nome do Campo
		"00"                         	, ;     // [02]  C   Ordem
		AllTrim( ''    )         		, ;     // [03]  C   Titulo do campo
		AllTrim( '' )       			, ;     // [04]  C   Descricao do campo
		{ 'Legenda' } 					, ;     // [05]  A   Array com Help
		'C'                             , ;     // [06]  C   Tipo do campo
		'@BMP'                			, ;     // [07]  C   Picture
		NIL                             , ;     // [08]  B   Bloco de Picture Var
		''                              , ;     // [09]  C   Consulta F3
		.T.                             , ;     // [10]  L   Indica se o campo é alteravel
		NIL                             , ;     // [11]  C   Pasta do campo
		NIL                             , ;     // [12]  C   Agrupamento do campo
		NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
		NIL                             , ;     // [15]  C   Inicializador de Browse
		.T.                             , ;     // [16]  L   Indica se o campo é virtual
		NIL                             , ;     // [17]  C   Picture Variavel
		NIL                             )       // [18]  L   Indica pulo de linha após o campo

	oStrSE5:AddField( ;            		// Ord. Tipo Desc.
		'E5_TITULO'                   	, ;   	// [01]  C   Nome do Campo
		"00"                         	, ;     // [02]  C   Ordem
		AllTrim( 'Titulo')         		, ;     // [03]  C   Titulo do campo
		AllTrim( 'Titulo' )       		, ;     // [04]  C   Descricao do campo
		{ 'Titulo' } 					, ;     // [05]  A   Array com Help
		'C'                             , ;     // [06]  C   Tipo do campo
		''                				, ;     // [07]  C   Picture
		NIL                             , ;     // [08]  B   Bloco de Picture Var
		''                              , ;     // [09]  C   Consulta F3
		.T.                             , ;     // [10]  L   Indica se o campo é alteravel
		NIL                             , ;     // [11]  C   Pasta do campo
		NIL                             , ;     // [12]  C   Agrupamento do campo
		NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
		NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
		NIL                             , ;     // [15]  C   Inicializador de Browse
		.T.                             , ;     // [16]  L   Indica se o campo é virtual
		NIL                             , ;     // [17]  C   Picture Variavel
		NIL                             )       // [18]  L   Indica pulo de linha após o campo

return

static function setPropV(oStrZ15, oStrZ16, oStrSE5, oStrZ15R, oStrZ15M)

	//Z15
	oStrZ15:setProperty('Z15_DATA'		, MVC_VIEW_CANCHANGE, .F. )
	oStrZ15:setProperty('Z15_STATUS'	, MVC_VIEW_CANCHANGE, .F. )
	oStrZ15:setProperty('Z15_BANCO'		, MVC_VIEW_CANCHANGE, .F. )
//	oStrZ15:setProperty('Z15_VLTX'		, MVC_VIEW_CANCHANGE, "Z15_STATUS $ '|1|2|'")
//	oStrZ15:setProperty('Z15_TXOUT'		, MVC_VIEW_CANCHANGE, "Z15_STATUS $ '|1|2|'")

	//Z16
	//oStrZ16:setProperty('*', MVC_VIEW_CANCHANGE, .F. )
	oStrZ16:setProperty('Z16_LEGEND'	,MVC_VIEW_ORDEM,	'01')
	oStrZ16:setProperty('Z16_NSUCV'		,MVC_VIEW_ORDEM,	'02')
	oStrZ16:setProperty('Z16_DTVEN'		,MVC_VIEW_ORDEM,	'03')
	oStrZ16:setProperty('Z16_DTREC'		,MVC_VIEW_ORDEM,	'04')
	oStrZ16:setProperty('Z16_VLBRU'		,MVC_VIEW_ORDEM,	'05')
	oStrZ16:setProperty('Z16_VLLIQ'		,MVC_VIEW_ORDEM,	'06')
	oStrZ16:setProperty('Z16_VLMDRD'	,MVC_VIEW_ORDEM,	'07')
	oStrZ16:setProperty('Z16_NUMCAR'	,MVC_VIEW_ORDEM,	'08')
	oStrZ16:setProperty('Z16_MODALI'	,MVC_VIEW_ORDEM,	'09')
	oStrZ16:setProperty('Z16_BANDEI'	,MVC_VIEW_ORDEM,	'10')
	oStrZ16:setProperty('Z16_STATUS'	,MVC_VIEW_ORDEM,	'11')
	oStrZ16:setProperty('Z16_IDCONC'	,MVC_VIEW_ORDEM,	'12')


	//SE5
	//oStrSE5:setProperty('*', MVC_VIEW_CANCHANGE, .F. )
	oStrSE5:setProperty('E5_LEGEND'		,MVC_VIEW_ORDEM,	'01')
	oStrSE5:setProperty('E5_DOCUMEN'	,MVC_VIEW_ORDEM,	'02')
	oStrSE5:setProperty('E5_DATA'		,MVC_VIEW_ORDEM,	'03')
	oStrSE5:setProperty('E5_VENCTO'		,MVC_VIEW_ORDEM,	'04')
	oStrSE5:setProperty('E5_VALOR'		,MVC_VIEW_ORDEM,	'05')
	oStrSE5:setProperty('E5_TITULO'		,MVC_VIEW_ORDEM,	'06')
	//oStrSE5:setProperty('E5_NUMERO'		,MVC_VIEW_ORDEM,	'06')
	//oStrSE5:setProperty('E5_PREFIXO'	,MVC_VIEW_ORDEM,	'07')
	//oStrSE5:setProperty('E5_PARCELA'	,MVC_VIEW_ORDEM,	'08')
	//oStrSE5:setProperty('E5_TIPO'		,MVC_VIEW_ORDEM,	'09')
	oStrSE5:setProperty('E5_XIDCONC'	,MVC_VIEW_ORDEM,	'10')
	oStrSE5:setProperty('E5_XDTCONC'	,MVC_VIEW_ORDEM,	'11')
	oStrSE5:setProperty('E5_BANCO'		,MVC_VIEW_ORDEM,	'12')
	oStrSE5:setProperty('E5_AGENCIA'	,MVC_VIEW_ORDEM,	'13')
	oStrSE5:setProperty('E5_CONTA'		,MVC_VIEW_ORDEM,	'14')

	oStrSE5:setProperty('E5_DOCUMEN'	,MVC_VIEW_TITULO,	'NSU/CV')
	oStrSE5:setProperty('E5_DATA'		,MVC_VIEW_TITULO,	'Dt Venda')

	//Z15R
	oStrZ15R:setProperty('*', MVC_VIEW_CANCHANGE, .F. )
//	oStrZ15R:setProperty('Z15_QTDVEN'		,MVC_VIEW_ORDEM,	'01')
//	oStrZ15R:setProperty('Z15_VLBRUT'		,MVC_VIEW_ORDEM,	'02')
//	oStrZ15R:setProperty('Z15_VLLIQ'		,MVC_VIEW_ORDEM,	'03')

	//Z15M
	oStrZ15M:setProperty('*', MVC_VIEW_CANCHANGE, .F. )
//	oStrZ15M:setProperty('Z15_QTDVENA'		,MVC_VIEW_ORDEM,	'01')
//	oStrZ15M:setProperty('Z15_VLBRUA'		,MVC_VIEW_ORDEM,	'02')
//	oStrZ15M:setProperty('Z15_VLLIQA'		,MVC_VIEW_ORDEM,	'03')

return

/*Funcaopara validar data */
static function _validadata()

	local _lRet		:= .T.
	
	local _dData	:= oModelZAB:getValue('ZAB_DATA')	//&(readvar())
	local _dDataAtu	:= DDATABASE

//	local oModel	:= FWModelActive()
//	local oModelZAB	:= oModel:GetModel('GRID_ZAB')
//	local oView		:= FWViewActive()

	if _dData > _dDataAtu
		_lRet	:= .F.
		help(,,'Help',,'Data inválida.', 1, 0)
	endif
		
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


static function CriaGat(oStrZ15, oStrZ16, oStrSE5) 

	Local _aGatillho := {}
	Local _iGat
	
	/* Gatilhos SE1*/
	_aGatillho := {}
	aAdd(_aGatillho	,FwStruTrigger('E1_NSUTEF' 	,'E1_XIDCONC' ,'Z16->Z16_IDCONC',.F.))
	aAdd(_aGatillho	,FwStruTrigger('E1_NSUTEF' 	,'E1_XDTCONC' ,'DDATABASE',.F.))
	
	For _iGat := 1 to Len(_aGatillho)
		oStrSE5:AddTrigger( _aGatillho[_iGat][1], _aGatillho[_iGat][2], _aGatillho[_iGat][3], _aGatillho[_iGat][4] )
	Next _iGat
	
//	/* Gatilhos Z07*/
//	_aGatillho := {}
//	aAdd(_aGatillho	,FwStruTrigger('Z07_SITUAC', 'Z07_DSCSIT', 'Z04->Z04_STATUS',.T.,'Z04',1 ,'xFilial("Z04")+M->Z07_SITUAC'))
	
//	For _iGat := 1 to Len(_aGatillho)
//		oStrZ07:AddTrigger( _aGatillho[_iGat][1], _aGatillho[_iGat][2], _aGatillho[_iGat][3], _aGatillho[_iGat][4] )
//	Next _iGat

return


/*Mostrar Campos em Tela */
static function VerCampo1( cCampo , cTipo)

	Local _lRet		:= .F.
	Local _cCampos	:= 'Z15_FILIAL|Z15_IDCONC|Z15_DATA|Z15_TP|Z15_STATUS|Z15_BANCO|Z15_AGENCI|Z15_CONTA|Z15_VLTX|Z15_TXOUT|Z15_VLCANC'

	If Alltrim(cCampo) $ _cCampos
		_lRet := .T.
	EndIf

return _lRet  

static function VerCampo3( pCampo , cTipo)

	local 	lRet	as logical,;
			cCampos	as string
//	Local _cCampos	:= 'E5_DOCUMEN|E5_DATA|E5_VENCTO|E5_VALOR|E5_XIDCONC|E5_XDTCONC|E5_PREFIXO|E5_NUMERO|E5_PARCELA|E5_TIPO|E5_BANCO|E5_AGENCIA|E5_CONTA'
	
	lRet:= .F.
	cCampos:= 'E5_DOCUMEN|E5_DATA|E5_VENCTO|E5_VALOR|E5_XIDCONC|E5_XDTCONC|E5_BANCO|E5_AGENCIA|E5_CONTA'

	if Alltrim(pCampo) $ cCampos
		lRet := .T.
	endif

return lRet 

static function VerCampo4( cCampo , cTipo)

	Local _lRet		:= .F.
	Local _cCampos	:= 'Z15_QTVEN|Z15_VLBRUT|Z15_VLLIQ|Z15_QTVENA|Z15_VLBRUA|Z15_VLLIQA|'

	If Alltrim(cCampo) $ _cCampos
		_lRet := .T.
	EndIf

return _lRet  

static function VerCampo5( cCampo , cTipo)

	Local _lRet		:= .F.
	Local _cCampos	:= 'Z15_QTVEN|Z15_VLBRUT|Z15_VLLIQ|Z15_QTVENA|Z15_VLBRUA|Z15_VLLIQA|'

	If Alltrim(cCampo) $ _cCampos
		_lRet := .T.
	EndIf

return _lRet  

/*Botao customizado*/
static function XVALID(cBanco, cAgenc, cConta)
	local	lRet	as logical

	cBanco:= SA6->A6_COD
	cAgenc:= SA6->A6_AGENCIA
	cConta:= SA6->A6_NUMCON

	lRet:= .T.

return lRet

user function MV06001B(nOpc)

	/*
		1 - PAGAR
		2 - RECEBER
		3 - EXCLUIR
		4 - CANCELAR
		5 - TRANSF.
		6 - EST. TRANSF
	*/

	//local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	
	//FWExecView('Inclusao por FWExecView','AMVC003', MODEL_OPERATION_INSERT, , { || .T. }, ,15,aButtons )
	
	//Local nOpc     := 0
	
	local	aArea		:= getArea(),;
			aAreaSA6	:= SA6->(getArea())
	
	local	aFINA100	:= {},;
			dData		:= DDATABASE,;
			nValor		:= 0,;
			cNatur		:= '',;
			cBanco		:= 'RED',;
			cAgenc		:= '00001',;
			cConta		:= '0000000001',;
			cBenef		:= '',;
			cHist		:= '',;
			cNaturDes	:= '',;
			cBancoDes	:= '',;
			cAgencDes	:= '',;
			cContaDes	:= '',;
			cNumDoc		:= '',;
			lInc		:= .F.
	
	private lMsErroAuto := .F.
	
	if Z15->Z15_DATA != DDATABASE .and. nOpc != 1
		u_msgErro('Para fazer esse tipo de OPERAÇÃO'+CRLF+'a DATA do SISTEMA tem que ser a mesma'+CRLF+'que a DATA DA APURAÇÃO.','')
		return
	endif
	
	if nOpc == 1

		SetPrvt('oDlg1','oSay1','oSay2','oSay3','oSay4','oSBtnOk','oSBtnCan','oMGet1')
		
		DEFINE MSDIALOG oDlg TITLE '[MV06001]-Incluindo Tx Vendas' From 0,0 TO 250,530 PIXEL
		
		@ 010,004 SAY OemToansi('Banco:') SIZE 052, 008 OF oDlg PIXEL
		@ 010,060 MSGET oGet01 VAR cBanco SIZE 032,008 F3 'SA6' WHEN .F. VALID XVALID(@cBanco, @cAgenc, @cConta) OF oDlg PIXEL

		@ 025,004 SAY OemToAnsi('Agencia:') SIZE 073,008 OF oDlg PIXEL
		@ 025,060 MSGET oGet02 VAR cAgenc SIZE 052,008 WHEN .F. VALID OF oDlg PIXEL
		
		@ 040,004 SAY OemToAnsi('Conta:') SIZE 073,008 OF oDlg PIXEL
		@ 040,060 MSGET oGet03 VAR cConta SIZE 032,008 WHEN .F. OF oDlg PIXEL
		
		@ 055,004 SAY OemToAnsi('Valor:') SIZE 073,008 OF oDlg PIXEL
		@ 055,060 MSGET oGet04 VAR nValor SIZE 052,008 PICTURE '@E 999,999,999.99' OF oDlg PIXEL
		
		DEFINE SBUTTON FROM 100, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
		DEFINE SBUTTON FROM 100, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED	

		if nOpca == '1'

			ProcRegua(1)
			
			incproc('Verificando informações para Pagamento...')

			cNatur	:= '0202010403'
			cNumDoc	:= dtos(dData)+'01'
			cBenef	:= 'CARTAO REDE'
			cHist	:= 'TX VENDAS CARTAO'
		
			aFINA100 := {	{"E5_DATA"		, dData		, Nil},;
							{"E5_MOEDA"		, 'R$'		, Nil},;
							{"E5_VALOR"		, nValor	, Nil},;
							{"E5_NATUREZ"	, cNatur	, Nil},;
							{"E5_BANCO"		, cBanco	, Nil},;
							{"E5_AGENCIA"	, cAgenc	, Nil},;
							{"E5_CONTA"		, cConta	, Nil},;
							{"CDOCTRAN"		, cNumDoc	, Nil},;
							{"E5_BENEF"		, cBenef	, Nil},;
							{"E5_HISTOR"    , cHist		, Nil}}
		
			incproc('Processando pagamento....')

			MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)
		
			if lMsErroAuto
				MostraErro()
			else
				u_msgInforma('Taxa bancário INCLUIDO com sucesso !!!','')
			endif
		endif

	elseif nOpc == 3
		dData		:= Z15->Z15_DATA
		nValor		:= Z15->Z15_VLTX
		cNatur		:= '0202010403'
		cBanco		:= Z15->Z15_BANCO
		cAgenc		:= Z15->Z15_AGENCI
		cConta		:= Z15->Z15_CONTA
		cNumDoc		:= dtos(Z15->Z15_DATA)+'01'

		ProcRegua(1)
		
		incproc('Verificando informações para Pagamento...')

		dbSelectArea('SE5')
		SE5->(dbSetOrder(6))
		SE5->(dbSeek(xFilial('SE5')+dtos(dData)+cNatur ))
		aFINA100 := {	{"E5_DATA"		, SE5->E5_DATA		, Nil},;
						{"E5_MOEDA"		, SE5->E5_MOEDA		, Nil},;
						{"E5_VALOR"		, SE5->E5_VALOR		, Nil},;
						{"E5_NATUREZ"	, SE5->E5_NATUREZ	, Nil},;
						{"E5_BANCO"		, SE5->E5_BANCO		, Nil},;
						{"E5_AGENCIA"	, SE5->E5_AGENCIA	, Nil},;
						{"E5_CONTA"		, SE5->E5_CONTA		, Nil},;
	    				{"CDOCTRAN"		, SE5->E5_DOCUMEN	, Nil},;
						{"E5_HISTOR"	, SE5->E5_HISTOR	, Nil},;
						{"E5_TIPOLAN"	, SE5->E5_TIPOLAN	, Nil} }
		
		incproc('Processando EXCLUSÃO do lançamento....')

		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,5)
		
		if lMsErroAuto
		    MostraErro()
		else
		    u_msgInforma('Taxa bancário EXCLUIDO com sucesso !!!','')
		endif       

	elseif nOpc == 4
		dData		:= Z15->Z15_DATA
		nValor		:= Z15->Z15_VLTX
		cNatur		:= '0202010403'
		cBanco		:= Z15->Z15_BANCO
		cAgenc		:= Z15->Z15_AGENCI
		cConta		:= Z15->Z15_CONTA
		cNumDoc		:= dtos(Z15->Z15_DATA)+'01'

		ProcRegua(1)
		
		incproc('Verificando informações para Pagamento...')

		dbSelectArea('SE5')
		SE5->(dbSetOrder(6))
		SE5->(dbSeek(xFilial('SE5')+dtos(dData)+cNatur ))
		aFINA100 := {	{"E5_DATA"		, SE5->E5_DATA		, Nil},;
						{"E5_MOEDA"		, SE5->E5_MOEDA		, Nil},;
						{"E5_VALOR"		, SE5->E5_VALOR		, Nil},;
						{"E5_NATUREZ"	, SE5->E5_NATUREZ	, Nil},;
						{"E5_BANCO"		, SE5->E5_BANCO		, Nil},;
						{"E5_AGENCIA"	, SE5->E5_AGENCIA	, Nil},;
						{"E5_CONTA"		, SE5->E5_CONTA		, Nil},;
	    				{"CDOCTRAN"		, cNumDoc			, Nil},;
						{"E5_HISTOR"	, SE5->E5_HISTOR	, Nil},;
						{"E5_TIPOLAN"	, SE5->E5_TIPOLAN	, Nil} }
		
		incproc('Processando CANCELAMENTO....')

		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,6)
		
		if lMsErroAuto
		    MostraErro()
		else
		    u_msgInforma('Taxa bancário CANCELADO com sucesso !!!','')
		endif       

	elseif nOpc == 5

		//verificar se tem taxa e fazer um lancamento de +pagar
		if Z15->Z15_TXOUT > 0
			cNatur	:= '0202010403'
			cNumDoc	:= dtos(dData)+'03'
			cBenef	:= 'CARTAO REDE'
			cHist	:= 'ALUGUEL DAS MAQUININHAS'
			nValor	:= Z15->Z15_TXOUT
		
			aFINA100 := {	{"E5_DATA"		, dData		, Nil},;
							{"E5_MOEDA"		, 'R$'		, Nil},;
							{"E5_VALOR"		, nValor	, Nil},;
							{"E5_NATUREZ"	, cNatur	, Nil},;
							{"E5_BANCO"		, cBanco	, Nil},;
							{"E5_AGENCIA"	, cAgenc	, Nil},;
							{"E5_CONTA"		, cConta	, Nil},;
							{"CDOCTRAN"		, cNumDoc	, Nil},;
							{"E5_BENEF"		, cBenef	, Nil},;
							{"E5_HISTOR"    , cHist		, Nil}}
		
			incproc('Processando pagamento....')

			MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)
		
			if lMsErroAuto
				MostraErro()
			else
				u_msgInforma('Aluguel das maquininhas INCLUIDO com sucesso !!!','')
				lInc	:= .T.

			endif
		endif

		if Z15->Z15_TXOUT = 0 .OR. lInc

			dData		:= Z15->Z15_DATA
			nValor		:= Z15->Z15_VLLIQ-Z15->Z15_TXOUT-Z15->Z15_VLCANC
			cNatur		:= '02030302  '
			cBanco		:= Z15->Z15_BANCO
			cAgenc		:= Z15->Z15_AGENCI
			cConta		:= Z15->Z15_CONTA
			cNumDoc		:= dtos(Z15->Z15_DATA)+'02'

			cNaturDes	:= '0104005'
			cBancoDes	:= '341'
			cAgencDes	:= '0944'
			cContaDes	:= '009551'

			dbSelectArea('SA6')
			SA6->(dbSetOrder(1))
			SA6->(dbGoTop())
			if SA6->(dbSeek(xFilial('SA6')+cBancoDes+cAgencDes+cContaDes))
				cBenef		:= SA6->A6_NREDUZ 
				cHist		:= 'TRANSF REDE P/ '+SA6->A6_NREDUZ
			endif 

			aFINA100 := {	{"CBCOORIG"		, cBanco			, Nil},;
							{"CAGENORIG"	, cAgenc			, Nil},;
							{"CCTAORIG"		, cConta			, Nil},;
							{"CNATURORI"	, cNatur			, Nil},;
							{"CBCODEST"		, cBancoDes			, Nil},;
							{"CAGENDEST"	, cAgencDes			, Nil},;
							{"CCTADEST"		, cContaDes			, Nil},;
							{"CNATURDES"	, cNaturDes			, Nil},;
							{"CTIPOTRAN"	, 'R$'				, Nil},;
							{"CDOCTRAN"		, cNumDoc			, Nil},;
							{"NVALORTRAN"	, nValor			, Nil},;
							{"CHIST100"		, cHist				, Nil},;
							{"CBENEF100"	, cBenef			, Nil} }

			MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,7)

			if lMsErroAuto
				MostraErro()
			else
				if recLock('Z15',.F.)
					Z15->Z15_STATUS := '4'
					Z15->(msUnlock())
				endif
				
				MsgAlert("Transferência executada com sucesso !!!")
			endif
		endif

	elseif nOpc == 6
		dData		:= Z15->Z15_DATA
		nValor		:= Z15->Z15_VLLIQ-Z15->Z15_TXOUT-Z15->Z15_VLCANC
		cNatur		:= '02030302  '
		cBanco		:= Z15->Z15_BANCO
		cAgenc		:= Z15->Z15_AGENCI
		cConta		:= Z15->Z15_CONTA
		cNumDoc		:= dtos(Z15->Z15_DATA)+'02'

		cNaturDes	:= '0104005   '
		cBancoDes	:= '341'
		cAgencDes	:= '0944 '
		cContaDes	:= '009551    '

		aFINA100 := {{"AUTNRODOC"	,cNumDoc	, Nil},;
					{"AUTDTMOV"		,dData		, Nil},;
					{"AUTBANCO"		,cBanco		, Nil},;
					{"AUTAGENCIA"	,cAgenc		, Nil},;
					{"AUTCONTA"		,cConta		, Nil}}
	            
		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,8)
	
	    if lMsErroAuto
	    	MostraErro()
	    else
			//estornando taxa de aluguel das maquininhas
			if Z15->Z15_TXOUT > 0
				cNatur	:= '0202010403'
				cNumDoc	:= dtos(dData)+'01'
				cBenef	:= 'CARTAO REDE'
				cHist	:= 'ESTORNO ALUGUEL DAS MAQUININHAS'
				nValor	:= Z15->Z15_TXOUT
			
				aFINA100 := {	{"E5_DATA"		, dData		, Nil},;
								{"E5_MOEDA"		, 'R$'		, Nil},;
								{"E5_VALOR"		, nValor	, Nil},;
								{"E5_NATUREZ"	, cNatur	, Nil},;
								{"E5_BANCO"		, cBanco	, Nil},;
								{"E5_AGENCIA"	, cAgenc	, Nil},;
								{"E5_CONTA"		, cConta	, Nil},;
								{"CDOCTRAN"		, cNumDoc	, Nil},;
								{"E5_BENEF"		, cBenef	, Nil},;
								{"E5_HISTOR"    , cHist		, Nil}}
			
				incproc('Processando pagamento....')

				MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)
			
				if lMsErroAuto
					MostraErro()
				else
					u_msgInforma('Estorno do aluguel das maquininhas EXCLUIDO com sucesso !!!','')
				endif
			endif
			if recLock('Z15',.F.)
				Z15->Z15_STATUS := '2'
				Z15->(msUnlock())
			endif
	    	MsgAlert("Transferência cancelada com sucesso !!!")
	    endif
	    
    endif
	
	restArea(aArea)
	restArea(aAreaSA6)

return nil

static function FClass(oModelGrid, nLine, cAction, cField)

	local	_lRet		as logical,;
			oModel		as object,;
			oModelZ16	as object,;
			oModelSE5	as object,;
			_nLinZ16	as numeric,;
			_nLinSE5	as numeric,;
			_aSave		as object
	
	local 	cStatus	as string,;
			cCVNSU	as string,;
			cIDCONC	as string,;
			dDtConc	as date,;
			_n		as numeric

	_lRet	:= .T.

	oModel	:= oModelGrid:getModel()
	oModelZ16	:= oModel:getModel('GRID_Z16')
	oModelSE5	:= oModel:getModel('GRID_SE5')
	
	_nLinZ16	:= oModelZ16:NLINE
	_nLinSE5	:= oModelSE5:NLINE
	
	_aSave	:= FwSaveRows()
	
	cStatus	:= ''
	cCVNSU	:= ''
	cIDCONC	:= ''
	dDtConc	:= DDATABASE
	
	//local oModelZ15	:= oModel:getModel('FIELD_Z15')

	for _n:= 1 to oModelSE5:Length()
		oModelSE5:Goline(_n)
		
		if _n = _nLinSE5
			if oModelZ16:getValue('Z16_STATUS') == '1'
				cStatus	:= '2' // 1-nao conciliado  2-conciliado
				cCVNSU	:= oModelZ16:getValue('Z16_NSUCV')
				cIDCONC	:= oModelZ16:getValue('Z16_IDCONC')
				dDtConc	:= DDATABASE
			
				oModelZ16:SetValue('Z16_STATUS',cStatus)
				oModelSE5:SetValue('E5_DOCUMEN',cCVNSU)
				oModelSE5:SetValue('E5_XIDCONC',cIDCONC)
				oModelSE5:SetValue('E5_XDTCONC',dDtConc)
			endif
				
		endif
		
	next _n

	FwRestRows(_aSave)
	
	oModelZ16:goLine(_nLinZ16)
	oModelSE5:goLine(_nLinSE5)

return _lRet

/*Ponte de Entrada MV06001LOK*/
static function MV06001LOK(oModelGrid, nLine, cAction, cField)
	local _lRet	:= .T.

	//_lRet	:= FClass(oModelGrid, nLine, cAction, cField)
	
return _lRet

static function MV06001LPRE(oModelGrid, nLine, cAction, cField)
	local _lRet	:= .T.

	_lRet	:= FClass(oModelGrid, nLine, cAction, cField)

	/*if oModelZ07:IsInserted() .and. (oModelZ07:getValue('Z07_SITUAC') == '09' .or. oModelZ07:getValue('Z07_SITUAC') == '10' .or. oModelZ07:getValue('Z07_SITUAC') == '11') 
		_lRet	:= .F.
		u_msgErro('Item de entregue já concluido. Favor inserir novo item','[MV06001] - Validacao Cont. Pedido')
		
	endif*/

return _lRet

static function MV06001GRV(oModel)
     local lRet 
      
     /*Aqui podemos chamar funções antes do Commit Padrão.*/ 
     //if FValidaSit(oModel) 
     
     if Z15->Z15_STATUS == '4'
     
     	u_msginforma('Já foi feita a transferencia de valores dessa conciliação e não poderá mais ser alterado.','')
     	return
     endif
      
	     /*Aqui temos a chamada da funcao padrão de gravação do MVC.*/ 	// http://tdn.totvs.com/display/framework/FWFormCommit 
	     lRet := FWFormCommit( oModel /*[ oModel ]*/,; 
	                                  /*[ bBefore ]*/,; 
	                                  /*[ bAfter ]*/,; 
	                                  /*[ bAfterSTTS ]*/,; 
	                                  /*[ bInTTS ]*/,; 
	                                  /*[ bABeforeTTS ]*/,; 
	                                  /*[ bIntegEAI ] */ ) 
	      
	     /* Aqui podemos chamar funções depois do Commit Padrão, verificando sempre se o commit foi realizado. */ 
	     if lRet
	     	//	__FazAlgoDepoisCommit()
	     	if Z15->Z15_VLBRUT = Z15->Z15_VLBRUA
		    	if recLock('Z15',.F.)
		    		Z15->Z15_STATUS := '2'
		    		Z15->(msUnlock())
		    	endif
		    else
		    	if recLock('Z15',.F.)
		    		Z15->Z15_STATUS := '1'
		    		Z15->(msUnlock())
		    	endif
		    endif
     	
	     endif
	     
	 // endif

return lRet


static function FValidaSit()
	local	lRet	:= .T.
	
return lRet


Static Function TT002()

	// Cria a legenda que identifica a estrutura
	oLegend := FWLegend():New()
	
	// Adiciona descrição para cada legenda
	oLegend:Add( { || }, 'BR_BRANCO'	, '01 - A Conciliar' )
	oLegend:Add( { || }, 'BR_VERDE'		, '02 - Conciliado' )
	oLegend:Add( { || }, 'BR_AZUL'		, '03 - Parcialmente Conciliado' )
	oLegend:Add( { || }, 'BR_PRETO'		, '04 - Transf. ITAU' )

	// Ativa a Legenda
	oLegend:Activate()
	
	// Exibe a Tela de Legendas
	oLegend:View()

Return Nil

static function TT003(oFormulario,cFieldName,nLineGrid,nLineModel)

	Local oModel     	:= FWModelActive()
	Local oModelZ15 	:= oModel:GetModel( 'FIELD_Z15' )
	Local oModelZ16 	:= oModel:GetModel( 'GRID_Z16' )
	Local oModelSE5 	:= oModel:GetModel( 'GRID_SE5' )
	Local oModelZ15R 	:= oModel:GetModel( 'FIELD_Z15R' )
	Local oModelZ15M 	:= oModel:GetModel( 'FIELD_Z15M' )
	Local oView			:= FWViewActive()

	local _nLinZ16	:= oModelZ16:NLINE
	local _nLinSE5	:= oModelSE5:NLINE
	
	local _aSave	:= FwSaveRows()
	
	local lRet		:= .F.
	
	if oModelZ15:getValue('Z15_STATUS') == '2'
	
		u_msgErro('Data já conciliada!!!...'+CRLF+'Favor reabri movimento.','')
		return 
	
	endif

	if oModelZ15M:getValue('Z15_VLBRUA') = oModelZ15R:getValue('Z15_VLBRUT')
	
		if u_msgPergunta('Valor Bruto já concilado!'+CRLF+'Deseja continuar?','') = 7
			return
		endif 
	
	endif

	//conciliar
	if alltrim(oModelSE5:getValue('E5_XIDCONC')) = ''

		if oModelSE5:getValue('E5_DOCUMEN')	!= oModelZ16:getValue('Z16_NSUCV')
			if u_msgPergunta('NSU/CV diferente. Deseja CONCILIAR mesmo assim?'+CRLF+'Se continuar o NSU será sobreposto e será considerado CONCILIADO.','') = 6
				lRet	:= .T.
			else
				lRet	:= .F.
				u_msgInforma('Concliação ABORDADO!!','')
			endif
		else
			lRet	:= .T.
		endif
		
		if lRet 
			oModelSE5:setValue('E5_DOCUMEN',oModelZ16:getValue('Z16_NSUCV'))
			oModelSE5:setValue('E5_XIDCONC',oModelZ16:getValue('Z16_IDCONC'))
			oModelSE5:setValue('E5_XDTCONC',DDATABASE)
			//oModelSE5:setValue('E5_LEGEND','2')
			
			//oModelZ16:setValue('Z16_LEGEND','2')
			oModelZ16:setValue('Z16_STATUS','2')
	
			//oModelZ15M:setValue('Z15_QTVENA',oModelZ15M:getValue('Z15_QTVENA')+1)
			oModelZ15M:setValue('Z15_VLBRUA',oModelZ15M:getValue('Z15_VLBRUA')+oModelSE5:getValue('E5_VALOR'))
			//oModelZ15M:setValue('Z15_VLLIQA',oModelZ15M:getValue('Z15_VLLIQA')+oModelZ16:getValue('Z16_VLLIQ'))
			
			if oModelZ15M:getValue('Z15_VLBRUA') = oModelZ15R:getValue('Z15_VLBRUT')
				oModelZ15:getValue('Z15_STATUS') = '2'
			endif
			
		endif
	
	//desconciliar
	else
		
		//oModelSE1:setValue('E1_NSUTEF','')
		oModelSE5:setValue('E5_XIDCONC','')
		oModelSE5:setValue('E5_XDTCONC',stod(''))
		//oModelSE5:setValue('E5_LEGEND','1')
		
		oModelZ16:setValue('Z16_STATUS','1')
		//oModelZ16:setValue('Z16_LEGEND','1')
		
		//oModelZ15M:setValue('Z15_QTVENA',oModelZ15M:getValue('Z15_QTVENA')-1)
		oModelZ15M:setValue('Z15_VLBRUA',oModelZ15M:getValue('Z15_VLBRUA')-oModelSE5:getValue('E5_VALOR'))
		//oModelZ15M:setValue('Z15_VLLIQA',oModelZ15M:getValue('Z15_VLLIQA')-oModelZ16:getValue('Z16_VLLIQ'))

		if oModelZ15M:getValue('Z15_VLBRUA') != oModelZ15R:getValue('Z15_VLBRUT')
			oModelZ15:getValue('Z15_STATUS') = '1'
		endif
		
	endif
	
	oView:refresh('FIELD_Z15M')
	oView:refresh('FIELD_Z15R')
	oView:refresh('GRID_SE5')
	oView:refresh('GRID_Z16')
	oView:refresh('FIELD_Z15')

	FwRestRows(_aSave)
	
	oModelZ16:goLine(_nLinZ16)
	oModelSE5:goLine(_nLinSE5)

return()

user function MV06001A()

	local	aArea		:= getArea(),;
			aAreaZ16	:= Z16->(getArea()),;
			aAreaSE5	:= SE5->(getArea())

	local	cIDCONC	:= ''
	
	cIDCONC	:= Z15->Z15_IDCONC
	
	//validacao
	if Z15->Z15_DATA != DDATABASE
		u_msgErro('A DATA BASE do SISTEMA tem que ser a mesma DATA do RECEBIMENTO.','')
		return
	endif
	
	if Z15->Z15_STATUS == '4'
		if u_msgPergunta('Antes de prosseguir deve DESCONCILIAR a tranferencia realizada. Podemos prosseguir?','') != 6
			u_msgInforma('Ação abortada','')
			return
		endif
	endif 
	
	begin transaction
	
		//CANCELAR TRANSFERENCIA
		if Z15->Z15_STATUS == '4'
			U_MV06001B(6)
		endif

		dbSelectArea('Z16')
		Z16->(dbSetOrder(1))
		Z16->(dbGoTop())
		Z16->(dbSeek(xFilial('Z16')+cIDCONC))
		while !Z16->(eof()) .and. Z16->Z16_IDCONC == cIDCONC
		
			cNSU	:= Z16->Z16_NSUCV
			
			dbSelectArea('SE5')
			SE5->(dbSetOrder(10))
			SE5->(dbGoTop())
			SE5->(dbSeek(xFilial('SE5')+cNSU))
			while !SE5->(eof()) .and. alltrim(SE5->E5_DOCUMEN) == alltrim(cNSU) .and. SE5->E5_XIDCONC = cIDCONC
				
				if recLock('SE5',.F.)
					SE5->E5_XIDCONC	:= ''
					SE5->E5_XDTCONC	:= stod('  /  /    ')
					SE5->(msUnlock())
				endif
	
				SE5->(dbSkip())
			enddo
	
			if recLock('Z16',.F.)
				Z16->(dbDelete())
				Z16->(msUnlock())
			endif
	
			Z16->(dbSkip())
		enddo
	
		if recLock('Z15',.F.)
			Z15->(dbDelete())
			Z15->(msUnlock())
		endif
		
	end transaction
	
	u_msgInforma('Conciliação Cancelado com sucesso.','')

	restArea(aAreaSE5)
	restArea(aAreaZ16)
	restArea(aArea)

return
