# 如何在Hifive Unmatched开发板上安装SPEC CPU 2006

与SPEC CPU2017类似，CPU2006官方不提供对RISCV平台的支持，因为我们需要自己编译CPU2006中的toolset，参考官方的文档：

[Building the SPEC CPU2006 Tool Suite](https://www.spec.org/cpu2006/Docs/tools-build.html)

我们编译toolset并安装运行CPU2006的硬软件环境如下：

- 开发板：Hifive Unmatched
- 内存：16G
- 硬盘：1T SSD
- OS：Ubuntu21.04
- GCC：10.3.0
- Glibc：2.33

### 编译toolset过程中的报错和解决方法

#### more undefined references to __alloca' follow

解决方法：

修改src/make-3.82/glob/glob.c第211行：

```
- #if !defined __alloca && !defined __GNU_LIBRARY__
+ #if !defined __alloca && defined __GNU_LIBRARY__
```

#### Building tar时报`'gets' undeclared here`

错误说明：

由于依赖库版本升级造成的代码兼容性问题。

解决方法：

修改下面两个文件

src/specsum/gnulib/stdio.in.h

src/tar-1.25/gnu/stdio.in.h

```
--- stdio.in.h.old      2021-10-18 04:23:40.643989910 -0400
+++ stdio.in.h  2021-10-18 04:31:03.193990991 -0400
@@ -159,7 +159,9 @@ _GL_WARN_ON_USE (fflush, "fflush is not
    so any use of gets warrants an unconditional warning.  Assume it is
    always declared, since it is required by C89.  */
 #undef gets
-_GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");
+#if defined(__GLIBC__) && !defined(__UCLIBC__) && !__GLIBC_PREREQ(2, 16)
+ _GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");
+#endif

 #if @GNULIB_FOPEN@
 # if @REPLACE_FOPEN@
```

### undefined reference to `pow` 等等

export PERLFLAGS="-A libs=-lm -A libs=-ldl -A libs=-lc -A ldflags=-lm -A cflags=-lm -A ccflags=-lm"

### perl Configure 需要打的patch

```
--- /mnt/tools/src/perl-5.12.3/Configure        2011-03-03 17:29:36.000000000 -00
500
+++ perl-5.12.3/Configure       2021-11-03 02:39:12.004657891 -0400
@@ -4536,7 +4536,7 @@ else
 fi
 $rm -f try try.*
 case "$gccversion" in
-1*) cpp=`./loc gcc-cpp $cpp $pth` ;;
+1.*) cpp=`./loc gcc-cpp $cpp $pth` ;;
 esac
 case "$gccversion" in
 '') gccosandvers='' ;;
@@ -4688,6 +4688,18 @@ fi

 if $ok; then
        : nothing
+elif echo 'Maybe "'"$cc"' -E -ftrack-macro-expansion=0" will work...'; \
+       $cc -E -ftrack-macro-expansion=0 <testcpp.c >testcpp.out 2>&1; \
+       $contains 'abc.*xyz' testcpp.out >/dev/null 2>&1 ; then
+       echo "Yup, it does."
+       x_cpp="$cc $cppflags -E -ftrack-macro-expansion=0"
+       x_minus='';
+elif echo 'Maybe "'"$cc"' -E -ftrack-macro-expansion=0 -" will work...';
+       $cc -E -ftrack-macro-expansion=0 - <testcpp.c >testcpp.out 2>&1; \
+       $contains 'abc.*xyz' testcpp.out >/dev/null 2>&1 ; then
+       echo "Yup, it does."
+       x_cpp="$cc $cppflags -E -ftrack-macro-expansion=0"
+       x_minus='-';
 elif echo 'Maybe "'"$cc"' -E" will work...'; \
        $cc -E <testcpp.c >testcpp.out 2>&1; \
        $contains 'abc.*xyz' testcpp.out >/dev/null 2>&1 ; then
@@ -5128,7 +5140,7 @@ fi
 case "$hint" in
 default|recommended)
        case "$gccversion" in
-       1*) dflt="$dflt -fpcc-struct-return" ;;
+       1.*) dflt="$dflt -fpcc-struct-return" ;;
        esac
        case "$optimize:$DEBUGGING" in
        *-g*:old) dflt="$dflt -DDEBUGGING";;
@@ -5143,7 +5155,7 @@ default|recommended)
                ;;
        esac
        case "$gccversion" in
-       1*) ;;
+       1.*) ;;
        2.[0-8]*) ;;
        ?*)     set strict-aliasing -fno-strict-aliasing
                eval $checkccflag
@@ -5245,7 +5257,7 @@ case "$cppflags" in
 *)  cppflags="$cppflags $ccflags" ;;
 esac
 case "$gccversion" in
-1*) cppflags="$cppflags -D__GNUC__"
+1.*) cppflags="$cppflags -D__GNUC__"
 esac
 case "$mips_type" in
 '');;
```

参考：https://github.com/Perl/perl5/issues/14491


### packagetools linux-riscv64

首先，新建$SPEC/tools/bin/linux-riscv64目录，并在其中新建description文件。

然后，回到$SPEC目录，执行：

```
$  ./bin/packagetools linux-riscv64
```

### Installation of linux-riscv64 aborted.

在安装CPU2006的过程中会进行perl工具的回归测试，可以在运行install脚本之前`export SPEC_INSTALL_NOCHECK=1 `跳过测试部分。不过其中一些Failed也是可以解决的。

- Perl的测试用例numconvert.t的报错和解决方法

对于numconvert.t报错可以加上`-A ccflags=-fwrapv`选项编译，即可通过：

```
$ export PERLFLAGS="-A ccflags=-fwrapv"
```

- Perl的测试用例Local.t的报错和解决方法

Local.t可能会报下面的错误，解决方法是按下面的patch修改perl-5.12.3/ext/Time-Local/t/Local.t文件
![image](pictures/t32-1.png)

```shell
--- /mnt/tools/src/perl-5.12.3/ext/Time-Local/t/Local.t 2011-03-03 17:29:36.00000
00000 -0500
+++ perl-5.12.3/ext/Time-Local/t/Local.t        2021-10-28 05:19:07.500262285 -00
400
@@ -84,7 +84,7 @@ for (@time, @neg_time) {

     # Test timelocal()
     {
-        my $year_in = $year < 70 ? $year + 1900 : $year;
+       my $year_in = $year + 1900;
         my $time = timelocal($sec,$min,$hour,$mday,$mon,$year_in);

         my($s,$m,$h,$D,$M,$Y) = localtime($time);
@@ -100,8 +100,8 @@ for (@time, @neg_time) {

     # Test timegm()
     {
-        my $year_in = $year < 70 ? $year + 1900 : $year;
-        my $time = timegm($sec,$min,$hour,$mday,$mon,$year_in);
+        my $year_in = $year + 1900;
+       my $time = timegm($sec,$min,$hour,$mday,$mon,$year_in);

         my($s,$m,$h,$D,$M,$Y) = gmtime($time);

@@ -117,7 +117,6 @@ for (@time, @neg_time) {

 for (@bad_time) {
     my($year, $mon, $mday, $hour, $min, $sec) = @$_;
-    $year -= 1900;
     $mon--;

     eval { timegm($sec,$min,$hour,$mday,$mon,$year) };
@@ -126,14 +125,14 @@ for (@bad_time) {
 }

 {
-    is(timelocal(0,0,1,1,0,90) - timelocal(0,0,0,1,0,90), 3600,
+    is(timelocal(0,0,1,1,0,1990) - timelocal(0,0,0,1,0,1990), 3600,
        'one hour difference between two calls to timelocal');

-    is(timelocal(1,2,3,1,0,100) - timelocal(1,2,3,31,11,99), 24 * 3600,
+    is(timelocal(1,2,3,1,0,2000) - timelocal(1,2,3,31,11,1999), 24 * 3600,
        'one day difference between two calls to timelocal');

     # Diff beween Jan 1, 1980 and Mar 1, 1980 = (31 + 29 = 60 days)
-    is(timegm(0,0,0, 1, 2, 80) - timegm(0,0,0, 1, 0, 80), 60 * 24 * 3600,
+    is(timegm(0,0,0, 1, 2, 1980) - timegm(0,0,0, 1, 0, 1980), 60 * 24 * 3600,
        '60 day difference between two calls to timegm');
 }
```

### Perl的测试用例DynaLoader.t的报错和解决方法

解决方法

```
export PERLFLAGS="$PERLFLAGS -Dlibpth=/usr/lib/riscv64-linux-gnu"
```

### 直接绕过安装时的校验

前面说过，安装时的perl test检查也是可以直接绕过的。就是在构建完toolset，并且packagetools打包完之后，设置一下环境变量：
```
export SPEC_INSTALL_NOCHECK=1 
```
然后再运行install.sh脚本就可以安装了，绕过校验和检查。

### unmatched上编译toolset并安装CPU2006的步骤总结

首先设置PERLFLAGS（参数供参考），执行buildtools脚本进行toolset的编译。

```
$ export PERLFLAGS="-A libs=-lm -A libs=-lc -A ldflags=-lm -A cflags=-lm -A ccflags=-lm -A ccflags=-fwrapv -Dlibpth=/usr/lib/riscv64-linux-gnu -A libs=-ldl"
$ cd $SPEC/tools/src
$ ./buildtools
```

完成编译之后，后出现下面的信息：

![image](pictures/t32-2.png)

然后创建tools/bin/linux-riscv64目录和其中的description文件：

```shell
$ cd $SPEC/tools/bin/
$ mkdir linux-riscv64
```

description文件内容：
```
For riscv64 Linux systems
                              Built on Qemu Fedora 5.5.0-0.rc5.git0.1.1.riscv64..
                              fc32.riscv64 with GCC 9.2.1 20191120 (Red Hat 9.2..
                              1-2)
```

然后打包toolset

```
$ cd $SPEC
$ source shrc
$ packagetools linux-riscv64
```

最后安装cpu2006：

```
$ export SPEC_INSTALL_NOCHECK=1 
$ ./install.sh -u linux-riscv64 -d /home/chenxiaoou/spec/cpu2006_install
```

安装成功，显示如下：

![image](pictures/t32-3.png)
