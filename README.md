# LLM Docker Helper

This project provides a simple way to manage large language models (LLMs) via Docker using either PowerShell or Shell scripts. It helps you start, stop Open WebUI, and install models into your `ollama` container with ease.

## Features

- Start and stop Docker containers
- Interactive model installation from a list
- Web UI for managing models and chatting
- Supports both PowerShell (`llm.ps1`) and Shell (`llm.sh`)

## Requirements

- Docker installed and running
- PowerShell (on Windows) or Bash (on macOS/Linux)
- Internet connection to download models

## Usage

To run the script, use the appropriate file for your platform. The command is the same regardless of whether you're using PowerShell or Shell:

```bash
./llm.(ps1|sh) <command>
```

Where `<command>` can be one of the following:

* **start** – Starts Docker containers using docker-compose.
* **stop** – Stops the running Docker containers.
* **install** – Interactively installs models into the ollama container from the model list in models.txt.

## Configuration

- **Model List:** Add or remove model names in `models.txt` (one model per line).
- **Docker Services:** This project uses `ollama` (for LLM models) and `open-webui` (for web UI) containers.
- **Web UI:** Once started, you can access the Web UI at [http://localhost:3000](http://localhost:3000) to manage models.

## Notes

- The `install` command interacts with Docker to pull models into the `ollama` container.
- If Docker is not running, the script will notify you and stop.
- Model downloads may take time depending on the model size and your internet connection speed.
- The Web UI at [http://localhost:3000](http://localhost:3000) provides an easy interface for managing models as well.

## Get More Models

You can add more models to `models.txt` by visiting [https://ollama.com/search](https://ollama.com/search) and copying model names into the file.


## License

For license details you should always consider the licenses of the models and Open WebUI.
