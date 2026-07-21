#include 'protheus.ch'
#include 'parmtype.ch'

/*/
===============================================================================================================================
Programa----------: F040FCR
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 26/08/2019
===============================================================================================================================
Descrição---------: Este programa serve para baixar titulos parcialmente que tenham abatimento automatico
===============================================================================================================================
Uso---------------: Contas a Receber
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFIN
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

user function F040FCR()

	local	cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))

	//local	cBCOTMP		:= Alltrim(GetMv("MV_XBCOTMP"))
	
	local	aArea		:= getArea(),;
			aAreaSE4	:= SE4->(getArea())
			
	local 	nTxJrs		:= 0,;
			nVlLiq		:= 0,;
			nVlTx		:= 0
	
	if cAmbiente == '1'	// ambiente 006

		if SE1->E1_TIPO == MVRECANT
			dbSelectArea('SE4')
			SE4->(dbSetOrder(1))
			SE4->(dbGoTop())
			if SE4->(dbSeek(xFilial('SE4')+SE1->E1_XCPGTO))
				nTxJrs	:= SE4->E4_XTXRED
			endif
			
			nVlTx	:= SE1->E1_VALOR * (nTxJrs/100)
			nVlLiq	:= SE1->E1_VALOR - nVlTx
			
			if recLock('SE1',.F.)
				SE1->E1_VALOR	:= nVlLiq
				SE1->E1_SALDO	:= nVlLiq
				SE1->E1_VLCRUZ	:= nVlLiq
				SE1->E1_XVLTX	:= nVlTx
				SE1->(msUnlock())
			endif
			
/*			aBxParc := {{"E1_PREFIXO" ,SE1->E1_PREFIXO			,Nil    },;
			           {"E1_NUM"      ,SE1->E1_NUM				,Nil    },;
					   {"E1_PARCELA"  ,SE1->E1_PARCELA			,Nil    },;
			           {"E1_TIPO"     ,SE1->E1_TIPO				,Nil    },;
			           {"AUTMOTBX"    ,"NOR"					,Nil    },;
			           {"AUTBANCO"    ,substring(cBCOTMP,1,3)	,Nil    },;
			           {"AUTAGENCIA"  ,substring(cBCOTMP,4,5)	,Nil    },;
			           {"AUTCONTA"    ,substring(cBCOTMP,9,10)	,Nil    },;
			           {"AUTDTBAIXA"  ,dDataBase				,Nil    },;
			           {"AUTDTCREDITO",dDataBase				,Nil    },;
			           {"AUTHIST"     ,"Abatimento JRS Cond."	,Nil    },;
			           {"AUTJUROS"    ,0						,Nil,.T.},;
			           {"AUTVALREC"   ,nVlLiq					,Nil    }}
			
	//		MSExecAuto({|x,y| Fina070(x,y)},aBxParc,3)
	
			lMsErroAuto := .F. 
			begin Transaction 
				MSExecAuto({|x,y| fina070(x,y)},aBxParc,3) //3-Inclusao 
				if lMsErroAuto 
					DisarmTransaction() 
					break 
				endif 
			end Transaction 
	  
			if lMsErroAuto 
				MostraErro() 
			endif*/
		endif
  	endif
	
	restArea(aAreaSE4)
	restArea(aArea)

return

