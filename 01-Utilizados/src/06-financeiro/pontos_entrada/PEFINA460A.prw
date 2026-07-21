#include 'protheus.ch'
#include 'FWMVCDef.ch'
/*/
===============================================================================================================================
Programa----------: FINA460A
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 28/02/2019
===============================================================================================================================
Descrição---------: Este programa serve para acessar o PE da rotina FINA460
===============================================================================================================================
Uso---------------: FINA460
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------:
===============================================================================================================================
Setor-------------: SIGAFIN - FINANCEIRO
===============================================================================================================================
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
user function FINA460A()
	local	aParam		:= PARAMIXB,;
		xRet		:= .T.,;
		oObj		:= '',;
		cIdPonto	:= '',;
		cIdModel	:= '',;
		cMsg		:= '',;
		cNumTitulo	:= ''
		//nLinha		:= 0,;
		//nQtdLinhas	:= 0,;
		//cClasse		:= ''

	if aParam <> nil
		oObj		:= aParam[1]
		cIdPonto	:= aParam[2]
		cIdModel	:= aParam[3]

		if cIdPonto == 'FORMPOS' // VALIDACAO TOTAL DO FORMULARIO
			if cIdModel == 'TITGERFO2'	// pode ser TITSELFO1 or TITGERFO2
				if 'CH' $ oObj:getValue('FO2_TIPO') .and. (empty(oObj:getValue('FO2_BANCO')) .or. empty(oObj:getValue('FO2_AGENCI')) .or. empty(oObj:getValue('FO2_CONTA')))
					cMsg	:= 'Campo BANCO, AGENCIA e CONTA obrigatório!' + CRLF
					xRet	:= .F.
					ApMsgAlert(cMsg)
				endif
			endif
		endif

		if cIdPonto == 'FORMLINEPOS'
			if cIdModel == 'TITGERFO2'	// pode ser TITSELFO1 or TITGERFO2
				if !empty(oObj:setValue('FO2_NUM'))
					//oObj:setValue('FO2_NUM'):= strZero(val(oObj:getValue('FO2_NUM')),tamSx3('FO2_NUM')[1])
					cNumTitulo:= strZero(val(oObj:getValue('FO2_NUM')),tamSx3('FO2_NUM')[1])
					oObj:setValue('FO2_NUM',cNumTitulo)
					
					//M->FO2_NUM:= strZero(M->FO2_NUM,tamSx3('FO2_NUM')[1])
				endif
			endif
		endif

		if cIdPonto == 'FORMCOMMITTTSPRE'
			if cIdModel == 'TITGERFO2'	// pode ser TITSELFO1 or TITGERFO2
				if !empty(oObj:setValue('FO2_NUM'))
					//oObj:setValue('FO2_NUM'):= strZero(val(oObj:getValue('FO2_NUM')),tamSx3('FO2_NUM')[1])
					cNumTitulo:= strZero(val(oObj:getValue('FO2_NUM')),tamSx3('FO2_NUM')[1])
					oObj:setValue('FO2_NUM',cNumTitulo)
					//M->FO2_NUM:= strZero(M->FO2_NUM,tamSx3('FO2_NUM')[1])
				endif
			endif
		endif

		if cIdPonto == 'BUTTONBAR'
			if !CUSERNAME $ '000016'
				if !(xRet := Pergunte('AFI460',.T.))
					xRet	:= .F.
					ApMsgInfo('Você cancelou as Perguntas e não será possivel prosseguir!!!..')
				endif
			endif
		endif

		if cIdPonto == 'MODELCOMMITNTTS' // Bloco substitui o ponto de entrada F460GRV.
		
		endIf
		
	endif

/*		if cIdPonto == 'MODELPOS' // Bloco substitui o ponto de entrada F460TOK e FA460CON
			cMsg := 'Chamada na validação total do formulário (MODELPOS).' + CRLF
			cMsg += 'ID ' + cIdModel + CRLF
			
			if cClasse == 'FWFORMGRID' // Bloco substitui o ponto de entrada FA460LOK, validação do Grid, utilizar o ID de Model 'TITGERFO2'
				nQtdLinhas	:= oObj:Length()
				nLinha		:= oObj:GetLine()
			
				cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
				cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF
			endif
				
			if !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
				Help( ,, 'Help',, 'O MODELPOS retornou .F.', 1, 0 )
			endif
			
		elseif cIdPonto == 'MODELCANCEL' // Bloco substitui os pontos de entrada F460CAN, F460CON e F460SAID no cancelamento da tela de geração de liquidação.
			cMsg := 'Chamada no Botão Cancelar (MODELCANCEL).' + CRLF + 'Deseja Realmente Sair ?'
		
			if !( xRet := ApMsgYesNo( cMsg ) )
			    Help( ,, 'Help',, 'O MODELCANCEL retornou .F.', 1, 0 )
			endif
		
		elseif cIdPonto == 'FORMLINEPRE' // Bloco substitui o ponto de entrada A460VALLIN.
			if cIdModel == 'TITGERFO2'
				nQtdLinhas	:= oObj:Length()
				nLinha		:= oObj:GetLine()
			
				if aParam[5] == 'DELETE' // Deleção de Linha do Grid
					cMsg := 'Chamada na pre validação da linha do formulário (FORMLINEPRE).' + CRLF
					cMsg += 'Onde esta se tentando deletar uma linha' + CRLF
					cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
					cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF
					cMsg += 'ID ' + cIdModel + CRLF
				
					if !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
						Help( ,, 'Help',, 'O FORMLINEPRE retornou .F.', 1, 0 )
					endif
				endif
			endif
		

			if cIdModel == 'TITGERFO2'
				nQtdLinhas	:= oObj:Length()
				nLinha		:= oObj:GetLine()
				
				cMsg := 'Chamada na validação da linha do formulário (FORMLINEPOS).' + CRLF
				cMsg += 'ID ' + cIdModel + CRLF
				cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ' linha(s).' + CRLF
				cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF
				
				if !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
					Help( ,, 'Help',, 'O FORMLINEPOS retornou .F.', 1, 0 )
				endif
			
		elseif cIdPonto == 'MODELCOMMITNTTS' // Bloco substitui o ponto de entrada F460GRV.
			ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel)

		elseif cIdPonto == 'BUTTONBAR' // Bloco substitui o ponto de entrada F460BOT.
			ApMsgInfo('Adicionando Botao na Barra de Botoes (BUTTONBAR).' + CRLF + 'ID ' + cIdModel )
			xRet := { {'Salvar', 'SALVAR', { || Alert( 'Salvou' ) }, 'Este botao Salva' } }
		endif
*/

return xRet
