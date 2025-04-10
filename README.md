# Experiments Graceful Degradation 2

This repository contains the code used in the second article about the graceful degradation and performance recovery thanks to online adaptation in robots subject to damages.
The start-up of specific instances of the experiment is managed through environmental variables set when starting the docker image.

The repository is organized as follows:
- `exp` contains the docker-compose files to run the two experiments
- `gym` contains the argos3 arenas of the two experiments
- `shl` contains the scripts that start the experiments in the docker container
- `src` contains the Lua code of the robot controllers

Finally, the Docker file is used to build the experiment image that will be pushed to a public repository:

```
docker build --network=host --tag quay.io/p-baldini/experiment_2025-03-28:1.0.2 .
docker push quay.io/p-baldini/experiment_2025-03-28:1.0.2
```

If you want to run or test the docker image locally you can use the following commands:

```
mkdir out
xhost +local:docker
docker run --rm --network=host -e DISPLAY \
    -e BIAS=0.79 \
    -e DAMAGE_MODULE="dmg_act_slowed" \
    -e START_SEED=1 \
    -e END_SEED=2 \
    -e WORK_DIR=out \
    quay.io/p-baldini/experiment_2025-03-28:1.0.1
```
