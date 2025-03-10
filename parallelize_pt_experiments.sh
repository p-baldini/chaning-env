ROOT_DIR=$(pwd)

# spread the experiment across multiple cores
for DAMAGE_MODULE in "dmg_act_slowed" "dmg_sns_disconnected" "dmg_sns_fixed" "dmg_sns_random"
do
    # set up the experiment directory
    WORK_DIR=$(date +"%Y-%m-%d")_experiment/pt/$DAMAGE_MODULE
    mkdir -p                    $WORK_DIR
    cp src/*                    $WORK_DIR
    cp exp/*                    $WORK_DIR
    cp start_pt_experiment.sh   $WORK_DIR
    cd $WORK_DIR

    # start the experiments in parallel
    BIAS=0.79 START_SEED=1 END_SEED=1000 DAMAGE_MODULE=$DAMAGE_MODULE nohup ./start_pt_experiment.sh &

    cd $ROOT_DIR
done

wait
