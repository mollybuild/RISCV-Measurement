## CPU2017

### GCC11.1.0

#### master commit 051b9f7 (2022.3.8)

riscv-gcc @ commit 5964b5c origin/riscv-gcc-11.1.0

#### Compiler options

-O3

#### intspeed

```
runcpu -c gcc-test.cfg --noreportable -n 1 -I -T base intspeed
```

```
                       Estimated                       Estimated
                 Base     Base        Base        Peak     Peak        Peak
Benchmarks      Threads  Run Time     Ratio      Threads  Run Time     Ratio
--------------- -------  ---------  ---------    -------  ---------  ---------
600.perlbench_s       4       5027      0.353  *
602.gcc_s             4       9537      0.418  *
605.mcf_s             4      16595      0.284  *
620.omnetpp_s         4       5762      0.283  *
623.xalancbmk_s       4       4466      0.317  *
625.x264_s            4       3777      0.467  *
631.deepsjeng_s       4       2728      0.525  *
641.leela_s           4       3123      0.546  *
648.exchange2_s       4       2314      1.27   *
657.xz_s              4       6952      0.889  *
=================================================================================
600.perlbench_s       4       5027      0.353  *
602.gcc_s             4       9537      0.418  *
605.mcf_s             4      16595      0.284  *
620.omnetpp_s         4       5762      0.283  *
623.xalancbmk_s       4       4466      0.317  *
625.x264_s            4       3777      0.467  *
631.deepsjeng_s       4       2728      0.525  *
641.leela_s           4       3123      0.546  *
648.exchange2_s       4       2314      1.27   *
657.xz_s              4       6952      0.889  *
 Est. SPECspeed(R)2017_int_base         0.474
 Est. SPECspeed(R)2017_int_peak                                        Not Run
```

#### intrate

```
runcpu -c gcc-test.cfg --noreportable -n 1 -I -T base intrate
```

```
                       Estimated                       Estimated
                 Base     Base        Base        Peak     Peak        Peak
Benchmarks       Copies  Run Time     Rate        Copies  Run Time     Rate
--------------- -------  ---------  ---------    -------  ---------  ---------
500.perlbench_r       4       5189      1.23   *
502.gcc_r             4       5933      0.955  *
505.mcf_r             4       9349      0.691  *
520.omnetpp_r         4       6844      0.767  *
523.xalancbmk_r       4       5311      0.795  *
525.x264_r            4       3860      1.81   *
531.deepsjeng_r       4       2149      2.13   *
541.leela_r           4       3185      2.08   *
548.exchange2_r       4       2316      4.53   *
557.xz_r              4       3750      1.15   *
=================================================================================
500.perlbench_r       4       5189      1.23   *
502.gcc_r             4       5933      0.955  *
505.mcf_r             4       9349      0.691  *
520.omnetpp_r         4       6844      0.767  *
523.xalancbmk_r       4       5311      0.795  *
525.x264_r            4       3860      1.81   *
531.deepsjeng_r       4       2149      2.13   *
541.leela_r           4       3185      2.08   *
548.exchange2_r       4       2316      4.53   *
557.xz_r              4       3750      1.15   *
 Est. SPECrate(R)2017_int_base          1.35
 Est. SPECrate(R)2017_int_peak                                         Not Run
```

#### fpspeed

```
runcpu -c gcc-test.cfg --noreportable -n 1 -I -T base fpspeed
```

```
                       Estimated                       Estimated
                 Base     Base        Base        Peak     Peak        Peak
Benchmarks      Threads  Run Time     Ratio      Threads  Run Time     Ratio
--------------- -------  ---------  ---------    -------  ---------  ---------
603.bwaves_s          4      34551      1.71   *
607.cactuBSSN_s       4      27334      0.610  *
619.lbm_s             4      17772      0.295  *
621.wrf_s             4      23516      0.562  *
627.cam4_s            1         --            CE
628.pop2_s            4      24543      0.484  *
638.imagick_s         4      23015      0.627  *
644.nab_s             4      17026      1.03   *
649.fotonik3d_s       4      14212      0.641  *
654.roms_s            4      39174      0.402  *
=================================================================================
603.bwaves_s          4      34551      1.71   *
607.cactuBSSN_s       4      27334      0.610  *
619.lbm_s             4      17772      0.295  *
621.wrf_s             4      23516      0.562  *
627.cam4_s                                    NR
628.pop2_s            4      24543      0.484  *
638.imagick_s         4      23015      0.627  *
644.nab_s             4      17026      1.03   *
649.fotonik3d_s       4      14212      0.641  *
654.roms_s            4      39174      0.402  *
 Est. SPECspeed(R)2017_fp_base          0.622
 Est. SPECspeed(R)2017_fp_peak                                         Not Run
```

#### fprate

```
runcpu -c gcc-test.cfg --noreportable -n 1 -I -T base fprate
```

```
                       Estimated                       Estimated
                 Base     Base        Base        Peak     Peak        Peak
Benchmarks       Copies  Run Time     Rate        Copies  Run Time     Rate
--------------- -------  ---------  ---------    -------  ---------  ---------
503.bwaves_r          4      20857      1.92   *
507.cactuBSSN_r       4      12189      0.415  *
508.namd_r            4       3481      1.09   *
510.parest_r          4      18263      0.573  *
511.povray_r          4       7609      1.23   *
519.lbm_r             4      13462      0.313  *
521.wrf_r             4      15302      0.586  *
526.blender_r         4       4015      1.52   *
527.cam4_r            4       9410      0.744  *
538.imagick_r         4       6747      1.47   *
544.nab_r             4       6688      1.01   *
549.fotonik3d_r       4      16166      0.964  *
554.roms_r            4      17760      0.358  *
=================================================================================
503.bwaves_r          4      20857      1.92   *
507.cactuBSSN_r       4      12189      0.415  *
508.namd_r            4       3481      1.09   *
510.parest_r          4      18263      0.573  *
511.povray_r          4       7609      1.23   *
519.lbm_r             4      13462      0.313  *
521.wrf_r             4      15302      0.586  *
526.blender_r         4       4015      1.52   *
527.cam4_r            4       9410      0.744  *
538.imagick_r         4       6747      1.47   *
544.nab_r             4       6688      1.01   *
549.fotonik3d_r       4      16166      0.964  *
554.roms_r            4      17760      0.358  *
 Est. SPECrate(R)2017_fp_base           0.810
 Est. SPECrate(R)2017_fp_peak                                          Not Run
```
