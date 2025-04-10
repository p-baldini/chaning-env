using Base.Iterators

const IMAGE_NAME="quay.io/p-baldini/experiment_2025-03-28:1.0.1"

file = open("compose.yaml", "w")

header =
"""
version: '3.9'

services:
"""
write(file, header)

EXPERIMENT_TYPES = [
    "collision_avoidance",
    "phototaxis"
]

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

template(EXPERIMENT_TYPE, DAMAGE_TYPE, S_SEED, E_SEED) = 
"""
  $EXPERIMENT_TYPE-$DAMAGE_TYPE-$S_SEED-$E_SEED:
    image: pbaldini/$IMAGE_NAME
    environment:
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
    entrypoint: "/home/start_$EXPERIMENT_TYPE.sh"
    restart: "no"
"""

for et in EXPERIMENT_TYPES
    for dt in DAMAGE_TYPES
        for (ss, es) in SEED_RANGES
            write(file, template(et, dt, ss, es))
        end
    end
end

volumes =
"""
volumes:
  data:
    name: p.baldini-volume
"""
write(file, volumes)

close(file)
