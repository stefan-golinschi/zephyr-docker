# Getting docker image
```
docker pull marshallc/zephyr-project
```

# Docker build
```
docker build -t zephyr-dev .
```

# Docker run
```
HOSTNAME="zephyr"
docker run \
--rm \
-it \
--hostname=${HOSTNAME} \
${HOSTNAME}-dev
```

## Get boards list
```
west boards
```

## Build a sample app
```
west build -b <board_name> samples/hello_world
```

## Menuconfig
```
west build -t menuconfig
```

