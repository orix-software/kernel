J'ai fait un programme de test qui se contente de créer un répertoire
puis d'ouvrir un fichier et d'y écrire quelque chose si l'ouverture du
fichier est ok.

Une remarque pour info, il y a une différence entre Oricutron et la
réalité quand un fait un mkdir alors que le répertoire existe déjà. Avec
Oricutron on récupère un code $43 "fichier existant", en réel on
récupère un code $14 "success" dans tous les cas.


J'ai un souci avec fopen, l'ouverture d'un fichier après un mkdir
revient toujours avec A=X=$FF et donc une erreur d'ouverture, si
j'enlève le mkdir alors tout se passe bien.

J'ai vérifié en réel et j'ai exactement le même comportement.