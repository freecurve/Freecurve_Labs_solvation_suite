#!/bin/bash

#This path must be replaced with local matlab path
MATLABPATH=/share/apps/MATLAB/R2017a/bin/matlab

#DIR=$(cat $InFile | head -n$a | tail -n1 | awk '{print $2}')  # Absolute path to the compute folder
ENEDIR="./Output"
echo ENEDIR=$ENEDIR
UseBar='yes' # Define this variable if you want use BAR method for dG
src_path="../../../BIN/"
TaskID=5
SkipT=100
  if [ "$UseBar" ]; then
  echo "######################################"
  echo "### Analyzing files for BAR method ###"
  echo "######################################"
  #
  # Check that length of bar-files is not too short
  #
  BarList=$(ls $ENEDIR/Task"$TaskID"_*_SYSTEM_L_*.bar 2> /dev/null | sort -V -u)
  if [ ! "$BarList" ]; then
     echo "ERROR: No Task"$TaskID"_*_SYSTEM_L_*.bar files found"
     ErrMsg="No *_SYSTEM_L_*.bar files found"
     echo "$OUTNM	FAILED_{ERROR:_No_*_SYSTEM_L_*.bar_files_found}	$DAT	$ARB	$DIR" 
#     continue
  fi
  
  # Define parameters of saving in bar-files
  fnm0=$(echo "$BarList"| head -n1)
  TLen0=$(echo $(printf "%8.6f" $(cat $fnm0 | tail -10 | grep . |tail -1| awk '{print $1}')))
  TLen1=$(echo $(printf "%8.6f" $(cat $fnm0 | tail -10 | grep . |tail -2| head -1| awk '{print $1}')))
  dT=$(echo "scale=15; $TLen0 - $TLen1" | bc)
  #SkipT=$(echo "scale=0; $StartStep * $dT"|bc)
  StartStep=$(echo "scale=0; $SkipT / $dT"|bc)
  echo "SkipT=$SkipT dT=$dT SkipN=$StartStep"
  #exit
  
  # NLn0=$(cat $fnm0 | grep . |sed -n '$=')
  # if [ $NLn0 -le $StartStep ]; then
     # echo "ERROR: N lines in 0-bar file $NLn0 is less than N of skipped steps $StartStep"
     # ErrMsg="ERROR: N lines in 0-bar file $NLn0 is less than N of skipped steps $StartStep"
     # echo "$OUTNM	FAILED_{ERROR:_N_lines_in_0-bar_file_$NLn0_is_less_than_N_of_skipped_steps_$StartStep}	$DAT	$ARB	$DIR" >> $OutFile
     # continue
  # fi
  # echo "$fnm0 TLen=$TLen0 NLn0=$NLn0 NLn=$NLn"
  
  FAILED=''
  for fnm in $BarList
  do
#     echo "barlist_name= $fnm"
     NLn=$(cat $fnm | grep . | sed -n '$=')
#     echo "NLn=$NLn StartStep=$StartStep"
#     echo "SkipT=$SkipT dT=$dT SkipN=$StartStep"     
     if [ $NLn -le $StartStep ]; then
       FAILED='FAILED'
       break
     fi
  done
  if [ $FAILED ]; then
     fnm_short=$(echo $fnm| sed 's/.*\/\([^/]\+\)$/\1/')
     echo "ERROR: N lines $NLn in $fnm_short is less than $StartStep skipping steps"
     ErrMsg="ERROR: N lines $NLn in $fnm_short is less than $StartStep skipping steps"
     echo "$OUTNM	FAILED_{N_lines_$NLn_in_$fnm_short_is_less_than_$StartStep_skipping_steps}	${NumTIPoints}TIpoints-${TLen0}ps	$MolNumb	$DAT	$ARB	$DIR" >> $OutFile
     continue
  fi
  
  echo "TLen=$TLen0 NLn0=$NLn0 NLn=$NLn"
  
#exit
#
#              Compute dG by BAR method
#
echo "=========== Computing DG by BAR method =============="
#
#################### MATLAB Part ###############
#
       ResBar=$($MATLABPATH  -r "addpath $ENEDIR/;addpath $src_path/; [errBar,barC,timeC]=save_bar_noneven('$ENEDIR/',1,[$SkipTIpList]);if (~isempty(errBar))  fprintf('<<<\"ERROR: %s\">>>',errBar); quit; end; [dgB,errdgB]=runBAR_noneven(0.59219,$SkipT,1000000,barC,timeC);fprintf('<<<%8.4f\t%8.4f>>>',dgB,errdgB);quit" -nosplash -nodisplay| sed -n 's/.*[<]\{3\}\(.*\)[>]\{3\}.*/\1/p')

################ END of MATLAB Part #############
dG_min=`echo $ResBar | awk '{print $1}'`
dG_min_real=$(echo "scale=15; -1*$dG_min " | bc)
dG_err=`echo $ResBar | awk '{print $2}'`
echo "DG_solvation: $dG_min_real  stat_error:  $dG_err"
#echo "DG: $ResBar"
echo -e "=====================================================\n"
  fi  # End if UseBar



if [ "$(echo $Result| grep ERROR)" ]; then
  echo "$Result"
  Result=$(echo "$Result"| sed 's/\"//g;s/[ \t]/\_/g') # Replace spaces by "_"
  Result=$(echo "FAILED_{$Result}")
fi
if  [ "$UseBar" ]; then
  if [ "$(echo $ResBar| grep ERROR)" ]; then
    echo "$ResBar"
    ResBar=$(echo "$ResBar"| sed 's/\"//g;s/[ \t]/\_/g') # Replace spaces by "_"
    ResBar=$(echo "FAILED_{$ResBar}")
  else
    ResBar=BAR:$ResBar
  fi
fi
