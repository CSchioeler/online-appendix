* ---------------------------------------------------------------------
* Replicating Denly but using my lootability measure and conflict variables and matched dataset - plus capdist
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
log using "$Results\Spatial_Regressions_matched_denly_with_lootability_capdist.log", replace

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

* Replace missing lootability_proportion values with 0
replace lootability_proportion = 0 if missing(lootability_proportion)

* Create the initial_lootability_proportion variable using the value from 1994
bysort gid (year): gen initial_lootability = lootability_proportion if year == 1994

* Propagate the 1994 value to all observations within the same gid
*bysort gid: replace initial_lootability = initial_lootability[1] if missing(initial_lootability)

* Generate interaction term lag log local value X initial_lootability
* gen interaction_term = lag1logwd_ann_val_loc2 * initial_lootability

* Generate the average lootability_proportion for the years 1994-1998
* bysort gid: egen initial_lootability = mean(cond(inrange(year, 1994, 1998), lootability_proportion, .))

* Ensure the average is constant over time for each gid
* bysort gid: replace initial_lootability = initial_lootability[1]



gen lagged_lootability = lootability_proportion[_n-1]

* generate lagged interaction_term
gen laginteraction_term = lag1logwd_ann_val_loc2 * lagged_lootability

* generate instrumented interaction term
gen instr_interaction_term = loglocal_value * lagged_lootability

replace lagged_lootability = 0 if missing(lagged_lootability)


* Label variables as in Denly to compare
label var lag1logwd_ann_val_loc2 "Log Natural Resource Value (Lagged)"
label var logwd_ann_val_loc2_M "Resources 1st Order Spatial Lag"
label var logwd_ann_val_loc2_M2 "Resources 2nd Order Spatial Lag"
label var lootability_proportion "Lootability Score"
label var lootable_ever "Presence of Lootable Resources"
label var lootable "Proportion of Distinct Lootable Resources"
label var excluded "Number of Excluded Ethnic Groups"
label var nlights_calib_mean "Nighttime Lights"
label var v2x_polyarchy "V-Dem Democracy Index"
label var popd_mean "Mean Population Density"
label var ACTION_ANY_M1 "Any Violence (Spatially Lagged)"
label var ACTION_DIR_M1 "Direct Violence (Spatially Lagged)"
label var ACTION_IND_M1 "Indirect Violence (Spatially Lagged)"
label var ACTION_PRT_M1 "Protest (Spatially Lagged)"
label var loglocal_value "Natural Resource Value w/ Instrumented Country-Specific Price"
label var action_dummy "Any Violence Dummy"
label var direct_dummy "Direct Violence Dummy"
label var indirect_dummy "Indirect Violence Dummy"
label var protest_dummy "Protest Dummy"
label var initial_lootability "Initial Lootability Proportion (1994)"
label var laginteraction_term "Log Natural Resource Value (Lagged) X Lootability Score (Lagged)"
label var popd_mean "Mean Population Density"
label var lagged_lootability "Lagged Lootability Score"
label var instr_interaction_term "Instrumented Log Resource Value X Lootability Score (Lagged)"
label var capdist "Distance to Country Capital"
label var v2stfisccap "State Fiscal Capacity"
* --------------------------------------------------------
* action_dummy Depdendent Variable
*-----------------------------------------------------------------
* Model 1: Action Dummy <- lagged_lootability w/no controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial action_dummy lagged_lootability, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lagged_lootability
restore

* Model 2: Action Dummy <- lagged_lootability w controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial action_dummy lagged_lootability logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 excluded nlights_calib_mean v2x_polyarchy ACTION_ANY_M1 v2stfisccap, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lagged_lootability logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 excluded nlights_calib_mean v2x_polyarchy ACTION_ANY_M1 v2stfisccap
restore

* Model 3: Action Dummy <– lag, log value w/no controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 lagged_lootability, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 lagged_lootability
restore

* Model 4: Action Dummy <– lag, log value w/ controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1 v2stfisccap, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1 v2stfisccap
restore

* Model 5: Action Dummy <– instrumented lag log values w/no controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) lagged_lootability, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument lagged_lootability 
restore

* Model 6: Action Dummy <– instrumented lag log values w/ controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1 v2stfisccap, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lagged_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1 v2stfisccap
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_SSA_Controls_lagged2.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4" "Model 5" "Model 6") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome on SSA (Three-Way Fixed Effects)) se tex label
*-----------------------------------------------------------------
* action_direct Depdendent Variable
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
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1
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
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1, fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_direct_dummy_SSA_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for direct_dummy Outcome on SSA (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_indirect Depdendent Variable
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
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1
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
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1, fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_indirect_dummy_SSA_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for indirect_dummy Outcome on SSA (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_protest Depdendent Variable
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
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1
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
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1, fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_protest_dummy_SSA_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for protest_dummy Outcome on SSA (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* action_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Action Dummy <– lag, log value w/no controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Action Dummy <– lag, log value w/ controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1
restore

* Model 3: Action Dummy <– instrumented lag log values w/no controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument
restore

* Model 4: Action Dummy <– instrumented lag log values w/ controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_MENA_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome on MENA (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* action_direct Dependent Variable
*-----------------------------------------------------------------
* Model 1: Direct Dummy <– lag, log value w/no controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Direct Dummy <– lag, log value w/ controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1
restore

* Model 3: Direct Dummy <– instrumented lag log values w/no controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument
restore

* Model 4: Direct Dummy <– instrumented lag log values w/ controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1, fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_direct_dummy_MENA_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for direct_dummy Outcome on MENA (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_indirect Dependent Variable
*-----------------------------------------------------------------

* Model 1: Indirect Dummy <– lag, log value w/no controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Indirect Dummy <– lag, log value w/ controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1
restore

* Model 3: Indirect Dummy <– instrumented lag log values w/no controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument
restore

* Model 4: Indirect Dummy <– instrumented lag log values w/ controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1, fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_indirect_dummy_MENA_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for indirect_dummy Outcome on MENA (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_protest Dependent Variable
*-----------------------------------------------------------------
* Model 1: Protest Dummy <– lag, log value w/no controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Protest Dummy <– lag, log value w/ controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1
restore

* Model 3: Protest Dummy <– instrumented lag log values w/no controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument
restore

* Model 4: Protest Dummy <– instrumented lag log values w/ controls, Middle East and North Africa only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1, fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_protest_dummy_MENA_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for protest_dummy Outcome on MENA (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Action Dummy <– lag, log value w/no controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Action Dummy <– lag, log value w/ controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 initial_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1 capdist popd_mean, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 initial_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1 capdist popd_mean
restore

* Model 3: Action Dummy <– instrumented lag log values w/no controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument
restore

* Model 4: Action Dummy <– instrumented lag log values w/ controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 initial_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1 capdist popd_mean, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 initial_lootability excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1 capdist popd_mean
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_LAC_Controls_initial.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome on LAC (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* action_direct Dependent Variable
*-----------------------------------------------------------------
* Model 1: Direct Dummy <– lag, log value w/no controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Direct Dummy <– lag, log value w/ controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1
restore

* Model 3: Direct Dummy <– instrumented lag log values w/no controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument
restore

* Model 4: Direct Dummy <– instrumented lag log values w/ controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1, fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_direct_dummy_LAC_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for direct_dummy Outcome on LAC (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_indirect Dependent Variable
*-----------------------------------------------------------------

* Model 1: Indirect Dummy <– lag, log value w/no controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Indirect Dummy <– lag, log value w/ controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1
restore

* Model 3: Indirect Dummy <– instrumented lag log values w/no controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument
restore

* Model 4: Indirect Dummy <– instrumented lag log values w/ controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1, fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_indirect_dummy_LAC_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for indirect_dummy Outcome on LAC (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_protest Dependent Variable
*-----------------------------------------------------------------
* Model 1: Protest Dummy <– lag, log value w/no controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Protest Dummy <– lag, log value w/ controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1
restore

* Model 3: Protest Dummy <– instrumented lag log values w/no controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument
restore

* Model 4: Protest Dummy <– instrumented lag log values w/ controls, Latin America and Caribbean only
preserve
keep if region_wb == "latin america and caribbean"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1, fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_protest_dummy_LAC_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for protest_dummy Outcome on LAC (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_dummy Dependent Variable
*-----------------------------------------------------------------
* Model 1: Action Dummy <– lag, log value w/no controls, all countries
preserve
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Action Dummy <– lag, log value w/ controls, all countries
preserve
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1
restore

* Model 3: Action Dummy <– instrumented lag log values w/no controls, all countries
preserve
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument
restore

* Model 4: Action Dummy <– instrumented lag log values w/ controls, all countries
preserve
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1, fe vce(cluster gid)
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_AllCountries_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome on All Countries (Three-Way Fixed Effects)) se tex label


*-----------------------------------------------------------------
* action_direct Dependent Variable
*-----------------------------------------------------------------
* Model 1: Direct Dummy <– lag, log value w/no controls, all countries
preserve
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Direct Dummy <– lag, log value w/ controls, all countries
preserve
eststo: my_reg2hdfespatial direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum direct_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1
restore

* Model 3: Direct Dummy <– instrumented lag log values w/no controls, all countries
preserve
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument
restore

* Model 4: Direct Dummy <– instrumented lag log values w/ controls, all countries
preserve
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1, fe vce(cluster gid)
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_DIR_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_direct_dummy_AllCountries_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for direct_dummy Outcome on All Countries (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_indirect Dependent Variable
*-----------------------------------------------------------------

* Model 1: Indirect Dummy <– lag, log value w/no controls, all countries
preserve
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Indirect Dummy <– lag, log value w/ controls, all countries
preserve
eststo: my_reg2hdfespatial indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum indirect_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1
restore

* Model 3: Indirect Dummy <– instrumented lag log values w/no controls, all countries
preserve
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument
restore

* Model 4: Indirect Dummy <– instrumented lag log values w/ controls, all countries
preserve
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1, fe vce(cluster gid)
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_IND_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_indirect_dummy_AllCountries_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for indirect_dummy Outcome on All Countries (Three-Way Fixed Effects)) se tex label

*-----------------------------------------------------------------
* action_protest Dependent Variable
*-----------------------------------------------------------------
* Model 1: Protest Dummy <– lag, log value w/no controls, all countries
preserve
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2
restore

* Model 2: Protest Dummy <– lag, log value w/ controls, all countries
preserve
eststo: my_reg2hdfespatial protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum protest_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1
restore

* Model 3: Protest Dummy <– instrumented lag log values w/no controls, all countries
preserve
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument
restore

* Model 4: Protest Dummy <– instrumented lag log values w/ controls, all countries
preserve
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1, fe vce(cluster gid)
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_PRT_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_protest_dummy_AllCountries_Controls.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for protest_dummy Outcome on All Countries (Three-Way Fixed Effects)) se tex label


* FIRST STAGE MODELS

* correlation for first-stage
pwcorr loglocal_value instrument
corrtex loglocal_value instrument, file("results/corr_table_first_stage") replace

* Action Dummy<--instrumented lag log values w / controls, SS africa only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_ANY_M1, fe vce(cluster gid) first
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_ANY_M1
restore

* Action Dummy<--instrumented lag log values w / controls, all africa only
preserve
keep if continent1 == "africa"
xtset gid cy
eststo: xtivreg action_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_ANY_M1, fe vce(cluster gid) first
estpost sum action_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_ANY_M1
restore

* Direct Dummy<--instrumented lag log values w / controls, SS africa only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_DIR_M1, fe vce(cluster gid) first
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_DIR_M1
restore

* Direct Dummy<--instrumented lag log values w / controls, all africa only
preserve
keep if continent1 == "africa"
xtset gid cy
eststo: xtivreg direct_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_DIR_M1, fe vce(cluster gid) first
estpost sum direct_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_DIR_M1
restore

* Indirect Dummy<--instrumented lag log values w / controls, SS africa only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_IND_M1, fe vce(cluster gid) first
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_IND_M1
restore

* Indirect Dummy<--instrumented lag log values w / controls, all africa only
preserve
keep if continent1 == "africa"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_IND_M1, fe vce(cluster gid) first
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_IND_M1
restore

* Protest Dummy<--instrumented lag log values w / controls, SS africa only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_PRT_M1, fe vce(cluster gid) first
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_PRT_M1
restore

* Protest Dummy<--instrumented lag log values w / controls, all africa only
preserve
keep if continent1 == "africa"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_PRT_M1, fe vce(cluster gid) first
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_PRT_M1
restore

* Indirect Dummy<--instrumented lag log values w / controls, mena only
preserve
keep if region_wb == "middle east and north africa"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_IND_M1, fe vce(cluster gid) first
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_IND_M1
restore

* Indirect Dummy<--instrumented lag log values w / controls, asia only
preserve
keep if region_wb == "south asia" | region_wb == "east asia and pacific"
xtset gid cy
eststo: xtivreg indirect_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_IND_M1, fe vce(cluster gid) first
estpost sum indirect_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_IND_M1
restore

* Protest Dummy<--instrumented lag log values w / controls, latin america only
preserve
keep if region_wb == "latin america and caribbean" | region_wb == "latin american and caribbean"
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_PRT_M1, fe vce(cluster gid) first
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_PRT_M1
restore

* Protest Dummy<--instrumented lag log values w / controls, world
preserve
xtset gid cy
eststo: xtivreg protest_dummy (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ///
ACTION_PRT_M1, fe vce(cluster gid) first
estpost sum protest_dummy loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean v2x_polyarchy ACTION_PRT_M1
restore

