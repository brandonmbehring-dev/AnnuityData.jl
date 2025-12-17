"""
Synthetic data provider for CI/testing.

Loads deterministic fixtures from CSV files for reproducible testing
and Julia-Python cross-validation.
"""

"""
    SyntheticProvider <: DataProvider

Data provider that loads synthetic fixtures from CSV files.

Fixtures are located in the `fixtures/` directory:
- `synthetic_rates.csv`: WINK-mimicking product rate data (200 rows)
- `payoff_truth_tables.csv`: Hand-verified payoff edge cases (135 rows)

# Example
```julia
provider = SyntheticProvider()
rates = load_rates(provider)
```
"""
struct SyntheticProvider <: DataProvider
    fixtures_path::String
end

# Default constructor using package fixtures directory
function SyntheticProvider()
    fixtures_path = joinpath(dirname(dirname(@__FILE__)), "fixtures")
    SyntheticProvider(fixtures_path)
end

"""
    load_rates(provider::SyntheticProvider)

Load synthetic rate data from CSV.

Returns DataFrame with 200 rows (40 MYGA, 110 FIA, 50 RILA)
mimicking WINK data distributions.
"""
function load_rates(provider::SyntheticProvider)
    csv_path = joinpath(provider.fixtures_path, "synthetic_rates.csv")
    if !isfile(csv_path)
        error("Synthetic rates fixture not found: $csv_path")
    end
    CSV.read(csv_path, DataFrame)
end

"""
    load_products(provider::SyntheticProvider, product_type::Symbol)

Load products of specified type from synthetic rates.

# Arguments
- `provider::SyntheticProvider`: The synthetic provider
- `product_type::Symbol`: One of :myga, :fia, :rila

# Returns
Vector of product structs
"""
function load_products(provider::SyntheticProvider, product_type::Symbol)
    rates = load_rates(provider)

    if product_type == :myga
        return _parse_myga_products(rates)
    elseif product_type == :fia
        return _parse_fia_products(rates)
    elseif product_type == :rila
        return _parse_rila_products(rates)
    else
        throw(ArgumentError("Unknown product type: $product_type. Expected :myga, :fia, or :rila"))
    end
end

"""
    load_payoff_truth_table(provider::SyntheticProvider)

Load payoff truth table for cross-validation testing.

Returns DataFrame with 135 test cases covering FIA and RILA payoffs
with all critical edge cases.
"""
function load_payoff_truth_table(provider::SyntheticProvider)
    csv_path = joinpath(provider.fixtures_path, "payoff_truth_tables.csv")
    if !isfile(csv_path)
        error("Payoff truth table fixture not found: $csv_path")
    end
    CSV.read(csv_path, DataFrame)
end


# =============================================================================
# Internal parsing functions
# =============================================================================

function _parse_myga_products(rates::DataFrame)
    myga_rows = filter(row -> row.productGroup == "MYGA", rates)
    products = MYGAProduct[]

    for row in eachrow(myga_rows)
        product = MYGAProduct(
            company = String(row.companyName),
            product_name = String(row.productName),
            fixed_rate = _safe_float(row.fixedRate),
            term_years = _safe_int(row.termYears),
            effective_yield = _get_col(row, :effectiveYield, row.fixedRate) |> _safe_float,
            am_best_rating = _get_col(row, :amBestRating, "A") |> _to_string,
            min_premium = _get_col(row, :minPremium, 10000.0) |> _safe_float,
            surrender_years = _get_col(row, :surrChargeDuration, row.termYears) |> _safe_int
        )
        push!(products, product)
    end

    return products
end

function _parse_fia_products(rates::DataFrame)
    fia_rows = filter(row -> row.productGroup == "FIA", rates)
    products = FIAProduct[]

    for row in eachrow(fia_rows)
        cap_val = _get_col(row, :capRate, missing)
        part_val = _get_col(row, :participationRate, missing)
        spread_val = _get_col(row, :spreadRate, missing)
        trigger_val = _get_col(row, :performanceTriggeredRate, missing)

        # Determine crediting method from available rates
        crediting_method = if !ismissing(cap_val) && cap_val > 0
            :cap
        elseif !ismissing(part_val) && part_val > 0
            :participation
        elseif !ismissing(spread_val) && spread_val > 0
            :spread
        elseif !ismissing(trigger_val)
            :trigger
        else
            :cap  # default
        end

        product = FIAProduct(
            company = String(row.companyName),
            product_name = String(row.productName),
            cap_rate = _safe_float_or_nothing(cap_val),
            participation_rate = _safe_float_or_nothing(part_val),
            spread_rate = _safe_float_or_nothing(spread_val),
            trigger_rate = _safe_float_or_nothing(trigger_val),
            trigger_threshold = _get_col(row, :triggerThreshold, 0.0) |> _safe_float,
            index_used = _get_col(row, :indexUsed, "S&P 500") |> _to_string,
            term_years = _safe_int(row.termYears),
            floor_rate = 0.0,  # FIA always has 0% floor
            crediting_method = crediting_method
        )
        push!(products, product)
    end

    return products
end

function _parse_rila_products(rates::DataFrame)
    rila_rows = filter(row -> row.productGroup == "RILA", rates)
    products = RILAProduct[]

    for row in eachrow(rila_rows)
        # Determine protection type from bufferModifier
        modifier = _get_col(row, :bufferModifier, "Losses Covered Up To")
        protection_type = if modifier == "Losses Covered Up To"
            :buffer
        else
            :floor
        end

        product = RILAProduct(
            company = String(row.companyName),
            product_name = String(row.productName),
            buffer_rate = _safe_float_or_nothing(_get_col(row, :bufferRate, missing)),
            floor_rate = _safe_float_or_nothing(_get_col(row, :floorRate, missing)),
            cap_rate = _safe_float_or_nothing(_get_col(row, :capRate, missing)),
            protection_type = protection_type,
            index_used = _get_col(row, :indexUsed, "S&P 500") |> _to_string,
            term_years = _safe_int(row.termYears),
            step_rate_tier1 = nothing,
            step_rate_tier2 = nothing
        )
        push!(products, product)
    end

    return products
end


# =============================================================================
# Helper functions
# =============================================================================

"""Get column value from DataFrameRow with default fallback."""
function _get_col(row, col::Symbol, default)
    if hasproperty(row, col)
        val = getproperty(row, col)
        return ismissing(val) ? default : val
    end
    return default
end

"""Convert any string type to String."""
_to_string(val::AbstractString) = String(val)
_to_string(val) = string(val)

function _safe_float(val)
    if ismissing(val)
        return 0.0
    elseif val isa AbstractString
        return parse(Float64, val)
    else
        return Float64(val)
    end
end

function _safe_float_or_nothing(val)
    if ismissing(val) || (val isa Number && val == 0)
        return nothing
    elseif val isa AbstractString
        parsed = tryparse(Float64, val)
        return parsed === nothing ? nothing : parsed
    else
        return Float64(val)
    end
end

function _safe_int(val)
    if ismissing(val)
        return 1
    elseif val isa AbstractString
        return parse(Int, val)
    else
        return Int(val)
    end
end
