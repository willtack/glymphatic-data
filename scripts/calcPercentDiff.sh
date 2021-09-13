#!/bin/bash
#
# Calulate difference and percent change maps for diffusion scalars at baseline vs sleep
#

dataDir=~/Projects/glymph/data3

# main loop
for modelDir in "${dataDir}"/*; do
  echo ------------------$(basename $modelDir)-----------------------
  for scalarDir in ${modelDir}/*; do
    echo $scalarDir
    for subjectDir in "${scalarDir}"/sub-*; do
      subjectName=$(basename "${subjectDir}")

      # calculate means
      fName="${subjectName}_$(basename $modelDir)_$(basename $scalarDir)"
      echo $fname
      bl_mean="${subjectDir}/baseline/${fName}_bl_mean.nii.gz"
      hex_mean="${subjectDir}/hex/${fName}_hex_mean.nii.gz"
      c3d "${subjectDir}"/baseline/*.nii.gz -mean -o "${bl_mean}"
      c3d "${subjectDir}"/hex/*.nii.gz -mean -o "${hex_mean}"

      # subtract two mean images
      c3d "${hex_mean}" "${bl_mean}" -scale -1 -add -o ${subjectDir}/${fName}_diff.nii.gz

      # create percent change map
      #c3d ${subjectDir}/${fName}_diff.nii.gz "${bl_mean}" -divide -scale 100 -o ${subjectDir}/${fName}_perc_change.nii.gz
      fslmaths ${subjectDir}/${fName}_diff.nii.gz -div "${bl_mean}" -mul 100 ${subjectDir}/${fName}_pc.nii.gz

    done

    # create percent change directories for each scalar
    pcDir="${scalarDir}"/$(basename $modelDir)_$(basename $scalarDir)_pc
    echo $pcDir
    mkdir -p $pcDir
    cp $(find "${scalarDir}" -type f | grep pc)  "${pcDir}"/

    # do a group average of the percent change maps
    averageDir="${dataDir}/percentChangeGroupAvg"
    mkdir -p ${averageDir}
    c3d "${pcDir}"/sub-*_pc.nii.gz -mean -o "${averageDir}/$(basename ${modelDir})_$(basename ${scalarDir})_groupavg_pc.nii.gz";

  done
done
