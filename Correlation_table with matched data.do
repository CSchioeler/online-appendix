clear all
* cd directory here
global base "D:\Dropbox\CHRISTIAN\MPhil\Thesis\Stata Regressions"

* Global

global Output_data	"code_tables_results\Data"
global Results		"code_tables_results\results"
global Do_files     "code_tables_results\Do"

cd "$base"

* Create correlation tables
log using "$Results\Correlation_table.log", replace
use "$Output_data\matched_grd_xsub.dta", clear


* collapse the data to compute the maximum values of the dummy variable, latitude, longitude, and the mean number of mines per gid and ID_0_xS (country identifier)
collapse (max) action_dummy PRIO_YCOORD_xS PRIO_XCOORD_xS mine_existence (mean) encoded_unique_site (mean) year, by(gid country)
tab country, gen(country_nb)


* First estimate: Existence of a mine over sample period
/*between cells, panel*/
eststo: my_spatial_2sls action_dummy mine_existence country_nb* , latitude(PRIO_YCOORD_xS) longitude(PRIO_XCOORD_xS) id(gid) time(year) lag(0) dist(500) lagdist(0) /*no time dimension*/

log close
