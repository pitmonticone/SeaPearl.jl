# Variables

```@meta
CurrentModule = SeaPearl
```

There are currently three types of variables available in SeaPearl: [Integer Variables](#Integer-variables), [Boolean Variables](#Boolean-variables) and [Set Variables](#Set-variables).

The variables are all a subset of `AbstractVar`.

Every `AbstractVar` must have a unique `id` that you can retrieve with `SeaPearl.id`.
```@docs
SeaPearl.id
```

```@index
Pages = ["variables.md"]
```
## Integer variables

The implementation of integer variables in SeaPearl is heavily inspired on [MiniCP](https://minicp.readthedocs.io/en/latest/learning_minicp/part_2.html). If you have some troubles understanding how it works, you can get more visual explanations by reading their [slides](https://inginious.org/course/minicp/domains).

All the integer variables are sub-types of `AbstractIntVar`.
```@docs
AbstractIntVar
AbstractIntDomain
```
### IntVar

```@docs
IntVar
IntVar(::Int, ::Int, ::String, ::Trailer)
assign!(::IntVar, ::Int)
isbound(::IntVar)
assignedValue(::IntVar)
```

### IntDomain

```@docs
IntDomain
IntDomain(::Trailer, ::Int, ::Int)
Base.isempty(::IntDomain)
Base.length(::IntDomain)
Base.in(::Int, ::IntDomain)
Base.iterate(::IntDomain)
remove!(::IntDomain, ::Int)
removeAll!(::IntDomain)
removeAbove!(::IntDomain, ::Int)
removeBelow!(::IntDomain, ::Int)
updateMaxFromRemovedVal!(::IntDomain, ::Int)
updateMinFromRemovedVal!(::IntDomain, ::Int)
updateBoundsFromRemovedVal!(::IntDomain, ::Int)
minimum(::IntDomain)
maximum(::IntDomain)
```

If you want to express some variations of an integer variable ``x`` (for example ``-x`` or ``a x`` with ``a > 0``) in a constraint, you can use the `IntVarView` types:

### IntVarView

```@docs

```

## Boolean variables

## Set variables
