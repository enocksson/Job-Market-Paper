# This script compiles all results found in Section 6 of the paper. Note 
# that this is a bash script. If you are using julia as an alias, it may 
# be necessary to specify the path to the Julia executable.

# Step 1: Run All Counterfactual Experiments
julia main.jl Base
julia main.jl d000
julia main.jl d050
julia main.jl d150
julia main.jl d200
julia main.jl dINF
julia main.jl r000
julia main.jl r050
julia main.jl r150
julia main.jl r200
julia main.jl rINF

# Step 2: Compute Wealth Statistics
julia wealth.jl Base
julia wealth.jl d000
julia wealth.jl d050
julia wealth.jl d150
julia wealth.jl d200
julia wealth.jl dINF
julia wealth.jl r000
julia wealth.jl r050
julia wealth.jl r150
julia wealth.jl r200
julia wealth.jl rINF

# Step 3: Compute Welfare Statistics
julia welfare.jl

# Step 4: Compile Main Tables
julia counterfactuals.jl
