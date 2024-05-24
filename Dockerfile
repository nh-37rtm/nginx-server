FROM debian:bookworm-slim as base

ARG DEBIAN_FRONTEND=noninteractive
ENV VIRTUAL_ENV=/opt/python/venv \
    APP_USER=app \
    TZ=Europe/Paris

USER root:root

RUN apt-get update

FROM base as build

RUN apt-get install -y --no-install-recommends \
    build-essential

RUN mkdir -p /usr/local/src
WORKDIR /usr/local/src

RUN apt-get install -y --no-install-recommends \
    wget ca-certificates libpcre3-dev libssl-dev

RUN update-ca-certificates

RUN wget https://nginx.org/download/nginx-1.26.0.tar.gz && \
    tar xzf nginx-1.26.0.tar.gz && \
    cd /usr/local/src/nginx-1.26.0 && \
    ./configure --without-http_gzip_module --with-http_ssl_module && \
    make && make install

FROM base as nginx

RUN apt-get install -y --no-install-recommends \ 
    openssl libpcre3
    
COPY --from=build /usr/local/nginx /usr/local/nginx

# RUN ln -s /etc/openvpn/openssl /etc/openvpn/server/openssl
# WORKDIR /etc/openvpn/server

# Create a dedicated user
# RUN useradd -ms /bin/bash openvpn
# RUN openvpn --genkey secret /etc/openvpn/server/openssl/ta.key

ENTRYPOINT [ "/bin/bash" ]

CMD [ \ 
        "-c", \
        "/usr/local/nginx/sbin/nginx && tail -f /usr/local/nginx/logs/access.log" \
]