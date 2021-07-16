@testset "CPLayerGraph2()" begin
    trailer = SeaPearl.Trailer()
    model = SeaPearl.CPModel(trailer)

    x = SeaPearl.IntVar(2, 3, "x", trailer)
    y = SeaPearl.IntVar(2, 3, "y", trailer)
    z = SeaPearl.IntVarViewOpposite(y, "-y")
    SeaPearl.addVariable!(model, x)
    SeaPearl.addVariable!(model, y)
    SeaPearl.addConstraint!(model, SeaPearl.Equal(x, y, trailer))
    SeaPearl.addConstraint!(model, SeaPearl.NotEqual(x, y, trailer))
    SeaPearl.addConstraint!(model, SeaPearl.NotEqual(z, y, trailer))

    g = SeaPearl.CPLayerGraph2(model)

    true_idToNode = [
        SeaPearl.VariableVertex(z),
        SeaPearl.VariableVertex(x),
        SeaPearl.VariableVertex(y),
        SeaPearl.ValueVertex(2),
        SeaPearl.ValueVertex(3)
    ]

    @test g.cpmodel == model
    @test g.idToNode == true_idToNode
    @test length(keys(g.nodeToId)) == 5

    for i in 1:5
        @test g.nodeToId[true_idToNode[i]] == i
    end

    @test Matrix(LightGraphs.LinAlg.adjacency_matrix(g.fixedEdgesGraph)) == [
        0 0 1
        0 0 1
        1 1 0
    ]

    @test g.numberOfConstraints == 3
    @test g.numberOfVariables == 3
    @test g.numberOfValues == 2
    @test g.totalLength == 5

    empty_g = SeaPearl.CPLayerGraph2()
    @test isnothing(empty_g.cpmodel)
end
