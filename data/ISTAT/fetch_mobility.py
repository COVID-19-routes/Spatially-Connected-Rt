#!/usr/bin/env python3
import sys
import zipfile
from collections import defaultdict
from pathlib import Path

import pandas as pd
import requests

URL = "https://www.istat.it/storage/cartografia/matrici_pendolarismo/matrici_pendolarismo_2011.zip"
LCL = Path("matrici_pendolarismo_2011.zip")
L_STRATA = Path("matrici_L")
S_STRATA = Path("matrici_S")


def download(url, path):
    with requests.get(url, stream=True) as resp:
        resp.raise_for_status()
        with open(path, "wb") as fp:
            for chunk in resp.iter_content(chunk_size=None):
                if chunk:
                    fp.write(chunk)


def read_pendo(path):
    mpath = "MATRICE PENDOLARISMO 2011/matrix_pendo2011_10112014.txt"
    with zipfile.ZipFile(path, "r") as zc:
        with zc.open(mpath) as fp:
            df = pd.read_table(
                fp,
                sep=r"\s+",
                dtype=defaultdict(pd.CategoricalDtype, n_est=float, n="Int64"),
                header=None,
                names=[
                    "strata",
                    "household",
                    "r_province",
                    "r_municipality",
                    "sex",
                    "reason",
                    "type",
                    "d_province",
                    "d_municipality",
                    "d_nation",
                    "transportation",
                    "time",
                    "duration",
                    "n_est",
                    "n",
                ],
                na_values=["+", "ND", "000"],
                keep_default_na=False,
            )

    assert df["r_municipality"].cat.categories.is_monotonic_increasing
    df["d_municipality"] = df["d_municipality"].cat.reorder_categories(
        df["r_municipality"].cat.categories
    )

    assert df["r_province"].cat.categories.is_monotonic_increasing
    df["d_province"] = df["d_province"].cat.reorder_categories(
        df["r_province"].cat.categories
    )

    df["household"] = df["household"].cat.rename_categories(
        {"1": "family", "2": "community"},
    )
    df["sex"] = df["sex"].cat.rename_categories(
        {"1": "male", "2": "female"},
    )
    df["reason"] = df["reason"].cat.rename_categories(
        {"1": "study", "2": "work"},
    )
    df["type"] = df["type"].cat.rename_categories(
        {"1": "local", "2": "national", "3": "international"},
    )
    df["transportation"] = df["transportation"].cat.rename_categories(
        {
            "01": "train",
            "02": "tramway",
            "03": "metro",
            "04": "public bus urban",
            "05": "public bus suburban",
            "06": "company/school bus",
            "07": "private car driver",
            "08": "private car passenger",
            "09": "motorcycle",
            "10": "bicycle",
            "11": "other",
            "12": "pedestrian",
        }
    )

    df["time"] = df["time"].cat.rename_categories(
        {
            "1": "<07:15",
            "2": "[07:15, 08:14]",
            "3": "[08:15, 09:14]",
            "4": ">=9.15",
        },
    )
    df["duration"] = df["duration"].cat.rename_categories(
        {
            "1": "<=15 min",
            "2": "[16 min, 30 min]",
            "3": "[31 min, 60 min]",
            "4": ">60 min",
        },
    )

    #
    # sanity checks, see <https://www.istat.it/it/archivio/139381>
    #
    assert (df["strata"] == "L").sum() == 3_887_617
    assert (df["strata"] == "S").sum() == 988_625

    assert df["n"].sum() == 28_871_447
    assert df.loc[df["household"] == "family", "n"].sum() == 28_852_721
    assert df.loc[df["household"] == "community", "n"].sum() == 18_726

    assert df.loc[df["strata"] == "L", "n"].isna().all()
    assert (
        df.loc[df["strata"] == "L", ["transportation", "time", "duration"]]
        .notna()
        .all(axis=None)
    )
    assert (
        df.loc[df["strata"] == "S", ["transportation", "time", "duration"]]
        .isna()
        .all(axis=None)
    )

    # check type is local
    mask = df["type"] == "local"
    assert (
        mask
        == (df["r_municipality"] == df["d_municipality"])
        & (df["r_province"] == df["d_province"])
    ).all()
    assert df.loc[mask, "d_nation"].isna().all()

    # check type is national
    mask = df["type"] == "national"
    assert df.loc[mask, "d_nation"].isna().all()

    # check type is international
    mask = df["type"] == "international"
    assert df.loc[mask, "d_nation"].notna().all()

    return df


def main():
    print(f"Download {URL}", file=sys.stderr)
    download(URL, LCL)

    print("Parse data", file=sys.stderr)
    pendo = read_pendo(LCL)

    # save "L" strata
    pendo.loc[pendo["strata"] == "L"].drop(
        columns=["strata", "n"],
    ).to_parquet(opth := L_STRATA.with_suffix(".parquet"))
    print(f"Wrote {opth}", file=sys.stderr)

    # save "S" strata
    pendo.loc[pendo["strata"] == "S"].drop(
        columns=["strata", "transportation", "time", "duration"],
    ).to_parquet(opth := S_STRATA.with_suffix(".parquet"))
    print(f"Wrote {opth}", file=sys.stderr)


if __name__ == "__main__":
    main()
