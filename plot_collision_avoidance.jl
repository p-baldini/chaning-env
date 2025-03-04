using Plots
using Statistics

EPOCH_COUNT = 800
SEEDS=0:1
DAMAGES=0:3:0
DISCARD_THRESHOLD=500



# Loads an experiment performance from file
load_experiment(seed, damages) =
    read("test/out/ca/dmg_sns_fixed-0.79-$damages-$seed.txt", String) |>
    s -> split(s, '\n') |>
    v -> filter(startswith('*'), v) |>
    v -> split.(v, '\t') |>
    v -> last.(v) |>
    v -> parse.(Float32, v)



# Loads all the experiments with the given number of damages
load_experiment_set(n) = SEEDS |>
    s -> load_experiment.(s, n) |>
    v -> filter(v -> maximum(v) > DISCARD_THRESHOLD, v) |>
    v -> mapreduce(permutedims, vcat, v) |>
    m -> mean(m, dims=1)



# Loads the experimental data: the matrix of performance for all the damages
data = DAMAGES |>
    v -> load_experiment_set.(v) |>
    v -> mapreduce(permutedims, hcat, v)



plot(
    data,
    label=DAMAGES |> collect |> transpose,
    title="Per-epoch performance",
    xlabel="Epochs", ylabel="Performance",
    margins=50Plots.px
)
1:length(DAMAGES) .|> i -> annotate!(800, data[end, i], DAMAGES[i])
savefig("ca.png")
