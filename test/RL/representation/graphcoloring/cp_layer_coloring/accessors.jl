@testset "arrayOfEveryValue()" begin
    trailer = SeaPearl.Trailer()

    x = SeaPearl.IntVar(2, 3, "x", trailer)
    y = SeaPearl.IntVar(3, 4, "y", trailer)

    @test SeaPearl.arrayOfEveryValue(SeaPearl.AbstractIntVar[x, y]) == [4, 2, 3]
end

@testset "cpVertexFromIndex()" begin
    trailer = SeaPearl.Trailer()
    model = SeaPearl.CPModel(trailer)

    x = SeaPearl.IntVar(2, 3, "x", trailer)
    y = SeaPearl.IntVar(2, 3, "y", trailer)
    SeaPearl.addVariable!(model, x)
    SeaPearl.addVariable!(model, y)
    SeaPearl.addConstraint!(model, SeaPearl.Equal(x, y, trailer))
    SeaPearl.addConstraint!(model, SeaPearl.NotEqual(x, y, trailer))

    g = SeaPearl.CPLayerGraph2(model)

    true_idToNode = [
        SeaPearl.VariableVertex(x),
        SeaPearl.VariableVertex(y),
        SeaPearl.ValueVertex(2),
        SeaPearl.ValueVertex(3)
    ]

    for i in 1:4
        @test SeaPearl.cpVertexFromIndex(g, i) == true_idToNode[i]
    end
end

@testset "indexFromCpVertex()" begin
    trailer = SeaPearl.Trailer()
    model = SeaPearl.CPModel(trailer)

    x = SeaPearl.IntVar(2, 3, "x", trailer)
    y = SeaPearl.IntVar(2, 3, "y", trailer)
    SeaPearl.addVariable!(model, x)
    SeaPearl.addVariable!(model, y)
    SeaPearl.addConstraint!(model, SeaPearl.Equal(x, y, trailer))
    SeaPearl.addConstraint!(model, SeaPearl.NotEqual(x, y, trailer))

    g = SeaPearl.CPLayerGraph2(model)

    true_idToNode = [
        SeaPearl.VariableVertex(x),
        SeaPearl.VariableVertex(y),
        SeaPearl.ValueVertex(2),
        SeaPearl.ValueVertex(3)
    ]

    for i in 1:4
        @test SeaPearl.indexFromCpVertex(g, true_idToNode[i]) == i
    end
end

@testset "caracteristics" begin
    trailer = SeaPearl.Trailer()
    model = SeaPearl.CPModel(trailer)

    g = SeaPearl.CPLayerGraph2(model)

    @test eltype(g) == Int64
    @test LightGraphs.edgetype(g) == LightGraphs.SimpleEdge{Int64}
    @test !LightGraphs.is_directed(SeaPearl.CPLayerGraph2)
end

@testset "has_vertex()" begin
    trailer = SeaPearl.Trailer()
    model = SeaPearl.CPModel(trailer)

    x = SeaPearl.IntVar(2, 3, "x", trailer)
    y = SeaPearl.IntVar(2, 3, "y", trailer)
    SeaPearl.addVariable!(model, x)
    SeaPearl.addVariable!(model, y)
    SeaPearl.addConstraint!(model, SeaPearl.Equal(x, y, trailer))
    SeaPearl.addConstraint!(model, SeaPearl.NotEqual(x, y, trailer))

    g = SeaPearl.CPLayerGraph2(model)

    for i in 1:4
        @test LightGraphs.has_vertex(g, i)
    end
    @test !LightGraphs.has_vertex(g, 0)
    @test !LightGraphs.has_vertex(g, 7)
end

@testset "has_edge()" begin
    trailer = SeaPearl.Trailer()
    model = SeaPearl.CPModel(trailer)

    x = SeaPearl.IntVar(2, 3, "x", trailer)
    y = SeaPearl.IntVar(2, 3, "y", trailer)
    SeaPearl.addVariable!(model, x)
    SeaPearl.addVariable!(model, y)
    SeaPearl.addConstraint!(model, SeaPearl.Equal(x, y, trailer))
    SeaPearl.addConstraint!(model, SeaPearl.NotEqual(x, y, trailer))

    g = SeaPearl.CPLayerGraph2(model)

    SeaPearl.assign!(x, 2)

    @test has_edge(g, 1, 2)
    @test has_edge(g, 2, 1)
    @test !has_edge(g, 3, 4)

    @test has_edge(g, 1, 3)
    @test !has_edge(g, 1, 4)
end

@testset "edges() & ne() & nv()" begin
    trailer = SeaPearl.Trailer()
    model = SeaPearl.CPModel(trailer)

    x = SeaPearl.IntVar(2, 3, "x", trailer)
    y = SeaPearl.IntVar(2, 3, "y", trailer)
    SeaPearl.addVariable!(model, x)
    SeaPearl.addVariable!(model, y)
    SeaPearl.addConstraint!(model, SeaPearl.Equal(x, y, trailer))
    SeaPearl.addConstraint!(model, SeaPearl.NotEqual(x, y, trailer))

    g = SeaPearl.CPLayerGraph2(model)

    SeaPearl.assign!(x, 2)

    @test sort(LightGraphs.edges(g); by=(e -> (e.src, e.dst))) == sort([
        LightGraphs.SimpleEdge{Int64}(1, 3),
        LightGraphs.SimpleEdge{Int64}(2, 3),
        LightGraphs.SimpleEdge{Int64}(2, 4),
        LightGraphs.SimpleEdge{Int64}(1, 2),
    ]; by=(e -> (e.src, e.dst)))

    @test LightGraphs.ne(g) == 4
end

@testset "inneighbors()/outneightbors()" begin
    trailer = SeaPearl.Trailer()
    model = SeaPearl.CPModel(trailer)

    x = SeaPearl.IntVar(2, 3, "x", trailer)
    y = SeaPearl.IntVar(2, 3, "y", trailer)
    SeaPearl.addVariable!(model, x)
    SeaPearl.addVariable!(model, y)
    SeaPearl.addConstraint!(model, SeaPearl.Equal(x, y, trailer))
    SeaPearl.addConstraint!(model, SeaPearl.NotEqual(x, y, trailer))

    g = SeaPearl.CPLayerGraph2(model)

    SeaPearl.assign!(x, 2)

    @test LightGraphs.inneighbors(g, 1) == [2, 3]
    @test LightGraphs.inneighbors(g, 2) == [1,3,4]
    @test LightGraphs.inneighbors(g, 3) == [1, 2]
    @test LightGraphs.inneighbors(g, 4) == [2]

    @test LightGraphs.inneighbors(g, 1) == [2, 3]
    @test LightGraphs.inneighbors(g, 2) == [1,3,4]
    @test LightGraphs.inneighbors(g, 3) == [1, 2]
    @test LightGraphs.inneighbors(g, 4) == [2]
end

@testset "CPLayerGraph2 => Simplegraph features" begin
    trailer = SeaPearl.Trailer()
    model = SeaPearl.CPModel(trailer)

    x = SeaPearl.IntVar(2, 3, "x", trailer)
    y = SeaPearl.IntVar(2, 3, "y", trailer)
    SeaPearl.addVariable!(model, x)
    SeaPearl.addVariable!(model, y)
    SeaPearl.addConstraint!(model, SeaPearl.Equal(x, y, trailer))
    SeaPearl.addConstraint!(model, SeaPearl.NotEqual(x, y, trailer))

    g = SeaPearl.CPLayerGraph2(model)
    sg = SimpleGraph(g)

    @test nv(sg) == 4
    @test ne(sg) == 5

    z = SeaPearl.IntVar(2, 3, "Z", trailer)
    SeaPearl.addVariable!(model, z)   #add an isolated variable

    g = SeaPearl.CPLayerGraph2(model)
    sg = SimpleGraph(g)

    @test nv(sg) == 5
    @test ne(sg) == 7

    @test adjacency_matrix(g)==adjacency_matrix(sg)
end
