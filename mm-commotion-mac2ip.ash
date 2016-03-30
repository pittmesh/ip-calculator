#!/bin/ash
#
# © 2016 Meta Mesh Wireless Communities. All rights reserved.
# Licensed under the terms of the MIT license.
#
# AUTHORS
# * Jason Khanlar
#

# Check for --list-all, otherwise proceed

while getopts ":-:" opt; do
    if [ $OPTARG = "list-all" ]; then
        mac1=DC
        mac2=9F
        mac3=DB
        mac4=00
        mac5=00
        mac6=00

        ip1=100
        ip2=64
        ip3=0
        ip4=0

        for ip2 in `seq 0 255`;do
            mac4=$(printf "%02X\n" $ip2)

            ip2=$(expr $ip2 % 64 + 64)

            # Format IP address
            ip="$ip1.$ip2.$ip3.$ip4"

            # Format MAC address
            mac="$mac1:$mac2:$mac3:$mac4:$mac5:$mac6"

            # Pad with space
            space=`printf '%*s' "$((15 - ${#ip}))"`

            # Output matching IP address and MAC address
            echo "$ip $space=> $mac"
        done

        exit
    fi
done

# Proceed if not --list-all

# Get # of arguments passed to this script
args=$#

# # of arguments should be 1 or 6
# 1 -> DC:9F:DB:CE:13:57 -or- DC-9F-DB-CE-13-57
# 6 -> DC 9F DB CE 13 57

if [ $args -eq 1 -a ${#1} -eq 17 ]; then
    # Split 1 argument into 6 separate arguments, 1 for each octet
    # and pass the 6 arguments to a new instance of this script
    $0 `echo $1 | tr ":-" " "`
    # After the new instance completes, make sure to end this one
    exit
elif [ $args -eq 6 ]; then
    mac1=$(echo $1|tr '[a-z]' '[A-Z]')
    mac2=$(echo $2|tr '[a-z]' '[A-Z]')
    mac3=$(echo $3|tr '[a-z]' '[A-Z]')
    mac4=$(echo $4|tr '[a-z]' '[A-Z]')
    mac5=$(echo $5|tr '[a-z]' '[A-Z]')
    mac6=$(echo $6|tr '[a-z]' '[A-Z]')
else
    echo "Usage: $0 <MAC address>"
    echo "Usage: $0 --list-all"
    echo
    echo "examples:"
    echo "  $0 DC:9F:DB:CE:13:57"
    echo "  $0 DC-9F-DB-CE-13-57"
    echo "  $0 DC 9F DB CE 13 57"
    echo "  $0 dc 9f db ce 13 57"
    exit 1
fi

# Ensure that we are working with a valid large MAC address block
validMacs=" "
# Ubiquiti
for block in "F0:9F:C2" "DC:9F:DB" "80:2A:A8" "68:72:51" "44:D9:E7" "24:A4:3C" "04:18:D6" "00:27:22" "00:15:6D";do
    validMacs="${validMacs}${block} "
done
# TP-Link
for block in "FC:D7:33" "F8:D1:11" "F8:1A:67" "F4:F2:6D" "F4:EC:38" "F4:83:CD" "F0:F3:36" "EC:88:8F" "EC:26:CA" "EC:17:2F" "E8:DE:27" "E8:94:F6" "E4:D3:32" "E0:05:C5" "D8:5D:4C" "D8:15:0D" "D4:01:6D" "D0:C7:C0" "CC:34:29" "C4:E9:84" "C4:6E:1F" "C0:61:18" "C0:4A:00" "BC:D1:77" "BC:46:99" "B0:48:7A" "A8:57:4E" "A8:15:4D" "A4:2B:B0" "A0:F3:C1" "9C:21:6A" "94:0C:6D" "90:F6:52" "90:AE:1B" "8C:21:0A" "88:25:93" "80:89:17" "78:A1:06" "74:EA:3A" "6C:E8:73" "64:70:02" "64:66:B3" "64:56:01" "60:E3:27" "5C:89:9A" "5C:63:BF" "54:E6:FC" "54:C8:0F" "50:FA:84" "50:C7:BF" "50:BD:5F" "44:B3:2D" "40:16:9F" "3C:46:D8" "38:83:45" "30:B5:C2" "28:2C:B2" "20:DC:E6" "1C:FA:68" "14:E6:E4" "14:CF:92" "14:CC:20" "14:86:92" "14:75:90" "10:FE:ED" "0C:82:68" "0C:72:2C" "08:57:00" "00:27:19" "00:25:86" "00:23:CD" "00:21:27" "00:1D:0F" "00:19:E0" "00:14:78" "00:0A:EB";do
    validMacs="${validMacs}${block} "
done

supported=0
if [ -n "$(echo $validMacs|grep " $mac1:$mac2:$mac3 ")" ];then supported=1;fi

if [ ! $mac1 = "DC" -o ! $mac2 = "9F" -o ! $mac3 = "DB" ]; then
    echo "Unsupported MAC address. Only Ubiquiti-assigned MAC addresses beginning with DC:9F:DB are supported."
    exit 1
fi

# Convert last three hexadecimal octets to decimal values
ip1=100
ip2=$(printf "%d" "0x$mac4")
ip3=$(printf "%d" "0x$mac5")
ip4=$(printf "%d" "0x$mac6")

((ip2=ip2%64 + 64))

echo "$ip1.$ip2.$ip3.$ip4"
