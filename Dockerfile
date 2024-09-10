FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# Set the working directory
WORKDIR /

# Create workspace directory
RUN mkdir /workspace

RUN apt update && \
    apt upgrade -y && \
    apt install -y \
      python3-dev \
      python3-pip \
      fonts-dejavu-core \
      rsync \
      git \
      jq \
      moreutils \
      aria2 \
      wget \
      curl \
      libglib2.0-0 \
      libsm6 \
      libgl1 \
      libxrender1 \
      libxext6 \
      ffmpeg \
      libgoogle-perftools4 \
      libtcmalloc-minimal4 \
      procps && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y

# Set up Python
RUN ln -s /usr/bin/python3.11 /usr/bin/python



RUN pip install --upgrade --no-cache-dir pip

RUN pip install --upgrade --no-cache-dir torch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0
RUN pip install --upgrade --no-cache-dir jupyterlab ipywidgets jupyter-archive jupyter_contrib_nbextensions
RUN pip install -U --no-cache-dir xformers

# Install Worker dependencies
RUN pip install requests runpod
# Add validation schemas
COPY schemas /schemas
# Add RunPod Handler and Docker container start script
COPY start.sh rp_handler.py ./


# Start the container
RUN chmod +x /start.sh
ENTRYPOINT /start.sh