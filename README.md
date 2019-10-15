# Job-Market-Paper

## Occupational Choice Under Compensation Frictions

This repository contains code files used to compile the results found in Section 6 of the paper. The scripts are written in `julia-0.6.2`. More recent versions of `Julia` may not work.

### Download

The repository can be downloaded by running the following commands in a terminal

```
mkdir -p ~/Downloads && cd ~/Downloads
git clone https://github.com/enocksson/Job-Market-Paper
```
### Replication

Main results reported in Table 6.1 and Table 6.2 are compiled using `main.jl`. The script requires specifying a folder name as an argument. The folder name has to be one of the following:

  - `Base (Baseline Parameterization)`
  - `d000 (Eliminating d)`
  - `d050 (50% reduction d)`
  - `d150 (50% increase d)`
  - `d200 (100% increase d)`
  - `dINF (Eliminating dual work)`
  - `r000 (Eliminating dual work)`
  - `r050 (50% reduction rho)`
  - `r150 (50% increase rho)`
  - `r200 (100% increase rho)`
  - `rALL (Full flexibility)`

For example, to compile results using the baseline paramaterization, run ```julia main.jl Base```. To compile Tables 5 and 6 you also need to compile welfare and wealth statistics. This can be done (for example) by running

```julia wealth.jl [folder name]```

```julia welfare.jl ```

Finally, to compile Table 5 and Table 6, run

```julia counterfactuals.jl```

### Warning

Running the program takes time. The script can easily be adjusted to take advantage of parallelization. If doing this it is advisable to exploit a high performance computing system where a larger number of cores can be exploited. However, an alternative (simpler) method is to run each counterfactual simultaneously on seperate computing nodes.

### Figures

Figures can be compiled in a similar fashion. Again, for the baseline parameterization, run
```
julia figures.jl BL
```

## Final Comments

Running the file `full.sh` will compile all results found in the paper.


