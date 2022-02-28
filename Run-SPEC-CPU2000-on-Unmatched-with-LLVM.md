# 在Unmatched开发板上运行SPEC CPU2000 （使用LLVM编译）

## 硬软件配置

- 开发板：Hifive unmatched board with 4 cores

- Memory: 16G

- DISK: 1T SSD

- OS: Ubuntu21.04

- Compiler: Clang 14.0.0

## Build error

#### 168.wupwise 178.galgel 187.facerec 191.fma3d 200.sixtrack 301.apsi

这些FP benchmark在编译时都有相似的报错，类似于：
```
flang_unparsed_file_e3b98667f33e_0.f90:240:26:

  240 |     CALL material_12_ini2(truss(n)%res%stress, matid, secid, isv, nsv)
      |                          1
Error: Rank mismatch in argument 'stress' at (1) (rank-1 and scalar)
```

```
flang_unparsed_file_687934ef6cf8_0.f90:2596:10:

 2596 |   vm(k) = xdimag(wm(k))
      |          1
Error: Type mismatch in argument 'qvar' at (1); passed COMPLEX(8) to REAL(8)
```

解决的方法是，如果系统的gfortran版本在10以上，那么在Fortran的编译选项中可以加上`-fallow-argument-mismatch`。

#### 252.eon

Build error 1
```
ggDiffuseMaterial.cc:36:33: error: cast from pointer to smaller type 'int' loses information
  s << "ggDiffuseMaterial. " << PTR_TO_INTEGRAL(this) <<
                                ^~~~~~~~~~~~~~~~~~~~
./kai.h:35:25: note: expanded from macro 'PTR_TO_INTEGRAL'
#define PTR_TO_INTEGRAL int
```

solution:
```
CXXPORTABILITY  = -DSPEC_CPU2000_LP64
```

Build error2
```
./ggRaster.cc:439:4: error: use of undeclared identifier 'memset'; did you mean 'wmemset'?
   memset((char*)(&filter[imax+1]),0,sizeof(double)*(size-imax));
   ^~~~~~
   wmemset
/usr/include/wchar.h:271:17: note: 'wmemset' declared here
extern wchar_t *wmemset (wchar_t *__s, wchar_t __c, size_t __n) __THROW;
                ^
In file included from mrSurfaceTexture.cc:28:
In file included from ./mrSurfaceTexture.h:33:
In file included from ./ggRasterSurfaceTexture.h:42:
In file included from ./ggRaster.h:189:
./ggRaster.cc:439:11: error: cannot initialize a parameter of type 'wchar_t *' with an rvalue of type 'char *'
   memset((char*)(&filter[imax+1]),0,sizeof(double)*(size-imax));
          ^~~~~~~~~~~~~~~~~~~~~~~~
/usr/include/wchar.h:271:35: note: passing argument to parameter '__s' here
extern wchar_t *wmemset (wchar_t *__s, wchar_t __c, size_t __n) __THROW;
```

solution:
```
CPORTABILITY = -include string.h
```

result:
```
252.eon           1300       303       430*
```

#### 300.twolf

```
addimp.c:158:1: error: non-void function 'addimp' should return a value [-Wreturn-type]
return ;
```

solution:
```
CPORTABILITY = -Wno-return-type
```

result:
```
300.twolf         3000       853       352*
```

## 完整的跑分情况

### FP SPEED

```
runspec --config linux-riscv64-llvm.cfg -n 1 -I --noreportable fp
```
```
   168.wupwise       1600       600       267*
   171.swim          3100      1928       161*
   172.mgrid         1800      1592       113*
   173.applu         2100      1409       149*
   177.mesa          1400       462       303*
   178.galgel        2900       823       352*
   179.art           2600       830       313*
   183.equake        1300       911       143*
   187.facerec       1900       429       443*
   188.ammp          2200       943       233*
   189.lucas         2000       756       265*
   191.fma3d         2100       865       243*
   200.sixtrack      1100       719       153*
   301.apsi          2600      1173       222*
   Est. SPECfp_base2000                   224
   Est. SPECfp2000                                                       --
```


### INT SPEED

```
runspec --config linux-riscv64-llvm.cfg -n 1 -I --noreportable int
```
```
   164.gzip          1400       595       235*
   175.vpr           1400       624       225*
   176.gcc           1100       335       329*
   181.mcf           1800       880       205*
   186.crafty        1000       240       417*
   197.parser        1800       823       219*
   252.eon           1300       301       432*
   253.perlbmk       1800       497       362*
   254.gap           1100       435       253*
   255.vortex        1900       544       349*
   256.bzip2         1500       608       247*
   300.twolf         3000       861       348*
   Est. SPECint_base2000                  292
   Est. SPECint2000                                                      --
```

## Config file

```
###############################################################################
# To run:
#     runspec --config linux-riscv64-llvm.cfg -n 1 -I --noreportable fp
###############################################################################


# Modify these variables according to your system, vendor, run environment etc.
# This is just an template, not my real HW/SW information.
company_name    = XYZ Inc.
hw_model        = ASUS SK8V, Opteron (TM) 150
hw_cpu          = AMD Opteron (TM) 150
hw_cpu_mhz      = 2400
hw_disk         = IDE, WD2000
hw_fpu          = Integrated
hw_memory       = 2 x 512 PC3200 DDR SDRAM CL2.0
hw_avail        = May-2003
test_date       =
sw_file         = Linux/ext3
sw_os           = SuSE Linux 9.2 for x86
hw_vendor       =
tester_name     = XYZ Inc.
license_num     = 9999
hw_ncpu         = 1
hw_ncpuorder    = 1
hw_ocache       = N/A
hw_other        = None
hw_parallel     = No
hw_pcache       = 64KBI + 64KBD on chip
hw_scache       = 1024KB(I+D) on chip
hw_tcache       = N/A
sw_state        = Multi-user SuSE Run level 3

VENDOR          =
action          = validate
tune            = base
output_format   = asc,html,config
ext             = clang10-low-opt

check_md5       = 1
reportable      = 1

teeout=yes
teerunout=yes

#
# NOTE: The F90 benchmarks will *not* work with this compiler
#       setting.
SPECLANG = /home/chenxiaoou/llvm-project/build-2/bin/

default=default=default=default:
CC      = $(SPECLANG)clang -I/usr/include/riscv64-linux-gnu -B/usr/lib/riscv64-linux-gnu
CXX     = $(SPECLANG)clang++ -I/usr/include/riscv64-linux-gnu -B/usr/lib/riscv64-linux-gnu
FC      = $(SPECLANG)flang -I/usr/include/riscv64-linux-gnu -B/usr/lib/riscv64-linux-gnu

################################################################
# Portability Flags
################################################################

168.wupwise=default=default=default:
EXTRA_FFLAGS = -fallow-argument-mismatch

178.galgel=default=default=default:
EXTRA_FFLAGS = -ffixed-form -FI -fallow-argument-mismatch

187.facerec=default=default=default:
EXTRA_FFLAGS = -fallow-argument-mismatch

186.crafty=default=default=default:
#CPORTABILITY   = -DLONG_HAS_64BITS -DLINUX
CPORTABILITY =   -DLINUX_i386 -DSPEC_CPU2000_LP64 -DLONG_HAS_64BITS -UHAS_LONGLONG

191.fma3d=default=default=default:
EXTRA_FFLAGS = -fallow-argument-mismatch

200.sixtrack=default=default=default:
EXTRA_FFLAGS = -fallow-argument-mismatch

252.eon=default=default=default:
CXXPORTABILITY  = -DHAS_ERRLIST -fpermissive -DUSE_STRERROR

253.perlbmk=default=default=default:
CPORTABILITY    = -DSPEC_CPU2000_NEED_BOOL -std=gnu89 -DI_FCNTL -DSPEC_CPU2000_GLIBC22 -DSPEC_CPU2000_DUNIX

254.gap=default=default=default:
#CPORTABILITY   = -DSYS_HAS_SIGNAL_PROTO -DSYS_HAS_MALLOC_PROTO -DSYS_HAS_CALLOC_PROTO -DSYS_IS_USG -DSYS_HAS_IOCTL_PROTO -DSYS_HAS_TIME_PROTO -D_GNU_SOURCE
CPORTABILITY = -DSPEC_CPU2000 -DSPEC_CPU2000_LP64 -DSYS

################################################################
# Baseline Tuning Flags
################################################################

#
# int2000
# Base tuning default optimization
#
int=base=clang10-low-opt=default:
notes0080=  Baseline C:   clang -O2
COPTIMIZE       = -O2
notes0085=  Baseline C++: g++ -O2
CXXOPTIMIZE     = -O2
feedback=0

int=base=clang10-high-opt=default:
notes0080=  Baseline C:   clang -O3 -funroll-all-loops
COPTIMIZE       = -O3 -funroll-all-loops
notes0085=  Baseline C++: g++ -O3 -funroll-all-loops
CXXOPTIMIZE     = -O3 -funroll-all-loops

int=peak=default=default:
basepeak=yes

fp=base=clang10-low-opt=default:
notes0080=  Baseline C,Fortran: -O2
COPTIMIZE       = -O2
FOPTIMIZE       = -O2

fp=base=clang10-high-opt=default:
notes0080=  Baseline C,Fortran: -O3 -funroll-all-loops_HAS_CALLOC_PROTO -DSYS_IS_USG -DSYS_HAS_IOCTL_PROTO -DSYS_HAS_TIME_PROTO -DSYS_HAS_SIGNAL_PROTO -DSYS_HAS_CALLOC_PROTO -DHOST_LINUX -fwrapv

255.vortex=default=default=default:
CPORTABILITY = -DSPEC_CPU2000_LP64

300.twolf=default=default=default:
CPORTABILITY = -DSPEC_CPU2000_LP64 -DHAVE_SIGNED_CHAR

301.apsi=default=default=default:
EXTRA_FFLAGS = -fallow-argument-mismatch

################################################################
# Baseline Tuning Flags
################################################################

#
# int2000
# Base tuning default optimization
#
int=base=clang10-low-opt=default:
notes0080=  Baseline C:   clang -O2
COPTIMIZE       = -O2
notes0085=  Baseline C++: g++ -O2
CXXOPTIMIZE     = -O2
feedback=0

int=base=clang10-high-opt=default:
notes0080=  Baseline C:   clang -O3 -funroll-all-loops
COPTIMIZE       = -O3 -funroll-all-loops
notes0085=  Baseline C++: g++ -O3 -funroll-all-loops
CXXOPTIMIZE     = -O3 -funroll-all-loops

int=peak=default=default:
basepeak=yes

fp=base=clang10-low-opt=default:
notes0080=  Baseline C,Fortran: -O2
COPTIMIZE       = -O2
FOPTIMIZE       = -O2

fp=base=clang10-high-opt=default:
notes0080=  Baseline C,Fortran: -O3 -funroll-all-loops
COPTIMIZE       = -O3 -funroll-all-loops
FOPTIMIZE       = -O3 -funroll-all-loops

fp=peak=default=default:
basepeak=yes

default=default=default=default:
notes0030=  Portability:
notes0086=  Peak tuning: basepeak=yes for all peak runs.
# change these variables according to your SUT
sw_avail= Dec-2003
sw_compiler0000= clang and g77 3.3.x compiler
```
