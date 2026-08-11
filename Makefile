.DEFAULT_GOAL := help

start: ## Start the LaTeX Docker container
	./run/start

build: ## Build the CV to PDF, in dist/
	./run/build

stop: ## Stop the LaTeX Docker container
	./run/stop

version: ## Tag a release point
	./run/version

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: start build stop version help
