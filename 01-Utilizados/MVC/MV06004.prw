#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: MV06004
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/03/2026
===============================================================================================================================
Descriï¿½ï¿½o-----: Este programa serve para CONFERENCIA DE PEDIDOS DE VENDAS DO DIA
===============================================================================================================================
Uso---------------: FINANCEIRO
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
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
user function MV06004()

	private cCadastro 	:= '[MV06004] - Conferencia de Pedidos',;
			aBrows		as object,;
			oCabec		as object,;
			cAlisCab	as char,;
			cTableCab	as char,;
			oBrowse		as object

	private	oMark		as object
	
	cAlisCab	:= getNextAlias()

	//campos e titulos dos cabecalhos gerando o objeto oCabec
	Estruct()

	//Obtenho o nome "verdadeiro" da tabela no BD (criada como temporaria)
	cTableCab  :=  oCabec:GetRealName()

	//carregar dados
	U_MV06004B()

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
	oBrowse:SetMenuDef('MV06004')

    oBrowse:SetSemaphore(.T.)	//defini se utiliza controle de marcacao exclusiva
    //oBrowse:SetFieldMark( 'CONCILIADO' )
	//oBrowse:SetAllMark({||finvert()})
	oBrowse:AddMarkColumns(;
            {|| iif((cAlisCab)->CONCILIADO, 'LBOK', 'LBNO') },;      //ícones
            {|| fMarcaReg()};   //ao dar duplo clique
        )

	oBrowse:Activate()

    oBrowse:DeActivate()
    FreeObj((cAlisCab))
    FreeObj(oBrowse)

return

//menu da rotina
static function MenuDef()

    local aRot	as array

	aRot:= {}
	add option aRot title 'Refresh' action 'U_MV06004B()' operation 8 access 0
	add option aRot title 'Mapa' action 'U_MV06004D()' operation 8 access 0
	add option aRot title 'Excel' action 'U_MV06004C()' operation 8 access 0

return (aclone(aRot))

//modelo de dados MVC 
static function ModelDef()

	local	oModel			as object,;
			osCabec			as object,;
			nX				as numeric,;
			bPre			as variant,;
			bPos			as variant,;
			bLoad			as variant

	//Documentos em Abertos
	oModel	:= nil
	osCabec	:= FWFormModelStruct():new()
	bPre	:= {|oModel,cAction,cIDField,xValue| validPre(oModel,cAction,cIDField,xValue)}
	bPos	:= {|oModel,|fValid(oModel)}
	bLoad	:= {|oModel, lCopy| loadField(oModel,lCopy)}

	for nX := 1 to Len(aBrows)
		aBrows[nX,6]=.F.
	next
	osCabec:addTable(cAlisCab, {'NOTA'}, cCadastro)

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

	oModel  :=  FWFormModel():New( 'MV06004_MVC',,,{|oModel| commit()},{|oModel| cancel()})   

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
 
    oModel:GetModel():SetErrorMessage('MV06004_MVC', 'NOTA')

return lRet

static function fValid(oModel)
    Local lRet  :=  .T.
 
    oModel:GetModel():SetErrorMessage('MV06004_MVC', 'NOTA')

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
		
	aadd(aLoad, aLine) 	//dados
	aadd(aLoad, 1) 		//recno

return aLoad

//visao de dados MVC para montagem de tela
static function ViewDef()
	Local	oModel	:= FWLoadModel('MV06004_MVC'),;
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
static function Estruct()
	local 	aCposCab	as array,;
			aTitulos	as array

	aCposCab:= CriaCampo()
	aTitulos:= CriaTit()

	//gerar as colunas do browser
	aBrows:= gerCpBrow(aCposCab,aTitulos)
	if oCabec <> nil
		oCabec:Delete()
		oCabec:= nil
	endif
	
	oCabec:= FWTemporaryTable():new(cAlisCab)
	oCabec:setFields(aCposCab)
	oCabec:addIndex('1', {'NOTA'})
	oCabec:create()

return

static function CriaCampo()
	local	aCposCab	as array
	
	aCposCab:= {}
	aadd(aCposCab,{'TIPO','C',15,0,''})
	aadd(aCposCab,{'NOTA','C',15,0,''})
	aadd(aCposCab,{'EMISSAO','D',8,0,''})
	aadd(aCposCab,{'CLIENTE','C',55,0,''})
	aadd(aCposCab,{'VALOR','N',16,2,'@E 9,999,999,999,999.99'})
	aadd(aCposCab,{'SALDO','N',16,2,'@E 9,999,999,999,999.99'})
	aadd(aCposCab,{'CONDPAGTO','C',49,0,''})
	aadd(aCposCab,{'VENDEDOR','C',60,0,''})
	aadd(aCposCab,{'USUARIO','C',60,0,''})
	aadd(aCposCab,{'CONCILIADO','L',1,0,''})
	//aadd(aCposCab,{'OK','C',2,0,''})

return aCposCab

static function CriaTit()
	local	aTitulos	as array
	
	aTitulos:= {}
	aadd(aTitulos,'Tipo')
	aadd(aTitulos,'Num.Doc.')
	aadd(aTitulos,'Dt. Emissão')
	aadd(aTitulos,'Cliente')
	aadd(aTitulos,'Valor')
	aadd(aTitulos,'Saldo')
	aadd(aTitulos,'Cond. Pagto')
	aadd(aTitulos,'Vendedor')
	aadd(aTitulos,'Usuário')
	aadd(aTitulos,'Conciliado')
	//aadd(aTitulos,'OK')

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
user function MV06004B(lRetorno)
	local	cPerg		as caracter,;
			lOk			as logical

	default lRetorno := .F.

	lOk 	:= .F.
	cPerg	:= 'MV06004'

	pAjustaSx1(cPerg)

	if !lRetorno
		lOk := Pergunte(cPerg)
	else
		lOk := .T.
	endif

	if lOk
		msgRun('Carregando dados ...!!!',,{||CursorWait(), CarregaDados(), CursorArrow()})
	endif

return

static function CarregaDados()
	local	aCampos		as array,;
			cQry		as char

	aCampos:= CriaCampo()

	dbSelectArea(cAlisCab)
	(cAlisCab)->(dbGoTop())
	while !(cAlisCab)->(eof())
		(cAlisCab)->(dbDelete())
		(cAlisCab)->(dbSkip())
	enddo
	PACK

	cQry:=  "exec dbo.PR_MV06004B @dtini = '" + dtos(mv_par01) + "', @dtfim = '" + dtos(mv_par02) + "', @sintetico = 'N', @tipo = 0"
	
	tcQuery cQry new alias 'TMP1'
	
	dbSelectArea('TMP1')
	TMP1->(dbGoTop())
	while !TMP1->(eof())

		dbSelectArea(cAlisCab)
		(cAlisCab)->(dbSetOrder(1))
		if (Reclock((cAlisCab),.T.))
			(cAlisCab)->TIPO		:= TMP1->TIPO
			(cAlisCab)->NOTA		:= TMP1->NOTA
			(cAlisCab)->EMISSAO		:= TMP1->EMISSAO
			(cAlisCab)->CLIENTE		:= TMP1->CLIENTE
			(cAlisCab)->VALOR		:= TMP1->VALOR
			(cAlisCab)->SALDO		:= TMP1->SALDO
			(cAlisCab)->CONDPAGTO	:= TMP1->CONDPAGTO
			(cAlisCab)->VENDEDOR	:= TMP1->VENDEDOR
			(cAlisCab)->USUARIO		:= TMP1->USUARIO
			(cAlisCab)->CONCILIADO	:= iif(TMP1->CONCILIADO == 'T',.T.,.F.)
			//(cAlisCab)->OK			:= space(2)
			(cAlisCab)->(MsUnLock())
		endif

		TMP1->(dbSkip())

	enddo
	TMP1->(dbCloseArea())
	
	(cAlisCab)->(dbGoTop())

return nil

user function MV06004C()
	local	cDirDocs	as caracter,;
			nHandle		as numeric,;
			cArquivo	as array,;
			cPath		as caracter,;
			oExcelApp	as object
	
	local	cQry		as caracter,;
			cBody		as caracter,;
			cHeader		as caracter,;
			cTrailer	as caracter,;
			nLinha		as numeric,;
			cConciliado	as caracter

	cDirDocs	:= msDocPath()
	cArquivo	:= CriaTrab(,.F.)
	cPath		:= alltrim(GetTempPath())

	cQry		:= ''
	cBody		:= ''
	cHeader		:= ''
	cTrailer	:= ''
	nLinha		:= 0

	nHandle		:= msfCreate(cDirDocs+'\'+cArquivo+'.xls',0)
	if nHandle > 0
		//cabecalho
		procRegua(reccount())

		//cabecalho   
		cHeader := ' <html> ' 																																+ CRLF 
		cHeader += ' 	<head> ' 																															+ CRLF
		cHeader += '		<title>Editor HTML Online</title> ' 																							+ CRLF
		cHeader += '	</head> ' 																															+ CRLF
		cHeader += '	<body> ' 																															+ CRLF
		cHeader += '		<div> ' 																														+ CRLF
		cHeader += '			<p>&nbsp;</p> ' 																											+ CRLF
		cHeader += '		</div> ' 																														+ CRLF
		cHeader += '		<table style="width: 100%;" border="1" cellpadding="1" cellspacing="1"> ' 														+ CRLF
		cHeader += '			<tbody> ' 																													+ CRLF
	 	cHeader += '				<tr> ' 																													+ CRLF 
		//A - TIPO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> ' 				  			   + CRLF 
		cHeader += '						<strong> Tipo </strong></td> ' 											   										+ CRLF 
		//B - NUMERO DOCUMENTO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Num. Doc. </strong></td> '														+ CRLF 
		//C - EMISSÃO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Emissão </strong></td> ' 														+ CRLF 
		//D - CLIENTE
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Cliente </strong></td> ' 														+ CRLF 
		//E - VALOR
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Valor </strong></td> ' 														+ CRLF 
		//F - COND. PAGTO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Cond Pagto </strong></td> ' 													+ CRLF 
		//G - VENDEDOR
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Vendedor </strong></td> ' 																				+ CRLF 
		//H - USUÁRIO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Usuário </strong></td> ' 																				+ CRLF 
		//I - CONCILIADO
		cHeader += '					<td style="text-align: center; background-color: rgb(204, 204, 204);"> '								+ CRLF 
		cHeader += '						<strong> Conciliado </strong></td> ' 																				+ CRLF 
		cHeader += '				</tr> '  													   															+ CRLF 
		fwrite(nHandle, cHeader)

		nLinha:= 0
		(cAlisCab)->(dbGoTop())
		while !(cAlisCab)->(eof())
			if((cAlisCab)->CONCILIADO)
				cConciliado := "Sim"
			else
				cConciliado := "Não"
			endif
			
			cBody := "				<tr> "
			//0 - A - TIPO
			cBody += "					<td style='text-align: left;	'> &nbsp;" 	+ (cAlisCab)->TIPO			   								+ "</td> "	+ CRLF
			//1 - B - NUMERO DOCUMENTO
			cBody += "					<td style='text-align: left;	'> &nbsp;" 	+ (cAlisCab)->NOTA	  						   				+ "</td> "	+ CRLF
			//2 - C - EMISSÃO
			cBody += "					<td style='text-align: left; 	'> &nbsp;" 	+ dtoc((cAlisCab)->EMISSAO)	  						   		+ "</td> "	+ CRLF
			//3 - D - CLIENTE
			cBody += "					<td style='text-align: left; 	'> &nbsp;" 	+ (cAlisCab)->CLIENTE	  						   			+ "</td> "	+ CRLF
			//4 - E - VALOR
			cBody += "					<td style='text-align: right;	'>  	 "	+ Transform((cAlisCab)->VALOR, x3Picture('E1_VALOR'))		+ "</td> "	+ CRLF
			//5 - F - COND. PAGTO
			cBody += "					<td style='text-align: left; 	'> &nbsp;" 	+ (cAlisCab)->CONDPAGTO										+ "</td> "	+ CRLF
			//6 - G - VENDEDOR
			cBody += "					<td style='text-align: left;  '> &nbsp;" 	+ (cAlisCab)->VENDEDOR										+ "</td> "	+ CRLF
			//7 - H - USUÁRIO
			cBody += "					<td style='text-align: left;  '> &nbsp;" 	+ (cAlisCab)->USUARIO										+ "</td> "	+ CRLF
			//8 - I - CONCILIADO
			cBody += "					<td style='text-align: left;  '> &nbsp;" 	+ cConciliado												+ "</td> "	+ CRLF
			cBody += "				</tr> " 																	 								   			+ CRLF
			fwrite(nHandle, cBody)

			(cAlisCab)->(dbSkip())
		enddo  
		(cAlisCab)->(dbGoTop())

		//rodape
		cTrailer := "				<tr> " 														 		   																				+ CRLF 
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "					<td style='text-align: left; background-color: rgb(204, 204, 204);'> " 	+ " " + "</td> " + CRLF
		cTrailer += "				</tr> " 																	 									   									+ CRLF         
	
		fwrite(nHandle, cTrailer) 
		fClose(nHandle)
		CpyS2T(cDirDocs+'\'+cArquivo+'.xls' , cPath, .T. )   
		
		if ! ApOleClient( 'MsExcel' )
			MsgAlert( "Excel nao instalado!" ) //'MsExcel nao instalado'
			return
		endif
		
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".xls" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
		oExcelApp:destroy()

	endif

return

user function MV06004D()
	U_RD06013()
	U_MV06004B(.T.) //recarrega os dados apos retormo do mapa

return nil

static function fMarcaReg()
	//Marca todos com .F. para limpar a Flag com exceção do registro atual
	//   Necessário baixar o zExecQry em https://terminaldeinformacao.com/2021/04/21/como-fazer-um-update-via-advpl/
	//u_zExecQry("UPDATE " + oTempTable:GetRealName() + " SET FLAG_OK = 'F' WHERE R_E_C_N_O_ != " + cValToChar((cAliasTmp)->(RecNo())) )

	//Atualiza o registro atual, marcando ou desmarcando ele
	(cAlisCab)->CONCILIADO := ! (cAlisCab)->CONCILIADO

	//Atualiza a tela posicionando no topo
	oBrowse:Refresh(.T.)
Return

static function pAjustaSx1(cPerg)

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Data Inicial:'			, /*cPerSpa		*/ 'Data Inicial:'			, /*cPerEng		*/ 'Data Inicial:'			, ;
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

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '02'						, 											  ;
				/*cPergunt	*/ 'Data Final:'			, /*cPerSpa		*/ 'Data Final:'			, /*cPerEng		*/ 'Data Final:'			, ;
				/*cVar		*/ 'mv_ch2'					, /*cTipo 		*/ 'D'						, 											  ;
				/*nTamanho	*/ 8						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 							, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par02'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

return
