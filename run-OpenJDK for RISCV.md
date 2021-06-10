## OpenJDK for RISCV目前的构建和回归测试过程重现一遍

#### 参考资料
构建测试可以参考：

https://github.com/openjdk-riscv/jdk11u

http://openjdk.java.net/jtreg/

https://github.com/azul-research/jdk-riscv/issues/5

https://zhuanlan.zhihu.com/p/344502147

openjdk 回归测试框架jtreg:

http://openjdk.java.net/jtreg/


bash configure \
    --with-jvm-variants=minimal \
    --disable-warnings-as-errors \
    --openjdk-target=riscv64-unknown-linux-gnu \
    --with-sysroot=/opt/riscv/sysroot \
    --x-includes=/opt/riscv/sysroot/usr/include \
    --x-libraries=/opt/riscv/sysroot/usr/lib --enable-headless-only
    
    https://zhuanlan.zhihu.com/p/344502147

```shell
bash configure --openjdk-target=riscv32-unknown-linux-gnu --disable-warnings-as-errors --with-sysroot=$HOME/RISCV32/sysroot --x-includes=$HOME/RISCV32/sysroot/usr/include --x-libraries=$HOME/RISCV32/sysroot/usr/lib --with-boot-jdk=$HOME/repos/jdk-10 --with-native-debug-symbols=none --with-jvm-variants=zero --with-jvm-interpreter=cpp --prefix=$PWD/nodebug_32
```

#### 遇到的问题

1，需要5.4以上的kernel。而docker容器的kernel是不能升级的，因为和宿主机共享kernel。

#### 完成状态

1，根据wiki的文档，完成了openjdk for rv32的构建；

2，写了自动构建的脚本：
/home/chenxiaoou/my-script/buildOpenJDK

3，回归测试不知道怎么做，因为是在x86的机器上构建，构建的是rv32的jdk，看了文档，还没有找到可用的配置。


### build jdk for x86

```
bash ../configure --with-boot-jdk=$HOME/repos/jdk-10 --prefix=$HOME/repos/jdk11u/x86 --disable-warnings-as-errors --with-jtreg=/usr/share/jtreg
```

make && make install

make run-test-tier1

```
==============================
Test summary
==============================
   TEST                                              TOTAL  PASS  FAIL ERROR
>> jtreg:test/hotspot/jtreg:tier1                     1355  1249     0   106 <<
>> jtreg:test/jdk:tier1                               1865  1837     3    25 <<
>> jtreg:test/langtools:tier1                         3911  3898     1    12 <<
   jtreg:test/nashorn:tier1                              0     0     0     0
   jtreg:test/jaxp:tier1                                 0     0     0     0
==============================
TEST FAILURE

make[1]: *** [/home/cxo/repos/jdk11u/make/Init.gmk:309: main] Error 1
make: *** [/home/cxo/repos/jdk11u/make/Init.gmk:186: run-test-tier1] Error 2

```

### 参考

[How to cross compile OpenJDK for Arm32?](http://mail.openjdk.java.net/pipermail/zero-dev/2014-December/000538.html)

