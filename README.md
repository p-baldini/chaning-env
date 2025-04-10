# Experiments Graceful Degradation 2

This repository contains the code used in the second article about the graceful degradation and performance recovery thanks to online adaptation in robots subject to damages.

The repository is organized as follows:
- `exp` contains the docker-compose files to run the two experiments
- `gym` contains the argos3 arenas of the two experiments
- `shl` contains the scripts that start the experiments in the docker container
- `src` contains the Lua code of the robot controllers

Finally, the Docker file is used to build the experiment image that will be pushed to a public repository:

```
docker build --network=host --tag quay.io/p-baldini/experiment_2025-03-28:1.0.1 .
docker push quay.io/p-baldini/experiment_2025-03-28:1.0.1
```
