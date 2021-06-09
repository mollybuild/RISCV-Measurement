# 嵌入式Benchmark在D1开发板上运行

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


## 参考资料

1. https://lowrisc.org/docs/tagged-memory-v0.1/spike/
2. https://riscv.org/wp-content/uploads/2015/01/riscv-software-stack-bootcamp-jan2015.pdf
