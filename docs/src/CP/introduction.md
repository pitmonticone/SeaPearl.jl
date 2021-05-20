# Introduction: the CP solver in details

The architecture of SeaPearl is heavily inspired by [MiniCP](http://www.minicp.org) for the CP part. As a result, the code is quite straightforward:
- different types of variables are defined with their associated domains. 
- the constraints are propagated by operating directly on these domains.
- the search is handled according to the specified strategy and with user-specified heuristics for branching decisions.
- the search also specifies when to save and restore the state of the solver, using the trailer for backtracking.

## Table of content

```@contents
Pages=["variables.md", "constraints.md", "trailer.md", "core.md"]
```