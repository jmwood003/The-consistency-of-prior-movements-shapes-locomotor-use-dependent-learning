# General Information
This repository includes all data and code used in all analyses and figures from "The consistency of prior movements shapes locomotor use-dependent learning."

In addition, it includes the laboratory log which provides some basic information for all the testing sessions.

There is also a link to stage 1 of the registered report.


## Code and Data folders
There are three primary scrips that can be used to reproduce all data and analyses from the eNeuro paper: 

### 1. Individual analysis 
This script is housed in the individual analysis folder and is named "UDLV_IndividualAnalysis.m"  

The purpose of this script is to:

1. Import each individual’s data
2. Organize and filter the marker data
3. Detect gait events (heel strike / toe off)
4. Calculate and plot gait parameters of interest
5. Save all the information into a group table

To run this script, all the sub-functions within the folder "IndivFunctions" are required. In addition, all the data from the "RawData" subfolder is required. This folder contains all the raw data, in .txt files from the Motion Monitor which we used for our analysis. Each participant has a file for each phase they completed for each condition. 

Once all the necessary files are downloaded, in the first section, you must first change the group directory paths and the function paths in the script to the location in which the data files and functions are saved, respectively. This code is commented for specific instructions. In the second section, the specific testing session must be selected, you can run more than 1 but it takes extra time. All the testing sessions are commented out. 

### 2. Phase 1 analysis
This script reproduces all the figures and analyses from phase 1 of the registered report. This includes 

1. Plotting example target distributions
2. Model recovery analysis (confusion matrices)
3. Fitting models to prior data (from experiment 2 of Wood et al., 2020) 
4. Simulating both computational models
5. Plotting pilot data

To run this script, the "Wood2020Data.mat" and "Pilotdata.mat" files must be downloaded from the Data folder. In addition, the "HelperFunctions", "ModelFunctions" and "PlotFunctions" folders must be downloaded from the Code folder. These will allow all the code to run. 

Once all the necessary files are downloaded, in the first section, you must first change the group directory paths and the function paths in the script to the location in which the data files and functions are saved, respectively.

The script itself is split into sections, one for each Figure/Analysis. For further details, see the script which includes comments. 

### 3. Phase 2 analysis
This script reproduces all the figures and analyses from phase 2 of the registered report. This includes all figures and statistical analysis that is in the final paper (excluding the figures and analysis from phase 1). 

To run this script the "AllT.mat" file must be downloaded from the Data folder. In addition, the "HelperFunctions", "ModelFunctions" and "PlotFunctions" folders must be downloaded from the Code folder. As before, these will allow all the code to run. 

Once all the necessary files are downloaded, in the first section, you must first change the group directory paths and the function paths in the script to the location in which the data files and functions are saved, respectively.

The script itself is split into sections, one for each Figure/Analysis. The statistical analysis for each question is also in a separate section. For further details, see the script which includes comments.

## Documents folder
The documents folder contains the laboratory log which includes the following information for each testing session:

1. Subject ID
2. Condition
3. Testing date
4. Sex
5. Age (years)
6. Height (cm)
7. Self-selected walking speed (meters/second)
8. The left and right step length measured in the Motion Monitor
9. Subject's answers to two questions: "how difficult was it to hit the step length targets?" and "did it feel like you were walking normally during the washout phase?" The second question was only asked after the final session as to not cue the subjects into the primary outcome measure.
