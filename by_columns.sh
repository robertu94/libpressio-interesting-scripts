#!/usr/bin/env bash

script=$(cat - <<EOF
if is_compress then
  local dims = inputs[1]:dimensions();
  local dims_size = #dims;
  local chunk_sizes = {};

  for i=1,dims_size do
    chunk_sizes[i] = 1;
  end
  chunk_sizes[dims_size-1] = dims[dims_size-1]
  chunk_sizes[dims_size] = dims[dims_size]

  local chunk_data = pressio_data.new(pressio_dtype.uint64, {dims_size}, chunk_sizes)
  local chunk_size_op = pressio_option:new();
  chunk_size_op:set_data(chunk_data);

  options:set("chunking:size", chunk_size_op)
end
EOF
)

perftrace record pressio \
  -i ~/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32 -d 500 -d 500 -d 100 -t float \
  -b lambda_fn:compressor=chunking \
  -b chunking:compressor=many_independent_threaded \
  -b many_independent_threaded:compressor=sz_threadsafe \
  -o many_independent_threaded:nthreads=8\
  -o lambda_fn:script="$script" \
  -o sz_threadsafe:error_bound_mode_str=abs\
  -o sz_threadsafe:abs_err_bound=1e-5\
  -o chunking:chunk_nthreads=8\
  -O all \
  -m size \
  -M all \
  lambda_fn

