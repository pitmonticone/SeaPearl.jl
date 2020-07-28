
"""
    Flux.testmode!(lh::LearnedHeuristic, mode = true)

Make it possible to change the mode of the LearnedHeuristic: training or testing. This makes sure
you stop updating the weights or the approximator once the training is done. It is used at the beginning
of the `train!` function to make sure it's training and changed automatically at the end of it but a user can 
manually change the mode again if he wants.
"""
Flux.testmode!(lh::LearnedHeuristic, mode = true) = Flux.testmode!(lh.agent, mode) 

"""
    update_with_cpmodel!(lh::LearnedHeuristic{SR, R, A}, model::CPModel)

This function initializes the fields of a LearnedHeuristic which are useful to do reinforcement learning 
and which depend on the CPModel considered. It is called at the beginning of the `search!` function (in the 
InitializingPhase).
"""
function update_with_cpmodel!(lh::LearnedHeuristic{SR, R, A}, model::CPModel) where {
    SR <: AbstractStateRepresentation, 
    R <: AbstractReward, 
    A <: ActionOutput
}

    # construct the action_space
    variables = collect(values(model.variables))
    valuesOfVariables = sort(arrayOfEveryValue(variables))

    lh.action_space = RL.DiscreteSpace(valuesOfVariables)
    # state rep construction
    lh.current_state = SR(model)

    lh.current_reward = 0
    lh.search_metrics = SearchMetrics(model)

    lh
end

include("reward.jl")

"""
    sync!(lh::LearnedHeuristic, model::CPModel, x::AbstractIntVar)

Synchronize the environment part of the LearnedHeuristic with the CPModel.
"""
function sync_state!(lh::LearnedHeuristic, model::CPModel, x::AbstractIntVar)
    update_representation!(lh.current_state, model, x)
    nothing 
end

"""
    get_observation!(lh::LearnedHeuristic, model::CPModel, x::AbstractIntVar, done = false)

This function retrieve all the elements that are useful for doing reinforcement learning. 
- The reward, which has been incremented through the set_reward!(PHASE, ...) functions. 
- The terminal boolean (is the episode done or not)
- The current state, which is the StateRepresentation of the CPModel at this stage of the solving.
This state is what will then be given to the agent to make him proposed an action (a value to assign.)
- The legal_actions & legal_actions_mask used to make sure the agent won't propose a value which isn't 
in the domain of the variable we're branching on. 

The result is given as a namedtuple for convenience with ReinforcementLearning.jl interface. 
"""
function get_observation!(lh::LearnedHeuristic, model::CPModel, x::AbstractIntVar, done = false)
    # get legal_actions_mask
    legal_actions_mask = [value in x.domain for value in lh.action_space]

    # compute legal actions
    legal_actions = lh.action_space.span[legal_actions_mask]

    reward = lh.current_reward
    # Initialize reward for the next state: not compulsory with DefaultReward, but maybe useful in case the user forgets it
    lh.current_reward = 0

    # synchronize state: we could delete env.state, we do not need it 
    sync_state!(lh, model, x)

    state = to_arraybuffer(lh.current_state, lh.cpnodes_max)
    # println("reward", reward)
    
    # return the observation as a named tuple (useful for interface understanding)
    return (reward = reward, terminal = done, state = state, legal_actions = legal_actions, legal_actions_mask = legal_actions_mask)
end

"""
    set_metrics!(PHASE::T, lh::LearnedHeuristic, model::CPModel, symbol::Union{Nothing, Symbol}, x::Union{Nothing, AbstractIntVar}) where T <: LearningPhase 

Call set_metrics!(::SearchMetrics, ...) on env.search_metrics to simplify synthax.
Could also add it to basicheuristic !
"""
function set_metrics!(PHASE::T, lh::LearnedHeuristic, model::CPModel, symbol::Union{Nothing, Symbol}, x::Union{Nothing, AbstractIntVar}) where T <: LearningPhase
    set_metrics!(PHASE, lh.search_metrics, model, symbol, x::Union{Nothing, AbstractIntVar})
end
