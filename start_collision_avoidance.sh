#!/bin/sh

OUTPUT_PATH="/home/persistent/2024_12_02-output-collision_avoidance"

# check that the variables of the experiment are set to a non empty value
[ -z "$BIAS" ] && exit 1
[ -z "$DAMAGE_MODULE" ] && exit 2
[ -z "$START_SEED" ] && exit 3
[ -z "$END_SEED" ] && exit 4

# create an output directory for the experiment results
mkdir $OUTPUT_PATH

for SEED in `seq $START_SEED $END_SEED`
do
    if [ $DAMAGE_MODULE = "dmg_act_slowed" ]
    then
        for N_FAULTS in 0 1
        do
            if [ -f "$OUTPUT_PATH/$DAMAGE_MODULE-$BIAS-$N_FAULTS-$SEED.txt" ]
            then
                continue
            fi
            # create an instance of the controller for the specific experiment
            cp collision_avoidance.lua collision_avoidance_instance.lua

            # set up the controller with the experiment parameters
            sed -i "s|££ DAMAGE_MODULE ££|\"$DAMAGE_MODULE\"|" "collision_avoidance_instance.lua"
            sed -i "s|££ SEED ££|$SEED|" "collision_avoidance_instance.lua"
            sed -i "s|££ BIAS ££|$BIAS|" "collision_avoidance_instance.lua"
            sed -i "s|££ NUMBER_OF_FAULTS ££|$N_FAULTS|" "collision_avoidance_instance.lua"

            # launch the argos3 experiment and save the results to a file
            argos3 -c run-collision-avoidance.argos | grep -v INFO > "$OUTPUT_PATH/$DAMAGE_MODULE-$BIAS-$N_FAULTS-$SEED.txt"
        done
    else
        for N_FAULTS in `seq 0 3 24`
        do
            if [ -f "$OUTPUT_PATH/$DAMAGE_MODULE-$BIAS-$N_FAULTS-$SEED.txt" ]
            then
                continue
            fi
            # create an instance of the controller for the specific experiment
            cp collision_avoidance.lua collision_avoidance_instance.lua

            # set up the controller with the experiment parameters
            sed -i "s|££ DAMAGE_MODULE ££|\"$DAMAGE_MODULE\"|" "collision_avoidance_instance.lua"
            sed -i "s|££ SEED ££|$SEED|" "collision_avoidance_instance.lua"
            sed -i "s|££ BIAS ££|$BIAS|" "collision_avoidance_instance.lua"
            sed -i "s|££ NUMBER_OF_FAULTS ££|$N_FAULTS|" "collision_avoidance_instance.lua"

            # launch the argos3 experiment and save the results to a file
            argos3 -c run-collision-avoidance.argos | grep -v INFO > "$OUTPUT_PATH/$DAMAGE_MODULE-$BIAS-$N_FAULTS-$SEED.txt"
        done
    fi
done
