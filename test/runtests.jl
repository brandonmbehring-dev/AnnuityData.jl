using Test
using AnnuityData
using DataFrames

@testset "AnnuityData.jl" begin
    include("test_schemas.jl")
    include("test_synthetic.jl")
end
