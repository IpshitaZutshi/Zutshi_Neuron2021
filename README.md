# Zutshi_Neuron2021
Additional scripts used for analyzing the datasets from Zutshi et al, Neuron 2021

Description of relevant scripts:

## Helper functions:		
  - getTrackingAcrossSess - wrapper to run specific scripts for each session
  - SessScriptWrapper	

## Metadata:
  - compileSessiontemplate - defines metadata for each animal to be compatible with cell explorer
  - compilecellMetrics - calculates cell metrics across animals and also loads the combined cell metrics structure to load the cell explorer GUI.
  - getHippocampalLayers_IZ - defines oriens, pyramidal layer., radiatum and sl.m. Needs manual inspection afterwards

## Scripts that calculate within a session:
  - bz_lfpCoherence
  - bz_ACFrequency

## Place field analysis
  - getPlaceFields - Need to have a lot of things calculated already, especially tracking and spikes. 
  - getPlaceFieldsDownsample - Rate matches stim and no stim trials separately for each session, and saves the downsampled spikes, as well as downsampled rate maps
  - getPhasePrecession - Need to have place fields and place field boundaries calculated already	

## Per animal, all sessions - stores the data in ‘summ’ folder for that animal

   ### For track recordings, LFP
      - SessBehaviorPowerSpectrum
      - SessPeriStimModIndexCSD - better for the CFC coupling
      - SessBehaviorLFPSpeed
      - SessBehaviorPowerProfile
      - SessBehaviorPhasePrecession - plots phase precession but need to add summary plots.
      - SessBehaviorCSDCoherence
      - SessBehaviorCSD - Calculates the CSD using oriens and slm as a reference
      - SessBehaviorThetaCompression - Calculates theta compression per session
      
  ### For track recordings, Unit data
      - SessBehaviorPlaceFields
      - SessTrialsPlaceFields - Calculates half session rate mapsto estimate stability
      - SessTrialByTrialMaps - Generates trial by trial rate maps
      - getPlaceFieldBoundaries - Need to have place field rate maps calculated already
      - SessPeriStimPhaseLocking
      - SessPeriStimACFrequency
      - SessUnitISI - Calculates the log ISI distribution, with LFP frequency for cells.

## Per animal, behavior results		
      - SessBehavior

## Calculate across animals, across sessions
  - calculateFiringMaps - generates firingmaps.mat across all animals
  - calculatePlaceFieldBoundaries
  - calculatePhaseLocking
  - calculateACData
  - calculatePhasePrecession - Calculates phase precession mat file
  - calculatePhasePrecessionSummary - Runs ‘SessBehaviorPhasePrecession’ across all mice
  - compileMiceBehavVars - Calculates time between stim and no stim trials etc

## Combine animals, after running the relevant per animal, all sessions script - stored in ‘Compiled’ folder’ 		
	- compileMiceBehavior
	- compileMicePowerProfile
  	- compileMicePowerSpectrumCSD
  	- compileMiceCSDPowerCorr
  	- compileMicePowerProfileCA3_individualmice
  	- compileMicePowerProfileCA3
  	- compileMiceThetaFreq - Compiles theta frequency and power in pyramidal  channel
  	- complileMiceCSDSinkShift
  	- compileMiceCSDPowerCoherence - Coherence along the linearized maze for stim vs no stim
  	- compileMiceModIdxCSD
  	- compileMiceLFPSpeed
  	- compileMiceUnitPSTH
  	- compileMiceResponseCA3 - plot the firing rate over time for CA3 mice.
  	- compileMicePlaceFields 
  	- compilePlaceFieldStats
  	- compileSplitterCells
  	- compileMicePhasePrecession
  	- compileMicePhaseLocking
  	- compileMicePhaseLockingVer2 - Incorporated polar statistics and only significant cells
  	- compileMiceACFrequency
  	- compileMiceACFrequencyVer2
  	- compileMiceISIHist
  	- compileMiceHippLayers - extracts theta power, CSD, coherence across select channels and plots across animals. Also does statistics
  	- compileMiceHippLayersCSD
  	- compileMiceCoherence - extracts coherence across select channels and plots across animals. 
  	- compareHCvsMaze - compares unit responses in the homecage versus on the maze

