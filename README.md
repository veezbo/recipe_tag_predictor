# Recipe Tag Predictor

## Abstract
This is a small test project to determine if it's possible  fine-tune a language model for a Seq2Seq task, despite the output sequence not requiring a specific order. As a case study, we focus on being able to predict tags in recipes.

## Background
Generally, Seq2Seq tasks are typically for learning _ordered_ sequences. Examples include:
- Machine Translation
- Text Summarization
- Question Answering
- Text to Code

Note that all of the above examples require the tokens in the output sequence to have a certain ordering.

However, can we use the same training paradigm for learning _unordered_ sequences? Examples include:
- Multi-label classification
- Sequence tagging (e.g. automatically generating tags for files, tagging gene sequences by function)
- Keyword Extraction
- Recommendation Systems (e.g. recommending a set of items for a user)

## Methods
In this project, we consider the task of predicting recipe tags given information about recipes as a case study.

We use the "Food.com Recipes and Interactions" dataset scraped from Food.com on Kaggle [1]. This dataset includes various features of recipes, including cooking time, ingredients, steps to complete the recipe, and user-generated tags.

Specifically, we naively construct a prompt using recipe metadata in the input of the form:

```
Given a recipe, predict its tags.
---
Recipe Name: {NAME}
Cooking Time: {COOKING_TIME} minutes
Number of Ingredients: {NUMBER_OF_INGREDIENTS}
Number of Steps: {NUMBER_OF_STEPS}
Ingredients: {INGREDIENTS_AS_A_CSV}
Steps: {STEPS_AS_PLAINTEXT}
---
Now, predict the tags.
```

And then we expect the output string to be a comma-separated list of tags, i.e. of the form:

```
tag_1,tag_2,tag_3,...tag_n
```

We then fine-tune the [t5-small](https://huggingface.co/google-t5/t5-small) text-to-text transformer model [2] using the [Seq2Seq training pipeline](https://huggingface.co/docs/transformers/v4.38.1/en/main_classes/trainer#transformers.Seq2SeqTrainer) available on HuggingFace using the input/output format above. Note that we don't even provide the model with the full set of tags- it has to learn the tag distribution during the fine-tuning process.

Because there is no implicit ordering on the recipe tags in our output, we cannot naively use the standard cross-entropy loss function for next-token prediction. However, we can impose an arbitrary ordering of recipe tags that can be learned. Two examples are:
1. Alphanumeric Ordering
2. Dataset Frequency

In this project, we chose to implement (1), with the expectation that transformer models can implicitly learn alphanumeric ordering by understanding which tokens should be output sooner in the sequences. We also expect that (2) will also produce good results, provided there are enough examples of each tag in the input. 

By imposing an ordering, we can once again learn from the standard cross-entropy loss.

## Results
Although we train on the cross-entropy loss, because it is differentiable, we track the performance of the model using the Jaccard Similarity and the Dice Coefficient metrics. These are both measures of the similarity of two sets, a good match for what is effectively a set prediction task. 

After fine-tuning t5-small on 95% of the input data for a single epoch, we are able to achieve the following performance:

| Metric  | Score |
|---------|-------|
| Jaccard | 0.218 |
| Dice    | 0.348 |

Performance here is represented as a performance on a 200 size validation set. Since training was only run once, the validation set can be considered as a test set as well (no chance of overfitting to the validation set). Additionally, no hyperparameter optimization was done.

The above performance is a bit surprising- given that we give the model no prior indication as to the distribution of tags, and also that there is no theoretical ground truth for user-generated tags, the model is nevertheless able to learn not only which tags to input, but also the arbitrary ordering we have imposed.

## How to Run
This repository has been prepared to be run easily in any environment and is fairly compact. Two scripts are provided for running this directly on Runpod, but the notebook can easily be run locally or on a different cloud GPU provider.

The generic steps are:
1. Clone this repo
2. Ensure the files are in the place you wish to run the script. 
3. Install the python package dependencies, using the provided `requirements.txt` file and pip 
4. Download the dataset from Kaggle (you may need to create an account if you haven't already)
5. Run the cells in the notebook

The specific steps if using Runpod are:
1. Clone this repo locally
2. Create a runpod instance if you don't already have one. Ideally create one with the latest Pytorch image already built-in.
3. Edit `RUNPOD_PORT` and `RUNPOD_ADDR` in `local_script.sh` with the values from your instance.
4. Run ```bash local_script.sh```
5. Create a Kaggle API key if you don't already have it and install it locally
6. ssh into your Runpod instance and run ```bash runpod_script.sh```
7. Run the cells in the notebook

## References
[1] Shuyang Li. (2019). <i>Food.com Recipes and Interactions</i> [Data set]. Kaggle. https://doi.org/10.34740/KAGGLE/DSV/783630

[2] Raffel, C., Shazeer, N., Roberts, A., Lee, K., Narang, S., Matena, M., ... & Liu, P. J. (2020). Exploring the limits of transfer learning with a unified text-to-text transformer. J. Mach. Learn. Res., 21(140), 1-67.
