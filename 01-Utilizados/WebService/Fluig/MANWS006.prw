#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TopConn.Ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "totvswebsrv.ch"
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'
#Include "Totvs.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATW001  º Autor ³ Fabrício Antunes      º Data da Criacao  ³ 17/01/2019               					    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera e altera o Orçamento de Venda integração FLUIG via webservice                                      		º±±
±±º          ³ 																					                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 														             						                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ Nenhum						   							                               						º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Nenhum						  							                               						º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUsuario   ³ Microsiga                                                                                					º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSetor     ³ Manfil 				                                                                   						º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            			          	ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                   						º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAutor     ³ Data     ³ Motivo da Alteracao  				               ³Usuario(Filial+Matricula+Nome)    ³Setor        º±±
±±ºÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄº±±
±±º          ³          ³                               				   ³                                  ³   	        º±±
±±º----------³----------³--------------------------------------------------³----------------------------------³-------------º±±
±±º          ³          ³                    							   ³                                  ³ 			º±±
±±º----------³----------³--------------------------------------------------³----------------------------------³-------------º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/    
User Function MANWS006
Return

WsStruct PEDITENS2
 	WsData CK_PRODUTO 	As String	OPTIONAL
	WsData CK_QTDVEN 	As FLOAT	OPTIONAL
	WsData CK_PRUNIT 	As FLOAT	OPTIONAL
EndWsStruct                       

WsStruct PEDIDOS2

    WsData CJ_NUM		As String	OPTIONAL
    WsData CJ_CLIENTE	As String	OPTIONAL
    WsData CJ_LOJACLI	As String	OPTIONAL
    WsData CJ_CONDPAG	As String	OPTIONAL  
    Wsdata CJ_XVEND		As String	OPTIONAL 
    WsData CJ_XOBS		As String	OPTIONAL
    WsData CJ_XUSER		As String	OPTIONAL
    WsData CJ_XDESCON	As Float	OPTIONAL
    WsData CJ_XSOLDES	As String	OPTIONAL
    WsData CJ_XSOLFAT	As String	OPTIONAL
	WsData oItens		As ARRAY 	OF  PEDITENS2 		
		
EndWsStruct


WsService FATWLODORC  DESCRIPTION "WebService de integração Fluig para importação e alteracao de orcamento"

	WSData cWSPWD 	    As String 	   
    WsData oPedidos    As PEDIDOS2
	WSData cWSRETURN   As String

    WsMethod GERAPEDIDO DESCRIPTION "Metodo para geracao de Orcamento via MSExecAuto() da MATA415"
    WsMethod ALTERAPEDIDO DESCRIPTION "Metodo para geracao de Orcamento via MSExecAuto() da MATA415"
    
EndWsService

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATW001P º Autor ³ Fabricio Antunes   º Data ³ 07/04/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Gera o Pedido de venda                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºArquivos  ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

WsMethod GERAPEDIDO WsReceive cWSPWD,oPedidos WsSend cWSRETURN WsService FATWLODORC 

Local cChave 	:= ::cWSPWD  //CHAVE DE VALIDAO ORIGEM
Local oDados 	:= ::oPedidos 
Local cPARPWD	:= "123456"   
Local aCabec	:={}
Local aItens	:={}
Local _cLog     :=""
Local nX
Private cXML	:=HttpOtherContent()//U_MtXmlWs(oPedidos,"OPEDIDOS")

IF AllTrim(cChave) == AllTrim(cPARPWD)
         aCabec:={oDados:CJ_CLIENTE,oDados:CJ_LOJACLI,oDados:CJ_CONDPAG,oDados:CJ_XVEND,oDados:CJ_XOBS,oDados:CJ_XUSER,oDados:CJ_XDESCON,oDados:CJ_XSOLDES,oDados:CJ_XSOLFAT}
         For nX:=1 to Len(oDados:oItens)
        	aadd(aItens,{oDados:oItens[nX]:CK_PRODUTO,oDados:oItens[nX]:CK_PRUNIT,oDados:oItens[nX]:CK_QTDVEN})
         Next 
         cRet	:= U_GERPED03(aCabec,aItens)
         ::cWSRETURN:= cRet
Else
	conOut("[ERRO] GERAPEDIDO " + dtoc(date()) + " " + Time() +"==>Chave de segurança inválida!")
	cMgs:="401|Erro de senha|0"
	::cWSRETURN :=cMgs //RETORNO DE OPERAO NO CONCLUIDA
EndIf

Return(.T.)     
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATW001P º Autor ³ Fabricio Antunes   º Data ³ 07/04/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Gera o Pedido de venda                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºArquivos  ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
User Function GERPED03(aCabec,aItens)

Local aSC5:={}
Local aLinha:={}
Local aSC6:={}
Local cNum:=""
Local lProc:=.T.
Local cRet:=""
Local _cLog:=""
Local nX
Local nY
Local nTotal:=0
Local 	nPDescA:=0,;
		nPDescR:=0,;
		cUsu:='',;
		cSolDesc:= 'N',;
		nPrcTab:= 0
Private lMsErroAuto :=.F.
Private lAutoErrNoFile:=.T. 
Private aDados 

//cNum:=GETSXENUM("SCJ","CJ_NUM")

//buscando o percental de desconto maximo para o vendedor
dbSelectArea('SA3')
SA3->(dbSetOrder(1))
SA3->(dbGoTop())
if SA3->(dbSeek(xFilial('SA3')+Alltrim(aCabec[4])))
	cUsu:= SA3->A3_CODUSR
endif

dbSelectArea("ZZ1")
dbSetorder(1)
if dbSeek(xFilial("ZZ1")+cUsu)
	nPDescA	:= ZZ1->ZZ1_DESCON
else
	nPDescA	:= 0
endif
ZZ1->(dbCloseArea())

dbSelectArea("SA1")
SA1->(dbSetOrder(1))
IF SA1->(dbSeek(xFilial("SA1")+Alltrim(aCabec[1])+Alltrim(aCabec[2])))

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))

		For nX:= 1 to Len(aItens) 
			IF SB1->(dbSeek(xFilial("SB1")+Alltrim(aItens[nX,1])))
				IF Alltrim(aItens[nX][1]) <> '' .AND. aItens[nX][2] <> 0 .AND. aItens[nX][3] <> 0 

					dbSelectArea("DA1")
					DA1->(dbSetorder(2))
					if dbSeek(xFilial("DA1")+SB1->B1_COD+'001')
						nPrcTab:= DA1->DA1_PRCVEN
					endif
					DA1->(dbCloseArea())
					if aItens[nX][2] < nPrcTab
						nPDescR:= ((nPrcTab-aItens[nX][2])/nPrcTab)*100
					else
						cSolDesc = 'N'
					endif
					ConOut('Antes da condição Sol. Desconto -> Tab.: ';
																	+alltrim(Transform(nPrcTab,'@E 9,999,999,999,999.99'));
																	+' - Orc.: '+alltrim(Transform(aItens[nX][2],'@E 9,999,999,999,999.99'));
																	+' - P.Desc.Max.: '+alltrim(Transform(nPDescR,'@E 999.99'));
																	+' - P.Desc.: '+alltrim(Transform(nPDescA,'@E 999.99'));
																	+' - '+cSolDesc;
																	)
					if (nPDescR > nPDescA) .and. (cSolDesc == 'N')
						cSolDesc:='S'
					endif
					ConOut('Depois da condição Sol. Desconto -> '+cSolDesc)
					dbSelectArea("SB1")

					//AADD(aLinha, {"CK_NUM"			,cNum	   				,Nil}  )
					AADD(aLinha, {"CK_ITEM"			,StrZero(nX,2)	   		,Nil}  )
					AADD(aLinha, {"CK_PRODUTO"		,SB1->B1_COD	   		,Nil}  )
					AADD(aLinha, {"CK_DESCRI"		,SB1->B1_DESC			,Nil}  )
					AADD(aLinha, {"CK_QTDVEN"		,aItens[nX][3]			,Nil}  ) //Val(StrTran(aItens[nX][2],',','.'))
					AADD(aLinha, {"CK_UM"			,SB1->B1_UM				,Nil}  )
					AADD(aLinha, {"CK_PRUNIT"		,nPrcTab				,Nil}  )
					AADD(aLinha, {"CK_PRCVEN"		,aItens[nX][2]			,Nil}  )
					//AADD(aLinha, {"CK_VALOR"		,cTes					,Nil}  ) //Calculado Automatico
					//AADD(aLinha, {"CK_DESCONT"	,cTes					,Nil}  ) //Calculado Automatico
					AADD(aLinha, {"CK_XPEM2"		,SB1->B1_XPEM2			,Nil}  )

					nTotal+=aItens[nX][3]*aItens[nX][2]
					aLinha:=FWVetByDic(aLinha,"SCK")
					AAdd(aSC6,aLinha)
					aLinha:={}  
	
				Else
					cRet+="Há produtos sem preço ou quantidade, Oraçamento não será processado."
					cRet:="400|"+cRet+"|0"
					lProc:=.F.
				EndIF

			Else
				cRet+="Produto de código: "+Alltrim(aItens[nX,1])+" nao encontrado. Orçamento não será processado."
				cRet:="400|"+cRet+"|0"
				lProc:=.F.
			EndIF

		Next nX
		   
		//aCabec:={1:CJ_CLIENTE,2:CJ_LOJA,3:CJ_CONPAG,4:CJ_XVEND,5:CJ_XOBS,6:CJ_XUSER,7:CJ_XDESCON,8:CJ_XSOLDES,9:CJ_XSOLFAT}
 		IF lProc   
 			cDesPG:=Posicione("SE4",1,xFilial("SE4")+Alltrim(aCabec[3]),"E4_DESCRI")
 			cEmailVend:=Posicione('SA3',1,xFilial('SA3')+Alltrim(aCabec[4]),'A3_EMAIL')
			//AAdd(aSC5,{"CJ_NUM"		,cNum 					,Nil})
			AAdd(aSC5,{"CJ_CLIENTE"	,SA1->A1_COD  			,Nil})
			AAdd(aSC5,{"CJ_LOJA"	,SA1->A1_LOJA			,Nil})
			AAdd(aSC5,{"CJ_CLIENT" ,SA1->A1_COD  			,Nil})
			AAdd(aSC5,{"CJ_LOJAENT"	,SA1->A1_LOJA			,Nil})
			AAdd(aSC5,{"CJ_XMUN"	,SA1->A1_MUN			,Nil})
			AAdd(aSC5,{"CJ_CONDPAG"	,Alltrim(aCabec[3])		,Nil})   
			AAdd(aSC5,{"CJ_NOMCLI"	,SA1->A1_NOME			,Nil})
			AAdd(aSC5,{"CJ_XVEND"	,Alltrim(aCabec[4])  	,Nil}) 
			AAdd(aSC5,{"CJ_XOBS"	,Alltrim(aCabec[5])		,Nil})
			AAdd(aSC5,{"CJ_DESCONT"	,aCabec[7]				,Nil})
			AAdd(aSC5,{"CJ_XDESCON", cDesPG					,NIl})
			AAdd(aSC5,{"CJ_XNOMCLI",SA1->A1_NOME			,NIl})
			AAdd(aSC5,{"CJ_XTIPOCL",SA1->A1_TIPO			,Nil})
			AAdd(aSC5,{"CJ_TXMOEDA",1						,Nil})
			/*IF Alltrim(aCabec[8]) = 'S'
				cSolDesc:="S"
			Else
				cSolDesc:="N"
			EndIF
			//cSolDesc:="N"*/
			IF Alltrim(aCabec[9]) = 'S'
				cSolFat:="S"
			Else
				cSolFat:="N"
			EndIF			
			
			ConOut('Montando o Vetor -> '+cSolDesc)
			AADD(aSC5,{"CJ_XFLDESC"		,cSolDesc			,Nil}  )
			AADD(aSC5,{"CJ_XAPROVA"		,cSolFat			,Nil}  )
			AADD(aSC5,{"CJ_XFLUIG"		,"S" 				,Nil}  )
			
			cVend:=Posicione("SA3",1,xFilial("SA3")+Alltrim(aCabec[4]),"A3_NREDUZ")
			
			lMsErroAuto := .F.
		    
			aSC5:=FWVetByDic(aSC5,"SCJ")

	   		MSExecAuto({|x,y,z|Mata415(x,y,z)},aSC5,aSC6,3)
	
			If lMsErroAuto
				//RollbackSx8()
				aAutoErro := GetAutoGRLog()
				_cLog:=""
			
				For nX := 1 To Len(aAutoErro)				
					_cLog+= aAutoErro[nX]+CHR(13)+CHR(10)		
					cRet+= aAutoErro[nX]+CHR(13)+CHR(10)	
				Next nX	
				/*
				_cLog+=CHR(13)+CHR(10)	
					For nY := 1 To Len(aSC5)				
						_cLog+= aSC5[nY][1]+" := "+aSC5[nY][2]+CHR(13)+CHR(10)		
					Next nY	*/
				
				
				//DisarmTransaction()
				cRet+="Erro na inclusão do pedido, favor contactar suporte técnico "+_cLog
				cRet:="400|"+cRet+"|0"
			Else 
				//ConfirmSx8() 
				cNum:=SCK->CK_NUM
				aDados:={cNum,SA1->A1_NOME,cVend,Alltrim(aCabec[5]),SA1->A1_COD,SA1->A1_LOJA,Alltrim(aCabec[4]),nTotal}
				cRet:="200|"+"Orçamento incluido com sucesso!"+"|"+cNum
				IF cSolDesc = "S"
					_cPara:=GetMV("MF_SOLDES")
					U_MANWS008(_cPara,, , "[FLUIG-MANFIL] - Solicitacao de Desconto - "+aDados[2]+" Orçamento: "+aDados[1], , , ,"2",aDados)
				EndIF
				
				IF cSolFat = "S"
					_cPara:=cEmailVend+';'+GetMV("MF_LIBFAT")
					U_MANWS008(_cPara,, , "[FLUIG-MANFIL] - Liberacao para Faturamento - "+aDados[2]+" Orçamento: "+aDados[1], , , ,"1",aDados)
				EndIF	
				
			EndIf
		EndIF
	
Else
	cRet+="Cliente e loja nao encontrado."
	cRet:="400|"+cRet+"|0"

EndIF


Return cRet                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATW001P º Autor ³ Fabricio Antunes   º Data ³ 07/04/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Gera o Pedido de venda                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºArquivos  ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

WsMethod ALTERAPEDIDO WsReceive cWSPWD,oPedidos WsSend cWSRETURN WsService FATWLODORC

Local cChave 	:= ::cWSPWD  //CHAVE DE VALIDAO ORIGEM
Local oDados 	:= ::oPedidos 
Local cPARPWD	:= "123456"   
Local aCabec	:={}
Local aItens	:={}
Local _cLog     :=""
Local nX
Private cXML	:=HttpOtherContent()

IF AllTrim(cChave) == AllTrim(cPARPWD)
         aCabec:={oDados:CJ_CLIENTE,oDados:CJ_LOJACLI,oDados:CJ_CONDPAG,oDados:CJ_XVEND,oDados:CJ_XOBS,oDados:CJ_XUSER,oDados:CJ_XDESCON,oDados:CJ_NUM,oDados:CJ_XSOLDES,oDados:CJ_XSOLFAT}
         For nX:=1 to Len(oDados:oItens)
        	aadd(aItens,{oDados:oItens[nX]:CK_PRODUTO,oDados:oItens[nX]:CK_PRUNIT,oDados:oItens[nX]:CK_QTDVEN})
         Next 
         cRet	:= U_GERPED04(aCabec,aItens)
         ::cWSRETURN:= cRet
Else
	conOut("[ERRO] GERAPEDIDO " + dtoc(date()) + " " + Time() +"==>Chave de segurança inválida!")
	cMgs:="401|Erro de senha|0"
	::cWSRETURN :=cMgs //RETORNO DE OPERAO NO CONCLUIDA
EndIf
Return(.T.)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FATW001P º Autor ³ Fabricio Antunes   º Data ³ 07/04/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Gera o Pedido de venda                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºArquivos  ³                                                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
User Function GERPED04(aCabec,aItens)

Local aSC5:={}
Local aLinha:={}
Local aSC6:={}
Local cNum:=""
Local lProc:=.T.
Local cRet:=""
Local _cLog:=""
Local nX
Local nY
Local cTpCli:= ''
Private lMsErroAuto :=.F.
Private lAutoErrNoFile:=.T.  

//cNum:=GETSXENUM("SCJ","CJ_NUM")

dbSelectArea("SA1")
SA1->(dbSetOrder(1))
IF SA1->(dbSeek(xFilial("SA1")+Alltrim(aCabec[1])+Alltrim(aCabec[2])))
	BEGIN TRANSACTION
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
		
		dbSelectArea("SCJ")
		SCJ->(dbSetOrder(1))
		IF SCJ->(dbSeek(xFilial("SCJ")+aCabec[8]))
			RecLock("SCJ",.F.)
				dbDelete()
			MsUnLock()
			dbSelectArea("SCK")
			SCK->(dbSetOrder(1))
			IF SCK->(dbSeek(xFilial("SCK")+aCabec[8]))
				While !SCK->(EOF()) .AND. SCK->CK_NUM = aCabec[8]
					RecLock("SCK",.F.)
						dbDelete()
					MsUnLock()				
					SCK->(dbSkip())
				EndDo
			EndIF			
		
		EndIf
		/*aadd(aLinha,{"LINPOS","CK_ITEM","01"})
	    aadd(aLinha,{"AUTDELETA","S",Nil})
	    AAdd(aSC6,aLinha)*/
	    
		For nX:= 1 to Len(aItens) 
			IF SB1->(dbSeek(xFilial("SB1")+Alltrim(aItens[nX,1])))
				IF Alltrim(aItens[nX][1]) <> '' .AND. aItens[nX][2] <> 0 .AND. aItens[nX][3] <> 0 
					
					//AADD(aLinha, {"CK_NUM"			,aCabec[8]	   			,Nil}  )
					AADD(aLinha, {"CK_ITEM"			,StrZero(nX,2)	   		,Nil}  )
					AADD(aLinha, {"CK_PRODUTO"		,SB1->B1_COD	   		,Nil}  )
					AADD(aLinha, {"CK_DESCRI"		,SB1->B1_DESC			,Nil}  )
					AADD(aLinha, {"CK_QTDVEN"		,aItens[nX][3]			,Nil}  ) //Val(StrTran(aItens[nX][2],',','.'))
					AADD(aLinha, {"CK_UM"			,SB1->B1_UM				,Nil}  )
					AADD(aLinha, {"CK_PRUNIT"		,SB1->B1_PRV1			,Nil}  )
					AADD(aLinha, {"CK_PRCVEN"		,aItens[nX][2]			,Nil}  )
					//AADD(aLinha, {"CK_VALOR"		,cTes					,Nil}  ) //Calculado Automatico
					//AADD(aLinha, {"CK_DESCONT"	,cTes					,Nil}  ) //Calculado Automatico
					AADD(aLinha, {"CK_XPEM2"		,SB1->B1_XPEM2			,Nil}  )
	
					aLinha:=FWVetByDic(aLinha,"SCK")
					AAdd(aSC6,aLinha)
					aLinha:={}  
	
				Else
					cRet+="Há produtos sem preço ou quantidade, Oraçamento não será processado."
					cRet:="400|"+cRet+"|0"
					lProc:=.F.
				EndIF
			Else
				cRet+="Produto de código: "+Alltrim(aItens[nX,1])+" nao encontrado. Orçamento não será processado."
				cRet:="400|"+cRet+"|0"
				lProc:=.F.
			EndIF
		Next nX
		   
		//aCabec:={1:CJ_CLIENTE,2:CJ_LOJA,3:CJ_CONPAG,4:CJ_XVEND,5:CJ_XOBS,6:CJ_XUSER,7:CJ_XDESCON}
 		IF lProc   
 			cDesPG:=Posicione("SE4",1,xFilial("SE4")+Alltrim(aCabec[3]),"E4_DESCRI")
			cTpCli:= iif(SA1->A1_TIPO=='S'.AND.SA1->A1_XDTSOL > DDATABASE,'F',SA1->A1_TIPO)
			//AAdd(aSC5,{"CJ_NUM"		,aCabec[8] 				,Nil})
			AAdd(aSC5,{"CJ_CLIENTE"	,SA1->A1_COD  			,Nil})
			AAdd(aSC5,{"CJ_LOJA"	,SA1->A1_LOJA			,Nil})
			AAdd(aSC5,{"CJ_CLIENT" ,SA1->A1_COD  			,Nil})
			AAdd(aSC5,{"CJ_LOJAENT"	,SA1->A1_LOJA			,Nil})
			AAdd(aSC5,{"CJ_XMUN"	,SA1->A1_MUN			,Nil})
			AAdd(aSC5,{"CJ_CONDPAG"	,Alltrim(aCabec[3])		,Nil})     
			AAdd(aSC5,{"CJ_NOMCLI"	,SA1->A1_NOME			,Nil})
			AAdd(aSC5,{"CJ_XVEND"	,Alltrim(aCabec[4])  	,Nil}) 
			AAdd(aSC5,{"CJ_XOBS"	,Alltrim(aCabec[5])		,Nil})
			AAdd(aSC5,{"CJ_DESCONT"	,aCabec[7]				,Nil})
			AAdd(aSC5,{"CJ_XDESCON", cDesPG					,NIl})
			AAdd(aSC5,{"CJ_XNOMCLI",SA1->A1_NOME			,NIl})
			AAdd(aSC5,{"CJ_XTIPOCL",cTpCli					,Nil})
			AAdd(aSC5,{"CJ_TIPOCLI",cTpCli					,Nil})
			AAdd(aSC5,{"CJ_TXMOEDA",1						,Nil})
			IF Alltrim(aCabec[8]) = 'S'
				cSolDesc:="S"
			Else
				cSolDesc:="N"
			EndIF
			IF Alltrim(aCabec[9]) = 'S'
				cSolFat:="S"
			Else
				cSolFat:="N"
			EndIF			
			
			AADD(aSC5,{"CJ_XFLDESC"		,cSolDesc ,Nil}  )
			AADD(aSC5,{"CJ_XAPROVA"		,cSolFat,Nil}  )
			AADD(aSC5,{"CJ_XFLUIG"		,"S" ,Nil}  )
			lMsErroAuto := .F.
		    
		    cVend:=Posicione("SA3",1,xFilial("SA3")+Alltrim(aCabec[4]),"A3_NREDUZ")
			
			
			aSC5:=FWVetByDic(aSC5,"SCJ")
			
	   		MSExecAuto({|x,y,z|Mata415(x,y,z)},aSC5,aSC6,3)
	
			If lMsErroAuto
				//RollbackSx8()
				aAutoErro := GetAutoGRLog()
				_cLog:=""
			
				For nX := 1 To Len(aAutoErro)				
					_cLog+= aAutoErro[nX]+CHR(13)+CHR(10)		
					cRet+= aAutoErro[nX]+CHR(13)+CHR(10)	
				Next nX	
				/*
				_cLog+=CHR(13)+CHR(10)	
					For nY := 1 To Len(aSC5)				
						_cLog+= aSC5[nY][1]+" := "+aSC5[nY][2]+CHR(13)+CHR(10)		
					Next nY	*/
				
				
				DisarmTransaction()
				cRet+="Erro na inclusão do pedido, favor contactar suporte técnico "+_cLog
				cRet:="400|"+cRet+"|0"
			Else 
				//ConfirmSx8()
				cNum:=SCK->CK_NUM
				aDados:={cNum,SA1->A1_NOME,cVend,Alltrim(aCabec[5]),SA1->A1_COD,SA1->A1_LOJA,Alltrim(aCabec[4])} 
				cRet:="200|"+"Orçamento incluido com sucesso!"+"|"+cNum
				
				IF cSolDesc = "S"
					_cPara:=GetMV("MF_SOLDES")
					U_MANWS008(_cPara,, , "Solicitacao de Desconto", , , ,"2")
				EndIF
				
				IF cSolFat = "S"
					_cPara:=GetMV("MF_LIBFAT")
					U_MANWS008(_cPara,, , "Liberacao para Faturamento", , , ,"1")
				EndIF	
			EndIf
		EndIF
END TRANSACTION	
		
Else
	cRet+="Cliente e loja nao encontrado."
	cRet:="400|"+cRet+"|0"
EndIF

Return cRet               
