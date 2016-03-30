#!/bin/bash
#
# © 2016 Meta Mesh Wireless Communities. All rights reserved.
# Licensed under the terms of the MIT license.
#
# AUTHORS
# * Jason Khanlar
#

function list-all {
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

    ((ip2=ip2%64 + 64))

    # Format IP address
    ip="$ip1.$ip2.$ip3.$ip4"

    # Format MAC address
    mac="$mac1:$mac2:$mac3:$mac4:$mac5:$mac6"

    # Pad with space
    space=`printf '%*s' "$((15 - ${#ip}))"`

    # Output matching IP address and MAC address
    echo "$ip $space=> $mac"
  done
}

function usage {
  echo "Usage: $0 <MAC address>"
  echo "Usage: $0 --list-all"
  echo
  echo "examples:"
  echo "  $0 DC:9F:DB:CE:13:57"
  echo "  $0 DC-9F-DB-CE-13-57"
  echo "  $0 DC 9F DB CE 13 57"
  echo "  $0 dc 9f db ce 13 57"
}

# Check for --list-all, otherwise proceed

while getopts ":-:" opt; do
    if [ $OPTARG = "list-all" ]; then
        list-all
        exit
    fi
done

if [[ "$*" =~ -*- ]]; then
    usage
    exit 1
fi

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
  usage
  exit 1
fi

# Ensure that we are working with a valid large MAC address block
validMacs=(
  # Ubiquiti
  "F09FC2" "DC9FDB" "802AA8" "687251" "44D9E7" "24A43C" "0418D6" "002722" "00156D"
  # TP-Link
  "FCD733" "F8D111" "F81A67" "F4F26D" "F4EC38" "F483CD" "F0F336" "EC888F" "EC26CA" "EC172F" "E8DE27" "E894F6" "E4D332" "E005C5" "D85D4C" "D8150D" "D4016D" "D0C7C0" "CC3429" "C4E984" "C46E1F" "C06118" "C04A00" "BCD177" "BC4699" "B0487A" "A8574E" "A8154D" "A42BB0" "A0F3C1" "9C216A" "940C6D" "90F652" "90AE1B" "8C210A" "882593" "808917" "78A106" "74EA3A" "6CE873" "647002" "6466B3" "645601" "60E327" "5C899A" "5C63BF" "54E6FC" "54C80F" "50FA84" "50C7BF" "50BD5F" "44B32D" "40169F" "3C46D8" "388345" "30B5C2" "282CB2" "20DCE6" "1CFA68" "14E6E4" "14CF92" "14CC20" "148692" "147590" "10FEED" "0C8268" "0C722C" "085700" "002719" "002586" "0023CD" "002127" "001D0F" "0019E0" "001478" "000AEB"
)

supported=0
for fto in "${validMacs[@]}"; do
  if [[ "$mac1:$mac2:$mac3" == "${fto:0:2}:${fto:2:2}:${fto:4:2}" ]]; then supported=1;fi
done

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
