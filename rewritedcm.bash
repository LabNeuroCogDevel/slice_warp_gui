#!/usr/bin/env bash
set -e

# rewrite dicoms to look like a nifti
# usage: rewritedcm.bash "path/to/dcmdir" "path/to/nii.gz" [ "python" ]

[ -z "$1" -o ! -d "$1" ] && echo "bad dcm directory '$1'" && exit 1
[ -z "$2" -o ! -r "$2" ] && echo "bad nifti '$2'"         && exit 1

mkcannon() { echo $(cd $(dirname $1);pwd)/$(basename $1);}
mkniiandimg(){
  pwd
  dcm2niix .
  slicer -a img.png $(ls -1tc *nii.gz|sed 1q)
  ls $(pwd)/img.png
}

dcmdir=$(mkcannon $1)
niifile=$(mkcannon $2)

thisdir=$(cd $(dirname $0);pwd)
mlcmd="rewritedcm('$dcmdir','$niifile')"

(cd $dcmdir; mkniiandimg)

if [ -z "$3" ]; then
  matlab -nodisplay -r "try, addpath('$thisdir');$mlcmd;catch e, disp(e), end, quit()"
  cd ml*/
  mkniiandimg

else
  cd $(dirname $niifile)
  $thisdir/rewritedcm.py "$dcmdir" "$niifile"
  cd pySlice*/
  mkniiandimg
fi

