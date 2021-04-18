### Embench的设计

#### Embench简介

嵌入式、物联网系统的Benchmark。现状是还没有高质量被广泛报道的嵌入式benchmark。嵌入式系统的特点：没有OS，最小C库支持，没有输出流。benchmark需要适应这些特点。

属于FOSSi基金会的项目。免费开源benchmark。脱胎于Bristol/Embecosm Embedded Benchmark Suite.

目前最新是1.0版本。

嵌入式系统benchmark需要关注的两个metric：性能，代码大小（menmory寸土寸金）


19个真实程序组成的套件：

- aha-mont64
Montgomery乘法，是公钥算法实现中的一个核心算法，其主要作用是为模乘运算加速。

- crc32
- cubic
- edn
- huffbench
- matmult-int
- minver
- nbody
- nettle-aes
- nettle-aes
- nettle-sha256
- nsichneu
- picojpeg
- qrduino
- sglib-combined
- sire
- st
- statemate
- ud
- wikisort

运行结束将产生一个分数，用来评估平台和编译链的性能。

#### Embench运行


#### 编译运行脚本(交叉编译）

在x86 host下编译Embench：

```shell
sudo apt install python3

sudo ln -snf /usr/bin/python3 /usr/bin/python

sudo apt install python3-pip

pip3 install pyelftools

./build_all.py --builddir build --arch riscv32 --chip generic --board ri5cyverilator --cc /home/cxo/opt/rv32/bin/riscv32-unknown-elf-gcc --cflags="-O2 -ffunction-sections -march=rv32gc" --ldflags="-O2 -W -march=rv32gc" --cc-output-pattern="-c"

```

注意设置--cc-output-pattern，不然会报错，说找不到main函数。

$HOME/RISCV32/qemu/bin/qemu-riscv32 -L $HOME/RISCV32/sysroot/ ./RV32上的可执行文件

#### 在Qemu模拟器上跑Embench并输出报告

目前Embench仅支持riscv32，还不支持riscv64，因此我们需要在Qemu上运行RISCV32 Linux。
参考https://zhuanlan.zhihu.com/p/342188138

其中遇到了一些问题：

- bitbake: command not found
解决方法： source  openembedded-core/oe-init-build-env

- Your system needs to support the en_US.UTF-8 locale.

解决方法：
```shell
sudo apt install locales
sudo dpkg-reconfigure locales
```

- 运行```MACHINE=qemuriscv32 runqemu nographic```
报错
```
runqemu - ERROR - TUN control device /dev/net/tun is unavailable; you may need to enable TUN (e.g. sudo modprobe tun)
```
当执行```sudo modprobe tun```后报告

```
modprobe: FATAL: Module tun not found in directory /lib/modules/4.15.0-124-generic
```


#### 参考资料

1. https://github.com/embench
2. https://risc-v-getting-started-guide.readthedocs.io/en/latest/linux-qemu.html#
3. https://wiki.qemu.org/Documentation/Platforms/RISCV
4. https://qemu.readthedocs.io/en/latest/system/target-riscv.html
5. https://www.embench.org/
