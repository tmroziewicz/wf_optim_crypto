# A novel approach to trading strategy parameter optimization, using double out-of-sample data and walk-forward techniques on cryptocurrency market 
authors :
- Tomasz Mroziewicz  ORCID: https://orcid.org/0009-0003-6540-6554, email: t.mroziewic2@student.uw.edu.pl
- Robert Ślepaczuk   ORCID: https://orcid.org/0000-0001-5227-2014, corresponding author: rslepaczuk@wne.uw.edu.pl 

## Overview
This repository contains the code to reproduce the raw trading data for the research described in the paper. These datasets serve as the upstream source for the WF_OPTIM_CRYPTO_ANALYSIS project, which handles the final visual representation and reporting.

The data generated here represents walk-forward optimization results across several dimensions:
- Variable Window Lengths: Various lengths for training and testing steps of the walk-forward optimization.

- Global Training Period: Optimization across the entire historical training set.

- Unseen Period: Validation results for out-of-sample data.

## Repository Structure
- 📥 master/data-raw: all raw/input data are stored
- 📥 master/data-raw: all data generated at each stage of processing
- 📜 master/rcode: R scripts executed by the DVC pipeline
- 🏗️ dvc.yaml: Defines all automated data processing stages, 
- 🛠️ params.yaml: Defines all parameters used by the DVC pipeline
- 📖 README.md: Project documentation and setup guide
## Git branches
- **experiments/**: Best walk forward exectution from global training period a  from  is stored in its own self-contained branch to keep the history clean.

## Prerequisite 
Follow the same procedure as specified in the wf_optim_crypto_analysis section [Prerequisite](https://github.com/tmroziewicz/wf_optim_crypto_analysis?tab=readme-ov-file#prerequisite)

## How to Reproduce Results
- 🐍 Open Anaconda Prompt: (Skip this if you chose manual installation). Activate the environment created in the prerequisites:
```
conda activate wf_optim
```
- 📂 Clone repository
```
git clone https://github.com/tmroziewicz/wf_optim_crypto wf_optim_crypto
```
- 📂 Navigate: Go to your cloned repository folder wf_optim_crypto 
- 📥 Data Acquisition: Download wf_optim_crypto.zip from https://drive.google.com/file/d/10DIfheR9Ub9KtvffmHcGcdc7gG3VEdWl/view?usp=drive_link and unzip it in `master\data-raw\`
- Ensure `master\data-raw\` contains the following files:
  - `data_global_train_20180101_20190930.csv` - Global training data.
  - `data_unseen_20191001_20210920.csv` - Unseen period data.
- 📈 Reproduce Global Train Period: Execute the following command to queue execution using the same parameters as in the paper:
```
dvc exp run --queue -S  general.tfmin=1,5,10,15,30,60  -S wf.train_length=1,2,3,5,7,10,14,21,28  -S wf.test_length=1,2,3,5,7,10,14,21,28  -S general.performance_stat=sharpe -S general.raw_data=master/data-raw/data_global_train_20180101_20190930.csv
```
- 📉 Reproduce Unseen Period: Execute these commands to queue execution for the unseen period using the research parameters:
```
dvc exp run --queue -S  general.asset=0,1,6  -S general.tfmin=60  -S wf.train_length=14  -S wf.test_length=10 -S general.performance_stat=sharpe -S general.raw_data=master/data-raw/data_unseen_20191001_20210920.csv
dvc exp run --queue -S  general.asset=0,1,6  -S general.tfmin=60  -S wf.train_length=7   -S wf.test_length=28 -S general.performance_stat=sharpe -S general.raw_data=master/data-raw/data_unseen_20191001_20210920.csv
```
- 📋 View Results: After the scripts finish, run the following command to list the DVC experiment results:
```
  dvc exp show
```
## Export data for further processing and generating chart and tables 
If you are performing a full data reproduction including walk-forward optimization, the generated outputs must be exported to the wf_optim_crypto_analysis project.

Required Exports:

- 📊 Global Training Experiments: Results of all experiments used to generate heatmaps and overall performance metrics. Example command : 
```
dvc exp show {filter data for global training} > global_training.csv
```

- 📈 Global Training Period: Intermediary data for the best parameter combinations identified in the research:

BTC: Training length 14 / Testing length 10
BTC: Training length 7 / Testing length 28

This data could be retrieved using dvc checkout {experiment name for 14 10} this checkout experiment and data could be copied 
```
dvc checkout {experiment 14 10}
cp /data-wip/1/60/  wf_optim_crypto_analysis
```

📉 Unseen Period: Intermediary data for the unseen period, applying optimal global parameters to BTC, ETH, and BNB:

BTC/ETH/BNB: Training length 14 / Testing length 10

BTC/ETH/BNB: Training length 7 / Testing length 28
    
