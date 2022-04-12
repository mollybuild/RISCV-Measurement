### 在unmatched上构建LLVM

参考Flang的文档编译：

https://github.com/llvm/llvm-project/tree/main/flang

里面提到编译Flang，mlir,clang,compiler-rt也是必要的。

llvm-project源码版本：branch main, commit commit 7fd60ee6e0a87957a718297a4a42d9881fc561e3l

命令记录：
```
$ sudo apt install ninja-build
$ cmake   -G Ninja   ../llvm   -DCMAKE_BUILD_TYPE=Release   -DFLANG_ENABLE_WERROR=On   -DLLVM_ENABLE_ASSERTIONS=ON   -DLLVM_TARGETS_TO_BUILD=host   -DCMAKE_INSTALL_PREFIX=/home/chenxiaoou/llvm-bin  -DLLVM_LIT_ARGS=-v -DLLVM_ENABLE_PROJECTS="clang;mlir;flang" -DLLVM_ENABLE_RUNTIMES="compiler-rt"

$ ninja
$ ninja install
```

报错：
```
[898/4842] Building CXX object lib/Transforms/IPO/CMakeFiles/LLVMipo.dir/OpenMPOpt.cpp.o                                                                                                                                      FAILED: lib/Transforms/IPO/CMakeFiles/LLVMipo.dir/OpenMPOpt.cpp.o                                              /usr/bin/c++ -DGTEST_HAS_RTTI=0 -D_DEBUG -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -Ilib/Transforms/IPO -I/home/chenxiaoou/llvm-project/llvm/lib/Transforms/IPO -Iinclude -I/home/chenxiaoou/llvm-project/llvm/include -fPIC -fno-semantic-interposition -fvisibility-inlines-hidden -Werror=date-time -Wall -Wextra -Wno-unused-parameter -Wwrite-strings -Wcast-qual -Wno-missing-field-initializers -pedantic -Wno-long-long -Wimplicit-fallthrough -Wno-maybe-uninitialized -Wno-class-memaccess -Wno-redundant-move -Wno-pessimizing-move -Wno-noexcept-type -Wdelete-non-virtual-dtor -Wsuggest-override -Wno-comment -Wmisleading-indentation -fdiagnostics-color -ffunction-sections -fdata-sections -O3 -DNDEBUG  -fno-exceptions -fno-rtti -UNDEBUG -std=c++14 -MD -MT lib/Transforms/IPO/CMakeFiles/LLVMipo.dir/OpenMPOpt.cpp.o -MF lib/Transforms/IPO/CMakeFiles/LLVMipo.dir/OpenMPOpt.cpp.o.d -o lib/Transforms/IPO/CMakeFiles/LLVMipo.dir/OpenMPOpt.cpp.o -c /home/chenxiaoou/llvm-project/llvm/lib/Transforms/IPO/OpenMPOpt.cpp                                                              malloc(): unaligned tcache chunk detected                                                                      during GIMPLE pass: dse                                                                                        malloc(): unaligned tcache chunk detected                                                                      c++: internal compiler error: Aborted signal terminated program cc1plus                                        Please submit a full bug report,                                                                               with preprocessed source if appropriate.                                                                       See <file:///usr/share/doc/gcc-10/README.Bugs> for instructions.                                               [903/4842] Building CXX object lib/Transforms/IPO/CMakeFiles/LLVMipo.dir/WholeProgramDevirt.cpp.o
```

这个是编译器的内部错误，尝试用Clang编译：

```
$ cmake   -G Ninja   ../llvm   -DCMAKE_BUILD_TYPE=Release   -DFLANG_ENABLE_WERROR=On   -DLLVM_ENABLE_ASSERTIONS=ON   -DLLVM_TARGETS_TO_BUILD=host   -DCMAKE_INSTALL_PREFIX=/home/chenxiaoou/llvm-bin  -DLLVM_LIT_ARGS=-v -DLLVM_ENABLE_PROJECTS="clang;mlir;flang" -DLLVM_ENABLE_RUNTIMES="compiler-rt" -DCMAKE_CXX_COMPILER=/usr/bin/clang++ -DCMAKE_C_COMPILER=/usr/bin/clang
$ ninja
```

SPEC的程序需要用到openmp库，所以可添加opemmp项目`-DLLVM_ENABLE_PROJECTS="clang;mlir;flang;openmp"`

同时设置了下面的环境变量：
```
$ export C_INCLUDE_PATH=/usr/include/riscv64-linux-gnu/:$C_INCLUDE_PATH
$ export CPLUS_INCLUDE_PATH=/usr/include/riscv64-linux-gnu/:$CPLUS_INCLUDE_PATH
$ export LIBRARY_PATH=/usr/lib/riscv64-linux-gnu/:$LIBRARY_PATH
$ export LD_LIBRARY_PATH=/usr/lib/riscv64-linux-gnu/:$LD_LIBRARY_PATH
$ sudo /sbin/ldconfig
```

借着报错找不到crt1.o，可以通过建立下面的软连接来解决：
```
sudo ln -s /usr/lib/riscv64-linux-gnu /usr/lib64
```

在unmatched016 ~/llvm-project/build-3目录下成功的完成了编译。
