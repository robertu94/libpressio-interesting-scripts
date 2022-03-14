#!/usr/bin/env python
import numpy as np
from libpressio import PressioCompressor
from pathlib import Path
from ctypes import cdll
from pprint import pprint
from multiprocessing import cpu_count
opt = cdll.LoadLibrary("liblibpressio_opt.so")
path = Path.home() / "git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32"

data = np.fromfile(path, dtype=np.float32).reshape(100,500,500)
output = data.copy()

comp = PressioCompressor.from_config({
        "compressor_id": "opt",
        "compressor_config": {
            "opt:inputs": ["zfp:omp_threads"],
            "opt:output": ["time:compress_many"],
            "opt:lower_bound": [1],
            "opt:upper_bound": [cpu_count()],
            "opt:is_integral": [1],
            "opt:max_iterations": cpu_count()//2,
            "opt:objective_mode_name": "min",
            "zfp:execution_name": "omp"
        },
        "early_config": {
            "opt:compressor": "zfp",
            "opt:search": "fraz",
            "pressio:metric": "time",
        }
    })
comp_data = comp.encode(data)
comp.decode(comp_data, output)
pprint(comp.get_metrics())
