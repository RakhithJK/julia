# This file is a part of Julia. License is MIT: https://julialang.org/license

const svar1 = ScopedVariable(1)

@testset "errors" begin
    var = ScopedVariable(1)
    @test_throws MethodError var[] = 2
    scoped() do
        @test_throws MethodError var[] = 2
    end
end

const svar = ScopedVariable(1)
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

const svar_float = ScopedVariable(1.0)

@testset "multiple scoped variables" begin
    scoped(svar => 2, svar_float => 2.0) do
        @test svar[] == 2
        @test svar_float[] == 2.0
    end
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
