# 在x86/Linux64上交叉编译Demo程序，在D1开发板上运行

## Demo

以输出斐波那契序列为示例程序：

 ```shell
 #include <stdio.h>

int main(){
        int i, n, t1 = 0, t2 = 1, nextTerm;

        printf("How many terms to output: ");
        scanf("%d", &n);

        printf("Fibonacci sequence: ");

        for(i = 1; i<=n; ++i){
                printf("%d, ", t1);
                nextTerm = t1 + t2;
                t1 = t2;
                t2 = nextTerm;
        }

        printf("\n");

        return 0;
}
 ```

本地编译：
```
$ gcc fibo.c -o fibo
```
本地运行：
```
$ ./fibo
How many terms to output: 8
Fibonacci sequence: 0, 1, 1, 2, 3, 5, 8, 13,
```

交叉编译：
```
$ export PATH="$HOME/opt/rv64_linux/bin:$PATH" 
$ riscv64-unknown-linux-gnu-gcc fibo.c -o fibo.rv64
```
之后我们在x86机器上用spike来运行fibo.rv64;

我的spike的安装目录是：`$HOME/opt/bin`
我这里只安装rv32 elf版本的pk，它被安装在: `$HOME/opt/rv32/riscv32-unknown-elf/bin`, `$HOME/opt/rv32`应该是我们构建pk时通过prefix参数指定的，而之所以会被安装在`riscv32-unknown-elf\bin`下，应该时构建pk时指定了`--host=riscv32-unknown-elf`。

我这里没有现成的rv64 linux/gnu版本的pk，需要先构建pk。
```
$ cd riscv-pk
$ mkdir build && cd build
$ ../configure --prefix=$HOME/opt/rv64_linux --host=riscv64-unknown-linux-gnu
$ make -j $nproc
$ make install 
```
pk构建成功之后，会安装在`/home/cxo/opt/rv64_linux/riscv64-unknown-linux-gnu/bin`目录下。

我们执行下面的命令，运行fibo.rv64:
```shell
$ spike /home/cxo/opt/rv64_linux/riscv64-unknown-linux-gnu/bin/pk fibo.rv64
bbl loader
not a statically linked ELF program
```
现在报错，错误这不是一个静态链接的elf程序。

那么编译的时候加上`-static`参数，这一次编译和在模拟器上运行成功：
```
$ riscv64-unknown-linux-gnu-gcc -static fibo.c -o fibo.rv64.static

$ spike /home/cxo/opt/rv64_linux/riscv64-unknown-linux-gnu/bin/pk fibo.rv64.static
bbl loader
How many terms to output: 8
Fibonacci sequence: 0, 1, 1, 2, 3, 5, 8, 13,
```

接着，把fibo.rv64.static拷到D1上，D1的终端通过开始-System Tools-LXTerminal进入。给fibo.rv64.static加上可执行权限，执行结果和模拟器下一致。成功！
