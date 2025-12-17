"""
    AnnuityData

Data layer for annuity pricing: product schemas, data providers, and synthetic fixtures.

This package provides:
- Product structs (MYGAProduct, FIAProduct, RILAProduct, GLWBProduct)
- DataProvider interface for extensible data sources
- SyntheticProvider for CI/testing with deterministic fixtures

# Example
```julia
using AnnuityData

# Load synthetic products for testing
provider = SyntheticProvider()
myga_products = load_products(provider, :myga)
fia_products = load_products(provider, :fia)
rila_products = load_products(provider, :rila)
```
"""
module AnnuityData

using CSV
using DataFrames

# Product schemas
include("schemas.jl")

# Data provider interface
include("providers.jl")

# Synthetic data provider
include("synthetic.jl")

# Public API
export MYGAProduct, FIAProduct, RILAProduct, GLWBProduct
export DataProvider, SyntheticProvider
export load_products, load_rates, load_payoff_truth_table

end # module AnnuityData
