# ------------------------------------------------------------------------------------------- #
# Project:  Occupational Choice Under Compensation Frictions                                  #
# Author:   David Enocksson                                                                   #
# Date:     October, 2019                                                                     #
# ------------------------------------------------------------------------------------------- #

tablesfolder = readdir("../out/tables/")

H = readdlm("../out/tables/Base/Manag.csv")
A = readdlm("../out/tables/Base/A.csv")

Pw = readdlm("../out/tables/Base/Pw.csv")
Pe = readdlm("../out/tables/Base/Pe.csv")
Pw = (Pw^1000)[1,:]
Pe = (Pe^1000)[1,:]
ρ = [.1314 1-.1314]
MaxInd = findfirst(A .> 1000)[1]

# Value Functions
VFBase = readdlm("../out/tables/Base/ValueFunction.csv")
VFd000 = readdlm("../out/tables/d000/ValueFunction.csv")
VFd050 = readdlm("../out/tables/d050/ValueFunction.csv")
VFd150 = readdlm("../out/tables/d150/ValueFunction.csv")
VFd200 = readdlm("../out/tables/d200/ValueFunction.csv")
VFdINF = readdlm("../out/tables/dINF/ValueFunction.csv")
VFr000 = readdlm("../out/tables/r000/ValueFunction.csv")
VFr050 = readdlm("../out/tables/r050/ValueFunction.csv")
VFr150 = readdlm("../out/tables/r150/ValueFunction.csv")
VFr200 = readdlm("../out/tables/r200/ValueFunction.csv")
VFrALL = readdlm("../out/tables/rALL/ValueFunction.csv")

# Invariant Distributions
FBase = readdlm("../out/tables/Base/InvariantDistribution.csv")
Fd000 = readdlm("../out/tables/d000/InvariantDistribution.csv")
Fd050 = readdlm("../out/tables/d050/InvariantDistribution.csv")
Fd150 = readdlm("../out/tables/d150/InvariantDistribution.csv")
Fd200 = readdlm("../out/tables/d200/InvariantDistribution.csv")
FdINF = readdlm("../out/tables/dINF/InvariantDistribution.csv")
Fr000 = readdlm("../out/tables/r000/InvariantDistribution.csv")
Fr050 = readdlm("../out/tables/r050/InvariantDistribution.csv")
Fr150 = readdlm("../out/tables/r150/InvariantDistribution.csv")
Fr200 = readdlm("../out/tables/r200/InvariantDistribution.csv")
FrALL = readdlm("../out/tables/rALL/InvariantDistribution.csv")

Fd = [FBase Fd000 Fd050 Fd150 Fd200 FdINF]
Fr = [FBase Fr000 Fr050 Fr150 Fr200 FrALL]

ωd000 = (VFBase./VFd000) .- 1
ωd050 = (VFBase./VFd050) .- 1
ωd150 = (VFBase./VFd150) .- 1
ωd200 = (VFBase./VFd200) .- 1
ωdINF = (VFBase./VFdINF) .- 1

ωr000 = (VFBase./VFr000) .- 1
ωr050 = (VFBase./VFr050) .- 1
ωr150 = (VFBase./VFr150) .- 1
ωr200 = (VFBase./VFr200) .- 1
ωrALL = (VFBase./VFrALL) .- 1

ωd000 = reshape(ωd000,length(FBase),1)
ωd050 = reshape(ωd050,length(FBase),1)
ωd150 = reshape(ωd150,length(FBase),1)
ωd200 = reshape(ωd200,length(FBase),1)
ωdINF = reshape(ωdINF,length(FBase),1)

ωr000 = reshape(ωr000,length(FBase),1)
ωr050 = reshape(ωr050,length(FBase),1)
ωr150 = reshape(ωr150,length(FBase),1)
ωr200 = reshape(ωr200,length(FBase),1)
ωrALL = reshape(ωrALL,length(FBase),1)

ωd = [ωd000 ωd050 ωd150 ωd200 ωdINF]
ωr = [ωr000 ωr050 ωr150 ωr200 ωrALL]

Eωd = zeros(length(A),5,4)
Eωr = zeros(length(A),5,4)


for mm = 1:5
	for ll = 1:length(A)
		for ii = 1:2
			for jj = 1:2
				C = 0
				for kk = 1:5
					Eωd[ll,mm,jj+2*(ii-1)] += ωd[ll+length(A)*(kk+5*(jj-1)+10*(ii-1)-1),mm] * Fd[ll+length(A)*(kk+5*(jj-1)+10*(ii-1)-1),mm]
					Eωr[ll,mm,jj+2*(ii-1)] += ωr[ll+length(A)*(kk+5*(jj-1)+10*(ii-1)-1),mm] * Fd[ll+length(A)*(kk+5*(jj-1)+10*(ii-1)-1),mm]
					C += Fd[ll + length(A)*(kk+5*(jj-1)+10*(ii-1)-1),mm]
				end
				if C > 0; Eωd[ll,mm,jj+2*(ii-1)] = Eωd[ll,mm,jj+2*(ii-1)] / C; else; Eωd[ll,mm,jj+2*(ii-1)] = 0; end
				if C > 0; Eωr[ll,mm,jj+2*(ii-1)] = Eωr[ll,mm,jj+2*(ii-1)] / C; else; Eωr[ll,mm,jj+2*(ii-1)] = 0; end
			end
		end

		#println(C2, " ", Eωd2[ll,mm])

	end
		
end

# Aggregate 
ωbard000 = dot(ωd000,Fd000)
ωbard050 = dot(ωd050,Fd050)
ωbard150 = dot(ωd150,Fd150)
ωbard200 = dot(ωd200,Fd200)
ωbardINF = dot(ωdINF,FdINF)
ωbarr000 = dot(ωr000,Fr000)
ωbarr050 = dot(ωr050,Fr050)
ωbarr150 = dot(ωr150,Fr150)
ωbarr200 = dot(ωr200,Fr200)
ωbarrALL = dot(ωrALL,FrALL)

# Positive
ωposd000 = sum(Fd000[find(ωd000 .> 0)])
ωposd050 = sum(Fd050[find(ωd050 .> 0)])
ωposd150 = sum(Fd150[find(ωd150 .> 0)])
ωposd200 = sum(Fd200[find(ωd200 .> 0)])
ωposdINF = sum(FdINF[find(ωdINF .> 0)])
ωposr000 = sum(Fr000[find(ωr000 .> 0)])
ωposr050 = sum(Fr050[find(ωr050 .> 0)])
ωposr150 = sum(Fr150[find(ωr150 .> 0)])
ωposr200 = sum(Fr200[find(ωr200 .> 0)])
ωposrALL = sum(FrALL[find(ωrALL .> 0)])

ω = [ωbard000 ωbard050 ωbard150 ωbard200 ωbardINF ωbarr000 ωbarr050 ωbarr150 ωbarr200 ωbarrALL;
     ωposd000 ωposd050 ωposd150 ωposd200 ωposdINF ωposr000 ωposr050 ωposr150 ωposr200 ωposrALL]

# Store Results
run(`mkdir -p ../out/tables/welfare`)
folder = "../out/tables/welfare/"

writedlm(string(folder,"omegatable.csv"), ω)
writedlm(string(folder,"Eomegad1.csv"), Eωd[:,:,1])
writedlm(string(folder,"Eomegad2.csv"), Eωd[:,:,2])
writedlm(string(folder,"Eomegad3.csv"), Eωd[:,:,3])
writedlm(string(folder,"Eomegad4.csv"), Eωd[:,:,4])
writedlm(string(folder,"Eomegar1.csv"), Eωr[:,:,1])
writedlm(string(folder,"Eomegar2.csv"), Eωr[:,:,2])
writedlm(string(folder,"Eomegar3.csv"), Eωr[:,:,3])
writedlm(string(folder,"Eomegar4.csv"), Eωr[:,:,4])