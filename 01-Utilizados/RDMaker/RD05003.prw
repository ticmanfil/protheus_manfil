#include 'protheus.ch'
#include "tbiconn.ch" 
#include 'topconn.ch'
/*/
===============================================================================================================================
Programa----------: RD05003
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 22/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para valida se existe ou nao oçamento válido para o cliente informado
===============================================================================================================================
Uso---------------: Orcamento de Pedido de Venda
===============================================================================================================================
Parametros--------: cCliente	- Codigo do Cliente
					cLoja		- loja do cliente
===============================================================================================================================
Retorno-----------: cRet	=> .F. - Falsou    ou .T. - Verdadeiro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFAT
===============================================================================================================================
========================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
========================================================================================================================================
	Autor		|	Data	|										Motivo																
----------------:-----------:-----------------------------------------------------------------------------------------------------------:
RENATO FUZESSY	|16.01.2019 | TRANTANDO ERRO AO ALTERAR O CLIENTE NA INCLUSAO DO ORCAMENTO E LOGO APOS DE INSERIR O PRIMEIRO PRODUTO 																										
----------------:-----------:-----------------------------------------------------------------------------------------------------------:
RENATO FUZESSY	|10.07.2021 | INCLUINDO VALIDACAO SE O CLIENTE É SOLIDARIO E É UM REVENDEDOR
----------------:-----------:-----------------------------------------------------------------------------------------------------------:
				|			|																											
=========================================================================================================================================
/*/
user function RD05003(cCliente, cLoja, cTipo)
	
//    Local aArea     	:= GetArea()
//    Local aAreaSCJ   	:= SCJ->(GetArea())
    Local 	cQuery	   	:= "",;
    		cMsg		:= "",;
    		lRet		:= .T.,;
    		cUF			:= alltrim(getMV('MV_ESTADO')),;
			lOk			:= .F.,;
			cLocal		:= GETMV("MV_XLOCAL")

	Local	cEnter		:= chr(10)+chr(13)

	local	aArea		:= GetArea(),;
			aAreaSA1	:= SA1->(GetArea())

    default cTipo 		:= ''
	
    lRet	:= .T.
       
	if FunName() == 'MATA415'
		if !empty(cCliente) .and. !empty(cLoja) .and. !l415Auto
			LOk:= .T.
		endif

	elseif FunName() == 'MATA410' //.and. cLocal = '2'
		if !empty(cCliente) .and. !empty(cLoja)
			LOk:= .T.
		endif

	endif

	if lOk
		dbSelectArea('SA1')
		SA1->(dbGoTop())
		SA1->(dbSetOrder())
		if (SA1->(dbSeek(xFilial('SA1')+cCliente+cLoja)))

			//01 - VALIDANDO CLIENTE CONSUMIDOR
			if SA1->A1_COD == '99999999' .and. cLocal == '1'
				cMsg:= cMsg+cEnter+'Cliente CONSUMIDOR NAO IDENTIFICADO não permitido!!! Utiliza o seu CLIENTE CONSUMIDOR NÃO IDENTIFICADO.' 
				lRet	:= .F.
			endif

			if SA1->A1_EST != cUF
				cMsg:= cMsg+cEnter;
						+'CLIENTE fora do ESTADO ('+alltrim(SA1->A1_EST)+')'
			endif

			//03 - VALIDANDO O CLIENTE E UM REVENDEDOR OU NÃO
			if SA1->A1_CODSEG == '000004' .and. SA1->A1_TIPO == 'S'
				cMsg:= cMsg+cEnter+cEnter;
						+'CLIENTE É UM REVENDEDOR e está sujeito a RETENÇÃO ICMS ST portanto a COBRANÇA extra. Para os sub-grupos:'+cEnter;
						+'- 7001 - Telhas de Aço MA - ICMS ST 15,90%'+cEnter;
						+'- 7002 - Colunas Prontas MA - ICMS ST 12,30%'+cEnter;
						+'- 7101 - Vergalhões MA 50/60 - ICMS ST 4,20%'+cEnter;
						+'- 7115 - Treliças MA - ICMS ST 15,90%'+cEnter;
						+'- 7116 - Telas/Paineis MA - ICMS ST 12,30%'+cEnter;
						+'- 7117 - Malhas Pop MA - ICMS ST 12,30%'+cEnter
			endif

			if SA1->A1_CODSEG == '000005'
				cMsg:= cMsg+cEnter+cEnter;
						+'CLIENTE É UM FAZENDEIRO!'+cEnter
			endif

			//04-ALERTANDO DIVERSOS REFERENTE AO CLIENTE
			if cLocal == '1'	//gerencial 
				if SA1->A1_XNF .and. FunName() $ 'MATA415|LOJA701' //tela de orcamento
					cMsg:= cMsg+cEnter+'Cliente requer FATURAMENTO'
				endif 
			elseif cLocal == '2'	//fiscal 
				if !SA1->A1_XNF
					cMsg:= cMsg+cEnter+'Cliente NÃO requer FATURAMENTO'
				endif 
			endif

			if SA1->A1_XCERTIF
				cMsg:= cMsg+cEnter+'Cliente requer CERTIFICADO DE QUALIDADE DO FORNECEDOR, com as informações na nota fiscal' 
			endif

			if SA1->A1_XPED
				if cLocal == '1'		//gerencial
					cMsg:= cMsg+cEnter+'Cliente requer ATENÇÃO' 
				elseif cLocal == '2'	//fiscal
					cMsg:= cMsg+cEnter+'Cliente requer PEDIDO DE COMPRA' 
				endif
			endif

			if SA1->A1_XRA .and. FunName() == 'MATA415|LOJA701'
				cMsg:= cMsg+cEnter+'Aceito somente com RECEBIMENTO ANTECIPADO' 
			endif

			if SA1->A1_XCONTAB
				cMsg:= cMsg+cEnter+'Será necessário a liberção da venda pelo CONTADOR' 
			endif

			//05-APURANDO SE HÁ ORCAMENTO EM ABERTO PARA O CLIENTE SELECIONADO
			if select('TB01') != 0
				TB01->(dbCloseArea())
			endif

			cQuery	:= "exec dbo.PR_RD05003 @FILIAL = '"+xFilial('SC5')+"', @CLIENTE = '"+cCliente+"', @LOJA = '"+cLoja+"', @TIPO = '"+cTipo+"'"
			TCQUERY cQuery NEW ALIAS 'TB01'
			dbSelectArea('TB01')
			TB01->(dbGoTop())
			if !TB01->(eof())
				cMsg:= cMsg+cEnter+cEnter;
						+"Pedidos que estão em Abertos:"
			endif
			while !TB01->(eof())
				cMsg:= cMsg+cEnter;
						+"Filial..: "+alltrim(TB01->CJ_FILIAL)+cEnter;
						+"Num.Ped.: "+alltrim(TB01->CJ_NUM)+" - Emissão: "+alltrim(TB01->CJ_EMISSAO)+" - R$ "+TransForm(TB01->CK_VALOR,"@E 999,999.99")+cEnter;
						+"Cliente.: "+alltrim(TB01->CLIENTE)+cEnter;
						+"Vendedor: "+alltrim(TB01->VENDEDOR)
				TB01->(dbSkip())
			enddo
			TB01->(dbCloseArea())
			
			If !Empty(cMsg)
				DEFINE MSDIALOG oDlg TITLE "Validação Cliente" From 000,000 TO 350,400 Pixel
				@ 005,005 GET oMemo VAR cMsg MEMO SIZE 150,150 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				DEFINE SBUTTON FROM 005,165 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
				ACTIVATE MSDIALOG oDlg CENTER
			Endif

		endif

	endif

	restArea(aAreaSA1)
	restArea(aArea)

return lRet
