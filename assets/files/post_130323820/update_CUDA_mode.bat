@echo off 
echo Activating conda environment... 
call "miniconda3\Scripts\activate.bat" 
call conda activate tts-dataset-env 
echo Updating TTS Dataset Creator... 
pip install -r updated_CUDA_requirements.txt
pause 