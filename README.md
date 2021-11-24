ARBALEST Molecular Dynamics Package and ARROW forcefield
---------------------------------------------------------

Inputs and running of Molecular Dynamics Simulations
----------------------------------------------------

1) System requirements: 
	a) There are two linux versions of the binaries: cuda and CPU only. the 
	   CPU binary should run on recent UBUNTU systems and other linux flavors.
 	   GPU binary requires one to install Cuda 10.2. 
	   For any problems use the 'issues' in https://github.com/freecurve/solvation_examples repository
	   if you wish to remain anonymous submit the links via and you can submit anonymous issues via 
	   https://gitreports.com/issue/freecurve/solvation_examples (will come as user 'freecurve')
	

	b) Post-processing scripts require MATLAB > R2017

2) Running examples:
 
	[A] For solute hydration Classical MD simulations

	Go to HydrationExamples
	Go to MD sub-directory
	Three examples of solute hydration a) methane b) water c) benzene
	For example: go to Methane sub-directory:
	a) For MD calculation on CPU
		./run_cpu.sh 
	b) For MD calculation on GPU
		./run_gpu.sh

	[B] For solute hydration Path-Integral MD simulations

	Go to HydrationExamples
	Go to PIMD sub-directory
	Three examples of solute hydration a) methane b) water c) benzene
        a) For PIMD calculation on CPU
                ./run_cpu.sh
        b) For PIMD calculation on GPU
                ./run_gpu.sh

The PIMD examples will run with 8 beads in H2O and 4 beads in CHEX

3) Post-processing and analysis: 

	a) The free energy of solvation is computed using BAR. Arbalest generates bar files in Output directory for the simulation 
	   runs. These .bar files are used by bar.sh to compute the free energy of solvation. 
	   As an example, we provide the output bar and energy files of methane hydration with MD in HydrationExamples/MD/SampleAnalysis: 
	   Go to that directory and on command line ./bar.sh
	   bar.sh  uses the bar files in Output directory generated from the MD/PIMD runs and provides the free energy of hydration.
	   To make it work one needs to provide path to matlab inside ./bar.sh e.g. by replacing line
	   MATLABPATH=/share/apps/MATLAB/R2017a/bin/matlab with your proper path. This will produce dG of solvation and estimated error.

	b) fermiBAR.m, out2mat.m, runBAR_noneven.m, and save_bar_noneven.m are 4 matlab files used by bar.sh in the computation
	    of free energy of solvation.

 
Helpful notes:
-------------- 

	a) The binaries for cpu and gpu version can be found in BIN:
	Arbalest binaries revision 3364

	-	ArbalestLight-FloatDoubleFixed-Cuda.r3364
		Cuda 10.2 is required to be installed
		Use '--gpu 1' option to run on GPU
	
	-	ArbalestLight-FloatDoubleFixed.r3364
		Runs on CPU only	
	

	b) use --help option to run Arbalest help, e.g.
	$./ArbalestLight-FloatDoubleFixed.r3364 --help

	c) The atom-typified input files for Methane, Benzene and water (HyperChemformat-HIN) can be found in HIN
