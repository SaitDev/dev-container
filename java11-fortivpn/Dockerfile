FROM eclipse-temurin:11.0.28_6-jdk-jammy
# ubuntu 22, no slim version but good enough ~182MB, alpine is only 30MB smaller 

ENV TZ="Asia/Ho_Chi_Minh"

# --- Install FortiClient VPN CLI ---
# The official FortiClient is not open source; you must fetch it from Fortinet.
# Example uses a public lightweight CLI wrapper 'openfortivpn' (simpler & scriptable)
RUN apt-get update && \
   apt-get install -y openfortivpn

# --- Install vpn prerequisites ---
RUN apt-get install -y --no-install-recommends \
      sudo iptables iproute2 iputils-ping net-tools resolvconf ppp ca-certificates

RUN apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/codex; \
    curl -fL -o /tmp/codex.tar.gz "https://github.com/openai/codex/releases/latest/download/codex-x86_64-unknown-linux-gnu.tar.gz"; \
    ls -la /tmp; \
    tar -xzvf /tmp/codex.tar.gz -C /opt/codex; \
    ls -la /opt/codex; \
    rm -f /tmp/codex.tar.gz; \
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
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# USER ${USER}
WORKDIR /home/${USER}
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


