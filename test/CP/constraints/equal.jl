
@testset "equal.jl" begin
    @testset "EqualConstant()" begin
        trailer = SeaPearl.Trailer()
        x = SeaPearl.IntVar(2, 6, "x", trailer)

        constraint = SeaPearl.EqualConstant(x, 3, trailer)

        @test constraint in x.onDomainChange
        @test constraint.active.value
    end
    @testset "propagate!(::EqualConstant)" begin
        trailer = SeaPearl.Trailer()
        x = SeaPearl.IntVar(2, 6, "x", trailer)
        ax = SeaPearl.IntVarViewMul(x, 3, "3x")

        constraint = SeaPearl.EqualConstant(ax, 6, trailer)

        toPropagate = Set{SeaPearl.Constraint}()
        prunedDomains = SeaPearl.CPModification()

        @test SeaPearl.propagate!(constraint, toPropagate, prunedDomains)

        @test length(ax.domain) == 1
        @test 6 in ax.domain
        @test !(9 in ax.domain)
        @test !(10 in ax.domain)
        @test prunedDomains == SeaPearl.CPModification(
            "3x" => [9, 12, 15, 18],
            "x"  => [3, 4, 5, 6]
        )


        cons2 = SeaPearl.EqualConstant(ax, 9, trailer)

        @test !SeaPearl.propagate!(cons2, toPropagate, prunedDomains)

        @test isempty(ax.domain)

        y = SeaPearl.IntVar(2, 6, "y", trailer)
        constraint1 = SeaPearl.EqualConstant(y, 3, trailer)
        constraint2 = SeaPearl.EqualConstant(y, 4, trailer)

        toPropagate2 = Set{SeaPearl.Constraint}()
        SeaPearl.propagate!(constraint1, toPropagate2, prunedDomains)
        
        @test constraint2 in toPropagate2

    end

    @testset "pruneEqual!()" begin
        trailer = SeaPearl.Trailer()
        x = SeaPearl.IntVar(2, 6, "x", trailer)
        y = SeaPearl.IntVar(5, 8, "y", trailer)

        SeaPearl.pruneEqual!(y, x)

        @test length(y.domain) == 2
        @test !(8 in y.domain) && 5 in y.domain && 6 in y.domain


    end

    @testset "propagate!(::Equal)" begin
        trailer = SeaPearl.Trailer()
        x = SeaPearl.IntVar(2, 6, "x", trailer)
        y = SeaPearl.IntVar(5, 8, "y", trailer)

        constraint = SeaPearl.Equal(x, y, trailer)
        toPropagate = Set{SeaPearl.Constraint}()
        prunedDomains = SeaPearl.CPModification()

        @test SeaPearl.propagate!(constraint, toPropagate, prunedDomains)


        @test length(x.domain) == 2
        @test length(y.domain) == 2
        @test !(2 in x.domain) && 5 in x.domain && 6 in x.domain
        @test !(8 in y.domain) && 5 in y.domain && 6 in y.domain
        @test prunedDomains == SeaPearl.CPModification("x" => [2, 3, 4],"y" => [7, 8])

        # Propagation test
        z = SeaPearl.IntVar(5, 15, "z", trailer)
        constraint2 = SeaPearl.Equal(y, z, trailer)
        SeaPearl.propagate!(constraint2, toPropagate, prunedDomains)

        # Domain not reduced => not propagation
        @test !(constraint in toPropagate)
        @test !(constraint2 in toPropagate)

        # Domain reduced => propagation
        SeaPearl.remove!(z.domain, 5)
        SeaPearl.propagate!(constraint2, toPropagate, prunedDomains)
        @test constraint in toPropagate
        @test !(constraint2 in toPropagate)

        #Unfeasible test
        t = SeaPearl.IntVar(15, 30, "t", trailer)
        constraint3 = SeaPearl.Equal(z, t, trailer)
        @test !SeaPearl.propagate!(constraint3, toPropagate, prunedDomains)
    end
end
