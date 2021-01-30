# ------------------------------------------------------------------------------
# Install build tools and compile webstore
FROM ubuntu:focal AS build
RUN apt-get update && \
	apt-get install -y build-essential git ca-certificates \
	  libcurl4-gnutls-dev libgcrypt20-dev && \
	git clone https://github.com/Fullaxx/webstore.git src && \
	cd src && \
	./compile_clients.sh

# ------------------------------------------------------------------------------
# Pull base image
FROM ubuntu:focal
MAINTAINER Brett Kuskie <fullaxx@gmail.com>

# ------------------------------------------------------------------------------
# Set environment variables
ENV DEBIAN_FRONTEND noninteractive

# ------------------------------------------------------------------------------
# Install libraries and clean up
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	  gnupg2 libcurl3-gnutls libgcrypt20 ca-certificates && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*

# ------------------------------------------------------------------------------
# Install scripts and binaries
COPY --from=build /src/ws_get.exe /src/ws_post.exe /usr/bin/

# ------------------------------------------------------------------------------
# Add volumes
VOLUME /root/.gnupg
VOLUME /root/xfer

# ------------------------------------------------------------------------------
# Define default command
CMD ["/bin/bash"]
