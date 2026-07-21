user function RD09003(pMes,pAno)

    local nTotal := 0
    local cData     := ''

    cData   := cValToChar(pAno)+StrZero(pMes,2)

    if select('TB1') > 0
        dbSelectArea('TB1')
        TB1->(dbCloseArea())
    endif

    beginsql alias 'TB1'
        select  sum(FT_VALICM) as VALICM, sum(FT_CRDPRES) as CREDPRES
        from
            %table:SFT%    SFT
            inner join %table:SB1%  SB1
                on  SB1.%notdel%
                and SB1.B1_FILIAL   = %xFilial:SB1%
                and SB1.B1_COD      = SFT.FT_PRODUTO
                and SB1.B1_GRTRIB    = '010'
        where
                SFT.%notdel%
            and SFT.FT_FILIAL                   = %xFilial:SFT%
            and substring(SFT.FT_ENTRADA,1,6)   = %exp:cData%
            and (substring(SFT.FT_DTCANC,1,6)   = '' or substring(SFT.FT_DTCANC,1,6) > %exp:cData%)
            //and SFT.FT_ENTRADA                  >= '20200824'//EXCLUIR PARA ENTRAR EM PRODUCAO
    endsql

    nTotal  := TB1->VALICM

    TB1->(dbCloseArea())

return nTotal
