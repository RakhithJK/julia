# This file is a part of Julia. License is MIT: https://julialang.org/license

const svar1 = ScopedValue(1)

@testset "errors" begin
    @test ScopedValue{Float64}(1) == 1.0
    var = ScopedValue(1)
    @test_throws MethodError var[] = 2
    scoped() do
        @test_throws MethodError var[] = 2
    end
    @test_throws MethodError ScopedValue{Int}()
    @test_throws MethodError ScopedValue()
end

const svar = ScopedValue(1)
@testset "inheritance" begin
    @test svar[] == 1
    scoped() do
        @test svar[] == 1
        scoped() do
            @test svar[] == 1
        end
        scoped(svar => 2) do
            @test svar[] == 2
        end
        @test svar[] == 1
    end
    @test svar[] == 1
end

const svar_float = ScopedValue(1.0)

@testset "multiple scoped values" begin
    scoped(svar => 2, svar_float => 2.0) do
        @test svar[] == 2
        @test svar_float[] == 2.0
    end
    scoped(svar => 2, svar => 3) do
        @test svar[] == 3
    end
end

emptyf() = nothing

@testset "conversion" begin
    scoped(emptyf, svar_float=>2)
    @test_throws MethodError scoped(emptyf, svar_float=>"hello")
end

import Base.Threads: @spawn
@testset "tasks" begin
    @test fetch(@spawn begin
        svar[]
    end) == 1
    scoped(svar => 2) do
        @test fetch(@spawn begin
            svar[]
        end) == 2
    end
end
