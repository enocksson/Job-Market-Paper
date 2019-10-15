# ------------------------------------------------------------------------------------------- #
# Project:  Occupational Choice Under Compensation Frictions                                  #
# Author:   David Enocksson                                                                   #
# Date:     October, 2019                                                                     #
# ------------------------------------------------------------------------------------------- #

BasePrice = readdlm("../out/tables/Base/Prices.csv")
d000Price = readdlm("../out/tables/d000/Prices.csv")
d050Price = readdlm("../out/tables/d050/Prices.csv")
d150Price = readdlm("../out/tables/d150/Prices.csv")
d200Price = readdlm("../out/tables/d200/Prices.csv")
dINFPrice = readdlm("../out/tables/dINF/Prices.csv")
r000Price = readdlm("../out/tables/r000/Prices.csv")
r050Price = readdlm("../out/tables/r050/Prices.csv")
r150Price = readdlm("../out/tables/r150/Prices.csv")
r200Price = readdlm("../out/tables/r200/Prices.csv")
rALLPrice = readdlm("../out/tables/rALL/Prices.csv")

RPrice = Array{Any}(2,11)
RPrice[1,1]  = round(100 * (BasePrice[1]/BasePrice[1]),2)
RPrice[2,1]  = round(100 * (BasePrice[2]/BasePrice[2]),2)
RPrice[1,2]  = round(100 * (d000Price[1]/BasePrice[1]),2)
RPrice[2,2]  = round(100 * (d000Price[2]/BasePrice[2]),2)
RPrice[1,3]  = round(100 * (d050Price[1]/BasePrice[1]),2)
RPrice[2,3]  = round(100 * (d050Price[2]/BasePrice[2]),2)
RPrice[1,4]  = round(100 * (d150Price[1]/BasePrice[1]),2)
RPrice[2,4]  = round(100 * (d150Price[2]/BasePrice[2]),2)
RPrice[1,5]  = round(100 * (d200Price[1]/BasePrice[1]),2)
RPrice[2,5]  = round(100 * (d200Price[2]/BasePrice[2]),2)
RPrice[1,6]  = round(100 * (dINFPrice[1]/BasePrice[1]),2)
RPrice[2,6]  = round(100 * (dINFPrice[2]/BasePrice[2]),2)
RPrice[1,7]  = round(100 * (r000Price[1]/BasePrice[1]),2)
RPrice[2,7]  = round(100 * (r000Price[2]/BasePrice[2]),2)
RPrice[1,8]  = round(100 * (r050Price[1]/BasePrice[1]),2)
RPrice[2,8]  = round(100 * (r050Price[2]/BasePrice[2]),2)
RPrice[1,9]  = round(100 * (r150Price[1]/BasePrice[1]),2)
RPrice[2,9]  = round(100 * (r150Price[2]/BasePrice[2]),2)
RPrice[1,10] = round(100 * (r200Price[1]/BasePrice[1]),2)
RPrice[2,10] = round(100 * (r200Price[2]/BasePrice[2]),2)
RPrice[1,11] = round(100 * (rALLPrice[1]/BasePrice[1]),2)
RPrice[2,11] = round(100 * (rALLPrice[2]/BasePrice[2]),2)

## Occupations
BaseOcc = rpad.(round.(100*readdlm("../out/tables/Base/OccupationMeasures.csv"),2),2,"0")
d000Occ = rpad.(round.(100*readdlm("../out/tables/d000/OccupationMeasures.csv"),2),2,"0")
d050Occ = rpad.(round.(100*readdlm("../out/tables/d050/OccupationMeasures.csv"),2),2,"0")
d150Occ = rpad.(round.(100*readdlm("../out/tables/d150/OccupationMeasures.csv"),2),2,"0")
d200Occ = rpad.(round.(100*readdlm("../out/tables/d200/OccupationMeasures.csv"),2),2,"0")
dINFOcc = rpad.(round.(100*readdlm("../out/tables/dINF/OccupationMeasures.csv"),2),2,"0")
r000Occ = rpad.(round.(100*readdlm("../out/tables/r000/OccupationMeasures.csv"),2),2,"0")
r050Occ = rpad.(round.(100*readdlm("../out/tables/r050/OccupationMeasures.csv"),2),2,"0")
r150Occ = rpad.(round.(100*readdlm("../out/tables/r150/OccupationMeasures.csv"),2),2,"0")
r200Occ = rpad.(round.(100*readdlm("../out/tables/r200/OccupationMeasures.csv"),2),2,"0")
rALLOcc = rpad.(round.(100*readdlm("../out/tables/rALL/OccupationMeasures.csv"),2),2,"0")

## Welfare
ω = rpad.(round.(100*readdlm("../out/tables/welfare/omegatable.csv"),2),4,"0")

## Wealth
WealthBase = readdlm("../out/tables/Base/Wealth.csv")'
Wealthd000 = readdlm("../out/tables/d000/Wealth.csv")'
Wealthd050 = readdlm("../out/tables/d050/Wealth.csv")'
Wealthd150 = readdlm("../out/tables/d150/Wealth.csv")'
Wealthd200 = readdlm("../out/tables/d200/Wealth.csv")'
WealthdINF = readdlm("../out/tables/dINF/Wealth.csv")'
Wealthr000 = readdlm("../out/tables/r000/Wealth.csv")'
Wealthr050 = readdlm("../out/tables/r050/Wealth.csv")'
Wealthr150 = readdlm("../out/tables/r150/Wealth.csv")'
Wealthr200 = readdlm("../out/tables/r200/Wealth.csv")'
WealthrALL = readdlm("../out/tables/rALL/Wealth.csv")'

Wealth = [WealthBase; 
		  Wealthd000; 
		  Wealthd050; 
		  Wealthd150; 
		  Wealthd200; 
		  WealthdINF; 
		  Wealthr000; 
		  Wealthr050; 
		  Wealthr150; 
		  Wealthr200; 
		  WealthrALL]

Wealth[:,1] = Wealth[:,1] / Wealth[1,1]
Wealth[:,3] = Wealth[:,3] / Wealth[1,3]
Wealth = round.(100*Wealth,2)

run(`mkdir -p ../out/tables/ResultsForPaper`)

# Table 1
row1 = "\\begin{tabularx}{\\textwidth}{L{.14}R{.18}R{.08}R{.10}R{.10}R{.10}R{.10}R{.10}R{.10}}"
row2 = "\\toprule"
row3 = "& & \\multicolumn{1}{c}{Data} & \\multicolumn{1}{c}{-100\\%} & \\multicolumn{1}{c}{-50\\%} & \\multicolumn{1}{c}{Base} & \\multicolumn{1}{c}{+50\\%} & \\multicolumn{1}{c}{+100\\%} & \\multicolumn{1}{c}{\$+\\infty\$} \\\\ \\midrule"
row4 = "\\multirow{2}{*}{Price} & \$r\\phantom{_0}\$ & & $(RPrice[1,2]) & $(RPrice[1,3]) & $(RPrice[1,1]) & $(RPrice[1,4]) & $(RPrice[1,5]) & $(RPrice[1,6]) \\\\"
row5 = "& \$w_0\$ & & $(RPrice[2,2]) & $(RPrice[2,3]) & $(RPrice[2,1]) & $(RPrice[2,4]) & $(RPrice[2,5]) &$(RPrice[2,6]) \\\\ \\midrule"
row6 = "\\multirow{3}{*}{Occupation} & Entrepreneur & \$11.75\$ & $(d000Occ[3]) & $(d050Occ[3]) & $(BaseOcc[3]) & $(d150Occ[3]) & $(d200Occ[3]) &$(dINFOcc[3]) \\\\"
row7 = "& Dual Employed & \$3.25\$ & $(d000Occ[2]) & $(d050Occ[2]) & $(BaseOcc[2]) & $(d150Occ[2]) & $(d200Occ[2]) &$(dINFOcc[2]) \\\\"
row8 = "& Employed & \$85.00\$ & $(d000Occ[1]) & $(d050Occ[1]) & $(BaseOcc[1]) & $(d150Occ[1]) & $(d200Occ[1]) &$(dINFOcc[1]) \\\\ \\midrule"
row9 = "\\multirow{2}{*}{Welfare} & \$\\overline{\\omega}\\phantom{^+}\$ & & $(ω[1,1]) & $(ω[1,2]) & --- & $(ω[1,3]) & $(ω[1,4]) & $(ω[1,5]) \\\\"
row10 = "& \$\\omega^{+}\$ & & $(ω[2,1]) & $(ω[2,2]) & --- & $(ω[2,3]) & $(ω[2,4]) & $(ω[2,5]) \\\\ \\midrule"
row11 = "\\multirow{3}{*}{Wealth} & Gini & \$85.9\$ & $(Wealth[2,2]) & $(Wealth[3,2]) & $(Wealth[1,2]) & $(Wealth[4,2]) & $(Wealth[5,2]) & $(Wealth[6,2]) \\\\"
row12 = " & Theil & & $(Wealth[2,3]) & $(Wealth[3,3]) & $(Wealth[1,3]) & $(Wealth[4,3]) & $(Wealth[5,3]) & $(Wealth[6,3]) \\\\"
row13 = " & Median & & $(Wealth[2,1]) & $(Wealth[3,1]) & $(Wealth[1,1]) & $(Wealth[4,1]) & $(Wealth[5,1]) & $(Wealth[6,1]) \\\\"
row14 = "\\bottomrule"
row15 = "\\end{tabularx}"

writedlm("../out/tables/ResultsForPaper/Counterfactuals1.tex",[
	row1;
	row2;
	row3;
	row4;
	row5;
	row6;
	row7;
	row8;
	row9;
	row10;
	row11;
	row12;
	row13;
	row14;
	row15])
#



# Table 2
row1 = "\\begin{tabularx}{\\textwidth}{L{.16}R{.21}R{.09}R{.09}R{.09}R{.09}R{.09}R{.09}R{.09}}"
row2 = "\\toprule"
row3 = "& & \\multicolumn{1}{c}{Data} & \\multicolumn{1}{c}{-100\\%} & \\multicolumn{1}{c}{-50\\%} & \\multicolumn{1}{c}{Base} & \\multicolumn{1}{c}{+50\\%} & \\multicolumn{1}{c}{+100\\%} & \\multicolumn{1}{c}{ALL} \\\\ \\midrule"
row4 = "\\multirow{2}{*}{Price} & \$r\\phantom{_0}\$ & & $(RPrice[1,7]) & $(RPrice[1,8]) & $(RPrice[1,1]) & $(RPrice[1,9]) & $(RPrice[1,10]) & $(RPrice[1,11]) \\\\"
row5 = "& \$w_0\$ & & $(RPrice[2,7]) & $(RPrice[2,8]) & $(RPrice[2,1]) & $(RPrice[2,9]) & $(RPrice[2,10]) & $(RPrice[2,11]) \\\\ \\midrule"
row6 = "\\multirow{3}{*}{Occupation} & Entrepreneur & \$11.75\$ & $(r000Occ[3]) & $(r050Occ[3]) & $(BaseOcc[3]) & $(r150Occ[3]) & $(r200Occ[3]) &$(rALLOcc[3]) \\\\"
row7 = "& Dual Employed & \$3.25\$ & $(r000Occ[2]) & $(r050Occ[2]) & $(BaseOcc[2]) & $(r150Occ[2]) & $(r200Occ[2]) &$(rALLOcc[2]) \\\\"
row8 = "& Employed & \$85.00\$ & $(r000Occ[1]) & $(r050Occ[1]) & $(BaseOcc[1]) & $(r150Occ[1]) & $(r200Occ[1]) &$(rALLOcc[1]) \\\\ \\midrule"
row9 = "\\multirow{2}{*}{Welfare} & \$\\overline{\\omega}\\phantom{^+}\$ & & $(ω[1,6]) & $(ω[1,7]) & --- & $(ω[1,8]) & $(ω[1,9]) & $(ω[1,10]) \\\\"
row10 = "& \$\\omega^{+}\$ & & $(ω[2,6]) & $(ω[2,7]) & --- & $(ω[2,8]) & $(ω[2,9]) & $(ω[2,10]) \\\\ \\midrule"
row11 = "\\multirow{3}{*}{Wealth} & Gini & \$85.9\$ & $(Wealth[7,2]) & $(Wealth[8,2]) & $(Wealth[1,2]) & $(Wealth[9,2]) & $(Wealth[10,2]) & $(Wealth[11,2]) \\\\"
row12 = " & Theil & & $(Wealth[7,3]) & $(Wealth[8,3]) & $(Wealth[1,3]) & $(Wealth[9,3]) & $(Wealth[10,3]) & $(Wealth[11,3]) \\\\"
row13 = " & Median & & $(Wealth[7,1]) & $(Wealth[8,1]) & $(Wealth[1,1]) & $(Wealth[9,1]) & $(Wealth[10,1]) & $(Wealth[11,1]) \\\\"
row14 = "\\bottomrule"
row15 = "\\end{tabularx}"

writedlm("../out/tables/ResultsForPaper/Counterfactuals2.tex",[
	row1;
	row2;
	row3;
	row4;
	row5;
	row6;
	row7;
	row8;
	row9;
	row10;
	row11;
	row12;
	row13;
	row14;
	row15])
