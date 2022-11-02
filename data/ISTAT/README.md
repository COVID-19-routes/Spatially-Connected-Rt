# ISTAT

This directory contains code to fetch and preprocess data from the Italian National Institute of Statistics (ISTAT, Istituto nazionale di statistica) that is not mirrored in this repository.

## ISTAT 2011 mobility data

In occasion of the 2011 census (reference date 2011-10-09) ISTAT compiled an origin–destination matrix pertaining to travel for work or study, with a spatial resolution at the municipality level.

### References

- Web page: [MATRICI DEL PENDOLARISMO](https://www.istat.it/it/archivio/139381) (in italian)
- Data bundle: [matrici_pendolarismo_2011.zip](http://www.istat.it/storage/cartografia/matrici_pendolarismo/matrici_pendolarismo_2011.zip)

### Code

The python script `fetch_mobility.py` will
- download the data bundle `matrici_pendolarismo_2011.zip`,
- parse the mobility matrix,
- save the parsed data in columnar [Apache Parquet format](https://parquet.apache.org):
  - `matrici_S.parquet` base data, stratified by sex, reason of travel (study/work), household (family/community);
  - `matrici_L.parquet` detailed matrix, stratified also by means of transportation, start time and duration of travel.
