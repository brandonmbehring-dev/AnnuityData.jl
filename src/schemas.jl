"""
Product schemas for annuity pricing.

These structs mirror the Python dataclasses in annuity_pricing.data.schemas
for cross-validation purposes.
"""

# =============================================================================
# MYGA (Multi-Year Guaranteed Annuity)
# =============================================================================

"""
    MYGAProduct

Fixed annuity with guaranteed interest rate for a specified term.

# Fields
- `company::String`: Insurance company name
- `product_name::String`: Product name/identifier
- `fixed_rate::Float64`: Guaranteed annual interest rate (decimal, e.g., 0.05 for 5%)
- `term_years::Int`: Guarantee period in years
- `effective_yield::Float64`: Effective annual yield after expenses
- `am_best_rating::String`: AM Best credit rating (e.g., "A+", "A-")
- `min_premium::Float64`: Minimum initial premium
- `surrender_years::Int`: Surrender charge period in years
"""
struct MYGAProduct
    company::String
    product_name::String
    fixed_rate::Float64
    term_years::Int
    effective_yield::Float64
    am_best_rating::String
    min_premium::Float64
    surrender_years::Int
end

# Constructor with defaults
function MYGAProduct(;
    company::String,
    product_name::String,
    fixed_rate::Float64,
    term_years::Int,
    effective_yield::Float64=fixed_rate,
    am_best_rating::String="A",
    min_premium::Float64=10000.0,
    surrender_years::Int=term_years,
)
    MYGAProduct(
        company,
        product_name,
        fixed_rate,
        term_years,
        effective_yield,
        am_best_rating,
        min_premium,
        surrender_years,
    )
end

# =============================================================================
# FIA (Fixed Indexed Annuity)
# =============================================================================

"""
    FIAProduct

Fixed indexed annuity with index-linked returns subject to cap/participation/spread.

# Fields
- `company::String`: Insurance company name
- `product_name::String`: Product name/identifier
- `cap_rate::Union{Float64,Nothing}`: Maximum credited return (decimal)
- `participation_rate::Union{Float64,Nothing}`: Participation in index gains (decimal)
- `spread_rate::Union{Float64,Nothing}`: Spread deducted from index return (decimal)
- `trigger_rate::Union{Float64,Nothing}`: Fixed rate if trigger threshold met
- `trigger_threshold::Float64`: Index return threshold for trigger (decimal)
- `index_used::String`: Index name (e.g., "S&P 500", "NASDAQ-100")
- `term_years::Int`: Crediting term in years
- `floor_rate::Float64`: Minimum credited return (typically 0.0 for FIA)
- `crediting_method::Symbol`: :cap, :participation, :spread, or :trigger
"""
struct FIAProduct
    company::String
    product_name::String
    cap_rate::Union{Float64,Nothing}
    participation_rate::Union{Float64,Nothing}
    spread_rate::Union{Float64,Nothing}
    trigger_rate::Union{Float64,Nothing}
    trigger_threshold::Float64
    index_used::String
    term_years::Int
    floor_rate::Float64
    crediting_method::Symbol
end

# Constructor with defaults
function FIAProduct(;
    company::String,
    product_name::String,
    cap_rate::Union{Float64,Nothing}=nothing,
    participation_rate::Union{Float64,Nothing}=nothing,
    spread_rate::Union{Float64,Nothing}=nothing,
    trigger_rate::Union{Float64,Nothing}=nothing,
    trigger_threshold::Float64=0.0,
    index_used::String="S&P 500",
    term_years::Int=1,
    floor_rate::Float64=0.0,
    crediting_method::Symbol=:cap,
)
    FIAProduct(
        company,
        product_name,
        cap_rate,
        participation_rate,
        spread_rate,
        trigger_rate,
        trigger_threshold,
        index_used,
        term_years,
        floor_rate,
        crediting_method,
    )
end

# =============================================================================
# RILA (Registered Index-Linked Annuity)
# =============================================================================

"""
    RILAProduct

Registered index-linked annuity with buffer or floor protection.

# Fields
- `company::String`: Insurance company name
- `product_name::String`: Product name/identifier
- `buffer_rate::Union{Float64,Nothing}`: Buffer protection level (decimal, e.g., 0.10 for 10%)
- `floor_rate::Union{Float64,Nothing}`: Floor protection level (decimal, e.g., -0.10 for -10%)
- `cap_rate::Union{Float64,Nothing}`: Maximum return cap (decimal)
- `protection_type::Symbol`: :buffer or :floor
- `index_used::String`: Index name
- `term_years::Int`: Term in years
- `step_rate_tier1::Union{Float64,Nothing}`: First tier buffer for step-rate
- `step_rate_tier2::Union{Float64,Nothing}`: Second tier buffer for step-rate
"""
struct RILAProduct
    company::String
    product_name::String
    buffer_rate::Union{Float64,Nothing}
    floor_rate::Union{Float64,Nothing}
    cap_rate::Union{Float64,Nothing}
    protection_type::Symbol
    index_used::String
    term_years::Int
    step_rate_tier1::Union{Float64,Nothing}
    step_rate_tier2::Union{Float64,Nothing}
end

# Constructor with defaults
function RILAProduct(;
    company::String,
    product_name::String,
    buffer_rate::Union{Float64,Nothing}=nothing,
    floor_rate::Union{Float64,Nothing}=nothing,
    cap_rate::Union{Float64,Nothing}=nothing,
    protection_type::Symbol=:buffer,
    index_used::String="S&P 500",
    term_years::Int=6,
    step_rate_tier1::Union{Float64,Nothing}=nothing,
    step_rate_tier2::Union{Float64,Nothing}=nothing,
)
    RILAProduct(
        company,
        product_name,
        buffer_rate,
        floor_rate,
        cap_rate,
        protection_type,
        index_used,
        term_years,
        step_rate_tier1,
        step_rate_tier2,
    )
end

# =============================================================================
# GLWB (Guaranteed Lifetime Withdrawal Benefit)
# =============================================================================

"""
    GLWBProduct

GLWB rider parameters for variable/indexed annuities.

# Fields
- `company::String`: Insurance company name
- `product_name::String`: Product name/identifier
- `withdrawal_rate::Float64`: Annual withdrawal rate (decimal, e.g., 0.05 for 5%)
- `rollup_rate::Float64`: Annual GWB rollup rate during deferral (decimal)
- `rollup_years::Int`: Maximum years rollup applies
- `step_up_frequency::Symbol`: :annual, :quarterly, or :none
- `rider_fee::Float64`: Annual rider fee (decimal, e.g., 0.01 for 1%)
- `fee_basis::Symbol`: :account_value or :gwb
"""
struct GLWBProduct
    company::String
    product_name::String
    withdrawal_rate::Float64
    rollup_rate::Float64
    rollup_years::Int
    step_up_frequency::Symbol
    rider_fee::Float64
    fee_basis::Symbol
end

# Constructor with defaults
function GLWBProduct(;
    company::String,
    product_name::String,
    withdrawal_rate::Float64=0.05,
    rollup_rate::Float64=0.05,
    rollup_years::Int=10,
    step_up_frequency::Symbol=:annual,
    rider_fee::Float64=0.01,
    fee_basis::Symbol=:gwb,
)
    GLWBProduct(
        company,
        product_name,
        withdrawal_rate,
        rollup_rate,
        rollup_years,
        step_up_frequency,
        rider_fee,
        fee_basis,
    )
end
