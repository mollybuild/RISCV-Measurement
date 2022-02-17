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
