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

setup: clone 

