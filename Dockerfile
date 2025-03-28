FROM        pbaldini/argos3:beta48
WORKDIR     /home

COPY        exp/* /home
COPY        src/* /home
COPY        start_pt_experiment.sh /home
COPY        start_ca_experiment.sh /home
