########################################################################################################################
# Base Image
########################################################################################################################
# Core Config
ARG alpine_tag=3.19.1
ARG monero_tag=v0.18.3.1

# Ports:
# 18080: mainnet peer-to-peer; for nodes to communicate with other nodes
# 18081: mainnet RPC port
# 18082: mainnet JSON RPC port
# 18083: mainnet ZMQ port
# 28080: stagenet peer-to-peer; for nodes to communicate with other nodes
# 28081: stagenet RPC port
# 28082: stagenet JSON RPC port
# 28083: stagenet ZMQ port
# 38080: testnet peer-to-peer; for nodes to communicate with other nodes
# 38081: testnet RPC port
# 38082: testnet JSON RPC port
# 38083: testnet ZMQ port
ARG ports='18080 18081 18082 18083 28080 28081 28082 28083 38080 38081 38082 38083'

# Defaults
ARG uid=10000
ARG build_dir=/tmp/build
ARG license=$build_dir/monero/LICENSE
ARG dist_dir=$build_dir/monero/build/release/bin
ARG install_dir=/usr/local/bin
ARG data_dir=/var/lib/monero

FROM alpine:${alpine_tag} as base


########################################################################################################################
# Build Image
########################################################################################################################
FROM base as build
ARG build_dir monero_tag
ARG build_packages="boost-dev ccache cmake g++ git gtest-dev libsodium-dev libunwind-dev make pkgconf openpgm-dev \
                    openssl-dev unbound-dev zeromq-dev"

WORKDIR $build_dir

# Update base Alpine system and add build packages
RUN apk update
RUN apk add $build_packages

# Add libexecinfo-dev from another repository since it's required for a Monero build on Alpine Linux but was removed in
# subsequent versions of alpine
RUN apk add --update --repository=https://dl-cdn.alpinelinux.org/alpine/v3.16/main/ libexecinfo-dev

# Download Monero source
RUN git clone --recursive https://github.com/monero-project/monero
WORKDIR $build_dir/monero
RUN git checkout $monero_tag
RUN git submodule sync
RUN git submodule update --init --force

# Remove the .git directory so the build outputs to build/release and not a detached head name or tag name, etc.
RUN rm -rf .git

# Run build - -DELPP_FEATURE_CRASH_LOG disables the libexecinfo crash log, which doesn't compile on Alpine
RUN CXXFLAGS='-DELPP_FEATURE_CRASH_LOG' make -j$(nproc)


########################################################################################################################
# Final Image
########################################################################################################################
FROM base as final
ARG data_dir dist_dir install_dir license ports uid

WORKDIR /home/monero

# Upgrade pre-installed Alpine packages and install runtime dependencies
RUN apk --no-cache upgrade
RUN apk add --no-cache --update --repository=https://dl-cdn.alpinelinux.org/alpine/v3.16/main/ libexecinfo
ARG runtime_packages="boost unbound-libs libzmq"
RUN apk add --no-cache $runtime_packages

# Environment variables, overridable from container
ENV MONERO_ADDITIONAL_ARGS=
ENV MONERO_DATA_DIR=$data_dir
ENV MONERO_LOG_LEVEL=0
ENV MONERO_DISABLE_DNS_CHECKPOINTS=
ENV MONERO_ENABLE_DNS_BLOCKLIST=true
ENV MONERO_NON_INTERACTIVE=true
ENV MONERO_P2P_BIND_IP=0.0.0.0
ENV MONERO_P2P_BIND_PORT=18080
ENV MONERO_P2P_EXTERNAL_PORT=0
ENV MONERO_RPC_BIND_IP=0.0.0.0
ENV MONERO_RPC_BIND_PORT=18081
ENV MONERO_RPC_RESTRICTED_BIND_IP=
ENV MONERO_RPC_RESTRICTED_BIND_IPV6_ADDRESS=
ENV MONERO_TX_PROXY=
ENV MONERO_ZMQ_PUB=

# Install Monero binaries
RUN mkdir -p "$install_dir" "$data_dir"
COPY --from=build $dist_dir $install_dir
COPY --from=build $license /usr/share/licenses/monero/

# Create Monero user
RUN addgroup -g $uid -S monero && adduser -u $uid -S -D -G monero monero

# Copy container entrypoint script into container
COPY entrypoint.sh .

# Change ownership of all files in user dir and data dir
RUN chown -R monero:monero "$data_dir" /home/monero

# Setup volume for blockchain
VOLUME $data_dir

# Expose ports
EXPOSE $ports

# Run as monero
USER monero

# Run entrypoint script
ENTRYPOINT ["./entrypoint.sh"]
