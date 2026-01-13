clear all
use replication_dataset


/*Generate a continous time variable to identify different sub-samples the full dataset*/
gen time = _n

/*Identify the dataset as timeseries*/
tsset time

/*Line Chart for Official Exchange Rate & Exchange Rate in Parallel Market*/
/*Figure 1*/
 twoway(tsline fxp official_fx if time >= 2848 & time <= 3178), ytitle("EGP/USD", angle(90)) xlabel(2848 "JAN23" 2888 "MAR23" 2925 "MAY23" 2965 "JUL23" 3007 "SEP23" 3047 "NOV23" 3090 "JAN24" 3131 "MAR24" 3169 "MAY24", angle(90)) xtitle("") 
 

		   
   twoway ///
    (tsline fxp official_fx if time >= 2848 & time <= 3178), ///
    ytitle("EGP/USD", angle(90) margin(r=8)) ///
    xlabel(2848 "JAN23" 2888 "MAR23" 2925 "MAY23" 2965 "JUL23" ///
           3007 "SEP23" 3047 "NOV23" 3090 "JAN24" 3131 "MAR24" 3169 "MAY24", ///
           angle(90) nogrid) ///
    ylabel(, nogrid) ///
    xtitle("") ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
    legend(order(1 "ER in the parallel market" ///
                 2 "ER in the official market") ///
           position(11) ring(0) cols(1) ///
           region(lcolor(none) fcolor(none)))
		   
graph export "ero_erp_chart.png", width(2000) replace

/*Summary Statistics*/
/*Table 1*/
summarize  interbank_ovn egx30 t3m t6m t1y t5y t10y official_fx fxp

estpost summarize interbank_ovn egx30 t3m t6m t1y t5y t10y official_fx fxp

esttab using "summary_stats.tex", ///
    cells("count(fmt(2)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    booktabs ///
    label ///
    noobs ///
    nonumber ///
    replace


/*Generate dummy variable for different sub-samples*/
gen period =.
replace period = 1 if time < 1347
replace period = 2 if time >= 1347 & time < 2641
replace period = 3 if time >= 2641

/*Generate differenced variables for indpendant variables*/
gen d_official_fx = D.official_fx
gen d_interbank_ovn = D.interbank_ovn


/*Generate differences for dependant variables*/

gen ln_egx = ln(egx30)*100
gen d_egx = D.ln_egx
gen d_t3m = D.t3m
gen d_t6m = D.t6m
gen d_t1y = D.t1y
gen d_t5y = D.t5y
gen d_t10y = D.t10y
gen d_fxp = D.fxp


/* Generating variables with 2 days window (using 2 leads)*/

gen d_official_fx_2lead = F2.official_fx - official_fx
gen d_interbank_ovn_2lead = F2.interbank_ovn - interbank_ovn

gen d_egx_2lead = F2.ln_egx - ln_egx
gen d_t3m_2lead = F2.t3m - t3m
gen d_t6m_2lead = F2.t6m - t6m
gen d_t1y_2lead = F2.t1y - t1y
gen d_t5y_2lead = F2.t5y - t5y
gen d_t10y_2lead = F2.t10y - t10y


/* Generating variables with 4 days window (using 4 leads)*/
gen d_official_fx_4lead = F4.official_fx - official_fx
gen d_interbank_ovn_4lead = F4.interbank_ovn - interbank_ovn

gen d_egx_4lead = F4.ln_egx - ln_egx
gen d_t3m_4lead = F4.t3m - t3m
gen d_t6m_4lead = F4.t6m - t6m
gen d_t1y_4lead = F4.t1y - t1y
gen d_t5y_4lead = F4.t5y - t5y
gen d_t10y_4lead = F4.t10y - t10y


/******************************************************************************/
/******************************************************************************/
/********BELOW ARE THE COMMANDS FOR ESTIMATING THE BASELINE MODEL**************/
/*********************2 DAYS WINDOW OF ESTIMATION******************************/
/*********************USING 2 LEADS FOR ALL VARIABLES *************************/
/******************************************************************************/
/******************************************************************************/

/***********************************/
/**Estimation for the stock market**/
/***********Table 2******************/
/***********************************/
eststo clear
quietly reg d_egx_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_egx_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_egx_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_egx_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) nocons nonumber mlabels("Full Sample" "Pegged Phase" "Controlled Floatation" "War Phase") collabels(,none) title("Table 2: Estimated effects of changes in the exchange rate and the interbank overnight rate on the stock market index") nonotes


/***********************************/
/*Estimation for the 3 month yields*/
/***********Table 3******************/
/***********************************/
eststo clear
quietly reg d_t3m_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t3m_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t3m_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t3m_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table 3: T3M") nonotes

/***********************************/
/*Estimation for the 6 month yields*/
/***********Table 3******************/
/***********************************/
eststo clear
quietly reg d_t6m_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t6m_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t6m_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t6m_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table 3: T6M") nonotes

/***********************************/
/*Estimation for the 1 year yields*/
/***********Table 3******************/
/***********************************/
eststo clear
quietly reg d_t1y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t1y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t1y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t1y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table 3: T12M") nonotes

/***********************************/
/*Estimation for the 5 year yields*/
/***********Table 4******************/
/***********************************/
eststo clear
quietly reg d_t5y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t5y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t5y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t5y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.3f) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table 4: T5Y") nonotes

/***********************************/
/*Estimation for the 10 year yields*/
/***********Table 4******************/
/***********************************/
eststo clear
quietly reg d_t10y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t10y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t10y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t10y_2lead d_official_fx_2lead d_interbank_ovn_2lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.3f) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table 4: T10Y") nonotes

/*****************************/
/*Estimations for the black market*/
/***********Table 5******************/
/************************************/


/*Estimation for the black market based on differenced ln levels of parallel market rates*/
  eststo clear
 /*Y_t = b_0 + b_1 Y_{t-1} + b_2 X_1t + b_3 X_2t*/
  reg d_egx L.d_egx d_fxp d_interbank_ovn if time  >= 2848 & time < 3133
 esttab,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) cons label title("Table 5") nonotes

 
 /*Table A.8:Results of the serial correlation test*/
*predict res, residuals
*tsline res
estat bgodfrey, lag(1) /* P-value = 0.4076, hence, there is no serial autocorrelation*/
 
 esttab,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.3f) r2(%9.2f) cons label nonotes

/////////******************************************///////////////




/******************************************************************************/
/******************************************************************************/
/******BELOW ARE THE COMMANDS FOR ESTIMATING THE ROBUSTNESS MODEL**************/
/***************************FOUND IN APPENDICIES******************************/
/*********************4 DAYS WINDOW OF ESTIMATION******************************/
/*********************USING 4 LEADS FOR ALL VARIABLES *************************/
/******************************************************************************/
/******************************************************************************/


/***********************************/
/**Estimation for the stock market**/
/***********Table A.2****************/
/***********************************/
eststo clear
quietly reg d_egx_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_egx_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_egx_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_egx_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table A.2: Estimation for Stock Market Index") nonotes

/***********************************/
/*Estimation for the 3 month yields*/
/***********Table A.3****************/
/***********************************/
eststo clear
quietly reg d_t3m_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t3m_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t3m_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t3m_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table A.3: T3M") nonotes

/***********************************/
/*Estimation for the 6 month yields*/
/***********Table A.3****************/
/***********************************/
eststo clear
quietly reg d_t6m_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t6m_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t6m_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t6m_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table A.3: T6M") nonotes

/***********************************/
/*Estimation for the 1 year yields*/
/***********Table A.3****************/
/***********************************/
eststo clear
quietly reg d_t1y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t1y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t1y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t1y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table A.3: T12M") nonotes


/***********************************/
/*Estimation for the 5 year yields*/
/***********Table A.4****************/
/***********************************/
eststo clear
quietly reg d_t5y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t5y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t5y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t5y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table A.4 T5Y") nonotes

/***********************************/
/*Estimation for the 10 year yields*/
/***********Table A.4***************/
/***********************************/
eststo clear
quietly reg d_t10y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1
eststo whole_sample

quietly reg d_t10y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 1
eststo pegged_phase

quietly reg d_t10y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 2
eststo controlled_flotation

quietly reg d_t10y_4lead d_official_fx_4lead d_interbank_ovn_4lead if mpc_meeting == 1 & period == 3
eststo war_phase

esttab whole_sample pegged_phase controlled_flotation war_phase,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2) r2(%9.2f) nocons mlabels("Whole_Sample" "Pegged_Phase" "Controlled_Floatation" "War_Phase") collabels(,none) title("Table A.4 T10Y") nonotes

/*******************************************************************************/
/*******************************************************************************/
/*******************************************************************************/
/************Estimations with Dummy Variables for the Full Sample***************/
/*********************           DUMMY VARIABLES        ************************/
/*******************************************************************************/
/*******************************************************************************/
/*******************************************************************************/


/*2 days window */
/*Table A.5*/

eststo clear
quietly reg d_egx_2lead d_official_fx_2lead d_interbank_ovn_2lead i.period if mpc_meeting == 1
eststo whole_sample_egx
quietly reg d_t3m_2lead d_official_fx_2lead d_interbank_ovn_2lead i.period if mpc_meeting == 1
eststo whole_sample_t3m
quietly reg d_t6m_2lead d_official_fx_2lead d_interbank_ovn_2lead i.period if mpc_meeting == 1
eststo whole_sample_t6m
quietly reg d_t1y_2lead d_official_fx_2lead d_interbank_ovn_2lead i.period if mpc_meeting == 1
eststo whole_sample_t1y
quietly reg d_t5y_2lead d_official_fx_2lead d_interbank_ovn_2lead i.period if mpc_meeting == 1
eststo whole_sample_t5y
quietly reg d_t10y_2lead d_official_fx_2lead d_interbank_ovn_2lead i.period if mpc_meeting == 1
eststo whole_sample_t10y

esttab whole_sample_egx whole_sample_t3m whole_sample_t6m whole_sample_t1y whole_sample_t5y whole_sample_t10y,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) cons mlabels("EGX30" "T3M" "T6M" "T1Y" "T5Y" "T10Y") collabels(,none) title("Table A.5: Estimated effects of changes in the exchange rate and the {break} interbank overnight rate on the financial variables, based on an event window of two business days") nonotes

/*4 days window*/
/*Table A.6*/
eststo clear
quietly reg d_egx_4lead d_official_fx_4lead d_interbank_ovn_4lead i.period if mpc_meeting == 1
eststo whole_sample_egx
quietly reg d_t3m_4lead d_official_fx_4lead d_interbank_ovn_4lead i.period if mpc_meeting == 1
eststo whole_sample_t3m
quietly reg d_t6m_4lead d_official_fx_4lead d_interbank_ovn_4lead i.period if mpc_meeting == 1
eststo whole_sample_t6m
quietly reg d_t1y_4lead d_official_fx_4lead d_interbank_ovn_4lead i.period if mpc_meeting == 1
eststo whole_sample_t1y
quietly reg d_t5y_4lead d_official_fx_4lead d_interbank_ovn_4lead i.period if mpc_meeting == 1
eststo whole_sample_t5y
quietly reg d_t10y_4lead d_official_fx_4lead d_interbank_ovn_4lead i.period if mpc_meeting == 1
eststo whole_sample_t10y

esttab whole_sample_egx whole_sample_t3m whole_sample_t6m whole_sample_t1y whole_sample_t5y whole_sample_t10y,  star(* 0.10 ** 0.05 *** 0.01) b(%9.2f) t(%9.2f) r2(%9.2f) cons mlabels("EGX30" "T3M" "T6M" "T1Y" "T5Y" "T10Y") collabels(,none) title("Table A.6: Estimated effects of changes in the exchange rate and the {break} interbank overnight rate on the financial variables, based on an event window of four business days") nonotes

/**********************************************/
/**********************************************/
/**********************************************/


/*Figure A.1: Dynamics of the variables*/
/* Generating Time Series Line Charts for all variables */

graph drop _all

tsline official_fx, lcolor(ebblue) name(g1)  ytitle("EGP/USD") ylabel(, angle(0) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) xlabel(0 "2011" 484 "2013" 955 "2015" 1387 "2017" 1874 "2019" 2360 "2021" 2848 "2023", angle(90) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) title("Official Exchange Rate", size(small)) xtitle("") , graphregion(color(white)) plotregion(color(white)) 


tsline interbank_ovn, lcolor(ebblue) name(g2) xlabel(0 "2011" 484 "2013" 955 "2015" 1387 "2017" 1874 "2019" 2360 "2021" 2848 "2023", angle(90) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) title("Interbank Overnight Rate", size(small)) xtitle("") ytitle(%) ylabel(, angle(0) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) , graphregion(color(white)) plotregion(color(white))

tsline fxp if time >2848, lcolor(ebblue) name(g9) , ytitle("EGPp/USD", angle(90)) xlabel(2848 "JAN23" 2888 "MAR23" 2925 "MAY23" 2965 "JUL23" 3007 "SEP23" 3047 "NOV23" 3090 "JAN24" 3131 "MAR24" 3169 "MAY24", angle(90) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) xtitle("") title(" Parallel Market Exchange Rate", size(small)) ylabel(, angle(0) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) , graphregion(color(white)) plotregion(color(white))

tsline egx30, lcolor(ebblue) name(g3) xlabel(0 "2011" 484 "2013" 955 "2015" 1387 "2017" 1874 "2019" 2360 "2021" 2848 "2023", angle(90) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) title("Stock Market Index", size(small)) xtitle("") ytitle(%) ylabel(, angle(0) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) , graphregion(color(white)) plotregion(color(white))

tsline t3m, lcolor(ebblue) name(g4) xlabel(0 "2011" 484 "2013" 955 "2015" 1387 "2017" 1874 "2019" 2360 "2021" 2848 "2023", angle(90) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) xtitle("") title("3-Month Treasury Yields", size(small)) ytitle(%) ylabel(, angle(0) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) , graphregion(color(white)) plotregion(color(white))
 
tsline t6m, lcolor(ebblue) name(g5) xlabel(0 "2011" 484 "2013" 955 "2015" 1387 "2017" 1874 "2019" 2360 "2021" 2848 "2023", angle(90) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) xtitle("") title("6-Month Treasury Yields", size(small)) ytitle(%) ylabel(, angle(0) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) , graphregion(color(white)) plotregion(color(white))

tsline t1y, lcolor(ebblue) name(g6) xlabel(0 "2011" 484 "2013" 955 "2015" 1387 "2017" 1874 "2019" 2360 "2021" 2848 "2023", angle(90) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) xtitle("") title("1-Year Treasury Yields", size(small)) ytitle(%) ylabel(, angle(0) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) , graphregion(color(white)) plotregion(color(white))

tsline t5y, lcolor(ebblue) name(g7) xlabel(0 "2011" 484 "2013" 955 "2015" 1387 "2017" 1874 "2019" 2360 "2021" 2848 "2023", angle(90) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) xtitle("") title("5-Year Treasury Yields", size(small)) ytitle(%) ylabel(, angle(0) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) , graphregion(color(white)) plotregion(color(white))

tsline t10y, lcolor(ebblue) name(g8) xlabel(0 "2011" 484 "2013" 955 "2015" 1387 "2017" 1874 "2019" 2360 "2021" 2848 "2023", angle(90) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) xtitle("") title("10-Year Treasury Yields", size(small)) ytitle(%) ylabel(, angle(0) grid glcolor(gs14) glwidth(vthin) glpattern(solid)) , graphregion(color(white)) plotregion(color(white))

graph combine g1 g2 g3 g4 g5 g6 g7 g8 g9		   

graph export "timeseries.png", width(2000) replace



