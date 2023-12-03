#!/usr/bin/env python
import re
import sys
from pathlib import Path
from typing import Any, Optional, TypeAlias

import click
import h5py  # type: ignore
import numpy as np
import numpy.typing as npt
from packaging.version import Version, parse

# type hints
NDArrayFloat: TypeAlias = npt.NDArray[np.floating[Any]]

# reference file pattern
REF = re.compile(r".*-(.+)-ref")


def version(pth: Path) -> Version:
    mo = REF.fullmatch(pth.stem)
    if mo is None:
        raise ValueError(f"Unable to find version number in {pth.stem}")
    ver = parse(mo.group(1))
    return ver


def find_last_rev(pth: Path) -> Optional[Path]:
    glob = pth.with_stem(pth.stem + "-?*-ref").name
    k: Optional[Path] = None
    for k in sorted(pth.parent.glob(glob), key=version):
        pass
    return k


def max_err_nulp(val: NDArrayFloat, ref: NDArrayFloat) -> float:
    if np.shape(val) != np.shape(ref):
        raise ValueError("Input arguments must have same shape")
    if np.any(np.isnan(val) != np.isnan(ref)):
        raise ValueError("Input arguments must have same NaN pattern")
    return np.nanmax(np.abs((val - ref) / np.spacing(ref)))


def comp_data(val: h5py.Dataset, ref: h5py.Dataset, verbose: bool) -> None:
    if np.shape(val) != np.shape(ref):
        raise ValueError("Input arguments must have same shape")
    if not np.can_cast(val.dtype, ref.dtype, "safe"):
        raise ValueError("input arguments have incompatible dtypes")

    # convert to numpy ndarrays
    nval = val.astype(ref.dtype)[()]
    nref = ref[()]

    # first check if equal
    if np.array_equal(
        nval,
        nref,
        equal_nan=True if np.issubdtype(ref.dtype, np.inexact) else False,
    ):
        # equal
        click.secho("  {:15}: equal".format(ref.name), dim=True) if verbose else None
    else:
        # different
        match ref.attrs["MATLAB_class"].decode():
            case "single" | "double":
                nulp = max_err_nulp(nval, nref)
                maxp = 1 + np.floor(np.log2(nulp))
                # FIXME: is the below assumption valid in general?
                nsignificand = np.finfo(ref).nmant + 1
                err_r = 2 ** (maxp - nsignificand)
                click.secho(
                    f"• {ref.name:15}: 2**({maxp:.0f} - {nsignificand:d})"
                    f" = {err_r:.1g}",
                    fg="red" if maxp > nsignificand // 2 else None,
                )
            case all:
                click.secho(
                    "  {:15}: differs (MATLAB class {})".format(ref.name, all),
                    fg="red",
                    bold=True,
                )


def comp(val: Any, ref: Any, verbose: bool) -> None:
    if ref.name.startswith("/#"):
        click.secho(f"- skipping {ref.name}", dim=True)
        return
    match ref:
        case h5py.Dataset():
            comp_data(val, ref, verbose)
        case h5py.Group():
            for k in ref:
                try:
                    comp(val[k], ref[k], verbose)
                except KeyError:
                    click.secho(f"✘ {ref[k].name:15}: missing", fg="red")
        case _:
            assert False, ref.name


def get_user_block(pth: Path) -> str:
    with h5py.File(pth, "r") as h5:
        blksize = h5.userblock_size
    with open(pth, "rb") as fp:
        blk = fp.read(blksize)
    return blk.split(b"\x00")[0].decode()


@click.command()
@click.argument("path", type=click.Path(path_type=Path, exists=True, dir_okay=True))
@click.option("--verbose", is_flag=True)
def main(path: Path, verbose: bool) -> None:
    """validate results file against latest saved reference results"""

    refpth = find_last_rev(path)
    if refpth is None:
        click.secho(f"Reference file for {path} not found", bold=True)
        sys.exit(1)
    assert refpth is not None

    try:
        click.secho(f"Validate: {path}", fg="blue")
        click.echo(f"  {get_user_block(path)}")
        click.secho(f"Reference: {refpth}", fg="blue")
        click.echo(f"  {get_user_block(refpth)}")
    except OSError as exc:
        msg = str(exc)
        sys.exit(msg)

    with h5py.File(refpth, "r") as ref, h5py.File(path, "r") as new:
        comp(new, ref, verbose)
        if extra := set(new) - set(ref):
            click.secho(f"Extra keys in validate: {', '.join(extra)}", bold=True)


if __name__ == "__main__":
    main()
