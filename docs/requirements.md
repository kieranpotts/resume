# Requirements

The only requirements are:

* Make
* Docker
* A LaTeX editor

The compilation scripts run in a Docker container, so you do not need to install
any LaTeX packages on your host system. The Docker image is based on my own
[Docker image](https://hub.docker.com/r/kieranpotts/latex), which is in turn
inspired by Benedikt Lang's [blang/latex](https://github.com/blang/latex-docker/)
images.

On Windows, it is RECOMMENDED to configure Docker to use WSL 2, and then run the
build commands from WSL in a terminal running under administrator mode. Linux
emulators like Git Bash are NOT sufficient.

The script to start the container will run the container under the current user
and group. You should add your user to the `docker` group, which will allow you
to run Docker commands without needing to use `sudo`.

```sh
sudo usermod -aG docker [your-username]
```

Finally, make sure that each of the `run/*` scripts are executable:

```sh
chmod +x run/*
```
