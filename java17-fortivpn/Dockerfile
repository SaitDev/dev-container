FROM eclipse-temurin:17.0.16_8-jdk-noble
# ubuntu 24, no slim version but good enough ~190MB, alpine is only 30MB smaller 

ENV TZ="Asia/Ho_Chi_Minh"

# --- Install FortiClient VPN CLI ---
# The official FortiClient is not open source; you must fetch it from Fortinet.
# Example uses a public lightweight CLI wrapper 'openfortivpn' (simpler & scriptable)
RUN apt-get update && \
   apt-get install -y openfortivpn

# --- Install vpn prerequisites ---
RUN apt-get install -y --no-install-recommends \
      sudo iptables iproute2 iputils-ping net-tools resolvconf ppp ca-certificates

RUN apt-get install -y curl

RUN apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

# --- Non-root user ---
ARG USER=dev
RUN useradd -m ${USER}
ENV PATH="/home/${USER}/.local/bin:${PATH}"

# --- Install Codex ---
ARG CODEX_VERSION=latest
COPY scripts/download-codex.sh /usr/local/bin/download-codex.sh
RUN chmod +x /usr/local/bin/download-codex.sh
RUN su ${USER} -c "CODEX_RELEASE=${CODEX_VERSION} /usr/local/bin/download-codex.sh"

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
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# USER ${USER}
WORKDIR /home/${USER}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

