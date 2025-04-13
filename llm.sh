#!/bin/bash

command=$1
modelsFile="models.txt"

check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Docker is not installed."
        exit 1
    fi
}

check_container() {
    if ! docker ps --filter "name=ollama" --filter "status=running" | grep -q "ollama"; then
        echo "Docker container 'ollama' is not running. Please run './llm.sh start'."
        exit 1
    fi
}

display_menu() {
    echo "Select models to install (type numbers to toggle, Enter to confirm):"
    for i in "${!models[@]}"; do
        if [[ ${selectedModels[$i]} == true ]]; then
            echo "$((i + 1)). [X] ${models[$i]}"
        else
            echo "$((i + 1)). [ ] ${models[$i]}"
        fi
    done
}

install_models() {
    mapfile -t models < "$modelsFile"
    selectedModels=()

    for ((i=0; i<${#models[@]}; i++)); do
        selectedModels+=false
    done

    check_container

    while true; do
        clear
        display_menu
        read -p "Toggle a model number or press Enter to continue: " key

        if [[ "$key" =~ ^[0-9]+$ ]] && (( key >= 1 && key <= ${#models[@]} )); then
            index=$((key - 1))
            if [[ ${selectedModels[$index]} == true ]]; then
                selectedModels[$index]=false
            else
                selectedModels[$index]=true
            fi
        elif [[ -z "$key" ]]; then
            break
        fi
    done

    echo -e "\nNote: Downloading models may take time depending on model size and connection."

    for i in "${!models[@]}"; do
        if [[ ${selectedModels[$i]} == true ]]; then
            model="${models[$i]}"
            if ! docker exec ollama ollama list | grep -q "$model"; then
                echo "Pulling model $model..."
                docker exec -it ollama ollama pull "$model"
            else
                echo "$model is already installed."
            fi
        fi
    done

    echo -e "\nDone. You can add more models to 'models.txt' from https://ollama.com/search"
}

case "$command" in
    start)
        check_docker
        if docker info &> /dev/null; then
            echo "Docker is installed and running."
            docker-compose up -d

            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                xdg-open "http://localhost:3000"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                open "http://localhost:3000"
            fi
        else
            echo "Docker is installed but not running."
        fi
        ;;
    stop)
        docker-compose down
        ;;
    install)
        install_models
        ;;
    *)
        echo "Usage: $0 <command>
Commands:
    start     - Start Docker containers using docker-compose
    stop      - Stop Docker containers
    install   - Interactively install models into the 'ollama' container from models.txt
"
        ;;
esac
