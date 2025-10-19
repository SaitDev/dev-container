FROM eclipse-temurin:11-jdk

# --- Install FortiClient VPN CLI ---
# The official FortiClient is not open source; you must fetch it from Fortinet.
# Example uses a public lightweight CLI wrapper 'openfortivpn' (simpler & scriptable)
RUN apt-get update && \
   apt-get install -y openfortivpn && \
   rm -rf /var/lib/apt/lists/*

# --- Install prerequisites ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo iptables iproute2 iputils-ping net-tools resolvconf ppp ca-certificates git && \
    rm -rf /var/lib/apt/lists/*

# --- Non-root user ---
ARG USER=dev
RUN useradd -m ${USER}
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


