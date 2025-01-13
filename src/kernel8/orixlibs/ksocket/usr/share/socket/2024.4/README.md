# Socket lib

## Documentation

## Repository

## Dependencies

## behavior

Each calls to connect will allocate source port from 170 to 170 + $FF. Each time a connect is performed, source port = source port ++

Because when we connect to same host, we are trying to connect to same source port from Orix and the remote computer won't accept a connexion from a source port when connection is still closing.

