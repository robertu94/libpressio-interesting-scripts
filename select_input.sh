#!/usr/bin/env bash

pressio -U all \
  -i ~/git/datasets/miranda_f32-256-384-384/density.f32.dat  \
  -d 384 -d 384 -d 256 -t float \
  -T "select"  \
  -u select:size=384 -u select:size=384 -u select:size=1 \
  -m input_stats -M all \
  noop
