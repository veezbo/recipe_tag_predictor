#!/bin/bash

RUNPOD_PORT=REPLACE WITH YOUR POD PORT NUMBER
RUNPOD_ADDR=REPLACE WITH YOUR POD IP ADDRESS

# Upload script, python reqs, and notebook to run on runpod
scp -P "${RUNPOD_PORT}" runpod_script.sh root@"${RUNPOD_ADDR}":/root/
scp -P "${RUNPOD_PORT}" requirements.txt root@"${RUNPOD_ADDR}":/root/
scp -P "${RUNPOD_PORT}" food_recipes_finetuning.ipynb root@"${RUNPOD_ADDR}":/root/

# Upload Kaggle API key
scp -P "${RUNPOD_PORT}" ~/.kaggle/kaggle.json root@"${RUNPOD_ADDR}":/root/.kaggle/kaggle.json
