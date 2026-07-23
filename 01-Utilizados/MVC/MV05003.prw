#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'

/*/
===============================================================================================================================
Programa----------: MV05003
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 13/09/2022
===============================================================================================================================
Descrição---------: Este programa serve para Importar os PEDIDOS DE VENDAS
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
user function MV05003()

	//Local oMainWnd
	//Local aCoors := FWGetDialogSize( oMainWnd )
	//Local oPanel, oFWLayer  
	local cPerg		:= 'MV05003'
	
	//private oDlgPrinc
	private cCadastro 	:= '[MV05003] - Importar PEDIDOS DE VENDAS'
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
	oMark:SetAlias( 'SC5' )
	oMark:SetMenuDef( 'MV05003' ) 		// Define de que fonte vem os botoes deste browse
	oMark:SetProfileID( '1' ) 			// Identificador ID para o Browse
	oMark:ForceQuitButton()				// Exibicao do botao Sair  
	oMark:SetFilterDefault(cFiltroTela) //Filtros da rotina
 	
 	//Setando semï¿½foro, descriï¿½ï¿½o e campo de mark
    oMark:SetSemaphore(.T.)	//defini se utiliza controle de marcacao exclusiva
    oMark:SetDescription(cCadastro)
    oMark:SetFieldMark( 'C5_OK' )
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
	local oStrSF2	:= FWFormStruct(1,'SC5', { |cCampo| VerCampo(cCampo) } )	//1 ou 2
	
	/* Definir modelo de dados */
	oModel	:= MPFormModel():New('MV05003_MVC', /*bPreValidacao*/, /*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )
	
	/* editar propriedades do modelo de dados */
	oModel:addFields('FIELD_SF2',,oStrSF2)

	oModel:setDescription('[MV05003] - Importa PEDIDOS DE VENDAS')
	
	/*Definicao da Chave Primaria*/
	oModel:SetPrimaryKey({'C5_FILIAL', 'C5_NUM'})


return oModel

/*CRIAR VIEWDEF DO MODELO DE DADOS*/
static function ViewDef()

	/*Importar modelo de dados */
	local oModel	:= FWLoadModel('MV05003')	//nome do fonte que esta criado a estrutura de dados
	
	/*Cria estrutura de dados da Viewdef*/
	Local oStrSF2 	:= FWFormStruct(2,'SC5', { |cCampo| VerCampo(cCampo) })
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
	aadd(aRotina,{'Boletos'			, 'U_MV05002A()'		, 0, 2, 0, nil})
//	aadd(aRotina,{'Danfe/NFCe'		, 'U_MV05002B()'		, 0, 2, 0, nil})
	aadd(aRotina,{'Marca Todos'		, 'U_MV05002C()'		, 0, 2, 0, nil})
	aadd(aRotina,{'Desmarcar Todos'	, 'U_MV05002D()'		, 0, 2, 0, nil})
	
return aRotina

/*Funcao para Processar as notas marcadas*/
user function MV05003A()
	local	aArea		:= getArea(),;
			aSF2		:= SF2->(getArea()),;
			cMarca		:= oMark:Mark(),;
			aTitulo		:= {},;
			aItem		:= {}
			
	local 	cFuncao		:= FunName(),;
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
			aItem	:= {}
			aadd(aItem,xFilial('SE1'))
			aadd(aItem,SF2->F2_PREFIXO)
			aadd(aItem,SF2->F2_DOC)
			aadd(aItem,SF2->F2_CLIENTE)
			aadd(aItem,SF2->F2_LOJA)
			aadd(aItem,'N')						//Impresso Bordero
			aadd(aItem,'N')						//Impresso Boleto
			aadd(aItem,SF2->F2_SERIE)			//Incluido serie por Fabricio Antunes
			aadd(aItem,'')						//parcela
			reclock('SF2',.F.)
				SF2->F2_OK	:= ''
			SF2->(msUnLock())
			aadd(aTitulo,aItem)
		endif
				
		SF2->(dbSkip())
	end

	if Len(aTitulo) > 0
		if MsgYesNo("Deseja enviar por e-mail?")
			lViewPDF	:= .F.
			lDanfe		:= .T.
			lBolet		:= .T.
		
			for nX:=1 to Len(aTitulo)
				U_FATWS001(aTitulo[nX,3],aTitulo[nX,8],aTitulo[nX,4],aTitulo[nX,5],aTitulo[nX,2],aTitulo[nX,9],lViewPDF)
			next nX
			//MSGINFO("E-mail enviado com sucesso")
	
		else
			lViewPDF	:= .T.
			lDanfe		:= .F.
			lBolet		:= .T.
			U_RD06007(cFuncao,aTitulo,lViewPDF)
			
			//cBoleto		:= 
			//cBoleto		:= cBoleto+".PDF"
			//ferase(_cPasta+Alltrim(cBoleto))	
	
		endif
	endif

	restArea(aSF2)
	restArea(aArea)
	
return nil

user function MV05003C() //Marcar todos os registros
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

user function MV05003D() //Desmarcar todos os registros
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
return


/*Mostrar Campos em Tela */
Static Function VerCampo( cCampo , cTipo)

	Local _lRet		:= .F.
	Local _cCampos	:= 'F2_DOC|F2_SERIE|F2_CLIENTE|F2_LOJA|F2_XNOMECL|F2_EMISSAO|F2_VEND1|F2_HORA|F2_XVEND1|F2_XTOTAL|F2_XBOLETO|'

	If Alltrim(cCampo) $ _cCampos
		_lRet := .T.
	EndIf

Return _lRet  
