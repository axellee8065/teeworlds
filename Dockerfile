FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    zlib1g-dev \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Install bam build tool
RUN git clone https://github.com/matricks/bam.git /tmp/bam && \
    cd /tmp/bam && \
    ./make_unix.sh && \
    cp bam /usr/local/bin/

# Copy source
COPY . .

# Build server only (no SDL/freetype needed for dedicated server)
RUN bam -a server_release

# --- Runtime stage ---
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    zlib1g \
    socat \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/teeworlds teeworlds

WORKDIR /home/teeworlds

# Copy server binary and data
COPY --from=builder /build/teeworlds_srv .
COPY --from=builder /build/data ./data
COPY --from=builder /build/storage.cfg .

# Copy entrypoint and config
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Default server config
RUN echo 'sv_name "Teeworlds Docker Server"' > autoexec.cfg && \
    echo 'sv_port 8303' >> autoexec.cfg && \
    echo 'sv_max_clients 16' >> autoexec.cfg && \
    echo 'sv_map dm1' >> autoexec.cfg

RUN chown -R teeworlds:teeworlds /home/teeworlds

USER teeworlds

EXPOSE 8303/udp

CMD ["./entrypoint.sh"]
