using Plots
using Statistics

EPOCH_COUNT = 800
SEEDS=0:0
DAMAGES=0:3:0
DISCARD_THRESHOLD=100



# Loads an experiment performance from file
load_experiment(seed, damages) =
    read("test/out/pt/dmg_sns_fixed-0.79-$damages-$seed.txt", String) |>
    s -> split(s, '\n') |>
    v -> filter(startswith('^'), v) |>
    v -> split.(v, ' ') |>
    v -> last.(v) |>
    v -> parse.(Float32, v)



# Compute the distance travelled in the last step
per_step(data) = data[begin+1:end] .- data[begin:end-1]



# Compute the distance travelled since the start of the experiment-phase
compute_distance(data) = data[1] .- data[:]



# Loads all the experiments with the given number of damages
load_experiment_set(n) = SEEDS |>
    s -> load_experiment.(s, n) |>
    v -> compute_distance.(v) |>
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
    title="Cumulative traveled distance",
    xlabel="Epochs", ylabel="Distance [m]", size=(750, 500),
    margins=50Plots.px
)
savefig("pt1.png")

# Put the data in function of the increased motion towards the light
data = data |>
    v -> eachcol(v) |>
    v -> per_step.(v) |>
    v -> mapreduce(permutedims, vcat, v) |>
    m -> transpose(m)
plot(
    data,
    label=DAMAGES |> collect |> transpose,
    title="Per-epoch traveled distance",
    xlabel="Epochs", ylabel="Distance [m]", size=(750, 500),
    margins=50Plots.px
)
savefig("pt2.png")
