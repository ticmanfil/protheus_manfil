#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'rwmake.CH'
#include 'topconn.ch'
#include 'ap5mail.ch'
#include 'report.ch'
/*/
===============================================================================================================================
Programa----------: SC04001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 18/04/2019
===============================================================================================================================
Descrição---------: Este PE é executado para enviar RELATORIO DE ACOMPANHAMENTO DE ESTOQUE
===============================================================================================================================
Uso---------------: SCHEDULE
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: Nenhum
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: 04 - ESTOQUE
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor		|	Data	|										Motivo																
----------------:-----------:-------------------------------------------------------------------------------------------------------:
				|			|																											
=====================================================================================================================================
/*/

user function SC04001()

	private nomeFonte 	:= 'SC04001'

		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101'
		EnviaRel('01', '0101')
		RESET ENVIRONMENT

return

static function EnviaRel(_codEmp,_codFil)

	local 	nLocal		as character,;
			cTitulo 	as character,;
			cAssunto	as character,;
			cMensagem	as character,;
			cFrom		as character,;
			lret		as logical,;
			aItens		as array,;
			aTitulos	as array,; 
			aTamCol		as array,; 
			aMascara	as array,;
			x, i		as numeric


	nLocal		:= alltrim(getmv('MV_XLOCAL'))
	cTitulo 	:= '[SC04001] - ESTOQUE'
	cAssunto	:= '[SCH-MANFIL] - '+cTitulo+' - '+dtoc(date())+' - '+time()
	cMensagem	:= ''
	cFrom		:= ''
	lret		:= .F.
	
	if nLocal == '1'
		cTitulo 	:= '[SC04001] - ESTOQUE - [006]'
	
	elseif nLocal == '2'
		cTitulo 	:= '[SC04001] - ESTOQUE - [005]'
	
	endif
	cAssunto	:= '[SCH-MANFIL] - '+cTitulo+' - '+dtoc(date())+' - '+time()
	
	cFrom	:= u_emails('000000') //email do grupo de administradores
		cFrom	+= ';'+u_emails('000014') //email do grupo supervisores estoque
		cFrom	+= ';'+u_emails('000007') //email do grupo fiscal/contabil
		
	Qry(@aItens, @aTitulos, @aTamCol, @aMascara)
	
	if Len(aItens) > 0
	
		/**		Monta o script HTML para ser enviado por email 	**/        
		cMensagem:="<html>" 						
		cMensagem+="<head> 					"	
		cMensagem+="<STYLE TYPE='text/css'> 	"	
		cMensagem+="<!--     					"	
		cMensagem+="TD{font-family: Calibri; font-size: 7pt;} "
		cMensagem+="--->     					"
		cMensagem+="</STYLE> 					"
		cMensagem+="</head>  					"
		cMensagem+="<body>						"
		
		//TITULO
		cMensagem+="<table  border=1 cellpadding=0 width='100%' style='border:none'>"
	  	cMensagem+="<tr>"
	    cMensagem+="<td width='20%' style='border:none'><img width='250px' height='100px' id='_x0000_i1033' src='http://www.manfil.com.br/logo.jpg'  alt='http://www.manfil.com.br/'></td>"
	    cMensagem+="<td width='80%'><p align=center><b><span style=' text-align:center;font-size:16.0px;font-weight:bold;font-family:Calibri;color:#000000'>"+cTitulo+"</span></b></p></td>"
	  	cMensagem+="</tr>"
	  	cMensagem+="</table>"
		
		//CABECALHO DOS ITENS
		cMensagem+="<table  BORDER=1 width='100%' height='92'  style='border-collapse:collapse;border:none;mso-border-alt:solid black .5pt;'>"       
		cMensagem+="<tr  BGCOLOR='#000000'>"
	
		//Alimenta os titulos
		For x := 1 to Len(aTitulos)
			cMensagem+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>"+aTitulos[x]+"</th>"
		Next x       
		
		cMensagem+="</tr>"  
						
		//ITENS
		for  i:=1 to Len(aItens) 
		
	  		if i % 2 == 1
	  			cMensagem+="<tr  BGCOLOR='#F4A460'>"
			else              
	  		    cMensagem+="<tr>"
			endif                                                                                                                                                                                                                                                        
	  		    
			for x := 1 to Len(aTitulos)
				if !empty(aMascara[x])
					if valtype(aMascara[x])		== 'N'
						cMensagem+="<td   style='text-align:rigth;font-size:13.0px;font-family:Calibri' >"+Transform(aItens[i][x], aMascara[x])+"</td>"
					elseif valtype(aMascara[x])	== 'D'
						cMensagem+="<td   style='text-align:center;font-size:13.0px;font-family:Calibri' >"+Transform(aItens[i][x], aMascara[x])+"</td>"
					else
						cMensagem+="<td   style='text-align:left;font-size:13.0px;font-family:Calibri' >"+Transform(aItens[i][x], aMascara[x])+"</td>"
					endif
				else
					cMensagem+="<td   style='text-align:left;font-size:13.0px;font-family:Calibri' >"+aItens[i][x]+"</td>"
				endif
			next x       
				
			cMensagem+="</tr>"
	  			    
	  	next i
	    
	  	cMensagem+="</table>"
	  	cMensagem+="</body>"
	  	cMensagem+="</html>"     
	  	                  
		U_EnvMail(,cFrom,'','',cAssunto,cMensagem,'',@lRet)
	endif
	
return lRet

static function Qry(aItens, aTitulos, aTamCol, aMascara)

	local	cQry		as character

	aItens		:= {} 
	aTitulos	:= {}
	aTamCol 	:= {}
	aMascara	:= {}

	if select('TMP1') <> 0
		dbSelectArea('TMP1')
		TMP1->(dbCloseArea())
	endif

	cQry := "exec dbo.PR_SC04001 @FILIAL = '"+fwxFilial('SB1')+"'"

	tcQuery cQry new alias 'TMP1'

	aTitulos	:= { 'TP.Registro',  U_UX3Titulo('B2_COD'), U_UX3Titulo('B1_DESC'), U_UX3Titulo('B1_UM'), U_UX3Titulo('B2_QATU'), U_UX3Titulo('B2_CM1'), U_UX3Titulo('B2_VATU1'), U_UX3Titulo('B2_VFIM1'), U_UX3Titulo('B1_SEGUM'), U_UX3Titulo('B2_QTSEGUM'), U_UX3Titulo('B1_UCOM') }
	aTamCol	:= { 40,  tamsx3('B2_COD'), tamsx3('B1_DESC'), tamsx3('B1_UM'), tamsx3('B2_QATU'), tamsx3('B2_CM1'), tamsx3('B2_VATU1'), tamsx3('B2_VFIM1'), tamsx3('B1_SEGUM'), tamsx3('B2_QTSEGUM'), tamsx3('B1_UCOM') }
	aMascara	:= { '@!',  x3Picture('B2_COD'), x3Picture('B1_DESC'), x3Picture('B1_UM'), x3Picture('B2_QATU'), x3Picture('B2_CM1'), x3Picture('B2_VATU1'), x3Picture('B2_VFIM1'), x3Picture('B1_SEGUM'), x3Picture('B2_QTSEGUM'), x3Picture('B1_UCOM') }

	while !TMP1->(eof())
		aadd(aItens,{TMP1->TIPO ,  TMP1->B2_COD, TMP1->B1_DESC, TMP1->B1_UM, TMP1->B2_QATU, TMP1->B2_CM1, TMP1->B2_VATU1, TMP1->B2_VFIM1, TMP1->B1_SEGUM, TMP1->B2_QTSEGUM, TMP1->B1_UCOM })
		TMP1->(dbSkip()) 
	enddo

return {aItens, aTitulos, aTamCol, aMascara}
