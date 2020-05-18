
"""
MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.EqualTo)

Interface function which add a constraint to the model (which is himself an Optimizer).
This constraints a single variable to be equal to a given Integer.  
"""
function MOI.add_constraint(model::Optimizer, sgvar::MOI.SingleVariable, set::MOI.EqualTo)
# get the VariableIndex and convert it to string
id = string(sgvar.variable)
constant = set.value

# create the constraint
constraint = EqualConstant(model.cpmodel.variables[id], constant, model.cpmodel.trailer)

# add constraint to the model
push!(model.cpmodel.constraints, constraint)

# return the constraint Index (asked by MathOptInterface)
constraint_index = length(model.cpmodel.constraints) + 1
return MOI.ConstraintIndex{MOI.SingleVariable, MOI.EqualTo}(constraint_index)
end

struct NotEqualTo <: MOI.AbstractScalarSet
value::Int
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
id = string(sgvar.variable)
constant = set.value

# create the constraint: need to create the native one first (WIP)
constraint = NotEqualConstant(model.cpmodel.variables[id], constant, model.cpmodel.trailer)

# add constraint to the model
push!(model.cpmodel.constraints, constraint)

# return the constraint Index (asked by MathOptInterface)
constraint_index = length(model.cpmodel.constraints) + 1
return MOI.ConstraintIndex{MOI.SingleVariable, MOI.NotEqualTo}(constraint_index)
end

# if true, variables are equal, else they are different
struct VariablesEquality <: MOI.AbstractScalarSet
value::Bool
end

"""
MOI.add_constraint(model::Optimizer, sgvar::MOI.VectorOfVariables, set::VariablesEquality)

Interface function which add a constraint to the model (which is himself an Optimizer)
This constraints a single variable to be different or equal to another variable.
"""
function MOI.add_constraint(model::Optimizer, vectOfVar::MOI.VectorOfVariables, set::VariablesEquality)
# get the VariableIndex and convert it to string
@assert MOI.output_dimension(vectOfVar) == 2

id1, id2 = string(vectOfVar.variables[1]), string(vectOfVar.variables[2])
equal = set.value

# create the constraint
if equal
    constraint = Equal(model.cpmodel.variables[id1], model.cpmodel.variables[id1], model.cpmodel.trailer)
else
    constraint = NotEqual(model.cpmodel.variables[id1], model.cpmodel.variables[id1], model.cpmodel.trailer)

# add constraint to the model
push!(model.cpmodel.constraints, constraint)

# return the constraint Index (asked by MathOptInterface)
constraint_index = length(model.cpmodel.constraints) + 1
return MOI.ConstraintIndex{MOI.SingleVariable, MOI.NotEqualTo}(constraint_index)
end


add_constraint() = @info "Constraint added !"