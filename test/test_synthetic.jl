@testset "SyntheticProvider" begin

    provider = SyntheticProvider()

    @testset "load_rates" begin
        rates = load_rates(provider)

        @test rates isa DataFrame
        @test nrow(rates) == 200  # 40 MYGA + 110 FIA + 50 RILA

        # Check product mix
        product_counts = combine(groupby(rates, :productGroup), nrow => :count)
        myga_count = filter(row -> row.productGroup == "MYGA", product_counts).count[1]
        fia_count = filter(row -> row.productGroup == "FIA", product_counts).count[1]
        rila_count = filter(row -> row.productGroup == "RILA", product_counts).count[1]

        @test myga_count == 40   # 20%
        @test fia_count == 110   # 55%
        @test rila_count == 50   # 25%

        # Check required columns exist
        required_cols = [:productGroup, :companyName, :productName, :termYears]
        for col in required_cols
            @test col in propertynames(rates)
        end
    end

    @testset "load_products MYGA" begin
        myga_products = load_products(provider, :myga)

        @test length(myga_products) == 40
        @test all(p -> p isa MYGAProduct, myga_products)

        # Check rate distributions (realistic MYGA rates 2.5-6.5%)
        rates = [p.fixed_rate for p in myga_products]
        @test minimum(rates) >= 0.02
        @test maximum(rates) <= 0.07

        # Check term distributions (should be 3-10 years)
        terms = [p.term_years for p in myga_products]
        @test minimum(terms) >= 3
        @test maximum(terms) <= 10
    end

    @testset "load_products FIA" begin
        fia_products = load_products(provider, :fia)

        @test length(fia_products) == 110
        @test all(p -> p isa FIAProduct, fia_products)

        # All FIA products should have 0% floor
        @test all(p -> p.floor_rate == 0.0, fia_products)

        # Check at least some have cap rates (5-15%)
        cap_products = filter(p -> p.cap_rate !== nothing, fia_products)
        @test length(cap_products) > 0
        cap_rates = [p.cap_rate for p in cap_products if p.cap_rate !== nothing]
        @test all(r -> 0.05 <= r <= 0.15, cap_rates)
    end

    @testset "load_products RILA" begin
        rila_products = load_products(provider, :rila)

        @test length(rila_products) == 50
        @test all(p -> p isa RILAProduct, rila_products)

        # Check buffer distributions (10%, 15%, 20%, 25%)
        buffer_rates = [p.buffer_rate for p in rila_products if p.buffer_rate !== nothing]
        @test length(buffer_rates) > 0

        # Buffer rates should be in typical range
        @test all(r -> 0.05 <= r <= 0.30, buffer_rates)

        # Note: 100% buffer edge case is in payoff_truth_tables.csv, not synthetic_rates.csv
    end

    @testset "load_payoff_truth_table" begin
        truth_table = load_payoff_truth_table(provider)

        @test truth_table isa DataFrame
        @test nrow(truth_table) == 135

        # Check required columns
        required_cols = [
            :test_id, :category, :method, :index_return,
            :expected_payoff, :edge_case
        ]
        for col in required_cols
            @test col in propertynames(truth_table)
        end

        # Check methods coverage
        methods = unique(truth_table.method)
        expected_methods = ["cap", "participation", "spread", "trigger",
                          "buffer", "floor", "buffer_floor", "step_rate",
                          "buffer_vs_floor"]
        for m in expected_methods
            @test m in methods
        end

        # Check 100% buffer case exists
        buffer_cases = filter(row -> row.method == "buffer", truth_table)
        @test any(row -> !ismissing(row.buffer_rate) && row.buffer_rate == 1.0, eachrow(buffer_cases))
    end

    @testset "Error handling" begin
        @test_throws ArgumentError load_products(provider, :invalid_type)
    end

end
