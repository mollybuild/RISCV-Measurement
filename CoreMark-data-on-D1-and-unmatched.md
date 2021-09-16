## 步骤

将coremarkv1.0拷贝到被测机器上，在coremark_v1.0目录下新建rv64目录，将linux64/下的文件拷贝到rv64目录下，做相应的修改。

### 在D1/oE上测试

oE系统信息：
```
# uname -a 
Linux openEuler-RISCV-rare 5.4.61 #20 SMP Thu Aug 26 11:50:01 CST 2021 riscv64 riscv64 riscv64 GNU/Linux
```

```
$ cd coremark_v1.0
$ make clean
$ make XCFLAGS="-DMULTITHREAD=4 -DUSE_FORK" ITERATIONS=150000 PORT_DIR=rv64
```

结果如下：

run1.log
```
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 268183
Total time (secs): 268.183000
Iterations/Sec   : 2237.278276
Iterations       : 600000
Compiler version : GCC9.3.1
Compiler flags   : -O2 -DMULTITHREAD=4 -DUSE_FORK -DPERFORMANCE_RUN=1  -lrt
Parallel Fork : 4
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[1]crclist       : 0xe714
[2]crclist       : 0xe714
[3]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[1]crcmatrix     : 0x1fd7
[2]crcmatrix     : 0x1fd7
[3]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[1]crcstate      : 0x8e3a
[2]crcstate      : 0x8e3a
[3]crcstate      : 0x8e3a
[0]crcfinal      : 0x25b5
[1]crcfinal      : 0x25b5
[2]crcfinal      : 0x25b5
[3]crcfinal      : 0x25b5
Correct operation validated. See readme.txt for run and reporting rules.
CoreMark 1.0 : 2237.278276 / GCC9.3.1 -O2 -DMULTITHREAD=4 -DUSE_FORK -DPERFORMANCE_RUN=1  -lrt / Heap / 4:Fork
```

run2.log
```
2K validation run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 269008
Total time (secs): 269.008000
Iterations/Sec   : 2230.416939
Iterations       : 600000
Compiler version : GCC9.3.1
Compiler flags   : -O2 -DMULTITHREAD=4 -DUSE_FORK -DPERFORMANCE_RUN=1  -lrt
Parallel Fork : 4
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0x18f2
[0]crclist       : 0xe3c1
[1]crclist       : 0xe3c1
[2]crclist       : 0xe3c1
[3]crclist       : 0xe3c1
[0]crcmatrix     : 0x0747
[1]crcmatrix     : 0x0747
[2]crcmatrix     : 0x0747
[3]crcmatrix     : 0x0747
[0]crcstate      : 0x8d84
[1]crcstate      : 0x8d84
[2]crcstate      : 0x8d84
[3]crcstate      : 0x8d84
[0]crcfinal      : 0x6225
[1]crcfinal      : 0x6225
[2]crcfinal      : 0x6225
[3]crcfinal      : 0x6225
Correct operation validated. See readme.txt for run and reporting rules.
```

D1只有一个物理核心：
```
# cat /proc/cpuinfo 
processor	: 0
hart		: 0
isa		: rv64imafdcvu
mmu		: sv39
```

又测了一下单线程：

```
$ make clean
$ make ITERATIONS=150000 PORT_DIR=rv64
```

结果如下：

run1.log
```
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 66586
Total time (secs): 66.586000
Iterations/Sec   : 2252.725798
Iterations       : 150000
Compiler version : GCC9.3.1
Compiler flags   : -O2 -DPERFORMANCE_RUN=1  -lrt
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x25b5
Correct operation validated. See readme.txt for run and reporting rules.
CoreMark 1.0 : 2252.725798 / GCC9.3.1 -O2 -DPERFORMANCE_RUN=1  -lrt / Heap
```

run2.log
```
2K validation run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 66905
Total time (secs): 66.905000
Iterations/Sec   : 2241.984904
Iterations       : 150000
Compiler version : GCC9.3.1
Compiler flags   : -O2 -DPERFORMANCE_RUN=1  -lrt
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0x18f2
[0]crclist       : 0xe3c1
[0]crcmatrix     : 0x0747
[0]crcstate      : 0x8d84
[0]crcfinal      : 0x6225
Correct operation validated. See readme.txt for run and reporting rules.
```


### 在Hifive unmatched上测试

unmatched的系统信息：

```
$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 21.04
Release:        21.04
Codename:       hirsute
```

在unmatched上执行：

```
$ cd coremark_v1.0
$ make clean
$ make XCFLAGS="-DMULTITHREAD=4 -DUSE_FORK" ITERATIONS=150000 PORT_DIR=rv64
```

结果如下：

run1.log:
```
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 48530
Total time (secs): 48.530000
Iterations/Sec   : 12363.486503
Iterations       : 600000
Compiler version : GCC10.3.0
Compiler flags   : -O2 -DMULTITHREAD=4 -DUSE_FORK -DPERFORMANCE_RUN=1  -lrt
Parallel Fork : 4
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[1]crclist       : 0xe714
[2]crclist       : 0xe714
[3]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[1]crcmatrix     : 0x1fd7
[2]crcmatrix     : 0x1fd7
[3]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[1]crcstate      : 0x8e3a
[2]crcstate      : 0x8e3a
[3]crcstate      : 0x8e3a
[0]crcfinal      : 0x25b5
[1]crcfinal      : 0x25b5
[2]crcfinal      : 0x25b5
[3]crcfinal      : 0x25b5
Correct operation validated. See readme.txt for run and reporting rules.
CoreMark 1.0 : 12363.486503 / GCC10.3.0 -O2 -DMULTITHREAD=4 -DUSE_FORK -DPERFORMANCE_RUN=1  -lrt / Heap / 4:Fork
```

run2.log：
```
2K validation run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 48595
Total time (secs): 48.595000
Iterations/Sec   : 12346.949275
Iterations       : 600000
Compiler version : GCC10.3.0
Compiler flags   : -O2 -DMULTITHREAD=4 -DUSE_FORK -DPERFORMANCE_RUN=1  -lrt
Parallel Fork : 4
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0x18f2
[0]crclist       : 0xe3c1
[1]crclist       : 0xe3c1
[2]crclist       : 0xe3c1
[3]crclist       : 0xe3c1
[0]crcmatrix     : 0x0747
[1]crcmatrix     : 0x0747
[2]crcmatrix     : 0x0747
[3]crcmatrix     : 0x0747
[0]crcstate      : 0x8d84
[1]crcstate      : 0x8d84
[2]crcstate      : 0x8d84
[3]crcstate      : 0x8d84
[0]crcfinal      : 0x6225
[1]crcfinal      : 0x6225
[2]crcfinal      : 0x6225
[3]crcfinal      : 0x6225
Correct operation validated. See readme.txt for run and reporting rules.
```
