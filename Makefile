PACKAGE_VERSION := $(shell grep -m1 '^version' pyproject.toml | sed -E 's/version *= *"(.*)"/\1/')

.PHONY: install
install: ## Install the virtual environment
	@echo "🚀 Creating virtual environment using uv"
	@uv sync

.PHONY: check
check: ## Run code quality tools.
	@echo "🚀 Checking lock file consistency with 'pyproject.toml'"
	@uv lock --locked
	@echo "🚀 Formatting code: Running ruff format"
	@uv run ruff format --check
	@echo "🚀 Linting code: Running ruff check"
	@uv run ruff check
	@echo "🚀 Static type checking: Running pyright"
	@uv run pyright

.PHONY: test
test: ## Test the code with pytest
	@echo "🚀 Testing code: Running pytest"
	@uv run python -m pytest

.PHONY: build
build: clean-build ## Build wheel file
	@echo "🚀 Creating wheel file"
	@uvx --from build pyproject-build --installer uv

.PHONY: docker-build ## Build docker image
docker-build: build
	@echo "🚀 Creating docker image with version $(PACKAGE_VERSION)"
	@docker build --no-cache -t user/testrepo:$(PACKAGE_VERSION) .

.PHONY: clean-build
clean-build: ## Clean build artifacts
	@echo "🚀 Removing build artifacts"
	@uv run python -c "import shutil; import os; shutil.rmtree('dist') if os.path.exists('dist') else None"

.PHONY: help
help:
	@uv run python -c "import re; \
	[[print(f'\033[36m{m[0]:<20}\033[0m {m[1]}') for m in re.findall(r'^([a-zA-Z_-]+):.*?## (.*)$$', open(makefile).read(), re.M)] for makefile in ('$(MAKEFILE_LIST)').strip().split()]"

.DEFAULT_GOAL := help
