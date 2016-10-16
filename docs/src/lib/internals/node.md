# `QueryNode`

```@meta
CurrentModule = StructuredQueries
```

```@docs
DataNode{T}
isequal(dn1::DataNode, dn2::DataNode)
isequal{T<:QueryNode}(q1::T, q2::T)
isequal{T<:JoinNode}(q1::T, q2::T)
```
