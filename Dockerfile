FROM dhi.io/uv:0.11.16-debian13@sha256:2af3731aa4e97ec88e5d739745b0fde1b70ea53bda512dadd81984d039149715 AS uv

FROM dhi.io/python:3.14.4-debian13-dev@sha256:ef2fa2beab6aa256da894c5c4d7cd81483764f68fc7814f5e8bab26d2c89dc6c AS builder
ARG TARGETPLATFORM
COPY --from=uv /usr/local/bin/uv /usr/local/bin/
WORKDIR /app

RUN python -m venv /app/.venv
# GoReleaser dockers_v2 provides the built wheel under $TARGETPLATFORM/.
COPY ${TARGETPLATFORM}/*.whl /tmp/
RUN uv pip install --python /app/.venv/bin/python /tmp/*.whl

FROM dhi.io/python:3.14.4-debian13@sha256:edb8192e94aef7bce840d1188f2e19b5fbd4f8aa7bd89bfb2c44eda0eca97346
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
WORKDIR /workspace
COPY --from=builder /app/.venv /app/.venv
ENTRYPOINT ["pid"]
