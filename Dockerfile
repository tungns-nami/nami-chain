FROM golang:1.26-alpine AS builder

# Install dependencies
RUN apk add --no-cache \
    make \
    git \
    gcc \
    musl-dev \
    linux-headers \
    binutils \
    binutils-gold

WORKDIR /build

# Copy go mod files first for better caching
COPY go.mod go.sum ./

# Download dependencies with cache mount
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go mod download

# Copy source code
COPY . .

# Build binary with cache mounts and proper temp directory
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOCACHE=/root/.cache/go-build \
    GOTMPDIR=/tmp \
    TMPDIR=/tmp \
    make build

# Final image
FROM alpine:3.21

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    curl \
    jq \
    bash

# Copy binary from builder
COPY --from=builder /build/build/namid /usr/local/bin/namid

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create directory for data
RUN mkdir -p /root/.namid

# Expose ports
EXPOSE 26656 26657 1317 8545 8546 26660

# Set working directory
WORKDIR /root

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Default command
CMD ["namid", "start", "--home", "/root/.namid"]

