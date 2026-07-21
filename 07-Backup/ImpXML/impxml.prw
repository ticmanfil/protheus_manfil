#include "TOTVS.CH"
#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "Xmlxfun.ch"
//#INCLUDE "bitmap.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "shell.ch"
#INCLUDE "APWEBSRV.CH"

/*
Tipos possíveis na nota fiscal de entrada:
N = NF Normal          
D = Devolução
I = NF Compl. ICMS
P = NF Compl. IPI
B = NF Beneficiamento
C = Compl. Preço
*/

/*
Histórico de Releases de versão 2.2 de 27/08/2014
	1. Nesta versão é possível dar duplo clique no cabeçalho (parte superior) e trocar o tipo da nota que somente era possível identificar com base na lista
	   de CFOPs informado no parâmetro corresponde na tela de configuração da rotina.
	   Isso permite a busca correta do código e loja que era indevido quando usava o parâmetro geral com CFOPs de Devolução e chegam notas de complemento
	   de imposto com o mesmo CFOP (notas complementares utilizam o mesmo CFOP da nota original)
	2. Foi realizado adequações para reconhecer algumas alterações da versão 3.10 da Nfe onde a TAG dEmi foi alterado para dhEmi pela SEFAZ
	3. Realizado ajustes para mover arquivos XML de notas fiscais de entrada (tpNF=0) que foram emitidos por empresas do grupo (sigamat) e usando formulário próprio
	4. Foi alterado a prioridade de busca do código do produto buscando internamente na base de dados quando estiver recebendo XML de uma filial da empresa corrente
	   onde o cadastro de produtos seja compartilhado entre filiais.
	5. Ajuste na quantidade por embalagem, para quando no campo B1_QE esteja zerado, considerar 1 para considerar Unitário e então pegar a quantidade que estiver no XML
Histórico de Releases de versão 2.3 de 12/09/2014
	6. Implementação de novo parâmetro para permitir filtrar tipos de produtos quando determinar de forma fixa o armazém para saldos de produtos
	7. Implementação de novo parâmetro para escolher armazém para devolução
	8. Permitir recusar arquivo XML sem enviar e-mail (move o XML para pasta recusados)
	9. Ajustes para usar RetSQLName() nas querys e não fixar filial com 2 dígitos deixando a rotina preparada para quando implementar o conceito de unidadde de negócios
	   (filial com 6 dígitos)
Histórico de Releases de versão 2.4 de 27/10/2014
	1. Verificação / checagem do índice 3 na tabela SA7, caso não exista, emite mensagem solicitando ao TI criar o mesmo;
	2. Ajustes na manipulação de pastas por empresa/filial corrigindo o problema que criava pastas xml1, xml12, xml123, etc. passando agora ter uma única pasta xml
	   e dentro desta uma pasta para cada empresa+filial;
	3. O sistema tenta criar a pasta xml no ROOTPATH se não conseguir, tentará criar xml1, xml2, etc. e esta pasta criada fica armazenada no parâmetro MV_XPASTXM e
	   por padrão no raiz desta pasta serão armazenados os XMLs para importação, exceto, se configurar um específico para cada empresa/filial dentro dos parâmetros
	   da rotina;
	4. Criação do parâmetro MV_XIGPCPN para manipular o conteúdo do parâmetro MV_PCNFE através do PE MT140PC e assim, permitir importar notas de transferência sem 
	   informar o pedido de compras na rotina de pré-nota quando o parâmetro MV_PCNFE estiver habilitado.
Histórico de Releases de versão 2.5 de 17/11/2014
	1. Ajustado tamanho da variável filial nas buscas dos parâmetros customizados da rotina quando a empresa utiliza filial de 6 dígitos, pois estava fixo "  " e
	   não localizava os parâmetros MV_ da rotina corretamente.
	2. Validar se o usuário logado tem acesso a opção 6 (alterar pedidos de compras) dos acessos no módulo configurador para permitir ou não alterar/incluir pedidos
	   de compras diretamente pela rotina de importação de XML.
	3. Troca da espécie padrão de NF para SPED
	4. Troca do texto/título da janela de falta de estoque para falta de pedido de compras.
	5. Não exibir pergunta se deseja conectar ao servidor de e-mails caso não tenha sido configurado a conta de e-mail nos parâmetros da rotina.
	6. Alterações na validação do pedido de compras onde foi adicionada uma nova opção na combo relativo a configuração do pedido de compras que antes tinha somente
	   duas opções (sim ou não), agora existe uma terceira opção Sim(-transf.) que indica que vai obrigar o pedido de compras somente quando não se tratar de notas onde
	   tanto o emitente do xml quanto o destinatário estejam cadastrados no sigamat.emp, com isso, se escolher esta nova opção a rotina não vai exigir pedido de compras
	   para notas de transferência.
Histórico de Releases de versão 2.51 de 04/12/2014
	1. Adequações necessárias para funcionamento da consulta posição fornecedor através do botão histórico após últimas atualizações da Totvs (RPO)
	2. Adequação no botão reativar produto para testar se o usuário tem permissão para alterar cadastro de produto e impedir erro se não tiver nenhum produto selecionado
	3. Adequado para a variável que considera o tamanho da filial para no lugar de LEN(SM0->M0_CODFIL) para FWSizeFilial()
	4. Foi realizado alterações no trecho SEM a tag NFEPROC que também precisa checar a versão 3.10 da Nfe onde a TAG dEmi foi alterado para dhEmi pela SEFAZ
	   alteração foi necessária pois alguns sistemas estão enviando dois modelos de XML para uma mesma nota, sendo um com a TAG NFEPROC e outro sem esta TAG
	5. Alteração para atualizar a variável cNota antes da chamada da função RECUSAR() pois mostrava o número da nota repetido e trocava apenas o nome do arquivo
Histórico de Releases de versão 2.52 de 20/03/2015
	1. Ajuste na variável _cCorrente colocando AllTrim() para retirar os espaços, pois a mesma é utilizada para criar as pastas
	2. Ajustes e testes/validações da utilização de contas de e-mail no Gmail.
	3. Acrescentado checagem VerSenha(6) //-- Evento 6 - Alteração de pedido de compras no duplo clique da seleção do pedido para não deixar eliminar resíduo do 
	   pedido de compras e nem alterar quantidades quando o usuário não tiver permissão para alterar pedido de compras.
Histórico de Releases de versão 2.6 de 09/04/2015
	1. Substituição do nome da tabela que estava concatenando M0_CODIGO em comandos de atualização da SC7 e SD1 por RetSQLName() para compatibilizar com gestão de empresas.
	2. Comentando/retirado bloco de código onde poderia permitir ao usuário trocar a loja e a filial do pedido sem atualizar dados da SB2 na static function PRENOTA() 
	   através da atualização do pedido de compras via TCSQLEXEC().
	3. Novo botão na tela aberta após duplo clique no item para permitir duplicar item do XML para permitir associar mais de um pedido de compras por item da nota.
Histórico de Releases de versão 2.61 de 16/04/2015
	1. Adicionado novo parâmetro para controle da quantidade de dígitos (colocando zero a esquerda) no campo série.
	2. Correção no posicionamento do controle/zeramento da variável nDescont para dentro do laço For/Next dos itens do XML, pois estava, fora e isso fazia com o desconto
	   do item anterior era replicado para os demais itens.
Histórico de Releases de versão 2.62 de 14/05/2015
	1. Alguns XMLs podem chegar sem a TAG IE do destinatário e estava causando error log ao selecionar o XML na parte superior da rotina. Foi colocado um tratamento para
	   avisar ao usuário que o XML está com a IE diferente da inscrição do cadastro da empresa em uso no momento (SM0->M0_INSC) permitindo recusar, visualizar ou dar OK no
	   aviso e então importar mesmo sem esta informação no XML.
Histórico de Releases de versão 2.63 de 18/08/2015 
	1. Correção no tratamento do parâmetro MV_PCNFE que estava duplicando pois ao usar o iif(SuperGetMV("MV_PCNFE",.F.,.F.) == .T.,".T.",".F.") a SX6 ficava desposicionada	   
*/

Static __nHdlPOP  := 0
Static oServerXML

#IFDEF WINDOWS
#ENDIF
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPXML    ºAutor  ³LS                  º Data ³  05/03/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Importacao do XML da nota fiscal eletrônica                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function IMPXML()
Local xi := 1 // Adicionado por Luiz em 05/04/2012 para gerenciar as pastas
local i	 := 0 
local _aXML	:={}
local _XML	:= {}

Private _xPstSalv:=""
Private xTextoCompleto := ""
Private xcCNPJ := ""
Private xKeyChave := ""
Private xcData := ""
Private cXml:= '',oXml
Private xlResp := .f. // Adicionado por Luiz em 24/05/2011 para tratar perguntas específicas
Private xnPercMaxDiverg := 0 // Adicionado por Luiz em 26/05/2011 para armazenar conteúdo do parâmetro customizado com valor máximo da variação de divergência entre Pedido de Compras x Nota fiscal de entrada
Private xnQtdItensTESDup := 0 // Adicionado por Luiz em 31/05/2011 para contar quantos itens gera duplicata
Private xEmailCC := "" // Adicionado por Luiz em 18/06/2011 para envio de cópia de email de recusa
Private xaPastas := {} // Adicionado por Luiz em 05/04/2012 para facilitar a gestão/implantação da rotina em outros ambientes/empresas (servidor diferente)
Private _xcBarraDir := IIF(!IsSrvUnix(),"\","/") //Adicinado em 17/08/13 para correto tratamento em servidor Linux (procurar por _xcBarraDir para saber onde foi alterado)
Private xcNPastaP := _xcBarraDir+"xml"  // Adicionado por Luiz em 05/04/2012 para facilitar a gestão/implantação da rotina em outros ambientes/empresas (servidor diferente)
Private xcNEmpresa := AllTrim(SM0->M0_NOME)
Private xaTam:={}
Private xcTipVer := "D" // "D" => Demo / "F"= Full   (usado apenas na exibição da mensagem todo o controle de funcionamento/bloqueio é baseado no arquivo txt)
Private cxAmbiente := "" // Adicionado por Luiz em 16/04/2012 para tratar se a nota veio em ambiente de homologação
Private xlRecusa := .f. // Adicionado por Luiz em 16/04/2012 para tratar se a nota veio em ambiente de homologação
//Declaração de variável para utilização nos tratamentos de picture
Private xSENHA := space(20)
Private _xPc7preco := X3Picture("C7_PRECO")
Private _xPd1vunit := X3Picture("D1_VUNIT")
Private _xPc7quant := X3Picture("C7_QUANT")
Private _xPd1quant := X3Picture("D1_QUANT")
Private _xPicb1qe  := X3Picture("B1_QE")
Private _xPicb1cod := X3Picture("B1_COD")    // Acrescentado em 21/08/2012 por Luiz
Private _xPica5prf := X3Picture("A5_CODPRF") // Acrescentado em 21/08/2012 por Luiz
Private _xcNomEmit := ""
Private _xnOpcAvis := 0
Private cNatOp := ""
Private cDecQtd:=2 //Adicionado por Luiz em 26/04/2012 a declaracao como private pois na utilizacao da CONFARQ() apresentava erro se nenhuma empresa tivesse autorizada no sigamat
Private cDecUni:=7
Private _cEmpresa:=SM0->M0_CODIGO
Private _cCorrente:=AllTrim(SM0->M0_CODFIL) //Adicionado Alltrim em 20/03/2015 para correto tratamento em empresas que utilizem gestão de empresas
Private _cxInscric:=SM0->M0_INSC
Private _cPastaXML := GetNewPar( "MV_XPASTXM", xcNPastaP)
Private _cx1UMPro := "" //Adicionado por Luiz em 07/07/2012
Private _cx2UMPro := "" //Adicionado por Luiz em 07/07/2012
Private _cxUMForn := "" //Adicionado por Luiz em 07/07/2012
Private _cxFatCon := "" //Adicionado por Luiz em 07/07/2012
Private _cxTipCon := "" //Adicionado por Luiz em 07/07/2012
Private bMostMsgCodBarras := .f. // Adicionado em 23/08/2012 para verificar duplicidade de códigos de barras
Private nContaCodBarras := 0 	// Adicionado em 23/08/2012 para verificar duplicidade de códigos de barras
Private cMensCodBarrasD := ""   // Adicionado em 23/08/2012 para verificar duplicidade de códigos de barras
Private cCodProAnterior := ""   // Adicionado em 28/08/2012 para melhorar verificação duplicidade de códigos de barras
Private cFile := "" // Adicionado em 23/08/2012
Private cxTipoNFXML := "" // Adicionado em 27/08/2012 para tratar XML de notas de devolução / Beneficiamento
Private _cCFOPsDEV:=space(300)
Private _cCFOPsBEN:=space(300)
Private _xVersaoXML := "" // Adicionado por Luiz em 18/08/2014 para contemplar alterações devido a versão do XML
Private cxDadosFornec := "" // Adicionado por Luiz em 27/08/2014 para contemplar alterações no tipo de importação de XML
Private cxInfCompl := "" // Adicionado por Luiz em 27/08/2014 para contemplar alterações no tipo de importação de XML
Private _cxtpNF := ""    // Adicionado por Luiz em 28/08/2014 para verificar o tipo de Nota (0=entrada 1=Saída)
Private axCNPJsm0 := {}  // Adicionado por Luiz em 28/08/2014 para contemplar tratamento do lote, sub-lote e data de validade
Private _cVersaoIMPXML := "Versão 2.63" //Adicionado por Luiz em 12/09/2014 para facilitar controle/exibição de versão
Private nxQtdDigEmp:=Len(SM0->M0_CODIGO) //Adicionado por Luiz em 29/10/2014 para permitir leitura correta de parâmetros em empresas com filial de 6 dígitos
Private nxQtdDigFil:=FWSizeFilial() //Adicionado por Luiz em 29/10/2014 para permitir leitura correta de parâmetros em empresas com filial de 6 dígitos
Private cxQtdDigFil := REPLICATE(" ",nxQtdDigFil) //Adicionado por Luiz em 17/11/2014 para ser utilizado nas buscas pelos parâmetros em empresa com filial de 6 dígitos
Private _xTCodEmp:=Len(SM0->M0_CODIGO)  //Estava local dentro da static function CONFARQ
Private _xTCodFil:=FWSizeFilial()  //Estava local dentro da static function CONFARQ
Private nxQtdDigF1SERIE := TamSX3("F1_SERIE")[1] //Adicionado em 16/04/2015
Private lx6mv_pcnfe := iif(SuperGetMV("MV_PCNFE",.F.,.F.) == .T.,".T.",".F.") //Adicionado em 18/08/2015

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fontes do windows usadas											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFont1 NAME "Arial Black" SIZE 6,17
DEFINE FONT oFont2 NAME "Courier New" SIZE 8,14
DEFINE FONT oFont3 NAME "Arial Black" SIZE 13,20
DEFINE FONT oFont4 NAME "Arial Black" SIZE 13,15
DEFINE FONT oFont5 NAME "Arial Black" SIZE 7,17
DEFINE FONT oFont6 NAME "Courier New" SIZE 6,20
DEFINE FONT oFont7 NAME "Courier New" SIZE 7,20

_cUsuario:=ALLTRIM(UPPER(SUBSTR(CUSUARIO,7,15)))
cArqTxt := xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir +"config"+_xcBarraDir+"cfgxml.txt"  //Adicionado +_cEmpresa+_cCorrente+_xcBarraDir por Luiz em 27/10/2014
l2Check2:=.F.
lCheck3:=.F.
lTLS:=.F.
lSSL:=.F.
lGmail:=.F.
lAceitaMasc:=.F. // Adicionado em 21/08/2012 para permitir aceitar máscara de formatação no código do produto no XML
nPortSMTP:=25
nPortPOP:=110
cNCM:=''
XEMAILREC:=""
lRefaz:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando parametro do programa										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX6")
DbSetorder(1)
DbgoTop()
//Dbseek(xFilial("SD1")+"MV_XPASTXM")
Dbseek(cxQtdDigFil+"MV_XPASTXM")  //Alterado por Luiz em 27/10/2014 para ficar com parâmetro compartilhado entre filiais
If !Found()
	
	// Se entrou aqui é porque não existia o parâmetro customizado e portanto se trata do primeiro acesso, deve-se validar se a pasta principal já é utilizada pela empresa. Se já existir vai criar uma com sequencial
	IF File(xcNPastaP) .and. !File(xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDirP+"config"+_xcBarraDir+"leiame_impxml.txt")
		msgbox("Já existe o diretório XML no ROOTPATH do servidor!. Pressione OK para iniciar pesquisa do nome de pasta disponível.", xcNEmpresa + ": IMPXML.PRW")
		MsgRun("Pesquisando nome de pasta disponível... "+alltrim(xcNPastaP),,{||xcNPastaP:=xBuscaPasta(xcNPastaP)})
	Endif

	Reclock("SX6",.T.)
	//SX6->X6_FIL:=xFilial("SD1")
	SX6->X6_FIL:=cxQtdDigFil //Alterado por Luiz em 27/10/2014 para ficar com parâmetro compartilhado entre filiais
	SX6->X6_VAR:="MV_XPASTXM"
	SX6->X6_TIPO:="C"
//	SX6->X6_CONTEUD:= xcNPastaP + _xcBarraDir +_cEmpresa+_cCorrente // variável contém o nome da Pasta padrão
	SX6->X6_CONTEUD:= xcNPastaP  // variável contém o nome da Pasta padrão // Alterado por Luiz em 27/10/2014 para compartilhar mesma pasta por sigamat.emp
	SX6->X6_DESCRIC:="Informe aqui iniciado por " + _xcBarraDir + " a pasta padrão da rotina IMPXML. Ex: " + _xcBarraDir +"xml"		
	MsUnlock()	
	
	msgbox("Primeiro acesso detectado! A pasta/diretório padrão da rotina IMPXML não existe para esta empresa/filial e será criada no ROOTPATH do servidor!. Pressione OK para criar/alterar a pasta " + xcNPastaP , xcNEmpresa + ": IMPXML.PRW")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criando pastas necessárias para funcionamento da rotina				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	IF MakePath(xcNPastaP)  // Se a pasta não existir com .T. a mesma será criada
		msgbox("A rotina IMPXML irá usar o diretório " + xcNPastaP + " no ROOTPATH do servidor!. Esta pasta será a pasta principal da rotina de importação de XML. Dentro dela " +;
		"será criada uma pasta para cada empresa+filial que utilizar esta rotina. Dentro da pasta de cada empresa/filial será criado as seguintes outras pastas " +;
		"também necessárias para funcionamento: config, importados, duplicados, recusadas e corrompidos. A pasta onde a rotina irá usar para salvar os XMLs recebidos "+;
		"por E-mail e onde estará lendo o XML. Esta pasta pode ser modificada pelo administrador na configuração da rotina para permitir usar uma mesma conta de e-mail " +;
		"para empresas diferentes onde os XMLs ainda não processados poderão ficar armazenados em uma única pasta a critério da empresa.", xcNEmpresa + ": IMPXML.PRW","INFO")
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"config")
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"importados")
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"duplicados")
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"recusadas")
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"corrompidos")

		For xi := 1 to len(xaPastas)
			MakePath(xaPastas[xi])
		Next
	Else
		msgbox("Foi encontrado um problema na criação de pastas necessárias para o funcionamento da rotina. Entre em contato com a equipe de TI para informar o problema!", xcNEmpresa + ": IMPXML.PRW")
		return
	EndIf
ElseIf File(GetNewPar( "MV_XPASTXM", xcNPastaP)) .AND. !File(xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"config")
	msgbox("Primeiro acesso detectado para esta empresa/filial! No entanto, já existe o diretório " + GetNewPar( "MV_XPASTXM", xcNPastaP) + " da rotina IMPXML no ROOTPATH do servidor para!. Pressione OK para criar um novo conjunto de pastas dentro da pasta " + xcNPastaP + " para esta empresa/filial.", xcNEmpresa + ": IMPXML.PRW")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criando pastas necessárias para funcionamento da rotina				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	IF MakePath(xcNPastaP)  // Se a pasta não existir com .T. a mesma será criada
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"config")
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"importados")
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"duplicados")
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"recusadas")
		aadd(xaPastas,xcNPastaP+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"corrompidos")

		For xi := 1 to len(xaPastas)
			MakePath(xaPastas[xi])
		Next
	Else
		msgbox("Foi encontrado um problema na criação de pastas necessárias para o funcionamento da rotina. Entre em contato com a equipe de TI para informar o problema!", xcNEmpresa + ": IMPXML.PRW")
		return
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando parametro do programa para cotrole de pedido de compras		³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX6")
DbSetorder(1)
DbgoTop()
Dbseek(cxQtdDigFil+"MV_XIGPCPN")  //Alterado por Luiz em 27/10/2014 para ficar com parâmetro compartilhado entre filiais
If !Found()
	Reclock("SX6",.T.)
	SX6->X6_FIL:=cxQtdDigFil //Alterado por Luiz em 27/10/2014 para ficar com parâmetro compartilhado entre filiais
	SX6->X6_VAR:="MV_XIGPCPN"
	SX6->X6_TIPO:="L"
	SX6->X6_CONTEUD:= lx6mv_pcnfe
	SX6->X6_DESCRIC:="Informe .F. para ignorar o MV_PCNFE na rotina de pré-nota"		
	MsUnlock()	
Endif

//Adicionado em 12/04/2012 para armazenar pasta/arquivo padrao
//xcNPastaP := Alltrim(GETMV("MV_XPASTXM")) //Comentado em 23/08/2012 como melhoria para utilização de compartilhamento de pastas entre filiais/empresas (substituido pela linha a seguir)
xcNPastaP := Alltrim(GETMV("MV_XPASTXM")+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir) //Adicionado +_cEmpresa+_cCorrente+_xcBarraDir por Luiz em 27/10/2014 
cArqTxt := xcNPastaP + "config"+_xcBarraDir+"cfgxml.txt"

DbSelectArea("SX6")
DbSetorder(1)
DbgoTop()
Dbseek(xFilial("SD1")+"MV_XGRVPED")
If !Found()
	Reclock("SX6",.T.)
	SX6->X6_FIL:=xFilial("SD1")
	SX6->X6_VAR:="MV_XGRVPED"
	SX6->X6_TIPO:="C"
	SX6->X6_DESCRIC:="Controle de gravacao pedidos de compras"
	MsUnlock()	
Endif

// Inicio novo parâmetro adicionado por Luiz em 26/05/2011 para Criar parâmetro que trata o percentual de diferença entre pedido de compras x nota fiscal de entrada
DbSelectArea("SX6")
DbSetorder(1)
DbgoTop()
Dbseek(cxQtdDigFil+"MV_XPERCDI")
If !Found()
	Reclock("SX6",.T.)
	SX6->X6_FIL:=cxQtdDigFil
	SX6->X6_VAR:="MV_XPERCDI"
	SX6->X6_TIPO:="N"
	SX6->X6_CONTEUD:= "0.15"  // Este valor representa o percentual (já em %). Ficou acordado na reunião semanal de TI que o percentual inicial (DEFAULT) para validar a variação máxima seria de 0,1% para permitir pequenas variações normalmente de arredondamento
	SX6->X6_DESCRIC:="% Max. Diverg. NF Entrada x Ped. Compras"
	MsUnlock()
Endif


xnPercMaxDiverg := GETMV("MV_XPERCDI") // Pega o percentual atual de variação permitido

// Final novo parâmetro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se o usuario ficou preco na ultima gravacao do pedido	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_lGrava:=ALLTRIM(UPPER(Getmv("MV_XGRVPED")))
If _lGrava==_cUsuario
	DbSelectArea("SX6")
	DbgoTop()
	While ! eof()
		If Alltrim(SX6->X6_VAR)=="MV_XGRVPED" .and. SX6->X6_FIL==xFilial("SC7")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD:=""
			MsUnlock()
		Endif
		DbSkip()
	End
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Manipulando arquivo de configuracao									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

_xPstSalv:=substr(xcNPastaP,1,len(xcNPastaP)-1) //Adicionado em 26/04/2012 para tratar compartilhamento de pasta entre empresas  // em 27/10/2014 Alterado mais acima no código de forma que xcNPastaP já contenha código da empresa+filial -> retirado barra do final
xLerKey() // Adicionado em 26/04/2012 para ler a chave que será usada para montagem da tela de configuração

If !File(cArqTxt) .OR. _cUsuario=="ADMINISTRADOR"
	CONFARQ()
	xLerKey() // Adicionado em 23/08/2012 para ler novamente a chave e a pasta do XML
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtros de XML														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cResp:=msgbox("Deseja realizar um filtro nos arquivos agora?","Atenção...","YESNO")

If cResp
	cPerg:="IMPXML"
	VALIDPERG(cPerg)
	Pergunte(cPerg,.t.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filial e empresa atual												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("SM0")
Dbsetorder(1)
Dbgotop()
Dbseek(_cEmpresa+_cCorrente)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lendo o arquivo de configuracao										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Adicionado em 12/04/2012 para armazenar pasta/arquivo padrao
cArqTxt := _xPstSalv +_xcBarraDir+ "config" +_xcBarraDir + "cfgxml.txt"
cBuffer := ""

IF !File(_xPstSalv)
	msgbox("O parâmetro MV_XPASTXM já existe no ambiente, mas a pasta " + _xPstSalv + " não existe no diretório principal da rotina!!! Informe esta inconsistência ao TI.", "Verificar pasta de XML no ROOTPATH - IMPXML.PRW")
	Return
Endif
IF !File(_xPstSalv+_xcBarraDir+"config")
	msgbox("Não existe o diretório CONFIG no diretório " + _xPstSalv)
	Return
Endif
IF !File(_xPstSalv+_xcBarraDir+"importados")
	msgbox("Não existe o diretório IMPORTADOS no diretório " + _xPstSalv)
	Return
Endif
IF !File(_xPstSalv+_xcBarraDir+"duplicados")
	msgbox("Não existe o diretório DUPLICADOS no diretório " + _xPstSalv)
	Return
Endif
IF !File(_xPstSalv+_xcBarraDir+"recusadas")
	msgbox("Não existe o diretório RECUSADAS no diretório " + _xPstSalv)
	Return
Endif
IF !File(_xPstSalv+_xcBarraDir+"corrompidos")
	msgbox("Não existe o diretório CORROMPIDOS no diretório " + _xPstSalv)
	Return
Endif


if xKeyChave != Substr(AllTrim(SM0->M0_CGC),1,8)
	if Empty(xKeyChave)
	    Msgbox("Empresa/filial não autorizada! Verifique se o arquivo " + _xPstSalv+_xcBarraDir+"config"+_xcBarraDir+"leiame_impxml.txt" + " existe. ","Atenção...","STOP")
	Else
	    Msgbox("Empresa/filial não autorizada! Esta chave de instalação vale apenas para empresas/filiais em que a raiz do CNPJ (8 primeiros dígitos) seja igual a: " +;
    	xKeyChave + ". Verifique se o arquivo " + _xPstSalv+_xcBarraDir+"config"+_xcBarraDir+"leiame_impxml.txt" + " é o arquivo correto para esta empresa/filial. ","Atenção...","STOP")    	
	EndIf
	Return
EndIf

If StoD(xcData) - dDataBase < 0
	Msgbox("Licença de uso expirada em " + dtoc(stod(xcData)) +" Verifique a integridade do arquivo "+_xcBarraDir+"config"+_xcBarraDir+"leiame_impxml.txt e/ou "+ iif(xcTipVer=="D","efetive a compra para continuar usando esta rotina após a data informada.","solicite nova liberação.") ,"Atenção...","STOP")
	Return
elseif StoD(xcData) - dDataBase <= 3
	Msgbox("A Licença de uso vai expirar em " + AllTrim(str(StoD(xcData) - dDataBase)) + " dia(s) (" +  dtoc(stod(xcData)) +"). " + iif(xcTipVer=="D","Efetive a compra para continuar usando esta rotina após a data informada.","Solicite nova liberação.") ,"Atenção...","ALERT")
EndIf

cSerie:=''
cEspecie:=''
cAlmox:=Space(02)
cAlmoxDEV:=Space(02)
cTiposSaldo:='' //Adicionado por Luiz em 08/09/2014
cUnidades:=''
cPedCom:=.F.
cIgnoraPCTransf:=.F.
cNDF:=.F.
cAlmoPed:=space(02)
_cURL:=space(500)
cZeros:=.F.
cZeroSerie:='' //Adicionado em 16/04/2015
cZerosP:=.F.
cDecUni:=7
cDecQtd:=2

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisando configuracoes da rotina									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File(cArqTxt)
	FT_FUSE(cArqTxt)
	FT_FGOTOP()
	ProcRegua(FT_FLASTREC())
	
	While !FT_FEOF()
		cBuffer := FT_FREADLN()
		
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+5))=="EMAIL"+SM0->M0_CODIGO+SM0->M0_CODFIL
			xEMAILREC:=lower(ALLTRIM(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+7,400)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+5))=="PASTA"+SM0->M0_CODIGO+SM0->M0_CODFIL
			_cPastaXML:=ALLTRIM(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+7,60))
		Endif		
		If UPPER(SUBSTR(cBuffer,1,3))=="POP"
			xPOP:=lower(ALLTRIM(SUBSTR(cBuffer,5,400)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,5))=="CONTA"
			xCONTA:=lower(ALLTRIM(SUBSTR(cBuffer,7,400)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,5))=="SENHA"
			xSENHA:=iif(empty(SUBSTR(cBuffer,7,400)),space(20),xEnCode(ALLTRIM(SUBSTR(cBuffer,7,400)),"SENHAPOP3",.f.))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil))==SM0->M0_CODIGO+SM0->M0_CODFIL
			cSerie:=UPPER(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+2,3))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+3))=="ESP"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cEspecie:=UPPER(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+5,5))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+6))=="DECQTD"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cDecQtd:=UPPER(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+8,2))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+6))=="DECUNI"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cDecUni:=UPPER(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+8,2))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+1))=="S"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cAlmox:=UPPER(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+3,2))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+2))=="SD"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cAlmoxDEV:=UPPER(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+4,2))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+6))=="STIPOS"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cTiposSaldo:=UPPER(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+8,18))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+6))=="SQTDZE"+SM0->M0_CODIGO+SM0->M0_CODFIL //Adicionado em 16/04/2015
			cZeroSerie:=UPPER(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+8,1))
		Endif
		If UPPER(SUBSTR(cBuffer,1,2))=="UM"
			cUnidades:=ALLTRIM(UPPER(SUBSTR(cBuffer,4,400)))
		Endif
//		If UPPER(SUBSTR(cBuffer,1,4))=="LOGO"  //Retirado logos em 11/04/2012 por Luiz para já apresentar as informações complementares
//			cLogo:=ALLTRIM(UPPER(SUBSTR(cBuffer,6,200)))+space(200)
//		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+1))=="P"+SM0->M0_CODIGO+SM0->M0_CODFIL
			cAlmoPed:=ALLTRIM(UPPER(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+3,2)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,10))=="PEDIDO=SIM"
			cPedCom:=.T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,10))=="PEDIDO=-TR"
			cPedCom:=.T.
			cIgnoraPCTransf:=.T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,3))=="NDF"
			cNDF:=.T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,11))=="NFZEROS=SIM"
			cZeros:=.T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,11))=="NFZEROS=PER"
			cZerosP:=.T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,11))=="PEDPROD=SIM"
			l2Check2:=.T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,3))=="URL"
			_cURL:=ALLTRIM(UPPER(SUBSTR(cBuffer,5,500)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,15))=="MANTEREMAIL=SIM"
			lCheck3:=.T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,10))=="USATLS=SIM"
			lTLS:=.T.
		Endif		
		If UPPER(SUBSTR(cBuffer,1,10))=="USASSL=SIM"
			lSSL:=.T.
		Endif		
		If UPPER(SUBSTR(cBuffer,1,9))=="PORTASMTP"
			nPortSMTP:=lower(ALLTRIM(SUBSTR(cBuffer,10,400)))
		Endif		
		If UPPER(SUBSTR(cBuffer,1,8))=="PORTAPOP"
			nPortPOP:=lower(ALLTRIM(SUBSTR(cBuffer,9,400)))
		Endif
		If UPPER(SUBSTR(cBuffer,1,12))=="USAGMAIL=SIM"
			lGmail:=.T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,12))=="USAPICTU=SIM"
			lAceitaMasc:=.T.
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+7))=="CFOPDEV"+SM0->M0_CODIGO+SM0->M0_CODFIL //Adicionado em 27/08/2012 para tratar CFOPs devolucao
			_cCFOPsDEV:=ALLTRIM(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+9,300))
		Endif
		If UPPER(SUBSTR(cBuffer,1,nxQtdDigEmp+nxQtdDigFil+7))=="CFOPBEN"+SM0->M0_CODIGO+SM0->M0_CODFIL //Adicionado em 27/08/2012 para tratar CFOPs Beneficiamento
			_cCFOPsBEN:=ALLTRIM(SUBSTR(cBuffer,nxQtdDigEmp+nxQtdDigFil+9,300))
		Endif
		FT_FSKIP()
	EndDo
	FT_FUSE()
Else
	Msgbox("Arquivo de configuracao CFGXML.TXT não encontrado no diretório " + _xPstSalv +_xcBarraDir+"CONFIG")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de numeracao do numero da nota fiscal						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cZerosP
	cResp:=msgbox("Numeração da Nota Fiscal com 9 Dígitos?","Atenção...","YESNO")
	
	If cResp
		cZeros:=.T.
	Endif
Endif

If Type("cZeroSerie") == "C"
	If Empty(cZeroSerie)
		cZeroSerie := 0
	Else
		cZeroSerie := Val(cZeroSerie)
	EndIF
EndIF

cSerieNF:=Alltrim(cSerie)

If Empty(cUnidades)
	Msgbox("Favor informar as Unidades de medidas fracionadas!")
	Return
Endif

//------------------------------------------------
//Verifica existencia do indice 3 do SA7 - A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI, R_E_C_N_O_, D_E_L_E_T_
//------------------------------------------------
If !xChecaInd() //Adicionado por Luiz em 27/10/2014 para checagem do índice 3 na tabela SA7
	Msgbox("Não foi encontrado o índice 3 (A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_CODCLI) na tabela SA7 (Amarração Produto x Cliente) necessário " +;
	"para correto funcionamento em notas tipo D (devolução) e/ou B (beneficiamento). Entre em contato com a área de TI e informe a falta do índice! " +;
	"Após a criação do índice, tente acessar esta rotina novamente.")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebendo emails dos fornecedores									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(xCONTA)
	xlResp := msgbox("Conectar ao servidor de E-mail?","Atenção...","YESNO") 	// Adicionado por Luiz em 24/05/2011
	if xlResp 	// Adicionado por Luiz em 24/05/2011
		IF lGmail
			MsgRun("Importando XML do E-mail usando Gmail "+alltrim(xCONTA),,{||RECEMAIL(lTLS, lSSL)})	// nova função que usa tmailmanager()
		Else
			MsgRun("Importando XML do E-mail " + alltrim(xCONTA) + iif(lTLS .and. lSSL," usando TLS e SSL",iif(lSSL," usando SSL",iif(lTLS," usando TLS",""))),,{||POPEMAIL(lTLS, lSSL)})
	//		MsgRun("Importando XML do E-mail "+alltrim(xCONTA),,{||bPOPEMAIL()})  //Esta chama a primeira versão (backup)
		EndIf
	Endif	// Adicionado por Luiz em 24/05/2011
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apagando arquivos diferentes de XML									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
a_XML:={}

//lsfm comentado tmp xcNPastaP:=iif(Alltrim(_cPastaXML) != "",Alltrim(_cPastaXML)+_xcBarraDir,xcNPastaP) //Adicionado em 26/04/2012 para tratar compartilhamento de pasta entre empresas

//ADir(xcNPastaP+_xcBarraDir+"*.*",aXML) //Comentado em 17/08/13 para usar a nova funcao Directory a qual possui parametro para nao mudar nome do arquivo o que causa problemas no Linux por ser case sensitive
a_XML:=Directory(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.*", "", Nil, .F.)
	
For i:=1 to len(_aXML)
	If !"XML" $ UPPER(ALLTRIM(_aXML[i,1]))
		//ferase(xcNPastaP+_xcBarraDir+lower(ALLTRIM(aXML[i])))  //Comentado em 17/08/13 para nao usar lower() devido alteracao de adir() para directory()
		ferase(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(aXML[i,1]))
	Else
		//_cFileOri:=xcNPastaP+_xcBarraDir+lower(ALLTRIM(aXML[i])) //Comentado em 17/08/13 para nao usar lower() devido alteracao de adir() para directory()
		_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(aXML[i,1])
		FRenameEx(_cFileOri,lower(_cFileOri))
		//FRename(_cFileOri,lower(_cFileOri))
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resolucao da tela													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
IF aSize[5] >=1220
	_nTop:=760
	_nRight:=1225
	_nSize:=590
Else
	@ 120,040 TO 750,1010 DIALOG oTela TITLE "Importação nota fiscal eletrônica - "+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL+"-"+SM0->M0_FILIAL
	_nTop:=750
	_nRight:=1010
	_nSize:=485
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista dos XML dos fornecedores										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aXML:={}
//ADir(xcNPastaP+_xcBarraDir+"*.xml",aXML)//Comentado em 17/08/13 para usar a nova funcao Directory a qual possui parametro para nao mudar nome do arquivo o que causa problemas no Linux por ser case sensitive
_aXML:=Directory(_cPastaXML + iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.xml", "", Nil, .F.)


If Len(_aXml)==0
	Msgbox("Não existem arquivos para serem importados no momento...","Atenção...","INFO")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto alterados													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
xaTam:=TamSX3("B1_COD")
aCampos5:= {{"PRODUTO","C",xaTam[1],0}} //Alterado em 10/04/2012 por Luiz os tamanhos fixos dos campos em todas as tabelas temporárias para pegar o SX3 usando array xaTam usando TamSX3() (para ver as alterações basta procurar o texto xaTam e/ou TamSX3)

cArqTrab5  := CriaTrab(aCampos5)
dbUseArea( .T.,, cArqTrab5, "LS5", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS5",cArqTrab5,"PRODUTO",,,)
dbSetIndex( cArqTrab5 +OrdBagExt())
dbSelectArea("LS5")

cDecUni:=val(cDecUni)
cDecQtd:=val(cDecQtd)

aCampos	:= {{"SEQ","N",5,0 },;
{"OK","C",1,0 },;
{"CODBAR","C",TamSX3("B1_CODBAR")[1],0},;
{"PRODUTO","C",TamSX3("B1_COD")[1],0},;
{"PRODFOR","C",TamSX3("A5_CODPRF")[1],0},;
{"DESCRICAO","C",TamSX3("B1_DESC")[1],0},;
{"DESCORI","C",TamSX3("B1_DESC")[1],0},;
{"UM","C",3,0},;
{"QE","N",TamSX3("B1_QE")[1],TamSX3("B1_QE")[2]},;
{"CAIXAS","N",TamSX3("D1_QUANT")[1],cDecQtd },;
{"NCM","C",TamSX3("B1_POSIPI")[1],0},;
{"QUANTIDADE","N",TamSX3("D1_QUANT")[1],cDecQtd},;
{"PRECO","N",TamSX3("D1_VUNIT")[1],cDecUni},;
{"CUSTO","N",TamSX3("D1_CUSTO")[1],TamSX3("D1_CUSTO")[2]},;
{"PRECOFOR","N",TamSX3("D1_TOTAL")[1],cDecUni},;
{"TOTAL","N",TamSX3("D1_TOTAL")[1],TamSX3("D1_TOTAL")[2]},;
{"DESCONTO","N",TamSX3("D1_VALDESC")[1],TamSX3("D1_VALDESC")[2]},;
{"EMISSAO","C",TamSX3("D1_EMISSAO")[1],0 },;
{"PEDIDO","C",TamSX3("D1_PEDIDO")[1],0 },;
{"ITEM","C",TamSX3("D1_ITEMPC")[1],0 },;
{"TES","C",TamSX3("D1_TES")[1],0 },;
{"ALMOX","C",TamSX3("D1_LOCAL")[1],0 },;
{"ALTERADO","C",1,0 },;
{"NOME","C",TamSX3("A2_NOME")[1],0 },;
{"NOTA","C",TamSX3("D1_DOC")[1],0 },;
{"TOTALNF","N",TamSX3("D1_TOTAL")[1],TamSX3("D1_TOTAL")[2] }}

cArqTrab  := CriaTrab(aCampos)
dbUseArea( .T.,, cArqTrab, "LS1", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS1",cArqTrab,"SEQ",,,)
dbSetIndex( cArqTrab +OrdBagExt())
dbSelectArea("LS1")

aCampos3:= {{"EMISSAO","D",TamSX3("D1_EMISSAO")[1],0 },;
{"FORNEC","C",TamSX3("D1_FORNECE")[1],0 },;
{"LOJA","C",TamSX3("D1_LOJA")[1],0 },;
{"NOTA","C",TamSX3("D1_DOC")[1],0 },;
{"NOME","C",TamSX3("A2_NOME")[1],0 },;
{"VENDEDOR","C",TamSX3("A3_NOME")[1],0 },;
{"TELEFONE","C",TamSX3("A3_DDDTEL")[1]+TamSX3("A3_TEL")[1],0 },;
{"XML","C",150,0 },;
{"CHAVE","C",60,0 },;
{"TIPO","C",1,0 },;
{"CNPJEMIT","C",14,0 }}  // Acrescentado em 27/08/2012 para tratar legenda de operações (N=Normal, B=Beneficiamento e D=Devolução)


cArqTrab3  := CriaTrab(aCampos3)
dbUseArea( .T.,, cArqTrab3, "LS3", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS3",cArqTrab3,"NOME+NOTA",,,)
dbSetIndex( cArqTrab3 +OrdBagExt())
dbSelectArea("LS3")

_cCNPJ:=''  //CNPJ DO EMITENTE
_cCNPJ2:='' //CNPJ DO DESTINATÁRIO
lAchou:=.F.

#IFDEF WINDOWS
	Processa({|| XMLFOUND()})
	Return
	Static Function XMLFOUND()
#ENDIF
aCampos4:= {{"NOTA","C",TamSX3("D1_DOC")[1],0 },;
{"FORNECEDOR","C",TamSX3("D1_FORNECE")[1],0 },;
{"LOJA","C",TamSX3("D1_LOJA")[1],0 }}

cArqTrab4  := CriaTrab(aCampos4)
dbUseArea( .T.,, cArqTrab4, "LS4", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS4",cArqTrab4,"FORNECEDOR+LOJA+NOTA",,,)
dbSetIndex( cArqTrab4 +OrdBagExt())
dbSelectArea("LS4")

cNota:=''
cEmissao:=''
cChave:=''
cxTipoNFXML := ''
_cOpcao:=''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento exclusivo conquista										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/* -- Comentado por Luiz em 24/05/2011 por não termos necessidade deste tratamento neste momento
If "CONQUISTA" $ ALLTRIM(UPPER(SM0->M0_NOME))
	
	aGrupos:={}
	AADD(aGrupos,"TODOS")
	
	cQuery:=" SELECT A2_GRPCOM GRUPO FROM "+RetSqlName('SA2')+" WHERE A2_FILIAL=' ' AND A2_GRPCOM<>' ' AND D_E_L_E_T_=' ' GROUP BY A2_GRPCOM ORDER BY A2_GRPCOM "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		AADD(aGrupos,UPPER(TCQ->GRUPO))
		DbSkip()
	End
	DbClosearea("TCQ")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Identificacao do Grupo										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 070,070 TO 150,280 dialog oGrupo title "Escolha o Grupo..."
	@ 005,010 SAY "Grupos Compras"
	@ 015,010 COMBOBOX _cOpcao ITEMS aGrupos SIZE 40,10
	@ 015,060 BUTTON "Confirma" SIZE 40,10 ACTION oGrupo:end()
	Activate Dialog oGrupo CENTERED
Endif
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processando XML														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Procregua(len(_aXML))

For i:=1 to len(_aXML)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recebendo dados do XML												³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_XML()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fornecedor															³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(_cCNPJ)
		DbSelectarea(iif(cxTipoNFXML $ "B/D","SA1","SA2")) //Alterado em 06/08/2014 por Luiz para tratar Devolução e Beneficiamento -> estava fixo SA2
		DbSetorder(3)
		Dbgotop()
		Dbseek(xFilial(iif(cxTipoNFXML $ "B/D","SA1","SA2"))+_cCNPJ)
		If Found()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificando grupo                        							³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lFornec:=.T.
			/* Comentado por se tratar de campo customizado A2_GRPCOM não em uso 
			If !Empty(_cOpcao) .and. alltrim(_cOpcao)<>"TODOS"
				If ALLTRIM(SA2->A2_GRPCOM)==_cOpcao
					lFornec:=.T.
				Else
					lFornec:=.F.
				Endif
				
				If Empty(SA2->A2_GRPCOM)
					Msgbox("Fornecedor "+SA2->A2_COD+"/"+ALLTRIM(SA2->A2_NREDUZ)+" está sem o grupo de compras informado!","Atenção...","ALERT")
				Endif
			Endif
			*/

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtros da Rotina													³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(MV_PAR01) .and. !Empty(MV_PAR02) .and. (iif(cxTipoNFXML $ "B/D",SA1->A1_COD,SA2->A2_COD)<>MV_PAR01 .OR. iif(cxTipoNFXML $ "B/D",SA1->A1_LOJA,SA2->A2_LOJA)<>MV_PAR02)
				lFornec:=.F.
			Endif
			If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04) .and. (STOD(cEmissao)<MV_PAR03 .OR. STOD(cEmissao)>MV_PAR04)
				lFornec:=.F.
			Endif
			If !Empty(MV_PAR05) .AND. !Empty(MV_PAR06) .and. (strzero(val(cNota),TamSX3("D1_DOC")[1])<strzero(val(MV_PAR05),TamSX3("D1_DOC")[1]) .OR. strzero(val(cNota),TamSX3("D1_DOC")[1])>strzero(val(MV_PAR06),TamSX3("D1_DOC")[1]))
				lFornec:=.F.
			Endif
		Else
			lFornec:=.F.
			//Início tratamento adicionado por Luiz em 20/04/2012 para poder ficar ciente que tem XML com destinatário da empresa corrente no sistema mas onde o fornecedor emitente ainda não existe na SA2
			//isso fazia com que os XMLs ficassem sempre na pasta a serem importados sem o conhecimento do usuário
			if Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
				_xnOpcAvis := Aviso("Arquivo XML de fornecedor e/ou cliente ainda não cadastrado", "O arquivo " + _cPastaXML+ iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1])) +" " +;
				"do emitente " + _xcNomEmit + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
				"Nota: " + cNota + " Tipo " + cxTipoNFXML +CHR(13)+CHR(10) +;
				"Emissão: " + cEmissao +CHR(13)+CHR(10) +;
				"Nat. Operação no XML: " + cNatOp +CHR(13)+CHR(10) +;
				"Chave: " + cChave +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
				"Tem como destinatário o CNPJ " + _cCNPJ2 + " desta empresa em uso, mas no entanto não foi encontrado o cadastro deste fornecedor e/ou cliente." +;
				"Será necessário efetuar o cadastro deste fornecedor/cliente primeiro antes de importar este XML ou verificar parâmetros da rotina relacionados a " +;
				"CFOPs de Devolução/Beneficiamento. Você deseja visualizar este XML agora " +;
				"para observar maiores informações sobre esta nota?" , {"Sim","Não"} ,3)
				If _xnOpcAvis == 1
					MsgRun("Acessando arquivo XML ...",,{||SEFAZ(lower(ALLTRIM(_aXML[i,1])),cChave)})					
				Endif
			Endif
			// Final			
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravando XML encontrados											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lFornec
			Incproc(iif(cxTipoNFXML $ "B/D",SA1->A1_NREDUZ,SA2->A2_NREDUZ))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifico arquivos XML duplicados									³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectarea("LS4")
			DbSetorder(1)
			Dbgotop()
			dbseek(iif(cxTipoNFXML $ "B/D",SA1->A1_COD+SA1->A1_LOJA,SA2->A2_COD+SA2->A2_LOJA)+cNota)
			If !Found()
				Reclock("LS4",.T.)
				LS4->NOTA:=cNota
				LS4->FORNECEDOR:=iif(cxTipoNFXML $ "B/D",SA1->A1_COD,SA2->A2_COD)
				LS4->LOJA:=iif(cxTipoNFXML $ "B/D",SA1->A1_LOJA,SA2->A2_LOJA)
				MsUnlock()

				Reclock("LS3",.T.)
				LS3->EMISSAO:=STOD(cEmissao)
				LS3->FORNEC:=iif(cxTipoNFXML $ "B/D",SA1->A1_COD,SA2->A2_COD)
				LS3->LOJA:=iif(cxTipoNFXML $ "B/D",SA1->A1_LOJA,SA2->A2_LOJA)
				LS3->VENDEDOR:=SUBSTR(iif(cxTipoNFXML $ "B/D",SA1->A1_CONTATO,SA2->A2_REPRES),1,30)
				LS3->TELEFONE:=alltrim(iif(cxTipoNFXML $ "B/D",SA1->A1_DDD,SA2->A2_DDD))+" "+alltrim(SUBSTR(iif(cxTipoNFXML $ "B/D",SA1->A1_TEL,SA2->A2_TEL),1,20))
				LS3->NOME:=iif(cxTipoNFXML $ "B/D",SA1->A1_NREDUZ,SA2->A2_NREDUZ)
				LS3->XML:=UPPER(aXML[i,1])
				LS3->NOTA:=cNota
				LS3->CHAVE:=cChave
				LS3->TIPO:=cxTipoNFXML
				LS3->CNPJEMIT:=AllTrim(_cCNPJ)
				MsUnlock()
				lAchou:=.T.
				
			ELSEIF cxTipoNFXML == "C"
				//Alteração Vinicius Fernandes - 29/02/16
				//tratamento para mover os XML de CTe para a pasta especifica
				_cFileNew	:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1]))
				
				DIRXML		:= "XMLNFE\"
				DIRALER		:= "NEW\"				
				//__CopyFile(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.dup",_xPstSalv+_xcBarraDir+"duplicados"+_xcBarraDir) // Alterado em 26/04/2012 para tratar compartilhamento de pasta entre empresas
				Copy File &_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(_aXML[i,1])) TO &(DIRXML+DIRALER+_xcBarraDir+lower(ALLTRIM(aXML[i,1])))
				ferase(_cFileNew)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nomeclatura dos arquivos											³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(_aXML[i,1]))
				_cFileNew:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(_cCNPJ)+"-nf"+ALLTRIM(cNota)+"-"+alltrim(cChave)+".xml.dup"
				
				FRenameEx(_cFileOri,_cFileNew)
				__CopyFile(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.dup",_xPstSalv+_xcBarraDir+"duplicados"+_xcBarraDir) // Alterado em 26/04/2012 para tratar compartilhamento de pasta entre empresas
				ferase(_cFileNew)
			Endif
		Endif
	Endif
Next

Dbselectarea("LS4")
dbCloseArea("LS4")
fErase( cArqTrab4+ ".DBF" )
fErase( cArqTrab4+ OrdBagExt() )

If lAchou==.F.
	Msgbox("Não existem arquivos para serem importados no momento. " + iif(len(_aXML)>0,"No entanto, existem arquivos xml na pasta " + _cPastaXML + ". Verifique a empresa "+;
		   "selecionada e/ou visualize o(s) arquivo(s) XML(s), pois talvez seja necessário fazer o cadastro do fornecedor/cliente antes de importar o XML!","") ,"Atenção...","ALERT")
	Dbselectarea("LS1")
	dbCloseArea("LS1")
	fErase( cArqTrab+ ".DBF" )
	fErase( cArqTrab+ OrdBagExt() )
	
	Dbselectarea("LS5")
	dbCloseArea("LS5")
	fErase( cArqTrab5+ ".DBF" )
	fErase( cArqTrab5+ OrdBagExt() )
	
	Dbselectarea("LS3")
	dbCloseArea("LS3")
	fErase( cArqTrab3+ ".DBF" )
	fErase( cArqTrab3+ OrdBagExt() )
	Return
Endif

cNota:=space(09)
cNatOp:=''
_cCNPJ:=space(18)
_cMensag:=''
_cMensaginfAdFisco:='' //Adicionado por Luiz em 27/08/2014 para tratamento da alteração do tipo de nota
nTotalNF:=0
nTotIt:=0
_cFornecedor:=''
_cTelefone:=''
_cInscr:=''
_cEnd:=''
_cCidade:=''
_cEmissao:=''
cUm:=''
nDescont:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aHeaders 															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPict1:="@E 9,999,999."  // alterado de 99,999.00 para 9,999,999. por Luiz em 24/05/2011
For w:=1 to cDecQtd
	cPict1:=alltrim(cPict1)+"9"
Next
cPict2:="@E 99,999."
For w:=1 to cDecUni
	cPict2:=alltrim(cPict2)+"9"
Next

DbSelectarea("LS3")
Dbgotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ legenda de cores	(ITENS DO XML)									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCores := {{ 'LS1->OK=="X"', 'BR_VERMELHO'  },;
{ 'EMPTY(LS1->OK)', 'BR_VERDE'  },;
{ 'LS1->OK=="O"', 'BR_AZUL'  }}

cMarca := GetMark()
linverte:=.f.
aTitulo := {}
aTituloX := {}

bColor := &("{||IIF(LS1->OK=='O',"+Str(CLR_HBLUE)+","+Str(CLR_BLACK)+")}")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela principal da rotina											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 120,040 TO _nTop,_nRight DIALOG oTela TITLE "Importação nota fiscal eletrônica - "+SM0->M0_CODIGO+"/"+SM0->M0_CODFIL+"-"+SM0->M0_FILIAL+" "+ _cVersaoIMPXML + " - " + xcNEmpresa +": IMPXML.PRW" // Adicionado por Luiz em 26/05/2011 a última parte da string somada referente ao nome da empresa
@ 004,005 BITMAP ResName "CHECKED" OF oTela Size 15,15 ON CLICK (MsgRun("Verificando pedidos em aberto...",,{||IMPORTA()})) NoBorder  Pixel
@ 005,025 BUTTON "_Recusar Recebimento" SIZE 65,10 ACTION RECUSAR()
@ 005,095 BUTTON "Re_fazer Nota Fiscal" SIZE 65,10 ACTION MsgRun("Restaurando informações originais...",,{||REFAZER()})
@ 005,165 BUTTON "E_xcluir Identificação" SIZE 65,10 ACTION EXCAMA()
//@ 005,235 BUTTON "Cons_ultar SEFAZ" SIZE 65,10 ACTION MsgRun("Processando NFE no site da SEFAZ...",,{||SEFAZ()})
@ 005,235 BUTTON iif(substr(lower(_cURL),1,2) == "ht","Acess_ar SEFAZ","Visu_alizar XML") SIZE 65,10 ACTION MsgRun("Acessando arquivo XML ...",,{||SEFAZ()})
@ 005,305 BUTTON "H_istórico" SIZE 65,10 ACTION MsgRun("Processando histórico do fornecedor/cliente...",,{||HISTFOR()})
@ 005,390 say "IMPORTAÇÃO DE XML" FONT oFont5 OF oTela PIXEL //COLOR CLR_HRED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Principal 															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 020,005 TO 110,_nSize BROWSE "LS3" OBJECT OBRWP FIELDS aTituloX
// início do trecho adicionado por Luiz em 27/08/2014 para tratamento da tela de alteração do tipo de nota a ser importada
OBRWP:oBrowse:bLDblClick := {||xMudaTipoNF(cxDadosFornec,cxInfCompl,LS3->TIPO)} // Acrescentado por Luiz em 27/08/2014 para permitir alterar o tipo de nota a ser importado
// final do trecho adicionado por Luiz em 27/08/2014 para tratamento da tela de alteração do tipo de nota a ser importada
OBRWP:oBrowse:BCHANGE := {||PROCESS()}

OBRWP:oBrowse:oFont := TFont():New ("Arial", 05, 18)

OBRWP:oBrowse:AddColumn(TCColumn():New("Tipo",      {||LS3->TIPO},"@!",,,"LEFT",10))
OBRWP:oBrowse:AddColumn(TCColumn():New("Emissão",   {||LS3->EMISSAO},"@D 99/99/9999",,,"LEFT",35)) //Alterado de 10 para 35 em 28/08/2014
OBRWP:oBrowse:AddColumn(TCColumn():New("Código",    {||LS3->FORNEC},,,,"LEFT",25)) //Alterado de 10 para 25 em 28/08/2014
OBRWP:oBrowse:AddColumn(TCColumn():New("Loja",      {||LS3->LOJA},,,,"LEFT",15))
OBRWP:oBrowse:AddColumn(TCColumn():New("Nome",      {||LS3->NOME},,,,"LEFT",60))
OBRWP:oBrowse:AddColumn(TCColumn():New("Vendedor",  {||LS3->VENDEDOR},"@!",,,"LEFT",90))
OBRWP:oBrowse:AddColumn(TCColumn():New("Telefone",  {||LS3->TELEFONE},"@!",,,"LEFT",60))
OBRWP:oBrowse:AddColumn(TCColumn():New("Nota Fiscal Eletrônica",{||LS3->CHAVE},"@!",,,"LEFT",10))
OBRWP:oBrowse:AddColumn(TCColumn():New("Arquivo XML",{||LS3->XML},"@!",,,"LEFT",10))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Secundaria															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
OBRWI:=MsSelect():New("LS1","","",aTitulo,@lInverte,@cMarca,{125,005,240,_nSize},,,,,aCores)
OBRWI:oBrowse:bLDblClick := {||CORRIGE()}
OBRWI:oBrowse:oFont := TFont():New ("Arial", 05, 18)

OBRWI:oBrowse:AddColumn(TCColumn():New("Cód. no XML" ,{||LS1->PRODFOR},_xPica5prf,,,"LEFT", 35))  // Adicionado Picture (variável _xPica5prf) em 21/08/2012 //Alterado de 25 para 35 em 28/08/2014
OBRWI:oBrowse:AddColumn(TCColumn():New("Produto"     ,{||LS1->PRODUTO},_xPicb1cod,,,"LEFT", 35)) 	// Adicionado Picture (variável _xPicb1cod) em 21/08/2012 //Alterado de 25 para 35 em 28/08/2014
OBRWI:oBrowse:AddColumn(TCColumn():New("Descrição"   ,{||LS1->DESCRICAO},,,,"LEFT",150))
OBRWI:oBrowse:AddColumn(TCColumn():New("UM"          ,{||LS1->UM},,,,"LEFT", 25))
OBRWI:oBrowse:AddColumn(TCColumn():New("Emb."        ,{||LS1->QE},"@E 999999",,,"LEFT", 25))
OBRWI:oBrowse:AddColumn(TCColumn():New("Caixas"      ,{||LS1->CAIXAS},cPict1,,,"RIGHT", 45))  // Alterado por Luiz de 25 para 45
OBRWI:oBrowse:AddColumn(TCColumn():New("Quant."      ,{||LS1->QUANTIDADE},cPict1,,,"RIGHT", 45))
OBRWI:oBrowse:AddColumn(TCColumn():New("Preço R$"    ,{||LS1->PRECO},cPict2,,,"RIGHT", 45))
OBRWI:oBrowse:AddColumn(TCColumn():New("Custo R$"    ,{||LS1->CUSTO},"@E 9,999.99",,,"RIGHT", 45))
OBRWI:oBrowse:AddColumn(TCColumn():New("Desc.R$"     ,{||LS1->DESCONTO},"@E 99,999.99",,,"RIGHT", 45))
OBRWI:oBrowse:AddColumn(TCColumn():New("Total-Desconto R$",{||LS1->TOTAL},"@E 99,999.99",,,"RIGHT", 45))
OBRWI:oBrowse:SetBlkColor(bColor)

If (l2Check2 .or. cPedCom) //.and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
	OBRWI:oBrowse:AddColumn(TCColumn():New("Pedido",{||LS1->PEDIDO},,,,"LEFT", 30))
	OBRWI:oBrowse:AddColumn(TCColumn():New("Item",{||LS1->ITEM},,,,"LEFT", 30))
Endif

@ 245,003 TO 315,235
@ 250,005 say "EMITENTE " + iif(LS3->TIPO $ "B/D","(Cliente)","(Fornecedor)") SIZE 150,40 FONT oFont4 OF oTela PIXEL COLOR CLR_BLUE  //Alterado em 28/08/2014 de FORNECEDOR para EMITENTE, visto que as devoluções são de clientes
@ 260,005 say _cFornecedor size 200,20 FONT oFont3 OF oTela PIXEL //COLOR CLR_BLUE
@ 270,005 say "CNPJ" FONT oFont1 OF oTela PIXEL
@ 270,040 say _cCNPJ size 80,20 size 50,20 FONT oFont2 OF oTela PIXEL
@ 280,005 say "Endereço" FONT oFont1 OF oTela PIXEL
@ 280,040 say _cEnd size 170,20 FONT oFont2 OF oTela PIXEL
@ 300,005 say "Cidade/UF" FONT oFont1 OF oTela PIXEL
@ 300,040 say _cCidade size 150,20 size 100,20 FONT oFont2 OF oTela PIXEL

@ 245,240 TO 315,435
@ 250,250 say "NOTA FISCAL" FONT oFont4 OF oTela PIXEL COLOR CLR_BLUE
@ 260,250 say "Emissão" FONT oFont1 OF oTela PIXEL
@ 260,290 say _cEmissao size 80,40 picture "@D 99/99/9999" FONT oFont3 OF oTela PIXEL
@ 270,250 say "Total-Desconto R$" FONT oFont1 OF oTela PIXEL
@ 270,300 say nTotalNF size 80,40 picture "@E 999,999.99" FONT oFont3 OF oTela PIXEL
@ 280,250 say "Qtd.Itens" FONT oFont1 OF oTela PIXEL
@ 280,290 say nTotIt size 40,40 picture "@E 9999" FONT oFont3 OF oTela PIXEL
@ 290,250 say "Nat.Operação" FONT oFont1 OF oTela PIXEL
@ 290,290 say SUBSTR(alltrim(cNatOP),1,32) size 180,40 picture "@!" FONT oFont2 OF oTela PIXEL //COLOR CLR_HRED
@ 300,250 say "Série/Nota Fiscal" FONT oFont1 OF oTela PIXEL
@ 300,310 say ALLTRIM(cSerie)+"-"+cNota size 95,40 picture "@!" FONT oFont3 OF oTela PIXEL //COLOR CLR_MAGENTA
@ 112,005 BUTTON "_Histórico" SIZE 65,10 ACTION xHistProdPol() // alterado por Luiz em 13/06/2011 - estava apenas MACOMVIEW(LS1->PRODUTO)
@ 112,075 BUTTON "Cód._Barras" SIZE 65,10 ACTION CODBAR(cFile)
//@ 112,145 BUTTON "_Mensagem Nota" SIZE 65,10 ACTION MSGNF(_cMensag)
 @ 112,145 BUTTON "_Consultar Chave" SIZE 65,10 ACTION xValidaNFE(cChave)
@ 112,215 BUTTON "Refa_z Desconto" SIZE 65,10 ACTION REFDESC()
@ 112,285 BUTTON "_Legenda" SIZE 65,10 ACTION LEGENDA()
If l2Check2 //.and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
	@ 112,355 BUTTON "_Selecionar Pedido" SIZE 65,10 ACTION PROCPED()
	@ 112,425 BUTTON "_Eliminar Pedido do item" SIZE 65,10 ACTION ELIMPED()
	@ 112,495 BUTTON "Eliminar _Todos Pedidos" SIZE 65,10 ACTION ELIMPEDT()
Endif
If aSize[5] >=1220
//	@ 018,055 BITMAP SIZE 110,110 FILE "NFE.BMP" NOBORDER      //Retirado logos em 11/04/2012 por Luiz para já apresentar as informações complementares
//	@ 018,065 BITMAP SIZE 110,110 FILE alltrim(cLogo)+".BMP" NOBORDER
 	@ 245,440 get oMemo VAR _cMensag MEMO SIZE 150,070 FONT oFont2 OF oTela PIXEL
Endif
ACTIVATE DIALOG oTela CENTER

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apagando arquivos temporarios										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Dbselectarea("LS1")
dbCloseArea("LS1")
fErase( cArqTrab+ ".DBF" )
fErase( cArqTrab+ OrdBagExt() )

Dbselectarea("LS5")
dbCloseArea("LS5")
fErase( cArqTrab5+ ".DBF" )
fErase( cArqTrab5+ OrdBagExt() )

Dbselectarea("LS3")
dbCloseArea("LS3")
fErase( cArqTrab3+ ".DBF" )
fErase( cArqTrab3+ OrdBagExt() )
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gerando pre nota													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function IMPORTA()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se existe a nota fiscal									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !file(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(LS3->XML))
	msgbox("Este arquivo já foi processado por outro usuário!","IMPORTA() - Atenção...","ALERT")
	Reclock("LS3",.F.)
	dbdelete()
	MsUnlock()
	
	DbSelectarea("LS3")
	Dbgotop()
	PROCESS()
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se todas as variaveis foram preenchidas					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cNota)
	Msgbox("Numero de nota fiscal não encontrada!")
	Return
Endif
If Empty(_cCNPJ)
	Msgbox("Dados do fornecedor não encontradosNumero de nota fiscal não encontrada!")
	Return
Endif
If nTotIt<=0
	Msgbox("Nota fiscal não contem itens!")
	Return
Endif
If nTotalNF<=0
	Msgbox("Nota fiscal sem valores das mercadorias!")
	Return
Endif
If xcData < cEmissao
	Msgbox("Licença de uso expirada em " + dtoc(ctod(xcData)) +" Verifique a integridade do arquivo "+_xcBarraDir+_cEmpresa+_cCorrente+_xcBarraDir+"config"+_xcBarraDir+"leiame_impxml.txt e/ou solicite nova liberação." ,"Atenção...","STOP") //Adicionado +_cEmpresa+_cCorrente por Luiz em 27/10/2014	
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se todos os produtos foram identificados				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lIdent:=.F.
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF LS1->OK=="X"
		lIdent:=.T.
	Endif
	Dbskip()
End
Dbgotop()

If lIdent
	Msgbox("Existem produtos não identificados, corrija primeiro!","Atenção...","ALERT")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando se o pedido foi feito por item							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPedCom .and. (axCNPJsm0[1] == .F. .or. (axCNPJsm0[1] == .T. .and. !cIgnoraPCTransf)) //Adicionado por Luiz em 19/11/2014 para obrigar pedido de compras quando não for empresa do grupo (geralmente notas de transferência não precisa do pedido, mas para isto precisa escolher Sim(-Transf.))  .and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
	lItem:=.F.
	DbSelectarea("LS1")
	Dbgotop()
	While !Eof()
		IF !Empty(LS1->PEDIDO)
			lItem:=.T.
		Endif
		Dbskip()
	End
	
	If lItem
		DbSelectarea("LS1")
		Dbgotop()
		While !Eof()
			IF Empty(LS1->PEDIDO) .and. FDESC("SF4",xFilial("SC7")+LS1->TES,"F4_DUPLIC") == "S" // Acrescentado por Luiz em 31/05/2011 a partir .and. para tratar se a TES gera duplicata (somente é obrigatório pedido de compras para TES que gera duplicata)
				Dbgotop()
				Msgbox("Existem produtos sem o pedido de compras, favor corrigi-los primeiro!","Atenção...","ALERT")
				xnQtdItensTESDup := xnQtdItensTESDup + 1 // Adicionado por Luiz em 31/05/2011 para contar itens que gera duplicata
				Return
			Endif
			Dbskip()
		End
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gerar pedido itens sem pedidos de compras							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lSemPed:=.F.
	If lItem
		DbSelectarea("LS1")
		Dbgotop()
		While !Eof()
			IF ALLTRIM(LS1->PEDIDO)=="CRIAR"
				lSemPed:=.T.
			Endif
			Dbskip()
		End
	Endif
	
	If lSemped
		cResp:=msgbox("Deseja gerar o pedido para os itens que não tem pedido de compra?","Atenção...","YESNO")
		If cResp
			NEWPED2()
			DbSelectarea("LS1")  // Acrescentado por Luiz em 13/06/2011
			dbgotop()			 // Acrescentado por Luiz em 13/06/2011
			Return				 // Acrescentado por Luiz em 13/06/2011
		Else
			DbSelectarea("LS1")
			dbgotop()
			Return
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificando se os produtos existem saldos no pedidos				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lItem
		DbSelectarea("LS1")
		Dbgotop()
		While !Eof()
			IF !Empty(LS1->PEDIDO)
				aProdutos	:= {{"PRODUTO","C",TamSX3("C7_PRODUTO")[1],0 },;
				{"DESCRICAO","C",TamSX3("B1_DESC")[1],0 },;
				{"QUANTIDADE","N",TamSX3("C7_QUANT")[1],TamSX3("C7_QUANT")[2] },;
				{"PEDIDO","C",TamSX3("C7_NUM")[1],0 },;
				{"ITEM","C",TamSX3("C7_ITEM")[1],0 },;
				{"PRECO","N",TamSX3("C7_PRECO")[1],TamSX3("C7_PRECO")[2] }}
				
				cArqTrabp  := CriaTrab(aProdutos)
				dbUseArea( .T.,, cArqTrabp, "PRO", if(.F. .OR. .F., !.F., NIL), .F. )
				IndRegua("PRO",cArqTrabp,"PEDIDO+PRODUTO+ITEM",,,)
				dbSetIndex( cArqTrabp +OrdBagExt())
				dbSelectArea("PRO")
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Aglutinando produtos iguais											³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectarea("LS1")
				Dbsetorder(1)
				Dbgotop()
				While !Eof()
					DbSelectarea("PRO")
					DbSetorder(1)
					Dbgotop()
					Dbseek(LS1->PEDIDO+LS1->PRODUTO+LS1->ITEM)
					If !Found()
						Reclock("PRO",.T.)
						PRO->PRODUTO:=LS1->PRODUTO
						PRO->QUANTIDADE:=LS1->QUANTIDADE
						PRO->DESCRICAO:=LS1->DESCRICAO
						PRO->PRECO:=LS1->PRECO
						PRO->PEDIDO:=LS1->PEDIDO
						PRO->ITEM:=LS1->ITEM
						MsUnlock()
					Else
						Reclock("PRO",.F.)
						PRO->QUANTIDADE:=(PRO->QUANTIDADE+LS1->QUANTIDADE)
						MsUnlock()
					Endif
					DbSelectarea("LS1")
					Dbskip()
				End
			Endif
			DbSelectarea("LS1")
			Dbskip()
		End
		
		cMsg:=''
		DbSelectArea("PRO")
		Dbgotop()
		While !Eof()
			cQuery:=" SELECT (C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
			cQuery:=cQuery + " AND C7_NUM='"+PRO->PEDIDO+"' "
			cQuery:=cQuery + " AND C7_PRODUTO='"+PRO->PRODUTO+"' "
			cQuery:=cQuery + " AND C7_ITEM='"+PRO->ITEM+"' "
			cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
			cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
			cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
			cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
			TCQUERY cQuery NEW ALIAS "TCQ"
			DbSelectarea("TCQ")
			IF PRO->QUANTIDADE>TCQ->QUANT
				cMsg:=cMsg+PRO->PEDIDO+"   "+PRO->ITEM+"   "+alltrim(PRO->PRODUTO)+"   "+PRO->DESCRICAO+CHR(13)+CHR(10)
			Endif
			Dbclosearea("TCQ")
			DbSelectArea("PRO")
			Dbskip()
		End

		Dbselectarea("PRO")
		dbCloseArea("PRO")
		fErase( cArqTrabp+ ".DBF" )
		fErase( cArqTrabp+ OrdBagExt() )
		
		If !Empty(cMsg)
			DEFINE MSDIALOG oProdd FROM 0,0 TO 300,420 PIXEL TITLE "produto sem pedido no momento..."
			@ 005,005 say " Pedido       Item       Produto    Descrição" SIZE 150,40 FONT oFont1 OF oProdd PIXEL COLOR CLR_HBLUE
			@ 015,005 GET oMemo VAR cMsg MEMO SIZE 200,135 FONT oFont6 PIXEL OF oProdd
			ACTIVATE MSDIALOG oProdd CENTER
			
			DbSelectarea("LS1")
			Dbgotop()
			Return
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o preco esta proximo do correto							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg:=''
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF LS1->CUSTO>0
		IF 100-((LS1->PRECO/LS1->CUSTO)*100)>xnPercMaxDiverg .OR. 100-((LS1->PRECO/LS1->CUSTO)*100)<-xnPercMaxDiverg        // Alterado por Luiz em 26/05/2011. Onde está xnPercMaxDiverg estava fixo 10
			cMsg:=cMsg+ALLTRIM(LS1->PRODUTO)+"  "+SUBSTR(LS1->DESCRICAO,1,35)+CHR(13)+CHR(10)
			cMsg:=cMsg+"Preço Nota R$ "+transform(LS1->PRECO,cPict2)+"   Preço Pedido R$"+transform(LS1->CUSTO,cPict2)+CHR(13)+CHR(10)
			cMsg:=cMsg+CHR(13)+CHR(10)
			
			Reclock("LS1",.F.)
			LS1->OK:="O"
			MsUnlock()
		Endif
	Endif
	Dbskip()
End
Dbgotop()

If !Empty(cMsg)
	lSaida:=.F.
	DEFINE MSDIALOG oProdd FROM 0,0 TO 330,420 PIXEL TITLE "Produtos com divergência de preços..."
	@ 005,005 GET oMemo VAR cMsg MEMO SIZE 200,135 FONT oFont6 PIXEL OF oProdd
	@ 150,005 BUTTON "<< Voltar" SIZE 55,10 ACTION oProdd:end()
	@ 150,070 BUTTON "Continuar >>" SIZE 55,10 ACTION (lsaida:=.T.,oProdd:end())
	ACTIVATE MSDIALOG oProdd CENTER
	
	If lSaida==.F.
		Return
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controla pedidos de compras											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
axCNPJsm0 := xChecaCNPJsm0(LS3->CNPJEMIT,SM0->M0_CGC) // _cCNPJ=EMITENTE _cCNPJ2=DESTINATÁRIO //Adicionado em 20/11/2014 para checar empresa do mesmo grupo (sigamat)
If cPedCom .and. (axCNPJsm0[1] == .F. .or. (axCNPJsm0[1] == .T. .and. !cIgnoraPCTransf)) //Adicionado por Luiz em 19/11/2014 para obrigar pedido de compras quando não for empresa do grupo (geralmente notas de transferência não precisa do pedido)  .and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
	If lItem==.F.
		aProdutos	:= {{"PRODUTO","C",TamSX3("C7_PRODUTO")[1],0 },;
		{"DESCRICAO","C",TamSX3("B1_DESC")[1],0 },;
		{"QUANTIDADE","N",TamSX3("C7_QUANT")[1],TamSX3("C7_QUANT")[2] },;
		{"PRECO","N",TamSX3("C7_PRECO")[1],TamSX3("C7_PRECO")[2] }}
		
		cArqTrabp  := CriaTrab(aProdutos)
		dbUseArea( .T.,, cArqTrabp, "PRO", if(.F. .OR. .F., !.F., NIL), .F. )
		IndRegua("PRO",cArqTrabp,"PRODUTO",,,)
		dbSetIndex( cArqTrabp +OrdBagExt())
		dbSelectArea("PRO")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Aglutinando produtos iguais											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("LS1")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			DbSelectarea("PRO")
			DbSetorder(1)
			Dbgotop()
			Dbseek(LS1->PRODUTO)
			If !Found()
				Reclock("PRO",.T.)
				PRO->PRODUTO:=LS1->PRODUTO
				PRO->QUANTIDADE:=LS1->QUANTIDADE
				PRO->DESCRICAO:=LS1->DESCRICAO
				PRO->PRECO:=LS1->PRECO
				MsUnlock()
			Else
				Reclock("PRO",.F.)
				PRO->QUANTIDADE:=(PRO->QUANTIDADE+LS1->QUANTIDADE)
				MsUnlock()
			Endif
			DbSelectarea("LS1")
			Dbskip()
		End
		
		aCampos2	:= {{"OK","C",1,0 },;
		{"EMISSAO","D",TamSX3("C7_EMISSAO")[1],0 },;
		{"PEDIDO","C",TamSX3("C7_NUM")[1],0 },;
		{"LOJA","C",TamSX3("C7_LOJA")[1],0 },;
		{"ITENS","N",5,0 },;
		{"ENTREGA","D",TamSX3("C7_DATPRF")[1],0 },;
		{"QTDIT","N",5,0 },;
		{"VALIDO","N",5,0 }}
		
		cArqTrab2  := CriaTrab(aCampos2)
		cIndice:="Descend(DTOS(EMISSAO))"
		dbUseArea( .T.,, cArqTrab2, "LS2", if(.F. .OR. .F., !.F., NIL), .F. )
		IndRegua("LS2",cArqTrab2,cIndice,,,)
		dbSetIndex( cArqTrab2 +OrdBagExt())
		dbSelectArea("LS2")
		
		lAchou:=.f.
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificando pedidos em aberto										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery:=" SELECT C7_EMISSAO EMISSAO,C7_LOJA LOJA,C7_NUM PEDIDO,MAX(C7_DATPRF) ENTREGA,COUNT(*) QTD FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
//		cQuery:=cQuery + " AND C7_EMISSAO>='"+DTOS(DDATABASE-60)+"' " // Comentado por Luiz em 31/05/2011 para mostrar todos os pedidos em aberto com saldo
		cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
		cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
		cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
		cQuery:=cQuery + " GROUP BY C7_EMISSAO,C7_NUM,C7_LOJA "
		cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectarea("TCQ")
		While !Eof()
			Reclock("LS2",.T.)
			LS2->EMISSAO:=STOD(TCQ->EMISSAO)
			LS2->PEDIDO:=TCQ->PEDIDO
			LS2->LOJA:=TCQ->LOJA
			LS2->ITENS:=TCQ->QTD
			LS2->ENTREGA:=STOD(TCQ->ENTREGA)
			Msunlock()
			lAchou:=.T.
			DbSelectarea("TCQ")
			Dbskip()
		End
		DbClosearea("TCQ")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico quantidade de itens do pedidos e usados					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("LS2")
		Dbgotop()
		While !Eof()
			cQuery:=" SELECT COUNT(*) QTD FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_NUM='"+LS2->PEDIDO+"' "
			cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
			TCQUERY cQuery NEW ALIAS "TCQ"
			DbSelectarea("TCQ")
			_nUsados:=TCQ->QTD
			DbClosearea("TCQ")
			
			DbSelectarea("LS2")
			Reclock("LS2",.F.)
			LS2->QTDIT:=_nUsados
			MsUnlock()
			Dbskip()
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico Itens validos												³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("LS2")
		Dbgotop()
		While !Eof()
			_nItem:=0
			Dbselectarea("PRO")
			Dbgotop()
			While !Eof()
				DbSelectarea("SC7")
				DbSetorder(4)
				Dbgotop()
				Dbseek(xFilial("SC7")+PRO->PRODUTO+LS2->PEDIDO)
				If Found() .and. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA>0) .AND. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA>=PRO->QUANTIDADE) .AND. SC7->C7_RESIDUO<>"S"
					_nItem:=_nItem+1
					xnQtdItensTESDup := xnQtdItensTESDup + 1 // Adicionado por Luiz em 31/05/2011 
				Endif
				Dbselectarea("PRO")
				Dbskip()
			End
			
			DbSelectarea("LS2")
			Reclock("LS2",.F.)
			IF _nItem==nTotIt .or. xnQtdItensTESDup == _nItem // Adicionado a partir do .or. para tratar itens somente que geram duplicata
				LS2->OK:="X"
			Endif
			LS2->VALIDO:=_nItem
			MsUnlock()
			Dbskip()
		End
		Dbselectarea("LS1")
		Dbgotop()
		
		Dbselectarea("LS2")
		Dbgotop()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ aHeader dos pedidos													³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTitulo2 := {}
		AADD(aTitulo2,{"EMISSAO","Emissão"})
		AADD(aTitulo2,{"PEDIDO","Pedido"})
		AADD(aTitulo2,{"LOJA","Lj"})
		AADD(aTitulo2,{"QTDIT","Itens","@E 99999"})
		AADD(aTitulo2,{"ITENS","Abertos","@E 99999"})
		AADD(aTitulo2,{"VALIDO","Válidos","@E 99999"})
		AADD(aTitulo2,{"ENTREGA","Dt.Entrega"})
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tela dos pedidos em aberto											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lAchou
			@ 120,040 TO 400,590 DIALOG oPedido TITLE "Pedidos em aberto..."
			@ 005,005 BITMAP ResName "CHECKED" OF oPedido Size 15,15 ON CLICK (VALIDA())  NoBorder  Pixel
			@ 005,035 BUTTON "A_tualizar Pedido" SIZE 55,10 ACTION PEDIDOS()
			@ 005,095 BUTTON "_Abrir Pedido" SIZE 55,10 ACTION ABREPED()
			@ 005,155 BUTTON "_Divergências" SIZE 55,10 ACTION DIVERG("1")  // Adicionado em 13/06/2011 por Luiz para passar parâmetro na função DIVERG()
			@ 005,215 BUTTON "_Eliminar" SIZE 55,10 ACTION ELIMINAR()
			@ 020,005 TO 140,275 BROWSE "LS2" ENABLE " LS2->OK<>'X' " OBJECT OBRWT FIELDS aTitulo2
			OBRWT:oBrowse:oFont := TFont():New ("Arial", 05, 18)
			ACTIVATE DIALOG oPedido CENTER
		Else
			Msgbox("Não existem pedidos em aberto para este fornecedor!")
			
			cResp:=Msgbox("Deseja gerar um pedido automaticamente para esta nota eletrônica?","Atenção...","YESNO")
			If cResp
				NEWPED()
			Endif
		Endif
		
		Dbselectarea("PRO")
		dbCloseArea("PRO")
		fErase( cArqTrabp+ ".DBF" )
		fErase( cArqTrabp+ OrdBagExt() )

		Dbselectarea("LS2")
		dbCloseArea("LS2")
		fErase( cArqTrab2+ ".DBF" )
		fErase( cArqTrab2+ OrdBagExt() )
	Else
		@ 120,040 TO 170,285 DIALOG oPedido TITLE "Pedidos por item..."
		@ 005,005 BUTTON "Gerar Pré-Nota" SIZE 55,10 ACTION VALIDA()
		@ 005,065 BUTTON "_Divergências" SIZE 55,10 ACTION DIVERG("2")  // Adicionado em 13/06/2011 por Luiz para passar parâmetro na função DIVERG()
		ACTIVATE DIALOG oPedido CENTER
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao controla pedidos de compras										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cRet:=.T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Manipulando numero da nota fiscal									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cZeros
		cNota:=strzero(val(cNota),9)
	Endif
	cSpaco:=9-len(alltrim(cNota))
	
	cResp:=msgbox("Deseja gerar a pré-nota fiscal "+cNota+" agora?","Atenção...","YESNO")
	
	If cResp
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se a pre nota ja existe									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SF1")
		DbSetorder(2)
		Dbgotop()
		Dbseek(xFilial("SF1")+LS3->FORNEC+LS3->LOJA+alltrim(cNota)+Space(cSpaco))
		If Found() .and. SF1->F1_TIPO==LS3->TIPO // Alterado em 17/04/2014 por Luiz estava fixo "N" e foi alterado para cxTipoNFXML para mover xmls já importados //--> alterado em 28/08/2014 para LS3->TIPO pois o usuário pode ter trocado o tipo manualmente com duplo clique
			
			Msgbox("Nota fiscal já existe!","Atenção...","ALERT")
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dados do fornecedor													³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectarea(iif(LS3->TIPO $ "B/D","SA1","SA2"))
			DbSetorder(1)
			Dbgotop()
			Dbseek(xFilial(iif(LS3->TIPO $ "B/D","SA1","SA2"))+LS3->FORNEC+LS3->LOJA)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nomeclatura dos arquivos											³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML)
			_cFileNew:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(iif(LS3->TIPO $ "B/D",SA1->A1_CGC,SA2->A2_CGC))+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+"xml.imp"
			
			FRenameEx(_cFileOri,_cFileNew)
			__CopyFile(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.imp",_xPstSalv+_xcBarraDir+"importados"+_xcBarraDir) // Alterado em 26/04/2012 para tratar compartilhamento de pasta entre empresas
			ferase(_cFileNew)
			
			Reclock("LS3",.F.)
			dbdelete()
			MsUnlock()
			
			DbSelectarea("LS3")
			Dbgotop()
			
			DbSelectarea("LS1")
			Dbsetorder(1)
			Dbgotop()
			While !Eof()
				Reclock("LS1",.F.)
				dbdelete()
				MsUnlock()
				Dbskip()
			End
			
			DbSelectarea("LS5")
			Dbsetorder(1)
			Dbgotop()
			While !Eof()
				Reclock("LS5",.F.)
				dbdelete()
				MsUnlock()
				Dbskip()
			End
			
			PROCESS()
			Return
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravando pre nota entrada											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsgRun("Gerando pré nota entrada No.:"+cNota,,{||PRENOTA()})
		cNotaAtu:=cNota
		
		If cRet
			
			DbSelectarea("LS1")
			Dbsetorder(1)
			Dbgotop()
			While !Eof()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualizando NCM do produto de acordo com o XML do fornecedor		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				IF !Empty(LS1->NCM)
					DbSelectarea("SB1")
					DbSetorder(1)
					Dbgotop()
					Dbseek(xFilial("SB1")+LS1->PRODUTO)
					If Found()
						Reclock("SB1",.F.)
						SB1->B1_POSIPI:=LS1->NCM
						MsUnlock()
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravando amarracao produto x fornecedor								³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(LS1->PRODFOR)
					DbSelectarea(iif(LS3->TIPO $ "B/D","SA7","SA5"))
					DbSetorder(1)
					Dbgotop()
					Dbseek(xFilial(iif(LS3->TIPO $ "B/D","SA7","SA5"))+LS3->FORNEC+LS3->LOJA+LS1->PRODUTO)
					If !Found()
						IF LS3->TIPO $ "B/D"
							Reclock("SA7",.T.)
							SA7->A7_FILIAL:=xFilial("SA7")
							SA7->A7_CLIENTE:=LS3->FORNEC
							SA7->A7_LOJA:=LS3->LOJA
							SA7->A7_CODCLI:=LS1->PRODFOR
							SA7->A7_PRODUTO:=LS1->PRODUTO
							SA7->A7_DESCCLI:=SUBSTR(POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_DESC"),1,30)
							//SA7->A7_NOMEFOR:=POSICIONE("SA1",1,xFilial("SA1")+LS3->FORNEC+LS3->LOJA,"A1_NREDUZ")  //Alterado LS2->LOJA para LS3->LOJA por Luiz em 27/03/2012
							MsUnlock()						
						ELSE
							Reclock("SA5",.T.)
							SA5->A5_FILIAL:=xFilial("SA5")
							SA5->A5_FORNECE:=LS3->FORNEC
							SA5->A5_LOJA:=LS3->LOJA
							SA5->A5_CODPRF:=LS1->PRODFOR
							SA5->A5_PRODUTO:=LS1->PRODUTO
							SA5->A5_NOMPROD:=SUBSTR(POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_DESC"),1,30)
							SA5->A5_NOMEFOR:=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_NREDUZ")  //Alterado LS2->LOJA para LS3->LOJA por Luiz em 27/03/2012
							MsUnlock()
						ENDIF
					Else
						IF LS3->TIPO $ "B/D"
							Reclock("SA7",.F.)
							SA7->A7_CODCLI:=LS1->PRODFOR
							MsUnlock()
						ELSE
							Reclock("SA5",.F.)
							SA5->A5_CODPRF:=LS1->PRODFOR
							MsUnlock()
						ENDIF
					Endif
				Endif
				DbSelectarea("LS1")
				Reclock("LS1",.F.)
				dbdelete()
				MsUnlock()
				Dbskip()
			End
			
			DbSelectarea("LS3")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dados do fornecedor													³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectarea(iif(LS3->TIPO $ "B/D","SA2","SA2"))
			DbSetorder(1)
			Dbgotop()
			Dbseek(xFilial(iif(LS3->TIPO $ "B/D","SA2","SA2"))+LS3->FORNEC+LS3->LOJA)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nomeclatura dos arquivos											³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML)
			_cFileNew:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(iif(LS3->TIPO $ "B/D",SA1->A1_CGC,SA2->A2_CGC))+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+"xml.imp"
			
			FRenameEx(_cFileOri,_cFileNew)
			__CopyFile(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.imp",_xPstSalv+_xcBarraDir+"importados"+_xcBarraDir)   // Alterado em 26/04/2012 para tratar compartilhamento de pasta entre empresas
			ferase(_cFileNew)
			
			Reclock("LS3",.F.)
			dbdelete()
			MsUnlock()
			
			DbSelectarea("LS3")
			Dbgotop()
			Msgbox("Pré-Nota "+cNotaAtu+" gerada com sucesso!","Atenção...","INFO")
			PROCESS()
		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apagando Flag dos pedidos											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("LS1")
		DbSetorder(1)
		Dbgotop()
		While !Eof()
			IF !Empty(LS1->PEDIDO)
				Reclock("LS1",.F.)
				LS1->PEDIDO:=""
				LS1->ITEM:=""
				LS1->ALTERADO:=""
				MsUnlock()
			Endif
			Dbskip()
		End
		DbSelectarea("LS1")
		DbSetorder(1)
		Dbgotop()
	Endif
Endif

Dbselectarea("LS1")
Dbgotop()
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida pedido														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VALIDA()
iF lItem==.F.
	If LS2->OK<>"X"
		Msgbox("Este pedido não atende as necessidades da nota fiscal!")
		Return
	Endif
Endif

Dbselectarea("LS1")
Dbgotop()
While !Eof()
	cQuery:=" SELECT C7_NUM PEDIDO,C7_LOCAL ALMOX,C7_TES TES,C7_ITEM ITEM,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	IF lItem==.F.
		cQuery:=cQuery + " AND C7_NUM='"+LS2->PEDIDO+"' "
	Else
		cQuery:=cQuery + " AND C7_NUM='"+LS1->PEDIDO+"' "
		cQuery:=cQuery + " AND C7_ITEM='"+LS1->ITEM+"' "
	Endif
	cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
	cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
	cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
	cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		IF (TCQ->QUANT>=LS1->QUANTIDADE) .AND. TCQ->QUANT>0 .AND. LS1->QUANTIDADE>0
			Reclock("LS1",.F.)
			LS1->PEDIDO:=TCQ->PEDIDO
			LS1->ITEM:=TCQ->ITEM
			LS1->TES:=TCQ->TES
			LS1->ALMOX:=TCQ->ALMOX
			MsUnlock()
		Endif
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	Dbselectarea("LS1")
	Dbskip()
End

lEntrou:=.f.
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF Empty(LS1->PEDIDO) .or. Empty(LS1->ITEM)
		Msgbox("O Produto "+alltrim(LS1->PRODUTO)+" não possui pedido/Item!")
		lEntrou:=.T.
	Endif
	Dbskip()
End

If lEntrou
	Msgbox("Existem produtos sem o pedido/item!")
	Return
Endif

cRet:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Manipulando numero da nota fiscal									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cZeros
	cNota:=strzero(val(cNota),TamSX3("D1_DOC")[1])
Endif
cSpaco:=TamSX3("D1_DOC")[1]-len(alltrim(cNota))

cResp:=msgbox("Deseja gerar a pré-nota fiscal "+cNota+" agora?","Atenção...","YESNO")

If cResp
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se a pre nota ja existe									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF1")
	DbSetorder(2)
	Dbgotop()
	Dbseek(xFilial("SF1")+LS3->FORNEC+LS3->LOJA+alltrim(cNota)+Space(cSpaco))
	If Found() .and. SF1->F1_TIPO==LS3->TIPO // Alterado em 17/04/2014 por Luiz estava fixo "N" e foi alterado para cxTipoNFXML para mover xmls já importados  --> alterado em 28/08/2014 para LS3->TIPO pois o usuário pode ter trocado o tipo manualmente com duplo clique
		
		Msgbox("Nota fiscal já existe!","Atenção...","ALERT")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados do fornecedor													³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea(iif(LS3->TIPO $ "B/D","SA1","SA2")) //--> alterado em 28/08/2014 para LS3->TIPO pois o usuário pode ter trocado o tipo manualmente com duplo clique
		DbSetorder(1)
		Dbgotop()
		Dbseek(xFilial(iif(LS3->TIPO $ "B/D","SA1","SA2"))+LS3->FORNEC+LS3->LOJA) //--> alterado em 28/08/2014 para LS3->TIPO pois o usuário pode ter trocado o tipo manualmente com duplo clique
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nomeclatura dos arquivos											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML)
		_cFileNew:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(iif(LS3->TIPO $ "B/D",SA1->A1_CGC,SA2->A2_CGC))+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+"xml.imp"
		
		FRenameEx(_cFileOri,_cFileNew)
		__CopyFile(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.imp",_xPstSalv+_xcBarraDir+"importados"+_xcBarraDir)   // Alterado em 26/04/2012 para tratar compartilhamento de pasta entre empresas
		ferase(_cFileNew)

		Reclock("LS3",.F.)
		dbdelete()
		MsUnlock()
		
		DbSelectarea("LS3")
		Dbgotop()
		
		DbSelectarea("LS1")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			Reclock("LS1",.F.)
			dbdelete()
			MsUnlock()
			Dbskip()
		End
		
		DbSelectarea("LS5")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			Reclock("LS5",.F.)
			dbdelete()
			MsUnlock()
			Dbskip()
		End
		
		PROCESS()
		oPedido:end()
		Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravando pre nota entrada											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgRun("Gerando pré nota entrada No.:"+cNota,,{||PRENOTA()})
	cNotaAtu:=cNota
	
	If cRet
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravando amarracao produto x fornecedor								³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("LS1")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizando NCM do produto de acordo com o XML do fornecedor		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF !Empty(LS1->NCM)
				DbSelectarea("SB1")
				DbSetorder(1)
				Dbgotop()
				Dbseek(xFilial("SB1")+LS1->PRODUTO)
				If Found()
					Reclock("SB1",.F.)
					SB1->B1_POSIPI:=LS1->NCM
					MsUnlock()
				Endif
			Endif
			
			If !Empty(LS1->PRODFOR)
				DbSelectarea(iif(LS3->TIPO $ "B/D","SA7","SA5"))
				DbSetorder(1)
				Dbgotop()
				Dbseek(xFilial(iif(LS3->TIPO $ "B/D","SA7","SA5"))+LS3->FORNEC+LS3->LOJA+LS1->PRODUTO)
				If !Found()
						IF LS3->TIPO $ "B/D"
							Reclock("SA7",.T.)
							SA7->A7_FILIAL:=xFilial("SA7")
							SA7->A7_CLIENTE:=LS3->FORNEC
							SA7->A7_LOJA:=LS3->LOJA
							SA7->A7_CODCLI:=LS1->PRODFOR
							SA7->A7_PRODUTO:=LS1->PRODUTO
							SA7->A7_DESCCLI:=SUBSTR(POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_DESC"),1,30)
							//SA7->A7_NOMEFOR:=POSICIONE("SA1",1,xFilial("SA1")+LS3->FORNEC+LS3->LOJA,"A1_NREDUZ")  //Alterado LS2->LOJA para LS3->LOJA por Luiz em 27/03/2012
							MsUnlock()						
						ELSE
							Reclock("SA5",.T.)
							SA5->A5_FILIAL:=xFilial("SA5")
							SA5->A5_FORNECE:=LS3->FORNEC
							SA5->A5_LOJA:=LS3->LOJA
							SA5->A5_CODPRF:=LS1->PRODFOR
							SA5->A5_PRODUTO:=LS1->PRODUTO
							SA5->A5_NOMPROD:=SUBSTR(POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_DESC"),1,30)
							If lItem==.F.
								SA5->A5_NOMEFOR:=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS2->LOJA,"A2_NREDUZ")
							Else
								SA5->A5_NOMEFOR:=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_NREDUZ")
							Endif
							MsUnlock()
						ENDIF
				Else
					IF LS3->TIPO $ "B/D"
						Reclock("SA7",.F.)
						SA7->A7_CODCLI:=LS1->PRODFOR
						MsUnlock()					
					ELSE
						Reclock("SA5",.F.)
						SA5->A5_CODPRF:=LS1->PRODFOR
						MsUnlock()
					ENDIF
				Endif
			Endif
			DbSelectarea("LS1")
			Reclock("LS1",.F.)
			dbdelete()
			MsUnlock()
			Dbskip()
		End
		
		DbSelectarea("LS3")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados do fornecedor													³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea(iif(LS3->TIPO $ "B/D","SA1","SA2"))
		DbSetorder(1)
		Dbgotop()
		Dbseek(xFilial(iif(LS3->TIPO $ "B/D","SA1","SA2"))+LS3->FORNEC+LS3->LOJA)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nomeclatura dos arquivos											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML)
		_cFileNew:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(iif(LS3->TIPO $ "B/D",SA1->A1_CGC,SA2->A2_CGC))+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+"xml.imp"
		
		FRenameEx(_cFileOri,_cFileNew)
		__CopyFile(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.imp",_xPstSalv+_xcBarraDir+"importados"+_xcBarraDir)   // Alterado em 26/04/2012 para tratar compartilhamento de pasta entre empresas
		ferase(_cFileNew)
		
		
		Reclock("LS3",.F.)
		dbdelete()
		MsUnlock()
		
		DbSelectarea("LS3")
		Dbgotop()
		oPedido:end()
		
		Msgbox("Pré-Nota "+cNotaAtu+" gerada com sucesso!","Atenção...","INFO")
		
		PROCESS()
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apagando Flag dos pedidos											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea("LS1")
	DbSetorder(1)
	Dbgotop()
	While !Eof()
		IF !EMPTY(LS1->PEDIDO)
			Reclock("LS1",.F.)
			LS1->PEDIDO:=""
			LS1->ITEM:=""
			LS1->ALTERADO:=""
			MsUnlock()
		Endif
		Dbskip()
	End
	DbSelectarea("LS1")
	DbSetorder(1)
	Dbgotop()
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Corrigir produto													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function CORRIGE()
nSeek:=LS1->SEQ

If LS1->OK=="X"
	aCampos6:= {{"PRODUTO","C",TamSX3("C7_PRODUTO")[1],0 },;
	{"DESCRICAO","C",TamSX3("B1_DESC")[1],0 },;
	{"QE","N",TamSX3("B1_QE")[1],TamSX3("B1_QE")[2] },;
	{"SALDO","N",TamSX3("C7_QUANT")[1],TamSX3("C7_QUANT")[2] },;
	{"PEDIDO","C",TamSX3("C7_NUM")[1],0 },;
	{"BLQ","C",5,0 }}
	
	cArqTrab6  := CriaTrab(aCampos6)
	dbUseArea( .T.,, cArqTrab6, "LS4", if(.F. .OR. .F., !.F., NIL), .F. )
	IndRegua("LS4",cArqTrab6,"DESCRICAO",,,)
	dbSetIndex( cArqTrab6 +OrdBagExt())
	dbSelectArea("LS4")
	
	lTem:=.F.
	cQuery:=" SELECT B1_MSBLQL BLQ,B1_CODBAR CODBAR,B1_COD PRODUTO,B1_DESC DESCRICAO FROM "+RetSqlName('SB1')+" "
	cQuery:=cQuery + " WHERE B1_FILIAL='"+xFilial("SB1")+"' "
	cQuery:=cQuery + " AND B1_DESC LIKE '"+'%'+SUBSTR(LS1->DESCRICAO,1,4)+'%'+"' "
	cQuery:=cQuery + " AND B1_PROC='"+LS3->FORNEC+"' "
	cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		If Empty(cAlmox)  // Se armazém não fixado então deve sempre pegar B1_LOCPAD
			cAlmox:=Posicione("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_LOCPAD")
		Else
			If !Empty(cTiposSaldo) // Se foi informado o armazém, verifica se existe filtro de tipo
				 if !(Posicione("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_TIPO") $ cTiposSaldo) // Alterado em 08/09/2014 Somente pega o B1_LOCPAD se não
				 	  cAlmox:=Posicione("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_LOCPAD")
				 Endif
			Endif
		Endif
		
		Reclock("LS4",.T.)
		LS4->PRODUTO:=TCQ->PRODUTO
		IF "SAIU" $ TCQ->DESCRICAO
			LS4->DESCRICAO:=SUBSTR(TCQ->DESCRICAO,6,45)
		Else
			LS4->DESCRICAO:=TCQ->DESCRICAO
		Endif
		LS4->SALDO:=POSICIONE("SB2",2,xFilial("SB2")+cAlmox+TCQ->PRODUTO,"B2_QATU-B2_RESERVA-B2_QEMP")
		LS4->QE:=POSICIONE("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_QE")
		LS4->PEDIDO:=TEMPED(TCQ->PRODUTO)
		LS4->BLQ:=IIF(TCQ->BLQ=="1","Bloq.","Ativo")
		MsUnlock()
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	
	_cProduto:=Space(TamSX3("B1_COD")[1])
	
	aTitulo6 := {}
	AADD(aTitulo6,{"BLQ","Sit."})
	AADD(aTitulo6,{"PRODUTO","Produto",_xPicb1cod}) //Acrescentado em 21/08/2012 o x3picture
	AADD(aTitulo6,{"DESCRICAO","Descrição"})
	AADD(aTitulo6,{"QE","Qtd.Emb.",_xPicb1qe})
	AADD(aTitulo6,{"SALDO","Saldo Atual","@E 999,999,999.99"})
	AADD(aTitulo6,{"PEDIDO","Possui Pedido?"})
	
	DbSelectarea("LS4")
	Dbgotop()
	
	_cFiltrox:=SUBSTR(LS1->DESCRICAO,1,4)+space(30)
	lCheck1:=.F.
	
	@ 120,040 TO 450,880 DIALOG oAmarra TITLE "Produto do fornecedor..."
	@ 005,005 say LS1->DESCRICAO SIZE 200,40 FONT oFont1 OF oAmarra PIXEL
	@ 020,005 TO 140,417 BROWSE "LS4" OBJECT OBRWX FIELDS aTitulo6
	OBRWX:OBROWSE:bLDblClick   := {|| SELECIONA(LS4->PRODUTO,2) }
	OBRWX:oBrowse:oFont := TFont():New ("Arial", 07, 18)
	
	@ 005,170 say "Filtro (ex.: CAIXA;1KG )" SIZE 200,40 FONT oFont1 OF oAmarra PIXEL COLOR CLR_HRED  // alterado em 23/08/2012 estava ,210 alterei para coluna 170 para adicionar o texto ferente a dica do ; 
	@ 005,230 get _cFiltrox SIZE 70,20 Picture "@!" Valid xValidTxtFiltro(_cFiltrox)
	@ 005,300 BUTTON "_Filtrar" SIZE 35,10 ACTION MsgRun("Processando produtos...",,{||FILTRE()})
	If cPedCom //.and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
		@ 005,340 CHECKBOX "Somente com Pedidos" VAR lCheck1
	Endif
	@ 150,010 BUTTON "Reativar Produto" SIZE 60,12 ACTION DESBLOQ()
	ACTIVATE DIALOG oAmarra CENTER
	
	Dbselectarea("LS4")
	dbCloseArea("LS4")
	fErase( cArqTrab6+ ".DBF" )
	fErase( cArqTrab6+ OrdBagExt() )
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Corrigir produtos encontrados automaticamente						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(LS1->OK) .OR. LS1->OK=="O"
	SELECIONA(LS1->PRODUTO,1)
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retirar aspas para não causar erro em select no botão filtrar	  	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function xValidTxtFiltro()
Local lxret 	:= .t.
Local ix 		:= 1
	for ix = 1 to len(_cFiltrox)
		If substr(_cFiltrox,ix,1) = "'"
			lxret := .f.
			MsgStop("Não é permitido DIGITAR aspas no texto a filtrar. Retire as aspas e tente novamente!","IMPXML.PRW") 
		Endif
	next ix   
Return(lxret)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processando arquivos												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function XML()
Private _oXml    := NIL
Private cError    := ''
Private cWarning := ''
nXmlStatus := XMLError()
cFile:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(_aXML[i,1]))
oXml := XmlParserFile(cFile,"_",@cError, @cWarning )
lTipo:=3

cxTipoNFXML := '' // Adicionado por Luiz em 27/08/2014 devido à permissão de troca do tipo de importação da nota

If ALLTRIM(TYPE("oxml:_NFE:_INFNFE"))=="O"
	lTipo:=1
Endif
If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE"))=="O"
	lTipo:=2
Endif


//início da parte adicionada em 18/08/2014 para reconhecer a versão do XML
If lTipo <> 3
	If lTipo ==2 //com NfeProc
		_xVersaoXML:=oxml:_NFEPROC:_NFE:_INFNFE:_VERSAO:TEXT
	Else
		_xVersaoXML:=oxml:_NFE:_INFNFE:_VERSAO:TEXT
	Endif
EndIf
//início da parte adicionada em 18/08/2014 para reconhecer a versão do XML

If Empty(@cError) .and. lTipo<>3
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Com _NFEPROC														³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTipo==2
		// Início parte adicionada por Luiz em 16/04/2012 para ser usada no Tratamento do ambiente da Nota
		cxAmbiente:=oxml:_NFEPROC:_PROTNFE:_INFPROT:_TPAMB:TEXT // Para usno no Tratamento do ambiente da Nota	(Adicionado por Luiz em 16/04/2012)
		cNota     :=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT //Adicionado por Luiz em 05/02/2015 para mostrar número correto na função RECUSAR()
		If cxAmbiente == "2" 
			Msgbox("Esta rotina não permite importação de notas fiscais (XML) emitidas em ambiente de homologação! " +;
			"O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1])) + " foi gerado em ambiente de homologação. " +;
			"Pressione OK para acessar a rotina para recusar este recebimento.","Recusar NF homologação","STOP")
			_cFornecedor:=''
			_cEmissao:=''
			nTotalNF:=0
			_cCNPJ:=''
			_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
			xlRecusa :=.t.
			RECUSAR()
			Return
		else
			xlRecusa :=.f.
		EndIF


		//If SUBSTR(alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT),1,1) $ "0/1/2/3/4/5/6/7/8/9"   //Comentado por Luiz em 20/04/2012
			//_cCNPJ2:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) //Comentado por Luiz em 03/07/2013 para tratamento nota para CPF
		//Endif
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ"))=="U"
			_cCNPJ2:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
		else
			_cCNPJ2:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
		Endif

		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ"))=="U"
			_cCNPJ:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT)
		else
			_cCNPJ:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)
		Endif
	
		cNota:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
		If Empty(cSerieNF)
			cSerie:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
			If cZeroSerie > 0  //Adicionado em 16/04/2015
				cSerie:=Right(Replicate("0",nxQtdDigF1SERIE)+Alltrim(cSerie),cZeroSerie)
			Endif
		Endif
		cNatOp:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
		if _xVersaoXML = "3.10"
			cEmissao:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
		else
			cEmissao:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DEMI:TEXT
		endif
		cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
		cChave:=ALLTRIM(SUBSTR(oxml:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,200))
		_xcNomEmit := alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT) // Adicionado por Luiz em 20/04/2012 para tratar Emitentes não cadastrados
		//pega o CFOP do primeiro item, pois na outra parte é processado novamente, mas somente quando possui mais de um item
		If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET"))#"A" //Se _DET não retornar tipo Array então a nota tem apenas um item
			If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF		
				If alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ Alltrim(_cCFOPsDEV)
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
				ElseIf alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
				Else
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
				EndIf
			EndIf
		ELSEIF ValType(XmlChildEx(oxml,"_CTEPROC")) == "O" .OR. ValType(XmlChildEx(oxml,"_CTE")) == "O"
			//Alteração Vinicius Fernandes - 29/02/16
			//tratamento para mover os XML de CTe para a pasta especifica
			cxTipoNFXML	:= "C"
		Else
			If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[1]:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
				If alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET[1]:_PROD:_CFOP:TEXT) $ Alltrim(_cCFOPsDEV)
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
				ElseIf alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET[1]:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
				Else
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Manipulando numero da nota fiscal									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If len(alltrim(cNota))<=6
			cNota:=strzero(val(cNota),6)
		Endif
		If cZeros
			cNota:=strzero(val(cNota),TamSX3("D1_DOC")[1])
		Endif
		nTam:=len(alltrim(cNota))
		cSpaco:=(TamSX3("D1_DOC")[1]-nTam)
		

		//Início da parte adicionada em 28/08/2014 para tratar se o XML for de uma nota de entrada (tpNF=0) e emitida por uma nota da própria empresa
		//então é formulário próprio e não precisa importar o XML sendo necessário mover o xml para a pasta de importados
		axCNPJsm0 := xChecaCNPJsm0(_cCNPJ,_cCNPJ2) // _cCNPJ=EMITENTE _cCNPJ2=DESTINATÁRIO
		_cxtpNF := oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_TPNF:TEXT
		//Final 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Empresa atual														³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Val(alltrim(_cCNPJ2))<>Val(alltrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
			_cCNPJ:=''
		Endif
		
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Sem _NFEPROC															³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		// Início parte adicionada por Luiz em 16/04/2012 para ser usada no Tratamento do ambiente da Nota
		cxAmbiente:=oxml:_NFE:_INFNFE:_IDE:_TPAMB:TEXT // Usado no Tratamento do ambiente da Nota	(Adicionado por Luiz em 16/04/2012)
		cNota:=oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT  //Adicionado por Luiz em 05/02/2015 para mostrar número correto na função RECUSAR()
		If cxAmbiente == "2" 
			Msgbox("Esta rotina não permite importação de notas fiscais (XML) emitidas em ambiente de homologação! " +;
			"Pressione OK para acessar a rotina para recusar este recebimento.","Recusar NF homologação","STOP")
			_cFornecedor:=''
			_cCNPJ:=''
			_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
			RECUSAR()
			Return
		EndIF
		
		//If SUBSTR(alltrim(oxml:_NFE:_INFNFE:_DEST:_IE:TEXT),1,1) $ "0/1/2/3/4/5/6/7/8/9" //Comentado por Luiz em 27/08/2012
			//_cCNPJ2:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)  //Comentado em 03/07/2013 para tratamento de Nfe com CPF no emitente ou destinatário
		//Endif
		
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ"))=="U"
			_cCNPJ2:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
		else
			_cCNPJ2:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT)
		Endif

		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_EMIT:_CNPJ"))=="U"
			_cCNPJ:=alltrim(oxml:_NFE:_INFNFE:_EMIT:_CPF:TEXT)
		else
			_cCNPJ:=alltrim(oxml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)
		Endif
		if _xVersaoXML = "3.10"		
			cEmissao:=oxml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
		Else
			cEmissao:=oxml:_NFE:_INFNFE:_IDE:_DEMI:TEXT
		Endif
		cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
		cNota:=oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT
		If Empty(cSerieNF)
			cSerie:=oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT
			If cZeroSerie > 0  //Adicionado em 16/04/2015
				cSerie:=Right(Replicate("0",nxQtdDigF1SERIE)+Alltrim(cSerie),cZeroSerie)
			Endif			
		Endif
		cNatOp:=oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT
		cChave:=ALLTRIM(SUBSTR(oxml:_NFE:_INFNFE:_ID:TEXT,4,200))
		_xcNomEmit := alltrim(oxml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT) // Adicionado por Luiz em 20/04/2012 para tratar Emitentes não cadastrados
		//pega o CFOP do primeiro item, pois na outra parte é processado novamente, mas somente quando possui mais de um item
		If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET"))#"A" //Se _DET não retornar tipo Array então a nota tem apenas um item
			If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
				If alltrim(oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ Alltrim(_cCFOPsDEV)
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
				ElseIf alltrim(oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
				Else
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
				EndIf
			EndIf
		Else
			If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[1]:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
				If alltrim(oxml:_NFE:_INFNFE:_DET[1]:_PROD:_CFOP:TEXT) $ Alltrim(_cCFOPsDEV)
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
				ElseIf alltrim(oxml:_NFE:_INFNFE:_DET[1]:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
				Else
					cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Manipulando numero da nota fiscal									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If len(alltrim(cNota))<=6
			cNota:=strzero(val(cNota),6)
		Endif
		If cZeros
			cNota:=strzero(val(cNota),TamSX3("D1_DOC")[1])
		Endif
		nTam:=len(alltrim(cNota))
		cSpaco:=(TamSX3("D1_DOC")[1]-nTam)
		
		//Início da parte adicionada em 28/08/2014 para tratar se o XML for de uma nota de entrada (tpNF=0) e emitida por uma nota da própria empresa
		//então é formulário próprio e não precisa importar o XML sendo necessário mover o xml para a pasta de importados
		axCNPJsm0 := xChecaCNPJsm0(_cCNPJ,_cCNPJ2) // _cCNPJ=EMITENTE _cCNPJ2=DESTINATÁRIO 
		_cxtpNF := oxml:_NFE:_INFNFE:_IDE:_TPNF:TEXT
		//Final 

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Empresa atual														³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Val(alltrim(_cCNPJ2))<>Val(alltrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
			_cCNPJ:=''
		Endif
 		
	Endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifico se a nota ja existe no sistema								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(_cCNPJ)
		DbSelectarea(iif(cxTipoNFXML $ "B/D","SA1","SA2"))
		DbSetorder(3)
		Dbgotop()
		Dbseek(xFilial(iif(cxTipoNFXML $ "B/D","SA1","SA2"))+_cCNPJ)
		If Found()
			dbSelectArea("SF1")
			DbSetorder(2)
			Dbgotop()
			Dbseek(xFilial("SF1")+iif(cxTipoNFXML $ "B/D",SA1->A1_COD+SA1->A1_LOJA,SA2->A2_COD+SA2->A2_LOJA)+alltrim(cNota)+Space(cSpaco))
			If (Found() .and. SF1->F1_TIPO==cxTipoNFXML) .or. (_cxtpNF == "0" .and. axCNPJsm0[1]) // Alterado em 17/04/2014 por Luiz estava fixo "N" e foi alterado para cxTipoNFXML para mover xmls já importados  // Adicionar o .or. para mover também para importados quando for nota de entrada (tpNF=0) e formulário próprio (CNPJ do emitente é de uma empresa do grupo) então indica que a nota já está na base de dados e não precisa importar XML
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Nomeclatura dos arquivos											³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1]))
				_cFileNew:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(_cCNPJ)+"-nf"+ALLTRIM(cNota)+"-"+ALLTRIM(cChave)+".xml.imp"
				FRenameEx(_cFileOri,_cFileNew)
				__CopyFile(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.imp",_xPstSalv+_xcBarraDir+"importados"+_xcBarraDir) // Alterado em em 26/04/2012 para tratar compartilhamento de pasta entre empresas
				ferase(_cFileNew)
				_cCNPJ:=''
				_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
			Endif
		Endif
	Endif
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nomeclatura dos arquivos											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ValType(XmlChildEx(oxml,"_CTEPROC")) == "O" .OR. ValType(XmlChildEx(oxml,"_CTE")) == "O"
		//Alteração Vinicius Fernandes - 29/02/16
		//tratamento para mover os XML de CTe para a pasta especifica
		_cFileNew	:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1]))
		cxTipoNFXML	:= "C"
		DIRXML		:= "XMLNFE\"
		DIRALER		:= "NEW\"						
		Copy File &_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1])) TO &(DIRXML+DIRALER+_xcBarraDir+lower(ALLTRIM(aXML[i,1])))
		ferase(_cFileNew)		
	ELSE
		_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1]))
		_cFileNew:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1]))+".err"
	
		FRenameEx(_cFileOri,_cFileNew)
		__CopyFile(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.err",_xPstSalv+_xcBarraDir+"corrompidos"+_xcBarraDir) // Alterado em em 26/04/2012 para tratar compartilhamento de pasta entre empresas
		ferase(_cFileNew)
	endif
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Pre nota entrada											 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function PRENOTA()
Local aCabec := {}
Local aItens := {}
Local aLinha := {}

Private lMsErroAuto := .f.
cRet:=.F.

DbSelectarea("LS1")
dbgotop()
_dEmissao:=STOD(LS1->EMISSAO)

/* ---Comentando este bloco de atualização do pedido onde poderia estar trocando a loja e a filial do pedido sem atualizar dados da SB2 
If cPedCom .and. (axCNPJsm0[1] == .F. .or. (axCNPJsm0[1] == .T. .and. !cIgnoraPCTransf)) //Adicionado por Luiz em 19/11/2014 para obrigar pedido de compras quando não for empresa do grupo (geralmente notas de transferência não precisa do pedido)  .and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
	cQuere:=" UPDATE "+RetSqlName('SC7')+" SET C7_LOJA='"+LS3->LOJA+"' WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_NUM='" + LS1->PEDIDO+"' AND D_E_L_E_T_=' ' "
	TCSQLEXEC(cQuere)
Endif
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Grava status no fornecedor que manda o XML					 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea(iif(LS3->TIPO $ "B/D","SA1","SA2"))
DbSetorder(1)
Dbgotop()
Dbseek(xFilial(iif(LS3->TIPO $ "B/D","SA1","SA2"))+LS3->FORNEC+LS3->LOJA)
If Found()
	IF LS3->TIPO $ "B/D"
		// NÃO TEM ESTE CAMPO STATUS NA SA1 - PRECISA VERIFICAR INCLUSIVE A APLICAÇÃO NA SA2
	ELSE
		Reclock("SA2",.F.)
		SA2->A2_STATUS:="1"
		MsUnlock()
	ENDIF
Endif

aadd(aCabec,{"F1_TIPO",LS3->TIPO})  // Alterado em 27/08/2012 para colocar o cxTipoNFXML para tratamento para reconhecer os tipos de operação (remessa para beneficiamento / devolução) --> Alterado em 06/08/2014 para campo da LS3 retirando o iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
aadd(aCabec,{"F1_SERIE",cSerie})
aadd(aCabec,{"F1_FORMUL","N"})
aadd(aCabec,{"F1_DOC",(cNota)})
aadd(aCabec,{"F1_EMISSAO",_dEmissao})
aadd(aCabec,{"F1_FORNECE",LS3->FORNEC})
aadd(aCabec,{"F1_LOJA",LS3->LOJA})
aadd(aCabec,{"F1_ESPECIE",cEspecie})
aadd(aCabec,{"F1_CHVNFE",LS3->CHAVE})
aadd(aCabec,{"F1_HORA",LEFT(TIME(),5)})

DbSelectarea("LS1")
DbSetorder(1)
Dbgotop()
While !Eof()
	_cPedido:=LS1->PEDIDO
	
	If LS1->DESCONTO>0
		_nPrecoU:=LS1->PRECO+IIF(LS1->QUANTIDADE <> 0,(LS1->DESCONTO/LS1->QUANTIDADE),0) // Alterado por Luiz em 10/04/2012 para poder evitar possível divisão por zero
		_nTotalIt:=(LS1->QUANTIDADE*_nPrecoU)
	Else
		_nPrecoU:=LS1->PRECO
		_nTotalIt:=LS1->TOTAL
	Endif
	
	aLinha := {}
	aadd(aLinha,{"D1_COD",LS1->PRODUTO,Nil})
	aadd(aLinha,{"D1_QUANT",LS1->QUANTIDADE,Nil})
	
	//Alterado por Luiz em 27/03/2012, adicionando if para checar se foi informado o pedido de compras, pois se o parâmetro estiver deixando importar 
	//sem associar o pedido de compras e não tiver associado o pedido, então vai evitar passar o número de pedido inválido se não tiver associado ao pedido existente
	If !Empty(LS1->PEDIDO+LS1->ITEM)
		aadd(aLinha,{"D1_PEDIDO",LS1->PEDIDO,Nil})
		aadd(aLinha,{"D1_ITEMPC",LS1->ITEM,Nil})
	EndIf

	//Adicionado em 09/09/2014 checagem final para saber se o almoxarifado está em branco até agora, então pega o B1_LOCAPAD
	if LS3->TIPO = "D"
	 	cAlmox := cAlmoxDEV
	else
		cAlmox := IIF(Empty(cAlmox),Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD"),cAlmox)
	endif
	
	aadd(aLinha,{"D1_VUNIT",_nPrecoU,Nil})
	aadd(aLinha,{"D1_TOTAL",_nTotalIt,Nil})
	aadd(aLinha,{"D1_VALDESC",LS1->DESCONTO,Nil})
	aadd(aLinha,{"D1_LOCAL",cAlmox,Nil})
	
	aadd(aItens,aLinha)
	DbSelectarea("LS1")
	Dbskip()
End

If !Empty(_cPedido) .and. cPedCom .and. (axCNPJsm0[1] == .F. .or. (axCNPJsm0[1] == .T. .and. !cIgnoraPCTransf)) //Adicionado por Luiz em 19/11/2014 para obrigar pedido de compras quando não for empresa do grupo (geralmente notas de transferência não precisa do pedido)  .and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
	DbSelectarea("SC7")
	DbSetorder(1)
	Dbgotop()
	Dbseek(xFilial("SC7")+_cPedido)
Endif

If Len(aCabec)>0 .and. Len(aItens)>0
	//MATA140(aCabec,aItens)
	MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, 3)    //Alterado por Luiz em 27/03/2012
Endif

If lMsErroAuto
	MostraErro()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gerando NDF para o fornecedor do valor excedido						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cNDF .and. cPedCom .and. (axCNPJsm0[1] == .F. .or. (axCNPJsm0[1] == .T. .and. !cIgnoraPCTransf)) //Adicionado por Luiz em 19/11/2014 para obrigar pedido de compras quando não for empresa do grupo (geralmente notas de transferência não precisa do pedido)  .and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
		_nExcedido:=VALORNDF()
		
		If _nExcedido>0
			cResp:=msgbox("Deseja gerar a NDF para o fornecedor no valor de R$ "+Transform(_nExcedido,x3Picture("D1_TOTAL")),"Atenção...","YESNO")
			If cResp
				NDF()
				Msgbox("NDF "+cNota+" gerada com sucesso!","Atenção...","INFO")
			Endif
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calculando o total do item na nota									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuere:=" UPDATE "+RetSqlName('SD1')+" SET D1_TOTAL=(D1_QUANT*D1_VUNIT) WHERE D1_FILIAL='"+xFilial("SD1")+"' AND D1_DOC='"+cNota+"' AND D1_FORNECE='"+LS3->FORNEC+"' AND D1_LOJA='"+LS3->LOJA+"' AND D1_SERIE='"+cSerie+"' "
	TCSQLEXEC(cQuere)
	cRet:=.T.
Endif
Return(cRet)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Alterar Pedido												 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function PEDIDOS()
If LS2->OK=="X"
	Msgbox("Não é necessário atualizar este pedido!","Atenção...","ALERT")
	Return
Endif

cPedido:=LS2->PEDIDO
cLoja:=LS2->LOJA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verifica se algum pedido ainda nao foi usado				 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("LS2")
Dbgotop()
While !Eof()
	IF 	LS2->OK=="X"
		Msgbox("Favor usar o Pedido "+LS2->PEDIDO,"Sem necessidade...","INFO")
		DbSelectarea("LS2")
		Dbgotop()
		Return
	Endif
	Dbskip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajustando o pedido com a nota										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cResp:=msgbox("Deseja atualizar o pedido "+cPedido+" com os itens faltantes?","Atenção...","YESNO")

If cResp .and. VerSenha(6) //-- Evento 6 - Alterar Pedido de Compras
	
	lEntrou:=.F.
	_nQtdIt:=0
	
	Dbselectarea("PRO")
	DbSetorder(1)
	Dbgotop()
	While !Eof()
		DbSelectarea("SC7")
		DbSetorder(4)
		Dbgotop()
		Dbseek(xFilial("SC7")+PRO->PRODUTO+cPedido)
		If !Found()
			Dbselectarea("SB1")
			DbSetorder(1)
			Dbgotop()
			Dbseek(xFilial("SB1")+PRO->PRODUTO)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Dados do pedido												 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery:=" SELECT C7_EMISSAO EMISSAO,C7_COND COND,MAX(C7_ITEM) ITEM FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_NUM='"+cPedido+"' AND D_E_L_E_T_=' ' GROUP BY C7_EMISSAO,C7_COND "
			TCQUERY cQuery NEW ALIAS "PED"
			DbSelectArea("PED")
			nItem:=strzero(val(PED->ITEM)+1,TamSX3("C7_ITEM")[1])
			_cCond:=PED->COND
			_dEmiss:=STOD(PED->EMISSAO)
			DbCloseArea("PED")
			
			Reclock("SC7",.T.)
			SC7->C7_FILIAL:=xFilial("SC7")
			SC7->C7_TIPO:=1
			SC7->C7_NUM:=cPedido
			SC7->C7_EMISSAO:=_dEmiss
			SC7->C7_FORNECE:=LS3->FORNEC
			SC7->C7_LOJA:=cLoja
			SC7->C7_CONTATO:=Posicione("SA2",1,xFilial("SA2")+LS3->FORNEC+cLoja,"A2_CONTATO")
			SC7->C7_COND:=_cCond
			SC7->C7_FILENT:=xFilial("SC7")
			SC7->C7_ITEM:=nItem
			SC7->C7_PRODUTO:=PRO->PRODUTO
			SC7->C7_UM:=SB1->B1_UM
			SC7->C7_SEGUM:=SB1->B1_SEGUM
			SC7->C7_DESCRI:=SUBSTR(SB1->B1_DESC,1,TamSX3("C7_DESCRI")[1])
			SC7->C7_QUANT:=PRO->QUANTIDADE
			SC7->C7_QTSEGUM:=IIF(SB1->B1_CONV <> 0 .AND. SB1->B1_TIPCONV = "D",(PRO->QUANTIDADE/SB1->B1_CONV),IIF(SB1->B1_CONV <> 0 .AND. SB1->B1_TIPCONV = "M",(PRO->QUANTIDADE*SB1->B1_CONV),0)) // Alterado em 10/04/2012 por Luiz pois estava errado SEM TRATAR O FATOR DE CONVERSAO (MULTIPLICADOR OU DIVISOR)
			SC7->C7_PRECO:=PRO->PRECO
			SC7->C7_TOTAL:=(PRO->QUANTIDADE*PRO->PRECO)
			SC7->C7_DATPRF:=_dEmiss
			SC7->C7_TES:=SB1->B1_TE
			SC7->C7_IPIBRUT:="B"
			SC7->C7_FLUXO:="S"
			SC7->C7_USER:=__CUSERID
			SC7->C7_TPOP:="F"
			SC7->C7_CONAPRO:="L"
			SC7->C7_MOEDA:=1
			SC7->C7_TPFRETE:="C"
			SC7->C7_OBS:=SUBSTR(AllTrim(SC7->C7_OBS) + "(INC. NF-E XML)",1,50)
			SC7->C7_PENDEN:="N"
			SC7->C7_POLREPR:="N"
			If Empty(cAlmoPed)
				SC7->C7_LOCAL:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
			Else
				SC7->C7_LOCAL:=cAlmoPed
			Endif
			MsUnlock()
			
			_nQtdIt:=_nQtdIt+1
			
			If Empty(cAlmox)
				cAlmox:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
			Else
				If !Empty(cTiposSaldo) // Se foi informado o armazém, verifica se existe filtro de tipo
				 	if !(Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_TIPO") $ cTiposSaldo) // Alterado em 08/09/2014 Somente pega o B1_LOCPAD se não
				 		cAlmox:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
				 	Endif
				 Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizado SB2 saldo de pedidos										³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectarea("SB2")
			DbSetorder(2)
			Dbgotop()
			Dbseek(xFilial("SB2")+cAlmox+PRO->PRODUTO)
			If Found()
				Reclock("SB2",.F.)
				SB2->B2_SALPEDI:=(SB2->B2_SALPEDI+PRO->QUANTIDADE)
				MsUnlock()
			Endif
			lEntrou:=.T.
		Else
			If (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)<PRO->QUANTIDADE
				_nTotal:=PRO->QUANTIDADE-(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)
				
				Reclock("SC7",.F.)
				SC7->C7_QUANT:=(SC7->C7_QUANT+_nTotal)
				SC7->C7_OBS:= SUBSTR(AllTrim(SC7->C7_OBS) + "(ALT. NF-E XML)",1,50)
				MsUnlock()
				
				Reclock("SC7",.F.)
				SC7->C7_TOTAL:=(SC7->C7_QUANT*SC7->C7_PRECO)
				MsUnlock()
				
				If Empty(cAlmox)
					cAlmox:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
				Else
					If !Empty(cTiposSaldo) // Se foi informado o armazém, verifica se existe filtro de tipo
						 if !(Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_TIPO") $ cTiposSaldo) // Alterado em 08/09/2014 Somente pega o B1_LOCPAD se não
						 	  cAlmox:=Posicione("SB1",1,xFilial("SB1")+PRO->PRODUTO,"B1_LOCPAD")
						 Endif
					Endif
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualizado SB2 saldo de pedidos										³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectarea("SB2")
				DbSetorder(2)
				Dbgotop()
				Dbseek(xFilial("SB2")+cAlmox+PRO->PRODUTO)
				If Found()
					Reclock("SB2",.F.)
					SB2->B2_SALPEDI:=(SB2->B2_SALPEDI+_nTotal)
					MsUnlock()
				Endif
				lEntrou:=.T.
			Endif
		Endif
		Dbselectarea("PRO")
		Dbskip()
	End
	
	If lEntrou
		Msgbox("Pedido atualizado com sucesso!","Atenção...","INFO")
	Endif
	
	DbSelectarea("LS2")
	Dbgotop()
	While !Eof()
		IF LS2->PEDIDO==cPedido
			Reclock("LS2",.F.)
			LS2->VALIDO:=nTotIt
			LS2->OK:="X"
			LS2->QTDIT:=(LS2->QTDIT+_nQtdIt)
			LS2->ITENS:=(LS2->ITENS+_nQtdIt)
			Msunlock()
		Endif
		Dbskip()
	End
ElseIf !VerSenha(6) //-- Evento 6 - Alteração de pedido de compras
		Msgbox("Usuário sem permissão para alterar pedido de compras!","Atenção...","STOP")
Endif
DbSelectarea("LS2")
Dbgotop()
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Novo Pedido													 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function NEWPED()
Local aCab2 :={}
Local aItem2:={}

PRIVATE lMsErroAuto := .F.

If !VerSenha(6) //-- Evento 6 - Alteração de pedido de compras
	Msgbox("Usuário sem permissão para alterar pedido de compras! Portanto, não vai ser possível também incluir pedido de compras pela rotina IMPXML.","Atenção...","STOP")
	Return
Endif

lAchei:=.F.
nOpc:=3

_nItens:=0
_cCond:=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_COND")
If Empty(_cCond)
	_cCond:="001"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar Status da Gravacao										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_lGrava:=Getmv("MV_XGRVPED")

If !Empty(Alltrim(_lGrava))
	ALERT("Atencao!!!, O Usuario "+_lGrava+" Esta concretizando um Pedido de Compra, Aguarde...")
	Return
Else
	DbSelectArea("SX6")
	DbgoTop()
	While ! eof()
		If Alltrim(SX6->X6_VAR)=="MV_XGRVPED" .and. SX6->X6_FIL==xFilial("SC7")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD:="NF-ELETRONICA-"+_cUsuario
			MsUnlock()
		Endif
		DbSkip()
	End
Endif

/* Comentado por Luiz em 27/03/2012 para utilizar padrão getx8num()
cQuery:=" SELECT MAX(C7_NUM) PEDIDO FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' AND D_E_L_E_T_=' ' "
TCQUERY cQuery NEW ALIAS "PED"
DbSelectArea("PED")
cNumPed:=STRZERO(VAL(PED->PEDIDO)+1,6)
DbCloseArea("PED")
*/

cNumPed:= GetSX8Num("SC7","C7_NUM")  // Adicionado por Luiz em 27/03/2012

DbSelectarea("LS1")
Dbgotop()
While !Eof()
	
	If Empty(cAlmoPed)
		_cAlmoxPed:=Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
	Else
		_cAlmoxPed:=cAlmoPed
	Endif
	
	aCab2:={{"C7_NUM",cNumPed,Nil},;
	{"C7_EMISSAO" ,dDataBase,Nil},;
	{"C7_FORNECE" ,LS3->FORNEC,Nil},;
	{"C7_LOJA"    ,LS3->LOJA,Nil},;
	{"C7_CONTATO" ,Posicione("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_CONTATO"),Nil},;
	{"C7_COND"    ,_cCond,Nil},;
	{"C7_FILENT" ,xFilial("SC7"),Nil}}
	
	aItem3:={}
	aItem3:={{"C7_ITEM",Strzero(_nItens+1,TamSX3("C7_ITEM")[1]),Nil},;
	{"C7_PRODUTO",LS1->PRODUTO,Nil},;
	{"C7_QUANT" ,LS1->QUANTIDADE,Nil},;
	{"C7_PRECO" ,LS1->PRECO,Nil},;
	{"C7_TOTAL" ,LS1->TOTAL,Nil},;
	{"C7_DATPRF" ,dDataBase,Nil},;
	{"C7_TES"    ,POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_TE"),Nil},;
	{"C7_FLUXO" ,"S",Nil},;
	{"C7_USER" ,__CUSERID,Nil},;
	{"C7_OBS"  ,"NF-ELETRONICA"			,Nil},;
	{"C7_LOCAL",_cAlmoxPed,Nil}}
	
	aadd(aItem2,aItem3)
	_nItens:=_nItens+1
	DbSelectarea("LS1")
	Dbskip()
End
DbSelectarea("SC7")
If Len(aItem2)>0 .and. Len(aCab2)>0
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab2,aItem2,nOpc)
Endif

If lMsErroAuto
	RollBackSx8()  // Adicionado por Luiz em 27/03/2012
	mostraerro()
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Liberando a Gravacao de um pedido para outro usuario				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SX6")
	DbgoTop()
	While ! eof()
		If Alltrim(SX6->X6_VAR)=="MV_XGRVPED" .and. SX6->X6_FIL==xFilial("SC7")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD:=""
			MsUnlock()
		Endif
		DbSkip()
	End
	ConfirmSX8() // Adicionado por Luiz em 27/03/2012
	Msgbox("Pedido "+cNumped+" Gerado com sucesso! Solicite a liberação do mesmo para que a pré-nota possa ser gerada!","Atenção...","INFO")
EndIf
DbSelectarea("LS1")
Dbgotop()
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Novo Pedido por item										 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function NEWPED2()
Local aCab2 :={}
Local aItem2:={}
PRIVATE lMsErroAuto := .F.

If !VerSenha(6) //-- Evento 6 - Alteração de pedido de compras
	Msgbox("Usuário sem permissão para alterar pedido de compras! Portanto, não vai ser possível também incluir pedido de compras pela rotina IMPXML.","Atenção...","STOP")
	Return
Endif

lAchei:=.F.
nOpc:=3

_nItens:=0
_cCond:=POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_COND")
If Empty(_cCond)
	_cCond:="001"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificar Status da Gravacao										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_lGrava:=Getmv("MV_XGRVPED")

If ! Empty(Alltrim(_lGrava))
	ALERT("Atencao!!!, O Usuario "+_lGrava+" Esta concretizando um Pedido de Compra, Aguarde...")
	Return
Else
	DbSelectArea("SX6")
	DbgoTop()
	While ! eof()
		If Alltrim(SX6->X6_VAR)=="MV_XGRVPED" .and. SX6->X6_FIL==xFilial("SC7")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD:="NF-ELETRONICA-"+_cUsuario
			MsUnlock()
		Endif
		DbSkip()
	End
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Numero do Pedido de compra											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/* Comentado por Luiz em 27/03/2012 para utilizar padrão getx8num()
cQuery:=" SELECT MAX(C7_NUM) PEDIDO FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' AND D_E_L_E_T_=' ' "
TCQUERY cQuery NEW ALIAS "PED"
DbSelectArea("PED")
cNumPed:=STRZERO(VAL(PED->PEDIDO)+1,6)
DbCloseArea("PED")
*/

cNumPed:= GetSX8Num("SC7","C7_NUM")  // Adicionado por Luiz em 27/03/2012

DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF ALLTRIM(LS1->PEDIDO)=="CRIAR"
		
		If Empty(cAlmoPed)
			_cAlmoxPed:=Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
		Else
			_cAlmoxPed:=cAlmoPed
		Endif
		
		aCab2:={{"C7_NUM",cNumPed,Nil},;
		{"C7_EMISSAO" ,dDataBase,Nil},;
		{"C7_FORNECE" ,LS3->FORNEC,Nil},;
		{"C7_LOJA"    ,LS3->LOJA,Nil},;
		{"C7_CONTATO" ,Posicione("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_CONTATO"),Nil},;
		{"C7_COND"    ,_cCond,Nil},;
		{"C7_FILENT" ,xFilial("SC7"),Nil}}
		
		aItem3:={}
		aItem3:={{"C7_ITEM",Strzero(_nItens+1,TamSX3("C7_ITEM")[1]),Nil},;
		{"C7_PRODUTO",LS1->PRODUTO,Nil},;
		{"C7_QUANT" ,LS1->QUANTIDADE,Nil},;
		{"C7_PRECO" ,LS1->PRECO,Nil},;
		{"C7_TOTAL" ,LS1->TOTAL,Nil},;
		{"C7_DATPRF" ,dDataBase,Nil},;
		{"C7_TES"    ,POSICIONE("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_TE"),Nil},;
		{"C7_FLUXO" ,"S",Nil},;
		{"C7_USER" ,__CUSERID,Nil},;
		{"C7_OBS"  ,"NF-ELETRONICA"			,Nil},;
		{"C7_LOCAL",_cAlmoxPed,Nil}}
		aadd(aItem2,aItem3)
		
		Reclock("LS1",.F.)
		LS1->PEDIDO:=cNumPed
		LS1->ITEM:=Strzero(_nItens+1,TamSX3("C7_ITEM")[1])
		
		_nItens:=_nItens+1
		MsUnlock()
	Endif
	DbSelectarea("LS1")
	Dbskip()
End
DbSelectarea("SC7")
If Len(aItem2)>0 .and. Len(aCab2)>0
	MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab2,aItem2,nOpc)
Endif

If lMsErroAuto  
	RollBackSx8()  // Adicionado por Luiz em 27/03/2012
// Inicio parte adicionada por Luiz em 13/06/2011
	DbSelectarea("LS1")
	Dbgotop()
	While !Eof()
		If ALLTRIM(LS1->PEDIDO)==cNumPed
			Reclock("LS1",.F.)
			LS1->PEDIDO:=""
			LS1->ITEM:=""
			MsUnlock()
		EndIf
		DbSelectarea("LS1")
		Dbskip()
	End
    Msgbox("Pedido "+cNumped+" NÃO gerado! Favor analise LOG a seguir! Procure identificar o motivo, normalmente podem ser cadastro bloqueado para uso!","Atenção...","STOP")
// final parte adicionada por Luiz em 13/06/2011
	mostraerro()
Else
	ConfirmSX8() // Adicionado por Luiz em 27/03/2012
	Msgbox("Pedido "+cNumped+" Gerado com sucesso! Solicite a liberação do mesmo para que a pré-nota possa ser gerada!","Atenção...","INFO")
EndIf
DbSelectarea("LS1")
Dbgotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Liberando a Gravacao de um pedido para outro usuario				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX6")
DbgoTop()
While ! eof()
	If Alltrim(SX6->X6_VAR)=="MV_XGRVPED" .and. SX6->X6_FIL==xFilial("SC7")
		RecLock("SX6",.F.)
		SX6->X6_CONTEUD:=""
		MsUnlock()
	Endif
	DbSkip()
End

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processando arquivo													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function PROCESS()
private _oXml    := NIL
private cError    := ''
private cWarning := ''

bMostMsgCodBarras:=.F.  //Adicionado em 27/08/2012 para tratar mensagem de código de barras duplicado (zerar a cada xml lido)
cMensCodBarrasD:=""
cCodProAnterior:=""

lRefaz:=.F.

If xlRecusa
	Return
Endif

If LS3->(eof()) 
	msgbox("Não existem notas fiscais eletrônicas para serem importadas!")
	OBRWI:obrowse:refresh()
	OBRWP:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	OBRWP:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")
	Return
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se existe a nota fiscal									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !file(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(LS3->XML))
	msgbox("Este arquivo já foi processado por outro usuário!","PROCESS() - Atenção...","ALERT")
	Reclock("LS3",.F.)
	dbdelete()
	MsUnlock()
	
	DbSelectarea("LS3")
	Dbgotop()
	PROCESS()
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se foi alterado algum item									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lAltera:=.F.
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF LS1->ALTERADO=="S"
		_cChave:=LS1->NOME+LS1->NOTA
		lAltera:=.T.
	Endif
	Dbskip()
End

IF lAltera
	cResp:=msgbox("Deseja perder todas as alterações realizadas?","Atenção...","YESNO")
	
	If cResp==.F.
		DbSelectarea("LS3")
		Dbsetorder(1)
		dbgotop()
		Dbseek(_cChave)
		
		DbSelectarea("LS1")
		Dbgotop()
		OBRWI:obrowse:refresh()
		OBRWP:obrowse:refresh()
		OBRWI:obrowse:setfocus()
		OBRWP:obrowse:setfocus()
		ObjectMethod(oTela,"Refresh()")
		Return
	Endif
Endif

nXmlStatus := XMLError()
cFile:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(LS3->XML))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apagando dados da tabela temporaria									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("LS1")
Dbsetorder(1)
Dbgotop()
While !Eof()
	Reclock("LS1",.F.)
	dbdelete()
	MsUnlock()
	Dbskip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apagando produtos temporarios										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("LS5")
Dbsetorder(1)
Dbgotop()
While !Eof()
	Reclock("LS5",.F.)
	dbdelete()
	MsUnlock()
	Dbskip()
End

oXml := XmlParserFile(cFile,"_",@cError, @cWarning )
aCols:={}
nTotIt:=0
nTotalNF:=0

IF ALLTRIM(TYPE("oxml:_NFE:_INFNFE"))=="O"
	lTipo:=1
Else
	lTipo:=2
Endif

//início da parte adicionada em 18/08/2014 para reconhecer a versão do XML
If lTipo <> 3
	If lTipo ==2 //com NfeProc
		_xVersaoXML:=oxml:_NFEPROC:_NFE:_INFNFE:_VERSAO:TEXT
	Else
		_xVersaoXML:=oxml:_NFE:_INFNFE:_VERSAO:TEXT
	Endif
EndIf
//final da parte adicionada em 18/08/2014 para reconhecer a versão do XML

//nDescont:=0  //Comentado em 16/04/2015 para corrigir problema com desconto ao importar sendo colocando dentro do For/Next dos itens

If ( nXmlStatus == XERROR_SUCCESS )
	
	If lTipo==2
		aCols:=aClone(oXml:_NFEPROC:_NFE:_INFNFE:_DET)
	Else
		aCols:=aClone(oXml:_NFE:_INFNFE:_DET)
	Endif
	
	If aCols==NIL
		nItens:=1
	Else
		nItens:=len(aCols)
	Endif
	
	For i:=1 to nItens
		nDescont:=0 //Adicionado em 16/04/2015, pois estava fora do For/Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Com _NFEPROC														³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTipo==2
			
			If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT"))=="C"
				_cMensag:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
			Endif
			
			If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT"))=="C" //Adicionado por Luiz em 27/08/2014 
				_cMensaginfAdFisco:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT)
			Endif
			
			If nItens>1
				cCodbar :=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CEAN:TEXT
				cProdFor:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT
				nQuant	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT)
				xDesc	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT"))=="C"
					cNCM	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT
				Endif
				nPreco	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VUNCOM:TEXT)
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT"))=="C"
					nDescont:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT)
				Endif
				nTotal	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT)
				cNota	:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
				If Empty(cSerieNF)
					cSerie:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
					If cZeroSerie > 0  //Adicionado em 16/04/2015
						cSerie:=Right(Replicate("0",nxQtdDigF1SERIE)+Alltrim(cSerie),cZeroSerie)
					Endif					
				Endif
				cNatOp  :=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
				cUM		:=oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_UCOM:TEXT
				if _xVersaoXML = "3.10"
					cEmissao:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
				else
					cEmissao:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DEMI:TEXT
				endif
				If !(ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE"))=="U")
					If SUBSTR(alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT),1,1) $ "0/1/2/3/4/5/6/7/8/9"
						//_cCNPJ2	:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) //Alterado em 27/08/2012 pois _cCNPJ2: é empresa destino  --> comentado e alterado para linha de baixo em 03/07/2013 por Luiz para tratamento do CPF
						_cCNPJ2 := IIF(ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ"))=="U",alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT),alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT))
						//_cEmpresa:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) //--> comentado e alterado para linha de baixo em 03/07/2013 por Luiz para tratamento do CPF
						//lsfm retirar _cEmpresa := IIF(ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ"))=="U",alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT),alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT))
					Else
						if AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT) <> AllTrim(_cxInscric)
							//Início tratamento adicionado por Luiz em 20/04/2012 para poder ficar ciente que tem XML com destinatário da empresa corrente no sistema mas onde o fornecedor emitente ainda não existe na SA2
								//isso fazia com que os XMLs ficassem sempre na pasta a serem importados sem o conhecimento do usuário
							if Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
								_xnOpcAvis := Aviso("Inscrição Estadual inválida", "O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML) +" " +;
								"do emitente " + ALLTRIM(LS3->NOME) + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
								"Nota: " + ALLTRIM(LS3->NOTA) +CHR(13)+CHR(10) +;
								"Emissão: " + ALLTRIM(LS3->EMISSAO) +CHR(13)+CHR(10) +;
								"Chave: " + ALLTRIM(LS3->CHAVE) +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
								"Tem como destinatário o CNPJ " + _cCNPJ2 + " desta empresa em uso, mas veio com a Inscrição estadual " + AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT) + " diferente do cadastro desta empresa em uso." +;
								"Será necessário efetuar recusar esta nota para que o fornecedor/cliente possa emitir uma nota fiscal com os dados corretos antes de importar este XML. " +;
								"Você pode se desejar visualizar este XML agora para observar maiores informações sobre esta nota?" , {"Recusar","Visualizar"} ,3)
								If _xnOpcAvis == 2
									MsgRun("Acessando arquivo XML ...",,{||SEFAZ()})
								Else
									_cFornecedor:=''
									_cCNPJ:=''
									_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
									RECUSAR()
									Return
								Endif
							Endif
							// Final
	                    else
							_cCNPJ2	:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT) //Alterado em 27/08/2012 pois _cCNPJ2: é empresa destino
							//lsfm retirar _cEmpresa:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
						Endif
					Endif
				Else
					if Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
						_xnOpcAvis := Aviso("Inscrição Estadual inválida", "O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML) +" " +;
						"do emitente " + ALLTRIM(LS3->NOME) + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
						"Nota: " + ALLTRIM(LS3->NOTA) +CHR(13)+CHR(10) +;
						"Emissão: " + ALLTRIM(LS3->EMISSAO) +CHR(13)+CHR(10) +;
						"Chave: " + ALLTRIM(LS3->CHAVE) +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
						"Tem como destinatário o CNPJ " + _cCNPJ2 + " desta empresa em uso, mas NÃO veio com a Inscrição estadual " + AllTrim(_cxInscric) + " que consta no cadastro desta empresa em uso." +;
						"Escolha recusar se deseja solicitar que o fornecedor/cliente possa emitir uma nota fiscal com os dados corretos antes de importar este XML. " +;
						"Você pode se desejar visualizar este XML agora para observar maiores informações sobre esta nota?" , {"Recusar","Visualizar","OK"} ,3)
						If _xnOpcAvis == 2
							MsgRun("Acessando arquivo XML ...",,{||SEFAZ()})
						ElseIf _xnOpcAvis == 1
							_cFornecedor:=''
							_cCNPJ:=''
							_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
							RECUSAR()
							Return
						Endif
					Endif
				EndIf
				cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
				cProd:=''
				_xcNomEmit := alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT) // Adicionado por Luiz em 20/04/2012 para tratar Emitentes não cadastrados
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET"))#"A" //Se _DET não retornar tipo Array então a nota tem apenas um item
					If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF					
						If alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ Alltrim(_cCFOPsDEV)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
						ElseIf alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
						Else
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
						EndIf
					EndIf				
				Else
					If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF					
						If alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT) $ Alltrim(_cCFOPsDEV)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
						ElseIf alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
						Else
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
						EndIf
					EndIf
				EndIf
			Else
				cCodbar :=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
				cProdFor:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
				nQuant	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT"))=="C"
					nDescont:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT)
				Endif
				xDesc	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT"))=="C"
					cNCM	:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT
				Endif
				nPreco	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VUNCOM:TEXT)
				nTotal	:=val(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT)
				cNota	:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT
				If Empty(cSerieNF)
					cSerie:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
					If cZeroSerie > 0  //Adicionado em 16/04/2015
						cSerie:=Right(Replicate("0",nxQtdDigF1SERIE)+Alltrim(cSerie),cZeroSerie)
					Endif
				Endif
				cNatOP	:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT
				if _xVersaoXML = "3.10"
					cEmissao:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
				else
					cEmissao:=oxml:_NFEPROC:_NFE:_INFNFE:_IDE:_DEMI:TEXT
				endif
				cUM		:=oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT
				If !(ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE"))=="U")
					If SUBSTR(alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT),1,1) $ "0/1/2/3/4/5/6/7/8/9"
						//_cCNPJ2	:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) //Alterado em 27/08/2012 pois _cCNPJ2: é empresa destino  --> comentado e alterado para linha de baixo em 03/07/2013 por Luiz para tratamento do CPF
						_cCNPJ2	:=IIF(ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ"))=="U",alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT),alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT))
						//_cEmpresa:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) //--> comentado e alterado para linha de baixo em 03/07/2013 por Luiz para tratamento do CPF
						//lsfm retirar _cEmpresa := IIF(ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ"))=="U",alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT),alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT))					
					Else
						if AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT) <> AllTrim(_cxInscric)
							//Início tratamento adicionado por Luiz em 20/04/2012 para poder ficar ciente que tem XML com destinatário da empresa corrente no sistema mas onde o fornecedor emitente ainda não existe na SA2
								//isso fazia com que os XMLs ficassem sempre na pasta a serem importados sem o conhecimento do usuário
							if Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
								_xnOpcAvis := Aviso("Inscrição Estadual inválida", "O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML) +" " +;
								"do emitente " + ALLTRIM(LS3->NOME) + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
								"Nota: " + ALLTRIM(LS3->NOTA) +CHR(13)+CHR(10) +;
								"Emissão: " + ALLTRIM(LS3->EMISSAO) +CHR(13)+CHR(10) +;
								"Chave: " + ALLTRIM(LS3->CHAVE) +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
								"Tem como destinatário o CNPJ " + _cCNPJ2 + " desta empresa em uso, mas veio com a Inscrição estadual " + AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT) + " diferente do cadastro desta empresa em uso." +;
								"Será necessário efetuar recusar esta nota para que o fornecedor/cliente possa emitir uma nota fiscal com os dados corretos antes de importar este XML. " +;
								"Você pode se desejar visualizar este XML agora para observar maiores informações sobre esta nota?" , {"Recusar","Visualizar"} ,3)
								If _xnOpcAvis == 2
									MsgRun("Acessando arquivo XML ...",,{||SEFAZ()})
								Else
									_cFornecedor:=''
									_cCNPJ:=''
									_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
									RECUSAR()
									Return
								Endif
							Endif
							// Final
	                    else
							_cCNPJ2	:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT) //Alterado em 27/08/2012 pois _cCNPJ2: é empresa destino
							//lsfm retirar _cEmpresa:=alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT)
						EndIf
					Endif
				Else
					if Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
						_xnOpcAvis := Aviso("Inscrição Estadual inválida", "O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML) +" " +;
						"do emitente " + ALLTRIM(LS3->NOME) + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
						"Nota: " + ALLTRIM(LS3->NOTA) +CHR(13)+CHR(10) +;
						"Emissão: " + ALLTRIM(LS3->EMISSAO) +CHR(13)+CHR(10) +;
						"Chave: " + ALLTRIM(LS3->CHAVE) +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
						"Tem como destinatário o CNPJ " + _cCNPJ2 + " desta empresa em uso, mas NÃO veio com a Inscrição estadual " + AllTrim(_cxInscric) + " que consta no cadastro desta empresa em uso." +;
						"Escolha recusar se deseja solicitar que o fornecedor/cliente possa emitir uma nota fiscal com os dados corretos antes de importar este XML. " +;
						"Você pode se desejar visualizar este XML agora para observar maiores informações sobre esta nota?" , {"Recusar","Visualizar","OK"} ,3)
						If _xnOpcAvis == 2
							MsgRun("Acessando arquivo XML ...",,{||SEFAZ()})
						ElseIf _xnOpcAvis == 1
							_cFornecedor:=''
							_cCNPJ:=''
							_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
							RECUSAR()
							Return
						Endif
					Endif
				EndIf
				cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
				cProd:=''
				_xcNomEmit := alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT) // Adicionado por Luiz em 20/04/2012 para tratar Emitentes não cadastrados
				If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET"))#"A" //Se _DET não retornar tipo Array então a nota tem apenas um item
					If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF					
						If alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsDEV)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
						ElseIf alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
						Else
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
						EndIf
					EndIf
				Else
					If ALLTRIM(TYPE("oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF					
						If alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsDEV)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
						ElseIf alltrim(oxml:_NFEPROC:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
						Else
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
						EndIf
					EndIf
				EndIf
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sem _NFEPROC														³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT"))=="C"
				_cMensag:=alltrim(oxml:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT)
			Endif

			If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT"))=="C" //Adicionado por Luiz em 27/08/2014 
				_cMensaginfAdFisco:=alltrim(oxml:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT)
			Endif
			
			
			If nItens>1
				cCodbar :=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CEAN:TEXT
				cProdFor:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CPROD:TEXT
				nQuant	:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_QCOM:TEXT)
				xDesc	:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_XPROD:TEXT
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT"))=="C"
					cNCM	:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_NCM:TEXT
				Endif
				cUM		:=oxml:_NFE:_INFNFE:_DET[i]:_PROD:_UCOM:TEXT
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT"))=="C"
					nDescont:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VDESC:TEXT)
				Endif
				nPreco	:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VUNCOM:TEXT)
				nTotal	:=val(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_VPROD:TEXT)
				cNota	:=oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT
				If Empty(cSerieNF)
					cSerie:=oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT
					If cZeroSerie > 0  //Adicionado em 16/04/2015
						cSerie:=Right(Replicate("0",nxQtdDigF1SERIE)+Alltrim(cSerie),cZeroSerie)
					Endif
				Endif
				cNatOP	:=oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT
				if _xVersaoXML = "3.10"
					cEmissao:=oxml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
				Else
					cEmissao:=oxml:_NFE:_INFNFE:_IDE:_DEMI:TEXT
				Endif
				If !(ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_IE"))=="U")
					If SUBSTR(alltrim(oxml:_NFE:_INFNFE:_DEST:_IE:TEXT),1,1) $ "0/1/2/3/4/5/6/7/8/9"
						//_cCNPJ2	:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) //Alterado em 27/08/2012 pois _cCNPJ2: é empresa destino  --> comentado e alterado para linha de baixo em 03/07/2013 por Luiz para tratamento do CPF
						_cCNPJ2	:=IIF(ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ"))=="U",alltrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT),alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT))
						//_cEmpresa:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) //--> comentado e alterado para linha de baixo em 03/07/2013 por Luiz para tratamento do CPF
						//lsfm retirar _cEmpresa := IIF(ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ"))=="U",alltrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT),alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT))					
					Else
						if AllTrim(oxml:_NFE:_INFNFE:_DEST:_IE:TEXT) <> AllTrim(_cxInscric)
							//Início tratamento adicionado por Luiz em 20/04/2012 para poder ficar ciente que tem XML com destinatário da empresa corrente no sistema mas onde o fornecedor emitente ainda não existe na SA2
								//isso fazia com que os XMLs ficassem sempre na pasta a serem importados sem o conhecimento do usuário
							if Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
								_xnOpcAvis := Aviso("Inscrição Estadual inválida", "O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML) +" " +;
								"do emitente " + ALLTRIM(LS3->NOME) + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
								"Nota: " + ALLTRIM(LS3->NOTA) +CHR(13)+CHR(10) +;
								"Emissão: " + ALLTRIM(LS3->EMISSAO) +CHR(13)+CHR(10) +;
								"Chave: " + ALLTRIM(LS3->CHAVE) +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
								"Tem como destinatário o CNPJ " + _cCNPJ2 + " desta empresa em uso, mas veio com a Inscrição estadual " + AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT) + " diferente do cadastro desta empresa em uso." +;
								"Será necessário efetuar recusar esta nota para que o fornecedor/cliente possa emitir uma nota fiscal com os dados corretos antes de importar este XML. " +;
								"Você pode se desejar visualizar este XML agora para observar maiores informações sobre esta nota?" , {"Recusar","Visualizar"} ,3)
								If _xnOpcAvis == 2
									MsgRun("Acessando arquivo XML ...",,{||SEFAZ()})
								Else
									_cFornecedor:=''
									_cCNPJ:=''
									_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
									RECUSAR()
									Return
								Endif
							Endif
							// Final
	                    else
							_cCNPJ2	:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT) //Alterado em 27/08/2012 pois _cCNPJ2: é empresa destino
							//lsfm retirar _cEmpresa:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
						Endif
					Endif
				Else
					if Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
						_xnOpcAvis := Aviso("Inscrição Estadual inválida", "O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML) +" " +;
						"do emitente " + ALLTRIM(LS3->NOME) + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
						"Nota: " + ALLTRIM(LS3->NOTA) +CHR(13)+CHR(10) +;
						"Emissão: " + ALLTRIM(LS3->EMISSAO) +CHR(13)+CHR(10) +;
						"Chave: " + ALLTRIM(LS3->CHAVE) +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
						"Tem como destinatário o CNPJ " + _cCNPJ2 + " desta empresa em uso, mas NÃO veio com a Inscrição estadual " + AllTrim(_cxInscric) + " que consta no cadastro desta empresa em uso." +;
						"Escolha recusar se deseja solicitar que o fornecedor/cliente possa emitir uma nota fiscal com os dados corretos antes de importar este XML. " +;
						"Você pode se desejar visualizar este XML agora para observar maiores informações sobre esta nota?" , {"Recusar","Visualizar","OK"} ,3)
						If _xnOpcAvis == 2
							MsgRun("Acessando arquivo XML ...",,{||SEFAZ()})
						ElseIf _xnOpcAvis == 1
							_cFornecedor:=''
							_cCNPJ:=''
							_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
							RECUSAR()
							Return
						Endif
					Endif
				EndIF
				cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
				cProd:=''
				_xcNomEmit := alltrim(oxml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT) // Adicionado por Luiz em 20/04/2012 para tratar Emitentes não cadastrados
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET"))#"A" //Se _DET não retornar tipo Array então a nota tem apenas um item				
					If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF					
						If alltrim(oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsDEV)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
						ElseIf alltrim(oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
						Else
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
						EndIf
					EndIf
				Else
					If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF					
						If alltrim(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsDEV)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
						ElseIf alltrim(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
						Else
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
						EndIf
					EndIf
				EndIf
			Else
				cCodbar :=oxml:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
				cProdFor:=oxml:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT
				nQuant	:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT)
				xDesc	:=oxml:_NFE:_INFNFE:_DET:_PROD:_XPROD:TEXT
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT"))=="C"
					cNCM	:=oxml:_NFE:_INFNFE:_DET:_PROD:_NCM:TEXT
				Endif
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT"))=="C"
					nDescont:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_VDESC:TEXT)
				Endif
				cUM		:=oxml:_NFE:_INFNFE:_DET:_PROD:_UCOM:TEXT
				nPreco	:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_VUNCOM:TEXT)
				nTotal	:=val(oxml:_NFE:_INFNFE:_DET:_PROD:_VPROD:TEXT)
				cNota	:=oxml:_NFE:_INFNFE:_IDE:_NNF:TEXT
				If Empty(cSerieNF)
					cSerie:=oxml:_NFE:_INFNFE:_IDE:_SERIE:TEXT
					If cZeroSerie > 0  //Adicionado em 16/04/2015
						cSerie:=Right(Replicate("0",nxQtdDigF1SERIE)+Alltrim(cSerie),cZeroSerie)
					Endif
				Endif
				cNatOP	:=oxml:_NFE:_INFNFE:_IDE:_NATOP:TEXT
				if _xVersaoXML = "3.10"
					cEmissao:=oxml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
				Else
					cEmissao:=oxml:_NFE:_INFNFE:_IDE:_DEMI:TEXT
				Endif
				If !(ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_IE"))=="U")
					If SUBSTR(alltrim(oxml:_NFE:_INFNFE:_DEST:_IE:TEXT),1,1) $ "0/1/2/3/4/5/6/7/8/9"
						//_cCNPJ2	:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) //Alterado em 27/08/2012 pois _cCNPJ2: é empresa destino  --> comentado e alterado para linha de baixo em 03/07/2013 por Luiz para tratamento do CPF
						_cCNPJ2	:=IIF(ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ"))=="U",alltrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT),alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT))
						//_cEmpresa:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT) //--> comentado e alterado para linha de baixo em 03/07/2013 por Luiz para tratamento do CPF
						//lsfm retirar _cEmpresa := IIF(ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DEST:_CNPJ"))=="U",alltrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT),alltrim(oxml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT))					
					Else
						if AllTrim(oxml:_NFE:_INFNFE:_DEST:_IE:TEXT) <> AllTrim(_cxInscric)
							//Início tratamento adicionado por Luiz em 20/04/2012 para poder ficar ciente que tem XML com destinatário da empresa corrente no sistema mas onde o fornecedor emitente ainda não existe na SA2
								//isso fazia com que os XMLs ficassem sempre na pasta a serem importados sem o conhecimento do usuário
							if Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
								_xnOpcAvis := Aviso("Inscrição Estadual inválida", "O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML) +" " +;
								"do emitente " + ALLTRIM(LS3->NOME) + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
								"Nota: " + ALLTRIM(LS3->NOTA) +CHR(13)+CHR(10) +;
								"Emissão: " + ALLTRIM(LS3->EMISSAO) +CHR(13)+CHR(10) +;
								"Chave: " + ALLTRIM(LS3->CHAVE) +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
								"Tem como destinatário o CNPJ " + _cCNPJ2 + " desta empresa em uso, mas veio com a Inscrição estadual " + AllTrim(oxml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT) + " diferente do cadastro desta empresa em uso." +;
								"Será necessário efetuar recusar esta nota para que o fornecedor/cliente possa emitir uma nota fiscal com os dados corretos antes de importar este XML. " +;
								"Você pode se desejar visualizar este XML agora para observar maiores informações sobre esta nota?" , {"Recusar","Visualizar"} ,3)
								If _xnOpcAvis == 2
									MsgRun("Acessando arquivo XML ...",,{||SEFAZ()})
								Else
									_cFornecedor:=''
									_cCNPJ:=''
									_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
									RECUSAR()
									Return
								Endif
							Endif
							// Final
	                    else
							_cCNPJ2	:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT) //Alterado em 27/08/2012 pois _cCNPJ2: é empresa destino
							//lsfm retirar _cEmpresa:=alltrim(oxml:_NFE:_INFNFE:_DEST:_CPF:TEXT)
						Endif
					Endif
				Else
					If Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
						_xnOpcAvis := Aviso("Inscrição Estadual inválida", "O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML) +" " +;
						"do emitente " + ALLTRIM(LS3->NOME) + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
						"Nota: " + ALLTRIM(LS3->NOTA) +CHR(13)+CHR(10) +;
						"Emissão: " + ALLTRIM(LS3->EMISSAO) +CHR(13)+CHR(10) +;
						"Chave: " + ALLTRIM(LS3->CHAVE) +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
						"Tem como destinatário o CNPJ " + _cCNPJ2 + " desta empresa em uso, mas NÃO veio com a Inscrição estadual " + AllTrim(_cxInscric) + " que consta no cadastro desta empresa em uso." +;
						"Escolha recusar se deseja solicitar que o fornecedor/cliente possa emitir uma nota fiscal com os dados corretos antes de importar este XML. " +;
						"Você pode se desejar visualizar este XML agora para observar maiores informações sobre esta nota?" , {"Recusar","Visualizar","OK"} ,3)
						If _xnOpcAvis == 2
							MsgRun("Acessando arquivo XML ...",,{||SEFAZ()})
						ElseIf _xnOpcAvis == 1
							_cFornecedor:=''
							_cCNPJ:=''
							_cCNPJ2:='' //Adicionado em 27/08/2012 para aumentar segurança na amarração do código de barras
							RECUSAR()
							Return
						Endif
					Endif
				EndIf
				cEmissao:=SUBSTR(cEmissao,1,4)+SUBSTR(cEmissao,6,2)+SUBSTR(cEmissao,9,2)
				cProd:=''
				_xcNomEmit := alltrim(oxml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT) // Adicionado por Luiz em 20/04/2012 para tratar Emitentes não cadastrados
				If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET"))#"A" //Se _DET não retornar tipo Array então a nota tem apenas um item
					If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF					
						If alltrim(oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsDEV)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
						ElseIf alltrim(oxml:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
						Else
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
						EndIf
					EndIf
				Else
					If ALLTRIM(TYPE("oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT"))=="C" .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF
						If alltrim(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsDEV)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"D",cxTipoNFXML)
						ElseIf alltrim(oxml:_NFE:_INFNFE:_DET[i]:_PROD:_CFOP:TEXT) $ AllTrim(_cCFOPsBEN)
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"B",cxTipoNFXML)
						Else
							cxTipoNFXML := iif(Empty(cxTipoNFXML),"N",cxTipoNFXML)
						EndIf
					EndIf
				EndIf
			Endif
		Endif

		If len(alltrim(cProdfor))<=5 .and. alltrim(cProdfor) <= "99999" 
			cProdFor:=strzero(val(cProdfor),6)
		Endif
		
		If len(alltrim(cProdfor))> TamSX3("A5_CODPRF")[1]
			cProdFor:=SUBSTR(cProdFor,1,TamSX3("A5_CODPRF")[1])
		Endif

	    // Faz tratamento do código do produto do fornecedor no XML (estava mais abaixo sendo tratado apenas na gravação da SA5) Alterado de localização no fonte em 21/08/2012
		if lAceitaMasc // Foi acrescentado em 21/08/2012 este if para tratar se deve ou não tratar a máscara (picture de formatação) para aceitar apenas números e letras
			_cCodFor:=''
			For w:=1 to len(alltrim(cProdFor))
				IF SUBSTR(UPPER(cProdFor),w,1) $ "A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q/R/S/T/U/V/X/Z/W/Y/0/1/2/3/4/5/6/7/8/9"
					_cCodFor:=alltrim(_cCodFor)+SUBSTR(UPPER(cProdFor),w,1)
				Endif
			Next
			cProdFor:=_cCodFor
		EndIf

		
		//Início da parte adicionada em 06/08/14 por Luiz para tratar códigos da mesma empresa quando tabela SB1 compartilhada entre filiais
		// a prioridade de uso do código do produto vai obedecer este critério onde prefixo do _cCNPJ (emitente) = prefixo _cCNPJ2 (destinatário)
		IF SUBSTR(AllTrim(LS3->CNPJEMIT),1,8) == SUBSTR(AllTrim(_cCNPJ2),1,8) .and. xFilial("SB1") == cxQtdDigFil
			cProd:=cProdFor
		ELSEIF SUBSTR(AllTrim(LS3->CNPJEMIT),1,8) == "22399174" .and. SUBSTR(AllTrim(_cCNPJ2),1,8) == "21851394"  //Alteração em 30/10/2015 para forçar mesmo código Somente notas da Politriz para a Melb 
			cProd:=cProdFor
		ELSEIF SUBSTR(AllTrim(LS3->CNPJEMIT),1,8) == "21851394" .and. SUBSTR(AllTrim(_cCNPJ2),1,8) == "22399174"  //Alteração em 30/10/2015 para forçar mesmo código Somente notas da Politriz para a Melb 
			cProd:=cProdFor			
		ENDIF 
		//Final da parte adicionada em 06/08/14 por Luiz para tratar códigos da mesma empresa quando tabela SB1 compartilhada entre filiais

		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Amarracao produto x fornecedor										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cProd) .and. !LS3->TIPO $ "D/B" // Alterado em 13/06/2011 por Luiz para deixar validando apenas o código na amarração não validando o código de Barras (retirado Empty(cCodbar) .or. ) --> Alterado em 27/08/2014 para somente entrar aqui não for D/B (ou seja, F1_FORNECE se trata de fornecedor, quando é D=devolução ou B=beneficiamento o código usado é do cliente tendo que procurar na SA7
			DbSelectarea("SA5")
			DbSetorder(13) //SA5020D   A5_FILIAL, A5_CODPRF, A5_REFGRD, A5_FABR, A5_FORNECE, R_E_C_N_O_, D_E_L_E_T_
			Dbgotop() 
			Dbseek(xFilial("SA5")+cProdFor,.t.)
			While !Eof() .AND. ALLTRIM(SA5->A5_CODPRF)==ALLTRIM(cProdFor)
				IF SA5->A5_FORNECE==LS3->FORNEC .AND. SA5->A5_LOJA==LS3->LOJA
					cProd:=SA5->A5_PRODUTO
					_cxUMForn:=SA5->A5_UNID
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifico se esta bloqueado											³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectarea("SB1")
					DbSetorder(1)
					Dbgotop()
					Dbseek(xFilial("SB1")+cProd,.t.)
					If Found() .and. SB1->B1_MSBLQL=="1"
						cProd:=''
					Endif
					If !Empty(cProd)
						If Empty(cCodbar)
							cCodbar:=POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_CODBAR")
						Endif
					Endif
				Endif
				DbSelectarea("SA5")
				Dbskip()
			End
		Endif		
		
		If Empty(cProd) .and. LS3->TIPO $ "D/B" //  --> Alterado em 06/05/2014 para somente entrar aqui se ainda não encontrou o código e (ou seja, F1_FORNECE se trata de cliente, quando é D=devolução ou B=beneficiamento o código usado é do cliente tendo que procurar na SA7
			DbSelectarea("SA7")
			DbSetorder(3) //SA70203   A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI, R_E_C_N_O_, D_E_L_E_T_
			Dbgotop() 
			Dbseek(xFilial("SA7")+LS3->FORNEC+LS3->LOJA+cProdFor,.t.)
			While !Eof() .AND. ALLTRIM(SA7->A7_CODCLI)==ALLTRIM(cProdFor)
				IF SA7->A7_CLIENTE==LS3->FORNEC .AND. SA7->A7_LOJA==LS3->LOJA
					cProd:=SA7->A7_PRODUTO
					_cxUMForn:=SA7->A7_UMNFE
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifico se esta bloqueado											³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectarea("SB1")
					DbSetorder(1)
					Dbgotop()
					Dbseek(xFilial("SB1")+cProd,.t.)
					If Found() .and. SB1->B1_MSBLQL=="1"
						cProd:=''
					Endif
					If !Empty(cProd)
						If Empty(cCodbar)
							cCodbar:=POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_CODBAR")
						Endif
					Endif
				Endif
				DbSelectarea("SA7")
				Dbskip()
			End
		endif
				
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ codigo barras														³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//		if cNota == "20322"
//			teste:=""
//		EndIf
		If Empty(cProd) .and. !Empty(cCodbar) .and. SUBSTR(cCodbar,1,TamSX3("B1_CODBAR")[1]) <> REPLICATE("0",TamSX3("B1_CODBAR")[1])  .and. Val(AllTrim(_cCNPJ2)) == Val(AllTrim(SM0->M0_CGC)) // Alterado por Luiz em 10/04/2012 para não ficar com tamanho fixo e em 27/08/2012 para apenas verificar notas para empresa selecionada //Alterado em 17/08/13 adicionando val() para tratar zeros a esquerda no cadastro de empresas com CPF		
			DbSelectarea("SB1")
			DbSetorder(5)  //B1_FILIAL, B1_CODBAR, R_E_C_N_O_, D_E_L_E_T_
			Dbgotop()
			Dbseek(xFilial("SB1")+cCodbar,.t.)
			While !Eof() .AND. AllTrim(SB1->B1_CODBAR) == AllTrim(cCodbar)
				If SB1->B1_MSBLQL <> "1"
					cProd:=SB1->B1_COD
					If cCodProAnterior <> cProd .and. nContaCodBarras > 0
						cMensCodBarrasD += iif(nContaCodBarras==1," #Código no Fornecedor: " + AllTrim(cProdFor) + " com código de barras: " + AllTrim(cCodbar) + " pode ser um destes produtos: ","/") + AllTrim(cCodProAnterior)  // Adicionado em 23/08/2012 para verificar duplicidade de códigos de barras
					EndIf
				Endif
				nContaCodBarras := iif(SB1->B1_MSBLQL <> "1",1,0)	// Adicionado em 23/08/2012 para verificar duplicidade de códigos de barras //Acrescentado iff em 07/08/2014
				cCodProAnterior := SB1->B1_COD
				Dbskip()
			End 
			
			If nContaCodBarras > 1
				bMostMsgCodBarras:=.t.
				cMensCodBarrasD += "/"+AllTrim(cCodProAnterior)
				cProd := ''
			EndIf

			nContaCodBarras := 0
			
			If Empty(cProd)
				DbSelectarea("SLK")
				DbSetorder(1)
				Dbgotop()
				Dbseek(xFilial("SLK")+cCodbar,.t.)

				While !Eof() .AND. AllTrim(SLK->LK_CODBAR) == AllTrim(cCodbar)
					cProd:=SLK->LK_CODIGO
					If cCodProAnterior <> cProd .and. nContaCodBarras > 0
						cMensCodBarrasD += iif(nContaCodBarras==1,"Código no Fornecedor: " + AllTrim(cProdFor) + " com código de barras: " + AllTrim(cCodbar) + " pode ser um destes produtos: ","/") + AllTrim(cCodProAnterior)  // Adicionado em 23/08/2012 para verificar duplicidade de códigos de barras
					EndIf
					nContaCodBarras++	// Adicionado em 23/08/2012 para verificar duplicidade de códigos de barras
					cCodProAnterior := SLK->LK_CODIGO
					Dbskip()
				End 
				
				If nContaCodBarras > 1
					bMostMsgCodBarras:=.t.
					cMensCodBarrasD += "/"+AllTrim(cCodProAnterior)
					cProd := ''					
				EndIf
					
				nContaCodBarras := 0
				
				If !Empty(cProd)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifico se esta bloqueado											³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectarea("SB1")
					DbSetorder(1)
					Dbgotop()
					Dbseek(xFilial("SB1")+cProd,.t.)
					If Found() .and. SB1->B1_MSBLQL=="1"
						cProd:=''
					Endif
				Endif
			Endif
		Endif
		
		_nQE:=1
		
		If Empty(cProd) // .or. Empty(cCodbar)  //Comentado por Luiz em 13/06/2011
			cProd:="999999"
			_cDescricao:=xDesc
		Else
			_cDescricao:=POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
			_nQE:=POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_QE")
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Unidade de medidas unitarias										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF cUM $ cUnidades
			_nQE:=1
		Endif
		
		If alltrim(cProd)<>"999999"
			DbSelectarea("LS5")
			DbSetorder(1)
			Dbgotop()
			Dbseek(cProd)
			if !Found()
				Reclock("LS5",.T.)
				LS5->PRODUTO:=cProd
				MsUnlock()
			Endif
		Endif
		
		IF alltrim(cProd)<>"999999"
			_nCusto:=ULTPED(cProd)
		Else
			_nCusto:=0
		Endif
		
		//Início da alteração implementada em 07/07/2012
		//Tratamento para conversão da segunda unidade de medida através da identificação
		//da unidade de medida informada no campo A5_UNID com a B1_SEGUM, com isso o sistema
		//irá fazer a conversão da unidade de medida do fornecedor (segunda unidade de medida) para
		//a primeira unidade de medida da empresa que está importando o XML

		IF alltrim(cProd)<>"999999" .and. !Empty(_cxUMForn)
			_cx1UMPro := POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_UM")
			_cx2UMPro := POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_SEGUM")
			_cxTipCon := POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_TIPCONV")
			_cxFatCon := POSICIONE("SB1",1,xFilial("SB1")+cProd,"B1_CONV")
			_nQE := 1
			If _cxUMForn <> _cx1UMPro .and. _cxUMForn == _cx2UMPro
   				If _cxTipCon=="M" .and. _cxFatCon <> 0 // para converver da segunda para primeira a lógica é inversa, ou seja, se é M=Multiplicador, precisa dividir
   					nQuant := nQuant / _cxFatCon
   				ElseIf _cxTipCon=="D"
   					nQuant := nQuant * _cxFatCon
   				Else
   					nQuant := nQuant
   				EndIf
			EndIf
		Endif
		
		//Final da alteração implementada em 07/07/2012
		
		_nQE := IIF(_nQE==0,1,_nQE) //Adicionado por Luiz em 28/08/2014 pois o preço é calculado com base na quantidade por embalagem e se tiver 0 deve considerar 1 para não zerar o preço
		
		_nPreco:=((nTotal-nDescont)/(nQuant*_nQE))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravando produtos do XML											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
		Reclock("LS1",.T.)
		LS1->SEQ:=nTotIt
		LS1->CODBAR:=cCodbar
		LS1->PRODUTO:=cProd
		LS1->PRODFOR:=cProdFor
		LS1->DESCRICAO:=UPPER(_cDescricao)
		LS1->DESCORI:=UPPER(_cDescricao)
		LS1->QUANTIDADE:=(nQuant*_nQE)
		LS1->PRECO:=_nPreco
		LS1->CUSTO:=_nCusto
		LS1->NCM:=IIF(LEN(ALLTRIM(cNCM))>=TamSX3("B1_POSIPI")[1],SUBSTR(cNCM,1,TamSX3("B1_POSIPI")[1]),"")
		LS1->PRECOFOR:=IIF((nQuant*_nQE) <> 0,(nTotal/(nQuant*_nQE)),0)
		LS1->TOTAL:=(nTotal-nDescont)
		IF alltrim(cProd)=="999999"
			LS1->OK:="X"
		Else
			IF 100-(IIF(_nCusto <> 0,(_nPreco/_nCusto),0)*100)>xnPercMaxDiverg .OR. 100-(IIF(_nCusto <> 0,(_nPreco/_nCusto),0)*100)<-xnPercMaxDiverg   // Alterado por Luiz em 26/05/2011. Onde está xnPercMaxDiverg estava fixo 10
				LS1->OK:="O"
			Endif
		Endif
		LS1->EMISSAO:=cEmissao
		LS1->ALTERADO:="N"
		LS1->DESCONTO:=nDescont
		LS1->UM:=UPPER(cUM)
		LS1->NOTA:=LS3->NOTA
		LS1->NOME:=LS3->NOME
		LS1->QE:=_nQE
		LS1->CAIXAS:=nQuant
		LS1->TOTALNF:=nTotal
		MsUnlock()
		nTotIt:=nTotIt+1
		nTotalNF:=nTotalNF+(nTotal-nDescont)
	Next
Else
	Msgbox("Problema ao abrir/ler o arquivo XML: " + cFile ,"Atenção...","ALERT")
Endif

If nTotalNF==0
	Msgbox("Alerta! O valor total da soma dos itens deste XML " + cFile + " está zerado. Provavelmente nota fiscal complementar. " +;
	       "Escolha o tipo de nota dando duplo clique na linha da nota antes de confirmar a importação. Os tipos possíveis de nota no Protheus são: " +;
	       " N = NF Normal,D = Devolução,I = NF Compl. ICMS,P = NF Compl. IPI,B = NF Beneficiamento e C = Compl. Preço.","Atenção... Itens zerados.","ALERT")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fornecedor															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea(iif(LS3->TIPO $ "B/D","SA1","SA2"))
DbSetorder(1)
Dbgotop()
Dbseek(xFilial(iif(LS3->TIPO $ "B/D","SA1","SA2"))+LS3->FORNEC+LS3->LOJA)
If Found()
	IF LS3->TIPO $ "B/D"
		_cFornecedor:=SUBSTR(SA1->A1_NREDUZ,1,25)
		_cEnd:=ALLTRIM(SA1->A1_END)+" - "+SA1->A1_BAIRRO
		_cCidade:=ALLTRIM(SA1->A1_MUN)+"/"+SA1->A1_EST
		_cCNPJ:=SA1->A1_CGC
		_cTelefone:=SA1->A1_TEL
	ELSE
		_cFornecedor:=SUBSTR(SA2->A2_NREDUZ,1,25)
		_cEnd:=ALLTRIM(SA2->A2_END)+" - "+SA2->A2_BAIRRO
		_cCidade:=ALLTRIM(SA2->A2_MUN)+"/"+SA2->A2_EST
		_cCNPJ:=SA2->A2_CGC
		_cTelefone:=SA2->A2_TEL
	ENDIF
		_cEmissao:=dtoc(stod(LS1->EMISSAO))
Endif

If len(alltrim(cNota))<=5
	cNota:=strzero(val(cNota),6)
Endif
If cZeros
	cNota:=strzero(val(cNota),TamSX3("D1_DOC")[1])
Endif

//Adicionado em 23/08/2012 para mostrar mensagem com códigos de barras duplicados
If bMostMsgCodBarras
	_xnOpcAvis := Aviso("Código de Barras duplicado", " No arquivo XML " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(cFile) +" " +;	
				"do emitente " + _xcNomEmit + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
				"Nota: " + cNota +CHR(13)+CHR(10) +;
				"Emissão: " + cEmissao +CHR(13)+CHR(10) +;
				"Nat. Operação: " + cNatOp +CHR(13)+CHR(10) +;
				"Chave: " + cChave +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
				"Possui um ou mais código de barras que foram encontrados em mais de um produto conforme a seguir: " + CHR(13)+CHR(10) + ;
				cMensCodBarrasD  +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
				"Verifique se realmente estes códigos de barras estão corretos juntamente aos responsáveis pelo cadastro de produto (tabelas SB1 e/ou SLK) " +;
				"Será necessário verificar manualmente a localização e/ou se necessário efetuar um novo cadastro de produto." , {"OK"} ,3)
EndIf

//Atualiza o tipo da nota fiscal com a variável cxTipoNFXML que sempre vai representar o tipo da nota fisca selecionada na parte superior na tela da rotina
//O usuário pode dar duplo clique para alterar o tipo 27/08/2014

//RecLock("LS3",.F.)
//	LS3->TIPO:=cxTipoNFXML
//MsUnLock()

// início do trecho adicionado por Luiz em 27/08/2014 para tratamento da tela de alteração do tipo de nota a ser importada
cxDadosFornec := "O arquivo " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(LS3->XML)) +" " +;
				"do emitente " + _xcNomEmit + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
				"Nota: " + cNota + " Tipo " + cxTipoNFXML +CHR(13)+CHR(10) +;
				"Emissão: " + cEmissao +CHR(13)+CHR(10) +;
				"Nat. Operação no XML: " + cNatOp +CHR(13)+CHR(10) +;
				"Chave: " + cChave +CHR(13)+CHR(10) +CHR(13)+CHR(10)
cxInfCompl := _cMensaginfAdFisco +CHR(13)+CHR(10) + _cMensag  				
// final do trecho adicionado por Luiz em 27/08/2014 para tratamento da tela de alteração do tipo de nota a ser importada


//FORÇA REFRESH PARA ATUALIZAR COLUNA DO TIPO DA NOTA --Adicionado por Luiz em 06/08/2014
OBRWI:obrowse:refresh()
OBRWP:obrowse:refresh()
OBRWI:obrowse:setfocus()
OBRWP:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")


DbSelectarea("LS3")
DbSelectarea("LS1")
Dbsetorder(1)
Dbgotop()
OBRWI:obrowse:refresh()
OBRWP:obrowse:refresh()
OBRWI:obrowse:setfocus()
OBRWP:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fornecedor															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ABREPED()
DbSelectarea("SC7")
SET FILTER TO C7_FILIAL==xFilial("SC7") .AND. C7_NUM==LS2->PEDIDO
MATA121()
SET FILTER TO
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Confirma produto													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RECUSAR()
Local xlEnvMail := .f., xcEmailFor := ""    // Adicionado por Luiz em 18/06/2011

cResp:=msgbox("Deseja recusar o recebimento da nota fiscal "+cNota+" ?","Atenção...","YESNO")

If cResp
	
	_cSenha:=Space(06)
	
	@ 0,0 TO 100,235 DIALOG oSenha TITLE "Informe a Senha para acesso..."
	@ 10,10 SAY "Senha "  FONT oFont1 OF oSenha PIXEL
	@ 10,40 Get _cSenha Picture "@!" Size 20,20  Valid .T.  PASSWORD
	@ 30,40 BUTTON "Confirma" SIZE 35,12 ACTION Close(oSenha)
	ACTIVATE DIALOG oSenha CENTER
	
	If Empty(_cSenha)
		Return
	Endif
	
	If ALLTRIM(_cSenha)<>SUBSTR(DTOC(M->DDATABASE),1,2)+SUBSTR(DTOC(M->DDATABASE),4,2)+SUBSTR(DTOC(M->DDATABASE),7,2)
		Msgbox("Senha inválida!")
		Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados do fornecedor													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea(iif(LS3->TIPO $ "B/D","SA1","SA2"))
	DbSetorder(1)
	Dbgotop()
	Dbseek(xFilial(iif(LS3->TIPO $ "B/D","SA1","SA2"))+LS3->FORNEC+LS3->LOJA)

	IF LS3->TIPO $ "B/D"
		xcEmailFor := IIF(LEN(Alltrim(SA1->A1_EMAIL))>6,Alltrim(SA1->A1_EMAIL),space(30))
	ELSE
		xcEmailFor := IIF(LEN(Alltrim(SA2->A2_EMAIL))>6,Alltrim(SA2->A2_EMAIL),space(30))
	ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se foi cadastrado os email de recusa 								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(xEMAILREC)
		cResp:=msgbox("Atualmente o e-mail da " + xcNEmpresa + " configurado para receber aviso de recusa é " + Alltrim(xEMAILREC) +". Você terá como adicionar outros e-mails se desejar. Deseja enviar um email para ficar documentado esta recusa?","Atenção...","YESNO")
		
		If cResp
			xlEnvMail := EMAIL(xcEmailFor)
		Endif
	Endif
	  
	IF (cResp .and. xlEnvMail) .or. !cResp  //Alterado por Luiz em 12/09/2014 para permitir inutilizar também se o usuário escolher para não enviar e-mail
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nomeclatura dos arquivos											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if xlRecusa
			_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1]))
			_cFileNew:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(ALLTRIM(aXML[i,1]))+".rec"
		Else
			_cFileOri:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(LS3->XML)
			_cFileNew:=_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+ALLTRIM(iif(LS3->TIPO $ "B/D",SA1->A1_CGC,SA2->A2_CGC))+"-nf"+ALLTRIM(LS3->NOTA)+"-"+ALLTRIM(LS3->CHAVE)+"xml.rec"
		EndIf
		
		FRenameEx(_cFileOri,_cFileNew)
		__CopyFile(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+"*.rec",_xPstSalv+_xcBarraDir+"recusadas"+_xcBarraDir) //Alterado em 26/04/2012 para tratar compartilhamento de pasta entre empresas
		ferase(_cFileNew)
		
		Msgbox("Nota Fiscal recusada com sucesso!","Atenção...","INFO")

		If xlRecusa // Adicionado por Luiz em 16/04/2012 para tratar recusa de nota em homologação
			Return
		EndIf
				
		Reclock("LS3",.F.)
		dbdelete()
		MsUnlock()
		
		DbSelectarea("LS3")
		Dbgotop()
		
		DbSelectarea("LS1")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			Reclock("LS1",.F.)
			dbdelete()
			MsUnlock()
			Dbskip()
		End
		
		DbSelectarea("LS5")
		Dbsetorder(1)
		Dbgotop()
		While !Eof()
			Reclock("LS5",.F.)
			dbdelete()
			MsUnlock()
			Dbskip()
		End
	ElseIf cResp .and. !xlEnvMail //Adicionado por Luiz em 12/09/2014 para permitir recusar arquivos sem enviar e-mail, no entanto se responder que deseja enviar e-mail este precisa ser informado/localizado ==> EMAIL(xcEmailFor) deve retornar .t. 
		Msgbox("A nota Fiscal não pode ser recusada, por falta do e-mail para envio. Verique o e-mail informado na tela de recusa e/ou no cadastro de fornecedor/cliente!","Atenção...","STOP")
	EndIf
	PROCESS()
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Divergencias														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function DIVERG(cOpc)  // Adicionado parâmetro cOpc em 13/06/2011 por Luiz
Local _xlpulatodos := .f. // Adicionado por Luiz em 31/05/2011 para ignorar pergunta de amarração com pedido de compras para pedidos que tenham muitos itens

aCampos4:= {{"FLAG","C",1,0 },;
{"OK","C",15,0 },;
{"PRODUTO","C",TamSX3("D1_COD")[1],0 },;
{"DESCRICAO","C",TamSX3("B1_DESC")[1],0 },;
{"PRCPED","N",TamSX3("C7_PRECO")[1],TamSX3("C7_PRECO")[2] },;
{"PRCNFE","N",TamSX3("D1_VUNIT")[1],TamSX3("D1_VUNIT")[2] },;
{"QTDPED","N",TamSX3("C7_QUANT")[1],TamSX3("C7_QUANT")[2] },;
{"QTDNFE","N",TamSX3("D1_QUANT")[1],TamSX3("D1_QUANT")[2] }}

cArqTrab4  := CriaTrab(aCampos4)
dbUseArea( .T.,, cArqTrab4, "LS4", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS4",cArqTrab4,"DESCRICAO",,,)
dbSetIndex( cArqTrab4 +OrdBagExt())
dbSelectArea("LS4")
_nMaior:=0

                
if cOpc == "2" // Início da parte adicionada por Luiz em 13/06/2011 (deve criar a área PRO)
	aProdutos	:= {{"PRODUTO","C",TamSX3("C7_PRODUTO")[1],0 },;
	{"DESCRICAO","C",TamSX3("B1_DESC")[1],0 },;
	{"QUANTIDADE","N",TamSX3("C7_QUANT")[1],TamSX3("C7_QUANT")[2] },;
	{"PEDIDO","C",TamSX3("C7_NUM")[1],0 },;
	{"ITEM","C",TamSX3("C7_ITEM")[1],0 },;
	{"PRECO","N",TamSX3("C7_PRECO")[1],TamSX3("C7_PRECO")[2] }}
	
	cArqTrabp  := CriaTrab(aProdutos)
	dbUseArea( .T.,, cArqTrabp, "PRO", if(.F. .OR. .F., !.F., NIL), .F. )
	IndRegua("PRO",cArqTrabp,"PEDIDO+PRODUTO+ITEM",,,)
	dbSetIndex( cArqTrabp +OrdBagExt())
	dbSelectArea("PRO")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aglutinando produtos iguais											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea("LS1")
	Dbsetorder(1)
	Dbgotop()
	While !Eof()
		IF !Empty(LS1->PEDIDO)
			DbSelectarea("PRO")
			DbSetorder(1)
			Dbgotop()
			Dbseek(LS1->PEDIDO+LS1->PRODUTO+LS1->ITEM)
			If !Found()
				Reclock("PRO",.T.)
				PRO->PRODUTO:=LS1->PRODUTO
				PRO->QUANTIDADE:=LS1->QUANTIDADE
				PRO->DESCRICAO:=LS1->DESCRICAO
				PRO->PRECO:=LS1->PRECO
				PRO->PEDIDO:=LS1->PEDIDO
				PRO->ITEM:=LS1->ITEM
				MsUnlock()
			Else
				Reclock("PRO",.F.)
				PRO->QUANTIDADE:=(PRO->QUANTIDADE+LS1->QUANTIDADE)
				MsUnlock()
			Endif
		EndIf
		DbSelectarea("LS1")
		Dbskip()
	End
	
	cMsg:=''
	DbSelectArea("PRO")
	Dbgotop()
	While !Eof()
		cQuery:=" SELECT (C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		cQuery:=cQuery + " AND C7_NUM='"+PRO->PEDIDO+"' "
		cQuery:=cQuery + " AND C7_PRODUTO='"+PRO->PRODUTO+"' "
		cQuery:=cQuery + " AND C7_ITEM='"+PRO->ITEM+"' "
		cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
		cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
		cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
		cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectarea("TCQ")
		IF PRO->QUANTIDADE>TCQ->QUANT
			cMsg:=cMsg+PRO->PEDIDO+"   "+PRO->ITEM+"   "+alltrim(PRO->PRODUTO)+"   "+PRO->DESCRICAO+CHR(13)+CHR(10)
		Endif
		Dbclosearea("TCQ")
		DbSelectArea("PRO")
		Dbskip()
	End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o preco esta proximo do correto							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMsg:=cMsg+CHR(13)+CHR(10)
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	IF LS1->CUSTO>0
		IF 100-(IIF(LS1->CUSTO<>0,(LS1->PRECO/LS1->CUSTO),0)*100)>xnPercMaxDiverg .OR. 100-(IIF(LS1->CUSTO <>0,(LS1->PRECO/LS1->CUSTO),0)*100)<-xnPercMaxDiverg        // Alterado por Luiz em 26/05/2011. Onde está xnPercMaxDiverg estava fixo 10
			cMsg:=cMsg+ALLTRIM(LS1->PRODUTO)+"  "+SUBSTR(LS1->DESCRICAO,1,35)+CHR(13)+CHR(10)
			cMsg:=cMsg+"Preço Nota R$ "+transform(LS1->PRECO,X3Picture("D1_VUNIT"))+"   Preço Pedido R$"+transform(LS1->CUSTO,X3Picture("C7_PRECO"))+CHR(13)+CHR(10)
			cMsg:=cMsg+CHR(13)+CHR(10)
			
			Reclock("LS1",.F.)
			LS1->OK:="O"
			MsUnlock()
		Endif
	Endif
	Dbskip()
End
Dbgotop()

Endif // Final da parte adicionada em 13/06/2011 por Luiz


Dbselectarea("PRO")
DbSetorder(1)
Dbgotop()
While !Eof()
	
    cQuery:=" SELECT COUNT(*) QTD,AVG(C7_PRECO) PRECO,SUM(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	If lItem==.F.
		cQuery:=cQuery + " AND C7_NUM='"+LS2->PEDIDO+"' "
	Else
		cQuery:=cQuery + " AND C7_NUM='"+PRO->PEDIDO+"' "
		cQuery:=cQuery + " AND C7_ITEM='"+PRO->ITEM+"' "
	Endif
	cQuery:=cQuery + " AND C7_PRODUTO='"+PRO->PRODUTO+"' "
	cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
	cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		IF TCQ->QTD==0 
			Reclock("LS4",.T.)
			LS4->PRODUTO:=PRO->PRODUTO
			LS4->DESCRICAO:=PRO->DESCRICAO
			LS4->PRCNFE:=round(PRO->PRECO,2)
			If ApMsgYesNo("Não foi encontrado amarração de pedido de compras para produto " + PRO->PRODUTO + ". Não será possível classificar a pré-nota caso a TES gere duplicata. Deseja continuar?" , "Falta Pedido de Compras") // Adicionado If inteiro por Luiz em 31/05/2011 para permitir aceitar itens sem pedidos, onde a validação no item da nota irá impedir a classificação caso a TES gere duplicata
				if !_xlpulatodos .and. ApMsgYesNo("Ignora validação de amarração com pedidos de compras para todos itens do pedido " + iif(lItem==.F.,LS2->PEDIDO,PRO->PEDIDO) + ".?" , "Falta Pedido de Compras")
					_xlpulatodos := .t.
				EndIf
				LS4->FLAG:="X"
			EndIf
			LS4->OK:="Nao Existe"
			MsUnlock()
			DbSelectarea("TCQ")
			Dbskip()
			Loop
		Endif
		
		If (TCQ->QUANT<PRO->QUANTIDADE .AND. TCQ->QUANT>0)
			Reclock("LS4",.T.)
			LS4->PRODUTO:=PRO->PRODUTO
			LS4->DESCRICAO:=PRO->DESCRICAO
			LS4->QTDPED:=TCQ->QUANT
			LS4->QTDNFE:=PRO->QUANTIDADE
			LS4->PRCPED:=round(TCQ->PRECO,2)
			LS4->PRCNFE:=round(PRO->PRECO,2)
			LS4->OK:="Quantidade"
			MsUnlock()
			If (round(PRO->PRECO,2)>round(TCQ->PRECO,2)) .AND. round(TCQ->PRECO,2)>0
				_nMaior:=_nMaior+(PRO->QUANTIDADE*(round(PRO->PRECO,2)-round(TCQ->PRECO,2)))
			Endif
			DbSelectarea("TCQ")
			DbSkip()
			Loop
		Endif
		If (round(PRO->PRECO,2)>round(TCQ->PRECO,2)) .AND. round(TCQ->PRECO,2)>0 .AND. TCQ->QUANT>0
			Reclock("LS4",.T.)
			LS4->PRODUTO:=PRO->PRODUTO
			LS4->DESCRICAO:=PRO->DESCRICAO
			LS4->PRCPED:=round(TCQ->PRECO,2)
			LS4->PRCNFE:=round(PRO->PRECO,2)
			LS4->QTDPED:=TCQ->QUANT
			LS4->QTDNFE:=PRO->QUANTIDADE
			LS4->OK:="Preco"
			MsUnlock()
			_nMaior:=_nMaior+(PRO->QUANTIDADE*(round(PRO->PRECO,2)-round(TCQ->PRECO,2)))
			DbSelectarea("TCQ")
			DbSkip()
			Loop
		Endif
		
		Reclock("LS4",.T.)
		LS4->PRODUTO:=PRO->PRODUTO
		LS4->DESCRICAO:=PRO->DESCRICAO
		LS4->PRCPED:=round(TCQ->PRECO,2)
		LS4->PRCNFE:=round(PRO->PRECO,2)
		LS4->QTDPED:=TCQ->QUANT
		LS4->QTDNFE:=PRO->QUANTIDADE
		If TCQ->QUANT>=PRO->QUANTIDADE
			LS4->FLAG:="X"
			LS4->OK:="Produto OK!"
		Else
			LS4->OK:="Sem saldo!"
		Endif
		MsUnlock()
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	Dbselectarea("PRO")
	Dbskip()
End

DbSelectarea("LS4")
Dbgotop()

aTitulo4 := {}
AADD(aTitulo4,{"OK","Divergência"})
AADD(aTitulo4,{"PRODUTO","Produto"})
AADD(aTitulo4,{"DESCRICAO","Descrição"})
AADD(aTitulo4,{"PRCPED","R$ Pedido",_xPc7preco})
AADD(aTitulo4,{"PRCNFE","R$ Nota",_xPd1vunit})
AADD(aTitulo4,{"QTDPED","Qtd.Pedido",_xPc7quant})
AADD(aTitulo4,{"QTDNFE","Qtd.Nota",_xPd1quant})

If !LS4->(eof())
	@ 120,040 TO 400,880 DIALOG oAmar TITLE "Divergências encontradas..."
	@ 005,005 BUTTON "Sair" SIZE 55,10 ACTION oAmar:end()
	If _nMaior>0
		@ 005,100 say "Valor Total Excedido R$ "+Transform(_nMaior,"@E 99,999.99") FONT oFont1 OF oAmar PIXEL COLOR CLR_HRED
	Endif
	@ 020,005 TO 140,417 BROWSE "LS4" ENABLE " LS4->FLAG<>'X' " OBJECT OBRWA FIELDS aTitulo4
	ACTIVATE DIALOG oAmar CENTER
Else
	Msgbox("Não foram encontradas nenhuma divergência!","Atenção...","ALERT")
Endif
Dbselectarea("LS4")
dbCloseArea("LS4")
fErase( cArqTrab4+ ".DBF" )
fErase( cArqTrab4+ OrdBagExt() )

if cOpc == "2" // Início da parte adicionada por Luiz em 13/06/2011 (deve criar a área PRO)
		Dbselectarea("PRO")
		dbCloseArea("PRO")
		fErase( cArqTrabp+ ".DBF" )
		fErase( cArqTrabp+ OrdBagExt() )
EndIf // Final da parte adicionada por Luiz em 13/06/2011

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia email de nota recusada										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function EMAIL(xcMailFor)
Local cSubject := "Nota fiscal "+cNota+" série " + cSerie + " recusado o recebimento..."
Local cMsg      := ""
Local cAttach   := ""
Local aMsg      := {}
Local aUsrMail := {}
Local lConectou := .f.
LOCAL cACCOUNT  := alltrim(getmv("MV_RELACNT"))
LOCAL cPASSWORD := alltrim(getmv("MV_RELPSW"))
LOCAL cSERVER   := alltrim(getmv("MV_RELSERV"))

If Empty(XEMAILREC)
	Msgbox("Favor cadastrar os E-Mails que serão enviados a mensagem de recusa!")
	Msgbox("Use o configurador da rotina IMPXML.PRW - Senha do Administrador...")
	Return
Endif

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lConectou

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Requer autenticacao													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If getmv("MV_RELAUTH")==.T. .or. lTLS
	MAILAUTh(cAccount,cPassword)
Endif
// Luiz 18/06/2011 ==> Foram realizados algumas alterações no texto padrão e adicionado abertura de campo memo para permitir alterar a mensagem bem como colocar permitir informar e-mail para cópia
cMensagem := "Estamos recusando o recebimento da Nota fiscal "+cNota + " Serie " + cSerie + "  de acordo com as informações abaixo:"+ chr(13)+chr(10)
cMensagem := cMensagem+ " Fornecedor:"+_cFornecedor +"               CNPJ:"+_cCNPJ+ chr(13)+chr(10)
cMensagem := cMensagem+ " Data Emissão:"+_cEmissao+ chr(13)+chr(10)
cMensagem := cMensagem+ " Total da Nota Fiscal R$ " + Alltrim(Transform(nTotalNF,"@ze 9,999,999,999,999.99")) + chr(13)+chr(10)
cMensagem := cMensagem+ chr(13)+chr(10)
cMensagem := cMensagem+ chr(13)+chr(10)
cMensagem := cMensagem+ " MOTIVO ==>" + chr(13)+chr(10)
cMensagem := cMensagem+ chr(13)+chr(10)
cMensagem := cMensagem+ "Caso tenha alguma dúvida, entrar em contato com "+Alltrim(_cUsuario)+ " (" + Alltrim(xDadosUsuario(1,14)) +")" + chr(13)+chr(10)  // Retorna Email de Usuário (http://tdn.totvs.com/kbm#14613)
cMensagem := cMensagem+ chr(13)+chr(10)
cMensagem := cMensagem+ chr(13)+chr(10)
cMensagem := cMensagem+ "NOTA FISCAL DA EMPRESA "+SM0->M0_CODIGO + " - " + SM0->M0_NOME +chr(13)+chr(10)
cMensagem := cMensagem+ "               FILIAL  "+SM0->M0_CODFIL + " - " + SM0->M0_FILIAL +chr(13)+chr(10)
cMensagem := cMensagem+ chr(13)+chr(10)
cMensagem := cMensagem+ "EMAIL AUTOMÁTICO ENVIADO PELO SISTEMA,FAVOR NÃO RESPONDÊ-LO"

xEmailCC := IIF(LEN(Alltrim(xcMailFor))>6,Alltrim(xcMailFor),space(30))

If !Empty(cMensagem)
	lSaida:=.F.
	DEFINE MSDIALOG oProdd FROM 0,0 TO 470,520 PIXEL TITLE "Texto do Email com Motivo da recusa..."
	@ 005,005 GET oMemo VAR cMensagem MEMO SIZE 250,185 FONT oFont6 PIXEL OF oProdd
	@ 190,005 Say "Enviar para: (sugerido o do cadastro do fornecedor)" SIZE 150,40 FONT oFont1 OF oProdd PIXEL COLOR CLR_HBLUE
	@ 200,005 Get xEmailCC SIZE 150,10 //Picture "@!"	
	@ 220,005 BUTTON "<< Cancelar" SIZE 55,10 ACTION (xlEnvMail:=.f.,oProdd:end())
	@ 220,070 BUTTON "Continuar >>" SIZE 55,10 ACTION (xlEnvMail:=.t.,lsaida:=.T.,oProdd:end())
	ACTIVATE MSDIALOG oProdd CENTER
	
	If lSaida==.F.
		Return
	Endif
Endif

If !empty(xEmailCC)
	SEND MAIL FROM cACCOUNT TO xEMAILREC CC xEmailCC SUBJECT cSubject BODY cMensagem RESULT lEnviado
Else
	SEND MAIL FROM cACCOUNT TO xEMAILREC SUBJECT cSubject BODY cMensagem RESULT lEnviado
Endif	

If !lEnviado
	cMensagem := ""
	GET MAIL ERROR cMensagem
	Alert(cMensagem)
Endif
DISCONNECT SMTP SERVER Result lDesConectou
Return(xlEnvMail)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona produto													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function SELECIONA(_cProduto,lOpcao)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se o produto esta bloqueado para uso						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Dbselectarea("SB1")
DbSetorder(1)
Dbgotop()
Dbseek(xFilial("SB1")+_cProduto)
If Found() .and. SB1->B1_MSBLQL=="1"
	msgbox("Produto bloqueado para uso!","Atenção...","ALERT")
	return
Endif

_nQE:=LS1->QE
cMemo:=''

_nQuantPed:=0
_nVlrPed:=0

If cPedCom .and. (axCNPJsm0[1] == .F. .or. (axCNPJsm0[1] == .T. .and. !cIgnoraPCTransf)) //Adicionado por Luiz em 19/11/2014 para obrigar pedido de compras quando não for empresa do grupo (geralmente notas de transferência não precisa do pedido)  .and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
	cQuery:=" SELECT C7_EMISSAO EMISSAO,C7_PRECO PRECO,C7_LOJA LOJA,C7_NUM PEDIDO,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	cQuery:=cQuery + " AND C7_PRODUTO='"+ALLTRIM(_cProduto)+"' "
	cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
	cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA)>0 "
	cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
	cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
	cQuery:=cQuery + " ORDER BY R_E_C_N_O_ DESC "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		cMemo:=cMemo+DTOC(STOD(TCQ->EMISSAO))+"   "+TCQ->PEDIDO+"   "+TCQ->LOJA+"   "+ALLTRIM(STR(TCQ->QUANT,12,2))+"       "+transform(TCQ->PRECO,"@E 9,999.99")+CHR(13)+CHR(10)
		If _nQuantPed==0
			_nQuantPed:=TCQ->QUANT
			_nVlrPed:=TCQ->PRECO
		Endif
		Dbskip()
	End
	DbClosearea("TCQ")
Endif

If Empty(cMemo)
	cmemo:="Não existe nenhum pedido com este produto..."
Endif


_nCaixas:=LS1->CAIXAS
_nQuant:=(_nQE*_nCaixas)
_nPreco:=(LS1->TOTAL/IIF((_nQE*_nCaixas)<>0,(_nQE*_nCaixas),0))
_nQuantNF:=LS1->QUANTIDADE
_nTotal:=_nQuantNF * _nPreco

If _nCaixas==0
	_nQuant:=_nQuantNF
Else
	_nQuant:=(_nQE*_nCaixas)
Endif
_nPreco:=IIF(_nQuant <> 0,(_nTotal/_nQuant),_nTotal)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de parametros													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lGravou:=.F.

cPict1:="@E 9,999,999." // alterado de 99,999.00 para 9,999,999. por Luiz em 24/05/2011
For w:=1 to cDecQtd
	cPict1:=alltrim(cPict1)+"9"
Next

cPict2:="@E 99,999."
For w:=1 to cDecUni
	cPict2:=alltrim(cPict2)+"9"
Next

@ 120,040 TO 450,370 DIALOG oDef TITLE "Produto "+_cProduto
@ 005,005 say "Qtd.Emb."  FONT oFont1 OF oDef PIXEL
@ 015,005 get _nQE size 20,20 Picture "@E 999999" valid CALCULA()
@ 005,040 say "Cx.Nota"  FONT oFont1 OF oDef PIXEL
@ 015,040 get _nCaixas when .f. size 50,40 Picture cPict1
@ 005,100 say "Quantidade"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
@ 015,100 get _nQuant size 50,40 when .f. Picture cPict1

@ 025,005 say "Preço R$"  FONT oFont1 OF oDef PIXEL COLOR CLR_GREEN
@ 035,005 get _nPreco size 50,40 WHEN .F. Picture cPict2
@ 025,055 say "Total R$"  FONT oFont1 OF oDef PIXEL
@ 035,055 get _nTotal when .f. size 50,40 Picture "@E 99,999.99"

@ 060,005 say "Pedidos em aberto"  FONT oFont1 OF oDef PIXEL COLOR CLR_HBLUE
@ 070,005 say "Emissão    Pedido   Lj  Quantidade  Preço Unid."  FONT oFont1 OF oDef PIXEL COLOR CLR_HRED
@ 080,005 GET oMemo VAR cMemo MEMO SIZE 140,55 when .f. PIXEL OF oDef
@ 145,005 BUTTON "Confirmar" SIZE 50,10 ACTION GRAVANDO(lOpcao)
@ 145,060 BUTTON "Sair" SIZE 50,10 ACTION oDef:end()
ACTIVATE DIALOG oDef CENTER

If lGravou .and. lOpcao==2
	oAmarra:end()
Endif
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravando produto...													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static function GRAVANDO(lOpcao)
lDifer:=.F.
If _nQuantPed>0
	If _nQuant<>_nQuantPed
		Msgbox("Quantidade da Nota fiscal, diferente da quantidade do último pedido!","Diferença de Qtde","ALERT")
		lDifer:=.T.
	Endif
	
	If _nPreco>=(_nVlrPed+0.01)
		Msgbox("Preço unitário da Nota fiscal, diferente do preço do último pedido!","Diferença de Preço","ALERT")
		lDifer:=.T.
	Endif
	
	If (_nPreco)>(_nVlrPed+1)
		Msgbox("Preço da nota fiscal, muito maior que do último pedido!","Diferença de Preço","ALERT")
		lDifer:=.T.
	Endif
Endif

If lDifer
	cResp:=Msgbox("Deseja gravar o produto mesmo assim?","Atenção...","YESNO")
	If cResp==.F.
		Return
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifico se o codigo de barras existe								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOpcao==2
	_cProduto:=LS4->PRODUTO
Else
	_cProduto:=LS1->PRODUTO
Endif

_cCodBarras:=''
DbSelectarea("SB1")
DbSetorder(1)
Dbgotop()
Dbseek(xFilial("SB1")+_cProduto)
If Found()
	_cCodBarras:=SB1->B1_CODBAR
Endif

_nCusto:=ULTPED(_cProduto)
_nPrecoA:=IIF(_nQuant <> 0 ,(LS1->TOTAL/_nQuant), LS1->TOTAL)

If lOpcao==2
	DbSelectarea("LS1")
	Reclock("LS1",.F.)
	IF 100-(IIF(_nCusto <> 0,(_nPrecoA/_nCusto),0)*100)>xnPercMaxDiverg .OR. 100-(IIF(_nCusto <> 0,(_nPrecoA/_nCusto),0)*100)<-xnPercMaxDiverg   // Alterado por Luiz em 26/05/2011. Onde está xnPercMaxDiverg estava fixo 10
		LS1->OK:="O"
	Else
		LS1->OK:=""
	Endif
	LS1->PRODUTO:=_cProduto
	LS1->DESCRICAO:=LS4->DESCRICAO
	LS1->ALTERADO:="S"
	LS1->CAIXAS:=_nCaixas
	LS1->QUANTIDADE:=_nQuant
	LS1->PRECOFOR:=_nPreco
	LS1->PRECO:=IIF(_nQuant <> 0,(LS1->TOTAL/_nQuant),LS1->TOTAL)
	LS1->CUSTO:=_nCusto
	LS1->QE:=_nQE
	MsUnlock()
	
	DbSelectarea("LS5")
	Reclock("LS5",.T.)
	LS5->PRODUTO:=_cProduto
	MsUnlock()
Else
	DbSelectarea("LS1")
	Reclock("LS1",.F.)
	LS1->ALTERADO:="S"
	IF 100-(IIF(_nCusto <> 0,(_nPrecoA/_nCusto),0)*100)>xnPercMaxDiverg .OR. 100-(IIF(_nCusto <> 0,(_nPrecoA/_nCusto),0)*100)<-xnPercMaxDiverg   // Alterado por Luiz em 26/05/2011. Onde está xnPercMaxDiverg estava fixo 10
		LS1->OK:="O"
	Else
		LS1->OK:=""
	Endif
	LS1->CAIXAS:=_nCaixas
	LS1->QUANTIDADE:=_nQuant
	LS1->PRECOFOR:=_nPreco
	LS1->PRECO:=IIF(_nQuant <> 0,(LS1->TOTAL/_nQuant),LS1->TOTAL)
	LS1->CUSTO:=ULTPED(LS1->PRODUTO)
	LS1->QE:=_nQE
	MsUnlock()
Endif

OBRWI:obrowse:refresh()
OBRWP:obrowse:refresh()
ObjectMethod(oTela,"Refresh()")

DbSelectarea("LS1")
DbSetorder(1)
Dbgotop()
Dbseek(nSeek)

lGravou:=.T.
oDef:end()
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtrar produtos													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function FILTRE()
If Len(alltrim(_cFiltrox))>2
	Dbselectarea("LS4")
	Dbgotop()
	While !Eof()
		Reclock("LS4",.F.)
		dbdelete()
		MsUnlock()
		Dbskip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a pesquisa do produto foi sub-dividida			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cDesc1:=''
	_cDesc2:=''
	_cDesc3:=''
	
	For w:=1 to len(alltrim(_cFiltrox))
		If SUBSTR(ALLTRIM(_cFiltrox),w,1) $ ";/,"
			cont2:=(w-1)
			_cDesc1:=SUBSTR(_cFiltrox,1,cont2)
			w:=100
		Endif
	Next
	
	If !Empty(_cDesc1)
		_nInicio:=(cont2+2)
		_cString:=SUBSTR(ALLTRIM(_cFiltrox),_nInicio,50)
		If !empty(_cString)
			For w:=1 to len(alltrim(_cString))
				If SUBSTR(ALLTRIM(_cString),w,1) $ ";/,"
					cont2:=(w-1)
					_cDesc2:=SUBSTR(_cString,1,cont2)
					w:=100
				Endif
			Next
			
			If Empty(_cDesc2)
				_cDesc2:=alltrim(_cString)
			Endif
		Endif
	Endif
	
	If !Empty(_cDesc2)
		_nInicio:=(cont2+2)
		_cString2:=SUBSTR(ALLTRIM(_cString),_nInicio,50)
		If !empty(_cString2)
			For w:=1 to len(alltrim(_cString2))
				If SUBSTR(ALLTRIM(_cString2),w,1) $ ";/,"
					cont2:=(w-1)
					_cDesc3:=SUBSTR(_cString2,1,cont2)
					w:=100
				Endif
			Next
			
			If Empty(_cDesc3)
				_cDesc3:=alltrim(_cString2)
			Endif
		Endif
	Endif
	
	If Empty(_cDesc1)
		_cDescp1:="%"+alltrim(_cFiltrox)+"%"
	Else
		_cDescp1:="%"+alltrim(_cDesc1)+"%"
		_cDescp2:="%"+alltrim(_cDesc2)+"%"
		_cDescp3:="%"+alltrim(_cDesc3)+"%"
	Endif
	
	cQuery:=" SELECT B1_MSBLQL BLQ,B1_CODBAR CODBAR,B1_COD PRODUTO,B1_DESC DESCRICAO FROM "+RetSqlName('SB1')+" "
	cQuery:=cQuery + " 	WHERE B1_FILIAL='"+xFilial("SB1")+"' AND (B1_DESC LIKE '"+_cDescp1+"' OR B1_COD LIKE '"+alltrim(_cDescp1)+"') "
	IF !Empty(_cDesc2)
		cQuery:=cQuery + " AND B1_DESC LIKE '"+_cDescp2+"' "
	Endif
	IF !Empty(_cDesc3)
		cQuery:=cQuery + " AND B1_DESC LIKE '"+_cDescp3+"' "
	Endif
	cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		If cPedCom .and. (axCNPJsm0[1] == .F. .or. (axCNPJsm0[1] == .T. .and. !cIgnoraPCTransf)) //Adicionado por Luiz em 19/11/2014 para obrigar pedido de compras quando não for empresa do grupo (geralmente notas de transferência não precisa do pedido)  .and. AllTrim(_cUsuario)<>"NABI" .AND. AllTrim(_cUsuario)<>"ZEZINHO" .AND. AllTrim(_cUsuario)<>"NETO"
			lPedido:=TEMPED(TCQ->PRODUTO)
		Else
			lPedido:="Não"
		Endif
		If (lCheck1 .and. lPedido=="Sim" .or. lCheck1==.F.)
			
			DbSelectarea("SB1")
			DbSetorder(1)
			Dbgotop()
			Dbseek(xFilial("SB1")+TCQ->PRODUTO)
			
			If Empty(cAlmox)
				cAlmox:=SB1->B1_LOCPAD
			Else
				If !Empty(cTiposSaldo) // Se foi informado o armazém, verifica se existe filtro de tipo
					 if !(Posicione("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_TIPO") $ cTiposSaldo) // Alterado em 08/09/2014 Somente pega o B1_LOCPAD se não
					 	  cAlmox:=Posicione("SB1",1,xFilial("SB1")+TCQ->PRODUTO,"B1_LOCPAD")
					 Endif
				Endif
			Endif
			
			Reclock("LS4",.T.)
			LS4->PRODUTO:=TCQ->PRODUTO
			IF "SAIU" $ TCQ->DESCRICAO
				LS4->DESCRICAO:=SUBSTR(TCQ->DESCRICAO,6,45)
			Else
				LS4->DESCRICAO:=TCQ->DESCRICAO
			Endif
			LS4->SALDO:=POSICIONE("SB2",2,xFilial("SB2")+cAlmox+TCQ->PRODUTO,"B2_QATU-B2_RESERVA-B2_QEMP")
			LS4->QE:=SB1->B1_QE
			LS4->PEDIDO:=lPedido
			LS4->BLQ:=IIF(TCQ->BLQ=="1","Bloq.","Ativo")
			MsUnlock()
		Endif
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	
	Dbselectarea("LS4")
	Dbgotop()
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula produto														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function CALCULA()
If _nCaixas==0
	_nQuant:=_nQuantNF
Else
	_nQuant:=(_nQE*_nCaixas)
Endif
_nPreco:=IIF(_nQuant<> 0,(_nTotal/_nQuant),_nTotal)
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula produto														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function TEMPED(_cProduto)
cQuery:=" SELECT COUNT(*) QTD FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
cQuery:=cQuery + " AND C7_PRODUTO='"+alltrim(TCQ->PRODUTO)+"' "
cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA)>0 "
cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
TCQUERY cQuery NEW ALIAS "PED"
DbSelectarea("PED")
lPedido:=PED->QTD
DbClosearea("PED")

If lPedido>0
	_cTem:="Sim"
Else
	_cTem:="Não"
Endif
Return(_cTem)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refazer Nota fiscal													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function REFAZER()
cResp:=msgbox("Deseja refazer toda a nota fiscal?","Atenção...","YESNO")

If cResp
	PROCESS()
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebendo email automaticamente										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function POPEMAIL(lTLS, lSSL)
Local cPassw := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da conta POP													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotMsg   :=0
cAccount  := xCONTA
cServer   := xPOP
cPassw    := xSENHA
lConectou := .f.
lReceiveOK:= .f.
cBody     :=""
cTO		  :=""
cFrom	  :=""
cCc       :=""
cBcc      :=""
cSubject  :=""
cCmdEnv   :=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conectado ao servidor POP											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __nHdlPOP == 0
	if lTLS .and. lSSL
		CONNECT POP SERVER cServer ACCOUNT cAccount PASSWORD cPassw RESULT lConectou TLS SSL
	ElseIf lTLS
		CONNECT POP SERVER cServer ACCOUNT cAccount PASSWORD cPassw RESULT lConectou TLS
	ElseIf lSSL
		CONNECT POP SERVER cServer ACCOUNT cAccount PASSWORD cPassw RESULT lConectou SSL
	Else
		CONNECT POP SERVER cServer ACCOUNT cAccount PASSWORD cPassw RESULT lConectou
	EndIf
	
	If lConectou
		__nHdlPOP := 1
	Else
		__nHdlPOP := 0
	EndIf
EndIf
If __nHdlPOP <> 0
	POP MESSAGE COUNT nTotMsg RESULT lReceiveOk	
	If !lReceiveOk
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Erro no recebimento do e-mail                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GET MAIL ERROR cError
		ConOut("[IMPXML] Error recebimento e-mail via POP: " + cError)
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Erro na conexao com o POP Server                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GET MAIL ERROR cError
	ConOut("[IMPXML] Error conexão com servidor POP: " + cError)
EndIf

If !lConectou .or. !lReceiveOk
	Msgbox("Não foi possível ler emails da conta...")
Else
	If nTotMsg>0
		Msgbox("Existem "+alltrim(str(nTotMsg,5,0))+" novas mensagens...","Atenção...","INFO")
	Endif
	For w:=1 to nTotMsg
		aFiles:={}
		If lCheck3 //Adicionado por Luiz em 22/04/2012 para permitir salvar cópia do e-mail no servidor
			RECEIVE MAIL MESSAGE w FROM cFrom TO cTo CC cCc BCC cBcc SUBJECT cSubject BODY cBody ATTACHMENT aFiles SAVE IN (_cPastaXML ) //Alterado em 23/08/2012 o local de salvamento de xcNPastaP para _cPastaXML para melhorias no compartilhamento entre empresas / filiais
		Else
			RECEIVE MAIL MESSAGE w FROM cFrom TO cTo CC cCc BCC cBcc SUBJECT cSubject BODY cBody ATTACHMENT aFiles SAVE IN (_cPastaXML ) DELETE  //Alterado em 23/08/2012 o local de salvamento de xcNPastaP para _cPastaXML para melhorias no compartilhamento entre empresas / filiais
		Endif
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desconectando														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lConectou
	DISCONNECT POP SERVER Result lDisConectou
	If !lDisConectou
		Alert ("Erro ao disconectar do Servidor de e-mail - " + cServer)
	Endif
EndIf
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebendo email automaticamente										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function bPOPEMAIL()
Local cPassw := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados da conta POP													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotMsg   :=0
cAccount  := xCONTA
cServer   := xPOP
cPassw    := xSENHA
lConectou := .f.
cBody     :=""
cTO		  :=""
cFrom	  :=""
cCc       :=""
cBcc      :=""
cSubject  :=""
cCmdEnv   :=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Conectado ao servidor POP											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CONNECT POP SERVER cServer ACCOUNT cAccount PASSWORD cPassw RESULT lConectou
POP MESSAGE COUNT nTotMsg

If nTotMsg>0
	Msgbox("Existem "+alltrim(str(nTotMsg,5,0))+" novas mensagens...","Atenção...","INFO")
Endif

If !lConectou
	Msgbox("Não foi possível ler emails da conta...")
Else
	For w:=1 to nTotMsg
		aFiles:={}
		If lCheck3 //Adicionado por Luiz em 22/04/2012 para permitir salvar cópia do e-mail no servidor
			RECEIVE MAIL MESSAGE w FROM cFrom TO cTo CC cCc BCC cBcc SUBJECT cSubject BODY cBody ATTACHMENT aFiles SAVE IN (_cPastaXML ) //Alterado em 23/08/2012 o local de salvamento de xcNPastaP para _cPastaXML para melhorias no compartilhamento entre empresas / filiais
		Else
			RECEIVE MAIL MESSAGE w FROM cFrom TO cTo CC cCc BCC cBcc SUBJECT cSubject BODY cBody ATTACHMENT aFiles SAVE IN (_cPastaXML ) DELETE  //Alterado em 23/08/2012 o local de salvamento de xcNPastaP para _cPastaXML para melhorias no compartilhamento entre empresas / filiais
		Endif
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desconectando														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lConectou
	DISCONNECT POP SERVER Result lDisConectou
	If !lDisConectou
		Alert ("Erro ao disconectar do Servidor de e-mail - " + cServer)
	Endif
EndIf
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebendo email automaticamente		(novo modelo usando SSL)		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RECEMAIL(lTLS, lSSL) 
     Local oMessage
     Local nNumMsg := 0 
     Local nTam    := 0 
     Local nI      := 0 
     Local nRet    := 0
     Local cNomeArq := ""
     Local _nInd   := 1 //Contador de anexos
     Local aAttInfo := {}
     Local xRet
     Local nQtdAnexos := 0
     Local nPortPOP := iif(lSSL,995,110)
     Local nPortSMTP := iif(lTLS,587,iif(lSSL,465,25))
     Local cBaseName := GetSrvProfString( "RootPath", "" ) 
	
     //Cria uma nova conexão, agora de POP 
     // Sintaxe: TMailManager(): Init ( < cMailServer>, < cSmtpServer>, < cAccount>, < cPassword>, [ nMailPort], [ nSmtpPort] ) --> nReturn

     oServerXML := TMailManager():New()

     If lSSL
       	oServerXML:SetUseSSL(.T.)
     EndIF
          
	 If lTLS      
     	oServerXML:SetUseTLS(.T.)
     EndIf
     
     oServerXML:Init( xPOP, "smtp.gmail.com", xCONTA, xSENHA, nPortPOP, nPortSMTP ) 

     // Define o Timeout SMTP 
     if oServerXML:SetSMTPTimeout(20) != 0 
          alert("[ERROR]Falha ao definir timeout SMTP") 
          return .F. 
     endif 
       
     // Conecta ao servidor 
     nRet := oServerXML:smtpConnect() 
     if nRet <> 0 
          Alert("[ERROR]Falha ao conectar: " + oServerXML:getErrorString(nRet)) 
          oServerXML:smtpDisconnect() 
          return .F. 
     endif 
       
     // Realiza autenticacao no servidor 
     nRet := oServerXML:smtpAuth(xCONTA, xSENHA) 
     if nRet <> 0 
          Alert("[ERROR]Falha ao autenticar: " + oServerXML:getErrorString(nRet)) 
          oServerXML:smtpDisconnect() 
          return .F. 
     endif
       
     If oServerXML:SetPopTimeOut( 20 ) != 0 
          Conout( "Falha ao setar o time out" ) 
          Return .F. 
     EndIf 
       
	 nRet := oServerXML:PopConnect()

     If nRet != 0 
          Conout( "[IMPXML]Falha ao conectar ao servidor POP usando Gmail" ) 
          Conout(nRet)
          Conout(oServerXML:GetErrorString(nRet))
   		  Msgbox("Erro ao conectar ao servidor POP do Gmail. Código de erro retornado pelo servidor nesta tentativa de conexão: " + AllTrim(Str(nRet)) + "= " + oServerXML:GetErrorString(nRet),"Atenção...","INFO")	
          Return .F. 
     EndIf 

     //Quantidade de mensagens 
     oServerXML:GetNumMsgs( @nNumMsg ) 
     nTam := nNumMsg 

	If nTam>0
		Msgbox("Existem "+alltrim(str(nTam,5,0))+" novas mensagens...","Atenção...","INFO")
	Else
		Msgbox("Não existem novas mensagens no servidor...","Atenção...","INFO")	
		Return .F. 
	Endif

    // INICIA O OBJETO 
    oMessage := TMailMessage():New() 
    For nI := 1 To nTam              
          //Limpa o objeto da mensagem 
          oMessage:Clear()                                           
          //Recebe a mensagem do servidor 
          nRet := oMessage:Receive(oServerXML,nI) 

	     If nRet != 0 
	          Conout( "[IMPXML]Falha ao baixar e-mail do servidor POP usando Gmail" ) 
	          Conout(nRet)
	          Conout(oServerXML:GetErrorString(nRet))
       		  Msgbox("Erro ao baixar e-mails. Talvez seja necessário baixar manualmente algum e-mail. Verifique a caixa de entrada via webmail e confira se todos " +;
	   		  "os e-mails já foram baixados. Também poderá acessar a configurações da conta e ativar o POP para mensagens já baixadas, para que o sistema consiga " +;
   			  "baixar os e-mails novamente. Código de erro retornado pelo servidor nesta tentativa de conexão: " + AllTrim(Str(nRet)) + "= " + oServerXML:GetErrorString(nRet),"Atenção...","INFO")
	          Return .F. 
	     EndIf 
	
          //Quantidade de anexos na mensagem            
          nQtdAnexos := oMessage:GetAttachCount()
          //ALERT("Qtde de anexos:" + Str(nQtdAnexos))  //tmp para debug 

          //Salva os Anexos na pasta
          If nQtdAnexos > 0
	          For _nInd := 1 to nQtdAnexos
 		  		aAttInfo := oMessage:GetAttachInfo( _nInd )
    	  		//varinfo( "", aAttInfo ) //tmp para debug
	            if aAttInfo[1] == ""
			      cNomeArq := "message." + SubStr( aAttInfo[2], At( "/", aAttInfo[2] ) + 1, Len( aAttInfo[2] ) )
			    else
			      cNomeArq := aAttInfo[1]
			    endif
	          	Conout("[IMPXML] Nome do anexo " + Alltrim(Str(_nInd)) + ": " + cNomeArq)
	          	Conout("[IMPXML] Caminho e Nome  " + Alltrim(Str(_nInd)) + ": " + _cPastaXML)
	          	xRet := oMessage:SaveAttach(_nInd,cBaseName+_cPastaXML+_xcBarraDir+TrataNome(cNomeArq)) //(USANDO _nInd -1 PORQUE TEM UM BUG NA ROTINA padrão)  //Alterado em 23/08/2012 para variável _cPastaXML para melhorar integração entre filiais / empresa quanto a compartilhamento de pasta do XML
			    if xRet == .F.
			      conout( "[IMPXML] ERRO:Não foi possível salvar o anexo: " + cBaseName+_cPastaXML+_xcBarraDir+TrataNome(cNomeArq)  )
			      loop
			    endif
	          Next _nInd
	      EndIf
          // recebe o anexo da mensagem em string 
                                                     
          //Escreve no server os dados do e-mail recebido
          //ALERT( oMessage:cFrom +" "+ oMessage:cTo+" "+oMessage:cCc +" "+oMessage:cSubject +" "+ oMessage:cBody ) //, {"OK"},3)  //tmp para debug 

		  If !lCheck3 .and. !lGmail //se não é para manter o e-mail, então deleta a mensagem após o processamento da mesma //Alterado em 26/03/2015 pois não aceita no Gmail
	          oMessage:DeleteMsg(nI)
	      ElseIf !lCheck3 .and. lGmail
	      	  oServerXML:DeleteMsg(nI)
	   	  EndIf
    Next 

     //Desconecta do servidor POP 
     oServerXML:POPDisconnect() 
Return
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Final do Recebendo email automaticamente	(novo modelo) 			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//Função para tratar nome dos anexos pois em alguns provedores ficam registrados caracteres especiais no nome do arquivo, por exemplo, "=?iso-8859-1? impedindo que seja salvo
STATIC FUNCTION TrataNome(_cFile)
  Local _cNome    := ""                
  Local _nPosFim  := 0
  Local _nPosIni  := 0
  
  _cFile := ALLTRIM(_cFile)
  
  // o nome do arquivo veio sem strings de complemento
  IF AT("?",_cFile) == 0 
   _cNome := _cFile                               
   
  // limpar o nome do arquivo e separar o formato do nome correto 
  Else
   _nPosFim := RAT("?",_cFile)
   _nPosIni := RAT("?",SUBSTR(_cFile,1,_nPosFim-1))
   
   _cNome := SUBSTR(_cFile,_nPosIni+1,_nPosFim-_nPosIni-1)
  EndIf
RETURN(_cNome)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Excluir amarracao													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function EXCAMA()
If Empty(LS1->OK) .OR. LS1->OK=="O"
	cResp:=msgbox("Deseja excluir a amarração do produto?","Atenção...","YESNO")
	
	If cResp
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Excluindo da tabela de produtos identificados						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea("LS5")
		DbSetorder(1)
		Dbgotop()
		Dbseek(LS1->PRODUTO)
		If Found()
			Reclock("LS5",.F.)
			dbdelete()
			MsUnlock()
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Excluindo da tabela amarracao produto x fornecedor					³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea(iif(LS3->FORNEC $ "B/D","SA7","SA5"))
		DbSetorder(1)
		Dbgotop()
		Dbseek(xFilial(iif(LS3->FORNEC $ "B/D","SA7","SA5"))+LS3->FORNEC+LS3->LOJA+LS1->PRODUTO)
		If Found()
			IF LS3->FORNEC $ "B/D"
				Reclock("SA7",.F.)
				dbdelete()
				MsUnlock()
			ELSE
				Reclock("SA5",.F.)
				dbdelete()
				MsUnlock()
			ENDIF
		Endif
		
		Reclock("LS1",.F.)
		LS1->DESCRICAO:=LS1->DESCORI
		LS1->PRODUTO:="999999"
		LS1->OK:="X"
		MsUnlock()
	Endif
Else
	Msgbox("Não existe amarração para este produto!")
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ultimo preco de pedido												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ULTPED(_cProduto)
_nPedido:=0
_nQtd:=1

cQuery:=" SELECT C7_PRECO PRECO FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' AND C7_PRODUTO='"+alltrim(_cProduto)+"' AND C7_FORNECE='"+LS3->FORNEC+"' AND C7_PRECO>0 AND D_E_L_E_T_=' ' ORDER BY C7_EMISSAO DESC "
TCQUERY cQuery NEW ALIAS "TCQ"
DbSelectarea("TCQ")
While !Eof() .and. _nQtd==1
	_nPedido:=TCQ->PRECO
	_nQtd:=2
	Dbskip()
End
Dbclosearea("TCQ")

If _nPedido<=0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao encontre, ultimo preco de entrada							³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nPedido:=POSICIONE("SB1",1,xFilial("SB1")+_cProduto,"B1_UPRC")
Endif
Return(_nPedido)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Eliminar pedido														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ELIMINAR()

If !VerSenha(7) //-- Evento 7 - Excluir de pedido de compras
	Msgbox("Usuário sem permissão para excluir pedido de compras!","Atenção...","STOP")
	Return
Endif

IF (DDATABASE-LS2->EMISSAO)<=30
	msgbox("O pedido tem que ter mais de 30 dias de vencimento!","Atenção...","STOP")
	Return
Endif

IF LS2->OK<>"X"
	cResp:=msgbox("Deseja eliminar o resíduo do pedido "+LS2->PEDIDO+"?","Atenção...","YESNO")
	
	If cResp
		lEntrou:=.F.
		DbSelectarea("SC7")
		DbSetorder(1)
		dbgotop()
		Dbseek(xFilial("SC7")+LS2->PEDIDO)
		While !Eof() .and. ALLTRIM(SC7->C7_NUM)==ALLTRIM(LS2->PEDIDO)
			IF SC7->C7_QTDACLA<=0
				IF SC7->C7_RESIDUO<>"S" .and. (SC7->C7_QUANT-SC7->C7_QUJE)>0
					Reclock("SC7",.F.)
					SC7->C7_RESIDUO:="S"
					MsUnlock()
					lEntrou:=.T.
					
					DbSelectarea("SB2")
					DbSetorder(2)
					Dbgotop()
					Dbseek(xFilial("SB2")+SC7->C7_LOCAL+SC7->C7_PRODUTO)
					If Found()
						Reclock("SB2",.F.)
						SB2->B2_SALPEDI:=(SB2->B2_SALPEDI-(SC7->C7_QUANT-SC7->C7_QUJE))
						MsUnlock()
					Endif
				Endif
			Endif
			DbSelectarea("SC7")
			Dbskip()
		End
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apagando pedido do browse											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEntrou
			DbSelectarea("LS2")
			Reclock("LS2",.F.)
			dbdelete()
			MsUnlock()
			dbgobottom()
			Msgbox("Pedido eliminado com sucesso!","Atenção...","INFO")
		Endif
	Endif
Else
	Msgbox("Este pedido não pode ser eliminado!","Atenção...","ALERT")
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mensagem nota fiscal												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function MSGNF(_cMensag)

If !Empty(_cMensag)
	DEFINE MSDIALOG oMensNF FROM 0,0 TO 290,415 PIXEL TITLE "Mensagem da Nota Fiscal"
	@ 005,005 GET oMemo VAR _cMensag MEMO SIZE 200,135 FONT oFont2 PIXEL OF oMensNF
	ACTIVATE MSDIALOG oMensNF CENTER
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao Legenda														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function LEGENDA()
_cLegenda := "Legenda dos produtos"

aCorLegen := { 	{ 'BR_VERDE'   ,"Produto OK!" },;
{ 'BR_VERMELHO',"Sem identificação" },;
{ 'BR_AZUL',"Preço diferente em " + transform(xnPercMaxDiverg,"@E 999.99") +"%" }}  // Alterado por Luiz em 26/05/2011. Onde está xnPercMaxDiverg estava fixo 10
BrwLegenda(_cLegenda,"Status do Produto",aCorLegen)
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao Consulta SEFAZ												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function SEFAZ(_xcNoXML, _xcChXML)
Local cEndWeb := ""
Local _xcPasta := ""
Local _xnPosBarra := 1
Local _xnPos  := 0
Local _xaFiles := {}
//Local oDlg2 

If substr(lower(_cURL),1,2) == "ht"
	
	cEndWeb:=lower(_cURL)+AllTrim(iif(_xcChXML==nil,LS3->CHAVE, _xcChXML))
	IF !IsSrvUnix()
		Aviso("Arquivo XML em Windows", "O site da receita será aberto já passando a chave completa usando a URL a seguir: " + chr(10) + chr(13) + cEndWeb  + chr(10) + chr(13) + ;
		" Caso tenha algum problema com a URL acima copie a chave de acesso a seguir e cole manualmente no site da receita: "  + chr(10) + chr(13) + AllTrim(iif(_xcChXML==nil,LS3->CHAVE, _xcChXML)), {"OK"},3)
		ShellExecute("open",cEndWeb,"","",5)
	ELSE
		Aviso("Arquivo XML em Linux/Outro SO", "O site da receita será aberto já passando a chave completa usando a URL a seguir: " + chr(10) + chr(13) + cEndWeb  + chr(10) + chr(13) + ;
		" Caso tenha algum problema com a URL acima copie a chave de acesso a seguir e cole manualmente no site da receita: "  + chr(10) + chr(13) + AllTrim(iif(_xcChXML==nil,LS3->CHAVE, _xcChXML)), {"OK"},3)
		WinExec(cEndWeb)
	ENDIF

Else
	_xnPos := At(".exe",lower(_cURL))

	While At("\",substr(_cURL,_xnPosBarra+1,_xnPos)) > 0
		_xnPosBarra += At("\",substr(_cURL,_xnPosBarra+1,_xnPos))
	End
	
	_xcPasta += Substr(_cURL,1,_xnPosBarra)
	
	//__CopyFile(xcNPastaP+"\"+LS3->XML,lower(_xcPasta))   //Copia arquivos no server
	_xaFiles := Directory(lower(_xcPasta) + iif(RIGHT(AllTrim(_xcPasta),1)==_xcBarraDir,"",_xcBarraDir) + '*.xml',"A")
    For xi := 1 to len(_xaFiles)	
		FERASE(lower(_xcPasta) + iif(RIGHT(AllTrim(_xcPasta),1)==_xcBarraDir,"",_xcBarraDir)+_xaFiles[xi][1])
    Next

	CpyS2T(_cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+iif(_xcNoXML==nil,LS3->XML,_xcNoXML),lower(_xcPasta))
	cEndWeb:= lower(_cURL) + ' ' + lower(_xcPasta) +  iif(_xcNoXML==nil,LS3->XML,_xcNoXML)
	//Aviso("Arquivo XML", cEndWeb , {"OK"},3)
	WinExec(cEndWeb)
EndIf	

//ShellExecute("open",cEndWeb,"","",0)
//ferase("%HOMEPATH%\" + ALLTRIM(aXML[i]))
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao NDF fornecedor												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function NDF()
RecLock("SE2",.T.)
SE2->E2_FILIAL  := xFilial("SE2")
SE2->E2_PREFIXO := "XML"
SE2->E2_NUM     := cNota
SE2->E2_PARCELA := ""
SE2->E2_TIPO	 := "NDF"
SE2->E2_EMISSAO := ddatabase
SE2->E2_VENCREA := ddatabase+30
SE2->E2_VENCTO  := ddatabase+30
SE2->E2_VENCORI := ddatabase+30
SE2->E2_MOEDA   := 1
SE2->E2_EMIS1   := dDataBase
SE2->E2_FORNECE := LS3->FORNEC
SE2->E2_LOJA    := LS3->LOJA
SE2->E2_VALOR   := _nExcedido
SE2->E2_SALDO   := _nExcedido
SE2->E2_VLCRUZ  := _nExcedido
If lItem==.F.
	SE2->E2_NOMFOR  := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS2->LOJA,"A2_NREDUZ")
Else
	SE2->E2_NOMFOR  := POSICIONE("SA2",1,xFilial("SA2")+LS3->FORNEC+LS3->LOJA,"A2_NREDUZ")
Endif
SE2->E2_ORIGEM  := "IMPXML"
MsUnlock()
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valor NDF do fornecedor												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VALORNDF()
_nExcedido:=0
Dbselectarea("LS1")
DbSetorder(1)
Dbgotop()
While !Eof()
	cQuery:=" SELECT COUNT(*) QTD,AVG(C7_PRECO) PRECO,SUM(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
	If lItem==.F.
		cQuery:=cQuery + " AND C7_NUM='"+LS2->PEDIDO+"' "
	Else
		cQuery:=cQuery + " AND C7_NUM='"+LS1->PEDIDO+"' "
		cQuery:=cQuery + " AND C7_ITEM='"+LS1->ITEM+"' "
	Endif
	cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
	cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
	cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
	TCQUERY cQuery NEW ALIAS "TCQ"
	DbSelectarea("TCQ")
	While !Eof()
		If (round(LS1->PRECO,2)>TCQ->PRECO) .AND. Round(TCQ->PRECO,2)>0
			_nExcedido:=_nExcedido+(LS1->QUANTIDADE*(round(LS1->PRECO,2)-Round(TCQ->PRECO,2)))
		Endif
		DbSelectarea("TCQ")
		Dbskip()
	End
	DbClosearea("TCQ")
	Dbselectarea("LS1")
	Dbskip()
End
Return(_nExcedido)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Manipulando arquivo de configuracao									³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function CONFARQ()
_lPOP:=space(100)
_lConta:=space(100)
_lSenha:=space(100)
_lUM:=space(100)
//_lLogo:=space(20)  //Retirado logos em 11/04/2012 por Luiz para já apresentar as informações complementares
_lPed:="Não"
_lNDF:="Não"
_lZeros:="Não"
_cURL:=space(500)


cResp:=msgbox("Deseja configurar os parametros da rotina?","Atenção...","YESNO")

If cResp
	cBuffer   := ""
	If File(cArqTxt)
		FT_FUSE(cArqTxt)
		FT_FGOTOP()
		ProcRegua(FT_FLASTREC())
		
		While !FT_FEOF()
			cBuffer := FT_FREADLN()
			If UPPER(SUBSTR(cBuffer,1,3))=="POP"
				_lPOP:=lower(ALLTRIM(SUBSTR(cBuffer,5,400)))+space(200)
			Endif
			If UPPER(SUBSTR(cBuffer,1,5))=="CONTA"
				_lConta:=lower(ALLTRIM(SUBSTR(cBuffer,7,400)))+space(200)
			Endif
			If UPPER(SUBSTR(cBuffer,1,5))=="SENHA"
				_lSenha:=iif(empty(SUBSTR(cBuffer,7,400)),space(100),xEnCode(ALLTRIM(SUBSTR(cBuffer,7,400)),"SENHAPOP3",.f.))
			Endif
			If UPPER(SUBSTR(cBuffer,1,2))=="UM"
				_lUM:=ALLTRIM(UPPER(SUBSTR(cBuffer,4,400)))+space(200)
			Endif
//			If UPPER(SUBSTR(cBuffer,1,4))=="LOGO"  //Retirado logos em 11/04/2012 por Luiz para já apresentar as informações complementares
//				_lLogo:=ALLTRIM(UPPER(SUBSTR(cBuffer,6,200)))+space(200)
//			Endif
			If UPPER(SUBSTR(cBuffer,1,10))=="PEDIDO=SIM"
				_lPed:="Sim"
			Endif
			If UPPER(SUBSTR(cBuffer,1,10))=="PEDIDO=-TR"
				_lPed:="Sim(-transf.)"
			Endif
			If UPPER(SUBSTR(cBuffer,1,3))=="NDF"
				_lNDF:="Sim"
			Endif
			If UPPER(SUBSTR(cBuffer,1,11))=="NFZEROS=SIM"
				_lZeros:="Sim"
			Endif
			If UPPER(SUBSTR(cBuffer,1,11))=="NFZEROS=PER"
				_lZeros:="Perguntar"
			Endif
			If UPPER(SUBSTR(cBuffer,1,11))=="PEDPROD=SIM"
				l2Check2:=.T.
			Endif
			If UPPER(SUBSTR(cBuffer,1,3))=="URL"
				_cURL:=ALLTRIM(UPPER(SUBSTR(cBuffer,5,500)))
			Endif
			If UPPER(SUBSTR(cBuffer,1,15))=="MANTEREMAIL=SIM"
				lCheck3:=.T.
			Endif
			If UPPER(SUBSTR(cBuffer,1,10))=="USATLS=SIM"
				lTLS:=.T.
			Endif		
			If UPPER(SUBSTR(cBuffer,1,10))=="USASSL=SIM"
				lSSL:=.T.
			Endif		
			If UPPER(SUBSTR(cBuffer,1,9))=="PORTASMTP"
				nPortSMTP:=lower(ALLTRIM(SUBSTR(cBuffer,10,400)))
			Endif		
			If UPPER(SUBSTR(cBuffer,1,8))=="PORTAPOP"
				nPortPOP:=lower(ALLTRIM(SUBSTR(cBuffer,9,400)))
			Endif
			If UPPER(SUBSTR(cBuffer,1,12))=="USAGMAIL=SIM"
				lGmail:=.T.
			Endif
			If UPPER(SUBSTR(cBuffer,1,12))=="USAPICTU=SIM"
				lAceitaMasc:=.T.
			Endif
			FT_FSKIP()
		EndDo
		FT_FUSE()
	Endif
	
	// Tabela de parãmetros da(s) empresa(s) / Filiais
	aCampos	:= {{"EMPRESA","C",_xTCodEmp,0 },;
	{"FILIAL","C",_xTCodFil,0 },;
	{"NOME","C",20,0 },;
	{"ALMOX","C",2,0 },;
	{"ALMOXDEV","C",2,0 },;	
	{"ALMOXTIPOS","C",18,0 },;
	{"PEDIDO","C",2,0 },;
	{"SERIE","C",3,0 },;
	{"ESPECIE","C",5,0 },;
	{"DECQTD","N",2,0 },;
	{"DECUNI","N",2,0 },;
	{"EMAIL","C",300,0 },;
	{"PASTA","C",60,0 },;
	{"CFOPDEV","C",300,0 },;
	{"CFOPBEN","C",300,0 },;
	{"QTDEZEROSE","C",1,0 }} //Adicionado em 16/04/2015
	
	cArqTrab  := CriaTrab(aCampos)
	dbUseArea( .T.,, cArqTrab, "LS1", if(.F. .OR. .F., !.F., NIL), .F. )
	IndRegua("LS1",cArqTrab,"EMPRESA+FILIAL",,,)
	dbSetIndex( cArqTrab +OrdBagExt())
	dbSelectArea("LS1")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Empresas/Filiais - SIGAMAT											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectarea("SM0")
	Dbsetorder(1)
	Dbgotop()
	While !Eof()

		if xKeyChave != Substr(AllTrim(SM0->M0_CGC),1,8) //Adicionado If para mostrar apenas empresas/filiais liberadas
			DbSelectarea("SM0")
			dbSkip()
		Else
			_lSerie:=space(03)
			_lAlmox:=space(02)
			_lAlmoxDEV:=space(02)
			_lTiposSaldo:=Space(18) // Adicionado em 08/09/2014
			_lQtdeZeroEsq:=Space(1) // Adicionado em 16/04/2015
			_lEmail:=space(300)
			_lPedido:=space(02)
			_lEspecie:="SPED "
			_lDecQtd:=TamSX3("D1_QUANT")[2]
			_lDecUni:=TamSX3("D1_VUNIT")[2]
			_lPasta:=space(60)
			_cCFOPsDEV:=space(300)
			_cCFOPsBEN:=space(300)
			
			If File(cArqTxt)
				FT_FUSE(cArqTxt)
				FT_FGOTOP()
				ProcRegua(FT_FLASTREC())
				
				While !FT_FEOF()
					cBuffer := FT_FREADLN()
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil))==SM0->M0_CODIGO+SM0->M0_CODFIL
						_lSerie:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+2,3))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+1))=="S"+SM0->M0_CODIGO+SM0->M0_CODFIL
						_lAlmox:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+3,2))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+2))=="SD"+SM0->M0_CODIGO+SM0->M0_CODFIL
						_lAlmoxDEV:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+4,2))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+6))=="STIPOS"+SM0->M0_CODIGO+SM0->M0_CODFIL
						_lTiposSaldo:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+8,18))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+6))=="SQTDZE"+SM0->M0_CODIGO+SM0->M0_CODFIL  //Adicionado em 16/04/2015
						_lQtdeZeroEsq:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+8,1))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+5))=="EMAIL"+SM0->M0_CODIGO+SM0->M0_CODFIL
						_lEmail:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+7,300))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+5))=="PASTA"+SM0->M0_CODIGO+SM0->M0_CODFIL
						_lPasta:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+7,60))
						_cPastaXML:=_lPasta
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+1))=="P"+SM0->M0_CODIGO+SM0->M0_CODFIL
						_lPedido:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+3,2))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+3))=="ESP"+SM0->M0_CODIGO+SM0->M0_CODFIL
						_lEspecie:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+5,5))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+6))=="DECQTD"+SM0->M0_CODIGO+SM0->M0_CODFIL
						_lDecQtd:=val(ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+8,5)))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+6))=="DECUNI"+SM0->M0_CODIGO+SM0->M0_CODFIL
						_lDecUni:=val(ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+8,5)))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+7))=="CFOPDEV"+SM0->M0_CODIGO+SM0->M0_CODFIL //Adiciondo em 27/08/2012 para tratar CFOPs devolucao
						_cCFOPsDEV:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+9,300))
					Endif
					If UPPER(SUBSTR(cBuffer,1,_xTCodEmp+_xTCodFil+7))=="CFOPBEN"+SM0->M0_CODIGO+SM0->M0_CODFIL //Adiciondo em 27/08/2012 para tratar CFOPs Beneficiamento
						_cCFOPsBEN:=ALLTRIM(SUBSTR(cBuffer,_xTCodEmp+_xTCodFil+9,300))
					Endif
					FT_FSKIP()
				EndDo
				FT_FUSE()
			Endif
			
			Reclock("LS1",.T.)
			LS1->EMPRESA:=SM0->M0_CODIGO
			LS1->FILIAL:=SM0->M0_CODFIL
			LS1->NOME:=UPPER(SM0->M0_FILIAL)
			LS1->SERIE:=_lSerie
			LS1->ESPECIE:=_lEspecie
			LS1->ALMOX:=_lAlmox
			LS1->ALMOXDEV:=_lAlmoxDEV
			LS1->ALMOXTIPOS:=_lTiposSaldo
			LS1->QTDEZEROSE:=_lQtdeZeroEsq //Adicionado em 16/04/2015
			LS1->EMAIL:=_lEmail
			LS1->PEDIDO:=_lPedido
			LS1->DECQTD:=_lDecQtd
			LS1->DECUNI:=_lDecUni
			LS1->PASTA:=_lPasta
			LS1->CFOPDEV:=_cCFOPsDEV
			LS1->CFOPBEN:=_cCFOPsBEN
			MsUnlock()
			DbSelectarea("SM0")
			Dbskip()
		Endif
	End
	
	aTitulo := {}
	AADD(aTitulo,{"EMPRESA","Empresa"})
	AADD(aTitulo,{"FILIAL","Filial"})
	AADD(aTitulo,{"NOME","Nome"})
	AADD(aTitulo,{"ESPECIE","Espécie"})
	AADD(aTitulo,{"SERIE","Série"})
	AADD(aTitulo,{"ALMOX","Saldos"})
	AADD(aTitulo,{"ALMOXDEV","Saldos Devolução"})
	AADD(aTitulo,{"ALMOXTIPOS","Tipos Produto para Almox. Saldos"})
	AADD(aTitulo,{"PEDIDO","Pedidos"})
	AADD(aTitulo,{"EMAIL","Emails para notas fiscais - Recusadas ( ; para separar )"})
	AADD(aTitulo,{"PASTA","Ler XMLs na pasta (se em branco usa padrão por empresa/filial)"})
	AADD(aTitulo,{"CFOPDEV","CFOPs Devolução"})	
	AADD(aTitulo,{"CFOPBEN","CFOPs Beneficiamento"})		
	
	DbSelectarea("LS1")
	Dbgotop()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcoes COMBOBOX														³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPedidos:={}
	AADD(aPedidos,"Sim")
	AADD(aPedidos,"Não")
	AADD(aPedidos,"Sim(-transf.)")
	
	aNDF:={}
	AADD(aNDF,"Sim")
	AADD(aNDF,"Não")
	
	aZeros:={}
	AADD(aZeros,"Sim")
	AADD(aZeros,"Não")
	AADD(aZeros,"Perguntar")
	
	If Empty(_cURL)
		_cURL:="http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&nfe="+space(100)
	Else
		_cURL:=_cURL+space(500-len(_cURL))
	Endif
	_cURL:=lower(_cURL)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apagando arquivo anterior										z	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Ferase(cArqTxt)
	
	DEFINE MSDIALOG oConfig FROM 0,0 TO 525,400 PIXEL TITLE "Configuração do arquivo CFGXML.TXT"
	@ 005,005 say "Servidor POP do recebimento do XML" SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 005,135 CHECKBOX "Usa Gmail" VAR lGmail
	@ 015,005 get _lPOP size 190,20
	@ 030,005 say "Email para recebimento do XML" SIZE 70,40 FONT oFont6 OF oConfig PIXEL
	@ 040,005 get _lConta size 90,20
	@ 050,003 CHECKBOX "Manter cópia no servidor" VAR lCheck3
		@ 050,075 CHECKBOX "Usa TLS" VAR lTLS
		@ 050,105 CHECKBOX "Usa SSL" VAR lSSL
		@ 030,135 say "NDF Fornecedor?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
		@ 040,135 COMBOBOX _lNDF ITEMS aNDF SIZE 30,20
	@ 060,005 say "Senha do Email" SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 070,005 get _lSenha size 60,20 valid .t. PASSWORD
//	@ 055,070 say "Logo (BMP)" SIZE 150,40 FONT oFont6 OF oConfig PIXEL  //Retirado logos em 11/04/2012 por Luiz para já apresentar as informações complementares
//	@ 065,070 get _lLogo size 40,20 picture "@!"
		@ 055,135 say "Ped.Compras?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
		@ 065,135 COMBOBOX _lPed ITEMS aPedidos SIZE 60,20
	@ 080,005 say "UM-Unitárias - Ex.: UN/PC/LT" SIZE 150,40 FONT oFont6 OF oConfig PIXEL
	@ 090,005 get _lUM size 100,20 picture "@!"
		@ 080,135 say "Nota (9 Dígitos)?" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
		@ 090,135 COMBOBOX _lZeros ITEMS aZeros SIZE 60,20
	@ 105,005 CHECKBOX "Apenas números/letras (código produto XML)" VAR lAceitaMasc
	@ 105,135 CHECKBOX "Pedido por Produto?" VAR l2Check2
	@ 115,005 say "Empresas/Filiais liberadas para uso" SIZE 150,40 FONT oFont5 OF oConfig PIXEL COLOR CLR_HBLUE
	@ 125,005 TO 220,195 BROWSE "LS1" OBJECT OBRWP FIELDS aTitulo
	
	@ 225,005 say "URL Consulta NF-e SEFAZ" SIZE 150,40 FONT oFont6 OF oConfig PIXEL COLOR CLR_HRED
	@ 235,005 get _cURL size 190,25
	
	OBRWP:OBROWSE:bLDblClick   := {||ATUCFG()}
	OBRWP:oBrowse:oFont := TFont():New ("Courier New", 06, 16)
	@ 250,005 BUTTON "Salvar" SIZE 60,10 ACTION oConfig:end()
	ACTIVATE MSDIALOG oConfig CENTER
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criando novo arquivo												³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cr:=chr(13)+chr(10)
	_nDiv    := 0
	_cDados     :={}
	
	AADD( _cDados,"POP="+alltrim(_lPOP))
	AADD( _cDados,"CONTA="+alltrim(_lConta))
	AADD( _cDados,"SENHA="+_lSenha)
	AADD( _cDados,"UM="+alltrim(_lUM))
//	AADD( _cDados,"LOGO="+alltrim(_lLogo))  //Retirado logos em 11/04/2012 por Luiz para já apresentar as informações complementares
	If l2Check2
		AADD( _cDados,"PEDPROD=SIM")
	Endif
	If lCheck3
		AADD( _cDados,"MANTEREMAIL=SIM")
	Endif
	If lTLS
		AADD( _cDados,"USATLS=SIM")
	Endif
	If lSSL
		AADD( _cDados,"USASSL=SIM")
	Endif
	If lGmail
		AADD( _cDados,"USAGMAIL=SIM")
	EndIf
	If lAceitaMasc
		AADD( _cDados,"USAPICTU=SIM")
	EndIf

	
	DbSelectarea("LS1")
	Dbgotop()
	While !Eof()
		IF !Empty(LS1->SERIE)
			AADD( _cDados,LS1->EMPRESA+LS1->FILIAL+"="+LS1->SERIE)
		Endif
		If !Empty(LS1->ALMOX)
			AADD(_cDados,"S"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->ALMOX)
		Endif
		If !Empty(LS1->ALMOXDEV)
			AADD(_cDados,"SD"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->ALMOXDEV)
		Endif
		If !Empty(LS1->ALMOXTIPOS)
			AADD(_cDados,"STIPOS"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->ALMOXTIPOS)
		Endif
		If !Empty(LS1->QTDEZEROSE)  //Adicionado em 16/04/2015
			AADD(_cDados,"SQTDZE"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->QTDEZEROSE)
		Endif		
		If !Empty(LS1->EMAIL)
			AADD(_cDados,"EMAIL"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->EMAIL)
		Endif
		If !Empty(LS1->PASTA)
			AADD(_cDados,"PASTA"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->PASTA)
		Endif		
		If !Empty(LS1->PEDIDO)
			AADD(_cDados,"P"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->PEDIDO)
		Endif
		If Empty(LS1->ESPECIE)
			AADD(_cDados,"ESP"+LS1->EMPRESA+LS1->FILIAL+"=SPED")
		Else
			AADD(_cDados,"ESP"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->ESPECIE)
		Endif
		If !Empty(LS1->DECUNI)
			AADD(_cDados,"DECUNI"+LS1->EMPRESA+LS1->FILIAL+"="+ALLTRIM(STR(LS1->DECUNI)))
		Else
			AADD(_cDados,"DECUNI"+LS1->EMPRESA+LS1->FILIAL+"=2")
		Endif
		If !Empty(LS1->DECQTD)
			AADD(_cDados,"DECQTD"+LS1->EMPRESA+LS1->FILIAL+"="+ALLTRIM(STR(LS1->DECQTD)))
		Else
			AADD(_cDados,"DECQTD"+LS1->EMPRESA+LS1->FILIAL+"=2")
		Endif
		If !Empty(LS1->CFOPDEV)
			AADD(_cDados,"CFOPDEV"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->CFOPDEV)
		Endif
		If !Empty(LS1->CFOPBEN)
			AADD(_cDados,"CFOPBEN"+LS1->EMPRESA+LS1->FILIAL+"="+LS1->CFOPBEN)
		Endif
		Dbskip()
	End
	If alltrim(_lPed)=="Sim"
		AADD( _cDados,"PEDIDO=SIM")
	Endif
	If alltrim(_lPed)=="Sim(-transf.)"
		AADD( _cDados,"PEDIDO=-TR")
	Endif
	If alltrim(_lNDF)=="Sim"
		AADD( _cDados,"NDF=SIM")
	Endif
	If alltrim(_lZeros)=="Sim"
		AADD( _cDados,"NFZEROS=SIM")
	Endif
	If alltrim(_lZeros)=="Perguntar"
		AADD( _cDados,"NFZEROS=PER")
	Endif
	AADD( _cDados,"URL="+alltrim(_cURL))
	
	hnda:=Fcreate(cArqTxt,0)
	for x := 1 TO len( _cDados )
		dados := IIF(SUBSTR(_cDados[x],1,5) == "SENHA","SENHA="+AllTrim(xEnCode(AllTrim(_lSenha), "SENHAPOP3", .t.)),_cDados[x])
		If SUBSTR(_cDados[x],1,nxQtdDigEmp+nxQtdDigFil+5) == "PASTA"+SM0->M0_CODIGO+SM0->M0_CODFIL
			_cPastaXML:=AllTrim(SUBSTR(_cDados[x],nxQtdDigEmp+nxQtdDigFil+7,60))
		EndIf
		Fwrite(hnda,dados+cr)
	next
	Fclose(hnda)
	FClose(cArqTxt)
	
	Msgbox("Configurações salvas com sucesso!","Atenção...","INFO")
	
	Dbselectarea("LS1")
	dbCloseArea("LS1")
	fErase( cArqTrab+ ".DBF" )
	fErase( cArqTrab+ OrdBagExt() )
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza informacoes arquivo de configuracao						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ATUCFG()
_lAlmox:=LS1->ALMOX
_lAlmoxDEV:=LS1->ALMOXDEV
_lTiposSaldo:=LS1->ALMOXTIPOS //Adicionado em 08/09/2014 para permitir filtrar tipo de produtos
_lQtdeZeroEsq:=LS1->QTDEZEROSE //Adicionado em 16/04/2015
_lSerie:=LS1->SERIE
_lEmail:=LS1->EMAIL
_lPedido:=LS1->PEDIDO
_lEspecie:=LS1->ESPECIE
_lDecQtd:=LS1->DECQTD
_lDecUni:=LS1->DECUNI
_lPasta:=LS1->PASTA
_cCFOPsDEV:=LS1->CFOPDEV
_cCFOPsBEN:=LS1->CFOPBEN

DEFINE MSDIALOG oAtuCfg TITLE "Informe os parametros..." From 9,0 To 40,70 OF oMainWnd
@002,004 TO 250,270

@005,006 Say "Almox.p/ saldos            (Branco-Local Padrão) Apenas p/ B1_TIPO:" FONT oFont6 PIXEL COLOR CLR_HBLUE
@005,060 Get _lAlmox SIZE 20,10 Picture "@!" Valid Len(AllTrim(_lAlmox)) <= 2
@005,210 Get _lTiposSaldo SIZE 60,10 Picture "@!" Valid Len(AllTrim(_lTiposSaldo)) <= 18

@025,006 Say "Almox.p/ Devolução           (Branco-Local Padrão) " FONT oFont6 PIXEL COLOR CLR_HBLUE
@025,060 Get _lAlmoxDEV SIZE 20,10 Picture "@!" Valid Len(AllTrim(_lAlmoxDEV)) <= 2

@045,006 Say "Almox.p/ Pedidos           (Branco-Local Padrão) " FONT oFont6 PIXEL COLOR CLR_HBLUE
@045,060 Get _lPedido SIZE 20,10 Picture "@!" Valid Len(AllTrim(_lPedido)) <= 2

@065,006 Say "Série da Nota              (Branco-Série Fornec.) / Dígitos(Zero a Esquerda):" FONT oFont6 PIXEL COLOR CLR_HBLUE  //Alterado em 16/04/2015
@065,060 Get _lSerie SIZE 20,10 Picture "@!"
@065,240 Get _lQtdeZeroEsq SIZE 05,10 Picture "@!" Valid Val(AllTrim(_lQtdeZeroEsq)) <= TamSX3("F1_SERIE")[1]  //Adicionado em 16/04/2015

@085,006 Say "Emails  " FONT oFont6 PIXEL COLOR CLR_HBLUE
@085,060 Get _lEmail SIZE 125,10 Picture "@"

@105,006 Say "Espécie NF " FONT oFont6 PIXEL COLOR CLR_HBLUE
@105,060 Get _lEspecie SIZE 125,10 Picture "@"

@125,006 Say "Decimais Quantidade " FONT oFont6 PIXEL COLOR CLR_HBLUE
@125,070 Get _lDecQtd SIZE 30,10 Picture "99"

@145,006 Say "Decimais Preço Unit." FONT oFont6 PIXEL COLOR CLR_HBLUE
@145,070 Get _lDecUni SIZE 30,10 Picture "99"

@165,006 Say "Pasta dos XMLs no rootpath " FONT oFont6 PIXEL COLOR CLR_HBLUE
@165,120 Get _lPasta SIZE 70,10 Picture "@" VALID (File(_lPasta) .or. Empty(_lPasta))

@185,006 Say "CFOPs Devolução " FONT oFont6 PIXEL COLOR CLR_HBLUE
@185,120 Get _cCFOPsDEV SIZE 70,10 Picture "@" VALID (Len(_cCFOPsDEV)>=4 .or. Empty(_cCFOPsDEV))

@205,006 Say "CFOPs Beneficiamento " FONT oFont6 PIXEL COLOR CLR_HBLUE
@205,120 Get _cCFOPsBEN SIZE 70,10 Picture "@" VALID (Len(_cCFOPsBEN)>=4 .or. Empty(_cCFOPsBEN))

@215,210 BUTTON "Gravar" SIZE 40,10 ACTION 	oAtuCfg:end()
ACTIVATE MSDIALOG oAtuCfg CENTERED

If Empty(_lDecQtd) .or. _lDecQtd==0
	_lDecQtd:=2
Endif
If Empty(_lDecUni) .or. _lDecUni==0
	_lDecUni:=7
Endif

Reclock("LS1",.F.)
LS1->ALMOX:=_lAlmox
LS1->ALMOXDEV:=_lAlmoxDEV
LS1->ALMOXTIPOS:=_lTiposSaldo
LS1->QTDEZEROSE:=_lQtdeZeroEsq //Adicionado em 16/04/2015
LS1->SERIE:=_lSerie
LS1->EMAIL:=_lEmail
LS1->PEDIDO:=_lPedido
LS1->ESPECIE:=_lEspecie
LS1->DECQTD:=_lDecQtd
LS1->DECUNI:=_lDecUni
LS1->PASTA:=_lPasta
LS1->CFOPDEV:=_cCFOPsDEV
LS1->CFOPBEN:=_cCFOPsBEN
MsUnlock()
Return



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Codigo de barra														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function CODBAR(cFile)
cCodbar:=''

If !Empty(LS1->CODBAR)
	DbSelectarea("SB1")
	DbSetorder(5)
	Dbgotop()
	Dbseek(xFilial("SB1")+LS1->CODBAR,.t.)
	If Found()
		cCodbar:=alltrim(cCodbar)+"Código de Barras " + alltrim(LS1->CODBAR) + " localizado no cadastro do Produto (SB1):"+chr(13)+chr(10)
		cCodbar:=alltrim(cCodbar)+alltrim(SB1->B1_COD)+chr(13)+chr(10)
		cCodbar:=alltrim(cCodbar)+chr(13)+chr(10)
	Else
		cCodbar:=alltrim(cCodbar)+"Código de Barras " + alltrim(LS1->CODBAR) + " NÃO localizado no cadastro do Produto (SB1):"+chr(13)+chr(10)
		cCodbar:=alltrim(cCodbar)+chr(13)+chr(10)	
	Endif

Endif

If ALLTRIM(LS1->PRODUTO)<>"999999"
	DbSelectarea("SB1")
	DbSetorder(1)
	Dbgotop()
	Dbseek(xFilial("SB1")+LS1->PRODUTO,.t.)
	If Found()
		cCodbar:=alltrim(cCodbar)+"Código de Barras na SB1:"+chr(13)+chr(10)
		cCodbar:=alltrim(cCodbar)+alltrim(SB1->B1_CODBAR)+chr(13)+chr(10)
		cCodbar:=alltrim(cCodbar)+chr(13)+chr(10)
	Endif
	
	DbSelectarea("SLK")
	DbSetorder(2)
	Dbgotop()
	Dbseek(xFilial("SLK")+LS1->PRODUTO,.t.)
	If Found()
		cCodbar:=alltrim(cCodbar)+"CADASTRO ALTERNATIVO"+chr(13)+chr(10)
		DbSelectarea("SLK")
		DbSetorder(2)
		Dbgotop()
		Dbseek(xFilial("SLK")+LS1->PRODUTO,.t.)
		While !Eof() .and. ALLTRIM(SLK->LK_CODIGO)==ALLTRIM(LS1->PRODUTO)
			cCodbar:=alltrim(cCodbar)+alltrim(SLK->LK_CODBAR)+chr(13)+chr(10)
			Dbskip()
		End
	Endif
Endif


If !Empty(cCodbar) .and. ALLTRIM(LS1->PRODFOR) <> "999999"
	Msgbox(cCodbar,"Atenção...","INFO")
ElseIf bMostMsgCodBarras .AND. ALLTRIM(LS1->PRODUTO) == "999999"
//Adicionado em 23/08/2012 para mostrar mensagem com códigos de barras duplicados
	_xnOpcAvis := Aviso("Código de Barras duplicado", " No arquivo XML " + _cPastaXML+iif(RIGHT(AllTrim(_cPastaXML),1)==_xcBarraDir,"",_xcBarraDir)+lower(cFile) +" " +;	
				"do emitente " + _xcNomEmit + " CNPJ " + _cCNPJ + " referente à: " + CHR(13)+CHR(10) + ;
				"Nota: " + cNota +CHR(13)+CHR(10) +;
				"Emissão: " + cEmissao +CHR(13)+CHR(10) +;
				"Nat. Operação: " + cNatOp +CHR(13)+CHR(10) +;
				"Chave: " + cChave +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
				"Possui um ou mais código de barras que foram encontrados em mais de um produto conforme a seguir: " + CHR(13)+CHR(10) + ;
				cMensCodBarrasD  +CHR(13)+CHR(10) +CHR(13)+CHR(10) +;
				"Verifique se realmente estes códigos de barras estão corretos juntamente aos responsáveis pelo cadastro de produto (tabelas SB1 e/ou SLK) " +;
				"Será necessário verificar manualmente a localização e/ou se necessário efetuar um novo cadastro de produto." , {"OK"} ,3)
Else
	Msgbox("Nenhum código de barras localizado!","Atenção...","INFO")
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desbloquear															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function DESBLOQ()

if !Empty(LS4->PRODUTO) .and. VerSenha(2) //-- Evento 2 - Alterar cadastro de produtos
	If UPPER(ALLTRIM(LS4->BLQ))=="ATIVO"
		Msgbox("O Produto já está ativo!","Atenção...","ALERT")
		Return
	Endif
	
	cResp:=msgbox("Deseja DESBLOQUEAR o produto novamente?","Atenção...","YESNO")
	
	If cResp
		DbSelectarea("LS4")
		Reclock("LS4",.F.)
		LS4->BLQ:="Ativo"
		MsUnlock()
		
		Dbselectarea("SB1")
		DbSetorder(1)
		Dbgotop()
		Dbseek(xFilial("SB1")+LS4->PRODUTO)
		If Found()
			Reclock("SB1",.F.)
			SB1->B1_MSBLQL:="2"
	//		IF "SAIU" $ ALLTRIM(SB1->B1_DESC)                //Comentado por Luiz em 10/04/2012 por não se aplicar a todas empresas
	//			SB1->B1_DESC:=SUBSTR(SB1->B1_DESC,6,45)
	//		Endif
			MsUnlock()
		End
		msgbox("O Produto foi reativado com sucesso!","Atenção...","INFO")
	Endif
ElseIf Empty(LS4->PRODUTO)
	Msgbox("Nenhum produto selecionado!","Atenção...","ALERT")
Else
	Msgbox("Usuário sem acesso a alteração no cadastro de produtos!","Atenção...","ALERT")
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Historico do fornecedor												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function HISTFOR()
cCadastro :='Historico Fornecedor'

aRotina2  := { {"Perdas","U_PR_PERD()",0,2},;
{"Trocas Produtos","U_PR_TRO()",0,2},;
{"Divergências Pedidos","U_PR_DIV()",0,2},;
{"Pedidos com cortes","U_PR_COR()",0,2},;
{"Pedidos Não Entregues","U_PR_NAO()",0,2},;
{"Saldos por Grupo","U_PR_SALG()",0,2}}

aRotina   := {  {"Pesquisar","AxPesqui",0,1},;
{"Comprar"      , "U_PR_COM()",0,8},;
{"Totalizar"    , "U_PR_TOT()",0,3},;
{"Gerar Pedidos" , "U_PR_PED()",0,8},;
{"F4-Histórico"    , "U_PR_HIS()",0,8},;
{"Consultas"	,aRotina2        ,0,2,0 ,NIL},;
{"Sugestão"     , "U_PR_SUG()",0,6},;
{"Preço Família", "U_PR_FAM()",0,7},;
{"Incluir Produto", "U_PR_INCP()",0,7},;
{"Fora de Linha", "U_PR_FORL()",0,7},;
{"Legenda"      , 'U_PR_LEG()', 0 , 9}}

Pergunte("FIC030",.T.)
ALTERA:=.T.
INCLUI:=.F.
NVLGERALNF:=0
LF030TITAB:=.F.
LF030TITPG:=.F.
LF030TITCOM:=.F.
LF030TITFAT:=.F.
CFILCORR:=cFilAnt //Adicionado em 03/12/2014 devido a erro na consulta após atualizações do RPO em outubro de 2014
NVLRGERNF:=0 //Adicionado em 03/12/2014 devido a erro na consulta após atualizações do RPO em outubro de 2014
NVLRGERNF5:=0 //Adicionado em 03/12/2014 devido a erro na consulta após atualizações do RPO em outubro de 2014
OGRE:=LoadBitmap( GetResources(), "BR_VERDE" )
OYEL:=LoadBitmap( GetResources(), "BR_AMARELO" )
ORED:=LoadBitmap( GetResources(), "BR_VERMELHO" )
FC030CON(LS3->FORNEC,LS3->LOJA)
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura pedido por item												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function PROCPED()
If ALLTRIM(LS1->PRODUTO)=="999999"
	Msgbox("Favor identificar o produto primeiro!","Atenção...","ALERT")
	OBRWI:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")
	Return
Endif

If !Empty(LS1->PEDIDO) .and. ALLTRIM(LS1->PEDIDO)<>"CRIAR"
	Msgbox("Favor eliminar o pedido primeiro!","Atenção...","ALERT")
	OBRWI:obrowse:refresh()
	OBRWI:obrowse:setfocus()
	ObjectMethod(oTela,"Refresh()")
	Return
Endif

aCampos2	:= {{"OK","C",1,0 },;
{"EMISSAO","D",TamSX3("C7_EMISSAO")[1],0 },;
{"PEDIDO","C",TamSX3("C7_NUM")[1],0 },;
{"ITEM","C",TamSX3("C7_ITEM")[1],0 },;
{"QUANTIDADE","N",TamSX3("C7_QUANT")[1],TamSX3("C7_QUANT")[2] },;
{"PRECO","N",TamSX3("C7_PRECO")[1],TamSX3("C7_PRECO")[2] },;
{"ENTREGA","D",TamSX3("C7_DATPRF")[1],0 }}

cArqTrab2  := CriaTrab(aCampos2)
cIndice:="Descend(DTOS(EMISSAO))"
dbUseArea( .T.,, cArqTrab2, "LS2", if(.F. .OR. .F., !.F., NIL), .F. )
IndRegua("LS2",cArqTrab2,cIndice,,,)
dbSetIndex( cArqTrab2 +OrdBagExt())
dbSelectArea("LS2")

lAchou:=.f.
_nQuantXml:=LS1->QUANTIDADE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando pedidos em aberto										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeq:=LS1->SEQ
cQuery:=" SELECT C7_EMISSAO EMISSAO,C7_PRECO PRECO,C7_ITEM ITEM,C7_NUM PEDIDO,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANTIDADE,C7_DATPRF ENTREGA FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
cQuery:=cQuery + " AND C7_LOJA='"+LS3->LOJA+"' "
cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
TCQUERY cQuery NEW ALIAS "TCQ"
DbSelectarea("TCQ")
While !Eof()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificando saldos de produtos em uso								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nUsados:=0
	DbSelectarea("LS1")
	Dbgotop()
	While !Eof()
		IF alltrim(LS1->PEDIDO)==TCQ->PEDIDO .AND. alltrim(LS1->ITEM)==TCQ->ITEM
			_nUsados:=(_nUsados+LS1->QUANTIDADE)
		Endif
		DbSelectarea("LS1")
		Dbskip()
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravando pedidos em aberto											³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (TCQ->QUANTIDADE-_nUsados)>0
		Reclock("LS2",.T.)
		IF (TCQ->QUANTIDADE-_nUsados)>=_nQuantXml
			LS2->OK:="X"
		Endif
		LS2->EMISSAO:=STOD(TCQ->EMISSAO)
		LS2->PEDIDO:=TCQ->PEDIDO
		LS2->ITEM:=TCQ->ITEM
		LS2->PRECO:=TCQ->PRECO
		LS2->QUANTIDADE:=(TCQ->QUANTIDADE-_nUsados)
		LS2->ENTREGA:=STOD(TCQ->ENTREGA)
		Msunlock()
		lAchou:=.T.
	Endif
	DbSelectarea("TCQ")
	Dbskip()
End
DbClosearea("TCQ")

DbSelectarea("LS1")
Dbgotop()
DbSeek(cSeq)

Dbselectarea("LS2")
Dbgotop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aHeader dos pedidos													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTitulo2 := {}
AADD(aTitulo2,{"EMISSAO","Emissão"})
AADD(aTitulo2,{"PEDIDO","Pedido"})
AADD(aTitulo2,{"ITEM","Item"})
AADD(aTitulo2,{"QUANTIDADE","Disponível",_xPd1quant})
AADD(aTitulo2,{"PRECO","Preço R$",_xPc7preco})
AADD(aTitulo2,{"ENTREGA","Dt.Entrega"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela dos itens														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lAchou
	@ 120,040 TO 440,550 DIALOG oPedido TITLE "Pedidos em aberto para o produto..."
	@ 005,005 say "Quantidade Necessária "+Transform(LS1->QUANTIDADE,X3Picture("C7_QUANT"))+"      Preço R$ "+Transform(LS1->PRECO,X3Picture("C7_PRECO")) FONT oFont1 OF oPedido PIXEL COLOR CLR_HRED
	@ 015,005 TO 140,255 BROWSE "LS2" ENABLE " LS2->OK<>'X' " OBJECT OBRWT FIELDS aTitulo2
	OBRWT:oBrowse:oFont := TFont():New ("Arial", 05, 18)
	OBRWT:OBROWSE:bLDblClick   := {||CONFPED()}
	@ 145,005 BUTTON "Atualizar Pedido" SIZE 65,10 ACTION ATUPED()
	@ 145,075 BUTTON "Eliminar do pedido" SIZE 65,10 ACTION ELIRPRO()
	@ 145,145 BUTTON "Vários Pedidos" SIZE 65,10 ACTION VARIOSPCS()
	ACTIVATE DIALOG oPedido CENTER
Else
	Msgbox("Não existem pedidos em aberto para este produto!","Atenção...","ALERT")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravando CRIAR nos produtos sem pedidos de compras em aberto		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SEMPED()
Endif
Dbselectarea("LS2")
dbCloseArea("LS2")
fErase( cArqTrab2+ ".DBF" )
fErase( cArqTrab2+ OrdBagExt() )

OBRWI:obrowse:refresh()
OBRWI:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vários pedidos de compra em um mesmo item da nota                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VARIOSPCS()  //Adicionado em 08/04/2015 para permitir selecionar mais de um pedido para uma mesma linha da nota (dividir item da nota)
Local cResp
Local nxQtdPC     := LS2->QUANTIDADE
Local nxQtdNF 	  := LS1->QUANTIDADE
Local nQteItens   := LS1->(LASTREC())
Local oDivideItem
Local aRegistro   := {} 
Local aAreaLS1    := LS1->(GetArea())

//parei aqui lsfm

cResp:=msgbox("Confirma replicação do item da nota para poder associar mais de um pedido de compra?","Atenção...","YESNO")

If cResp
	
	@ 0,0 TO 100,235 DIALOG oDivideItem TITLE "Informe a quantidade"
	@ 10,10 SAY "Qtde.: "  FONT oFont1 OF oDivideItem PIXEL
	@ 10,40 Get nxQtdPC Picture x3Picture("C7_QUANT") Size 50,30  Valid nxQtdPC <= nxQtdNF .and. nxQtdPC <= LS2->QUANTIDADE
	@ 30,40 BUTTON "Confirma" SIZE 35,12 ACTION Close(oDivideItem)
	ACTIVATE DIALOG oDivideItem CENTER
	
	If Empty(nxQtdPC)
		Return
	Endif      

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
    //³ Le as informacoes do registro corrente                          ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
    For nx:=1 to LS1->(FCount()) 
         AADD(aRegistro,LS1->(FieldGet(nx))) 
    Next nx                                       
     
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
    //³ Altera a quantidade da linha atual                             ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	RecLock("LS1",.F.)
	LS1->QUANTIDADE := nxQtdPC
	LS1->CAIXAS := nxQtdPC / IIF(LS1->QE<>0,LS1->QE,1)
	LS1->TOTAL := nxQtdPC * LS1->PRECO
	MsUnlock()
     
	If !l2Check2 //Se não é pedido por item
		RecLock("LS1",.F.)
		LS1->PEDIDO := LS2->PEDIDO
		MsUnlock()
	Else
		RecLock("LS1",.F.)
		LS1->PEDIDO := LS2->PEDIDO
		LS1->ITEM   := LS2->ITEM
		MsUnlock()
	Endif
	     
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 
    //³ Efetua a gravacao do novo registro                             ³ 
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IF nxQtdNF-nxQtdPC > 0 //se ainda tem quantidade não associada a pedido 
	    RecLock("LS1",.T.) 
	    For nx := 1 TO LS1->(FCount())
	    	 If nx == FieldPos("SEQ")
	    	 	LS1->(FieldPut(nx,nQteItens+1))
	         ElseIf nx == FieldPos("QUANTIDADE") 
	            LS1->(FieldPut(nx,nxQtdNF-nxQtdPC))
	         ElseIf nx == FieldPos("CAIXAS") 
	            LS1->(FieldPut(nx,nxQtdNF-nxQtdPC)/IIF(LS1->QE<>0,LS1->QE,1))
	         ElseIf nx == FieldPos("TOTAL") 
	            LS1->(FieldPut(nx,(nxQtdNF-nxQtdPC)*LS1->PRECO))
	         ElseIF nx == FieldPos("PEDIDO")
	         	LS1->(FieldPut(nx,Space(Len(LS1->PEDIDO))))
	         ElseIF nx == FieldPos("ITEM")
	         	LS1->(FieldPut(nx,Space(Len(LS1->ITEM))))
	         Else 
	            LS1->(FieldPut(nx,aRegistro[nx])) 
	         Endif 
	    Next nx 
	    MsUnlock()
	EndIf
	PROCESS()    
Endif
oPedido:end()
LS1->(RestArea(aAreaLS1))
Return




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Confirma Pedido 													³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function CONFPED()
teste:= ""
If (LS1->QUANTIDADE>LS2->QUANTIDADE)
	If MsgYesNo("Não existe saldo suficiente para atender este produto! Deseja informar vários pedidos?","Atenção...")
		VARIOSPCS()
		oPedido:end()
		Return
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravando CRIAR nos produtos sem pedidos de compras em aberto		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SEMPED()
		oPedido:end()
		Return
	EndIf
Endif

Reclock("LS1",.F.)
LS1->PEDIDO:=LS2->PEDIDO
LS1->ITEM:=LS2->ITEM
LS1->ALTERADO:="S"
MsUnlock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravando o mesmo pedido para os outros itens						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeqori:=LS1->SEQ

DbSelectarea("LS1")
Dbgotop()
While !Eof()
	cSeq:=LS1->SEQ
	IF Empty(LS1->PEDIDO)
		cQuery:=" SELECT C7_ITEM ITEM,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		cQuery:=cQuery + " AND C7_NUM='"+LS2->PEDIDO+"' "
		cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
		cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
		cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
		cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
		cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectarea("TCQ")
		While !Eof()
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificando saldos de produtos em uso								³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_nUsados:=0
			DbSelectarea("LS1")
			Dbgotop()
			While !Eof()
				IF alltrim(LS1->PEDIDO)==ALLTRIM(LS2->PEDIDO) .AND. alltrim(LS1->ITEM)==TCQ->ITEM
					_nUsados:=(_nUsados+LS1->QUANTIDADE)
				Endif
				DbSelectarea("LS1")
				Dbskip()
			End
			
			DbSelectarea("LS1")
			Dbgotop()
			DbSeek(cSeq)
			
			IF (LS1->QUANTIDADE<=(TCQ->QUANT-_nUsados))
				Reclock("LS1",.F.)
				LS1->PEDIDO:=LS2->PEDIDO
				LS1->ITEM:=TCQ->ITEM
				LS1->ALTERADO:="S"
				MsUnlock()
			Endif
			DbSelectarea("TCQ")
			Dbskip()
		End
		DbClosearea("TCQ")
	Endif
	DbSelectarea("LS1")
	Dbskip()
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravando CRIAR nos produtos sem pedidos de compras em aberto		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectarea("LS1")
Dbgotop()
DbSeek(cSeqOri)
SEMPED()
oPedido:end()
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Eliminar pedido														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ELIMPED()
Reclock("LS1",.F.)
LS1->PEDIDO:=""
LS1->ITEM:=""
LS1->ALTERADO:=""
MsUnlock()

OBRWI:obrowse:refresh()
OBRWI:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Eliminar Todos														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ELIMPEDT()
cResp:=Msgbox("Deseja limpar todas as referências de pedidos dos produtos da nota fiscal?","Atenção...","YESNO")

If cResp
	DbSelectarea("LS1")
	Dbgotop()
	While !Eof()
		IF !Empty(LS1->PEDIDO)
			Reclock("LS1",.F.)
			LS1->PEDIDO:=""
			LS1->ITEM:=""
			LS1->ALTERADO:=""
			MsUnlock()
		Endif
		Dbskip()
	End
	DbSelectarea("LS1")
	Dbgotop()
Endif

OBRWI:obrowse:refresh()
OBRWI:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Eliminar pedido														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ELIRPRO()

If VerSenha(6) //Somente se o usuário tiver acesso a alteração de pedido de compras
	cResp:=msgbox("Deseja eliminar o resíduo deste item do pedido "+LS2->PEDIDO+"?","Atenção...","YESNO")
	
	If cResp
		DbSelectarea("SC7")
		DbSetorder(1)
		dbgotop()
		Dbseek(xFilial("SC7")+LS2->PEDIDO)
		While !Eof() .and. ALLTRIM(SC7->C7_NUM)==ALLTRIM(LS2->PEDIDO)
			IF alltrim(SC7->C7_PRODUTO)==alltrim(LS1->PRODUTO) .AND. LS2->ITEM==SC7->C7_ITEM
				IF SC7->C7_QTDACLA>0
					Msgbox("Este produto está sendo usado em pré nota fiscal!","Atenção...","ALERT")
					Return
				Endif
				
				IF SC7->C7_RESIDUO<>"S" .and. (SC7->C7_QUANT-SC7->C7_QUJE)>0
					Reclock("SC7",.F.)
					SC7->C7_RESIDUO:="S"
					MsUnlock()
					
					DbSelectarea("SB2")
					DbSetorder(2)
					Dbgotop()
					Dbseek(xFilial("SB2")+SC7->C7_LOCAL+SC7->C7_PRODUTO)
					If Found()
						Reclock("SB2",.F.)
						SB2->B2_SALPEDI:=(SB2->B2_SALPEDI-(SC7->C7_QUANT-SC7->C7_QUJE))
						MsUnlock()
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Apagando pedido do browse											³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectarea("LS2")
					Reclock("LS2",.F.)
					dbdelete()
					MsUnlock()
					dbgotop()
					Msgbox("Resíduo eliminado com sucesso!","Atenção...","INFO")
				Endif
			Endif
			DbSelectarea("SC7")
			Dbskip()
		End
	Endif
ElseIf !VerSenha(6) //-- Evento 6 - Alteração de pedido de compras
		Msgbox("Não é possível eliminar resíduo do pedido de compras, pois o usuário sem permissão para alterar pedido de compras!","Atenção...","STOP")
Endif
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Alterar Pedido												 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function ATUPED()

If VerSenha(6) //-- Evento 6 - Alteração de pedido de compras
	
	IF LS1->QUANTIDADE<=LS2->QUANTIDADE
		Msgbox("Não é necessário atualizar este pedido!","Atenção...","ALERT")
		Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajustando o pedido com a nota										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cResp:=msgbox("Deseja atualizar o pedido "+LS2->PEDIDO+" com a quantidade que falta?","Atenção...","YESNO")
	
	If cResp
		lEntrou:=.F.
		_nQtdIt:=0
		
		DbSelectarea("SC7")
		DbSetorder(4)
		Dbgotop()
		Dbseek(xFilial("SC7")+LS1->PRODUTO+LS2->PEDIDO+LS2->ITEM)
		If Found() .AND. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)<LS1->QUANTIDADE
			_nTotal:=LS1->QUANTIDADE-(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)
			
			Reclock("SC7",.F.)
			SC7->C7_QUANT:=(SC7->C7_QUANT+_nTotal)
			SC7->C7_OBS:=SUBSTR(AllTrim(SC7->C7_OBS) + "(ALT. NF-E XML)",1,50)
			MsUnlock()
			
			Reclock("SC7",.F.)
			SC7->C7_TOTAL:=(SC7->C7_QUANT*SC7->C7_PRECO)
			MsUnlock()
			
			If Empty(cAlmox)
				cAlmox:=Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
			Else
				If !Empty(cTiposSaldo) // Se foi informado o armazém, verifica se existe filtro de tipo
					 if !(Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_TIPO") $ cTiposSaldo) // Alterado em 08/09/2014 Somente pega o B1_LOCPAD se não
					 	  cAlmox:=Posicione("SB1",1,xFilial("SB1")+LS1->PRODUTO,"B1_LOCPAD")
					 Endif
				Endif
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizado SB2 saldo de pedidos										³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectarea("SB2")
			DbSetorder(2)
			Dbgotop()
			Dbseek(xFilial("SB2")+cAlmox+LS1->PRODUTO)
			If Found()
				Reclock("SB2",.F.)
				SB2->B2_SALPEDI:=(SB2->B2_SALPEDI+_nTotal)
				MsUnlock()
			Endif
			lEntrou:=.T.
		Endif
		
		If lEntrou
			Msgbox("Pedido atualizado com sucesso!","Atenção...","INFO")
			Reclock("LS2",.F.)
			LS2->QUANTIDADE:=LS1->QUANTIDADE
			LS2->OK:="X"
			Msunlock()
		Endif
	Endif
	DbSelectarea("LS2")
ElseIf !VerSenha(6) //-- Evento 6 - Alteração de pedido de compras
		Msgbox("Usuário sem permissão para alterar pedido de compras!","Atenção...","STOP")
Endif	
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verificando produto sem pedido de compras da nota			 |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function SEMPED()
cSeqori:=LS1->SEQ

DbSelectarea("LS1")
Dbgotop()
While !Eof()
	cSeq:=LS1->SEQ
	
	IF Empty(LS1->PEDIDO) .AND. ALLTRIM(LS1->PRODUTO)<>"999999"
		lEntrou:=.F.
		cQuery:=" SELECT C7_NUM PEDIDO,C7_ITEM ITEM,(C7_QUANT-C7_QUJE-C7_QTDACLA) QUANT FROM "+RetSqlName('SC7')+" WHERE C7_FILIAL='"+xFilial("SC7")+"' "
		cQuery:=cQuery + " AND C7_FORNECE='"+LS3->FORNEC+"' "
		cQuery:=cQuery + " AND C7_LOJA='"+LS3->LOJA+"' "
		cQuery:=cQuery + " AND C7_PRODUTO='"+LS1->PRODUTO+"' "
		cQuery:=cQuery + " AND (C7_QUANT-C7_QUJE-C7_QTDACLA>0) "
		cQuery:=cQuery + " AND D_E_L_E_T_=' ' "
		cQuery:=cQuery + " AND C7_RESIDUO<>'S' "
		cQuery:=cQuery + " ORDER BY C7_EMISSAO DESC "
		TCQUERY cQuery NEW ALIAS "TCQ"
		DbSelectarea("TCQ")
		While !Eof() .and. lEntrou==.F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verificando saldos de produtos em uso								³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_nUsados:=0
			DbSelectarea("LS1")
			Dbgotop()
			While !Eof()
				IF alltrim(LS1->PEDIDO)==ALLTRIM(TCQ->PEDIDO) .AND. alltrim(LS1->ITEM)==TCQ->ITEM
					_nUsados:=(_nUsados+LS1->QUANTIDADE)
				Endif
				DbSelectarea("LS1")
				Dbskip()
			End
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o saldo do pedido atende ao produto da nota fiscal				³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectarea("LS1")
			Dbgotop()
			DbSeek(cSeq)
			
			IF (LS1->QUANTIDADE<=(TCQ->QUANT-_nUsados)) .OR. (TCQ->QUANT-_nUsados)>0
				lEntrou:=.T.
			Endif
			DbSelectarea("TCQ")
			Dbskip()
		End
		DbClosearea("TCQ")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se nao encontrou nenhum pedido de compra com saldo suficiente		³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lEntrou==.F.
			Reclock("LS1",.F.)
			LS1->PEDIDO:="CRIAR"
			LS1->ALTERADO:="S"
			MsUnlock()
		Endif
	Endif
	DbSelectarea("LS1")
	Dbskip()
End
DbSelectarea("LS1")
Dbgotop()
DbSeek(cSeqori)
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refaz desconto														³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function REFDESC()
DbSelectarea("LS1")
Dbgotop()
While !Eof()
	If LS1->DESCONTO>0
		If lRefaz
			Reclock("LS1",.F.)
			LS1->PRECO:=IIF(LS1->QUANTIDADE <> 0 ,(LS1->TOTALNF-LS1->DESCONTO)/LS1->QUANTIDADE, (LS1->TOTALNF-LS1->DESCONTO))
			LS1->TOTAL:=(LS1->TOTALNF-LS1->DESCONTO)
			MsUnlock()
		Else
			Reclock("LS1",.F.)
			LS1->PRECO:=IIF(LS1->QUANTIDADE <> 0 ,LS1->TOTALNF/LS1->QUANTIDADE, LS1->TOTALNF)
			LS1->TOTAL:=LS1->TOTALNF
			MsUnlock()
		Endif
	Endif
	Dbskip()
End

If lRefaz
	lRefaz:=.F.
	Msgbox("O Total do produto está com o desconto!","Atenção...","INFO")
Else
	lRefaz:=.T.
	Msgbox("O Total do produto está sem o desconto!","Atenção...","ALERT")
Endif
DbSelectarea("LS1")
Dbgotop()
OBRWI:obrowse:refresh()
OBRWI:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validas perguntas usadas no filtro dos registros					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function VALIDPERG(cPerg)
aRegs := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,7)+"   "

aAdd(aRegs,{cPerg,"01","Fornecedor ?","","","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SA2",""})
aAdd(aRegs,{cPerg,"02","Loja ?","","","mv_ch2","C",2,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Emissao de ??","","","mv_ch3","D",8,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Emissao Ate?","","","mv_ch4","D",8,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","N.Fiscal de?","","","mv_ch5","C",9,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","N.Fiscal Ate?","","","mv_ch6","C",9,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
Return
      
// função adicionada por Luiz em 13/06/2011     // Devido a alterações na função padrão MACOMVIEW() feita pela Totvs em abril de 2011 onde passou a dar erro de variável AROTINA não declarada
Static Function xHistProdPol()
Private AROTINA := {{"Pesquisar","AxPesqui",0,1}}

MACOMVIEW(LS1->PRODUTO)

Return



Static Function xDadosUsuario(xl,xc)
Local axArray := {}, cxRetorno := ""

PswOrder(1)
PswSeek(__cUserId,.T.)
axArray := PswRet(1)   // 1 ==> Retorna vetor com informações do usuário
If Len(axArray[xl][xc]) > 0
	cxRetorno := axArray[xl][xc] 
EndIf
Return(cxRetorno)


Static Function xBuscaPasta(cnomepasta)
Local nSeq := 1
Local bLoop := .t.

While bLoop
	cnomepasta := Alltrim(cnomepasta) + AllTrim(str(nSeq))
	IF !File(cnomepasta)
		bLoop := .f.
	EndIf
	nSeq++
End
Return(cnomepasta)



Static Function MakePath(cFullPath)
Local nPathNAt := At(':',cFullPath)
Local cPathFil := Left( cFullPath, nPathNAt )
Local aTmpPath := StrToKArr( Right(cFullPath, Len(cFullPath) - nPathNAt ) ,'\')
Local nFolders := Len(aTmpPath)
Local nY := 0
 
For nY := 1 To nFolders
 cPathFil += '/' + aTmpPath[nY]
 Iif( !ExistDir(cPathFil), MakeDir(cPathFil), Nil )
Next
 
Return( ExistDir(cFullPath) )


Static function xEnCode (cTexto, cSenha, lEncDec)
//lEncDec ==> .t. encriptar / .f. ==> desencriptar
Local cRetorno := ""
Local nx := 1
Local nContaTexto := 1
Local nContaSenha := 1
Local anCaracTexto := {}
Local anCaracSenha := {}
            
For nx := 1 to len(AllTrim(cTexto))

	aadd(anCaracTexto,ASC(substr(AllTrim(cTexto),nContaTexto,1)))
	aadd(anCaracSenha,ASC(substr(AllTrim(cSenha),nContaSenha,1)))
  
	cRetorno := cRetorno + CHR(anCaracTexto[nx]+iif(lEncDec==.t.,anCaracSenha[nx],-anCaracSenha[nx]))
	
	If nContaSenha >= len(AllTrim(cSenha)) // Rotacionar a senha
		nContaSenha := 0
	EndIf
        
	nContaTexto++
	nContaSenha++
Next 

Return(cRetorno)


Static Function xValidaNFE(cCHVNFE)
Local cIdEnt
Local retDaFuncStatic
/*
função StaticCall().
Que pode ser usada da seguinte forma.
retDaFuncStatic := StaticCall( xParam1, xParam2, xParam3, ..., ..., xParamN)
xParam1 := NomeDoPrograma (sem aspas), onde se encontra a Static Function
xParam2 := NomeDaStaticFunction (sem aspas), a ser executada
xParam3 := A partir desse espaço são definidos os parametros que são passados
para a Static Function que esta sendo invocada.
*/
//ConsNFeChave(cChaveNFe,cIdEnt)

cIdEnt := StaticCall(SPEDNFE,GetIdEnt)
retDaFuncStatic := StaticCall(SPEDNFE,ConsNFeChave,cCHVNFE,cIdEnt)
Return()


/*/
Funcao: UnMaskCNPJ
Autor: Marinaldo de Jesus
Data: 16/07/2010

Descrição: Retirar a Máscara do CNPJ
/*/
Static Function UnMaskCNPJ( cCNPJ )
 Local cCNPJClear := CNPJ
 BEGIN SEQUENCE
  IF Empty( cCNPJClear )
   return
  EndIF
  
  cCNPJClear := StrTran( cCNPJClear , "." , "" )
  cCNPJClear := StrTran( cCNPJClear , "/" , "" )
  cCNPJClear := StrTran( cCNPJClear , "-" , "" )
  cCNPJClear := AllTrim( cCNPJClear )
 
 END SEQUENCE

Return( cCNPJClear )

Static Function xLerKey()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lendo o arquivo de chave										    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Adicionado em 13/04/2012 para armazenar pasta/arquivo padrao
cBuffer   := ""

If File(_xPstSalv+_xcBarraDir+"config"+_xcBarraDir+"leiame_impxml.txt")
	FT_FUSE(_xPstSalv+_xcBarraDir+"config"+_xcBarraDir+"leiame_impxml.txt")
	FT_FGOTOP()
	ProcRegua(FT_FLASTREC())
	
	While !FT_FEOF()
		cBuffer := FT_FREADLN()
		If substr(lower(ALLTRIM(cBuffer)),1,3) == "key"
			xTextoCompleto := xEnCode(substr(cBuffer,5,len(cBuffer)-4),"1mp0rt@rXMLprenota",.f.) // retirado 4 caracteres relativos a chave KEY=
			xcCNPJ:=substr(xTextoCompleto,1,8)
			xcData:=substr(xTextoCompleto,9,8)
			xKeyChave:=xcCNPJ
		EndIf
		If substr(lower(ALLTRIM(cBuffer)),1,_xTCodEmp+_xTCodFil+5) == "pasta"+SM0->M0_CODIGO+SM0->M0_CODFIL
			_cPastaXML := AllTrim(SUBSTR(ALLTRIM(cBuffer),_xTCodEmp+_xTCodFil+7,60))
		EndIf

		FT_FSKIP()
	EndDo
	FT_FUSE()
Endif

FClose(_xPstSalv+_xcBarraDir+"config"+_xcBarraDir+"leiame_impxml.txt")

Return


Static function xMudaTipoNF(cxDadosFornec,cxInfCompl,cxTipoNFOrig)
//Adicionado por Luiz em 27/08/2014 para permitir trocar o tipo de nota identificado automaticamente com base no CFOP
Local oFont1 := TFont():New("MS Sans Serif",,016,,.T.,,,,,.F.,.F.)
Local oFont2 := TFont():New("MS Sans Serif",,022,,.T.,,,,,.F.,.F.)
Local oRadMenu1
Local nRadMenu1 := 1
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSButton1
Local oSButton2
Local nxopcao
Local axret := {}
Local _lFechaMain := .f.  // Equanto estiver .F. desabilitar o x para evitar fechar caixa de diálogo sem ser pelos botões ou teclando ESC			      	    

Static oDlg

AADD(axret,"N")	//N = NF Normal
AADD(axret,"D")	//D = Devolução	
AADD(axret,"I")	//NF Compl. ICMS
AADD(axret,"P")	//NF Compl. IPI
AADD(axret,"B")	//NF Beneficiamento
AADD(axret,"C")	//Compl. Preço


nRadMenu1 := aScan(axret,cxTipoNFOrig)


  DEFINE MSDIALOG oDlg TITLE "Seleção do tipo de nota" FROM 000, 000  TO 350, 650 COLORS 0, 16777215 PIXEL

    @ 004, 003 SAY oSay1 PROMPT "Escolha o tipo de nota a importar para este arquivo XML:" SIZE 266, 017 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
    @ 024, 001 MSPANEL oPanel1 PROMPT "" SIZE 206, 076 OF oDlg COLORS 0, 16777215 RAISED
    @ 005, 002 SAY oSay4 PROMPT cxDadosFornec SIZE 199, 071 OF oPanel1 COLORS 0, 16777215 PIXEL
    @ 048, 212 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "N = NF Normal          ","D = Devolução","I = NF Compl. ICMS","P = NF Compl. IPI","B = NF Beneficiamento","C = Compl. Preço" SIZE 067, 052 OF oDlg COLOR 0, 16777215 PIXEL
    @ 105, 005 SAY oSay3 PROMPT "Informações adicionais (para o fisco e complementares) no XML:" SIZE 203, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 118, 001 MSPANEL oPanel2 PROMPT "" SIZE 320, 054 OF oDlg COLORS 0, 16777215 RAISED
    @ 005, 002 SAY oSay2 PROMPT cxInfCompl SIZE 315, 045 OF oPanel2 COLORS 0, 16777215 PIXEL
    DEFINE SBUTTON oSButton1 FROM 062, 288 TYPE 01 OF oDlg ENABLE ACTION {||nxopcao:=1,_lFechaMain:=.t.,oDlg:End()}
    DEFINE SBUTTON oSButton2 FROM 080, 288 TYPE 02 OF oDlg ENABLE ACTION {||nxopcao:=2,oDlg:End()}
    
  ACTIVATE MSDIALOG oDlg CENTERED

if nxopcao == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Como foi alterado o tipo identificado pela leitura do XML com base  ³
	//³ nos CFOPs, precisa trocar o código/loja/nome, etc. pois pode ter    ³
	//³ considerado da SA2 se identificado como tipo N e se se o usuário    ³
	//³ mudar para D precisa pegar da SA1  									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectarea(iif(axret[nRadMenu1] $ "B/D","SA1","SA2")) //Alterado em 06/08/2014 por Luiz para tratar Devolução e Beneficiamento -> estava fixo SA2
		DbSetorder(3)
		Dbgotop()
		Dbseek(xFilial(iif(axret[nRadMenu1] $ "B/D","SA1","SA2"))+_cCNPJ)
		If Found()
			RecLock("LS3",.F.)
			LS3->TIPO:=axret[nRadMenu1]
			LS3->FORNEC:=iif(axret[nRadMenu1] $ "B/D",SA1->A1_COD,SA2->A2_COD)
			LS3->LOJA:=iif(axret[nRadMenu1] $ "B/D",SA1->A1_LOJA,SA2->A2_LOJA)
			LS3->VENDEDOR:=SUBSTR(iif(axret[nRadMenu1] $ "B/D",SA1->A1_CONTATO,SA2->A2_REPRES),1,30)
			LS3->TELEFONE:=alltrim(iif(axret[nRadMenu1] $ "B/D",SA1->A1_DDD,SA2->A2_DDD))+" "+alltrim(SUBSTR(iif(axret[nRadMenu1] $ "B/D",SA1->A1_TEL,SA2->A2_TEL),1,20))
			LS3->NOME:=iif(axret[nRadMenu1] $ "B/D",SA1->A1_NREDUZ,SA2->A2_NREDUZ)
			MsUnLock()
		Else
			Msgbox("Não foi possível alterar o tipo desta nota, pois este CNPJ " + _cCNPJ + " não está cadastrado na tabela " +;
			iif(axret[nRadMenu1] $ "B/D","SA1 (cadastro de clientes)","SA2 (cadastro de fornecedores)") + " o que é necessário " +;
			"para importar uma nota tipo " + axret[nRadMenu1] + ". Será primeiro necessário fazer o cadastro antes de importar " +;
	       "este XML.","CNPJ não encontrado após alteração do tipo da Nfe","STOP")
		Endif	
Endif

OBRWI:obrowse:refresh()
OBRWP:obrowse:refresh()
OBRWI:obrowse:setfocus()
OBRWP:obrowse:setfocus()
ObjectMethod(oTela,"Refresh()")

Return


Static Function xChecaCNPJsm0(cxcnpjemitente, cxcnpjdestinatario)
Local axret := {}
Local ix := 1
Local lxEmitsm0 := .f.
Local lxDestsm0 := .f.
/*
FWLoadSM0() --> RETORNA DADOS DO SIGAMAT
len(aFils)
14
aFils[1][18]
"00000000000000" --> CNPJ
aFils[1][1]
"02" --CÓDIGO DA EMPRESA
aFils[1][2]
"01" --> CODIGO DA FILIAL
aFils[1][6]
"NOME DA EMPRESA                                "
aFils[1][7]
"NOME DA FILIAL                                  "

_cCNPJ (emitente) = prefixo _cCNPJ2 (destinatário)
*/
aFils := FWLoadSM0()

For ix := 1 to len(aFils)
	If aFils[ix][18] == cxcnpjemitente .and. !(aFils[ix][1] + aFils[ix][2] $ GetMV("MV_CONSOLD"))
		 lxEmitsm0 := .t.
	Endif
	If aFils[ix][18] == cxcnpjdestinatario .and. !(aFils[ix][1] + aFils[ix][2] $ GetMV("MV_CONSOLD"))
		 lxDestsm0 := .t.
	Endif
Next

Aadd(axret,lxEmitsm0)
Aadd(axret,lxDestsm0)

Return(axret)



//------------------------------------------------
Static Function xChecaInd()
//------------------------------------------------
Local lIndSA7 := .F.
Local aAreaAtu := GetArea()

//Verifica existencia do indice 3 do SA7 - A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI, R_E_C_N_O_, D_E_L_E_T_
dbSelectArea("SIX")
If MSSeek("SA7"+"3") 
	If "A7_CODCLI" $ CHAVE
		lIndSA7 :=	.T.
	EndIf
Endif

RestArea(aAreaAtu)

Return(lIndSA7)
