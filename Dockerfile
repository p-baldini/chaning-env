FROM        pbaldini/argos3:beta48
WORKDIR     /home

COPY        gym/*       /home
COPY        lib/*       /home
COPY        shl/*       /home
COPY        src/*       /home
