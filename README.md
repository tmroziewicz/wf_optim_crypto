# A novel approach to trading strategy parameter optimization, using double out-of-sample data and walk-forward techniques on cryptocurrency market 
authors :
- Tomasz Mroziewicz  ORCID: https://orcid.org/0009-0003-6540-6554, email: t.mroziewic2@student.uw.edu.pl
- Robert Ślepaczuk   ORCID: https://orcid.org/0000-0001-5227-2014, corresponding author: rslepaczuk@wne.uw.edu.pl 

## Overview

This repository contains the code to reproduce the raw trading data for the research described in the paper. These datasets serve as the upstream source for the [wf_optim_crypto_analysis](https://github.com/tmroziewicz/wf_optim_crypto_analysis) project, which handles the final visual representation and reporting. 

The data generated here represents walk-forward optimization results across several key dimensions:

- Variable Window Lengths: Various lengths for the training and testing steps of the walk-forward process.

- Time Frequency: Multi-resolution data sampling (e.g., 1, 5, 10, 15, 30, and 60-minute intervals).

- Global Training Period: Optimization performed across the entire historical training set to identify best-performing parameters.

- Unseen Period: Validation results for out-of-sample data to test strategy robustness.
  
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

If you are performing a full data reproduction including walk-forward optimization, the generated outputs must be exported to the [wf_optim_crypto_analysis](https://github.com/tmroziewicz/wf_optim_crypto_analysis) project, so it could generate charts and tables.

### What is an experiment?

DVC uses the concept of an experiment to encapsulate the specific set of parameters, code, and data used during a single execution. In the context of this project, an experiment represents a complete walk-forward optimization run defined by:

- Time Frequency: e.g., 60-minute intervals.

- Window Periods: Specific training and testing lengths (e.g., 14 days and 10 days).

- Dataset: The source data used (e.g., the global training period).

The combination of these parameters, the script versions, and the resulting datasets constitute a unique experiment. To perform the final visualization and reporting, specific experiments must be exported to the [wf_optim_crypto_analysis](https://github.com/tmroziewicz/wf_optim_crypto_analysis) project.

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

    Run dvc exp show and identify the experiment names corresponding to the following parameter sets:
    
    - Set A: 14-day training / 10-day testing, 60-min frequency, using data_global_train_20180101_20190930.csv.

    - Set B: 7-day training / 28-day testing, 60-min frequency, using data_global_train_20180101_20190930.csv
      
  - Export the Data: (see [Example: Extracting experiments](https://github.com/tmroziewicz/wf_optim_crypto/blob/main/README.md#-example-extracting-experiments)) For each identified experiment, perform a `dvc checkout` and copy the intermediary data to the respective folders in the [wf_optim_crypto_analysis](https://github.com/tmroziewicz/wf_optim_crypto_analysis)
    

         

- 📉 **Unseen Period**:

  Experiment results generated by applying the optimal parameter sets, selected during the global training period, to the unseen (out-of-sample) data for BTC, ETH, and BNB:
  
  - Intermediary data for unseen perdio execution should also be copied to [wf_optim_crypto_analysis](https://github.com/tmroziewicz/wf_optim_crypto_analysis)

  - In the list of experiments which could be obtained by `dvc exp show` find experiments which was executed with following parameters:
  
    - BTC/ETH/BNB: Training length 14 days/Testing length 10 days executed on data_unseen_20191001_20210920.csv

    - BTC/ETH/BNB: Training length 7 days/Testing length 28 days executed on data_unseen_20191001_20210920.csv
  
  -  Export the Data: (see [Example: Extracting experiments](https://github.com/tmroziewicz/wf_optim_crypto/blob/main/README.md#-example-extracting-experiments)) For each identified experiment, perform a `dvc checkout` and copy the intermediary data to the respective folders in the [wf_optim_crypto_analysis](https://github.com/tmroziewicz/wf_optim_crypto_analysis)

#### 📋 Example: Extracting experiments

To analyze specific results, you must export the data generated by a DVC experiment (e.g., BTC: 14-day training / 10-day testing at a 60-minute frequency, experiment name: crash-taka).

- **Checkout the Experiment** This command synchronizes the local filesystem with the specific parameters and data of that experiment:
```
dvc checkout crash-taka
```
- **Copy Data** to the Analysis Project Transfer the contents of the data-wip directory to the corresponding folder in your cloned `wf_optim_crypto_analysis` repository. 
```
cp master\data-wip\1\60\* ..\wf_optim_crypto_analysis\data\global_training_period_results\dvc-exps\TRAIN_14_TEST_10_BTC
```
  [!IMPORTANT] **Target Folder**:
   
   - **Custom Parameters**: If you are exporting data using parameters different from those defined in the original research, ensure the export folder name is updated to reflect these new settings.
  
   - **Configuration Update**: You must update all folder references within the general section of params.yaml. Note that these path references appear in multiple entries throughout that section.
    
  [!IMPORTANT] Path Mapping Reference:    
  
  The directory structure follows the pattern data-wip\[AssetID]\[Timeframe]\.
  
  - Asset IDs: 1 = BTC, 0 = BNB, 6 = ETH.
   
  - Timeframe: 60 represents the 60-minute time sampling.

  
Ensure you adjust these identifiers when exporting data for different assets or time frequencies.


