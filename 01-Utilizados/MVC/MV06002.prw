#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: MV06002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 28/08/2024
===============================================================================================================================
Descriï¿½ï¿½o---------: Este programa serve para gerar as liquidacoes das NOTAS GERADAS
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
user function MV06002()

	private cCadastro 	:= '[MV06002] - Integrar Boletas Geradas',;
			aBrows		as object,;
			oCabec		as object,;
			cAlisCab	:= getNextAlias(),;
			cTableCab	as char,;
			oBrowse		as object

	private	oMark		as object

	//campos e titulos dos cabecalhos gerando o objeto oCabec
	CriaEstrutura()

	//Obtenho o nome "verdadeiro" da tabela no BD (criada como temporaria)
	cTableCab  :=  oCabec:GetRealName()

	//carregar dados
	MsgRun("Carregando dados de pedidos...",,{||CursorWait(),U_MV06002B(),CursorArrow()})

	//Montagem do browser
	//oBrowse:=  FwMBrowse():New()
	oBrowse:= FWMarkBrowse():New()
	oBrowse:setDescription(cCadastro) 
	oBrowse:setAlias(cAlisCab) 
	oBrowse:setWalkThru(.F.)
	oBrowse:setAmbiente(.T.) 
	oBrowse:setTemporary(.T.)
	oBrowse:setFields(aBrows)

	oBrowse:SetIgnoreARotina(.T.)
	oBrowse:SetMenuDef('MV06002')

    oBrowse:SetSemaphore(.T.)	//defini se utiliza controle de marcacao exclusiva
    oBrowse:SetFieldMark( 'OK' )
	oBrowse:SetAllMark({||finvert()})

	oBrowse:Activate()

    oBrowse:DeActivate()
    FreeObj((cAlisCab))
    FreeObj(oBrowse)

return

//menu da rotina
static function MenuDef()

    local aRot	as array

	aRot:= {}
	add option aRot title 'Liquidar' action 'U_MV06002A()' operation 8 access 0
	add option aRot title 'Refresh' action 'U_MV06002B()' operation 8 access 0

return (aclone(aRot))

//modelo de dados MVC 
static function ModelDef()
	local	oModel	as object,;
			osCabec	as object,;
			nX		as numeric,;
			bPre	as variant,;
			bPos	as variant,;
			bLoad	as variant

	oModel	:= nil
	osCabec	:= FWFormModelStruct():new()
	bPre	:= {|oModel,cAction,cIDField,xValue| validPre(oModel,cAction,cIDField,xValue)}
	bPos	:= {|oModel,|fieldValidPos(oModel)}
	bLoad	:= {|oModel, lCopy| loadField(oModel,lCopy)}

	for nX := 1 to Len(aBrows)
		aBrows[nX,6]=.F.
	next
	osCabec:addTable(cAlisCab, {'SERIE','NOTA'}, cCadastro)

    /*----------------------------------------------------------------------
    Estrutura do array para montagem dos campos usados na funcao MntStrut
        1 - Descricao
        2 - Nome do Campo
        3 - Tipo do campo
        4 - Tamanho do campo
        5 - Decimal
        6 - Se campo e editavel
    ------------------------------------------------------------------------*/
     MntStrut(@osCabec,cAlisCab,aBrows)  
 
	osCabec:AddTable(cAlisCab,, cCadastro, {|| oCabec:GetRealName()})

	oModel  :=  FWFormModel():New( 'MV06002_MVC',,,{|oModel| commit()},{|oModel| cancel()})   

	oModel:addFields( 'ID_M_FLD',, osCabec,bPre,bPos,bLoad)
     
return oModel

//monta estrutura de dados do modeldef
static function MntStrut(oObj,cAlias, aCampos)
    local	nX	as numeric

    default aCampos := {}
 
	for nX := 1 to Len(aCampos)
		oObj:AddField(;
			aCampos[nX,1],;                                                                                  // [01]  C   Titulo do campo
			aCampos[nX,1],;                                                                                  // [02]  C   ToolTip do campo
			aCampos[nX,2],;                                                                                  // [03]  C   Id do Field
			aCampos[nX,3],;                                                                                  // [04]  C   Tipo do campo
			aCampos[nX,4],;                                                                                  // [05]  N   Tamanho do campo
			aCampos[nX,5],;                                                                                  // [06]  N   Decimal do campo
			nil,;                                                                                            // [07]  B   Code-block de validação do campo
			nil,;                                                                                            // [08]  B   Code-block de validação When do campo
			{},;                                                                                             // [09]  A   Lista de valores permitido do campo
			.F.,;                                                                                            // [10]  L   Indica se o campo tem preenchimento obrigatório
			FwBuildFeature( STRUCT_FEATURE_INIPAD, "iif(!INCLUI,('"+cAlias+"')->"+aCampos[nX,2]+",'')" ),;   // [11]  B   Code-block de inicializacao do campo
			.T.,;                                                                                            // [12]  L   Indica se trata-se de um campo chave
			aCampos[nX,6],;                                                                                  // [13]  L   Indica se o campo pode receber valor em uma operação de update.
			.F.;                                                                                             // [14]  L   Indica se o campo é virtual
		)

		if aCampos[nX,6]
			oObj:SetProperty(aCampos[nX,2], MODEL_FIELD_WHEN, { || .T.})
			oObj:SetProperty(aCampos[nX,2], MODEL_FIELD_NOUPD,.F.)
		endif
	next
return

//funcoes ponto de entrada
static function validPre(oModel, cAction, cIDField, xValue)
    Local lRet  :=  .T.
 
    oModel:GetModel():SetErrorMessage('MV06002_MVC', 'NUMPED')
return lRet

static function fieldValidPos(oModel)
    Local lRet  :=  .T.
 
    oModel:GetModel():SetErrorMessage('MV06002_MVC', 'NUMPED')
return lRet
 
static function loadField(oModel, lCopy)
	local 	aLoad		as array,;
			nI			as numeric,;
			aLine		as array,;
			xValue		as variant

	aLoad:= {}
	aLine:= {}

	for nI  :=  1 to Len(aBrows)
		If aBrows[nI][3] == "C"
			xValue  :=  (cAlisCab)->&(aBrows[nI,2])
		Elseif aBrows[nI][3] == "D"
			xValue  :=  StoD((cAlisCab)->&(aBrows[nI,2]))
		Elseif aBrows[nI][3] == "N"
			xValue  :=  (cAlisCab)->&(aBrows[nI,2])
		Else
			xValue  :=  .F.
		Endif

		aadd(aLine, xValue)
	next
		
	aadd(aLoad, aLine) //dados
	aadd(aLoad, 1) //recno
return aLoad

//visao de dados MVC para montagem de tela
static function ViewDef()
	Local	oModel	:= FWLoadModel('MV06002_MVC'),;
			osCabec	:= FWFormViewStruct():New(),;
			oView	as object,;
			nX		as numeric,;
			aDadCab	as array

	/*----------------------------------------------------------------------
	Estrutura do array para montagem dos campos usados na funcao MntView
		1 - Nome do Campo
		2 - Ordem
		3 - Titulo do campo
		4 - Tipo do campo
		5 - Picture
		6 - Se campo e editavel
	------------------------------------------------------------------------*/

	for nX := 1 to Len(aBrows)
		if aBrows[nX,3] == "C"
			cPict := "@!"
		elseif aBrows[nX,3] == "N"
			cPict := "@E 9,999,999,999,999.99"
		else
			cPict := ""
		endif
		aadd(aDadCab,{aBrows[nX,2],StrZero(nX,2),aBrows[nX,1],aBrows[nX,3],cPict,.F.})
	next

	MntView(@osCabec,aDadCab)

	oView:= FWFormView():New()
	oView:setModel(oModel)

	oView:addField('ID_V_FLD', osCabec,'ID_M_FLD')

	//Colocando título do formulário
	oView:enableTitleView('ID_V_FLD', cCadastro)  
	oView:setCloseOnOk({||.T.})

return oView

//funco para montar estrutura de dados para view
static function MntView(oObj,aCampos)
	local	nX	as numeric

	for nX := 1 to Len(aCampos)
		//Adicionando campos da estrutura
		oObj:AddField(;
			aCampos[nX,1],;                  // [01]  C   Nome do Campo
			aCampos[nX,2],;                  // [02]  C   Ordem
			aCampos[nX,3],;                  // [03]  C   Titulo do campo
			aCampos[nX,3],;                  // [04]  C   Descricao do campo
			Nil,;                            // [05]  A   Array com Help
			aCampos[nX,4],;                  // [06]  C   Tipo do campo
			aCampos[nX,5],;                  // [07]  C   Picture
			Nil,;                            // [08]  B   Bloco de PictTre Var
			Nil,;                            // [09]  C   Consulta F3
			aCampos[nX,6],;                  // [10]  L   Indica se o campo é alteravel
			Nil,;                            // [11]  C   Pasta do campo
			Nil,;                            // [12]  C   Agrupamento do campo
			Nil,;                            // [13]  A   Lista de valores permitido do campo (Combo)
			Nil,;                            // [14]  N   Tamanho maximo da maior opção do combo
			Nil,;                            // [15]  C   Inicializador de Browse
			Nil,;                            // [16]  L   Indica se o campo é virtual
			Nil,;                            // [17]  C   Picture Variavel
			Nil;                             // [18]  L   Indica pulo de linha após o campo
		)
	next
 
return

//funcao que cria a estrutura do browser
static function CriaEstrutura()
	local 	aCposCab	as array,;
			aTitulos	as array

	aCposCab:= CriaCampo()
	aTitulos:= CriaTitulos()

	//gerar as colunas do browser
	aBrows:= gerCpBrow(aCposCab,aTitulos)
	if oCabec <> nil
		oCabec:Delete()
		oCabec:= nil
	endif
	oCabec:= FWTemporaryTable():new(cAlisCab)
	oCabec:setFields(aCposCab)
	oCabec:addIndex("1", {'SERIE','NOTA'})
	oCabec:create()
		
return

static function CriaCampo()
	local	aCposCab	as array
	
	aCposCab:= {}
	aadd(aCposCab,{'SERIE','C',3,0,''})
	aadd(aCposCab,{'NOTA','C',9,0,''})
	aadd(aCposCab,{'VALOR','N',16,2,'@E 9,999,999,999,999.99'})
	aadd(aCposCab,{'EMISSAO','D',8,0,''})
	aadd(aCposCab,{'CODCLIENTE','C',8,0,''})
	aadd(aCposCab,{'LOJACLI','C',4,0,''})
	aadd(aCposCab,{'CLIENTE','C',40,0,''})
	aadd(aCposCab,{'OK','C',2,0,''})

return aCposCab

static function CriaTitulos()
	local	aTitulos	as array
	
	aTitulos:= {}
	aadd(aTitulos,'Série Doc.')
	aadd(aTitulos,'Num.Doc.')
	aadd(aTitulos,'Valor')
	aadd(aTitulos,'Dt. Emissão')
	aadd(aTitulos,'Cod. Cliente')
	aadd(aTitulos,'Loja Cliente')
	aadd(aTitulos,'Cliente')
	aadd(aTitulos,'OK')

return aTitulos

//funcao para  gerar as colunas do browser
static function gerCpBrow(aCampos,aTitulos)
    local	nX		as numeric,;
			aBrows	as array
 
	aBrows:= {}
    for nX := 1 to len(aCampos)
    	aadd(aBrows,{aTitulos[nX], aCampos[nX,1] ,aCampos[nX,2] ,aCampos[nX,3] ,aCampos[nX,4], aCampos[nX,5]})
    next

return aBrows

//populando grid
user function MV06002B()
	local	aArea		:= fWGetArea(),;
			cPerg		:= 'MV06002'

	local	aCampos		as array,;
			cQry		as char

	pAjustaSx1(cPerg)

	if Pergunte(cPerg)

		aCampos:= CriaCampo()

		dbSelectArea(cAlisCab)
		(cAlisCab)->(dbGoTop())
		while !(cAlisCab)->(eof())
			(cAlisCab)->(dbDelete())
			(cAlisCab)->(dbSkip())
		enddo
		PACK

		cQry:=  'exec dbo.PR_MV06002A @dtini = '+char(39)+dtos(mv_par01)+char(39)+', @pNovo = "A"'

		if select('TMP1') <> 0
			dbSelectArea('TMP1')
			TB1->(dbCloseArea())
		endif
		
		TCQUERY cQry NEW ALIAS 'TMP1'
		
		dbSelectArea('TMP1')
		TMP1->(dbGoTop())
		while !TMP1->(eof())

			dbSelectArea(cAlisCab)
			(cAlisCab)->(dbSetOrder(1))
			if (Reclock((cAlisCab),.T.))
				(cAlisCab)->EMISSAO		:= stod(TMP1->F2_EMISSAO)
				(cAlisCab)->CODCLIENTE	:= TMP1->F2_CLIENTE
				(cAlisCab)->LOJACLI		:= TMP1->F2_LOJA
				(cAlisCab)->CLIENTE		:= TMP1->A1_NOME
				(cAlisCab)->SERIE		:= TMP1->F2_SERIE
				(cAlisCab)->NOTA		:= TMP1->F2_DOC
				(cAlisCab)->VALOR		:= TMP1->F2_VALOR
				(cAlisCab)->(MsUnLock())
			endif

			TMP1->(dbSkip())
		enddo
		TMP1->(dbCloseArea())
		FWRestArea(aArea)
		(cAlisCab)->(dbGoTop())
	endif
return

//funcoes das acoes programadas
user function MV06002A()			//Botao Liquidar

	local	aArea		:= fWGetArea()

	local	cMarca		as object,;
			aTituloSel	as array,;
			aTituloGer	as array,;
			cQry		as char,;
			lRet		as logical,;
			nValTitSel	as numeric,;
			nValTitGer	as numeric,;
			cMsg		as char,;
			cNotaOrig	as char

	
	lRet		:= .F.
	cMsg		:= ''
	cNotaOrig	:= ''

	cMarca:= oMark:mark()
	dbSelectArea(cAlisCab)
	(cAlisCab)->(dbSetOrder(1))
	(cAlisCab)->(dbGoTop())
	while !(cAlisCab)->(eof())
		aTituloSel:= {}
		aTituloGer:= {}
		nValTitGer:= 0
		nValTitSel:= 0

		if oMark:IsMark(cMarca)

			//buscando os titulos originais
			cQry:=  'exec dbo.PR_MV06002C @SERIE = '+char(39)+(cAlisCab)->SERIE+char(39)+', @NOTA = '+chr(39)+(cAlisCab)->NOTA+char(39)+''

			if select('TMP2') <> 0
				dbSelectArea('TMP2')
				TMP2->(dbCloseArea())
			endif
			
			TCQUERY cQry NEW ALIAS 'TMP2'
			
			dbSelectArea('TMP2')
			TMP2->(dbGoTop())
			while !TMP2->(eof())
				cNotaOrig:= TMP2->NOTA

				SE1->(dbSelectArea('SE1'))
				SE1->(dbSetOrder(1))
				SE1->(dbGoTop())
				if SE1->(dbSeek(fwxFilial('SE1')+cNotaOrig))
					while !SE1->(eof()) .and. alltrim(SE1->E1_TIPO) == 'NF'.and. SE1->E1_PREFIXO + SE1->E1_NUM == cNotaOrig 
						if SE1->E1_SALDO > 0
							aadd(aTituloSel,{SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_VALOR})
							nValTitSel+= SE1->E1_SALDO
						endif
						SE1->(dbSkip())
					enddo
					SE1->(dbCloseArea())
				endif

				TMP2->(dbSkip())
			enddo
			TMP2->(dbCloseArea())

			//buscar os titulos a serem gerados
			cQry:=  'exec dbo.PR_MV06002B @SERIE = '+char(39)+(cAlisCab)->SERIE+char(39)+', @NOTA = '+chr(39)+(cAlisCab)->NOTA+char(39)+''

			if select('TMP2') <> 0
				dbSelectArea('TMP2')
				TMP2->(dbCloseArea())
			endif
			
			TCQUERY cQry NEW ALIAS 'TMP2'
			
			dbSelectArea('TMP2')
			TMP2->(dbGoTop())
			while !TMP2->(eof())
				aadd(aTituloGer,{TMP2->E1_FILIAL,TMP2->E1_PREFIXO,TMP2->E1_NUM,TMP2->E1_PARCELA,TMP2->E1_TIPO,TMP2->E1_CLIENTE,TMP2->E1_LOJA,stod(TMP2->E1_VENCTO),TMP2->E1_VALOR})
				nValTitGer+= TMP2->E1_VALOR
				TMP2->(dbSkip())
			enddo
			TMP2->(dbCloseArea())

			if nValTitSel = 0
				if empty(cMsg)
					cMsg:= 'Titulos não integrados:'+CRLF
				endif
				cMsg+= (cAlisCab)->SERIE+(cAlisCab)->NOTA+' Já integrado ou baixado! '+CRLF
			
			elseif nValTitSel <> nValTitGer
				if empty(cMsg)
					cMsg:= 'Titulos não integrados:'+CRLF
				endif
				cMsg+= (cAlisCab)->SERIE+(cAlisCab)->NOTA+' Valores divergentes '+transform(nValTitSel,'@E 999,999,999,999,999.99')+' - '+transform(nValTitGer,'@E 999,999,999,999,999.99')+CRLF
			
			else
				lRet:= u_rd06011(aTituloSel,aTituloGer)
				if !lRet
					if empty(cMsg)
						cMsg:= 'Titulos não integrados:'+CRLF
					endif
					cMsg+= (cAlisCab)->SERIE+(cAlisCab)->NOTA+' Valor '+transform(nValTitGer,'@E 999,999,999,999,999.99')+' ==>> OUTROS MOTIVOS'+CRLF
				endif
			endif

			if reclock((cAlisCab),.F.)
				(cAlisCab)->OK:= ''
				(cAlisCab)->(MsUnLock())
			endif

		endif 
		(cAlisCab)->(dbSkip())
	enddo

	FWRestArea(aArea)

	if !Empty(cMsg)
		DEFINE MSDIALOG oDlg TITLE "Validação Liquidação" From 000,000 TO 350,400 Pixel
		@ 005,005 GET oMemo VAR cMsg MEMO SIZE 150,150 OF oDlg PIXEL
		oMemo:bRClicked := {||AllwaysTrue()}
		DEFINE SBUTTON FROM 005,165 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTER
	else
		u_msgInforma('Liquidação finalizada com sucesso!','[MV06002]')
	endif

return

static function pAjustaSx1(cPerg)

//	local lRet

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Data mínima:'			, /*cPerSpa		*/ 'Data mínima:'			, /*cPerEng		*/ 'Data mínima:'			, ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'D'						, 											  ;
				/*nTamanho	*/ 8						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 							, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par01'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

return
