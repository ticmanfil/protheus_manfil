#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'rwmake.CH'
#include 'topconn.ch'
#include 'ap5mail.ch'
#include 'report.ch'
/*/
===============================================================================================================================
Programa----------: SC04002
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 17/08/2020
===============================================================================================================================
Descrição---------: Este PE é executado para enviar RELATORIO DE PEDIDOS DE COMPRA
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

user function SC04002()

	private nomeFonte 	:= 'SC04002'

		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101'
		EnviaRel('01', '0101')
		RESET ENVIRONMENT

return

static function EnviaRel(_codEmp,_codFil)

	local 	nLocal		:= Alltrim(GetMv("MV_XLOCAL"))

	local 	cTitulo 	:= '[SC04002] - PEDIDO DE COMPRA',;
			_cAssunto	:= '[SCH-MANFIL] - '+cTitulo+' Data: '+DTOC(DDATABASE)
	   
	local	_cMensagem	:= ' ',;
			i, x, y,_aArrays,_aItens,_aTitulos, _aTamCol, _aMascara,;
			_cFrom		:= alltrim(UsrRetMail('000000')),;
			_ret		:= .F.
	
	local 	aAllusers 	:= FWSFALLUSERS(),;
			aGroup		:= {}
			
	if nLocal = '1'

		if nLocal == '1'
			cTitulo	+= ' - [006]'
		elseif nLocal == '2'
			cTitulo	+= ' - [005]'
		endif
		
		/*	retorno FWSFALLUSERS()
		[n][1] Id da tabela de usuários
		[n][2] Id do usuário
		[n][3] Login do Usuário
		[n][4] Nome do usuário
		[n][5] email do usuário
		[n][6] departamento do usuário
		[n][7] cargo do usuário
		*/
		for x := 1 To Len(aAllusers)
			aGroup	:= {}
			aGroup	:= usrRetGrp(,aAllusers[x][2])
			
			_cFrom	:= 'renato.filho@manfil.com.br;tic@manfil.com.br'
			for y := 1 to len(aGroup)
				if (nLocal == '1' .and. aGroup[y] = '000014') .or. (nLocal == '2' .and. aGroup[y] = '000007') // 14- sup estoque e 7 - fiscal e contabil
					if empty(_cFrom)
						_cFrom	:= alltrim(aAllusers[x][5])
					else
						_cFrom	+= ';' + alltrim(aAllusers[x][5])
					endif
				endif
			next y
		next x

		_aArrays	:= QryMain()
		_aItens		:= _aArrays[1]
		_aTitulos	:= _aArrays[2]
		_aTamCol	:= _aArrays[3]
		_aMascara	:= _aArrays[4]
		
		if Len(_aItens) > 0
		
			_cMensagem:="<html>"
			_cMensagem+="<head>"
			_cMensagem+="<STYLE TYPE='text/css'>"
			_cMensagem+="<!--"
			_cMensagem+="TD{font-family: Calibri; font-size: 7pt;} "
			_cMensagem+="--->"
			_cMensagem+="</STYLE>"
			_cMensagem+="</head>"
			_cMensagem+="<body>"
			
			//DADOS DA NOTA
			_cMensagem+="<table  border=0 cellpadding=0 width='100%' style='border:none'>"
			_cMensagem += "    <tr>"
			_cMensagem += "      <td style='text-align:rigth;font-size:13.0px;font-family:Calibri'>"
			_cMensagem += "	      <p>Segue a relação de PRODUTOS em PONTO DE PEDIDOS</p>" 
			_cMensagem += "	      <p>&nbsp;<\p>" 
			_cMensagem += "      </td>"
			_cMensagem += "    </tr>"
			_cMensagem+="</table>"

			//TITULO
			_cMensagem+="<table  border=1 cellpadding=0 width='100%' style='border:none'>"
			_cMensagem+="<tr>"
			_cMensagem+="<td width='20%' style='border:none'><img width='250px' height='100px' id='_x0000_i1033' src='http://www.manfil.com.br/logo.jpg'  alt='http://www.manfil.com.br/'></td>"
			_cMensagem+="<td width='80%'><p align=center><b><span style=' text-align:center;font-size:16.0px;font-weight:bold;font-family:Calibri;color:#000000'>PEDIDOS EM PONTOS DE PEDIDOS</span></b></p></td>"
			_cMensagem+="</tr>"
			_cMensagem+="</table>"
			
			//CABECALHO DOS ITENS
			_cMensagem+="<table  BORDER=1 width='100%' height='92'  style='border-collapse:collapse;border:none;mso-border-alt:solid black .5pt;'>"       
			_cMensagem+="<tr  BGCOLOR='#000000'>"
			//Alimenta os titulos
			For x := 1 to Len(_aTitulos)
				_cMensagem+="<th  style='font-size:13.0px;font-family:Calibri;color:#FFFAFA'  scope='col'><b>"+_aTitulos[x]+"</th>"
			Next x       
			_cMensagem+="</tr>"	 

			//ITENS
			for  i:=1 to Len(_aItens) 
			
				if i % 2 == 1
					_cMensagem+="<tr  BGCOLOR='#F4A460'>"
				else              
					_cMensagem+="<tr>"
				endif                                                                                                                                                                                                                                                        
					
				for x := 1 to Len(_aTitulos)
					if !empty(_aMascara[x])
						if 		valtype(_aMascara[x])	== 'N'
							_cMensagem+="<td   style='text-align:rigth;font-size:13.0px;font-family:Calibri' >"+Transform(_aItens[i][x], _aMascara[x])+"</td>"
						elseif 	valtype(_aMascara[x])	== 'D'
							_cMensagem+="<td   style='text-align:center;font-size:13.0px;font-family:Calibri' >"+Transform(_aItens[i][x], _aMascara[x])+"</td>"
						else
							_cMensagem+="<td   style='text-align:left;font-size:13.0px;font-family:Calibri' >"+Transform(_aItens[i][x], _aMascara[x])+"</td>"
						endif
					else
						_cMensagem+="<td   style='text-align:left;font-size:13.0px;font-family:Calibri' >"+_aItens[i][x]+"</td>"
					endif
				next x       
					
				_cMensagem+="</tr>"
						
			next i
			_cMensagem+="</table>"

			
			//Rodapé
			_cMensagem+="<table  border=0 cellpadding=0 width='100%' style='border:none'>"
			_cMensagem += "    <tr>"
			_cMensagem += "      <td style='text-align:rigth;font-size:13.0px;font-family:Calibri'>"
			_cMensagem += "	      <p>Este e-mail foi enviado automaticamente pelo PROTHEUS.</p>" 
			_cMensagem += "	      <p><strong>Equipe MANFIL</strong></p>"
			_cMensagem += "	      <p><strong>Tecnologia, Informação e Comunicação</strong></p>"
			_cMensagem += "      </td>"
			_cMensagem += "    </tr>"
			_cMensagem+="</table>"

			_cMensagem+="</body>"
			_cMensagem+="</html>"   

			_ret	:= U_EnvMail(, _cFrom, '', '', _cAssunto, _cMensagem, '', _ret)
			//U_MANWS008(_cPara, _cCc, _cBCC, _cTitulo, _aAnexo, _cMsg, _lAudit,cHtml,aDados)
			//exemplo: U_MANWS008(cEmailSA1, "tic@manfil.com.br;faturamento@manfil.com.br", "", cAssunto, _aAnexo,, ,"3",aDados)
			//_ret:= U_MANWS008(_cFrom, '', '', _cAssunto, '', _cMensagem, ,"3",aDados)
		endif
	endif
return _ret

static function QryMain()
	local	_aItens 	:= {},; 
			_aTitulos	:= {},;
			_aTamCol 	:= {},;
			_aMascara	:= {}
	
	if select('TMPWF')<>0
		dbSelectArea('TMPWF')
		TMPWF->(dbCloseArea())
	endif
	
	beginSql alias 'TMPWF'
		SELECT 	 SB1.B1_COD
				,SB1.B1_DESC
				,SB1.B1_UM
				,SB2.B2_QATU
				,SB1.B1_ESTSEG
				,SB1.B1_EMIN
				,SB1.B1_EMAX
				,SB1.B1_LE
				,SB1.B1_EMAX-SB2.B2_QATU AS 'SUGCOMP'

		FROM
			%table:SB1% AS SB1
			INNER JOIN %table:SB2% AS SB2
				ON	SB2.%NotDel%
				AND	SB2.B2_FILIAL	= %xFilial:SB2%
				AND	SB2.B2_COD 		= SB1.B1_COD
		WHERE
				SB1.%NotDel%
			AND	SB1.B1_FILIAL	= %xFilial:SB1%
			AND SB2.B2_QATU		<= SB1.B1_EMIN
			AND SB1.B1_EMIN		> 0
		ORDER BY %Order:SB1%
	endSql

	_aTitulos	:= { U_UX3Titulo('B1_COD'),  U_UX3Titulo('B1_DESC'), U_UX3Titulo('B1_UM'), U_UX3Titulo('B2_QATU'), U_UX3Titulo('B1_ESTSEG'), U_UX3Titulo('B1_EMIN'), U_UX3Titulo('B1_EMAX'), U_UX3Titulo('B1_LE'), 'Sug. Compra' }
	_aTamCol	:= { tamsx3('B1_COD'), tamsx3('B1_DESC'), tamsx3('B1_UM'), tamsx3('B2_QATU'), tamsx3('B1_ESTSEG'), tamsx3('B1_EMIN'), tamsx3('B1_EMAX'), tamsx3('B1_LE'), 16.2}
	_aMascara	:= { x3Picture('B1_COD'), x3Picture('B1_DESC'), x3Picture('B1_UM'), x3Picture('B2_QATU'), x3Picture('B1_ESTSEG'), x3Picture('B1_EMIN'), x3Picture('B1_EMAX'), x3Picture('B1_LE'), x3Picture('B2_QATU')}

	while !TMPWF->(eof())
		aadd(_aItens,{TMPWF->B1_COD ,  TMPWF->B1_DESC, TMPWF->B1_UM, TMPWF->B2_QATU, TMPWF->B1_ESTSEG, TMPWF->B1_EMIN, TMPWF->B1_EMAX, TMPWF->B1_LE, TMPWF->SUGCOMP})
		TMPWF->(dbSkip()) 
	enddo
 
return {_aItens,_aTitulos, _aTamCol, _aMascara }
