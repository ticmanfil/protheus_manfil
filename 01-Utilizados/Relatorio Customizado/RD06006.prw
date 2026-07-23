#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'TbiCode.ch'
#include 'rwmake.ch'
/*/
===============================================================================================================================
Programa----------: RD06006
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 01/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para ENVIAR TITULOS A ADVOGADO E PERDAS
===============================================================================================================================
Uso---------------: FINANCEIRO
===============================================================================================================================
Parametros--------: 
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FINANCEIRO
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
user function RD06006(cAcao)

	chkfile('Z12')

	if cAcao = 1
		Processa({|| RD06006A()}, 'Aguarde! Enviando titulo ao ADVOGADO...',,.T.)
	elseif cAcao = 2
		Processa({|| RD06006B()}, 'Aguarde! Retirando da situação ADVOGADO...',,.T.)
	elseif cAcao = 3
		Processa({|| RD06006C()}, 'Aguarde! Gerando histórico de cessões...',,.T.)
	elseif cAcao = 5
		Processa({|| RD06006E()}, 'Aguarde! Retirando da situação PERDA...',,.T.)
	elseif cAcao = 6
		Processa({|| RD06006F(cAcao)}, 'Aguarde! Preparando para envio de título a ADVOGADO...',,.T.)
	elseif cAcao = 7
		Processa({|| RD06006F(cAcao)}, 'Aguarde! Preparando para envio de título para PERDA...',,.T.)
	endif
	
return

static function RD06006A(nOpcao, cPrefixo, cNum, cParcela, cTipo, cSituac, cSaldo, cErro)
	local	cPortad		:= 'ADV',;
			cAgeDep		:= '00001',;
			cConta		:= '0000000001',;
			cSeq		:= '',;
			cHist		:= ''
			
	if cSaldo <= 0
		cErro	:= 'Titulo já RECEBIDO e não poderá ser enviado!!!'
		return .F.
	elseif nOpcao = 6 .and. cSituac == '5'
		cErro	:= 'Titulo já se encontra no ADVOGADO!!!'
		return .F.
	elseif nOpcao = 7 .and. cSituac == 'L'
		cErro	:= 'Titulo já se encontra em PERDA!!!'
		return .F.
	elseif !cSituac $ '015L'  
		//u_msgErro('Titulo em situação não programado!!!'+chr(13)+chr(10)+'Informa situação ('+cSituac+') ao administrador do sistema antes de continuar.','RD06006 - Envio de Titulos a ADVOGADO')
		cErro	:= 'Titulo em situação não programado!!!'
		return .F.
	endif
	
	if nOpcao = 6
		cSituac		:= '5'
		cHist		:= 'TITULO ENVIADO PARA ADVOGADO'
		cPortad		:= 'ADV'
		cAgeDep		:= '00001'
		cConta		:= '0000000001'
	elseif nOpcao = 7
		cSituac		:= 'L'
		cHist		:= 'TITULO ENVIADO PARA PERDA'
		cPortad		:= 'PER'
		cAgeDep		:= '00001'
		cConta		:= '0000000001'
	endif

	dbSelectArea('Z12')
	Z12->(dbSetOrder(1))
	Z12->(dbGoTop())
	if Z12->(dbSeek(xFilial('Z12')+cPrefixo+cNum+cParcela+cTipo))
		while Z12->(!eof()) .and. Z12->Z12_PREFIX+Z12->Z12_NUM+Z12->Z12_PARCEL+Z12->Z12_TIPO == cPrefixo+cNum+cParcela+cTipo
			cSeq	:= Z12->Z12_SEQ
			Z12->(dbSkip())
		enddo
	else
		cSeq	:= '00'
	endif
	cSeq	:= Strzero(val(cSeq)+1,tamsx3('Z12_SEQ')[1])

	if RecLock('Z12',.T.)
		Z12->Z12_FILIAL	:= XFILIAL('Z12')
		Z12->Z12_PREFIX	:= cPrefixo
		Z12->Z12_NUM	:= cNum
		Z12->Z12_PARCEL	:= cParcela
		Z12->Z12_TIPO	:= cTipo
		Z12->Z12_SEQ	:= cSeq
		Z12->Z12_DATA	:= DDATABASE
		Z12->Z12_SITUAC	:= cSituac
		Z12->Z12_PORTAD	:= cPortad
		Z12->Z12_AG		:= cAgeDep
		Z12->Z12_CONTA	:= cConta
		Z12->Z12_HIST	:= cHist
		Z12->Z12_USR	:= CUSERNAME
		msUnlock()
	endif
	
	if RecLock('SE1',.F.)
		SE1->E1_SITUACA	:= cSituac
		SE1->E1_PORTADO	:= cPortad
		SE1->E1_AGEDEP	:= cAgeDep
		SE1->E1_CONTA	:= cConta
		msUnlock()
	endif

return

static function RD06006B
	//dados do titulo selecionado
	local	cPrefixo	:= space(tamsx3('E1_PREFIXO')[1]),;
			cNum		:= space(tamsx3('E1_NUM')[1]),;
			cParcela	:= space(tamsx3('E1_PARCELA')[1]),;
			cTipo		:= space(tamsx3('E1_TIPO')[1]),;
			cSaldo		:= 0,;
			cSituac		:= '',;
			cPortad		:= '',;
			cAgeDep		:= '',;
			cConta		:= '',;
			cSeq		:= ''

	//recupera os dados do titulo selecionado
	cPrefixo	:= SE1->E1_PREFIXO
	cNum		:= SE1->E1_NUM
	cParcela	:= SE1->E1_PARCELA
	cTipo		:= SE1->E1_TIPO
	cSituac		:= SE1->E1_SITUACA
	cSaldo		:= SE1->E1_SALDO
	
	if cSaldo <= 0
		u_msgErro('Titulo já RECEBIDO e não poderá ser enviado ao ADVGOADO!!!'+chr(13)+chr(10)+'Ação será cancelado.','{RD06006} - Envio de Titulos a ADVOGADO')
		return .F.
	elseif cSituac != '5'
		u_msgErro('Titulo não se encontra no Advogado!!!'+chr(13)+chr(10)+'Ação será cancelado.','{RD06006} - Envio de Titulos a ADVOGADO')
		return .F.
	endif
	cSituac	:= '0'
	
	dbSelectArea('Z12')
	Z12->(dbSetOrder(1))
	Z12->(dbGoTop())
	if Z12->(dbSeek(xFilial('Z12')+cPrefixo+cNum+cParcela+cTipo))
		while Z12->(!eof()) .and. Z12->Z12_PREFIX+Z12->Z12_NUM+Z12->Z12_PARCEL+Z12->Z12_TIPO == cPrefixo+cNum+cParcela+cTipo
			cSeq	:= Z12->Z12_SEQ
			Z12->(dbSkip())
		enddo
	else
		cSeq	:= '00'
	endif
	cSeq	:= Strzero(val(cSeq)+1,tamsx3('Z12_SEQ')[1])

	begin transaction
		if RecLock('Z12',.T.)
			Z12->Z12_FILIAL	:= XFILIAL('Z12')
			Z12->Z12_PREFIX	:= cPrefixo
			Z12->Z12_NUM	:= cNum
			Z12->Z12_PARCEL	:= cParcela
			Z12->Z12_TIPO	:= cTipo
			Z12->Z12_SEQ	:= cSeq
			Z12->Z12_DATA	:= DDATABASE
			Z12->Z12_SITUAC	:= cSituac
			Z12->Z12_PORTAD	:= cPortad
			Z12->Z12_AG		:= cAgeDep
			Z12->Z12_CONTA	:= cConta
			Z12->Z12_HIST	:= 'TITULO RETORNADO DO ADVOGADO'
			Z12->Z12_USR	:= CUSERNAME
			msUnlock()
		endif
		
		if RecLock('SE1',.F.)
			SE1->E1_SITUACA	:= cSituac
			SE1->E1_PORTADO	:= cPortad
			SE1->E1_AGEDEP	:= cAgeDep
			SE1->E1_CONTA	:= cConta
			msUnlock()
		endif

	end transaction

	u_msgInforma('Titulo RETORNADO do ADVOGADO com sucesso!','{RD06006} - Envio de Titulos a ADVOGADO')
return


static function RD06006C
	local	aObjects	:= {},;
			aPosObj		:= {},;
			aSizeAut  	:= MsAdvSize(),;
			nOpc 		:= GD_UPDATE,; //GD_INSERT + GD_UPDATE + GD_DELETE 
			oDlg,;
			oSay1,;
			oButton2,;
			cTitulo		:= ''

	private	aHeader	:= {},;
			aCols	:= {}

	mnHeader()
	mnDados()
	
	cTitulo	:= '[RD06006] - HISTÓRICO DE CESSÕES'

	aadd( aObjects, { 343, 200, .T., .T. } ) //Browse
	aadd( aObjects, { 280, 007, .T., .F. } ) //Linha horizontal
	aadd( aObjects, { 040, 010, .F., .F. } ) //Botao
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7]  ,00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	oBrw:= MsNewGetDados():New(aPosObj[1,2],aPosObj[1,1] -30,aPosObj[1,3],aPosObj[1,4],nOpc, "AllwaysTrue", "AllwaysTrue","" ,/*{'TOTALANALIS','B1_CUSTO'}*/,, 999, "AllwaysTrue", "",  "AllwaysFalse", oDlg  ,aHeader, aCols, ) // {||  GChange(nMarg), oBrw:Refresh() })

	//oBrw:oBrowse:bChange := { ||  GChange(nMarg) }

	oBrw:SetArray(aCols)
	oBrw:Refresh(.T.)
	oBrw:oBrowse:lUseDefaultColors := .F. // Desabilita cor padrao das linhas

	oBrw:SetEditLine(.T.)

	//oBrw:bDelOk:={||AlterDados(2)}

	//Linha horizontal
	@ 203, 005 SAY oSay1 PROMPT Repl("_",295) SIZE 280, 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL
	@ aPosObj[2,1], aPosObj[2,2] SAY oSay1 PROMPT Repl("_",aPosObj[1,4]) SIZE aPosObj[1,4], 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL

	@ aPosObj[3,1], aPosObj[1,4] - 40 BUTTON oButton2 PROMPT "Sair" SIZE 040, 010 OF oDlg ACTION oDlg:End() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

return

static function mnDados()
	local 	cQuery		:= '',;
			nvLinha		:= 0,;
			nLinha		:= 0

	local	cPrefixo	:= space(tamsx3('E1_PREFIXO')[1]),;
			cNum		:= space(tamsx3('E1_NUM')[1]),;
			cParcela	:= space(tamsx3('E1_PARCELA')[1]),;
			cTipo		:= space(tamsx3('E1_TIPO')[1])

	//recupera os dados do titulo selecionado
	cPrefixo	:= SE1->E1_PREFIXO
	cNum		:= SE1->E1_NUM
	cParcela	:= SE1->E1_PARCELA
	cTipo		:= SE1->E1_TIPO

	
	if select('TB01') <> 0
		dbSelectArea('TB01')
		TB01->(dbCloseArea())
	endif
	
	cQuery	:= 'exec dbo.PR_RD06006 @FILIAL = '+chr(39)+xFilial('Z12')+chr(39)+', @PREFIXO = '+chr(39)+cPrefixo+chr(39)+', @NUMERO = '+chr(39)+cNum+chr(39)+', @PARCELA = '+char(39)+cParcela+chr(39)+', @TIPO = '+chr(39)+cTipo+chr(39)

	TCQUERY cQuery NEW ALIAS 'TB01'
	
	dbSelectArea('TB01')
	TB01->(dbGoTop())

	nvLinha		:= 0
	nLinha		:= 0
	while TB01->(!eof())
		nvLinha	:= len(aCols)+1
		aadd(aCols,array((len(aHeader)+1)))
		aCols[nvLinha][len(aHeader)+1]	:= .F.
		nLinha:= len(aCols)
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='Z12_SEQ'})]		:= TB01->Z12_SEQ								//1
		aCols[nLinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='Z12_DATA'})]	:= stod(TB01->Z12_DATA)							//2
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='Z12_HIST'})]	:= TB01->Z12_HIST								//3
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='Z12_PORTAD'})]	:= TB01->Z12_PORTAD								//4
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='Z12_AG'})]		:= TB01->Z12_AG									//5
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='Z12_CONTA'})]	:= TB01->Z12_CONTA								//6
		aCols[nlinha,ascan(aHeader, {|x| upper(alltrim(x[2]))=='Z12_USR'})]		:= TB01->Z12_USR								//7
		
		TB01->(dbSkip())
	enddo
	TB01->(dbCloseArea())

return


static function mnHeader()
	if empty(aHeader)

		aadd(aHeader,{u_ux3Titulo('Z12_SEQ')		,'Z12_SEQ'			, x3Picture('Z12_SEQ')			, tamSx3('Z12_SEQ')[1]			, tamSx3('Z12_SEQ')[2]			, '', '', 'C', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('Z12_DATA')		,'Z12_DATA'			, x3Picture('Z12_DATA')			, tamSx3('Z12_DATA')[1]			, tamSx3('Z12_DATA')[2]			, '', '', 'D', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('Z12_HIST')		,'Z12_HIST'			, x3Picture('Z12_HIST')			, tamSx3('Z12_HIST')[1]			, tamSx3('Z12_HIST')[2]			, '', '', 'C', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('Z12_PORTAD')		,'Z12_PORTAD'		, x3Picture('Z12_PORTAD')		, tamSx3('Z12_PORTAD')[1]		, tamSx3('Z12_PORTAD')[2]		, '', '', 'C', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('Z12_AG')			,'Z12_AG'			, x3Picture('Z12_AG')			, tamSx3('Z12_AG')[1]			, tamSx3('Z12_AG')[2]			, '', '', 'C', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('Z12_CONTA')		,'Z12_CONTA'		, x3Picture('Z12_CONTA')		, tamSx3('Z12_CONTA')[1]		, tamSx3('Z12_CONTA')[2]		, '', '', 'C', '', 'V'})
		aadd(aHeader,{u_ux3Titulo('Z12_USR')		,'Z12_USR'			, x3Picture('Z12_USR')			, tamSx3('Z12_USR')[1]			, tamSx3('Z12_USR')[2]			, '', '', 'C', '', 'V'})

	endif
return


static function RD06006E
	//dados do titulo selecionado
	local	cPrefixo	:= space(tamsx3('E1_PREFIXO')[1]),;
			cNum		:= space(tamsx3('E1_NUM')[1]),;
			cParcela	:= space(tamsx3('E1_PARCELA')[1]),;
			cTipo		:= space(tamsx3('E1_TIPO')[1]),;
			cSaldo		:= 0,;
			cSituac		:= '',;
			cPortad		:= '',;
			cAgeDep		:= '',;
			cConta		:= '',;
			cSeq		:= ''

	//recupera os dados do titulo selecionado
	cPrefixo	:= SE1->E1_PREFIXO
	cNum		:= SE1->E1_NUM
	cParcela	:= SE1->E1_PARCELA
	cTipo		:= SE1->E1_TIPO
	cSituac		:= SE1->E1_SITUACA
	cSaldo		:= SE1->E1_SALDO
	
	if cSaldo <= 0
		u_msgErro('Titulo já RECEBIDO e não poderá ser enviado a PERDA!!!'+chr(13)+chr(10)+'Ação será cancelado.','RD06006 - Envio de Titulos a PERDA')
		return .F.
	elseif cSituac != 'L'
		u_msgErro('Titulo não se encontra na situação PERDA!!!'+chr(13)+chr(10)+'Informa situação ('+cSituac+') ao administrador do sistema antes de continuar.','RD06006 - Envio de Titulos a PERDA')
		return .F.
	endif
	cSituac	:= '0'
	
	dbSelectArea('Z12')
	Z12->(dbSetOrder(1))
	Z12->(dbGoTop())
	if Z12->(dbSeek(xFilial('Z12')+cPrefixo+cNum+cParcela+cTipo))
		while Z12->(!eof()) .and. Z12->Z12_PREFIX+Z12->Z12_NUM+Z12->Z12_PARCEL+Z12->Z12_TIPO == cPrefixo+cNum+cParcela+cTipo
			cSeq	:= Z12->Z12_SEQ
			Z12->(dbSkip())
		enddo
	else
		cSeq	:= '00'
	endif
	cSeq	:= Strzero(val(cSeq)+1,tamsx3('Z12_SEQ')[1])

	begin transaction
		if RecLock('Z12',.T.)
			Z12->Z12_FILIAL	:= XFILIAL('Z12')
			Z12->Z12_PREFIX	:= cPrefixo
			Z12->Z12_NUM	:= cNum
			Z12->Z12_PARCEL	:= cParcela
			Z12->Z12_TIPO	:= cTipo
			Z12->Z12_SEQ	:= cSeq
			Z12->Z12_DATA	:= DDATABASE
			Z12->Z12_SITUAC	:= cSituac
			Z12->Z12_PORTAD	:= cPortad
			Z12->Z12_AG		:= cAgeDep
			Z12->Z12_CONTA	:= cConta
			Z12->Z12_HIST	:= 'TITULO RETORNADO DA PERDA'
			Z12->Z12_USR	:= CUSERNAME
			msUnlock()
		endif
		
		if RecLock('SE1',.F.)
			SE1->E1_SITUACA	:= cSituac
			SE1->E1_PORTADO	:= cPortad
			SE1->E1_AGEDEP	:= cAgeDep
			SE1->E1_CONTA	:= cConta
			msUnlock()
		endif

	end transaction

	u_msgInforma('Titulo RETORNADO da PERDA com sucesso!','[RD06006] - Envio de Titulos para PERDA')
return


static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Cliente?" 		,"."     ,"."       ,"mv_ch1","C",8,0,0,"G","","SA1","","","mv_par01","","","","","","","","","","","","","","","","")

return

static function RD06006F(nOpcao)

	local	cPerg		:= 'RD06006',;
			cCliente	:= space(tamsx3('E1_CLIENTE')[1]),;
			dVencto		:= DDATABASE
			
	local	aCpos		:= {},;
			aCampos		:= {},;
			nI			:= 0,;
			cMark		:= GetMark(,'SE1','E1_OK'),;
			aQryRes		:= {},;
			oMark
	
	private	aRotina 	:= {},;
			cCadastro 	:= '',;
			cFiltro		:= '',;
			bFiltraBrw	:= {|| nil},;
			bProc 		:= {|| FProc(nOpcao) }

	if nOpcao = 6
		cCadastro	:= 'Enviando Titulo a ADVOGADO'
	elseif nOpcao = 7
		cCadastro	:= 'Enviando Titulo a PERDA'
	endif
	
	AjustaSx1(cPerg)
	
	if !Pergunte(cPerg, .T.)
		return .F.
	else
		cCliente	:= mv_par01
		dVencto		:= mv_par02
	end

	aadd(aRotina,{'Processar','eval(bProc)',0,5})

	//limpa todos os registros que estao com esta marca
 	//cQry	:= 'exec dbo.PR_RD06006A @CMARK = '+chr(39)+cMark+chr(39)
	aQryRes	:= tcSpExec('PR_RD06006A',cMark)
	
 	cFiltro	:= 'E1_CLIENTE == '+chr(39)+alltrim(cCliente)+chr(39)+'	'
 	cFiltro	+= '.and. E1_SALDO > 0	'
 	cFiltro	+= '.and. !(E1_TIPO $ '+char(39)+'RA NCC'+chr(39)+') '
 	cFiltro	+= '.and. E1_SITUACA # '+chr(39)+'5'+chr(39)+'	'
 	
 	bFiltraBrw	:= {|| FilBrowse('SE1',{ },@cFiltro) }
 	Eval(bFiltraBrw)
 	
	aadd(aCpos, "E1_OK"			)
	aadd(aCpos, "E1_PREFIXO" 	)
	aadd(aCpos, "E1_NUM" 		)
	aadd(aCpos, "E1_PARCELA" 	)
	aadd(aCpos, "E1_TIPO" 		)
	aadd(aCpos, "E1_CLIENTE" 	)
	aadd(aCpos, "E1_LOJA" 		)
	aadd(aCpos, "E1_NOMCLI" 	)
	aadd(aCpos, "A1_EMISSAO" 	)
	aadd(aCpos, "A1_VENCTO" 	)
	aadd(aCpos, "A1_VALOR" 		)
	aadd(aCpos, "A1_SALDO" 		)

	dbSelectArea("SX3")
	dbSetOrder(2)
	for nI := 1 to len(aCpos)
		if dbSeek(aCpos[nI])
			aadd(aCampos,{X3_CAMPO,"",IIF(nI==1,"",Trim(X3_TITULO)),Trim(X3_PICTURE)})
		endif
	next nI
   
	dbSelectArea('SE1')
 	set filter to &(cFiltro)

 	oMark	:= MarkBrow('SE1',aCpos[1],,aCampos,.F., cMark,FAll(oMark,cMark))

	dbSelectArea('SE1')
	set filter to 
return nil

static function FProc(nOpcao)
 
	local	cPrefixo	:= space(tamsx3('E1_PREFIXO')[1]),;
			cNum		:= space(tamsx3('E1_NUM')[1]),;
			cParcela	:= space(tamsx3('E1_PARCELA')[1]),;
			cTipo		:= space(tamsx3('E1_TIPO')[1]),;
			cSaldo		:= 0,;
			cSituac		:= space(tamsx3('E1_SITUACA')[1]),;
			cMark 		:= ThisMark(),;
			cQry		:= '',;
			cMsg		:= {},;
			aQryRes		:= {}
	
	private	cErro		:= ''
			
 	cQry 	:= " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCTO, E1_VALOR, E1_SITUACA, E1_SALDO	"
	cQry 	+= " FROM "+RetSqlName("SE1")+"  SE1						 									"
	cQry 	+= " WHERE  D_E_L_E_T_ = ' ' 								 									"
	cQry 	+= " AND E1_FILIAL = '"+xFilial("SE1") +"' 														"
	cQry 	+= " AND E1_OK = '"+cMark +"' 																	"
	
	TcQuery cQry new alias 'TMSE1'
		
	begin transaction
		dbSelectArea('TMSE1')
		while !TMSE1->(eof())
		
			//recupera os dados do titulo selecionado
			cPrefixo	:= TMSE1->E1_PREFIXO
			cNum		:= TMSE1->E1_NUM
			cParcela	:= TMSE1->E1_PARCELA
			cTipo		:= TMSE1->E1_TIPO
			cSituac		:= TMSE1->E1_SITUACA
			cSaldo		:= TMSE1->E1_SALDO

			dbSelectArea('SE1')
			SE1->(dbSetOrder(1))
			if SE1->(dbSeek(xFilial('SE1')+cPrefixo+cNum+cParcela+cTipo))
				if nOpcao = 6
					if !RD06006A(nOpcao, cPrefixo, cNum, cParcela, cTipo, cSituac, cSaldo)
						aadd(cMsg,{'Titulo não enviado. '+cPrefixo+cNum+cParcela+cTipo+cErro})
					endif
				elseif nOpcao = 7
					if !RD06006A(nOpcao, cPrefixo, cNum, cParcela, cTipo, cSituac, cSaldo)
						aadd(cMsg,{'Titulo não enviado. '+cPrefixo+cNum+cParcela+cTipo+cErro})
					endif
				endif
				
			endif
			
			dbSelectArea('TMSE1')
			TMSE1->(dbSkip())
		enddo 
		
		TMSE1->(DbCloseArea())

	end transaction
	
	//limpa todos os registros que estao com esta marca
 	//cQry	:= 'exec dbo.PR_RD06006A @CMARK = '+chr(39)+cMark+chr(39)
	aQryRes	:= tcSpExec('PR_RD06006A',cMark)

	if nOpcao = 6
		u_msgInforma('Titulo enviado para ADVOGADO com sucesso!','RD06006 - Envio de Titulos a ADVOGADO')
	elseif nOpcao = 7 
		u_msgInforma('Titulo enviado para PERDA com sucesso!','RD06006 - Envio de Titulos a ADVOGADO')
	endif
	
	CloseBrowse()

 return
 

 static function FAll(oMark, cMark)
 	SE1->(dbGoTop())
 	while !SE1->(eof())
 		if RecLock('SE1',.F.)
 			SE1->E1_OK	:= cMark
 			SE1->(msUnlock())
 		endif
 		SE1->(dbSkip())
 	enddo
 	if !empty(oMark)
 		oMark:oBrowser:Refresh()
 	endif
 return .T.
