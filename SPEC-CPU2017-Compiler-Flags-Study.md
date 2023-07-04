# SPEC CPU2017调优之编译器优化选项

SPEC CPU2017测试套件被用于评估CPU、内存和编译器所组成的子系统性能。因此选择开启哪些编译选项是CPU2017调优的重要部分。我们参考了目前SPEC官网发布的所有测试结果，将它们所用到的编译器优化选项进行统计并排序，能够看到哪些优化选项是最常被用到、对性能影响最显著。

下图列出了部分编译选项的统计结果，左列数字代表这个选项在所有SPEC官网发布报告中出现的次数，完整的列表参见：

https://github.com/mollybuild/RISCV-Measurement/blob/master/scripts/getflags/speccpu_flags_sort.xlsx

GCC：

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/017b8ec4-259f-4148-a259-2eeba6b90846)

AOCC：


![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/f7d97b55-d2ae-4df3-ad20-fc37556ad728)

ICC：

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/cf7b3b2f-c32a-4af2-ae32-43bd11120e70)

AOCC是基于LLVM针对AMD芯片做了优化的编译器，可以在AMD官网上免费下载，有很多选项都是AOCC特有而Clang没有。Intel ICC是付费的，针对Intel CPU优化，在向量化、并行化上优于GCC，对Intel CPU的跑分ICC也明显更高。

从SPEC官网报告中摘出的这些选项，我们这里仅看GCC/Clang通用的几个，因为目前我们工作主要在RISCV芯片上，就暂时忽略AOCC和ICC特有的优化选项啦。我们大概要看一遍的选项有下列这些：

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/ee19fab8-b314-4486-a53c-d4d218da9c1d)

### -funroll-loops

GCC文档上的介绍：

```
Unroll loops whose number of iterations can be determined at compile time or upon entry to the loop. -funroll-loops implies -frerun-cse-after-loop, -fweb and -frename-registers. It also turns on complete loop peeling (i.e. complete removal of loops with a small constant number of iterations). This option makes code larger, and may or may not make it run faster.
```

循环展开：当循环次数确定，可将循环进行展开。但循环次数较小时，可完全展开。这个参数将产生更大的代码体积，是否运行更快不确定。

这个选项不包含在O3中，SPEC CPU跑Base一般使用O3优化级别，这个选项需要单独开启。

这个选项GCC和Clang都有的。

### -flto

-flto是GCC和Clang都有的优化选项，下面以GCC为例介绍。

这个选项开启标准的链接时优化（link time optimization）。当运用于源码时，它将产生GIMPLE代码并将它写入目标文件的特殊ELF section中。当这些目标代码链接时，从这些特殊的ELF段中读取所有的函数体并将它们实例化，如同在同一个翻译单元中。

该选项应同时应用于编译时和最终链接时。推荐所有参与链接的文件采用相同的编译选项，并且在链接时也使用这些选项。例如：

```
gcc -c -O2 -flto foo.c
gcc -c -O2 -flto bar.c
gcc -o myprog -flto -O2 foo.o bar.o
```

GCC 的前两次调用将 GIMPLE 的字节码表示保存在 foo.o 和 bar.o 中的特殊 ELF 部分。最后一次调用从 foo.o 和 bar.o 中读取 GIMPLE 的字节码，将两个文件合并成一个内部映像，并像往常一样编译结果。由于foo.o和bar.o都被合并成一个镜像，这使得GCC中所有的程序间分析和优化都在这两个文件中进行，就像它们是一个单独的文件一样。例如，这意味着inliner能够将bar.o中的函数内联到foo.o中的函数，反之亦然。

另一种更简单的方式是：

```
gcc -o myprog -flto -O2 foo.c bar.c
```

开启-flto编译时间会比较长，编译消耗更多内存。GCC O3优化没有默认开启-flto，需要单独开启。通过实际测试SPEC CPU，发现单独开启-flto对跑分没有太大的影响，需要结合PGO（profile-guided optimization）优化一起，可使整体跑分得到提升。但PGO优化只能在peak中使用。

在x86上使用GCC测试LTO+PGC带来的性能buff，结果如下图，对不同的benchmark影响不同，有的benchmark能获得超过30%的性能提升，例如511.povray_r，但也有部分benchmark性能反而下降了，多个benchmark下降超过20%，其中548.exchange2_r下降最多，降幅25%。但从整体来看，除了fpspeed，其它三个metric均提升了4-5%。

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/564c6c99-b9ec-403b-90ac-fa0e94633b88)

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/39bb4571-abd1-44c8-91f3-bfa63dce3f8d)

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/208ef28c-e96c-4798-a781-f5228d0809d3)

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/ca67acad-8c92-416f-ab5d-72a348ba0c72)


### -ffinite-loops

###  -fomit-frame-pointer

### -z muldefs

GCC文档上的介绍：

```
Allows links to proceed even if there are multiple definitions of some symbols. This switch may resolve duplicate symbol errors, as noted in the [502.gcc_r benchmark description](http://www.spec.org/cpu2017/Docs/benchmarks/502.gcc_r.html#inline).
```

这个是链接器的选项，ld有此选项，lld没有。这不是一个优化选项，而是处理链接时符号多重定义的问题，该选项指定链接器不报错，而是以第一个遇到的定义为准。

### -ffast-math

-ffast-math针对浮点运算，只要在Ofast中开启。这个选项为了提高速度，会启用一些不太安全的数学优化，带来数学计算的精度损失，特别是在使用复杂的数学函数时。因此，建议只在对计算精度要求不高的情况下使用该选项。

具体来说，它可以执行以下优化：

1. 忽略浮点数的严格规范，例如对 NaN 和 Inf 的处理，以及舍入误差的处理。
2. 允许将浮点数的运算顺序进行重排，以加速程序的执行。
3. 允许使用快速的数学函数实现，例如使用平方根的近似算法，这可以在一定程度上提高程序的执行速度。

包括一组选项： -fno-math-errno, -funsafe-math-optimizations, -ffinite-math-only, -fno-rounding-math, -fno-signaling-nans, -fcx-limited-range, -fexcess-precision=fast

Clang的描述：

```
-ffast-math, -fno-fast-math
Allow aggressive, lossy floating-point optimizations
```

GCC的描述：

```
Sets the options -fno-math-errno, -funsafe-math-optimizations, -ffinite-math-only, -fno-rounding-math, -fno-signaling-nans, -fcx-limited-range and -fexcess-precision=fast.

This option causes the preprocessor macro __FAST_MATH__ to be defined.

This option is not turned on by any -O option besides -Ofast since it can result in incorrect output for programs that depend on an exact implementation of IEEE or ISO rules/specifications for math functions. It may, however, yield faster code for programs that do not require the guarantees of these specifications.
```

-ffast-math我们也在x86上使用GCC测试了性能buff，可以看到它对int型benchmark没有帮助，整体分数反而有些下降，因为它本身是针对浮点运算的优化，fpspeed和fprate分别由6.67%和8.04%的性能提升。详细的分数见下图第三列：

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/967168e2-69f7-4dfb-9550-8a960024f601)

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/214dd47b-50fb-4e94-9549-5abfb8b7012d)

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/d2140a19-a9f2-44ed-af72-f8e64f1f10d8)

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/d434b2ca-efa1-4214-919c-5add21f6dfa8)

### -ljemalloc

jemalloc是一个通用的malloc(3)实现，它的优势是避免内存碎片化和支持可扩展的并发。在2005年作为FreeBSD的libc分配器投入使用，在2010年jemalloc的开发工作扩大到包括开发者支持功能，诸如堆分析和广泛的监控/调整hooks。jemalloc目前已经可以在riscv上成功编译了。jemalloc GitHub地址：https://github.com/jemalloc/jemalloc/tree/dev，使用下面的命令下载源码和安装：

```
$ git clone https://gitee.com/mirrors/jemalloc.git
$ cd jemalloc
$ ./autogen.sh
$ make
$ make install
```

可以使用`make uninstall`来卸载。

我们用一个简单的程序来测试jemalloc在x86和riscv上的性能，该程序执行简单的内存申请、写入、释放操作，代码如下：

```
/*
 * wenfh2020.com / 2020-07-30
 * g++ -std='c++11' -g test_jemalloc.cpp -o tjemalloc && ./tjemalloc
 * g++ -std='c++11' -g test_jemalloc.cpp -o tjemalloc -DUSE_JEMALLOC -ljemalloc && ./tjemalloc
*/

#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

#include <iostream>

#ifdef USE_JEMALLOC
#include <jemalloc/jemalloc.h>
#endif

#define MALLOC_CNT 10000000

long long mstime() {
    long long mst;
    struct timeval tv;
    gettimeofday(&tv, NULL);
    mst = ((long long)tv.tv_sec) * 1000;
    mst += tv.tv_usec / 1000;
    return mst;
}

int main() {
    srand((unsigned)time(NULL));
    long long begin = mstime();
    for (int i = 0; i < MALLOC_CNT; i++) {
        int size = rand() % 1024 + 1024*4;
        char* p = (char*)malloc(size);   
        memset(p, rand() % 128, size);
        free(p);
    }
    long long end = mstime();

    std::cout << "begin: " << begin << std::endl
              << "end:   " << end << std::endl
              << "val:   " << end - begin << std::endl;
    return 0;
}
```

(源码来自：https://github.com/wenfh2020/c_test/blob/master/memory/jemalloc/test_jemalloc.cpp)

测试结果如下：

|         machine         | w/o jemalloc time (ms) | w/ jemalloc time (ms) |
| :---------------------: | :--------------------: | :-------------------: |
|           x86           |          1503          |         1124          |
| riscv64 (visionfive v1) |          5466          |         6558          |

对于这个简单程序，在RV平台上，jemalloc对内存操作没有提升，反而耗时更久；而在x86上jemalloc带来了25%的速度提升。jemalloc实际对RV平台上SPEC CPU2017的影响还有待测试。

### -mllvm -enable-gvn-hoist

llvm的参数，GCC没有这个参数，GCC有-fhoist-adjacent-loads，-fira-hoist-pressure，-fcode-hoisting这三个参数，应该和-fcode-hoisting的功能相似，GCC默认在O2及以上开启。

功能是将那些在所有分支路径上都存在的运算表达式提到分支前，这个优化主要有利于优化代码体积，通常对代码速度也是有帮助的。优化示例如下：

![image](https://github.com/mollybuild/RISCV-Measurement/assets/26591790/5a9231ac-5bb7-450b-8194-f7a4d74525ca)

### -fopenmp

### -fvirtual-function-elimination

### -fvisibility=hidden

### -lmvec

### -Wl,-allow-multiple-definition

### -lpthread

### -ldl

