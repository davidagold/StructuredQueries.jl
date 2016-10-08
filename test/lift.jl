module TestLift

using StructuredQueries
const SQ = StructuredQueries
using Base.Test

##############################################################################
##
## Test standard lifting semantics
##
##############################################################################

types = [
    Float16,
    Float32,
    Float64,
    Int128,
    Int16,
    Int32,
    Int64,
    Int8,
    UInt16,
    UInt32,
    UInt64,
    UInt8,
]

f(x::Number) = 5 * x
f(x::Number, y::Number) = x + y
f(x::Number, y::Number, z::Number) = x + y * z

for T in types
    a = one(T)
    x = Nullable{T}(a)
    y = Nullable{T}()

    U1 = Core.Inference.return_type(f, Tuple{T})
    @test isequal(SQ.lift(f, x), Nullable(f(a)))
    @test isequal(SQ.lift(f, y), Nullable{U1}())

    U2 = Core.Inference.return_type(f, Tuple{T, T})
    @test isequal(SQ.lift(f, x, x), Nullable(f(a, a)))
    @test isequal(SQ.lift(f, x, y), Nullable{U2}())

    U3 = Core.Inference.return_type(f, Tuple{T, T, T})
    @test isequal(SQ.lift(f, x, x, x), Nullable(f(a, a, a)))
    @test isequal(SQ.lift(f, x, y, x), Nullable{U3}())
end

##############################################################################
##
## Test non-standard lifting semantics
##
##############################################################################

# three-valued logic

# & truth table
v1 = SQ.lift(&, Nullable(true), Nullable(true))
v2 = SQ.lift(&, Nullable(true), Nullable(false))
v3 = SQ.lift(&, Nullable(true), Nullable{Bool}())
v4 = SQ.lift(&, Nullable(false), Nullable(true))
v5 = SQ.lift(&, Nullable(false), Nullable(false))
v6 = SQ.lift(&, Nullable(false), Nullable{Bool}())
v7 = SQ.lift(&, Nullable{Bool}(), Nullable(true))
v8 = SQ.lift(&, Nullable{Bool}(), Nullable(false))
v9 = SQ.lift(&, Nullable{Bool}(), Nullable{Bool}())

@test isequal(v1, Nullable(true))
@test isequal(v2, Nullable(false))
@test isequal(v3, Nullable{Bool}())
@test isequal(v4, Nullable(false))
@test isequal(v5, Nullable(false))
@test isequal(v6, Nullable(false))
@test isequal(v7, Nullable{Bool}())
@test isequal(v8, Nullable(false))
@test isequal(v9, Nullable{Bool}())

# | truth table
u1 = SQ.lift(|, Nullable(true), Nullable(true))
u2 = SQ.lift(|, Nullable(true), Nullable(false))
u3 = SQ.lift(|, Nullable(true), Nullable{Bool}())
u4 = SQ.lift(|, Nullable(false), Nullable(true))
u5 = SQ.lift(|, Nullable(false), Nullable(false))
u6 = SQ.lift(|, Nullable(false), Nullable{Bool}())
u7 = SQ.lift(|, Nullable{Bool}(), Nullable(true))
u8 = SQ.lift(|, Nullable{Bool}(), Nullable(false))
u9 = SQ.lift(|, Nullable{Bool}(), Nullable{Bool}())

@test isequal(u1, Nullable(true))
@test isequal(u2, Nullable(true))
@test isequal(u3, Nullable(true))
@test isequal(u4, Nullable(true))
@test isequal(u5, Nullable(false))
@test isequal(u6, Nullable{Bool}())
@test isequal(u7, Nullable(true))
@test isequal(u8, Nullable{Bool}())
@test isequal(u9, Nullable{Bool}())

# others

x1 = Nullable(1)
x2 = Nullable(2)
y = Nullable{Int}()
z1 = 1
z2 = 2

@test SQ.lift(isnull, x1) == false
@test SQ.lift(isnull, y) == true

@test SQ.lift(isless, x1, y) == true
@test SQ.lift(isless, y, x1) == false
@test SQ.lift(isless, x1, x2) == true
@test SQ.lift(isless, x2, x1) == false
@test SQ.lift(isless, y, y) == false
@test SQ.lift(isless, x1, z2) == true
@test SQ.lift(isless, x2, z1) == false
@test SQ.lift(isless, z1, x2) == true
@test SQ.lift(isless, z2, x1) == false

@test SQ.lift(get, x1) == 1
@test_throws NullException SQ.lift(get, y)
@test SQ.lift(get, y, 1) == 1

end
