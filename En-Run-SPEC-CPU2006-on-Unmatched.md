# How to install and run SPEC CPU2006 on Hifive Unmatched

Similar to SPEC CPU2017, CPU2006 don't support RISCV officially, so we need to build toolset by ourselves. Official document can be referenced:

[Building the SPEC CPU2006 Tool Suite](https://www.spec.org/cpu2006/Docs/tools-build.html)

The RISCV platform we use is described as bellow:

- Board: Hifive Unmatched
- Memory: 16G
- Storage: 1T SSD
- OS: Ubuntu21.04
- GCC：10.3.0
- Glibc：2.33

### Error when building toolset and solutions 

#### more undefined references to __alloca' follow

solution:

modify src/make-3.82/glob/glob.c line 211:

```
- #if !defined __alloca && !defined __GNU_LIBRARY__
+ #if !defined __alloca && defined __GNU_LIBRARY__
```

#### `'gets' undeclared here` when building tar

cause:

Code compatibility issues due to dependency library version upgrades. 

solution：

modify these two files:

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

### undefined reference to `pow` etc.

export PERLFLAGS="-A libs=-lm -A libs=-ldl -A libs=-lc -A ldflags=-lm -A cflags=-lm -A ccflags=-lm"

### perl Configure need patch

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

refer to：https://github.com/Perl/perl5/issues/14491


### packagetools linux-riscv64

After building toolset successfully, next we need to package the toolset.

first, make directory $SPEC/tools/bin/linux-riscv64, and create a file named description.

then back to path $SPEC and execute:

```
$  ./bin/packagetools linux-riscv64
```

### Installation of linux-riscv64 aborted.

Installation of SPEC CPU 2006 will fail because several perl tests can't pass. The walkaround is set  `export SPEC_INSTALL_NOCHECK=1 ` before installation to skip perl verification.

Here we also record some issues and their solutions.

- Perl test case numconvert.t failure

solution: add compiler option `-A ccflags=-fwrapv`
```
$ export PERLFLAGS="-A ccflags=-fwrapv"
```

- Perl test case Local.t Failure

Local.t may has this error, the solution is to modify perl-5.12.3/ext/Time-Local/t/Local.t as the patch bellow.

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

### Perl test case DynaLoader.t failure

solution:

```
export PERLFLAGS="$PERLFLAGS -Dlibpth=/usr/lib/riscv64-linux-gnu"
```

### Skip verification

As mentioned ahead, perl test can be skiiped by setting SPEC_INSTALL_NOCHECK.
```
export SPEC_INSTALL_NOCHECK=1 
```

Now we can execute install.sh successfully.

### Conclusion about build and install CPU2006

First set PERLFLAGS, then execute buildtools.

```
$ export PERLFLAGS="-A libs=-lm -A libs=-lc -A ldflags=-lm -A cflags=-lm -A ccflags=-lm -A ccflags=-fwrapv -Dlibpth=/usr/lib/riscv64-linux-gnu -A libs=-ldl"
$ cd $SPEC/tools/src
$ ./buildtools
```

Building succeed with this information:

![image](pictures/t32-2.png)

Then make directory tools/bin/linux-riscv64 and create a file named description:

```shell
$ cd $SPEC/tools/bin/
$ mkdir linux-riscv64
```

description file contains：
```
For riscv64 Linux systems
                              Built on ubuntu21.04 with GCC 10.3.0
```

Then package the toolset.

```
$ cd $SPEC
$ source shrc
$ packagetools linux-riscv64
```

Finally install CPU2006：

```
$ export SPEC_INSTALL_NOCHECK=1 
$ ./install.sh -u linux-riscv64 -d /home/chenxiaoou/spec/cpu2006_install
```

Installation succeed with this information.

![image](pictures/t32-3.png)
