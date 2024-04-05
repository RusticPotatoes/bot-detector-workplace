# Setup Guide

## SSH Keys
1. Setup SSH keys for github following: https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh

## Repos: 

### MacOS/Linux
1. Run make setup

    ```makefile
    make setup
    ```

2. (Optional) Install Reccomended Extensions

    ```terminal
    make setup_extensions
    ```

### Windows:
1. Install Chocolately Package Manager: https://chocolatey.org/install#individual

2. Intall Make through chocolately
    ```powershell
    choco install make
    ```

3. *If needed, install VSCode

    ```powershell
    choco install vscode
    ```

3. Relaunch your terminal and run make setup.  Ensure you are in the root of the project, where the MAKEFILE exists.
    ```powershell
    make setup
    ```

4. (Optional) Install Reccomended Extensions

    ```powershell
    make setup_extensions
    ```

## Project Speicific Guideance 

### ML

### Hiscore Worker

### Scraper

### Core Files

### Bot Detector Common Libraries (Bdpy)

### MySQL

### Private API

### Public API

### AIOKafkaEngine