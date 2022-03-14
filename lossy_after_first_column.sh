#!/usr/bin/env bash

outer_script=$(cat - <<EOF
if is_compress then
  local dims = inputs[1]:dimensions();
  local dims_size = #dims;
  local chunk_sizes = {};

  print(dims[1], dims[2])
  for i=1,dims_size do
    chunk_sizes[i] = 1;
  end
  chunk_sizes[1] = dims[1]
  print(chunk_sizes[1], chunk_sizes[2])

  local chunk_data = pressio_data.new(pressio_dtype.uint64, {dims_size}, chunk_sizes)
  local chunk_size_op = pressio_option:new();
  chunk_size_op:set_data(chunk_data);

  options:set("chunking:size", chunk_size_op)
end
EOF
)
inner_script=$(cat - <<EOF
local key = "/pressio/chunking/many_independent_threaded:many_independent_threaded:idx"
if is_set_options and set_options:key_status(key) == pressio_options_key_status.set then
  opt = set_options:get(key):get_uint64();
  local active_id;
  if opt == 0 then 
    active_id = pressio_option:new();
    active_id:set_uint64(0);
    options:set("switch:active_id", active_id);
  else
    active_id = pressio_option:new();
    active_id:set_uint64(1);
    options:set("switch:active_id", active_id);
  end
end
EOF
)

pressio -Q \
  -i ~/git/datasets/candle/nt_scaled_x4_train2.csv -T csv -t float \
  -b /pressio:lambda_fn:compressor=chunking \
  -b /pressio/chunking:chunking:compressor=many_independent_threaded \
  -b /pressio/chunking/many_independent_threaded:many_independent_threaded:compressor=lambda_fn \
  -b /pressio/chunking/many_independent_threaded/lambda_fn:lambda_fn:compressor=switch \
  -b /pressio/chunking/many_independent_threaded/lambda_fn/switch:switch:compressors=blosc \
  -b /pressio/chunking/many_independent_threaded/lambda_fn/switch:switch:compressors=sz_threadsafe \
  -o /pressio/chunking/many_independent_threaded:many_independent_threaded:nthreads=1\
  -o /pressio:lambda_fn:script="$outer_script" \
  -o /pressio/chunking:chunking:chunk_nthreads=8\
  -o /pressio/chunking/many_independent_threaded/lambda_fn/switch/sz_threadsafe:sz_threadsafe:error_bound_mode_str=rel\
  -o /pressio/chunking/many_independent_threaded/lambda_fn/switch/sz_threadsafe:sz_threadsafe:rel_err_bound=1e-5\
  -o /pressio/chunking/many_independent_threaded/lambda_fn/switch/blosc:blosc:compressor=zstd\
  -o /pressio/chunking/many_independent_threaded/lambda_fn:lambda_fn:on_set_options=1 \
  -o /pressio/chunking/many_independent_threaded/lambda_fn:lambda_fn:script="$inner_script" \
  -m size -m time \
  -O all \
  -M all \
  -F csv -W /tmp/out.csv \
  lambda_fn


