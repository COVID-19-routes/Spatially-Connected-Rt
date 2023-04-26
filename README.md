# Spatially explicit reproduction numbers from incidence and mobility data

This repository contains code and data described in

C. Trevisin, E. Bertuzzo, D. Pasetto, L. Mari, S. Miccoli, R. Casagrandi, M. Gatto, A. Rinaldo.
Spatially explicit reproduction numbers from incidence and mobility data.
*Proc Natl Acad Sci USA*, in press (2023).

## Repository structure

- The top level directory contains MATLAB® scripts for running all the analyses described in the above paper and generating the relevant figures:

	- `run_synthetic.m`
	- `run_SMC.m`

  Please refer to the comments inside the scripts for more information.

- The `private` directory contains the MATLAB® implementation of the models described in the paper along with auxiliary functions for generating the figures.

- The `data` directory contains input data for the models and routines for data ingestion from the primary sources.

- The `results` is an empty directory in which the driver scripts will store results and intermediate results.

## Cross reference

The following table contains a cross reference between the figures in the paper and the figures produced by the driver scripts.

| Paper Figure # | script    | parameters                          | window   |
|--------|-------------------|-------------------------------------|----------|
| Fig. 1 | `run_synthetic.m` |                                     | Figure 2 |
| Fig. 2 | `run_SMC.m`       | `purpose = 'make_figure_incidence'` | Figure 1 |
| Fig. 3 | `run_SMC.m`       | `purpose = 'run_veneto'`            | Figure 1 |
| Fig. 4 | `run_SMC.m`       | `purpose = 'run_veneto'`            | Figure 5 |
| Fig. 5 | `run_SMC.m`       | `purpose = 'run_veneto'`            | Figure 4 |
| Fig. 6 | `run_SMC.m`       | `purpose = 'run_veneto'`            | Figure 2 |
