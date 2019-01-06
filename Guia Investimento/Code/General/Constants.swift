//
//  Constants.swift
//  Guia Investimento
//
//  Created by Felipe on 24/06/18.
//  Copyright © 2018 Thiago. All rights reserved.
//

import Foundation
struct Constants {
    
    struct TypeOp {
        static let INVALID = -1
        static let BUY = 0
        static let SELL = 1
        static let BONIFICATION = 2
        static let GROUPING = 3
        static let SPLIT = 4
        static let EDIT = 5
        static let DELETE_TRANSACTION = 6
        static let EDIT_TRANSACTION = 7
        static let EDIT_INCOME = 8
    }
    
    struct Status {
        static let INVALID = -1
        static let ACTIVE = 0
        static let SOLD = 1
    }
    
    struct ProductType {
        static let INVALID = -1
        static let STOCK = 0
        static let FII = 1
        static let CURRENCY = 2
        static let FIXED = 3
        static let TREASURY = 4
        static let OTHERS = 5
        static let PORTFOLIO = 6
    }
    
    struct IncomeType {
        static let INVALID = -1
        static let DIVIDEND = 0
        static let JCP = 1
        static let BONIFICATION = 2
        static let GROUPING = 3
        static let SPLIT = 4
        static let FII = 5
        static let FIXED = 6
        static let TREASURY = 7
        static let OTHERS = 8
    }
    
    struct UpdateStatus {
        static let INVALID = -1
        static let UPDATED = 0
        static let NOT_UPDATED = 1
    }
    
    struct FixedType {
        static let INVALID = -1
        static let CDI = 0
        static let IPCA = 1
        static let PRE = 2
    }
    
    struct Symbols{
        static let TREASURY = ["Tesouro Selic 2021","Tesouro Selic 2023","Tesouro Prefixado 2019","Tesouro Prefixado 2020","Tesouro Prefixado 2021","Tesouro Prefixado 2023","Tesouro Prefixado 2025","NTNC 2021","NTNC 2031","Tesouro IPCA com Juros Semestrais 2020","Tesouro IPCA com Juros Semestrais 2024","Tesouro IPCA com Juros Semestrais 2026","Tesouro IPCA com Juros Semestrais 2035","Tesouro IPCA com Juros Semestrais 2045","Tesouro IPCA com Juros Semestrais 2050","Tesouro IPCA 2019","Tesouro IPCA 2024","Tesouro IPCA 2035","Tesouro IPCA 2045","Tesouro Prefixado com Juros Semestrais 2021","Tesouro Prefixado com Juros Semestrais 2023","Tesouro Prefixado com Juros Semestrais 2025","Tesouro Prefixado com Juros Semestrais 2027","Tesouro Prefixado com Juros Semestrais 2029"];
        static let TREASURY_ID = ["18","19","20","21","22","23","40","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","41"];
        static let STOCKS = ["BOVA11","BRAX11","CSMO11","DIVO11","ECOO11","FIND11","GOVE11","ISUS11","MATB11","MILA11","MOBI11","PIBB11","SMAL11","UTIP11","XBOV11","ADHM3","AELP3","TIET11","TIET3","TIET4","AFLU3","AFLU5","AFLU6","AFLT3","RPAD3","RPAD5","RPAD6","ALSC3","ALPA3","ALPA4","ALTS11","ALTS3","ALUP11","ALUP3","ALUP4","ABEV3","CBEE3","ARZZ3","ATOM3","AZEV3","AZEV4","AZUL4","BTOW3","BAHI3","BEES3","BEES4","BDLL3","BDLL4","BTTL3","BTTL4","BALM3","BALM4","BBSE3","ABCB4","BRIV3","BRIV4","BAZA3","BBDC3","BBDC4","BBAS11","BBAS12","BBAS3","BPAC11","BPAC3","BPAC5","BGIP3","BGIP4","BPAR3","BRSR3","BRSR5","BRSR6","IDVL3","IDVL4","BMIN3","BMIN4","BMEB3","BMEB4","BNBR3","BPAN4","BPAT33","PINE3","PINE4","SANB11","SANB3","SANB4","BSAN33","BMKS3","BIOM3","BSEV3","B3SA3","BOBR3","BOBR4","HCBR3","BRIN3","BRML3","BRPR3","BRAP3","BRAP4","BBRK3","BPHA3","AGRO3","BRKM3","BRKM5","BRKM6","BFRE11","BFRE12","BSLI3","BSLI4","BRFS3","BRQB3","BBTG11","BBTG12","BBTG35","BBTG36","CAMB3","CAMB4","CCRO3","CCXC3","RANI3","RANI4","MAPT3","MAPT4","ELET3","ELET5","ELET6","CLSC3","CLSC4","CELP3","CELP5","CELP6","CELP7","AALR3","CESP3","CESP5","CESP6","CABB3","PCAR3","PCAR4","CASN3","CASN4","GPAR3","CEGR3","CEEB3","CEEB5","CEEB6","CEBR3","CEBR5","CEBR6","CMIG3","CMIG4","CEPE3","CEPE5","CEPE6","COCE3","COCE5","COCE6","ENMA3B","ENMA5B","ENMA6B","CSRN3","CSRN5","CSRN6","CEED3","CEED4","EEEL3","EEEL4","FESA3","FESA4","CEDO3","CEDO4","CGAS3","CGAS5","HBTS3","HBTS5","HBTS6","HGTX3","CATA3","CATA4","LCAM3","MSPA3","MSPA4","CPLE3","CPLE5","CPLE6","PEAB3","PEAB4","SBSP3","CSMG3","SAPR3","SAPR4","CSAB3","CSAB4","CSNA3","CTNM3","CTNM4","CTSA3","CTSA4","CTSA8","CIEL3","CMSA3","CMSA4","CNSY3","ODER3","ODER4","BRGE11","BRGE12","BRGE3","BRGE5","BRGE6","BRGE7","BRGE8","CALI3","CALI4","LIXC3","LIXC4","TEND3","CTAX3","CORR3","CORR4","CZLT33","RLOG3","CSAN3","CPFE3","CPRE3","CRDE3","CREM3","CRPG3","CRPG5","CRPG6","CARD3","CTCA3","TRPL3","TRPL4","CVCB3","CYRE3","CCPR3","DASA3","PNVL3","PNVL4","DIRR3","DOHL3","DOHL4","DTCY3","DTCY4","DAGB33","DTEX3","ECOR3","ENBR3","EALT3","EALT4","ELEK3","ELEK4","EKTR3","EKTR4","LIPR3","ELPL3","ELPL4","EMAE3","EMAE4","EMBR3","ECPR3","ECPR4","ENMT3","ENMT4","ENGI11","ENGI3","ENGI4","ENEV3","EGIE3","EQTL3","ESTC3","ETER3","EUCA3","EUCA4","EVEN3","BAUH3","BAUH4","EZTC3","VSPT3","VSPT4","FHER3","FBMC3","FBMC4","FIBR3","CRIV3","CRIV4","FNCN3","FLRY3","FJTA3","FJTA4","FOMS3","FRAS3","ANIM3","GFSA3","GSHP3","GGBR3","GGBR4","GOLL4","GPIV33","GPCP3","GPCP4","CGRA3","CGRA4","GRND3","GRUC3","GRUC6","GUAR3","GUAR4","HAGA3","HAGA4","HBOR3","HETA3","HETA4","HOOT3","HOOT4","HYPE3","IDNT3","IGBR3","IGTA3","JBDU3","JBDU4","ROMI3","INEP3","INEP4","PARD3","MEAL3","FIGE3","FIGE4","MYPK3","SQRM11","SQRM3","ITUB3","ITUB4","ITSA3","ITSA4","ITEC3","JBSS3","MLFT3","MLFT4","JHSF3","JFEN3","JOPA3","JOPA4","LFFE3","LFFE4","JSLG3","CTKA3","CTKA4","KEPL3","KLBN11","KLBN3","KLBN4","KROT3","LIGT3","LINX3","RENT3","LOGN3","LAME3","LAME4","LHER3","LHER4","LREN3","LPSB3","LUPA3","MDIA3","MSRO3","MGLU3","MAGG3","LEVE3","MGEL3","MGEL4","ESTR3","ESTR4","POMO3","POMO4","MRFG3","AMAR3","MEND3","MEND5","MEND6","MERC3","MERC4","FRIO3","MTIG3","MTIG4","GOAU3","GOAU4","RSUL3","RSUL4","MTSA3","MTSA4","MILS3","MMAQ3","MMAQ4","BEEF3","MNPR3","MMXM3","MOAR3","MOVI3","MRVE3","MULT3","MPLU3","MNDL3","NAFG3","NAFG4","NATU3","NORD3","NRTQ3","NUTR3","ODPV3","OGSA3","OIBR3","OIBR4","OGXP3","OSXB3","OFSA3","PATI3","PATI4","PRBC4","PMAM3","PTBL3","PDGR3","PRIO3","PETR3","PETR4","PTNT3","PTNT4","PLAS3","PPAR3","FRTA3","PSSA3","POSI3","PRCA11","PRCA12","PRCA3","PFRM3","PRML3","QGEP3","QUAL3","QUSW3","RADL3","RAPT3","RAPT4","RCSL3","RCSL4","REDE3","REDE4","RPMG3","RNEW11","RNEW3","RNEW4","LLIS3","GEPA3","GEPA4","RDNI3","RSID3","RAIL3","SNSY3","SNSY5","SNSY6","STBP3","SCAR3","SMTO3","AHEB3","AHEB5","AHEB6","SLED3","SLED4","PSEG3","PSEG4","SHUL3","SHUL4","SNSL3","SEER3","APTI3","APTI4","SLCE3","SMLE3","SEDU3","SSBR3","SOND3","SOND5","SOND6","SPRI3","SPRI5","SPRI6","SGPS3","STKF3","SULA11","SULA3","SULA4","NEMO3","NEMO5","NEMO6","SUZB5","SUZB6","SHOW3","TRPN3","TOYB3","TOYB4","TECN3","TCSA3","TCNO3","TCNO4","TGMA3","TEKA3","TEKA4","TKNO3","TKNO4","TELB3","TELB4","VIVT3","VIVT4","TESA3","TXRX3","TXRX4","TIMP3","TOTS3","TPIS3","TAEE11","TAEE3","TAEE4","LUXM3","LUXM4","TRIS3","TUPY3","UGPA3","UCAS3","UNIP3","UNIP5","UNIP6","USIM3","USIM5","USIM6","VALE3","VALE5","VLID3","VVAR11","VVAR3","VVAR4","VIVR3","VULC3","WEGE3","MWET3","MWET4","WHRL3","WHRL4","WSON33","WIZS3","SGAS3","SGAS4","IRBR3","CRFB3","SAPR11","SUZB3","OMGE3","RHPY3","BRDT3","BIDI11"];
        static let FII = ["AEFI11","ATCR11","BCRI11","BNFS11","BBFI11B","BBPO11","BBIM11","BBRC11","RNDP11","BCIA11","CARE11","CXRI11","CPTS11B","CBOP11","ATSA11B","HGBS11","GRLV11","HGJH11","HGLG11","HGRE11","HGCR11","FOFT11","TFOF11","DOMC11","DOVL11B","FIXX11","VRTA11","BMII11","ANCR11B","FAED11","BRCR11","FEXC11","BCFF11B","FCFL11B","CNES11","CEOC11B","THRA11B","FAMB11B","FCAS11","EDGA11","ELDO11B","FLRP11","HCRI11","NSLU11","HTMX11","MAXR11","NVHO11","PQDP11","PRSV11","JRDM11","SHDP11B","WPLZ11B","SAIC11B","TBOF11","ALMI11","TRNT11","VLOL11","AGCX11","BBVJ11","BMLC11B","BPFF11","BVAR11","CXCE11B","CXTL11","CTXT11","FLMA11","EDFO11B","EURO11","FIGS11","ABCP11","GWIR11","FIIB11","FMOF11","MBRF11","PABY11","FPNG11","VPSI11","FPAB11","FFCI11","RNGO11","SFND11","SCPF11","SHPH11","ONEF11","FVBI11","VERE11","FVPQ11","RBBV11","JPPC11","JSRE11","KNRE11","KNIP11","KNRI11","KNCR11","LATR11B","MXRF11","MFII11","DRIT11B","FTCE11B","PRSN11B","PLRI11","PORD11","RBDS11","RBGS11","FIIP11B","RBRD11","REIT11B","RDES11","RBCB11","RBVO11","SAAG11","SDIL11","SPTW11","SPAF11","TSNC11","XTED11","TRXL11","VLJS12","XPCM11","XPGA11","JTPR11","OUJP11","GGRC11","KINP11","VLJS11","RBRF11","VISC11","RBRR11"];
        static let ALL = ["DOLAR","EURO","BITCOIN","LITECOIN","ETHERIUM","BOVA11","BRAX11","CSMO11","DIVO11","ECOO11","FIND11","GOVE11","ISUS11","MATB11","MILA11","MOBI11","PIBB11","SMAL11","UTIP11","XBOV11","ADHM3","AELP3","TIET11","TIET3","TIET4","AFLU3","AFLU5","AFLU6","AFLT3","RPAD3","RPAD5","RPAD6","ALSC3","ALPA3","ALPA4","ALTS11","ALTS3","ALUP11","ALUP3","ALUP4","ABEV3","CBEE3","ARZZ3","ATOM3","AZEV3","AZEV4","AZUL4","BTOW3","BAHI3","BEES3","BEES4","BDLL3","BDLL4","BTTL3","BTTL4","BALM3","BALM4","BBSE3","ABCB4","BRIV3","BRIV4","BAZA3","BBDC3","BBDC4","BBAS11","BBAS12","BBAS3","BPAC11","BPAC3","BPAC5","BGIP3","BGIP4","BPAR3","BRSR3","BRSR5","BRSR6","IDVL3","IDVL4","BMIN3","BMIN4","BMEB3","BMEB4","BNBR3","BPAN4","BPAT33","PINE3","PINE4","SANB11","SANB3","SANB4","BSAN33","BMKS3","BIOM3","BSEV3","B3SA3","BOBR3","BOBR4","HCBR3","BRIN3","BRML3","BRPR3","BRAP3","BRAP4","BBRK3","BPHA3","AGRO3","BRKM3","BRKM5","BRKM6","BFRE11","BFRE12","BSLI3","BSLI4","BRFS3","BRQB3","BBTG11","BBTG12","BBTG35","BBTG36","CAMB3","CAMB4","CCRO3","CCXC3","RANI3","RANI4","MAPT3","MAPT4","ELET3","ELET5","ELET6","CLSC3","CLSC4","CELP3","CELP5","CELP6","CELP7","AALR3","CESP3","CESP5","CESP6","CABB3","PCAR3","PCAR4","CASN3","CASN4","GPAR3","CEGR3","CEEB3","CEEB5","CEEB6","CEBR3","CEBR5","CEBR6","CMIG3","CMIG4","CEPE3","CEPE5","CEPE6","COCE3","COCE5","COCE6","ENMA3B","ENMA5B","ENMA6B","CSRN3","CSRN5","CSRN6","CEED3","CEED4","EEEL3","EEEL4","FESA3","FESA4","CEDO3","CEDO4","CGAS3","CGAS5","HBTS3","HBTS5","HBTS6","HGTX3","CATA3","CATA4","LCAM3","MSPA3","MSPA4","CPLE3","CPLE5","CPLE6","PEAB3","PEAB4","SBSP3","CSMG3","SAPR3","SAPR4","CSAB3","CSAB4","CSNA3","CTNM3","CTNM4","CTSA3","CTSA4","CTSA8","CIEL3","CMSA3","CMSA4","CNSY3","ODER3","ODER4","BRGE11","BRGE12","BRGE3","BRGE5","BRGE6","BRGE7","BRGE8","CALI3","CALI4","LIXC3","LIXC4","TEND3","CTAX3","CORR3","CORR4","CZLT33","RLOG3","CSAN3","CPFE3","CPRE3","CRDE3","CREM3","CRPG3","CRPG5","CRPG6","CARD3","CTCA3","TRPL3","TRPL4","CVCB3","CYRE3","CCPR3","DASA3","PNVL3","PNVL4","DIRR3","DOHL3","DOHL4","DTCY3","DTCY4","DAGB33","DTEX3","ECOR3","ENBR3","EALT3","EALT4","ELEK3","ELEK4","EKTR3","EKTR4","LIPR3","ELPL3","ELPL4","EMAE3","EMAE4","EMBR3","ECPR3","ECPR4","ENMT3","ENMT4","ENGI11","ENGI3","ENGI4","ENEV3","EGIE3","EQTL3","ESTC3","ETER3","EUCA3","EUCA4","EVEN3","BAUH3","BAUH4","EZTC3","VSPT3","VSPT4","FHER3","FBMC3","FBMC4","FIBR3","CRIV3","CRIV4","FNCN3","FLRY3","FJTA3","FJTA4","FOMS3","FRAS3","ANIM3","GFSA3","GSHP3","GGBR3","GGBR4","GOLL4","GPIV33","GPCP3","GPCP4","CGRA3","CGRA4","GRND3","GRUC3","GRUC6","GUAR3","GUAR4","HAGA3","HAGA4","HBOR3","HETA3","HETA4","HOOT3","HOOT4","HYPE3","IDNT3","IGBR3","IGTA3","JBDU3","JBDU4","ROMI3","INEP3","INEP4","PARD3","MEAL3","FIGE3","FIGE4","MYPK3","SQRM11","SQRM3","ITUB3","ITUB4","ITSA3","ITSA4","ITEC3","JBSS3","MLFT3","MLFT4","JHSF3","JFEN3","JOPA3","JOPA4","LFFE3","LFFE4","JSLG3","CTKA3","CTKA4","KEPL3","KLBN11","KLBN3","KLBN4","KROT3","LIGT3","LINX3","RENT3","LOGN3","LAME3","LAME4","LHER3","LHER4","LREN3","LPSB3","LUPA3","MDIA3","MSRO3","MGLU3","MAGG3","LEVE3","MGEL3","MGEL4","ESTR3","ESTR4","POMO3","POMO4","MRFG3","AMAR3","MEND3","MEND5","MEND6","MERC3","MERC4","FRIO3","MTIG3","MTIG4","GOAU3","GOAU4","RSUL3","RSUL4","MTSA3","MTSA4","MILS3","MMAQ3","MMAQ4","BEEF3","MNPR3","MMXM3","MOAR3","MOVI3","MRVE3","MULT3","MPLU3","MNDL3","NAFG3","NAFG4","NATU3","NORD3","NRTQ3","NUTR3","ODPV3","OGSA3","OIBR3","OIBR4","OGXP3","OSXB3","OFSA3","PATI3","PATI4","PRBC4","PMAM3","PTBL3","PDGR3","PRIO3","PETR3","PETR4","PTNT3","PTNT4","PLAS3","PPAR3","FRTA3","PSSA3","POSI3","PRCA11","PRCA12","PRCA3","PFRM3","PRML3","QGEP3","QUAL3","QUSW3","RADL3","RAPT3","RAPT4","RCSL3","RCSL4","REDE3","REDE4","RPMG3","RNEW11","RNEW3","RNEW4","LLIS3","GEPA3","GEPA4","RDNI3","RSID3","RAIL3","SNSY3","SNSY5","SNSY6","STBP3","SCAR3","SMTO3","AHEB3","AHEB5","AHEB6","SLED3","SLED4","PSEG3","PSEG4","SHUL3","SHUL4","SNSL3","SEER3","APTI3","APTI4","SLCE3","SMLE3","SEDU3","SSBR3","SOND3","SOND5","SOND6","SPRI3","SPRI5","SPRI6","SGPS3","STKF3","SULA11","SULA3","SULA4","NEMO3","NEMO5","NEMO6","SUZB5","SUZB6","SHOW3","TRPN3","TOYB3","TOYB4","TECN3","TCSA3","TCNO3","TCNO4","TGMA3","TEKA3","TEKA4","TKNO3","TKNO4","TELB3","TELB4","VIVT3","VIVT4","TESA3","TXRX3","TXRX4","TIMP3","TOTS3","TPIS3","TAEE11","TAEE3","TAEE4","LUXM3","LUXM4","TRIS3","TUPY3","UGPA3","UCAS3","UNIP3","UNIP5","UNIP6","USIM3","USIM5","USIM6","VALE3","VALE5","VLID3","VVAR11","VVAR3","VVAR4","VIVR3","VULC3","WEGE3","MWET3","MWET4","WHRL3","WHRL4","WSON33","WIZS3","SGAS3","SGAS4","IRBR3","CRFB3","AEFI11","ATCR11","BCRI11","BNFS11","BBFI11B","BBPO11","BBIM11","BBRC11","RNDP11","BCIA11","CARE11","CXRI11","CPTS11B","CBOP11","ATSA11B","HGBS11","GRLV11","HGJH11","HGLG11","HGRE11","HGCR11","FOFT11","TFOF11","DOMC11","DOVL11B","FIXX11","VRTA11","BMII11","ANCR11B","FAED11","BRCR11","FEXC11","BCFF11B","FCFL11B","CNES11","CEOC11B","THRA11B","FAMB11B","FCAS11","EDGA11","ELDO11B","FLRP11","HCRI11","NSLU11","HTMX11","MAXR11","NVHO11","PQDP11","PRSV11","JRDM11","SHDP11B","WPLZ11B","SAIC11B","TBOF11","ALMI11","TRNT11","VLOL11","AGCX11","BBVJ11","BMLC11B","BPFF11","BVAR11","CXCE11B","CXTL11","CTXT11","FLMA11","EDFO11B","EURO11","FIGS11","ABCP11","GWIR11","FIIB11","FMOF11","MBRF11","PABY11","FPNG11","VPSI11","FPAB11","FFCI11","RNGO11","SFND11","SCPF11","SHPH11","ONEF11","FVBI11","VERE11","FVPQ11","RBBV11","JPPC11","JSRE11","KNRE11","KNIP11","KNRI11","KNCR11","LATR11B","MXRF11","MFII11","DRIT11B","FTCE11B","PRSN11B","PLRI11","PORD11","RBDS11","RBGS11","FIIP11B","RBRD11","REIT11B","RDES11","RBCB11","RBVO11","SAAG11","SDIL11","SPTW11","SPAF11","TSNC11","XTED11","TRXL11","VLJS12","XPCM11","XPGA11","JTPR11","OUJP11","GGRC11","KINP11","VLJS11","RBRF11","VISC11","SAPR11","SUZB3","OMGE3","RHPY3","BRDT3","BIDI11","RBRR11"];
    }
}
