# Multi-stage Dockerfile for ethsold project

# Base image for Node.js projects
FROM node:18-alpine AS node-base
RUN apk add --no-cache git python3 make g++

# Solidity build stage
FROM node-base AS solidity-build
WORKDIR /app/solidity
COPY solidity/package*.json ./
RUN npm ci
COPY solidity/ ./
RUN npm run compile

# TypeScript DApp build stage
FROM node-base AS dapp-build
WORKDIR /app/dapp
COPY typescript/dapp-frontend/package*.json ./
RUN npm ci
COPY typescript/dapp-frontend/ ./
RUN npm run build

# Python base
FROM python:3.11-slim AS python-base
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

# Python CLI tools
FROM python-base AS python-cli
COPY python/web3-cli/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY python/web3-cli/ ./
ENTRYPOINT ["python"]

# Vyper compiler environment
FROM python-base AS vyper-env
COPY vyper/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY vyper/ ./
WORKDIR /app

# Go development
FROM golang:1.21-alpine AS go-build
RUN apk add --no-cache gcc musl-dev
WORKDIR /app
COPY go/rpc-client/go.* ./
RUN go mod download
COPY go/rpc-client/ ./
RUN go build -o /app/go-rpc-client .

# Rust/Solana environment
FROM rust:1.75-slim AS rust-build
WORKDIR /app
COPY rust/ ./
# Note: Would require Solana CLI for full build
# RUN cargo build --release

# Final production image with all tools
FROM node-base AS production
WORKDIR /app

# Copy built artifacts
COPY --from=solidity-build /app/solidity/artifacts ./solidity/artifacts
COPY --from=dapp-build /app/dapp/dist ./dapp/dist
COPY --from=go-build /app/go-rpc-client /usr/local/bin/

# Copy source files
COPY . .

# Install dependencies
RUN cd solidity && npm ci --only=production && \
    cd ../typescript/dapp-frontend && npm ci --only=production

EXPOSE 8545 5173 3000

CMD ["sh", "-c", "echo 'Use docker-compose to run specific services'"]
