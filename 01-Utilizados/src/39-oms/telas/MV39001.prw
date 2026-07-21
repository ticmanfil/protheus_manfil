#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: MV39001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 01/04/2019
===============================================================================================================================
Descrição---------: Este programa serve para FAZER MONTAGEM DE CARGA
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
user function MV39001()

	local 	oBrowse,;
			cFiltroTela	:= ''	//'1=1'
			

	private	cOrigem		as char,;
			aItens		as array		//para  controlar pedidos adicionados evitando duplicidade


	cCadastro 	:= '[MV39001] - Montagem de Carga'
	
	/* FWmBrowse */
	oBrowse:= FWmBrowse():New()
	oBrowse:SetDescription( cCadastro )
	oBrowse:DisableDetails()
	oBrowse:SetAlias( 'DAK' )
	oBrowse:SetMenuDef( 'MV39001' ) 		// Define de que fonte vem os botoes deste browse
	oBrowse:SetProfileID( '1' ) 			// Identificador ID para o Browse
	oBrowse:ForceQuitButton()				// Exibicao do botao Sair  
	oBrowse:SetFilterDefault(cFiltroTela) 	// Filtros da rotina
	
	oBrowse:AddLegend( "DAK_XDTSAID == ctod('  /  /    ') .AND. DAK_XDTRET == ctod('  /  /    ') .AND. DAK_XFINAL == 'N'"	, "BR_VERDE"		, "Carga Cadastrada" )
	oBrowse:AddLegend( "DAK_XDTSAID == ctod('  /  /    ') .AND. DAK_XDTRET == ctod('  /  /    ') .AND. DAK_XFINAL == 'J'"	, "BR_MARROM"		, "Carga Juntada" )
	oBrowse:AddLegend( "DAK_XDTSAID != ctod('  /  /    ') .AND. DAK_XDTRET == ctod('  /  /    ') .AND. DAK_XFINAL == 'N'"	, "BR_AMARELO"		, "Saiu para Entrega" )
	oBrowse:AddLegend( "DAK_XDTSAID != ctod('  /  /    ') .AND. DAK_XDTRET != ctod('  /  /    ') .AND. DAK_XFINAL == 'N'"	, "BR_PRETO_0"		, "Entrega Retornado" )
	oBrowse:AddLegend( "DAK_XDTSAID != ctod('  /  /    ') .AND. DAK_XDTRET != ctod('  /  /    ') .AND. DAK_XFINAL == 'S'"	, "BR_VERMELHO"		, "Entraga Concluida" )
/*
	oBrowse:AddLegend( "DAK_XDTSAID == ctod('  /  /    ') .AND. DAK_XDTRET == ctod('  /  /    ') .AND. DAK_JUNTOU <> ' ' .AND. DAK_XFINAL == 'J'"	, "BR_MARROM"		, "Carga Juntada" )
	oBrowse:AddLegend( "DAK_XDTSAID == ctod('  /  /    ') .AND. DAK_XDTRET == ctod('  /  /    ') .AND. DAK_JUNTOU == 'N' .AND. DAK_XFINAL != 'S'"	, "BR_VERDE"		, "Carga Cadastrada" )
	oBrowse:AddLegend( "DAK_XDTSAID != ctod('  /  /    ') .AND. DAK_XDTRET == ctod('  /  /    ') .AND. DAK_JUNTOU == 'N' .AND. DAK_XFINAL != 'S'"	, "BR_AMARELO"		, "Saiu para Entrega" )
	oBrowse:AddLegend( "DAK_XDTSAID != ctod('  /  /    ') .AND. DAK_XDTRET != ctod('  /  /    ') .AND. DAK_JUNTOU == 'N' .AND. DAK_XFINAL != 'S'"	, "BR_PRETO_0"		, "Entrega Retornado" )
	oBrowse:AddLegend( "DAK_XDTSAID != ctod('  /  /    ') .AND. DAK_XDTRET != ctod('  /  /    ') .AND. DAK_JUNTOU == 'N' .AND. DAK_XFINAL == 'S'"	, "BR_VERMELHO"		, "Entraga Concluida" )
*/
	oBrowse:Activate()      
	
return


/*CRIAR MODELO DE DADOS*/
static function ModelDef

	local oModel
	
	/* Carregar a estrutura de dados */
	local oStrDAK	:= FWFormStruct(1,'DAK')
	local oStrDAI	:= FWFormStruct(1,'DAI')
	
	/* Definir propriedades da estrutura de dados */
	FAddCampo(oStrDAK,oStrDAI)
	FCriaGat(oStrDAK,oStrDAI)
	FSetPropM(oStrDAK,oStrDAI)
	
	/* Definir modelo de dados */
	oModel	:= MPFormModel():New('MV39001_MVC', /*bPreValidacao*/, /*bPosValidacao*/, {|oModel| MV39001GRV(oModel)} /*bCommit*/, /*bCancel*/ )
	
	/* editar propriedades do modelo de dados */
	oModel:addFields('FIELD_DAK', , oStrDAK)
	oModel:addGrid('GRID_DAI', 'FIELD_DAK', oStrDAI, /*bLinePre*/, /*bLinePost*/, {|oModel, nLine, cAction, cField| MV39001LOK(oModel, nLine, cAction, cField)}/*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	/*Relacao entre as Estrutura*/
	oModel:SetRelation('GRID_DAI',{{'DAI_FILIAL','xFilial("DAI")'}, {'DAI_COD', 'DAK_COD'}, {'DAI_SEQCAR', 'DAK_SEQCAR'}}, DAI->(IndexKey(1)))
	
	oModel:setDescription(cCadastro)
	oModel:GetModel('GRID_DAI'):setDescription('[MV39001] - Pedidos Faturados')
	
	/*Liga o controle de não repetição de linha*/
	oModel:GetModel('GRID_DAI'):setUniqueLine({'DAI_SEQUEN'})
	
	/* Indica que é opcional ter dados nas Grids permitindo salvar a grid vazia*/
	oModel:GetModel( 'GRID_DAI' ):SetOptional(.F.)

	/* Define que o modelo de dados não será gravado, apenas usado para consulta */
	//oModel:GetModel("FIELD_SF2"):SetOnlyQuery(.T.)

	/*Definicao da Chave Primaria*/
	oModel:SetPrimaryKey({'DAK_FILIAL', 'DAK_COD', 'DAK_SEQCAR'})
	
return oModel


/*CRIAR VIEWDEF DO MODELO DE DADOS*/
static function ViewDef()

	/*Importar modelo de dados */
	local oModel	:= FWLoadModel('MV39001')	//nome do fonte que esta criado a estrutura de dados
	
	/*Cria estrutura de dados da Viewdef*/
	Local 	oStrDAK 	:= FWFormStruct(2,'DAK', { |cCampo| VerCampo(cCampo) } ),;
			oStrDAI		:= FWFormStruct(2,'DAI', { |cCampo| VerCampoG(cCampo) } )	//criar a estrutura de dados da camada de visualização 

	local	oView	:= FWFormView():New()
	
	/*Definir propriedades da Viewdef*/
	FAddCampoG(oStrDAK,oStrDAI)
	FSetPropG(oStrDAK,oStrDAI)
//	RemoveFld(oStrSF2,oStrZ03,oStrZ07)		//remocao de campos da estrutura
	
	/*Define qual modelo de dados sera utilizado pela View*/
	oView:SetModel(oModel)

	/* Construir ViewDef*/
	oView:AddField('VIEW_DAK'	, oStrDAK, 'FIELD_DAK' )
	oView:AddGrid('VIEW_DAI'	, oStrDAI, 'GRID_DAI' )
	
	/*Define campos que terao auto incremento*/
	oView:addIncrementField('VIEW_DAI','DAI_SEQUEN')
	
	/*Gerar Box de Visualizacao*/
	oView:CreateHorizontalBox('SUPERIOR', 40)  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateHorizontalBox('INFERIOR', 60)  			// <nome do box>, <%que vai ocupar na tela>
	
	/*Relacionar box com a Estrutura*/
	oView:SetOwnerView('VIEW_DAK', 'SUPERIOR')
	oView:SetOwnerView('VIEW_DAI', 'INFERIOR')

/*	if !empty(DAK->DAK_XFINAL) .and. DAK->DAK_XFINAL == 'S'
		u_msgErro('Carga já PROCESSADA e FINALIZADA!',cCadastro)
		return
	endif
*/	

	aItens:= {}

return oView


/*CRIAR MENU DA ROTINA*/
static function MenuDef()

	local 	aRotina	:= {}

	aadd(aRotina,{'Visualizar'					, 'VIEWDEF.MV39001'		, 0, 2, 0, nil})
	aadd(aRotina,{'Incluir'						, 'VIEWDEF.MV39001'		, 0, 3, 0, nil})
	aadd(aRotina,{'Alterar'						, 'VIEWDEF.MV39001'		, 0, 4, 0, nil})
	aadd(aRotina,{'Movimenta Veiculo'			, 'U_MV39001D()'		, 0, 8, 0, nil})
	aadd(aRotina,{'Junção de Carga'				, 'U_MV39001H()'		, 0, 8, 0, nil})
	aadd(aRotina,{'Processar Entrega'			, 'U_MV39001G()'		, 0, 8, 0, nil})
	aadd(aRotina,{'Cancela Carga'				, 'U_MV39001C()'		, 0, 6, 0, nil})
	aadd(aRotina,{'Cancela Movimenta Veiculo'	, 'U_MV39001F()'		, 0, 8, 0, nil})

	//if RetCodUsr()="000000"
	if u_EstaGrp(__CUSERID,'000000')
		aadd(aRotina,{'Cancela Processar Entrega'	, 'U_MV39001E()'		, 0, 8, 0, nil})
	endif

	aadd(aRotina,{'Imprimir'					, 'U_FIMP("C")'			, 0, 8, 0, nil})
	aadd(aRotina,{'Romaneio Carga'				, 'U_FIMP("R")'			, 0, 8, 0, nil})
	
return aRotina

/*VISUALIZAR SOMENTES OS CAMPOS DESEJADOS*/
static function VerCampo(cCampo)
	local 	_lRet		:= .F.,;
			_cCampos	:= 'DAK_COD|DAK_SEQCAR|DAK_XTPCAR|DAK_CAMINH|DAK_XPLACA|DAK_MOTORI|DAK_XNMOTO|DAK_AJUDA1|DAK_XNAJU1|DAK_AJUDA2|DAK_AJUDA3|DAK_XCONFE|DAK_XNCONF|DAK_XTARA|DAK_PESO|DAK_XPESOL|DAK_VALOR|DAK_DATA|DAK_HORA|DAK_PTOENT|DAK_FEZNF|DAK_ACECAR|DAK_XOBS|DAK_XDTSAI|DAK_XHRSAI|DAK_XKMINI|DAK_XDTRET|DAK_XHRRET|DAK_XKMRET|DAK_XTEMPO|DAK_XDISTA|DAK_XFINAL|DAK_XTITEM'
			
	if Alltrim(cCampo) $ _cCampos
		_lRet := .T.
	endif

return _lRet  

static function VerCampoG(cCampo)
	local 	_lRet		:= .F.,;
			_cCampos	:= 'DAI_SEQUEN|DAI_PEDIDO|DAI_NFISCA|DAI_SERIE|DAI_CLIENT|DAI_LOJA|DAI_VENDED|DAI_PESO|DAI_XPAG|DAI_XVALOR|DAI_DATA|DAI_HORA|DAI_XSERIE|DAI_XNFIS|DAI_XSRRES|DAI_XNFRES|DAI_XCIDAD|DAI_VALFRE|DAI_XSIT|DAI_XOCOR|DAI_XPEDRE'

	if Alltrim(cCampo) $ _cCampos
		_lRet := .T.
	endif

return _lRet  


/*CRIAR CAMPOS VIRTUAIS*/
static function FAddCampo(oStrDAK,oStrDAI)

	//FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ]
	//							, [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
	oStrDAK:addField('Ajudante 2'	,'Nome do Ajudante 2'	,'DAK_XNAJU2','C',tamsx3('DAU_NREDUZ')[1],tamsx3('DAU_NREDUZ')[2],,{|| .F.},,,fwBuildFeature(STRUCT_FEATURE_INIPAD, "POSICIONE('DAU',1,XFILIAL('DAU')+M->DAK_AJUDA2,'DAU_NREDUZ')"),.F.,,.T., )
	oStrDAK:addField('Ajudante 3'	,'Nome do Ajudante 3'	,'DAK_XNAJU3','C',tamsx3('DAU_NREDUZ')[1],tamsx3('DAU_NREDUZ')[2],,{|| .F.},,,fwBuildFeature(STRUCT_FEATURE_INIPAD, "POSICIONE('DAU',1,XFILIAL('DAU')+M->DAK_AJUDA3,'DAU_NREDUZ')"),.F.,,.T., )
	oStrDAK:addField('Peso Bruto', 'Peso Bruto', 'DAK_XPESOB','N',tamsx3('DAK_PESO')[1]		,tamsx3('DAK_PESO')[2]	,,{|| .F.},,,fwBuildFeature(STRUCT_FEATURE_INIPAD, "DAK_XPESOL+DAK_XTARA"),.F.,,.T., )
	
	oStrDAI:addField('N.Cliente'	,'Nome do Cliente'			,'DAI_XNCLI','C',tamsx3('A1_NOME')[1]						,tamsx3('A1_NOME')[2]	,,{|| .F.},,,fwBuildFeature(STRUCT_FEATURE_INIPAD, "posicione('SC5',1,xFILIAL('SC5')+DAI->DAI_PEDIDO,'C5_XCLIENT')"),.F.,,.T., )
	oStrDAI:addField('N.Vendedor'	,'Nome do Vendedor'			,'DAI_XNVEN','C',tamsx3('A3_NREDUZ')[1]						,tamsx3('A3_NREDUZ')[2]	,,{|| .F.},,,fwBuildFeature(STRUCT_FEATURE_INIPAD, "posicione('SC5',1,xFILIAL('SC5')+DAI->DAI_PEDIDO,'C5_XNVEND1')"),.F.,,.T., )
	oStrDAI:addField('Ocorrência'	,'Ocorrência'				,'DAI_XDOCOR','C',tamsx3('Z05_STATUS')[1]					,tamsx3('Z05_STATUS')[2]	,,{|| .F.},,,fwBuildFeature(STRUCT_FEATURE_INIPAD, "posicione('Z05',1,xFILIAL('Z05')+DAI->DAI_XOCOR,'Z05_STATUS')"),.F.,,.T., )
return nil

static function FAddCampoG(oStrDAK,oStrDAI)

	//FWFORMVIEWSTRUCT():AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >
	//					, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])
	/*DAK*/
	oStrDAK:addField('DAK_XNAJU2','17','Ajudante 2','Ajudante 2',{'Nome do Ajudante'},'C',alltrim(x3Picture('DAU_NREDUZ')),,'',.T.,'','',{},0,,.T.,)
	oStrDAK:addField('DAK_XNAJU3','17','Ajudante 3','Ajudante 3',{'Nome do Ajudante'},'C',alltrim(x3Picture('DAU_NREDUZ')),,'',.T.,'','',{},0,,.T.,)
	oStrDAK:addField('DAK_XPESOB','17','Peso Bruto','Peso Bruto',{'Peso Bruto da carga'},'C',alltrim(x3Picture('DAK_PESO')),,'',.T.,'','',{},0,,.T.,)

	/*DAI*/
	oStrDAI:addField('DAI_XNCLI','07','N.Cliente','Nome do Cliente',{'Nome do Cliente'},'C',alltrim(x3Picture('A1_NREDUZ')),,'',.T.,'','',{},0,,.T.,)
	oStrDAI:addField('DAI_XNVEN','20','N.Vendedor','Nome do Vendedor',{'Nome do Vendedor'},'C',alltrim(x3Picture('A3_NREDUZ')),,'',.T.,'','',{},0,,.T.,)
	oStrDAI:addField('DAI_XDOCOR','24','Ocorrência','Ocorrência',{'Ocorrência'},'C',alltrim(x3Picture('Z05_STATUS')),,'',.T.,'','',{},0,,.T.,)

return nil

/*CRIAR OS GATILHOS PERSONALIZADOS*/
static function FCriaGat(oStrDAK,oStrDAI)

	Local 	_aGatillho := {},;
			_iGat
	
	/* Gatilhos oStrDAK*/
	_aGatillho := {}
//	aadd(_aGatillho	,FwStruTrigger('DAK_CAMINH'	,'DAK_XPLACA' 	,'DA3->DA3_PLACA',.T.,'DA3',1 ,'xFilial("DA3")+DAK_CAMINH'))
//	aadd(_aGatillho	,FwStruTrigger('DAK_MOTORI'	,'DAK_XMOTOR' 	,'DA4->DA4_NOME',.T.,'DA4',1 ,'xFilial("DA4")+DAK_MOTORI'))
//	aadd(_aGatillho	,FwStruTrigger('DAK_AJUDA1'	,'DAK_XAJUDA' 	,'DAU->DAU_NOME',.T.,'DAU',1 ,'xFilial("DAU")+DAK_AJUDA1'))
//	aadd(_aGatillho	,FwStruTrigger('DAK_XTARA'	,'DAK_XPESOL' 	,'M->DAK_PESOT - M->DAK_XTARA',.F.))
	aadd(_aGatillho	,FwStruTrigger('DAK_CAMINH'	,'DAK_XTARA' 	,'DA3->DA3_TARA',.T.,'DA3',1 ,'xFilial("DA3")+DAK_CAMINH'))
	aadd(_aGatillho	,FwStruTrigger('DAK_AJUDA2'	,'DAK_XNAJU2' 	,'POSICIONE("DAU",1,XFILIAL("DAU")+M->DAK_AJUDA2,"DAU_NREDUZ")',.F.))
	aadd(_aGatillho	,FwStruTrigger('DAK_AJUDA3'	,'DAK_XNAJU3' 	,'POSICIONE("DAU",1,XFILIAL("DAU")+M->DAK_AJUDA3,"DAU_NREDUZ")',.F.))
	aadd(_aGatillho	,FwStruTrigger('DAK_CAMINH'	,'DAK_XTARA' 	,'DA3->DA3_TARA',.T.,'DA3',1 ,'xFilial("DA3")+DAK_CAMINH'))
	aadd(_aGatillho	,FwStruTrigger('DAK_XTARA'	,'DAK_XPESOL' 	,'M->DAK_XPESOB - M->DAK_XTARA',.F.))
	aadd(_aGatillho	,FwStruTrigger('DAK_XPESOB'	,'DAK_XPESOL' 	,'M->DAK_XPESOB - M->DAK_XTARA',.F.))
	
	For _iGat := 1 to Len(_aGatillho)
		oStrDAK:AddTrigger( _aGatillho[_iGat][1], _aGatillho[_iGat][2], _aGatillho[_iGat][3], _aGatillho[_iGat][4] )
	Next _iGat
	
	/* Gatilhos oStrDAI*/
	_aGatillho := {}
	aadd(_aGatillho	,FwStruTrigger('DAI_NFISCA'	,'DAI_PEDIDO' 	,'SD2->D2_PEDIDO'								,.T.,'SD2',3,'xFilial("SD2")+M->DAI_NFISCA+M->DAI_SERIE'))
	aadd(_aGatillho	,FwStruTrigger('DAI_NFISCA'	,'DAI_CLIENT' 	,'SC5->C5_CLIENTE'								,.T.,'SC5',1,'xFilial("SC5")+M->DAI_PEDIDO'))
	aadd(_aGatillho	,FwStruTrigger('DAI_NFISCA'	,'DAI_LOJA' 	,'SC5->C5_LOJACLI'								,.F.)) //,'SC5',10,'xFilial("SC5")+M->DAI_SERIE+M->DAI_NFISCA'))
	aadd(_aGatillho	,FwStruTrigger('DAI_NFISCA'	,'DAI_XNCLI' 	,'SC5->C5_XCLIENT'								,.F.)) //,'SC5',10,'xFilial("SC5")+M->DAI_SERIE+M->DAI_NFISCA'))
	aadd(_aGatillho	,FwStruTrigger('DAI_NFISCA'	,'DAI_PESO' 	,'SC5->C5_PBRUTO'								,.F.)) //,'SC5',10,'xFilial("SC5")+M->DAI_SERIE+M->DAI_NFISCA'))
	aadd(_aGatillho	,FwStruTrigger('DAI_NFISCA'	,'DAI_VENDED' 	,'SC5->C5_VEND1'								,.F.)) //,'SC5',10,'xFilial("SC5")+M->DAI_SERIE+M->DAI_NFISCA'))
	aadd(_aGatillho	,FwStruTrigger('DAI_NFISCA'	,'DAI_XNVEN' 	,'SC5->C5_XNVEND1'								,.F.)) //,'SC5',10,'xFilial("SC5")+M->DAI_SERIE+M->DAI_NFISCA'))
	aadd(_aGatillho	,FwStruTrigger('DAI_NFISCA'	,'DAI_XVALOR' 	,'U_xVlNota(M->DAI_SERIE,M->DAI_NFISCA) '		,.F.))
	aadd(_aGatillho ,FwStruTrigger('DAI_NFISCA'	,'DAI_DATA'		,'M->DAK_DATA'									,.F.))
	aadd(_aGatillho ,FwStruTrigger('DAI_NFISCA'	,'DAI_HORA'		,'M->DAK_HORA'									,.F.))
	aadd(_aGatillho ,FwStruTrigger('DAI_NFISCA'	,'DAI_XSERIE'	,'U_NFFISCA(M->DAI_NFISCA,M->DAI_SERIE,1)'		,.F.))
	aadd(_aGatillho ,FwStruTrigger('DAI_NFISCA'	,'DAI_XNFIS'	,'U_NFFISCA(M->DAI_NFISCA,M->DAI_SERIE,2)'		,.F.))
	aadd(_aGatillho ,FwStruTrigger('DAI_NFISCA'	,'DAI_XSRRES'	,'U_SERIEORIG(M->DAI_NFISCA,M->DAI_SERIE)'		,.F.))
	aadd(_aGatillho ,FwStruTrigger('DAI_NFISCA'	,'DAI_XNFRES'	,'U_NOTAORIG(M->DAI_NFISCA,M->DAI_SERIE)'		,.F.))
	aadd(_aGatillho ,FwStruTrigger('DAI_NFISCA'	,'DAI_XPAG'		,'U_TEMNFORI(M->DAI_NFISCA,M->DAI_SERIE)'		,.F.))
	aadd(_aGatillho ,FwStruTrigger('DAI_NFISCA'	,'DAI_XCIDAD'	,'SC5->C5_XMUNE'								,.F.))
	aadd(_aGatillho ,FwStruTrigger('DAI_NFISCA'	,'DAI_VALFRE'	,'SF2->F2_FRETE'								,.T.,'SF2',1,'xFilial("SF2")+M->DAI_NFISCA+M->DAI_SERIE'))
	aadd(_aGatillho ,FwStruTrigger('DAI_XOCOR'	,'DAI_XDOCOR'	,'iif(!empty(M->DAI_XOCOR),Z05->Z05_STATUS,"")'	,.T.,'Z05',1,'xFILIAL("Z05")+M->DAI_XOCOR'))

	For _iGat := 1 to Len(_aGatillho)
		oStrDAI:AddTrigger( _aGatillho[_iGat][1], _aGatillho[_iGat][2], _aGatillho[_iGat][3], _aGatillho[_iGat][4] )
	Next _iGat

return


/*PROPRIEDADES DA ESTURUTURA DE DADOS (ModelDef) e VIEWDEF*/
static function FSetPropM(oStrDAK,oStrDAI)

	/*oStrDAK*/
	oStrDAK:SetProperty('DAK_COD'		, MODEL_FIELD_INIT		, {|| substr(dtos(DDATABASE),-6,tamsx3('DAK_COD')[1]) })
	oStrDAK:SetProperty('DAK_COD'		, MODEL_FIELD_WHEN		, {|| .F.})

	oStrDAK:SetProperty('DAK_SEQCAR'	, MODEL_FIELD_INIT		, {|| U_PRXSEQCAR(substr(dtos(DDATABASE),-6,tamsx3('DAK_COD')[1])) })
	oStrDAK:SetProperty('DAK_SEQCAR'	, MODEL_FIELD_WHEN		, {|| .F.})

//	oStrDAK:SetProperty('DAK_XTPCAR'	, MODEL_FIELD_INIT		, {|| DDATABASE})
//	oStrDAK:SetProperty('DAK_XTPCAR'	, MODEL_FIELD_WHEN		, {|| INCLUI})

	oStrDAK:SetProperty('DAK_DATA'		, MODEL_FIELD_INIT		, {|| DDATABASE})
	oStrDAK:SetProperty('DAK_DATA'		, MODEL_FIELD_WHEN		, {|| .F.})

	oStrDAK:SetProperty('DAK_HORA'		, MODEL_FIELD_INIT		, {|| TIME()})
	oStrDAK:SetProperty('DAK_HORA'		, MODEL_FIELD_WHEN		, {|| .F.})

	oStrDAK:SetProperty('DAK_PTOENT'	, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:SetProperty('DAK_PTOENT'	, MODEL_FIELD_WHEN		, {|| .T.})

	oStrDAK:SetProperty('DAK_XTARA'		, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:setProperty('DAK_XTARA'		, MODEL_FIELD_WHEN		, {|| .T.})

	oStrDAK:SetProperty('DAK_XPESOB'	, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:setProperty('DAK_XPESOB'	, MODEL_FIELD_WHEN		, {|| .T.})
	oStrDAK:setProperty('DAK_XPESOB'	, MODEL_FIELD_VALID		, {|| .T.})//VPESOBRUTO(M->DAK_XTARA,M->DAK_XPESOB)})

	oStrDAK:SetProperty('DAK_PESO'		, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:SetProperty('DAK_PESO'		, MODEL_FIELD_WHEN		, {|| .T.})

	oStrDAK:SetProperty('DAK_XPESOL'	, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:setProperty('DAK_XPESOL'	, MODEL_FIELD_WHEN		, {|| .F.})

	oStrDAK:SetProperty('DAK_VALOR'		, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:SetProperty('DAK_VALOR'		, MODEL_FIELD_WHEN		, {|| .T.})

	oStrDAK:SetProperty('DAK_CAMINH'	, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:SetProperty('DAK_CAMINH'	, MODEL_FIELD_WHEN		, {|| .T.})
	
	oStrDAK:SetProperty('DAK_MOTORI'	, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:SetProperty('DAK_MOTORI'	, MODEL_FIELD_WHEN		, {|| .T.})
	
	oStrDAK:SetProperty('DAK_AJUDA1'	, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:SetProperty('DAK_AJUDA1'	, MODEL_FIELD_WHEN		, {|| .T.})

	oStrDAK:SetProperty('DAK_AJUDA2'	, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:SetProperty('DAK_AJUDA2'	, MODEL_FIELD_WHEN		, {|| .T.})

	oStrDAK:SetProperty('DAK_AJUDA3'	, MODEL_FIELD_OBRIGAT	, .F.)
	oStrDAK:SetProperty('DAK_AJUDA3'	, MODEL_FIELD_WHEN		, {|| .T.})

	oStrDAK:SetProperty('DAK_FEZNF'		, MODEL_FIELD_INIT		, {|| '1'})
	oStrDAK:SetProperty('DAK_FEZNF'		, MODEL_FIELD_WHEN		, {|| .F.})

	oStrDAK:SetProperty('DAK_ACECAR'	, MODEL_FIELD_INIT		, {|| '2'})
	oStrDAK:SetProperty('DAK_ACECAR'	, MODEL_FIELD_WHEN		, {|| .F.})

	oStrDAK:SetProperty('DAK_XOBS'		, MODEL_FIELD_WHEN		, {|| .T.})

	oStrDAK:SetProperty('DAK_XDTSAI'	, MODEL_FIELD_WHEN		, {|| .F.})
	oStrDAK:SetProperty('DAK_XHRSAI'	, MODEL_FIELD_WHEN		, {|| .F.})
	oStrDAK:SetProperty('DAK_XKMINI'	, MODEL_FIELD_WHEN		, {|| .F.})
	oStrDAK:SetProperty('DAK_XDTRET'	, MODEL_FIELD_WHEN		, {|| .F.})
	oStrDAK:SetProperty('DAK_XHRRET'	, MODEL_FIELD_WHEN		, {|| .F.})
	oStrDAK:SetProperty('DAK_XKMRET'	, MODEL_FIELD_WHEN		, {|| .F.})
	oStrDAK:SetProperty('DAK_XTEMPO'	, MODEL_FIELD_WHEN		, {|| .F.})
	oStrDAK:SetProperty('DAK_XDISTA'	, MODEL_FIELD_WHEN		, {|| .F.})

	oStrDAK:SetProperty('DAK_XFINAL'	, MODEL_FIELD_INIT		, {|| 'N'})
	oStrDAK:SetProperty('DAK_XFINAL'	, MODEL_FIELD_WHEN		, {|| .F.})

	oStrDAK:SetProperty('DAK_XTITEM'	, MODEL_FIELD_INIT		, {|| 0})
	oStrDAK:SetProperty('DAK_XTITEM'	, MODEL_FIELD_WHEN		, {|| .F.})

	/*oStrDAI*/                                                                           
	//oStrDAI:SetProperty('DAI_XPAG'		, MODEL_FIELD_OBRIGAT, {|| .T.})
	oStrDAI:SetProperty('DAI_DATA'		, MODEL_FIELD_WHEN, {|| .F.})
	oStrDAI:SetProperty('DAI_HORA'		, MODEL_FIELD_WHEN, {|| .F.})
	oStrDAI:SetProperty('DAI_VALFRE'	, MODEL_FIELD_WHEN, {|| .F.})
	oStrDAI:SetProperty('DAI_SERIE'		, MODEL_FIELD_INIT, {|| 'UNI'})
	oStrDAI:SetProperty('DAI_XSIT'		, MODEL_FIELD_INIT, {|| 'N'})
	oStrDAI:SetProperty('DAI_XPEDRE'	, MODEL_FIELD_INIT, {|| 'N'})
//	oStrDAI:SetProperty('DAI_XOCOR'		, MODEL_FIELD_WHEN, {|| .T.})

	oStrDAI:SetProperty('DAI_NFISCA'	, MODEL_FIELD_VALID, {|| VALNF(,M->DAI_NFISCA) })

return

static function FSetPropG(oStrDAK,oStrDAI)
	
	/*oStrDAK*/
	oStrDAK:setProperty('DAK_COD'		,MVC_VIEW_ORDEM,	'01')
	oStrDAK:setProperty('DAK_SEQCAR'	,MVC_VIEW_ORDEM,	'02')
	oStrDAK:setProperty('DAK_XTPCAR'	,MVC_VIEW_ORDEM,	'03')
	oStrDAK:setProperty('DAK_DATA'		,MVC_VIEW_ORDEM,	'04')
	oStrDAK:setProperty('DAK_HORA'		,MVC_VIEW_ORDEM,	'05')
	oStrDAK:setProperty('DAK_CAMINH'	,MVC_VIEW_ORDEM,	'06')
	oStrDAK:setProperty('DAK_XPLACA'	,MVC_VIEW_ORDEM,	'07')
	oStrDAK:setProperty('DAK_XPLACA'	,MVC_VIEW_ORDEM,	'08')
	oStrDAK:setProperty('DAK_MOTORI'	,MVC_VIEW_ORDEM,	'09')
	oStrDAK:setProperty('DAK_XNMOTO'	,MVC_VIEW_ORDEM,	'10')
	oStrDAK:setProperty('DAK_AJUDA1'	,MVC_VIEW_ORDEM,	'11')
	oStrDAK:setProperty('DAK_XNAJU1'	,MVC_VIEW_ORDEM,	'12')
	oStrDAK:setProperty('DAK_AJUDA2'	,MVC_VIEW_ORDEM,	'13')
	oStrDAK:setProperty('DAK_XNAJU2'	,MVC_VIEW_ORDEM,	'14')
	oStrDAK:setProperty('DAK_AJUDA3'	,MVC_VIEW_ORDEM,	'15')
	oStrDAK:setProperty('DAK_XNAJU3'	,MVC_VIEW_ORDEM,	'16')
	oStrDAK:setProperty('DAK_XCONFE'	,MVC_VIEW_ORDEM,	'17')
	oStrDAK:setProperty('DAK_XNCONF'	,MVC_VIEW_ORDEM,	'18')
	oStrDAK:setProperty('DAK_PTOENT'	,MVC_VIEW_ORDEM,	'19')
	oStrDAK:setProperty('DAK_XTARA'		,MVC_VIEW_ORDEM,	'20')
	oStrDAK:SetProperty('DAK_XPESOB'	,MVC_VIEW_ORDEM,	'21')
	oStrDAK:setProperty('DAK_PESO'		,MVC_VIEW_ORDEM,	'22')
	oStrDAK:SetProperty('DAK_XPESOL'	,MVC_VIEW_ORDEM,	'23')
	oStrDAK:setProperty('DAK_VALOR'		,MVC_VIEW_ORDEM,	'24')
	oStrDAK:setProperty('DAK_FEZNF'		,MVC_VIEW_ORDEM,	'25')
	oStrDAK:setProperty('DAK_ACECAR'	,MVC_VIEW_ORDEM,	'26')
	oStrDAK:setProperty('DAK_XOBS'		,MVC_VIEW_ORDEM,	'27')
	oStrDAK:setProperty('DAK_XDTSAI'	,MVC_VIEW_ORDEM,	'28')
	oStrDAK:setProperty('DAK_XHRSAI'	,MVC_VIEW_ORDEM,	'29')
	oStrDAK:setProperty('DAK_XKMINI'	,MVC_VIEW_ORDEM,	'30')
	oStrDAK:setProperty('DAK_XDTRET'	,MVC_VIEW_ORDEM,	'31')
	oStrDAK:setProperty('DAK_XHRRET'	,MVC_VIEW_ORDEM,	'32')
	oStrDAK:setProperty('DAK_XKMRET'	,MVC_VIEW_ORDEM,	'33')
	oStrDAK:setProperty('DAK_XTEMPO'	,MVC_VIEW_ORDEM,	'34')
	oStrDAK:setProperty('DAK_XDISTA'	,MVC_VIEW_ORDEM,	'35')
	oStrDAK:setProperty('DAK_XFINAL'	,MVC_VIEW_ORDEM,	'36')
	oStrDAK:setProperty('DAK_XTITEM'	,MVC_VIEW_ORDEM,	'37')
	
	oStrDAK:setProperty('DAK_PESO'		,MVC_VIEW_TITULO,	'Peso Ped.')
	
	/*oStrDAI*/
	oStrDAI:setProperty('DAI_SEQUEN'	,MVC_VIEW_ORDEM, 	'01')
	oStrDAI:setProperty('DAI_SERIE'		,MVC_VIEW_ORDEM, 	'02')
	oStrDAI:setProperty('DAI_NFISCA'	,MVC_VIEW_ORDEM, 	'03')
	oStrDAI:setProperty('DAI_PEDIDO'	,MVC_VIEW_ORDEM, 	'04')
	oStrDAI:setProperty('DAI_CLIENT'	,MVC_VIEW_ORDEM, 	'05')
	oStrDAI:setProperty('DAI_LOJA'		,MVC_VIEW_ORDEM, 	'06')
	oStrDAI:setProperty('DAI_XNCLI'		,MVC_VIEW_ORDEM,	'07')
	oStrDAI:setProperty('DAI_XCIDAD'	,MVC_VIEW_ORDEM,	'08')
	oStrDAI:setProperty('DAI_PESO'		,MVC_VIEW_ORDEM,	'09')
	oStrDAI:setProperty('DAI_XPAG'		,MVC_VIEW_ORDEM, 	'10')
	oStrDAI:setProperty('DAI_XVALOR'	,MVC_VIEW_ORDEM, 	'11')
	oStrDAI:setProperty('DAI_XSERIE'	,MVC_VIEW_ORDEM, 	'12')
	oStrDAI:setProperty('DAI_XNFIS'		,MVC_VIEW_ORDEM, 	'13')
	oStrDAI:setProperty('DAI_XSRRES'	,MVC_VIEW_ORDEM,	'14')
	oStrDAI:setProperty('DAI_XNFRES'	,MVC_VIEW_ORDEM,	'15')
	oStrDAI:setProperty('DAI_XPEDRE'	,MVC_VIEW_ORDEM,	'16')
	oStrDAI:setProperty('DAI_VENDED'	,MVC_VIEW_ORDEM, 	'17')
	oStrDAI:setProperty('DAI_XNVEN'		,MVC_VIEW_ORDEM, 	'18')
	oStrDAI:setProperty('DAI_DATA'		,MVC_VIEW_ORDEM, 	'19')
	oStrDAI:setProperty('DAI_HORA'		,MVC_VIEW_ORDEM, 	'20')
	oStrDAI:setProperty('DAI_VALFRE'	,MVC_VIEW_ORDEM,	'21')
	oStrDAI:setProperty('DAI_XSIT'		,MVC_VIEW_ORDEM,	'22')
	oStrDAI:setProperty('DAI_XOCOR'		,MVC_VIEW_ORDEM,	'23')

	oStrDAI:setProperty('DAI_SEQUEN'	,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_SERIE'		,MVC_VIEW_CANCHANGE, .T.)
	oStrDAI:setProperty('DAI_NFISCA'	,MVC_VIEW_CANCHANGE, .T.)
	oStrDAI:setProperty('DAI_PEDIDO'	,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_CLIENT'	,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_LOJA'		,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_XNCLI'		,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_XCIDAD'	,MVC_VIEW_CANCHANGE, .T.)
	oStrDAI:setProperty('DAI_PESO'		,MVC_VIEW_CANCHANGE, .T.)
	oStrDAI:setProperty('DAI_XPAG'		,MVC_VIEW_CANCHANGE, .T.)
	oStrDAI:setProperty('DAI_XVALOR'	,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_XSERIE'	,MVC_VIEW_CANCHANGE, .T.)
	oStrDAI:setProperty('DAI_XNFIS'		,MVC_VIEW_CANCHANGE, .T.)
	oStrDAI:setProperty('DAI_XSRRES'	,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_XNFRES'	,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_XPEDRE'	,MVC_VIEW_CANCHANGE, .T.)
	oStrDAI:setProperty('DAI_VENDED'	,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_XNVEN'		,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_DATA'		,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_HORA'		,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:SetProperty('DAI_VALFRE'	,MVC_VIEW_CANCHANGE, .F.)
	oStrDAI:setProperty('DAI_XDOCOR'	,MVC_VIEW_CANCHANGE, .F.)

return

user function MV39001C()
	
	local 	aArea		:= getArea(),;
			aAreaDAK	:= DAK->(getArea()),;
			aAreaDAI	:= DAI->(getArea()),;
			aAreaSF2	:= SF2->(getArea()),;
			cChNF		:= ''

	if !empty(DAK->DAK_XDTSAI)
		u_msgErro('Tem saida de veiculo já lançado para essa carga! Cancelamento será ABORDADO.')
		
	else
		MV39001MOV(DAK->DAK_COD,DAK->DAK_SEQCAR,'16', DAK->DAK_XDTRET, DAK->DAK_XHRRET)		//CANC CARGA

		dbSelectArea('DAI')
		DAI->(dbSetOrder(1))
		DAI->(dbGoTop())
		DAI->(dbSeek(xFilial('DAI')+DAK->DAK_COD+DAK->DAK_SEQCAR))
		while !DAI->(EOF()) .and. DAI->DAI_COD == DAK->DAK_COD .and. DAI->DAI_SEQCAR == DAK->DAK_SEQCAR
			
			cChNF:= DAI->DAI_NFISCA + DAI->DAI_SERIE
			dbSelectArea('SF2')
			SF2->(dbSetOrder(1))
			SF2->(dbGoTop())
			SF2->(dbSeek(xFilial('SF2')+cChNF))
			while !SF2->(eof()) .and. SF2->F2_DOC+SF2->F2_SERIE == cChNF
				
				if RecLock('SF2',.F.)
					SF2->F2_CARGA	:= ''
					SF2->F2_SEQCAR	:= ''
					SF2->(msUnlock())
				endif

				SF2->(dbSkip())
			enddo

			dbSelectArea('DAI')
			if RecLock('DAI',.F.)
				DAI->(dbDelete())
				DAI->(msUnlock())
			endif
			DAI->(dbSkip())
		enddo

		dbSelectArea('DAK')
		if RecLock('DAK',.F.)
			DAK->(dbDelete())
			DAK->(msUnlock())
		endif

		u_msgInformacao('Cancelamento de CARGA finalizado com sucesso!',cCadastro)

	endif

	restArea(aAreaSF2)
	restArea(aAreaDAI)
	restArea(aAreaDAK)
	restArea(aArea)


return nil

/*BOTAO MOVIMENTA VEICULO*/
user function MV39001D()

	local	oDlg, oGet01, oGet02, oGet03, oGet04, oGet05, oGet06, oGet07,;
				oGet09, oGet10, oGet11

	local	nOpca	as char

	private	cControle		as char,;
			dDtSaida		as date,;
			cHrSaida		as char,;
			nKmSaida		as numeric,;
			dDtRetorno		as date,;
			cHrRetorno		as char,;
			nKmRetorno		as numeric,;
			nTara			as numeric,;
			nPeso			as numeric,;
			nPesoLiq		as numeric,;
			nPesoTeorico	as numeric,;
			nPesoFinal		as numeric,;
			nValor			as numeric,;
			lSaida			as logical

	if empty(DAK->DAK_CAMINH) .or. empty(DAK->DAK_MOTORI)
		u_msgErro('Carga sem VEICULO ou MOTORISTA cadastrado! Favor cadastrar.',cCadastro)

	elseif DAK->DAK_XFINAL == 'S'
		u_msgErro('Carga já finalizada e não poderá mais ser movimentado!',cCadastro)

	elseif DAK->DAK_XTPCAR == 'P'
		u_msgErro('Pré Carga não pode ser movimentado!',cCadastro)

//	elseif EmTransito(DAK->DAK_CAMINH)
//		u_msgErro('Veiculo em TRANSITO! Favor efetuar o retorno antes de prosseguir.',cCadastro)
	
	else
		SetPrvt('oDlg1','oSay1','oSay2','oSay3','oSay4','oSay5','oSay6','oSBtnOk','oSBtnCan','oMGet1')
		
		cControle		:= DAK->DAK_COD+DAK->DAK_SEQCAR
		dDtSaida		:= iif(empty(DAK->DAK_XDTSAI),DDATABASE,DAK->DAK_XDTSAI)
		cHrSaida		:= iif(empty(DAK->DAK_XHRSAI),time(),DAK->DAK_XHRSAI)
		nKmSaida		:= iif(empty(DAK->DAK_XKMINI),0,DAK->DAK_XKMINI)
		dDtRetorno		:= iif(empty(DAK->DAK_XDTRET),DDATABASE,DAK->DAK_XDTRET)
		cHrRetorno		:= iif(empty(DAK->DAK_XHRRET),time(),DAK->DAK_XHRRET)
		nKmRetorno		:= iif(empty(DAK->DAK_XKMRET),0,DAK->DAK_XKMRET)
		nTara			:= DAK->DAK_XTARA
		nPeso			:= DAK->DAK_PESO
		nPesoLiq		:= DAK->DAK_XPESOL
		nPesoTeorico	:= nTara + nPeso
		nPesoFinal		:= nTara + nPesoLiq
		nValor			:= DAK->DAK_VALOR

		if empty(DAK->DAK_XDTSAI)
			lSaida:= .T.
			nKmSaida	:= 0	//u_UltKM(DAK->DAK_CAMINH)
			dDtRetorno	:= cTod('  /  /    ')
			cHrRetorno	:= ''
			nKmRetorno	:= 0
		else
			lSaida:= .F.
		endif
		
		DEFINE MSDIALOG oDlg TITLE '[MV39001]-Retorno da Carga' From 0,0 TO 250,530 PIXEL
		
		@ 010,004 SAY OemToansi('Data Saída:') SIZE 052, 008 OF oDlg PIXEL
		@ 018,004 MSGET oGet01 VAR dDtSaida SIZE 052,008 WHEN lSaida OF oDlg PIXEL

		@ 010,064 SAY OemToansi('Hora da Saída:') SIZE 052, 008 OF oDlg PIXEL
		@ 018,064 MSGET oGet02 VAR cHrSaida SIZE 052,008 WHEN lSaida PICTURE '99:99:99' OF oDlg PIXEL

		@ 010,124 SAY OemToansi('Km da Saída:') SIZE 052, 008 OF oDlg PIXEL
		@ 018,124 MSGET oGet03 VAR nKmSaida SIZE 052,008 WHEN lSaida PICTURE '@E 9,999,999' OF oDlg PIXEL

		@ 010,184 SAY OemToansi('Valor Carga:') SIZE 052, 008 OF oDlg PIXEL
		@ 018,184 MSGET oGet04 VAR nValor SIZE 052,008 WHEN lSaida PICTURE '@E 9,999,999.99' OF oDlg PIXEL

		@ 040,004 SAY OemToansi('Tara:') SIZE 052, 008 OF oDlg PIXEL
		@ 048,004 MSGET oGet05 VAR nTara SIZE 052,008 WHEN .F. PICTURE '@E 9,999,999.9999'  OF oDlg PIXEL

		@ 040,064 SAY OemToansi('Peso Teórico:') SIZE 052, 008 OF oDlg PIXEL
		@ 048,064 MSGET oGet06 VAR nPesoTeorico SIZE 052,008 WHEN .F. PICTURE '@E 9,999,999.9999'  OF oDlg PIXEL

		@ 040,124 SAY OemToansi('Peso Final:') SIZE 052, 008 OF oDlg PIXEL
		@ 048,124 MSGET oGet07 VAR nPesoFinal SIZE 052,008 WHEN .F. PICTURE '@E 9,999,999.9999'  OF oDlg PIXEL

		@ 040,184 SAY OemToansi('Peso Real:') SIZE 052, 008 OF oDlg PIXEL
		@ 048,184 MSGET oGet07 VAR nPesoLiq SIZE 052,008 WHEN .F. PICTURE '@E 9,999,999.9999'  OF oDlg PIXEL

		@ 070,004 SAY OemToansi('Data do Retorno:') SIZE 052, 008 OF oDlg PIXEL
		@ 078,004 MSGET oGet09 VAR dDtRetorno SIZE 052,008 WHEN !lSaida OF oDlg PIXEL

		@ 070,064 SAY OemToansi('Hora do Retorno:') SIZE 052, 008 OF oDlg PIXEL
		@ 078,064 MSGET oGet10 VAR cHrRetorno SIZE 052,008 WHEN !lSaida PICTURE '99:99:99' OF oDlg PIXEL

		@ 070,124 SAY OemToansi('Km do Retorno:') SIZE 052, 008 OF oDlg PIXEL
		@ 078,124 MSGET oGet11 VAR nKmRetorno SIZE 052,008 WHEN !lSaida PICTURE '@E 9,999,999' OF oDlg PIXEL

		DEFINE SBUTTON FROM 100, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
		DEFINE SBUTTON FROM 100, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED	

		if nOpca == '1'

			if Valida(DAK->DAK_CAMINH,dDtSaida,dDtRetorno,cHrSaida,cHrRetorno,nKmSaida,nKmRetorno)
				if RecLock('DAK',.F.)
					DAK_XDTSAI	:= dDtSaida
					DAK_XHRSAI	:= cHrSaida
					DAK_XKMINI	:= nKmSaida
					DAK_XDTRET	:= dDtRetorno
					DAK_XHRRET	:= cHrRetorno
					DAK_XKMRET	:= nKmRetorno
					DAK_XTEMPO	:= DifPeriodo(dDtSaida, cHrSaida, dDtRetorno, cHrRetorno)
					DAK_XDISTA	:= nKmRetorno-nKmSaida
					DAK_XTARA	:= nTara
					DAK_PESO	:= nPeso
					DAK_XPESOL	:= nPesoLiq
					DAK_VALOR	:= nValor
					DAK->(msUnlock())

					if lSaida
						MV39001MOV(DAK->DAK_COD,DAK->DAK_SEQCAR,'08', dDtSaida, cHrSaida)	//SAIU PARA ENTREGA
					else
						MV39001MOV(DAK->DAK_COD,DAK->DAK_SEQCAR,'17', dDtRetorno, cHrRetorno)	//RETORNO DE CARGA    
					endif

				endif
			endif
		endif
	endif
return nil

//cancela SAIDA DE VEICULO e RETORNO DE VEICULO
user function MV39001F()	

	if DAK->DAK_XFINAL == 'S'
		u_msgErro('Carga já FINALIZADA!',cCadastro)
		
	else
		if !empty(DAK->DAK_XDTRET) .or. !empty(DAK->DAK_XDTSAI)
			if RecLock('DAK',.F.)

				DAK_XDTSAI	:= ctod('  /  /    ')
				DAK_XHRSAI	:= ''
				DAK_XKMINI	:= 0

				DAK_XDTRET	:= ctod('  /  /    ')
				DAK_XHRRET	:= ''
				DAK_XKMRET	:= 0
				DAK_XTEMPO	:= ''
				DAK_XDISTA	:= 0

				DAK->(msUnlock())

				MV39001MOV(DAK->DAK_COD,DAK->DAK_SEQCAR,'19', date(), time())	//CANC. RETORNO DE CAR
				MV39001MOV(DAK->DAK_COD,DAK->DAK_SEQCAR,'18', date(), time())	//CANC. SAIU P/ ENTREG
				
				u_msgInformacao('Saída de veículo cancelado com sucesso!',cCadastro)

			endif
		endif
	endif
return nil

/*PROCESSAR ENTREGA*/
user function MV39001G()	

	local	aArea		:= getArea(),;
			aAreaDAK	:= DAK->(getArea()),;
			aAreaDAI	:= DAI->(getArea()),;
			nTotalItem	as numeric

	nTotalItem:= 0
	
	if DAK->DAK_XFINAL	== 'S'
		u_msgErro('Carga já finalizada e não poderá ser mais processada novamente!',cCadastro)

	elseif EmTransito(DAK->DAK_CAMINH)
		u_msgErro('Veículo em transito e não pode pode ser processada!'+CRLF+'Finaliza o movimento anterior antes de prossseguir.',cCadastro)

	elseif KmInicial(DAK->DAK_CAMINH, DAK->DAK_COD, DAK->DAK_SEQCAR)
		u_msgErro('KM Inicial inválido!'+CRLF+'Revisar os ultimos movimentos.',cCadastro)

	elseif DAK->DAK_XTARA <= 0 .or. DAK->DAK_XPESOL <= 0
		u_msgErro('TARA ou PESO BRUTO invalido! Favor corrigir.',cCadastro)

	elseif DAK->DAK_XTPCAR == 'P' .or. DAK->DAK_XTPCAR == 'X'
		u_msgErro('Pré Carga não pode ser processado!',cCadastro)

	elseif empty(DAK->DAK_MOTORI)
		u_msgErro('Carga sem MOTORISTA!'+CRLF+'Favor verificar.',cCadastro)

	elseif empty(DAK->DAK_XCONFE)
		u_msgErro('Carga sem CONFERENTE!'+CRLF+'Favor verificar.',cCadastro)

	else
		dbSelectArea('DAK')
		if !empty(DAK->DAK_XDTRET)
			dbSelectArea('DAK')
			nTotalItem:= pBuscaQtdItem(DAK->DAK_COD,DAK->DAK_SEQCAR)
			if !empty(DAK->DAK_XDTSAI) .and. !empty(DAK->DAK_XDTRET)
				if RecLock('DAK',.F.)
					DAK_XFINAL	:= 'S'
					DAK_XTITEM	:= nTotalItem
					DAK->(msUnlock())
					Processa({|| MV39001MOV(DAK->DAK_COD,DAK->DAK_SEQCAR,'09', DAK->DAK_XDTRET, DAK->DAK_XHRRET)},"Processando ...")
					//MV39001MOV(DAK->DAK_COD,DAK->DAK_SEQCAR,'09', DAK->DAK_XDTRET, DAK->DAK_XHRRET)	//ENTREGUE
				endif
				u_msgInformacao('Entrega processado com sucesso!',cCadastro)
			endif
		else
			u_msgErro('Cargar ainda retornado e não pode ser processado!',cCadastro)
		endif
	
	endif

	restArea(aAreaDAK)
	restArea(aAreaDAI)
	restArea(aArea)

return nil

/*CANCELA ENTREGA PROCESSADA*/
user function MV39001E()	

	if DAK->DAK_XFINAL != 'S'
		u_msgErro('Carga ainda não PROCESSADA!'+CRLF+' Operação será abortada.',cCadastro)
		
	else
		if RecLock('DAK',.F.)
			DAK_XFINAL	:= 'N'
			DAK_XTITEM	:= 0
			DAK->(msUnlock())
		endif

		MV39001MOV(DAK->DAK_COD,DAK->DAK_SEQCAR,'20', date(), time())	//CANC. PROC. ENTREGA 
		
		u_msgInformacao('Processamento CANCELADO com sucesso!',cCadastro)

	endif
	
return nil

/*JUNCAO DE CARGAS*/
user function MV39001H()

	local	oDlg, oGet01, oGet02, nOpca as char

	local	cCarga1	as char,;
			cCarga2	as char

	local	cQry	as char,;
			lExec	as logical,;
			cCodCar	as char,;
			cSeqCar	as char

	SetPrvt('oDlg1','oSay1','oSay2','oSBtnOk','oSBtnCan','oMGet1')
	
	cCarga1	:= ' '+replicate(' ',TAMSX3('DAK_COD')[1])+replicate(' ',TAMSX3('DAK_SEQCAR')[1])
	cCarga2 := ' '+replicate(' ',TAMSX3('DAK_COD')[1])+replicate(' ',TAMSX3('DAK_SEQCAR')[1])
	
	DEFINE MSDIALOG oDlg TITLE '[MV39001]-Junção de Carga' From 0,0 TO 250,530 PIXEL
	
	@ 010,004 SAY OemToansi('Carga 1:') SIZE 052, 008 OF oDlg PIXEL
	@ 018,004 MSGET oGet01 VAR cCarga1 F3 'DAK2' SIZE 052,008 WHEN .T. VALID XVALID(1) PICTURE '@E 99999999' OF oDlg PIXEL

	@ 040,004 SAY OemToansi('Carga 2:') SIZE 052, 008 OF oDlg PIXEL
	@ 048,004 MSGET oGet02 VAR cCarga2 F3 'DAK2' SIZE 052,008 WHEN .T. VALID XVALID(2) PICTURE '@E 99999999' OF oDlg PIXEL

	DEFINE SBUTTON FROM 100, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
	DEFINE SBUTTON FROM 100, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED	

	if nOpca == '1'
		//validando dados
		if empty(cCarga1).or.empty(cCarga2)
			u_msgErro('Campos CARGA 1 e CARGA 2 estão vazios!!!',cCadastro)
			return
		elseif cCarga1 == cCarga2
			u_msgErro('Campos são iguais!'+CRLF+'Favor revisar.',cCadastro)
			return
		endif

		cCodCar:= substr(dtos(DDATABASE),-6,tamsx3('DAK_COD')[1])
		cSeqCar:= U_PRXSEQCAR(cCodCar)

		cQry:= 'exec dbo.PR_MV39001H @FILIAL = '+char(39)+xFilial('DAK')+char(39)+', @COD = '+char(39)+cCodCar+char(39)+', @SEQCAR = '+char(39)+cSeqCar+char(39);
				+', @CARGA1 = '+char(39)+cCarga1+char(39)+', @CARGA2 = '+char(39)+cCarga2+char(39);
				+', @DATA = '+char(39)+dtos(DDATABASE)+char(39)+', @HORA = '+char(39)+TIME()+char(39)+''

		lExec:= u_ExecQry(cQry,.T.)

		if lExec
			dbSelectArea('DAK')
			DAK->(dbSetOrder())
			DAK->(dbGoTop())
			DAK->(dbSeek(xFilial('DAK')+cCodCar+cSeqCar))

			u_msgInforma('Junção executado com sucesso!'+CRLF+'Novo Carga '+cCodCar+' '+cSeqCar,cCadastro)
		endif

	endif

return nil


/**** PONTO'S DE ENTRADAS ***/
static function MV39001MOV(pCarga,pSeqCarga,pSituacao,pData,pHora)
	local	lRet	as logical

	local 	aArea		:= getArea(),;
			aAreaDAK	:= DAK->(getArea()),;
			aAreaDAI	:= DAI->(getArea()),;
			aAreaSF2	:= SF2->(getArea()),;
			cChNF		as char,;
			cSit		as char,;
			cNFRes		as char,;
			cSRRes		as char,;
			cSerie		as char,;
			cNota		as char

	dbSelectArea('DAI')
	DAI->(dbSetOrder(1))
	DAI->(dbGoTop())
	DAI->(dbSeek(xFilial('DAI')+pCarga+pSeqCarga))
	while !DAI->(EOF()) .and. DAI->DAI_COD == pCarga .and. DAI->DAI_SEQCAR == pSeqCarga
		cSerie	:= DAI->DAI_SERIE
		cNota	:= DAI->DAI_NFISCA
		cChNF	:= cNota+cSerie
		cSit	:= DAI->DAI_XSIT
		cNFRes	:= DAI->DAI_XNFRES
		cSRRes	:= DAI->DAI_XSRRES
		cPedRes	:= DAI->DAI_XPEDRE

		dbSelectArea('SF2')
		SF2->(dbSetOrder(1))
		SF2->(dbGoTop())
		SF2->(dbSeek(xFilial('SF2')+cChNF))
		while !SF2->(eof()) .and. SF2->F2_DOC+SF2->F2_SERIE == cChNF

			if pSituacao == '09'
				if cSit == 'N'			//ENTREGUE
					u_MovSitPed(cSerie, cNota, '09',pData,pHora,pCarga,pSeqCarga)   
				elseif cSit == 'P'		//ENTREGA PARCIAL
					u_MovSitPed(cSerie, cNota, '10',pData,pHora,pCarga,pSeqCarga)   
				elseif cSit == 'T'		//DEVOLUCAO
					u_MovSitPed(cSerie, cNota, '11',pData,pHora,pCarga,pSeqCarga)
				endif

				if !empty(cNFRes) .and. !empty(cSRRes) .and. cPedRes == 'S'
					u_MovSitPed(cSRRes,cNFRes,'09',pData,pHora,pCarga,pSeqCarga)
				else
					u_MovSitPed(cSRRes,cNFRes,'10',pData,pHora,pCarga,pSeqCarga)
				endif

			elseif pSituacao $ '08|16|17|18|19'		//SAIDA | CANC CAGAR | RETORNO DE  ENTREGA | CANC. RETORNO | CANC. SAIU ENTR
				u_MovSitPed(cSerie, cNota, pSituacao,pData,pHora,pCarga,pSeqCarga)

				if !empty(cNFRes) .and. !empty(cSRRes) 
					u_MovSitPed(cSRRes,cNFRes,pSituacao,pData,pHora,pCarga,pSeqCarga)
				else
					u_MovSitPed(cSRRes,cNFRes,pSituacao,pData,pHora,pCarga,pSeqCarga)
				endif

			endif

			SF2->(dbSkip())
		enddo

		DAI->(dbSkip())
	enddo

	restArea(aAreaSF2)
	restArea(aAreaDAI)
	restArea(aAreaDAK)
	restArea(aArea)

	lRet:= .T.

return lRet

static function Valida(cVeiculo,cDtIni,cDtFin,cHrIni,cHrFin,nKmIni,nKmFin)
	local	lRet	as logical,;
			cMsg	as char,;
			nUltKM	as numeric

	lRet:= .T.
	cMsg:= 'Validando Movimento:'
	nUltKM:= u_UltKM(cVeiculo)

//	if EmTransito(cVeiculo)
//		u_msgErro('Veiculo encontra-se em TRANSITO!'+CRLF+' Finalizar antes continuar.',cCadastro)
//		return .F.
//	else
		if !empty(cDtIni) .and. (empty(cHrIni) .or. empty(nKmIni))
			lRet	:= .F.
			cMsg	+= CRLF + 'HORA SAIDA ou KM SAIDA não preenchido!'
		endif

		if !empty(cHrIni) .and. !u_VldHora(alltrim(cHrIni))
			lRet	:= .F.
			cMsg	+= CRLF + 'Hora de SAÍDA não é válido!'
		endif

		if !empty(cHrFin) .and. !u_VldHora(alltrim(cHrFin))
			lRet	:= .F.
			cMsg	+= CRLF + 'Hora de RETORNO não é válido!'
		endif

		if !empty(cHrIni) .and. len(alltrim(cHrIni)) < 8
			lRet	:= .F.
			cMsg	+= CRLF + 'Hora de SAÍDA com tamanho válido!'
		endif

		if !empty(cHrFin) .and. len(alltrim(cHrFin)) < 8
			lRet	:= .F.
			cMsg	+= CRLF + 'Hora de RETORNO com tamanho válido!'
		endif

		if !empty(cDtIni) .and. !empty(cDtFin) .and. cDtIni > cDtFin
			lRet	:= .F.
			cMsg	+= CRLF + 'DATA de RETORNO não pode ser menor que a DATA de SAIDA!'
		endif

		if !empty(cDtIni) .and. cDtIni > DDATABASE
			lRet	:= .F.
			cMsg	+= CRLF + 'DATA de RETORNO maior que a DATA BASE!'
		endif

		if !empty(cDtFin) .and. cDtFin > DDATABASE
			lRet	:= .F.
			cMsg	+= CRLF + 'DATA de SAÍDA maior que a DATA BASE!'
		endif

		if !empty(nKmIni) .and. nKmIni < nUltKM
			lRet	:= .F.
			cMsg	+= CRLF + 'KM INICIAL menor que o último retorno! ('+transform(nUltKM,'@E 999,999')+')'
		endif

		if !empty(nKmIni) .and. !empty(nKmFin) .and. nKmIni > nKmFin 
			lRet	:= .F.
			cMsg	+= CRLF + 'KM RETORNO não pode ser menor que a KM INICIAL!'
		endif

		if !empty(nKmIni) .and. !empty(nKmFin) .and. nKmFin - nKmIni > 5000 
			lRet	:= .F.
			cMsg	+= CRLF + 'DISTÂNCIA percorrida superior a 5.000 KM!'
		endif

		if !empty(cDtFin) .and. (empty(cHrFin) .or. empty(nKmFin))
			lRet	:= .F.
			cMsg	+= CRLF + 'HORA ou KM de RETORNO não preenchido!'
		endif

		if empty(nTara) .or. empty(nPesoFinal) .or. empty(nPesoTeorico)
			lRet	:= .F.
			cMsg	+= CRLF + 'TARA ou PESO TEORICO ou PESO FINAL não preenchido!'
		
		elseif nTara > nPesoTeorico .or. nTara > nPesoFinal
			lRet	:= .F.
			cMsg	+= CRLF + 'PESO TEORICO ou FINAL inválido!'

		elseif nPesoTeorico < 0 .or. nPesoFinal < 0
			lRet	:= .F.
			cMsg	+= CRLF + 'PESO TEORICO ou FINAL inválido!'

		elseif nPesoLiq <= 0
			lRet	:= .F.
			cMsg	:= CRLF + 'PESO FINAL menor ou igual a 0 (zero)!'

		endif

		if	!lRet
			help(,,'Help',,cMsg, 1, 0)
		endif
		
//	endif

return lRet

static function buscatara(cVeiculo)
	local	nTara	as numeric,;
			cQry	as char

	nTara:= 0

	cQry := "exec PR_MV39001TARA @pVeiculo = '"+cVeiculo+"'"
	
	TcQuery cQry New Alias "TRB"

	dbSelectArea("TRB")
	TRB->(dbGoTop())
	nTara:= TRB->DA3_TARA
	dbSelectArea('TRB')
	TRB->(dbCloseArea())

return nTara

static function EmTransito(cVeiculo)

	local 	cQry	:= '',;
			lRet	:= .F.

	cQry := "exec PR_MV39001EMTRANS1 @pVeiculo = '"+cVeiculo+"'"
	
	TcQuery cQry New Alias "TRB"

	dbSelectArea("TRB")
	TRB->(dbGoTop())
	lRet:= iif(alltrim(TRB->CARGA)== '',.F.,.T.)
	if lRet .and. TRB->CARGA > DAK->DAK_COD+DAK->DAK_SEQCAR
		lRet:= .F.
	endif

	dbSelectArea('TRB')
	TRB->(dbCloseArea())

	
return lRet

static function KmInicial(cVeiculo,cCarga,cSeqCar)

	local 	cQry	:= '',;
			lRet	:= .T.

	cQry := "exec PR_MV39001KM @pVeiculo = '"+cVeiculo+"', @carga = '"+cCarga+"', @seqcarga = '"+cSeqCar+"'"
	
	TcQuery cQry New Alias "TRB"

	dbSelectArea("TRB")
	TRB->(dbGoTop())
	if TRB->DAK_XKMINI >= TRB->KMANT
		lRet:= .F.
	endif
	dbSelectArea('TRB')
	TRB->(dbCloseArea())
	
return lRet

user function FIMP(pTipo)

	local lOk	:= .F.

	if pTipo == 'C'
		lOk	:= U_RL39002(DAK->DAK_COD,DAK->DAK_SEQCAR)
	elseif pTipo == 'R'
		lOk	:= U_RL39003(DAK->DAK_COD,DAK->DAK_SEQCAR)
	endif

	if !lOk
		u_msgErro('Erro ao Imprimir Controle de Carga!',cCadastro)
	endif
return lOk

static function FAtSF2(oModel)
	
	local	oModelDAI	:= oModel:getModel('GRID_DAI'),;
			oModelDAK	:= oModel:getModel('FIELD_DAK')

	local	cCarga		as char,;
			cSeqCarga	as char

	//local 	_nLinDAI	:= oModelDAI:NLINE,;
	//		_aSave		:= FwSaveRows()
	
	local 	_n			:= 0,;
			cChave		:= ''

	cCarga		:= oModelDAK:getValue('DAK_COD')
	cSeqCarga	:= oModelDAK:getValue('DAK_SEQCAR')

	for _n:= 1 to oModelDAI:Length()
		oModelDAI:Goline(_n)

		if !oModelDAI:IsDeleted()
		
			cChave	:= oModelDAI:getValue('DAI_NFISCA');
						+oModelDAI:getValue('DAI_SERIE')

			dbSelectArea('SF2')
			SF2->(dbSetOrder(1))
			SF2->(dbGoTop())
			SF2->(dbSeek(xFilial('SF2')+cChave))
			while !SF2->(eof()) .and. SF2->F2_DOC+SF2->F2_SERIE == cChave
			
				if RecLock('SF2',.F.)
						SF2->F2_CARGA	:= cCarga
						SF2->F2_SEQCAR	:= cSeqCarga
					SF2->(msUnlock())
				endif

				if empty(oModelDAK:getValue('DAK_XDTSAI')).and.empty(oModelDAK:getValue('DAK_XDTRET'))
					u_MovSitPed(SF2->F2_SERIE, SF2->F2_DOC, '15', DAK->DAK_DATA, DAK_HORA,cCarga,cSeqCarga)	// CARGAS
					if !empty(oModelDAI:getValue('DAI_XSRRES')) .and. !empty(oModelDAI:getValue('DAI_XNFRES'))
						u_MovSitPed(oModelDAI:getValue('DAI_XSRRES'), oModelDAI:getValue('DAI_XNFRES'), '15', DAK->DAK_DATA, DAK_HORA,cCarga,cSeqCarga)	// CARGAS
					endif
				endif
				
				SF2->(dbSkip())
			enddo

		endif

	next _n
	
return .T.

/*PONTOS DE ENTRADAS*/
static function MV39001LOK(oModelGrid, nLine, cAction, cField)

	local	_lRet		:= .T.
	
	local	oModel		:= oModelGrid:getModel()
	
	local	oModelDAK	:= oModel:getModel('FIELD_DAK'),;
			oModelDAI	:= oModel:getModel('GRID_DAI')
	
	local 	_nLinDAI	:= oModelDAI:NLINE,;
			_aSave		:= FwSaveRows()
	
	local 	nPeso		as numeric,;
			nValor		as numeric,;
			nQtd		as numeric,;//oModelDAK:getValue('DAK_PTOENT'),;
			_n			as numeric

	nPeso		:= 0
	nValor		:= 0
	nQtd		:= 0
	_n			:= 0

	for _n:= 1 to oModelDAI:Length()
		oModelDAI:Goline(_n)

		if !oModelDAI:IsDeleted()
			if (_n == _nLinDAI) 
				if !(cAction	== 'DELETE')
					nPeso	+= oModelDAI:getValue('DAI_PESO')
					nValor	+= oModelDAI:getValue('DAI_XVALOR')	//U_UVlOrc(oModelDAI:getValue('DAI_PEDIDO'),'P')
					nQtd++
				endif
			else
				nPeso	+= oModelDAI:getValue('DAI_PESO')
				nValor	+= oModelDAI:getValue('DAI_XVALOR')
				nQtd++
			endif


		endif
				
	next _n
	
	if !(cAction	== 'ISENABLE')
		oModelDAK:SetValue('DAK_PESO',nPeso)
		oModelDAK:SetValue('DAK_VALOR',nValor)
		oModelDAK:SetValue('DAK_PTOENT',nQtd)
	endif

	FwRestRows(_aSave)

	oModelDAI:goLine(_nLinDAI)

return _lRet

static function MV39001GRV(oModel)

	local lRet	:= .F.

	/*Aqui podemos chamar funções antes do Commit Padrão.*/ 
	lRet:= ValidGeral(oModel) 

	if lRet

		/*Aqui temos a chamada da funcao padrão de gravação do MVC.*/ 	// http://tdn.totvs.com/display/framework/FWFormCommit 
		lRet := FWFormCommit( oModel 	/*[ oModel ]*/,; 
										/*[ bBefore ]*/,; 
										/*[ bAfter ]*/,; 
										/*[ bAfterSTTS ]*/,; 
										/*[ bInTTS ]*/,; 
										/*[ bABeforeTTS ]*/,; 
										/*[ bIntegEAI ] */ ) 
		
		/* Aqui podemos chamar funções depois do Commit Padrão, verificando sempre se o commit foi realizado. */ 
		if lRet
			FAtSF2(oModel)      	
		endif
		
	endif 

return lRet 

static function ValidGeral(oModelGrid)
	local	lRet		as logical,;
			oModelDAK	as object,;
			oModelDAI	as object,;
			nLinDAI		as numeric,;
			nX			as numeric,;
			cPedido		as char,;
			cFilent		as char,;
			cNumDoc		as char,;
			cSeq		as char,;
			cMsg		as char

	oModel		:= oModelGrid:getModel()
	oModelDAK	:= oModel:getModel('FIELD_DAK')
	oModelDAI	:= oModel:getModel('GRID_DAI')
	cMsg		:= 'Ocorrências: '

	if oModelDAK:getValue('DAK_XFINAL') == 'S'
		u_msgErro('Carga já finalizada e não pode mais ser alterada.',cCadastro)
		lRet		:= .F.

	else
		lRet		:= .T.
		nLinDAI		:= oModelDAI:nLine
		nX			:= 0

		//verificar inconsistencia no preenchimento do formulário
		for nX:= 1 to oModelDAI:Length()
			oModelDAI:Goline(nX)

			if !oModelDAI:IsDeleted()
				cSeq	:= oModelDAI:getValue('DAI_SEQUEN')
				cNumDoc	:= oModelDAI:getValue('DAI_SERIE')+oModelDAI:getValue('DAI_NFISCA')

				if oModelDAI:getValue('DAI_XSIT') == 'N' .and. !empty(oModelDAI:getValue('DAI_XOCOR'))
					cMsg += CRLF +cSeq+' - '+cNumDoc + ' Campo DEVOLVIDO inconsistente! Favor revisar.'
					lRet:= .F.

				elseif oModelDAI:getValue('DAI_XSIT') != 'N' .and. empty(oModelDAI:getValue('DAI_XOCOR'))
					cMsg += CRLF +cSeq+' - '+cNumDoc + 'Campo OCORRENCIA inconsistente! Favor revisar.'
					lRet:= .F.
				endif

			endif
		next nX

		if !lRet
			cMsg+=CRLF+CRLF+'Clica em OK para continuar.'
			DEFINE MSDIALOG oDlg TITLE "Validação Pedidos de Vendas" From 000,000 TO 350,400 Pixel
			@ 005,005 GET oMemo VAR cMsg MEMO SIZE 150,150 OF oDlg PIXEL
			oMemo:bRClicked := {||AllwaysTrue()}
			DEFINE SBUTTON FROM 005,165 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
			ACTIVATE MSDIALOG oDlg CENTER
			lRet:= .F.
		endif

		oModelDAI:goLine(nLinDAI)
		if !lRet
			return lRet
		else

			nX:= 0

			//verificar se tem pedidos em retira
			for nX:= 1 to oModelDAI:Length()
				oModelDAI:Goline(nX)

				if !oModelDAI:IsDeleted()
					cPedido:= oModelDAI:getValue('DAI_PEDIDO')
					cFilent	:= posicione('SC5',1,xFilial('SC5')+cPedido,'C5_FLENT')
					cSeq	:= oModelDAI:getValue('DAI_SEQUEN')
					cNumDoc	:= oModelDAI:getValue('DAI_SERIE')+oModelDAI:getValue('DAI_NFISCA')
					
					if cFilent == 'R'
						if empty(cMsg)
							cMsg+= CRLF+'Os pedidos abaixo são de RETIRA:'+CRLF
						else
							cMsg+=CRLF+cSeq+' - '+cNumDoc
						endif
						lRet:= .F.
					endif

				endif
			next nX

			if !lRet
				cMsg+=CRLF+CRLF+'Clica em OK para continuar.'
				DEFINE MSDIALOG oDlg TITLE "Validação Pedidos de Vendas" From 000,000 TO 350,400 Pixel
				@ 005,005 GET oMemo VAR cMsg MEMO SIZE 150,150 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				DEFINE SBUTTON FROM 005,165 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
				ACTIVATE MSDIALOG oDlg CENTER
				lRet:= .T.
			endif

			oModelDAI:goLine(nLinDAI)

		endif
	endif

return lRet

static function VPESOBRUTO(nTara, nPesoB)
	local	lRet			as logical

	default nTara:= 0
	default nPesoB:= 0

	if nPesoB < nTara
		lRet:= .F.
		u_msgErro('Peso Bruto invalido.')
	endif

return LRet

static function VALNF(pSerie,pNota)

	local	lRet			as logical,;
			cSituacao		as char,;
			cDscSituacao	as char,;
			lEntregue		as logical

	lRet:= .F.

	if empty(pSerie)
		pSerie:= 'UNI'
	endif

	if !existcpo('SF2', pNota + pSerie, 1)
		u_msgErro('Pedido não encontrado! '+ CRLF + pSerie + pNota)
		lRet:= .F.
	
	else
		lRet:= .T.
		cSituacao	:= posicione('SF2',1,xFilial('SF2')+pNota+pSerie,'F2_XSTNOTA')
		cDscSituacao:= posicione('Z04',1,xFilial('Z04')+cSituacao,'Z04_STATUS')
		lEntregue	:= posicione('Z04',1,xFilial('Z04')+cSituacao,'Z04_FLFINA')

		if lEntregue //cSituacao $ '08|09|12|15|17|99'
			lRet:= .F.
			u_msgErro('Pedido não pode ser carregado! '+CRLF+pSerie+pNota+' - '+cSituacao+' - '+cDscSituacao)

		else
			lRet:= .T.
			if !TMPPedidos(aItens,pSerie+pNota)
				aadd(aItens,pSerie+pNota)
			else
				lRet:= .F.
				u_msgErro('Pedido já lancado na carga! '+CRLF+pSerie+pNota)
			endif

		endif

	endif

return lRet

static function TMPPedidos(aItens, pDoc)

	local	lRet	:= .F.,;
			nPos	:= 0
	
	nPos	:= ascan(aItens, {|x| alltrim(upper(x)) == alltrim(upper(pDoc))})
	if nPos = 0
		lRet	:= .F.
	else
		lRet	:= .T.
	endif
	
return lRet

static function pBuscaQtdItem(pCarga, pSeqCarga)

	local	nTotal	as numeric,;
			cQry	as string

	nTotal	:= 0
	cQry	:= ''

	if select('TMP1') <> 0
		TMP1->(dbCloseArea())
	endif
	cQry:= 'exec dbo.PR_MV39001ITEM @FILIAL = "'+fwxFilial('SF2')+'", @CARGA = "'+pCarga+'", @SEQCAR = "'+pSeqCarga+'"'
	tcQuery cQry new alias 'TMP1'

	nTotal:= TMP1->TOTAL
	TMP1->(dbCloseArea())

return nTotal
