.PHONY: clean clean-test clean-pyc clean-build build help
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

archive: ## archive all bot-detector repos to an archive folder with the file being a datestamp,  create a archive folder if it does not exist, archived files should go here, should remove repo folders after archiving
	mkdir -p archive
	tar -czvf ./archive/bot-detector-workplace-$(shell date +'%Y-%m-%d').tar.gz private-api highscore-worker public-api report-worker bot-detector-scraper Bot-Detector-Core-Files bot-detector-mysql AioKafkaEngine bot-detector-ML bdpy-repositories
	rm -rf private-api highscore-worker public-api report-worker bot-detector-scraper Bot-Detector-Core-Files bot-detector-mysql AioKafkaEngine bot-detector-ML bdpy-repositories

archive_temp: ## archive all bot-detector repos to an archive folder with the file being a datestamp,  create a archive folder if it does not exist, archived files should go here, should remove repo folders after archiving
	-mkdir -p archive
	-tar -czvf ./archive/temp-bot-detector-workplace-$(shell date +'%Y-%m-%d').tar.gz private-api highscore-worker public-api report-worker bot-detector-scraper Bot-Detector-Core-Files bot-detector-mysql AioKafkaEngine bot-detector-ML bdpy-repositories

restore_last_archived: archive_temp ## restore the last archived workplace, this will delete the current workplace, use with caution, should archive the current workplace before restoring with a temp flag so it's not selected for restore
	-rm -rf private-api highscore-worker public-api report-worker bot-detector-scraper Bot-Detector-Core-Files bot-detector-mysql AioKafkaEngine bot-detector-ML bdpy-repositories
	tar -xzvf $(shell ls -t archive/bot-detector-workplace-*.tar.gz | head -1)

remove_temp_archive: ## remove the last temp archive
	rm -f $(shell ls -t archive/temp-bot-detector-workplace-*.tar.gz | head -1)

restore_last_temp_archived_workplace: ## restore the last archived workplace, this will delete the current workplace, use with caution, should archive the current workplace before restoring with a temp flag so it's not selected for restore
	rm -rf private-api highscore-worker public-api report-worker bot-detector-scraper Bot-Detector-Core-Files bot-detector-mysql AioKafkaEngine bot-detector-ML bdpy-repositories
	tar -xzvf $(shell ls -t archive/temp-bot-detector-workplace-*.tar.gz | head -1)

remove_repos: ## remove all bot-detector repos
	rm -rf private-api highscore-worker public-api report-worker bot-detector-scraper Bot-Detector-Core-Files bot-detector-mysql AioKafkaEngine bot-detector-ML bdpy-repositories

export_extensions:
	code --list-extensions | xargs -L 1 echo code --install-extension

list_extensions:
	code --list-extensions

setup_extensions:
	code --install-extension codium.codium
	code --install-extension cweijan.dbclient-jdbc
	code --install-extension cweijan.vscode-mysql-client2
	code --install-extension eamodio.gitlens
	code --install-extension esbenp.prettier-vscode
	code --install-extension github.vscode-github-actions
	code --install-extension ms-azuretools.vscode-docker
	code --install-extension ms-python.black-formatter
	code --install-extension ms-python.debugpy
	code --install-extension ms-python.python
	code --install-extension ms-python.vscode-pylance
	code --install-extension oderwat.indent-rainbow
	code --install-extension redhat.vscode-yaml
	code --install-extension svipas.prettier-plus

# setup workspace by cloning down bot-detector repos
# must have github ssh keys setup, follow instructions here: 
# https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
clone:
	git clone git@github.com:Bot-detector/private-api.git
	git clone git@github.com:Bot-detector/highscore-worker.git
	git clone git@github.com:Bot-detector/public-api.git
	git clone git@github.com:Bot-detector/report-worker.git
	git clone git@github.com:Bot-detector/bot-detector-scraper.git
	git clone git@github.com:Bot-detector/Bot-Detector-Core-Files.git
	git clone git@github.com:Bot-detector/bot-detector-mysql.git
	git clone git@github.com:Bot-detector/AioKafkaEngine.git
	git clone git@github.com:Bot-detector/bot-detector-ML.git
	git clone git@github.com:Bot-detector/bdpy-repositories.git

setup: clone

setup_ml: ## setup the repos needed to debug the bot-detector-ML, init the .env file from the .env.example file
	git clone git@github.com:Bot-detector/bot-detector-ML.git
	git clone git@github.com:Bot-detector/Bot-Detector-Core-Files.git
	git clone git@github.com:Bot-detector/private-api.git
	git clone git@github.com:Bot-detector/bot-detector-mysql.git
# cp bot-detector-ML/.env-example bot-detector-ML/.env

build_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml build

up_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml up -d

down_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml down

restart_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml down
	docker-compose -f bot-detector-ML/docker-compose.yml up --build -d

clean_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml down --volumes

cleanbuild_ml: clean_ml
	docker-compose -f bot-detector-ML/docker-compose.yml up --build
