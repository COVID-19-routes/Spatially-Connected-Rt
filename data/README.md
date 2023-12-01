# Data

This directory contains the curated data used for the manuscript along with auxiliary scripts and programs.
All `*.mat` files are in binary MATLAB® -v7.3 format.

## `google-data.mat`

This file contains a preprocessed subset of the Community Mobility reports pertaining to the Veneto provinces, see SM, *6 Setup of the application to the epidemic in Veneto – Generation of the contact matrix*.

To recreate this file
- launch `fetch_reports.py` in the `Google` subdirectory,
- run the MATLAB® script `extract_google_data.m` in this directory.

## `mobility.hdf5`

This file contains the `C^0` contact matrix, see SM, *6 Setup of the application to the epidemic in Veneto – Generation of the contact matrix*.

To recreate this file
- launch `fetch_mobility.py` in the `ISTAT` subdirectory,
- launch `make_mobility_matrix.py` in this directory.

This file was created with HDF5 ver. 1.12.2

## `synthetic_rt.mat`

R_t for the synthetic example, see SM, *5 Setup of the synthetic example*.
