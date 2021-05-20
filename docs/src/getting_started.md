# Getting started

The goal of this section is to provide any new user or contributor the basis of SeaPearl. We give directions for installation, basic CP usage and more complex RL usage of the package.

## Installation

[SeaPearl.jl](index.md) is now available directly on Julia public registry. You can install it via `Pkg` as follow:

```julia
julia> ]add SeaPearl
```

If you want to access the source code with the last version of the project, you can use the `Pkg.dev` command as follow:

```julia
julia> ]dev [--shared|--local] https://github.com/corail-research/SeaPearl.jl.git
```
_See [Pkg.jl](https://pkgdocs.julialang.org/v1.0) page for further details_


## Use

SeaPearl can be used either as a classic CP solver with predefined variable and value selection heuristics, or as a Reinforcement Learning driven CP solver that is capable of learning through solving automatically generated instances of a given problem ( knapsack, tsptw, graphcoloring, nurse rostering ...). 

### SeaPearl as a classic CP solver: 
To use SeaPearl as a classic CP solver, one needs to: 

1. create a variable selection heuristic.
2. create a value selection heuristic.
3. create a Constraint Programming Model.
4. _optionnaly_, add an objective function to your model. 
5. solve your model.

```julia
# Variable selection heuristic setup
YourVariableSelectionHeuristic{TakeObjective} <: SeaPearl.AbstractVariableSelection{TakeObjective}

# Value selection heuristic setup
BasicHeuristic <: ValueSelection

# CP Model setup
trailer = SeaPearl.Trailer()
model = SeaPearl.CPModel(trailer)

SeaPearl.addVariable!(...)

push!(model.constraints, SeaPearl.AbstractConstraint(...))

# Add optionnal objective function: 
model.objective = ObjectiveVar

# Model resolution
SeaPearl.search!(model, SeaPearl.DFSearch, YourVariableSelectionHeuristic, BasicHeuristic)
```

### SeaPearl as a RL-driven CP solver: 
To use SeaPearl as a RL-driven CP solver, one needs to: 

1. declare a variable selection heuristic.
1. declare a value selection learnedheuristic.
1. _optionnaly_, declare some classic value selection heuristic for benchmarking purposes.
1. define an agent.
1. _optionnaly_, declare a custom reward.
1. _optionnaly_, declare a custom StateRepresentation (instead of the Default tripartite-graph representation).
1. _optionnaly_, declare a custom featurization for the StateRepresentation.
1. create a generator for your given problem, that will create different instances of the specific problem used during the learning process. 
1. set a number of training epochs, declare an evaluator, a Strategy, a metric for benchmarking.
1. launch the training.
1. solve your model on other instances.

```julia
# Variable selection heuristic setup
CustomVariableSelectionHeuristic{TakeObjective} <: SeaPearl.AbstractVariableSelection{TakeObjective}

# Value selection heuristic setup
LearnedHeuristic{SR<:AbstractStateRepresentation, R<:AbstractReward, A<:ActionOutput} <: ValueSelection

# Deterministic value selection heuristic setup
basicHeuristic = SeaPearl.BasicHeuristic((x; cpmodel) -> your_function(...))

# Agent setup
agent = RL.Agent(
policy=(...),
trajectory=(...),
)

# Reward function setup
CustomReward <: SeaPearl.AbstractReward 

# Problem representation setup
CustomStateRepresentation <: SeaPearl.AbstractStateRepresentation

# Node features setup
CustomFeaturization <: SeaPearl.AbstractFeaturization

# Problem generator setup
CustomProblemGenerator <: AbstractModelGenerator

# Training setup
nb_epochs = 3000
CustomStrategy <: SearchStrategy #or use predefined one: SeaPearl.DFSearch
CustomEvaluator <: AbstractEvaluator #or use predefined one: SeaPearl.SameInstancesEvaluator(...)
function CustomMetricsFun

# Training launch
bestsolutions, nodevisited,timeneeded, eval_nodevisited, eval_timeneeded = SeaPearl.train!(
    valueSelectionArray = [learnedHeuristic, basicHeuristic], 
    generator = CustomProblemGenerator,
    nb_episodes = nb_episodes,
    strategy = CustomStrategy,
    variableHeuristic = CustomVariableSelectionHeuristic,
    metricsFun = CustomMetricsFun,
    evaluator = CustomEvaluator
)

# Test launch
SeaPearl.search!(model, SeaPearl.DFSearch, CustomVariableSelectionHeuristic, LearnedHeuristic)
```

## Examples

For a more complete use of SeaPearl, you are welcome to check the [SeaPearlZoo](https://github.com/corail-research/SeaPearlZoo). It provides a standard way to build complex models and to train heursitics to solve them.

## Contributing

All PRs and issues are welcome.
This repo contains README.md and images to facilitate the understanding of the code. 
To contribute to Sealpearl, follow these steps:

1. Fork this repository.
2. Push your changes on your fork.
3. Create a pull request, and explain us what modifications you want to bring to SeaPearl.
4. _optionnaly_, Link the issue related to your PR.

Alternatively see the GitHub documentation on [creating a pull request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request).


