FROM nvidia/cuda:12.2.0-devel-ubuntu22.04

ENV PORT=${PORT}
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    git \
    curl \
    libgomp1 \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y gcc-11 g++-11 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100

RUN curl -fsSL https://apt.kitware.com/kitware-archive.sh | bash && \
    apt-get update && \
    apt-get install -y cmake

WORKDIR /app

RUN git clone https://github.com/ggerganov/llama.cpp.git

WORKDIR /app/llama.cpp

RUN cmake -B build -G Ninja \
    -DGGML_CUDA=ON \
    -DCMAKE_CUDA_ARCHITECTURES=86 \
    -DGGML_CURL=ON \
    -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build

RUN mkdir -p /app/models

EXPOSE ${PORT}
ENTRYPOINT ["./build/bin/llama-server"]
CMD ["--host", "0.0.0.0", "--port", ${PORT}]
