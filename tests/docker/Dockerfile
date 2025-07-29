# Utilise une image de base, par exemple Ubuntu
FROM ubuntu:latest

# Installe Git
RUN apt-get update && apt-get install -y git pip python3 python3.12-venv

# Clone un dépôt Git
#COPY ../../ /kernel
RUN git clone https://github.com/orix-software/kernel.git -b develop

# Définit le répertoire de travail
WORKDIR /kernel

RUN git clone https://github.com/orix-software/bpm

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
#RUN python3 -m venv mon_env  
#RUN source mon_env/bin/activate
RUN ls -l

RUN cd bpm && pip install -r requirements.txt && cd ..
RUN mkdir ~/bin
RUN cp bpm/src/bpm ~/bin
RUN chmod 755 ~/bin/bpm 
ENV PATH=$PATH:~/bin
# RUN echo $PATH
RUN echo "#!/bin/bash\nbpm --force-update --replace-for-new-project" > initscript.sh
#RUN echo "cd src/kernel8 && bpm update cd ../../" >> initscript.sh
# Commande par défaut à exécuter lorsque le conteneur démarre

# Rendez le script exécutable
RUN chmod +x initscript.sh
# Exécutez le script au démarrage du conteneur
#ENTRYPOINT  ["/kernel/initscript.sh"]

CMD ["echo", "Le dépôt Git a été clonné avec succès."]