var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#StructuredQueries.jl-1",
    "page": "Home",
    "title": "StructuredQueries.jl",
    "category": "section",
    "text": "A query representation framework for Julia."
},

{
    "location": "index.html#Package-Abstract-1",
    "page": "Home",
    "title": "Package Abstract",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Manual-Outline-1",
    "page": "Home",
    "title": "Manual Outline",
    "category": "section",
    "text": "Pages = [\n    \"man/guide.md\",\n    \"man/syntax.md\",\n    \"man/extension.md\",\n    \"man/examples.md\"\n]\nDepth = 1"
},

{
    "location": "index.html#Library-Outline-1",
    "page": "Home",
    "title": "Library Outline",
    "category": "section",
    "text": "Pages = [\n    \"lib/public.md\",\n    \"lib/internals.md\"\n]"
},

{
    "location": "man/guide.html#",
    "page": "Guide",
    "title": "Guide",
    "category": "page",
    "text": ""
},

{
    "location": "man/guide.html#Guide-1",
    "page": "Guide",
    "title": "Guide",
    "category": "section",
    "text": ""
},

{
    "location": "man/guide.html#Installation-1",
    "page": "Guide",
    "title": "Installation",
    "category": "section",
    "text": "StructuredQueries is a registered package. Install it withPkg.add(\"StructuredQueries\")This package supports Julia 0.5."
},

{
    "location": "man/guide.html#Usage-1",
    "page": "Guide",
    "title": "Usage",
    "category": "section",
    "text": "StructuredQueries.jl provides a generic framework for data manipulation in Julia. The center of this framework are the @query and @collect macros.To express a query in SQ, one uses the @query macro:@query qrywhere qry is Julia code that follows a certain structure that we will describe below.qry is parsed according to what we'll call a query context. By a context we mean a general semantics for Julia code that may differ from the semantics of the standard Julia environment. That is to say: though qry must be valid Julia syntax, the code is not run as it would were it executed outside of the @query macro. Rather, code such as qry that occurs inside of a query context is subject to a number of transformations before it is run.For instance, suppose iris names some tabular data source object (e.g. a DataFrame). We might express a query to produce a subset of the data that satisfies some predicate, say sepal_length > 5.0 withjulia> q = @query filter(iris, sepal_length > 5.0)\nQuery against a source of type DataFrames.DataFrameThe structure of the query passed to @query consists of a manipulation verb (e.g. filter) that in turn takes a data source argument (e.g. iris) for its first argument and any number of query arguments (e.g. sepal_length > 5.0) for its latter arguments. These are the three different \"parts\" of a query: (1) data sources (or just \"sources\"), (2) manipulation verbs (or just \"verbs\"), and (3) query arguments.The @query macro transforms the code filter(iris, sepal_length > 5.0) into code that produces a Query object that represents the structure of the query:julia> typeof(q)\nStructuredQueries.Query\n\njulia> graph(q)\nFilterNode\n  arguments:\n      1)  sepal_length > 5.0\n  inputs:\n      1)  DataNode\n            source:  source of type DataFrame"
},

{
    "location": "man/guide.html#Natively-Supported-Verbs-1",
    "page": "Guide",
    "title": "Natively Supported Verbs",
    "category": "section",
    "text": "note: Note\nBy \"natively supported\", we mean that the following verbs are recognized by the @query macro and properly incorporated into a graph representation.select\nfilter\ngroupby\nsummarize\norderby\ninnerjoin\nleftjoin\nouterjoin\ncrossjoin"
},

{
    "location": "man/guide.html#Contexts-1",
    "page": "Guide",
    "title": "Contexts",
    "category": "section",
    "text": "Each part of a query induces its own context in which code is evaluated. The most significant aspect of such contexts is name resolution. That is to say, names resolve differently depending on which part of a query they appear in and in what capacity they appear:In a data source specification context – e.g., as the first argument to a verb such as filter above – names are evaluated in the enclosing scope of the @query invocation. Thus, iris in the query used to define q above refers precisely to the Table object to which the name is bound in the top level of Main.\nNames of manipulation verbs are not resolved to objects but rather merely signal how to construct the graphical representation of the query. (Indeed, in what follows there is no such function filter that is ever invoked in the execution of a query involving a filter clause.)\nNames of functions called within a query argument context, such as > in sepal_length > 5.0 are evaluated in the enclosing scope of the @query invocation.\nNames that appear as arguments to function calls within a query argument context, such as sepal_length in sepal_length > 5.0 are not resolved to objects but are rather parsed as \"attributes\" of the data source (in this case, iris). When the data source is a tabular data structure, such attributes are taken to be column names, but such behavior is just a feature of a particular query semantics (see below in the section \"Roadmap and open questions\".) The attributes that are passed as arguments to a given function call in a query argument are stored as data in the graphical query representation."
},

{
    "location": "man/guide.html#Composition-1",
    "page": "Guide",
    "title": "Composition",
    "category": "section",
    "text": "Manipulation verbs are composable in that an invocation of one verb may serve as a source argument to another verb:julia> @query select(filter(iris, sepal_length > 5.0), species, petal_width)\nQuery against a source of type DataFrames.DataFrame\n\njulia> graph(ans)\nSelectNode\n  arguments:\n      1)  species\n      2)  petal_width\n  inputs:\n      1)  FilterNode\n            arguments:\n                1)  sepal_length > 5.0\n            inputs:\n                1)  DataNode\n                      source:  source of type DataFrameOne can pipe arguments to verbs inside an @query context. For instance, the above Query is equivalent to that produced by@query iris |>\n    filter(sepal_length > 5.0) |>\n    select(species, petal_width)In this case, the first argument (i.e. sepal_length > 5.0) to the verb filter is not a data source argument (e.g. iris, which is instead the first argument to |>), but is rather a query argument.If q is a Query, then invoking @query q ... simply extends the graph of q to include a representation of ...:julia> f(q::Query) = @query q |> groupby(species, petal_length > 5.0)\nf (generic function with 1 method)\n\njulia> f(@query filter(iris, sepal_length > 5.0))\nQuery against a source of type DataFrames.DataFrame\n\njulia> graph(ans)\nGroupbyNode\n  arguments:\n      1)  species\n      2)  petal_length > 5.0\n  inputs:\n      1)  FilterNode\n            arguments:\n                1)  sepal_length > 5.0\n            inputs:\n                1)  DataNode\n                      source:  source of type DataFrame"
},

{
    "location": "man/guide.html#Collection-1",
    "page": "Guide",
    "title": "Collection",
    "category": "section",
    "text": "note: Note\nStructuredQueries.jl does not provide any sort of collection machinery; it only provides a query representation interface. Support for backend-specific collection machineries can be found either in data type hosting packages (e.g. TablesDemo.jl) or in a collection interface package (e.g. Collect.jl)To materialize the results of q as a concrete, in-memory Julia object, one callscollect(q)"
},

{
    "location": "man/examples.html#",
    "page": "Examples",
    "title": "Examples",
    "category": "page",
    "text": ""
},

{
    "location": "man/examples.html#Examples-1",
    "page": "Examples",
    "title": "Examples",
    "category": "section",
    "text": "The following packages are examples of how the StructuredQueries framework can be extended to support queries against particular backends."
},

{
    "location": "man/examples.html#AbstractTables.jl-1",
    "page": "Examples",
    "title": "AbstractTables.jl",
    "category": "section",
    "text": "AbstractTables.jl is an example of how the present query framework can be embedded in a particular data type's API. Concrete data types such as Table that implement the requisite interfaces are in turn furnished with querying and collection facilities for free."
},

{
    "location": "man/examples.html#Collect.jl-1",
    "page": "Examples",
    "title": "Collect.jl",
    "category": "section",
    "text": "Collect.jl is an interface between StructuredQueries.jl and extant data types, such as DataFrame, that do not directly extend the present query framework as part of their core API."
},

{
    "location": "lib/public.html#",
    "page": "Public",
    "title": "Public",
    "category": "page",
    "text": ""
},

{
    "location": "lib/public.html#Public-Documentation-1",
    "page": "Public",
    "title": "Public Documentation",
    "category": "section",
    "text": "This page contains documentation for StructuredQueries.jl's public interface.See the Internal Documentation for documentation of StructuredQueries.jl's internals."
},

{
    "location": "lib/public.html#Contents-1",
    "page": "Public",
    "title": "Contents",
    "category": "section",
    "text": "Pages = [\"public.md\"]"
},

{
    "location": "lib/public.html#Index-1",
    "page": "Public",
    "title": "Index",
    "category": "section",
    "text": "Pages = [\"public.md\"]"
},

{
    "location": "lib/public.html#StructuredQueries.@query",
    "page": "Public",
    "title": "StructuredQueries.@query",
    "category": "Macro",
    "text": "@query(qry)\n\nReturn a Query object that represents the query structure of qry.\n\n\n\n"
},

{
    "location": "lib/public.html#StructuredQueries.@collect",
    "page": "Public",
    "title": "StructuredQueries.@collect",
    "category": "Macro",
    "text": "@collect(qry)\n\nLike @query, but automatically collects the resulting Query object.\n\n\n\n"
},

{
    "location": "lib/public.html#StructuredQueries.Query",
    "page": "Public",
    "title": "StructuredQueries.Query",
    "category": "Type",
    "text": "Query\n\nWrap a QueryNode graph that represents the structure of a query passed to the @query macro.\n\n\n\n"
},

{
    "location": "lib/public.html#Base.collect-Tuple{StructuredQueries.Query}",
    "page": "Public",
    "title": "Base.collect",
    "category": "Method",
    "text": "Base.collect(q::Query)\n\nCollect a qry against the source wrapped in the base DataNode of qry.graph.\n\n\n\n"
},

{
    "location": "lib/public.html#StructuredQueries.source",
    "page": "Public",
    "title": "StructuredQueries.source",
    "category": "Function",
    "text": "source(q::Query)\n\nReturn the data source(s) against which q is to be collected.\n\n\n\n"
},

{
    "location": "lib/public.html#StructuredQueries.graph",
    "page": "Public",
    "title": "StructuredQueries.graph",
    "category": "Function",
    "text": "graph(q::Query)\n\nReturn the QueryNode graph representation of the query that produced q.\n\n\n\n"
},

{
    "location": "lib/public.html#Public-Interface-1",
    "page": "Public",
    "title": "Public Interface",
    "category": "section",
    "text": "CurrentModule = StructuredQueries@query\n@collect\nQuery\ncollect(q::Query)\nsource\ngraph"
},

{
    "location": "lib/internals.html#",
    "page": "Internals",
    "title": "Internals",
    "category": "page",
    "text": ""
},

{
    "location": "lib/internals.html#Internal-Documentation-1",
    "page": "Internals",
    "title": "Internal Documentation",
    "category": "section",
    "text": "This page lists all the documented internals of the StructuredQueries module."
},

{
    "location": "lib/internals.html#Contents-1",
    "page": "Internals",
    "title": "Contents",
    "category": "section",
    "text": "Pages = [\n    \"internals/query.md\",\n    \"internals/graph.md\",\n    \"internals/node.md\",\n    \"internals/helper.md\",\n    \"internals/expr.md\",\n    \"internals/collect.md\"\n]"
},

{
    "location": "lib/internals.html#Index-1",
    "page": "Internals",
    "title": "Index",
    "category": "section",
    "text": "A list of all internal documentation.Pages = [\n    \"internals/query.md\",\n    \"internals/graph.md\",\n    \"internals/node.md\",\n    \"internals/helper.md\",\n    \"internals/expr.md\",\n    \"internals/collect.md\"\n]"
},

{
    "location": "lib/internals/query.html#",
    "page": "Querying",
    "title": "Querying",
    "category": "page",
    "text": ""
},

{
    "location": "lib/internals/query.html#Querying-1",
    "page": "Querying",
    "title": "Querying",
    "category": "section",
    "text": ""
},

{
    "location": "lib/internals/graph.html#",
    "page": "Graph Generation",
    "title": "Graph Generation",
    "category": "page",
    "text": ""
},

{
    "location": "lib/internals/graph.html#StructuredQueries.QUERYNODE",
    "page": "Graph Generation",
    "title": "StructuredQueries.QUERYNODE",
    "category": "Constant",
    "text": "QUERYNODE\n\nInternal map from manipulation verb names (as Symbols) to tuples (T<:QueryNode, H<:QueryHelper).\n\n\n\n"
},

{
    "location": "lib/internals/graph.html#StructuredQueries.gen_graph_ex",
    "page": "Graph Generation",
    "title": "StructuredQueries.gen_graph_ex",
    "category": "Function",
    "text": "gen_graph_ex(qry)::Expr\n\nReturn an Expr to produce a graph representation of qry.\n\n\n\n"
},

{
    "location": "lib/internals/graph.html#StructuredQueries.gen_helpers_ex",
    "page": "Graph Generation",
    "title": "StructuredQueries.gen_helpers_ex",
    "category": "Function",
    "text": "gen_helpers_ex(H, args)::Expr\n\nReturn an Expr to produce a Vector{H<:QueryHelper}, for which each element is derived from a query argument in args.\n\n\n\n"
},

{
    "location": "lib/internals/graph.html#StructuredQueries.gen_helper_ex",
    "page": "Graph Generation",
    "title": "StructuredQueries.gen_helper_ex",
    "category": "Function",
    "text": "gen_helper_ex(H, arg)::Expr\n\nReturn an Expr to produce an H <: QueryHelper object from the query argument arg.\n\n\n\n"
},

{
    "location": "lib/internals/graph.html#Graph-Generation-1",
    "page": "Graph Generation",
    "title": "Graph Generation",
    "category": "section",
    "text": "CurrentModule = StructuredQueriesQUERYNODE\ngen_graph_ex\ngen_helpers_ex\ngen_helper_ex"
},

{
    "location": "lib/internals/node.html#",
    "page": "QueryNode",
    "title": "QueryNode",
    "category": "page",
    "text": ""
},

{
    "location": "lib/internals/node.html#StructuredQueries.DataNode",
    "page": "QueryNode",
    "title": "StructuredQueries.DataNode",
    "category": "Type",
    "text": "DataNode <: QueryNode\n\nRepresent a data source in a QueryNode manipulation graph.\n\nNote: the \"leaves\" of any QueryNode graph must be DataNodes.\n\n\n\n"
},

{
    "location": "lib/internals/node.html#Base.isequal-Tuple{StructuredQueries.DataNode,StructuredQueries.DataNode}",
    "page": "QueryNode",
    "title": "Base.isequal",
    "category": "Method",
    "text": "Base.isequal(dn1::DataNode, dn2::DataNode)::Bool\n\nTest two DataNodes for equality. This \"loose\" form of DataNode equality is satisfied when both dn1 and dn2 are empty, as in the case of a base DataNode of a Query graph that has not yet been collected against.\n\n\n\n"
},

{
    "location": "lib/internals/node.html#Base.isequal-Tuple{T<:StructuredQueries.QueryNode,T<:StructuredQueries.QueryNode}",
    "page": "QueryNode",
    "title": "Base.isequal",
    "category": "Method",
    "text": "Base.isequal{T<:QueryNode}(q1::T, q2::T)::Bool\n\nTest two QueryNode objects for equality.\n\nNote that the result depends only on the input and args fields of each q1 and q2; the contents of the helpers and parameters fields are not compared. This \"loose\" form of QueryNode equality is therefore only determined by the content of the expression passed to @query and reflects the expectation that the same query (as passed to @query) twice should produce Query objects that satisfy isequal.\n\n\n\n"
},

{
    "location": "lib/internals/node.html#Base.isequal-Tuple{T<:StructuredQueries.JoinNode,T<:StructuredQueries.JoinNode}",
    "page": "QueryNode",
    "title": "Base.isequal",
    "category": "Method",
    "text": "Base.isequal{T<:JoinNode}(q1::T, q2::T)::Bool\n\nTest two JoinNode objects for equality.\n\nThis result depends only on the input1, input2 and argsfields of each q1 and q2; the contents of the helpers and parameters fields are not compared.\n\n\n\n"
},

{
    "location": "lib/internals/node.html#QueryNode-1",
    "page": "QueryNode",
    "title": "QueryNode",
    "category": "section",
    "text": "CurrentModule = StructuredQueriesDataNode{T}\nisequal(dn1::DataNode, dn2::DataNode)\nisequal{T<:QueryNode}(q1::T, q2::T)\nisequal{T<:JoinNode}(q1::T, q2::T)"
},

{
    "location": "lib/internals/helper.html#",
    "page": "QueryHelper",
    "title": "QueryHelper",
    "category": "page",
    "text": ""
},

{
    "location": "lib/internals/helper.html#StructuredQueries.QueryHelper",
    "page": "QueryHelper",
    "title": "StructuredQueries.QueryHelper",
    "category": "Type",
    "text": "abstract QueryHelper\n\nLeaf subtypes T <: QueryHelper contain data extracted from query arguments and stored in fields of T as resources for collection machineries.\n\n\n\n"
},

{
    "location": "lib/internals/helper.html#StructuredQueries.parts",
    "page": "QueryHelper",
    "title": "StructuredQueries.parts",
    "category": "Function",
    "text": "parts(helper::QueryHelper)\n\nReturn the parts of the helper (this is usually a tuple of useful things, e.g. a kernel generated from a query argument).\n\n\n\n"
},

{
    "location": "lib/internals/helper.html#QueryHelper-1",
    "page": "QueryHelper",
    "title": "QueryHelper",
    "category": "section",
    "text": "CurrentModule = StructuredQueriesQueryHelper\nparts"
},

{
    "location": "lib/internals/expr.html#",
    "page": "Expression Analysis",
    "title": "Expression Analysis",
    "category": "page",
    "text": ""
},

{
    "location": "lib/internals/expr.html#StructuredQueries.get_res_field",
    "page": "Expression Analysis",
    "title": "StructuredQueries.get_res_field",
    "category": "Function",
    "text": "Extract the assigned column's name from an assignment-like expression.\n\nArguments:\n\ne::Expr: An assignment-like expression, which is either a top-level   assignment expression, which might look like col3 = f(col1) + g(col2); or   a function/macro's keyword argument expression, which might look like   foo(col3 = f(col1) + g(col2)).\n\nReturns:\n\ns::Symbol: A symbol specifying the column name that will be assigned to.\n\n\n\n"
},

{
    "location": "lib/internals/expr.html#StructuredQueries.get_value_expr",
    "page": "Expression Analysis",
    "title": "StructuredQueries.get_value_expr",
    "category": "Function",
    "text": "Extract the value-defining sub-expression from an assignment-like expression.\n\nArguments:\n\ne_in::Expr: An assignment-like expression, which is either a top-level   expression like col3 = f(col1) + g(col2) or a function/macro's keyword   argument like foo(col3 = f(col1) + g(col2)).\n\nReturns:\n\ne_out::Any: A value-defining expression that will be used to compute the   value assigned to the column implied by. May be a literal, a raw symbol or   a full Expr object.\n\n\n\n"
},

{
    "location": "lib/internals/expr.html#StructuredQueries.find_symbols!",
    "page": "Expression Analysis",
    "title": "StructuredQueries.find_symbols!",
    "category": "Function",
    "text": "Recursively descends an expression's AST to find all of the symbols contained in it. Inserts any unquoted symbols that are found into the set argument, s. Note that this function is not designed to handle assignment-like expressions: it is intended for application to value expressions only.\n\nArguments:\n\ns::Set{Symbol}: A set of symbols that will be mutated whenever any new   symbols are found.\ne::Any: An expression-like object that will be descended through to find new   symbols.\n\nReturns:\n\nVoid: This function is used exclusively to mutate the argument s.\n\n\n\n"
},

{
    "location": "lib/internals/expr.html#StructuredQueries.find_symbols",
    "page": "Expression Analysis",
    "title": "StructuredQueries.find_symbols",
    "category": "Function",
    "text": "Recursively descends an expression's AST to find all of the symbols contained in it. Returns all found symbols in a Set{Symbol} object.\n\nArguments:\n\ne::Any: An expression-like object that will be descended through to find new   symbols.\n\nReturns:\n\ns::Set{Symbol}: A set containing all of the symbols found by descending   through the expression-like object's AST.\n\n\n\n"
},

{
    "location": "lib/internals/expr.html#StructuredQueries.map_symbols",
    "page": "Expression Analysis",
    "title": "StructuredQueries.map_symbols",
    "category": "Function",
    "text": "Produce a mapping from symbols to numeric indices and a reverse mapping from numeric indices to symbols.\n\nArguments:\n\ns::Set{Symbol}: A set of symbols that should be assigned numeric indices.\n\nReturns:\n\nmapping::Dict{Symbol, Int}: A mapping from symbols to indices.\nreverse_mapping::Vector{Symbol}: A mapping from indices to symbols.\n\n\n\n"
},

{
    "location": "lib/internals/expr.html#StructuredQueries.replace_symbols",
    "page": "Expression Analysis",
    "title": "StructuredQueries.replace_symbols",
    "category": "Function",
    "text": "Traverse an AST-like object and replace a fixed set of symbols with tuple-indexing expressions.\n\nArguments:\n\ne::Any: An AST-like object.\nmapping:Dict{Symbol, Int}: A mapping from symbols to numeric indices.\ntuple_name::Symbol: The name of the tuple that will be indexed into.\n\nReturns:\n\nnew_e::Any: A new AST-like object with all symbols replaced with   tuple-indexing operations.\n\n\n\n"
},

{
    "location": "lib/internals/expr.html#StructuredQueries.build_kernel_ex!",
    "page": "Expression Analysis",
    "title": "StructuredQueries.build_kernel_ex!",
    "category": "Function",
    "text": "build_kernel_ex!(e, paramters)\n\nReturn an Expr to define a (tuple-argument) lambda whose body reflects the structure of e. Also push any query parameters found while traversing e to parameters.\n\n\n\n"
},

{
    "location": "lib/internals/expr.html#Expression-Analysis-1",
    "page": "Expression Analysis",
    "title": "Expression Analysis",
    "category": "section",
    "text": "CurrentModule = StructuredQueriesget_res_field\nget_value_expr\nfind_symbols!\nfind_symbols\nmap_symbols\nreplace_symbols\nbuild_kernel_ex!"
},

{
    "location": "lib/internals/collect.html#",
    "page": "Collection",
    "title": "Collection",
    "category": "page",
    "text": ""
},

{
    "location": "lib/internals/collect.html#Collection-1",
    "page": "Collection",
    "title": "Collection",
    "category": "section",
    "text": ""
},

]}
