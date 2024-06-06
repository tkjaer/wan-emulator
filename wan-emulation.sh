#!/usr/bin/env bash

remove_emulation () {
    # ignore output of non-existing qdiscs
    sudo tc qdisc del dev eth0 root 2>/dev/null
    sudo tc qdisc del dev eth1 root 2>/dev/null
}

# base delay
base_rx_delay () {
    sudo tc qdisc add dev eth1 root handle 1: netem delay ${1}ms
}
base_tx_delay () {
    sudo tc qdisc add dev eth0 root handle 1: netem delay ${1}ms
}


# sub delay variation per-packet
sub_rx_delay_var () {
    sudo tc qdisc add dev eth1 parent 1: handle 10: netem delay ${1}ms reorder 100% gap 2
}
sub_tx_delay_var () {
    sudo tc qdisc add dev eth0 parent 1: handle 10: netem delay ${1}ms reorder 100% gap 2
}

# sub packet loss
sub_rx_loss () {
    sudo tc qdisc add dev eth1 parent 1: handle 10: netem loss ${1}%
}
sub_tx_loss () {
    sudo tc qdisc add dev eth0 parent 1: handle 10: netem loss ${1}%
}

# 0.3ms delay in both directions
set_1 () {
    base_rx_delay 0.3
    base_tx_delay 0.3
}
# 10ms delay in both directions
set_2 () {
    base_rx_delay 10
    base_tx_delay 10
}
# 20ms delay in both directions
set_3 () {
    base_rx_delay 20
    base_tx_delay 20
}
# 10ms delay in both directions with 20ms rx delay variation added
set_4 () {
    base_rx_delay 10
    base_tx_delay 10
    sub_rx_delay_var 20
}

remove_emulation

set_1
