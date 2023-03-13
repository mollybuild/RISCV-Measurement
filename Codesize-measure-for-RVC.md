## RISC-V压缩指令扩展

RISC-V标准压缩指令扩展，命令为C扩展，通过为常用操作增加16位指令编码来减少静态和动态代码大小。 C扩展可以被添加到任何一个基础ISA（RV32、RV64、RV128）中，我们使用通用术语 "RVC "来指代其中的任何一个。 通常，一个程序中50%-60%的RISC-V指令可以用RVC指令代替，从而使代码大小减少25%-30%。C扩展包含Zca，Zcd，Zcf。（参：RISC-V Specifications）

RISC-V还有另一组压缩指令扩展————Zce，主要是为了运行在微控制器中，包含Zca, Zcb, Zcmp, Zcmt，如果有f扩展的话，还包含Zcf。目前（2023.3）Zce扩展还未ratified。

我们将分别测试两类压缩指令对代码体积的影响，然后再测试组合两种指令的效果。

## 准备交叉编译环境

### riscv gnu toolchain


#### GC扩展

源码：https://github.com/riscv-collab/riscv-gnu-toolchain

commit ID：

risc-gnu-toolchian f0b0094

binutils @ b2bc62b

gcc @ 2ee5e43

glibc @ a704fd9

newlib @ 415fdd4

Date:   Fri Feb 24 16:12:28 2023 +0800

build rv64gc:
```
$ ./configure --prefix=$HOME/opt/riscv64gc --with-arch=rv64gc --with-abi=lp64d
$ make linux -j 52
$ make install
```

build rv32gc:
```
./configure --prefix=$HOME/opt/riscv32gc --with-arch=rv32gc --with-abi=ilp32d
```

#### GCZce扩展

gcc和binutils仓库需要切换到Openhw

```
$ cd riscv-gcc
$ git remote add openhw https://github.com/openhwgroup/corev-gcc.git
$ git fetch openhw
$ git checkout openhw/development

$ cd ../riscv-binutils
$ git remote add openhw https://github.com/openhwgroup/corev-binutils-gdb.git
$ git fetch openhw
$ git checkout openhw/development

$ ./configure --prefix=$HOME/opt/riscv64gcZce --with-arch=rv64gczcazcbzcfzcmpzcmt --with-abi=lp64d
$ make linux -j52
```

如果在`git fetch`时报错`GnuTLS recv error (-110): The TLS connection was non-properly terminated.`，可进行如下设置
```
apt install gnutls-bin
git config --global http.sslverify false
git config --global http.postbuffer 1048576000
```

目前Zce扩展构建有点问题，Zce正在重构，等待upstream。

### LLVM

源码：https://github.com/llvm/llvm-project

commit ID : 0d94b63

Date:   Tue Feb 28 15:20:46 2023 +0000

LLVM在构建时不需特别指定32位或64位，也不需要特别指定指令扩展，`DLLVM_TARGETS_TO_BUILD`中指定`RISCV`就包含所有的扩展

具体支持的扩展参见代码：

https://github.com/llvm/llvm-project/blob/main/llvm/lib/Support/RISCVISAInfo.cpp

和文档：

https://github.com/llvm/llvm-project/blob/main/llvm/docs/RISCVUsage.rst#riscv-scalar-crypto-note2

```
cd `llvm project`
mkdir build
cd build
cmake -DLLVM_PARALLEL_LINK_JOBS=3 -DLLVM_TARGETS_TO_BUILD="X86;RISCV" -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_INSTALL_PREFIX=$HOME/opt/rv64gc_llvm -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
make -j4
make install
```

## 准备Benchmark

这里我们用CSiBE来测试代码体积。CSiBE是专门测试编译器生成二进制代码体积的Benchmark。

#### 下载Benchmark Csibe：

```
$ git clone https://github.com/szeged/csibe.git
```

#### 运行Csibe：

```
$ cd csibe && mkdir gcc-rv64
$ ./csibe.py --build-dir=gcc-rv64/ --toolchain gcc-riscv64-g CSiBE-v2.1.1
```
其中gcc-rv64是build目录，result也将在这个目录中。gcc-riscv64-g对应我们的gcc-riscv64-g.cmake文件。另外需要指定CSiBE-v2.1.1分支，如果不指定的话，会报下面的错误，提示CMSIS不支持在目标CPU上编译。

![image](https://user-images.githubusercontent.com/26591790/224637944-59aa88ef-9ef8-4aef-b193-feab7afc41e9.png)

#### Cmake文件

需要写我们自己的cmake文件来编译csibe，cmake文件在toolchain-files目录下，我们可以参考已经有的模板来写。我们的配置如下：

GCC的Cmake文件：
```
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR RISCV64)

set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)

set(TOOLCHAIN_PATH $HOME/opt/riscv64gc)
set(CMAKE_SYSROOT $HOME/opt/riscv64gc/sysroot)

set(CMAKE_C_COMPILER ${TOOLCHAIN_PATH}/bin/riscv64-unknown-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH}/bin/riscv64-unknown-linux-gnu-g++)

set(RISCV64_FLAGS "-Os -march=rv64g -D__GLIBC_HAVE_LONG_LONG")
set(CMAKE_C_FLAGS "${RISCV64_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${RISCV64_FLAGS}" CACHE STRING "" FORCE)
```

-Os是追求代码体积的优化选项，它包含O2的所有选项，除了那些会增加代码体积的优化，另外开启了`-finline-functions`，为了缩减代码体积。

注意需要在编译参数中加上`-D__GLIBC_HAVE_LONG_LONG`，不然会报下面的错误：

![image](https://user-images.githubusercontent.com/26591790/224638072-cfdf80ce-75a1-4820-b470-601892e0d9ea.png)

`-march`参数分别指定为`rv64g`,`rv64gc`,`rv64gczcazcbzcfzcmpzcmt`,`rv64gzcazcbzcfzcmpzcmt`。

rv32类似。

LLVM的Cmake文件：
```
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR RISCV64)

set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)

set(triple riscv64-unknown-linux-gnu)

set(TOOLCHAIN_PATH $HOME/opt/rv64gc_llvm)
set(CMAKE_SYSROOT $HOME/opt/riscv64gc/sysroot)

set(CMAKE_C_COMPILER ${TOOLCHAIN_PATH}/bin/clang)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH}/bin/clang++)

set(RISCV64_FLAGS "--target=${triple} -Os -march=rv64g -Wno-implicit-function-declaration -Wno-implicit-int -D__GLIBC_HAVE_LONG_LONG")
set(CMAKE_C_FLAGS "${RISCV64_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "${RISCV64_FLAGS}" CACHE STRING "" FORCE)
```

`-march`参数分别指定为`rv64`,`rv64gc`,`rv64gc_zca1p0_zcb1p0_zcd1p0_zcf1p0`,`rv64g_zca1p0_zcb1p0_zcd1p0_zcf1p0`。其中指定Zce扩展的时候还需加上`-menable-experimental-extensions`，因为Zce扩展目前（2023.3）还没有ratified。（参见：https://riscv.org/technical/specifications/）

rv32类似。

## 结果分析

Csibe的结果文件大概是这样的，列出了每个程序所包含的obj文件以及对应的大小。

![image](https://user-images.githubusercontent.com/26591790/224638307-3af4b785-37b1-4261-9a66-916dda472619.png)

我们计算csibe所有obj文件大小的平均值，以此用于Codesize的比较，标准化后的结果如下：

RV64 code size的对比：

![屏幕截图 2023-03-13 154248](https://user-images.githubusercontent.com/26591790/224638613-f92f03e6-106e-4963-acd9-893c5d9ad0fa.png)

RV64在不打开压缩指令的情况下，GCC的代码体积就比LLVM要小3%；无论是GCC还是LLVM，C扩展大概可以减少17%的代码体积。LLVM gcZce比gc优化不到0.5%，打开Zce之后，开不开c的效果是一样的。RVC指令理想情况是带来20-30%的代码压缩，这里的测试是接近20%。

RV32 code size的对比：

![屏幕截图 2023-03-13 154211](https://user-images.githubusercontent.com/26591790/224638682-ef58deba-d761-4d4f-a070-a11713d2eabc.png)
