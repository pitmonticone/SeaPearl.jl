#function used for graph coloring in SeaPearl Zoo
function labelOfVertex(g::CPLayerGraph2, d::Int64)
    cpVertex = cpVertexFromIndex(g, d)
    labelOfVertex(g, cpVertex)
end

labelOfVertex(g::CPLayerGraph2, d::VariableVertex) = "x"*d.variable.id, 1
labelOfVertex(g::CPLayerGraph2, d::ValueVertex) = string(d.value), 2
