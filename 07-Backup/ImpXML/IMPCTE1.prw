#INCLUDE 'Protheus.ch'
#INCLUDE 'TOPConn.ch'
//#INCLUDE 'COMXCOL.ch'
#INCLUDE "FILEIO.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPCTE1   บAutor  ณ TOTVS TMAPs		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monitor de Compras para Totvs                              บฑฑ
ฑฑบ          ณ Fonte com as funcoes do monitor e engines de Compras para  บฑฑ
ฑฑบ          ณ TOTVS.	                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Compras                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER Function IMPCTE1()
	Local aCores  	:= {}
	Local aIndSDS	:= {}
	Local lRet    	:= .T.
	Local lInverte	:= .F.
	Local cFilBrw	:= ""
	Local cFilSQL	:= ""
	
	Private DIRXML		:= "NFEENT\"
	Private DIRALER		:= "NEW\"
	Private DIRLIDO 	:= "OLD\"
	Private DIRERRO 	:= "ERR\"
	Private aRotina	  	:= MenuDef()
	Private cMarca	  	:= GetMark()
	Private cCadastro 	:= "Monitor Importa็ใo XML Entrada"
	Private _aValores	:= {}
	Private cCondPag	:= ""   
	Private cIniFile	:= GetADV97()
	Private cStartPath 	:= GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFEENT\ENTRADA\'
	Private cStartLido	:= Trim(cStartPath)+"OLD\"
	Private c2StartPath	:= Trim(cStartLido)+AllTrim(Str(Year(Date())))+"\"
	Private c3StartPath	:= Trim(c2StartPath)+AllTrim(Str(Month(Date())))+"\"	//MES    
	Private c4StartPath := Trim(c3StartPath)+AllTrim(Str(Day(Date())))+"\"
	Private c5StartPath := Trim(c4StartPath)+alltrim(str(POSICIONE("SM0",1,cNumEmp,AllTrim(SM0->M0_CGC))))+"\"
	Private cStartError	:= Trim(cStartPath)+"ERRO\"
	
   //	U_MEST003() 
	U_MEST002()      
	
	//CRIA DIRETORIOS
	MakeDir(GetPvProfString(GetEnvServer(),"StartPath","ERROR", cIniFile )+'NFEENT\')
	MakeDir(Trim(cStartPath)) //CRIA DIRETOTIO ENTRADA
	MakeDir(cStartLido) //CRIA DIRETORIO ARQUIVOS IMPORTADOS
	MakeDir(c2StartPath) //CRIA DIRETOTIO ANO
	MakeDir(c3StartPath) //CRIA DIRETOTIO MES    
	MakeDir(c4StartPath) //CRIA DIRETORIO DIA
	MakeDir(c5StartPath) //CRIA DIRETORIO CNPJ
	MakeDir(cStartError) //CRIA DIRETORIO ERRO
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ mv_par01: Documento de 					ณ
	//ณ mv_par02: Documento ate 				ณ
	//ณ mv_par03: Serie de 						ณ
	//ณ mv_par04: Serie ate 					ณ
	//ณ mv_par05: Fornecedor de 				ณ
	//ณ mv_par06: Fornecedor ate 				ณ
	//ณ mv_par07: Emissao de 					ณ
	//ณ mv_par08: Emissao ate 					ณ
	//ณ mv_par09: Importacao de 				ณ
	//ณ mv_par10: Importacao ate 				ณ
	//ณ mv_par11: Mostra gerados: 1=Sim ; 2=Nao	ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lRet .And. Pergunte("MTA140I",.T.)
		aAdd(aCores,{'DS_STATUS	== "P"','BR_VERMELHO'})	// -- "Documento Gerado"
		aAdd(aCores,{'DS_STATUS	== "E"','BR_PRETO'})	// -- "Documento c/ Ocorr๊ncia"
		aAdd(aCores,{'DS_TIPO 	== "N" .AND. DS_STATUS = "L"','BR_VERDE'})	// -- "Documento Normal"
		aAdd(aCores,{'DS_TIPO 	== "O"','BR_AZUL'})		// -- "Docto. de Bonifica็ใo"
		aAdd(aCores,{'DS_TIPO 	== "D"','BR_AMARELO'})	// -- "Docto. de Devolu็ใo"
		aAdd(aCores,{'DS_TIPO 	== "B"','BR_CINZA'})	// -- "Docto. de Beneficiamento"
		aAdd(aCores,{'DS_TIPO 	== "C"','BR_PINK'})		// -- "Docto. de Compl. Pre็o"
		aAdd(aCores,{'DS_TIPO 	== "T"','BR_LARANJA'})	// -- "Docto. de Transporte"
		aAdd(aCores,{'DS_TIPO 	== "N" .AND. DS_STATUS = " "','BR_VIOLETA'})
		
		//-- Monta filtro ISAM
		cFilBrw := "DS_DOC 				>= '" + mv_par01 		+ "' And DS_DOC 			<= '" + mv_par02 		+ "' And "
		cFilBrw += "DS_SERIE 			>= '" + mv_par03 		+ "' And DS_SERIE 			<= '" + mv_par04 		+ "' And "
		cFilBrw += "DS_FORNEC 			>= '" + mv_par05 		+ "' And DS_FORNEC 			<= '" + mv_par06 		+ "' And "
		cFilBrw += "DS_EMISSA		 	>= '" + DToS(mv_par07) 	+ "' And DS_EMISSA		 	<= '" +DToS(mv_par08) 	+ "' And "
		cFilBrw += "DS_DATAIMP			>= '" + DToS(mv_par09) 	+ "' And DS_DATAIMP			<= '" +DToS(mv_par10) 	+ "' "
		If mv_par11 == 2
			cFilBrw += " And DS_STATUS <> 'P'"
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializa o filtro                                                    ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//		CHKFILE("SDS")
//		CHKFILE("SDT")
		dbSelectArea("SDS")
		dbSetOrder(1)
		//Importa XML
		MsgRun("Aplicando filtros e preparando inferface","Aguarde",{|| CursorWait(),,CursorArrow(),MarkBrow("SDS","DS_OK",'DS_STATUS == "P"',,lInverte,cMarca,'MarkAll()',,,,,,cFilBrw,,aCores)})
		//MsgRun("Aplicando filtros e preparando inferface","Aguarde",{|| CursorWait(),,CursorArrow(),MarkBrow("SDS","DS_OK",'DS_STATUS == "P"',,lInverte,cMarca,'MarkAll()',,,,,,,,aCores)})
		
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บAutor  ณ TOTVS TMAP 		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta as opcoes de rotina.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ COMXCOL                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
	Local aRotAlt		:= {}
	PRIVATE aRotina	:= {}
	
	aAdd(aRotina,{"Pesquisar"	,"PesqBrw"		,0,1,0,.F.}) 					// Pesquisar
	aAdd(aRotina,{"Visualizar"	,"StaticCall(IMPCTE1,Visualizar)"	,0,2,0,NIL})	// Visualizar
	aAdd(aRotina,{"Vinc. Docto"	,"StaticCall(IMPCTE1,Vincular)"		,0,4,0,nil})	// Vinc. Docto
	aAdd(aRotina,{"Gerar Docto"	,"StaticCall(IMPCTE1,GerarDocs)"	,0,4,0,nil}) 	// Gerar Docto
	aAdd(aRotina,{"Imp. XML"	,"MSGRUN('Importando XML','Processando',{||U_ImpManual()})"						,0,3,0,nil})  	// Importar XML
	aAdd(aRotina,{"Excluir"		,"StaticCall(IMPCTE1,Excluir)"		,0,4,0,nil})   	// Excluir
	aAdd(aRotina,{"Reprocessar"	,"StaticCall(IMPCTE1,Reprocessa)"	,0,3,0,nil})	// Reprocessar
	aAdd(aRotina,{"Legenda"		,"StaticCall(IMPCTE1,Legenda)"		,0,5,0,.F.})	// Legenda
	aAdd(aRotina,{"Conf Recebi"	,"StaticCall(IMPCTE1,Recebiment)"	,0,5,0,.F.})	// Recebimento
	
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVisualizarบAutor  ณ TOTVS TMAP 		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta interface pra visualizacao do documento.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPCTE1                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Visualizar()
Return MontaTela(2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVisualizarบAutor  ณ TOTVS TMAP 		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta interface pra visualizacao do documento.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPCTE1                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Recebiment()
Local lRet:=.T.
	If !Alltrim(SDS->DS_STATUS) == ""
		Aviso("Aten็ใo","Documento jแ com recebimento confirmado.",{"OK"}) //-- Aten็ใo # Esta a็ใo nใo pode ser executada para documentos jแ gerados.
		lRet := .F.
	EndIf

	If lRet
		If MsgYesNo("Confirma o recebimento dos produtos do documento Selecionado?","Aten็ใo")
			RecLock("SDS",.F.)
				SDS->DS_STATUS	:="L"
				SDS->DS_XULIB	:=CUSERNAME
				SDS->DS_XDLIB	:=dDataBase
			msUnLock()
			MsgInfo("Confirmado Recebimento dos produtos da nota")
		EndIf
	EndIF
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Vincular บAutor  ณ TOTVS TMAP 		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta interface vinculo do documento com pedidos/nf origem.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPCTE1                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Vincular()
	Local lRet := .T.
	Local lRemet := .F.
	
	If SDS->DS_TIPO == "T" .And. SDS->DS_TPFRETE == "F" // Verifica se e CT-e e se e remetente da mercadoria (saida), neste caso deve permitir vincular pedido
		lRemet := .T.
	EndIf
	
	If SDS->DS_STATUS == "P"
		Aviso("Aten็ใo","Esta a็ใo nใo pode ser executada para documentos jแ gerados.",{"OK"}) //-- Aten็ใo # Esta a็ใo nใo pode ser executada para documentos jแ gerados.
		lRet := .F.
	EndIf
	
	If Alltrim(SDS->DS_STATUS) == ""
		Aviso("Aten็ใo","Documento nao confirmado o recebimento, favor confirmar antes de Vincular.",{"OK"}) //-- Aten็ใo # Esta a็ใo nใo pode ser executada para documentos jแ gerados.
		lRet := .F.
	EndIf
	
	If !(SDS->DS_TIPO $ "NDC")
		If !lRemet							// Quando for CT-e referente a envio de mercadoria deve permitir vinculo com pedido, caso contrario nao deve permitir
			Aviso("Aten็ใo","Esta a็ใo pode ser executada apenas para documentos do tipo Normal, Devolu็ใo, Complemento ou CT-e referente a envio de mercadoria.",{"OK"})	//-- Aten็ใo # Esta a็ใo pode ser executada apenas para documentos do tipo Normal, Devolu็ใo, Complemento ou CT-e referente a envio de mercadoria.
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		lRet := MontaTela(4)
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaTela บAutor  ณTOTVS TMAP          บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta interface de visualiza็ใo e vinculo do documeto.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nOpc: opcao de rotina acionada (2=Visualizar;4Vincular)	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Visualizar e Vincular                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaTela(nOpc)
	
	Local lRet   		:= .F.	
	Local oEnchoice 	:= NIL
	Local oFolder		:= NIL
	Local oComboFrt 	:= NIL
	Local oSize     	:= FwDefSize():New()
	Local aCpsAlt		:= {}
	Local aNoFields 	:= {}
	Local aButtons  	:= {}
	Local aPosCab   	:= {}
	Local aPosIts   	:= {}
	Local aPosRdp		:= {}
	Local aFolders  	:= {"Totais","Dados DANFE","Dados da NF-e","Dados da Importa็ใo","Dados da Importa็ใo","Ocorr๊ncia","Financeiro"} 
	Local cSeek	    	:= ""
	Local bWhile		:= {|| SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE)}
	Local nTotDoc		:= SDS->(DS_VALMERC+DS_DESPESA+DS_FRETE+DS_SEGURO-DS_DESCONT)
	Local nX			:= 0
	Local oGetDados 	:= NIL
	Local aColsAnt  	:= {}
	Local cFilBkp   	:= cFilAnt
	Local lRemet		:= .F.
	
	Private oDlg      	:= NIL
	Private aHeader  	:= {}
	Private aCols	  	:= {}
	
	If nOpc == 4
		aCpsAlt		:= {"DT_NFORI","DT_SERIORI","DT_ITEMORI","DT_XTES","DT_XCC","DT_XCONTA","DT_COD","DT_XTES"}
	ELSEIf nOpc == 2
		aCpsAlt		:= {"DT_XTES","DT_XCC","DT_XCONTA"}
	ELSE
		aCpsAlt		:= {}
	ENDIF
	
	//-- Se filial diferente, troca
	If PadR(cFilAnt,Len(AllTrim(SDS->DS_FILIAL))) # AllTrim(SDS->DS_FILIAL)
		Do Case
		Case FWModeAccess("SB2",3) == "E"
			cFilAnt := SDS->DS_FILIAL
		Case FWModeAccess("SB2",2) == "E" .Or. FWModeAccess("SB2",1) == "E"
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cEmpAnt+SDS->DS_FILIAL))
			cFilAnt := SM0->M0_CODFIL
		EndCase
	EndIf
	
	cSeek := xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
	
	oSize:AddObject("CABEC",100,20,.T.,.T.) // Totalmente dimensionavel
	oSize:AddObject("ITENS",100,55,.T.,.T.) // Totalmente dimensionavel
	oSize:AddObject("RODAP",100,25,.T.,.T.) // Totalmente dimensionavel
	oSize:lProp := .T. 						 // Proporcional
	oSize:aMargins := {0,0,0,3}			  	 // Espaco ao lado dos objetos 0, entre eles 3
	oSize:Process() 	   					 // Dispara os calculos de coordenadas
	
	aPosCab := {oSize:GetDimension("CABEC","LININI"),oSize:GetDimension("CABEC","COLINI"),;
		oSize:GetDimension("CABEC","LINEND"),oSize:GetDimension("CABEC","COLEND")}
	aPosIts := {oSize:GetDimension("ITENS","LININI"),oSize:GetDimension("ITENS","COLINI"),;
		oSize:GetDimension("ITENS","LINEND"),oSize:GetDimension("ITENS","COLEND")}
	aPosRdp := {oSize:GetDimension("RODAP","LININI"),oSize:GetDimension("RODAP","COLINI"),;
		oSize:GetDimension("RODAP","LINEND"),oSize:GetDimension("RODAP","COLEND")}
	
	//-- Tratamento para que seja possivel alterar os campos da nota origem
	If nOpc == 4 .And. SDS->DS_TIPO $ "DC"
		aRotina[2,4] := 6
	EndIf
	
	// Verifica se e CT-e e se e remetente da mercadoria (saida), neste caso deve exibir os campos para vinculo com pedido
	If SDS->DS_TIPO == "T" .And. SDS->DS_TPFRETE == "F"
		lRemet := .T.
	EndIf
	
	//-- Retira campos que nao sao usados pelo tipo de documento
	If SDS->DS_TIPO $ "DC"
		aNoFields := {"DT_PEDIDO","DT_ITEMPC"}
	ElseIf SDS->DS_TIPO == "N"
		aNoFields := {"DT_NFORI","DT_SERIORI","DT_ITEMORI"}
	ElseIf SDS->DS_TIPO == "T"
		If lRemet
			aNoFields := {"DT_PRODFOR","DT_DESCFOR","DT_NFORI","DT_SERIORI","DT_ITEMORI"}
		Else
			aNoFields := {"DT_PRODFOR","DT_DESCFOR","DT_PEDIDO","DT_ITEMPC","DT_NFORI","DT_SERIORI","DT_ITEMORI"}
		EndIf
	Else
		aNoFields := {"DT_PEDIDO","DT_ITEMPC","DT_NFORI","DT_SERIORI","DT_ITEMORI"}
	EndIf
	
	RegToMemory("SDS",.F.,.T.)
	FillGetDados(2,"SDT",3,cSeek,bWhile,,aNoFields,,,,,.F.,aHeader,aCols)
	aSort(aCols,,,{|x,y| x[GDFieldPos("DT_ITEM")] < y[GDFieldPos("DT_ITEM")]}) //-- Ordena por item
	aColsAnt := aClone(aCols)
	Define MsDialog oDlg From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4];
		Title "Monitor Importa็ใo CT-e" + " - " +If(nOpc == 2,"Visualiza็ใo","Vincular Documento") Of oMainWnd Pixel
	
	oEnchoice := MsMGet():New("SDS",,2,,,,,aPosCab,,,,,,oDlg)
	oGetDados := MsGetDados():New(aPosIts[1],aPosIts[2],aPosIts[3],aPosIts[4],4,,,,,aCpsAlt,,,9999,,,,,oDlg)
	oFolder   := TFolder():New(aPosRdp[1],aPosRdp[2],aFolders,,oDlg,,,,.T.,,aPosRdp[4]-aPosRdp[2],aPosRdp[3]-aPosRdp[1])
	
	//-- Montagem dos campos do rodape
	
	//-- Vlr. Mercadoria
	TSay():New(10,10,{|| RetTitle("DS_VALMERC")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
	TGet():New(08,70,{|| SDS->DS_VALMERC},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_VALMERC"),,,,,,,.T.,,,,,,,.T.,,,"DS_VALMERC")
	//-- Vlr. Frete
	TSay():New(30,10,{|| RetTitle("DS_FRETE")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
	TGet():New(28,70,{|| SDS->DS_FRETE},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_FRETE"),,,,,,,.T.,,,,,,,.T.,,,"DS_FRETE")
	//-- Vlr. Seguro
	TSay():New(10,180,{|| RetTitle("DS_SEGURO")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
	TGet():New(08,250,{|| SDS->DS_SEGURO},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_SEGURO"),,,,,,,.T.,,,,,,,.T.,,,"DS_SEGURO")
	//-- Vlr. Despesas
	TSay():New(30,180,{|| RetTitle("DS_DESPESA")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
	TGet():New(28,250,{|| SDS->DS_DESPESA},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_DESPESA"),,,,,,,.T.,,,,,,,.T.,,,"DS_DESPESA")
	//-- Descontos
	TSay():New(10,350,{|| RetTitle("DS_DESCONT")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
	TGet():New(08,430,{|| SDS->DS_DESCONT},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_DESCONT"),,,,,,,.T.,,,,,,,.T.,,,"DS_DESCONT")
	//-- Total do documento
	TSay():New(70,10,{|| "Total do documento"},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
	TGet():New(68,70,{|| nTotDoc},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_VALMERC"),,,,,,,.T.,,,,,,,.T.,,,"nTotDoc")
	
	//-- Transportadora
	TSay():New(10,10,{|| RetTitle("DS_TRANSP")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(08,50,{|| SDS->DS_TRANSP},oFolder:aDialogs[2],40,10,PesqPict("SDS","DS_TRANSP"),,,,,,,.T.,,,,,,,.T.,,,"DS_TRANSP")
	//-- Placa
	TSay():New(30,10,{|| RetTitle("DS_PLACA")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(28,50,{|| SDS->DS_PLACA},oFolder:aDialogs[2],40,10,PesqPict("SDS","DS_PLACA"),,,,,,,.T.,,,,,,,.T.,,,"DS_PLACA")
	//-- Peso Liquido
	TSay():New(10,110,{|| RetTitle("DS_PLIQUI")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(08,160,{|| SDS->DS_PLIQUI},oFolder:aDialogs[2],70,10,PesqPict("SDS","DS_PLIQUI"),,,,,,,.T.,,,,,,,.T.,,,"DS_PLIQUI")
	//-- Peso Bruto
	TSay():New(30,110,{|| RetTitle("DS_PBRUTO")},oFolder:aDialogs[2],,,,,,.T.,,,5400,10)
	TGet():New(28,160,{|| SDS->DS_PBRUTO},oFolder:aDialogs[2],70,10,PesqPict("SDS","DS_PBRUTO"),,,,,,,.T.,,,,,,,.T.,,,"DS_PBRUTO")
	//-- Tipo de frete
	TSay():New(50,10,{|| RetTitle("DS_TPFRETE")},oFolder:aDialogs[2],,,,,,.T.,,,5400,10)
	oComboFrt := TComboBox():New(48,50,{|| SDS->DS_TPFRETE},{"C=CIF","F=FOB","T=Por Terceiros","S=Sem Frete"},70,10,oFolder:aDialogs[2],,,,,,.T.,,,,,,,,,"DS_TPFRETE")
	oComboFrt:Disable()
	//-- Especie 1
	TSay():New(10,290,{|| RetTitle("DS_ESPECI1")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(08,330,{|| SDS->DS_ESPECI1},oFolder:aDialogs[2],90,10,PesqPict("SDS","DS_ESPECI1"),,,,,,,.T.,,,,,,,.T.,,,"DS_ESPECI1")
	//-- Especie 2
	TSay():New(30,290,{|| RetTitle("DS_ESPECI2")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(28,330,{|| SDS->DS_ESPECI2},oFolder:aDialogs[2],90,10,PesqPict("SDS","DS_ESPECI2"),,,,,,,.T.,,,,,,,.T.,,,"DS_ESPECI2")
	//-- Especie 3
	TSay():New(50,290,{|| RetTitle("DS_ESPECI3")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(48,330,{|| SDS->DS_ESPECI3},oFolder:aDialogs[2],90,10,PesqPict("SDS","DS_ESPECI3"),,,,,,,.T.,,,,,,,.T.,,,"DS_ESPECI3")
	//-- Especie 4
	TSay():New(70,290,{|| RetTitle("DS_ESPECI4")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(68,330,{|| SDS->DS_ESPECI4},oFolder:aDialogs[2],90,10,PesqPict("SDS","DS_ESPECI4"),,,,,,,.T.,,,,,,,.T.,,,"DS_ESPECI4")
	//-- Volume 1
	TSay():New(10,440,{|| RetTitle("DS_VOLUME1")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(08,480,{|| SDS->DS_VOLUME1},oFolder:aDialogs[2],50,10,PesqPict("SDS","DS_VOLUME1"),,,,,,,.T.,,,,,,,.T.,,,"DS_VOLUME1")
	//-- Volume 2
	TSay():New(30,440,{|| RetTitle("DS_VOLUME2")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(28,480,{|| SDS->DS_VOLUME2},oFolder:aDialogs[2],50,10,PesqPict("SDS","DS_VOLUME2"),,,,,,,.T.,,,,,,,.T.,,,"DS_VOLUME2")
	//-- Volume 3
	TSay():New(50,440,{|| RetTitle("DS_VOLUME3")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(48,480,{|| SDS->DS_VOLUME3},oFolder:aDialogs[2],50,10,PesqPict("SDS","DS_VOLUME3"),,,,,,,.T.,,,,,,,.T.,,,"DS_VOLUME3")
	//-- Volume 4
	TSay():New(70,440,{|| RetTitle("DS_VOLUME4")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
	TGet():New(68,480,{|| SDS->DS_VOLUME4},oFolder:aDialogs[2],50,10,PesqPict("SDS","DS_VOLUME4"),,,,,,,.T.,,,,,,,.T.,,,"DS_VOLUME4")
	
	//-- Chave NF-e
	TSay():New(10,10,{|| RetTitle("DS_CHAVENF")},oFolder:aDialogs[3],,,,,,.T.,,,50,10)
	TGet():New(08,70,{|| SDS->DS_CHAVENF},oFolder:aDialogs[3],230,10,PesqPict("SDS","DS_CHAVENF"),,,,,,,.T.,,,,,,,.T.,,,"DS_CHAVENF")
	//-- Versao NF-e
	TSay():New(30,10,{|| RetTitle("DS_VERSAO")},oFolder:aDialogs[3],,,,,,.T.,,,50,10)
	TGet():New(28,70,{|| SDS->DS_VERSAO},oFolder:aDialogs[3],50,10,PesqPict("SDS","DS_VERSAO"),,,,,,,.T.,,,,,,,.T.,,,"DS_VERSAO")
	//-- Nome do arquivo
	TSay():New(50,10,{|| RetTitle("DS_ARQUIVO")},oFolder:aDialogs[3],,,,,,.T.,,,50,10)
	TGet():New(48,70,{|| SDS->DS_ARQUIVO},oFolder:aDialogs[3],230,10,PesqPict("SDS","DS_ARQUIVO"),,,,,,,.T.,,,,,,,.T.,,,"DS_ARQUIVO")
	
	//-- Usuario
	TSay():New(10,10,{|| RetTitle("DS_USERIMP")},oFolder:aDialogs[4],,,,,,.T.,,,50,10)
	TGet():New(08,70,{|| SDS->DS_USERIMP},oFolder:aDialogs[4],100,10,PesqPict("SDS","DS_USERIMP"),,,,,,,.T.,,,,,,,.T.,,,"DS_USERIMP")
	//-- Data
	TSay():New(30,10,{|| RetTitle("DS_DATAIMP")},oFolder:aDialogs[4],,,,,,.T.,,,50,10)
	TGet():New(28,70,{|| SDS->DS_DATAIMP},oFolder:aDialogs[4],50,10,PesqPict("SDS","DS_DATAIMP"),,,,,,,.T.,,,,,,,.T.,,,"DS_DATAIMP")
	//-- Hora
	TSay():New(50,10,{|| RetTitle("DS_HORAIMP")},oFolder:aDialogs[4],,,,,,.T.,,,50,10)
	TGet():New(48,70,{|| SDS->DS_HORAIMP},oFolder:aDialogs[4],50,10,PesqPict("SDS","DS_HORAIMP"),,,,,,,.T.,,,,,,,.T.,,,"DS_HORAIMP")
	
	//-- Usuario
	TSay():New(10,10,{|| RetTitle("DS_USERPRE")},oFolder:aDialogs[5],,,,,,.T.,,,50,10)
	TGet():New(08,70,{|| SDS->DS_USERPRE},oFolder:aDialogs[5],100,10,PesqPict("SDS","DS_USERPRE"),,,,,,,.T.,,,,,,,.T.,,,"DS_USERPRE")
	//-- Data
	TSay():New(30,10,{|| RetTitle("DS_DATAPRE")},oFolder:aDialogs[5],,,,,,.T.,,,50,10)
	TGet():New(28,70,{|| SDS->DS_DATAPRE},oFolder:aDialogs[5],50,10,PesqPict("SDS","DS_DATAPRE"),,,,,,,.T.,,,,,,,.T.,,,"DS_DATAPRE")
	//-- Hora
	TSay():New(50,10,{|| RetTitle("DS_HORAPRE")},oFolder:aDialogs[5],,,,,,.T.,,,50,10)
	TGet():New(48,70,{|| SDS->DS_HORAPRE},oFolder:aDialogs[5],50,10,PesqPict("SDS","DS_HORAPRE"),,,,,,,.T.,,,,,,,.T.,,,"DS_HORAPRE")
	
	//-- Ocorrencia
	TMultiGet():New(10,10,{|| SDS->DS_DOCLOG},oFolder:aDialogs[6],aPosRdp[4]*0.96,oFolder:nHeight*0.35,,,,,,.T.,,,,,,.T.)
	
	//Folder Financeiro
	
	cCondPag	:= IIF(!EMPTY(SDS->DS_XCONDPG),SDS->DS_XCONDPG,SPACE(3))
	TSay():New(10,10,{|| RetTitle("DS_XCONDPG")},oFolder:aDialogs[7],,,,,,.T.,,,50,10)
	@ 008, 070 MSGET oGet1 VAR cCondPag SIZE 030, 010 OF oFolder:aDialogs[7] F3 "SE4" COLORS 0, 16777215 PIXEL WHEN .T.
	
	cNatureza	:= IIF(!EMPTY(SDS->DS_XNATURE),SDS->DS_XNATURE,SPACE(10))
	TSay():New(30,10,{|| RetTitle("DS_XNATURE")},oFolder:aDialogs[7],,,,,,.T.,,,50,10)
	@ 028, 070 MSGET oGet1 VAR cNatureza SIZE 050, 010 OF oFolder:aDialogs[7] F3 "SED" COLORS 0, 16777215 PIXEL WHEN .T.
	
	@ 000,160 ListBox oBoxLib Fields Headers "Dt. Vencto","Valor  " Size 150,60 Pixel of oFolder:aDialogs[7]

	oBoxLib:SetArray(_aValores)
	oBoxLib:bLine := {|| {	_aValores[oBoxLib:nAt,1],;
							_aValores[oBoxLib:nAt,2]}} 

	oBoxLib:bLDblClick := {||TelaVenc()}
								
	GridVenc()
		
	
	If nOpc == 4 .And. ( SDS->DS_TIPO $ "DCN" .Or. lRemet )
		aAdd(aButtons, {"PEDIDO", {|| Documentos(aCols[n,GDFieldPos("DT_COD",aHeader)],.F.)}, If(SDS->DS_TIPO $ "NT","Pedido de Compra (Item)","Documento Origem"),If(SDS->DS_TIPO $ "NT","PC (Item)","Origem")})
		If SDS->DS_TIPO $ "NT"
			aAdd(aButtons, {"SOLICITA", {|| Documentos(aCols[n,GDFieldPos("DT_COD",aHeader)],.T.)},"Pedido de Compra (Doc.)","PC (Doc.)"}) //-- Pedido de Compra (Doc.) # PC (Doc.)
		EndIf
	EndIf
	
	Activate MsDialog oDlg On Init(EnchoiceBar(oDlg,{|| IIF(ComXTudoOk(),lRet := .T.,lRet := .F.)}, {|| IIF(SDS->DS_TIPO=="D",ComXGetAnt(aColsAnt),),oDlg:End()},,aButtons))
	//Activate MsDialog oDlg On Init(EnchoiceBar(oDlg,{|| lRet := .T.,IIF(IIF(SDS->DS_TIPO=="D",ComXTudoOk(),.T.),oDlg:End(),)}, {|| IIF(SDS->DS_TIPO=="D",ComXGetAnt(aColsAnt),),oDlg:End()},,aButtons))
	
	If lRet .And. (nOpc == 4 .OR. nOpc == 2) //-- Caso tenha processado o vinculo
		RecLock("SDS",.F.)
			SDS->DS_XCONDPG := cCondPag
			SDS->DS_XNATURE := cNatureza
		SDS->(MsUnLock())
		
		For nX := 1 To Len(aCols)
			SDT->(dbGoTo(aCols[nX,Len(aHeader)]))

			If SDS->DS_TIPO $ "N" .Or. lRemet	//-- Grava pedido e item
				RecLock("SDT",.F.)
					SDT->DT_PEDIDO 	:= aCols[nX,GDFieldPos("DT_PEDIDO",aHeader)]
					SDT->DT_ITEMPC 	:= aCols[nX,GDFieldPos("DT_ITEMPC",aHeader)]
					SDT->DT_XTES 	:= aCols[nX,GDFieldPos("DT_XTES",aHeader)]
					SDT->DT_XCFOP 	:= POSICIONE("SF4",1,xFilial("SF4")+aCols[nX,GDFieldPos("DT_XTES",aHeader)],"F4_CF")
					SDT->DT_XCC 	:= aCols[nX,GDFieldPos("DT_XCC",aHeader)]
					SDT->DT_XCONTA 	:= aCols[nX,GDFieldPos("DT_XCONTA",aHeader)]
					SDT->DT_COD 	:= aCols[nX,GDFieldPos("DT_COD",aHeader)]
				SDT->(MsUnLock())
				
				dbSelectArea("SA5")
				SA5->(dbSetOrder(1))
				If !SA5->(dbSeek(xFilial("SA5")+SDS->DS_FORNEC+SDS->DS_LOJA+aCols[nX,GDFieldPos("DT_COD",aHeader)]))
					RecLock("SA5",.T.)
						A5_FILIAL 	:= xFilial("SA5")
						A5_FORNECE 	:= SDS->DS_FORNEC
						A5_LOJA 	:= SDS->DS_LOJA
						A5_NOMEFOR	:= Posicione("SA2",1,xFilial("SA2")+SDS->DS_FORNEC,"A2_NOME")
						A5_CODPRF	:= aCols[nX,GDFieldPos("DT_PRODFOR",aHeader)]
						A5_PRODUTO  := aCols[nX,GDFieldPos("DT_COD",aHeader)]
						A5_NOMPROD  := Posicione("SB1",1,xFilial("SB1")+aCols[nX,GDFieldPos("DT_COD",aHeader)],"B1_DESC") 
					MsUnlock()
				Else
			  		RecLock("SA5",.F.)
			  			A5_FILIAL 	:= xFilial("SA5")
						A5_CODPRF	:= aCols[nX,GDFieldPos("DT_PRODFOR",aHeader)]
						A5_PRODUTO  := aCols[nX,GDFieldPos("DT_COD",aHeader)]
						A5_NOMPROD  := Posicione("SB1",1,xFilial("SB1")+aCols[nX,GDFieldPos("DT_COD",aHeader)],"B1_DESC") 
					MsUnlock()
				EndIF 
			ELSEIF nOpc == 2
				RecLock("SDT",.F.)
					SDT->DT_XTES 	:= aCols[nX,GDFieldPos("DT_XTES",aHeader)]
					SDT->DT_XCFOP 	:= aCols[nX,GDFieldPos("DT_XCFOP",aHeader)]
					SDT->DT_XCC 	:= aCols[nX,GDFieldPos("DT_XCC",aHeader)]
					SDT->DT_XCONTA 	:= aCols[nX,GDFieldPos("DT_XCONTA",aHeader)]
				SDT->(MsUnLock())
			Else	//-- Grava nota, serie e item origem
				RecLock("SDT",.F.)
					SDT->DT_NFORI   := aCols[nX,GDFieldPos("DT_NFORI",aHeader)]
					SDT->DT_SERIORI := aCols[nX,GDFieldPos("DT_SERIORI",aHeader)]
					SDT->DT_ITEMORI := aCols[nX,GDFieldPos("DT_ITEMORI",aHeader)]
					SDT->DT_XTES 	:= aCols[nX,GDFieldPos("DT_XTES",aHeader)]
					SDT->DT_XCFOP 	:= aCols[nX,GDFieldPos("DT_XCFOP",aHeader)]
					SDT->DT_XCC 	:= aCols[nX,GDFieldPos("DT_XCC",aHeader)]
					SDT->DT_XCONTA 	:= aCols[nX,GDFieldPos("DT_XCONTA",aHeader)]  
					SDT->DT_COD 	:= aCols[nX,GDFieldPos("DT_COD",aHeader)]
				SDT->(MsUnLock())
			EndIf			
		Next nX
	EndIf
	
	cFilAnt := cFilBkp
	aRotina[2,4] := 2
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MarkAll  บAutor  ณTOTVS TMAP       	 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para marcar todos os registros da MarkBrowse.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ COMXCOL                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarkAll()
	Local nRecno := SDS->(Recno())
	
	SDS->(dbGoTop())
	While !SDS->(EOF())
		If SDS->DS_STATUS <> 'P'
			Reclock("SDS",.F.)
			SDS->DS_OK := If(SDS->DS_OK == cMarca,"",cMarca)
			SDS->(MsUnlock())
		EndIf
		SDS->(dbSkip())
	EndDo
	
	SDS->(dbGoto(nRecno))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GerarDocsบAutor  ณ TOTVS TMAP 		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processa a geracao dos documentos fiscais.			      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPCTE1                                        			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GerarDocs()
	Local nRegs   := 0
	Local nRecno  := SDS->(Recno())
	
	If MsgYesNo("Confirma a gera็ใo de documento para os itens selecionados?","Aten็ใo")
		SDS->(dbEval({|| nRegs++},{|| DS_OK == cMarca}))
		SDS->(dbGoTop())
		Processa({|| ProcDocs(nRegs),"Monitor TOTVS " +" - " +"Gera็ใo de Documentos"})
		SDS->(dbGoTo(nRecno))
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ProcDocs บAutor  ณ TOTVS TMAP  		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processa a geracao dos documentos a partir de SDS/SDT      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nRegs: total de registros a serem processados.			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GerarDocs												  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcDocs(nRegs,lNFeAut)
	Local aCabec 	:= {}
	Local aItens 	:= {}
	Local aErro  	:= {}
	Local cErro  	:= ""
	Local nX	 	:= 0
	Local nCount 	:= 0
	Local cFilBkp	:= cFilAnt
	Local lRet		:= .F.
	Default lNFeAut := .F.
	
	Private 	lMSErroAuto	   := .F.
	Private		lAutoErrNoFile := .T.
	_lExec	:= .F.
	
	ProcRegua(nRegs)
	While !SDS->(EOF())
		/*If lNFeAut .And. (!SDS->DS_TIPO $ "DC")
			aCabec := MontaSF1()
			aItens := MontaSD1()
			If (lRet := (SDS->DS_STATUS <> "E"))
				If !(SDS->DS_TIPO $ "OCT")
					lRet := .T.
					MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
				ElseIf (SDS->DS_TIPO $ "OCT")
					lRet   := IIf(SDS->DS_TIPO $ "OCT",.T.,COLNfeAut(aCabec,aItens))
					If lRet
						MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,3)
					EndIf
				EndIf
			EndIf
		Else */
			
		If (SDS->DS_OK == cMarca)
			If Alltrim(SDS->DS_STATUS) == ""
				Aviso("Aten็ใo","Documento " +AllTrim(SDS->DS_DOC) +"/" +AllTrim(SDS->DS_SERIE)+", nao serแ processado pois nao foi confirmado.",{"OK"}) //-- Aten็ใo # Esta a็ใo nใo pode ser executada para documentos jแ gerados.
				lRet := .F.
			Else
				lRet := .T.
				nCount++
				IncProc("Processando documento " +AllTrim(SDS->DS_DOC) +"/" +AllTrim(SDS->DS_SERIE) +"(" +StrZero(nCount,2) +" de " +StrZero(nRegs,2) +")")
				
				//-- Se filial diferente, troca
				If PadR(cFilAnt,Len(AllTrim(SDS->DS_FILIAL))) # AllTrim(SDS->DS_FILIAL)
					Do Case
					Case FWModeAccess("SB2",3) == "E"
						cFilAnt := SDS->DS_FILIAL
					Case FWModeAccess("SB2",2) == "E" .Or. FWModeAccess("SB2",1) == "E"
						SM0->(dbSetOrder(1))
						SM0->(dbSeek(cEmpAnt+SDS->DS_FILIAL))
						cFilAnt := SM0->M0_CODFIL
					EndCase
				EndIf
				
				lRemet := .F.
				
				If SDS->DS_TIPO == "T" .And. SDS->DS_TPFRETE == "F" // Verifica se e CT-e e se e remetente da mercadoria (saida), neste caso deve permitir vincular pedido
					lRemet := .T.
				EndIf
				
				_nTiMov	:= 4
				
				If SDS->DS_STATUS == "P"
					_nTiMov := 0
				EndIf
				
				If !(SDS->DS_TIPO $ "NDC")
					If !lRemet	
						_nTiMov := 2
					EndIf
				EndIf
				
				//-- Esvazia log
				RecLock("SDS",.F.)
				SDS->DS_DOCLOG := CriaVar("DS_DOCLOG",.F.)
				SDS->(MsUnLock())			
				
				If _nTiMov <> 0
					_lExec	:= MontaTela(_nTiMov)
				EndIf
				
				IF _lExec
					//-- Esvazia log
					RecLock("SDS",.F.)
						SDS->DS_DOCLOG := CriaVar("DS_DOCLOG",.F.)
					SDS->(MsUnLock())			
					
					aCabec := MontaSF1()
					aItens := MontaSD1()
					If Empty(SDS->DS_DOCLOG) //-- Se nao houve erro na montagem dos dados, continua
						lMSErroAuto := .F.
						If SDS->DS_TIPO $ "OCT"					
							MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,3)
						Else
							MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
						EndIf
						
						IF lMSErroAuto
							MostraErro() 
						EndIF
					EndIf
				ELSE
					lRet := .F.
				ENDIF
			EndIF
		Else
			lRet := .F.
		EndIf
	
		//IF _lExec
			If lRet
				//-- Grava resultado do processamento na SDS
				RecLock("SDS",.F.)
				Replace SDS->DS_OK	With ''
				
				If !lMsErroAuto
					Replace SDS->DS_USERPRE	With cUserName
					Replace SDS->DS_DATAPRE	With dDataBase
					Replace SDS->DS_HORAPRE	With Time()
					Replace SDS->DS_STATUS	With 'P'
					Replace SDS->DS_DOCLOG	With ''
				ELSE
					DBSELECTAREA("SF1")
					DBSETORDER(1)
					IF DBSEEK(XFILIAL("SF1") + SDS->DS_DOC + SDS->DS_SERIE + SDS->DS_FORNEC + SDS->DS_LOJA)
						Replace SDS->DS_USERPRE	With cUserName
						Replace SDS->DS_DATAPRE	With dDataBase
						Replace SDS->DS_HORAPRE	With Time()
						Replace SDS->DS_STATUS	With 'P'
						Replace SDS->DS_DOCLOG	With ''			
					Else
						aErro := GetAutoGRLog()
						cErro := ""
						For nX := 1 To Len(aErro)
							cErro += aErro[nX] +CRLF
						Next nY
						Replace SDS->DS_DOCLOG With cErro
						Replace SDS->DS_STATUS With 'E'
					ENDIF
				EndIf
				SDS->(MsUnLock())
			EndIf
		//ENDIF
		//If lNFeAut
			//Exit
		//EndIf
		SDS->(dbSkip())
		cFilAnt := cFilBkp
	End
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MontaSF1 บAutor  ณTOTVS TMAP          บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta cabecalho para rotina automatica com os dados do SDS บฑฑ
ฑฑบ          ณ posicionado.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRet: array para uso na rotina automatica.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ProcDocs                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaSF1()
	Local aRet	 	 := {}
	Local cTipoNF	 := ""
	Local cCondPagto := ""
	Local aAreaSDS	 := SDS->(GetArea())
	Local lRemet	 := .F.
	
	Do Case
	Case SDS->DS_TIPO == "T"
		cTipoNF := "C"
	Case SDS->DS_TIPO == "O"
		cTipoNF := "N"
	Otherwise
		cTipoNF := SDS->DS_TIPO
	EndCase
	
	// Quando a empresa for remetente da mercadoria (FOB) nao deve passar F1_TPFRETE na rotina automatica, caso contrario vai cair na validacao A103FRETE que nao permite vincular pedido de compra a documentos com TPFRETE preenchido
	If SDS->DS_TIPO == "T" .And. SDS->DS_TPFRETE == "F"
		lRemet := .T.
	EndIf
	
	aAdd(aRet,{"F1_FILIAL",  SDS->DS_FILIAL,	Nil})
	If AllTrim(SDS->DS_ESPECI) == "CTE"
		SDT->(dbSetOrder(2))
		If lRemet .And. SDT->(dbSeek(xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE))) .And.  AllTrim(SDT->DT_COD) $ AllTrim(SuperGetMV("MV_XMLPFCT",.F.,""))
			aAdd(aRet,{"F1_TIPO","N",Nil})
		Else
			aAdd(aRet,{"F1_TIPO",cTipoNF,Nil})
		EndIf
	Else
		aAdd(aRet,{"F1_TIPO",  cTipoNF,			Nil})
	EndIf
	
	aAdd(aRet,{"F1_FORMUL",  SDS->DS_FORMUL,	Nil})
	aAdd(aRet,{"F1_DOC",     SDS->DS_DOC,		Nil})
	aAdd(aRet,{"F1_SERIE",   SDS->DS_SERIE,		Nil})
	aAdd(aRet,{"F1_EMISSAO", SDS->DS_EMISSA,	Nil})
	aAdd(aRet,{"F1_FORNECE", SDS->DS_FORNEC,	Nil})
	aAdd(aRet,{"F1_LOJA",    SDS->DS_LOJA,		Nil})
	aAdd(aRet,{"F1_ESPECIE", SDS->DS_ESPECI,	Nil})
	aAdd(aRet,{"F1_DTDIGIT", dDataBase,			Nil})
	aAdd(aRet,{"F1_EST",     SDS->DS_EST,		Nil})
	aAdd(aRet,{"F1_CHVNFE",  SDS->DS_CHAVENF,	Nil})
	aAdd(aRet,{"F1_FRETE",   SDS->DS_FRETE,		Nil})
	aAdd(aRet,{"F1_DESPESA", SDS->DS_DESPESA,	Nil})
	aAdd(aRet,{"F1_DESCONT", SDS->DS_DESCONT,	Nil})
	aAdd(aRet,{"F1_SEGURO",  SDS->DS_SEGURO,	Nil})
	If !Empty(SDS->DS_TRANSP)
		aAdd(aRet,{"F1_TRANSP",SDS->DS_TRANSP,	Nil})
	EndIf
	aAdd(aRet,{"F1_PLACA",   	SDS->DS_PLACA,		Nil})
	aAdd(aRet,{"F1_PLIQUI",  	SDS->DS_PLIQUI,		Nil})
	aAdd(aRet,{"F1_PBRUTO",  	SDS->DS_PBRUTO,		Nil})
	aAdd(aRet,{"F1_ESPECI1", 	SDS->DS_ESPECI1,	Nil})
	aAdd(aRet,{"F1_VOLUME1", 	SDS->DS_VOLUME1,	Nil})
	aAdd(aRet,{"F1_ESPECI2", 	SDS->DS_ESPECI2,	Nil})
	aAdd(aRet,{"F1_VOLUME2", 	SDS->DS_VOLUME2,	Nil})
	aAdd(aRet,{"F1_ESPECI3", 	SDS->DS_ESPECI3,	Nil})
	aAdd(aRet,{"F1_VOLUME3", 	SDS->DS_VOLUME3,	Nil})
	aAdd(aRet,{"F1_ESPECI4", 	SDS->DS_ESPECI4,	Nil})
	aAdd(aRet,{"F1_VOLUME4",	SDS->DS_VOLUME4,	Nil})
	If !lRemet	// Nao deve passar TPFRETE quando for CT-e e a empresa for remetente da mercadoria (FOB). Para os outros casos deve passar,
		aAdd(aRet,{"F1_TPFRETE", SDS->DS_TPFRETE,	Nil})
	EndIf
	aAdd(aRet,{"F1_BASEICM",	SDS->DS_BASEICM, 	Nil})
	aAdd(aRet,{"F1_VALICM", 	SDS->DS_VALICM, 	Nil})
	/*
	//-- Preenche condicao de pagamento para tipos de documento que geram NF
	Do Case
	Case SDS->DS_TIPO == "C" //-- Complemento de preco
		//-- Obtem cond. pagto utilizada na nota origem
		SDT->(dbSetOrder(2))
		SDT->(dbSeek(xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
		While Empty(cCondPagto) .And. SDT->(!EOF()) .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
			SF1->(dbSetOrder(1))
			If SF1->(dbSeek(xFilial("SF1")+SDT->(DT_NFORI+DT_SERIORI+DT_FORNEC+DT_LOJA))) .And. !Empty(SF1->F1_COND)
				cCondPagto := SF1->F1_COND
			EndIf
			SDT->(dbSkip())
		End
		aAdd(aRet,{"F1_COND",cCondPagto,Nil})
	Case SDS->DS_TIPO == "T" //-- Conhecimento de transporte
		//-- Obtem cond. pagto para utilizacao no CT-e (MV_XMLCPCT)
		//U_IMPCTE2A(NIL,NIL,@cCondPagto)
		cCondPagto := SDS->DS_XCONDPG
		aAdd(aRet,{"F1_COND",cCondPagto,Nil})
	EndCase
	*/
	
	//-- Flag colab para tratamentos especificos
	//aAdd(aRet,{"COLAB","S",NIL})
	
	aAdd(aRet,{"F1_COND"	, 	SDS->DS_XCONDPG, 	Nil})
	aAdd(aRet,{"E2_NATUREZ"	, 	SDS->DS_XNATURE, 	Nil})
	
	aRet := FWVetByDic(aRet, 'SF1')
	
	RestArea(aAreaSDS)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MontaSD1 บAutor  ณTOTVS TMAP          บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta itens para rotina automatica com os dados do SDS 	  บฑฑ
ฑฑบ          ณ posicionado.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRet: array para uso na rotina automatica.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ProcDocs                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaSD1()
	Local aRet	    := {}
	Local cTES_CT	:= ""
	Local aAreaSDS	:= SDS->(GetArea())
	
	SDT->(dbSetOrder(2))
	SDT->(dbSeek(xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
	While SDT->(!EOF()) .AND. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
		aAdd(aRet,{})
		
		aAdd(aTail(aRet),{"D1_ITEM",   SDT->DT_ITEM, 	 NIL})
		aAdd(aTail(aRet),{"D1_COD",    SDT->DT_COD,	 NIL})
		If !Empty(SDT->DT_PEDIDO)
			aAdd(aTail(aRet),{"D1_PEDIDO", SDT->DT_PEDIDO,	 NIL})
			aAdd(aTail(aRet),{"D1_ITEMPC", SDT->DT_ITEMPC,	 NIL})
		EndIf
		If !Empty(SDT->DT_NFORI)
			aAdd(aTail(aRet),{"D1_NFORI",  SDT->DT_NFORI,	 NIL})
			aAdd(aTail(aRet),{"D1_SERIORI",SDT->DT_SERIORI, NIL})
			aAdd(aTail(aRet),{"D1_ITEMORI",SDT->DT_ITEMORI, NIL})
		EndIf
		
		aAdd(aTail(aRet),{"D1_CONTA",SDT->DT_XCONTA, NIL})
		aAdd(aTail(aRet),{"D1_CC",SDT->DT_XCC, NIL})
		
		If !SDS->DS_TIPO $ "C"
			If SDS->DS_TIPO == "T"
				If SDS->DS_TPFRETE == "F"				// Somente quando a empresa e remetente da mercadoria (FOB) deve gerar nota com quantidade 1, caso contrario nao e para enviar quantidade (ficara zerada)
					aAdd(aTail(aRet),{"D1_QUANT",  SDT->DT_QUANT, 	 NIL})
				EndIf
				dbSelectArea("SD1")
				dbSetOrder(2)
				If SD1->(dbSeek(xFilial('SD1')+ SDT->DT_COD + SDT->DT_NFORI + SDT->DT_SERIORI))
					aAdd(aTail(aRet),{"D1_CONTA",SD1->D1_CONTA, NIL})
					aAdd(aTail(aRet),{"D1_CC",SD1->D1_CC, NIL})
				EndIf
			Else
				aAdd(aTail(aRet),{"D1_QUANT",  SDT->DT_QUANT, 	 NIL})
			EndIf
		EndIf
		aAdd(aTail(aRet),{"D1_VUNIT",  SDT->DT_VUNIT, 	 NIL})
		If SDS->DS_TIPO $ "CT"
			aAdd(aTail(aRet),{"D1_TOTAL",SDT->DT_VUNIT,NIL})
		Else
			aAdd(aTail(aRet),{"D1_TOTAL",Round(SDT->DT_VUNIT * SDT->DT_QUANT,TamSX3("D1_TOTAL")[2]),NIL})
		EndIf
		aAdd(aTail(aRet),{"D1_VALFRE"	,SDT->DT_VALFRE,	NIL})
		aAdd(aTail(aRet),{"D1_SEGURO"	,SDT->DT_SEGURO,	NIL})
		aAdd(aTail(aRet),{"D1_DESPESA"	,SDT->DT_DESPESA, 	NIL})
		aAdd(aTail(aRet),{"D1_VALDESC"	,SDT->DT_VALDESC, 	NIL})
		aAdd(aTail(aRet),{"D1_PICM"		,SDT->DT_PICM, 		Nil })
		
		//-- Realiza validacoes pertinentes e preenche TES
		Do Case
		Case SDS->DS_TIPO == "C" //-- Complemento de preco
			//-- Valida vinculo com documento origem
			If Empty(SDT->DT_NFORI)
				RecLock("SDS",.F.)
				Replace SDS->DS_DOCLOG With SDS->DS_DOCLOG +CRLF+CRLF + " Por tratar-se de um documento de complemento de pre็o, deverแ ser realizado o vํnculo com o documento origem para o item " +SDT->DT_ITEM + " deste documento."
				Replace SDS->DS_STATUS With 'E'
				SDS->(MsUnlock())
			EndIf
			//-- Obtem TES
			SA5->(dbSetOrder(1))
			If SA5->(dbSeek(xFilial("SA5")+SDT->(DT_FORNEC+DT_LOJA+DT_COD))) .And. Empty(SA5->A5_TESCP)
				RecLock("SDS",.F.)
				Replace SDS->DS_DOCLOG With SDS->DS_DOCLOG +CRLF+CRLF +;
					"Por tratar-se de um documento de complemento de pre็o, deverแ ser identificado o tipo de entrada para o produto " +AllTrim(SDT->DT_COD) + " e fornecedor " +AllTrim(SDS->DS_FORNEC) +'/' +AllTrim(SDS->DS_LOJA) + " no campo 'TE p/ Compl.' (A5_TESCP) no cadastro de Produto X Fornecedor."
				Replace SDS->DS_STATUS With 'E'
				SDS->(MsUnlock())
			Else
				//aAdd(aTail(aRet),{"D1_TES",SA5->A5_TESCP,NIL})
				aAdd(aTail(aRet),{"D1_TES"	,SDT->DT_XTES	,NIL})				
				aAdd(aTail(aRet),{"D1_CF"	,SDT->DT_XCFOP	,NIL})
			EndIf
		Case SDS->DS_TIPO == "T" //-- Conhecimento de transporte
			//-- Obtem cond. pagto para utilizacao no CT-e (MV_XMLCPCT)
			//U_IMPCTE2A(NIL,@cTES_CT)
			cTES_CT := SDT->DT_XTES
			// -- Valida config. do parametro MV_XMLCPCT
			If Empty(cTES_CT)
				RecLock("SDS",.F.)
				Replace SDS->DS_DOCLOG With SDS->DS_DOCLOG +CRLF+CRLF + "Por tratar-se de um documento de transporte, deverแ ser identificado o tipo de entrada a ser utilizado atrav้s do parโmetro MV_XMLCPCT."
				Replace SDS->DS_STATUS With 'E'
				SDS->(MsUnlock())
				Exit
			Else
				//aAdd(aTail(aRet),{"D1_TES"	,cTES_CT,NIL})
				aAdd(aTail(aRet),{"D1_TES"	,SDT->DT_XTES	,NIL})				
				aAdd(aTail(aRet),{"D1_CF"	,SDT->DT_XCFOP	,NIL})
			EndIf
		Case SDS->DS_TIPO == "O"
			SA5->(dbSetOrder(1))
			If SA5->(dbSeek(xFilial("SA5")+SDT->DT_FORNEC+SDT->DT_LOJA+SDT->DT_COD)) .And. Empty(SA5->A5_TESBP)
				RecLock("SDS",.F.)
				Replace SDS->DS_DOCLOG With "Por tratar-se de um documento de bonifica็ใo, deverแ ser identificado o tipo de entrada para o produto " +AllTrim(SDT->DT_COD) +" e fornecedor " +AllTrim(SDS->DS_FORNEC) +'/' +AllTrim(SDS->DS_LOJA) + " no campo 'TE p/ Bonif.' (A5_TESBP) no cadastro de Produto X Fornecedor."
				Replace SDS->DS_STATUS With 'E'
				SDS->(MsUnlock())
			Else
				//aAdd(aTail(aRet),{"D1_TES", SA5->A5_TESBP,  NIL})
				aAdd(aTail(aRet),{"D1_TES"	,SDT->DT_XTES	,NIL})				
				aAdd(aTail(aRet),{"D1_CF"	,SDT->DT_XCFOP	,NIL})
			EndIf
		Case SDS->DS_TIPO == "N"
			aAdd(aTail(aRet),{"D1_TES"	,SDT->DT_XTES	,NIL})
		EndCase
		
		aTail(aRet) := FWVetByDic(aTail(aRet), 'SD1')
		
		SDT->(dbSkip())
	EndDo
	RestArea(aAreaSDS)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ COLNfeAutบAutor  ณTOTVS TMAP          บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao das tabelas SE4/SF4 para geracao automatica 	  บฑฑ
ฑฑบ          ณ dos documentos TOTVS                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aCabec: Cabecalho documento de entrada		  			  บฑฑ
ฑฑบ			 ณ cItens: Itens documento de entrada		  				  บฑฑ
ฑฑบ			 ณ cCGCEmit: CNPJ do emitente		  				  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRet: (True/False) verifica se passou todas as validacoes  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPCTE1                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function COLNfeAut(aCabec,aItens)
	Local aAreaSB1 := SB1->(GetArea())
	Local aAreaSF4 := SF4->(GetArea())
	Local aAreaSE4 := SE4->(GetArea())
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaSA2 := SA2->(GetArea())
	Local lRet     := .T.
	Local nX       := 0
	Local nPosFor  := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_FORNECE"})
	Local nPosLoj  := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_LOJA"})
	Local nPosTpNF := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_TIPO"})
	Local nPosCPg  := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_COND"})
	Local nPosFre  := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_TPFRETE"})
	Local nPosPrd  := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_COD"})
	Local nPosPed  := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_PEDIDO"})
	Local nPosItPC := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_ITEMPC"})
	Local nPosTes  := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_TES"})
	Local nPosQtde := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_QUANT"})
	Local nPosPrec := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_VUNIT"})
	Local cCodTes  := ""
	Local cCondPg  := ""
	Local clQuery  := ""
	Local clArqSQL := "TMP"
	Local lGerDupl := .F.
	
	// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	// | Verifica se o tipo NF esta contido no paramentro para geracao automatica |
	// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !(SDS->DS_TIPO $ SuperGetMV("MV_COMCOL2",.F.,.F.))
		lRet := .F.
	ElseIf aCabec[nPosTpNF,2] == "N" .And. ExistBlock("COMCOL2")
		lRet := ExecBlock("COMCOL2",.F.,.F.,{aCabec,aItens})
		If ValType(lRet) <> "L"
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		SB1->(dbSetOrder(1))
		SF4->(dbSetOrder(1))
		For nX := 1 To Len(aItens)
			SB1->(DbSeek(xFilial("SB1")+aItens[nX][nPosPrd][2])) //Codigo do Produto
			cCodTes := ""
			cCodTes := SB1->B1_TE
			// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			// |  Ponto de entrada para obter o codigo da TES |
			// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If ExistBlock("COMCOLF4")
				cCodTes := ExecBlock("COMCOLF4",.F.,.F.,{aCabec[nPosFor,2],aCabec[nPosLoj,2],aItens[nX][nPosPrd][2],cCodTes})
				If ValType(cCodTes) # "C" .Or. !SF4->(dbSeek(xFilial("SE4")+cCodTes))
					cCodTes := SB1->B1_TE
				EndIf
			EndIf
			// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			// |  Caso nao encontre a TES cancelar a operacao |
			// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Empty(cCodTes)
				lRet := .F.
				Exit
			ElseIf nPosTes > 0
				aItens[nX][nPosTes][2] := cCodTes
			Else
				//aAdd(aItens[nX],{"D1_TES",cCodTes, NIL})
				aAdd(aItens[nX],{"D1_TES"	,SDT->DT_XTES	,NIL})				
				aAdd(aItens[nX],{"D1_CF"	,SDT->DT_XCFOP	,NIL})
			EndIf
		Next nX
	EndIf
	
	// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	// |  Ponto de entrada para obter a cond de pagto |
	// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lRet
		SF4->(dbSetOrder(1))
		For nX := 1 To Len(aItens)
			nPosTes  := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_TES"})
			If SF4->(dbSeek(xFilial("SF4")+aItens[nX][nPosTes][2])) .And. SF4->F4_DUPLIC == "S"
				lGerDupl := .T.
				Exit
			EndIf
		Next nX
		If lGerDupl
			SE4->(dbSetOrder(1))
			IF aCabec[nPosTpNF,2] == "N"
				For nX := 1 To Len(aItens)
					// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					// |  MONTA QUERY   |
					// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					clQuery += " SELECT C7_NUM, C7_ITEM, C7_COND"
					clQuery += " FROM " + RetSqlName("SC7") + " SC7 "
					clQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "' AND D_E_L_E_T_ <> '*' "
					clQuery += " AND C7_FORNECE = '" + aCabec[nPosFor,2] + "' AND C7_LOJA = '" + aCabec[nPosLoj,2] + "'"
					clQuery += " AND C7_PRODUTO = '" + aItens[nX][nPosPrd][2] + "'"
					clQuery += " AND C7_PRECO = " + STR(aItens[nX][nPosPrec][2])
					clQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA) >= "+ STR(aItens[nX][nPosQtde][2])
					clQuery += " ORDER BY C7_DATPRF"
					clQuery := ChangeQuery(clQuery)
					dbUseArea(.T., "TOPCONN", TCGenQry(,,clQuery),"TMP", .T., .T.)
					DbSelectArea(clArqSQL)
					TMP->(dbGoTop())
					If !TMP->(Eof())
						aSize(aItens[nX],Len(aItens[nX])+2)
						aIns(aItens[nX],3)
						aItens[nX][3] := {"D1_PEDIDO", TMP->C7_NUM, NIL}
						aIns(aItens[nX],4)
						aItens[nX][4] := {"D1_ITEMPC", TMP->C7_ITEM, NIL}
						aCabec[nPosFre,2] := ""
						cCondPg	:= TMP->C7_COND
					EndIf
					clQuery := ""
					TMP->(dbCloseArea())
				Next nX
			EndIf
			If Empty(cCondPg)
				If aCabec[nPosTpNF,2] $ "B"
					SA1->(dbSetOrder(1))
					If SA1->(dbSeek(xFilial("SA1")+aCabec[nPosFor,2]+aCabec[nPosLoj,2]))
						cCondPg	:= SA1->A1_COND
					EndIf
				Else
					SA2->(dbSetOrder(1))
					If SA2->(dbSeek(xFilial("SA2")+aCabec[nPosFor,2]+aCabec[nPosLoj,2]))
						cCondPg	:= SA2->A2_COND
					EndIf
				EndIf
			EndIf
			If ExistBlock("A140ICOND")
				cCondPg := ExecBlock("A140ICOND",.F.,.F.,{aCabec[1][nPosFor],aCabec[1][nPosLoj],cCondPg})
				If ValType(cCondPg) # "C" .Or. !SE4->(dbSeek(xFilial("SE4")+cCondPg))
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !Empty(cCondPg) .And. nPosCPg > 0
					aCabec[nX][nPosCPg][2] := cCondPg
				ElseIf !Empty(cCondPg)
					//aAdd(aCabec,{"F1_COND",cCondPg, NIL})
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSB1)
	RestArea(aAreaSF4)
	RestArea(aAreaSE4)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReprocessaบAutor  ณ TOTVS TMAP 		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abre interface para o reprocessamento de arquivos XML com  บฑฑ
ฑฑบ			 ณ erros ou excluidos.  									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPCTE1                                        			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reprocessa()
	Local lProc		:= .F.
	Local oDlg		:= NIL
	Local oBrowse   := NIL
	Local nX	    := 0
	Local cCombo	:= ""
	Local aArquivos := {}
	Local aSize    := MsAdvSize()
	Local aHeadCols := {" ",RetTitle("DS_ARQUIVO"),RetTitle("DS_DOC"),RetTitle("DS_SERIE"),RetTitle("DS_NOMEFOR")}
	
	Define MsDialog oDlg Title "Reprocessar Documentos" From aSize[1],aSize[2] To aSize[1]+450,aSize[2]+797 Pixel
	
	cCombo := "Documentos com erro"
	TComboBox():New(211,130,{|u| If(PCount()>0,cCombo:=u,cCombo)},{"Documentos com erro","Documentos excluํdos"},085,20,oDlg,,{|| LoadFiles(@oBrowse,cCombo)},,,,.T.,,,,,,,,,'cCombo')
	
	oBrowse := TCBrowse():New(01,01,400,205,,aHeadCols,,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
	LoadFiles(@oBrowse,cCombo) //-- Carrega arquivos no browse
	
	TButton():New(aSize[1]+210,aSize[2]+5,"Inverte Sel.",oDlg,{|| aEval(@oBrowse:aArray,{|x| x[1] := !x[1]}),oBrowse:Refresh() },50,11,,,.F.,.T.,.F.,,.F.,,,.F.)
	TButton():New(aSize[1]+210,aSize[2]+60,"Pesquisar",oDlg,{|| PesquiArq(@oBrowse)},50,11,,,.F.,.T.,.F.,,.F.,,,.F.) //--
	Define SButton From aSize[1]+210,aSize[2]+330 Type 1 Action (aArquivos := aClone(oBrowse:aArray),lProc := .T., oDlg:End()) Enable Of oDlg
	Define SButton From aSize[1]+210,aSize[2]+360 Type 2 Action oDlg:End() Enable Of oDlg
	
	Activate MsDialog oDlg Centered
	
	If lProc
		For nX := 1 To Len(aArquivos)
			If aArquivos[nX,1]
				//-- Move arquivo para pasta new
				If cCombo $ "Documentos com erro"
					Copy File &(DIRXML+DIRERRO+aArquivos[nX,2]) To &(DIRXML+DIRALER+aArquivos[nX,2])
					FErase(DIRXML+DIRERRO+aArquivos[nX,2])
				Else
					Copy File &(DIRXML+DIRLIDO+aArquivos[nX,2]) To &(DIRXML+DIRALER+aArquivos[nX,2])
					FErase(DIRXML+DIRLIDO+aArquivos[nX,2])
				EndIf
			EndIf
		Next nX
		Aviso("Aten็ใo","Os arquivos selecionados foram movidos para a fila de reprocessamento. Quando disponํveis, os documentos serใo apresentados no Monitor TOTVS Colabora็ใo.",{"OK"})
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LoadFilesบAutor  ณ TOTVS TMAP 		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que carrega os arquivos no browse de reprocessamentoบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oBrowse: browse dos arquivos a serem reprocessados.		  บฑฑ
ฑฑบ			 ณ cCombo: op็ใo selecionada no combo de documentos.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Reprocessa												  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadFiles(oBrowse,cCombo)
	Local aArea		 := SDS->(GetArea())
	Local aArquivo 	 := {}
	Local aFiles   	 := {}
	Local cError   	 := ""
	Local cWarning 	 := ""
	Local cTagRem    := ""
	Local cTagDest	 := ""
	Local cDiretorio := If(cCombo == "Documentos com erro",DIRXML +DIRERRO,DIRXML +DIRLIDO)
	Local lVldImport := If(cCombo == "Documentos com erro",.F.,.T.)
	Local lAddArq  	 := .T.
	Local oFullXML 	 := NIL
	Local oOK 		 := LoadBitmap(GetResources(),'LBOK')
	Local oNO 		 := LoadBitmap(GetResources(),'LBNO')
	Local nX		 := 0
	Local cXMLOri	 := ""
	Local cXMLEncod	 := ""
	Local nHandle	 := 0
	Local nLength	 := 0
	
	SDS->(dbSetOrder(2))
	aFiles := Directory("\" +cDiretorio +"*.xml")
	For nX := 1 To Len(aFiles)
		nHandle := FOpen(cDiretorio +aFiles[nX,1])
		nLength := FSeek(nHandle,0,FS_END)
		FSeek(nHandle,0)
		If nHandle > 0
			FRead(nHandle, cXMLOri, nLength)
			FClose(nHandle)
			If !Empty(cXMLOri)
				If SubStr(cXMLOri,1,1) != "<"
					nPosPesq := At("<",cXMLOri)
					cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
				EndIf
			EndIf
			cXMLEncod := EncodeUtf8(cXMLOri)
			// Verifica se o encode ocorreu com sucesso, pois alguns caracteres especiais provocam erro na funcao de encode, neste caso e feito o tratamento pela funcao A140IRemASC
			If Empty(cXMLEncod)
				cStrXML := cXMLOri
				cXMLOri := A140IRemASC(cStrXML)
				cXMLEncod := EncodeUtf8(cXMLOri)
			EndIf
			If Empty(cXMLEncod)
				cXMLEncod := cXMLOri
			EndIf
		EndIf
		If !Empty(cXMLEncod)
			oFullXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
		EndIf
		//-- Se nao houver Erro na sintaxe do XML adiciona no array
		If Empty(cError)
			If !Empty(oFullXML) .And. Empty(cError) .And. (ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O" .Or.; //-- Nota normal, devolucao, beneficiamento, bonificacao
				ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O" ) //-- Aviso de Embarque
				If ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O"
					//-- Verifica se o arquivo pertence a filial corrente
					If ValType(XmlChildEx(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_DEST,"_CNPJ")) == "O"
						lAddArq := AllTrim(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_DEST:_CNPJ:Text) == AllTrim(SM0->M0_CGC)
					Else
						lAddArq := AllTrim(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_DEST:_CPF:Text) == AllTrim(SM0->M0_CGC)
					EndIf
				Else
					//-- Verifica se o arquivo pertence a filial corrente
					If ValType(XmlChildEx(oFullXML:_NFeProc:_NFe:_InfNfe:_Dest,"_CNPJ")) == "O"
						lAddArq := AllTrim(oFullXML:_NFeProc:_NFe:_InfNfe:_Dest:_CNPJ:Text) == AllTrim(SM0->M0_CGC)
					Else
						lAddArq := AllTrim(oFullXML:_NFeProc:_NFe:_InfNfe:_Dest:_CPF:Text) == AllTrim(SM0->M0_CGC)
					EndIf
				EndIf
				If lAddArq .And. lVldImport
					If ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O"
						lAddArq := SDS->(!DbSeek(xFilial("SDS")+Right(AllTrim(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_ID:Text),44)))
					Else
						lAddArq := SDS->(!DbSeek(xFilial("SDS")+Right(AllTrim(oFullXML:_NFEPROC:_NFE:_InfNfe:_Id:Text),44)))
					EndIf
				EndIf
				If lAddArq .And. ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O"
					aAdd(aArquivo,{})
					aAdd(aTail(aArquivo),.F.) 																	//-- Nome do arquivo
					aAdd(aTail(aArquivo),aFiles[nX,1]) 														//-- Nome do arquivo
					aAdd(aTail(aArquivo),oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_IDE:_NNF:Text)	//-- Numero do Doc.
					aAdd(aTail(aArquivo),oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_IDE:_SERIE:Text)  //-- Serie Doc.
					aAdd(aTail(aArquivo),oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_EMIT:_XNOME:Text)	//-- Razao Social do fornecedor
				Elseif lAddArq
					aAdd(aArquivo,{})
					aAdd(aTail(aArquivo),.F.) 												//-- Nome do arquivo
					aAdd(aTail(aArquivo),aFiles[nX,1]) 									//-- Nome do arquivo
					aAdd(aTail(aArquivo),oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_nNF:Text)	//-- Numero do Doc.
					aAdd(aTail(aArquivo),oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_Serie:Text)  //-- Serie Doc.
					aAdd(aTail(aArquivo),oFullXML:_NFeProc:_NFe:_InfNfe:_Emit:_xNome:Text)	//-- Razao Social do fornecedor
				EndIf
			ElseIf !Empty(oFullXML) .And. Empty(cError) .And. ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
				//-- Verifica se o arquivo pertence a filial corrente
				lAddArq := U_IMPCTE2B(oFullXML:_CteProc:_CTe,SM0->M0_CGC)
				
				If lAddArq .And. lVldImport
					lAddArq := !SDS->(dbSeek(xFilial("SDS")+AllTrim(oFullXML:_CteProc:_CTe:_InfCTe:_Id:Text)))
				EndIf
				If lAddArq
					aAdd(aArquivo,{})
					aAdd(aTail(aArquivo),.F.) 										//-- Nome do arquivo
					aAdd(aTail(aArquivo),aFiles[nX,1]) 							//-- Nome do arquivo
					aAdd(aTail(aArquivo),oFullXML:_CteProc:_CTe:_InfCte:_Ide:_nCt:Text)  	//-- Numero do Doc.
					aAdd(aTail(aArquivo),oFullXML:_CteProc:_CTe:_InfCte:_Ide:_Serie:Text)  	//-- Serie Doc.
					aAdd(aTail(aArquivo),oFullXML:_CteProc:_CTe:_InfCte:_Emit:_xNome:Text) 	//-- Razao Social do fornecedor
				EndIf
			EndIf
		EndIf
		oFullXML := Nil //-- Limpa objeto pra descarregar a memoria
		DelClassIntf()	//-- Limpa memoria
	Next nX
	
	If Len(aArquivo) == 0
		aAdd(aArquivo,{})
		aAdd(aTail(aArquivo),.F.)
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
	EndIf
	
	oBrowse:SetArray(aArquivo)
	If Len(aArquivo) > 0
		oBrowse:bLine := {|| {If(aArquivo[oBrowse:nAT,1],oOK,oNO),aArquivo[oBrowse:nAt,02],aArquivo[oBrowse:nAt,03],aArquivo[oBrowse:nAt,04],aArquivo[oBrowse:nAt,05]}}
		oBrowse:bLDblClick := {|| aArquivo[oBrowse:nAt,1] := !aArquivo[oBrowse:nAt,1], oBrowse:Refresh()}
	EndIf
	oBrowse:Refresh()
	
	SDS->(RestArea(aArea))
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesquiArq บAutor  ณTOTVS TMAP          บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Realiza pesquisa no browse de reprocessamento.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ oBrowse: browse com os arquivos a serem reprocessados.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Reprocessa                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PesquiArq(oBrowse)
	Local lProc      := .F.
	Local cCpoPesq   := Space(100)
	Local cOrdem     := "Arquivo"
	Local nSeek      := 0
	Local oDlg		 := NIL
	Local oCombo	 := NIL
	Local oGet		 := NIL
	Local nOrdem     := 1
	
	Define MSDialog oDlg Title "Pesquisar" From 00,00 To 100,490 Pixel
	
	@05,05 ComboBox oCombo Var cOrdem Items {RetTitle("DS_ARQUIVO"),RetTitle("DS_DOC"),;
		RetTitle("DS_SERIE"),RetTitle("DS_NOMEFOR")} Size 206,36 Pixel Of oDlg On Change (nOrdem := oCombo:nAT)
	@22,05 MSGet oGet Var cCpoPesq Size 206,10 Pixel Of oDlg
	Define SButton From 05,215 Type 1 Of oDlg Enable Action (lProc := .T., oDlg:End())
	Define SButton From 20,215 Type 2 Of oDlg Enable Action oDlg:End()
	
	Activate MSDialog oDlg Center
	
	If lProc
		cCpoPesq := Upper(AllTrim(cCpoPesq))
		If nOrdem == 1 //-- Arquivo
			aSort(oBrowse:aArray,,,{|x,y| x[2] < y[2]})
			nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[2])) == cCpoPesq})
		ElseIf nOrdem == 2 //-- Documento
			aSort(oBrowse:aArray,,,{|x,y| x[3] < y[3]})
			nSeek := aScan(oBrowse:aArray,{|x| Upper(Left(x[3],Len(cCpoPesq))) == cCpoPesq})
		ElseIf nOrdem == 3 //-- Serie
			aSort(oBrowse:aArray,,,{|x,y| x[4] < y[4]})
			nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[4])) == cCpoPesq})
		ElseIf nOrdem == 4 //-- Razao Social
			aSort(oBrowse:aArray,,,{|x,y| x[5] < y[5]} )
			nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[5])) == cCpoPesq})
		EndIf
		If nSeek > 0
			oBrowse:nAT := nSeek
			oBrowse:Refresh()
			oBrowse:SetFocus()
		Else
			Aviso("Aten็ใo","A busca nใo encontrou resultados.",{"OK"})
		EndIf
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Excluir  บAutor  ณ TOTVS TMAP 		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Exclui os documentos marcados.					          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPCTE1                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Excluir()
	Local lRet := .F.
	
	lRet := MsgYesNo("Confirma a exclusใo dos documentos marcados?","Aten็ใo")
	
	SDT->(dbSetOrder(3))
	SDS->(dbGoTop())
	While lRet .And. !SDS->(EOF())
		//-- Processa somente marcados e nao processados
		If DS_OK # cMarca .Or. DS_STATUS == "P"
			dbSkip()
			Loop
		EndIf
		
		//-- Deleta itens do documento
		SDT->(dbSeek(SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
		While !SDT->(EOF()) .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == SDS->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
			RecLock("SDT",.F.)
			SDT->(dbDelete())
			SDT->(MsUnLock())
			SDT->(dbSkip())
		End
		
		//-- Deleta cabecalho do documento
		RecLock("SDS",.F.)
		SDS->(dbDelete())
		SDS->(MsUnLock())
		SDS->(dbSkip())
	End
	
	SDS->(dbGoTop())
Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ Legenda   ณ Autor ณ TOTVS TMAP 			ณ Data ณ 01/01/16  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Exibe uma janela contendo a legenda da browse.              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ IMPCTE1  												   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Legenda()
	Local aCores := {}
	
	aAdd(aCores,{'BR_VERMELHO'	,"Documento Gerado"})
	aAdd(aCores,{'BR_VIOLETA'	,"Documento Normal - Sem Confirmacao"})
	aAdd(aCores,{'BR_AZUL'		,"Docto. de Bonifica็ใo"})
	aAdd(aCores,{'BR_AMARELO'	,"Docto. de Devolu็ใo"})
	aAdd(aCores,{'BR_CINZA'		,"Docto. de Beneficiamento"})
	aAdd(aCores,{'BR_PINK'		,"Docto. de Compl. Pre็o"})
	aAdd(aCores,{'BR_LARANJA'	,"Docto. de Transporte"})
	aAdd(aCores,{'BR_PRETO'		,"Documento com erro na geracao"})
	aAdd(aCores,{'BR_VERDE'		,"Documento Normal - Confirmado"})
	
	BrwLegenda("Monitor Importa็ใo XML","Legenda",aCores)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    | Documentos ณAutor ณ TOTVS TMAP       		   |Data ณ 01/01/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao | Funcao procura possiveis pedidos de compra relacionados a NF     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cProduto: codigo do produto posicionado.							ณฑฑ
ฑฑณ			 ณ lPedDoc: indica se a pequisa e por documento ou item.			ณฑฑ
ฑฑณ			 ณ oGetDados: objeto com os itens do documento.						ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ MontaTela	                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function Documentos(cProduto,lPedDoc)
	Local aArea		:= GetArea()
	Local lRet		:= .F.
	Local cAliasTmp	:= "SC7TMP"
	Local nRecSDT	:= 0
	Local lA140IPed := ExistBlock("A140IPED")
	Local aCampos   := {}
	Local nX        := 0
	Local lRemet	:= .F.
	Local cQuery := ""
	
	// Verifica se e CT-e e se e remetente da mercadoria (saida), neste caso deve permitir vinculo com pedido
	If SDS->DS_TIPO == "T" .And. SDS->DS_TPFRETE == "F"
		lRemet := .T.
	EndIf
	
	If SDS->DS_TIPO $ "N" .Or. lRemet	//-- NF Normal (Compra) ou CT-e de saida
		
		cQuery += "SELECT " +If(lPedDoc,"DISTINCT ","") +"C7_NUM, C7_EMISSAO"
		If !lPedDoc
			cQuery += ", C7_ITEM, C7_QUANT, C7_PRECO, C7_TOTAL, C7_QTDACLA, C7_CC"
		EndIf
		// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		// |  Ponto de entrada utilizado para adicionar campos na interface de visualiza็ใo de pedidos  |
		// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lA140IPed
			aCampos := ExecBlock("A140IPED",.F.,.F.,{1,{},{}})
			If ValType(aCampos[1]) == "A"
				For nX:=1 to Len(aCampos[1])
					cQuery += " , " + aCampos[1][nX]
				Next nX
			EndIf
		EndIf
		cQuery += " FROM " +RetSqlName("SC7") +" SC7"
		cQuery += " WHERE C7_FILIAL = '" +xFilial("SC7") + "' AND D_E_L_E_T_ <> '*'"
		cQuery += " AND C7_FORNECE = '" +SDS->DS_FORNEC + "' AND C7_LOJA = '" +SDS->DS_LOJA + "'"
		If !lPedDoc
			cQuery += " AND C7_PRODUTO = '" +cProduto +"'"
		EndIf
		cQuery += " AND (C7_QUANT - C7_QUJE - C7_QTDACLA) > 0"
		cQuery += " AND C7_ENCER = ' ' AND C7_RESIDUO <> 'S'"
		If SuperGetMV("MV_RESTNFE") == "S"
			cQuery += " AND C7_CONAPRO <> 'B'"
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTmp,.T.,.T.)
		
		(cAliasTmp)->(dbGoTop())
		If (cAliasTmp)->(!EOF())
			lRet := Pedidos(cProduto,lPedDoc,cAliasTmp)
		Else
			Aviso("Aten็ใo",("Nใo hแ pedidos de compra para o produto " +AllTrim(cProduto) + " do documento " +AllTrim(SDS->DS_DOC)+"/"+AllTrim(SDS->DS_SERIE) +"."),{"OK"})
		EndIf
		(cAliasTmp)->(dbCloseArea())
	Else
		If SDS->DS_TIPO $ "D"
			lRet := F4NFORI(,,"M->DT_NFORI",SDS->DS_FORNEC,SDS->DS_LOJA,cProduto,"A140I",,@nRecSDT) .And. nRecSDT <> 0
		ElseIf SDS->DS_TIPO == "C"
			lRet := F4COMPL(,,,SDS->DS_FORNEC,SDS->DS_LOJA,cProduto,"A140I",@nRecSDT,"M->DT_NFORI") .And. nRecSDT <> 0
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    | Pedidos    ณAutor ณ TOTVS TMAP                  |Data ณ 01/01/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao | Funcao responsavel por criar o browse de selecao para que o      ณฑฑ
ฑฑณ          | usuario escolha os pedidos de compra referentes aos itens na NF  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cProduto: codigo do produto posicionado.						    ณฑฑ
ฑฑณ			 ณ lPedDoc: indica se a selecao e por documento.					ณฑฑ
ฑฑณ			 ณ cAliasTmp: alias com o resultado da query dos documentos			ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ lRet: indica a confirmacao da selecao dos pedidos                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Documentos														ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function Pedidos(cProduto,lPedDoc,cAliasTmp)
	Local lRet 		 := .F.
	Local oDlg		 := NIL
	Local oBrowse	 := NIL
	Local oOk		 := LoadBitMap(GetResources(),"LBOK")
	Local oNo		 := LoadBitMap(GetResources(),"LBNO")
	Local aPedidos	 := {}
	Local aArea		 := GetArea()
	Local aCampos    := {}
	Local aSize	     := MsAdvSize()
	Local nlTl1      := aSize[1]
	Local nlTl2    	 := aSize[2]
	Local nlTl3    	 := aSize[1]+300
	Local nlTl4		 := aSize[2]+480
	Local nX		 := 0
	Local nY		 := 0
	Local nPosQtde	 := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_QUANT"})
	Local lContinua	 := .T.
	Local lA140IPed  := ExistBlock("A140IPED")
	Local aRetPE     := {}
	Local nZ         := 0
	Local cCampoUsr  := ""
	Local aCampoUsr  := {}
	Local nPosCpo    := 0
	Local nCont		 := 1
	Local lInforma	 := .F.
	
	// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
	Private INCLUI      := .F.
	Private ALTERA      := .F.
	Private nTipoPed    := 1
	Private l120Auto    := .F.
	
	If !lPedDoc
		aCampos := {"",RetTitle("C7_NUM"),RetTitle("C7_ITEM"),RetTitle("C7_EMISSAO"),"Saldo"}
		bLine := {|| {	If(aPedidos[oBrowse:nAt,1],oOk,oNo),;								//-- Marca
		aPedidos[oBrowse:nAt,2],;											//-- Pedido
		aPedidos[oBrowse:nAt,3],;											//-- Item
		aPedidos[oBrowse:nAt,4],;											//-- Emissao
		Transform(aPedidos[oBrowse:nAt,5],PesqPict("SC7","C7_QUANT"))}} 	//-- Saldo
		
		// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		// |  Ponto de entrada utilizado para adicionar campos na interface de visualiza็ใo de pedidos  |
		// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lA140IPed
			aRetPE := ExecBlock("A140IPED",.F.,.F.,{2,aCampos,aCampos})
			If ValType(aRetPE[1]) == "A"
				For nZ:=1 to Len(aRetPe[1])
					Aadd(aCampoUsr,aRetPE[3][1][nZ+5])
				Next nZ
			EndIf
		EndIf
		
		&(cAliasTmp+"->(dbGoTop())")
		While &(cAliasTmp+"->(!EOF())")
			aAdd(aPedidos, {.F.,;															//-- Marca
			&(cAliasTmp+"->C7_NUM"),;										//-- Pedido
			&(cAliasTmp+"->C7_ITEM"),;										//-- Item
			StoD(&(cAliasTmp+"->C7_EMISSAO")),;								//-- Emissao
			&(cAliasTmp+"->C7_QUANT") - (&(cAliasTmp+"->C7_QTDACLA")),;	//-- Saldo
			&(cAliasTmp+"->C7_PRECO") })									//-- Preco unitario
			
			If lA140IPed
				If ValType(aRetPE[1]) == "A"
					For nZ:=1 to Len(aRetPe[1])
						cCampoUsr := "CAMPO"+AllTrim(Str(nZ))
						nPosCpo := AScan( aCampoUsr, {|x| AllTrim(x[1]) == cCampoUsr } )
						If nPosCpo > 0
							If nCont==1
								Aadd(aCampos,aCampoUsr[nPosCpo][3])
							EndIf
							If aRetPE[2][1][nZ+5][2]=="D"												// Se campo tipo Data
								Aadd(aPedidos[Len(aPedidos)],(StoD(&(cAliasTmp+"->"+aRetPE[1][nZ]))))	// Converte para data
							Else
								Aadd(aPedidos[Len(aPedidos)],((&(cAliasTmp+"->"+aRetPE[1][nZ]))))		// Caso contrแrio nใo converte
							EndIf
						Else
							Aadd(aPedidos[Len(aPedidos)],((&(cAliasTmp+"->"+aRetPE[1][nZ]))))
						EndIf
					Next nZ
				EndIf
				nCont++
			EndIf
			
			//-- Se o pedido ja esta no aCols, marca como usado
			If !Empty(aCols[n,GDFieldPos("DT_PEDIDO",aHeader)]) .And.;
					aCols[n,GDFieldPos("DT_PEDIDO")] == &(cAliasTmp+"->C7_NUM") .And.;
					aCols[n,GDFieldPos("DT_ITEMPC")] == &(cAliasTmp+"->C7_ITEM")
				aTail(aPedidos)[1] := .T.
			EndIf
			
			&(cAliasTmp)->(dbSkip())
		EndDo
		
		If lA140IPed
			If ValType(aRetPE[1]) == "A"
				If Len(aRetPE[1]) == 1
					bLine := {|| {	If(aPedidos[oBrowse:nAt,1],oOk,oNo),;								//-- Marca
					aPedidos[oBrowse:nAt,2],;											//-- Pedido
					aPedidos[oBrowse:nAt,3],;											//-- Item
					aPedidos[oBrowse:nAt,4],;											//-- Emissao
					Transform(aPedidos[oBrowse:nAt,5],PesqPict("SC7","C7_QUANT")),; 	//-- Saldo
					aPedidos[oBrowse:nAt,7],}}
				ElseIf Len(aRetPE[1]) == 2
					bLine := {|| {	If(aPedidos[oBrowse:nAt,1],oOk,oNo),;
						aPedidos[oBrowse:nAt,2],;
						aPedidos[oBrowse:nAt,3],;
						aPedidos[oBrowse:nAt,4],;
						Transform(aPedidos[oBrowse:nAt,5],PesqPict("SC7","C7_QUANT")),;
						aPedidos[oBrowse:nAt,7],;
						aPedidos[oBrowse:nAt,8],}}
				Else
					bLine := {|| {	If(aPedidos[oBrowse:nAt,1],oOk,oNo),;
						aPedidos[oBrowse:nAt,2],;
						aPedidos[oBrowse:nAt,3],;
						aPedidos[oBrowse:nAt,4],;
						Transform(aPedidos[oBrowse:nAt,5],PesqPict("SC7","C7_QUANT")),;
						aPedidos[oBrowse:nAt,7],;
						aPedidos[oBrowse:nAt,8],;
						aPedidos[oBrowse:nAt,9],}}
				EndIf
			EndIf
		EndIf
		
	Else
		aCampos := {"",RetTitle("C7_NUM"),RetTitle("C7_EMISSAO")}
		bLine := {|| {	If(aPedidos[oBrowse:nAt,1],oOk,oNo),;	//-- Marca
		aPedidos[oBrowse:nAt,2],;				//-- Pedido
		aPedidos[oBrowse:nAt,3]	}	}			//-- Emissao
		
		&(cAliasTmp+"->(dbGoTop())")
		While &(cAliasTmp+"->(!EOF())")
			aAdd(aPedidos, {.F.,;															//-- Marca
			&(cAliasTmp+"->C7_NUM"),;										//-- Pedido
			StoD(&(cAliasTmp+"->C7_EMISSAO"))	})							//-- Emissao
			
			//-- Se o pedido ja esta no aCols, marca como usado
			If !Empty(aCols[n,GDFieldPos("DT_PEDIDO")]) .And.;
					aCols[n,GDFieldPos("DT_PEDIDO")] == &(cAliasTmp+"->C7_NUM")
				aTail(aPedidos)[1] := .T.
			EndIf
			&(cAliasTmp)->(dbSkip())
		EndDo
	EndIf
	
	//-- Monta interface para selecao do pedido
	Define MsDialog oDlg Title "Vํnculo com Pedido de Compra" From nlTl1,nlTl2 To nlTl3,nlTl4 Pixel
	
	//-- Cabecalho
	@(nlTl1+10),nlTl2+3 To (nlTl1+22),(nlTl2+240) Pixel Of oDlg
	If !lPedDoc
		@(nlTl1+12),(nlTl2+8) Say "Doc: " +SDS->DS_DOC +" - " +  "Item: " +AllTrim(aCols[n,GDFieldPos("DT_ITEM")]) +" / " +AllTrim(cProduto) + " - " + Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC") Pixel Of oDlg
	Else
		@(nlTl1+12),(nlTl2+8) Say "Doc: " +SDS->DS_DOC +" - " + " Fornecedor " +SDS->DS_FORNEC +"/" +SDS->DS_LOJA +" - " +Posicione("SA2",1,xFilial("SA2")+SDS->(DS_FORNEC+DS_LOJA),"A2_NOME") Pixel Of oDlg
	EndIf
	
	//-- Itens
	oBrowse := TCBrowse():New(nlTl1+30,nlTl2+3,nlTl4-245,nlTl3-200,,aCampos,,oDlg,,,,,{|| MarcaPC(@aPedidos,oBrowse:nAt,lPedDoc),oBrowse:Refresh()},,,,,,,,,.T.)
	oBrowse:SetArray(aPedidos)
	oBrowse:bLine := bLine
	
	//-- Botoes
	TButton():New(nlTl1+134,nlTl2+3,"Visualizar pedido",oDlg,{|| MsgRun("Carregando visualiza็ใo do pedido " +AllTrim(aPedidos[oBrowse:nAt,2]) +"...","", {|| A120Pedido("SC7",GetC7Recno(aPedidos[oBrowse:nAt,2]),2)})},055,012,,,,.T.)
	
	Define SButton From nlTl1+134,nlTl2+177 Type 1 Action Eval({|| If(lRet := ValidPC(cProduto,lPedDoc,aPedidos,oBrowse:nAt),oDlg:End(),)}) Enable Of oDlg
	Define SButton From nlTl1+134,nlTl2+212 Type 2 Action oDlg:End() Enable Of oDlg
	
	Activate Dialog oDlg Centered
	
	If lRet
		SC7->(dbSetOrder(2))
		IF lPedDoc
			For nX := 1 To Len(aCols)
				aCols[nX,GDFieldPos("DT_PEDIDO")] 	:= CriaVar("DT_PEDIDO",.F.)
				aCols[nX,GDFieldPos("DT_ITEMPC")] 	:= CriaVar("DT_ITEMPC",.F.)
				aCols[nX,GDFieldPos("DT_XCC")] 		:= CriaVar("DT_XCC",.F.)
			Next nX
		EndIf
		For nX := 1 To Len(aPedidos)
			If aPedidos[nX,1] //-- Preenche aCols com o item marcado
				If !lPedDoc
					aCols[n,GDFieldPos("DT_PEDIDO")] := aPedidos[nX,2]
					aCols[n,GDFieldPos("DT_ITEMPC")] := aPedidos[nX,3]
					aCols[n,GDFieldPos("DT_XCC")] 	 := POSICIONE("SC7",1,XFILIAL("SC7") + aPedidos[nX,2] + aPedidos[nX,3],"C7_CC") 
					cCondPag	:= POSICIONE("SC7",1,XFILIAL("SC7") + aPedidos[nX,2],"C7_COND")
					GridVenc() 
					//oBrowse:Refresh()
					Exit
				Else
					For nY := 1 To Len(aCols)
						If SC7->(dbSeek(xFilial("SC7")+	aCols[nY,GDFieldPos("DT_COD")]+SDS->(DS_FORNEC+DS_LOJA)+aPedidos[nX,2]))
							While SC7->(!EOF()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_PRODUTO == aCols[nY,GDFieldPos("DT_COD")] .And.;
									SC7->C7_FORNECE == SDS->DS_FORNEC .And. SC7->C7_LOJA == SDS->DS_LOJA .And. SC7->C7_NUM == aPedidos[nX,2]
								If aCols[nY,nPosQtde] <= SC7->C7_QUANT
									aCols[nY,GDFieldPos("DT_PEDIDO")] 	:= SC7->C7_NUM
									aCols[nY,GDFieldPos("DT_ITEMPC")] 	:= SC7->C7_ITEM
									aCols[nY,GDFieldPos("DT_XCC")] 		:= SC7->C7_CC
									cCondPag	:= SC7->C7_COND 
									//oBrowse:Refresh()
									lContinua := .F.
								Else
									If !lInforma
										AVISO("Aten็ใo","Para os itens do pedido com quantidade inferior aos itens correspondentes da nota utilize a op็ใo de vํnculo por Item.",{"Verificar dado NF Origem."})
										lInforma := .T.
									EndIf
								EndIf
								
								SC7->(dbSkip())
							End
						EndIf
					Next nY
					IF !lContinua
						Exit
					EndIf
				EndIf
			Else
				aCols[n,GDFieldPos("DT_PEDIDO")] 	:= CriaVar("DT_PEDIDO",.F.)
				aCols[n,GDFieldPos("DT_ITEMPC")] 	:= CriaVar("DT_ITEMPC",.F.)
				aCols[n,GDFieldPos("DT_XCC")] 		:= CriaVar("DT_XCC",.F.)
			EndIf
		Next nX
	EndIf
	
	RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    | ValidPC    ณAutor ณ TOTVS TMAP              	   |Data ณ 01/01/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao | Validacao dos campos qtde e preco Unit. do pedido de compra com  ณฑฑ
ฑฑณ			 | o documento NFe.						                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametros| cCodProd: codigo do produto.										ณฑฑ
ฑฑณ          | lPedDoc: indica se a busca e por documento ou item.				ณฑฑ
ฑฑณ          | aPedidos: array com os pedidos exibidos na tela de vinculo.		ณฑฑ
ฑฑณ          | nLinha: indica a linha do browse de pedidos que foi marcada.		ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ lRet: pedido valido ou nao valido                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Pedidos		                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function ValidPC(cCodProd,lPedDoc,aPedidos,nLinha)
	Local lRet  := .T.
	Local aArea	:= SDT->(GetArea())
	
	// Ponto de entrada para validacao do pedido selecionado
	If ExistBlock("COMCOLPC")
		lRet := ExecBlock("COMCOLPC",.F.,.F.,{aCols,"TMP"})
	ElseIf !lPedDoc
		//-- Verifica se quantidade e preco sao diferentes para alertar o usuario
		SDT->(dbSetOrder(3))
		SDT->(dbSeek(xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)+cCodProd))
		If aPedidos[nLinha,1] .And. (SDT->DT_QUANT <> aPedidos[nLinha,5] .Or. SDT->DT_VUNIT <> aPedidos[nLinha,6])
			lRet := MsgYesNo("A quantidade e/ou pre็o unitแrio do pedido selecionado ้ divergente do item da NF-e. Confirma o vํnculo?","Aten็ใo")
		EndIF
	EndIf
	SDT->(RestArea(aArea))
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    | MarcaPC	  ณAutor ณ TOTVS TMAP        	       |Data ณ 01/01/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao | Executada quando o registro e marcado para desmarcar os demais.  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ aPedidos: array com os pedidos exibidos em tela.					ณฑฑ
ฑฑณ			 ณ nLinha: linha do pedido que foi marcado.							ณฑฑ
ฑฑณ			 ณ lPedDoc: indica se e selecao por documento.						ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Pedidos	                                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function MarcaPC(aPedidos,nLinha,lPedDoc)
	Local nDesmarca := 0
	
	//-- Desmarca o item que ja estava marcado
	If !lPedDoc
		nDesmarca := aScan(aPedidos,{|x| x[1]})
		If nDesmarca == nLinha
			nDesmarca := aScan(aPedidos,{|x| x[1]},nLinha+1)
		EndIf
		If !Empty(nDesmarca)
			aPedidos[nDesmarca,1] := .F.
		EndIf
	EndIf
	aPedidos[nLinha,1] := !aPedidos[nLinha,1]
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    | GetC7Recno ณAutor ณ TOTVS TMAP       		   |Data ณ 01/01/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao | Funcao para retornar o recno do pedido.                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cPedido: numero do pedido de compra                             	ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ nRet: recno do pedido de compra									ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Pedidos														    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function GetC7Recno(cPedido)
	Local nRet := 0
	
	SC7->(dbSetOrder(1))
	If SC7->(dbSeek(xFilial("SC7")+cPedido))
		nRet := SC7->(Recno())
	EndIf
	
Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  | NOMEFORIni ณAutor ณ TOTVS TMAP          		   |Data ณ 01/01/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao | Busca o nome do cliente quando o tipo da nota for devolucao ou   ณฑฑ
ฑฑณ			 | beneficiamento caso contrario busca o nome do fornecedor.   		ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nome do fornecedor/cliente                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Inicializador do campo DS_NOMEFOR (X3_RELACAO e X3_INIBRW)       ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

STATIC Function NOMEFORIni()
	Local cNomeFC := ""
	
	If SDS->DS_TIPO $ "DB"
		cNomeFC := Posicione("SA1",1,xFilial("SA1")+SDS->(DS_FORNEC+DS_LOJA),"A1_NOME")
	Else
		cNomeFC := Posicione("SA2",1,xFilial("SA2")+SDS->(DS_FORNEC+DS_LOJA),"A2_NOME")
	EndIf
	
Return(cNomeFC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณ CPNJPict บAutor  ณ TOTVS TMAP         บ Data ณ  01/01/16     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna a picture de acordo com o tipo do fornecedor/cliente.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MATA140I                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function CPNJPict()
	Local cAlias := If(SDS->DS_TIPO $ "DB","SA1","SA2")
Return PicPes(Posicione(cAlias,1,xFilial(cAlias)+M->(DS_FORNEC+DS_LOJA),Substr(cAlias,2)+"_TIPO"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  | NFORIValid ณAutor ณ TOTVS TMAP          		   |Data ณ 01/01/16 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao | Valida o preenchimento da NF de Origem quando a nota for Dev/Compณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ lRet                                    							ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ COMXCOL	                                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function NFORIValid()
	Local lRet 	   	 := .T.
	Local cCampo   	 := ReadVar()
	Local aAreaSF2	:= SF2->(GetArea())
	Local aAreaSD2	:= SD2->(GetArea())
	Local aAreaSF1	:= SF1->(GetArea())
	Local aAreaSD1	:= SD1->(GetArea())
	
	If SDS->DS_TIPO == "D"
		SF2->(dbSetOrder(1))
		If cCampo == "M->DT_NFORI" .And. !Empty(AllTrim(M->DT_NFORI))
			If !SF2->(dbSeek(xFilial("SF2")+M->DT_NFORI))
				Aviso("Aten็ใo","Nใo foi possํvel locazilar a NF de Origem.",{"Verificar dado NF Origem."})
				lRet := .F.
			Else
				aCols[n,GdFieldPos("DT_SERIORI")] := CriaVar("DT_SERIORI",.F.)
				aCols[n,GdFieldPos("DT_ITEMORI")] := CriaVar("DT_ITEMORI",.F.)
			EndIf
		ElseIf cCampo == "M->DT_SERIORI"
			If !Empty(AllTrim(M->DT_SERIORI))
				If Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
					Aviso("Aten็ใo","Data Nota Fiscal de Origem nใo informado",{"Verificar dados NF Origem"})
					lRet := .F.
				ElseIf !Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
					If !SF2->(dbSeek(xFilial("SF2")+aCols[n,GdFieldPos("DT_NFORI")]+M->DT_SERIORI))
						Aviso("Aten็ใo","Nใo foi possํvel locazilar a NF de Origem.",{"Verificar dado NF Origem."})
						lRet := .F.
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "M->DT_ITEMORI"
			If !Empty(AllTrim(M->DT_ITEMORI))
				If Val(M->DT_ITEMORI) > 0
					M->DT_ITEMORI := PADL(Val(M->DT_ITEMORI),2,"0")
				EndIf
				If Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
					Aviso("Aten็ใo","Nใo foi possํvel locazilar a NF de Origem.",{"Verificar dado NF Origem."})
					lRet := .F.
				ElseIf !Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
					DbSelectArea("SF2")
					DbSetOrder(1)
					MsSeek(xFilial("SF2")+aCols[n,GdFieldPos("DT_NFORI")]+aCols[n,GdFieldPos("DT_SERIORI")] )
					
					dbSelectArea("SD2")
					dbSetOrder(3)
					If !MsSeek(xFilial('SD2')+aCols[n,GdFieldPos("DT_NFORI")]+aCols[n,GdFieldPos("DT_SERIORI")]+SF2->F2_CLIENTE+SF2->F2_LOJA+aCols[n,GdFieldPos("DT_COD")]+M->DT_ITEMORI)
						Aviso("Aten็ใo","Nใo foi possํvel locazilar a NF de Origem.",{"Verificar dado NF Origem."})
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf SDS->DS_TIPO == "C"
		SF1->(dbSetOrder(1))
		If cCampo == "M->DT_NFORI" .And. !Empty(AllTrim(M->DT_NFORI))
			If !SF1->(dbSeek(xFilial("SF1")+M->DT_NFORI))
				Aviso("Aten็ใo","Nใo foi possํvel locazilar a NF de Origem.",{"Verificar dado NF Origem."})
				lRet := .F.
			Else
				aCols[n,GdFieldPos("DT_SERIORI")] := CriaVar("DT_SERIORI",.F.)
				aCols[n,GdFieldPos("DT_ITEMORI")] := CriaVar("DT_ITEMORI",.F.)
			EndIf
		ElseIf cCampo == "M->DT_SERIORI"
			If !Empty(AllTrim(M->DT_SERIORI))
				If Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
					Aviso("Aten็ใo","NF de Origem nใo informado.",{"Verificar dado NF Origem."})
					lRet := .F.
				ElseIf !Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
					If !SF1->(dbSeek(xFilial("SF1")+aCols[n,GdFieldPos("DT_NFORI")]+M->DT_SERIORI))
						Aviso("Aten็ใo","Nใo foi possํvel locazilar a NF de Origem.",{"Verificar dado NF Origem."})
						lRet := .F.
					EndIf
				EndIf
			EndIf
		ElseIf cCampo == "M->DT_ITEMORI"
			If !Empty(AllTrim(M->DT_ITEMORI))
				If Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
					Aviso("Aten็ใo","NF de Origem nใo informada",{"Verificar dado NF Origem."})
					lRet := .F.
				ElseIf !Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
					DbSelectArea("SF1")
					DbSetOrder(1)
					MsSeek(xFilial("SF1")+aCols[n,GdFieldPos("DT_NFORI")]+aCols[n,GdFieldPos("DT_SERIORI")] )
					
					dbSelectArea("SD1")
					dbSetOrder(1)
					If !MsSeek(xFilial('SD1')+aCols[n,GdFieldPos("DT_NFORI")]+aCols[n,GdFieldPos("DT_SERIORI")]+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[n,GdFieldPos("DT_COD")]+M->DT_ITEMORI)
						Aviso("Aten็ใo","Nใo foi possํvel locazilar a NF de Origem.",{"Verificar dado NF Origem."})
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD2)
	RestArea(aAreaSF2)
	
Return (lRet)


/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSchedComColบAutor  ณSchedComCol         บ Data ณ  08/06/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para ser schedulada e processar a importacao dos     บฑฑ
ฑฑบ          ณ arquivos TOTVS                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ aParam: array de parametros recebidos do schedule Protheus. บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACOM                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function IMPCTE1A(aParam)
	Local aFiles := {}
	Local nX	 := 0
	Local NY	 := 0
	Local aProc  := {}
	Local aErros := {}
	
	//-- Loga empresa e filial
	//RpcSetType(3)
	//RpcSetEnv(aParam[1],aParam[2],,,"COM")
	
	//-- Prepara estrutura de diretorios
	If !ExistDir(DIRXML)
		MakeDir(DIRXML)
		MakeDir(DIRXML +DIRALER)
		MakeDir(DIRXML +DIRLIDO)
		MakeDir(DIRXML +DIRERRO)
	EndIf
	
	//-- Comunica com TSS para baixa dos documentos disponiveis
	//COMXCOLTSS()
	
	//-- Processa importacao dos arquivos baixados
	aFiles := Directory("\" +DIRXML +DIRALER +"*.xml")
	For nX := 1 To Len(aFiles)
		XMLImp(aFiles[nX,1],.T.,@aProc,@aErros)
	Next nX
	
	_cMSGErro	:= ""
	
	For nX := 1 To Len(aErros)
		FOR NY := 1 TO LEN(aErros[nX])
			IF VALTYPE(aErros[nX][NY]) == "C"
				_cMSGErro	+= aErros[nX][NY] + Chr(13)+Chr(10)
			ENDIF
		NEXT NY
		_cMSGErro	+= Chr(13)+Chr(10)
	Next nX	
	
	//MSGINFO(_cMSGErro)	
	xMagHelpFis("Inconsistencia na Importa็ใo",_cMSGErro,"Corrija os erros apresentados e importe novamente")	
	
	//-- Dispara M-Messenger para erros (evento 052)
	//If !Empty(aErros)
//		MEnviaMail("052",aErros)
//	EndIf
	
	//-- Dispara M-Messenger para docs disponiveis (evento 053)
//	If !Empty(aProc)
		//MEnviaMail("053",aProc)
//	EndIf
	
	//RpcClearEnv()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXMLImp    บAutor  ณ TOTVS TMAP 		 บ Data ณ  01/01/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que realiza a importacao de um arquivo XML do TOTVS บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cFile: caminho do arquivo que esta sendo importado.		  บฑฑ
ฑฑบ			 ณ lJob: indica se o processamento esta sendo fendo em job.	  บฑฑ
ฑฑบ			 ณ aProc: array para guardar os arquivos processados (M-Mess).บฑฑ
ฑฑบ			 ณ aErros: array para guardar os arquivos com erros (M-Mess). บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ lRet: indica se a importacao foi realizada.				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SchedComCol                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function XMLImp(cFile,lJob,aProc,aErros)
	Local lRet 	   := .T.
	Local cError   := ""
	Local cWarning := ""
	Local oFullXml := NIL
	Local cXMLOri  := ""
	Local cXMLEncod:= ""
	Local nHandle  := 0
	Local nLength  := 0
	Local nNFeAut  := SuperGetMV("MV_COMCOL1",.F.,0)
	
	Private LTOMA4NFORI	:= .T.
	
	nHandle := FOpen(DIRXML +DIRALER +cFile)
	nLength := FSeek(nHandle,0,FS_END)
	FSeek(nHandle,0)
	If nHandle > 0
		FRead(nHandle, cXMLOri, nLength)
		FClose(nHandle)
		If !Empty(cXMLOri)
			If SubStr(cXMLOri,1,1) != "<"
				nPosPesq := At("<",cXMLOri)
				cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
			EndIf
		EndIf
		cXMLEncod := EncodeUtf8(cXMLOri)
		// Verifica se o encode ocorreu com sucesso, pois alguns caracteres especiais provocam erro na funcao de encode, neste caso e feito o tratamento pela funcao A140IRemASC
		If Empty(cXMLEncod)
			cStrXML := cXMLOri
			cXMLOri := A140IRemASC(cStrXML)
			cXMLEncod := EncodeUtf8(cXMLOri)
		EndIf
		If Empty(cXMLEncod)
			cXMLEncod := cXMLOri
		EndIf
	EndIf
	
	If !Empty(cXMLEncod)
		oFullXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
	EndIf
	If !File(DIRXML +DIRALER +cFile)
		If lJob
			aAdd(aErros,{cFile,"Arquivo inexistente.","Nใo se aplica."})
		Else
			Aviso("Erro","Arquivo" +cFile +"inexistente",{"OK"},2,"COMXCOMImp")
		EndIf
		lRet := .F.
	ElseIf !Empty(cError) //-- Erro na sintaxe do XML
		If lJob
			aAdd(aErros,{cFile,"Erro de sintaxe no arquivo XML:" +cError,"Entre em contato com o emissor do documento e comunique a ocorr๊ncia."})
		Else
			Aviso("Erro",cError,{"OK"},2,"COMXCOMImp")
		EndIf
		lRet := .F.
	Else //-- Direciona processamento conforme tipo de documento
		If ValType(oFullXML)=="O"
			Do Case
			//Case ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O" //-- Nota normal, devolucao, beneficiamento, bonificacao
			//	lRet := ImpXML_NFe(cFile,lJob,@aProc,@aErros,.F.,oFullXml:_NFeProc:_NFe)
			Case ValType(XmlChildEx(oFullXML,"_CTE")) == "O" //-- Nota de transporte
				//Verifica se hแ integra็ใo com o Frete Embarcador
				If SuperGetMV("MV_INTGFE",.F.)
					lRet := GFEA118XML(cFile,@aProc,@aErros,oFullXml:_CTe)
				Else
					lRet := u_IMPCTE2(cFile,lJob,@aProc,@aErros,oFullXml:_CTe)
					//lRet := ImpXML_Cte(cFile,lJob,@aProc,@aErros,oFullXml:_CTe)
					//ImpXML_Cte
				EndIf
			Case ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
				//Verifica se hแ integra็ใo com o Frete Embarcador
				If SuperGetMV("MV_INTGFE",.F.)
					lRet := GFEA118XML(cFile,@aProc,@aErros,oFullXml:_CTeProc:_Cte)
				Else
					lRet := u_IMPCTE2(cFile,lJob,@aProc,@aErros,oFullXml:_CTeProc:_Cte)
					//lRet := ImpXML_Cte(cFile,lJob,@aProc,@aErros,oFullXml:_CTeProc:_Cte)
				EndIf
			//Case ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O" //-- Nota Fiscal Complementar
			//	lRet := ImpXML_Ave(cFile,lJob,@aProc,@aErros,oFullXml:_INVOIC_NFE_COMPL)
			//Case ValType(XmlChildEx(oFullXML:_TOTVSMESSAGE:_BUSINESSMESSAGE,"_PROCNEOGRIDNFSE")) == "O" // Nota de Servico
			//	lRet := ImpXML_NFs(cFile,lJob,@aProc,@aErros,oFullXml:_TOTVSMESSAGE:_BUSINESSMESSAGE:_PROCNEOGRIDNFSE)
			EndCase
		EndIf
		If lRet .And. (nNFeAut == 1 .Or. nNFeAut == 2)
			ProcDocs(SDS->(Recno()),.T.)
		EndIf
	EndIf
	
Return lRet

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณComXTudoOkณ Autor ณ TOTVS                 ณ Data ณ01.01.2016 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณRotina de avaliacao TudOk                                    ณฑฑ
ฑฑณ          ณ                                                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpL1: .T. -> Linha valida                                   ณฑฑ
ฑฑณ          ณ       .F. -> Linha invalida                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณEsta rotina tem como objetivo efetuar a validacao das        ณฑฑ
ฑฑณ          ณlinhas da getdados para a rotina de atualizacao do registro  ณฑฑ
ฑฑณ          ณimportado pelo TOTVS Colabora็ใo                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Materiais                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC Function ComXTudoOk()
	
	Local nPosNfOri		:= aScan(aHeader,{|x| AllTrim(x[2])=="DT_NFORI"})
	Local nPosSerOri	:= aScan(aHeader,{|x| AllTrim(x[2])=="DT_SERIORI"})
	Local nPosItOri		:= aScan(aHeader,{|x| AllTrim(x[2])=="DT_ITEMORI"})
	Local nPosCod		:= aScan(aHeader,{|x| AllTrim(x[2])=="DT_COD"})
	Local nPosQtd		:= aScan(aHeader,{|x| AllTrim(x[2])=="DT_QUANT"})
	Local nPosVUni		:= aScan(aHeader,{|x| AllTrim(x[2])=="DT_VUNIT"})
	Local nPosItem		:= aScan(aHeader,{|x| AllTrim(x[2])=="DT_ITEM"})
	Local nPosTES		:= aScan(aHeader,{|x| AllTrim(x[2])=="DT_XTES"})
	Local aAreaSF2		:= SF2->(GetArea())
	Local aAreaSD2		:= SD2->(GetArea())
	Local aAreaSF1		:= SF1->(GetArea())
	Local aAreaSD1		:= SD1->(GetArea())
	Local lRet			:= .T.
	Local nX			:= 0
	Local nCont			:= 0
	Local I				:= 0
	
/*	IF EMPTY(cCondPag)
		Aviso("Aten็ใo","Nใo foi informado a Condi็ใo de Pagamento",{"Informar Condi็ใo de Pagamento."})
		lRet := .F.
	ENDIF
	
	For nX := 1 To Len(aCols)
		If Empty(AllTrim(aCols[nX][nPosTES]))
			Aviso("Aten็ใo","ษ obrigatario informar a TES para todos os itens",{"Preencher a TES."})
			lRet := .F. 
			Exit
		ENDIF
	NEXT*/
	
	_nTotFin	:= 0
	IF LEN(_aValores) > 0
		FOR I := 1 TO LEN(_aValores)
			_nTotFin += _aValores[I][2]
		NEXT
	ENDIF
	
	IF _nTotFin <> SDS->DS_VALMERC
		Aviso("Aten็ใo","Valor total financeiro diferente do valor total da NF",{"Conferir Parcelas do Financeiro."})
		lRet := .F.
	ENDIF
	
	If SDS->DS_TIPO == "D"		// Nota de Devolu็ใo
		For nX := 1 To Len(aCols)
			If !Empty(AllTrim(aCols[nX][nPosNfOri]))
				If Empty(AllTrim(aCols[nX][nPosItOri]))
					Aviso("Aten็ใo","Item: "+aCols[nX][nPosItem]+" nใo foi informado a NF Origem",{"Verificar dado NF Origem."})
					lRet := .F.
					nCont++
					Exit
				Else
					DbSelectArea("SF2")
					DbSetOrder(1)
					MsSeek(xFilial("SF2")+aCols[nX][nPosNfOri]+aCols[nX][nPosSerOri] )
					
					dbSelectArea("SD2")
					dbSetOrder(3)
					If MsSeek(xFilial('SD2')+aCols[nX][nPosNfOri]+aCols[nX][nPosSerOri]+SF2->F2_CLIENTE+SF2->F2_LOJA+aCols[nX][nPosCod]+aCols[nX][nPosItOri])
						If SD2->D2_QUANT < aCols[nX][nPosQtd]
							Aviso("Aten็ใo","Item: "+aCols[nX][nPosItem]+" verificar quantidade informada com saldo da NF Origem",{"Verificar quantidade"})
							lRet := .F.
							nCont++
							Exit
						EndIf
					Else
						Aviso("Aten็ใo","Item: "+aCols[nX][nPosItem]+" NF Origem nใo encontrada",{"Verificar Documento"})
						lRet := .F.
						nCont++
						Exit
					EndIf
				EndIf
				nCont++
			ElseIf !Empty(AllTrim(aCols[nX][nPosSerOri])) .Or. !Empty(AllTrim(aCols[nX][nPosItOri]))
				Aviso("Aten็ใo","Item: "+aCols[nX][nPosItem]+"",{"Verificar dados NF origem"})
			EndIf
		Next nX
	EndIf
	
	IF lRet
		oDlg:End()
	ENDIF
	
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD2)
	RestArea(aAreaSF2)
	
Return(lRet)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณComXGetAntณ Autor ณ TOTVS                 ณ Data ณ01.01.2016 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณEsta rotina tem como objetivo retornare a GetDados ao        ณฑฑ
ฑฑณ          ณseu estado anterior ao clicar no botใo cancelar no vํnculo   ณฑฑ
ฑฑณ          ณde documentos                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Materiais                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC Function ComXGetAnt(aColsAnt)
	
	If SDS->DS_TIPO == "D"		// Nota de Devolu็ใo
		aCols := aClone(aColsAnt)
	EndIf
	
Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGridVenc  บ Autor ณ TOTVS TMAP         บ Data ณ  00/00/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche o grid do titulo a pagar                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GridVenc()

	local I	:= 0

aVencto		:= Condicao(SDS->DS_VALMERC,cCondPag,,SDS->DS_EMISSA)//nPEValor,cPECondicao,nPEValIPI,dPEDEmissao,nPEValSol)
_aValores	:= {}

IF LEN(aVencto) > 0
	FOR I := 1 TO LEN(aVencto)	
		aAdd(_aValores, {	aVencto[I][1]		,; 	//1 
							aVencto[I][2]		})	//2
	NEXT
ELSE
	_aValores	:= {{STOD(""),0}}
ENDIF

oBoxLib:SetArray(_aValores)
oBoxLib:bLine := {|| {	_aValores[oBoxLib:nAt,1],TRANSFORM(_aValores[oBoxLib:nAt,2],"@E 999,999,999.99")}}
oBoxLib:Refresh()  

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTelaVenc  บ Autor ณ TOTVS TMAP         บ Data ณ  00/00/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche o grid do titulo a pagar                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TelaVenc()                        
Local oFont1 := TFont():New("MS Sans Serif",,018,,.F.,,,,,.F.,.F.)
Local oGet1
Local dGet1 := _aValores[oBoxLib:nAt,1]
Local oGet2
Local nGet2 := _aValores[oBoxLib:nAt,2]
Local oSay1
Local oSay2
Local oSay3
Local oSButton1
Local oSButton2
Local oDlg

  DEFINE MSDIALOG oDlg TITLE "Dados da Parcela" FROM 000, 000  TO 200, 300 COLORS 0, 16777215 PIXEL

    @ 008, 009 SAY oSay3 PROMPT "Informe os dados da Parcela:" SIZE 116, 013 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 027, 008 SAY oSay1 PROMPT "Data de Vencimento:" SIZE 058, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 025, 069 MSGET oGet1 VAR dGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 048, 008 SAY oSay2 PROMPT "Valor Parcela:" SIZE 058, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 046, 069 MSGET oGet2 VAR nGet2 SIZE 060, 010 OF oDlg PICTURE "@E 999,999,999.99" COLORS 0, 16777215 PIXEL
    DEFINE SBUTTON oSButton1 FROM 077, 026 TYPE 01 OF oDlg ENABLE ACTION {||_lRet := .T.,oDlg:END()}
    DEFINE SBUTTON oSButton2 FROM 077, 093 TYPE 02 OF oDlg ENABLE ACTION {||_lRet := .F.,oDlg:END()}
    

  ACTIVATE MSDIALOG oDlg CENTERED
  
  IF _lRet
  	_aValores[oBoxLib:nAt,1]	:= dGet1
  	_aValores[oBoxLib:nAt,2]	:= nGet2
  	oBoxLib:Refresh()
  ENDIF

Return

USER FUNCTION IMPCTE1B()

Local _cRet	:= ""
DBSELECTAREA("SF4")
DBSETORDER(1)
IF DBSEEK(XFILIAL("SF4") + &(READVAR()))
	_cRet	:= SF4->F4_CF
	IF SM0->M0_ESTENT <> M->DS_EST
		_cRet := "2" + SUBSTR(_cRet,2,3)
	ENDIF
ENDIF

RETURN _cRet