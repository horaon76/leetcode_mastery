# Makefile for mdBook

# Variables
MD_BOOK = mdbook
BOOK_NAME = book
BUILD_DIR = book

# Default target
.PHONY: all
all: build

# Build the book
.PHONY: build
build:
	@echo "Building the mdBook..."
	$(MD_BOOK) build

# Serve the book locally
.PHONY: serve
serve:
	@echo "Serving the mdBook on localhost:3000..."
	$(MD_BOOK) serve

# Clean the build artifacts
.PHONY: clean
clean:
	@echo "Cleaning up the build directory..."
	rm -rf $(BUILD_DIR)

# Update mdBook to the latest version
.PHONY: update
update:
	@echo "Updating mdBook to the latest version..."
	brew upgrade mdbook

# Install mdBook (if not installed)
.PHONY: install
install:
	@echo "Installing mdBook using Homebrew..."
	brew install mdbook

# Help message
.PHONY: help
help:
	@echo "Makefile for mdBook"
	@echo "Usage:"
	@echo "  make build       - Build the mdBook"
	@echo "  make serve       - Serve the book locally"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make update      - Update mdBook to the latest version"
	@echo "  make install     - Install mdBook using Homebrew"
	@echo "  make help        - Display this help message"

