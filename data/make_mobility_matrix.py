#!/usr/bin/env python3
"""
This file creates the mobility matrix C^0 for the 7 provinces of Veneto
"""

import sys

import h5py
import pandas as pd

# raw mobility matrix in parquet format
INPATH = "ISTAT/matrici_S.parquet"
# mobility submatrix in hdf5 format
OUTPATH = "mobility.hdf5"

# provinces for which the mobility matrix has to be formed
pro = pd.Index(["023", "024", "025", "026", "027", "028", "029"])


def main():
    mmraw = pd.read_parquet(INPATH)

    # form national mobility matrix as pandas dataframe
    mm = (
        mmraw.groupby(["d_province", "r_province"], observed=False)["n"].sum().unstack()
    )
    assert mm.notna().all(axis=None)

    # extract submatrix as numpy double
    odv = mm.loc[pro, pro].astype("float64").to_numpy()

    # create column stochastic matrix
    pdv = odv / odv.sum(axis=0)

    # save in hdf5 format
    with h5py.File(OUTPATH, "w") as h5out:
        h5out.create_dataset("OD_V", data=odv, track_times=False)
        h5out.create_dataset("P_V", data=pdv, track_times=False)
    print(f"Wrote '{OUTPATH}'", file=sys.stderr)


if __name__ == "__main__":
    main()
