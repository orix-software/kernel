# ch395-lib

## Documentation

https://orix-software.github.io/ch395lib/api/

## Repository

## Dependencies

ca65 syntax

If you set a mac address maybe will refuse to attribute a mac address

## Informations complémentaires sur le chip

* Même quand le cable est déconnecté, il est possible de lire le buffer quand on a déjà récupéré de la data.
* Quand le cable est débranché, l'ip est persistante dans la stack. En revanche, les serveurs DNS fournis par le dhcp smeblent être eux resettés quand le cable est débranché.
* Quand on teste le cable, il est toujours déconnecté après l'initialisation de la stack. Il faut faire une boucle avec des compteurs sur le get_phy_status pour vraiment détecter si oui on non le cable est débranché
* Il ne faut pas fermer une socket quand la connexion TCP est toujours en established. Il faut attendre le disconnect TCP (et bien tcp, et non pas le statut de la socket en SUCCESS) avant d'envoyer l'ordre de stop de la socket
