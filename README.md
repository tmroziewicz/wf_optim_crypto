
<div align="center">

# Walk-Forward Crypto Optimization - A novel approach to trading strategy parameter optimization, using double out-of-sample data and walk-forward techniques 📈
### High-performance backtesting and data pipeline orchestration.



![DVC](https://img.shields.io/badge/DVC-945DDB?style=flat-square&logo=data-version-control&logoColor=white)
![R](https://img.shields.io/badge/R-276DC3?style=flat-square&logo=r&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.9+-blue?style=flat-square&logo=python)
![Conda](https://img.shields.io/badge/Conda-Managed-green?style=flat-square&logo=anaconda)


</div>

authors :
- Tomasz Mroziewicz  ORCID: https://orcid.org/0009-0003-6540-6554, email: tomasz.mroziewicz2@gmail.com
- Robert Ślepaczuk   ORCID: https://orcid.org/0000-0001-5227-2014, corresponding author: rslepaczuk@wne.uw.edu.pl 


## Abstract 
This study introduces a novel approach to walk-forward optimization by parameterizing the
lengths of training and testing windows. We demonstrate that the performance of a trading
strategy using the Exponential Moving Average (EMA) evaluated within a walk-forward procedure
based on the Robust Sharpe Ratio is highly dependent on the chosen window size. We
investigated the strategy on intraday Bitcoin data at six frequencies (1 minute to 60 minutes)
using 81 combinations of walk-forward window lengths (1 day to 28 days) over a 19-month training period. The two best-performing parameter sets from the training data were applied to a 21-month out-of-sample testing period to ensure data independence. The strategy was only
executed once during the testing period. To further validate the framework, strategy parameters
estimated on Bitcoin were applied to Binance Coin and Ethereum. Our results suggest the robustness of our custom approach. In the training period for Bitcoin, all combinations of walk-forward windows outperformed a Buy-and-Hold strategy. During the testing period, the strategy
performed similarly to Buy-and-Hold but with lower drawdown and a higher Information Ratio.
Similar results were observed for Binance Coin and Ethereum. The real strength was demonstrated
when a portfolio combining Buy-and-Hold with our strategies outperformed all individual
strategies and Buy-and-Hold alone, achieving the highest overall performance and a 50%
reduction in drawdown. A conservative fee of 0.1\% per transaction was included in all calculations. A cost sensitivity analysis was performed as a sanity check, revealing that the strategy's break-even point was around 0.4\% per transaction. This research highlights the importance of optimizing walk-forward window lengths and emphasizing the value of single-time out-of-sample testing for reliable strategy evaluation.

<img width="400" alt="image" src="https://github.com/user-attachments/assets/6644af88-b8d4-4517-aba3-3b9ba58875cd" />                  <img width="395"  alt="image" src="https://github.com/user-attachments/assets/8d4dfe3d-70a2-4c42-8b4c-5cebf5a0873f" />


## Overview

This repository contains the code to reproduce the raw trading data for the research described in the paper. These datasets serve as the upstream source for the [wf_optim_crypto_analysis](https://github.com/tmr-crypto/wf_optim_crypto_analysis) project, which handles the final visual representation and reporting. 

The data generated here represents walk-forward optimization results across several key dimensions:

- A novel optimization metric less sensitive to its adjacent parametrization: Robust Sharpe Ratio

- Variable Window Lengths: Various lengths for the training and testing steps of the walk-forward process.

- Time Frequency: Multi-resolution data sampling (e.g., 1, 5, 10, 15, 30, and 60-minute intervals).

- Global Training Period: Optimization performed across the entire historical training set to identify best-performing parameters.

- Unseen Period: Validation results for out-of-sample data to test strategy robustness.
  
## Repository Structure

- 📂 master/data-raw: all raw/input data are stored
  
- 📂 master/data-wip: all data generated at each stage of processing
  
- 📜 master/rcode: R scripts executed by the DVC pipeline
  
- 🏗️ dvc.yaml: Defines all automated data processing stages,
  
- 🛠️ params.yaml: Defines all parameters used by the DVC pipeline
  
- 📖 README.md: Project documentation and setup guide
  
## Git branches

- **experiments/**: Best walk forward exectution from global training period a  from  is stored in its own self-contained branch to keep the history clean.

## Prerequisite 

Follow the same procedure as specified in the `wf_optim_crypto_analysis` section [Prerequisite](https://github.com/tmr-crypto/wf_optim_crypto_analysis#prerequisite)

## How to Reproduce Results

- 🐍 Open Anaconda Prompt: (Skip this if you chose manual installation). Activate the environment created in the prerequisites:
```
  conda activate wf_optim
```

- 📥 Clone repository
```
  git clone https://github.com/tmr-crypto/wf_optim_crypto wf_optim_crypto
```
- 📂 Navigate: Go to your cloned repository folder wf_optim_crypto 

- 📥 Data Acquisition: Download [wf_optim_crypto.zip](https://drive.google.com/file/d/10DIfheR9Ub9KtvffmHcGcdc7gG3VEdWl/view?usp=drive_link) (830 MB) from Google Drive and unzip it in `master\data-raw\`

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

- :rocket: To start executing the queue, run the following command:
```
  dvc queue start
```

- ⏳ To monitor the execution progress, use:
```
  dvc queue status 
```

- 📋 View Results: After the scripts finish, run the following command to list the DVC experiment results:
```
  dvc exp show
```

## Export Guide

If you are performing a full data reproduction—including the walk-forward optimization - the generated outputs must be exported to the [wf_optim_crypto_analysis](https://github.com/tmr-crypto/wf_optim_crypto_analysis) project to enable the generation of charts and tables.

### What is an experiment?

DVC uses the concept of an experiment to encapsulate the specific set of parameters, code, and data used during a single execution. In the context of this project, an experiment represents a complete walk-forward run defined by:

- Time Frequency: e.g., 60-minute intervals.

- WF Window Periods: Specific training and testing durations (e.g., 14-day training and 10-day testing intervals).

- Dataset: The source data used (e.g., the global training period).

The combination of these parameters, the script versions, and the resulting datasets constitute a unique experiment. To perform the final visualization and reporting, specific experiments must be exported to the [wf_optim_crypto_analysis](https://github.com/tmr-crypto/wf_optim_crypto_analysis) project.

### Required Exports:

- 📊 **Exporting Global Training Metrics**:
  
    To generate heatmaps and performance tables, you must export the metrics from all global training experiments.
    - **CSV Export**: Export the results to a CSV file for easy auditing and filtering before moving them to the analysis project. Ensure results are filtered so that experiments from the "unseen period" do not pollute the global training data.
    ```
    dvc exp show --csv > global_training.csv  
    ```
        
    - **Move the data**: copy file to `wf_crypto_analysis\data\global_training`
    ```
    cp  global_training.csv wf_crypto_analysis\data\global_training
    ```
    
    - **Update Configuration**: Open `wf_crypto_analysis\params.yaml` and update the corresponding entry in the `general` section under the `global_training_exps` item to point to your new file.
 
- 📈 **Global Training Period** :

  Experiment results and all intermediary data for the two best-performing parameter sets identified during the research for the BTC global training period:
    
  - **Locate the Experiments**:

    Run `dvc exp show` and identify the experiment names corresponding to the following parameter sets:
    
    - Set A: 14-day training / 10-day testing, 60-min frequency, using data_global_train_20180101_20190930.csv.

    - Set B: 7-day training / 28-day testing, 60-min frequency, using data_global_train_20180101_20190930.csv
      
  - Export the Data: For each of the experiments identified above, export the intermediary data to the `wf_optim_crypto_analysis`. See [Example: Extracting experiments](#-example-extracting-experiments))  for more     detailed instruction.
    
- 📉 **Unseen Period**:

  Experiment results generated by applying the optimal parameter sets, selected during the global training period, to the unseen (out-of-sample) data for BTC, ETH, and BNB:
 
  - **Locate the Experiments**:

    Run `dvc exp show` and identify the experiment names corresponding to the following parameter sets:
  
    - BTC/ETH/BNB: Training length 14 days/Testing length 10 days executed on data_unseen_20191001_20210920.csv

    - BTC/ETH/BNB: Training length 7 days/Testing length 28 days executed on data_unseen_20191001_20210920.csv
  
  -  Export the Data: For each of the experiments identified above, export the intermediary data to the `wf_optim_crypto_analysis`. See [Example: Extracting experiments](https://github.com/tmr-crypto/wf_optim_crypto/blob/main/README.md#-example-extracting-experiments))  for more     detailed instruction


#### 📋 Example: Extracting experiments

To analyze specific results, you must export the data generated by a DVC experiment (e.g. BTC: 14-day training / 10-day testing at a 60-minute frequency, experiment name: crash-taka).

- **Checkout the Experiment** This command synchronizes the local filesystem with the specific parameters and data of that experiment:
```
  dvc checkout crash-taka
```

- **Copy Data** to the Analysis Project Transfer the contents of the `master\data-wip` directory to the corresponding folder in your cloned `wf_optim_crypto_analysis` repository. 
```
  cp master\data-wip\1\60\* ..\wf_optim_crypto_analysis\data\global_training_period_results\dvc-exps\TRAIN_14_TEST_10_BTC
```

  [!IMPORTANT] **Target Folder**:

   - **Custom Parameters**: If exporting non-standard parameters, update the export folder name to reflect the new settings.

   - **Update params.yaml** : Ensure all folder path references within the general section of params.yaml of `wf_optim_crypto_analysis` are updated to match the new directory.
   
   
  [!IMPORTANT] Path Mapping Reference:    
  
  The directory structure follows the pattern data-wip\[AssetID]\[Timeframe]\.
  
  - Asset IDs: 1 = BTC, 0 = BNB, 6 = ETH.
   
  - Timeframe: 60 represents the 60-minute time sampling.

  
Ensure you adjust these identifiers when exporting data for different assets or time frequencies.


