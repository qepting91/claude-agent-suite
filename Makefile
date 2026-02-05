.PHONY: help test test-unit test-integration test-coverage test-verbose install clean build lint format package release-tag

help:
	@echo "Claude Agent Suite - Make Commands"
	@echo ""
	@echo "Testing:"
	@echo "  make test              - Run all tests"
	@echo "  make test-unit         - Run unit tests only"
	@echo "  make test-integration  - Run integration tests only"
	@echo "  make test-coverage     - Run tests with HTML coverage report"
	@echo "  make test-verbose      - Run tests with verbose output"
	@echo ""
	@echo "Development:"
	@echo "  make install           - Install dependencies"
	@echo "  make build             - Build all agents"
	@echo "  make build-verbose     - Build agents with verbose output"
	@echo "  make validate          - Validate templates without building"
	@echo "  make lint              - Run code linters"
	@echo "  make format            - Format code with black and isort"
	@echo ""
	@echo "Release:"
	@echo "  make package           - Create release zip package"
	@echo "  make release-tag V=x.y.z - Create and push release tag"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean             - Remove build artifacts and cache files"
	@echo "  make clean-test        - Remove test artifacts and coverage reports"

# Testing targets
test:
	pytest

test-unit:
	pytest -m unit

test-integration:
	pytest -m integration

test-coverage:
	pytest --cov=scripts --cov-report=html --cov-report=term-missing
	@echo "Coverage report generated in htmlcov/index.html"

test-verbose:
	pytest -v -s

# Development targets
install:
	pip install -r requirements.txt

build:
	python scripts/build.py

build-verbose:
	python scripts/build.py --verbose

validate:
	python scripts/build.py --validate-only

# Intelligence testing targets
eval: build
	@echo "Running intelligence tests with Promptfoo..."
	npx --yes promptfoo@latest eval -c eval/promptfoo.yaml

eval-ci: build
	@echo "Running intelligence tests (CI mode)..."
	npx --yes promptfoo@latest eval -c eval/promptfoo.yaml --output eval/results.json

# Code quality targets
lint:
	@echo "Running flake8..."
	flake8 scripts/ tests/ --max-line-length=120 --exclude=__pycache__,.pytest_cache
	@echo "Running mypy..."
	mypy scripts/build.py --ignore-missing-imports

format:
	@echo "Formatting with black..."
	black scripts/ tests/
	@echo "Sorting imports with isort..."
	isort scripts/ tests/

# Cleanup targets
clean:
	rm -rf dist/agents/*.md
	rm -rf build/
	rm -rf *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.orig" -delete

clean-test:
	rm -rf .pytest_cache/
	rm -rf htmlcov/
	rm -rf .coverage
	rm -f coverage.xml

# Release targets
package: build
	@echo "Creating release package..."
	mkdir -p dist/agents
	cp .claude/agents/*.md dist/agents/
	cp config/dangerous_commands.json dist/
	cp config/settings.json dist/
	cd dist && zip -r ../claude-agents.zip .
	@echo "Package created: claude-agents.zip"

release-tag:
ifndef V
	$(error Version not set. Usage: make release-tag V=1.0.0)
endif
	@echo "Creating release tag v$(V)..."
	git tag -a v$(V) -m "Release v$(V)"
	git push origin v$(V)
	@echo "Tag v$(V) pushed. GitHub Actions will create the release."
