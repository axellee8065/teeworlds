FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/teeworlds teeworlds

WORKDIR /home/teeworlds

# Download official pre-built teeworlds 0.7.5 server
RUN curl -sL "https://github.com/teeworlds/teeworlds/releases/download/0.7.5/teeworlds-0.7.5-linux_x86_64.tar.gz" \
    | tar xz --strip-components=1 && \
    chmod +x teeworlds_srv

# Copy entrypoint
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
