"""
Data provider interface for annuity data sources.

Providers implement the abstract `DataProvider` type and its methods
to supply product data from various sources (synthetic, WINK, database, etc.).
"""

"""
    DataProvider

Abstract type for data providers.

Implementations must define:
- `load_products(provider, product_type::Symbol)` → Vector of product structs
- `load_rates(provider)` → DataFrame of rate data
"""
abstract type DataProvider end

"""
    load_products(provider::DataProvider, product_type::Symbol)

Load products of the specified type from the data provider.

# Arguments
- `provider::DataProvider`: The data provider instance
- `product_type::Symbol`: One of :myga, :fia, :rila, :glwb

# Returns
- Vector of product structs (MYGAProduct, FIAProduct, etc.)

# Example
```julia
provider = SyntheticProvider()
myga_products = load_products(provider, :myga)
```
"""
function load_products end

"""
    load_rates(provider::DataProvider)

Load raw rate data from the data provider.

# Arguments
- `provider::DataProvider`: The data provider instance

# Returns
- DataFrame containing rate data with columns matching WINK schema

# Example
```julia
provider = SyntheticProvider()
rates_df = load_rates(provider)
```
"""
function load_rates end

"""
    load_payoff_truth_table(provider::DataProvider)

Load payoff truth table for cross-validation testing.

# Arguments
- `provider::DataProvider`: The data provider instance

# Returns
- DataFrame with columns: test_id, category, method, index_return,
  cap_rate, participation_rate, spread_rate, trigger_rate, trigger_threshold,
  buffer_rate, floor_rate, expected_payoff, cap_applied, floor_applied,
  edge_case, formula, reference
"""
function load_payoff_truth_table end
