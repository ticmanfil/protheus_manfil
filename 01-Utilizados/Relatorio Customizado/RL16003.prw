#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'colors.ch'
#include 'rptdef.ch'
#include 'fwprintsetup.ch'
#include 'topconn.ch'
#include 'prtopdef.ch'

/*/
===============================================================================================================================
Programa----------: RL16003
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 20/01/2020
===============================================================================================================================
Descrição---------: Este programa serve para imprimir as FOLHA INDIVIDUAL DE PONTO AVULSO
===============================================================================================================================
Uso---------------: CONTROLE DE PONTO
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAPON
===============================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor	|	Data	|										Motivo																
------------:-----------:-----------------------------------------------------------------------------------------------------------:
			|			|																											
=====================================================================================================================================
/*/
user function RL16003()

	private	cPerg 			:= "RL16003",;
			_cLogo 			:= GetSrvProfString("StartPath","")+"lgrl01.bmp",; // ou "StartPath", "" valor caso nao encontre no AppServer.ini
			oPrinter,;
			cNomePDF		:= 'FIndPonto',;
			lRodapeImpresso	:= .F.,;
			_cAlias			:= ""

	private	dDtIni	:= '',;
			dDtFin	:= ''

			//variaveis de controle dos box's'
	private	_nLinBox 		:= 005,;
			_nLinAnt 		:= 000,;
			_nColIni 		:= 002,;
			_nColFim		:= 560,;
			_nEspacador 	:= 008,;
			_nEspacol		:= 040,;
			_nFator			:= 2665 / _nColFim
			
	private	nConsNeg		:= 0.4,; // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
			nConsTex		:= 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.

			//Fontes
	private	oFontTit,;
			oFontRod,;
			oFont05,;
			oFont05N,;
			oFont07,; 
			oFont07N,; 
			oFont10,;	
			oFont10N,;
			oFont14N,;
			oFont14,;
			oFont12,;
			oFont12N,;
			oFontA16N
			
	private	oBrush			:= TBrush():New( , CLR_GRAY)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializacao do objeto grafico                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lPreview := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do objeto.                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	private	_plAdjustToLegacy 	:= .F.,;
			cPathInServer 		:= GetTempPath(),; //"C:\TEMP\" // define local padrao para gerar arquivo 
			lDisabeSetup 		:= .T. 		// .t. desabilita a tela de configuração de impressao

	/*
	private	dDtIni	:= stod(substr(getMv('MV_PONMES'),1,8)),;
			dDtFin	:= stod(substr(getMv('MV_PONMES'),10,8))
	*/

	AjustaSX1(cPerg)

	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	if Pergunte(cPerg,.T.)
	
		dDtIni	:= stod(mv_par02+'01')
		dDtFin	:= LastDate(dDtIni)

		oPrinter	:= FWMSPrinter():New(cNomePDF+"_" + DtoS(Date())+ "_"+StrTran(Time(),':','-'), IMP_SPOOL, _plAdjustToLegacy,cPathInServer,lDisabeSetup,.F., ,"Microsoft Print to PDF")  
		oPrinter:SetDevice(IMP_PDF) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF
	
		oPrinter:SetDevice(IMP_SPOOL) //IMP_SPOOL=IMPRESSORA, IMP_PDF=PDF
		oPrinter:SetPortrait() // Formato Retrato
		oPrinter:SetPaperSize(9) // Papel A4
		oPrinter:SetMargin(60,60,60,60) // Margem
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao das fontes.                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oFontTit	:= TFontEx():New(oPrinter,"courier new",,020,,.T.,,,,,.F.,.F.)
		oFontRod	:= TFontEx():New(oPrinter,"courier new",,015,,.F.,,,,,.F.,.F.)
		oFont05		:= TFontEx():New(oPrinter,"courier new",05,05,.F.,.T.,.F.) // 6
		oFont05N	:= TFontEx():New(oPrinter,"courier new",05,05,.T.,.T.,.F.) // 6
		oFont07		:= TFontEx():New(oPrinter,"courier new",07,07,.F.,.T.,.F.) 
		oFont07N	:= TFontEx():New(oPrinter,"courier new",07,07,.T.,.T.,.F.) 
		oFont10		:= TFontEx():New(oPrinter,"courier new",10,10,.F.,.T.,.F.)
		oFont10N	:= TFontEx():New(oPrinter,"courier new",10,10,.T.,.T.,.F.)
		oFont12		:= TFontEx():New(oPrinter,"courier new",12,12,.F.,.T.,.F.)
		oFont12N	:= TFontEx():New(oPrinter,"courier new",12,12,.T.,.T.,.F.)
		oFont14		:= TFontEx():New(oPrinter,"courier new",14,14,.F.,.T.,.F.)
		oFont14N	:= TFontEx():New(oPrinter,"courier new",14,14,.T.,.T.,.F.)
		oFontA16N	:= TFontEx():New(oPrinter,"courier new",16,16,.T.,.T.,.F.)
	
		oPrinter:SetFont(oFont12N:oFont) // Fonte Padrao para calculo do objeto de impressao
	
		Processa({|| PrintRel(mv_par01) },"Gerando Folha Individual de Ponto...","")
	endif

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
static function PrintRel(cCusto)

	incProc("Gerando Folha Individual de Ponto Avulsom")

	ImpCabec()
	
	ImpItens()

	oPrinter:Preview()
	
	if oPrinter # Nil
		FreeObj(oPrinter)
	endIf
	oPrinter := Nil

Return

static function ImpCabec()

	local	_cTexto		:= '',;
			_nLinBoxBkp	:= 0
	
	_nLinBox := 005

	oPrinter:StartPage()
	
	//Titulo
	_cTexto	:= 'FOLHA INDIVIDUAL DE PONTO'
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,2,0)
	oPrinter:Line(_nLinBox+(_nEspacador*2),_nColIni,_nLinBox+(_nEspacador*2),_nColFim)
	oPrinter:Line(_nLinBox+(_nEspacador*2)+002,_nColIni,_nLinBox+(_nEspacador*2)+002,_nColFim)
	
	_nLinBox	+= _nEspacador*3
	_cTexto	:= 'PORTARIA 3.626/91'
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,2,0)
	oPrinter:Line(_nLinBox+(_nEspacador*2),_nColIni,_nLinBox+(_nEspacador*2),_nColFim)
	oPrinter:Line(_nLinBox+(_nEspacador*2)+002,_nColIni,_nLinBox+(_nEspacador*2)+002,_nColFim)

	_nLinBox	+= _nEspacador*2
	_cTexto	:= 'Funcionário  : '
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,0,0)
	//oPrinter:SayAlign(_nLinBox,_nColIni+089,alltrim(TB1->RA_MAT)+' - '+alltrim(TB1->RA_NOMECMP),oFont10:oFont,_nColFim,,,0,0)
	
	//IMPRIMIR DADOS DA EMPRESA
	_nLinBoxBkp	:= _nLinBox
	FImpEmp()
	_nLinBox	:= _nLinBoxBkp

	_nLinBox	+= _nEspacador*2
	_cTexto	:= 'Cargo        : '
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,0,0)
	//oPrinter:SayAlign(_nLinBox,_nColIni+089,alltrim(TB1->RA_CODFUNC)+' - '+alltrim(TB1->RJ_DESC),oFont10:oFont,_nColFim,,,0,0)

	_nLinBox	+= _nEspacador*2
	_cTexto	:= 'Data Admissão: '
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,0,0)
	//oPrinter:SayAlign(_nLinBox,_nColIni+089,alltrim(TB1->RA_ADMISSA),oFont10:oFont,_nColFim,,,0,0)

	_cTexto	:= 'Matrícula: '
	oPrinter:SayAlign(_nLinBox,_nColIni+200,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,0,0)
	//oPrinter:SayAlign(_nLinBox,_nColIni+260,alltrim(TB1->RA_MAT),oFont10:oFont,_nColFim,,,0,0)

	_nLinBox	+= _nEspacador*2
	_cTexto	:= 'Horário      : '
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,0,0)
	//oPrinter:SayAlign(_nLinBox,_nColIni+089,alltrim(TB1->RA_TNOTRAB)+' - '+alltrim(TB1->R6_DESC),oFont10:oFont,_nColFim,,,0,0)

	_nLinBox	+= _nEspacador*2
	_cTexto	:= 'Período      : '
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,0,0)
	//oPrinter:SayAlign(_nLinBox,_nColIni+090,dtoc(dDtIni)+' - '+dtoc(dDtFin),oFont10:oFont,_nColFim,,,0,0)

	_nLinBox	+= _nEspacador*2
	_cTexto	:= 'Departamento : '
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,0,0)
	//oPrinter:SayAlign(_nLinBox,_nColIni+089,alltrim(TB1->RA_DEPTO)+' - '+alltrim(TB1->QB_DESCRIC),oFont10:oFont,_nColFim,,,0,0)

	_nLinBox	+= _nEspacador*2
	_cTexto	:= 'Centro Custo : '
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,0,0)
	//oPrinter:SayAlign(_nLinBox,_nColIni+089,alltrim(TB1->RA_CC)+' - '+alltrim(TB1->CTT_DESC01),oFont10:oFont,_nColFim,,,0,0)

	//linha final
	_nLinBox	+= _nEspacador*2
	oPrinter:Line(_nLinBox,_nColIni,_nLinBox,_nColFim)
	oPrinter:Line(_nLinBox+002,_nColIni,_nLinBox+002,_nColFim)

return


static function ImpItens()

	local	_nLinBoxBkp	:= 0

	//desenha a tabela
	_nLinBoxBkp	:= _nLinBox
	FDesTab()

	//Imprir os textos
	_nLinBox	:= _nLinBoxBkp
	FImpTxt()
	
	//Imprimir rodape
	FImpRod()

return

static function FDesTab()

	local	_nX			:= 0

	//TABELA
	//1º linha
	_nLinBox	+= _nEspacador*3
	oPrinter:Line(_nLinBox,_nColIni,_nLinBox,_nColFim)															//LINHA SUPERIOR
	oPrinter:Line(_nLinBox,_nColIni,_nLinBox+(_nEspacador*2),_nColIni)											//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*02),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*02))				//COLUNAS LATERAIS
//	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*03.5),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*03.5))			//COLUNAS LATERAIS
//	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*05.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*05.0))			//COLUNAS LATERAIS
//	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*06.5),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*06.5))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*08.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*08.0))			//COLUNAS LATERAIS
//	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*09.5),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*09.5))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*11.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*11.0))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColFim,_nLinBox+(_nEspacador*2),_nColFim)											//COLUNAS LATERAIS
	_nLinBox	+= _nEspacador*2
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*02),_nLinBox,_nColIni+(_nEspaCol*11.0))							//LINHA INFERIOR
	
	//2º linha
	oPrinter:Line(_nLinBox,_nColIni,_nLinBox+(_nEspacador*2),_nColIni)											//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*02.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*02.0))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*03.5),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*03.5))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*05.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*05.0))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*06.5),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*06.5))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*08.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*08.0))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*09.5),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*09.5))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*11.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*11.0))			//COLUNAS LATERAIS
	oPrinter:Line(_nLinBox,_nColFim,_nLinBox+(_nEspacador*2),_nColFim)											//COLUNAS LATERAIS
	_nLinBox	+= _nEspacador*2
	oPrinter:Line(_nLinBox,_nColIni,_nLinBox,_nColFim)															//LINHA INFERIOR
	
	//a partir da 3º linha
	for _nX	:= 1 to 31
		oPrinter:Line(_nLinBox,_nColIni,_nLinBox+(_nEspacador*2),_nColIni)										//COLUNAS LATERAIS
		oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*02.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*02.0))		//COLUNAS LATERAIS
		oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*03.5),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*03.5))		//COLUNAS LATERAIS
		oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*05.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*05.0))		//COLUNAS LATERAIS
		oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*06.5),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*06.5))		//COLUNAS LATERAIS
		oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*08.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*08.0))		//COLUNAS LATERAIS
		oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*09.5),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*09.5))		//COLUNAS LATERAIS
		oPrinter:Line(_nLinBox,_nColIni+(_nEspaCol*11.0),_nLinBox+(_nEspacador*2),_nColIni+(_nEspaCol*11.0))		//COLUNAS LATERAIS
		oPrinter:Line(_nLinBox,_nColFim,_nLinBox+(_nEspacador*2),_nColFim)										//COLUNAS LATERAIS
		_nLinBox	+= _nEspacador*2
		oPrinter:Line(_nLinBox,_nColIni,_nLinBox,_nColFim)														//LINHA INFERIOR
	next _nX

return

static function FImpTxt()

	local 	_cTexto		:= '',;
			aDias		:= {},;
			dDiaAtu		:= stod('  /  /    '),;
			nX			:= 0

	//TEXTO
	//1º linha
	_nLinBox	+= _nEspacador*3
	_cTexto	:= 'DIA'
	oPrinter:SayAlign(_nLinBox+(_nEspacador/2),_nColIni,alltrim(_cTexto),oFont10N:oFont,_nColIni+(_nEspaCol*02.0),,,2,0)
	_cTexto	:= 'INTERVALO'
	oPrinter:SayAlign(_nLinBox,_nColIni+040,alltrim(_cTexto),oFont10N:oFont,_nColIni+(_nEspaCol*08.0),,,2,0)
	_cTexto	:= 'HORA EXTRA'
	oPrinter:SayAlign(_nLinBox,_nColIni+160,alltrim(_cTexto),oFont10N:oFont,_nColIni+(_nEspaCol*11.0),,,2,0)
	_cTexto	:= 'ASSINATURA'
	oPrinter:SayAlign(_nLinBox+(_nEspacador/2),_nColIni+220,alltrim(_cTexto),oFont10N:oFont,_nColFim,,,2,0)
	
	//2º linha - esta mesclada com a 1º linha
	_nLinBox	+= _nEspacador*2
	_cTexto	:= 'ENTRADA'
	oPrinter:SayAlign(_nLinBox,_nColIni+090,alltrim(_cTexto),oFont10:oFont,_nColIni+150,,,0,0)
	_cTexto	:= 'SAIDA'
	oPrinter:SayAlign(_nLinBox,_nColIni+150,alltrim(_cTexto),oFont10:oFont,_nColIni+210,,,0,0)
	_cTexto	:= 'ENTRADA'
	oPrinter:SayAlign(_nLinBox,_nColIni+210,alltrim(_cTexto),oFont10:oFont,_nColIni+270,,,0,0)
	_cTexto	:= 'SAIDA'
	oPrinter:SayAlign(_nLinBox,_nColIni+270,alltrim(_cTexto),oFont10:oFont,_nColIni+330,,,0,0)
	_cTexto	:= 'ENTRADA'
	oPrinter:SayAlign(_nLinBox,_nColIni+330,alltrim(_cTexto),oFont10:oFont,_nColIni+390,,,0,0)
	_cTexto	:= 'SAIDA'
	oPrinter:SayAlign(_nLinBox,_nColIni+390,alltrim(_cTexto),oFont10:oFont,_nColIni+450,,,0,0)

	//apartir da 3º linha
	aDias	:= {}
	dDiaAtu	:= dDtIni
	while dDiaAtu <= dDtFin
	
		//if dDiaAtu >= stod(TB1->R8_DATAINI) .and. dDiaAtu <= stod(TB1->R8_DATAFIM)
		//	aadd(aDias,{day(dDiaAtu),dDiaAtu,diasemana(dDiaAtu),'FERIAS'})
		//else
			aadd(aDias,{day(dDiaAtu),dDiaAtu,diasemana(dDiaAtu),''})
		//end
		dDiaAtu	:= daysum(dDiaAtu,1)
		
	enddo
	
	_nLinBox	+= _nEspacador*1
	for nX := 1 to len(aDias)
		_cTexto		:= strzero(aDias[nX][1],2)+' - '+aDias[nX][3]
		oPrinter:SayAlign(_nLinBox+(_nEspacador/2),_nColIni+1,alltrim(_cTexto),oFont07:oFont,_nColIni+(_nEspaCol*02.0)-1,,,0,0)
	
		_cTexto		:= aDias[nX][4]
		oPrinter:SayAlign(_nLinBox+(_nEspacador/2),_nColIni+090,alltrim(_cTexto),oFont10:oFont,_nColIni+150+(_nEspaCol*02.0)-1,,,0,0)
		oPrinter:SayAlign(_nLinBox+(_nEspacador/2),_nColIni+150,alltrim(_cTexto),oFont10:oFont,_nColIni+210+(_nEspaCol*02.0)-1,,,0,0)
		oPrinter:SayAlign(_nLinBox+(_nEspacador/2),_nColIni+210,alltrim(_cTexto),oFont10:oFont,_nColIni+270+(_nEspaCol*02.0)-1,,,0,0)
		oPrinter:SayAlign(_nLinBox+(_nEspacador/2),_nColIni+270,alltrim(_cTexto),oFont10:oFont,_nColIni+330+(_nEspaCol*02.0)-1,,,0,0)
		oPrinter:SayAlign(_nLinBox+(_nEspacador/2),_nColIni+330,alltrim(_cTexto),oFont10:oFont,_nColIni+390+(_nEspaCol*02.0)-1,,,0,0)
		oPrinter:SayAlign(_nLinBox+(_nEspacador/2),_nColIni+390,alltrim(_cTexto),oFont10:oFont,_nColIni+450+(_nEspaCol*02.0)-1,,,0,0)

		_nLinBox	+= _nEspacador*2		
	next nX
	
return

static function FImpRod()

	local	_cTexto	:= ''
	
	_nLinBox	+= _nEspacador*3
	_cTexto	:= 'De conformidade com a Portaria MTB 3.626 de 13/11/1991 art. 13, este cartão substitui, para todos os efeitos legais, o quadro de horário de trabalho, inclusive o de menores.'
	oPrinter:SayAlign(_nLinBox,_nColIni,alltrim(_cTexto),oFont07N:oFont,_nColFim,,,2,0)

	_nLinBox	+= _nEspacador*4
	oPrinter:Line(_nLinBox,_nColIni,_nLinBox,_nColFim)
	
return

static function FImpEmp()
	
	local 	_cTexto		:= ''
	

	OpenSm0()
	dbSelectArea('SM0')
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(cEmpAnt+cFilAnt))
	
//	_cTexto	:= transform(alltrim(SM0->M0_CGC),"@! 99.999.999.9999/99")
	_cTexto	:= alltrim(SM0->M0_CGC)
	oPrinter:SayAlign(_nLinBox,250,alltrim(_cTexto),oFont07N:oFont,350,,,2,0)

	_nLinBox	+= _nEspacador
	_cTexto	:= alltrim(SM0->M0_NOMECOM)
	oPrinter:SayAlign(_nLinBox,250,alltrim(_cTexto),oFont07N:oFont,350,,,2,0)

	_nLinBox	+= _nEspacador
	_cTexto	:= alltrim(SM0->M0_ENDENT)
	oPrinter:SayAlign(_nLinBox,250,alltrim(_cTexto),oFont07N:oFont,350,,,2,0)

	_nLinBox	+= _nEspacador
	_cTexto	:= alltrim(SM0->M0_BAIRENT)+' - '+alltrim(SM0->M0_CEPENT)
	oPrinter:SayAlign(_nLinBox,250,alltrim(_cTexto),oFont07N:oFont,350,,,2,0)

	_nLinBox	+= _nEspacador
	_cTexto	:= alltrim(SM0->M0_CIDENT)+' - '+alltrim(SM0->M0_ESTENT)
	oPrinter:SayAlign(_nLinBox,250,alltrim(_cTexto),oFont07N:oFont,350,,,2,0)
	
	SM0->(dbCloseArea())

return

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	U_XPUTSX1(cPerg,"01","Centro Custo ?" ,"Centro Custo?"     ,"Centro Custo?"       ,"mv_ch1","C",06,0,0,"G","","CTT","","","mv_par01","","","","","","","","","","","","","","","","")

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '01'						, 											  ;
				/*cPergunt	*/ 'Centro Custo'			, /*cPerSpa		*/ 'Centro Custo ?'			, /*cPerEng		*/ 'Centro Custo ?'		    , ;
				/*cVar		*/ 'mv_ch1'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 6						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ 'CTT'					, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par01'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

	u_xPutSx1(	/*cGrupo	*/ cPerg					, /*cOrdem		*/ '02'						, 											  ;
				/*cPergunt	*/ 'Periodo'				, /*cPerSpa		*/ 'Periodo'				, /*cPerEng		*/ 'Periodo'		    	, ;
				/*cVar		*/ 'mv_ch2'					, /*cTipo 		*/ 'C'						, 											  ;
				/*nTamanho	*/ 6						, /*nDecimal	*/ 0						, /*nPresel		*/ 0						, ;
				/*cGSC		*/ 'C'						, /*cValid		*/ ''						, /*cF3			*/ ''						, ;
				/*cGrpSxg	*/ ''						, /*cPyme		*/ ''						, /*cVar01		*/ 'mv_par02'				, ;
				/*cDef01	*/ ''						, /*cDefSpa1	*/ ''						, /*cDefEng1	*/ ''						, ;
				/*cCnt01	*/ ''						, 																						  ; 
				/*cDef02	*/ ''						, /*cDefSpa2	*/ ''						, /*cDefEng2	*/ ''						, ; 
				/*cDef03	*/ ''						, /*cDefSpa3	*/ ''						, /*cDefEng3	*/ ''						, ; 
				/*cDef04	*/ ''						, /*cDefSpa4	*/ ''						, /*cDefEng4	*/ ''						, ; 
				/*cDef05	*/ ''						, /*cDefSpa5	*/ ''						, /*cDefEng5	*/ ''						, ; 
				/*aHelpPor	*/ ''						, /*aHelpEng	*/ ''						, /*aHelpSpa	*/ ''						, ;
				/*cHelp		*/) 

return
