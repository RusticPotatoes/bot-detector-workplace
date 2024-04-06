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
	cp bot-detector-ML/.env-example bot-detector-ML/.env

build_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml build

run_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml up -d

stop_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml down

restart_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml down
	docker-compose -f bot-detector-ML/docker-compose.yml up --build -d

clean_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml down --volumes

cleanbuild_ml: clean_ml
	docker-compose -f bot-detector-ML/docker-compose.yml up --build

## enter venv
enter_venv:
	. venv/bin/activate

requirements: ## in venv install requirements
	source venv/bin/activate && \
	python3 -m pip install setuptools && \
	find . -name 'requirements.txt' -exec python3 -m pip install -r {} \;

# stop all containers in docker running
stop_all_containers:
	if [ "`docker ps -q -f status=running | wc -l`" -gt 0 ]; then docker stop $(docker ps -q -f status=running); fi

# remove all containers in docker
remove_all_containers:
	if [ "`docker ps -a -q | wc -l | tr -d ' '`" -gt 0 ]; then docker rm `docker ps -a -q`; fi

# remove all images in docker
remove_all_images:
	if [ "`docker images -q | wc -l | tr -d ' '`" -gt 0 ]; then docker rmi `docker images -q`; fi

# remove all volumes in docker
remove_all_volumes:
	if [ "`docker volume ls -q | wc -l | tr -d ' '`" -gt 0 ]; then docker volume rm `docker volume ls -q`; fi

# remove all networks in docker
remove_all_networks:
	if [ "`docker network ls -q | wc -l | tr -d ' '`" -gt 0 ]; then docker network rm `docker network ls -q`; fi

# remove all containers, images, volumes, and networks in docker
clean_all: stop_all_containers remove_all_containers remove_all_images remove_all_volumes remove_all_networks

rerun_ml: stop_ml clean_ml build_ml run_ml