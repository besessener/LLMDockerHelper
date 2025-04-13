param(
    [string]$command
)

$modelsFile = "models.txt"

if ($command -eq "start") {
    if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
        Write-Host "Docker is not installed." -ForegroundColor Red
        exit
    }

    try {
        docker info | Out-Null
        Write-Host "Docker is installed and running." -ForegroundColor Green
        docker-compose up -d
    }
    catch {
        Write-Host "Docker is installed but not running." -ForegroundColor Red
    }
}

elseif ($command -eq "stop") {
    docker-compose down
}

elseif ($command -eq "install") {
    function Check-Docker {
        $dockerStatus = docker ps --filter "name=ollama" --filter "status=running" | Select-String "ollama"
        if ($dockerStatus -eq $null) {
            Write-Host "Docker container 'ollama' is not running. Please run 'start' command to start it." -ForegroundColor Yellow
            exit
        }
    }

    $models = Get-Content -Path $modelsFile

    function Display-Menu {
        Write-Host "Select models to install (press number to toggle, Enter to continue):"
        for ($i = 0; $i -lt $models.Length; $i++) {
            $selected = if ($selectedModels[$i]) { "[X]" } else { "[ ]" }
            Write-Host "$($i + 1). $selected $($models[$i])"
        }
    }

    function Install-Models {
        $selectedModels = @()

        for ($i = 0; $i -lt $models.Length; $i++) {
            $selectedModels += $false
        }

        Check-Docker

        while ($true) {
            Clear-Host
            Display-Menu

            $key = Read-Host "Toggle a model number or press Enter to confirm"

            if ($key -match '^\d+$' -and $key -gt 0 -and $key -le $models.Length) {
                $modelIndex = [int]$key - 1
                $selectedModels[$modelIndex] = -not $selectedModels[$modelIndex]
            } elseif ($key -eq "") {
                break
            }
        }

        Write-Host "`nNote: Downloading models can take a while depending on size and connection. Be patient." -ForegroundColor Cyan

        for ($i = 0; $i -lt $models.Length; $i++) {
            if ($selectedModels[$i]) {
                $model = $models[$i]
                $installedModels = docker exec ollama ollama list

                if (-not ($installedModels -match $model)) {
                    Write-Host "Pulling model $model..."
                    docker exec -it ollama ollama pull $model
                } else {
                    Write-Host "$model is already installed."
                }
            }
        }

        Write-Host "`nDone. Add more models to 'models.txt' from https://ollama.com/search if you like." -ForegroundColor Green
    }

    Install-Models
}

else {
    Write-Host @"
Usage: ./llm.ps1 <command>

Commands:
  start     Start Docker containers using docker-compose
  stop      Stop Docker containers
  install   Interactively install models into the 'ollama' container from models.txt
"@
}
