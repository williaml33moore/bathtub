#!/usr/bin/perl

# Check Questa output log for error reports.
#
# Questa outputs simulation results in a separate log file.
# This script reads and parses that file and dies with a nonzero return code if the log file indicates an error in the simulation.
# This script also reports an error if it encounters an improperly formatted line (reverse-engineered).
# This script also reports an error if it fails to find a line which positively indicates there were 0 errors, e.g. if the file were empty.

$stats_log_file_name = "qrun.out/stats_log";

-r $stats_log_file_name or die "---\n$0: Can't read file $stats_log_file_name";

open($stats_log_file_handle, "<", $stats_log_file_name) or die "---\n$0: Can't open file $stats_log_file_name";

$ok_count = 0;
while (<$stats_log_file_handle>) {
    if (/^\s*\w+:\s+Errors:\s+(\d+),\s+Warnings:\s+\d+\s*$/) {
        if ($1 == 0) {
            $ok_count++;
        } else {
            die "---\n$0: Error reported in $stats_log_file_name:\n$_";
        }
    } else {
        die "---\n$0: $stats_log_file_name line is not properly formatted:\n$_";
    }
}

close ($stats_log_file_handle) or die "---\n$0: Can't close file $stats_log_file_name";

$ok_count > 0 or die "---\n$0: File $stats_log_file_name is not properly formatted";

exit 0;
