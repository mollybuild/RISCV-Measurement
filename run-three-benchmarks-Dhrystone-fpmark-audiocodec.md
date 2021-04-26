## Run three benchmark: Dhrystone, fpmark, audiocodec

### 1. Dhrystone

#### - benchmark下载Ru

1. Dhystone2.1
http://groups.google.com/group/comp.arch/browse_thread/thread/b285e89dfc1881d3/068aac05d4042d54?lnk=gst&q=dhrystone+2.1#068aac05d4042d54

This is a shell archive, meaning:
1. Remove everything above the #! /bin/sh line.
2. Save the resulting text in a file.
3. Execute the file with /bin/sh (not csh) to create:

Rationale, dhry.h, dhry_1.c, dhry_2.c

2. riscv-tests benchmark

https://github.com/riscv/riscv-tests

#### - 编译和运行

1. source1中的dhystone2.1的编译：

参考https://riscv.org/blog/2014/10/about-our-dhrystone-benchmarking-methodology/的编译命令：

```
$ riscv64-unknown-elf-gcc -c -O2 -fno-inline dhry_1.c
$ riscv64-unknown-elf-gcc -c -O2 -fno-inline dhry_2.c
$ riscv64-unknown-elf-gcc -o dhrystone dhry_1.o dhry_2.o
```

会有下面报错：

```
dhry_1.c:32:14: error: conflicting types for 'malloc'
   32 | extern char *malloc ();
      |              ^~~~~~
In file included from dhry_1.c:19:
/home/molly/opt/rv64/riscv64-unknown-elf/include/stdlib.h:108:7: note: previous declaration of 'malloc' was here
  108 | void *malloc(size_t) __malloc_like __result_use_check __alloc_size(1) _NOTHROW;
      |       ^~~~~~
dhry_1.c:49:12: error: conflicting types for 'times'
   49 | extern int times ();
      |            ^~~~~
In file included from dhry.h:371,
                 from dhry_1.c:18:
/home/molly/opt/rv64/riscv64-unknown-elf/include/sys/times.h:24:9: note: previous declaration of 'times' was here
   24 | clock_t times (struct tms *);
      |         ^~~~~

dhry_1.c:51:27: error: 'HZ' undeclared (first use in this function)
   51 | #define Too_Small_Time (2*HZ)
```

2. source2中的riscv-tests的编译

**编译**

```
$ git clone https://github.com/riscv/riscv-tests
$ cd riscv-tests
$ git submodule update --init --recursive
$ autoconf
$ ./configure --prefix=$RISCV/target
$ make
$ make install
```

或者是单独编译dhystone，命令如下：
```
$ riscv64-unknown-elf-gcc -I./../env -I./common -I./dhrystone -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf -o dhrystone.elf ./dhrystone/dhrystone.c ./dhrystone/dhrystone_main.c ./common/syscalls.c ./common/crt.S -static -nostdlib -nostartfiles -lm -lgcc -T ./common/test.ld
```
**运行**

- qemu用户模式运行

```
molly@molly-Huawei:~/repos/riscv-tests/benchmarks$ qemu-riscv64 ./dhrystone.riscv
非法指令 (核心已转储)
```

- qemu系统模式的fedora下也不能运行
- spike运行

用`spike pk ./dhrystone.riscv`会报告非法指令
```
molly@molly-Huawei:~/repos/riscv-tests/benchmarks$ spike /home/molly/opt/rv64/riscv64-unknown-elf/bin/pk dhrystone.riscv
bbl loader
z  0000000000000000 ra 0000000000000000 sp 0000000000000000 gp 0000000000000000
tp 0000000000000000 t0 000000000001e000 t1 0000000000000000 t2 0000000000000000
s0 0000000000000000 s1 0000000000000000 a0 0000000000000000 a1 0000000000000000
a2 0000000000000000 a3 0000000000000000 a4 0000000000000000 a5 0000000000000000
a6 0000000000000000 a7 0000000000000000 s2 0000000000000000 s3 0000000000000000
s4 0000000000000000 s5 0000000000000000 s6 0000000000000000 s7 0000000000000000
s8 0000000000000000 s9 0000000000000000 sA 0000000000000000 sB 0000000000000000
t3 0000000000000000 t4 0000000000000000 t5 0000000000000000 t6 0000000000000000
pc 0000000080000040 va/inst 000000003002a073 sr 8000000200006020
An illegal instruction was executed!
```

最后用`spike ./dhrystone.riscv`可以运行

```
molly@molly-Huawei:~/repos/riscv-tests/benchmarks$ spike dhrystone.riscv
Microseconds for one run through Dhrystone: 392
Dhrystones per Second:                      2550
mcycle = 196024
minstret = 196029
```

*gh/issue中有人提到riscv-tests的编译仅适合bare metal系统，所以在OS host系统中运行不了。*


#### Reference
1. https://en.wikipedia.org/wiki/Dhrystone
2. https://developer.arm.com/documentation/dai0273/latest/
3. https://github.com/riscv/riscv-tests
4. https://github.com/openhwgroup/cva6/issues/405
3. https://github.com/riscv/riscv-tests/issues/305
4. https://riscv.org/blog/2014/10/about-our-dhrystone-benchmarking-methodology/

