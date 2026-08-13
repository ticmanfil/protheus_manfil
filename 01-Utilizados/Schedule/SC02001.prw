#include 'protheus.ch'
#include 'tbiconn.ch'
#include 'rwmake.CH'
#include 'topconn.ch'
#include 'ap5mail.ch'
#include 'report.ch'
/*/
===============================================================================================================================
Programa----------: SC02001
Autor-------------: RENATO FUZESSY TEIXEIRA FILHO
Data da Criacao---: 13/08/2026
===============================================================================================================================
Descrição---------: Este programa serve para sincronizar a tabela CKOCOL da base TOTVSGER para a TOTVSFIS
===============================================================================================================================
Uso---------------: SCHEDULE
===============================================================================================================================
Parametros--------: cEmpProc (Caracter) - Empresa para inicialização do ambiente (Padrão: '01')
                    cFilProc (Caracter) - Filial para inicialização do ambiente (Padrão: '0101')
===============================================================================================================================
Retorno-----------: lRet (Lógico) - Retorna .T. em caso de sucesso na execução da query
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: 02 - FISCAL / COMPRAS
=====================================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
=====================================================================================================================================
	Autor		|	Data	|										Motivo																
----------------:-----------:-------------------------------------------------------------------------------------------------------:
				|			|																											
=====================================================================================================================================
/*/

user function SC02001(cEmpProc, cFilProc)

	local cQry      as character
	local lRet      as logical
	local cEmp      as character
	local cFil      as character
	local cLogFile  as character
	local cMsgLog   as character

	// Tratamento dos parâmetros de entrada
	default cEmpProc := '01'
	default cFilProc := '0101'

	cQry     := 'exec dbo.PR_SC02001'
	lRet     := .F.
	cEmp     := cEmpProc
	cFil     := cFilProc
	cLogFile := '\logs\SC02001_' + DToS(Date()) + '.log'

	// Log de Início de Execução
	cMsgLog := '[' + DToC(Date()) + ' ' + Time() + '] - [SC02001] Início do Job de Sincronização CKOCOL.'
	FWLogMsg('INFO', /*cTransactionId*/, 'SC02001', 'JOBS', /*cCategory*/, '01', cMsgLog, 0, 0, {})
	u_GravaLog(cLogFile, cMsgLog)

	PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

	// Execução da Procedure de Integração
	lRet := u_ExecQry(cQry, .F.) // Nao encerrar em caso de falha

	RESET ENVIRONMENT

	// Log de Término e Status
	IF lRet
		cMsgLog := '[' + DToC(Date()) + ' ' + Time() + '] - [SC02001] Sincronização executada com SUCESSO.'
	ELSE
		cMsgLog := '[' + DToC(Date()) + ' ' + Time() + '] - [SC02001] ERRO ao executar a Stored Procedure PR_SC02001.'
	ENDIF

	FWLogMsg(IF(lRet, 'INFO', 'ERROR'), /*cTransactionId*/, 'SC02001', 'JOBS', /*cCategory*/, '01', cMsgLog, 0, 0, {})
	u_GravaLog(cLogFile, cMsgLog)

return lRet

/*/{Protheus.doc} u_GravaLog
Função auxiliar para escrita de log em arquivo .txt físico no servidor
/*/
static function u_GravaLog(cPathFile, cTexto)
	local nHandle as numeric

	IF !File(cPathFile)
		nHandle := FCreate(cPathFile)
	ELSE
		nHandle := FOpen(cPathFile, 2) // Modo Leitura/Escrita
		FSeek(nHandle, 0, 2)           // Vai para o final do arquivo
	ENDIF

	IF nHandle != -1
		FWrite(nHandle, cTexto + CRLF)
		FClose(nHandle)
	ENDIF

return Nil
