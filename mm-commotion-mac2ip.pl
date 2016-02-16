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
Usage: ./mm-commotion-mac2ip.pl <MAC address>
Usage: ./mm-commotion-mac2ip.pl --list-all

Examples:
        ./mm-commotion-mac2ip.pl DC:9F:DB:CE:13:57
        ./mm-commotion-mac2ip.pl DC-9F-DB-CE-13-57
        ./mm-commotion-mac2ip.pl DC 9F DB CE 13 57
        ./mm-commotion-mac2ip.pl dc 9f db ce 13 57
USAGE
}

sub list_all {
    my $mac1 = 0xDC;
    my $mac2 = 0x9F;
    my $mac3 = 0xDB;
    my $mac4 = 0x00;
    my $mac5 = 0x00;
    my $mac6 = 0x00;

    my $ip1 = 100;
    my $ip2 = 64;
    my $ip3 = 0;
    my $ip4 = 0;

    for my $i (0 .. 255) {
        $mac4 = $i;
        
        # Format IP address
        my $ip = sprintf('%d.%d.%d.%d', $ip1, $i % 64 + 64, $ip3, $ip4);

        # Format MAC address
        my $mac = sprintf('%02X:%02X:%02X:%02X:%02X:%02X', $mac1, $mac2, $mac3, $mac4, $mac5, $mac6);

        ## Output matching IP address and MAC address
        printf("%-15s => %s\n", $ip, $mac);
    }
}

# Check for --list-all, otherwise proceed

if (@ARGV == 1 and $ARGV[0] =~ '-.*') {
    if ($ARGV[0] eq '--list-all') { list_all(); }
    else { usage(); }
    exit;
}

# Proceed if not --list-all

# Get # of arguments passed to this script
my $args=@ARGV;

# # of arguments should be 1 or 6
# 1 -> DC:9F:DB:CE:13:57 -or- DC-9F-DB-CE-13-57
# 6 -> DC 9F DB CE 13 57

if ($args == 1) {
    # Split 1 argument into 6 separate arguments, 1 for each octet
    @ARGV = split('[:-]', $ARGV[0]);
} elsif ($args != 6) {
    pod2usage(-exitval => 1);
}

my $mac1 = uc $ARGV[0];
my $mac2 = uc $ARGV[1];
my $mac3 = uc $ARGV[2];
my $mac4 = uc $ARGV[3];
my $mac5 = uc $ARGV[4];
my $mac6 = uc $ARGV[5];

# Ensure that we are working with the correct large MAC address block
# DC-9F-DB

if ($mac1 ne "DC" || $mac2 ne "9F" || $mac3 ne "DB") {
    print "Unsupported MAC address. Only Ubiquiti-assigned MAC addresses beginning with DC:9F:DB are supported.\n";
    exit 1;
}

# Convert last three hexadecimal octets to decimal values
my $ip1=100;
my $ip2=hex($mac4);
my $ip3=hex($mac5);
my $ip4=hex($mac6);

$ip2 = $ip2 % 64 + 64;

print "$ip1.$ip2.$ip3.$ip4\n";
