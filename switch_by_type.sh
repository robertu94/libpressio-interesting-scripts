#!/usr/bin/env bash

script=$(cat - <<EOF
local is_floating = false;
local dtype = pressio_dtype.int8;
if is_compress then
  dtype = inputs[1]:dtype();
else
  dtype = outputs[1]:dtype();
end

if dtype == pressio_dtype.float or dtype == pressio_dtype.double then
  local option = pressio_option:new()
  option:set_uint64(1)
  options:set("switch:active_id", option)
else
  local option = pressio_option:new()
  option:set_uint64(0)
  options:set("switch:active_id", option)
end
EOF
)

pressio \
  -i ~/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32 -d 500 -d 500 -d 100 -t float \
  -b lambda_fn:compressor=switch \
  -b switch:compressors=blosc \
  -b switch:compressors=sz \
  -o lambda_fn:script="$script" \
  -o sz:error_bound_mode_str="abs"\
  -o sz:abs_err_bound=1e-5\
  -o blosc:compressor="zstd"\
  -o blosc:clevel=9\
  -O all \
  -M all \
  lambda_fn
