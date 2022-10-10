#!/usr/bin/env bash

read -r -d '' ACC_GAIN << EOF
  local rse = metrics['error_stat:rmse'];
  local bitrate = metrics['size:bit_rate'];
  local std = metrics['error_stat:value_std'];
  local acc_gain = -1;
  if rse ~= nil and bitrate ~= nil then
    acc_gain = ( math.log( std / rse ) / math.log(2) ) - bitrate;
  end
  return "acc_gain", acc_gain
EOF

DATASETS=(
  "-i $HOME/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32 -t float -d 500 -d 500 -d 100"
)

echo_do () {
  echo $@
  "$@"
}


# spack install libpressio-tools+tthresh+sperr ^ libpressio+sz+zfp+lua+mgard cuda_arch=80
# spack load libpressio-tools ^ libpressio+lua

declare -A comp_extra_flags
comp_extra_flags[sperr]="-o sperr:chunks=100 -o sperr:chunks=100 -o sperr:chunks=100" # tuned chunk size for Hurricane

for input_dset in "${DATASETS[@]}"
  do
  for COMP in sz sz3 zfp sperr mgard tthresh 
  do
    REL=.5
    for (( i = 0; i < 10; i++ )); do
      echo compressor=$COMP REL=$REL
      echo_do pressio \
        $input_dset \
        -m error_stat -m size -M size:bit_rate -M error_stat:rmse -M composite:acc_gain \
        -b compressor=$COMP \
        -o rel=$REL \
        -o composite:scripts="$ACC_GAIN" \
        ${comp_extra_flags[$COMP]}

        REL=$(python -c "print( 0.5 * $REL )")
    done
  done
done
