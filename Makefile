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

setup: clone