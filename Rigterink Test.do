
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


* set the panel variable
xtset gid year

* Calculate total resource value using lootability proportion and total lootable value
gen total_resource_value = total_lootable_value / lootability_proportion

* Calculate total non-lootable value
gen total_non_lootable_value = total_resource_value - total_lootable_value

* Create 1-period lags of conflict variables
sort gid year
gen ACTION_ANY_M1 = L.ACTION_ANY_xS_M
gen ACTION_DIR_M1 = L.ACTION_DIR_xS_M
gen ACTION_IND_M1 = L.ACTION_IND_xS_M
gen ACTION_PRT_M1 = L.ACTION_PRT_xS_M

* Replace missing lootability_proportion values with 0
replace lootability_proportion = 0 if missing(lootability_proportion)

* Generate the initial lootability proportion variable
bysort gid: egen initial_lootability_proportion = max(cond(year == 1994, lootability_proportion, .))

* Ensure the initial lootability variable is constant over time for each gid
bysort gid: replace initial_lootability_proportion = initial_lootability_proportion[_n==1]

* Generate lootability lag
gen lag1_lootscore = L.lootability_proportion

* Generate key interaction term between log value of resource in cell and lootability score.
gen log_val_X_lootscore = logwd_ann_val_loc2 * lootability_proportion
gen lag1log_val_X_lootscore = lag1logwd_ann_val_loc2 * lag1_lootscore



* Label variables as in Denly to compare
label var lag1logwd_ann_val_loc2 "Natural Resource Value in Cell (Time Lag/Log)"
label var logwd_ann_val_loc2_M "Resources 1st Order Spatial Lag"
label var logwd_ann_val_loc2_M2 "Resources 2nd Order Spatial Lag"
label var lootability_proportion "Lootability Score (Uses World Prices)"
label var lootable_ever "Presence of Lootable Resources"
label var lootable "Proportion of Distinct Lootable Resources"
label var excluded "Number of Excluded Ethnic Groups"
label var nlights_calib_mean "Nighttime Lights"
label var v2x_polyarchy "V-Dem Democracy Index"
label var popd_mean "Mean Population Density"
label var ACTION_ANY_M1 "Any Violence Counts (Spatially and Temporally Lagged)"
label var ACTION_DIR_M1 "Direct Violence Counts (Spatially and  Temporally Lagged)"
label var ACTION_IND_M1 "Indirect Violence Counts (Spatially and TemporallyLagged)"
label var ACTION_PRT_M1 "Protest Counts (Spatially and TemporallyLagged)"
label var loglocal_value "Natural Resource Value w/ Instrumented Country-Specific Price"
label var action_dummy "Any Violence Dummy"
label var direct_dummy "Direct Violence Dummy"
label var indirect_dummy "Indirect Violence Dummy"
label var protest_dummy "Protest Dummy"
label var initial_lootability_proportion "Initial Lootability Proportion (1994)"
label var total_non_lootable_value "Total Value of Non-Lootable Resources Produced (Using World Prices)"
label var total_lootable_value "Total Value of Lootable Resources Produced (Using World Prices)"
label var log_val_X_lootscore "Natural Resource Value in Cell X Lootability Score"
label var lag1log_val_X_lootscore "Natural Resource Value in Cell X Lootability Score Lagged"
label var lag1_lootscore "Lootability Score Lagged (Uses World Prices)"
label var logexp_ann_val_loc1 "log annual spatial sum of cell prioritizing export prices (no multicolour prices)"
label var logexp_ann_val_loc2 "log annual spatial sum of cell prioritizing export prices (with multicolour prices)"
label var logwd_ann_val_loc1 "log annual spatial sum of cell prioritizing world prices (no multicolour prices)"
label var logwd_ann_val_loc2 "log annual spatial sum of cell prioritizing world prices (with multicolour prices)"
label var loglocal_value "log annual spatial sum of cell with only export/local prices"
label var logwb_value "log annual spatial sum of cell with only World Bank prices"
label var logusgs_value "log annual spatial sum of cell with only USGS prices"
label var logwd_ann_val_loc2_M "log annual spatial sum of neighboring (1st order) cells prioritizing world prices (with multicolour prices)"
label var logwd_ann_val_loc2_M2 "log annual spatial sum of neighboring (2nd order) cells prioritizing world prices (with multicolour prices)"

label var ACTION_ANY_xS "Counts of ANY Violence"
label var ACTION_DIR_xS "Counts of Direct Violence"
label var ACTION_IND_xS "Counts of Indirect Violence"
label var ACTION_PRT_xS "Counts of Protests"

label var ACTION_ANY_xS_M "Counts of ANY Violence (Spatially Lagged)"
label var ACTION_DIR_xS_M  "Counts of Direct Violence (Spatially Lagged)"
label var ACTION_IND_xS_M  "Counts of Indirect Violence (Spatially Lagged)"
label var ACTION_PRT_xS_M  "Counts of Protests (Spatially Lagged)"


* Run Pseudo Denly in Levels


* Model 1: Action Dummy <– lag, log value w/no controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial ACTION_ANY_xS lag1logwd_ann_val_loc2, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum ACTION_ANY_xS lag1logwd_ann_val_loc2
restore

* Model 2: Action Dummy <– lag, log value w/ controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial ACTION_ANY_xS lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_xS_M ACTION_ANY_M1 , ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum ACTION_ANY_xS lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_xS ACTION_ANY_M1
restore

* Model 3: Action Dummy <– instrumented lag log values w/no controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg ACTION_ANY_xS (loglocal_value = lag1instrument), fe vce(cluster gid)
estpost sum ACTION_ANY_xS loglocal_value lag1instrument
restore

* Model 4: Action Dummy <– instrumented lag log values w/ controls, SSA only
preserve
keep if region_wb == "africa"
xtset gid cy
eststo: xtivreg ACTION_ANY_xS (loglocal_value = lag1instrument) logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_xS_M ACTION_ANY_M1, fe vce(cluster gid)
estpost sum ACTION_ANY_xS loglocal_value lag1instrument logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lootability_proportion excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_xS_M ACTION_ANY_M1
restore

* Save the results into LaTeX table
esttab using "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions\code_tables_results\results\Tables\denly_method_my_vars\MainModels_action_dummy_SSA_Controls_levels.tex", replace mtitles("Model 1" "Model 2" "Model 3" "Model 4") b(%5.4f) se(%5.4f) r2 ar2 star(* 0.10 ** 0.05 *** 0.01) title(Main Spatial HAC Model Results for action_dummy Outcome on SSA (Three-Way Fixed Effects)) se tex label






















* Model 1: Action Dummy <- lag, log value w/no controls SSA
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 lag1log_val_X_lootscore lag1_lootscore, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 lag1log_val_X_lootscore lag1_lootscore
restore

* Model 2: Action Dummy <– lag, log value w/ controls, SSA only
preserve
keep if region_wb == "africa"
eststo: my_reg2hdfespatial action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lag1log_val_X_lootscore lag1_lootscore excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1, ///
timevar(cy) panelvar(gid) lat(ycoord) lon(xcoord) distcutoff(50) lagcutoff(25)
estpost sum action_dummy lag1logwd_ann_val_loc2 logwd_ann_val_loc2_M ///
logwd_ann_val_loc2_M2 lag1log_val_X_lootscore lag1_lootscore excluded nlights_calib_mean ///
v2x_polyarchy ACTION_ANY_M1
restore


* Run without restricting mines to be always active (RIGTERINK SPEC)
* Grid level

* Step 1: Define the panel data structure
xtset gid year

* Step 2: Run the regressions for each conflict dummy variable and output to LaTeX

* Run regression for action_dummy
reghdfe action_dummy total_lootable_value total_non_lootable_value, absorb(year##countryid i.gid) vce(cluster gid)
outreg2 using tables/table2B.tex, replace tex label /// 
    addtext("Country-Year FE", "YES", "Grid-cell FE", "YES") ///
    nonotes addnote("Clustered standard errors (grid-cell level) in parentheses", "* p<0.1 ** p<0.05 *** p<0.01")

* Run regression for direct_dummy
reghdfe direct_dummy total_lootable_value total_non_lootable_value, absorb(year##countryid i.gid) vce(cluster gid)
outreg2 using tables/table2B.tex, append tex label /// 
    addtext("Country-Year FE", "YES", "Grid-cell FE", "YES") ///
    nonotes addnote("Clustered standard errors (grid-cell level) in parentheses", "* p<0.1 ** p<0.05 *** p<0.01")

* Run regression for indirect_dummy
reghdfe indirect_dummy total_lootable_value total_non_lootable_value, absorb(year##countryid i.gid) vce(cluster gid)
outreg2 using tables/table2B.tex, append tex label /// 
    addtext("Country-Year FE", "YES", "Grid-cell FE", "YES") ///
    nonotes addnote("Clustered standard errors (grid-cell level) in parentheses", "* p<0.1 ** p<0.05 *** p<0.01")

* Run regression for protest_dummy
reghdfe protest_dummy total_lootable_value total_non_lootable_value, absorb(year##countryid i.gid) vce(cluster gid)
outreg2 using tables/table2B.tex, append tex label /// 
    addtext("Country-Year FE", "YES", "Grid-cell FE", "YES") ///
    nonotes addnote("Clustered standard errors (grid-cell level) in parentheses", "* p<0.1 ** p<0.05 *** p<0.01")

* Check the first few rows of the new dataset
list in 1/10

* Check the first few rows of the new dataset
list in 1/10


* Check the first few rows of the new dataset
list in 1/10

* Country Level

* Step 1: Aggregate data at the country-year level
collapse (sum) conflict lootable_value total_resource_value (mean) lootability_score, by(country year)

