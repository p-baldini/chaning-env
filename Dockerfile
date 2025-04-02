FROM        pbaldini/argos3:beta48
WORKDIR     /home

COPY        gym/*       /home
COPY        src/*       /home
COPY        exp/*.sh    /home
