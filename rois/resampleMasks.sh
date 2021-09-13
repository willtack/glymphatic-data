#!/bin/bash
#
# Resample masks to be compatible with glymph data
#

dataDir="/home/will/Projects/glymph/rois"

for roi in ${dataDir}/*_roi.nii.gz; do
  roiName=$(echo $(basename $roi) | cut -d '_' -f 1)
  echo $roiName
  resampleName="${dataDir}/${roiName}_res_mask"

  fslmaths ${roi} -thrp 50 -bin ${roi}
  3dresample -master ${dataDir}/template.nii.gz -input ${roi} -prefix ${resampleName}.nii.gz || echo 'already done'
done
