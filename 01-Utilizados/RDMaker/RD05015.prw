#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'
#include 'rwmake.ch'

/*/
===============================================================================================================================
Programa----------: RD05015
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 09/07/2026
===============================================================================================================================
Descrição---------: Este programa serve para gerar uma pre nota do tipo beneficiamento
===============================================================================================================================
Uso---------------: ESTOQUE
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: FATURAMENTO
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
user function RD05015()

	local	aCabec		as array,;
			aItens		as array,;
			aLinha		as array,;
			nOpcao		as numeric,;
			cTes		as char,;
			cAlias		as char

	local	cPerg		as char,;
			cCodForne	as char,;
			cLoja		as char,;
			nGeraPre	as numeric,;
			cNumDoc		as char,;
			cSerie		as char


	private	lMsErroAuto	as logical

	//iniciando as variaveis locais
	aCabec		:= {}
	aItens		:= {}
	aLinha		:= {}
	cAlias		:= 'TMP'

	cCodForne	:= ''
	cLoja		:= ''
	nGeraPre	:= 0
	cNumDoc		:= ''
	cSerie		:= getmv('MV_XSERTER')
	mv_par05	:= cSerie	//pre preenchendo o parametro serie com o parametro que define a serie usado neste contexto
	cNumDoc		:= ''

	nOpcao		:= 0	//opcao de operacao
	cPerg		:= 'RD05015'
	cTes		:= getmv('MV_XTESTER')

	lMsErroAuto	:= .F.

	// Selecionando o cliente que ira gerar a pre-nota do controle terceiro
	CriaPerg(cPerg)

	if Pergunte(cPerg,.T.)
		cCodForne	:= mv_par01
		cLoja		:= mv_par02
		nGeraPre	:= mv_par03
		cNumDoc		:= mv_par04
		cSerie		:= mv_par05

		if nGeraPre = 1	//Sim para gerar a pre nota
			nOpcao:= 3	//3 = inclusao
			//1. Motagem do Cabecalho
			aadd(aCabec, {'F1_TIPO'		, 'B'		, nil})
			aadd(aCabec, {'F1_FORMUL'	, 'S'		, nil})
			//aadd(aCabec, {'F1_DOC'		, (cAlias)->DOC		, nil})
			aadd(aCabec, {'F1_SERIE'	, cSerie	, nil})
			aadd(aCabec, {'F1_EMISSAO'	, ddatabase	, nil})
			aadd(aCabec, {'F1_FORNECE'	, cCodForne	, nil})
			aadd(aCabec, {'F1_LOJA'		, cLoja		, nil})
			aadd(aCabec, {'F1_ESPECIE'	, 'NFE'		, nil})
			//aadd(aCabec, {'F1_COND'		, (cAlias)->CONDPGTO, nil})
			aadd(aCabec, {'F1_STATUS'	, ''		, nil})

			//2. Busca os produtos que estão pendentes na SB6 para o terceiro
			U_PesqProc(@cAlias, 'PR_RD05015', '@FORNEC = "'+cCodForne+'", @LOJA = "'+cLoja+'"')

			while !(cAlias)->(eof())
				aLinha:= {}
				//aadd(aLinha, {'D1_ITEM'	, (cAlias)->ITEM					, nil})
				aadd(aLinha, {'D1_COD'	, (cAlias)->B6_PRODUTO					, nil})
				aadd(aLinha, {'D1_QUANT', (cAlias)->B6_SALDO					, nil})
				aadd(aLinha, {'D1_VUNIT', (cAlias)->B6_CUSTO					, nil})
				aadd(aLinha, {'D1_TOTAL', (cAlias)->B6_SALDO*(cAlias)->B6_CUSTO	, nil})
				//aadd(aLinha, {'D1_TES'	, cTes									, nil})

				aadd(aItens, aLinha)

				(cAlias)->(dbSkip())
			enddo
			(cAlias)->(dbCloseArea())

			//3. Executar o EXECAUTO
			if len(aItens) > 0
				msExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, nOpcao)

				if lMsErroAuto
					//Se der erro, grava o log ou mostra na tela
					MostraErro()
					rollbackSX8()	//cancela a sequencia travada se houver
					u_msgErro('Erro ao gerar a Pré-Nota Retorno de Remessa Terceiro','[RD05015] - GERAR PRE-NOTA RETORNO DE REMESSA A TERCEIRO')
				else
					cNumDoc:= SF1->F1_DOC
					u_RL05018(cNumDoc,cSerie)
				endif

			endif

		elseif	nGeraPre = 2 // para nao gerar a pre nota
			u_RL05018(cNumDoc,cSerie)

		elseif	nGeraPre = 3 // para excluir a pre nota
			nOpcao:= 5	//5 = exclusao
			aCabec:= {}
			aItens:= {}

			//1. Busca os produtos e pre-nota de acordo com os parametros informados
			U_PesqProc(@cAlias, 'PR_RD05015E', '@numnota = "'+cNumDoc+'", @serie = "'+@cSerie+'", @fornec = "'+cCodForne+'", @loja = "'+cLoja+'"')

			//3. Motagem do Cabecalho e seus itens
			aadd(aCabec, {'F1_TIPO'		, (cAlias)->TIPO	, nil})
			aadd(aCabec, {'F1_FORMUL'	, (cAlias)->FORMUL	, nil})
			aadd(aCabec, {'F1_DOC'		, (cAlias)->DOC		, nil})
			aadd(aCabec, {'F1_SERIE'	, (cAlias)->SERIE	, nil})
			aadd(aCabec, {'F1_EMISSAO'	, (cAlias)->EMISSAO	, nil})
			aadd(aCabec, {'F1_FORNECE'	, (cAlias)->FORNEC	, nil})
			aadd(aCabec, {'F1_LOJA'		, (cAlias)->LOJA	, nil})
			aadd(aCabec, {'F1_ESPECIE'	, (cAlias)->ESPECIE	, nil})
			aadd(aCabec, {'F1_COND'		, (cAlias)->CONDPGTO, nil})
			aadd(aCabec, {'F1_STATUS'	, (cAlias)->STATUS	, nil})


			while !(cAlias)->(eof())
				aLinha:= {}
				aadd(aLinha, {'D1_ITEM'	, (cAlias)->ITEM	, nil})
				aadd(aLinha, {'D1_COD'	, (cAlias)->PRODUTO	, nil})
				aadd(aLinha, {'D1_QUANT', (cAlias)->QUANT	, nil})
				aadd(aLinha, {'D1_VUNIT', (cAlias)->VUNIT	, nil})
				aadd(aLinha, {'D1_TOTAL', (cAlias)->TOTAL	, nil})
				//aadd(aLinha, {'D1_TES'	, (cAlias)->TES		, nil})

				aadd(aItens, aLinha)

				(cAlias)->(dbSkip())
			enddo
			(cAlias)->(dbCloseArea())

			//3. Executar o EXECAUTO
			if len(aItens) > 0
				msExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, nOpcao)

				if lMsErroAuto
					//Se der erro, grava o log ou mostra na tela
					MostraErro()
					rollbackSX8()	//cancela a sequencia travada se houver
					u_msgErro('Erro ao excluir a Pré-Nota Retorno de Remessa Terceiro','[RD05015] - EXCLUIR PRE-NOTA RETORNO DE REMESSA A TERCEIRO')
				else
					u_msgInforma('Exclusão realizado com sucesso!','[RD05015] - EXCLUIR PRE-NOTA RETORNO DE REMESSA A TERCEIRO')
				endif

			endif

		endif

	endif

return

static function CriaPerg(cPerg)

	// 1. FORNECEDOR (CLIENTE SA1)
	u_xPutSx1(  cPerg, '01', ;
				'Fornecedor:', 'Fornecedor:', 'Fornecedor:', ;
				'mv_ch1', 'C', 6, 0, 0, ;
				'G', '', 'SA1', ; // Usa consulta F3 da SA1
				'', '', 'mv_par01', ;
				'', '', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', '')

	// 2. LOJA
	u_xPutSx1(  cPerg, '02', ;
				'Loja:', 'Loja:', 'Loja:', ;
				'mv_ch2', 'C', 2, 0, 0, ;
				'G', '', '', ;
				'', '', 'mv_par02', ;
				'', '', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', '')

	// 3. DESEJA CRIA UMA NOVA PRE-NOTA (COMBOBOX SIM / NÃO)
	u_xPutSx1(  cPerg, '03', ;
				'Deseja nova Pré-Nota?', '¿Nueva Pre-Nota?', 'New Pre-Note?', ;
				'mv_ch3', 'N', 1, 0, 1, ; // Tipo N (Numérico) para Combobox
				'C', '', '', ;            // 'C' indica tipo Combo/Escolha
				'', '', 'mv_par03', ;
				'Sim', '', '', ;          // cDef01 = Primeira opção do Combo
				'Não', '', '', ;          // cDef02 = Segunda opção do Combo
				'Excluir', '', '', ;	  // cDef03 = Terceira opcao do Combo
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', '')

	// 4. NUMERO DA PRE-NOTA
	u_xPutSx1(  cPerg, '04', ;
				'Número Pré-Nota:', 'Número Pre-Nota:', 'Pre-Note Number:', ;
				'mv_ch4', 'C', 9, 0, 0, ;
				'G', '', '', ;
				'', '', 'mv_par04', ;
				'', '', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', '')

	// 5. SERIE DA PRE-NOTA
	u_xPutSx1(  cPerg, '05', ;
				'Série Pré-Nota:', 'Serie Pre-Nota:', 'Pre-Note Series:', ;
				'mv_ch5', 'C', 3, 0, 0, ;
				'G', '', '', ;
				'', '', 'mv_par05', ;
				'', '', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', ;
				'', '', '', '')
return
