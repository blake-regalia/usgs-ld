# USGS-LD

This project bundles up the triplifier, triplestore, bulk-importer and frontend interface for the GNIS and NHD.

## Requirements
For 64-bit Linux:
 - Docker CE - [Installation guide for Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04) (recommend making docker work without sudo, see Step 2)
 - Docker Compose - [Installation guide for Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-16-04)

## CLI Usage
From the main directory, use `./usgs-ld.sh` to manage services:

```shell
$ ./usgs-ld.sh --help
Usage: ./usgs-ld.sh [COMMAND] [ARGS]

Commands:
  download          download data from USGS
  convert           convert USGS datasets into RDF
  triplestore       launch the triplestore as a service
  import            import triples and geometry into the triplestore
  frontend          launch the HTTP web interface frontend as a service

For more information about a specific command, use: ./usgs-ld.sh [COMMAND] --help

```

## Getting Started
To get the entire USGS-LD up and running as-is, the following setup procedure will initialize and load all the data, as well as start the services with default settings:

```shell
./usgs-ld.sh download all \
	&& ./usgs-ld.sh convert all
	&& ./usgs-ld.sh triplestore up
	&& ./usgs-ld.sh import all
	&& ./usgs-ld.sh fronted up
```
