.PHONY: build run up shell clean outdated

# Variables
IMAGE_NAME = pyhabot
DIR = .

build:
	docker build -t $(IMAGE_NAME) ./$(DIR)

run:
	docker run --rm --env-file $(DIR)/.env $(IMAGE_NAME)

up: build run

shell:
	docker run --rm -it --env-file $(DIR)/.env --entrypoint /bin/bash $(IMAGE_NAME)

clean:
	rm -f $(DIR)/=*.0 $(DIR)/=*.1 $(DIR)/=*.5
	rm -rf $(DIR)/.venv $(DIR)/__pycache__ $(DIR)/**/__pycache__

outdated:
	cd $(DIR) && uv pip list --outdated