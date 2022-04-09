#!/usr/bin/env bash


pressio opt \
  -O all \
  -o opt:inputs=pressio:abs \
  -o opt:output=size:compression_ratio \
  -o opt:lower_bound=0 \
  -o opt:upper_bound=0.0005 \
  -o opt:is_integral=0 \
  -o opt:max_iterations=100 \
  -o opt:do_decompress=0 \
  -o opt:objective_mode_name=target \
  -o opt:target=20 \
  -o opt:global_rel_tolerance=.2 \
  -b pressio:compressor=mgard \
  -b opt:compressor=pressio \
  -b opt:search=fraz \
  -b opt:metric=composite \
  -b pressio:metric=size \
  -b composite:plugins=time \
  -b composite:plugins=size \
  -b composite:plugins=error_stat \
  -i ~/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32 \
  -d 500 -d 500 -d 100 -t float \
  -M all

  

