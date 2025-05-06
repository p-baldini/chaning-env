using Base.Iterators

const IMAGE_NAME="quay.io/p-baldini/2025-egd:1.0.3"
const WORK_DIR="/home/persistent/2025-egd-1.0.3"
const EXP="ca-informed"
# const EXP="ca-clueless"
# const EXP="pt-informed"
# const EXP="pt-clueless"

file = open("compose-$EXP.yaml", "w")

header =
"""
version: '3.9'

services:
"""
write(file, header)

DAMAGE_TYPES = [
    "dmg_act_slowed",
    "dmg_sns_disconnected",
    "dmg_sns_fixed",
    "dmg_sns_random"
]
SEED_RANGES = zip(
    (0:50 |> collect) .* 50 .+ 1,
    (1:50 |> collect) .* 50
)

template(DAMAGE_TYPE, S_SEED, E_SEED) = 
"""
  $EXP-$DAMAGE_TYPE-$S_SEED-$E_SEED:
    image: $IMAGE_NAME
    environment:
      - WORK_DIR=$WORK_DIR
      - BIAS=0.79
      - DAMAGE_MODULE=$DAMAGE_TYPE
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

for dt in DAMAGE_TYPES
    for (ss, es) in SEED_RANGES
        write(file, template(dt, ss, es))
    end
end

volumes =
"""
volumes:
  data:
    name: paolo.baldini-volume
"""
write(file, volumes)

close(file)
