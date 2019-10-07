# This script compiles all results found in the paper. 
# Note that this is a bash script. If you are using 
# julia as an alias, it may be necessary to specify 
# the path to the Julia executable.

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

julia main.jl sloo
julia main.jl shii
julia main.jl ploo
julia main.jl phii

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

# Step 3: Compute General Entropy Wealth Statistics
julia entropy.jl

# Step 4: Compute Welfare Statistics
julia welfare.jl

# Step 5: Compile Figures
julia figures.jl Base
julia figures.jl d000
julia figures.jl d050
julia figures.jl d150
julia figures.jl d200
julia figures.jl dINF
julia figures.jl r000
julia figures.jl r050
julia figures.jl r150
julia figures.jl r200
julia figures.jl rINF

# Step 6: Compile Main Tables
julia counterfactuals.jl

# Step 7: Compile Robustness Table
julia robustness.jl
