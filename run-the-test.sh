rm -rf client server && \
  nix-shell --run '{
    export CONFIG_PATH=../config.json

    echo "Building Client..."
    nix-build --arg isJS true -o client --fallback --builders "" &
    C=$!

    echo "Building Server..."
    nix-build --arg isJS false -o server --fallback --builders "" &
    S=$!

    wait $C $S
    echo "Running Server with Client..."
    ./server/bin/server
  }'

