#!/bin/sh

# a bug was introduced version after 0.82.3 and was fixed in a 0.88.0

pressio \
  many_independent_threaded \
  -b many_independent_threaded:compressor=sz3 \
  -b sz3:metric=historian \
  -b historian:metrics=composite \
  -b many_independent_threaded:metric=noop \
  -o composite:plugins=error_stat \
  -o composite:plugins=size \
  -o historian:events=clone \
  -o historian:events=decompress_many \
  -o many_independent_threaded:collect_metrics_on_decompression=1 \
  -o many_independent_threaded:preserve_metrics=1 \
  -o pressio:abs=1e-5 \
  -i ~/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32 -d 500 -d 500 -d 100 -t float -W /tmp/cloud.out -p \
  -i ~/git/datasets/hurricane/100x500x500/PRECIPf48.bin.f32 -d 500 -d 500 -d 100 -t float  -W /tmp/prect.out \
  -M all -O all

  
  
