# Dockerfile adapted from https://github.com/dfinity/examples/blob/1fc8a44d7c9660073163a815e712312ea0a85816/motoko/encrypted-notes-dapp/Dockerfile
FROM --platform=linux/amd64 node:17-slim

# Install a basic environment needed for our build tools
# build-essential only necessary if you need to build the Rust canister.
RUN \
    apt -yq update && \
    apt -yqq install --no-install-recommends curl rsync ca-certificates libdigest-sha-perl jq

# Install dfx; the version is picked up from the DFX_VERSION environment variable
# Lowercase [dfx_version] is an argument of this Dockerfile (with a default value)
# Uppercase [DFX_VERSION] is an environment variable for expected by the DFX installation script
ARG dfx_version=0.10.0
ENV DFX_VERSION=${dfx_version}
RUN sh -ci "$(curl -fsSL https://smartcontracts.org/install.sh)"
ENV NODE_OPTIONS=--openssl-legacy-provider
EXPOSE 8080 8000
WORKDIR /canister
ADD ./ /canister
RUN ["chmod", "+x", "./deploy.sh"]
ENTRYPOINT [ "./deploy.sh" ]