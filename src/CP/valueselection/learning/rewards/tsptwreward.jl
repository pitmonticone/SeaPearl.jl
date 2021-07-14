"""
    struct TsptwReward <: AbstractReward end

TsptwReward is one of the already implemented rewards of SeaPearl.jl. A user can use it directly.
This reward is adapted to the tsptw problem and is inspired from the one used by Quentin Cappart in
his recent paper: Combining RL & CP for Combinatorial Optimization, https://arxiv.org/pdf/2006.01610.pdf.
"""
mutable struct TsptwReward <: AbstractReward
    value::Float32
    positiver::Float32
    normalizer::Float32
    max_dist::Float32
end

"""
    TsptwReward(model::CPModel)

Initialize a TsptwReward instance from a CPModel. The value is set to 0.
The positiver and normalizer are inspired from Quentin's paper.

Suggestions for the positiver:
    Mathematically exact and tighter than n * max(dist) :
n_biggest = partialsort(vec(dist), 1:n, rev = true)
n_minus_one_smallest = partialsort(vec(dist), 1:n-1)
positiver = sum(n_biggest) - sum(n_minus_one_smallest)
"""
function TsptwReward(model::CPModel)
    dist = nothing
    for constraint in model.constraints
        if isnothing(dist) && isa(constraint, Element2D) && size(constraint.matrix, 2) > 1
            dist = constraint.matrix
        end
    end
    n = size(dist, 1)
    max_dist = Float32(Base.maximum(dist))
    positiver = Float32(1 + (2^0.5) * n * max_dist)
    normalizer = positiver ^ (-1)
    TsptwReward(0, positiver, normalizer, max_dist)
end

"""
set_reward!(::StepPhase, lh::LearnedHeuristic{SR, R::TsptwReward, A}, model::CPModel, symbol::Union{Nothing, Symbol})

Change the "current_reward" attribute of the LearnedHeuristic at the StepPhase.
"""
function set_reward!(::Type{StepPhase}, lh::LearnedHeuristic{SR, TsptwReward, A}, model::CPModel, symbol::Union{Nothing, Symbol}) where {
    SR <: AbstractStateRepresentation,
    A <: ActionOutput
}
end

"""
    set_reward!(::DecisionPhase, lh::LearnedHeuristic{TsptwReward, O}, model::CPModel)

Change the current reward at the DecisionPhase. This is called right before making the next decision, so you know you have the very last state before the new decision
and every computation like fixPoints and backtracking has been done.
"""

"""
function set_reward!(::Type{DecisionPhase}, lh::LearnedHeuristic{SR, TsptwReward, A}, model::CPModel) where {
    SR <: AbstractStateRepresentation,
    A <: ActionOutput
}
    current_turn = lh.search_metrics.total_decisions-1
    println(current_turn)
    for i in 1:length(keys(model.variables))
        if haskey(model.variables, "a_"*string(current_turn)) && isbound(model.variables["a_"*string(current_turn)]) #ne dépend pas de i
            println("ouf")
            a_i = assignedValue(model.variables["a_"*string(current_turn)])
            if lh.search_metrics.total_decisions == 0 ##==?
                v_i = 1
            else
                v_i = assignedValue(model.variables["v_"*string(current_turn - 1)])
            end
            last_dist = lh.current_state.dist[v_i, a_i] * lh.reward.max_dist
            lh.reward.value += lh.reward.normalizer * (lh.reward.positiver - last_dist)
            break
        else
            #println("not found")
        end
    end
    # lh.reward.value += lh.reward.normalizer * (lh.reward.positiver)
end
"""

function set_reward!(::Type{DecisionPhase}, lh::LearnedHeuristic{SR, TsptwReward, A}, model::CPModel) where {
    SR <: AbstractStateRepresentation,
    A <: ActionOutput
}
    println("on rentre dans la fonction set reward decision phase")
    n = size(lh.current_state.dist, 1)
    if isa(model.adhocInfo[end],Array)&&(!isempty(model.adhocInfo[end]))
        s = model.adhocInfo[end][end][1] #Si on ne met pas de -1 la variable n'est pas bound
        current = model.adhocInfo[end][end][2]
        println("on regarde le dernier choix de variable de branchement")
        println("elle est bien bound : "*string(isbound(model.variables[s])))
        if isbound(model.variables["a_"*string(current)])
            println("on compte le reward pour a"*string(current))
            a_i = assignedValue(model.variables["a_"*string(current)])
            v_i = assignedValue(model.variables["v_"*string(current)])
            last_dist = lh.current_state.dist[v_i, a_i] * lh.reward.max_dist
            println(last_dist)
            lh.reward.value += lh.reward.normalizer* (lh.reward.positiver - last_dist)
            println(lh.reward.normalizer* (lh.reward.positiver - last_dist))
        end
    else lh.reward.value+=0
        println("encore aucune variable choisie on ne rajoute pas de reward")
    end
end


"""
    set_reward!(::EndingPhase, lh::LearnedHeuristic{TsptwReward, A}, model::CPModel, symbol::Union{Nothing, Symbol})

Increment the current reward at the EndingPhase. Called when the search is finished by an optimality proof or by a limit in term of nodes or
in terms of number of solution. This is useful to add some general results to the reward like the number of ndoes visited during the episode for instance.
"""
function set_reward!(::Type{EndingPhase}, lh::LearnedHeuristic{SR, TsptwReward, A}, model::CPModel, symbol::Union{Nothing, Symbol}) where {
    SR <: AbstractStateRepresentation,
    A <: ActionOutput
}
    if symbol == :Feasible || symbol == :FoundSolution
        lh.reward.value += 20
    elseif symbol == :Infeasible
        lh.reward.value -= 10/lh.search_metrics.total_steps
    end

    print("reward EnfingPhase avec symbol ")
    println(symbol)
    println(lh.reward.value)
    println()
    # lh.reward.value += 1.
end
