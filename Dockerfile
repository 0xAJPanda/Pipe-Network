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
EXPOSE 8003 80 443

# Declare environment variables
ENV SOLANA_WALLET=${SOLANA_WALLET}
ENV RAM_SIZE=${RAM_SIZE}
ENV DISK_SIZE=${DISK_SIZE}
ENV CACHE_DIR=${CACHE_DIR}

# Create an entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
