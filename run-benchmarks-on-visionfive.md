## 硬件信息

官方文档中对Visionfive v1的介绍：

昉·星光是第一代价格实惠的RISC-V计算机，支持Linux操作系统。昉·星光完全开源，拥有开源软件、开源硬件设计和RISC-V开源架构。 昉·星光搭载RISC-V SiFive U74双核64位RV64GC ISA的芯片平台（SoC）及8 GB LPDDR4  RAM，具有丰富的外设I/O接口，包括USB 3.0、40-Pin GPIO Header、千兆以太网连接器、Micro SD卡插槽等。 昉·星光具有神经网络引擎和NVDLA引擎，提供丰富的AI功能；昉·星光不仅具有板载音频和视频处理功能，还具有用于视频硬件的MIPI-CSI和MIPI-DSI接口。昉·星光支持Wi-Fi和蓝牙无线功能，兼容大量软件，提供对Fedora的支持。

![image](49FC4A4BA9594CA7A5B93DDB4F470E37)
图1  昉·星光顶部视图

![image](23E268A96C1C49D89A934E34766D9AA0)
图2 需另外购买风扇使用

![image](DB211A0875F749C893FA45B8BA1B8FC4)
图3 DIY机器外壳

## 安装系统

Visionfive官方提供对Fedora的支持，这里我们参照官方文档来安装操作系统。

（文档地址：https://doc.rvspace.org/VisionFive/PDF/VisionFive_Quick_Start_Guide.pdf）

#### 硬件准备

安装和运行系统我们用到下面这些硬件：

- Visionfive单板计算机
- 32 GB的Micro SD卡
- Micro SD卡读卡器
- 计算机（Windows/Linux）
- 以太网电缆
- 电源适配器（5 V / 3 A）
- USB Type-C数据线

#### 步骤

1. 下载Fedora

下载地址：https://fedora.starfivetech.com/pub/downloads/VisionFive-release/Fedora-riscv64-jh7100-developer-xfce-Rawhide-20211226-214100.n.0-sda.raw.zst

下载和解压命令：
```
$ wget https://fedora.starfivetech.com/pub/downloads/VisionFive-release/Fedora-riscv64-jh7100-developer-xfce-Rawhide-20211226-214100.n.0-sda.raw.zst
$ zstd -d Fedora-riscv64-jh7100-developer-xfce-Rawhide-20211226-214100.n.0-sda.raw.zst
```

2. 在windows上烧录

我们需要在Windows上进行烧录，因此需要下载BalenaEtcher这个软件；如果是linux系统，使用dd命令即可。

![image](3E60FEA27262400FBFD3CFB8EA2CF73D)
图四 BalenaEtcher烧录软件界面

（wsl不支持挂载SD卡，SD卡相关的驱动没有打开。使用lsblk命令查看挂载磁盘）

3. 插上SD卡上电即可进入系统

默认的用户名：riscv，密码：starfive

4. 连接网络并尝试ssh访问

为了方便操作（省去单独连接键鼠到开发板），可以使用本地电脑ssh连接到开发板或者用串口线连接到开发板。我们这里使用ssh连接。visionfive支持wifi，但wifi连接不稳定，延时较大，因此我们使用以太网电缆连接。

![image](1F497EFE892F4F4A9863B70CCAA79F00)
图5 visionfive上电之后

![image](98044E2E3C82426CAA3D903103B203BE)
图6 ssh连接visionfive

## Benchmark测试

我们测试的整形Benchmark包过Dhrystone，Coremark，LINPACK

浮点型Benchmark包过FPMark，Whetstone

##### Dhrystone

Dhrystone V2.1 源码：

https://github.com/mollybuild/RISCV-Measurement/tree/master/Benchmarks/DhrystoneV2.1

需要打patch，patch地址：

https://github.com/mollybuild/RISCV-Measurement/blob/master/patch/Dhrystone.patch

打patch和编译命令：

```
$ cd DhrystoneV2.1
$ patch -p1 < ../Dhrystone.patch
$ gcc -c -O2 -fno-inline dhry_1.c
$ gcc -c -O2 -fno-inline dhry_2.c
$ gcc -o dhrystone dhry_1.o dhry_2.o
```

运行dhrystone，设置运行次数为100000000
```
 ./dhrystone.riscv

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
 Ptr_Comp: 586871456
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
 Ptr_Comp: 586871456
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

Microseconds for one run through Dhrystone:    0.6
Dhrystones per Second: 1720676.8
```

#### Coremark

测试使用的是Coremark V1.0，测试命令如下，Visionfive是双核的，因此这里设定2个线程：

```
make XCFLAGS="-DMULTITHREAD=2 -DUSE_FORK" ITERATIONS=150000 PORT_DIR=rv64
```

测试结果：
run1.log
```
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 46188
Total time (secs): 46.188000
Iterations/Sec   : 6495.193557
Iterations       : 300000
Compiler version : GCC10.3.1 20210422 (Red Hat 10.3.1-1)
Compiler flags   : -O2 -DMULTITHREAD=2 -DUSE_FORK -DPERFORMANCE_RUN=1  -lrt
Parallel Fork : 2
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[1]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[1]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[1]crcstate      : 0x8e3a
[0]crcfinal      : 0x25b5
[1]crcfinal      : 0x25b5
Correct operation validated. See readme.txt for run and reporting rules.
CoreMark 1.0 : 6495.193557 / GCC10.3.1 20210422 (Red Hat 10.3.1-1) -O2 -DMULTITHREAD=2 -DUSE_FORK -DPERFORMANCE_RUN=1  -lrt / Heap / 2:Fork
```

run2.log
```
2K validation run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 46326
Total time (secs): 46.326000
Iterations/Sec   : 6475.845098
Iterations       : 300000
Compiler version : GCC10.3.1 20210422 (Red Hat 10.3.1-1)
Compiler flags   : -O2 -DMULTITHREAD=2 -DUSE_FORK -DPERFORMANCE_RUN=1  -lrt
Parallel Fork : 2
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0x18f2
[0]crclist       : 0xe3c1
[1]crclist       : 0xe3c1
[0]crcmatrix     : 0x0747
[1]crcmatrix     : 0x0747
[0]crcstate      : 0x8d84
[1]crcstate      : 0x8d84
[0]crcfinal      : 0x6225
[1]crcfinal      : 0x6225
Correct operation validated. See readme.txt for run and reporting rules.
```

##### Whetstone

Whetstone源码：

https://github.com/mollybuild/RISCV-Measurement/tree/master/Benchmarks/Whetstone

编译命令：
```
gcc -o whetstone whetstone.c -lm
```
运行和结果：

![image](BA7968CF6FB443DAA56FCCC0D05DD58B)

##### FPMark

将FPMark拷贝到visionfive上，进入fpmark_1.5.3126目录下，执行：

```
$ make TARGET=linux64 certify-all XCMD='-c2 -v0'
```

运行后会出现除零错误：

![image](78A70D26C0CA4C2AAB8FC0FC5C774B17)

FPMark中ray-1024x768at24s运行时间较长，iter/s在保留两位小数的精度下结果为0，因此会出现除零错误，需要修改中间计算过程中的精度，主要涉及两处的更改：

```
diff -urN fpmark_1.5.3126/util/perl/cert_median.pl fpmark_1.5.3126_new/util/perl/cert_median.pl
--- fpmark_1.5.3126/util/perl/cert_median.pl    2023-01-10 05:26:09.965291005 +0000
+++ fpmark_1.5.3126_new/util/perl/cert_median.pl        2023-01-09 09:05:40.002032918 +0000
@@ -86,7 +86,7 @@
        $med=median($timed{$lastuid});
        $all_fields{$lastuid}->[$itime]=$med;

-       printf("%-15d %5s %-40s %3d %3d %5d %10.3f %10d %10.2f %9d %10d median $contype\n",
+       printf("%-15d %5s %-40s %3d %3d %5d %10.3f %10d %10.4f %9d %10d median $contype\n",
                @{$all_fields{$lastuid}},
                #variance($res{$lastuid}),
                #std_dev($res{$lastuid})
diff -urN fpmark_1.5.3126/util/perl/results_parser.pl fpmark_1.5.3126_new/util/perl/results_parser.pl
--- fpmark_1.5.3126/util/perl/results_parser.pl 2023-01-10 05:21:42.150987553 +0000
+++ fpmark_1.5.3126_new/util/perl/results_parser.pl     2023-01-09 09:06:28.545932704 +0000
@@ -136,7 +136,7 @@
                        }

                        # $runlog{$uid}="$uid\tMLT\t$oname\t$ctxt\t$wrkr\t$fails\t$secs\t$its\t".$itps;
-                       $runlog{$uid} = sprintf("%-15d %5s %-40s %3d %3d %5d %10.3f %10d %10.2f",
+                       $runlog{$uid} = sprintf("%-15d %5s %-40s %3d %3d %5d %10.3f %10d %10.4f",
                                $uid,
                                "MLT",
                                $oname,
```
(patch地址：https://github.com/mollybuild/RISCV-Measurement/commit/b653df17153d15c734d3b3841344af192d808081)

修改之后运行结果如下：

![image](05353010A02047E4BF64DEBCBE9A05D7)

![image](01CE7528CB9A408F83AF59F6BF287E64)   

##### LINPACK

LINPACK源码：

https://github.com/mollybuild/RISCV-Measurement/tree/master/Benchmarks/LINPACK

编译命令：

```
gcc -o linpack linpack.c -lm
```

运行结果：

![image](C4B12A8921B04EE991833C3B9C2C8A44)

## 结果对比

下表汇总了此前测过的一些开发板，也包括这次的Visionfive的性能结果：

![image](121894C0A6B84319AEEE05CEB5B32D77)

注：
1. Dhrystone 分数除以 1757（在 VAX 11/780 上获得的每秒 Dhrystone 数，标称 1 MIPS 机器）获得的 DMIPS（Dhrystone MIPS）
2. FPMark的分数为MultiCore项的分数
3. Linpack数据在array size=200测得
4. Unmatched和Visionfive采用相同CPU core（sifive U74），但在不同的文档或新闻中报告的主频不一样，仅供参考。（不支持cpuinfo查看频率）

Unmatched和Visionfive使用了相同的CPU core（U74），不同的是Unmatched是四核，Visionfive是双核，从CoreMark和FPMark测得的多核性能也能看出，Unmatched差不多是Visionfive的两倍。单核整形性能Visionfive略低于Unmatched，单核浮点性能二者基本持平。
