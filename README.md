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
If you are performing a full data reproduction including walk-forward optimization, the generated outputs must be exported to the wf_optim_crypto_analysis project, so it could generate charts and tables.
### What is an experiment?
DVC uses the concept of an experiment to encapsulate the specific set of parameters, code, and data used during a single execution. In the context of this project, an experiment represents a complete walk-forward optimization run defined by:

- Time Frequency: e.g., 60-minute intervals.

- Window Periods: Specific training and testing lengths (e.g., 14 days and 10 days).

- Dataset: The source data used (e.g., the global training period).

The combination of these parameters, the script versions, and the resulting datasets constitute a unique experiment. To perform the final visualization and reporting, specific experiments must be exported to the wf_optim_crypto_analysis project.

### Required Exports:

- 📊 Global Training Experiments: Results of all experiments used to generate heatmaps and overall performance metrics. Example command :
  -  results should be filtered to make sure that other experiments (from unseen period) does not polute the data
  -  results are exported to CSV so later on, could be easily filetered, before planting them to data folder of `wf_optim_crypto_analysis`
```
dvc exp show --csv > global_training.csv
```

- 📈 Global Training Period: Intermediary data for the best parameter combinations identified in the research:
  - in order to generate equity curves and other statistics `wf_optim_crypto_analysis` need intermediate data which was generated during execution with  best paramaters in global traininng period (see research for details)
  - In the list of experiments which could be obtained by `dvc exp show` find experiment which was executed with following parameters:
    - BTC: Training length 14 days/Testing length 10  days, frequency 60 min, executed on data_global_train_20180101_20190930.csv
    - BTC: Training length 7 days/Testing length 28  days, frequency 60 min, executed on data_global_train_20180101_20190930.csv
  - For both found experiments names checkout experiment and copy intermediary data to respective folder of `wf_optim_crypto_analysis`

         

📉 Unseen Period: Intermediary data for the unseen period, applying optimal global parameters to BTC, ETH, and BNB:
  - Intermediary data for unseen perdio execution should also be copied to  `wf_optim_crypto_analysis`
  - In the list of experiments which could be obtained by `dvc exp show` find experiments which was executed with following parameters:
    - BTC/ETH/BNB: Training length 14 / Testing length 10 executed on data_unseen_20191001_20210920.csv
    - BTC/ETH/BNB: Training length 7 / Testing length 28 executed on data_unseen_20191001_20210920.csv

📋 Example: Extracting experiments
Follow this process to export data for specific experiments (e.g., BTC training 14 / testing 10, experiment name: crash-taka):

Checkout the experiment:
```
dvc checkout crash-taka
```
Copy the data to the analysis project: Copy the contents of the master\data-wip\ directory to `wf_optim_crypto_analysis analysis folder:
```
cp master\data-wip\1\60\* `wf_optim_crypto_analysis\data\global_training_period_results\dvc-exps\TRAIN_14_TEST_10_BTC`
```
[!IMPORTANT] Path Mapping: In the directory data-wip\[AssetID]\[Timeframe]\, the ID 1 represents BTC, 0 represents BNB, and 6 represents ETH. The value 60 represents the time sampling used. Adjust these folder names accordingly when copying for different experiment.


