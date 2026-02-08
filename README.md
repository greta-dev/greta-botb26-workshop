## Getting Started with Bayesian Modelling in greta: A Practical Introduction

## Abstract

This intensive one-hour workshop provides a practical introduction to Bayesian modelling using the greta R package. Participants will learn the essential workflow for fitting Bayesian models, from model specification through to basic inference. We'll work through a simple linear regression example on real ecological data, demonstrating how to specify priors, fit models using MCMC, assess convergence, and interpret results. This course is designed for those with familiarity in R and linear models who want to quickly get started with Bayesian analysis in greta. By the end of the session, you'll have the foundational skills needed to fit basic Bayesian models and know where to go to learn more advanced techniques.

## Prerequisites

- Familiarity with R and RStudio
- Experience fitting linear models (lm/glm)
- Basic awareness of Bayesian concepts (priors, posteriors)

## Key Learning Objectives

1. **Understand greta's core workflow**: Recognise the key steps in a greta analysis pipeline
2. **Specify a simple Bayesian linear model**: Define variables, set priors, and construct a model object
3. **Run MCMC sampling**: Execute basic MCMC inference and understand what's happening
4. **Check model convergence**: Interpret trace plots and R-hat values to assess whether the model has converged
5. **Extract and interpret results**: Summarise posterior distributions and understand what they mean for your data

## Target Audience

Researchers and analysts who want a quick, practical introduction to get started with Bayesian modelling, with the understanding that additional self-study will be needed for more complex applications.

## Opening up the course locally on your machine

If you plan on following along locally on your machine instead of on posit cloud, you can download the course materials by copying this link and running it inside an RStudio session:

```r
use_course("https://github.com/greta-dev/greta-botb26-workshop/archive/refs/heads/main.zip")
```

Alternatively you can download the repository details by forking the repo, or pasting the above URL into the address bar of a browser.

## Setup & Installation

For instructions on installation see:

- [Cloud installation](setup-cloud.md)
- [Local installation](setup-local.md)

## Other packages requirements

To do this workshop, we recommend the following packages are installed. These are automatically installed on the posit cloud instance shared during the talk.

```r
library(pak)
pak(
  c(
    "tidyverse",
    "palmerpenguins",
    "coda",
    "bayesplot",
    "stats",
    "DiagrammeR"
  )
)
```
