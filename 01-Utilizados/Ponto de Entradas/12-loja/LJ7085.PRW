#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Topconn.ch"
/*/
===============================================================================================================================
Programa----------: LJ7085 
Autor-------------: Tiago Lucio
Data da Criacao---: 01/07/2019
===============================================================================================================================
Descrição---------: permite definir o conteúdo da tag infCpl (Informações Complementares de Interesse do Contribuinte) 
presente no grupo  "Z. Informações Adicionais da NF-e".  O conteúdo dessa tag é impresso no DANFE da NFC-e, na divisão 
Va - Mensagem de Interesse do Contribuinte.
===============================================================================================================================
Uso---------------: LOJNFCE.PRW, LOJSAT.PRW
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: aRet[1][1] U(Unknown), aRet[1][2] C(Caracter)
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: CONTROLE DE LOJAS
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

User Function LJ7085() 

	local	aRet 	:= {},;
	 		_aArea	:= getArea(),;
	 		cMsg	:= '',;
	 		cMemo

	aadd( aRet, Array(2) ) 

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial("SC5")+SL1->L1_XPEDIDO))
	
	cMemo	:= SC5->C5_XOBS
	
	cMsg	:=  'Cond.Pagto: ' + SC5->C5_CONDPAG+'-'+AllTrim(POSICIONE('SE4',1,xFilial('SE4')+SC5->C5_CONDPAG,'E4_DESCRI'))+CRLF;
				+'Parcelas: '
	
	dbSelectArea('SL4')
	SL4->(dbSetOrder(1))
	SL4->(dbSeek(xFilial('SL4')+SL1->L1_NUM))
	while !SL4->(eof()) .and. SL4->L4_NUM == SL1->L1_NUM
		cMsg	+= alltrim(dtoc(SL4->L4_DATA))+' '+alltrim(transform(SL4->L4_VALOR,'@E 9,999,999,999,999.99'))+' '+alltrim(SL4->L4_FORMA)+' / '
		
		SL4->(dbSkip())
	enddo
	
	cMsg	+=CRLF+'Vend.: ' + alltrim(SL1->L1_VEND)+'-'+AllTrim(POSICIONE('SA3',1,xFilial('SA3')+SL1->L1_VEND,'A3_NOME'))+CRLF;
			+CRLF+' '+CRLF+' '+CRLF;
			+AllTrim(SC5->C5_XOBS)

/*			+CRLF;
			+'Recebemos da MANFIL COM. IND. FERRO E ACO LTDA os produtos'+CRLF;
			+'constantes do NFC-e acima.'+CRLF;
			+' '+CRLF+' '+CRLF+' '+CRLF;
			+'__________________________________________________________'+CRLF;
			+' '+CRLF+' '+CRLF;
			+alltrim(SC5->C5_XOBS)+CRLF+' '+CRLF
*/			
				 
		

	aRet[1][1] := NiL  //Reservado sistema
	aRet[1][2] := cMsg 
	
	restArea(_aArea)

return aRet