# Use the official Debian base image
FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y sudo curl git && \
    rm -rf /var/lib/apt/lists/*

RUN apt update -y

# Create a non-root user
ARG USERNAME=myuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

# Set the password for the user
ARG USER_PASSWORD=password
RUN echo "$USERNAME:$USER_PASSWORD" | chpasswd

# Add the user to the sudo group
RUN usermod -aG sudo $USERNAME

# Configure sudo to allow passwordless sudo for the user
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

# Switch to the non-root user
USER $USERNAME

# Set the working directory to the user's home directory
WORKDIR /home/$USERNAME/code
COPY . ./dotfiles
WORKDIR /home/$USERNAME/code/dotfiles

# Entry point
CMD ["/bin/bash"]
