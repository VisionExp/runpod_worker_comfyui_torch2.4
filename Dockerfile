FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash

# Set the working directory
WORKDIR /

# Create workspace directory
RUN mkdir /workspace

# Update, upgrade, install packages, install python if PYTHON_VERSION is specified, clean up
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends git wget curl bash libgl1 software-properties-common openssh-server nginx && \
    apt install "python3.11-dev" "python3.11-venv" -y --no-install-recommends; \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Set up Python and pip only if PYTHON_VERSION is specified
RUN ln -s /usr/bin/python3.11 /usr/bin/python && \
    rm /usr/bin/python3 && \
    ln -s /usr/bin/python3.11 /usr/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py; \



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