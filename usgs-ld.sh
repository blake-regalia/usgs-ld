#!/bin/bash
trap "exit" INT

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


# download USGS datasets
download() {
	default $# download all
	help $* "Usage: $0 convert [ARGUMENTS]

Arguments:
  all               runs all of the commands below, in order
  gnis	[SUFFIX]    download GNIS data, optionally using SUFFIX, e.g., \"20180201\"
  tnm [DATASET]     download datasets from The National Map, optionally using DATASET, e.g., \"nhd\"
 "

	# args
	case "$1" in
	all)
		download gnis && download tnm
		;;
	gnis)
		shift
		convert download-gnis $*
		;;
	tnm)
		shift
		convert tnm $*
		;;
	*)
		echo -e "Invalid download command \"$1\"\n"
		download --help
	esac
}


# convert source USGS data to RDF
convert() {
	default $# convert all
	help $* "Usage: $0 convert [ARGUMENTS]

Arguments:
  all               runs all of the commands below, in order
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
	default $# triplestore --help
	help $* "Usage: $0 triplestore

Commands:
  up        bring the triplestore online
  down      shut down the container
"

	# commands
	case "$1" in
	up)
		# container already exists
		container=$(docker-compose ps -q marmotta)
		if [ $? -eq 0 ]; then
			# container already running
			if [ "$(docker ps -qf id=$container)" ]; then
				echo "triplestore already running. see it by running: docker-compose ps marmotta"
				exit 1
			fi
		fi

		# pull latest image; bring marmotta up
		docker-compose pull marmotta \
			&& docker-compose up \
				-d \
				--no-recreate \
				marmotta
		;;
	down)
		# stop the container
		docker-compose stop marmotta
		;;
	*)
		echo -e "Invalid triplestore command \"$1\"\n"
		triplestore --help
	esac
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
download)
	shift
	download $*
	;;
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
"-h" | "--help" | *)
	echo "Usage: $0 [COMMAND] [ARGS]

Commands:
  download          download data from USGS
  convert           convert USGS datasets into RDF
  triplestore       launch the triplestore as a service
  import            import triples and geometry into the triplestore
  frontend          launch the HTTP web interface frontend as a service

For more information about a specific command, use: $0 [COMMAND] --help
"
esac

exit 0