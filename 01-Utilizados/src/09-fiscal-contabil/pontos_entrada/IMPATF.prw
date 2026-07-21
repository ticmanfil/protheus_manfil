#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณimpATF	   บAutor ณLeonardo Peixoto บ Data ณ  21/03/16    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao utilizada para importar arquivo de Ativos baseado noบฑฑ
ฑฑบ          ณ Layout pre estabelecido                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function impATF()

	local cArq    := ""
	local cLinha  := ""
	local aDados  := {}
	

	Private aErro := {}
	Private cPerg := Padr("IMPATF",10)

	ValidPerg()
	if !pergunte(cPerg,.T.)
		return
	endif

	cArq := mv_par01
	
	If !File(cArq)
		MsgStop("O arquivo " + cArq + " nใo foi encontrado. A importa็ใo serแ abortada!","ATENCAO")
		Return
	EndIf
	
	MsgRun("Importando arquivo texto. Por favor aguarde...","Processando",{|| aDados := leArq(cArq) })
	 	
	//Chama funcao que importa ativos
	cFilBkp := cFilAnt
	Processa({|lEnd| geraSN1(aDados,@lEnd) },"Importando Ativos","Iniciando...",.T.)	
	cFilAnt := cFilBkp
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณleArq 	   บAutor ณLeonardo Peixoto บ Data ณ  21/03/16    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao utilizada para ler arquivo cvs e formatar dados     บฑฑ
ฑฑบ          ณ conforme rotina precisa                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function leArq(cArq)
	local aRet	:= {}

	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	
	FT_FGOTOP()
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		aadd(aRet,Separa(cLinha,";",.T.))
		incProc("Lendo arquivo texto. Por favor aguarde...")
		FT_FSKIP()
	EndDo
	FT_FUSE()


return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgeraSN1	   บAutor ณLeonardo Peixoto บ Data ณ  21/03/16    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao utilizada para importar arquivo de Ativos baseado noบฑฑ
ฑฑบ          ณ Layout pre estabelecido                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function geraSN1(aDados)
	Local i			:= 0
	Local aCab 		:= {} //Cabecalho Bem SN1
	Local aItens 	:= {} //Valores - SN3
	local aLinhaN3	:= {} //Detalhe do item N3
	Private lMsHelpAuto := .f. // Determina se as mensagens de help devem ser direcionadas para o arq. de log
	Private lMsErroAuto := .f. // Determina se houve alguma inconsistencia na execucao da rotina

	
	ProcRegua(len(aDados))
	
	Begin Transaction
	
	for i :=  2 to len(aDados)
	
		aCab	:= {}
		aItens	:= {}
		aLinhaN3 := {}
		
		//Preenche dados cabecalho 
		cFilSN1 	:= xFilial("SN1") //"01"
		cN1_PATRIM	:= "N"
		cN1_STATUS	:= "1"
		cN1_TPAVP	:= "1"
		aadd(aCab, {'N1_FILIAL' 	,cFilSN1 		,NIL})
		aadd(aCab, {'N1_PATRIM' 	,cN1_PATRIM		,NIL})
		aadd(aCab, {'N1_STATUS' 	,cN1_STATUS		,NIL})
		aadd(aCab, {'N1_TPAVP' 		,cN1_TPAVP		,NIL})
		

		cN1_GRUPO	:= aDados[i,1]
		cN1_CBASE	:= aDados[i,2]
		cN1_ITEM	:= aDados[i,3]
		nN1_QUANTD	:= val(aDados[i,4])
		dN1_AQUISIC	:= ctod(aDados[i,5])
		cN1_DESCRIC	:= substr(aDados[i,6],1,TamSX3('N1_DESCRIC')[01])
		dN1_INIAVP	:= ctod(aDados[i,8])
		cN1_CHAPA	:= aDados[i,7] 
		cN1_LOCAL	:= aDados[i,20]
		cN1_NFISCAL	:= StrZero(Val(aDados[i,21]),9)
		aadd(aCab, {'N1_GRUPO'		,cN1_GRUPO 		,NIL})
		aadd(aCab, {'N1_CBASE'		,cN1_CBASE 		,NIL})
		aadd(aCab, {'N1_ITEM' 		,cN1_ITEM 		,NIL})
		aadd(aCab, {'N1_QUANTD' 	,nN1_QUANTD 	,NIL})
		aadd(aCab, {'N1_AQUISIC' 	,dN1_AQUISIC 	,NIL})
		aadd(aCab, {'N1_DESCRIC' 	,cN1_DESCRIC	,NIL})
		aadd(aCab, {'N1_INIAVP' 	,dN1_INIAVP		,NIL})
		aadd(aCab, {'N1_CHAPA' 		,cN1_CHAPA 		,NIL})
		aadd(aCab, {'N1_LOCAL' 		,cN1_LOCAL 		,NIL})
		aadd(aCab, {'N1_NFISCAL' 	,cN1_NFISCAL 	,NIL})		
	
	
		//Preenche dados de valores - tabela sn3
		cN3_TIPO	:= aDados[i,9]
		cN3_HISTOR	:= substr(aDados[i,10],1,TamSX3('N3_HISTOR')[01])
		cN3_CCONTAB	:= aDados[i,11]
		cN3_CDEPREC	:= aDados[i,12]
		cN3_CCUSTO	:= aDados[i,13]
		cN3_CCDEPR	:= aDados[i,14]
		dN3_DINDEPR	:= ctod(aDados[i,15])
		If At(",",aDados[i,16]) > 0
        	_nValor :=  val(SubStr(aDados[i,16],1,At(",",aDados[i,16])-1)+"."+Right(aDados[i,16],2))
		Else
        	_nValor :=  val(aDados[i,16])		
  		EndIf

		nN3_VORIG1	:= _nValor
		nN3_TXDEPR1	:= val(aDados[i,17])
		
		If At(",",aDados[i,18]) > 0
        	_nValor1 :=  val(SubStr(aDados[i,18],1,At(",",aDados[i,18])-1)+"."+Right(aDados[i,18],2))
		Else
        	_nValor1 :=  val(aDados[i,18])		
  		EndIf
		
		nN3_VRDACM1	:= _nValor1
		dN3_AQUISIC	:= ctod(aDados[i,19])
		
	
		aadd(aLinhaN3, {'N3_TIPO' 		,cN3_TIPO 		, NIL})
		aadd(aLinhaN3, {'N3_HISTOR' 	,cN3_HISTOR 	, NIL})
		aadd(aLinhaN3, {'N3_CCONTAB' 	,cN3_CCONTAB	, NIL})
		aadd(aLinhaN3, {'N3_CDEPREC' 	,cN3_CDEPREC	, NIL})
		aadd(aLinhaN3, {'N3_CCUSTO' 	,cN3_CCUSTO		, NIL})
		aadd(aLinhaN3, {'N3_CCDEPR' 	,cN3_CCDEPR		, NIL})
		aadd(aLinhaN3, {'N3_DINDEPR' 	,dN3_DINDEPR	, NIL})  
		aadd(aLinhaN3, {'N3_VORIG1' 	,nN3_VORIG1 	, NIL})
		aadd(aLinhaN3, {'N3_TXDEPR1' 	,nN3_TXDEPR1 	, NIL})
		aadd(aLinhaN3, {'N3_VRDACM1' 	,nN3_VRDACM1 	, NIL})
		aadd(aLinhaN3, {'N3_AQUISIC' 	,dN3_AQUISIC	, NIL})
		
		//Dados Fixos
		cN3_TPSALDO	:= "1"
		cN3_TPDEPR	:= "1"
		cN3_SEQ		:= "001"
		//cN3_NOVO	:= "S"
		cN3_RATEIO	:= "2"
		cN3_ATFCPR	:= "2"
		nN3_VLSALV1	:= 0
		nN3_PERDEPR	:= 0
		nN3_PRODMES	:= 0
		nN3_PRODANO	:= 0
		cN3_BAIXA	:= "0"
		
		aadd(aLinhaN3, {'N3_TPSALDO'	,cN3_TPSALDO 	, NIL})
		aadd(aLinhaN3, {'N3_TPDEPR' 	,cN3_TPDEPR		, NIL})
		aadd(aLinhaN3, {'N3_SEQ' 		,cN3_SEQ		, NIL})
		//aadd(aLinhaN3, {'N3_NOVO' 		,cN3_NOVO		, NIL})
		aadd(aLinhaN3, {'N3_RATEIO' 	,cN3_RATEIO		, NIL})
		aadd(aLinhaN3, {'N3_ATFCPR' 	,cN3_ATFCPR		, NIL})
		aadd(aLinhaN3, {'N3_VLSALV1' 	,nN3_VLSALV1	, NIL})
		aadd(aLinhaN3, {'N3_PERDEPR' 	,nN3_PERDEPR	, NIL})
		aadd(aLinhaN3, {'N3_PRODMES' 	,nN3_PRODMES	, NIL})
		aadd(aLinhaN3, {'N3_PRODANO' 	,nN3_PRODANO	, NIL})
		aadd(aLinhaN3, {'N3_BAIXA' 		,cN3_BAIXA		, NIL})
		
		aLinhaN3 := FWVetByDic(aLinhaN3, 'SN3')
	
		aAdd(aItens,aLinhaN3)

		MSExecAuto( {|X,Y,Z| ATFA012(X,Y,Z)} ,aCab ,aItens, 3)

		If lMsErroAuto
			lRetorno := .F.
			MostraErro()
		Else
			lRetorno:=.T.
		EndIf
	     
	 	lMsErroAuto:= .F.

		If !lRetorno
			If !MsgYesNo("A rotina apresentou erros, deseja continuar com a importa็ใo?")
				DisarmTransaction()
				Return
			EndIf
		EndIf
	 	
		incProc("Importando registros. Por favor aguarde...")
	next i
	
	End Transaction
	msgInfo(" Importa็ใo do ativo concluida.")
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณvalidPerg	   บAutor  ณLeonardo Peixotoบ Data ณ  21/03/16    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao utilizada para criar grupo de perguntas automatica- บฑฑ
ฑฑบ          ณ mente no dicionado de dados                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function validPerg()

	Local aHelpPor := {}
	Local aHelpSpa := {}
	Local aHelpEng := {}

	//Arquivo a ser importado
	aHelpPor := {}
	Aadd( aHelpPor, 'Selecione o arquivo que deseja')
	Aadd( aHelpPor, 'importar                 ')
	U_xPutSx1(cPerg,"01","Arquivo"," "," ","mv_ch1","C",60,0,0,"G","","DIR","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

return


