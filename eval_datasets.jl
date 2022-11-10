using Pressio

function eval_compressor(compressor_id, settings, data)
    comp = compressor(pressio(), compressor_id)
    set_options(comp, Dict{String,Any}("pressio:metric" => "composite"))
    set_options(comp, Dict{String,Any}("composite:plugins" => ["size", "time", "input_stats"]))
    set_options(comp, settings)
    output = similar(data)
    comp_data = compress(comp, data)
    decompress(comp, comp_data, output)
    get_metrics_results(comp)["size:compression_ratio"]
end

function main()
    filename = "/home/runderwood/git/datasets/hurricane/100x500x500/CLOUDf48.bin.f32"
    data = Array{Float32,3}(undef, 500, 500, 100)
    read!(filename, data)
    libpressio_register_all()
    println(unsafe_string(Pressio.LibPressio.pressio_supported_compressors()))
    println()

    println("realistic data")
    @show eval_compressor("blosc", Dict{String,Any}("blosc:compressor"=>"zstd", "blosc:clevel"=>Int32(9)), data)
    for abs in [1e-3 1e-4 1e-5]
        @show abs
        abs_config = Dict{String, Any}("pressio:abs"=> abs)
        @show eval_compressor("sz", abs_config, data)
        @show eval_compressor("zfp", abs_config, data)
        @show eval_compressor("sperr", abs_config, data)
    end

    println()

    println("random data")
    data = rand(Float32, 500,500,100)
    @show eval_compressor("blosc", Dict{String,Any}("blosc:compressor"=>"zstd", "blosc:clevel"=>Int32(9)), data)
    for abs in [1e-3 1e-4 1e-5]
        @show abs
        abs_config = Dict{String, Any}("pressio:abs"=> abs)
        @show eval_compressor("sz", abs_config, data)
        @show eval_compressor("zfp", abs_config, data)
        @show eval_compressor("sperr", abs_config, data)
    end
end
main()
