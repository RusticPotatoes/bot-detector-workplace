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
clone_all:
	git clone git@github.com:RusticPotatoes/private-api.git
	git clone git@github.com:RusticPotatoes/highscore-worker.git
	git clone git@github.com:RusticPotatoes/public-api.git
	git clone git@github.com:RusticPotatoes/report-worker.git
	git clone git@github.com:RusticPotatoes/bot-detector-scraper.git
	git clone git@github.com:RusticPotatoes/Bot-Detector-Core-Files.git
	git clone git@github.com:RusticPotatoes/bot-detector-mysql.git
	git clone git@github.com:RusticPotatoes/AioKafkaEngine.git
	git clone git@github.com:RusticPotatoes/bot-detector-ML.git
	git clone git@github.com:RusticPotatoes/bdpy-repositories.git

clone_ml:
	git clone git@github.com:RusticPotatoes/bot-detector-ML.git

clone_core:
	git clone git@github.com:RusticPotatoes/Bot-Detector-Core-Files.git

clone_private:
	git clone git@github.com:RusticPotatoes/private-api.git

clone_hiscore:
	git clone git@github.com:RusticPotatoes/highscore-worker.git

clone_public:
	git clone git@github.com:RusticPotatoes/public-api.git

clone_report:
	git clone git@github.com:RusticPotatoes/report-worker.git

clone_scraper:
	git clone git@github.com:RusticPotatoes/bot-detector-scraper.git

clone_kafka:
	git clone git@github.com:RusticPotatoes/AioKafkaEngine.git

clone_sql:
	git clone git@github.com:RusticPotatoes/bot-detector-mysql.git

clone_bdpy:
	git clone git@github.com:RusticPotatoes/bdpy-repositories.git

clone_all_repos: clone_ml clone_core clone_private clone_hiscore clone_public clone_report clone_scraper clone_kafka clone_sql clone_bdpy

setup: clone_all_repos

# build docker containers
build_sql:
	docker-compose -f bot-detector-mysql/docker-compose-standalone.yml build

build_kafka:
	docker-compose -f AioKafkaEngine/docker-compose-standalone.yml build

build_private:
	docker-compose -f private-api/docker-compose-standalone.yml build

build_scraper: build_kafka
	docker-compose -f bot-detector-scraper/docker-compose-kafka.yml build
	docker-compose -f bot-detector-scraper/docker-compose-standalone.yml build

##TODO: determine why mysql when added to the docker-compose file list it fails at transferring context: 2B 
build_report: ## kafka base report kafaka setup, then sql setup, then report worker
	docker-compose -f bot-detector-mysql/docker-compose-standalone.yml -f AioKafkaEngine/docker-compose-standalone.yml -f report-worker/docker-compose-kafka.yml  build  --progress plain

# build_public: ## todo-test after ml work
# 	docker-compose -f AioKafkaEngine/docker-compose-standalone.yml -f bot-detector-mysql/docker-compose-standalone.yml -f public-api/docker-compose-standalone.yml build

# build_hiscore:
# 	docker-compose -f AioKafkaEngine/docker-compose-standalone.yml -f bot-detector-mysql/docker-compose-standalone.yml -f highscore-worker/docker-compose-standalone.yml build

# build_core:
# 	docker-compose -f AioKafkaEngine/docker-compose-standalone.yml -f bot-detector-mysql/docker-compose-standalone.yml -f Bot-Detector-Core-Files/docker-compose-standalone.yml build

build_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml build --progress plain

build_all: build_sql build_core build_private build_hiscore build_public build_report build_scraper build_kafka build_ml

# run docker containers
run_sql:
	docker-compose -f bot-detector-mysql/docker-compose-standalone.yml up -d

run_core:
	docker-compose -f Bot-Detector-Core-Files/docker-compose-standalone.yml up -d

run_private:
	docker-compose -f private-api/docker-compose-standalone.yml up -d

run_hiscore:
	docker-compose -f highscore-worker/docker-compose-standalone.yml up -d

run_public:
	docker-compose -f public-api/docker-compose-standalone.yml up -d

run_report:
	docker-compose -f report-worker/docker-compose-standalone.yml up -d

run_scraper:
	docker-compose -f bot-detector-scraper/docker-compose-standalone.yml up -d

run_kafka:
	docker-compose -f AioKafkaEngine/docker-compose-standalone.yml up -d

run_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml up

run_all: run_sql run_core run_private run_hiscore run_public run_report run_scraper run_kafka run_ml

# stop docker containers
stop_sql:
	docker-compose -f bot-detector-mysql/docker-compose-standalone.yml down

stop_core:
	docker-compose -f Bot-Detector-Core-Files/docker-compose-standalone.yml down

stop_private:
	docker-compose -f private-api/docker-compose-standalone.yml down

stop_hiscore:
	docker-compose -f highscore-worker/docker-compose-standalone.yml down

stop_public:
	docker-compose -f public-api/docker-compose-standalone.yml down

stop_report:
	docker-compose -f report-worker/docker-compose-standalone.yml down

stop_scraper:
	docker-compose -f bot-detector-scraper/docker-compose-standalone.yml down

stop_kafka:
	docker-compose -f AioKafkaEngine/docker-compose-standalone.yml down

stop_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml down

stop_all: stop_sql stop_core stop_private stop_hiscore stop_public stop_report stop_scraper stop_kafka stop_ml

# restart docker containers
restart_sql: stop_sql run_sql

restart_core: stop_core run_core

restart_private: stop_private run_private

restart_hiscore: stop_hiscore run_hiscore

restart_public: stop_public run_public

restart_report: stop_report run_report

restart_scraper: stop_scraper run_scraper

restart_kafka: stop_kafka run_kafka

restart_ml: stop_ml run_ml

restart_all: restart_sql restart_core restart_private restart_hiscore restart_public restart_report restart_scraper restart_kafka

# clean docker containers
clean_sql:
	docker-compose -f bot-detector-mysql/docker-compose-standalone.yml down --volumes

clean_core:
	docker-compose -f Bot-Detector-Core-Files/docker-compose-standalone.yml down --volumes

clean_private:
	docker-compose -f private-api/docker-compose-standalone.yml down --volumes

clean_hiscore:
	docker-compose -f highscore-worker/docker-compose-standalone.yml down --volumes

clean_public:
	docker-compose -f public-api/docker-compose-standalone.yml down --volumes

clean_report:
	docker-compose -f report-worker/docker-compose-standalone.yml down --volumes

clean_scraper:
	docker-compose -f bot-detector-scraper/docker-compose-standalone.yml down --volumes

clean_kafka:
	docker-compose -f AioKafkaEngine/docker-compose-standalone.yml down --volumes

clean_ml:
	docker-compose -f bot-detector-ML/docker-compose.yml down --volumes

clean_all: clean_sql clean_core clean_private clean_hiscore clean_public clean_report clean_scraper clean_kafka clean_ml

# clean and build docker containers
cleanbuild_ml: clean_ml build_ml

cleanbuild_sql: clean_sql clean_mysql_mount build_sql

cleanbuild_core: clean_core build_core

cleanbuild_private: clean_private build_private

cleanbuild_hiscore: clean_hiscore build_hiscore

cleanbuild_public: clean_public build_public

cleanbuild_report: clean_report build_report

cleanbuild_scraper: clean_scraper build_scraper

cleanbuild_kafka: clean_kafka build_kafka

cleanbuild_all: clean_all build_all

# stop, clean, build, and run docker containers
rerun_ml: cleanbuild_ml run_ml

rerun_sql: cleanbuild_sql run_sql

rerun_core: cleanbuild_core run_core

rerun_all: cleanbuild_all run_all

clean_mysql_mount:
	rm -rf ../bot-detector-mysql/mount

## enter venv
enter_venv:
	. venv/bin/activate

requirements: ## in venv install requirements
	source venv/bin/activate && \
	python3 -m pip install setuptools && \
	find . -name 'requirements.txt' -exec python3 -m pip install -r {} \;

# stop all containers in docker running
stop_all_containers:
	-if [ "`docker ps -q -f status=running | wc -l`" -gt 0 ]; then docker stop $(docker ps -q -f status=running); fi

# remove all containers in docker
remove_all_containers:
	-if [ "`docker ps -a -q | wc -l | tr -d ' '`" -gt 0 ]; then docker rm `docker ps -a -q`; fi

# remove all images in docker
remove_all_images:
	-if [ "`docker images -q | wc -l | tr -d ' '`" -gt 0 ]; then docker rmi `docker images -q`; fi

# remove all volumes in docker
remove_all_volumes:
	-if [ "`docker volume ls -q | wc -l | tr -d ' '`" -gt 0 ]; then docker volume rm `docker volume ls -q`; fi

# remove all networks in docker
remove_all_networks:
	-if [ "`docker network ls -q | wc -l | tr -d ' '`" -gt 0 ]; then docker network rm `docker network ls -q`; fi

# remove all containers, images, volumes, and networks in docker
reset_all: stop_all_containers remove_all_containers remove_all_images remove_all_volumes remove_all_networks

clone_ml_dependents:
	-clone_core
	-clone_hiscore
	-clone_scraper
	-clone_private
	-clone_sql
	-clone_public
	-clone_kafka

build_ml_dependents:
	build_sql
	build_core
	build_hiscore
	build_scraper
	build_private
	build_public
	build_kafka

setup_ml: clone_ml_dependents ## setup the repos needed to debug the bot-detector-ML, init the .env file from the .env.example file
# cp bot-detector-ML/.env-example bot-detector-ML/.env

# set upstream for every sub directory to be upstream for the org Bot-detector with the repo being the dir name
# upstream for example private-api would be Bot-detector/private-api
set_upstream:
	cd private-api && git remote add upstream https://github.com/Bot-detector/private-api.git
	cd highscore-worker && git remote add upstream https://github.com/Bot-detector/highscore-worker.git
	cd public-api && git remote add upstream https://github.com/Bot-detector/public-api.git
	cd report-worker && git remote add upstream https://github.com/Bot-detector/report-worker.git
	cd bot-detector-scraper && git remote add upstream https://github.com/Bot-detector/bot-detector-scraper.git
	cd Bot-Detector-Core-Files && git remote add upstream https://github.com/Bot-detector/Bot-Detector-Core-Files.git
	cd bot-detector-mysql && git remote add upstream https://github.com/Bot-detector/bot-detector-mysql.git
	cd AioKafkaEngine && git remote add upstream https://github.com/Bot-detector/AioKafkaEngine.git
	cd bot-detector-ML && git remote add upstream https://github.com/Bot-detector/bot-detector-ML.git

set_upstream_private_api:
	cd private-api && git remote add upstream https://github.com/Bot-detector/private-api.git

set_upstream_highscore_worker:
	cd highscore-worker && git remote add upstream https://github.com/Bot-detector/highscore-worker.git

set_upstream_public_api:
	cd public-api && git remote add upstream https://github.com/Bot-detector/public-api.git

set_upstream_report_worker:
	cd report-worker && git remote add upstream https://github.com/Bot-detector/report-worker.git

set_upstream_bot_detector_scraper:
	cd bot-detector-scraper && git remote add upstream https://github.com/Bot-detector/bot-detector-scraper.git

set_upstream_Bot_Detector_Core_Files:
	cd Bot-Detector-Core-Files && git remote add upstream https://github.com/Bot-detector/Bot-Detector-Core-Files.git

set_upstream_bot_detector_mysql:
	cd bot-detector-mysql && git remote add upstream https://github.com/Bot-detector/bot-detector-mysql.git

set_upstream_AioKafkaEngine:
	cd AioKafkaEngine && git remote add upstream https://github.com/Bot-detector/AioKafkaEngine.git

set_upstream_bot_detector_ML:
	cd bot-detector-ML && git remote add upstream https://github.com/Bot-detector/bot-detector-ML.git

#  git pull --unshallow 

fetch_upstream_bot-detector-mysql:
	git -C bot-detector-mysql stash save --include-untracked "Temporary stash before fetch upstream" && STASHED=1 || STASHED=0
	git -C bot-detector-mysql fetch upstream
	git -C bot-detector-mysql checkout develop
	git -C bot-detector-mysql reset --hard upstream/develop
	git -C bot-detector-mysql push origin develop
	if [ "$$STASHED" = "1" ]; then git -C bot-detector-mysql stash pop; fi

fetch_upstream_private-api:
	git -C private-api stash save --include-untracked "Temporary stash before fetch upstream" && STASHED=1 || STASHED=0
	git -C private-api fetch upstream
	git -C private-api checkout develop
	git -C private-api reset --hard upstream/develop
	git -C private-api push origin develop
	if [ "$$STASHED" = "1" ]; then git -C private-api stash pop; fi

fetch_upstream_highscore-worker:
	git -C highscore-worker stash save --include-untracked "Temporary stash before fetch upstream" && STASHED=1 || STASHED=0
	git -C highscore-worker fetch upstream
	git -C highscore-worker checkout develop
	git -C highscore-worker reset --hard upstream/develop
	git -C highscore-worker push origin develop
	if [ "$$STASHED" = "1" ]; then git -C highscore-worker stash pop; fi

# Repeat for other directories...
fetch_upstream_public-api:
	git -C public-api stash save --include-untracked "Temporary stash before fetch upstream" && STASHED=1 || STASHED=0
	git -C public-api fetch upstream
	git -C public-api checkout develop
	git -C public-api reset --hard upstream/develop
	git -C public-api push origin develop
	if [ "$$STASHED" = "1" ]; then git -C public-api stash pop; fi

fetch_upstream_report-worker:
	git -C report-worker stash save --include-untracked "Temporary stash before fetch upstream" && STASHED=1 || STASHED=0
	git -C report-worker fetch upstream
	git -C report-worker checkout develop
	git -C report-worker reset --hard upstream/develop
	git -C report-worker push origin develop
	if [ "$$STASHED" = "1" ]; then git -C report-worker stash pop; fi

fetch_upstream_bot-detector-scraper:
	git -C bot-detector-scraper stash save --include-untracked "Temporary stash before fetch upstream" && STASHED=1 || STASHED=0
	git -C bot-detector-scraper fetch upstream
	git -C bot-detector-scraper checkout develop
	git -C bot-detector-scraper reset --hard upstream/develop
	git -C bot-detector-scraper push origin develop
	if [ "$$STASHED" = "1" ]; then git -C bot-detector-scraper stash pop; fi

fetch_upstream_Bot-Detector-Core-Files:
	git -C Bot-Detector-Core-Files stash save --include-untracked "Temporary stash before fetch upstream" && STASHED=1 || STASHED=0
	git -C Bot-Detector-Core-Files fetch upstream
	git -C Bot-Detector-Core-Files checkout develop
	git -C Bot-Detector-Core-Files reset --hard upstream/develop
	git -C Bot-Detector-Core-Files push origin develop
	if [ "$$STASHED" = "1" ]; then git -C Bot-Detector-Core-Files stash pop; fi

fetch_upstream_AioKafkaEngine:
	git -C AioKafkaEngine stash save --include-untracked "Temporary stash before fetch upstream" && STASHED=1 || STASHED=0
	git -C AioKafkaEngine fetch upstream
	git -C AioKafkaEngine checkout develop
	git -C AioKafkaEngine reset --hard upstream/develop
	git -C AioKafkaEngine push origin develop
	if [ "$$STASHED" = "1" ]; then git -C AioKafkaEngine stash pop; fi

fetch_upstream_bot-detector-ML:
	git -C bot-detector-ML stash save --include-untracked "Temporary stash before fetch upstream" && STASHED=1 || STASHED=0
	git -C bot-detector-ML fetch upstream
	git -C bot-detector-ML checkout develop
	git -C bot-detector-ML reset --hard upstream/develop
	git -C bot-detector-ML push origin develop
	if [ "$$STASHED" = "1" ]; then git -C bot-detector-ML stash pop; fi

# fetch upstream for all repos
fetch_upstream_all: fetch_upstream_private-api fetch_upstream_highscore-worker fetch_upstream_public-api fetch_upstream_report-worker fetch_upstream_bot-detector-scraper fetch_upstream_Bot-Detector-Core-Files fetch_upstream_bot-detector-mysql fetch_upstream_AioKafkaEngine fetch_upstream_bot-detector-ML
