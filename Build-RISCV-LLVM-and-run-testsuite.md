# 构建RISCV LLVM，并运行test-suite

## 构建 RISCV LLVM

**源码地址：**

https://github.com/isrc-cas/rvv-llvm

**Prerequiriste:**

```shell
$ sudo apt update

$ sudo apt install cmake ninja-build
```

**构建的命令如下：**

```shell
$ git clone https://github.com/isrc-cas/rvv-llvm.git

$ cd `llvm project`

$ mkdir build && cd build

## 链接过程硬盘空间可能不足，请指定DLLVM_PARALLEL_LINK_JOBS限制并行ld数量。

$ cmake -DLLVM_PARALLEL_LINK_JOBS=3 -DLLVM_TARGETS_TO_BUILD="X86;RISCV" -DLLVM_ENABLE_PROJECTS="clang" -G Ninja ../llvm

$ ninja

$ ninja check
```

这个构建没有指定安装目录，可执行程序在build/bin中。

## 运行LLVM test-suite

**1. 编译test-suite，参考官方文档：**

https://llvm.org/docs/TestSuiteGuide.html

**注意事项：**
- 要先build llvm，再把test-suite拷到llvm/projects下面，再重新configure和build，不然会报错说找不到llvm-size工具；

- 可能需要安装`tcl, tk, tcl-dev, tk-dev`，缺少这些包在cmake时报如下错误：

```shell
-- Could NOT find TCL (missing: TCL_INCLUDE_PATH)
-- Could NOT find TCLTK (missing: TCL_INCLUDE_PATH TK_INCLUDE_PATH)
-- Could NOT find TK (missing: TK_INCLUDE_PATH)
```

- 链接阶段可能报PIE的错误，报错如下：

```shell
/usr/bin/ld: CMakeFiles/Dither.dir/orderedDitherKernel.c.o: relocation R_X86_64_32S against `.rodata' can not be used when making a PIE object; recompile with -fPIE
/usr/bin/ld: CMakeFiles/Dither.dir/__/utils/glibc_compat_rand.c.o: relocation R_X86_64_32S against `.bss' can not be used when making a PIE object; recompile with -fPIE
collect2: error: ld returned 1 exit status
make[2]: *** [MicroBenchmarks/ImageProcessing/Dither/CMakeFiles/Dither.dir/build.make:146: MicroBenchmarks/ImageProcessing/Dither/Dither] Error 1
make[1]: *** [CMakeFiles/Makefile2:14633: MicroBenchmarks/ImageProcessing/Dither/CMakeFiles/Dither.dir/all] Error 2
make: *** [Makefile:130: all] Error 2
```
解决方法是在文件中修改：

CMAKE_C_FLAGS:STRING = -fPIE

CMAKE_CXX_FLAGS:STRING = fPIE

- 可能遇到speedtest.tcl权限问题，报错如下：

```shell
[ 26%] Generating sqlite test inputs
/bin/sh: 1: /home/cxo/repo/llvm-project/llvm/projects/llvm-test-suite/MultiSource/Applications/sqlite3/speedtest.tcl: Permission denied
make[2]: *** [MultiSource/Applications/sqlite3/CMakeFiles/sqlite_input.dir/build.make:58：MultiSource/Applications/sqlite3/test15.sql] 错误 126
make[1]: *** [CMakeFiles/Makefile2:29299：MultiSource/Applications/sqlite3/CMakeFiles/sqlite_input.dir/all] 错误 2
make: *** [Makefile:130：all] 错误 2
```

给speedtest.tcl加上可执行权限（chmod +x 就可以了）。

- XRay可能编译不过，就先注释掉吧

报错如下：

```shell
Scanning dependencies of target retref-bench
[ 37%] Building CXX object MicroBenchmarks/XRay/ReturnReference/CMakeFiles/retref-bench.dir/retref-bench.cc.o
/home/removed/release/test-suite/MicroBenchmarks/XRay/ReturnReference/retref-bench.cc:18:10: fatal error:
      'xray/xray_interface.h' file not found
#include "xray/xray_interface.h"
         ^~~~~~~~~~~~~~~~~~~~~~~
1 error generated.
make[2]: *** [MicroBenchmarks/XRay/ReturnReference/CMakeFiles/retref-bench.dir/build.make:63: MicroBenchmarks/XRay/ReturnReference/CMakeFiles/retref-bench.dir/retref-bench.cc.o] Error 1
make[1]: *** [CMakeFiles/Makefile2:19890: MicroBenchmarks/XRay/ReturnReference/CMakeFiles/retref-bench.dir/all] Error 2
make: *** [Makefile:130: all] Error 2
```

MicroBenchmarks/CMakeLists.txt 中注释掉add_subdirectory(XRay)

**2. 运行llvm test-suite**

Command:

```shell
# run test
$ llvm-lit -v -j 1 -o results.json .

# Make sure pandas and scipy are installed. Prepend `sudo` if necessary.
$ pip install pandas scipy

# Show a single result file:
$ test-suite/utils/compare.py results.json
```

我这里查看结果如下:

```shell
cxo@be42fa9ca89b:~/repo/llvm-project/llvm/projects/llvm-test-suite/llvm-test-build$ ../utils/compare.py results.json
Warning: 'test-suite :: MicroBenchmarks/XRay/FDRMode/fdrmode-bench.test' has no metrics, skipping!
Warning: 'test-suite :: MicroBenchmarks/XRay/ReturnReference/retref-bench.test' has no metrics, skipping!
Warning: 'test-suite :: SingleSource/UnitTests/Vector/AVX512F/Vector-AVX512F-reduce.test' has no metrics, skipping!
Tests: 2882
Metric: exec_time

Program                                        results
LCALS/Subs...aw.test:BM_MAT_X_MAT_RAW/44217   230781.79
LCALS/Subs...test:BM_MAT_X_MAT_LAMBDA/44217   229731.13
ImageProce...t:BENCHMARK_GAUSSIAN_BLUR/1024    77005.87
harris/har...est:BENCHMARK_HARRIS/2048/2048    38352.47
ImageProce...HMARK_ANISTROPIC_DIFFUSION/256    30532.07
ImageProce...MARK_BICUBIC_INTERPOLATION/256    21323.56
ImageProce...st:BENCHMARK_GAUSSIAN_BLUR/512    18230.56
LCALS/Subs....test:BM_MAT_X_MAT_LAMBDA/5001    10144.18
harris/har...est:BENCHMARK_HARRIS/1024/1024    10035.18
LCALS/Subs...Raw.test:BM_MAT_X_MAT_RAW/5001     8981.66
ImageProce...HMARK_ANISTROPIC_DIFFUSION/128     7359.81
ImageProce...MARK_BICUBIC_INTERPOLATION/128     5186.29
ImageProce...st:BENCHMARK_GAUSSIAN_BLUR/256     4502.60
ImageProce...ARK_BILINEAR_INTERPOLATION/256     4033.49
ImageProce...t:BENCHMARK_boxBlurKernel/1024     3788.60
             results
count  2866.000000
mean   311.559959
std    6350.988758
min    0.000000
25%    0.000400
50%    0.000500
75%    0.004400
max    230781.792333
```

## 交叉编译RISCV的llvm test-suite

**1. 在clang_riscv_linux.cmake中配置工具链信息。**

配置文件目录 rvv-llvm/llvm/projects/llvm-test-suite-main/your-build-dir/clang_riscv_linux.cmake

```shell
root@e7299bcbf9e1:~/chenxiaoou/rvv-llvm/llvm/projects/llvm-test-suite-main/riscv-build# cat clang_riscv_linux.cmake
set(CMAKE_SYSTEM_NAME Linux )
set(triple riscv64-unknown-linux-gnu )
set(CMAKE_C_COMPILER /root/chenxiaoou/rvv-llvm/build/bin/clang CACHE STRING "" FORCE)
set(CMAKE_C_COMPILER_TARGET ${triple} CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER /root/chenxiaoou/rvv-llvm/build/bin/clang++ CACHE STRING "" FORCE)
set(CMAKE_CXX_COMPILER_TARGET ${triple} CACHE STRING "" FORCE)
set(CMAKE_SYSROOT /root/riscv/linux/sysroot )
set(CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN  /root/riscv/linux/)
set(CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN  /root/riscv/linux/)
```
*我尝试用gnu toolchain newlib编译不能通过，用linux lib是可以的*


**2. cmake和make**

```shell
$ cmake -DCMAKE_TOOLCHAIN_FILE=/root/chenxiaoou/rvv-llvm/llvm/projects/llvm-test-suite-main/riscv-build/clang_riscv_linux.cmake  -DCMAKE_C_COMPILER="/root/chenxiaoou/rvv-llvm/build/bin/clang"  ../

$ make
```

可能有报错如下：

- 找不到crt1.o

```shell
riscv64-unknown-linux-gnu/bin/ld: cannot find crt1.o: No such file or directory
```

那么注意看一下CMAKE_SYSROOT指定的目录中是否有crt1.o

- matrix-types-spec编译不过

build下面的程序可能有问题，会卡住：
SingleSource/UnitTests/CMakeFiles/matrix-types-spec.dir/matrix-types-spec.cpp.o

解决的办法就是暂时不要它，通过修改SingleSource/UnitTests/CMakeFiles/CMakeLists.txt:

```
# Enable matrix types extension tests for compilers supporting -fenable-matrix.
check_c_compiler_flag(-fenable-matrix COMPILER_HAS_MATRIX_FLAG)
if (COMPILER_HAS_MATRIX_FLAG)
  set_property(SOURCE matrix-types-spec.cpp PROPERTY COMPILE_FLAGS -fenable-matrix)
else()
  list(REMOVE_ITEM Source matrix-types-spec.cpp)
endif()
++ # Hack for testing riscv.
++  list(REMOVE_ITEM Source matrix-types-spec.cpp)
```

**3. 在模拟器上运行交叉编译的test-suite**

- 需要安装dtc

```shell
apt-get install device-tree-compiler
```

- ld加上选项-static

在CMakeCache.txt中修改下面的配置项

```shell
//Flags used by the linker during all build types.
CMAKE_EXE_LINKER_FLAGS:STRING= -static
```


- 手动运动单个测试用例

```shell
root@e7299bcbf9e1:~/chenxiaoou/rvv-llvm/llvm/projects/llvm-test-suite-main/riscv-build/SingleSource/Benchmarks/Linpack# spike --isa=RV64gc /root/bin/riscv64-unknown-linux-gnu/bin/pk functionobjects
```
注意pk需要是linux/gnu版本的。

有一些可以成功的运行，有一些测试程序需要用到动态链接库的，就会出错。

我试了一下这个程序是可以正确执行的：
SingleSource/Benchmarks/BenchmarkGame/fannkuch

仿真的命令是：

```shell
spike --isa=RV64gc /root/bin/riscv64-unknown-linux-gnu/bin/pk fannkuch > fannkuch.result 2>&1
```

对比参考输出，程序的输出正常。












