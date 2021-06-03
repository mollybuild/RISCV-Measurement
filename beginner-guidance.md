# 新手入门

这里总结了我在PLCT实验室做的有关RISCV测试测评方向的工作，也可以作为新员工入门的热身训练。

## 1. RISCV平台下各类编译工具的构建及运行回归测试

主要掌握RISCV GNU Toolchain，llvm，OpenJDK for RISCV的构建和回归测试。

也可以参考孙同学的整理：https://github.com/sunshaoce/learning-riscv/blob/main/2/2.md

另外，官方github README和官网的start guide都是很好的参考。

### RISCV Gnu Toolchain的构建和回归测试

1. 构建zfinx分支并运行回归测试

https://github.com/mollybuild/RISCV-Measurement/blob/master/run-riscv-gnu-toolchain-testsuite.md

2. 分别构建B、K、V扩展的分支，并运行回归测试

https://github.com/mollybuild/RISCV-Measurement/blob/master/run-riscv-gnu-toolchain-testsuite-for-BKV-extension.md


### RISCV LLVM的构建和回归测试

1. 构建RISCV LLVM并运行回归测试

https://github.com/mollybuild/RISCV-Measurement/blob/master/Build-RISCV-LLVM-and-run-testsuite.md

2. 在LLVM test-suite中添加测试用例

【TODO】

### 使用RISCV GCC/LLVM编译小程序并在模拟器上运行

1. 使用RISCV GCC/LLVM编译小程序并在模拟器上运行

【TODO】

### OpenJDK for RISCV的构建

【Java on RISC-V】交叉编译OpenJDK11 for RV32G（ZERO VM）

https://zhuanlan.zhihu.com/p/344502147

## 2. RISCV平台的测评工作

这一块工作主要是要掌握常用的benchmark：Embench, Dhrystone, fpmark, linpack, whetstone, coremark

### 复现CodeSize测评

【TODO】

### Embench的介绍和在RISCV模拟器上的运行

https://github.com/mollybuild/RISCV-Measurement/blob/master/run-Embench-on-rv32Linux-on-Qemu.md

### 熟悉Dhrystone, fpmark, linpack, whetstone, coremark

https://github.com/mollybuild/RISCV-Measurement/blob/master/run-benchmarks-Dhrystone-FPmark-Linpack-Whetstone-Coremark.md

## 3.性能工具的使用

### gcov和linux perf工具的使用

目前主要涉及到的工具有：gcov，Linux perf，linux性能可观测工具集。
参考B站报告。

## 4.测试工作的自动化

目前实现了RISCV GNU Toolchain回归测试的自动运行脚本，可以自动的安装依赖、下载GNU源码、构建、运行回归测试，这个过程将针对目前的B、K、V、P、Zfinx都会进行一遍。
脚本位置：scripts/runGNUforInsExts.sh 

## 公开报告

1. 20201204-LLVM测试框架介绍

幻灯片或资料链接：

https://github.com/isrc-cas/PLCT-Open-Reports

视频或专栏文章链接：

https://www.bilibili.com/video/BV1MK4y1L7jw

2. 20210113-Csmith vs YARPGen

幻灯片或资料链接：

https://www.bilibili.com/video/BV1rt4y1z7h4

3. 20210310 - GNU GCC Testsuite

内容简介：GNU GCC Testsuite介绍和运行方法

幻灯片或资料链接：

https://github.com/isrc-cas/PLCT-Open-Reports/blob/master/20210310-GNU-GCC-Testsuite-chenxiaoou.pdf

视频或专栏文章链接：

https://www.bilibili.com/video/BV1EV411Y7Ne

4. 20210331 - 如何使用gcov和linux-perf工具抓热点代码

幻灯片或资料链接：

https://github.com/isrc-cas/PLCT-Open-Reports/blob/master/20210331-如何使用gcov和linux-perf工具抓热点代码-陈小欧.pdf

视频或专栏文章链接：

https://www.bilibili.com/video/BV1MK4y1m7Uj

5. 20210512 - Perf更详细的介绍 - 陈小欧

报告题目：Perf更详细的介绍

报告时间：20210512

报告人：陈小欧

隶属项目：测试测评

内容简介：Perf更详细的介绍，更多介绍了常用的参数。

幻灯片或资料链接：

https://github.com/isrc-cas/PLCT-Open-Reports/blob/master/20210512-常用perf命令详解-陈小欧.pdf

视频或专栏文章链接：

https://www.bilibili.com/video/BV1hK4y1A7U4
