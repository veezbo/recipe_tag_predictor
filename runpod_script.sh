#!/bin/bash

mkdir recipe_tag_predictor
mv requirements.txt recipe_tag_predictor/
mv food_recipes_finetuning.ipynb recipe_tag_predictor/

cd recipe_tag_predictor || exit
pip install -r requirements.txt

mkdir data
cd data || exit
kaggle datasets download -d shuyangli94/food-com-recipes-and-user-interactions

cd ..
