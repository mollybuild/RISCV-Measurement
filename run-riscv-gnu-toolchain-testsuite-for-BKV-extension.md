## 跑RISC-V GNU Toolchain的B K V扩展的回归测试 （20210416）

## 前言

测试目前RISCV GNU Toolchain B K V 扩展的回归测试情况。

## 扩展的仓库

**B 扩展:**

GCC: https://github.com/pz9115/riscv-gcc/tree/riscv-gcc-10.2.0-rvb

Binutils: https://github.com/pz9115/riscv-binutils-gdb/tree/riscv-binutils-experiment

**K 扩展：**

GCC: https://github.com/WuSiYu/riscv-gcc

Binutils：https://github.com/pz9115/riscv-binutils-gdb/tree/riscv-binutils-2.36-k-ext

**V 扩展：**

GCC: https://github.com/riscv/riscv-gcc/tree/riscv-gcc-10.1-rvv-dev

Binutils: https://github.com/riscv/riscv-binutils-gdb/tree/rvv-1.0.x


## 步骤

 0. make sure you had installed git and build-essential tools. If tips any error with miss, just use ``apt-get install`` to install it
```
apt-get install git build-essential tcl expect flex texinfo bison libpixman-1-dev libglib2.0-dev pkg-config zlib1g-dev ninja-build 
```

1. download riscv-gnu-toolchain form github

```
$ git clone https://github.com/riscv/riscv-gnu-toolchain
$ cd riscv-gnu-toolchain
$ git submodule update --init --recursive
$ cd ..
$ cp riscv-gnu-toolchain zfinx -r && cd zfinx
```

#### for b-ext

```shell

$ cp -r riscv-gnu-toolchain b-ext && cd b-ext

## switch gcc to rvb branch
$ cd riscv-gcc
$ git remote add pz9115 https://github.com/pz9115/riscv-gcc.git
$ git fetch pz9115
$ git checkout pz9115/riscv-gcc-10.2.0-rvb

## switch binutils to rvb branch
$ cd ../riscv-binutils/
$ git remote add pz9115 https://github.com/pz9115/riscv-binutils-gdb.git
$ git fetch pz9115
$ git checkout pz9115/riscv-binutils-experiment

## no need for customized qemu at now.

## set configure for building
$ cd .. && mkdir build && cd build
$ ../configure --prefix=$HOME/RISCV64/rvb/ --with-arch=rv64gc_zba_zbb_zbc_zbe_zbf_zbm_zbp_zbr_zbs_zbt --with-abi=lp64 --with-multilib-generator="rv64gc_zba_zbb_zbc_zbe_zbf_zbm_zbp_zbr_zbs_zbt-lp64--"

## build scr
$ make -j $(nproc)

## run testsuite
$ make report-gcc-newlib 2>&1|tee gcclog.md
$ make report-binutils-newlib 2>&1|tee binutilslog.md

```

###### 结果

构建成功，但目前跑testsuite还有不支持的地方，大部分test case Failed.

```shell
                === gcc Summary ===

# of expected passes            67500
# of unexpected failures        35769
# of unexpected successes       5
# of expected failures          514
# of unresolved testcases       979
# of unsupported tests          2568

                === g++ Summary ===

# of expected passes            138419
# of unexpected failures        19058
# of expected failures          558
# of unresolved testcases       2
# of unsupported tests          8538

               ========= Summary of gcc testsuite =========
                            | # of unexpected case / # of unique unexpected case
                            |          gcc |          g++ |     gfortran |
 rv64i_zba_zbb_zbc_zbe_zbf_zbm_zbp_zbr_zbs_zbt/   lp64/ medlow |35737 /  3611 |19032 /  2517 |      - |
```

```shell
                === binutils Summary ===

# of expected passes            206
# of expected failures          1
# of untested testcases         10
# of unsupported tests          12

                === gas Summary ===

# of expected passes            337
# of unexpected failures        2
# of expected failures          15
# of unsupported tests          13

                === ld Summary ===

# of expected passes            388
# of expected failures          9
# of untested testcases         20
# of unsupported tests          186


               ========= Summary of binutils testsuite =========
                            | # of unexpected case
                            |     binutils |           ld |          gas |
 rv64i_zba_zbb_zbc_zbe_zbf_zbm_zbp_zbr_zbs_zbt/   lp64/ medlow |            0 |            0 |            2 |
```

~~gas unexpected Fail:~~ (已修复)
```
FAIL: gas/riscv/b-ext-64
FAIL: gas/riscv/b-ext
```

#### for k-ext

```shell
$ cp -r riscv-gnu-toolchain k-ext && cd k-ext

## switch gcc to k ext branch
$ cd riscv-gcc/
$ git remote add wsy https://github.com/WuSiYu/riscv-gcc.git
$ git fetch wsy
$ git checkout wsy/riscv-gcc-10.2.0-crypto

## switch binutils to k ext branch
$ cd ..
$ cd riscv-binutils/
$ git remote add pz9115 https://github.com/pz9115/riscv-binutils-gdb.git
$ git fetch pz9115
$ git checkout pz9115/riscv-binutils-2.36-k-ext

## configure for building
$ ../configure --prefix=$HOME/RISCV64/rvk --with-arch=rv64imafdck --with-abi=lp64d --with-multilib-generator="rv64imafdck-lp64d--"

## build src
$ make -j $(nproc)

## run testsuite
$ make report-gcc-newlib 2>&1|tee gcclog.md
$ make report-binutils-newlib 2>&1|tee binutilslog.md
```

注意：K扩展在configure时的with-arch参数是imafdck，不能等价的写为gck。因为有子模块，这里用g只会展开一次，对后续bk的子模块就不处理了。

扩展的字母顺序有要求吗？

![image](BA1FC057729748FE82C985D22CF84C76)

**遇到的问题**

1, 找不到lib.a
```shell
riscv64-unknown-elf-ar rc ../libc.a *.o                                                                                    riscv64-unknown-elf-ar: ../argz/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../stdlib/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../ctype/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../search/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../stdio/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../string/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../signal/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../time/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../locale/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../reent/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../errno/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../misc/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../ssp/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../syscalls/lib.a: No such file or directory
riscv64-unknown-elf-ar: ../machine/lib.a: No such file or directory
riscv64-unknown-elf-ar: *.o: No such file or directory
make[9]: *** [Makefile:1034: libc.a] Error 1
```

解决方法，需要更新riscv-glibc，查看官网，目前riscv-glibc模块版本是commit 9826b03

```shell
git checkout 9826b03
```

2，```Error: -march=rv64imafdck_zkb_zkg_zkn_zknd_zkne_zknh_zkr: unknown z ISA extension `zkn' ```

~~TODO: cjw to fix~~ （bug已经修复，更新riscv-gcc，riscv-binutils重新测试）

###### 结果

构建成功，但目前跑testsuite还有不支持的地方，大部分test case Failed.

```shell
                === gcc Summary ===

# of expected passes            84672
# of unexpected failures        18813
# of unexpected successes       5
# of expected failures          514
# of unresolved testcases       979
# of unsupported tests          2571

                === g++ Summary ===

# of expected passes            147343
# of unexpected failures        10147
# of unexpected successes       4
# of expected failures          554
# of unresolved testcases       2
# of unsupported tests          8538

               ========= Summary of gcc testsuite =========
                            | # of unexpected case / # of unique unexpected case
                            |          gcc |          g++ |     gfortran |
 rv64imafdck/  lp64d/ medlow |18810 /  3609 |10129 /  2517 |      - |
 
 ```

```shell

                === binutils Summary ===

# of expected passes            206
# of expected failures          1
# of untested testcases         10
# of unsupported tests          12

                === gas Summary ===

# of expected passes            339
# of expected failures          15
# of unsupported tests          13

                === ld Summary ===

# of expected passes            388
# of expected failures          9
# of untested testcases         20
# of unsupported tests          186

               ========= Summary of binutils testsuite =========
                            | # of unexpected case
                            |     binutils |           ld |          gas |
 rv64imafdck/  lp64d/ medlow |            0 |            0 |            0 |

```


#### for v-ext

```shell
$ cp -r riscv-gnu-toolchain v-ext && cd v-ext

## switch gcc to v ext branch
$ cd riscv-gcc/
$ git fetch origin
$ git checkout origin/riscv-gcc-10.1-rvv-dev

## switch binutils to v ext branch
$ cd ..
$ cd riscv-binutils/
$ git fetch origin
$ git checkout origin/rvv-1.0.x

## configure for building
$ cd ..
$ mkdir build && cd build
$ ../configure --prefix=$HOME/RISCV64/rvv --with-arch=rv64gcv --with-abi=lp64d --with-multilib-generator="rv64gcv-lp64d--"

## build src
$ make -j $(nproc)

## run testsuite
$ make report-gcc-newlib 2>&1|tee gcclog.md
$ make report-binutils-newlib 2>&1|tee binutilslog.md
```

###### 结果

下面的结果是with-abi=lp64的，还没改过来（改成with-abi=lp64d)
```shell
                === gcc Summary ===

# of expected passes            105296
# of unexpected failures        165
# of unexpected successes       3
# of expected failures          514
# of unresolved testcases       761
# of unsupported tests          2299

                === g++ Summary ===

# of expected passes            157339
# of unexpected failures        20
# of expected failures          554
# of unresolved testcases       4
# of unsupported tests          8391

           ========= Summary of gcc testsuite =========
                            | # of unexpected case / # of unique unexpected case
                            |          gcc |          g++ |     gfortran |
    rv64gcv/   lp64/ medlow |  138 /   138 |    1 /     1 |      - |

```

```shell
                === binutils Summary ===

# of expected passes            212
# of expected failures          1
# of unsupported tests          9

                === gas Summary ===

# of expected passes            298
# of expected failures          15
# of unsupported tests          10

                === ld Summary ===

# of expected passes            502
# of unexpected failures        12
# of expected failures          11
# of unsupported tests          183

           ========= Summary of binutils testsuite =========
                            | # of unexpected case
                            |     binutils |           ld |          gas |
    rv64gcv/   lp64/ medlow |            0 |            0 |            0 |

```


