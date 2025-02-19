FROM ubuntu:24.04

RUN apt-get update && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /root/pipe /data

# Set working directory
WORKDIR /root/pipe

# Download Pipe binary
ARG POP_VERSION=v0.2.8
RUN curl -L -o pop "https://dl.pipecdn.app/${POP_VERSION}/pop" \
    && chmod +x pop

# Expose required port
EXPOSE 8003 
# docker run -d --name popnode -v $HOME/pipe_data:/app -p 48003:8003 -p 48080:80 -p 48443:443 popnode
# Set entrypoint
ENTRYPOINT ["./pop"]
CMD ["--ram=${RAM_SIZE}", "--pubKey=${SOLANA_WALLET}", "--max-disk=${DISK_SIZE}", "--cache-dir=${CACHE_DIR}"]
