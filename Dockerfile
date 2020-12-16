FROM alpine:latest AS build-env
LABEL maintainer="Per-Ole Fanuelsen"
WORKDIR /build
RUN apk --update --no-cache add tar git bash curl openssl
RUN \
    latest_url_ppwup=$(curl -s "https://github.com/rgl/packer-provisioner-windows-update/releases/latest/" | sed -E 's/^.+href="([^"]+)".+$/\1/' | head -1) && \
    full_url_ppwup=$(curl -s "$latest_url_ppwup" | grep linux_amd64.tar.gz | sed -E 's/^.+href="([^"]+)".+$/\1/' | head -1) && \
    download=$(curl -s -L https://github.com$full_url_ppwup -o outfile.tar.gz) && \
    tar -xf outfile.tar.gz && \
    chmod +x packer-provisioner-windows-update && \
    rm outfile.tar.gz 
RUN chmod u+x,o+x .
FROM hashicorp/packer
ENV APP_DIR="/bin"
WORKDIR $APP_DIR
COPY --from=build-env /build .
ENTRYPOINT ["bin/packer"]
