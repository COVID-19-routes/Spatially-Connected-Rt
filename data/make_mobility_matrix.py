#!/usr/bin/env python3
"""
This file creates the mobility matrix C^0 for the 7 provinces of Veneto
"""

import click
import pandas as pd
from scipy.io import savemat

# raw mobility matrix in parquet format
INPATH = "ISTAT/matrici_S.parquet"
# mobility submatrix in MATLAB(R) format
OUTPATH = "mobility.mat"

# provinces for which the mobility matrix has to be formed
pro = pd.Index(["023", "024", "025", "026", "027", "028", "029"])


@click.command()
def main():

    mmraw = pd.read_parquet(INPATH)

    # form national mobility matrix as pandas dataframe
    mm = mmraw.groupby(["d_province", "r_province"])["n"].sum().unstack()
    assert mm.notna().all(axis=None)

    # extract submatrix as numpy double
    odv = mm.loc[pro, pro].astype("float64").to_numpy()
    # create column stochastic matrix
    pdv = odv / odv.sum(axis=0)

    # save in MATLAB(R) format
    savemat(OUTPATH, {"OD_V": odv, "P_V": pdv})
    click.echo(f"Wrote '{OUTPATH}'")


if __name__ == "__main__":
    main()
