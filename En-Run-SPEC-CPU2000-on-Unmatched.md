# How to install and run SPEC CPU2000 on Hifive unmatched

##  Build toolset

About how to build toolset we can refer SPEC website:

https://www.spec.org/cpu2000/docs/tools_build.txt

While building toolset, we encountered these issues as following.

#### 1. replace config.guess and config.sub for the tools bellow

We need replace config files for specinvoke, make-3.80, tar-1.15.1, and the config file paths are as follow:
```
./specinvoke/config.guess
./make-3.80/config/config.guess
./tar-1.15.1/config/config.guess
```
(config.guess and config.sub are under the same directory)


#### 2. undefined reference to `__alloca'

error information:

```
glob.c:(.text+0x126e): undefined reference to `__alloca'
/usr/bin/ld: glob.c:(.text+0x13dc): undefined reference to `__alloca'
/usr/bin/ld: glob.c:(.text+0x147c): undefined reference to `__alloca'
collect2: error: ld returned 1 exit status
```

solution:

modify make-3.80/glob/glob.c line 209：
```
#if !defined __alloca && defined __GNU_LIBRARY__
```

#### 3. undefined reference to `__stat'

error information:

```
linking make...
/usr/bin/ld: glob.o: in function `.L57':
glob.c:(.text+0x7d8): undefined reference to `__stat'
/usr/bin/ld: glob.o: in function `.L82':
glob.c:(.text+0xb2a): undefined reference to `__stat'
/usr/bin/ld: glob.o: in function `.L71':
glob.c:(.text+0xd5e): undefined reference to `__stat'
/usr/bin/ld: glob.o: in function `.L134':
glob.c:(.text+0x1274): undefined reference to `__stat'
collect2: error: ld returned 1 exit status
```

solution

modify make-3.80/glob/glob.c：
```
# if _GNU_GLOB_INTERFACE_VERSION == GLOB_INTERFACE_VERSION 
```
to
```
# if _GNU_GLOB_INTERFACE_VERSION >= GLOB_INTERFACE_VERSION
```

#### 4. format incompatible

error information: 

```
md5sum.c: In function 'main':
md5sum.c:682:15: warning: format '%X' expects argument of type 'unsigned int', but argument 2 has type 'size_t' {aka 'long unsigned int'} [-Wformat=]
  682 |   printf ("%08X", size);
      |            ~~~^   ~~~~
      |               |   |
      |               |   size_t {aka long unsigned int}
      |               unsigned int
      |            %08lX
make: *** [md5sum.o] Error 1
```

solution:

modify specmd5sum/md5sum.c：
```
printf ("%08X", size);
```
to
```
printf ("%08lX", size);
```

#### 5. error: conflicting types for 'getline'

error information

```
sed -i "s/getline/getline1/g" `grep getline -rl $HOME/spec/cpu2000/tools/src/specmd5sum`
```

#### 6. fatal error: getline1.h: No such file or directory

After modifying specmd5sum，this error comes up.

```
gcc -DHAVE_CONFIG_H    -I/home/xxx/spec/cpu2000/tools/output/include   -I. -Ilib  -c -o md5sum.o md5sum.c
md5sum.c:38:10: fatal error: getline1.h: No such file or directory
   38 | #include "getline1.h"
      |          ^~~~~~~~~~~~
compilation terminated.
make: *** [md5sum.o] Error 1
```

solution:

rename lib/getline.h lib/getline.c to lib/getline1.h and lib/getline1.c

#### 7. error: conflicting types for 'getdelim'

![image](pictures/t33-1.png)


#### 8. make: *** No rule to make target <command-line>', needed byminiperlmain.o’. Stop

Can't fix this error, the walk-around is to replace perl-5.8.7 with perl-5.12.3 in SPEC CPU2006 toolset.

In addition, need to  comment this line in buildtools script.
```
# [ -f $i/spec_do_no_tests ] || ($MYMAKE test; testordie "error running $i test suite")
```

Then running buildtools will be OK：

![image](pictures/t33-4.png)

## Packagetools and install

After building toolset successfully，then we need to package the toolset and install SPEC CPU 2000. The commands are as following:
```
$ cd $SPEC
$ source shrc
$ packagetools linux-riscv64
$ export SPEC_INSTALL_NOCHECK=1
$ ./install.sh -u linux-riscv64
```

## Running CPU2000

INT RATE
```
runspec --config linux-riscv64.cfg -n 1 --noreportable --rate --users 4 int
```
INT SPEED
```
runspec --config linux-riscv64.cfg -n 1 --noreportable int
```
FP RATE
```
runspec --config linux-riscv64.cfg -n 1 --noreportable --rate --users 4 fp
```
FP SPEED
```
runspec --config linux-riscv64.cfg -n 1 --noreportable fp
```
