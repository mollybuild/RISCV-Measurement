#### 遇到的问题

1, git clone 报错：

`gnutls_handshake() failed: Error in the pull function.`

解决方法：

 `apt-get -y install build-essential nghttp2 libnghttp2-dev libssl-dev`
 
#### follow cjw's wiki

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

2. switch gcc、binutils、qemu form github

```
$ cd riscv-gcc
$ git remote add zfinx https://github.com/pz9115/riscv-gcc.git
$ git fetch zfinx
$ git checkout zfinx/riscv-gcc-10.2.0-zfinx
$ cd ../riscv-binutils
$ git remote add zfinx https://github.com/pz9115/riscv-binutils-gdb.git
$ git fetch zfinx
$ git checkout zfinx/riscv-binutils-2.35-zfinx
$ cd ../qemu
$ git remote add plct-qemu https://github.com/isrc-cas/plct-qemu.git
$ git fetch plct-qemu
$ git checkout plct-qemu/plct-zfinx-dev
$ git reset --hard d73c46e4a84e47ffc61b8bf7c378b1383e7316b5
$ cd ..
```

3. set configure in riscv-gnu-toolchain for compile

```
# for rv64:
$ ./configure --prefix=/opt/rv64/ --with-arch=rv64gc --with-abi=lp64 --with-multilib-generator="rv64gc-lp64--"

# for rv32:
$ ./configure --prefix=/opt/rv32/ --with-arch=rv32gc --with-abi=ilp32 --with-multilib-generator="rv32gc-ilp32--"

# for rv32e:
$ ./configure --prefix=/opt/rv32e/ --with-arch=rv32ec --with-abi=ilp32e --with-multilib-generator="rv32ec-ilp32e--"
```

rv32g: rv32imfad （ 整型，乘除，单精度浮点，原子，双精度浮点

rv32e: 一个只有16个寄存器的嵌入式版本的RISC-V，只使用寄存器x0-x15.

rv32c: 压缩指令，只对汇编器和链接器可见，编译器编写者和汇编语言程序员可以幸福地忽略RV32C指令及其格式，他们能感知到的则是最后的程序大小小于大多数其他ISA的程序。

RV32的ABI分别名为ilp32,ilp32f,ilp32d。ilp32表示C语言的整型(int),长整形(long)和指针（pointer）都是32位，可选后缀表示如何传递浮点参数。在ilp32中，浮点参数在整数寄存器中传递；在ilp32f中，单精度浮点参数在浮点寄存器中传递；在ilp32d中，双精度浮点参数**也**在浮点寄存器中传递。

--with-multilib-generator参考riscv-gnu-toolchain readme:

https://github.com/riscv/riscv-gnu-toolchain

4. regression test

```
# you can use make -j* to make speed up
# see the report
$ make report-gcc-newlib 2>&1|tee gcclog.md
$ make report-binutils-newlib 2>&1|tee binutilslog.md
# Use `make clean` to re-check different abi, reset configure and remake for other abi again (lp64\ilp32\ilp32e)
```
- make check和make report的区别

make check只能跑一次，report多次有效

- make report-gcc-linux

也可使用glibc库测试，源码编译时使用`make linux`


#### 下面就是自己的一些尝试，帮助理解test suite是怎么运行和组织的

1 向gcc.dg目录中添加了一个测试用例spec-barrier-1.c，执行gcc.dg/dg.exp时候运行了该测试用例。


cp c-c++-common/spec-barrier-1.c gcc.dg

```shell
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/dg.exp ...
XPASS: gcc.dg/attr-alloc_size-11.c missing range info for signed char (test for warnings, line 50)
XPASS: gcc.dg/attr-alloc_size-11.c missing range info for short (test for warnings, line 51)
FAIL: gcc.dg/spec-barrier-1.c (test for excess errors)
FAIL: c-c++-common/patchable_function_entry-decl.c  -Wc++-compat   scan-assembler-times nop|NOP 2
FAIL: c-c++-common/patchable_function_entry-default.c  -Wc++-compat   scan-assembler-times nop|NOP 3
FAIL: c-c++-common/patchable_function_entry-definition.c  -Wc++-compat   scan-assembler-times nop|NOP 1
FAIL: c-c++-common/spec-barrier-1.c  -Wc++-compat  (test for excess errors)
```

2，gcc.dg/下添加一个目录aaa，向其中添加spec-barrier-1.c，该目录下没有.exp文件

这个测试文件没有被执行。

```shell
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/analyzer/analyzer.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/analyzer/torture/analyzer-torture.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/asan/asan.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/atomic/atomic.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/autopar/autopar.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/charset/charset.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/compat/compat.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/compat/struct-layout-1.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/cpp/cpp.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/cpp/trad/trad.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/debug/debug.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/debug/dwarf2/dwarf2.exp ...
FAIL: gcc.dg/debug/dwarf2/inline5.c scan-assembler-not \\(DIE \\(0x([0-9a-f]*)\\) DW_TAG_lexical_block\\)[^#/!@;\\|]*[#/!@;\\|]+ +[^(].*DW_TAG_lexical_block\\)[^#/!@;\\|x]*x\\1[^#/!@;\\|]*[#/!@;\\|] +DW_AT_abstract_origin
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/dfp/dfp.exp ...
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/dg.exp ...
XPASS: gcc.dg/attr-alloc_size-11.c missing range info for signed char (test for warnings, line 50)
XPASS: gcc.dg/attr-alloc_size-11.c missing range info for short (test for warnings, line 51)
FAIL: c-c++-common/patchable_function_entry-decl.c  -Wc++-compat   scan-assembler-times nop|NOP 2
FAIL: c-c++-common/patchable_function_entry-default.c  -Wc++-compat   scan-assembler-times nop|NOP 3
FAIL: c-c++-common/patchable_function_entry-definition.c  -Wc++-compat   scan-assembler-times nop|NOP 1
FAIL: c-c++-common/spec-barrier-1.c  -Wc++-compat  (test for excess errors)
```

3，gcc.dg/下添加一个目录aaa，向其中添加spec-barrier-1.c，并添加aaa.exp。

```shell
Running /home/cxo/repos/zfinx/riscv-gcc/gcc/testsuite/gcc.dg/aaa/aaa.exp ...
FAIL: gcc.dg/aaa/spec-barrier-1.c (test for excess errors)  
```





结论：

1，每个子目录必须有exp文件，该目录下的测试文件才会被执行吗？ 是的

2，一个目录下的exp文件，会执行它的子目录下的测试文件吗？不会

当然，一个exp要执行那些测试文件，是在exp中定义的，例如gcc.dg/dg.exp就会执行c-c++-common中的测试用例。

3，include dg.exp的方式是怎样的？ 
