# Makefile for Canopy - Fork of canopy-network/canopy

.PHONY: all build run stop clean logs test docker-build docker-up docker-down

# Default binary name
BINARY_NAME=canopy
BUILD_DIR=./build
MAIN_PATH=./cmd/canopy

# Docker compose file
COMPOSE_FILE=docker-compose.yml

# Go build flags
GOFLAGS=-ldflags "-s -w"

all: build

## build: Compile the Go binary
build:
	@echo "Building $(BINARY_NAME)..."
	@mkdir -p $(BUILD_DIR)
	go build $(GOFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_PATH)
	@echo "Build complete: $(BUILD_DIR)/$(BINARY_NAME)"

## run: Run the node locally
run: build
	@echo "Starting $(BINARY_NAME)..."
	$(BUILD_DIR)/$(BINARY_NAME)

## test: Run all tests
test:
	@echo "Running tests..."
	go test ./... -v -race -timeout 120s

## lint: Run golangci-lint
lint:
	@echo "Running linter..."
	golangci-lint run ./...

## fmt: Format Go source files
fmt:
	@echo "Formatting code..."
	gofmt -s -w .
	goimports -w .

## vet: Run go vet
vet:
	@echo "Running go vet..."
	go vet ./...

## docker-build: Build the Docker image
docker-build:
	@echo "Building Docker image..."
	docker build -f .docker/Dockerfile -t canopy:latest .

## docker-up: Start all services via docker-compose
docker-up:
	@echo "Starting services..."
	docker compose -f $(COMPOSE_FILE) up -d

## docker-down: Stop all services
docker-down:
	@echo "Stopping services..."
	docker compose -f $(COMPOSE_FILE) down

## logs: Tail docker-compose logs
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

## clean: Remove build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	go clean -cache

## deps: Download and tidy Go modules
deps:
	@echo "Downloading dependencies..."
	go mod download
	go mod tidy

## help: Show this help message
help:
	@echo "Usage: make [target]"
	@grep -E '^## ' Makefile | sed 's/## /  /'
