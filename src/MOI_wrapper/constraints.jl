
"""
    MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.EqualTo)

Interface function which add a constraint to the model (which is himself an Optimizer).
This constraints a single variable to be equal to a given Integer.  
"""
function MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.EqualTo)
    # get the VariableIndex and convert it to string
    id = string(sgvar.variable.value)
    constant = set.value

    # create the constraint
    constraint = EqualConstant(model.cpmodel.variables[id], constant, model.cpmodel.trailer)

    # add constraint to the model
    push!(model.cpmodel.constraints, constraint)

    # return the constraint Index (asked by MathOptInterface)
    constraint_index = length(model.cpmodel.constraints) + 1
    return MOI.ConstraintIndex{MOI.SingleVariable, MOI.EqualTo}(constraint_index)
end

sense_to_set(::Function, ::Val{:!=}) = NotEqualTo(0)
MOIU.shift_constant(set::NotEqualTo, value) = NotEqualTo(set.value + value)

"""
    MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::NotEqualTo)

Interface function which add a constraint to the model (which is himself an Optimizer)
This constraints a single variable to be equal to a given interval.
"""
function MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::NotEqualTo)
    # get the VariableIndex and convert it to string
    id = string(sgvar.variable.value)
    constant = set.value

    # create the constraint: need to create the native one first (WIP)
    constraint = NotEqualConstant(model.cpmodel.variables[id], constant, model.cpmodel.trailer)

    # add constraint to the model
    push!(model.cpmodel.constraints, constraint)

    # return the constraint Index (asked by MathOptInterface)
    constraint_index = length(model.cpmodel.constraints) + 1
    return MOI.ConstraintIndex{MOI.SingleVariable, MOI.NotEqualTo}(constraint_index)
end

"""
    MOI.add_constraint(model::Optimizer, sgvar::MOI.VectorOfVariables, set::VariablesEquality)

Interface function which add a constraint to the model (which is himself an Optimizer)
This constraints a single variable to be different or equal to another variable.
"""
function MOI.add_constraint(model::Optimizer, vectOfVar::MOI.VectorOfVariables, set::VariablesEquality)
    # get the VariableIndex and convert it to string
    #@assert MOI.output_dimension(vectOfVar) == 2

    id1, id2 = string(vectOfVar.variables[1].value), string(vectOfVar.variables[2].value)
    equal = set.value

    # create the constraint
    if equal
        constraint = Equal(model.cpmodel.variables[id1], model.cpmodel.variables[id2], model.cpmodel.trailer)
    else
        constraint = NotEqual(model.cpmodel.variables[id1], model.cpmodel.variables[id2], model.cpmodel.trailer)
    end
    
    # add constraint to the model
    push!(model.cpmodel.constraints, constraint)

    # return the constraint Index (asked by MathOptInterface)
    constraint_index = length(model.cpmodel.constraints) + 1
    return MOI.ConstraintIndex{MOI.VectorOfVariables, VariablesEquality}(constraint_index)
end

"""
    MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.LessThan)

Interface function which add a constraint to the model (which is himself an Optimizer).
This constraints a single variable to be less than a given Integer.  
"""
function MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.LessThan)
    # get the VariableIndex and convert it to string
    id = string(sgvar.variable.value)
    constant = set.upper

    # create the constraint
    constraint = LessOrEqualConstant(model.cpmodel.variables[id], constant, model.cpmodel.trailer)

    # add constraint to the model
    push!(model.cpmodel.constraints, constraint)

    # return the constraint Index (asked by MathOptInterface)
    constraint_index = length(model.cpmodel.constraints) + 1
    return MOI.ConstraintIndex{MOI.SingleVariable, MOI.LessThan}(constraint_index)
end

"""
    MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.GreaterThan)

Interface function which add a constraint to the model (which is himself an Optimizer).
This constraints a single variable to be greater than a given Integer.  
"""
function MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.GreaterThan)
    # get the VariableIndex and convert it to string
    id = string(sgvar.variable.value)
    constant = set.lower

    # create the constraint
    constraint = GreaterOrEqualConstant(model.cpmodel.variables[id], constant, model.cpmodel.trailer)

    # add constraint to the model
    push!(model.cpmodel.constraints, constraint)

    # return the constraint Index (asked by MathOptInterface)
    constraint_index = length(model.cpmodel.constraints) + 1
    return MOI.ConstraintIndex{MOI.SingleVariable, MOI.GreaterThan}(constraint_index)
end

"""
    MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.Interval)

Interface function which add a constraint to the model (which is himself an Optimizer).
This constraints a single variable to be in an Interval.  
"""
function MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.Interval)
    # get the VariableIndex and convert it to string
    id = string(sgvar.variable.value)
    lower = set.lower
    upper = set.upper

    # create the constraint
    constraint = IntervalConstant(model.cpmodel.variables[id], lower, upper, model.cpmodel.trailer)

    # add constraint to the model
    push!(model.cpmodel.constraints, constraint)

    # return the constraint Index (asked by MathOptInterface)
    constraint_index = length(model.cpmodel.constraints) + 1
    return MOI.ConstraintIndex{MOI.SingleVariable, MOI.Interval}(constraint_index)
end

"""
    MOI.add_constraint(model::Optimizer, sgvar::MOI.ScalarAffineFunction, set::MOI.LessThan)

Interface function which add a constraint to the model (which is himself an Optimizer).
This constraints a scalar affine function to be less than a given Integer.  
"""
function MOI.add_constraint(model::Optimizer, saf::MOI.ScalarAffineFunction, set::MOI.LessThan)
    # get the VariableIndexs, convert them to strings and create 
    var_array = IntVarViewMul[]
    for term in saf.terms
        id = term.variable_index.value
        new_id = string(length(keys(model.cpmodel.variables)) + 1)
        push!(var_array, IntVarViewMul(model.cpmodel.variables[id], term.coefficient, new_id))
    end

    # create the constraint
    constraint = SumLessThan(var_array, set.upper - saf.constant, model.cpmodel.trailer)

    # add constraint to the model
    push!(model.cpmodel.constraints, constraint)

    # return the constraint Index (asked by MathOptInterface)
    constraint_index = length(model.cpmodel.constraints) + 1
    return MOI.ConstraintIndex{MOI.ScalarAffineFunction, MOI.LessThan}(constraint_index)
end

"""
    MOI.add_constraint(model::Optimizer, sgvar::MOI.ScalarAffineFunction, set::MOI.GreaterThan)

Interface function which add a constraint to the model (which is himself an Optimizer).
This constraints a scalar affine function to be greater than a given Integer.  
"""
function MOI.add_constraint(model::Optimizer, saf::MOI.ScalarAffineFunction, set::MOI.GreaterThan)
    # get the VariableIndexs, convert them to strings and create 
    var_array = IntVarViewMul[]
    for term in saf.terms
        id = term.variable_index.value
        new_id = string(length(keys(model.cpmodel.variables)) + 1)
        push!(var_array, IntVarViewMul(model.cpmodel.variables[id], term.coefficient, new_id))
    end

    # create the constraint
    constraint = SumGreaterThan(var_array, set.lower - saf.constant, model.cpmodel.trailer)

    # add constraint to the model
    push!(model.cpmodel.constraints, constraint)

    # return the constraint Index (asked by MathOptInterface)
    constraint_index = length(model.cpmodel.constraints) + 1
    return MOI.ConstraintIndex{MOI.ScalarAffineFunction, MOI.GreaterThan}(constraint_index)
end


add_constraint() = @info "Constraint added !"
