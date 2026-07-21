#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

User Function FINM020()
	Local aParam := PARAMIXB
	Local lRet := .T.
	Local oModParam := ''
	Local oModelBxR := ''
	Local cIdPonto := ''
	Local cIdModel := ''
	//Local oFK8 := Nil
	//Local oFKA := Nil
	Local cCamposE5 := ''

	If aParam <> NIL

		oModParam := aParam[1] //Objeto do formulário ou do modelo, conforme o caso
		cIdPonto := aParam[2] //ID do local de execução do ponto de entrada
		cIdModel := aParam[3] //ID do formulário

		If cIdPonto == 'FORMPOS'
			If cIdModel == 'FK5DETAIL'
				oModelBxR := oModParam:GetModel()
				/*
				oFK8 := oModelBxR:GetModel( "FK8DETAIL" )
				oFKA := oModelBxR:GetModel( "FKADETAIL" )
				*/

				cCamposE5 := AllTrim(oModelBxR:GetValue('MASTER', 'E5_CAMPOS'))
				If !Empty(cCamposE5)
					cCamposE5 := Left( cCamposE5, Len(cCamposE5) -1 )
					cCamposE5 += ",{ 'E5_XDTLGIN', FWLEUSERLG('E5_USERLGI',2) }"
					cCamposE5 += ",{ 'E5_XUSRLGI', FWLEUSERLG('E5_USERLGI',1) }}"
				Else
					cCamposE5 := "{{ 'E5_XDTLGIN', FWLEUSERLG('E5_USERLGA',2) }}"
					cCamposE5 += ",{ 'E5_XUSRLGI', FWLEUSERLG('E5_USERLGA',1) }}"
				EndIf

				oModelBxR:SetValue( "MASTER","E5_CAMPOS",cCamposE5 ) // Informando o atributo "E5_CAMPOS"
				/*
				oFK8:SetValue( "FK8_CCD", '000000001' )
				oFK8:SetValue( "FK8_CCC", '000000002' )
				oFK8:SetValue( "FK8_IDMOV", oFKA:GetValue('FKA_IDORIG') )
				*/
			EndIf
		EndIf
	EndIf

Return lRet
