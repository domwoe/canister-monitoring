FROM debian

# Install a basic environment needed for our build tools
RUN \
    apt -yq update && \
    apt -yqq install --no-install-recommends curl ca-certificates nginx

# Install dfx; the version is picked up from the DFX_VERSION environment variable
# Lowercase [dfx_version] is an argument of this Dockerfile (with a default value)
# Uppercase [DFX_VERSION] is an environment variable for expected by the DFX installation script
ARG dfx_version=0.10.0
ENV DFX_VERSION=${dfx_version}
RUN sh -ci "$(curl -fsSL https://smartcontracts.org/install.sh)"
ENV NODE_OPTIONS=--openssl-legacy-provider
EXPOSE 80
WORKDIR /canister
ADD ./ /canister
RUN ["chmod", "+x", "./deploy.sh"]
ENTRYPOINT [ "./deploy.sh" ]