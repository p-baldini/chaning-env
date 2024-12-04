FROM        pbaldini/argos3:beta48
WORKDIR     /home

COPY        exp/* /home
COPY        src/* /home
COPY        start_phototaxis.sh /home
COPY        start_collision_avoidance.sh /home
