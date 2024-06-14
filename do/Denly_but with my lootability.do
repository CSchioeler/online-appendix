* ---------------------------------------------------------------------
* Replicating Denly but using my lootability measure and conflict variables and matched dataset
* ---------------------------------------------------------------------

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
log using "$Results\Spatial_Regressions_matched_denly_with_lootability_1stage.log", replace

use "$Output_data\matched_grd_xsub_withlags.dta", clear

* Rename _merge
rename _merge _merge_lags

* Create spatially lagged dummy conflict variable
gen ACTION_ANY_M = .
gen ACTION_DIR_M = .
gen ACTION_IND_M = .
gen ACTION_PRT_M = .

* Fill in the values
replace ACTION_ANY_M = 1 if ACTION_ANY_xS_M > 0 & ACTION_ANY_xS_M ~= .
replace ACTION_ANY_M = 0 if ACTION_ANY_xS_M == 0

replace ACTION_DIR_M = 1 if ACTION_DIR_xS_M > 0 & ACTION_DIR_xS_M ~= .
replace ACTION_DIR_M = 0 if ACTION_DIR_xS_M == 0

replace ACTION_IND_M = 1 if ACTION_IND_xS_M > 0 & ACTION_IND_xS_M ~= .
replace ACTION_IND_M = 0 if ACTION_IND_xS_M == 0

replace ACTION_PRT_M = 1 if ACTION_PRT_xS_M > 0 & ACTION_PRT_xS_M ~= .
replace ACTION_PRT_M = 0 if ACTION_PRT_xS_M == 0

* set the panel variable
xtset gid year

* Create 1-period lags of conflict variables
sort gid year
gen ACTION_ANY_M1 = L.ACTION_ANY_M
gen ACTION_DIR_M1 = L.ACTION_DIR_M
gen ACTION_IND_M1 = L.ACTION_IND_M
gen ACTION_PRT_M1 = L.ACTION_PRT_M

* Generate the average lootability variable
bysort gid: egen avg_lootability = mean(lootability_proportion)

* Replace values
bysort gid: replace avg_lootability = avg_lootability[1] if missing(avg_lootability)
replace avg_lootability = 0 if missing(avg_lootability)
* Replace missing lootability_proportion values with 0
replace lootability_proportion = 0 if missing(lootability_proportion)

* Generate the initial lootability proportion variable
bysort gid: egen initial_lootability_proportion = max(cond(year == 1994, lootability_proportion, .))

* Ensure the initial lootability variable is constant over time for each gid
bysort gid: replace initial_lootability_proportion = initial_lootability_proportion[_n==1]

gen lagged_lootability = lootability_proportion[_n-1]

replace lagged_lootability = 0 if missing(lagged_lootability)



* Label variables as in Denly to compare
label var lag1logwd_ann_val_loc2 "Log Natural Resource Value in Cell (Lagged)"
label var logwd_ann_val_loc2_M "Log Natural Resource Value (1st Order Spatial Lag)"
label var logwd_ann_val_loc2_M2 "Log Natural Resource Value (2nd Order Spatial Lag)"
label var lootability_proportion "Lootability Score"
label var lootable_ever "Presence of Lootable Resources"
label var lootable "Proportion of Distinct Lootable Resources"
label var excluded "Number of Excluded Ethnic Groups"
label var nlights_calib_mean "Nighttime Lights"
label var v2x_polyarchy "V-Dem Democracy Index"
label var popd_mean "Mean Population Density"
label var ACTION_ANY_M "Any Violence (1st Order Spatial Lag)"
label var ACTION_DIR_M "Direct Violence (1st Order Spatial Lag)"
label var ACTION_IND_M "Indirect Violence (1st Order Spatial Lag)"
label var ACTION_PRT_M "Protest (1st Order Spatial Lag)"
label var loglocal_value "Log Natural Resource Value (Instrumented Price)"
label var action_dummy "Any Violence Dummy"
label var direct_dummy "Direct Violence Dummy"
label var indirect_dummy "Indirect Violence Dummy"
label var protest_dummy "Protest Dummy"
label var initial_lootability_proportion "Initial Lootability Proportion (1994)"
label var lagged_lootability "Lootability Score (Lagged)"
label var v2svstterr "State Authority over Territory"
label var avg_lootability "Average Lootability (1994-2014)"
label var lag1instrument "World Price Instrument"

*-----------------------------------------------------------------
* action_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Action Dummy <– lag, log value w/no controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Action Dummy <– lag, log value w/ controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Model 3: Action Dummy <– instrumented lag log values w/no controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument
restore

* Model 4: Action Dummy <– instrumented lag log values w/ controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_SSA_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome on Sub-Saharan Africa (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* direct_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Direct Dummy <– lag, log value w/no controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Direct Dummy <– lag, log value w/ controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Model 3: Direct Dummy <– instrumented lag log values w/no controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument
restore

* Model 4: Direct Dummy <– instrumented lag log values w/ controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_direct_dummy_SSA_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for direct_dummy Outcome on Sub-Saharan Africa (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* indirect_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Indirect Dummy <– lag, log value w/no controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Indirect Dummy <– lag, log value w/ controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Model 3: Indirect Dummy <– instrumented lag log values w/no controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument
restore

* Model 4: Indirect Dummy <– instrumented lag log values w/ controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_indirect_dummy_SSA_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for indirect_dummy Outcome on Sub-Saharan Africa (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* protest_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Protest Dummy <– lag, log value w/no controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Protest Dummy <– lag, log value w/ controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Model 3: Protest Dummy <– instrumented lag log values w/no controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument
restore

* Model 4: Protest Dummy <– instrumented lag log values w/ controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_protest_dummy_SSA_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for protest_dummy Outcome on Sub-Saharan Africa (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* action_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Action Dummy <– lag, log value w/no controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Action Dummy <– lag, log value w/ controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Model 3: Action Dummy <– instrumented lag log values w/no controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument
restore

* Model 4: Action Dummy <– instrumented lag log values w/ controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_MENA_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome on Middle East and North Africa (Three-Way Fixed Effects)) se tex label



*-----------------------------------------------------------------
* direct_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Direct Dummy <– lag, log value w/no controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Direct Dummy <– lag, log value w/ controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Model 3: Direct Dummy <– instrumented lag log values w/no controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument
restore

* Model 4: Direct Dummy <– instrumented lag log values w/ controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_direct_dummy_MENA_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for direct_dummy Outcome on Middle East and North Africa (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* indirect_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Indirect Dummy <– lag, log value w/no controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Indirect Dummy <– lag, log value w/ controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Model 3: Indirect Dummy <– instrumented lag log values w/no controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument
restore

* Model 4: Indirect Dummy <– instrumented lag log values w/ controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_indirect_dummy_MENA_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for indirect_dummy Outcome on Middle East and North Africa (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* protest_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Protest Dummy <– lag, log value w/no controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Protest Dummy <– lag, log value w/ controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Model 3: Protest Dummy <– instrumented lag log values w/no controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument
restore

* Model 4: Protest Dummy <– instrumented lag log values w/ controls, MENA only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_protest_dummy_MENA_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for protest_dummy Outcome on Middle East and North Africa (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* action_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Action Dummy <– lag, log value w/no controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Action Dummy <– lag, log value w/ controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Model 3: Action Dummy <– instrumented lag log values w/no controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument
restore

* Model 4: Action Dummy <– instrumented lag log values w/ controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_LAC_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome on Latin America and Caribbean (Three-Way Fixed Effects)) se tex label



*-----------------------------------------------------------------
* direct_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Direct Dummy <– lag, log value w/no controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Direct Dummy <– lag, log value w/ controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Model 3: Direct Dummy <– instrumented lag log values w/no controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument
restore

* Model 4: Direct Dummy <– instrumented lag log values w/ controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_direct_dummy_LAC_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for direct_dummy Outcome on Latin America and Caribbean (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* indirect_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Indirect Dummy <– lag, log value w/no controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Indirect Dummy <– lag, log value w/ controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Model 3: Indirect Dummy <– instrumented lag log values w/no controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument
restore

* Model 4: Indirect Dummy <– instrumented lag log values w/ controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_indirect_dummy_LAC_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for indirect_dummy Outcome on Latin America and Caribbean (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* protest_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Protest Dummy <– lag, log value w/no controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Protest Dummy <– lag, log value w/ controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Model 3: Protest Dummy <– instrumented lag log values w/no controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument
restore

* Model 4: Protest Dummy <– instrumented lag log values w/ controls, LAC only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_protest_dummy_LAC_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for protest_dummy Outcome on Latin America and Caribbean (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* action_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Action Dummy <– lag, log value w/no controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Action Dummy <– lag, log value w/ controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Model 3: Action Dummy <– instrumented lag log values w/no controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument
restore

* Model 4: Action Dummy <– instrumented lag log values w/ controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_SA_EAP_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome on South Asia and East Asia & Pacific (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* direct_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Direct Dummy <– lag, log value w/no controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Direct Dummy <– lag, log value w/ controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Model 3: Direct Dummy <– instrumented lag log values w/no controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument
restore

* Model 4: Direct Dummy <– instrumented lag log values w/ controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_direct_dummy_SA_EAP_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for direct_dummy Outcome on South Asia and East Asia & Pacific (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* indirect_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Indirect Dummy <– lag, log value w/no controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Indirect Dummy <– lag, log value w/ controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Model 3: Indirect Dummy <– instrumented lag log values w/no controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument
restore

* Model 4: Indirect Dummy <– instrumented lag log values w/ controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_indirect_dummy_SA_EAP_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for indirect_dummy Outcome on South Asia and East Asia and Pacific (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* protest_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Protest Dummy <– lag, log value w/no controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Protest Dummy <– lag, log value w/ controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Model 3: Protest Dummy <– instrumented lag log values w/no controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument
restore

* Model 4: Protest Dummy <– instrumented lag log values w/ controls, South Asia and East Asia & Pacific only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_protest_dummy_SA_EAP_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for protest_dummy Outcome on South Asia, East Asia and Pacific (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* action_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Action Dummy <– lag, log value w/no controls, Global
preserve
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Action Dummy <– lag, log value w/ controls, Global
preserve
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Model 3: Action Dummy <– instrumented lag log values w/no controls, Global
preserve
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument
restore

* Model 4: Action Dummy <– instrumented lag log values w/ controls, Global
preserve
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_Global_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* direct_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Direct Dummy <– lag, log value w/no controls, Global
preserve
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Direct Dummy <– lag, log value w/ controls, Global
preserve
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Model 3: Direct Dummy <– instrumented lag log values w/no controls, Global
preserve
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument
restore

* Model 4: Direct Dummy <– instrumented lag log values w/ controls, Global
preserve
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr, fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_direct_dummy_Global_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for direct_dummy Outcome (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* indirect_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Indirect Dummy <– lag, log value w/no controls, Global
preserve
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Indirect Dummy <– lag, log value w/ controls, Global
preserve
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Model 3: Indirect Dummy <– instrumented lag log values w/no controls, Global
preserve
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument
restore

* Model 4: Indirect Dummy <– instrumented lag log values w/ controls, Global
preserve
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr, fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_indirect_dummy_Global_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for indirect_dummy Outcome (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* protest_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Protest Dummy <– lag, log value w/no controls, Global
preserve
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Protest Dummy <– lag, log value w/ controls, Global
preserve
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Model 3: Protest Dummy <– instrumented lag log values w/no controls, Global
preserve
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument
restore

* Model 4: Protest Dummy <– instrumented lag log values w/ controls, Global
preserve
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr, fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M v2svstterr
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_protest_dummy_Global_Controls_final.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for protest_dummy Outcome (Three-Way Fixed Effects)) se tex label




* FIRST STAGE MODELS

* correlation for first-stage
pwcorr loglocal_value instrument
corrtex loglocal_value instrument, file("results/corr_table_first_stage") replace


*-----------------------------------------------------------------
* First Stage IV Models for Africa Sample
*-----------------------------------------------------------------

* Open a log file for Africa
log using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\OxThesis-master\tables\first_stage\first_stage_results_Africa.log", replace text

* Preserve the dataset and filter for Africa
preserve
keep if region_wb == "africa"
xtset gid cy
xtreg loglocal_value lag1instrument logwd_ann_val_loc2_M logwd_ann_val_loc2_M2 ///
lagged_lootability excluded nlights_calib_mean v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
test lag1instrument
local Fstat_africa = r(F)
local pvalue_africa = r(p)
display "First stage F statistic for Africa: " `Fstat_africa'
display "First stage p-value for Africa: " `pvalue_africa'
eststo first_stage_africa
restore

* Close the log file for Africa
log close

*-----------------------------------------------------------------
* First Stage IV Models for Latin America & Caribbean Sample
*-----------------------------------------------------------------

* Open a log file for Latin America & Caribbean
log using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\OxThesis-master\tables\first_stage\first_stage_results_LAC.log", replace text

* Preserve the dataset and filter for Latin America & Caribbean
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
xtreg loglocal_value lag1instrument logwd_ann_val_loc2_M logwd_ann_val_loc2_M2 ///
lagged_lootability excluded nlights_calib_mean v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
test lag1instrument
local Fstat_lac = r(F)
local pvalue_lac = r(p)
display "First stage F statistic for Latin America & Caribbean: " `Fstat_lac'
display "First stage p-value for Latin America & Caribbean: " `pvalue_lac'
eststo first_stage_lac
restore

* Close the log file for Latin America & Caribbean
log close

*-----------------------------------------------------------------
* First Stage IV Models for South Asia & East Asia & Pacific Sample
*-----------------------------------------------------------------

* Open a log file for South Asia & East Asia & Pacific
log using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\OxThesis-master\tables\first_stage\first_stage_results_SEAP.log", replace text

* Preserve the dataset and filter for South Asia & East Asia & Pacific
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
xtreg loglocal_value lag1instrument logwd_ann_val_loc2_M logwd_ann_val_loc2_M2 ///
lagged_lootability excluded nlights_calib_mean v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
test lag1instrument
local Fstat_seap = r(F)
local pvalue_seap = r(p)
display "First stage F statistic for South Asia, East Asia and Pacific: " `Fstat_seap'
display "First stage p-value for South Asia & East Asia & Pacific: " `pvalue_seap'
eststo first_stage_seap
restore

* Close the log file for South Asia & East Asia & Pacific
log close

*-----------------------------------------------------------------
* First Stage IV Models for Middle East & North Africa Sample
*-----------------------------------------------------------------

* Open a log file for Middle East & North Africa
log using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\OxThesis-master\tables\first_stage\first_stage_results_MENA.log", replace text

* Preserve the dataset and filter for Middle East & North Africa
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
xtreg loglocal_value lag1instrument logwd_ann_val_loc2_M logwd_ann_val_loc2_M2 ///
lagged_lootability excluded nlights_calib_mean v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
test lag1instrument
local Fstat_mena = r(F)
local pvalue_mena = r(p)
display "First stage F statistic for Middle East & North Africa: " `Fstat_mena'
display "First stage p-value for Middle East & North Africa: " `pvalue_mena'
eststo first_stage_mena
restore

* Close the log file for Middle East & North Africa
log close

*-----------------------------------------------------------------
* First Stage IV Models for Global Sample
*-----------------------------------------------------------------

* Open a log file for Global
log using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\OxThesis-master\tables\first_stage\first_stage_results_Global.log", replace text

* Run the first stage regression for the global sample
xtset gid cy
xtreg loglocal_value lag1instrument logwd_ann_val_loc2_M logwd_ann_val_loc2_M2 ///
lagged_lootability excluded nlights_calib_mean v2x_polyarchy ACTION_ANY_M v2svstterr, fe vce(cluster gid)
test lag1instrument
local Fstat_global = r(F)
local pvalue_global = r(p)
display "First stage F statistic for Global: " `Fstat_global'
display "First stage p-value for Global: " `pvalue_global'
eststo first_stage_global

* Close the log file for Global
log close


