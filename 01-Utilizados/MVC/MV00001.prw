#include 'protheus.ch'
#include 'topconn.ch'
#include 'FWMVCDef.ch'

/*/
===============================================================================================================================
Programa----------: MV00001
Autor-------------: Renato Fuzessy Teixeira Filho
Data da Criacao---: 15/01/2019
===============================================================================================================================
Descrição---------: Este programa serve para CADASTRAR OS CHAMADOS JUNTO A TI
===============================================================================================================================
Uso---------------: TODOS OS MUDULOS
===============================================================================================================================
Parametros--------: Sem parametros
===============================================================================================================================
Retorno-----------: sem parametro
===============================================================================================================================
Chamado(SPS)------: 
===============================================================================================================================
Setor-------------: TIC
===============================================================================================================================
===============================================================================================================================
										ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL
===============================================================================================================================
	Autor		|	Data	|										Motivo																
----------------:-----------:-------------------------------------------------------------------------------------------------:
Renato Fuzessy	|03/06/2026 |
----------------:-----------:-------------------------------------------------------------------------------------------------:
				|			|																											
===============================================================================================================================
/*/

user function MV00001()

	local oBrowse  
	local cFiltroTela	:= ''	//'1=1'
	
	private oDlgPrinc
	private cCadastro 	:= '[MV00001] - Controle de Chamados TIC'
	
	oBrowse:= FWmBrowse():New()
	oBrowse:SetDescription( cCadastro )
	//oBrowse:DisableDetails()
	oBrowse:SetAlias( 'Z09' )
	oBrowse:SetMenuDef( 'MV00001' ) // Define de que fonte vem os botoes deste browse
	oBrowse:SetProfileID( '1' ) // Identificador ID para o Browse
	oBrowse:ForceQuitButton()	// Exibicao do botao Sair  
	oBrowse:SetFilterDefault(cFiltroTela) //Filtros da rotina
	
	/* Legendas */ 
	oBrowse:AddLegend( "Z09_STATUS == '0' "	, "BR_VERDE"		, "0 - Aberto" )
	oBrowse:AddLegend( "Z09_STATUS == '1' "	, "BR_AMARELO"		, "1 - Em Analise" )
	oBrowse:AddLegend( "Z09_STATUS == '2' "	, "BR_LARANJA"		, "2 - Terceiro" )
	oBrowse:AddLegend( "Z09_STATUS == '3' "	, "BR_VERMELHO"		, "3 - Ag Definicao" )
	oBrowse:AddLegend( "Z09_STATUS == '4' "	, "BR_VIOLETA"		, "4 - Ag Validacao" )
	oBrowse:AddLegend( "Z09_STATUS == '7' "	, "BR_AZUL"			, "7 - Lib. Publicacao" )
	oBrowse:AddLegend( "Z09_STATUS == '8' "	, "BR_MARRON"		, "8 - Cancelado" )
	oBrowse:AddLegend( "Z09_STATUS == '9' "	, "BR_PRETO"		, "9 - Encerrado" )

	oBrowse:Activate()      

return


/*CRIAR MODELO DE DADOS*/
static function ModelDef

	local oModel
	
	/* Carregar a estrutura de dados */
	local oStrZ09	:= FWFormStruct(1,'Z09')
	local oStrZ10	:= FWFormStruct(1,'Z10')
	
	/* Definir modelo de dados */
	oModel	:= MPFormModel():New('MV00001_MVC', /*bPreValidacao*/, /*bPosValidacao*/,{|oModel| MV00001GRV(oModel) }/*bCommit*/, /*bCancel*/ )
	
	/* editar propriedades do modelo de dados */
	oModel:addFields('FIELD_Z09',,oStrZ09)
	oModel:addGrid('GRID_Z10','FIELD_Z09' ,oStrZ10, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	/*Relacao entre as Estrutura*/
	oModel:SetRelation('GRID_Z10',{{'Z10_FILIAL','fwxFilial("Z10")'}, {'Z10_NUM', 'Z09_NUM'}}, Z10->(IndexKey(1)))
	
	oModel:setDescription('[MV00001] - Controle de Chamados TIC')
	oModel:GetModel('GRID_Z10'):setDescription('Chamados Externos')
	
	/*Liga o controle de não repetição de linha*/
	oModel:GetModel('GRID_Z10'):setUniqueLine({'Z10_ITEM'})
	
	/* Indica que é opcional ter dados nas Grids permitindo salvar a grid vazia*/
	oModel:GetModel( 'GRID_Z10' ):SetOptional(.T.)

	/*Definicao da Chave Primaria*/
	oModel:SetPrimaryKey({'Z09_FILIAL', 'Z09_NUM'})
	
return oModel


/*CRIAR VIEWDEF DO MODELO DE DADOS*/
static function ViewDef()

	/*Importar modelo de dados */
	local oModel	:= FWLoadModel('MV00001')	//nome do fonte que esta criado a estrutura de dados
	
	/*Cria estrutura de dados da Viewdef*/
	Local oStrZ09 	:= FWFormStruct(2,'Z09')
	local oStrZ10	:= FWFormStruct(2,'Z10')	//criar a estrutura de dados da camada de visualização 
	local oView		:= FWFormView():New()
	
	/*Definir propriedades da Viewdef*/
	RemoveFld(oStrZ09,oStrZ10)		//remocao de campos da estrutura
	
	/*Define qual modelo de dados sera utilizado pela View*/
	oView:SetModel(oModel)

	/* Construir ViewDef*/
	oView:AddField('VIEW_Z09', oStrZ09, 'FIELD_Z09' )
	oView:AddGrid('VIEW_Z10', oStrZ10, 'GRID_Z10' )
	
	/*Define campos que terao auto incremento*/
	oView:addIncrementField('VIEW_Z10','Z10_ITEM')
	
	/*Define se exibe Titulo do componente*/
	//oView:enableTitleView('VIEW_Z09')
	oView:enableTitleView('VIEW_Z10')
	
	/*Incluir BOTOES customizados*/
	oView:addUserButton('Conhecimento', 'Z09', {|oView| _botao()})
	
	/*Gerar Box de Visualizacao*/
	oView:CreateHorizontalBox('SUPERIOR', 80)  			// <nome do box>, <%que vai ocupar na tela>
	oView:CreateHorizontalBox('INFERIOR', 20)  			// <nome do box>, <%que vai ocupar na tela>
	
	/*Relacionar box com a Estrutura*/
	oView:SetOwnerView('VIEW_Z09', 'SUPERIOR')			//
	oView:SetOwnerView('VIEW_Z10', 'INFERIOR')			//
	
/*	// Define os filtros para o grid
	oView:SetViewProperty('VIEW_Z10', "ENABLENEWGRID") 					//Define que o grid deve usar como interface visual o browse (FWBrowse)
	oView:SetViewProperty('VIEW_Z10', "GRIDFILTER"		, {.T.})  		//Habilita Filtro no Grid
	oView:SetViewProperty('VIEW_Z10', "GRIDSEEK"		, {.T.})   		//Habilita Localizar no Grid na ViewDef
*/
return oView


/*CRIAR MENU DA ROTINA*/
static function MenuDef()

	local aRotina	:= {}
	
	aadd(aRotina,{'Visualizar'	, 'VIEWDEF.MV00001', 0, 2, 0, nil})
	aadd(aRotina,{'Incluir'		, 'VIEWDEF.MV00001', 0, 3, 0, nil})
	aadd(aRotina,{'Alterar'		, 'VIEWDEF.MV00001', 0, 4, 0, nil})
	aadd(aRotina,{'Excluir'		, 'VIEWDEF.MV00001', 0, 5, 0, nil})
	aadd(aRotina,{'Imprimir'	, 'VIEWDEF.MV00001', 0, 8, 0, nil})
	//aadd(aRotina,{'Conhecimento', "MsDocument('Z09', Z09->(recno()), 4)", 0, 4, 0, nil})

return aRotina

static function _botao()
	//local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

	local	cAliasKey	as caracter,;
			cChave		as caracter,;
			cDescricao	as caracter

	cAliasKey	:= 'Z09'
	cChave		:= Z09->Z09_FILIAL + Z09->Z09_NUM
	cDescricao	:= Z09->Z09_FILIAL + Z09->Z09_NUM + ' - ' + Z09->Z09_DESC

	//axConhec( cAliasKey, cChave, cDescricao )

	//FWExecView('Conhecimento',"axconhec()", MODEL_OPERATION_UPDATE, , { || .T. } )

return

/*Remove campos da estrutura*/
static function RemoveFld(oStrZ09,oStrZ10)

	oStrZ10:RemoveField('Z10_DATA')
	oStrZ10:RemoveField('Z10_NUM')

return

/*Seta propriedades da estrutura de dados*/
static function SetPropM(oStrZ09, oStrZ10)

	oStrZ10:SetProperty('Z10_DTCHAM', MODEL_FIELD_VALID, {||_validadata()})

return

static function setPropV(oStrZ09, oStrZ10)
	
//	oStrZ09:addGroup('grp01','Abertura do Chamado','',1)
//	oStrZ09:addGroup('grp02','Detalhe do Chamado','',2)
//	
//	oStrZ09:setProperty('Z09_DETAL',MVC_VIEW_GROUP_NUMBER,'grp02')

return

/*Funcaopara validar data */
static function _validadata()

	local _lRet		:= .T.
	local oModel	:= FWModelActive()
	local oModelZ10	:= oModel:GetModel('GRID_Z10')
	
	local _dData	:= oModelZ10:getValue('Z10_DTCHAM')	//&(readvar())
	local _dDataAtu	:= DDATABASE

	if _dData > _dDataAtu
		_lRet	:= .F.
		help(,,'Help',,'Data inválida.', 1, 0)
	endif
		
return _lRet


/*Ponto de Entrada MV00001GRV*/
static function MV00001GRV( oModel ) 

     local lRet 
      
     /*Aqui podemos chamar funções antes do Commit Padrão.*/ 
     DefStatusChamado() 
      
     /*Aqui temos a chamada da funcao padrão de gravação do MVC.*/ 	// http://tdn.totvs.com/display/framework/FWFormCommit 
     lRet := FWFormCommit( oModel /*[ oModel ]*/,; 
                                  /*[ bBefore ]*/,; 
                                  /*[ bAfter ]*/,; 
                                  /*[ bAfterSTTS ]*/,; 
                                  /*[ bInTTS ]*/,; 
                                  /*[ bABeforeTTS ]*/,; 
                                  /*[ bIntegEAI ] */ ) 
      
     /* Aqui podemos chamar funções depois do Commit Padrão, verificando sempre se o commit foi realizado. */ 
     if lRet
     	//	__FazAlgoDepoisCommit() 
     	if u_msgPergunta('Enviar e-mail com posição do chamado?','[MV00001] - ENVIANDO EMAIL AGUARDE') = 6
     		EnviaEmail()
     	endif
     	
     endif 

return lRet 

/*Funcao para definir o status atual*/
static function DefStatusChamado()

	if altera .and. Z09->Z09_STATUS	== '0' .and. M->Z09_STATUS == '0'
		if u_msgPergunta('Deseja alterar o status para 1-EM ANALISE?','[MV00001] - Atualizando Status do Chamado') = 6
			if RecLock('Z09',.F.)
				Z09->Z09_STATUS	:= '1'
				msUnLock()
			endif
		endif
	endif
return


/*Funcao para Enviar Email*/
static function EnviaEmail()
	local	_cTo			:= lower(AllTrim(GetMv('MV_RELACNT'))),;
			_cFrom			:= lower(UsrRetMail(Z09->Z09_SOLIC)+';'+alltrim(Z09->Z09_EMAILC)),;
			_cCopia			:= ' ',;
			_cCopiaOculta	:= ' ',;
			_cAssunto		:= ' ',;
			_cMensagem		:= ' ',;
			_lReturn		:= .F.
			
	if Z09->Z09_STATUS	== '0'	//ABETURA DE CHAMADO
		_cAssunto	:= OemToAnsi('[TIC-MANFIL] ABERTURA CHAMADO: '+alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC))
		_cMensagem	:= OemToAnsi('Chamado: ') + alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC) + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Ocorrêcia: ') + Z09->Z09_OCOR + CRLF + CRLF

	elseif Z09->Z09_STATUS	== '1'	//1=Em Analise
		_cAssunto	:= OemToAnsi('[TIC-MANFIL] CHAMADO ATUALIZADO: '+alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC))
		_cMensagem	:= OemToAnsi('Chamado: ') + alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC) + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Ocorrêcia: ') + Z09->Z09_OCOR + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Detalhe: ') + Z09->Z09_DETAL + CRLF + CRLF

	elseif Z09->Z09_STATUS	== '2'
		_cAssunto	:= OemToAnsi('[TIC-MANFIL] CHAMADO ATUALIZADO: '+alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC))
		_cMensagem	:= OemToAnsi('Chamado foi encaminhado a TERCEIROS e estamos aguardando o retorno') + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Chamado: ') + alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC) + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Ocorrêcia: ') + Z09->Z09_OCOR + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Detalhe: ') + Z09->Z09_DETAL + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Próxima Ações: ') + Z09->Z09_ACOES + CRLF + CRLF

	elseif Z09->Z09_STATUS	== '3'	//3=Ag.Definicao
		_cAssunto	:= OemToAnsi('[TIC-MANFIL] CHAMADO ATUALIZADO: '+alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC))
		_cMensagem	:= OemToAnsi('Chamado encontra-se no STATUS AGUARDANDO RETORNO') + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Chamado: ') + alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC) + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Ocorrêcia: ') + Z09->Z09_OCOR + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Próxima Ações: ') + Z09->Z09_ACOES + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Solução: ') + Z09->Z09_SOL + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Detalhe: ') + Z09->Z09_DETAL + CRLF + CRLF

	elseif Z09->Z09_STATUS	== '7'	//7=Lib.Publicacao
		_cAssunto	:= OemToAnsi('[TIC-MANFIL] CHAMADO ATUALIZADO: '+alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC))
		_cMensagem	:= OemToAnsi('Chamado encontra-se no STATUS LIB. PUBLICACAO e ocorrerá em próxima agenda') + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Chamado: ') + alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC) + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Ocorrêcia: ') + Z09->Z09_OCOR + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Próxima Ações: ') + Z09->Z09_ACOES + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Detalhe: ') + Z09->Z09_DETAL + CRLF + CRLF

	elseif Z09->Z09_STATUS	== '8'	//8=Cancelado
		_cAssunto	:= OemToAnsi('[TIC-MANFIL] CHAMADO CANCELADO: '+alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC))
		_cMensagem	:= OemToAnsi('Chamado: ') + alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC) + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Ocorrêcia: ') + Z09->Z09_OCOR + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Detalhe: ') + Z09->Z09_DETAL + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Próxima Ações: ') + Z09->Z09_ACOES + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Solução: ') + Z09->Z09_SOL + CRLF + CRLF

	elseif Z09->Z09_STATUS	== '9'	//9=Encerrado
		_cAssunto	:= OemToAnsi('[TIC-MANFIL] CHAMADO ENCERRADO: '+alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC))
		_cMensagem	:= OemToAnsi('Chamado: ') + alltrim(Z09->Z09_NUM)+' - '+AllTrim(Z09->Z09_DESC) + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Ocorrêcia: ') + Z09->Z09_OCOR + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Detalhe: ') + Z09->Z09_DETAL + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Próxima Ações: ') + Z09->Z09_ACOES + CRLF + CRLF
		_cMensagem	+= OemToAnsi('Solução: ') + Z09->Z09_SOL + CRLF + CRLF
		
	endif
	_cMensagem	+= CRLF + CRLF 
	_cMensagem	+= OemToAnsi('TIC - Manfil      ') + CRLF
	_cMensagem	+= OemToAnsi('Tecnologia, Informa'+chr(35947)+'o e Comunica'+chr(35947)+'o') + CRLF

	Processa({ || U_EnvMail(_cTo,_cFrom,_cCopia,_cCopiaOculta,_cAssunto,_cMensagem,'',_lReturn)},'[MV00001] - ENVIANDO EMAIL AGUARDE')

return
