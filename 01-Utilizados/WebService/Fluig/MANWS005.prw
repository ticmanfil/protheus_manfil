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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออออออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณ FATW001  บ Autor ณ Fabrํcio Antunes      บ Data da Criacao  ณ 17/01/2019               					    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDescricao ณ Gera e altera o Or็amento de Venda integra็ใo FLUIG via webservice                                      		บฑฑ
ฑฑบ          ณ 																					                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 														             						                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Nenhum						   							                               						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nenhum						  							                               						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUsuario   ณ Microsiga                                                                                					บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบSetor     ณ Manfil 				                                                                   						บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ            			          	ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                   						บฑฑ
ฑฑฬออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออัออออออออออออออออออออออออออออออออออัอออออออออออออนฑฑ
ฑฑบAutor     ณ Data     ณ Motivo da Alteracao  				               ณUsuario(Filial+Matricula+Nome)    ณSetor        บฑฑ
ฑฑบฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤบฑฑ
ฑฑบ          ณ          ณ                               				   ณ                                  ณ   	        บฑฑ
ฑฑบ----------ณ----------ณ--------------------------------------------------ณ----------------------------------ณ-------------บฑฑ
ฑฑบ          ณ          ณ                    							   ณ                                  ณ 			บฑฑ
ฑฑบ----------ณ----------ณ--------------------------------------------------ณ----------------------------------ณ-------------บฑฑ
ฑฑศออออออออออฯออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออฯออออออออออออออออออออออออออออออออออฯอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/    

User Function FATW0X01; Return

WsStruct PEDITENS
 	WsData CK_PRODUTO 	As String	OPTIONAL
	WsData CK_QTDVEN 	As FLOAT	OPTIONAL
	WsData CK_PRUNIT 	As FLOAT	OPTIONAL
EndWsStruct                       

WsStruct PEDIDOS

    WsData CJ_NUM		As String	OPTIONAL
    WsData CJ_CLIENTE	As String	OPTIONAL
    WsData CJ_LOJACLI	As String	OPTIONAL
    WsData CJ_CONDPAG	As String	OPTIONAL  
    Wsdata CJ_XVEND		As String	OPTIONAL 
    WsData CJ_XOBS		As String	OPTIONAL
    WsData CJ_XUSER		As String	OPTIONAL
    WsData CJ_XDESCON	As Float	OPTIONAL
	WsData oItens		As ARRAY 	OF  PEDITENS 		
		
EndWsStruct


WsService IMPPEDIDOS DESCRIPTION "WebService de integra็ใo Fluig para importa็ใo e alteracao de orcamento"

	WSData cWSPWD 	    As String 	   
    WsData oPedidos    As PEDIDOS
	WSData cWSRETURN   As String

    WsMethod GERAPEDIDO DESCRIPTION "Metodo para geracao de Orcamento via MSExecAuto() da MATA415"
    WsMethod ALTERAPEDIDO DESCRIPTION "Metodo para geracao de Orcamento via MSExecAuto() da MATA415"
    
EndWsService

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FATW001P บ Autor ณ Fabricio Antunes   บ Data ณ 07/04/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera o Pedido de venda                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบArquivos  ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

WsMethod GERAPEDIDO WsReceive cWSPWD,oPedidos WsSend cWSRETURN WsService IMPPEDIDOS

Local cChave 	:= ::cWSPWD  //CHAVE DE VALIDAO ORIGEM
Local oDados 	:= ::oPedidos 
Local cPARPWD	:= "123456"   
Local aCabec	:={}
Local aItens	:={}
Local _cLog     :=""
Local nX

IF AllTrim(cChave) == AllTrim(cPARPWD)
         aCabec:={oDados:CJ_CLIENTE,oDados:CJ_LOJACLI,oDados:CJ_CONDPAG,oDados:CJ_XVEND,oDados:CJ_XOBS,oDados:CJ_XUSER,oDados:CJ_XDESCON}
         For nX:=1 to Len(oDados:oItens)
        	aadd(aItens,{oDados:oItens[nX]:CK_PRODUTO,oDados:oItens[nX]:CK_PRUNIT,oDados:oItens[nX]:CK_QTDVEN})
         Next 
         cRet	:= U_GERPED01(aCabec,aItens)
         ::cWSRETURN:= cRet
Else
	conOut("[ERRO] GERAPEDIDO " + dtoc(date()) + " " + Time() +"==>Chave de seguran็a invแlida!")
	::cWSRETURN := "00000 -CHAVE DE SEGURANวA INVมLIDA" //RETORNO DE OPERAO NO CONCLUIDA
EndIf

Return(.T.)     
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FATW001P บ Autor ณ Fabricio Antunes   บ Data ณ 07/04/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera o Pedido de venda                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบArquivos  ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  
User Function GERPED01(aCabec,aItens)

Local aSC5:={}
Local aLinha:={}
Local aSC6:={}
Local cNum:=""
Local lProc:=.T.
Local cRet:=""
Local _cLog:=""
Local nX
Local nY
Private lMsErroAuto :=.F.
Private lAutoErrNoFile:=.T.  

cNum:=GETSXENUM("SCJ","CJ_NUM")

dbSelectArea("SA1")
SA1->(dbSetOrder(1))
IF SA1->(dbSeek(xFilial("SA1")+Alltrim(aCabec[1])+Alltrim(aCabec[2])))

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
		
		For nX:= 1 to Len(aItens) 
			IF SB1->(dbSeek(xFilial("SB1")+Alltrim(aItens[nX,1])))
				IF Alltrim(aItens[nX][1]) <> '' .AND. aItens[nX][2] <> 0 .AND. aItens[nX][3] <> 0 
					
					AADD(aLinha, {"CK_NUM"			,cNum	   				,Nil}  )
					AADD(aLinha, {"CK_ITEM"			,StrZero(nX,2)	   		,Nil}  )
					AADD(aLinha, {"CK_PRODUTO"		,SB1->B1_COD	   		,Nil}  )
					AADD(aLinha, {"CK_DESCRI"		,SB1->B1_DESC			,Nil}  )
					AADD(aLinha, {"CK_QTDVEN"		,aItens[nX][3]			,Nil}  ) //Val(StrTran(aItens[nX][2],',','.'))
					AADD(aLinha, {"CK_UM"			,SB1->B1_UM				,Nil}  )
					AADD(aLinha, {"CK_PRUNIT"		,aItens[nX][2]			,Nil}  )
					AADD(aLinha, {"CK_PRCVEN"		,SB1->B1_PRV1			,Nil}  )
					//AADD(aLinha, {"CK_VALOR"		,cTes					,Nil}  ) //Calculado Automatico
					//AADD(aLinha, {"CK_DESCONT"	,cTes					,Nil}  ) //Calculado Automatico
					AADD(aLinha, {"CK_XPEM2"		,SB1->B1_XPEM2			,Nil}  )
	
					aLinha:=FWVetByDic(aLinha,"SCK")
					AAdd(aSC6,aLinha)
					aLinha:={}  
	
				Else
					cRet+="Hแ produtos sem pre็o ou quantidade, Ora็amento nใo serแ processado."
					lProc:=.F.
				EndIF
			Else
				cRet+="Produto de c๓digo: "+Alltrim(aItens[nX,1])+" nao encontrado. Or็amento nใo serแ processado."
				lProc:=.F.
			EndIF
		Next nX
		   
		//aCabec:={1:CJ_CLIENTE,2:CJ_LOJA,3:CJ_CONPAG,4:CJ_XVEND,5:CJ_XOBS,6:CJ_XUSER,7:CJ_XDESCON}
 		IF lProc   
 			cDesPG:=Posicione("SE4",1,xFilial("SE4")+Alltrim(aCabec[3]),"E4_DESCRI")
			AAdd(aSC5,{"CJ_NUM"		,cNum 					,Nil})
			AAdd(aSC5,{"CJ_CLIENTE"	,SA1->A1_COD  			,Nil})
			AAdd(aSC5,{"CJ_LOJA"	,SA1->A1_LOJA			,Nil})
			AAdd(aSC5,{"CJ_CLIENT" ,SA1->A1_COD  			,Nil})
			AAdd(aSC5,{"CJ_LOJAENT"	,SA1->A1_LOJA			,Nil})
			AAdd(aSC5,{"CJ_XMUN"	,SA1->A1_MUN			,Nil})
			AAdd(aSC5,{"CJ_CONPAG"	,Alltrim(aCabec[3])		,Nil})   
			AAdd(aSC5,{"CJ_NOMCLI"	,SA1->A1_NOME			,Nil})
			AAdd(aSC5,{"CJ_XVEND"	,Alltrim(aCabec[4])  	,Nil}) 
			AAdd(aSC5,{"CJ_XOBS"	,Alltrim(aCabec[5])		,Nil})
			AAdd(aSC5,{"CJ_DESCONT"	,aCabec[7]				,Nil})
			AAdd(aSC5,{"CJ_XDESCON", cDesPG					,NIl})
			AAdd(aSC5,{"CJ_XNOMCLI",SA1->A1_NOME			,NIl})
			AAdd(aSC5,{"CJ_XTIPOCL",SA1->A1_TIPO			,Nil})
			AAdd(aSC5,{"CJ_TXMOEDA",1						,Nil})
			lMsErroAuto := .F.
		    
			aSC5:=FWVetByDic(aSC5,"SCJ")

	   		MSExecAuto({|x,y,z|Mata415(x,y,z)},aSC5,aSC6,3)
	
			If lMsErroAuto
				RollbackSx8()
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
				cRet:="Erro na inclusใo do pedido, favor contactar suporte t้cnico "+_cLog
			Else 
				ConfirmSx8() 
				cRet+="Or็amento de numero "+cNum+" incluido com sucesso!"
				
			EndIf
		EndIF
	
		
Else
	cRet+="Cliente e loja nao encontrado."
EndIF


Return cRet                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FATW001P บ Autor ณ Fabricio Antunes   บ Data ณ 07/04/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera o Pedido de venda                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบArquivos  ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

WsMethod ALTERAPEDIDO WsReceive cWSPWD,oPedidos WsSend cWSRETURN WsService IMPPEDIDOS

Local cChave 	:= ::cWSPWD  //CHAVE DE VALIDAO ORIGEM
Local oDados 	:= ::oPedidos 
Local cPARPWD	:= "123456"   
Local aCabec	:={}
Local aItens	:={}
Local _cLog     :=""
Local nX

IF AllTrim(cChave) == AllTrim(cPARPWD)
         aCabec:={oDados:CJ_CLIENTE,oDados:CJ_LOJACLI,oDados:CJ_CONDPAG,oDados:CJ_XVEND,oDados:CJ_XOBS,oDados:CJ_XUSER,oDados:CJ_XDESCON,oDados:CJ_NUM}
         For nX:=1 to Len(oDados:oItens)
        	aadd(aItens,{oDados:oItens[nX]:CK_PRODUTO,oDados:oItens[nX]:CK_PRUNIT,oDados:oItens[nX]:CK_QTDVEN})
         Next 
         cRet	:= U_GERPED02(aCabec,aItens)
         ::cWSRETURN:= cRet
Else
	conOut("[ERRO] GERAPEDIDO " + dtoc(date()) + " " + Time() +"==>Chave de seguran็a invแlida!")
	::cWSRETURN := "00000 -CHAVE DE SEGURANวA INVมLIDA" //RETORNO DE OPERAO NO CONCLUIDA
EndIf
Return(.T.)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FATW001P บ Autor ณ Fabricio Antunes   บ Data ณ 07/04/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera o Pedido de venda                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบArquivos  ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  
User Function GERPED02(aCabec,aItens)

Local aSC5:={}
Local aLinha:={}
Local aSC6:={}
Local cNum:=""
Local lProc:=.T.
Local cRet:=""
Local _cLog:=""
Local nX
Local nY
Private lMsErroAuto :=.F.
Private lAutoErrNoFile:=.T.  

cNum:=GETSXENUM("SCJ","CJ_NUM")

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
					
					AADD(aLinha, {"CK_NUM"			,aCabec[8]	   			,Nil}  )
					AADD(aLinha, {"CK_ITEM"			,StrZero(nX,2)	   		,Nil}  )
					AADD(aLinha, {"CK_PRODUTO"		,SB1->B1_COD	   		,Nil}  )
					AADD(aLinha, {"CK_DESCRI"		,SB1->B1_DESC			,Nil}  )
					AADD(aLinha, {"CK_QTDVEN"		,aItens[nX][3]			,Nil}  ) //Val(StrTran(aItens[nX][2],',','.'))
					AADD(aLinha, {"CK_UM"			,SB1->B1_UM				,Nil}  )
					AADD(aLinha, {"CK_PRUNIT"		,aItens[nX][2]			,Nil}  )
					AADD(aLinha, {"CK_PRCVEN"		,SB1->B1_PRV1			,Nil}  )
					//AADD(aLinha, {"CK_VALOR"		,cTes					,Nil}  ) //Calculado Automatico
					//AADD(aLinha, {"CK_DESCONT"	,cTes					,Nil}  ) //Calculado Automatico
					AADD(aLinha, {"CK_XPEM2"		,SB1->B1_XPEM2			,Nil}  )
	
					aLinha:=FWVetByDic(aLinha,"SCK")
					AAdd(aSC6,aLinha)
					aLinha:={}  
	
				Else
					cRet+="Hแ produtos sem pre็o ou quantidade, Ora็amento nใo serแ processado."
					lProc:=.F.
				EndIF
			Else
				cRet+="Produto de c๓digo: "+Alltrim(aItens[nX,1])+" nao encontrado. Or็amento nใo serแ processado."
				lProc:=.F.
			EndIF
		Next nX
		   
		//aCabec:={1:CJ_CLIENTE,2:CJ_LOJA,3:CJ_CONPAG,4:CJ_XVEND,5:CJ_XOBS,6:CJ_XUSER,7:CJ_XDESCON}
 		IF lProc   
 			cDesPG:=Posicione("SE4",1,xFilial("SE4")+Alltrim(aCabec[3]),"E4_DESCRI")
			AAdd(aSC5,{"CJ_NUM"		,aCabec[8] 				,Nil})
			AAdd(aSC5,{"CJ_CLIENTE"	,SA1->A1_COD  			,Nil})
			AAdd(aSC5,{"CJ_LOJA"	,SA1->A1_LOJA			,Nil})
			AAdd(aSC5,{"CJ_CLIENT" ,SA1->A1_COD  			,Nil})
			AAdd(aSC5,{"CJ_LOJAENT"	,SA1->A1_LOJA			,Nil})
			AAdd(aSC5,{"CJ_XMUN"	,SA1->A1_MUN			,Nil})
			AAdd(aSC5,{"CJ_CONPAG"	,Alltrim(aCabec[3])		,Nil})   
			AAdd(aSC5,{"CJ_NOMCLI"	,SA1->A1_NOME			,Nil})
			AAdd(aSC5,{"CJ_XVEND"	,Alltrim(aCabec[4])  	,Nil}) 
			AAdd(aSC5,{"CJ_XOBS"	,Alltrim(aCabec[5])		,Nil})
			AAdd(aSC5,{"CJ_DESCONT"	,aCabec[7]				,Nil})
			AAdd(aSC5,{"CJ_XDESCON", cDesPG					,NIl})
			AAdd(aSC5,{"CJ_XNOMCLI",SA1->A1_NOME			,NIl})
			AAdd(aSC5,{"CJ_XTIPOCL",SA1->A1_TIPO			,Nil})
			AAdd(aSC5,{"CJ_TXMOEDA",1						,Nil})
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
				
				
				DisarmTransaction()
				cRet:="Erro na altercao do pedido, favor contactar suporte t้cnico "+_cLog
			Else 
				ConfirmSx8() 
				cRet+="Or็amento de numero "+aCabec[8]+" alterado com sucesso!"
				
			EndIf
		EndIF
END TRANSACTION	
		
Else
	cRet+="Cliente e loja nao encontrado."
EndIF

Return cRet               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณpicVal    บAutor  ณFabricio Antunes    บ Data ณ  03/12/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para retornar a picture correta de valores em       บฑฑ
ฑฑบ          ณ moeda (tratado como texto)                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function picVal (cValor)
	Local nTamanho:=Len(cValor) //13
	Local nPosP:=At(".",cValor) //12
	Local aPart:={}
	Local cRet:=''
	Local nX
	
	If nTamanho - nPosP = 1
	     cValor:=cValor+"0"
	EndIF 
	
	IF nTamanho - nPosP = 0
	     cValor:=cValor+"00"
	EndIF 
	
	IF nPosP = 0
		cValor:=cValor+".00"
	EndIF
	
	cValor:=Strtran(cValor,'.',",")  
	cInt:=SubStr(cValor,1,Len(cValor)-3)
    cDec:=SubStr(cValor,Len(cValor)-2,3)
    nQuant:=Int(Len(cInt)/3)
    
    For nx:=1 to nQuant
    	AADD(aPart,SubStr(cInt,Len(cInt)-2,3))
    	cInt:=SubStr(cInt,1,Len(cInt)-3)
    Next
	
	AADD(aPart,cInt)
	
	For nx:=Len(aPart) to 1 step -1
		IF Alltrim(aPart[nx]) <> ''
			cRet+=aPart[nx]+'.'		
		EndIF
	Next
	cRet:="R$"+SubStr(cRet,1,Len(cRet)-1)+cDec	
 
Return (cRet) 