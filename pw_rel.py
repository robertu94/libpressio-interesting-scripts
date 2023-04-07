#!/usr/bin/env python
import libpressio as lp
import numpy as np
from pprint import pprint

data = np.fromfile("/home/runderwood/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32", dtype=np.float32).reshape(100, 500, 500)

comp = lp.PressioCompressor.from_config({
        "compressor_id": "pw_rel",
        "early_config": {
            "pw_rel:abs_comp": "sz3",
            "pw_rel:sign_comp": "blosc",
            "pressio:metric": "composite",
            # "composite:plugins": ["size", "error_stat"] # to also look at error stats
            "composite:plugins": ["size"]
        },
        "compressor_config": {
            "blosc:compressor": "zstd",
            "blosc:clevel": 6,
            "pressio:pw_rel": 1e-3
        }
    })
out = np.zeros_like(data)
cdata = comp.encode(data)
out = comp.decode(cdata, out)
pprint(comp.get_metrics())
