# ------------------------------------------------------------------------------------------- #
# Project:  Occupational Choice Under Compensation Frictions                                   #
# Author:   David Enocksson                                                                    #
# Date:     October, 2019                                                                      #
# ------------------------------------------------------------------------------------------- #

const tablesfolder = string("../out/tables/",ARGS[1],"/")

F = readdlm(string(tablesfolder,"/InvariantDistribution.csv"))
A = readdlm(string(tablesfolder,"/A.csv"))
AssetFlat = readdlm(string(tablesfolder,"/Asset.csv"))
Manag = readdlm(string(tablesfolder,"/Manag.csv"))
OccupationMeasures = readdlm(string(tablesfolder,"/OccupationMeasures.csv"))

na = length(A)
nn = length(Manag[1,:])
nx = Int(nn/2)
Asset = zeros(na,nn,nn)

for ii=1:nn; Asset[:,:,ii] = AssetFlat[:,(1+nx*(ii-1)):(nn+nx*(ii-1))]; end

# Asset Densities and Distributions
AssetDens, AssetDensW, AssetDensD, AssetDensE = zeros(na), zeros(na), zeros(na), zeros(na)
AssetDist, AssetDistW, AssetDistD, AssetDistE = zeros(na), zeros(na), zeros(na), zeros(na)

for ii=1:na
    AssetDens[ii] = sum(F[ii:na:end])
    for jj=ii:na:na*nn
        if Manag[jj] == 0.0
            AssetDensW[ii] += F[jj] / OccupationMeasures[1]
        elseif Manag[jj] == 1.0
            AssetDensE[ii] += F[jj] / OccupationMeasures[3]
        else
            AssetDensD[ii] += F[jj] / (1-OccupationMeasures[1]-OccupationMeasures[3])
        end
    end
    AssetDist[ii] = sum(AssetDens[1:ii])
    AssetDistW[ii] = sum(AssetDensW[1:ii])
    AssetDistE[ii] = sum(AssetDensE[1:ii])
    AssetDistD[ii] = sum(AssetDensD[1:ii])
end

# Wealth Gini Coefficient: G = (1/μ)∫F(y)(1-F(y)dy
MeanWealth = ⋅(A,AssetDens) 
Integral = 0
for ii=2:na
    Integral += AssetDist[ii] * (1 - AssetDist[ii]) * (A[ii] - A[ii-1])
end

Gini = Integral/MeanWealth

# Theil Index: T = ∫ (k/μ) ln(k/μ) dF(k)
Theil = 0
for ii=2:na
    Theil += (A[ii]/MeanWealth ) * log(A[ii]/MeanWealth) * (AssetDist[ii] - AssetDist[ii-1])
end

# Median wealth
ind = findfirst(AssetDist .> .5)
UpperDeviation = (AssetDist[ind] - .5)/(AssetDist[ind]-AssetDist[ind-1])
LowerDeviation = (.5 - AssetDist[ind-1])/(AssetDist[ind]-AssetDist[ind-1])
LowerWeight = UpperDeviation 
UpperWeight = LowerDeviation 
Median = LowerWeight * A[ind-1] + UpperWeight * A[ind]

# ------------------------------------------------------------------------------------------- #
# Output                                                                                      #
# ------------------------------------------------------------------------------------------- #
writedlm(string(tablesfolder,"AssetDens.csv"),  AssetDens)
writedlm(string(tablesfolder,"AssetDensW.csv"), AssetDensW)
writedlm(string(tablesfolder,"AssetDensD.csv"), AssetDensD)
writedlm(string(tablesfolder,"AssetDensE.csv"), AssetDensE)
writedlm(string(tablesfolder,"AssetDist.csv"),  AssetDist)
writedlm(string(tablesfolder,"AssetDistW.csv"), AssetDistW)
writedlm(string(tablesfolder,"AssetDistD.csv"), AssetDistD)
writedlm(string(tablesfolder,"AssetDistE.csv"), AssetDistE)
writedlm(string(tablesfolder,"Wealth.csv"),     [Median, Gini, Theil])
