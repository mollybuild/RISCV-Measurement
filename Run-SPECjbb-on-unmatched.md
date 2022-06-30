本文记录了SPECjbb在Unmatched开发板上运行的过程，用来测试JDK for rv64的性能情况。涉及到从源码构建JDK，以及在unmatched上运行SPECjbb等步骤。

## 一、从源码构建OpenJDK

交叉编译OpenJDK for rv64的步骤参考：https://zhuanlan.zhihu.com/p/265628548

主要步骤包括：1，安装依赖的软件包；2，获取源码；3，下载bootJDK；4，执行configure和make进行交叉编译

1，安装依赖的软件包

其中第一步安装依赖包有两种方式，一是通过挂在fedora文件系统，二是通过脚本来安装。
分别参考[https://zhuanlan.zhihu.com/p/386123758](https://note.youdao.com/)和[https://zhuanlan.zhihu.com/p/386123758](https://note.youdao.com/)

2，获取源码

Upstream源码地址：https://github.com/openjdk/jdk

```
git clone https://github.com/openjdk/jdk.git
```

3，下载bootJDK

第三步，编译JDK需要自举，要编译大版本号为N的JDK，需要首先有一个大版本号至少为N-1的JDK作为bootJDK。在这里我要编译的是目前OpenJDK upstream主线正在开发的19版本，采用的bootJDK是reviewer个人构建的OpenJDK19。下载地址：[https://builds.shipilev.net/openjdk-jdk-riscv/](https://note.youdao.com/)（该网站算是半官方的nightly build，官方wiki有提到：https://wiki.openjdk.java.net/display/RISCVPort）。

选择版本时，注意glibc的版本需要和运行JDK的目标平台的glibc版本相兼容。

4，执行configure & make

```
$ bash configure --openjdk-target=riscv64-unknown-linux-gnu \
--disable-warnings-as-errors \
--with-sysroot=/home/cxo/temp/riscv/sysroot \
--with-boot-jdk=/home/cxo/jdk \
--with-native-debug-symbols=none

$ make JOBS=$(nproc) && make images
```

其中`--with-native-debug-symbols=<method>`指定是否及如何编译debug symbols。可选的方法有none、internal、external、zipped。none表示在构建过程中不生成debug symbols。

`--with-debug-level`设置debug级别，可选级别有release, fastdebug, slowdebug和optimized。默认是release。试验发现fastdebug和slowdebug级别的JDK在运行SPECjbb时，都会出现`PR is under limit`的问题，可能表明Java服务器端处理请求的能力不足。需要使用release级别，SPECjbb composite可以运行起来。

Debug各级别的说明：
```
# Set the debug level
#    release: no debug information, all optimizations, no asserts.
#    optimized: no debug information, all optimizations, no asserts, HotSpot target is 'optimized'.
#    fastdebug: debug information (-g), all optimizations, all asserts
#    slowdebug: debug information (-g), no optimizations, all asserts
```

这里我使用的GNU Toolchain GCC的版本是10.2.0

JDK构建完成之后，将build/linux-riscv64-server-release/images/jdk打包拷贝到Unmatched上。


## 二、运行SPECjbb2015

1，解压SPECjbb2015

```
$ mkdir mnt
$ sudo mount -o loop cpu2006_install.tar.gz mnt/
$ mkdir jbb2015
$ cd mnt && cp -r * jbb2015
$ sudo umount mnt
```

2，运行SPECjbb2015

#### composite

- jbb2015 command：
```
$ /home/chenxiaoou/jdk/bin/java -Xms3g -Xmx3g -jar specjbb2015.jar -m composite
```

结果：
```
Report directory is result/specjbb2015-C-20220610-00001/report-00001
RUN RESULT: hbIR (max attempted) = 307, hbIR (settled) = 273, max-jOPS = 359, critical-jOPS = 0
```

- jbb2015 command:
```
/home/chenxiaoou/jdk-release/bin/java -Xms6g -Xmx6g -jar specjbb2015.jar -m composite
```

结果：
```
Report directory is result/specjbb2015-C-20220615-00001/report-00001
RUN RESULT: hbIR (max attempted) = 556, hbIR (settled) = 522, max-jOPS = 484, critical-jOPS = 63
```

- Java option = -server -Xms6g -Xmx6g

结果：
```
Report directory is result/specjbb2015-C-20220617-00001/report-00001
RUN RESULT: hbIR (max attempted) = 556, hbIR (settled) = 522, max-jOPS = 395, critical-jOPS = 61
```

#### multiJVM

- Java Option1:
```
JAVA_OPTS_C="-Xms2g -Xmx2g"
JAVA_OPTS_TI="-Xms2g -Xmx2g"
JAVA_OPTS_BE="-Xms2g -Xmx2g"
```

结果：
```
Report directory is result/specjbb2015-M-20220617-00001/report-00001
RUN RESULT: hbIR (max attempted) = 320, hbIR (settled) = 220, max-jOPS = 218, critical-jOPS = 0
```

- Java Option2:
```
JAVA_OPTS_C="-Xms2g -Xmx2g"
JAVA_OPTS_TI="-Xms2g -Xmx2g"
JAVA_OPTS_BE="-Xms6g -Xmx6g"
```

结果：
```
Report directory is result/specjbb2015-M-20220620-00001/report-00001
RUN RESULT: hbIR (max attempted) = 451, hbIR (settled) = 427, max-jOPS = 347, critical-jOPS = 0
```

- Java Option3:
```
JAVA_OPTS_C="-Xms2g -Xmx2g"
JAVA_OPTS_TI="-Xms2g -Xmx2g"
JAVA_OPTS_BE="-Xms8g -Xmx8g"
```

结果：
```
Report directory is result/specjbb2015-M-20220620-00001/report-00001
RUN RESULT: hbIR (max attempted) = 451, hbIR (settled) = 427, max-jOPS = 437, critical-jOPS = 0
```

#### Distributed

- 1 Group with 1 TxI/Backend

set both on Driver and SUT:

```
specjbb.group.count=1
specjbb.controller.host=<ControllerIP>
```

on Driver:

```
java -jar specjbb2015.jar -m distcontroller
java -jar specjbb2015.jar -m txinjector -G GRP1 -J JVM2
```

on SUT:

```
java -jar specjbb2015.jar -m backend -G GRP1 -J JVM2
```

result:

on unmathced015 
```
Report directory is result/specjbb2015-D-20220628-00001/report-00001
RUN RESULT: hbIR (max attempted) = 417, hbIR (settled) = 388, max-jOPS = 384, critical-jOPS = 0
```

- 1 Group with 1 TxI/Backend + set heap size

run_distributed_ctrl_txI.sh:
```
JAVA_OPTS_C="-Xms2g -Xmx2g"
JAVA_OPTS_TI="-Xms2g -Xmx2g"
```

run_distributed_sut.sh:
```
JAVA_OPTS_BE="-Xms12g -Xmx12g"
```

结果：
```
Report directory is result/specjbb2015-D-20220630-00001/report-00001
RUN RESULT: hbIR (max attempted) = 451, hbIR (settled) = 427, max-jOPS = 388, critical-jOPS = 29
```
