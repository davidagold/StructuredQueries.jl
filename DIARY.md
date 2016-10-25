Here's the problem:

we have something like

```
@with df(i)
    filter(i.A > .5)
    groupby(i.B)
    mean(df.C)
end
```

We want the correct graph structure, but we can't necessarily infer as much from the ordering of the manipulation verbs. We need to rely on which tokens/sources are named in the query arguments.

We have, at the beginning, a list of source/token pairs. Parsing the first verb, we should identify which sources are required by identifying which tokens/sources are named.

We shouldn't end up with any unmerged source paths
