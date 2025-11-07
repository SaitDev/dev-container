ARG UBUNTU_VERSION=noble-20251001
# 24.04 LTS
FROM ubuntu:$UBUNTU_VERSION

ENV TZ="Asia/Ho_Chi_Minh"

# --- Install FortiClient VPN CLI ---
# The official FortiClient is not open source; you must fetch it from Fortinet.
# Example uses a public lightweight CLI wrapper 'openfortivpn' (simpler & scriptable)
RUN apt-get update && \
   apt-get install -y openfortivpn

# --- Install vpn prerequisites ---
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      sudo iptables iproute2 iputils-ping net-tools ppp ca-certificates

RUN apt-get install -y curl git

RUN apt-get install -y unzip && \
    rm -rf /var/lib/apt/lists/*

# --- Non-root user ---
ARG USER=dev
RUN useradd -m ${USER}
USER ${USER}

# install fnm and node
ENV FNM_DIR=/home/${USER}/.local/share/fnm
ENV PATH="${FNM_DIR}:/home/${USER}/.local/bin:${PATH}"
ENV SHELL=/bin/bash
RUN curl -fsSL https://fnm.vercel.app/install | bash

ARG NODE_VERSION=16
RUN fnm install $NODE_VERSION

# create ssh config folder
RUN mkdir -p /home/${USER}/.ssh && \
        # chown ${USER}:${USER} /home/${USER}/.ssh && \
        chmod 700 /home/${USER}/.ssh


# need user root to run forti vpn client
USER root

COPY scripts/download-codex.sh /usr/local/bin/scripts/download-codex.sh
RUN chmod +x /usr/local/bin/scripts/download-codex.sh

RUN mkdir -p /opt/codex; \
    /usr/local/bin/scripts/download-codex.sh; \
    ln -sf /opt/codex/codex-x86_64-unknown-linux-gnu /usr/local/bin/codex

# --- Copy entrypoint & make it executable ---
# COPY --chown=${USER}:${USER} entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/entrypoint-fortivpn.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY scripts/setup-ssh.sh /usr/local/bin/setup-ssh.sh
RUN chmod +x /usr/local/bin/setup-ssh.sh

WORKDIR /home/${USER}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
