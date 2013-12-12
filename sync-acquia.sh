#!/bin/sh

# Holds the help information displayed when the -h flag is added
usage="
sync
============

Syncs database, files with an acquia site

./ocr.sh -f\"my file.pdf\" -p5 -d72


OPTIONS
    -s
        Source (if not specified as the argument)

    -d
        Destination drush alias. Not required if run with in site dir.
        
    -c
        Command to use for drush. Defaults to 'drush', but you could use ~/drush/drush



RETURN
    This script will print a JSON array to the screen containing:
    {
        text: <THE_TEXT_OUTPUT_OF_THE_DOC>,
        mimetype: application/pdf|application/msword|...,
        utility: convert|pdftotext|ocr,
        pages: <NUMBER_OF_PAGES>
    }
"

# Settings and default options
SOURCE="$1"
DEST="@self"
DATE=`date +%Y-%m-%d_%H-%M`
DRUSH="drush"

# Get the arguments
while getopts "f:p:d:h" option; do
  case "${option}" in
    s) SOURCE=${OPTARG};;
    d) DEST=${OPTARG};;
    c) DRUSH=${OPTARG};;
    h) echo "$usage"; exit 2;;
  esac
done

# Database
$DRUSH $DEST sql-dump > "$DATE-local.sql" 
echo "Local backup saved to $DATE-local.sql"
$DRUSH $SOURCE sql-dump > "$DATE-remote.sql"
echo "Remote backup saved to $DATE-local.sql"
$DRUSH $DEST sql-drop -y
$DRUSH $DEST sqlc < "$DATE-remote.sql"
$DRUSH $DEST rr
$DRUSH $DEST cc all
echo "Remote backup loaded, caches cleared"
$DRUSH $DEST uli


# See https://docs.acquia.com/articles/synchronizing-acquia-cloud-with-local-environment
#drush rsync @presales.prod:%files/ @presales.local:%files