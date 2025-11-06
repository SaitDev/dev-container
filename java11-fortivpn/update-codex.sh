curl -fL -o /tmp/codex.tar.gz "https://github.com/openai/codex/releases/latest/download/codex-x86_64-unknown-linux-gnu.tar.gz"; \
    ls -la /tmp; \
    tar -xzvf /tmp/codex.tar.gz -C /home/dev/codex; \
    ls -la /home/dev/codex; \
    rm -f /tmp/codex.tar.gz;