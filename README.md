# Job-Market-Paper

## Occupational Choice Under Compensation Frictions

This repository contains code files used to compile the results found in section 6 of the paper. The scripts are written in `julia-0.6.2`. More recent versions of `Julia` may not work.

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
  - `rINF (Full flexibility)`




