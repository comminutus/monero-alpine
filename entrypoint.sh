#!/bin/ash

set -e

args="--data-dir          $MONERO_DATA_DIR          \
      --log-level         $MONERO_LOG_LEVEL         \
      --p2p-bind-ip       $MONERO_P2P_BIND_IP       \
      --p2p-bind-port     $MONERO_P2P_BIND_PORT     \
      --p2p-external-port $MONERO_P2P_EXTERNAL_PORT \
      --rpc-bind-ip       $MONERO_RPC_BIND_IP       \
      --rpc-bind-port     $MONERO_RPC_BIND_PORT"

if ! echo "$MONERO_RPC_BIND_IP" | grep -q '^127.'; then
    args="$args --confirm-external-bind"
fi

if [ -n "$MONERO_DISABLE_DNS_CHECKPOINTS" ]; then
    args="$args --disable-dns-checkpoints"
fi

if [ -n "$MONERO_ENABLE_DNS_BLOCKLIST" ]; then
    args="$args --enable-dns-blocklist"
fi

if [ -n "$MONERO_NON_INTERACTIVE" ]; then
    args="$args --non-interactive"
fi

if [ -n "$MONERO_RPC_RESTRICTED_BIND_IP" ]; then
    args="$args --restricted-bind-ip $MONERO_RPC_RESTRICTED_BIND_IP"
fi

if [ -n "$MONERO_RPC_RESTRICTED_BIND_IPV6_ADDRESS" ]; then
    args="$args --rpc-restricted-bind-ipv6-address $MONERO_RPC_RESTRICTED_BIND_IPV6_ADDRESS"
fi

if [ -n "$MONERO_TX_PROXY" ]; then
    args="$args --tx-proxy $MONERO_TX_PROXY"
fi

if [ -n "$MONERO_ZMQ_PUB" ]; then
    args="$args --zmq-pub $MONERO_ZMQ_PUB"
fi

if [ -n "$MONERO_ADDITIONAL_ARGS" ]; then
    args="$args $MONERO_ADDITIONAL_ARGS"
fi

args="$args $@"

old_ifs=$IFS
set -- $args
IFS=$old_ifs

echo monerod "$@"
exec monerod "$@"
