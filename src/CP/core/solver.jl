"""
    solve!()


"""
function solve!(model::CPModel, strategy::Type{T}=DFSearch; variableHeuristic=MinDomainVariableSelection, valueSelection=BasicHeuristic(), out_solver::Bool=false) where T <: SearchStrategy
    return search!(model, strategy, variableHeuristic, valueSelection, out_solver)
end
