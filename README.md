# USGS-LD

This project bundles up the triplifier, triplestore, bulk-importer and frontend interface for the GNIS and NHD.

## Requirements
 - 64-bit Linux w/ `bash`:
 - Docker CE - [Installation guide for Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04) (recommend making docker work without sudo, see Step 2)
 - Docker Compose - [Installation guide for Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-install-docker-compose-on-ubuntu-16-04)

## CLI Usage
From the main directory, use `./run` to manage services:

```shell
$ ./run --help
Usage: ./run [COMMAND] [ARGS]

Commands:
  download          download data from USGS
  convert           convert USGS datasets into RDF
  triplestore       launch the triplestore as a service
  import            import triples and geometry into the triplestore
  frontend          launch the HTTP web interface frontend as a service

For more information about a specific command, use: ./run [COMMAND] --help

```

## Getting Started
To get the entire USGS-LD up and running as-is, the following setup procedure will initialize and load all the data, as well as start the services with default settings:

```shell
./run download all \
	&& ./run convert all
	&& ./run triplestore up
	&& ./run import all
	&& ./run frontend up
```

## Updating Datasets
Changes to the source datasets require regenerating the entire RDF dataset.

If you only need to update the GNIS:
```shell
# remove old GNIS data first
rm -rf data/*/gnis

# download new datasets, convert them, then load everything
./run download gnis \
	&& ./run convert gnis \
	&& ./run triplestore down \
	&& ./run triplestore up \
	&& ./run import all
```

If you only need to update the NHD:
```shell
# remove old NHD data first
rm -rf data/*/nhd

# download new datasets, convert them, then load everything
./run download nhd \
	&& ./run convert nhd \
	&& ./run triplestore down \
	&& ./run triplestore up \
	&& ./run import all
```

<!-- Since there is no way to 'update' the triplestore, the script command `triplestore stage` will launch a new container (with an empty database) alongside the triplestore container currently running. This allows keeping the public endpoint online without interruption. When the import process has finished on the new container, `triplestore swap` will prepare and launch the new container, will kill and delete the triplestore container that is currently running and then  -->