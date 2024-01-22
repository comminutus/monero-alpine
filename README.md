# monero-alpine
[![Monero License](https://img.shields.io/badge/license-BSD3-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![CI](https://github.com/comminutus/monero-alpine/actions/workflows/ci.yaml/badge.svg)](https://github.com/comminutus/monero-alpine/actions/workflows/ci.yaml)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/comminutus/monero-alpine)](https://github.com/comminutus/monero-alpine/releases/latest)


## Description
`monero-alpine` is a [Monero](https://www.getmonero.org/) container image compiled for Alpine Linux.  The container image runs `monerod`.

## Getting Started
```
podman pull ghcr.io/comminutus/monero-alpine
podman run -it --rm ghcr.io/comminutus/monero-alpine
```

## Usage

### Environment Variables and Options
Some configuration options from `moderod` can be set directly via environment variables.  They correspond to the '`--`'
options that `monerod` supports.  For help regarding a specific option, consult `monerod --help`

**Supported Environment Variables:**
| Environment Variable                        | `monerod` option                    | Default Value                                         |
| ------------------------------------------- | ----------------------------------- | ----------------------------------------------------- |
| `MONERO_DATA_DIR`                         | `--data-dir`                          | _/var/lib/monero_                                     |
| `MONERO_LOG_LEVEL`                        | `--log-level`                         | _0_                                                   |
| `MONERO_DISABLE_DNS_CHECKPOINTS`          | `--disable-dns-checkpoints`           |                                                       |
| `MONERO_ENABLE_DNS_BLOCKLIST`             | `--enable-dns-blocklist`              | _on, to turn off, set `MONERO_ENABLE_DNS_BLOCKLIST=`_ |
| `MONERO_NON_INTERACTIVE`                  | `--non-interactive`                   |                                                       |
| `MONERO_P2P_BIND_IP`                      | `--p2p-bind-ip`                       | _0.0.0.0_                                             |
| `MONERO_P2P_BIND_PORT`                    | `--p2p-bind-port`                     | _18080_                                               |
| `MONERO_P2P_EXTERNAL_PORT`                | `--p2p-external-port`                 | _0_                                                   |
| `MONERO_RPC_BIND_IP`                      | `--rpc-bind-ip`                       | _0.0.0.0_                                             |
| `MONERO_RPC_BIND_PORT`                    | `--rpc-bind-port`                     | _18081_                                               |
| `MONERO_RPC_RESTRICTED_BIND_IP`           | `--rpc-restricted-bind-ip`            |                                                       |
| `MONERO_RPC_RESTRICTED_BIND_IPV6_ADDRESS` | `--rpc-restricted-bind-ipv6-address`  |                                                       |
| `MONERO_TX_PROXY`                         | `--tx-proxy`                          |                                                       |
| `MONERO_ZMQ_PUB`                          | `--zmq-pub`                           |                                                       |

If there are other options you'd like to set that don't correspond to an environment variable, you can set `MONERO_ADDITIONAL_ARGS` to
include other arguments.  For example: `MONERO_ADDITIONAL_ARGS=--disable-dns-checkpoints --disable-rpc-ban`.

### Volumes
By default, the container's persistent data, including configuration and blockchain data are stored at _/var/lib/monero_.
You can change this by setting the `MONERO_DATA_DIR` environment variable.

This can be useful if you're running the container image with Docker, Kubernetes, OpenShift, etc.  Mount your volumes at
_/var/lib/monero_ or wherever you choose to set `MONERO_DATA_DIR` to.

### User/Group
The container uses a user named _monero_ with a UID of _10000_, with a group that matches the same.  If you'd like to change this, rebuild
the container and set the `uid` build argument.

### Ports
The container exposes the following ports:
| Port  | Enabled by Default? | Use                                                                                |
| ----- | :-----------------: | ---------------------------------------------------------------------------------- |
| 18080 | Y                   | peer-to-peer communications; used for nodes to communicate with other nodes        |
| 18081 | Y                   | RPC communications, used for wallets and other tools to communicate with this node |
| 18082 | N                   | JSON-RPC port                                                                      |
| 28080 | N                   | _stagenet_ peer-to-peer communications                                             |
| 28081 | N                   | _stagenet_ RPC communications                                                      |
| 28082 | N                   | _stagenet_ JSON-RPC port                                                           |
| 38080 | N                   | _testnet_ peer-to-peer communications                                             |
| 38081 | N                   | _testnet_ RPC communications                                                      |
| 38082 | N                   | _testnet_ JSON-RPC port                                                           |

## License
This project inherits Monero's license - see the [LICENSE](LICENSE) file for details.
