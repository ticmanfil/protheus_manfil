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
#include 'tbiconn.ch'
#include 'colors.ch'
#include 'rptdef.ch'
#include 'fwprintsetup.ch'
#include 'topconn.ch'
#include 'rwmake.ch' 
#include 'report.ch'
#include 'prtopdef.ch'


/*/
===============================================================================================================================
Programa----------: ORCFAT
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 10/08/2018
===============================================================================================================================
Descrição---------: Este programa serve para imprimir o orcamento padrao MANFIL
===============================================================================================================================
Uso---------------: Orcamento do Pedido de Venda (faturamento)
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
===============================================================================================================================
/*/
user function ORCFAT()

	local	xSeek	as caractere,;
			aGroups	as array,;
			aPerson	as array,;
			pImp	as caractere,;
			pTitulo	as caractere
	
	Private cPerg 			:= "ORCFAT"
	Private _cLogo			:= GetSrvProfString("StartPath","")+"lgrl01.bmp" // ou "StartPath", "" valor caso nao encontre no AppServer.ini
	Private oPrinter
	Private cNomePDF		:= 'Orcamento'
	Private lRodapeImpresso := .F.
	Private _cAlias			:= ""
	Private _nModelo		:= 0

	Private _nLinBox 		:= 5
	Private _nLinAnt 		:= 0	
		
	Private _nColIni := 001
	Private _nColFim := 560
	Private _nEspacador := 8

	Private _nFator    := 2665 / _nColFim
		
	Private nConsNeg := 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
		
	Private nConsTex := 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.

	//Fontes
	PRIVATE oFontTit
	PRIVATE oFontRod
	PRIVATE oFont07
	PRIVATE oFont08
	PRIVATE oFont10
	PRIVATE oFont10N
	PRIVATE oFont14N
	PRIVATE oFont14
	PRIVATE oFont12
	PRIVATE oFont12N
	PRIVATE oFontA16N

	PRIVATE oBrush   := TBrush():New( , CLR_GRAY)

	//RpcSetEnv( '01', '0101' )   //############################# A P A G A R

	Private _aArea := SCJ->(GetArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao do objeto grafico                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lPreview := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do objeto.                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomePDF := cNomePDF+"_"+SCJ->CJ_NUM

	Private _plAdjustToLegacy := .F.
	Private cPathInServer := GetTempPath() 
	Private lDisabeSetup := .T. 		// .t. desabilita a tela de configuração de impressao

	private lVlUnit

	pImp:= ''
	pTitulo:= 'Imprimindo Orçamento'

	cPathInServer:= getmv('MV_XTEMP')

	if SCJ->CJ_STATUS == 'C' .or. SCJ->CJ_STATUS == 'D'
		u_msgInforma('Esse orçamento não pode ser impresso. Status CANCELADO ou COM ERRO.','[M415COPIA]')
		RETURN
	endif

	xSeek   := __cUserID
	aGroups := FWSFUsrGrps(xSeek)

	AjustaSX1(cPerg)

	if Pergunte(cPerg,.T.)
		if mv_par01 = 1
			lVlUnit	:= 'S'
		else
			lVlUnit	:= 'N'
		endif

		if mv_par01 = 3
			if aScan(aGroups, {|x| allTrim(Upper(x)) $ "000000|000027|000030"}) > 0 //administrador, supervisor financeiro e comercial 1 (coordenadores comercial)
				aPerson:= pDados()
			endif
		endif
	else
		return
	endif

	oPrinter := FWMSPrinter():New(cNomePDF+"_" + DtoS(Date())+ "_"+StrTran(Time(),':','-'), IMP_PDF, _plAdjustToLegacy,cPathInServer,lDisabeSetups)  
	oPrinter:SetDevice(IMP_PDF) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF
	oPrinter:SetPortrait() // Formato Retrato
	oPrinter:SetPaperSize(9) // Papel A4
	oPrinter:SetMargin(60,100,60,60) // Margem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao das fontes.                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFontTit	:= TFontEx():New(oPrinter,"Courier New",,020,,.T.,,,,,.F.,.F.)
	oFontRod	:= TFontEx():New(oPrinter,"Courier New",,015,,.F.,,,,,.F.,.F.)
	oFont07		:= TFontEx():New(oPrinter,"Courier New",07,07,.F.,.T.,.F.) // 6
	oFont08		:= TFontEx():New(oPrinter,"Courier New",08,08,.F.,.T.,.F.)
	oFont08N	:= TFontEx():New(oPrinter,"Courier New",08,08,.T.,.T.,.F.)
	oFont10		:= TFontEx():New(oPrinter,"Courier New",10,10,.F.,.T.,.F.)
	oFont10N	:= TFontEx():New(oPrinter,"Courier New",10,10,.T.,.T.,.F.)
	oFont14N	:= TFontEx():New(oPrinter,"Courier New",13,13,.T.,.T.,.F.)
	oFont14		:= TFontEx():New(oPrinter,"Courier New",13,13,.F.,.T.,.F.)
	oFont12		:= TFontEx():New(oPrinter,"Courier New",12,12,.F.,.T.,.F.)
	oFont12N	:= TFontEx():New(oPrinter,"Courier New",12,12,.T.,.T.,.F.)
	oFontA16N	:= TFontEx():New(oPrinter,"Courier New",15,15,.T.,.T.,.F.)

	oPrinter:SetFont(oFont12N:oFont) // Fonte Padrao para calculo do objeto de impressao

	oFTitulos := oFont07
	oFDados := oFont12N

	Processa({|| PrintRel(aPerson) },"Aguarde a abertura do relatorio...","Gerando arquivo PDF ...")

	restArea(_aArea)

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintRel  ºAutor  ³Guilherme França    º Data ³  23/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressao do relatorio.                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintRel(aPerson)

Local _nVia := 1

MontaTRB()

IncProc("Gerando relatorio "+Alltrim(SCJ->CJ_NUM))

ImpCabec(_nVia)

ImpItens(_nVia,aPerson)

ImpRodape(_nVia)

If lPreview
	oPrinter:Preview()
EndIf

If oPrinter # Nil
	FreeObj(oPrinter)
EndIf
oPrinter := Nil

Return


static function Query()

	local cQuery	:= ''
	
	cQuery	:= 'exec PR_ORCFAT @FILIAL	= "'+xFilial('SCK')+'", @NUM = "'+SCJ->CJ_NUM+'"'

return cQuery

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaTRB  ºAutor  ³Microsiga           º Data ³  08/02/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Seleciona registros do ticket a ser impresso.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaTRB()

	local cQuery := query()
		
	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	if select('TRB') <> 0
		dbSelectArea('TRB')
		TRB->(dbCloseArea())
	endif
	
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS 'TRB'
	
	dbSelectArea('TRB')
	TRB->(dbGoTop())
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCabec  ºAutor  ³Microsiga           º Data ³  02/08/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCabec(xnVia)

	//Dados da Empresa
	Local _cLogo := GetSrvProfString("StartPath","")+"lgrl01.bmp"

	_nLinBox := 020

	oPrinter:StartPage()

	//DADOS DA EMPRESA
	oPrinter:SayBitMap(_nLinBox, 001, _cLogo, 100, 50) 
	oPrinter:SayAlign(_nLinBox+050 ,100, "ORÇAMENTO"					,oFontA16N:oFont ,_nColFim,,,2,1)
	oPrinter:SayAlign(_nLinBox+066 ,100, Alltrim(SCJ->CJ_NUM)			,oFontA16N:oFont ,_nColFim,,,2,1)
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	oPrinter:Say(_nLinBox, _nColIni, Alltrim(SM0->M0_NOMECOM), oFont10N:oFont)
	//oPrinter:Say(_nLinBox, _nColIni+350, "ORÇAMENTO", oFontA16N:oFont)
	_nLinBox += _nEspacador
	oPrinter:Say(_nLinBox, _nColIni, Alltrim(SM0->M0_ENDCOB)+" - "+Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+"-"+Alltrim(SM0->M0_ESTCOB), oFont08:oFont)
	_nLinBox += _nEspacador
	oPrinter:Say(_nLinBox, _nColIni, "CNPJ:            "+Transform(Alltrim(SM0->M0_CGC),"@r 99.999.999/9999-99"), oFont08:oFont)
	_nLinBox += _nEspacador
	oPrinter:Say(_nLinBox, _nColIni, "Insc. Estadual:  "+Transform(Alltrim(SM0->M0_INSC),"@r 999.999999-9999"), oFont08:oFont)
	_nLinBox += _nEspacador
	oPrinter:Say(_nLinBox, _nColIni, "Insc. Municipal: "+Alltrim(SM0->M0_INSCM), oFont08:oFont)
	_nLinBox += _nEspacador
	oPrinter:Say(_nLinBox, _nColIni, "Telefone:        "+Alltrim(SM0->M0_TEL), oFont08:oFont)
	_nLinBox += _nEspacadori
	oPrinter:Line(_nLinBox, _nColIni, _nLinBox, _nColFim)
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador

	//DADOS DO CLIENTE
	oPrinter:Say(_nLinBox, _nColIni, "Núm. Orçamento: "+Alltrim(SCJ->CJ_NUM), oFont10N:oFont)
	_nLinBox += _nEspacador

	oPrinter:Say(_nLinBox, _nColIni, "Data:           "+Alltrim(TRB->EMISSAO), oFont10:oFont)
	_nLinBox += _nEspacador

	oPrinter:Say(_nLinBox, _nColIni, "Validade:       "+Alltrim(TRB->VALIDA), oFont10:oFont)
	_nLinBox += _nEspacador
	
	oPrinter:Say(_nLinBox, _nColIni, "Vendedor:       "+Alltrim(SCJ->CJ_XNOMVEN), oFont10:oFont)
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	oPrinter:Say(_nLinBox, _nColIni, "Cliente:    "+Alltrim(SCJ->CJ_XNOMCLI), oFont14N:oFont)
	_nLinBox += _nEspacador
	oPrinter:Line(_nLinBox, _nColIni, _nLinBox, _nColFim)
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpItens()  ºAutor  ³Microsiga         º Data ³  13/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpItens(xnVia,aPerson)

	Local _nTBruto		:= 0
	Local _nTDesc		:= 0
	Local _nTLiq		:= 0
	Local _nDesc		:= 0
	local _nFrete		:= 0
	local _nJrs			:= 0
	local _nVlAcresc	:= 0.00


	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	oPrinter:Line(_nLinBox, _nColIni+60, _nLinBox, _nColFim-050)
	oPrinter:SayAlign(_nLinBox ,065, "CÓDIGO"					,oFont08N:oFont ,040,,,0,0) //,ALIGN_LEFT ,1)
	oPrinter:SayAlign(_nLinBox ,100, "QUANT."					,oFont08N:oFont ,100,,,2,0)
	oPrinter:SayAlign(_nLinBox ,201, "UNID."					,oFont08N:oFont ,025,,,2,0)
	oPrinter:SayAlign(_nLinBox ,226, "PRODUTOS"					,oFont08N:oFont ,210,,,0,0)
	if alltrim(lVlUnit) == 'S'
		oPrinter:SayAlign(_nLinBox ,396, "VALOR"				,oFont08N:oFont ,100,,,1,1)
	endif
	_nLinBox += _nEspacador+4
	oPrinter:Line(_nLinBox, _nColIni+60, _nLinBox, _nColFim-050)


	// IMPRIME LINHAS DE PRODUTOS
	dbSelectArea('TRB')
	TRB->(dbGoTop())
	_nFrete	:= TRB->FRETE 
	_nJrs	:= TRB->JRS
	While !TRB->(Eof())
	
		_nLinBox += _nEspacador
		oPrinter:SayAlign(_nLinBox ,065, ALLTRIM(TRB->PROD)											,oFont08:oFont ,040,,,0,1)
		oPrinter:SayAlign(_nLinBox ,100, TransForm(TRB->QTD,"@E 999,999,999.99")					,oFont08:oFont ,100,,,1,1)
		oPrinter:SayAlign(_nLinBox ,201, ALLTRIM(TRB->UM)											,oFont08:oFont ,025,,,0,1)
		oPrinter:SayAlign(_nLinBox ,226, SUBSTR(TRB->DESCRICAO,1,55) 								,oFont08:oFont ,210,,,0,1)
		if alltrim(lVlUnit) == 'S'
		oPrinter:SayAlign(_nLinBox ,396, TransForm(TRB->QTD * TRB->VLRUNITBRUTO,"@E 999,999,999.99"),oFont08:oFont ,100,,,1,1)
		//oPrinter:SayAlign(_nLinBox ,396, TransForm(TRB->VLRTOT,"@E 999,999,999.99"),oFont08:oFont ,100,,,1,1)
		endif
		
		
		_nLinBox += _nEspacador+2
		oPrinter:Line(_nLinBox, _nColIni+60, _nLinBox, _nColFim-050)
		
		_nTBruto += TRB->QTD * TRB->VLRUNITBRUTO
		if TRB->DESCONTO >= 0
			_nTDesc += TRB->DESCONTO
		ENDIF
		_nTLiq += TRB->VLRTOT
		_nDesc	:= TRB->CABDESCONTO

		TRB->(DbSkip())
	EndDo
	
	if empty(aPerson)
		_nTDesc	+= _nDesc
		_nTLiq	-= _nDesc
		_nTLiq	+= _nFrete
		_nVlAcresc	:= _nTLiq*_nJrs
		_nTLiq	:= _nTLiq+_nVlAcresc
	else
		_nTBruto	:= aPerson[1]
		_nTDesc		:= aPerson[2]
		_nFrete		:= aPerson[3]
		_nVlAcresc	:= aPerson[4]
		_nTLiq		:= aPerson[5]
	endif

	// IMPRIME SUB TOTAIS
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox ,200, "Sub Total -> " + TransForm(_nTBruto,"@E 999,999,999.99")	,oFont08N:oFont ,300,,,1,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox ,200, "Desconto -> " + TransForm(_nTDesc,"@E 999,999,999.99")	,oFont08N:oFont ,300,,,1,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox ,200, "Frete -> " + TransForm(_nFrete,"@E 999,999,999.99")		,oFont08N:oFont ,300,,,1,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox ,200, "Acréscimo -> " + TransForm(_nVlAcresc,"@E 999,999,999.99")		,oFont08N:oFont ,300,,,1,1)
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	oPrinter:Line(_nLinBox, _nColIni+200, _nLinBox, _nColFim-050)
	oPrinter:SayAlign(_nLinBox ,200, "Total -> " + TransForm(_nTLiq,"@E 999,999,999.99")		,oFont08N:oFont ,300,,,1,1)
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	oPrinter:Line(_nLinBox, _nColIni+200, _nLinBox, _nColFim-050)
	
Return

Static Function ImpRodape(xnVia)

	Local cObs	:= SCJ->CJ_XOBS
	Local nXi	:= 0
	Local BnLinBox	:= 0

	// IMPRIME CONSIDERAÇÕES FINAIS
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	oPrinter:Line(_nLinBox, _nColIni, _nLinBox, _nColFim)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni, "Condição de Pagamento: " + SCJ->CJ_XDESCON	,oFont10N:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni, "Prazo de Entrega: A combinar."		,oFont10N:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni, "Observação: "						,oFont10N:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	For nXi := 1 To MLCount(cObs,070)
	     If ! Empty(MLCount(cObs,070))
	          If ! Empty(MemoLine(cObs,070,nXi))
					oPrinter:SayAlign(_nLinBox , _nColIni, OemToAnsi(MemoLine(cObs,070,nXi))	,oFont10:oFont ,_nColFim,,,0,1)
					_nLinBox += _nEspacador                                          
	          EndIf
	     EndIf
	Next nXi
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Não aceitamos devoluções de mercadorias sob medida",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Venda sujeito a confirmação de estoque",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Preços válidos até "+cvaltochar(GETMV("MV_XVALORC"))+' dias',oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Vendas faturadas a prazo somente após aprovação do cadastro",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Faturamento será efetuado somente após aquisição da ordem de compra.",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Vendas sem aprovação do cadastro somente com PAGAMENTO ANTECIPADO",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Para clientes fora do estado de MINAS GERAIS que não são CONTRIBUINTES DE ICMS, haverá cobrança da diferença",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "  de imposto entre estados (DIFAL) em cima do preço de cada produto",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* FRETE INCLUSO PARA COMPRAS ACIMA R$ 500,00.",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* AJUDANTE DE DESCARGA sob RESPONSABILIDADE do CLIENTE",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni, "DOCUMENTOS NECESSÁRIOS PARA FAZERMOS CADASTRO",oFont10N:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni, "PESSOA JURÍDICA",oFont10N:oFont ,_nColFim,,,0,1)
	BnLinBox:= _nLinBox
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Cópia do contrato social",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Cópia da última alteração contratual",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Cópia do cartão do CNPJ",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Cópia da inscrição estadual",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Último balanço da empresa",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* 03 informações comerciais com telefone",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3, "* Telefone e e-mail's para envio de Nota Fiscas",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	_nLinBox := BnLinBox
	oPrinter:SayAlign(_nLinBox , _nColIni+300, "PESSOA FÍSICA",oFont10N:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3+300, "* Xerox RG e CPF frente e verso",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3+300, "* Xerox comprovante de residência",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3+300, "* Xerox comprovante de rendimento",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3+300, "* 03 Informações comerciais com telefone",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador
	oPrinter:SayAlign(_nLinBox , _nColIni+3+300, "* Telefone e e-mail's para envio de Nota Fiscas",oFont10:oFont ,_nColFim,,,0,1)
	_nLinBox += _nEspacador

return

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Imprimir Vl Unit. ?" ,"Imprimir Vl Unit.?"     ,"Imprimir Vl Unit.?"       ,"mv_ch1","C",01,0,0,"G","","","","","mv_par01","Sim","Sim","Sim","","Não","Não","Não","Outros","Outros","Outros","","","","","","")
			
return

static function pDados()
	local	aDados		as array

	private	nSubTotal	as numeric,;
			nDesconto	as numeric,;
			nFrete		as numeric,;
			nAcrescimo	as numeric,;
			nTotal		as numeric

	private oDlg	as object

	aDados		:= {}
	nSubTotal	:= 0
	nDesconto	:= 0
	nFrete		:= 0
	nAcrescimo	:= 0
	nTotal		:= 0

	SetPrvt('oDlg1','oSay1','oSay2','oSay3','oSay4','oSay5','oSay6','oSBtnOk','oSBtnCan','oMGet1')
	
	DEFINE MSDIALOG oDlg TITLE '[ORCFAT]-Dados Adicionais' From 0,0 TO 250,530 PIXEL
	
	@ 010,004 say OemToansi('SubTotal:') size 052, 008 OF oDlg PIXEL
	@ 010,160 msget oGet01 var nSubTotal size 052,008 when .T. picture '@E 9,999,999.99' valid pValida() OF oDlg PIXEL

	@ 025,004 say OemToAnsi('Desconto:') size 073,008 OF oDlg PIXEL
	@ 025,160 msget oGet02 var nDesconto size 052,008 when .T.  picture '@E 9,999,999.99' valid pValida() OF oDlg PIXEL
	
	@ 040,004 say OemToAnsi('Frete:') size 073,008 OF oDlg PIXEL
	@ 040,160 msget oGet03 var nFrete size 052,008 when .T.  picture '@E 9,999,999.99' valid pValida() OF oDlg PIXEL

	@ 055,004 SAY OemToAnsi('Acrerscimo:') SIZE 073,008 OF oDlg PIXEL
	@ 055,160 msget oGet04 VAR nAcrescimo SIZE 052,008 when .T. picture '@E 9,999,999.99' valid pValida() OF oDlg PIXEL
	
	@ 070,004 SAY OemToAnsi('Total:') SIZE 073,008 OF oDlg PIXEL
	@ 070,160 msget oGet05 VAR nTotal SIZE 052,008 when .F. picture '@E 9,999,999.99' OF oDlg PIXEL

	DEFINE SBUTTON FROM 100, 206 When .T. TYPE 1 ACTION (oDlg:End(),nOpca:='1') ENABLE OF oDlg
	DEFINE SBUTTON FROM 100, 234 When .T. TYPE 2 ACTION (oDlg:End(),nOpca:='2') ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED	

	aadd(aDados,nSubTotal)
	aadd(aDados,nDesconto)
	aadd(aDados,nFrete)
	aadd(aDados,nAcrescimo)
	aadd(aDados,nTotal)

return aDados

static function pValida()

	nTotal:= nSubTotal-nDesconto+nFrete+nAcrescimo

return .T.
