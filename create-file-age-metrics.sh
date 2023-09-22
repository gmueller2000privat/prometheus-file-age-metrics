#!/bin/bash
#
# Create prometheus metrics about one or more files that have not been modified
# in last <x> minutes. This can be useful for things like making sure that
# file-based backups are working as expected.
#
usage() {
    echo "Usage: $0 -a <max_age_in_minutes> [-p <metric_prefix>] -f <file> [-f <file>]"
    exit 1
}

while getopts "a:f:p:" o; do
    case "${o}" in
        a)
            MAX_AGE=${OPTARG}
            ;;
        p)
            METRIC_PREFIX=${OPTARG}
            ;;
        f)
	    FILES+=("$OPTARG")
	    ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND -1))

if [ "${MAX_AGE}" = "" ]; then
    echo "Error: max age parameter (-a) missing"
    usage
fi

if [ "${FILES}" = "" ]; then
    echo "Error: file parameter (-f) missing"
    usage
fi

if [ "${METRIC_PREFIX}" = "" ]; then
    METRIC_PREFIX="default"
fi

# Ensure that all files are available before running
for FILE in "${FILES[@]}"; do
    test -r $FILE
    if [ $? -ne 0 ]; then
        echo "ERROR: file $FILE not found!"
	exit 1
    fi
done

# Initialize metrics
OUTDATED=0
UP_TO_DATE=0
FAILED=0

for FILEPATH in "${FILES[@]}"; do
    DIRNAME=$(dirname $FILEPATH)
    FILENAME=$(basename $FILEPATH)

    find $DIRNAME -name $FILENAME -mmin +$MAX_AGE|grep $FILENAME #/dev/null 2>&1
    if [ $? -eq 1 ]; then
        UP_TO_DATE=$((UP_TO_DATE+1))
    elif [ $? -ne 0 ]; then
        OUTDATED=$((OUTDATED+1))
    else
        FAILED=$((FAILED+1))
    fi
done

echo "# HELP ${METRIC_PREFIX}_outdated_files_total Number of outdated files"
echo "# TYPE ${METRIC_PREFIX}_outdated_files_total gauge"
echo "${METRIC_PREFIX}_outdated_files_total ${OUTDATED}"

echo "# HELP ${METRIC_PREFIX}_uptodate_files_total Number of up-to-date files"
echo "# TYPE ${METRIC_PREFIX}_uptodate_files_total gauge"
echo "${METRIC_PREFIX}_uptodate_files_total ${UP_TO_DATE}"

echo "# HELP ${METRIC_PREFIX}_failed_files_total Number of failed files"
echo "# TYPE ${METRIC_PREFIX}_failed_files_total gauge"
echo "${METRIC_PREFIX}_failed_files_total ${FAILED}"
