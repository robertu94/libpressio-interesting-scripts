#!/usr/bin/env bash


pressio opt \
  -o opt:inputs=zfp:omp_threads \
  -o opt:output=time:compress_many \
  -o opt:lower_bound=1 \
  -o opt:upper_bound=$(nproc) \
  -o opt:is_integral=1 \
  -o opt:max_iterations=$(($(nproc) / 2)) \
  -o opt:objective_mode_name=min \
  -o zfp:execution_name=omp \
  -b opt:compressor=zfp \
  -b opt:search=fraz \
  -b pressio:metric=time \
  -i ~/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32 \
  -d 500 -d 500 -d 100 -t float \
  -M all

  

