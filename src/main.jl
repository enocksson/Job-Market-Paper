# -------------------------------------------------------------------------------------------- #
# Project:  Occupational Choice Under Compensation Frictions                                   #
# Author:   David Enocksson                                                                    #
# Date:     October, 2019                                                                      #
# -------------------------------------------------------------------------------------------- #

const tablesfolder = string("../out/tables/",ARGS[1],"/")
run(`mkdir -p $tablesfolder`)

const Counterfactuals = ["Base", 
                         "d000",
                         "d050",
                         "d150",
                         "d200",
                         "dINF",
                         "r000",
                         "r050",
                         "r150",
                         "r200",
                         "rALL",
                         "sloo", 
                         "shii", 
                         "ploo", 
                         "phii"]

const counterfactual = find(ARGS[1] .== Counterfactuals)[1]
const Prices = readdlm(string(tablesfolder,"Prices.csv"))

const Φ = [1.0-17.6323/43.1091 1.0-10.0/43.1091 1.0-29/43.10911]
const Θ = [1.0 1.0 2.0 1.0;    # Base
           1.0 0.0 2.0 1.0;    # d000
           1.0 0.5 2.0 1.0;    # d050
           1.0 1.5 2.0 1.0;    # d150
           1.0 2.0 2.0 1.0;    # d200
           1.0 1.0 2.0 1.0;    # dINF
           0.0 1.0 2.0 1.0;    # r000
           0.5 1.0 2.0 1.0;    # r050
           1.5 1.0 2.0 1.0;    # r150
           2.0 1.0 2.0 1.0;    # r200
           -.1 1.0 2.0 1.0;    # rINF
           1.0 1.0 1.5 1.0;    # Lo σ Robustness
           1.0 1.0 2.5 1.0;    # Hi σ Robustness
           1.0 1.0 2.0 3.0;    # Lo φ Robustness
           1.0 1.0 2.0 2.0]    # Hi φ Robustness

const θ = Θ[counterfactual,:]

function main()

    # ---------------------------------------------------------------------------------------- #
    # Calibration                                                                              #
    # ---------------------------------------------------------------------------------------- #

    # Parameters
    const δ = .062                                              # Depreciation Rate
    const β = .940                                              # Discount Factor
    const σ = θ[3]                                              # Utility Coefficient
    const α = 0.35                                              # Production Function Parameter 1
    const η = 0.55                                              # Production Function Parameter 2
    const ϵ = 1.0-α-η                                           # Production Function Parameter 3
    const ϕ = (θ[4]==1)*Φ[1]+(θ[4]==2)*Φ[2]+(θ[4]==3)*Φ[3]      # Part Time Relative Full Time
    const ρ = θ[1] >= 0 ? .1314*θ[1] : 1                        # 3.25 % Dual workers
    println(ρ)
    const d = .23323173803526442*θ[2]                           # Wage Discrimination

    # Grids
    const A = linspace(0,2500,1000) .* linspace(0.01,1,1000)    # Asset Grid
    const K = linspace(0,3000,1000) .* linspace(0.02,1,1000)    # Capital Grid
    const H = linspace(0,1,100); 

    # Transition States and Probabilities
    const Xz = [0.000 1.000]                                    # Contract States
    const Pz = [ρ 1-ρ; ρ 1-ρ]                                   # Flexibility Transition Matrix  
    const Xe = [0.000 3.000]                                    # Entrepreneur Productivity Shocks
    const Pe = [0.9070 0.0930; 0.1894 0.8106]                   # Entrepreneur Transition Matrix
    const Xw = [0.646 0.798 0.966 1.169 1.444]                  # Worker Productivity Shocks
    const Pw = [0.731 0.253 0.016 0.000 0.000;                  # Worker Transition Matrix
                0.192 0.555 0.236 0.017 0.000;                  
                0.011 0.222 0.534 0.222 0.011;                  
                0.000 0.017 0.236 0.555 0.192;                  
                0.000 0.000 0.016 0.253 0.731]                  
    const Px = kron(Pe,Pw)                                      # Ability Tran Matrix
    const Σ  = kron(Pz,Px)                                      # Type Tran Matrix

    # Grid and State Lengths                                    
    const na = length(A)                                        # Asset Length         
    const nk = length(K)                                        # Capital Length       
    const nh = length(H)                                        # Management Length    
    const nz = length(Xz)                                       # Length Contract Vector
    const ne = length(Xe)                                       # Length Entrepreneur Ability
    const nw = length(Xw)                                       # Length Worker Ability Space
    const nx = ne * nw                                          # Length Ability Tuple Space
    const nn = nx * nz                                          # Length Ability and Contract Space

    # Invariant Distributions Old and New, and Transition Matrix
    OldDistr = fill(1/(na*nn), na*nn)                           # Invariant Distribution 1
    NewDistr = zeros(na*nn)                                     # Invariant Distribution 2
    
    # Occupation Distributions
    μ = zeros(Float64,nh)                                       # Occupation Density
    λ = zeros(Float64,nh)                                       # Occupation Density | h < 1
  
    # Initialize Value and Policy Functions
    VFold = zeros(Float64,na,nn)                                # Old Value Function: V
    VFold = readdlm(string(tablesfolder,"ValueFunction.csv"))
    VFnew = SharedArray{Float64}(na,nn)                         # New Value Function: TV
    Asset = SharedArray{Float64}(na,nn,nn)                      # Asset Policy Function
    Capit = SharedArray{Float64}(na,nn)                         # Capital Policy Function
    Manag = SharedArray{Float64}(na,nn)                         # Manager Policy Function
    ValHi = zeros(Float64,nx)                                   # Value High by State Tomorrow
    ExpVF = zeros(Float64,na,nx)                                # Expected Value ValHi
  
    # --------------------------------------------------------------------------------- #
    # Define Useful Functions                                                           # 
    # --------------------------------------------------------------------------------- #
  
    WageDiscount = zeros(Float64,nh)
    for hh=1:nh
        WageDiscount[hh] = (1 - (d/ϕ)*H[hh])
    end

    # Income
    function inc(k::Int64,h::Int64,xw::Int64,xe::Int64,Wage::Float64,WBar::Float64,Rate::Float64)
        (1-H[h])*WageDiscount[h]*Wage*Xw[xw]+Xe[xe]*H[h]^ϵ*K[k]^α*(K[k]*(η/α)*(Rate/WBar))^η-(Rate+(η/α)*Rate)*K[k]
    end

    # Computes Transition Matrix
    function Trans()
        I, J, V = Int64[], Int64[], Float64[]
        for s=1:nn # All Abilities and Contract Types
            row = na*(s-1)
            for a=1:na
                row += 1
                for s2m=1:nn
                    a2m = find(A .== Asset[a,s,s2m])[1]
                    col = na*(s2m-1)+a2m
                    push!(J,row)        # Transposed
                    push!(I,col)        # Transposed
                    push!(V,Σ[s,s2m])
                end
            end
        end
        return sparse(I,J,V,na*nn,na*nn)
    end    
  
    # --------------------------------------------------------------------------------- #
    # Initial Guess for Prices                                                          #
    # --------------------------------------------------------------------------------- #

    Rate = Prices[1]
    Wage = Prices[2]
    WBar = Prices[3]
 
    # --------------------------------------------------------------------------------- #
    # Rearrange States for Performance if too few Cores                                 #
    # --------------------------------------------------------------------------------- #

    Employed = [1,2,3,4,5,11,12,13,14,15]
    if nprocs() > 1
        StateToday = Int[]
        for ii=1:nprocs()-1
            for jj=ii:nprocs()-1:nn
                push!(StateToday,jj)
            end
        end
    else
        StateToday = collect(1:nn)
    end 

    function u(c::Float64)
        if σ == 2
            x = c > 0 ? -1.0/c : -Inf
        elseif σ == 1.5
            x = c > 0 ? -2/sqrt(c) : -Inf
        elseif σ == 2.5
            x = c > 0 ? -(2/3)/(c*sqrt(c)) : -Inf
        end
        return x
    end
    
    # --------------------------------------------------------------------------------- #
    # BEGINNING OF VALUE FUNCTION ITERATION AND PRICE SEARCH                            #
    # --------------------------------------------------------------------------------- #
    
    ExLaborDemand, ExCapitDemand, ExWageBar = 1.0, 1.0, 1.0
    WBiter, Witer, Riter = 1, 1, 1
    
    WageMin, WageMax = 0.9*Wage, 1.1*Wage
    RateMin, RateMax = 0.8*Rate, 1.2*Rate
    WBarMin, WBarMax = 0.9*Wage, 1.0*Wage

    const ValTolerance     = 5e-4    
    const WageTolerance    = 1e-2
    const RateTolerance    = 1e-2
    const WageBarTolerance = 1e-3

    const WIterMax     = 20
    const RIterMax     = 20
    const WBIterMax    = 10
    const ValueIterMax = 100
    
    WageIntegral = 0
    MarketsClear = false 
    Weight = zeros(nx)
   
    while( !MarketsClear )
    
        # ----------------------------------------------------------------------------- #
        # Value Function Iteration                                                      #
        # ----------------------------------------------------------------------------- #
          
        ValueIter = 0;
        ValueDist = 1;
                
        while(ValueDist >= ValTolerance && ValueIter < ValueIterMax) 
            if ValueDist < ValTolerance; end; ValueIter += 1

            ExpVF[:,:] = β * (ρ*VFold[:,1:nx] + (1-ρ)*VFold[:,nx+1:2*nx])

            #@sync @paralell for ii=StateToday            
            @time for ii=StateToday
                        
                Ability2d = rem(ii-1,nx)+1
                Weight[:] = Px[Ability2d,:]
                StatesTom = find(Weight .> 0)
                            
                CapitHi = 1; CapitUB = nk
                ManagHi = 1; ManagUB = nh
                AssetHi = fill(1,nx); AssetPr = fill(1,nx);

                for jj=1:na
                    ExValueHi = -1000.0
                    Resources = (1+Rate-δ)*A[jj]

                    for pp=ManagHi:nh, mm=CapitHi:CapitUB

                        if Ability2d <= nw && (mm + pp > 2); continue; end  
                        if ii <= nx && pp > ManagUB; continue; end  
                        if ii > nx && 1 < pp < nh; continue; end  

                        for ll=StatesTom
   
                            Worker2m = rem(ll-1,nw)+1; Entrepreneur2m = div(ll-1,nw)+1
                            Income = inc(mm,pp,Worker2m,Entrepreneur2m,Wage,WBar,Rate)
                            Resources += Income
                            ValHi[ll] = -1000.0 
                            
                            if Ability2d <= ll; Alb = AssetHi[ll]; else; Alb = 1; end
                              
                            for kk=Alb:na
                                        
                                C = Resources-A[kk]
                                if C < 0; break; end
                                valueProv = u(C) + ExpVF[kk,ll]
                                if valueProv > ValHi[ll]
                                    ValHi[ll] = valueProv
                                    AssetPr[ll] = kk
                                else
                                    break
                                end

                            end

                            Resources -= Income

                        end
                        
                        ExpectedValueProv = dot(ValHi,Weight)
                        if ExpectedValueProv > ExValueHi
                            ExValueHi = ExpectedValueProv
                            CapitHi = mm
                            ManagHi = pp
                            AssetHi[:] = AssetPr
                        end

                    end

                    if ManagHi > 1; CapitUB = min(CapitHi+50,nk); ManagUB = min(ManagHi+50,nh); end
                    VFnew[jj,ii] = ExValueHi
                    Asset[jj,ii,1:nx] = A[AssetHi]
                    Asset[jj,ii,nx+1:end] = A[AssetHi]
                    Capit[jj,ii] = K[CapitHi]
                    Manag[jj,ii] = H[ManagHi]

                end
            end

            ValueDist = maximum(abs.(VFnew-VFold))
            VFold[:] = VFnew
            println(ValueIter," Value Function Norm: ",ValueDist)

        end

        # ------------------------------------------------------------------------------- #
        # Computing Invariant Distribution                                                #
        # ------------------------------------------------------------------------------- #
        
        # Transition Matrix
        TransMat = Trans()

        DistrIter = 0; DistrDistance = 1; DistrTolerance = 1e-15; DistrMaxIter = 10000
        while(DistrDistance > DistrTolerance && DistrIter < DistrMaxIter); DistrIter += 1
            NewDistr[:] = TransMat * OldDistr[:]
            DistrDistance = maximum(abs.(NewDistr - OldDistr))
            OldDistr[:] = NewDistr[:]
        end

        # ------------------------------------------------------------------------------- #
        # Occupation Distribution and Occupation Distribution Conditional on h < 1        #
        # ------------------------------------------------------------------------------- #

        μ[:] = [sum(NewDistr[find(Manag .== H[ii])]) for ii=1:nh]
        λ[:] = μ[:] ./ sum(μ[1:end-1]); λ[end] = 0

        # ------------------------------------------------------------------------------- #
        # Market Clearing                                                                 #
        # ------------------------------------------------------------------------------- #

        # Wage Integral
        WageIntegral = dot(WageDiscount,λ)*Wage
       
        # Capital Demand and Supply
        CapitalDemand = ⋅(NewDistr,Capit)
        CapitalSupply = ⋅(A,[sum(NewDistr[ii:na:end]) for ii=1:na])

        # Labor Demand and Supply
        LaborDemand = ⋅(NewDistr,Capit[:] .* (γ/α) .* (Rate/WBar))
        LaborSupply = ⋅(NewDistr,[sum((1-Manag[m,k+(j-1)*nw+(i-1)*nx])*Xw[l]*Pw[k,l] for l=1:nw) 
                                     for i=1:nz for j=1:ne for k=1:nw for m=1:na])
        
        ExWageBar = WageIntegral - WBar                 # Distance from Wage Bar
        ExCapitDemand = CapitalDemand - CapitalSupply   # Excess Capital Demand
        ExLaborDemand = LaborDemand - LaborSupply       # Excess Labor Demand
    
        # ------------------------------------------------------------------------------- #
        
        if abs(ExWageBar) > WageBarTolerance && WBiter < WBIterMax
            if ExWageBar > WageBarTolerance
                WBarMin = WBar;
                WBar = .5*WBar + .5*WBarMax
                println("     Excess Wage = ",ExWageBar,". -> Increasing WageBar to = ", WBar)
            elseif ExWageBar < -WageBarTolerance
                WBarMax = WBar
                WBar = .5*WBar + .5*WBarMin
                println("     Excess Wage = ",ExWageBar,". -> Decreasing WageBar to = ", WBar)
            end
            WBiter += 1
        elseif abs(ExCapitDemand) > RateTolerance && Riter < RIterMax
            if ExCapitDemand > RateTolerance
                RateMin = Rate;
                Rate = .5*Rate + .5*RateMax
                println("      Excess Wage = ",ExWageBar,". WBar =  ", WBar,".")
                println("   Excess Capital = ",ExCapitDemand,". -> Increasing Rate to ", Rate)
            elseif ExCapitDemand < -RateTolerance
                RateMax = Rate
                Rate = .5*Rate + .5*RateMin
                println("      Excess Wage = ",ExWageBar,". WBar =  ", WBar,".")
                println("   Excess Capital = ",ExCapitDemand,". -> Decreasing Rate to ", Rate)
            end
            WBarMin, WBarMax = 0.9*Wage, 1.0*Wage
            Riter += 1
            WBiter = 1
        elseif abs(ExLaborDemand) > WageTolerance && Witer < WIterMax
            if ExLaborDemand > WageTolerance                              
                WageMin = Wage;                                             
                Wage = .5*Wage + .5*WageMax                                    
                println("      Excess Wage = ",ExWageBar,". WBar =  ", WBar,".")
                println("   Excess Capital = ",ExCapitDemand,". Rate =  ", Rate,".")
                println("     Excess Labor = ",ExLaborDemand,". -> Increasing Wage to ", Wage)
            elseif ExLaborDemand < -WageTolerance                           
                WageMax = Wage                                              
                Wage = .5*Wage + .5*WageMin                                    
                println("      Excess Wage = ",ExWageBar,". WBar =  ", WBar,".")
                println("   Excess Capital = ",ExCapitDemand,". Rate =  ", Rate,".")
                println("     Excess Labor = ",ExLaborDemand,". -> Decreasing Wage to ", Wage)
            end   
            WBarMin, WBarMax = 0.9*Wage, 1.0*Wage
            RateMin, RateMax = 0.8*Rate, 1.2*Rate
            WBar = .99*Wage
            Witer += 1
            Riter = 1
            WBiter = 1
        elseif Witer == WIterMax
            println("Did not converge... Verify price range!")
            println("Rerunning the script with most recent prices may suffice.")
        else
            MarketsClear = true
        end

    end

    # --------------------------------------------------------------------------------- #

    println("Markets Clear:")
    println("Excess Wage Bar = ",ExWageBar)
    println(" Excess Capital = ",ExCapitDemand)
    println("   Excess Labor = ",ExLaborDemand)

    # -------------------
    # Relevant Quantities
    # -------------------

    # Occupation Measures
    OccupationMeasures = zeros(3)
    OccupationMeasures[1] = sum(NewDistr[find(Manag .== 0.0)])
    OccupationMeasures[3] = sum(NewDistr[find(Manag .== 1.0)])
    OccupationMeasures[2] = 1.0-OccupationMeasures[1]-OccupationMeasures[3]

    # --------------------------------------------------------------------------------- #
    # Storing Objects as .CSV                                                           #
    # --------------------------------------------------------------------------------- #
    
    AssetFlat = zeros(na,nn*nn)
    for ii=1:nn
        AssetFlat[:,(1+nn*(ii-1)):(nn+nn*(ii-1))] = Asset[:,:,ii]
    end
    
    writedlm(string(tablesfolder,"A.csv"),                     A)
    writedlm(string(tablesfolder,"K.csv"),                     K)
    writedlm(string(tablesfolder,"H.csv"),                     H)
    writedlm(string(tablesfolder,"Pw.csv"),                    Pw)
    writedlm(string(tablesfolder,"Pe.csv"),                    Pe)
    writedlm(string(tablesfolder,"ValueFunction.csv"),         VFnew)
    writedlm(string(tablesfolder,"Manag.csv"),                 Manag)
    writedlm(string(tablesfolder,"Asset.csv"),                 AssetFlat)
    writedlm(string(tablesfolder,"Capital.csv"),               Capit)
    writedlm(string(tablesfolder,"Labor.csv"),                 Capit .* (η/α) .* (Rate/WBar))
    writedlm(string(tablesfolder,"OccupationMeasures.csv"),    OccupationMeasures)
    writedlm(string(tablesfolder,"Prices.csv"),                [Rate Wage WBar])
    writedlm(string(tablesfolder,"InvariantDistribution.csv"), NewDistr)
    writedlm(string(tablesfolder,"mu.csv"),                    μ)
    writedlm(string(tablesfolder,"lambda.csv"),                λ)

    # --------------------------------------------------------------------------------- #
    #                                       FIN                                         #
    # --------------------------------------------------------------------------------- #

end

main()
