FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    python3 \
    zlib1g-dev \
    git \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Force git:// -> https:// for submodules, then clone official teeworlds 0.7.5
RUN git config --global url."https://github.com/".insteadOf "git://github.com/" && \
    git clone --depth 1 --branch 0.7.5 https://github.com/teeworlds/teeworlds.git . && \
    git submodule update --init --recursive

# Build server only with CMake
RUN mkdir build && cd build && \
    cmake .. -DCLIENT=OFF -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc)

# --- Runtime stage ---
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    zlib1g \
    libicu72 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/teeworlds teeworlds

WORKDIR /home/teeworlds

# Copy server binary
COPY --from=builder /build/build/teeworlds_srv .

# Copy data directory (maps included in official repo)
COPY --from=builder /build/data ./data

# Copy entrypoint from our fork
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
