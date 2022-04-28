## 在Unmatched上的STREAM内存带宽测试

## STREAM是什么

一个Benchmark，用于测量持续性的内存带宽，和相应的简单向量内核的计算率。

STREAM操作的数据集要远大于cache大小，因此更能评估非常大的向量类型的应用程序的性能。

## 编译STREAM

源码地址：

http://www.cs.virginia.edu/stream/FTP/Code/

编译命令：
```
$ make all
```

运行命令：
```
./stream_c.exe
```

多线程的编译和运行:

编译选项添加`-fopenmp`，并设置环境变量`export OMP_NUM_THREADS=X`，其中X为指定的线程数，最后执行`./stream_c.exe`。

## STREAM run on Unmatched

unmatched cpu参数如下：

![image](pictures/t39-1.png)

STREAM测试结果：

GCC -O0：

![image](pictures/t39-2.png)

GCC -O2：

![image](pictures/t39-3.png)

GCC -Ofast:

![image](pictures/t39-4.png)

GCC -Ofast thread=2

![image](pictures/t39-5.png)

GCC -Ofast thread=3

![image](pictures/t39-6.png)

GCC -Ofast thread=4

![image](pictures/t39-7.png)

GCC -Ofast thread=5

![image](pictures/t39-8.png)

GCC -Ofast thread=16

![image](pictures/t39-9.png)

## 参考：

https://www.cnblogs.com/iouwenbo/p/14377478.html

Stream带宽测试的解释 - 阳光总在风雨后的文章 - 知乎
https://zhuanlan.zhihu.com/p/407489860

