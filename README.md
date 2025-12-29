# A novel approach to trading strategy parameter optimization, using double out-of-sample data and walk-forward techniques on cryptocurrency market 

## Overview
This repository contains results and code to reproduce  research described in the paper "A novel approach to trading strategy parameter optimization,
using double out-of-sample data and walk-forward techniques on cryptocurrency market" 

authors :
- Tomasz Mroziewicz  ORCID: https://orcid.org/0009-0003-6540-6554, email: t.mroziewic2@student.uw.edu.pl
- Robert Ślepaczuk   ORCID: https://orcid.org/0000-0001-5227-2014, corresponding author: rslepaczuk@wne.uw.edu.pl 

## Repository Structure
- **main**: Contains this documentation.
- **experiments/**: Each experiment is stored in its own self-contained branch to keep the history clean.

#Prerequistits 
**Git**: Installed and configured.
**R**: version 3.6 or higher.
**DVC**: Install via `pip install dvc`.


## How to reproduce experiments 
- Clone repository git clone https://github.com/tmroziewicz/wf_optim_crypto wf_optim_crypto
- Navigate to repository cd wf_optim_crypto 
- Download data from https://drive.google.com/drive/folders/1HAYX3iUfO5ewWXlWK0MbOAu9HQ4l6Zzr
- Place in master\data-raw\
- Execute script  reproduce_unseen_period.bat  which contains dvc command to queue and executed the dvc experiments
- After script finished run command to list dvc experiment results: dvc exp show 