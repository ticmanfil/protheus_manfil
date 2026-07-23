#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: MV05004
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 25/01/2024
===============================================================================================================================
Descriï¿½ï¿½o---------: Este programa serve para IMPRIMIR OS PEDIDOS DE VENDAS
===============================================================================================================================
Uso---------------: Faturamento
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
user function MV05004()

	//Local oMainWnd
	//Local aCoors := FWGetDialogSize( oMainWnd )
	//Local oPanel, oFWLayer  
	local cPerg		:= 'MV05004'
	
	//private oDlgPrinc
	private cCadastro 	:= '[MV05004] - Impressão dos Docs Saídas''
	private oMark

	private	lGerPDF		:= .T.,;
			lViewPDF	:= .T.,;
			lDanfe		:= .F.,;
			lBolet		:= .F.

	private cFiltroTela	:= space(500)

	cFiltroTela	:= ' 1=1 '
	pAjustaSx1(cPerg)
	if Pergunte(cPerg,.T.)
		if !empty(mv_par01)		//Clientes de
			cFiltroTela	+= ' .AND. F2_CLIENTE >= ' + chr(39) + mv_par01 + chr(39) + ' '
		endif
		if !empty(mv_par02)	//Clientes ate
			cFiltroTela	+= ' .AND. F2_CLIENTE <= ' + chr(39) + mv_par02 + chr(39) + ' '
		endif
		if !empty(mv_par03)	//Serie de
			cFiltroTela	+= ' .AND. F2_SERIE >= ' + chr(39) + mv_par03 + chr(39) + ' '
		endif
		if !empty(mv_par04)	//Serie ate
			cFiltroTela	+= ' .AND. F2_SERIE <= ' + chr(39) + mv_par04 + chr(39) + ' '
		endif
		if !empty(mv_par05)	//Nota de
			cFiltroTela	+= ' .AND. F2_DOC >= ' + chr(39) + mv_par05 + chr(39) + ' '
		endif
		if !empty(mv_par06)	//Nota ate
			cFiltroTela	+= ' .AND. F2_DOC <= ' + chr(39) + mv_par06 + chr(39) + ' '
		endif
		if !empty(mv_par07)	//Data de Emissao de
			cFiltroTela	+= ' .AND. dToS(F2_EMISSAO) >= ' + chr(39) + DTOS(mv_par07) + chr(39) + ' '
		endif
		if !empty(mv_par07)	//Data de Emissao ate
			cFiltroTela	+= ' .AND. dToS(F2_EMISSAO) <= ' + chr(39) + DTOS(mv_par08) + chr(39) + ' '
		endif
		//cFiltroTela += ' .AND. F2_XIMP == '+ chr(39) + 'N' + chr(39) + ''

	endif

//	Define MsDialog oDlgPrinc Title cCadastro From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	/* Cria o conteiner onde sï¿½o colocados os browses */
//	oFWLayer := FWLayer():New()
//	oFWLayer:Init( oDlgPrinc, .F., .T. )
	
	/* Define Painel Principal */
//	oFWLayer:AddLine( 'FULL', 100, .F. )			// Cria uma "linha" com 100% da tela
//	oFWLayer:AddCollumn( 'ALL', 100, .T., 'FULL' )	// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
//	oPanel := oFWLayer:GetColPanel( 'ALL', 'FULL' )	// Pego o objeto desse do container
	
	/* FWMarkBrowse */
	oMark:= FWMarkBrowse():New()
	oMark:SetAlias( 'SF2' )
	oMark:SetMenuDef( 'MV05004' ) 		// Define de que fonte vem os botoes deste browse
	oMark:SetProfileID( '1' ) 			// Identificador ID para o Browse
	oMark:ForceQuitButton()				// Exibicao do botao Sair  
	oMark:SetFilterDefault(cFiltroTela) //Filtros da rotina
 	
 	//Setando semï¿½foro, descriï¿½ï¿½o e campo de mark
    oMark:SetSemaphore(.T.)	//defini se utiliza controle de marcacao exclusiva
    oMark:SetDescription(cCadastro)
    oMark:SetFieldMark( 'F2_OK' )
	oMark:SetAllMark({||finvert()})
	
	/* Legendas */ 
	//oMark:AddLegend( "F2_XBOLETO == 'N' "	, "DISABLE"		, "Faturado",,.F. )
	//oMark:AddLegend( "F2_XBOLETO == 'S' "	, "ENABLE"		, "Boleto",,.F. )
	
	oMark:Activate()      
	
	//Activate MsDialog oDlgPrinc Center

return


/*CRIAR MODELO DE DADOS*/
static function ModelDef

	local 	oModel
	
	/* Carregar a estrutura de dados */
	local oStrSF2	:= FWFormStruct(1,'SF2', { |cCampo| MV05004VC(cCampo) } )	//1 ou 2
	
	/* Definir modelo de dados */
	oModel	:= MPFormModel():New('MV05004_MVC', /*bPreValidacao*/, /*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )
	
	/* editar propriedades do modelo de dados */
	oModel:addFields('FIELD_SF2',,oStrSF2)

	oModel:setDescription('[MV05004] - Impressão dos Docs Saídas')
	
	/*Definicao da Chave Primaria*/
	oModel:SetPrimaryKey({'F2_FILIAL', 'F2_SERIE', 'F2_DOC'})


return oModel

/*CRIAR VIEWDEF DO MODELO DE DADOS*/
static function ViewDef()

	/*Importar modelo de dados */
	local oModel	:= FWLoadModel('MV05004')	//nome do fonte que esta criado a estrutura de dados
	
	/*Cria estrutura de dados da Viewdef*/
	Local oStrSF2 	:= FWFormStruct(2,'SF2', { |cCampo| VerCampo(cCampo) })
	local oView		:= FWFormView():New()
	
	/*Definir propriedades da Viewdef*/
	setPropV(oStrSF2)		//setar propriedade da estrutura
	
	/*Define qual modelo de dados sera utilizado pela View*/
	oView:SetModel(oModel)

	/* Construir ViewDef*/
	oView:AddField('VIEW_SF2', oStrSF2, 'FIELD_SF2' )
	
	/*Gerar Box de Visualizacao*/
	oView:CreateHorizontalBox('SUPERIOR', 100)  			// <nome do box>, <%que vai ocupar na tela>
	
	/*Relacionar box com a Estrutura*/
	oView:SetOwnerView('VIEW_SF2', 'SUPERIOR')			//
	
return oView

/*CRIAR MENU DA ROTINA*/
static function MenuDef()

	local aRotina	:= {}
	
	//aadd(aRotina,{'Visualizar'			, 'VIEWDEF.MV05002'	, 0, 2, 0, nil})
//	aadd(aRotina,{'Processar'			, 'msgRun("Processando os registros selecionados... Aguarde...","Processando os registros",{|| U_MV05002A()})'		, 0, 2, 0, nil})
	aadd(aRotina,{'Imprimir'		, 'U_MV05004A()'		, 0, 2, 0, nil})
	aadd(aRotina,{'Marca Todos'		, 'U_MV05004C()'		, 0, 2, 0, nil})
	aadd(aRotina,{'Desmarcar Todos'	, 'U_MV05004D()'		, 0, 2, 0, nil})
	
return aRotina

/*Funcao para Processar as notas marcadas*/
user function MV05004A()
	local	aArea		:= getArea(),;
			aSF2		:= SF2->(getArea()),;
			aSD2		:= SD2->(getArea()),;
			aSC6		:= SC6->(getArea()),;
			cMarca		:= oMark:Mark(),;
			aNFs		:= {},;
			aItens		:= {},;
			nX
	
	SF2->(dbSelectArea((aSF2)))
	//cFiltro := BuildExpr('SF2')
      
    //Se tiver filtro, usa o DbSetFilter para filtrar a tabela
    If ! Empty(cFiltroTela)
        SF2->(DbSetfilter({|| &(cFiltroTela)}, cFiltroTela))
    //Senão, limpa qualquer filtragem
    Else
        SF2->(DbClearFilter())
    Endif
	
	SF2->(dbGoTop())
	while !SF2->(eof())
		if oMark:IsMark(cMarca)
			aItens:= {}
			aadd(aItens,xFilial('SF2'))
			aadd(aItens,SF2->F2_DOC)
			aadd(aItens,SF2->F2_SERIE)
			reclock('SF2',.F.)
				SF2->F2_OK	:= ''
			SF2->(msUnLock())
			aadd(aNfs,aItens)
		endif
		SF2->(dbSkip())
	end

	if Len(aNFs) > 0
		nX:= 0
		for nX:=1 to Len(aNFs)
			SD2->(dbSelectArea(aSD2))
			SD2->(dbSetorder(3))
			if (SD2->(dbSeek(aNFs[nX,1]+aNFs[nX,2]+aNFs[nX,3])))
				if !SD2->(eof()) .and. SD2->D2_DOC == aNFs[nX,2] .and. SD2->D2_SERIE == aNFs[nX,3]
					SC6->(dbSelectArea(aSC6))
					SC6->(dbSetOrder(1))
					SC6->(dbSeek(SD2->D2_FILIAL+SD2->D2_PEDIDO))
					if !SC6->(eof()) .and. SC6->C6_NUM == SD2->D2_PEDIDO
						U_ImpPedVen(SC6->C6_NUM,FunName())
					endif
				endif
			endif
		next nX
	endif

	restArea(aSC6)
	restArea(aSD2)
	restArea(aSF2)
	restArea(aArea)
	
return nil

user function MV05004C() //Marcar todos os registros
	local	aArea		:= getArea(),;
			aSF2		:= SF2->(getArea()),;
			cMarca		:= oMark:Mark()
			
	SF2->(dbSelectArea((aSF2)))
	//cFiltro := BuildExpr('SF2')
      
    //Se tiver filtro, usa o DbSetFilter para filtrar a tabela
    If ! Empty(cFiltroTela)
        SF2->(DbSetfilter({|| &(cFiltroTela)}, cFiltroTela))
    //Senão, limpa qualquer filtragem
    Else
        SF2->(DbClearFilter())
    Endif
	
	SF2->(dbGoTop())
	while !SF2->(eof())
		reclock('SF2',.F.)
		SF2->F2_OK	:= cMarca
		SF2->(msUnLock())				
		SF2->(dbSkip())
	end
	SF2->(dbGoTop())

	restArea(aSF2)
	restArea(aArea)
return nil

user function MV05004D() //Desmarcar todos os registros
	local	aArea		:= getArea(),;
			aSF2		:= SF2->(getArea()),;
			cMarca		:= oMark:Mark()
			
	SF2->(dbSelectArea((aSF2)))
	//cFiltro := BuildExpr('SF2')
      
    //Se tiver filtro, usa o DbSetFilter para filtrar a tabela
    If ! Empty(cFiltroTela)
        SF2->(DbSetfilter({|| &(cFiltroTela)}, cFiltroTela))
    //Senão, limpa qualquer filtragem
    Else
        SF2->(DbClearFilter())
    Endif
	
	SF2->(dbGoTop())
	while !SF2->(eof())
		reclock('SF2',.F.)
		SF2->F2_OK	:= ''
		SF2->F2_OK	:= cMarca
		SF2->(msUnLock())				
		SF2->(dbSkip())
	end
	SF2->(dbGoTop())

	restArea(aSF2)
	restArea(aArea)


return nil

static function pAjustaSx1(cPerg)

//	local lRet

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Cliente de ?'			, /*cPerSpa		*/ 'Cliente de ?'			, /*cPerEng		*/ 'Cliente de ?'			, ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('A1_COD')[1]		, /*nDecimal	*/ tamsx3('A1_COD')[2]		, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par01'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '02'						, 											  ;
				/*cPergunt	*/ 'Cliente ate ?'			, /*cPerSpa		*/ 'Cliente ate ?'			, /*cPerEng		*/ 'Cliente ate ?'			, ;
				/*cVar		*/ 'mv_ch2'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('A1_COD')[1]		, /*nDecimal	*/ tamsx3('A1_COD')[2]		, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par02'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '03'						, 											  ;
				/*cPergunt	*/ 'Serie de ?'				, /*cPerSpa		*/ 'Serie de ?'				, /*cPerEng		*/ 'Serie de ?'				, ;
				/*cVar		*/ 'mv_ch3'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('F2_SERIE')[1]	, /*nDecimal	*/ tamsx3('F2_SERIE')[2]	, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par03'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '04'						, 											  ;
				/*cPergunt	*/ 'Serie ate ?'			, /*cPerSpa		*/ 'Serie ate ?'			, /*cPerEng		*/ 'Serie ate ?'			, ;
				/*cVar		*/ 'mv_ch4'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('F2_SERIE')[1]	, /*nDecimal	*/ tamsx3('F2_SERIE')[2]	, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par04'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '05'						, 											  ;
				/*cPergunt	*/ 'Num.Nota de ?'			, /*cPerSpa		*/ 'Num.Nota de ?'			, /*cPerEng		*/ 'Num.Nota de ?'			, ;
				/*cVar		*/ 'mv_ch5'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('F2_DOC')[1]		, /*nDecimal	*/ tamsx3('F2_DOC')[2]		, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par05'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '06'						, 											  ;
				/*cPergunt	*/ 'Num.Nota ate ?'			, /*cPerSpa		*/ 'Num.Nota ate ?'			, /*cPerEng		*/ 'Num.Nota ate ?'			, ;
				/*cVar		*/ 'mv_ch6'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ tamsx3('F2_DOC')[1]		, /*nDecimal	*/ tamsx3('F2_DOC')[2]		, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par06'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '07'						, 											  ;
				/*cPergunt	*/ 'Data Emissao de ?'		, /*cPerSpa		*/ 'Data Emissao de ?'		, /*cPerEng		*/ 'Data Emissao de ?'		, ;
				/*cVar		*/ 'mv_ch7'					, /*cTipo 		*/ 'D'						, 											  ;
				/*nTamanho	*/ tamsx3('F2_EMISSAO')[1]	, /*nDecimal	*/ tamsx3('F2_EMISSAO')[2]	, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par07'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '08'						, 											  ;
				/*cPergunt	*/ 'Data Emissao ate ?'		, /*cPerSpa		*/ 'Data Emissao ate ?'		, /*cPerEng		*/ 'Data Emissao ate ?'		, ;
				/*cVar		*/ 'mv_ch8'					, /*cTipo 		*/ 'D'						, 											  ;
				/*nTamanho	*/ tamsx3('F2_EMISSAO')[1]	, /*nDecimal	*/ tamsx3('F2_EMISSAO')[2]	, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par08'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '09'						, 											  ;
				/*cPergunt	*/ 'Data Emissao ate ?'		, /*cPerSpa		*/ 'Data Emissao ate ?'		, /*cPerEng		*/ 'Data Emissao ate ?'		, ;
				/*cVar		*/ 'mv_ch9'					, /*cTipo 		*/ 'D'						, 											  ;
				/*nTamanho	*/ tamsx3('F2_EMISSAO')[1]	, /*nDecimal	*/ tamsx3('F2_EMISSAO')[2]	, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par08'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/)
return


/*Mostrar Campos em Tela */
Static Function MV05004VC( cCampo)

	Local _lRet		:= .F.
	Local _cCampos	:= 'F2_EMISSAO|F2_XVEND1|F2_DOC|F2_SERIE|F2_XTOTAL|F2_XNOMECL|F2_CLIENTE|F2_LOJA|F2_XIMP'

	If Alltrim(cCampo) $ _cCampos
		_lRet := .T.
	EndIf

Return _lRet  
