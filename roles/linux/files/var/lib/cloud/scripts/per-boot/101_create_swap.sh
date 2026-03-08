#!/bin/sh

SWAP_FILE=/swap.img
MEM_SIZE=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`

if [ $MEM_SIZE -lt 2097152 ]; then
    SWAP_SIZE="$((MEM_SIZE * 2 / 1024))"
elif [ $MEM_SIZE -lt 4194304 ]; then
    SWAP_SIZE="$((MEM_SIZE / 1024))"
elif [ $MEM_SIZE -lt 16777216 ]; then
    SWAP_SIZE="$((MEM_SIZE / 2 / 1024))"
elif [ $MEM_SIZE -lt 67108864 ]; then
    SWAP_SIZE="$((MEM_SIZE / 8 / 1024))"
else
    SIZE="4096"
fi

dd if=/dev/zero of=$SWAP_FILE bs=1M count=$SWAP_SIZE && chmod 600 $SWAP_FILE
mkswap $SWAP_FILE && sleep 1 && swapon $SWAP_FILE
