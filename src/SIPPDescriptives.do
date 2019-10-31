clear
* cls

* * * Data collected from NBER: https://www.nber.org/sipp/2014/pu2014w1.dta.zip

set maxvar 6000                 `Increase allowed number of variables to fit data set'

cd "~/Desktop/SIPP"             `Change working directory'

* Import data file (Large)
use pu2014w1.dta                `870,352 Observations * 5,229 Variables'

drop if EJB1_JBORSE == 3 | EJB2_JBORSE == 3 | EJB3_JBORSE == 3

*** SINGLE JOBHOLDERS AND THEIR OCCUPATIONS
generate singlejobholder = 0
replace singlejobholder = 1 if rmnumjobs == 1 & !missing(EJB1_STRTMON) & !missing(EJB1_EMONTH)
replace singlejobholder = 2 if rmnumjobs == 2 & ///
			((EJB1_STRTMON < EJB2_STRTMON & EJB1_EMONTH < EJB2_EMONTH) | ///
			 (EJB1_STRTMON > EJB2_STRTMON & EJB1_EMONTH > EJB2_EMONTH))
replace singlejobholder = 3 if rmnumjobs == 3 & ///
			((EJB1_STRTMON < EJB2_STRTMON & EJB1_EMONTH < EJB2_EMONTH) | ///
			 (EJB1_STRTMON > EJB2_STRTMON & EJB1_EMONTH > EJB2_EMONTH) | ///
			 (EJB2_STRTMON < EJB3_STRTMON & EJB2_EMONTH < EJB3_EMONTH) | ///
			 (EJB2_STRTMON > EJB3_STRTMON & EJB2_EMONTH > EJB3_EMONTH) | ///
			 (EJB1_STRTMON < EJB3_STRTMON & EJB1_EMONTH < EJB3_EMONTH) | ///
			 (EJB1_STRTMON > EJB3_STRTMON & EJB1_EMONTH > EJB3_EMONTH))

generate singlejobholderempl = 0
replace singlejobholderempl = 1 if singlejobholder == 1 & EJB1_JBORSE == 1
replace singlejobholderempl = 1 if singlejobholder == 2 & EJB1_JBORSE == 1 & EJB2_JBORSE == 1 
replace singlejobholderempl = 1 if singlejobholder == 3 & EJB1_JBORSE == 1 & EJB2_JBORSE == 1 & EJB3_JBORSE == 1 

generate singlejobholderself = 0
replace singlejobholderself = 1 if singlejobholder == 1 & EJB1_JBORSE == 2
replace singlejobholderself = 1 if singlejobholder == 2 & EJB1_JBORSE == 2 & EJB1_JBORSE == 2
replace singlejobholderself = 1 if singlejobholder == 3 & EJB1_JBORSE == 2 & EJB1_JBORSE == 2 & EJB3_JBORSE == 2

generate singleoccupation = .
replace singleoccupation = 1 if singlejobholderempl == 1
replace singleoccupation = 3 if singlejobholderself == 1

*** MULTIPLE JOBHOLDERS AND THEIR OCCUPATIONS
generate multiplejobholder = 0
replace multiplejobholder = 2 if rmnumjobs == 2 & ///
			((EJB1_STRTMON <= EJB2_STRTMON & EJB1_EMONTH >= EJB2_EMONTH) | ///
			 (EJB1_STRTMON >= EJB2_STRTMON & EJB1_EMONTH <= EJB2_EMONTH))
replace multiplejobholder = 3 if rmnumjobs == 3 & ( ///
			((EJB1_STRTMON <= EJB2_STRTMON & EJB1_EMONTH >= EJB2_EMONTH) | ///
			 (EJB1_STRTMON <= EJB3_STRTMON & EJB1_EMONTH >= EJB3_EMONTH) | ///
			 (EJB2_STRTMON <= EJB3_STRTMON & EJB2_EMONTH >= EJB3_EMONTH)) | ///
			((EJB1_STRTMON >= EJB2_STRTMON & EJB1_EMONTH <= EJB2_EMONTH) | ///
			 (EJB1_STRTMON >= EJB3_STRTMON & EJB1_EMONTH <= EJB3_EMONTH) | ///
			 (EJB2_STRTMON >= EJB3_STRTMON & EJB2_EMONTH <= EJB3_EMONTH)))

generate dualjobholder = 0
replace dualjobholder = 1 if multiplejobholder == 2 & (EJB1_JBORSE + EJB2_JBORSE > 2) & (EJB1_JBORSE + EJB2_JBORSE < 4) 
replace dualjobholder = 1 if multiplejobholder == 3 & (EJB1_JBORSE + EJB2_JBORSE + EJB3_JBORSE > 3) & (EJB1_JBORSE + EJB2_JBORSE + EJB3_JBORSE < 6) 

generate multiplejobholderempl = 0
replace multiplejobholderempl = 1 if multiplejobholder == 2 & EJB1_JBORSE == 1 & EJB2_JBORSE == 1
replace multiplejobholderempl = 1 if multiplejobholder == 3 & EJB1_JBORSE == 1 & EJB2_JBORSE == 1 & EJB3_JBORSE == 1
	
generate multiplejobholderself = 0
replace multiplejobholderself = 1 if multiplejobholder == 2 & EJB1_JBORSE == 2 & EJB2_JBORSE == 2
replace multiplejobholderself = 1 if multiplejobholder == 3 & EJB1_JBORSE == 2 & EJB2_JBORSE == 2 & EJB3_JBORSE == 2

generate typejobholder = .
replace typejobholder = 1 if singlejobholder > 0
replace typejobholder = 2 if multiplejobholder > 0

generate multipleoccupation = .
replace multipleoccupation = 1 if multiplejobholderempl == 1
replace multipleoccupation = 2 if dualjobholder == 1
replace multipleoccupation = 3 if multiplejobholderself == 1

generate occupation = .
replace occupation = 1 if singleoccupation == 1 | multipleoccupation == 1
replace occupation = 2 if multipleoccupation == 2
replace occupation = 3 if singleoccupation == 3 | multipleoccupation == 3
separate occupation, by(occupation)

keep if esex == 1 & tage >= 25
generate industrycode1 = tjb1_ind
destring industrycode1, replace

generate naics1 = .
replace naics1 = 1 if industrycode1 >= 10 & industrycode1 <= 560
replace naics1 = 2 if industrycode1 >= 770 & industrycode1 <= 1060
replace naics1 = 3 if industrycode1 >= 1070 & industrycode1 <= 4060
replace naics1 = 4 if industrycode1 >= 4070 & industrycode1 <= 4660
replace naics1 = 5 if industrycode1 >= 4670 & industrycode1 <= 6060
replace naics1 = 6 if (industrycode1 >= 6070 & industrycode1 <= 6460) | (industrycode1 >= 570 & industrycode1 <= 760)
replace naics1 = 7 if industrycode1 >= 6470 & industrycode1 <= 6860
replace naics1 = 8 if industrycode1 >= 6870 & industrycode1 <= 7260
replace naics1 = 9 if industrycode1 >= 7270 & industrycode1 <= 7790
replace naics1 = 10 if industrycode1 >= 7860 & industrycode1 <= 8490
replace naics1 = 11 if industrycode1 >= 8560 & industrycode1 <= 8690
replace naics1 = 12 if industrycode1 >= 8770 & industrycode1 <= 9290
replace naics1 = 13 if industrycode1 >= 9370 & industrycode1 <= 9590
replace naics1 = 14 if industrycode1 >= 9670 & industrycode1 <= 9890

label define industrylabel ///
	1  "Agriculture, Forestry, Fishing and Hunting, and Mining" ///
	2  "Construction" ///
	3  "Manufacturing" ///
	4  "Wholesale Trade" ///
	5  "Retail Trade" ///
	6  "Transportation and Warehousing, and Utilities" ///
	7  "Information" ///
	8  "Finance and Insurance, and Real Estate and Rental and Leasing" ///
	9  "Professional, Scientific, and Management, and Administrative and Waste Management Services" ///
	10 "Educational Services, and Health Care and Social Assistance" ///
	11 "Arts, Entertainment, and Recreation, and Accommodation and Food Services" ///
	12 "Other Services (except Public Administration)" ///
	13 "Public Administration" /// 
	14 "Active Duty Military"
	
label values naics1 industrylabel
keep if naics1 > 0

generate occupationcode1 = tjb1_occ
destring occupationcode1, replace
generate soc1 = .
replace soc1 = 1  if  occupationcode1 >= 0010 & occupationcode1 <= 0430 
replace soc1 = 2  if  occupationcode1 >= 0500 & occupationcode1 <= 0950 
replace soc1 = 3  if  occupationcode1 >= 1000 & occupationcode1 <= 1240 
replace soc1 = 4  if  occupationcode1 >= 1300 & occupationcode1 <= 1560 
replace soc1 = 5  if  occupationcode1 >= 1600 & occupationcode1 <= 1965 
replace soc1 = 6  if  occupationcode1 >= 2000 & occupationcode1 <= 2060 
replace soc1 = 7  if  occupationcode1 >= 2100 & occupationcode1 <= 2160 
replace soc1 = 8  if  occupationcode1 >= 2200 & occupationcode1 <= 2550 
replace soc1 = 9  if  occupationcode1 >= 2600 & occupationcode1 <= 2960 
replace soc1 = 10 if  occupationcode1 >= 3000 & occupationcode1 <= 3540 
replace soc1 = 11 if  occupationcode1 >= 3600 & occupationcode1 <= 3655 
replace soc1 = 12 if  occupationcode1 >= 3700 & occupationcode1 <= 3955 
replace soc1 = 13 if  occupationcode1 >= 4000 & occupationcode1 <= 4160 
replace soc1 = 14 if  occupationcode1 >= 4200 & occupationcode1 <= 4250 
replace soc1 = 15 if  occupationcode1 >= 4300 & occupationcode1 <= 4650 
replace soc1 = 16 if  occupationcode1 >= 4700 & occupationcode1 <= 4965 
replace soc1 = 17 if  occupationcode1 >= 5000 & occupationcode1 <= 5940 
replace soc1 = 18 if  occupationcode1 >= 6000 & occupationcode1 <= 6130 
replace soc1 = 19 if  occupationcode1 >= 6200 & occupationcode1 <= 6940 
replace soc1 = 20 if  occupationcode1 >= 7000 & occupationcode1 <= 7630 
replace soc1 = 21 if  occupationcode1 >= 7700 & occupationcode1 <= 8965 
replace soc1 = 22 if  occupationcode1 >= 9000 & occupationcode1 <= 9750 
replace soc1 = 23 if  occupationcode1 == 9840 

label define occupationlabel ///
	1  "Management occupations" ///
	2  "Business and financial operations occupations" ///
	3  "Computer and mathematical science occupations" ///
	4  "Architecture and engineering occupations" ///
	5  "Life, physical, and social science occupations " ///
	6  "Community and social service occupation" ///
	7  "Legal occupations" ///
	8  "Education, training, and library occupations" ///
	9  "Arts, design, entertainment, sports, and media occupations" ///
	10 "Healthcare practitioner and technical occupations" ///
	11 "Healthcare support occupations" ///
	12 "Protective service occupations" ///
	13 "Food preparation and serving related occupations" ///
	14 "Building and grounds cleaning and maintenance occupations" ///
	15 "Personal care and service occupations" ///
	16 "Sales and related occupations " ///
	17 "Office and administrative support occupations" ///
	18 "Farming, fishing, and forestry occupations" ///
	19 "Construction and extraction occupations" ///
	20 "Installation, maintenance, and repair occupations" ///
	21 "Production occupations" ///
	22 "Transportation and material moving occupations" ///
	23 "Armed Forces"

label values soc1 occupationlabel

generate ReasonPTJob1 = .
replace ReasonPTJob1 = 1 if EJB1_PTRESN1 == 2
replace ReasonPTJob1 = 2 if EJB1_PTRESN1 == 6 | EJB1_PTRESN1 == 11
replace ReasonPTJob1 = 3 if EJB1_PTRESN1 == 1 | EJB1_PTRESN1 == 8
replace ReasonPTJob1 = 4 if EJB1_PTRESN1 == 7
replace ReasonPTJob1 = 5 if EJB1_PTRESN1 == 3 | EJB1_PTRESN1 == 4 | EJB1_PTRESN1 == 5
replace ReasonPTJob1 = 6 if EJB1_PTRESN1 == 9 | EJB1_PTRESN1 == 10
replace ReasonPTJob1 = 7 if EJB1_PTRESN1 == 12

label define ReasonPTJob1Label ///
	1  "Wanted to work part-time" ///
	2  "In school or taking care of children or other person" ///
	3  "Could not find full-time job, includes slack work or material shortage" ///
	4  "Full-time work weekis less than hours" ///
	5  "Health condition" ///
	6  "Job-sharing or on vacation" ///
	7  "Other"
label values ReasonPTJob1 ReasonPTJob1Label

generate ReasonPTJob2 = .
replace ReasonPTJob2 = 1 if EJB2_PTRESN1 == 2
replace ReasonPTJob2 = 2 if EJB2_PTRESN1 == 6 | EJB2_PTRESN1 == 11
replace ReasonPTJob2 = 3 if EJB2_PTRESN1 == 1 | EJB2_PTRESN1 == 8
replace ReasonPTJob2 = 4 if EJB2_PTRESN1 == 7
replace ReasonPTJob2 = 5 if EJB2_PTRESN1 == 3 | EJB2_PTRESN1 == 4 | EJB2_PTRESN1 == 5
replace ReasonPTJob2 = 6 if EJB2_PTRESN1 == 9 | EJB2_PTRESN1 == 10
replace ReasonPTJob2 = 7 if EJB2_PTRESN1 == 12

label define ReasonPTJob2Label ///
	1  "Wanted to work part-time" ///
	2  "In school or taking care of children or other person" ///
	3  "Could not find full-time job, includes slack work or material shortage" ///
	4  "Full-time work week is less than 35 hours" ///
	5  "Health condition" ///
	6  "Job-sharing or on vacation" ///
	7  "Other"
label values ReasonPTJob2 ReasonPTJob2Label

set scheme sj

graph hbar (percent) occupation1 occupation2 occupation3 if multiplejobholder == 2 & esex == 1 & tage > 24 ///
	& EJB1_JBORSE == 1 & TJB1_JOBHRS1 < 35 & TJB2_JOBHRS1 < 35, ///
over(ReasonPTJob1, label(labsize(medlarge)) relabel( ///
	1  `"Wanted to work part-time"' ///
	2  `""In school or taking care of" "children or other person""' ///
	3  `""Could not find full-time job, includes" "slack work or material shortage""' ///
	4  `""Full-time work week" "is less than 35 hours""' ///
	5  `"Health condition"' ///
	6  `"Job-sharing or on vacation"' ///
	7  `"Other"'))  bar(1, color(178 102 255)) bar(2, color(204 153 255)) blabel(total,format(%12.1fc) size(medsmall)) name(g1, replace) ylabel(0(10)60,labsize(medium)) ytitle(,size(small)) yscale(range(0,5,60)) legend(off) fxsize(265) title("First Job", size(large)) graphregion(color(white)) bgcolor(white)

graph hbar (percent) occupation1 occupation2 if multiplejobholder == 2 & esex == 1 & tage > 24 ///
	& EJB2_JBORSE == 1 & TJB1_JOBHRS1 < 35 & TJB2_JOBHRS1 < 35, ///
over(ReasonPTJob2, label(labsize(medlarge)) relabel( ///
	1  `" "' ///
	2  `" "' ///
	3  `" "' ///
	4  `" "' ///
	5  `" "' ///
	6  `" "' ///
	7  `" "'))  bar(1, color(178 102 255)) bar(2, color(204 153 255)) blabel(total,format(%12.1fc) size(medsmall)) name(g2, replace) ylabel(0(10)60,labsize(medium)) ytitle(,size(small)) yscale(range(0,5,60)) legend(nobox region(lcolor(white)) cols(1) symxsize(5) size(large) lab(1 "Employed") lab(2 "Dual Employed") ring(0) position(5) bmargin("0 0 30 0")) fxsize(160) title("Second Job", size(large)) graphregion(color(white)) bgcolor(white)

graph combine g1 g2, rows(1) graphregion(color(white)) xsize(6.5) ysize(2.85)
graph export ReasonPartTimeEMP.pdf, replace

graph hbar (percent) occupation2 occupation3 if multiplejobholder == 2 & esex == 1 & tage > 24 ///
	& EJB1_JBORSE == 2 & TJB1_JOBHRS1 < 35 & TJB2_JOBHRS1 < 35, ///
over(ReasonPTJob1, label(labsize(medlarge)) relabel( ///
	1  `"Wanted to work part-time"' ///
	2  `""In school or taking care of" "children or other person""' ///
	3  `""Could not find full-time job, includes" "slack work or material shortage""' ///
	4  `""Full-time work week" "is less than 35 hours""' ///
	5  `"Health condition"' ///
	6  `"Job-sharing or on vacation"' ///
	7  `"Other"')) allcategories bar(1, color(204 153 255)) bar(2, color(102 107 255))  blabel(total,format(%12.1fc) size(medsmall)) name(g3, replace) ylabel(0(10)60,labsize(medium)) ytitle(,size(tiny)) yscale(range(0,5,60)) legend(off) fxsize(265) title("First Job", size(large)) graphregion(color(white)) bgcolor(white)

graph hbar (percent) occupation2 occupation3 if multiplejobholder == 2 & esex == 1 & tage > 24 ///
	& EJB2_JBORSE == 2 & TJB1_JOBHRS1 < 35 & TJB2_JOBHRS1 < 35, ///
over(ReasonPTJob2, label(labsize(medlarge)) relabel( ///
	1  `" "' ///
	2  `" "' ///
	3  `" "' ///
	4  `" "' ///
	5  `" "' ///
	6  `" "' ///
	7  `" "')) allcategories bar(1, color(204 153 255)) bar(2, color(102 107 255)) blabel(total,format(%12.1fc) size(medsmall)) name(g4, replace) ylabel(0(10)60,labsize(medium)) ytitle(,size(tiny)) yscale(range(0,5,60)) legend(nobox region(lcolor(white)) cols(1) symxsize(5) size(large) lab(1 "Dual Employed") lab(2 "Self-Employed") ring(0) position(5) bmargin("0 0 25 0")) fxsize(160) title("Second Job", size(large)) graphregion(color(white)) bgcolor(white)

graph combine g3 g4, rows(1) graphregion(color(white)) xsize(6.5) ysize(2.85)
graph export ReasonPartTimeSELF.pdf, replace

graph hbar (percent) occupation1 occupation2 if multiplejobholder == 2 & esex == 1 & tage > 24 & EJB1_JBORSE == 1, ///
	over(naics1, label(labsize(vsmall)) relabel( ///
	1 `""Agriculture, Forestry, Fishing" "and Hunting, and Mining""' /// 
	2 `"Construction"' ///
	3 `"Manufacturing"' ///
	4 `"Wholesale Trade"' ///
	5 `"Retail Trade"' ///
	6 `"Transportation and Warehousing and Utilities"' ///
	7 `"Information"' ///
	8 `""Finance and Insurance, and" "Real Estate and Rental and Leasing""' ///
	9 `""Professional, Scientific, and Management, and" "Administrative and Waste Management Services""' ///
	10 `""Educational Services, and Health" "Care and Social Assistance""' ///
	11 `""Arts, Entertainment, and Recreation, and" "Accommodation and Food Services""' ///
	12 `"Other Services (except Public Administration)"' ///
	13 `"Public Administration"' ///
	14 `"Active Duty Military"')) bar(1, color(178 102 255)) bar(2, color(204 153 255)) blabel(total,format(%12.1fc) size(vsmall)) name(g5, replace) ylabel(0(5)20,labsize(small)) ytitle(,size(small)) yscale(range(0,5,20)) legend(nobox region(lcolor(white)) cols(1) symxsize(5) size(vsmall) lab(1 "Employed") lab(2 "Dual Employed") ring(0) position(1)) graphregion(color(white)) bgcolor(white)

graph combine g5, rows(1) graphregion(color(white)) xsize(6.5) ysize(7.9)
graph export IndByOcc.pdf, replace

graph hbar (percent) occupation2 occupation3 if multiplejobholder == 2 & esex == 1 & tage > 24 & EJB1_JBORSE == 2, ///
	over(naics1, label(labsize(vsmall)) relabel( ///
	1 `""Agriculture, Forestry, Fishing" "and Hunting, and Mining""' /// 
	2 `"Construction"' ///
	3 `"Manufacturing"' ///
	4 `"Wholesale Trade"' ///
	5 `"Retail Trade"' ///
	6 `"Transportation and Warehousing and Utilities"' ///
	7 `"Information"' ///
	8 `""Finance and Insurance, and" "Real Estate and Rental and Leasing""' ///
	9 `""Professional, Scientific, and Management, and" "Administrative and Waste Management Services""' ///
	10 `""Educational Services, and Health" "Care and Social Assistance""' ///
	11 `""Arts, Entertainment, and Recreation, and" "Accommodation and Food Services""' ///
	12 `"Other Services (except Public Administration)"' ///
	13 `"Public Administration"' ///
	14 `"Active Duty Military"')) bar(1, color(178 102 255)) bar(2, color(204 153 255)) blabel(total,format(%12.1fc) size(vsmall)) name(g6, replace) ylabel(0(5)20,labsize(small)) ytitle(,size(small)) yscale(range(0,5,20)) legend(nobox region(lcolor(white)) cols(1) symxsize(5) size(vsmall) lab(1 "Dual Employed") lab(2 "Self-Employed") ring(0) position(1)) graphregion(color(white)) bgcolor(white)

graph combine g6, rows(1) graphregion(color(white)) xsize(6.5) ysize(7.9)
graph export IndByOccSelf.pdf, replace

graph hbar (percent) occupation1 occupation2 if multiplejobholder == 2 & esex == 1 & tage > 24 & EJB1_JBORSE == 1, ///
	over(naics1, label(labsize(small)) relabel( ///
	1 `"Agriculture, Forestry, Fishing and Hunting, and Mining"' /// 
	2 `"Construction"' ///
	3 `"Manufacturing"' ///
	4 `"Wholesale Trade"' ///
	5 `"Retail Trade"' ///
	6 `"Transportation and Warehousing and Utilities"' ///
	7 `"Information"' ///
	8 `"Finance and Insurance, and Real Estate and Rental and Leasing"' ///
	9 `"Professional, Scientific, Mgmt., Admin. and Waste Mgmt. Services"' ///
	10 `"Educational Services, Health Care and Social Assistance"' ///
	11 `"Arts, Entmt., and Recreation, Accommodation and Food Services"' ///
	12 `"Other Services (except Public Administration)"' ///
	13 `"Public Administration"' ///
	14 `"Active Duty Military"')) bar(1, color(178 102 255)) bar(2, color(204 153 255)) blabel(total,format(%12.1fc) size(vsmall)) name(g5, replace) ylabel(0(5)20,labsize(small)) ytitle(,size(small)) yscale(range(0,5,20)) legend(nobox region(lcolor(white)) cols(1) symxsize(5) size(vsmall) lab(1 "Employed") lab(2 "Dual Employed") ring(0) position(1)) graphregion(color(white)) bgcolor(white)

graph combine g5, rows(1) graphregion(color(white)) xsize(4.5) ysize(3.0)
graph export IndByOccBeamer.pdf, replace

graph hbar (percent) occupation1 occupation2 if multiplejobholder == 2 & EJB1_JBORSE == 1 & esex == 1 & tage > 24, ///
	over(soc1, label(labsize(vsmall)) relabel( ///
	1  `"Management"' ///
	2  `"Business and financial operations"' ///
	3  `"Computer and mathematical science"' ///
	4  `"Architecture and engineering"' ///
	5  `"Life, physical, and social science "' ///
	6  `"Community and social service occupation"' ///
	7  `"Legal"' ///
	8  `"Education, training, and library"' ///
	9  `"Arts, design, entertainment, sports, and media"' ///
	10 `"Healthcare practitioner and technical"' ///
	11 `"Healthcare support"' ///
	12 `"Protective service"' ///
	13 `"Food preparation and serving related"' ///
	14 `"Building and grounds cleaning and maintenance"' ///
	15 `"Personal care and service"' ///
	16 `"Sales and related"' ///
	17 `"Office and administrative support"' ///
	18 `"Farming, fishing, and forestry"' ///
	19 `"Construction and extraction"' ///
	20 `"Installation, maintenance, and repair"' ///
	21 `"Production"' ///
	22 `"Transportation and material moving"' ///
	23 `"Armed Forces"')) bar(1, color(178 102 255)) bar(2, color(204 153 255)) blabel(total,format(%12.1fc) size(tiny)) name(g1, replace) ylabel(0(5)20,labsize(small)) ytitle(,size(small)) yscale(range(0,5,20)) legend(nobox region(lcolor(white)) cols(1) symxsize(5) size(vsmall) lab(1 "Employed") lab(2 "Dual Employed") ring(0) position(5) bmargin("0 0 20 0")) graphregion(color(white)) bgcolor(white)

graph combine g1, rows(1) graphregion(color(white)) xsize(6.5) ysize(7.9)
graph export SocByOcc.pdf, replace

graph combine g1, rows(1) graphregion(color(white)) xsize(4.5) ysize(3.0)
graph export SocByOccBeamer.pdf, replace

graph hbar (percent) occupation2 occupation3 if multiplejobholder == 2 & EJB1_JBORSE == 2 & esex == 1 & tage > 24, ///
	over(soc1, label(labsize(vsmall)) relabel( ///
	1  `"Management"' ///
	2  `"Business and financial operations"' ///
	3  `"Computer and mathematical science"' ///
	4  `"Architecture and engineering"' ///
	5  `"Life, physical, and social science "' ///
	6  `"Community and social service occupation"' ///
	7  `"Legal"' ///
	8  `"Education, training, and library"' ///
	9  `"Arts, design, entertainment, sports, and media"' ///
	10 `"Healthcare practitioner and technical"' ///
	11 `"Healthcare support"' ///
	12 `"Building and grounds cleaning and maintenance"' ///
	13 `"Personal care and service"' ///
	14 `"Sales and related"' ///
	15 `"Office and administrative support"' ///
	16 `"Farming, fishing, and forestry"' ///
	17 `"Construction and extraction"' ///
	18 `"Installation, maintenance, and repair"' ///
	19 `"Production"' ///
	20 `"Transportation and material moving"' ///
	21 `"Armed Forces"')) bar(1, color(204 153 255)) bar(2, color(102 107 255)) blabel(total,format(%12.1fc) size(tiny)) name(g2, replace) ylabel(0(5)20,labsize(small)) ytitle(,size(small)) yscale(range(0,5,20)) legend(nobox region(lcolor(white)) cols(1) symxsize(5) size(vsmall) lab(1 "Dual Employed") lab(2 "Self-Employed") ring(0) position(5) bmargin("0 0 1 0")) graphregion(color(white)) bgcolor(white)

graph combine g2, rows(1) graphregion(color(white)) xsize(6.5) ysize(7.9)
graph export SocByOccSelf.pdf, replace


generate mynetworth = thnetworth/1000
format mynetworth %12.2fc

file open myfile using "WealthDist1C.tex", write replace
file write myfile "\begin{tabularx}{\textwidth}{L{.23}R{.05}R{.06}R{.06}R{.06}R{.08}R{.08}R{.08}R{.075}R{.075}R{.075}R{.075}}" _newline
file write myfile "\toprule" _newline
file write myfile " & \multicolumn{7}{c}{Percentile} & & & &  \\ \cmidrule{2-8}" _newline
file write myfile " & 5\% & 10\% & 25\% & 50\% & 75\% & 90\% & 95\% & Mean & St.D. & Skew. & Kurt. \\" _newline
file write myfile "\midrule" _newline
summarize thnetworth if occupation == 1, detail
file write myfile " Employed & " %12.0fc (`r(p5)'/1000) " & " %12.0fc (`r(p10)'/1000) " & " %12.0fc (`r(p25)'/1000) " & " %12.0fc (`r(p50)'/1000) " & " %12.0fc (`r(p75)'/1000) " & " %12.0fc (`r(p90)'/1000) " & " %12.0fc (`r(p95)'/1000) " & " %12.0fc (`r(mean)'/1000) " & " %12.0fc (`r(sd)'/1000) " & " %12.2fc (`r(skewness)') " & " %12.0fc (`r(kurtosis)') " \\ " _newline
summarize thnetworth if occupation == 2, detail
file write myfile " Dual Employed & " %12.0fc (`r(p5)'/1000) " & " %12.0fc (`r(p10)'/1000) " & " %12.0fc (`r(p25)'/1000) " & " %12.0fc (`r(p50)'/1000) " & " %12.0fc (`r(p75)'/1000) " & " %12.0fc (`r(p90)'/1000) " & " %12.0fc (`r(p95)'/1000) " & " %12.0fc (`r(mean)'/1000) " & " %12.0fc (`r(sd)'/1000) " & " %12.2fc (`r(skewness)') " & " %12.0fc (`r(kurtosis)') " \\ " _newline
summarize thnetworth if occupation == 3, detail
file write myfile " Self-Employed & " %12.0fc (`r(p5)'/1000) " & " %12.0fc (`r(p10)'/1000) " & " %12.0fc (`r(p25)'/1000) " & " %12.0fc (`r(p50)'/1000) " & " %12.0fc (`r(p75)'/1000) " & " %12.0fc (`r(p90)'/1000) " & " %12.0fc (`r(p95)'/1000) " & " %12.0fc (`r(mean)'/1000) " & " %12.0fc (`r(sd)'/1000) " & " %12.2fc (`r(skewness)') " & " %12.0fc (`r(kurtosis)') " \\ " _newline
file write myfile "\bottomrule" _newline
file write myfile "\end{tabularx}"
file close myfile

generate oneormorejobs = .
replace oneormorejobs = 1 if rmnumjobs == 1
replace oneormorejobs = 2 if rmnumjobs > 1 & rmnumjobs < .

file open myfile using "WealthDist2C.tex", write replace
file write myfile "\begin{tabularx}{\textwidth}{L{.23}R{.05}R{.06}R{.06}R{.06}R{.08}R{.08}R{.08}R{.075}R{.075}R{.075}R{.075}}" _newline
file write myfile "\toprule" _newline
file write myfile " & \multicolumn{7}{c}{Percentile} & & & &  \\ \cmidrule{2-8}" _newline
file write myfile " & 5\% & 10\% & 25\% & 50\% & 75\% & 90\% & 95\% & Mean & St.D. & Skew. & Kurt. \\" _newline
file write myfile "\midrule" _newline
summarize thnetworth if occupation == 1 & oneormorejobs == 2, detail
file write myfile " Employed & " %12.0fc (`r(p5)'/1000) " & " %12.0fc (`r(p10)'/1000) " & " %12.0fc (`r(p25)'/1000) " & " %12.0fc (`r(p50)'/1000) " & " %12.0fc (`r(p75)'/1000) " & " %12.0fc (`r(p90)'/1000) " & " %12.0fc (`r(p95)'/1000) " & " %12.0fc (`r(mean)'/1000) " & " %12.0fc (`r(sd)'/1000) " & " %12.2fc (`r(skewness)') " & " %12.0fc (`r(kurtosis)') " \\ " _newline
summarize thnetworth if occupation == 2 & oneormorejobs == 2, detail
file write myfile " Dual Employed & " %12.0fc (`r(p5)'/1000) " & " %12.0fc (`r(p10)'/1000) " & " %12.0fc (`r(p25)'/1000) " & " %12.0fc (`r(p50)'/1000) " & " %12.0fc (`r(p75)'/1000) " & " %12.0fc (`r(p90)'/1000) " & " %12.0fc (`r(p95)'/1000) " & " %12.0fc (`r(mean)'/1000) " & " %12.0fc (`r(sd)'/1000) " & " %12.2fc (`r(skewness)') " & " %12.0fc (`r(kurtosis)') " \\ " _newline
summarize thnetworth if occupation == 3 & oneormorejobs == 2, detail
file write myfile " Self-Employed & " %12.0fc (`r(p5)'/1000) " & " %12.0fc (`r(p10)'/1000) " & " %12.0fc (`r(p25)'/1000) " & " %12.0fc (`r(p50)'/1000) " & " %12.0fc (`r(p75)'/1000) " & " %12.0fc (`r(p90)'/1000) " & " %12.0fc (`r(p95)'/1000) " & " %12.0fc (`r(mean)'/1000) " & " %12.0fc (`r(sd)'/1000) " & " %12.2fc (`r(skewness)') " & " %12.0fc (`r(kurtosis)') " \\ " _newline
file write myfile "\bottomrule" _newline
file write myfile "\end{tabularx}"
file close myfile


