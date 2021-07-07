## Benchmark

Embench, Dhrystone, fpmark, linpack, whetstone, coremark

## 过程记录

#### Embench
Embench目前只支持rv32，不支持rv64。目前Embench多在RISCV的模拟器环境下运行，其他经验还有待拓展。（2020.10.9号的报告中提到）

参考：https://www.youtube.com/watch?v=xX0krFFvlUM

#### Dhrystone

Dhrystone源码从下面的链接获得，按照文件头几行的提示获得源码文件，最终得到的是
```
Rationale
dhry.h
dhry_1.c
dhry_2.c
```
http://groups.google.com/group/comp.arch/browse_thread/thread/b285e89dfc1881d3/068aac05d4042d54?lnk=gst&q=dhrystone+2.1#068aac05d4042d54

现在我们要编译在D1 linux上运行的binary，因此我们的工具链要使用GNU/Linux版本的。编译的命令如下：
```shell
riscv64-unknown-linux-gnu-gcc -c -O2 -fno-inline dhry_1.c
riscv64-unknown-linux-gnu-gcc -c -O2 -fno-inline dhry_2.c
riscv64-unknown-linux-gnu-gcc -o dhrystone dhry_1.o dhry_2.o
```

但是我在编译dhry_1.c时就报错了：

```shell
dhry_1.c:31:14: warning: conflicting types for built-in function 'malloc'; expected 'void *(long unsigned int)' [-Wbuiltin-declaration-mismatch]
   31 | extern char *malloc ();
      |              ^~~~~~
dhry_1.c:19:1: note: 'malloc' is declared in header '<stdlib.h>'
   18 | #include "dhry.h"
  +++ |+#include <stdlib.h>
   19 |
dhry_1.c:48:12: error: conflicting types for 'times'
   48 | extern int times ();
      |            ^~~~~
In file included from dhry.h:371,
                 from dhry_1.c:18:
/home/cxo/opt/rv64_linux/sysroot/usr/include/sys/times.h:46:16: note: previous declaration of 'times' was here
   46 | extern clock_t times (struct tms *__buffer) __THROW;
      |                ^~~~~
dhry_1.c:73:1: warning: return type defaults to 'int' [-Wimplicit-int]
   73 | main ()
      | ^~~~
dhry_1.c: In function 'main':
dhry_1.c:98:2: warning: implicit declaration of function 'strcpy' [-Wimplicit-function-declaration]
   98 |  strcpy (Ptr_Glob->variant.var_1.Str_Comp,
      |  ^~~~~~
dhry_1.c:98:2: warning: incompatible implicit declaration of built-in function 'strcpy'
dhry_1.c:19:1: note: include '<string.h>' or provide a declaration of 'strcpy'
   18 | #include "dhry.h"
  +++ |+#include <string.h>
   19 |
dhry_1.c:149:2: warning: implicit declaration of function 'Proc_5' [-Wimplicit-function-declaration]
  149 |  Proc_5();
      |  ^~~~~~
dhry_1.c:150:2: warning: implicit declaration of function 'Proc_4' [-Wimplicit-function-declaration]
  150 |  Proc_4();
      |  ^~~~~~
dhry_1.c:156:16: warning: implicit declaration of function 'Func_2'; did you mean 'Func_1'? [-Wimplicit-function-declaration]
  156 |  Bool_Glob = ! Func_2 (Str_1_Loc, Str_2_Loc);
      |                ^~~~~~
      |                Func_1
dhry_1.c:162:2: warning: implicit declaration of function 'Proc_7' [-Wimplicit-function-declaration]
  162 |  Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
      |  ^~~~~~
dhry_1.c:167:2: warning: implicit declaration of function 'Proc_8' [-Wimplicit-function-declaration]
  167 |  Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);
      |  ^~~~~~
dhry_1.c:169:2: warning: implicit declaration of function 'Proc_1' [-Wimplicit-function-declaration]
  169 |  Proc_1 (Ptr_Glob);
      |  ^~~~~~
dhry_1.c:176:2: warning: implicit declaration of function 'Proc_6' [-Wimplicit-function-declaration]
  176 |  Proc_6 (Ident_1, &Enum_Loc);
      |  ^~~~~~
dhry_1.c:187:2: warning: implicit declaration of function 'Proc_2' [-Wimplicit-function-declaration]
  187 |  Proc_2 (&Int_1_Loc);
      |  ^~~~~~
dhry_1.c:224:29: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  224 |  printf (" Ptr_Comp: %d\n", (int) Ptr_Glob->Ptr_Comp);
      |                             ^
dhry_1.c:235:29: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
  235 |  printf (" Ptr_Comp: %d\n", (int) Next_Ptr_Glob->Ptr_Comp);
      |                             ^
dhry_1.c:50:27: error: 'HZ' undeclared (first use in this function)
   50 | #define Too_Small_Time (2*HZ)
      |                           ^~
dhry_1.c:262:18: note: in expansion of macro 'Too_Small_Time'
  262 |  if (User_Time < Too_Small_Time)
      |                  ^~~~~~~~~~~~~~
dhry_1.c:50:27: note: each undeclared identifier is reported only once for each function it appears in
   50 | #define Too_Small_Time (2*HZ)
      |                           ^~
dhry_1.c:262:18: note: in expansion of macro 'Too_Small_Time'
  262 |  if (User_Time < Too_Small_Time)
      |                  ^~~~~~~~~~~~~~
dhry_1.c: At top level:
dhry_1.c:290:1: warning: return type defaults to 'int' [-Wimplicit-int]
  290 | Proc_1 (Ptr_Val_Par)
      | ^~~~~~
dhry_1.c: In function 'Proc_1':
dhry_1.c:306:2: warning: implicit declaration of function 'Proc_3'; did you mean 'Proc_1'? [-Wimplicit-function-declaration]
  306 |  Proc_3 (&Next_Record->Ptr_Comp);
      |  ^~~~~~
      |  Proc_1
dhry_1.c: At top level:
dhry_1.c:324:1: warning: return type defaults to 'int' [-Wimplicit-int]
  324 | Proc_2 (Int_Par_Ref)
      | ^~~~~~
dhry_1.c:347:1: warning: return type defaults to 'int' [-Wimplicit-int]
  347 | Proc_3 (Ptr_Ref_Par)
      | ^~~~~~
dhry_1.c:362:1: warning: return type defaults to 'int' [-Wimplicit-int]
  362 | Proc_4 () /* without parameters */
      | ^~~~~~
dhry_1.c:374:1: warning: return type defaults to 'int' [-Wimplicit-int]
  374 | Proc_5 () /* without parameters */
      | ^~~~~~
```

先来研究一下这个error：
```shell
dhry_1.c:48:12: error: conflicting types for 'times'
   48 | extern int times ();
      |            ^~~~~
In file included from dhry.h:371,
                 from dhry_1.c:18:
/home/cxo/opt/rv64_linux/sysroot/usr/include/sys/times.h:46:16: note: previous declaration of 'times' was here
   46 | extern clock_t times (struct tms *__buffer) __THROW;
      |                ^~~~~
```

修改dhry_1.c
```shell
   48 | extern int times ();
```
为
```shell
extern clock_t times();
```

看下一个error:
```shell
dhry_1.c:50:27: error: 'HZ' undeclared (first use in this function)
   50 | #define Too_Small_Time (2*HZ)
      |                           ^~
```

在dhry.h的373行加入：
```
#define HZ 60
```

改完之后，编译没有问题了，虽然有一些warning。

这样就生成了dhrystone可执行文件。

运行dhrystone:

```shell
$ /home/cxo/opt/rv64/bin/qemu-riscv64 ./dhrystone
qemu-riscv64: Could not open '/lib/ld-linux-riscv64-lp64d.so.1': No such file or directory
```
找不到这个动态链接库，那么把sysroot加进入：

```shell
$ /home/cxo/opt/rv64/bin/qemu-riscv64 -L /home/cxo/opt/rv64_linux/sysroot ./dhrystone                               

Dhrystone Benchmark, Version 2.1 (Language: C) 

Program compiled without 'register' attribute

Please give the number of runs through the benchmark: 100000000                                                                                                                                                                 
Execution starts, 100000000 runs through Dhrystone
Execution ends

Final values of the variables used in the benchmark:

Int_Glob: 5
 should be: 5
Bool_Glob: 1
 should be: 1
Ch_1_Glob: A
 should be: A
Ch_2_Glob: B
 should be: B
Arr_1_Glob[8]: 7
 should be: 7
Arr_2_Glob[8][7]: 100000010
 should be: Number_Of_Runs + 10
Ptr_Glob->
 Ptr_Comp: 90784
 should be: (implementation-dependent)
 Discr: 0
 should be: 0
 Enum_Comp: 2
 should be: 2
 Int_Comp: 17
 should be: 17
 Str_Comp: DHRYSTONE PROGRAM, SOME STRING
 should be: DHRYSTONE PROGRAM, SOME STRING
Next_Ptr_Glob->
 Ptr_Comp: 90784
 should be: (implementation-dependent), same as above
 Discr: 0
 should be: 0
 Enum_Comp: 1
 should be: 1
 Int_Comp: 18
 should be: 18
 Str_Comp: DHRYSTONE PROGRAM, SOME STRING
 should be: DHRYSTONE PROGRAM, SOME STRING
Int_1_Loc: 5
 should be: 5
Int_2_Loc: 13
 should be: 13
Int_3_Loc: 7
 should be: 7
Enum_Loc: 1
 should be: 1
Str_1_Loc: DHRYSTONE PROGRAM, 1'ST STRING
 should be: DHRYSTONE PROGRAM, 1'ST STRING
Str_2_Loc: DHRYSTONE PROGRAM, 2'ND STRING
 should be: DHRYSTONE PROGRAM, 2'ND STRING

Microseconds for one run through Dhrystone:    0.4
Dhrystones per Second: 2753556.8
```

接下来，把dhrystone binary拷贝到D1上运行，运行成功，结果如下：

```shell
# ./dhrystone

Dhrystone Benchmark, Version 2.1 (Language: C)

Program compiled without 'register' attribute

Please give the number of runs through the benchmark: 100000000    

Execution starts, 100000000 runs through Dhrystone
Execution ends

Final values of the variables used in the benchmark:

Int_Glob: 5
 should be: 5
Bool_Glob: 1
 should be: 1
Ch_1_Glob: A
 should be: A
Ch_2_Glob: B
 should be: B
Arr_1_Glob[8]: 7
 should be: 7
Arr_2_Glob[8][7]: 100000010
 should be: Number_Of_Runs + 10
Ptr_Glob->
 Ptr_Comp: 392475296
 should be: (implementation-dependent)
 Discr: 0
 should be: 0
 Enum_Comp: 2
 should be: 2
 Int_Comp: 17
 should be: 17
 Str_Comp: DHRYSTONE PROGRAM, SOME STRING
 should be: DHRYSTONE PROGRAM, SOME STRING
Next_Ptr_Glob->
 Ptr_Comp: 392475296
 should be: (implementation-dependent), same as above
 Discr: 0
 should be: 0
 Enum_Comp: 1
 should be: 1
 Int_Comp: 18
 should be: 18
 Str_Comp: DHRYSTONE PROGRAM, SOME STRING
 should be: DHRYSTONE PROGRAM, SOME STRING
Int_1_Loc: 5
 should be: 5
Int_2_Loc: 13
 should be: 13
Int_3_Loc: 7
 should be: 7
Enum_Loc: 1
 should be: 1
Str_1_Loc: DHRYSTONE PROGRAM, 1'ST STRING
 should be: DHRYSTONE PROGRAM, 1'ST STRING
Str_2_Loc: DHRYSTONE PROGRAM, 2'ND STRING
 should be: DHRYSTONE PROGRAM, 2'ND STRING

Microseconds for one run through Dhrystone:    0.7 
Dhrystones per Second: 1464128.9 
```

#### FPMark

##### FPMark简介

###### FPMark 的认证标志 

FPMark 由 8 个评分组成，由 10 个基准内核构建的 55 个工作负载组成。 每个
标记表示工作负载性能子集的几何平均值。表现，或每个工作负载的吞吐量以每秒迭代次数来衡量。 

###### FPMark 基准内核

在x86上运行

```shell
$ make certify-all XCMD='-c4'

WORKLOAD RESULTS TABLE

                                                 MultiCore SingleCore
Workload Name                                     (iter/s)   (iter/s)    Scaling
----------------------------------------------- ---------- ---------- ----------
atan-1M                                              95.24      38.91       2.45
atan-1M-sp                                          158.73      67.57       2.35
atan-1k                                          129870.13   40983.61       3.17
atan-1k-sp                                       158730.16   57803.47       2.75
atan-64k                                           1727.12     726.74       2.38
atan-64k-sp                                        2288.33    1049.32       2.18
blacks-big-n5000v200                                  7.36       2.94       2.50
blacks-big-n5000v200-sp                              11.20       5.32       2.11
blacks-mid-n1000v40                                 227.27      90.09       2.52
blacks-mid-n1000v40-sp                              344.83     117.65       2.93
blacks-sml-n500v20                                  909.09     303.03       3.00
blacks-sml-n500v20-sp                              1250.00     434.78       2.88
horner-big-100k                                     568.18     234.74       2.42
horner-big-100k-sp                                  534.76     206.19       2.59
horner-mid-10k                                     5319.15    2083.33       2.55
horner-mid-10k-sp                                  5586.59    2444.99       2.28
horner-sml-1k                                     55248.62   23364.49       2.36
horner-sml-1k-sp                                  47619.05   19762.85       2.41
inner-product-big-100k                              102.56      50.76       2.02
inner-product-big-100k-sp                           140.85      54.20       2.60
inner-product-mid-10k                               865.80     425.99       2.03
inner-product-mid-10k-sp                           1526.72     642.05       2.38
inner-product-sml-1k                              18181.82    5347.59       3.40
inner-product-sml-1k-sp                           22222.22    6578.95       3.38
linear_alg-big-1000x1000                              0.89       0.92       0.97
linear_alg-big-1000x1000-sp                           1.79       1.15       1.56
linear_alg-mid-100x100                              574.71     196.85       2.92
linear_alg-mid-100x100-sp                           602.41     183.82       3.28
linear_alg-sml-50x50                               3144.65    1381.22       2.28
linear_alg-sml-50x50-sp                            3225.81    1146.79       2.81
loops-all-big-100k                                    0.72       0.52       1.38
loops-all-big-100k-sp                                 1.00       0.56       1.79
loops-all-mid-10k                                    16.04       7.39       2.17
loops-all-mid-10k-sp                                 18.92       7.70       2.46
loops-all-tiny                                     9259.26    3246.75       2.85
loops-all-tiny-sp                                  9090.91    3448.28       2.64
lu-big-2000x2_50                                     13.76       5.93       2.32
lu-big-2000x2_50-sp                                  13.28       6.45       2.06
lu-mid-200x2_50                                    1086.96     464.68       2.34
lu-mid-200x2_50-sp                                 1009.08     473.04       2.13
lu-sml-20x2_50                                    12500.00    5910.17       2.11
lu-sml-20x2_50-sp                                 11185.68    4930.97       2.27
nnet-data1-sp                                     17543.86    4587.16       3.82
nnet_data1                                        12195.12    4424.78       2.76
nnet_test                                            20.96       9.67       2.17
nnet_test-sp                                         17.99       8.87       2.03
radix2-big-64k                                     1366.12     590.32       2.31
radix2-mid-8k                                     23148.15    9132.42       2.53
radix2-sml-2k                                    139664.80   67340.07       2.07
ray-1024x768at24s                                     0.07       0.03       2.33
ray-320x240at8s                                       1.70       0.93       1.83
ray-64x48at4s                                       108.46      48.83       2.22
xp1px-big-c10000n2000                                 1.72       0.76       2.26
xp1px-mid-c1000n200                                 125.00      75.76       1.65
xp1px-sml-c100n20                                 26315.79    8264.46       3.18

MARK RESULTS TABLE

Mark Name                                        MultiCore SingleCore    Scaling
----------------------------------------------- ---------- ---------- ----------
FPMark                                            45317.42   19172.94       2.36
FPv1.0. DP Small Dataset                          10697.02    4060.34       2.63
FPv1.1. DP Medium Dataset                           301.44     133.72       2.25
FPv1.2. DP Big Dataset                               11.95       5.91       2.02
FPv1.3. SP Small Dataset                          13654.36    4821.96       2.83
FPv1.4. SP Medium Dataset                           439.52     180.98       2.43
FPv1.5. SP Big Dataset                               22.78      10.76       2.12
FPv1.D. DP Mark                                     374.91     163.10       2.30
FPv1.S. SP Mark                                     589.95     240.10       2.46
MicroFPMark                                       13654.36    4821.96       2.83
```

##### 在D1上运行FPMark

我们现在要在D1上运行。我尝试将fpmark的源码拷贝到D1，执行`make certify-all`，会卡在ray-1024x768at24s的编译阶段。（系统卡死，只能断电重启）

于是，我就打算在x86上交叉编译fpmark，再在D1上运行。

- 交叉编译

由于D1上的glibc版本是2.31，而最新工具链源码的glibc是2.33，因此要先编译glibc版本低于2.31的工具链，可以参考https://zhuanlan.zhihu.com/p/386123758其中的2.2部分。

```
(这里是个人记录备忘，可直接跳过，看下面)

我按照上面文档构建的时候，遇到下面的问题：

/home/cxo/opt/rv64-linux-glibc2.29/lib/gcc/riscv64-unknown-linux-gnu/10.2.0/../../../../riscv64-unknown-linux-gnu/bin/ld: cannot find -lstdc++
/home/cxo/opt/rv64-linux-glibc2.29/lib/gcc/riscv64-unknown-linux-gnu/10.2.0/../../../../riscv64-unknown-linux-gnu/bin/ld: cannot find -lgcc_s
collect2: error: ld returned 1 exit status

解决的方法是：

有小伙伴说make时不要加-j，我试了，仍然报错。

最后这个问题没解决。
```

也可以直接使用别人已经编译好的工具链。



然后，就可以开始编译fpmark了。步骤如下：

1. 修改util/make/linux64.mak
```shell
ifndef TOOLCHAIN
TOOLCHAIN=gcc-cross-linux
endif
```
2. 修改util/make/gcc-cross-linux.mak

```shell
TOOLS   = /home/cxo/temp/riscv # your riscv gnu toolchain install directory.
TPREF = riscv64-unknown-linux-gnu-
```

3. 编译命令使用

```shell
# cd your fpmark_1.5.3126 directory and run following command:
$ make build
```

然后把整个fpmark_1.5.3126文件夹打包，拷贝到D1上。

- 在D1上运行fpmark

这里有一个比较tricky的地方，因为运行fpmark需要用到size工具，这个是gnu工具链中的一个工具，因为我这里是在x86上交叉编译fpmark的，所以在fpmark构建配置中指定的size工具是/home/cxo/temp/riscv/riscv64-unknown-linux-gnu-size(就是我x86机器上的)。这里我就创建了一个软连接指向本系统上的size工具：

```shell
$ sudo ln -snf /home/cxo/temp/riscv/riscv64-unknown-linux-gnu-size /usr/bin/size
```

```shell
$ make run-all
```


```
(可忽略，继续看后面)

用glibc2.29的工具链编译了fpmark（make build），然后拷贝到D1上运行（make run-all），有一些workloads在D1上还需要重新编译，但是configure中的工具链是x86平台的，就会报错：

blacks-mid-n1000v40

blacks-sml-n500v20

linear_alg-sml-50*50

lu-sml-20*2_50

```

结果存放在 builds/linux64/gcc-cross-linux/logs/linux64.gcc-cross-linux.log

![image](pictures/0707.jpg)

这个结果没有Mark分数，需要Mark分数的过，运行下面的命令：

```shell
$ make certify-all
```


## 参考资料

1. https://lowrisc.org/docs/tagged-memory-v0.1/spike/
2. https://riscv.org/wp-content/uploads/2015/01/riscv-software-stack-bootcamp-jan2015.pdf
