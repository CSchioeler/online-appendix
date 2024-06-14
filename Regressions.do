* Main Regressions
log close
clear all
* cd directory here
global base "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions"

* Global

global Output_data	"code_tables_results\Data"
global Results		"code_tables_results\results"
global Do_files     "code_tables_results\Do"
global Shape_files  "code_tables_results\shape files"

cd "$base"

* Create Spatial Conflict Lags
log using "$Results\Spatial_Regressions_denlyrep.log", replace

use "$Output_data\matched_grd_xsub_withlags.dta", clear

* Rename _merge
rename _merge _merge_lags

* Create spatially lagged dummy conflict variable
gen ACTION_ANY_M = .
gen ACTION_DIR_M = .
gen ACTION_IND_M = .
gen ACTION_PRT_M = .

* Fill in the values
replace ACTION_ANY_M = 1 if ACTION_ANY_xS > 0 & ACTION_ANY_xS ~= .
replace ACTION_ANY_M = 0 if ACTION_ANY_xS == 0 & ACTION_ANY_M ~= .

replace ACTION_DIR_M = 1 if ACTION_DIR_xS > 0 & ACTION_DIR_xS ~= .
replace ACTION_DIR_M = 0 if ACTION_DIR_xS == 0 & ACTION_DIR_M ~= .

replace ACTION_IND_M = 1 if ACTION_IND_xS > 0 & ACTION_IND_xS ~= .
replace ACTION_IND_M = 0 if ACTION_IND_xS == 0 & ACTION_IND_M ~= .

replace ACTION_PRT_M = 1 if ACTION_PRT_xS > 0 & ACTION_PRT_xS ~= .
replace ACTION_PRT_M = 0 if ACTION_PRT_xS == 0 & ACTION_PRT_M ~= .

* set the panel variable
xtset gid year

* Create 1-period lags of conflict variables
sort gid year
gen ACTION_ANY_M1 = L.ACTION_ANY_M
gen ACTION_DIR_M1 = L.ACTION_DIR_M
gen ACTION_IND_M1 = L.ACTION_IND_M
gen ACTION_PRT_M1 = L.ACTION_PRT_M

*------------------------------------------------------------
* Replicate Denly exact specifications
*------------------------------------------------------------

tab acled 
tab attacksged

gen ucdpdum = attacksged
replace ucdpdum = 1 if attacksged > 0 & attacksged ~= .

* set the panel variable
xtset gid year

*create a spatially lagged DV
gen acled_M = .
replace acled_M = 1 if attacksacled_M > 0 & attacksacled_M ~= .
replace acled_M = 0 if attacksacled_M == 0 & attacksacled_M ~= .

gen acled_M1 = L.acled_M

* Label variables as in Denly to compare
label var lag1logwd_ann_val_loc2 "Natural Resource Value in Cell (Time Lag/Log)"
label var logwd_ann_val_loc2_M "Resources 1st Order Spatial Lag"
label var logwd_ann_val_loc2_M2 "Resources 2nd Order Spatial Lag"
label var lootable_ever "Presence of Lootable Resources"
label var excluded "Number of Excluded Ethnic Groups"
label var nlights_calib_mean "Nighttime Lights"
label var v2x_polyarchy "V-Dem Democracy Index"
label var popd_mean "Mean Population Density"
label var acled_M1 "Spatially Lagged Conflict Measure"

* Table 4, Model 1: Acled conflict<--lag, log value w/no controls, SS africa only
preserve
keep if region_wb=="africa"
eststo: my_reg2hdfespatial acled lag1logwd_ann_val_loc2  , ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum acled lag1logwd_ann_val_loc2
restore

* Table 4, Model 2: Acled conflict<--lag, log value w / controls, SS africa only
* Summary data reported in Appendix Table A1
preserve
keep if region_wb=="africa"
eststo: my_reg2hdfespatial acled lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum acled lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1
restore

* Table 4, Model 3: Acled conflict<--instrumented lag log values w/no controls, SS africa only
preserve
keep if region_wb=="africa"
xtset gid cy
eststo: xtivreg acled (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum acled loglocal_value lag1instrument
restore

* Table 4, Model 4: Acled conflict<--instrumented lag log  values w / controls, SS africa only
* Summary data reported in Appendix Table A1
preserve
keep if region_wb=="africa"
xtset gid cy
eststo: xtivreg acled (loglocal_value = lag1instrument)  logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
 v2x_polyarchy acled_M1, fe  vce(cluster gid)
estpost sum acled loglocal_value lag1instrument logwd_ann_val_loc2_M /// 
logwd_ann_val_loc2_M2 excluded nlights_calib_mean v2x_polyarchy  acled_M1
restore

* get the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_ACLED_SSA_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for ACLED Outcome on SSA (Three-Way Fixed Effects)) se tex label
eststo clear 

* Presuming that the data is already loaded and necessary packages are installed
* Table with population density included
* Model 1: Acled conflict <– lag, log value w / controls, SSA only (including pop density)
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial acled lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Model 2: Acled conflict <– instrumented lag log values w / controls, SSA only (including pop density)
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg acled (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, fe vce(cluster gid)
restore

* Generate the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_ACLED_SSA_Controls_with_PopDensity.tex", replace mtitles("Model 1" "Model 2") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for ACLED Outcome on SSA (Including Population Density)) se tex label
eststo clear

log close

********************************************************************************
****SUB-SAHARAN AFRICA WITH UCDP DUMMY****
*note, excluding population density from these controls models because too 
* many observations drop. but then models follow with it in so we can check

* Table 5, Model 1: Ucdp ged conflict<--lag, log value w/no controls, SS africa only
preserve
keep if region_wb=="africa"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2  , ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Table 5, Model 2: Ucdp ged conflict<--lag, log value w / controls, SS africa only
preserve
keep if region_wb=="africa"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

****INSTRUMENT SUB SAHARAN AFRICA WITH UCDP DUMMY****
* Table 5, Model 3: Ucdp conflict<--instrumented lag log values w/no controls, SS africa
preserve
keep if region_wb=="africa"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument), fe vce(cluster gid)
restore

* Table 5, Model 4: Ucdp conflict<--instrumented lag log  values w / controls, SS africa only
preserve
keep if region_wb=="africa"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument)  logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, fe  vce(cluster gid)
restore

* get the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_UCDP_SSA-Sample_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for UCDP Outcome on SSA (Three-Way Fixed Effects)) se tex label
eststo clear

* Presuming that the data is already loaded and necessary packages are installed
* Model 1: Ucdp ged conflict <– lag, log value w / controls, SSA only (including pop density)
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Model 2: Ucdp conflict <– instrumented lag log values w / controls, SSA only (including pop density)
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, fe vce(cluster gid)
restore

* Generate the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_UCDP_SSA_Controls_with_PopDensity.tex", replace mtitles("Model 1" "Model 2") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for UCDP Outcome on SSA (Including Population Density)) se tex label
eststo clear


****SUB-SAHARAN AFRICA & NORTH AFRICA WITH ACLED DUMMY****
*note, excluding population density from these controls models because too 
* many observations drop. but then models follow with it in so we can check

* Table A2, Model 1: Acled conflict<--lag, log value w/no controls, all africa only
preserve
keep if continent1=="africa"
eststo: my_reg2hdfespatial acled lag1logwd_ann_val_loc2  , ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estimates store B
restore

* Table A2, Model 2: Acled conflict<--lag, log value w / controls, all africa only
preserve
keep if continent1=="africa"
eststo: my_reg2hdfespatial acled lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy  acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore


* Table A2, Model 3: Acled conflict<--instrumented lag log values w/no controls, all africa only
preserve
keep if continent1=="africa"
xtset gid cy
eststo: xtivreg acled (loglocal_value = lag1instrument), fe vce(cluster gid)
restore


* Table A2, Model 4: Acled conflict<--instrumented lag log  values w / controls, all africa only
preserve
keep if continent1=="africa"
xtset gid cy
eststo: xtivreg acled (loglocal_value = lag1instrument)  logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy  acled_M1, fe  vce(cluster gid)
restore


* get the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_ACLED_SSA-NA_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for ACLED Outcome on SSA and NA (Three-Way Fixed Effects)) se tex label
eststo clear

* Presuming that the data is already loaded and necessary packages are installed

* Model 1: Acled conflict <– lag, log value w / controls, all Africa only (including pop density)
preserve
keep if continent1 == "africa"
eststo: my_reg2hdfespatial acled lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Model 2: Acled conflict <– instrumented lag log values w / controls, all Africa only (including pop density)
preserve
keep if continent1 == "africa"
xtset gid cy
eststo: xtivreg acled (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy acled_M1, fe vce(cluster gid)
restore

* Generate the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_ACLED_SSA-NA_Controls_with_PopDensity.tex", replace mtitles("Model 1" "Model 2") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for ACLED Outcome on All Africa (Including Population Density)) se tex label
eststo clear


********************************************************************************
****SUB-SAHARAN & NORTH AFRICA WITH UCDP DUMMY****
*note, excluding population density from these controls models because too 
* many observations drop. but then models follow with it in so we can check

* Table A3, Model 1: Ucdp ged conflict<--lag, log value w/no controls, all africa only
preserve
keep if continent1=="africa"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2  , ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Table A3, Model 2: Ucdp ged conflict<--lag, log value w / controls, all africa only
preserve
keep if continent1=="africa"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

****INSTRUMENT SUB SAHARAN & NORTH AFRICA WITH UCDP DUMMY****
* Table A3, Model 3: Ucdp conflict<--instrumented lag log values w/no controls, all africa
preserve
keep if continent1=="africa"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument), fe vce(cluster gid)
restore

* Table A3, Model 4: Ucdp conflict<--instrumented lag log  values w / controls, all africa
preserve
keep if continent1=="africa"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument)  logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, fe  vce(cluster gid)
restore

* get the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_UCDP_SSA-NA-Sample_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for UCDP Outcome on SSA NA (Three-Way Fixed Effects)) se tex label
eststo clear

* Presuming that the data is already loaded and necessary packages are installed

* Model 1: UCDP GED conflict <– lag, log value w / controls, all Africa only (including pop density)
preserve
keep if continent1 == "africa"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Model 2: UCDP conflict <– instrumented lag log values w / controls, all Africa only (including pop density)
preserve
keep if continent1 == "africa"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, fe vce(cluster gid)
restore

* Generate the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_UCDP_AllAfrica_Controls_with_PopDensity.tex", replace mtitles("Model 1" "Model 2") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for UCDP Outcome on All Africa (Including Population Density)) se tex label
eststo clear

****MIDDLE EAST & NORTH AFRICA WITH UCDP DUMMY****
*note, excluding population density from these controls models because too 
* many observations drop. but then models follow with it in so we can check

* Table A4, Model 1: Ucdp ged conflict<--lag, log value w/no controls, mena only
preserve
keep if region_wb=="middle east and north africa"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2  , ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Table A4, Model 2: Ucdp ged conflict<--lag, log value w / controls,mena only
preserve
keep if region_wb=="middle east and north africa"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

****INSTRUMENT MENA WITH UCDP DUMMY****
* Table A4, Model 3: Ucdp conflict<--instrumented lag log values w/no controls, mena only
preserve
keep if region_wb=="middle east and north africa"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument), fe vce(cluster gid)
restore

* Table A4, Model 4: Ucdp conflict<--instrumented lag log  values w / controls, mena only
preserve
keep if region_wb=="middle east and north africa"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument)  logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, fe  vce(cluster gid)
restore

* get the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_UCDP_MENA-Sample_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for UCDP Outcome on Middle East and North Africa (Three-Way Fixed Effects)) se tex label
eststo clear

* Presuming that the data is already loaded and necessary packages are installed

* Model 1: UCDP GED conflict <– lag, log value w / controls, MENA only (including pop density)
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Model 2: UCDP conflict <– instrumented lag log values w / controls, MENA only (including pop density)
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, fe vce(cluster gid)
restore

* Generate the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_UCDP_MENA_Controls_with_PopDensity.tex", replace mtitles("Model 1" "Model 2") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for UCDP Outcome on MENA (Including Population Density)) se tex label
eststo clear


********************************************************************************
****ASIA WITH UCDP DUMMY****
*note, excluding population density from these controls models because too 
* many observations drop. but then models follow with it in so we can check

* Table A5, Model 1: Ucdp ged conflict<--lag, log value w/no controls, asia only
preserve
keep if region_wb=="south asia" | region_wb== "east asia and pacific"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2  , ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Table A5, Model 2: Ucdp ged conflict<--lag, log value w / controls, asia only
preserve
keep if region_wb=="south asia" | region_wb== "east asia and pacific"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

****INSTRUMENT ASIA WITH UCDP DUMMY****
* Table A5, Model 3: Ucdp conflict<--instrumented lag log values w/no controls, asia only
preserve
keep if region_wb=="south asia" | region_wb== "east asia and pacific"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument), fe vce(cluster gid)
restore

* Table A5, Model 4: Ucdp conflict<--instrumented lag log  values w / controls, asia only
preserve
keep if region_wb=="south asia" | region_wb== "east asia and pacific"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument)  logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, fe  vce(cluster gid)
restore

* get the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_UCDP_ASIA-Sample_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for UCDP Outcome on Asia (Three-Way Fixed Effects)) se tex label
eststo clear

* Presuming that the data is already loaded and necessary packages are installed

* Model 1: UCDP GED conflict <– lag, log value w / controls, Asia only (including pop density)
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Model 2: UCDP conflict <– instrumented lag log values w / controls, Asia only (including pop density)
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean ///
v2x_polyarchy popd_mean acled_M1, fe vce(cluster gid)
restore

* Generate the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_UCDP_Asia_Controls_with_PopDensity.tex", replace mtitles("Model 1" "Model 2") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for UCDP Outcome on Asia (Including Population Density)) se tex label
eststo clear

*******************************************************************************
****LATIN AMERICA WITH UCDP DUMMY**** 
*note, excluding population density from these controls models because too 
* many observations drop. but then models follow with it in so we can check

* LATIN AMERICAN OBSERVATIONS MISSING BECAUSE OF THE MERGE I MADE - TRY WITH ALL DATA xsub_denly_lootcols
* Table A6, Model 1: Ucdp ged conflict<--lag, log value w/no controls, latin america only
preserve
keep if region_wb=="latin america and caribbean" 
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2  , ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore


* Table A6, Model 2: Ucdp ged conflict<--lag, log value w / controls, latin america only
preserve
keep if region_wb=="latin america and caribbean" 
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

****INSTRUMENT LATIN AMERICA WITH UCDP DUMMY****
* Table A6, Model 3: Ucdp conflict<--instrumented lag log values w/no controls, latin america only
preserve
keep if region_wb=="latin america and caribbean" 
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument), fe vce(cluster gid)
restore


* Table A6, Model 4: Ucdp conflict<--instrumented lag log  values w / controls, latin america only
preserve
keep if region_wb=="latin america and caribbean" 
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument)  logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, fe  vce(cluster gid)
restore

* get the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModels_UCDP_LA-Sample_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for UCDP Outcome on Latin America (Three-Way Fixed Effects)) se tex label
eststo clear

*******************************************************************************
****ALL COUNTRIES WITH UCDP DUMMY****
*note, excluding population density from these controls models because too 
* many observations drop. but then models follow with it in so we can check

* Table A7, Model 1: Ucdp ged conflict<--lag, log value w/no controls, all countries
preserve
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2  , ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

* Table A7, Model 2: Ucdp ged conflict<--lag, log value w / controls, all countries
preserve
eststo: my_reg2hdfespatial ucdpdum lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
restore

****INSTRUMENT GLOBAL WITH UCDP DUMMY****
* Table A7, Model 3: Ucdp conflict<--instrumented lag log values w/no controls, all countries only
preserve
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument), fe vce(cluster gid)
restore

* Table A7, Model 4: Ucdp conflict<--instrumented lag log  values w / controls, all countries only
preserve
xtset gid cy
eststo: xtivreg ucdpdum (loglocal_value = lag1instrument)  logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootable_ever excluded nlights_calib_mean  ///
v2x_polyarchy acled_M1, fe  vce(cluster gid)
restore

* get the LaTeX table
set linesize 250
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\Models_Full-Sample_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(2SLS Instrumented Local Prices Model Results for UCDP Outcome on Full Sample  (Three-Way Fixed Effects)) se tex label
eststo clear



******BERMAN ET AL REPLICATION

*main berman model relies on this interaction
gen bermaninteractcontemp = log_berman_wb_usgs_price*berman_mine_active

preserve
keep if continent1=="africa"
eststo: my_reg2hdfespatial acled log_berman_wb_usgs_price berman_mine_active bermaninteractcontemp, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estimates store A
restore

* Generate the LaTeX table
set linesize 250
esttab A using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_specs\MainModel_ACLED_Africa_InteractionTerm.tex", replace b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for ACLED Outcome on Africa with Interaction Term) se tex label

log close