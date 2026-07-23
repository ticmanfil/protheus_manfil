#Include 'Protheus.ch'

User Function FA330FBRW()

	Local aGroups as array
	Local xSeek
	Local cFiltro:= '' 

	cFiltro:= "((E1_TIPO IN ('RA','NCC') AND E1_EMISSAO >= '"+dtos(monthsum(DDATABASE,-1))+"') OR E1_TIPO NOT IN ('RA','NCC'))"
	xSeek   := __cUserID
	aGroups := FWSFUsrGrps(xSeek)

  	if xSeek $ "000000/0000006/0000004/0000085" //Administrador, luciene.queiroz, flavia.santos,
		cFiltro	:= nil
	endif

	//AVISO("PE.FA330FBRW","EM EXECUCAO - "+cFiltro, {"OK"})

return cFiltro

