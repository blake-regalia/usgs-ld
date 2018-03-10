#!/bin/bash

# relative to script
cd "${BASH_SOURCE%/*}" || exit


# sets a command's default action
default() {
	if [ $1 -eq 0 ]; then
		shift
		echo -e "Running default for '$1' command:\n  $0 $*\n"
		$0 $* && exit 0
	fi
}


# handles showing a command's usage info
help() {
	if [ $# -eq 2 ]; then
		if [[ "$1" == "--help" || "$1" == "-h" ]]; then
			echo "$2"
			exit 0
		fi
	fi
}


# convert source USGS data to RDF
convert() {
	default $# convert all
	help $* "Usage: $0 convert [ARGUMENTS]

Arguments:
  all               runs all of the commands below, in order
  download-gnis	[SUFFIX]
                    download GNIS data, optionally using SUFFIX, e.g., \"20180201\"
  tnm [DATASET]     download datasets from The National Map, optionally using DATASET, e.g., \"nhd\"
  gnis              convert the downloaded GNIS datasets into RDF
  nhd               convert the downloaded NHD datasets into RDF
 "

	# pull latest image; run triplifier
	docker-compose pull triplifier \
		&& docker-compose run \
			--rm \
			triplifier $*
}


# launch the triplestore
triplestore() {
	help $* "Usage: $0 triplestore

No arguments.
"

	# pull latest image; bring marmotta up
	docker-compose pull marmotta \
		&& docker-compose up \
			-d \
			marmotta
}


# import data into the triplestore
import() {
	default $# import all
	help $* "Usage: $0 import [ARGUMENTS]

Arguments:
  all           runs all of the commands below, in order
  ttl [FILES]   imports triples in TTL files, defaulting to all files in the data directory, or FILES if given
  tsv [FILES]   imports geometries in TSV files, defaulting to all files in the data directory, or FILES if given
 "

	# pull latest image; import all data
	docker-compose pull importer \
		&& docker-compose run \
			--rm \
			importer $*
}


# launch the frontend server
frontend() {
	help $* "Usage: $0 frontend [PORT=3001]
  PORT -- the port to run the HTTP interface on
"

	# pull latest image; launch front-end
	docker-compose pull frontend \
		&& docker-compose up \
			-d \
			frontend
}


# commands
case "$1" in
convert)
	shift
	convert $*
	;;
triplestore)
	shift
	triplestore $*
	;;
import)
	shift
	import $*
	;;
frontend)
	shift
	frontend $*
	;;
*)
	help $* "Usage: $0 [COMMAND] [ARGS]

Commands:
  convert           convert USGS datasets into RDF
  triplestore       launch the triplestore as a service
  import            import triples and geometry into the triplestore
  frontend          launch the HTTP web frontend as a service

For more information about a specific command, use: $0 [COMMAND] --help
"
esac

exit 0