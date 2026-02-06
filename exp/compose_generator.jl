using Base.Iterators

const IMAGE_NAME="quay.io/p-baldini/2025-ece:1.1.0"
const WORK_DIR="/home/persistent/2025-ece/1.1.0"
const EXP="cawh"

file = open("compose-$EXP.yaml", "w")

header =
"""
version: '3.9'

services:
"""
write(file, header)

SEED_RANGES = zip(
    (0:50 |> collect) .* 10 .+ 1,
    (1:50 |> collect) .* 10
)

template(S_SEED, E_SEED) = 
"""
  $EXP-$S_SEED-$E_SEED:
    image: $IMAGE_NAME
    environment:
      - WORK_DIR=$WORK_DIR
      - START_SEED=$S_SEED
      - END_SEED=$E_SEED
    volumes:
      - "data:/home/persistent"
      - type: tmpfs
        target: /dev/shm
        tmpfs:
           size: 131072
    entrypoint: "/home/start_$(EXP)_experiment.sh"
"""

for (ss, es) in SEED_RANGES
    write(file, template(ss, es))
end

volumes =
"""
volumes:
  data:
    name: paolo.baldini-volume
"""
write(file, volumes)

close(file)
