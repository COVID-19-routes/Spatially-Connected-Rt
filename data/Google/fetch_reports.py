#!/usr/bin/env python3
import tempfile
import zipfile

import click
import requests

URL = "https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip"


def download(url, fp):
    with requests.get(url, stream=True) as resp:
        resp.raise_for_status()
        for chunk in resp.iter_content(chunk_size=None):
            if chunk:
                fp.write(chunk)


@click.command()
def main():

    click.echo(f"Download {URL}")
    with tempfile.TemporaryFile() as fp:
        download(URL, fp)
        fp.seek(0)
        with zipfile.ZipFile(fp, "r") as zc:
            for pth in [
                "2020_IT_Region_Mobility_Report.csv",
                "2021_IT_Region_Mobility_Report.csv",
            ]:
                zc.extract(pth)
                click.echo(f"Wrote {pth}")


if __name__ == "__main__":
    main()
