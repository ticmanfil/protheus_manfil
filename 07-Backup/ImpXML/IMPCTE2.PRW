#INCLUDE 'Protheus.ch'

#DEFINE DIRXML  "XMLNFE\"
#DEFINE DIRALER "NEW\"
#DEFINE DIRLIDO "OLD\"
#DEFINE DIRERRO "ERR\"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | IMPCTE2    ³Autor ³ TOTVS TMAP              	   |Data ³ 01/01/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Faz o processamento do arquivo xml CT-e no diretorio NEW para	³±±
±±³			 | gravar os registros do arquivo XML nas tabelas SDS e SDT.		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros| cFile: caminho do Arquivo XML.                              		³±±
±±³          | lJob: indica se a rotina esta sendo executada via JOB.	    	³±±
±±³          | aProc: grava msgs de sucesso no array aProc durante a importacao.³±±
±±³          | aErros: grava msg de falha no array durante a importacao.	  	³±±
±±³          | oXMl: objeto com o conteudo XML do documento.					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet: indica se a importacao foi feita com sucesso.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Totvs                                                         	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
user Function IMPCTE2(cFile,lJob,aProc,aErros,oXml,aErroErp)
	
	Local cPrdFrete		:= ""
	Local _cConta		:= ""
	Local lRet      	:= .T.
	Local lRemet 	 	:= .F.
	Local lDelFile	 	:= .T.
	Local lDesTrFil	 	:= .F.
	Local lCliente	 	:= .F.
	Local lDevSemSF1 	:= .F.
	Local lToma4	 	:= .F.
	Local nX		 	:= 0
	Local nPesoBruto 	:= 0
	Local nPesoLiqui 	:= 0
	Local nY		 	:= 0
	Local nCount	 	:= 0
	Local cError    	:= ""
	Local cCNPJ_CT	 	:= ""
	Local cCNPJ_CF	 	:= ""
	Local cFornCTe   	:= ""
	Local cLojaCTe   	:= ""
	Local cNomeCTe   	:= ""
	Local cEstCTe		:= ""
	Local cNatuCTe		:= ""
	Local cCodiRem   	:= ""
	Local cLojaRem   	:= ""
	Local cChaveNF   	:= ""
	Local cTES_CT 	 	:= ""
	Local cCPag_CT 	 	:= ""
	Local cTipoFrete 	:= ""
	Local cTagDest	 	:= ""
	local cTagRem		:= ""
	Local cQuery	 	:= ""
	Local cTabRem	 	:= ""
	Local cRetPrd	 	:= ""
	Local aDadosFor  	:= Array(2) //-- 1- Codigo; 2-Loja
	Local aDadosCli  	:= Array(2) //-- 1- Codigo; 2-Loja
	Local aCabec116	 	:= {}
	Local aItens116	 	:= {}
	Local aAux		 	:= {}
	Local aEspecVol  	:= {}
	Local aAux1		 	:= {}
	Local aAuxFor	 	:= {}
	Local aParamPE	 	:= {}
	Local lMt116XmlCt	:= ExistBlock("MT116XMLCT")
	Local lA116IFor	 	:= ExistBlock("A116IFOR")
	Local lA116ITPCT 	:= ExistBlock("A116ITPCT")
	Local cVersao		:= oXML:_InfCte:_Versao:Text
	Local nTamFil		:= 0
	Local lComp			:= .F. // Indica se CTe é do tipo complementar
	
	// Variaveis para apuracao do ICMS
	Local oICMS
	Local oICMSTipo
	Local oICMSNode
	Local nZ			:= 0
	Local nBaseICMS 	:= 0
	Local nValICMS		:= 0
	Local nAliqICMS		:= 0
	Local lBaseICMS 	:= .F.
	Local lValICMS		:= .F.
	Local lAliqICMS		:= .F.
	Local lFornExt		:= .F.
	Local lNewColab   	:= Findfunction("ColUsaColab") .And. ColUsaColab('6')
	
	Default lJob    	:= .T.
	Default aProc   	:= {}
	Default aErros  	:= {}
	Default aErroERP 	:= {}
	
	//-- Verifica se o arquivo pertence a filial corrente
	If !U_IMPCTE2B(oXML,SM0->M0_CGC,@lDesTrFil,@lToma4,lJob,cFile)
		If !lJob
			aAdd(aErros,{cFile,"Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial corrente.",""})
			Aviso("Erro","Este XML pertence a outra empresa/filial e não podera ser processado na empresa/filial corrente.",{"OK"},2,"IMPCTE2")
		EndIf
		aAdd(aErroErp,{cFile,"COM002"})
		lDelFile := .F.
		lRet := .F.
	EndIf
	
	//-- Verifica se o ID ja foi processado
	If lRet
		SDS->(dbSetOrder(2))
		If lRet .And. SDS->(dbSeek(xFilial("SDS")+Right(AllTrim(oXML:_InfCte:_Id:Text),44)))
			If lJob
				aAdd(aErros,{cFile,"ID de CT-e já registrado na NF " +SDS->(DS_DOC+"/"+DS_SERIE); //"ID de CT-e já registrado na NF "
				+ "do Fornecedor/Cliente " + " (" +SDS->(DS_FORNEC +"/" +DS_LOJA)+ ").","Exclua o documento registrado na ocorrência"}) //"do Fornecedor/Cliente "#"Exclua o documento registrado na ocorrência."
			Else
				Aviso("Aviso ","ID de CT-e já registrado na NF " +SDS->(DS_DOC+"/"+DS_SERIE);
					+ "do Fornecedor/Cliente " + SDS->(DS_FORNEC+"/"+DS_LOJA) +".",{"OK"},2,"IMPCTE2")
			EndIf
			aAdd(aErroErp,{cFile,"COM019"})
			lRet := .F.
		EndIf
	EndIf
	
	//-- Verifica se CTe é do tipo complementar
	If lRet .And. Valtype(XmlChildEx(oXml:_InfCte,"_INFCTECOMP")) != "U"
		lComp := .T.
	EndIf
	
	//-- Verifica se o fornecedor do conhecimento esta cadastrado no sistema.
	If lRet
		If ValType(XmlChildEx(oXML:_InfCte:_Emit,"_CNPJ")) <> "U"
			cCNPJ_CT := AllTrim(oXML:_InfCte:_Emit:_CNPJ:Text)
		Else
			cCNPJ_CT := AllTrim(oXML:_InfCte:_Emit:_CPF:Text)
		EndIf
		SA2->(dbSetOrder(3))
		If !SA2->(dbSeek(xFilial("SA2")+cCNPJ_CT))
			If lJob
				aAdd(aErros,{cFile,"Fornecedor" + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R 99.999.999/9999-99") +"] "+ "inexistente na base","Gere cadastro para este fornecedor."}) //"Fornecedor"#"inexistente na base."#"Gere cadastro para este fornecedor."
			Else
				Aviso("Erro","Fornecedor" + oXML:_InfCte:_Emit:_Xnome:Text +" [" + Transform(cCNPJ_CT,"@R 99.999.999/9999-99") +"] "+ "inexistente na base","Gere cadastro para este fornecedor.",2,"IMPCTE2") //"Fornecedor inexistente na base. Gere cadastro para este fornecedor."#"
			EndIF
			aAdd(aErroErp,{cFile,"COM007"})
			lRet := .F.
		Else
			cFornCTe := SA2->A2_COD
			cLojaCTe := SA2->A2_LOJA
			cNomeCTe := SA2->A2_NOME
			cEstCTe	 := SA2->A2_EST
			cNatuCTe := SA2->A2_NATUREZ
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Identifica se a empresa foi remetente das notas fiscais contidas no conhecimento: 			³
	//³ 																				 			³
	//³ Se sim, significa que as notas contidas no conhecimento sao notas de saida, podendo ser 	³
	//³ notas de venda, devolucao de compras ou devolucao de remessa para beneficiamento.     		³
	//³ 																				 			³
	//³ Se nao, significa que as notas contidas no conhecimento sao notas de entrada, podendo ser	³
	//³ notas de compra, devolucao de vendas ou remessa para beneficiamento.     					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		cTagRem := If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF")
		If ( lRemet := (SM0->M0_CGC == (AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text))) .And. !lDesTrFil ) .Or. lToma4
			cTagDest := If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_CNPJ")) == "O","_CNPJ","_CPF")
			cCNPJ_CF := AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text) //-- Armazena o CNPJ do destinatario das notas contidas no conhecimento
			cTipoFrete := "F"
		Else
			cCNPJ_CF := AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)//-- Armazena o CNPJ do remetente das notas contidas no conhecimento
			cTipoFrete := "C"
			//-- Como no XML nao e possivel saber se o destinatario e cliente ou fornecedor
			//-- Validarei os dois casos
			SA1->(dbSetOrder(3))
			If SA1->(dbSeek(xFilial("SA1")+cCNPJ_CF))
				aDadosCli[1] := SA1->A1_COD
				aDadosCli[2] := SA1->A1_LOJA
				lCliente := .T.
			Else
				aDadosCli[1] := CriaVar("A1_COD",.F.)
				aDadosCli[2] := CriaVar("A1_LOJA",.F.)
			EndIf
			SA2->(dbSetOrder(3))
			If SA2->(dbSeek(xFilial("SA2")+cCNPJ_CF))
				aDadosFor[1] := SA2->A2_COD
				aDadosFor[2] := SA2->A2_LOJA
			Else
				aDadosFor[1] := CriaVar("A2_COD",.F.)
				aDadosFor[2] := CriaVar("A2_LOJA",.F.)
			EndIf
			
			If Empty(aDadosCli[1]) .And. !Empty(aDadosFor[1])
				cCodiRem := aDadosFor[1]
				cLojaRem := aDadosFor[2]
			ElseIf !Empty(aDadosCli[1]) .And. Empty(aDadosFor[1])
				cCodiRem := aDadosCli[1]
				cLojaRem := aDadosCli[2]
			ElseIf !Empty(aDadosCli[1]) .And. !Empty(aDadosFor[1])
				cCodiRem := ""
				cLojaRem := ""
			ElseIf lDesTrFil .And. !Empty(aDadosFor[1])
				cCodiRem := aDadosFor[1]
				cLojaRem := aDadosFor[2]
			ElseIf lA116IFor	// Ponto de entrada para identificar o fornecedor/cliente da mercadoria
				aAuxFor := ExecBlock("A116IFor",.F.,.F.,{oXML})
				If	Len(aAuxFor) == 3 .And.;
						ValType(aAuxFor[1]) == "C" .And. !Empty(aAuxFor[1]) .And. (aAuxFor[1] $ "SA1#SA2") .And.;
						ValType(aAuxFor[2]) == "C" .And. !Empty(aAuxFor[2]) .And.;
						ValType(aAuxFor[3]) == "C" .And. !Empty(aAuxFor[3])
					cAliasRem:= aAuxFor[1]
					cCodiRem := Padr(aAuxFor[2],TamSX3("A2_COD")[1])
					cLojaRem := Padr(aAuxFor[3],TamSX3("A2_LOJA")[1])
					If cAliasRem == "SA1" .Or. cAliasRem == "SA2"
						(cAliasRem)->(dbSetOrder(1))
						If (cAliasRem)->(dbSeek(xFilial(cAliasRem)+cCodiRem+cLojaRem))
							If cAliasRem $ "SA1"
								aDadosCli[1] := SA1->A1_COD
								aDadosCli[2] := SA1->A1_LOJA
								lCliente := .T.
							Else
								aDadosFor[1] := SA2->A2_COD
								aDadosFor[2] := SA2->A2_LOJA
							EndIf
						Else
							lRet := .F.
						EndIf
					Else
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf
			ElseIf cCNPJ_CF == "00000000000000"
				lFornExt := .T. //tratamento para quando CTE for com remetente extrangeiro (nao tem CNPJ)
				// deve processar apenas se for NF-E
			Else
				lRet := .F.
			EndIf
			If !lRet
				If lJob
					aAdd(aErros,{cFile,"Fornecedor" + oXML:_InfCte:_Rem:_Xnome:Text +" [" + Transform(cCNPJ_CF,"@R 99.999.999/9999-99") +"] "+ "inexistente na base","Gere cadastro para este fornecedor."}) //"Fornecedor"#"inexistente na base."#"Gere cadastro para este fornecedor."
				Else
					Aviso("Erro","Fornecedor" + oXML:_InfCte:_Rem:_Xnome:Text +" [" + Transform(cCNPJ_CF,"@R 99.999.999/9999-99") +"] "+ "inexistente na base","Gere cadastro para este fornecedor.",2,"IMPCTE2") //"Fornecedor inexistente na base. Gere cadastro para este fornecedor."
				EndIf
				aAdd(aErroErp,{cFile,"COM007"})
			EndIf
		EndIf
	EndIf
	
	If lRet
		//-- Caso o remetente nao seja a propria empresa, valida o cadasotro do remetente
		//-- Podendo este ser cliente ou fornecedor (descobira atrabes das notas do conhecimento)
		If !lRemet .And. !lToma4
			//-- Separa secao que contem as notas do conhecimento para laco
			
			If lComp
				aAux1 := If(ValType(oXML:_InfCte:_InfCTeComp) == "O",{oXML:_InfCte:_InfCTeComp},oXML:_InfCte:_InfCTeComp)
			ElseIf cVersao >= "2.00"
				If ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm:_InfDoc,"_INFNF")) != "U"
					aAux := If(ValType(oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNF) == "O",{oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNF},oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNF)
				ElseIf ValType(XmlChildEx(oXML:_InfCte:_InfCTeNorm:_InfDoc,"_INFNFE")) != "U"
					aAux1 := If(ValType(oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNFE) == "O",{oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNFE},oXML:_InfCte:_InfCTeNorm:_InfDoc:_INFNFE)
				EndIf
			Else
				If ValType(XmlChildEx(oXML:_InfCte:_Rem,"_INFNF")) != "U"
					aAux := If(ValType(oXML:_InfCte:_Rem:_INFNF) == "O",{oXML:_InfCte:_Rem:_INFNF},oXML:_InfCte:_Rem:_INFNF)
				ElseIf ValType(XmlChildEx(oXML:_InfCte:_Rem,"_INFNFE")) != "U"
					aAux1 := If(ValType(oXML:_InfCte:_Rem:_INFNFE) == "O",{oXML:_InfCte:_Rem:_INFNFE},oXML:_InfCte:_Rem:_INFNFE)
				EndIf
			EndIf
			
			// Limpa filtro da tabela SF1 para pesquisar pelo fornecedor correto
			SF1->(dbClearFilter())
			
			If Len(aAux) > 0 .And. !lFornExt		// Quando preenche aAux significa que o XML contem os numeros das notas originais, portanto o emitente do CTe nao trabalha com NF-e
				SF1->(dbSetOrder(1))
				For nX := 1 To Len(aAux)
					
					cChaveNF :=	PadL(AllTrim(aAux[nX]:_nDoc:Text),TamSX3("F1_DOC")[1], "0") +;
						PadR(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F1_SERIE")[1])
					
					SDS->(dbSetOrder(1))
					If (!SDS->(msSeek(xFilial("SDS")+cChaveNF+aDadosFor[1]+aDadosFor[2])) .And.;
							!SDS->(msSeek(xFilial("SDS")+cChaveNF+aDadosCli[1]+aDadosCli[1])))
						cChaveNF :=	Padr(AllTrim(aAux[nX]:_nDoc:Text),TamSX3("F1_DOC")[1],) +;
							Padr(AllTrim(aAux[nX]:_Serie:Text),TamSX3("F1_SERIE")[1])
					EndIf
					
					//-- Se remetente nao identificado e porque pode ser cliente ou fornecedor
					//-- Dai identifica atraves de seek no SF1
					If Empty(cCodiRem)
						If SF1->(dbSeek(xFilial("SF1")+cChaveNF+aDadosFor[1]+aDadosFor[2])) // Se achar, significa que sao notas de compra
							cCodiRem := aDadosFor[1]
							cLojaRem := aDadosFor[2]
						ElseIf SF1->(dbSeek(xFilial("SF1")+cChaveNF+aDadosCli[1]+aDadosCli[1])) //Se achar, significa que sao notas de devol./beneficiamento
							cCodiRem := aDadosCli[1]
							cLojaRem := aDadosCli[2]
						Else //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
							lRet := .F.
						EndIf
					ElseIf !SF1->(dbSeek(xFilial("SF1")+cChaveNF+cCodiRem+cLojaRem))
						lRet := .F. //-- Se nao achou, e porque nota ainda nao estao no sistema: dai nao da pra processar
					EndIf
					
					//-- Registra notas que farao parte do conhecimento
					If lRet
						nTamFil := Len(xFilial("SF1"))
						aAdd(aItens116,{{"PRIMARYKEY",SubStr(SF1->&(IndexKey()),nTamFil+1)}})
					Else
						If lJob
							aAdd(aErros,{cFile, "Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada." + cChaveNF}) //"Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada."
						Else
							Aviso("Erro","Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada." + cChaveNF,2,"IMPCTE2") //"Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada."
						EndIf
						aAdd(aErroErp,{cFile,"COM020"})
						Exit
					EndIf
				Next nX
				
				// Tratamento para CTe de devolucao quando o cliente nao aceitou receber a mercadoria
				// Neste caso a transportadora emite um novo CTe referenciando as notas de venda, as notas estarao em SF2 e nao SF1
				If !lRet .And. lCliente
					SF2->(dbClearFilter())
					SF2->(dbSetOrder(1))
					For nY := 1 To Len(aAux)
						cChaveNF :=	Padr(AllTrim(aAux[nY]:_nDoc:Text),TamSX3("F2_DOC")[1]) +;
							Padr(AllTrim(aAux[nY]:_Serie:Text),TamSX3("F2_SERIE")[1])
						If SF2->(dbSeek(xFilial("SF2")+cChaveNF+aDadosCli[1]+aDadosCli[2]))
							cCodiRem := aDadosCli[1]
							cLojaRem := aDadosCli[2]
							lRet := .T.
						Else
							lRet := .F.
							Exit
						EndIf
					Next nY
					If lRet
						aErros	:= {}
						cTipoFrete := "F"
						lDevSemSF1 := .T.
					EndIf
				EndIf
			EndIf
			
			IF Len(aAux1) > 0		// Quando preenche aAux1 significa que o XML contem a chave DANFE das notas originais, portanto o emitente do CTe trabalha com NF-e
				For nX := 1 To Len(aAux1)
					SF1->(dbSetOrder(8))
					cChaveNF :=	Padr(AllTrim(aAux1[nX]:_chave:Text),TamSX3("F1_CHVNFE")[1])
					
					//Verifica existência da nota
					If SF1->(dbSeek(xFilial("SF1")+cChaveNF)) //Se nota existir, preenche informações do Remetente com dados da nota
						cCodiRem := SF1->F1_FORNECE
						cLojaRem := SF1->F1_LOJA
					Else
						lRet := .F.
					EndIf
					
					SF1->(dbSetOrder(1))
					
					//-- Registra notas que farao parte do conhecimento
					If lRet
						nTamFil := Len(xFilial("SF1"))
						aAdd(aItens116,{{"PRIMARYKEY",SubStr(SF1->&(IndexKey()),nTamFil+1)}})
					Else
						If lJob
							aAdd(aErros,{cFile, "Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada. " + cChaveNF}) //"Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada."
						Else
							Aviso("Erro","Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada. " + cChaveNF,2,"IMPCTE2") //"Documento de entrada inexistente na base. Processe o recebimento deste documento de entrada."
						EndIf
						aAdd(aErroErp,{cFile,"COM020"})
						Exit
					EndIf
				Next nX
				
				// Tratamento para CTe de devolucao quando o cliente nao aceitou receber a mercadoria
				// Neste caso a transportadora emite um novo CTe referenciando as notas de venda, as notas estarao em SF2 e nao SF1
				If !lRet .And. lCliente
					cChaveNF := ""
					For nY := 1 To Len(aAux1)
						cChaveNF +=	"'" + Padr(AllTrim(aAux1[nY]:_chave:Text),TamSX3("F2_CHVNFE")[1]) + "',"
						nCount++
					Next nY
					cChaveNF :=	"(" + Substr(cChaveNF,1,Len(cChaveNF)-1) + ")"
					SF2->(dbClearFilter())
					SF2->(dbSetOrder(1))
					#IFDEF TOP
						// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						// |  MONTA QUERY   |
						// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cQuery += " SELECT COUNT(*) TOTAL "
						cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
						cQuery += " WHERE F2_CHVNFE IN " + cChaveNF
						cQuery := ChangeQuery(cQuery)
						dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TMP", .T., .T.)
						TMP->(dbGoTop())
						If !TMP->(Eof())
							If nCount == TMP->TOTAL
								lRet := .T.
							EndIf
						EndIf
						TMP->(dbCloseArea())
					#ENDIF
					
					If lRet
						aErros	:= {}
						cTipoFrete := "F"
						lDevSemSF1 := .T.
					EndIf
				EndIf
				
			EndIf
			
			//-- Obtem TES e cond. pagto para utilizacao no CT-e
			
			U_IMPCTE2A(oXML,@cTES_CT,@cCPag_CT,1)
			
			//-- Valida existencia da TES a utilizar no CTe
			If lRet .And. Empty(cTES_CT) .Or. !SF4->(dbSeek(xFilial("SF4")+cTES_CT))
				If lJob
					aAdd(aErros,{cFile, "TES não informada no parâmetro MV_XMLTECT ou inexistente no cadastro correspondente.","TES não informada no parâmetro MV_XMLTECT ou inexistente no cadastro correspondente."}) //"TES não informada no parâmetro MV_XMLTECT ou inexistente no cadastro correspondente."
				Else
					Aviso("Erro","TES não informada no parâmetro MV_XMLTECT ou inexistente no cadastro correspondente.",2,"IMPCTE2")
				EndIf
				aAdd(aErroErp,{cFile,"COM021"})
				lRet := .F.
			EndIf
			
			//-- Se TES gera dulp., valida existencia da cond. pgto a utilizar no CTe
			If lRet .And. SF4->F4_DUPLIC == "S" .And. (Empty(cCPag_CT) .Or. !SE4->(dbSeek(xFilial("SE4")+cCPag_CT)))
				If lJob
					aAdd(aErros,{cFile,"Condição de pagamento não informada no parâmetro MV_XMLCPCT ou inexistente no cadastro correspondente.","Verifique a configuração do parâmetro."})
				Else
					Aviso("Erro","Condição de pagamento não informada no parâmetro MV_XMLCPCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro.",2,"IMPCTE2")
				EndIf
				lRet := .F.
				aAdd(aErroErp,{cFile,"COM022"})
			EndIf
			
			
			//-- Ponto de entrada para considerar o CTe como se fosse de venda (nota do tipo Normal com apenas um item)
			/*
			If lA116ITPCT
				aParamPE := If(Len(aAux) > 0,aAux,aAux1)
				cRetPrd := ExecBlock("A116ITPCT",.F.,.F.,{aParamPE, oXML})
				If ValType(cRetPrd) == "C" .And. SB1->(dbSeek(xFilial("SB1")+cRetPrd))
					cPrdFrete := PadR(cRetPrd,TamSX3("B1_COD")[1])
					cTipoFrete := "F"
					lRemet := .T.
				EndIf
			EndIf
			*/
		Else
			SB1->(dbSetOrder(1))
			
			cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
			If At(";",cPrdFrete) > 0
				cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
			EndIf
			cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])
			
			//-- Ponto de entrada para mudar o produto frete
			If ExistBlock("A116PRDF")
				cPrdFrete := ExecBlock("A116PRDF",.F.,.F.,{oXML})
				If ValType(cPrdFrete) # "C" .Or. !SB1->(dbSeek(xFilial("SB1")+cPrdFrete))
					cPrdFrete := SuperGetMV("MV_XMLPFCT",.F.,"")
					If At(";",cPrdFrete) > 0
						cPrdFrete := SubStr(cPrdFrete,1,(At(";",cPrdFrete)-1))
					EndIf
					cPrdFrete := PadR(cPrdFrete,TamSX3("B1_COD")[1])
				EndIf
			EndIf
			
			//-- Valida existencia do produto frete
			If Empty(cPrdFrete) .Or. !SB1->(dbSeek(xFilial("SB1")+cPrdFrete))
				If lJob
					aAdd(aErros,{cFile, "Produto frete não informado no parâmetro MV_XMLPFCT ou inexistente no cadastro correspondente.","Verifique a configuração do parâmetro."})
				Else
					Aviso("Erro","Produto frete não informado no parâmetro MV_XMLPFCT ou inexistente no cadastro correspondente.Verifique a configuração do parâmetro.",2,"IMPCTE2")
				EndIf
				aAdd(aErroErp,{cFile,"COM023"})
				lRet := .F.
			ELSEIF !EMPTY(cPrdFrete)
				_cConta	:= SB1->B1_CONTA 
			EndIf
		EndIf
	EndIf
	
	If lRet
		//-- Separa secao que contem as notas do conhecimento para laco
		If ValType(XmlChildEx(oXML:_InfCte,"_INFCTENORM")) <> "U"
			aAux := If(ValType(oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ) == "O",{oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ},oXML:_InfCte:_InfCteNorm:_InfCarga:_InfQ)
		EndIf
		For nX := 1 To Len(aAux)
			If Upper(AllTrim(aAux[nX]:_TPMED:Text)) == "PESO BRUTO"
				nPesoBruto := Val(aAux[nX]:_QCARGA:Text)
			EndIf
			If Upper(AllTrim(aAux[nX]:_TPMED:Text)) == "PESO LíQUIDO"
				nPesoLiqui := Val(aAux[nX]:_QCARGA:Text)
			EndIf
			If !("PESO" $ Upper(aAux[nX]:_TPMED:Text)) .And. Len(aEspecVol) < 5
				aAdd(aEspecVol,{AllTrim(aAux[nX]:_TPMED:Text),Val(aAux[nX]:_QCARGA:Text)})
			EndIf
		Next nX
		
		// Apuracao do ICMS para as diversas situacoes tributarias
		If ValType(XmlChildEx(oXML:_InfCte:_imp,"_ICMS")) <> "U"
			If ( oICMS := oXML:_INFCTE:_IMP:_ICMS ) != Nil
				If ( oICMSTipo := XmlGetChild( oICMS, 1 )) != Nil
					For nZ := 1 To 5	// O nivel maximo para descer dentro da tag que define o tipo do ICMS para obter tanto base quanto valor é 5, conforme manual de orientacao do CTe
						If ( oICMSNode := XmlGetChild( oICMSTipo, nZ )) != Nil
							If "vBC" $ oICMSNode:REALNAME
								nBaseICMS := Val(oICMSNode:TEXT)
								lBaseICMS := .T.
							ElseIf "vICMS" $ oICMSNode:REALNAME
								nValICMS := Val(oICMSNode:TEXT)
								lValICMS := .T.
							ElseIf "pICMS" $ oICMSNode:REALNAME
								nAliqICMS := Val(oICMSNode:TEXT)
								lAliqICMS := .T.
							EndIf
							If lBaseICMS .And. lValICMS .And. lAliqICMS
								Exit
							EndIf
						EndIf
					Next nZ
				EndIf
			EndIf
		EndIf
		
		Begin Transaction
			
			//-- Grava cabeca do conhecimento de transporte
			RecLock("SDS",.T.)
			SDS->DS_FILIAL		:= xFilial("SDS")														// Filial
			SDS->DS_CNPJ		:= cCNPJ_CT																// CGC
			SDS->DS_DOC			:= PadL(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1],"0")			// Numero do Documento
			SDS->DS_SERIE		:= AllTrim(oXML:_InfCte:_Ide:_Serie:Text) 								// Serie
			SDS->DS_FORNEC		:= cFornCTe																// Fornecedor do Conhecimento de transporte
			SDS->DS_LOJA		:= cLojaCTe																// Loja do Fornecedor do Conhecimento de transporte
			SDS->DS_XEST		:= cEstCTe
			SDS->DS_EMISSA		:= StoD(StrTran(AllTrim(oXML:_InfCte:_Ide:_Dhemi:Text),"-",""))		// Data de Emissão
			SDS->DS_EST			:= oXML:_InfCte:_Ide:_UFIni:TEXT										// Estado de emissao da NF
			SDS->DS_TIPO		:= "T"													 				// Tipo da Nota
			SDS->DS_FORMUL		:= "N" 																	// Formulario proprio
			SDS->DS_ESPECI		:= "CTE"															  	// Especie
			SDS->DS_ARQUIVO		:= AllTrim(cFile)														// Arquivo importado
			SDS->DS_CHAVENF		:= Right(AllTrim(oXML:_InfCte:_Id:Text),44)								// Chave de Acesso da NF
			SDS->DS_VERSAO		:= AllTrim(oXML:_InfCte:_Versao:Text) 									// Versão
			SDS->DS_USERIMP		:= If(!lJob,cUserName,"TOTVS")											// Usuario na importacao
			SDS->DS_DATAIMP		:= dDataBase															// Data importacao do XML
			SDS->DS_HORAIMP		:= SubStr(Time(),1,5)													// Hora importacao XML
			SDS->DS_VALMERC		:= Val(oXML:_InfCte:_VPrest:_VRec:Text)								  	// Valor Mercadoria
			SDS->DS_TPFRETE		:= cTipoFrete															// Tipo de Frete
			SDS->DS_PBRUTO		:= nPesoBruto															// Peso Bruto
			SDS->DS_PLIQUI		:= nPesoLiqui															// Peso Liquido
			SDS->DS_XNATURE		:= cNatuCTe																// Natureza Financeira
			For nX := 1 To Len(aEspecVol)
				If SDS->(FieldPos("DS_ESPECI" +Str(nX,1))) > 0
					SDS->&("DS_ESPECI" +Str(nX,1)) := aEspecVol[nX,1]							 		// Especie
					SDS->&("DS_VOLUME" +Str(nX,1)) := aEspecVol[nX,2]							 		// Volume
				EndIf
			Next nX
			If SDS->(FieldPos("DS_BASEICM")) > 0 .And. lBaseICMS
				SDS->DS_BASEICM := nBaseICMS
			EndIf
			If SDS->(FieldPos("DS_VALICM")) > 0 .And. lValICMS
				SDS->DS_VALICM := nValICMS
			EndIf
			SDS->(MsUnlock())
			
			//-- Grava itens do conhecimento de transporte
			If lRemet .Or. lDevSemSF1 .Or. lToma4
				RecLock("SDT",.T.)
				SDT->DT_FILIAL		:= xFilial("SDT")													// Filial
				SDT->DT_ITEM		:= StrZero(1,TamSX3("DT_ITEM")[1])							   		// Item
				SDT->DT_COD			:= cPrdFrete														// Codigo do produto
				SDT->DT_FORNEC		:= cFornCTe															// Forncedor
				SDT->DT_LOJA		:= cLojaCTe															// Loja
				SDT->DT_DOC			:= PadL(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1],"0")		// Docto
				SDT->DT_SERIE		:= AllTrim(oXML:_InfCte:_Ide:_Serie:Text) 					   		// Serie
				SDT->DT_CNPJ		:= SDS->DS_CNPJ														// Cnpj do Fornecedor
				SDT->DT_QUANT		:= 1																// Quantidade
				SDT->DT_VUNIT		:= Val(oXML:_InfCte:_VPrest:_VRec:Text)								// Valor Unitário
				SDT->DT_TOTAL		:= Val(oXML:_InfCte:_VPrest:_VRec:Text)						   		// Vlor Total
				SDT->DT_XCONTA		:= _cConta
				SDT->(MsUnlock())
				//If lMt116XmlCt
					//ExecBlock("Mt116XmlCt",.F.,.F.,{oXML})
				//EndIf
				If SDT->(FieldPos("DT_PICM")) > 0 .And. lAliqICMS
					IF VALTYPE(nAliqICMS) == "N"
						IF nAliqICMS > 0
							SDT->DT_PICM := nAliqICMS
						ENDIF
					ENDIF
				EndIf
			Else
				
				aAdd(aCabec116,{"",dDataBase-90})       												// Data inicial para filtro das notas
				aAdd(aCabec116,{"",dDataBase})          												// Data final para filtro das notas
				aAdd(aCabec116,{"",2})                  												// 2-Inclusao ; 1=Exclusao
				aAdd(aCabec116,{"",IIf(lComp,cFornCTe,cCodiRem)})            						// Rementente das notas contidas no conhecimento
				aAdd(aCabec116,{"",IIf(lComp,cLojaCTe,cLojaRem)})             						// Loja do remetente das notas contidas no conhecimento
				aAdd(aCabec116,{"",1})                  												// Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
				aAdd(aCabec116,{"",2})                  												// 1=Aglutina itens ; 2=Nao aglutina itens
				aAdd(aCabec116,{"F1_EST",""})  		  													// UF das notas contidas no conhecimento
				aAdd(aCabec116,{"",Val(oXML:_InfCte:_VPrest:_VRec:Text)}) 								// Valor do conhecimento
				aAdd(aCabec116,{"F1_FORMUL",1})															// Formulario proprio: 1=Nao ; 2=Sim
				aAdd(aCabec116,{"F1_DOC",PadR(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1])})		// Numero da nota de conhecimento
				aAdd(aCabec116,{"F1_SERIE",PadR(oXML:_InfCte:_Ide:_Serie:Text,TamSx3("F1_SERIE")[1])})	// Serie da nota de conhecimento
				aAdd(aCabec116,{"F1_FORNECE",cFornCTe}) 												// Fornecedor da nota de conhecimento
				aAdd(aCabec116,{"F1_LOJA",cLojaCTe})													// Loja do fornecedor da nota de conhecimento
				aAdd(aCabec116,{"",cTES_CT})															// TES a ser utilizada nos itens do conhecimento
				aAdd(aCabec116,{"F1_BASERET",nBaseICMS})												// Valor da base de calculo do ICMS retido
				aAdd(aCabec116,{"F1_ICMRET",nValICMS})													// Valor do ICMS retido
				aAdd(aCabec116,{"F1_COND",cCPag_CT})											   		// Condicao de pagamento
				aAdd(aCabec116,{"F1_EMISSAO",SToD(Substr(StrTran(oXML:_InfCte:_Ide:_dhEmi:Text,"-",""),1,8))}) // Data de emissao do conhecimento
				aAdd(aCabec116,{"F1_ESPECIE","CTE"})															 // Especie do documento
				aAdd(aCabec116,{"COLAB","S"})
				//aAdd(aCabec116,{"DT_CONTA",_cConta})
				If SDT->(FieldPos("DT_PICM")) > 0 .And. lAliqICMS
					IF VALTYPE(nAliqICMS) == "N"
						IF nAliqICMS > 0 
							aAdd(aCabec116,{"DT_PCIM",nAliqICMS})
						ENDIF
					ENDIF
				EndIf												   				 // Chave para tratamentos especificos
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Executa a ExecAuto do MATA116 para gravar os itens com o valor de frete rateado ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lMsErroAuto    := .F.
				lAutoErrNoFile := .T.
				//ALERT(PadR(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1]))
				MsExecAuto({|x,y| MATA116(x,y)},aCabec116,aItens116)
				
				If lMsErroAuto
					//-- Desfaz transacao
					DisarmTran()
					If lJob
						aAux := GetAutoGRLog()
						For nX := 1 To Len(aAux)
							cError += aAux[nX]
						Next nX
						aAdd(aErros,{cFile,cError,"Corrija a inconsistência apontada no log."}) 
					Else
						MostraErro()
					EndIf
					aAdd(aErroErp,{cFile,"COM024"})
					lRet := .F.
				Else
					//If lMt116XmlCt
						//ExecBlock("Mt116XmlCt",.F.,.F.,{oXML})
					//EndIf
				EndIf
			EndIf
			
		End Transaction
		If !lNewColab
			If lRet
				//-- Move arquivo para pasta dos processados
				Copy File &(DIRXML+DIRALER+cFile) To &(DIRXML+DIRLIDO+cFile)
				FErase(DIRXML+DIRALER+cFile)
				
				aAdd(aProc,{	PadL(oXML:_InfCte:_Ide:_nCt:Text,TamSx3("F1_DOC")[1],"0"),;
					PadR(oXML:_InfCte:_Ide:_Serie:Text,TamSx3("F1_SERIE")[1]),;
					cNomeCTe})
			ElseIf lDelFile
				//-- Move arquivo para pasta de erros
				Copy File &(DIRXML+DIRALER+cFile) To &(DIRXML+DIRERRO+cFile)
				FErase(DIRXML+DIRALER+cFile)
			EndIf
		Endif
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPCTE2B	ºAutor  ³ TOTVS TMAPs		 º Data ³  01/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se o XML deve ser processado pela empresa.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oXml: XML do arquivo CTe.								  º±±
±±º			 ³ cCNPJ_CPF: CNPJ/CPF da empresa que ira processar.		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno	 ³ lRet: indica se o arquivo deve ser processado.			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPCTE2 e COMXCOL (LoadFiles)		                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user Function IMPCTE2B(oXML,cCNPJ_CPF,lDesTrFil,lToma4,lJob,cFile)
	Local lRet 	   := .T.
	Local lNewColab := Findfunction("ColUsaColab") .And. ColUsaColab('6')
	Local cTagRem  := If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF")
	Local cTagDest := If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_CNPJ")) == "O","_CNPJ","_CPF")
	Local cIERem   := If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_IE")) == "O","_IE","")
	Local cIEDest  := If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_IE")) == "O","_IE","")
	Local cTagToma4:= ""
	Local cTagRec	:= ""
	Local cTagExp	:= ""
	Local aSm0		 := FWLoadSM0()
	Local nX		 := 0
	Local nQtdCNPJ := 0
	
	DEFAULT lDesTrFil:= .F.
	DEFAULT lToma4	 := .F.
	
	If lNewColab
		//Verifica remetente
		If DirFilial(cFile,AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text),AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cIERem):Text),lJob)[1]
			lRet:= .T.
			//Verifica destinatário
		ElseIf DirFilial(cFile,AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text),AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text),lJob)[1]
			lRet:= .T.
		Else
			lRet:= .F.
		Endif
	Else
		// Verifica se existe mais de uma filial com mesmo CNPJ, neste caso a validação para importação da nota será feita pela inscricao estadual
		For nX := 1 To Len(aSm0)
			If cCNPJ_CPF $ aSm0[nX][SM0_CGC]
				nQtdCNPJ++
			EndIf
		Next nX
		
		//-- Verifica se o arquivo pertence a filial corrente
		If (AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text) == AllTrim(cCNPJ_CPF) .Or.;
				AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text) == AllTrim(cCNPJ_CPF)) .And. nQtdCNPJ == 1
			lRet := .T.
		ElseIf (!Empty(cIERem) .And. (AllTrim(SM0->M0_INSC) $ AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cIERem):Text))) .Or.;
				(!Empty(cIEDest) .And. (AllTrim(SM0->M0_INSC) $ AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)))
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Validacao para Transferencia entre Filiais: 									 			³
	//³ 																				 			³
	//| Valida se o CT-e deve ser importado na filial remetente ou na filial destinataria			³
	//| para o caso de ser uma operacao de transferencia entre filiais  				 			³
	//| 																				 			³
	//| Validacao efetuada pela tag TOMA03 conforme Manual do Conhecimento de Transporte Eletronico |
	//| Versao 1.0.4c - Abril/2012, que identifica quem e o tomador do servico, sendo:				|
	//| 0-Remetente																					|
	//| 1-Expedidor																					|
	//| 2-Recebedor																					|
	//| 3-Destinatario																				|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA03")) <> "U"
		If AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "0"
			If AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text) == AllTrim(cCNPJ_CPF)
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		ElseIf AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "1"
			cTagExp := If(ValType(XmlChildEx(oXML:_InfCte:_Exped,"_CNPJ")) == "O","_CNPJ","_CPF")
			If AllTrim(XmlChildEx(oXML:_InfCte:_Exped,cTagExp):Text) == AllTrim(cCNPJ_CPF)
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		ElseIf AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "2"
			cTagRec := If(ValType(XmlChildEx(oXML:_InfCte:_Receb,"_CNPJ")) == "O","_CNPJ","_CPF")
			If AllTrim(XmlChildEx(oXML:_InfCte:_Receb,cTagRec):Text) == AllTrim(cCNPJ_CPF)
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		ElseIf AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text) == "3"
			lDesTrFil := .T.					// Destinatario da nota no processo de transferencia entre filiais
			If AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text) != AllTrim(cCNPJ_CPF)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Validacao para tag TOMA4 quando a empresa nao e Remetente, Expedidor, Recebedor nem			³
	//³ Destinatario																	 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA4")) <> "U"
		If AllTrim(oXML:_InfCte:_Ide:_Toma4:_TOMA:Text) == "4"
			cTagToma4 := If(ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_CNPJ")) == "O","_CNPJ","_CPF")
			lToma4 := .T.
			If AllTrim(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,cTagToma4):Text) == AllTrim(cCNPJ_CPF)
				lRet := .T.
			EndIf
		EndIf
	EndIf
	
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPCTE2A	ºAutor  ³ TOTVS TMAPs		 º Data ³  01/01/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que retorna TES e cond. pagto para utilizacao no CTeº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oXml: objeto com o XML do CTe.							  º±±
±±º			 ³ cTES_CT: variavel que recebera o codigo da TES (referencia)º±±
±±º			 ³ cCPag_CT: variavel que recebera o codigo da cond pagto.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPCTE2 e COMXCOL (MontaSF1,MontaSD1)                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user Function IMPCTE2A(oXML,cTES_CT,cCPag_CT,nExec)
	Local aAux 	   := {}
	Local cError   := ""
	Local cWarning := ""
	
	Default oXML   	 := NIL
	Default cTES_CT  := ""
	Default cCPag_CT := ""
	Default nExec   	 := 1
	
	cTES_CT  := PadR(SuperGetMV("MV_XMLTECT",.F.,""),TamSX3("F4_CODIGO")[1])
	cCPag_CT := PadR(SuperGetMV("MV_XMLCPCT",.F.,""),TamSX3("E4_CODIGO")[1])
	
	SF4->(dbSetOrder(1))
	SDS->(dbSetOrder(2))
	
	oXML := XmlParserFile("XMLNFE\OLD\" + AllTrim(SDS->DS_ARQUIVO),"_",@cError,@cWarning)
	
	//-- Ponto de entrada para alterar a TES a utilizar no CTe
	If ExistBlock("A116TECT")
		aAux := ExecBlock("A116TECT",.F.,.F.,{oXML,nExec})
		If ValType(aAux[1]) == "C" .And. !Empty(aAux[1]) .And. SF4->(dbSeek(xFilial("SF4")+aAux[1]))
			cTES_CT := aAux[1]
		EndIf
		If ValType(aAux[2]) == "C" .And. !Empty(aAux[2]) .And. SE4->(dbSeek(xFilial("SE4")+aAux[2]))
			cCPag_CT := aAux[2]
		EndIf
	EndIf
	
Return
