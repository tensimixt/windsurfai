# Dockerfile for Windsurf IDE on Akash Network

# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

# Set environment variables to prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages: supervisord, wget, gnupg, sudo, net-tools, 
# TigerVNC, OpenBox, and other dependencies for GUI applications
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
    # Clean up apt cache
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add Windsurf apt repository and install Windsurf IDE
RUN curl -fsSL "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | sudo gpg --dearmor -o /usr/share/keyrings/windsurf-stable-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/windsurf-stable-archive-keyring.gpg arch=amd64] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/ apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list > /dev/null \
    && sudo apt-get update \
    && sudo apt-get install -y windsurf \
    # Clean up apt cache
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install easy-novnc
RUN wget https://github.com/geek1011/easy-novnc/releases/download/v1.2.0/easy-novnc_1.2.0_amd64.deb \
    && dpkg -i easy-novnc_1.2.0_amd64.deb \
    && rm easy-novnc_1.2.0_amd64.deb

# Copy supervisord configuration file
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose the port easy-novnc will listen on
EXPOSE 8080

# Set the entrypoint to supervisord
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

