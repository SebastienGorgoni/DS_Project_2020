/////////////////////////////// Data Science For Fincance: Project Group 28 ////////////////////////////

use Data_ESG_Final_All, clear

histogram esg, frequency title("Frequency of ESG")
graph export HistESG.pdf,replace

histogram esgcomb, frequency title("Frequency of ESG Combined")
graph export HistESGComb.pdf,replace

encode identifierric, gen(ric)

xtset  ric year

sort identifierric year

by identifierric year: gen returns_rf=returns-rf

pwcorr returns_rf mktrf SMB HML 

winsor returns, gen(returns_w) p(0.01) 

sort identifierric year

by identifierric year: gen returns_rf_w=returns_w-rf

drop returns_rf 

rename returns_rf_w returns_rf

drop returns

rename returns_w returns


////////////Descriptive Table//////////////

estpost summarize returns returns_rf sd_returns mktcap debtequ revenuepershare currentratio esg esgcomb e s g mktrf SMB HML rf
esttab using DescriptiveTable.rtf, cells("count mean sd min max") noobs append

estpost tab icbindustryname
esttab using DescriptiveTable.rtf,cells("b(label(frequence)) pct(fmt(2)) cumpct(fmt(2))") varlabels(, blist(Total "{hline @width}{break}")) nonumber nomtitle noobs append 

////////////Regressions for entire US market (1-2) A //////////////

//Fama-French 3 Factor

** ESG 

gen dummy_ESGA=0
replace dummy_ESGA=1 if esg>=75

gen dummy_ESGB=0
replace dummy_ESGB=1 if esg<75  & esg>50 

gen dummy_ESGC=0
replace dummy_ESGC=1 if esg<=50 & esg>25

gen dummy_ESGD=0
replace dummy_ESGD=1 if esg<=25

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC, vce(robust)
estimates store r1_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD, vce(robust)
estimates store r2_1

** ESG combined

gen dummy_ESGAA=0
replace dummy_ESGAA=1 if esgcomb>=75

gen dummy_ESGBB=0
replace dummy_ESGBB=1 if esgcomb<75 & esgcomb>50 

gen dummy_ESGCC=0
replace dummy_ESGCC=1 if esgcomb<=50  & esgcomb>25

gen dummy_ESGDD=0
replace dummy_ESGDD=1 if esgcomb<=25 

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC, vce(robust)
estimates store r1_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD, vce(robust)
estimates store r2_2

** E

gen dummy_EA=0
replace dummy_EA=1 if e>=75

gen dummy_EB=0
replace dummy_EB=1 if e<75 & e>50 

gen dummy_EC=0
replace dummy_EC=1 if e<=50  & e>25

gen dummy_ED=0
replace dummy_ED=1 if e<=25

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC, vce(robust)
estimates store r1_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED, vce(robust) 
estimates store r2_3

** S

gen dummy_SA=0
replace dummy_SA=1 if s>=75

gen dummy_SB=0
replace dummy_SB=1 if s<75 & s>50

gen dummy_SC=0
replace dummy_SC=1 if s<=50 & s>25

gen dummy_SD=0
replace dummy_SD=1 if s<=25

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC, vce(robust)
estimates store r1_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD, vce(robust)
estimates store r2_4

** G

gen dummy_GA=0
replace dummy_GA=1 if g>=75

gen dummy_GB=0
replace dummy_GB=1 if g<75 & g>50

gen dummy_GC=0
replace dummy_GC=1 if g<=50 & g>25

gen dummy_GD=0
replace dummy_GD=1 if g<=25

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC, vce(robust)
estimates store r1_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD, vce(robust)
estimates store r2_5

** Final 

esttab r1_1 r1_2 r1_3 r1_4 r1_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r1_1 r1_2 r1_3 r1_4 r1_5 , r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r2_1 r2_2 r2_3 r2_4 r2_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

////Sharpe Ratio & Treynor Ratio

sort identifierric year

by identifierric year: gen SharpeRatio = returns_rf/sd_returns

winsor SharpeRatio, gen(SharpeRatio_w) p(0.01)

drop SharpeRatio

rename SharpeRatio_w SharpeRatio

**Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio,vce(robust)
estimates store ra_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC  mktcap debtequ revenuepershare currentratio, vce(robust)
estimates store ra_2

**STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio, vce(robust)
estimates store ra_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio, vce(robust)
estimates store ra_4

**Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio, vce(robust)
estimates store ra_5

xi: reg returns_rf  dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio, vce(robust)
estimates store ra_6

**Treynor Ratio 

sort identifierric year

by identifierric year: gen TreynorRatio = returns_rf/beta if beta>=0

winsor TreynorRatio, gen(TreynorRatio_w) p(0.01)

drop TreynorRatio

rename TreynorRatio_w TreynorRatio

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio, vce(robust)
estimates store ra_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio, vce(robust)
estimates store ra_8

**Beta

xi: reg beta dummy_ESGA dummy_ESGB dummy_ESGC, vce(robust)

xi: reg beta dummy_ESGA dummy_ESGB dummy_ESGC, vce(robust)

esttab ra_1 ra_2 ra_7 ra_8 ra_3 ra_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab ra_1 ra_2 ra_7 ra_8 ra_3 ra_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg, legend(label(1 ESG)))(qfit returns_rf esgcomb, legend(label(2 ESG Combined))), title("US Market: Excess Returns per ESG Score")
graph export USMarket.pdf,replace

/*
twoway (qfit returns_rf esgcomb), title("US Market: ESG Combined & Excess Returns")
graph export USMarket_ESG.pdf,replace

twoway (qfit returns_rf esgcomb), title("US Market: ESG Combined & Excess Returns")
graph export USMarket_ESGcomb.pdf,replace
*/

////////////Regressions for Basic Materials (3-4) B //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Basic Materials", vce(robust)
estimates store r3_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Basic Materials", vce(robust) 
estimates store r4_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Basic Materials", vce(robust) 
estimates store r3_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Basic Materials", vce(robust) 
estimates store r4_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Basic Materials", vce(robust) 
estimates store r3_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Basic Materials", vce(robust) 
estimates store r4_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Basic Materials", vce(robust) 
estimates store r3_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Basic Materials", vce(robust) 
estimates store r4_4

** S


xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Basic Materials", vce(robust) 
estimates store r3_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Basic Materials", vce(robust) 
estimates store r4_5

** Final 

esttab r3_1 r3_2 r3_3 r3_4 r3_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r3_1 r3_2 r3_3 r3_4 r3_5, r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r4_1 r4_2 r4_3 r4_4 r4_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Basic Materials", vce(robust)
estimates store rb_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Basic Materials", vce(robust)
estimates store rb_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Basic Materials", vce(robust)
estimates store rb_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Basic Materials", vce(robust)
estimates store rb_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Basic Materials", vce(robust)
estimates store rb_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Basic Materials", vce(robust)
estimates store rb_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Basic Materials", vce(robust)
estimates store rb_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Basic Materials", vce(robust)
estimates store rb_8

esttab rb_1 rb_2 rb_7 rb_8 rb_3 rb_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab rb_1 rb_2 rb_7 rb_8 rb_3 rb_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Basic Materials", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Basic Materials", legend(label(2 ESG Combined))), title("Basic Materials: Excess Returns per ESG Score")
graph export BasicMaterials.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Basic Materials"), title("Basic Materials: ESG & Excess Returns")
graph export BasicMaterials_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Basic Materials"), title("Basic Materials: ESG Combined & Excess Returns")
graph export BasicMaterials_ESGcomb.pdf,replace
*/

////////////Regressions for Consumer Discretionary (5-6) C //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Consumer Discretionary", vce(robust)
estimates store r5_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Consumer Discretionary", vce(robust) 
estimates store r6_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Consumer Discretionary", vce(robust) 
estimates store r5_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Consumer Discretionary", vce(robust) 
estimates store r6_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Consumer Discretionary", vce(robust) 
estimates store r5_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Consumer Discretionary", vce(robust) 
estimates store r6_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Consumer Discretionary", vce(robust) 
estimates store r5_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Consumer Discretionary", vce(robust) 
estimates store r6_4

** G

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Consumer Discretionary", vce(robust) 
estimates store r5_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Consumer Discretionary", vce(robust) 
estimates store r6_5

** Final 

esttab r5_1 r5_2 r5_3 r5_4 r5_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r5_1 r5_2 r5_3 r5_4 r5_5, r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r6_1 r6_2 r6_3 r6_4 r6_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Discretionary", vce(robust)
estimates store rc_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Discretionary", vce(robust)
estimates store rc_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Discretionary", vce(robust)
estimates store rc_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Discretionary", vce(robust)
estimates store rc_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Discretionary", vce(robust)
estimates store rc_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Discretionary", vce(robust)
estimates store rc_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Discretionary", vce(robust)
estimates store rc_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Discretionary", vce(robust)
estimates store rc_8

esttab rc_1 rc_2 rc_7 rc_8 rc_3 rc_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab rc_1 rc_2 rc_7 rc_8 rc_3 rc_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Consumer Discretionary", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Consumer Discretionary", legend(label(2 ESG Combined))), title("Consumer Discretionary: Excess Returns per ESG Score")
graph export ConsumerDiscretionary.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Consumer Discretionary"), title("Consumer Discretionary: ESG & Excess Returns")
graph export ConsumerDiscretionary_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Consumer Discretionary"), title("Consumer Discretionary: ESG Combined & Excess Returns")
graph export ConsumerDiscretionary_ESGcomb.pdf,replace
*/

////////////Regressions for Consumer Staples (7-8) D //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Consumer Staples", vce(robust)
estimates store r7_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Consumer Staples", vce(robust) 
estimates store r8_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Consumer Staples", vce(robust) 
estimates store r7_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Consumer Staples", vce(robust) 
estimates store r8_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Consumer Staples", vce(robust) 
estimates store r7_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Consumer Staples", vce(robust) 
estimates store r8_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Consumer Staples", vce(robust) 
estimates store r7_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Consumer Staples", vce(robust) 
estimates store r8_4

** S


xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Consumer Staples", vce(robust) 
estimates store r7_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Consumer Staples", vce(robust) 
estimates store r8_5

** Final 

esttab r7_1 r7_2 r7_3 r7_4 r7_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r7_1 r7_2 r7_3 r7_4 r7_5, r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r8_1 r8_2 r8_3 r8_4 r8_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Staples", vce(robust)
estimates store rd_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Staples", vce(robust)
estimates store rd_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Staples", vce(robust)
estimates store rd_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Staples", vce(robust)
estimates store rd_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Staples", vce(robust)
estimates store rd_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Staples", vce(robust)
estimates store rd_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Staples", vce(robust)
estimates store rd_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Consumer Staples", vce(robust)
estimates store rd_8

esttab rd_1 rd_2 rd_7 rd_8 rd_3 rd_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab rd_1 rd_2 rd_7 rd_8 rd_3 rd_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Consumer Staples", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Consumer Staples", legend(label(2 ESG Combined))), title("Consumer Staples: Excess Returns per ESG Score")
graph export ConsumerStaples.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Consumer Staples"), title("Consumer Staples: ESG & Excess Returns")
graph export ConsumerStaple_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Consumer Staples"), title("Consumer Staples: ESG Combined & Excess Returns")
graph export ConsumerStaple_ESGcomb.pdf,replace
*/

////////////Regressions for Energy (9-10) E //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Energy", vce(robust)
estimates store r9_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Energy", vce(robust) 
estimates store r10_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Energy", vce(robust) 
estimates store r9_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Energy", vce(robust) 
estimates store r10_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Energy", vce(robust) 
estimates store r9_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Energy", vce(robust) 
estimates store r10_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Energy", vce(robust) 
estimates store r9_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Energy", vce(robust) 
estimates store r10_4

** G

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Energy", vce(robust) 
estimates store r9_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Energy", vce(robust) 
estimates store r10_5

** Final 

esttab r9_1 r9_2 r9_3 r9_4 r9_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r9_1 r9_2 r9_3 r9_4 r9_5, r2 se star(* 0.10 ** 0.05 *** 0.01) 
esttab r10_1 r10_2 r10_3 r10_4 r10_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Energy", vce(robust)
estimates store re_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Energy", vce(robust)
estimates store re_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Energy", vce(robust)
estimates store re_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Energy", vce(robust)
estimates store re_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Energy", vce(robust)
estimates store re_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Energy", vce(robust)
estimates store re_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Energy", vce(robust)
estimates store re_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Energy", vce(robust)
estimates store re_8

esttab re_1 re_2 re_7 re_8 re_3 re_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab re_1 re_2 re_7 re_8 re_3 re_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Energy", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Energy", legend(label(2 ESG Combined))), title("Energy: Excess Returns per ESG Score")
graph export Energy.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Energy"), title("Energy: ESG & Excess Returns")
graph export Energy_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Energy"), title("Energy: ESG Combined & Excess Returns")
graph export Energy_ESGcomb.pdf,replace
*/

////////////Regressions for Financials (11-12) F //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Financials", vce(robust)
estimates store r11_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Financials", vce(robust) 
estimates store r12_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Financials", vce(robust) 
estimates store r11_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Financials", vce(robust) 
estimates store r12_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Financials", vce(robust) 
estimates store r11_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Financials", vce(robust) 
estimates store r12_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Financials", vce(robust) 
estimates store r11_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Financials", vce(robust) 
estimates store r12_4

** G

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Financials", vce(robust) 
estimates store r11_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Financials", vce(robust) 
estimates store r12_5

** Final 

esttab r11_1 r11_2 r11_3 r11_4 r11_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r11_1 r11_2 r11_3 r11_4 r11_5, r2 se star(* 0.10 ** 0.05 *** 0.01) 
esttab r12_1 r12_2 r12_3 r12_4 r12_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Financials", vce(robust)
estimates store rf_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Financials", vce(robust)
estimates store rf_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Financials", vce(robust)
estimates store rf_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Financials", vce(robust)
estimates store rf_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Financials", vce(robust)
estimates store rf_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Financials", vce(robust)
estimates store rf_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Financials", vce(robust)
estimates store rf_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Financials", vce(robust)
estimates store rf_8

esttab rf_1 rf_2 rf_7 rf_8 rf_3 rf_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab rf_1 rf_2 rf_7 rf_8 rf_3 rf_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Financials", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Financials", legend(label(2 ESG Combined))), title("Financials: Excess Returns per ESG Score")
graph export Financials.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Financials"), title("Financials: ESG & Excess Returns")
graph export Financials_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Financials"), title("Financials: ESG Combined & Excess Returns")
graph export Financials_ESGcomb.pdf,replace
*/

////////////Regressions for Health Care (13-14) G //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Health Care", vce(robust)
estimates store r13_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Health Care", vce(robust) 
estimates store r14_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Health Care", vce(robust) 
estimates store r13_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Health Care", vce(robust) 
estimates store r14_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Health Care", vce(robust) 
estimates store r13_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Health Care", vce(robust) 
estimates store r14_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Health Care", vce(robust) 
estimates store r13_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Health Care", vce(robust) 
estimates store r14_4

** G

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Health Care", vce(robust) 
estimates store r13_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Health Care", vce(robust) 
estimates store r14_5

** Final 

esttab r13_1 r13_2 r13_3 r13_4 r13_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r13_1 r13_2 r13_3 r13_4 r13_5, r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r14_1 r14_2 r14_3 r14_4 r14_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Health Care", vce(robust)
estimates store rg_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Health Care", vce(robust)
estimates store rg_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Health Care", vce(robust)
estimates store rg_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Health Care", vce(robust)
estimates store rg_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Health Care", vce(robust)
estimates store rg_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Health Care", vce(robust)
estimates store rg_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Health Care", vce(robust)
estimates store rg_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Health Care", vce(robust)
estimates store rg_8


esttab rg_1 rg_2 rg_7 rg_8 rg_3 rg_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab rg_1 rg_2 rg_7 rg_8 rg_3 rg_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Health Care", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Health Care", legend(label(2 ESG Combined))), title("Health Care: Excess Returns per ESG Score")
graph export HealthCare.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Health Care"), title("Health Care: ESG & Excess Returns")
graph export HealthCare_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Health Care"), title("Health Care: ESG Combined & Excess Returns")
graph export HealthCare_ESGcomb.pdf,replace
*/

////////////Regressions for Industrials (15-16) H //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Industrials", vce(robust)
estimates store r15_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Industrials", vce(robust) 
estimates store r16_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Industrials", vce(robust) 
estimates store r15_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Industrials", vce(robust) 
estimates store r16_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Industrials", vce(robust) 
estimates store r15_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Industrials", vce(robust) 
estimates store r16_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Industrials", vce(robust) 
estimates store r15_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Industrials", vce(robust) 
estimates store r16_4

** G

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Industrials", vce(robust) 
estimates store r15_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Industrials", vce(robust) 
estimates store r16_5

** Final 

esttab r15_1 r15_2 r15_3 r15_4 r15_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r15_1 r15_2 r15_3 r15_4 r15_5, r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r16_1 r16_2 r16_3 r16_4 r16_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Industrials", vce(robust)
estimates store rh_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Industrials", vce(robust)
estimates store rh_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Industrials", vce(robust)
estimates store rh_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Industrials", vce(robust)
estimates store rh_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Industrials", vce(robust)
estimates store rh_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Industrials", vce(robust)
estimates store rh_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Industrials", vce(robust)
estimates store rh_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Industrials", vce(robust)
estimates store rh_8

esttab rh_1 rh_2 rh_7 rh_8 rh_3 rh_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab rh_1 rh_2 rh_7 rh_8 rh_3 rh_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Industrials", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Industrials", legend(label(2 ESG Combined))), title("Industrials: Excess Returns per ESG Score")
graph export Industrials.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Industrials"), title("Industrials: ESG & Excess Returns")
graph export Industrials_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Industrials"), title("Industrials: ESG Combined & Excess Returns")
graph export Industrials_ESGcomb.pdf,replace
*/

////////////Regressions for Real Estate (17-18) I //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Real Estate", vce(robust)
estimates store r17_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Real Estate", vce(robust) 
estimates store r18_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Real Estate", vce(robust) 
estimates store r17_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Real Estate", vce(robust) 
estimates store r18_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Real Estate", vce(robust) 
estimates store r17_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Real Estate", vce(robust) 
estimates store r18_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Real Estate", vce(robust) 
estimates store r17_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Real Estate", vce(robust) 
estimates store r18_4

** G

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Real Estate", vce(robust) 
estimates store r17_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Real Estate", vce(robust) 
estimates store r18_5

** Final 

esttab r17_1 r17_2 r17_3 r17_4 r17_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r17_1 r17_2 r17_3 r17_4 r17_5, r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r18_1 r18_2 r18_3 r18_4 r18_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Real Estate", vce(robust)
estimates store ri_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Real Estate", vce(robust)
estimates store ri_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Real Estate", vce(robust)
estimates store ri_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Real Estate", vce(robust)
estimates store ri_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Real Estate", vce(robust)
estimates store ri_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Real Estate", vce(robust)
estimates store ri_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Real Estate", vce(robust)
estimates store ri_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Real Estate", vce(robust)
estimates store ri_8

esttab ri_1 ri_2 ri_7 ri_8 ri_3 ri_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab ri_1 ri_2 ri_7 ri_8 ri_3 ri_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Real Estate", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Real Estate", legend(label(2 ESG Combined))), title("Real Estate: Excess Returns per ESG Score")
graph export RealEstate.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Real Estate"), title("Real Estate: ESG & Excess Returns")
graph export RealEstate_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Real Estate"), title("Real Estate: ESG Combined & Excess Returns")
graph export RealEstate_ESGcomb.pdf,replace
*/

////////////Regressions for Technology (19-20) J //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Technology", vce(robust)
estimates store r19_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Technology", vce(robust) 
estimates store r20_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Technology", vce(robust) 
estimates store r19_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Technology", vce(robust) 
estimates store r20_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Technology", vce(robust) 
estimates store r19_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Technology", vce(robust) 
estimates store r20_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Technology", vce(robust) 
estimates store r19_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Technology", vce(robust) 
estimates store r20_4

** G

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Technology", vce(robust) 
estimates store r19_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Technology", vce(robust) 
estimates store r20_5

** Final 

esttab r19_1 r19_2 r19_3 r19_4 r19_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r19_1 r19_2 r19_3 r19_4 r19_5, r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r20_1 r20_2 r20_3 r20_4 r20_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Technology", vce(robust)
estimates store rj_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Technology", vce(robust)
estimates store rj_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Technology", vce(robust)
estimates store rj_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Technology", vce(robust)
estimates store rj_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname== "Technology", vce(robust)
estimates store rj_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Technology", vce(robust)
estimates store rj_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Technology", vce(robust)
estimates store rj_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Technology", vce(robust)
estimates store rj_8

esttab rj_1 rj_2 rj_7 rj_8 rj_3 rj_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab rj_1 rj_2 rj_7 rj_8 rj_3 rj_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Technology", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Technology", legend(label(2 ESG Combined))), title("Technology: Excess Returns per ESG Score")
graph export Technology.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Technology"), title("Technology: ESG & Excess Returns")
graph export Technology_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Technology"), title("Technology: ESG Combined & Excess Returns")
graph export Technology_ESGcomb.pdf,replace
*/

////////////Regressions for Telecommunications (21-22) K //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Telecommunications", vce(robust)
estimates store r21_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Telecommunications", vce(robust) 
estimates store r22_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Telecommunications", vce(robust) 
estimates store r21_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Telecommunications", vce(robust) 
estimates store r22_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Telecommunications", vce(robust) 
estimates store r21_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Telecommunications", vce(robust) 
estimates store r22_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Telecommunications", vce(robust) 
estimates store r21_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Telecommunications", vce(robust) 
estimates store r22_4

** G

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Telecommunications", vce(robust) 
estimates store r21_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Telecommunications", vce(robust) 
estimates store r22_5

** Final 

esttab r21_1 r21_2 r21_3 r21_4 r21_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r21_1 r21_2 r21_3 r21_4 r21_5, r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r22_1 r22_2 r22_3 r22_4 r22_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Telecommunications", vce(robust)
estimates store rk_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Telecommunications", vce(robust)
estimates store rk_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Telecommunications", vce(robust)
estimates store rk_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Telecommunications", vce(robust)
estimates store rk_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname== "Telecommunications", vce(robust)
estimates store rk_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Telecommunications", vce(robust)
estimates store rk_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Telecommunications", vce(robust)
estimates store rk_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Telecommunications", vce(robust)
estimates store rk_8

esttab rk_1 rk_2 rk_7 rk_8 rk_3 rk_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab rk_1 rk_2 rk_7 rk_8 rk_3 rk_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Telecommunications", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Telecommunications", legend(label(2 ESG Combined))), title("Telecommunications: Excess Returns per ESG Score")
graph export Telecommunications.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Telecommunications"), title("Telecommunications: ESG & Excess Returns")
graph export Telecommunications_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Telecommunications"), title("Telecommunications: ESG Combined & Excess Returns")
graph export Telecommunications_ESGcomb.pdf,replace
*/

////////////Regressions for Utilities (23-24) L //////////////

//Fama-French 3 Factor

** ESG 

xi: reg returns_rf mktrf SMB HML dummy_ESGA dummy_ESGB dummy_ESGC if icbindustryname=="Utilities", vce(robust)
estimates store r23_1

xi: reg returns_rf mktrf SMB HML dummy_ESGB dummy_ESGC dummy_ESGD if icbindustryname=="Utilities", vce(robust) 
estimates store r24_1

** ESG combined

xi: reg returns_rf mktrf SMB HML dummy_ESGAA dummy_ESGBB dummy_ESGCC if icbindustryname=="Utilities", vce(robust) 
estimates store r23_2

xi: reg returns_rf mktrf SMB HML dummy_ESGBB dummy_ESGCC dummy_ESGDD if icbindustryname=="Utilities", vce(robust) 
estimates store r24_2

** E

xi: reg returns_rf mktrf SMB HML dummy_EA dummy_EB dummy_EC if icbindustryname=="Utilities", vce(robust) 
estimates store r23_3

xi: reg returns_rf mktrf SMB HML dummy_EB dummy_EC dummy_ED if icbindustryname=="Utilities", vce(robust) 
estimates store r24_3

** S

xi: reg returns_rf mktrf SMB HML dummy_SA dummy_SB dummy_SC if icbindustryname=="Utilities", vce(robust) 
estimates store r23_4

xi: reg returns_rf mktrf SMB HML dummy_SB dummy_SC dummy_SD if icbindustryname=="Utilities", vce(robust) 
estimates store r24_4

** G

xi: reg returns_rf mktrf SMB HML dummy_GA dummy_GB dummy_GC if icbindustryname=="Utilities", vce(robust) 
estimates store r23_5

xi: reg returns_rf mktrf SMB HML dummy_GB dummy_GC dummy_GD if icbindustryname=="Utilities", vce(robust) 
estimates store r24_5

** Final 

esttab r23_1 r23_2 r23_3 r23_4 r23_5 using FF_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(8)
esttab r23_1 r23_2 r23_3 r23_4 r23_5, r2 se star(* 0.10 ** 0.05 *** 0.01)
esttab r24_1 r24_2 r24_3 r24_4 r24_5, r2 se star(* 0.10 ** 0.05 *** 0.01)

//Sharpe Ratio

xi: reg SharpeRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Utilities", vce(robust)
estimates store rl_1

xi: reg SharpeRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Utilities", vce(robust)
estimates store rl_2

** STD regression

xi: xtreg sd_returns i.year dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Utilities", vce(robust)
estimates store rl_3

xi: xtreg sd_returns i.year dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Utilities", vce(robust)
estimates store rl_4

** Average returns-rf

xi: reg returns_rf dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname== "Utilities", vce(robust)
estimates store rl_5

xi: reg returns_rf dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Utilities", vce(robust)
estimates store rl_6

**Treynor Ratio 

xi: reg TreynorRatio dummy_ESGA dummy_ESGB dummy_ESGC mktcap debtequ revenuepershare currentratio if icbindustryname=="Utilities", vce(robust)
estimates store rl_7

xi: reg TreynorRatio dummy_ESGAA dummy_ESGBB dummy_ESGCC mktcap debtequ revenuepershare currentratio if icbindustryname=="Utilities", vce(robust)
estimates store rl_8

esttab rl_1 rl_2 rl_7 rl_8 rl_3 rl_4 using SR_Estimations.rtf, r2 se star(* 0.10 ** 0.05 *** 0.01) append modelwidth(6)
esttab rl_1 rl_2 rl_7 rl_8 rl_3 rl_4, r2 se star(* 0.10 ** 0.05 *** 0.01)

** Graph

twoway (qfit returns_rf esg if icbindustryname=="Utilities", legend(label(1 ESG)))(qfit returns_rf esgcomb if icbindustryname=="Utilities", legend(label(2 ESG Combined))), title("Utilities: Excess Returns per ESG Score")
graph export Utilities.pdf,replace

/*
twoway (qfit returns_rf esg if icbindustryname=="Utilities"), title("Utilities: ESG & Excess Returns")
graph export Utilities_ESG.pdf,replace

twoway (qfit returns_rf esgcomb if icbindustryname=="Utilities"), title("Utilities: ESG Combined & Excess Returns")
graph export Utilities_ESGcomb.pdf,replace
*/
