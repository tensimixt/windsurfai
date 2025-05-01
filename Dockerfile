# Dockerfile for Windsurf IDE on Akash Network (Final Update 3)

# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages: supervisord, wget, gnupg, sudo, net-tools, 
# TigerVNC, OpenBox, Python, pip, git, and other dependencies for GUI applications
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    wget \
    gnupg \
    sudo \
    net-tools \
    tigervnc-standalone-server \
    tigervnc-common \
    openbox \
    xterm \
    dbus-x11 \
    ca-certificates \
    curl \
    python3-pip \
    git \
    # Clean up apt cache
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install Windsurf IDE .deb package using the correct URL
ARG WINDSURF_VERSION="1.7.3"
ARG WINDSURF_DEB_URL="https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt/pool/main/w/windsurf/Windsurf-linux-x64-${WINDSURF_VERSION}.deb"
RUN wget "${WINDSURF_DEB_URL}" -O windsurf_amd64.deb \
    && apt-get update \
    # Use apt install -y ./<file>.deb to handle dependencies
    && apt install -y ./windsurf_amd64.deb \
    && rm windsurf_amd64.deb \
    # Clean up apt cache
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install websockify using pip
RUN pip3 install websockify

# Clone the noVNC repository which contains the web client files
RUN git clone https://github.com/novnc/noVNC.git /usr/share/novnc

# Create a dummy project directory
RUN mkdir -p /home/ubuntu/project

# Copy supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose the port websockify will listen on
EXPOSE 8080

# Set the entrypoint to supervisord
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

