# AnnuityData.jl

Data layer for annuity pricing: product schemas, data providers, and synthetic fixtures.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/brandonmbehring-dev/AnnuityData.jl")
```

## Quick Start

```julia
using AnnuityData

# Load synthetic products for testing
provider = SyntheticProvider()
myga_products = load_products(provider, :myga)
fia_products = load_products(provider, :fia)
rila_products = load_products(provider, :rila)

# Access product data
for product in myga_products[1:3]
    println("$(product.company): $(product.product_name) - $(product.fixed_rate * 100)%")
end
```

## Features

- **Product Schemas**: Type-safe structs for MYGA, FIA, RILA, and GLWB products
- **DataProvider Interface**: Extensible interface for different data sources
- **SyntheticProvider**: Deterministic fixtures for CI/testing and cross-validation

## Product Types

### MYGAProduct
Multi-Year Guaranteed Annuity with fixed interest rate.

### FIAProduct
Fixed Indexed Annuity with cap/participation/spread/trigger crediting methods.

### RILAProduct
Registered Index-Linked Annuity with buffer or floor protection.

### GLWBProduct
Guaranteed Lifetime Withdrawal Benefit rider parameters.

## Testing

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

## License

MIT
