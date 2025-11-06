ARG PYTHON_VERSION=3.13.9

FROM python:$PYTHON_VERSION-slim-trixie
# debian 2025

ENV TZ="Asia/Ho_Chi_Minh"

# --- Install FortiClient VPN CLI ---
# The official FortiClient is not open source; you must fetch it from Fortinet.
# Example uses a public lightweight CLI wrapper 'openfortivpn' (simpler & scriptable)
RUN apt-get update && \
   apt-get install -y openfortivpn

# --- Install vpn prerequisites ---
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      sudo iptables iproute2 iputils-ping net-tools ppp ca-certificates

RUN apt-get install -y curl

RUN apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/download-codex.sh /usr/local/bin/scripts/download-codex.sh
RUN chmod +x /usr/local/bin/scripts/download-codex.sh

RUN mkdir -p /opt/codex; \
    /usr/local/bin/scripts/download-codex.sh; \
    ln -sf /opt/codex/codex-x86_64-unknown-linux-gnu /usr/local/bin/codex

# --- Non-root user ---
ARG USER=dev
RUN useradd -m ${USER}

# create ssh config folder
RUN mkdir -p /home/${USER}/.ssh && \
        chown ${USER}:${USER} /home/${USER}/.ssh && \
        chmod 700 /home/${USER}/.ssh

# Allow just the VPN command via sudo without password
# If use Fortinet's official CLI, replace /usr/bin/openfortivpn with /usr/bin/forticlientsslvpn_cli
# RUN echo "${USER} ALL=(ALL) NOPASSWD: /usr/bin/openfortivpn" > /etc/sudoers.d/${USER} && \
#     chmod 440 /etc/sudoers.d/${USER}

# --- Copy entrypoint & make it executable ---
# COPY --chown=${USER}:${USER} entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/entrypoint-fortivpn.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# USER ${USER}
WORKDIR /home/${USER}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


