#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create installation directory
mkdir -p ollama-webui-install
cd ollama-webui-install

# Install required packages if not present
echo "Checking and installing required packages..."
if ! command_exists curl; then
    sudo apt-get update && sudo apt-get install -y curl
fi

# Download and install Miniconda if not exists
if [ ! -d "miniconda3" ]; then
    echo "Downloading Miniconda..."
    curl -k -L -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py311_25.5.1-1-Linux-x86_64.sh
    
    if [ $? -ne 0 ]; then
        echo "Error downloading Miniconda. Please check your internet connection and try again."
        exit 1
    fi
    
    echo "Installing Miniconda..."
    bash miniconda.sh -b -p $PWD/miniconda3
    rm miniconda.sh
fi

# Add Miniconda to PATH for this session
export PATH="$PWD/miniconda3/bin:$PATH"

# Create and activate conda environment
echo "Creating conda environment with Python 3.11..."
conda create -y -n ollama-env python=3.11
source miniconda3/bin/activate ollama-env

# Install Ollama
echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh

if [ $? -ne 0 ]; then
    echo "Error installing Ollama. Please check your internet connection and try again."
    exit 1
fi

# Install Open WebUI
echo "Installing Open WebUI..."
pip install open-webui

if [ $? -ne 0 ]; then
    echo "Error installing Open WebUI dependencies."
    exit 1
fi

# Create startup scripts
echo "Creating startup and management scripts..."

# Create start-ollama.sh
cat > start-ollama.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
echo "Starting Ollama server..."
ollama serve &
echo "Waiting for server to start..."
sleep 5
echo "Ollama server is running!"
echo
echo "You can now run start-webui.sh to access the web interface"
echo "or use manage-models.sh to manage your models."
EOF

# Create start-webui.sh
cat > start-webui.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
source miniconda3/bin/activate ollama-env
open-webui serve
EOF

# Create manage-models.sh
cat > manage-models.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

while true; do
    clear
    echo "Ollama Model Manager"
    echo "==================="
    echo
    echo "1. List installed models"
    echo "2. Download new model"
    echo "3. Run a model"
    echo "4. Remove a model"
    echo "5. Show model information"
    echo "6. Open Ollama Model Library in browser"
    echo "7. Exit"
    echo
    read -p "Enter your choice (1-7): " choice
    echo

    case $choice in
        1)
            clear
            echo "Currently installed models:"
            echo "========================="
            ollama list
            echo
            read -p "Press Enter to continue..."
            ;;
        2)
            clear
            echo "Download New Model"
            echo "================="
            echo
            echo "Visit https://ollama.com/library to see available models"
            echo "Example models: mistral, llama2, codellama, gemma"
            echo
            read -p "Enter model name to download: " model_name
            echo
            echo "Downloading $model_name..."
            ollama pull $model_name
            echo
            read -p "Press Enter to continue..."
            ;;
        3)
            clear
            echo "Run Model"
            echo "========="
            echo
            echo "Available models:"
            ollama list
            echo
            read -p "Enter model name to run: " model_name
            echo
            echo "Starting chat with $model_name..."
            echo "Type 'exit' to end the chat"
            echo
            ollama run $model_name
            ;;
        4)
            clear
            echo "Remove Model"
            echo "============"
            echo
            echo "Available models:"
            ollama list
            echo
            read -p "Enter model name to remove: " model_name
            echo
            ollama rm $model_name
            echo
            read -p "Press Enter to continue..."
            ;;
        5)
            clear
            echo "Show Model Information"
            echo "====================="
            echo
            echo "Available models:"
            ollama list
            echo
            read -p "Enter model name to show information: " model_name
            echo
            ollama show $model_name
            echo
            read -p "Press Enter to continue..."
            ;;
        6)
            xdg-open https://ollama.com/library 2>/dev/null || \
            open https://ollama.com/library 2>/dev/null || \
            echo "Could not open browser. Please visit https://ollama.com/library manually"
            ;;
        7)
            exit 0
            ;;
        *)
            echo "Invalid option"
            sleep 2
            ;;
    esac
done
EOF

# Create run-model.sh
cat > run-model.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

echo "Available models:"
echo "==============="
ollama list
echo
read -p "Enter model name to run: " model_name
echo
echo "Starting chat with $model_name..."
echo "Type 'exit' to end the chat"
echo
ollama run $model_name
EOF

# Make scripts executable
chmod +x start-ollama.sh start-webui.sh manage-models.sh run-model.sh

echo "Installation completed successfully!"
echo "To start the services:"
echo "1. Run ./start-ollama.sh"
echo "2. Wait a few seconds, then run ./start-webui.sh"
echo "The web interface will be available at http://localhost:8080"
echo
echo "To manage models:"
echo "- Use ./manage-models.sh for a menu-driven interface"
echo "- Use ./run-model.sh for quick model chat access"
EOF
