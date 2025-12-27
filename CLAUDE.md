# AnnuityData.jl

Data layer for annuity pricing: product schemas, data providers, synthetic fixtures.

## Development

### Build & Test

```bash
# Run tests
julia --project=. -e "using Pkg; Pkg.test()"

# REPL development
julia --project=.
```

### Architecture Notes

**Package Suite Hierarchy**:
```
AnnuityCore.jl  (base math layer)
    ↑
AnnuityData.jl  ← YOU ARE HERE (product schemas)
    ↑
AnnuityProducts.jl (uses both Core + Data)
```

**Why no AnnuityCore dependency?**

Deliberate decoupling. This package defines *what* products are (schemas), not *how* to price them (math). Benefits:
1. Data layer can be tested independently
2. Schema changes don't require repricing validation
3. Lighter dependency footprint for data-only consumers

**DataProvider Interface**:

Extensible pattern for different data sources:
- `SyntheticProvider`: Deterministic fixtures for CI
- Future: `CSVProvider`, `DatabaseProvider`, etc.

```julia
# Implementing a new provider
struct MyProvider <: DataProvider end
load_products(::MyProvider, product_type::Symbol) = ...
```

### Schema Design

**Product structs are immutable** with explicit field types:
- Catches data errors at load time, not pricing time
- Enables compile-time optimizations
- Forces explicit handling of optional fields

**Synthetic fixtures are deterministic**:
- Same seed → same products
- Enables cross-language validation (Python annuity-pricing uses same seed)

## Contributing

**Adding a new product type**:
1. Define struct in `src/schemas/`
2. Add to `load_products` dispatch in provider
3. Create synthetic fixture with representative edge cases
4. Verify schema matches AnnuityProducts.jl expectations

---

**Hub**: @~/Claude/lever_of_archimedes/
**Related**: AnnuityCore.jl, AnnuityProducts.jl
