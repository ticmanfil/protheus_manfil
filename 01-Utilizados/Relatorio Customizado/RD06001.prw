/*/
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
#include 'protheus.ch'
#include 'parmtype.ch'
/*/
===============================================================================================================================
Programa----------: RD06001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 19/06/2018
===============================================================================================================================
Descrição---------: Este programa serve para exportar um cadastro de cliente para fornecedor
===============================================================================================================================
Uso---------------: No pedido de vendas (faturamento)
===============================================================================================================================
Parametros--------: sem parametros
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
===============================================================================================================================
/*/
user function RD06001()
	
	Local aArea     	:= GetArea()
	Local aAreaSA1  	:= SA1->(GetArea())
	Local aAreaSA2  	:= SA2->(GetArea())
	Local aValues		:= {}
    Local cCgcCad		:= ""
    Local cCodFor		:= ""
    Local cLojaFor		:= ""
    Local cCodPa		:= ""
	Local lAchou		:= .F.
	Local nOpc			:= 3
	Local _cTipo	    := ""
	Local _cGRPTRIB	    := ""
	Local cEndFor       := ""
	Local aCpos  		:= {"A2_NOME","A2_NREDUZ"}
	Local _cTpessoa 	:= ""
	local cDDD			:= ""
	local cTelefone		:= ""
	
	Private aRotAuto 	:= Nil
	Private lMsErroAuto := .F.
	Private A1_CODMARC
	Private A1_OBS


	DbSelectarea("SA2")
	SA2->(DbSetorder(3))
	
	If SA2->(DbSeek(xFilial("SA2") + SA1->A1_CGC))
		Aviso("Aviso",	"Fornecedor " + ALLTRIM(SA1->A1_NOME) + " CNPJ/CPF: " + SA1->A1_CGC + CRLF +;
						"Já estão cadastrado como fornecedor!" + CRLF +;
						"Código / Loja: " + SA2->A2_COD + " / " + SA2->A2_LOJA + CRLF, {"OK"},3)
		Return
	EndIf

	If SA1->A1_TPESSOA = "EP"
		_cTpessoa := "OS"
	Else
		_cTpessoa := SA1->A1_TPESSOA
	EndIf
	
	if empty(SA1->A1_DDD)
		if empty(SA1->A1_XDDD)
			cDDD	:= '9'
		else
			cDDD	:= SA1->A1_XDDD
		endif
	else
		cDDD	:= SA1->A1_DDD
	end
		
	if empty(SA1->A1_TEL)
		if empty(SA1->A1_XCEL)
			cTelefone	:= '9'
		else
			cTelefone	:= SA1->A1_XCEL
		endif
	else
		cTelefone	:= SA1->A1_TEL
	end
		
	

	aValues	:= {	{"A2_LOJA"		,cLojaFor  , Nil},;
		{"A2_NOME"		,UPPER(SA1->A1_NOME)   , Nil},;
		{"A2_NREDUZ"	,UPPER(SA1->A1_NREDUZ) , Nil},;
		{"A2_TIPO"  	,SA1->A1_PESSOA		   , Nil},;
		{"A2_CGC"		,SA1->A1_CGC		   , Nil},;
		{"A2_END"   	,SA1->A1_END           , Nil},;
		{"A2_EST"   	,UPPER(SA1->A1_EST)    , Nil},;
		{"A2_COD_MUN"	,SA1->A1_COD_MUN	   , Nil},;
		{"A2_MUN"   	,UPPER(SA1->A1_MUN)    , Nil},;
		{"A2_INSCR"		,SA1->A1_INSCR	       , Nil},;
		{"A2_CEP"		,SA1->A1_CEP		   , Nil},;
		{"A2_DDD"		,cDDD			   	   , Nil},;
		{"A2_TEL"		,cTelefone	     	   , Nil},;
		{"A2_BAIRRO"	,UPPER(SA1->A1_BAIRRO) , Nil},;
		{"A2_FAX"		,SA1->A1_FAX		   , Nil},;
		{"A2_CONTATO"	,UPPER(SA1->A1_CONTATO), Nil},;
		{"A2_COMPLEM"	,UPPER(SA1->A1_COMPLEM), Nil},;
		{"A2_EMAIL"		,SA1->A1_EMAIL		   , Nil},;
		{"A2_TPESSOA"	,_cTpessoa         	   , Nil},;
		{"A2_PAIS"		,ALLTRIM("105")		   , Nil},;
		{"A2_CLIENTE"	,SA1->A1_COD		   , Nil},;
		{"A2_LOJCLI"	,SA1->A1_LOJA		   , Nil}}

	If Aviso("Aviso","Confirma Importação do Cliente para o cadastro de Fornecedores?" + CRLF + CRLF +;
					 "Favor verificar os campos que devem ser preenchidos após a importação.",{"Sim","N?"}) == 2
		Return
	EndIf

	MSExecAuto({|x,y| MATA020(x,y)}, aValues, 3)
	If lMsErroAuto
		RollBackSX8()
		MostraErro()
	Else
		ConfirmSX8()
		If MsgYesNo("Deseja abrir tela de Cadastro?")
			AxAltera("SA2", SA2->(Recno()) ,3)
		EndIf
		MsgInfo("Fornecedor " +cCodFor+ " loja " +cLojaFor+ " importado com sucesso!","TOTVS")
		//RecLock("SA1",.F.)
		//	SA1->A1_XIMPFOR := "S"
		//MsUnlock()
	EndIf		
			
	RestArea(aArea)
	SA1->(RestArea(aAreaSA1))
	SA2->(RestArea(aAreaSA2))

return