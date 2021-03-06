module UnivariateTest
using AverageShiftedHistograms, StatsBase, FactCheck, Distributions

facts("Univariate") do
    context("Constructors") do
        n = rand(10_000:100_000)
        y = randn(n)
        o = ash(y)
        o = ash(y, -4:.1:4, m = 3, kernel = :gaussian)
    end

    context("methods") do
        n = rand(10_000:100_000)
        y = randn(n)
        o = ash(y, -4:.1:4, m=3)
        o = ash(y, -4:.1:4)
        show(o)
        @fact mean(o) - mean(y) --> roughly(0.0, .1)
        @fact var(o)  - var(y) --> roughly(0.0, .1)
        @fact std(o)  - std(y) --> roughly(0.0, .1)
        @fact quantile(o, 0.5)  - quantile(y, 0.5) --> roughly(0.0, .3)
        @fact quantile(o, .00000001) --> o.rng[1]
        @fact quantile(o, [.25, .5, .75]) - quantile(y, [.25, .5, .75]) --> roughly(zeros(3), .3)
        @fact typeof(xy(o)) <: Tuple --> true
        @fact xy(o)[1] --> collect(-4:.1:4)
        @fact maxabs(o.v - hist(y, (-4:.1:4.1) - .05)[2]) --> 0 "Check that histogram is correct"
        @fact pdf(o, 0.0) - 0.4 --> roughly(0.0, .1)
        pdf(o, [-1, 0, 1])
        @fact quadgk(x -> pdf(o, x), -Inf, Inf)[1] --> roughly(1.0, .001) "pdf integrates to 1.0"

        @fact nobs(o) --> n

        # nobs and nout
        y2 = randn(n)
        fit!(o, y2)
        @fact nobs(o) --> 2n
        o2 = copy(o)
        @fact nobs(o2) - nobs(o) --> 0
        merge!(o, o2)
        @fact nobs(o) --> 4n
        o = ash(rand(10), -1:.1:1)
        @fact nout(o) --> 0
        fit!(o, [5.0])
        @fact nout(o) --> 1
    end
end

end # module
