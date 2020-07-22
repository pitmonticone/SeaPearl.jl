MOI.get(::Optimizer, ::MOI.SolverName) = "CPRL Solver"
MOI.get(model::Optimizer, ::MOI.TerminationStatus) = model.terminationStatus
MOI.get(model::Optimizer, ::MOI.PrimalStatus) = model.primalStatus

function MOI.get(optimizer::CPRL.Optimizer, ::MathOptInterface.VariablePrimal, vi::MathOptInterface.VariableIndex)
    id = vi.value
    last(optimizer.cpmodel.solutions)[string(id)]
end

"""
    MOI.is_empty(model::Optimizer)

Return a boolean saying if the model is empty or not. 
"""
function MOI.is_empty(model::Optimizer)
    return isempty(model.cpmodel.variables) && isempty(model.cpmodel.constraints)
end

"""
    MOI.empty!(model::Optimizer)

Empty a given Optimizer. 
"""
function MOI.empty!(model::Optimizer)
    # empty the cpmodel
    Base.empty!(model.cpmodel)
    model.variableselection = MinDomainVariableSelection()
    model.terminationStatus = MOI.OPTIMIZE_NOT_CALLED
    Base.empty!(model.moimodel.variables)
    Base.empty!(model.moimodel.constraints)
    Base.empty!(model.moimodel.affines)
    model.moimodel.objective_identifier = nothing

    # do not empty the options atm
end

MOI.supports(::Optimizer, ::MOI.RawParameter) = true
MOI.supports(::Optimizer, ::CPRL.MOIVariableSelectionAttribute) = true
MOI.supports(::Optimizer, ::CPRL.MOIValueSelectionAttribute) = true
MOI.supports(::Optimizer, ::MOI.VariablePrimal) = true

MOI.Utilities.map_indices(::Function, x::AbstractVariableSelection) = x
MOI.Utilities.map_indices(::Function, x::ValueSelection) = x

function MOI.set(model::Optimizer, p::MOI.RawParameter, value)
    model.options[p.name] = value
end

function MOI.set(model::Optimizer, ::CPRL.MOIVariableSelectionAttribute, heuristic::AbstractVariableSelection)
    model.variableselection = heuristic
end

function MOI.set(model::Optimizer, ::MOIValueSelectionAttribute, valueselection::ValueSelection)
    model.valueselection = valueselection
end


MOI.Utilities.supports_default_copy_to(model::Optimizer, copy_names::Bool) = !copy_names

function MOI.copy_to(dest::Optimizer, src::MOI.ModelLike; kwargs...)
    return MOI.Utilities.automatic_copy_to(dest, src; kwargs...)
end