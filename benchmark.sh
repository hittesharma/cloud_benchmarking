#!/bin/sh

# Timestamp definition as UNIX epoch timestamp
timeStamp=$(date +%s)

# Run CPU Speed benchmarking for 60 seconds with 1 event per second and collect the resulting value 
cpuSpeed=$(sysbench cpu run --time=60 \
    | grep -m 1 "events per second" \
    | grep -oP "[0-9]+(\.[0-9]*)?")

# Run Memory Access benchmarking with the block size of 4K and the total size of 100T for 60 seconds and collect the resulting value
memoryAccess=$(sysbench memory \
                    --memory-block-size=4K \
                    --memory-total-size=100T \
                    --time=60 run \
                    | grep -m 1 " MiB/sec" \
                    | grep -oP "\(.*\)" \
                    | grep -oP "[0-9]+(\.[0-9]*)?")

# Sequential disk read speed with the desired parameters according to the assignment sheet and collect the resulting value 
sysbench fileio --file-total-size=1G --file-test-mode=seqrd --file-num=1 --file-extra-flags=direct prepare > /dev/null 2>&1
sequentialDiskReadSpeed=$(sysbench fileio \
                        --file-total-size=1G \
                        --file-test-mode=seqrd \
                        --file-num=1 \
                        --file-extra-flags=direct \
                        --time=60 run \
                        | grep -m 1 "read, MiB/s" \
                        | grep -oP "[0-9]+(\.[0-9]*)?")
sysbench fileio --file-total-size=1G cleanup > /dev/null 2>&1

# Random disk read speed with the desired parameters according to the assignment sheet and collect the resulting value 
sysbench fileio --file-total-size=1G --file-test-mode=rndrd --file-num=1 --file-extra-flags=direct prepare > /dev/null 2>&1
randomDiskReadSpeed=$(sysbench fileio \
                    --file-total-size=1G \
                    --file-test-mode=rndrd \
                    --file-num=1 \
                    --file-extra-flags=direct \
                    --time=60 run \
                    | grep -m 1 "read, MiB/s" \
                    | grep -oP "[0-9]+(\.[0-9]*)?")
sysbench fileio --file-total-size=1G cleanup > /dev/null 2>&1

echo "${timeStamp},${cpuSpeed},${memoryAccess},${randomDiskReadSpeed},${sequentialDiskReadSpeed}"