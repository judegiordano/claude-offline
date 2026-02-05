FROM ubuntu:22.04

ENV PORT=${PORT}

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    cmake \
    libgomp1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/ggerganov/llama.cpp.git && \
    cd llama.cpp && \
    cmake -B build -DLLAMA_CURL=ON && \
    cmake --build build --config Release -j$(nproc)

WORKDIR /app/llama.cpp

RUN mkdir -p /app/models

EXPOSE ${PORT}
ENTRYPOINT ["./build/bin/llama-server"]
CMD ["--host", "0.0.0.0", "--port", ${PORT}]
