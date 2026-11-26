#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

#--------------------- Miniconda: Download and Install If Needed -------------------
if [ ! -d "$SCRIPT_DIR/miniconda3" ]; then
    echo "Downloading Miniconda..."
    curl -fL -o miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py311_26.3.2-2-Linux-x86_64.sh

    echo "Installing Miniconda..."
    bash miniconda.sh -b -p "$SCRIPT_DIR/miniconda3"
    rm miniconda.sh
fi

CONDA_ROOT="$SCRIPT_DIR/miniconda3"
export PATH="$CONDA_ROOT/bin:$PATH"

# Initialize conda for this shell session
eval "$("$CONDA_ROOT/bin/conda" shell.bash hook)"

#--------------------- Accept Anaconda ToS (non-interactive) -----------------------
echo "Accepting Anaconda Terms of Service..."
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true
conda config --set plugins.auto_accept_tos yes || true

#--------------------- Create conda environment ------------------------------------
echo "Creating conda environment 'omnivoice' with Python 3.11..."
conda create -n omnivoice python=3.11 -y
conda activate omnivoice

#--------------------- Install dependencies ----------------------------------------
pip install torch==2.8.0+cu128 torchaudio==2.8.0+cu128 --extra-index-url https://download.pytorch.org/whl/cu128
pip install numpy==1.26.4
pip install omnivoice
pip install pandas==2.2.2

#--------------------- Create start_webui.sh ---------------------------------------
cat > "$SCRIPT_DIR/start_webui.sh" << 'EOF'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONDA_ROOT="$SCRIPT_DIR/miniconda3"
export PATH="$CONDA_ROOT/bin:$PATH"
eval "$("$CONDA_ROOT/bin/conda" shell.bash hook)"
conda activate omnivoice
echo "========================================="
echo " OmniVoice - Linux Launcher"
echo "========================================="
echo ""
omnivoice-demo --ip 0.0.0.0 --port 8001
EOF
chmod +x "$SCRIPT_DIR/start_webui.sh"

echo ""
echo "========================================="
echo " Installation complete!"
echo " Run ./start_webui.sh to launch OmniVoice."
echo " Open browser to: http://localhost:8001"
echo "========================================="
echo ""
