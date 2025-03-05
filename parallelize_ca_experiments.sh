ROOT_DIR=$(pwd)

# spread 1000 replicas among 10 different cores
for I in $(seq 0 333 666)
do
    # calculate the seed range that the core should manage
    SSEED=$I
    ESEED=$(($I + 332))

    # set up the experiment directory
    WORK_DIR=$(date +"%Y-%m-%d")_experiment/ca/$SSEED-$ESEED
    mkdir -p                    $WORK_DIR
    cp src/*                    $WORK_DIR
    cp exp/*                    $WORK_DIR
    cp start_ca_experiment.sh   $WORK_DIR
    cd $WORK_DIR

    # start the experiments in parallel
    BIAS=0.79 START_SEED=$SSEED END_SEED=$ESEED DAMAGE_MODULE="dmg_act_slowed"       nohup ./start_ca_experiment.sh &
    BIAS=0.79 START_SEED=$SSEED END_SEED=$ESEED DAMAGE_MODULE="dmg_sns_disconnected" nohup ./start_ca_experiment.sh &
    BIAS=0.79 START_SEED=$SSEED END_SEED=$ESEED DAMAGE_MODULE="dmg_sns_fixed"        nohup ./start_ca_experiment.sh &
    BIAS=0.79 START_SEED=$SSEED END_SEED=$ESEED DAMAGE_MODULE="dmg_sns_random"       nohup ./start_ca_experiment.sh &

    cd $ROOT_DIR
done

wait
