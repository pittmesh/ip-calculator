#!/usr/bin/perl
#
# © 2016 Meta Mesh Wireless Communities. All rights reserved.
# Licensed under the terms of the MIT license.
#
# AUTHORS
# * Jason Khanlar
#

=pod

 Usage: ./mm-commotion-mac2ip.pl <MAC address>
 Usage: ./mm-commotion-mac2ip.pl --list-all

 examples:
   ./mm-commotion-mac2ip.pl DC:9F:DB:CE:13:57
   ./mm-commotion-mac2ip.pl DC-9F-DB-CE-13-57
   ./mm-commotion-mac2ip.pl DC 9F DB CE 13 57
   ./mm-commotion-mac2ip.pl dc 9f db ce 13 57
=cut

use Getopt::Long qw(:config bundling auto_help);
use Pod::Usage;

my $list_all = '';
GetOptions('list-all!' => \$list_all) or pod2usage(-exitval => 1);

sub list_all {
    my $mac1 = hex 'DC';
    my $mac2 = hex '9F';
    my $mac3 = hex 'DB';
    my $mac4 = hex '00';
    my $mac5 = hex '00';
    my $mac6 = hex '00';

    my $ip1 = 100;
    my $ip2 = 64;
    my $ip3 = 0;
    my $ip4 = 0;

    for (0 .. 255) {
        $mac4 = sprintf('%02X', $ip2);
        
        $ip2 = $_ % 64 + 64;

        # Format IP address
        $ip = "$ip1.$ip2.$ip3.$ip4";

        # Format MAC address
        $mac = sprintf('%02X:%02X:%02X:%02X:%02X:%02X', $mac1, $mac2, $mac3, $mac4, $mac5, $mac6);

        # Pad with space
        $space = sprintf('%*s', 15 - length($ip));

        ## Output matching IP address and MAC address
        print "$ip $space=> $mac\n";
    }
}

# Check for --list-all, otherwise proceed

if ($list_all) { list_all(); exit; }

# Proceed if not --list-all

# Get # of arguments passed to this script
$args=$#ARGV + 1;

# # of arguments should be 1 or 6
# 1 -> DC:9F:DB:CE:13:57 -or- DC-9F-DB-CE-13-57
# 6 -> DC 9F DB CE 13 57

if ($args == 1) {
    # Split 1 argument into 6 separate arguments, 1 for each octet
    # and pass the 6 arguments to a new instance of this script
    @ARGV = split('[:-]', $ARGV[0]);
    system $0, @ARGV;
    # After the new instance completes, make sure to end this one
    exit
} elsif ($args == 6) {
    $mac1 = uc $ARGV[0];
    $mac2 = uc $ARGV[1];
    $mac3 = uc $ARGV[2];
    $mac4 = uc $ARGV[3];
    $mac5 = uc $ARGV[4];
    $mac6 = uc $ARGV[5];
} else {
    pod2usage(-exitval => 1);
}

# Ensure that we are working with the correct large MAC address block
# DC-9F-DB

if ($mac1 ne "DC" || $mac2 ne "9F" || $mac3 ne "DB") {
    print "Unsupported MAC address. Only Ubiquiti-assigned MAC addresses beginning with DC:9F:DB are supported.\n";
    exit 1
}

# Convert last three hexadecimal octets to decimal values
$ip1=100;
$ip2=hex($mac4);
$ip3=hex($mac5);
$ip4=hex($mac6);

$ip2 = $ip2 % 64 + 64;

print "$ip1.$ip2.$ip3.$ip4\n";
