#!/usr/bin/perl
#
# © 2016 Meta Mesh Wireless Communities. All rights reserved.
# Licensed under the terms of the MIT license.
#
# AUTHORS
# * Jason Khanlar
#

use strict;
use warnings;

sub usage {
    print <<USAGE;
Usage: ./mm-mac2ipv4.pl <MAC address>
Usage: ./mm-mac2ipv4.pl --list-all

Examples:
        ./mm-mac2ipv4.pl DC:9F:DB:CE:13:57
        ./mm-mac2ipv4.pl DC-9F-DB-CE-13-57
        ./mm-mac2ipv4.pl DC 9F DB CE 13 57
        ./mm-mac2ipv4.pl dc 9f db ce 13 57
USAGE
    exit 1;
}

sub list_all {
    my @mac = (0xDC, 0x9F, 0xDB, 0x00, 0x00, 0x00);
    my @ip = (100, 64, 0, 0);

    for my $i (0 .. 255) {
        $mac[3] = $i;
        
        # Format IP address
        my $ip = sprintf('%d.%d.%d.%d', $ip[0], $i % 64 + 64, $ip[2], $ip[3]);

        # Format MAC address
        my $mac = sprintf('%02X:%02X:%02X:%02X:%02X:%02X', @mac);

        ## Output matching IP address and MAC address
        printf("%-15s => %s\n", $ip, $mac);
    }
    exit;
}

# Check for --list-all, otherwise proceed

if (@ARGV == 1 and $ARGV[0] =~ m/^-/) {
    if ($ARGV[0] eq '--list-all') { list_all(); }
    else { usage(); }
}

# Proceed if not --list-all

# # of arguments should be 1 or 6
# 1 -> DC:9F:DB:CE:13:57 -or- DC-9F-DB-CE-13-57
# 6 -> DC 9F DB CE 13 57

if (@ARGV == 1) {
    # Split 1 argument into 6 separate arguments, 1 for each octet
    @ARGV = split('[:-]', $ARGV[0]);
}

if (@ARGV != 6) { usage(); }

my @mac = @ARGV;
$_ = uc for @mac;

# Ensure nothing

# Convert last three hexadecimal octets to decimal values
my @ip = (100, hex($mac[3]) % 64 + 64, hex($mac[4]), hex($mac[5]));

print "$ip[0].$ip[1].$ip[2].$ip[3]\n";
