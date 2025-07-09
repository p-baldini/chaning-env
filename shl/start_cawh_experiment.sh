#!/bin/sh

# check that the variables of the experiment are set to a non empty value
[ -z "$START_SEED" ] &&    echo "[ERROR] Missing parameter START_SEED" &&    exit 1
[ -z "$END_SEED" ] &&      echo "[ERROR] Missing parameter END_SEED" &&      exit 2
[ -z "$WORK_DIR" ] &&      echo "[ERROR] Missing parameter WORK_DIR" &&      exit 3

# create an output directory for the experiment results
OUTPUT_PATH="$WORK_DIR/cawh"
mkdir -p $OUTPUT_PATH

for SEED in $(seq $START_SEED $END_SEED)
do
    if [ -f "$OUTPUT_PATH/s$SEED.txt" ]
    then
        continue
    fi
    # create an instance of the controller for the specific experiment
    cp main.lua main_instance.lua
    cp collision-avoidance-with-homeostasis.argos collision-avoidance-with-homeostasis_instance.argos

    # set up the controller with the experiment parameters
    sed -i "s|££ SEED ££|$SEED|" "main_instance.lua"
    sed -i "s|££ EPOCH_STEPS ££|300|" "main_instance.lua"
    sed -i "s|££ PHASE_1_EPOCHS ££|1200|" "main_instance.lua"   # length experiment (72000s) * steps per second (10) / steps per epochs (300) / phase count (2)
    sed -i "s|££ SENSORS_TYPE ££|proximity|" "main_instance.lua"
    sed -i "s|random_seed=\"1\"|random_seed=\"$SEED\"|" "collision-avoidance-with-homeostasis_instance.argos"

    # launch the argos3 experiment and save the results to a file
    argos3 -n -c collision-avoidance-with-homeostasis_instance.argos | grep -v INFO > "$OUTPUT_PATH/s$SEED.txt"
done
