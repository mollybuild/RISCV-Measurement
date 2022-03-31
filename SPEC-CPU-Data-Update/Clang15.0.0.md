## CPU2017

### Clang 15.0.0

llvm-project源码版本：branch main, commit 7fd60ee6e0a87957a718297a4a42d9881fc561e3l

### Compiler Options

-O3

#### intspeed

```
runcpu -c clang14-riscv.cfg --noreportable -n 1 -I -T base intspeed
```

```
                       Estimated                       Estimated
                 Base     Base        Base        Peak     Peak        Peak
Benchmarks      Threads  Run Time     Ratio      Threads  Run Time     Ratio
--------------- -------  ---------  ---------    -------  ---------  ---------
600.perlbench_s       4       5769      0.308  *
602.gcc_s             4      10438      0.382  *
605.mcf_s             4      16915      0.279  *
620.omnetpp_s         4       5958      0.274  *
623.xalancbmk_s       4       4559      0.311  *
625.x264_s            4       3673      0.480  *
631.deepsjeng_s       4       3046      0.470  *
641.leela_s           4       4847            VE
648.exchange2_s       4       2431      1.21   *
657.xz_s              4       7164      0.863  *
=================================================================================
600.perlbench_s       4       5769      0.308  *
602.gcc_s             4      10438      0.382  *
605.mcf_s             4      16915      0.279  *
620.omnetpp_s         4       5958      0.274  *
623.xalancbmk_s       4       4559      0.311  *
625.x264_s            4       3673      0.480  *
631.deepsjeng_s       4       3046      0.470  *
641.leela_s                                   NR
648.exchange2_s       4       2431      1.21   *
657.xz_s              4       7164      0.863  *
 Est. SPECspeed(R)2017_int_base         0.443
 Est. SPECspeed(R)2017_int_peak                                        Not Run
```

#### intrate

```
runcpu -c clang14-riscv.cfg --noreportable -n 1 -I -T base intrate
```

```
                       Estimated                       Estimated
                 Base     Base        Base        Peak     Peak        Peak
Benchmarks       Copies  Run Time     Rate        Copies  Run Time     Rate
--------------- -------  ---------  ---------    -------  ---------  ---------
500.perlbench_r       4       5891      1.08   *
502.gcc_r             4       6070      0.933  *
505.mcf_r             4       9450      0.684  *
520.omnetpp_r         4       7039      0.746  *
523.xalancbmk_r       4       5409      0.781  *
525.x264_r            4       3748      1.87   *
531.deepsjeng_r       4       2425      1.89   *
541.leela_r           4       4978            VE
548.exchange2_r       4       2437      4.30   *
557.xz_r              4       3878      1.11   *
=================================================================================
500.perlbench_r       4       5891      1.08   *
502.gcc_r             4       6070      0.933  *
505.mcf_r             4       9450      0.684  *
520.omnetpp_r         4       7039      0.746  *
523.xalancbmk_r       4       5409      0.781  *
525.x264_r            4       3748      1.87   *
531.deepsjeng_r       4       2425      1.89   *
541.leela_r                                   NR
548.exchange2_r       4       2437      4.30   *
557.xz_r              4       3878      1.11   *
 Est. SPECrate(R)2017_int_base          1.24
 Est. SPECrate(R)2017_int_peak                                         Not Run
```

#### fpspeed

```
runcpu -c clang14-riscv.cfg --noreportable -n 1 -I -T base fpspeed
```

```
                       Estimated                       Estimated
                 Base     Base        Base        Peak     Peak        Peak
Benchmarks      Threads  Run Time     Ratio      Threads  Run Time     Ratio
--------------- -------  ---------  ---------    -------  ---------  ---------
603.bwaves_s         16     105507      0.559  *
607.cactuBSSN_s       1         --            CE
619.lbm_s            16      19291      0.272  *
621.wrf_s             1         --            CE
627.cam4_s            1         --            CE
628.pop2_s            1         --            CE
638.imagick_s        16      18886      0.764  *
644.nab_s            16      17986      0.971  *
649.fotonik3d_s      16      43884      0.208  *
654.roms_s            1         --            CE
=================================================================================
603.bwaves_s         16     105507      0.559  *
607.cactuBSSN_s                               NR
619.lbm_s            16      19291      0.272  *
621.wrf_s                                     NR
627.cam4_s                                    NR
628.pop2_s                                    NR
638.imagick_s        16      18886      0.764  *
644.nab_s            16      17986      0.971  *
649.fotonik3d_s      16      43884      0.208  *
654.roms_s                                    NR
 Est. SPECspeed(R)2017_fp_base          0.472
 Est. SPECspeed(R)2017_fp_peak                                         Not Run
```

#### fprate

```
runcpu -c clang14-riscv.cfg --noreportable -n 1 -I -T base fprate
```

```
                       Estimated                       Estimated
                 Base     Base        Base        Peak     Peak        Peak
Benchmarks       Copies  Run Time     Rate        Copies  Run Time     Rate
--------------- -------  ---------  ---------    -------  ---------  ---------
503.bwaves_r          4      21082      1.90   *
507.cactuBSSN_r       1         --            CE
508.namd_r            4       4757      0.799  *
510.parest_r          4      18178      0.576  *
511.povray_r          4       8963      1.04   *
519.lbm_r             4      13741      0.307  *
521.wrf_r             1         --            CE
526.blender_r         1         --            CE
527.cam4_r            1         --            CE
538.imagick_r         4       5813      1.71   *
544.nab_r             4       6882      0.978  *
549.fotonik3d_r       4      16236      0.960  *
554.roms_r            4      17845      0.356  *
=================================================================================
503.bwaves_r          4      21082      1.90   *
507.cactuBSSN_r                               NR
508.namd_r            4       4757      0.799  *
510.parest_r          4      18178      0.576  *
511.povray_r          4       8963      1.04   *
519.lbm_r             4      13741      0.307  *
521.wrf_r                                     NR
526.blender_r                                 NR
527.cam4_r                                    NR
538.imagick_r         4       5813      1.71   *
544.nab_r             4       6882      0.978  *
549.fotonik3d_r       4      16236      0.960  *
554.roms_r            4      17845      0.356  *
 Est. SPECrate(R)2017_fp_base           0.816
 Est. SPECrate(R)2017_fp_peak                                          Not Run
```
