# svndl
MATLAB code used for my research at the SVNDL in 2017.<br><br>
**Codebase dependencies**: <br>
https://github.com/svndl/rcaBase<br>
https://github.com/svndl/sweepAnalysis<br>
https://github.com/svndl/mrC<br>
https://github.com/alexschlegel/matlab_lib
<br><br>
**Directories:**<br>
*rcaFrequency* – Per-paradigm scripts for reading frequency-domain PowerDiva DFT text exports, performing RCA, calculating SEM via error ellipses, and plotting the results. Generates figures with several subplots: amplitude vs harmonic, phase angle vs harmonic, EGI topography plot.<br><br>
*rcaTime* – Per-paradigm scripts for reading time-domain PowerDiva Matlab exports, performing RCA, calculating SEM, and plotting the results. Generates multiple figures that display the timecourses of the reliable components for comparison across conditions.<br><br>
*archives* – Older, potentially non-functional code.<br><br>
*functions* – Dependencies for scripts in all other directories.<br><br
*sample data* – De-identified sample EEG data for whmRCA_mixed_freq.m test run.<br><br>
**Sample usage:**<br>
Clone entire repo and open whmRCA_mixed_freq.m. Fix directories in the header area of code, and run on sample data (in this repo). 
<br><br>
*Bethany H 2017*
