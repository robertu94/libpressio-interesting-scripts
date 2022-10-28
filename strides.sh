#!/bin/sh

# a bug was introduced version after 0.82.3 and was fixed in a 0.88.0

pressio \
  chunking \
  -b chunking:compressor=many_independent_threaded \
  -b many_independent_threaded:compressor=sz3 \
  -b sz3:metric=historian \
  -b historian:metrics=composite \
  -b many_independent_threaded:metric=noop \
  -b composite:plugins=error_stat \
  -b composite:plugins=size \
  -b composite:plugins=write_debug_inputs \
  -o write_debug_inputs:write_output=true \
  -o write_debug_inputs:display_paths=true \
  -o write_debug_inputs:base_path=/tmp/hurr- \
  -o historian:events=clone \
  -o historian:events=decompress_many \
  -o many_independent_threaded:collect_metrics_on_decompression=1 \
  -o many_independent_threaded:preserve_metrics=1 \
  -o pressio:abs=1e-5 \
  -o chunking:size=500 \
  -o chunking:size=500 \
  -o chunking:size=1 \
  -i ~/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32 -d 500 -d 500 -d 100 -t float -W /tmp/cloud.out \
  -M all -O all
