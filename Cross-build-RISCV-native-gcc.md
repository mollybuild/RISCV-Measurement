### 在x86/linux64上交叉编译RISCV native gcc

以下步骤是在x86/linux64上进行的，交叉编译一个RISCV native gcc。在交叉编译之前，你的x86/linux64机器上应该有riscv的交叉工具链（如果没有，请先构建riscv-gnu-toolchain）。

注意x86上用于交叉编译的工具链glic版本要和D1开发板上的glibc版本一致。

这里的步骤目前适用于编译riscv-gcc项目，整个riscv-gnu-toolchain项目还没有尝试。

0. 安装依赖软件：

```shell
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
```

1. 需要将riscv交叉工具链的bin添加到PATH中。

```shell
export PATH="$HOME/opt/rv64_linux/bin:$PATH"
```

2. 安装gmp,mpfr,mpc

不执行这一步，可能会报错:
```shell
configure: error: Building GCC requires GMP 4.2+, MPFR 3.1.0+ and MPC 0.8.0+.
```
需要执行下面的安装命令：
```shell
$ cd riscv-gnu-toolchain/riscv-gcc
$ contrib/download_prerequisites
```

3. 在riscv-gnu-toolchain/riscv-gcc下新建build目录，再进行configure/make/make install。

*整个riscv-gnu-toolchain不知道目前是否支持交叉编译riscv native工具*

```shell
$ cd riscv-gnu-toolchain/riscv-gcc

$ mkdir build-native && cd build-native

$ ../configure --with-host=riscv64-unknown-linux-gnu --target=riscv64-unknown-linux-gnu --host=riscv64-unknown-linux-gnu --enable-languages=c,c++ --enable-tls --enable-shared --prefix=$HOME/RISCV64/native

$ make -j $nproc

$ make install
```

编译中可能遇到找不到riscv64-unknown-linux-gnu-cc的问题：
```shell
riscv-gnu-toolchain/riscv-gcc/libgcc/configure: line 2739: riscv64-unknown-linux-gnu-cc: command not found
```
解决的办法是在你的riscv cross compiler的安装目录下新建一个cc的软链接指向gcc：
```shell
$ cd $HOME/opt/rv64_linux/bin

$ ln -snf $HOME/opt/rv64_linux/bin/riscv64-unknown-linux-gnu-gcc $HOME/opt/rv64_linux/bin/riscv64-unknown-linux-gnu-cc
```

将install目录$HOME/RISCV64/native打包拷贝到D1上，又遇到glibc版本不一致的问题，所以这里要注意x86上用于交叉编译的工具链glic版本要和D1开发板上的glibc版本一致。

4. 将编译好的gcc binary拷贝到D1开发板上，做一些验证

编译完成之后，把$HOME/RISCV64/native打包拷贝到D1上，在D1开发板的native/bin目录下执行`./gcc -v`，看到gcc的版本，则gcc可以运行。
现在试着用gcc进行编译，编译一个fibo.c文件。报错如下：

```shell
$ gcc fibo.c -o fibo.out
In file included from fibo.c:1
/usr/include/stdio.h:10 fatal error: bits/libc-header-start.h: No such file or directory
   27 | #include <bits/libc-header-start.h>
```

试着把riscv gnu toolchain编译好的sysroot拷到D1上，编译的时候指定sysroot，编译成功：

```shell
$ gcc --sysroot=/home/cxo/RISCV64/native/sysroot fibo.c -o fibo.out
$ ./fibo.out
How many terms to outputs: 5
Fibonacci sequence: 0, 1, 1, 2, 3,
```
