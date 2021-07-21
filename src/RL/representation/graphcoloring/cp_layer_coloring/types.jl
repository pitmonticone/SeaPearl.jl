"""
    struct CPLayerGraph2 <: AbstractGraph{Int}

Graph representing the current status of the CPModel.
It is a tripartite graph, linking 2 types of nodes: variables and values.
A variable is connected to a value if the value is in the variable's domain, and the variables are connected together if they share a constraint.

Domains get pruned during the solving. To always keep an up-to-date representation,
none of the value-variables edges are stored, and everytime they're needed, they are gotten from
the `CPModel` directly, hence the "layer" in the name of the struct.

Each vertex is indexed by an integer, in a specific order. You first have the variables and then the values.
"""
struct CPLayerGraph2 <: LightGraphs.AbstractGraph{Int}
    cpmodel                     ::Union{CPModel, Nothing}
    idToNode                    ::Array{CPLayerVertex}
    nodeToId                    ::Dict{CPLayerVertex, Int}
    fixedEdgesGraph             ::LightGraphs.Graph
    numberOfConstraints         ::Int
    numberOfVariables           ::Int
    numberOfValues              ::Int
    totalLength                 ::Int

    """
        function CPLayerGraph2(cpmodel::CPModel)

    Create the graph corresponding to the CPModel.
    The graph gets linked to `cpmodel` and does not need to get updated by anyone when domains are pruned.
    """
    function CPLayerGraph2(cpmodel::CPModel)
        variables = Set{AbstractVar}(values(cpmodel.variables))
        valuesOfVariables = branchable_values(cpmodel)
        numberOfConstraints = length(cpmodel.constraints)
        numberOfValues = length(valuesOfVariables)

        variableConnections = Tuple{AbstractVar, AbstractVar}[]

        # Take into account IntVarViews that are only declared in constraints
        for constraint in cpmodel.constraints
            for constraintVar in variablesArray(constraint)
                while typeof(constraintVar) <: Union{IntVarView, BoolVarView}
                    push!(variables, constraintVar)

                    # Storing variable connections
                    push!(variableConnections, (constraintVar, constraintVar.x))

                    constraintVar = constraintVar.x
                end
            end
        end


        variables = collect((variables))

        # We sort the variables by their id to get a consistent order
        sort!(variables; by=(x) -> x.id)

        numberOfVariables = length(variables)


        totalLength = numberOfVariables + numberOfValues
        nodeToId = Dict{CPLayerVertex, Int}()
        idToNode = Array{CPLayerVertex}(undef, totalLength)

        # Filling constraints
        #for i in 1:numberOfConstraints
        #    idToNode[i] = ConstraintVertex(cpmodel.constraints[i])
        #    nodeToId[ConstraintVertex(cpmodel.constraints[i])] = i
        #end

        # Filling variables
        for i in 1:numberOfVariables
            idToNode[i] = VariableVertex(variables[i])
            nodeToId[VariableVertex(variables[i])] = i
        end

        # Filling values
        for i in 1:numberOfValues
            idToNode[numberOfVariables + i] = ValueVertex(valuesOfVariables[i])
            nodeToId[ValueVertex(valuesOfVariables[i])] = numberOfVariables + i
        end


        #fixedEdgesGraph = Graph(numberOfConstraints + numberOfVariables)
        fixedEdgesGraph = Graph(numberOfVariables)
        for constraint in cpmodel.constraints
            varArray = variablesArray(constraint)
            for x in varArray
                 for y in varArray
                     if nodeToId[VariableVertex(x)] < nodeToId[VariableVertex(y)]
                         add_edge!(fixedEdgesGraph, nodeToId[VariableVertex(y)], nodeToId[VariableVertex(x)])
                     end
                 end
            end
        end

        for (x1, x2) in variableConnections
            v1, v2 = VariableVertex(x1), VariableVertex(x2)
            add_edge!(fixedEdgesGraph, nodeToId[v1], nodeToId[v2])
        end

        return new(cpmodel, idToNode, nodeToId, fixedEdgesGraph, numberOfConstraints, numberOfVariables, numberOfValues, totalLength)
    end

    """
        function CPLayerGraph2()

    Create an empty graph, needed to implement the `zero` function for the LightGraphs.jl interface.
    """
    function CPLayerGraph2()
        return new(nothing, CPLayerVertex[], Dict{CPLayerVertex, Int}(), Graph(0), 0, 0, 0, 0)
    end
end
