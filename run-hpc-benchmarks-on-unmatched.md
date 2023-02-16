
## RAJA性能套件（RAJAPerf）

RAJA 性能套件旨在探索 HPC 应用中基于循环的计算内核的性能。具体而言，它可用于评估和监控使用 RAJA C++ 性能可移植性抽象实现的内核的运行时性能，并将其与直接使用常见并行编程模型（例如 OpenMP 和 CUDA）实现的变体进行比较。

- 内核是一种独特的基于循环的计算，以多种变体（或实现）形式出现在套件中，每个变体执行相同的计算。
- 变体是套件中内核的一个实现或一组实现，它们共享相同的方法/抽象和编程模型，例如基线 OpenMP、RAJA OpenMP 等。
- 调优是套件中内核变体的特定实现，例如 gpu 块大小 128、gpu 块大小 256 等。
- Group 是 Suite 中内核的集合，因为它们来自相同的源，例如特定的基准测试套件，所以它们被组合在一起。 

#### 构建RAJAPerf

**构建串行程序**
```
$ git clone --recursive https://github.com/llnl/RAJAPerf.git
$ cd RAJAPerf
$ mkdir my-build
$ cd my-build
$ cmake ../
$ make
```
注：在unmatched上执行`make -j`会出现c++ fatal error，可能是因为多线程编译内存不足。

**构建OpenMP并行程序**

```
$ cmake -DENABLE_OPENMP=on ../
$ make
```

#### 运行RAJAPerf

```
./bin/raja-perf.exe 
```

结果文件：

RAJAPerf-timing-Average.csv
![屏幕截图_20230213_165359](https://user-images.githubusercontent.com/26591790/219258565-a762a9b1-5edd-49b6-8b22-fa4068a29b31.png)

RAJAPerf-speedup-Average.csv
![屏幕截图_20230213_165717](https://user-images.githubusercontent.com/26591790/219258635-eb1a604d-7c0e-43f3-939d-d4b6aeb09046.png)

RAJAPerf-kernels.csv
![屏幕截图_20230213_165833](https://user-images.githubusercontent.com/26591790/219258650-2d197319-5da4-4461-a3e5-e7df9983bcdd.png)

RAJAPerf-fom.csv
![屏幕截图_20230213_170035](https://user-images.githubusercontent.com/26591790/219258793-8d27759c-6f29-4453-a39b-536cd7ea1d9f.png)


整理数据，我们可以看到各kernel串行和并行运行的速度差异，以及使用RAJA库对性能的影响。大多数kernel并行性能是串行的3.5-4倍之间，这是因为unmatched处理器是4核心的。

![屏幕截图_20230215_204449](https://user-images.githubusercontent.com/26591790/219258934-2d8819d2-636e-4f1c-b5ff-ae39190fa996.png)

![屏幕截图_20230215_210120](https://user-images.githubusercontent.com/26591790/219258966-4e3aed8c-b9f0-43cb-ba27-f5c10979e80d.png)

![屏幕截图_20230215_210732](https://user-images.githubusercontent.com/26591790/219258975-e46295d6-4d18-4454-8a9c-bcf02533d378.png)

![屏幕截图_20230215_211258](https://user-images.githubusercontent.com/26591790/219258985-a6fd9be3-682f-40f1-857a-81dccd2e41b0.png)

![屏幕截图_20230215_211535](https://user-images.githubusercontent.com/26591790/219258997-69d00074-8046-4da4-9df4-e9c6809813fa.png)

![屏幕截图_20230215_212406](https://user-images.githubusercontent.com/26591790/219259031-334d105d-f743-4a4a-8abd-fd68c8051da0.png)

#### 使用MPI运行

TBD

## ExCALIBUR

ExCALIBUR测试套件中包含的Benchmark实际是BabelStream。BabelStream 是一个基准测试，用于测量读写容量内存的内存传输速率。 与其他内存带宽基准测试不同，它不包括连接设备的任何 PCIe 传输时间。与基于CPU的STREAM基准类似。

理想情况下，不同的编程模型不应该限制设备可达到的最优性能，目前BabelStream支持的编程模型有：OpenCL, CUDA, OpenACC, OpenMP 3 and 4.5, Kokkos, RAJA, SYCL。

这里我们仅测试了采用OpenMP的内存传输速率。在Unmatched上测试需要将CMakeLists.txxt中的`-march`修改为rv64gc:

修改47行：
```
set(DEFAULT_RELEASE_FLAGS -O3 -march=native)
```
改为：
```
set(DEFAULT_RELEASE_FLAGS -O3 -march=rv64gc)
```

构建和运行的命令：
```
$ git clone https://github.com/UoB-HPC/BabelStream.git
$ cd BabelStream
$ cmake -Bbuild -H. -DMODEL=omp
$ cmake --build build
$ ./build/omp-stream
```

运行结果：

![屏幕截图_20230203_110336](https://user-images.githubusercontent.com/26591790/219259204-ac5eab37-3410-4977-809e-037c082abe8f.png)

## sombrero

sombrero是一个基于晶格场理论应用（lattice field theory applications）的高性能计算基准实用程序。需要用到MPI库和MPI编译器。

构建和运行

1. 安装mpich
```
$ sudo apt install mpich
```

2. 下载sombrero源码
```
$ git clone https://github.com/sa2c/sombrero.git
$ cd sombrero
```

3. 去掉`Make/MkFlags`中最后两行的注释，指定MPICC
```
# -*- makefile -*-

override CFLAGS += -std=c99

#Compiler
# Set these variables either here or in the environment. See
# https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html
# If you are using Spack, leave these commented out
# (Spack will manage them when building)
 MPICC = mpicc
 LDFLAGS =
```

4. 最后执行make
```
$ make
```

5. run benchmarks
```
./sombrero.sh -n 2 -s small
```

结果：
![屏幕截图_20230206_103445](https://user-images.githubusercontent.com/26591790/219259529-f2ee8262-80ef-48b2-96e2-ad52544bf456.png)
![屏幕截图_20230206_103532](https://user-images.githubusercontent.com/26591790/219259538-3e8c2491-896f-40fa-8d95-3e8a0f2ae256.png)


## HPGMG

TBD

