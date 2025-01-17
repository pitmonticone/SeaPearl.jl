@testset "geometricflux.jl" begin
    
    @testset "GraphConv" begin
        gnn = GeometricFlux.GraphConv(3 => 3)

        graphs = Matrix.(adjacency_matrix.([random_regular_graph(10, 4) for i = 1:4]))
        nodeFeatures = [rand(Float32, 3, 10) for i = 1:4]
        featuredGraphs = [FeaturedGraph(g; nf=nf) for (g, nf) in zip(graphs, nodeFeatures)]
        batchedFG = SeaPearl.BatchedFeaturedGraph{Float32}(
            cat(graphs...; dims=3);
            nf=cat(nodeFeatures...;dims=3)
        )

        classicOutput = cat(GeometricFlux.FeatureSelector(:node).(gnn.(featuredGraphs))...;dims=3)
        batchedOutput = gnn(batchedFG).nf

        @test all(abs.(classicOutput .- batchedOutput) .< 1e-5)

        grad = gradient(batchedFG) do inp
            gnn(inp).nf[1, 3, 2]
        end
        grad = grad[1]

        @test all(grad.nf[:, :, [1, 3, 4]] .== 0)
        @test !all(grad.nf[:, :, 2] .== 0)
        @test all(grad.graph[:, :, [1, 3, 4]] .== 0)
        @test !all(grad.graph[:, :, 2] .== 0)
    end

    # TODO find why it won't work on CPU
    """
    @testset "GraphNorm" begin
        gnn = SeaPearl.GraphNorm(3)

        graphs = Matrix.(adjacency_matrix.([random_regular_graph(10, 4) for i = 1:4]))
        nodeFeatures = [rand(Float32, 3, 10) for i = 1:4]
        batchedFG = SeaPearl.BatchedFeaturedGraph{Float32}(
            cat(graphs...; dims=3);
            nf=cat(nodeFeatures...;dims=3)
        )
        batchedOutput = gnn(batchedFG).nf

        @test size(batchedOutput) = (3, 10, 3)

        grad = gradient(batchedFG) do inp
            gnn(inp).nf[1, 1, 1]
        end
        grad = grad[1]

        @test all(grad.nf[:, :, 2:4] .== 0)
        @test all(grad.nf[:, 2:10, 1] .== 0)
        @test !all(grad.nf[:, 1, 1] .== 0)
        @test all(grad.graph .== 0)
    end
    """
end