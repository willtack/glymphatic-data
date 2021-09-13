#!/bin/bash
#
# Sort the glymphatic data by contrast mechanism
#
# GQI_MNI.zip: A GQI reconstruction of all the shells PLUS a DTI fit of the lower b-value shells. You’ll find diffusion ODF values (GFA, fa0-3, ISO) and tensor-based values (dti_fa, AD, MD,RD) in this archive
# NODDIGM_MNI.zip: A NODDI fit to all the shells. This uses a non-standard dPar=1.2e-3 as recommended here https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0217118
# NODDIWM_MNI.zip: Same NODDI model as the previous, but using the standard dPar=1.7e-3.
# MAPLMRI_MNI.zip: Laplacian-regularized MAPMRI scalars. These have a bunch of propagator metrics like RTOP, RTAP, RTPP, MSD and QIV.


rawDataDir=~/Projects/glymph/rawdata
dataDir=~/Projects/glymph/data

rm $(find -type f | grep template)

# start with GQI
for f in "${rawDataDir}"/GQI_MNI/MNI/*; do
  echo $f
  newbasename="$(echo $(basename $f) | sed -e 's/sphere.*x//')" # sort by timestamp, not series no
  newfile=$(dirname $f)/$newbasename
  cp $f $newfile
  contrast=$(echo $newfile | cut -d '-' -f 8 | cut -d '_' -f 1)
  subject=$(echo $newfile | cut -d '-' -f 2 | cut -d '_' -f 1)
  subjectDir="${dataDir}/GQI/${contrast}/sub-${subject}"
  mkdir -p ${subjectDir}
  mv $newfile ${subjectDir}/
done

# MAPLMRI_MNI
for f in "${rawDataDir}"/MAPLMRI_MNI/MNI/*; do
  newbasename="$(echo $(basename $f) | sed -e 's/sphere.*x//')" # sort by timestamp, not series no
  newfile=$(dirname $f)/$newbasename
  cp $f $newfile
  contrast=$(echo $newfile| cut -d '-' -f 8 | cut -d '_' -f 1)
  subject=$(echo $newfile | cut -d '-' -f 2 | cut -d '_' -f 1)
  subjectDir="${dataDir}/MPALMRI/${contrast}/sub-${subject}"
  mkdir -p ${subjectDir}
  mv $newfile ${subjectDir}/
done

# NODDIGM_MNI
for f in "${rawDataDir}"/NODDIGM_MNI/MNI/*; do
  newbasename="$(echo $(basename $f) | sed -e 's/sphere.*x//')" # sort by timestamp, not series no
  newfile=$(dirname $f)/$newbasename
  cp $f $newfile
  contrast=$(echo $newfile | cut -d '-' -f 8 | cut -d '_' -f 1)
  subject=$(echo $newfile | cut -d '-' -f 2 | cut -d '_' -f 1)
  subjectDir="${dataDir}/NODDIGM/${contrast}/sub-${subject}"
  mkdir -p ${subjectDir}
  mv $newfile ${subjectDir}/
done

# NODDIWM_MNI
for f in "${rawDataDir}"/NODDIWM_MNI/MNI/*; do
  newbasename="$(echo $(basename $f) | sed -e 's/sphere.*x//')" # sort by timestamp, not series no
  newfile=$(dirname $f)/$newbasename
  cp $f $newfile
  contrast=$(echo $newfile | cut -d '-' -f 8 | cut -d '_' -f 1)
  subject=$(echo $newfile | cut -d '-' -f 2 | cut -d '_' -f 1)
  subjectDir="${dataDir}/NODDIWM/${contrast}/sub-${subject}"
  mkdir -p ${subjectDir}
  mv $newfile ${subjectDir}/
done

# remove unnecessary folders
rm -r $(find ${dataDir} -type d | grep glymphatic)

#
# Breaking folders down by conditions
#

divideFolder(){
  # split subjects' scalar maps folder into baseline and sleep conditions
  subjectDir=$1 # the directory containing subject scalar data
  k=$2 # the number at which to split the list of files
  n=0
  for f in ${subjectDir}/*.nii.gz; do
    fname=$(basename $f)
    d="$(dirname $f)/subdir$((n++ / $k))" # create subfolders
    mkdir -p "$d"
    mv -- "$f" "$d/$fname"
  done
  # rename folders
  pushd "${subjectDir}"; mv subdir0 baseline; mv subdir1 hex; popd > /dev/null

  # exception case AC4907
  subname=$(basename "${subjectDir}")
  if [[ $subname == sub-AC4907 ]]; then
     pushd "${subjectDir}"; mv subdir2/* hex/; rmdir subdir2; fi
}

# main loop
for modelDir in "${dataDir}"/*; do
  echo ------------------$(basename $modelDir)-----------------------
  for scalarDir in ${modelDir}/*; do
    echo $scalarDir
    for subjectDir in "${scalarDir}"/*; do
      subjectName=$(basename "${subjectDir}")
      case $subjectName in
        sub-AC4907 ) divideFolder $subjectDir 4
          ;;
        sub-KP5509 ) divideFolder $subjectDir 4
          ;;
        sub-LPV0000 ) divideFolder $subjectDir 4
          ;;
        sub-OW7586 ) divideFolder $subjectDir 8
          ;;
        *) divideFolder $subjectDir 6
      esac
    done
  done
done
