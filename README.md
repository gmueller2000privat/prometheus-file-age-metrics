# prometheus-file-age-metrics

A Prometheus Textfile Collector Bash script that generates metrics on file age. In
particular, it creates metrics on outdate and up-to-date files. What is "old" is
defined by you in minutes.

This script as originally developed to ensure that important database dumps are
getting updated. In case they're not an alert would be sent.

This script supports checking the age of multiple files at once. In this case the
metric prefix (-p) and maximum age (-a) will be the same for all files.

# Prerequisites

The following things are needed:
* Bash
* Cron or some other tool that runs this script automatically to update the metrics
* Node Exporter is configured to use Textfile Collector
* Node Exporter is pointed to the correct Textfile Collector directory
* Prometheus that can scrape the data this script produces

# Usage

Basic usage:

    create-file-age-metrics.sh -a <max_age_in_minutes> [-p <metric_prefix>] -f <file> [-f <file>]

Here's an example:

    create-file-age-metrics.sh -a 2880 -p backups -f /var/backups/local/first_db.sql.gz -f /var/backups/local/second_db.sql.gz > /var/lib/node_exporter/textfile_collector/backups_file_age_metrics.prom

In this case the maximum age (-a) is set to 2880 seconds (=2 days), two database dumps are checked (-f) and results are stored in a .prom file in the Textfile Collector directory. 

You can safely run this script multiple times, as long as you

1. Use a different metric prefix (-p)
2. Save the results in a different .prom file

# Metrics

The exact output from this script depends on the files as well as the prefix (-p)
you set. By default prefix is "default". In the below example it was set to
"backups":
```
# HELP backups_outdated_files_total Number of outdated files
# TYPE backups_outdated_files_total gauge
backups_outdated_files_total gauge 0
# HELP backups_uptodate_files_total Number of up-to-date files
# TYPE backups_uptodate_files_total gauge
backups_uptodate_files_total gauge 3
# HELP backups_failed_files_total Number of failed files
# TYPE backups_failed_files_total gauge
backups_failed_files_total gauge 0
```
