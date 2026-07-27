#include 'protheus.ch'
#include 'topconn.ch'
#include 'prtopdef.ch'
#include 'tbiconn.ch'
#include 'rwmake.CH'
#include 'ap5mail.ch'
#include 'report.ch'

/*/
===============================================================================================================================
Programa----------: RD06012
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 28/05/2025
===============================================================================================================================
Descrição---------: Este programa serve para AUDITAR OS ERROS DE ENVIO DE BOLETAS POR EMAIL e encaminhar para acerto
===============================================================================================================================
Uso---------------: FINANCEIRO
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: Faturamento
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
user function RD06012()

	local	aClientes	as array

	//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101'

	aClientes:= {}
	aStruct:= {}

	BuscaDados(@aClientes)
	if !empty(aClientes)
		EnviaEmail(@aClientes)
	endif
	
	//RESET ENVIRONMENT

return

static function BuscaDados(aClientes,aStruct)

	local	cQry	as char,;
			aItens	as array

	cQry	:= ''
	aItens	:= {}

	cQry:= 'exec dbo.PR_RD06012'

	if select('TB01')
		TB01->(dbCloseArea())
	endif

	tcquery cQry new alias 'TB01'

	dbSelectArea('TB01')
	while !TB01->(eof())
		aItens:= {}
		aadd(aItens,TB01->EA_NUMBOR)	/*01*/
		aadd(aItens,TB01->EA_PREFIXO)	/*02*/
		aadd(aItens,TB01->EA_NUM)		/*03*/
		aadd(aItens,TB01->EA_PARCELA)	/*04*/
		aadd(aItens,TB01->EA_TIPO)		/*05*/
		aadd(aItens,TB01->EA_SALDO)		/*06*/
		aadd(aItens,TB01->E1_CLIENTE)	/*07*/
		aadd(aItens,TB01->E1_LOJA)		/*08*/
		aadd(aItens,TB01->E1_NOMCLI)	/*09*/
		aadd(aItens,TB01->AI0_EMABOL)	/*10*/
		aadd(aItens,TB01->AI0_RECBOL)	/*11*/
		aadd(aItens,'X')				/*12*/
		aadd(aClientes,aItens)

		TB01->(dbSkip())
	enddo

	if select('TB01')
		TB01->(dbCloseArea())
	endif

return nil

static function EnviaEmail(aClientes)
	local	cEmail		as char,;
			cEmailCop	as char,;
			cAssunto	as char,;
			cMsg		as char

	local	xi		as numeric,;
			lret	as logical

	cEmail		:= u_Emails('000022')	//FINANCEIRO
	cEmailCop	:= usrRetMail('000000')
	cAssunto	:= '[AUDIT-BOL] - Log Envio de Email Boleta'
	cMsg		:= ''
	lret		:= .F.

	/**		Monta o script HTML para ser enviado por email 	**/        
	cMsg:="<html>" 						
	cMsg+="<head> 					"	
	cMsg+="<STYLE TYPE='text/css'> 	"	
	cMsg+="<!--     					"	
	cMsg+="TD{font-family: Calibri; font-size: 7pt;} "
	cMsg+="--->     					"
	cMsg+="</STYLE> 					"
	cMsg+="</head>  					"
	cMsg+="<body>						"
	
	//TITULO
	cMsg+="<table  border=1 cellpadding=0 width='100%' style='border:none'>"
		cMsg+="<tr>"
		cMsg+="<td width='20%' style='border:none'><img width='250px' height='100px' id='_x0000_i1033' src='http://www.manfil.com.br/logo.jpg'  alt='http://www.manfil.com.br/'></td>"
		cMsg+="<td width='80%'><p align=center><b><span style=' text-align:center;font-size:16.0px;font-weight:bold;font-family:Calibri;color:#000000'>"+'LISTA DE CLIENTES'+"</span></b></p></td>"
		cMsg+="</tr>"
	cMsg+="</table>"
	
	//CABECALHO DOS ITENS
	cMsg+="<table  BORDER=1 width='100%' height='92'  style='border-collapse:collapse;border:none;mso-border-alt:solid black .5pt;'>"       
	cMsg+="<tr  BGCOLOR='#000000'>"
		cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>CLIENTE</th>"
		cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>EMAIL</th>"
		//cMsg+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>ENVIA BOLETA</th>"
	cMsg+="</tr>"  

	//ITENS
	for xi:=1 to Len(aClientes)
		if xi % 2 == 1
			cMsg+="<tr BGCOLOR='#F4A460'>"
		else              
			cMsg+="<tr>"
		endif
		cMsg+= "<td   style='text-align:left;font-size:13.0px;font-family:Calibri' >"+aClientes[xi][7]+'-'+aClientes[xi][8]+'-'+aClientes[xi][9]+"</td>"
		cMsg+= "<td   style='text-align:left;font-size:13.0px;font-family:Calibri' >"+aClientes[xi][10]+"</td>"
		//cMsg+= "<td   style='text-align:left;font-size:13.0px;font-family:Calibri' >"+aClientes[xi][11]+"</td>"
		cMsg+="</tr>"
	next xi
	
	cMsg+="</table>"
	cMsg+="</body>"
	cMsg+="</html>"

	lret:= u_EnvMail(,cEmail,cEmailCop,'',cAssunto,cMsg,'',lret)

return lret
