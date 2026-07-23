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
Programa----------: SX5NOTA
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 01/10/2018
===============================================================================================================================
Descrição---------: Este programa serve para validar o saldo do produto para faturamento
===============================================================================================================================
Uso---------------: MATA415
===============================================================================================================================
Parametros--------: Nenhum
===============================================================================================================================
Retorno-----------: sem retorno
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: SIGAFAT
===============================================================================================================================
/*/

user function SX5NOTA()
 
	local	cAmbiente	as char,;
			cChave   	as char,;
			lRet     	as logical,;
			lControl	as logical

/*	Local _cFilial  := Paramixb[1]  //Filial
	Local _cTabela  := Paramixb[2]  //Tabela da SX5
	local cChave   	:= Paramixb[3]	//serie da nota
	Local _cDescri  := Paramixb[4]  //Conteúdo da Chave indicada
	local cForm		:= '[SX5NOTA] - Validando as Sequencia de Notas'
*/

	cAmbiente	:= Alltrim(GetMv("MV_XLOCAL"))
	cChave   	:= Paramixb[3]	//serie da nota fiscal
	lRet     	:= .F.
	lControl	:= .F.

	//é do grupo de administradores, fiscal/contabil ou supervisor de estoque?
	if u_EstaGrp(RetCodUsr(),'000000') .or. u_EstaGrp(RetCodUsr(),'000007') .or. u_EstaGrp(RetCodUsr(),'000014')
		lControl:= .T.
	endif

	if cAmbiente == '1'
		if alltrim(cChave) == 'XTR' .and. !lControl
			lRet:= .F.
		else
			lRet:= .T.
		endif

	elseif cAmbiente == '2'
		lRet:= .F.
		if alltrim(funname()) $  "MATA461"
			if alltrim(cChave) == 'TST'
				lRet:= .T.

			elseIf SC5->C5_TIPO $ "D|B"
				lRet:= .T.

			elseif lControl	// é administrador ou fiscal
				lRet:= .T.

			elseif !lControl .and. alltrim(cChave) >= '003' .and. alltrim(cChave) <= '017'
				lRet:= .T.
				if ExisteSrv()
					lRet:= .F.
				endif
			else
				if (alltrim(cChave) >= '018' .and. alltrim(cChave) <= '999')
					if ExisteSrv()
						lRet:= .T.
					else
						lRet:= .F.
					endif
				endif
				
			endif
		else
			lRet     := .T.			
		endif
	endif

return lRet

static function ExisteSrv()
	local	aArea		as object,;
			aAreaSC6	as object,;
			lRet		as logical

	aArea		:= getArea()
	aAreaSC6	:= SC6->(getArea())
	lRet		:= .F.

	dbSelectArea('SC6')
	SC6->(dbSetOrder(1))
	SC6->(dbGoTop())
	SC6->(dbSeek(FwxFilial('SC6')+SC5->C5_NUM))
	while !SC6->(eof()) .and. SC6->C6_NUM == SC5->C5_NUM
		if !empty(SC6->C6_CODISS)
			lRet:= .T.
		endif
		SC6->(dbskip())
	enddo
	SC6->(dbCloseArea())

	restArea(aAreaSC6)
	restArea(aArea)

return lRet
