## 步骤

将之前在x86上已经编译好的coremark v1.0拷贝到D1/oE上，执行:

### 在D1/oE上测试

oE系统信息：
```
# uname -a 
Linux openEuler-RISCV-rare 5.4.61 #20 SMP Thu Aug 26 11:50:01 CST 2021 riscv64 riscv64 riscv64 GNU/Linux
```

```
$ cd coremark_v1.0
$ make XCFLAGS="-DMULTITHREAD=4 -DUSE_FORK" ITERATIONS=150000
```

结果如下：

run1.log
```
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 64114
Total time (secs): 64.114000
Iterations/Sec   : 2339.582618
Iterations       : 150000
Compiler version : GCC10.2.0
Compiler flags   : -O2   -lrt
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x25b5
Correct operation validated. See readme.txt for run and reporting rules.
CoreMark 1.0 : 2339.582618 / GCC10.2.0 -O2   -lrt / Heap
```

run2.log
```
K validation run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 63989
Total time (secs): 63.989000
Iterations/Sec   : 2344.152901
Iterations       : 150000
Compiler version : GCC10.2.0
Compiler flags   : -O2   -lrt
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
$ make XCFLAGS="-DMULTITHREAD=4 -DUSE_FORK" ITERATIONS=150000 PORT_DIR=rv64
```

结果如下：

run1.log:
```
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 44810
Total time (secs): 44.810000
Iterations/Sec   : 3347.467083
Iterations       : 150000
Compiler version : GCC10.2.0
Compiler flags   : -O2   -lrt
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x25b5
Correct operation validated. See readme.txt for run and reporting rules.
CoreMark 1.0 : 3347.467083 / GCC10.2.0 -O2   -lrt / Heap
```

run2.log：
```
2K validation run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 44962
Total time (secs): 44.962000
Iterations/Sec   : 3336.150527
Iterations       : 150000
Compiler version : GCC10.2.0
Compiler flags   : -O2   -lrt
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0x18f2
[0]crclist       : 0xe3c1
[0]crcmatrix     : 0x0747
[0]crcstate      : 0x8d84
[0]crcfinal      : 0x6225
Correct operation validated. See readme.txt for run and reporting rules.
```
