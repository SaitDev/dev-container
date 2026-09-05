FROM eclipse-temurin:21.0.12_8-jdk-noble
# ubuntu 24, no slim version, close to ubuntu 22 and less than u26, alpine is only 25MB smaller

ENV TZ="Asia/Ho_Chi_Minh"

# libicu74: if vscode extension use .net, .net need libicu
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        openssh-server \
        ripgrep \
        sudo \
        unzip \
        zsh \
        libicu74 \
        bubblewrap \
        nano \
        screen \
        tmux && \
    rm -rf /var/lib/apt/lists/*

# --- Non-root user ---
ARG USER=dev
RUN useradd -m -s /usr/bin/zsh ${USER}

# --- SSH server ---
RUN mkdir -p /var/run/sshd && \
    sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# --- Install Oh My Zsh ---
RUN git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /home/${USER}/.oh-my-zsh && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /home/${USER}/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    cp /home/${USER}/.oh-my-zsh/templates/zshrc.zsh-template /home/${USER}/.zshrc && \
    sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions)/' /home/${USER}/.zshrc && \
    chown -R ${USER}:${USER} /home/${USER}/.oh-my-zsh /home/${USER}/.zshrc

# --- Java env for dev shell sessions ---
RUN printf '%s\n' \
      'export JAVA_HOME=/opt/java/openjdk' \
      'case ":$PATH:" in' \
      '  *":$JAVA_HOME/bin:"*) ;;' \
      '  *) export PATH="$JAVA_HOME/bin:$PATH" ;;' \
      'esac' \
      > /home/${USER}/.java-env && \
    touch /home/${USER}/.bashrc /home/${USER}/.bash_profile /home/${USER}/.profile /home/${USER}/.zprofile && \
    printf '%s\n' \
      '' \
      '# Load Java for dev shell sessions' \
      '[ -f "$HOME/.java-env" ] && . "$HOME/.java-env"' \
      >> /home/${USER}/.zshrc && \
    printf '%s\n' \
      '' \
      '# Load Java for dev shell sessions' \
      '[ -f "$HOME/.java-env" ] && . "$HOME/.java-env"' \
      >> /home/${USER}/.zprofile && \
    printf '%s\n' \
      '' \
      '# Load Java for dev shell sessions' \
      '[ -f "$HOME/.java-env" ] && . "$HOME/.java-env"' \
      >> /home/${USER}/.bashrc && \
    printf '%s\n' \
      '' \
      '# Load Java for dev shell sessions' \
      '[ -f "$HOME/.java-env" ] && . "$HOME/.java-env"' \
      >> /home/${USER}/.bash_profile && \
    printf '%s\n' \
      '' \
      '# Load Java for dev shell sessions' \
      '[ -f "$HOME/.java-env" ] && . "$HOME/.java-env"' \
      >> /home/${USER}/.profile && \
    chown ${USER}:${USER} /home/${USER}/.java-env /home/${USER}/.zshrc /home/${USER}/.zprofile /home/${USER}/.bashrc /home/${USER}/.bash_profile /home/${USER}/.profile

# --- Install JDK helper and jenv ---
COPY scripts/install-temurin.sh /usr/local/bin/install-temurin.sh
RUN chmod +x /usr/local/bin/install-temurin.sh

ENV JENV_ROOT=/home/${USER}/.jenv
RUN git clone https://github.com/jenv/jenv.git "${JENV_ROOT}" && \
    chown -R ${USER}:${USER} "${JENV_ROOT}" && \
    printf '%s\n' \
      "export JENV_ROOT=${JENV_ROOT}" \
      'export PATH="$JENV_ROOT/bin:$PATH"' \
      'if command -v jenv >/dev/null 2>&1; then' \
      '  eval "$(jenv init -)"' \
      'fi' \
      > /etc/profile.d/jenv.sh && \
    cat /etc/profile.d/jenv.sh >> /home/${USER}/.zshrc && \
    cat /etc/profile.d/jenv.sh >> /home/${USER}/.zprofile

# --- Install fnm ---
# ARG NODE_VERSION=24
ENV FNM_DIR=/home/${USER}/.local/share/fnm
ENV PATH="${FNM_DIR}:${PATH}"
RUN mkdir -p "${FNM_DIR}" && \
    chown -R ${USER}:${USER} /home/${USER}/.local && \
    su ${USER} -c 'curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell' && \
    # su ${USER} -c "${FNM_DIR}/fnm install ${NODE_VERSION}" && \
    # su ${USER} -c "${FNM_DIR}/fnm default ${NODE_VERSION}" && \
    printf '%s\n' \
      "export FNM_DIR=${FNM_DIR}" \
      'export PATH="$FNM_DIR:$PATH"' \
      'if command -v fnm >/dev/null 2>&1; then' \
      '  eval "$(fnm env --use-on-cd --shell zsh)"' \
      'fi' \
      > /etc/profile.d/fnm.sh && \
    cat /etc/profile.d/fnm.sh >> /home/${USER}/.zshrc && \
    cat /etc/profile.d/fnm.sh >> /home/${USER}/.zprofile

# --- Install VS Code CLI ---
COPY scripts/download-vscode-cli.sh /usr/local/bin/download-vscode-cli.sh
COPY scripts/setup-vscode-cli.sh /usr/local/bin/setup-vscode-cli.sh
RUN chmod +x /usr/local/bin/download-vscode-cli.sh /usr/local/bin/setup-vscode-cli.sh && \
    TARGET_USER=${USER} /usr/local/bin/download-vscode-cli.sh && \
    TARGET_USER=${USER} /usr/local/bin/setup-vscode-cli.sh

# --- Install Codex ---
COPY scripts/download-codex.sh /usr/local/bin/download-codex.sh
RUN chmod +x /usr/local/bin/download-codex.sh
RUN mkdir -p /opt/codex; \
    /usr/local/bin/download-codex.sh; \
    ln -sf /opt/codex/codex-x86_64-unknown-linux-musl /usr/local/bin/codex

COPY scripts/setup-ssh.sh /usr/local/bin/setup-ssh.sh
RUN chmod +x /usr/local/bin/setup-ssh.sh

COPY scripts/entrypoint-sshd.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/${USER}
EXPOSE 22 25577 25565
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
