#!/usr/bin/env bash


MAKE2D=$(cat -<<EOF
  if is_compress then
    local dims = inputs[1]
    local dims_v = dims:dimensions()

    local cdims_v = {dims_v[1], dims_v[2]}
    for i=3,#dims_v do
      cdims_v[2] = cdims_v[2] * dims_v[i]
    end
    local my_dims_v = {}
    for i=1,#dims_v do
      my_dims_v[i] = dims_v[i]
    end
    local cdims = pressio_data.new(pressio_dtype.uint64, {2}, cdims_v)
    local dims_data = pressio_data.new(pressio_dtype.uint64, {#dims_v}, my_dims_v)

    local dims_op = pressio_option:new()
    dims_op:set_data(dims_data)
    options:set("resize:decompressed_dims", dims_op)

    local cdims_op = pressio_option:new()
    cdims_op:set_data(cdims)
    options:set("resize:compressed_dims", cdims_op)
  end
EOF
)

pressio -i ~/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32 -d 500 -d 500 -d 100 -t float \
  -b /pressio:pressio:compressor=lambda_fn \
  -b /pressio/lambda_fn:lambda_fn:compressor=resize \
  -b /pressio/lambda_fn/resize:resize:compressor=sz \
  -b /pressio/lambda_fn:lambda_fn:script="$MAKE2D" \
  -b /pressio:pressio:metric=input_stats \
  -o /pressio/lambda_fn/resize/sz:pressio:abs=1e-4 \
  -O all \
  -M all \
  -Q \
#  2>&1 | grep input_stats
