## 创建docker容器
我们的工作大部分在服务器上进行，老板当然是不会给我们Root权限的，那么怎么自由的安装我所需要的软件呢？那么就需要用到docker了。

1. 创建docker, 并挂载/usr/Downloads到host

```shell
$ docker run -P --expose 80 -v $HOME/dock/Downloads:/usr/Downloads --privileged=true -it --na
me YOUR-DOCKER-NAME ubuntu:20.04 /bin/bash
```

之后连接
```shell
# Attach to the default shell of a running container
docker attach YOUR-DOCKER-NAME

# Access a shell and run custom commands inside a container. Everytime you use this command will create a new bash shell.
docker exec -it YOUR-DOCKER-NAME /bin/bash
```

如果docker容器没有running，那么还需要重启docker容器，在执行上面的连接
```shell
docker restart YOUR-DOCKER-NAME
```

2. 添加docker容器内的用户

docker容器内的root和宿主机的root属于同一个用户，两者的UID均为0。因此虽然在docker容器中，我们还是需要新建普通用户，并使用普通用户来运行程序。
（YOUR-USER-NAME代表你自己的用户名）

```
$ adduser YOUR-USER-NAME
$ su YOUR-USER-NAME
$ cd ~
```

切换回root用户，安装sudo命令，给用户添加sudo权限

```
# apt update
# apt install sudo
```
在/etc/sudoers中添加一行`YOUR-USER-NAME     ALL=(ALL:ALL) ALL`

```
# User privilege specification
root    ALL=(ALL:ALL) ALL
YOUR-USER-NAME     ALL=(ALL:ALL) ALL
```


