clear
set more off
cd "D:/Dropbox/CHRISTIAN/MPhil/Thesis/R Code/Data/GRD Dataset"
use "dfhsw_GRD_public_v1.dta"

* Collapse to country-resource-year
egen cry = concat(country resource year)
collapse (firstnm) country resource (mean) year comtrade_price_mult wb_price_mult usgs_price_mult , by(cry)

* Generate log variables
gen log_usgs = log(usgs_price_mult + 1)
gen log_wb = log(wb_price_mult + 1)
gen log_un = log(comtrade_price_mult + 1)

* Calculate all pairwise correlations
pwcorr comtrade_price_mult wb_price_mult usgs_price_mult log_usgs log_wb log_un, obs

* Extract correlation matrix
matrix C = r(C)
matrix list C

* Round correlation coefficients to 3 decimal places
matrix R = J(rowsof(C), colsof(C), .)
forvalues i = 1/`=rowsof(C)' {
    forvalues j = 1/`=colsof(C)' {
        matrix R[`i', `j'] = round(C[`i', `j'], 0.001)
    }
}

* Define custom labels
matrix colnames R = "Country-Specific Price" "World Price" "US Price" "Log US Price" "Log World Price" "Log Country-Specific Price"
matrix rownames R = "Country-Specific Price" "World Price" "US Price" "Log US Price" "Log World Price" "Log Country-Specific Price"

* Save to LaTeX table
esttab matrix(R) using "correlations.tex", replace booktabs ///
    title("Pairwise Correlations between World, US, and Country-Specific Resource Prices") ///
    cells("b(fmt(3))") nonotes label

