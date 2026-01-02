FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git openssh-client tini \
  && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash dev
USER dev
WORKDIR /work

# Install VS Code CLI (standalone)
RUN curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' \
    --output /tmp/vscode_cli.tar.gz \
 && mkdir -p /home/dev/.vscode-cli/bin \
 && tar -xf /tmp/vscode_cli.tar.gz -C /home/dev/.vscode-cli/bin \
 && rm /tmp/vscode_cli.tar.gz \
 && echo 'export PATH="$HOME/.vscode-cli/bin:$PATH"' >> /home/dev/.bashrc

ENV PATH="/home/dev/.vscode-cli/bin:${PATH}"
ENV MACHINE_NAME="vscode-server"

ENTRYPOINT ["/usr/bin/tini","--"]
CMD ["bash","-lc","code tunnel --accept-server-license-terms --disable-telemetry --name ${MACHINE_NAME}"]
