#!/bin/sh

# check that the variables of the experiment are set to a non empty value
[ -z "$BIAS" ] &&          echo "[ERROR] Missing parameter BIAS" &&          exit 1
[ -z "$DAMAGE_MODULE" ] && echo "[ERROR] Missing parameter DAMAGE_MODULE" && exit 2
[ -z "$START_SEED" ] &&    echo "[ERROR] Missing parameter START_SEED" &&    exit 3
[ -z "$END_SEED" ] &&      echo "[ERROR] Missing parameter END_SEED" &&      exit 4

# create an output directory for the experiment results
OUTPUT_PATH="out/$START_SEED-$END_SEED"
mkdir -p $OUTPUT_PATH

for SEED in $(seq $START_SEED $END_SEED)
do
    if [ $DAMAGE_MODULE = "dmg_act_slowed" ]
    then
        RANGE=$(seq 0 2)
    else
        RANGE=$(seq 0 3 24)
    fi

    for N_FAULTS in $RANGE
    do
        if [ -f "$OUTPUT_PATH/f$N_FAULTS-s$SEED.txt" ]
        then
            continue
        fi
        # create an instance of the controller for the specific experiment
        cp main.lua main_instance.lua
        cp run-phototaxis.argos run-phototaxis_instance.argos

        # set up the controller with the experiment parameters
        sed -i "s|££ DAMAGE_MODULE ££|\"$DAMAGE_MODULE\"|" "main_instance.lua"
        sed -i "s|££ SEED ££|$SEED|" "main_instance.lua"
        sed -i "s|££ BIAS ££|$BIAS|" "main_instance.lua"
        sed -i "s|££ NUMBER_OF_FAULTS ££|$N_FAULTS|" "main_instance.lua"
        sed -i "s|££ EVALUATOR ££|\"eval_pt\"|" "main_instance.lua"
        sed -i "s|££ EPOCH_STEPS ££|250|" "main_instance.lua"
        sed -i "s|££ SAFE_EPOCHS ££|150|" "main_instance.lua"
        sed -i "s|££ SENSORS_TYPE ££|light|" "main_instance.lua"
        sed -i "s|random_seed=\"1\"|random_seed=\"$SEED\"|" "run-phototaxis_instance.argos"

        # launch the argos3 experiment and save the results to a file
        argos3 -n -c run-phototaxis_instance.argos | grep -v INFO > "$OUTPUT_PATH/f$N_FAULTS-s$SEED.txt"
    done
done
