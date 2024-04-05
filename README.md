# Setup Guide

## SSH Keys
1. Setup SSH keys for github following: https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh

## Repos: 

*Note: All make commands need to be ran in the same directory as the Makefile*
### MacOS/Linux
#### general setup



1. Run make setup
    
    ```makefile
    make setup
    ```

#### vscode and extensions setup

2. Install homebrew package manager: https://brew.sh

3. Relaunch your terminal and if needed, install VSCode and VSCode CLI. 
    
    *Note: you don't need to be admin*
    ```terminal
    brew install vscode
    brew install code-cli
    ```
4. Install Reccomended Extensions

    ```terminal
    make setup_extensions
    ```

### Windows:

#### general setup
1. Install Chocolately Package Manager: https://chocolatey.org/install#individual

2. Intall Make through chocolately
    ```powershell
    choco install make
    ```

#### vscode and extensions setup
3. *If needed, install VSCode

    ```powershell
    choco install vscode
    ```

3. Relaunch your terminal and run make setup.  

    ```powershell
    make setup
    ```

4. Install Reccomended Extensions

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