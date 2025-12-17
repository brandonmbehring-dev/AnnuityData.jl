@testset "Product Schemas" begin

    @testset "MYGAProduct" begin
        # Test keyword constructor with defaults
        product = MYGAProduct(
            company = "Test Insurance",
            product_name = "Test MYGA 5yr",
            fixed_rate = 0.05,
            term_years = 5
        )

        @test product.company == "Test Insurance"
        @test product.product_name == "Test MYGA 5yr"
        @test product.fixed_rate == 0.05
        @test product.term_years == 5
        @test product.effective_yield == 0.05  # default
        @test product.am_best_rating == "A"    # default
        @test product.min_premium == 10000.0   # default
        @test product.surrender_years == 5     # default to term_years

        # Test with all fields specified
        product_full = MYGAProduct(
            company = "Premium Life",
            product_name = "Elite MYGA",
            fixed_rate = 0.055,
            term_years = 7,
            effective_yield = 0.052,
            am_best_rating = "A+",
            min_premium = 25000.0,
            surrender_years = 6
        )

        @test product_full.effective_yield == 0.052
        @test product_full.am_best_rating == "A+"
        @test product_full.surrender_years == 6
    end

    @testset "FIAProduct" begin
        # Cap method product
        cap_product = FIAProduct(
            company = "Test Life",
            product_name = "Cap FIA",
            cap_rate = 0.10,
            crediting_method = :cap
        )

        @test cap_product.cap_rate == 0.10
        @test cap_product.participation_rate === nothing
        @test cap_product.spread_rate === nothing
        @test cap_product.floor_rate == 0.0  # FIA floor always 0%
        @test cap_product.crediting_method == :cap

        # Participation method product
        part_product = FIAProduct(
            company = "Test Life",
            product_name = "Participation FIA",
            participation_rate = 0.80,
            cap_rate = 0.15,
            crediting_method = :participation
        )

        @test part_product.participation_rate == 0.80
        @test part_product.cap_rate == 0.15
        @test part_product.crediting_method == :participation

        # Spread method product
        spread_product = FIAProduct(
            company = "Test Life",
            product_name = "Spread FIA",
            spread_rate = 0.02,
            crediting_method = :spread
        )

        @test spread_product.spread_rate == 0.02
        @test spread_product.crediting_method == :spread

        # Trigger method product
        trigger_product = FIAProduct(
            company = "Test Life",
            product_name = "Trigger FIA",
            trigger_rate = 0.08,
            trigger_threshold = 0.0,
            crediting_method = :trigger
        )

        @test trigger_product.trigger_rate == 0.08
        @test trigger_product.trigger_threshold == 0.0
        @test trigger_product.crediting_method == :trigger
    end

    @testset "RILAProduct" begin
        # Buffer product
        buffer_product = RILAProduct(
            company = "Test Annuity",
            product_name = "Buffer RILA",
            buffer_rate = 0.10,
            cap_rate = 0.20,
            protection_type = :buffer
        )

        @test buffer_product.buffer_rate == 0.10
        @test buffer_product.cap_rate == 0.20
        @test buffer_product.protection_type == :buffer
        @test buffer_product.floor_rate === nothing

        # Floor product
        floor_product = RILAProduct(
            company = "Test Annuity",
            product_name = "Floor RILA",
            floor_rate = -0.10,
            cap_rate = 0.25,
            protection_type = :floor
        )

        @test floor_product.floor_rate == -0.10
        @test floor_product.cap_rate == 0.25
        @test floor_product.protection_type == :floor

        # 100% buffer edge case
        full_buffer = RILAProduct(
            company = "Test Annuity",
            product_name = "100% Buffer RILA",
            buffer_rate = 1.0,
            cap_rate = 0.15
        )

        @test full_buffer.buffer_rate == 1.0
    end

    @testset "GLWBProduct" begin
        glwb = GLWBProduct(
            company = "Test Life",
            product_name = "Income Plus GLWB",
            withdrawal_rate = 0.05,
            rollup_rate = 0.06,
            rollup_years = 10,
            rider_fee = 0.01
        )

        @test glwb.withdrawal_rate == 0.05
        @test glwb.rollup_rate == 0.06
        @test glwb.rollup_years == 10
        @test glwb.rider_fee == 0.01
        @test glwb.step_up_frequency == :annual  # default
        @test glwb.fee_basis == :gwb             # default
    end

end
