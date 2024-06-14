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
log using "$Results\Spatial_Lag_Creation.log", replace

use "$Output_data\xsub_denly_lootcols.dta", clear
keep if merge1 == 3

* Generate dummy for any conflict incidence
gen action_dummy = ACTION_ANY_xS > 0
gen direct_dummy = ACTION_DIR_xS > 0
gen indirect_dummy = ACTION_IND_xS > 0
gen protest_dummy = ACTION_PRT_xS > 0

* Generate dummy for existence of a mine/extraction site
gen mine_existence = encoded_unique_site > 0

* Destring coordinate variables
destring PRIO_YCOORD_xS, replace
destring PRIO_XCOORD_xS, replace

* Specify the filename and path where the dataset will be saved
save "$Output_data\matched_grd_xsub.dta", replace


* Repeat process below for all years 1994-2014
* ----------------------------------------------------*


keep if year==1994

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-1994.dta", replace


use "$Output_data\matched_grd_xsub.dta", clear

keep if year==1995

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-1995.dta", replace



use "$Output_data\matched_grd_xsub.dta", clear

keep if year==1996

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-1996.dta", replace



use "$Output_data\matched_grd_xsub.dta", clear

keep if year==1997 

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-1997.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==1998

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-1998.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==1999

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-1999.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2000

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2000.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2001

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2001.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2002

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2002.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2003

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2003.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2004

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2004.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2005

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2005.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2006

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2006.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2007

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2007.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2008

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2008.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2009

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2009.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2010

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2010.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2011

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2011.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2012

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2012.dta", replace


use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2013

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2013.dta", replace

use "$Output_data\matched_grd_xsub.dta", clear

keep if year==2014

spmat drop M
spmat contiguity M using "$Shape_files/coors.dta", id(gid) banded
spmat summarize M, links

spmat lag double ACTION_ANY_xS_M M ACTION_ANY_xS
spmat lag double ACTION_DIR_xS_M M ACTION_DIR_xS
spmat lag double ACTION_IND_xS_M M ACTION_IND_xS
spmat lag double ACTION_PRT_xS_M M ACTION_PRT_xS

* Save only the lag variables and key identifiers
keep gid year ACTION_ANY_xS_M ACTION_DIR_xS_M ACTION_IND_xS_M ACTION_PRT_xS_M
save "$Results\temporary\lags-all-2014.dta", replace


* Append all lags files
* Clear the workspace
clear

* Load the first lag file to initialize the dataset
use "$Results\temporary\lags-all-1994.dta", clear

* Manually append each subsequent year's lag file
append using "$Results\temporary\lags-all-1995.dta"
append using "$Results\temporary\lags-all-1996.dta"
append using "$Results\temporary\lags-all-1997.dta"
append using "$Results\temporary\lags-all-1998.dta"
append using "$Results\temporary\lags-all-1999.dta"
append using "$Results\temporary\lags-all-2000.dta"
append using "$Results\temporary\lags-all-2001.dta"
append using "$Results\temporary\lags-all-2002.dta"
append using "$Results\temporary\lags-all-2003.dta"
append using "$Results\temporary\lags-all-2004.dta"
append using "$Results\temporary\lags-all-2005.dta"
append using "$Results\temporary\lags-all-2006.dta"
append using "$Results\temporary\lags-all-2007.dta"
append using "$Results\temporary\lags-all-2008.dta"
append using "$Results\temporary\lags-all-2009.dta"
append using "$Results\temporary\lags-all-2010.dta"
append using "$Results\temporary\lags-all-2011.dta"
append using "$Results\temporary\lags-all-2012.dta"
append using "$Results\temporary\lags-all-2013.dta"
append using "$Results\temporary\lags-all-2014.dta"

* Save the combined spatial lags file after appending all
save "$Results\temporary\combined_lags.dta", replace


* Merge back into dataset
* Clear the workspace and load the main dataset
clear
use "$Output_data\matched_grd_xsub.dta", clear

rename _merge _mergelootable

* Merge the combined lags file
merge 1:1 gid year using "$Results\temporary\combined_lags.dta"


* Save the updated main dataset
sort gid year

save "$Output_data\matched_grd_xsub_withlags.dta", replace
log close