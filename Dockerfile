# Using the ubuntu 22.04 image, create a dockerfile that checks out az-hop's source code into /az-hop

FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York \
    DEBIAN_FRONTEND=noninteractive

LABEL author    ="Tim Meyers"
LABEL version   ="0.1"
LABEL email     ="tmeyers@microsoft.com"

ENV AZ_HOP_VERSION="v1.0.40" \
    AZ_HOP_BRANCH="main" \
    AZ_HOP_REPO="https://github.com/Azure/az-hop.git"

# Set the default shell to bash rather than sh
ENV SHELL /bin/bash

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    apt-transport-https \
    lsb-release \
    gnupg \
    git \
    jq \
    unzip \
    wget \
    vim \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN git clone --branch ${AZ_HOP_BRANCH} ${AZ_HOP_REPO} /az-hop

# Set the working directory to /az-hop
WORKDIR /az-hop
COPY ./config/ /az-hop

# install az-hop's helper tools
RUN ./toolset/scripts/install.sh

# Add a non-root user azhopinstaller with an explicit UID/GID and add permissions to access the /az-hop folder
RUN groupadd --gid 1000 azhopinstaller \
    && useradd --uid 1000 --gid azhopinstaller --shell /bin/bash --create-home azhopinstaller
RUN chown -R azhopinstaller:azhopinstaller /az-hop

USER azhopinstaller
