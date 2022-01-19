# How to install and run SPEC CPU2017 on Hifive unmatched

### CPU2017 system requirements 

  - 1 to 2 GB of main memory to run SPECrate (per copy); 16 GB for SPECspeed.
  - 250 GB disk space is recommended; a minimal installation needs 10 GB.
  - C, C++, and Fortran compilers (or a set of pre-compiled binaries from another CPU 2017 user).
  A variety of chips and operating systems are supported.

## Building toolset

SPEC CPU running process need some tools, like spectar,specperl etc. These tools are just wrappers for open sources tools. SPEC doesn't support RISCV officially, so we need to build this tool set by hand. There is an officail help document can be referred.

https://www.spec.org/cpu2017/Docs/tools-build.html

The issues that we met are listed in the following.

### Issues when building toolset for RISCV

In order for packagetools script to package toolset after building, we'd better untar $SPEC/install_archives/tools-src.tar to $SPEC/tools directory.

#### 1. replace config.guess and config.sub

The config.guess and config.sub files of the following tools need to be replaced. These files are too old。

```
./specinvoke/config.guess
./specsum/build-aux/config.guess
./tar-1.28/build-aux/config.guess
./make-4.2.1/config/config.guess
./rxp-1.5.0/config.guess
./expat-2.1.0/conftools/config.guess
./xz-5.2.2/build-aux/config.guess
```

The two files can be replaced with files in these links:

http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess

http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub

#### 2. Can't locate FindBin.pm

Error message
```
make[2]: Entering directory '/home/riscv/benchmarks/tools/src/make-4.2.1'^M
cd tests && perl ./run_make_tests.pl -srcdir /home/riscv/benchmarks/tools/src/maa
ke-4.2.1 -make ../make ^M
Can't locate FindBin.pm in @INC (you may need to install the FindBin module) (@II
NC contains: /usr/local/lib64/perl5/5.32 /usr/local/share/perl5/5.32 /usr/lib64//
perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl55
) at ./run_make_tests.pl line 32.^M
BEGIN failed--compilation aborted at ./run_make_tests.pl line 32.^M
```

Solution ：`sudo dnf install perl`

#### 3. perl bug when compile with gcc10

![image](pictures/t31-1.png)

Due to compile config files bug of perl on gcc10, we need to modify Configure and cflags.SH files. Replace `1*` with `1.*` in sentence `case "$gccversion"`

#### 4. TimeDate error

![image](pictures/t31-2.png)

This is a bug. This test will fail after 2020. Need to modify TimeDate-2.30/t/getdate.t

```
require Time::Local;
-my $offset = Time::Local::timegm(0,0,0,1,0,70);
+my $offset = Time::Local::timegm(0,0,0,1,0,1970);
```

#### 5. read only issue

![image](pictures/t31-4.png)

Solution: Copy all from cpu_mount to new directory, and add write permission to the new directory.

```
$ mkdir cpu2017
$ cp -r cpu_mount/* cpu2017/
$ chmod -R +w cpu2017
```

#### 6. missing makeinfo

![image](pictures/t31-5.png)

sudo dnf install texinfo

#### Set some environment variables

Before running buildtools, we can set some enviroment variables, like set MAKEFLAGS to use multithreaded compilation.

```
$ export MAKEFLAGS=-j4
$ ./buildtools
```
### Use packagetools to generate directory $SPEC/tools/bin/linux-riscv64

After building toolset, we need to use packagetools to generate directory $SPEC/tools/bin/linux-riscv64.

If buildtools finished successfully, there will be tools like specperl, spectar, specxz under $SPEC/bin directory.

Then we can make $SPEC/tools/bin/linux-riscv64 by hand, and create a file named description under it.  The content of description looks like:

```shell
For riscv64 Linux systems
                              Built on Qemu Fedora  5.10.6-200.0.riscv64.fc33.rii
                              scv64 with GCC 10.3.1 20210422 (Red Hat 10.3.1-1)
```

Finally, back to $SPEC,  and run this command under $SPEC:

```shell
$ ./bin/packagetools linux-riscv64
```
When finished, there will be this prompt.

![image](pictures/t31-6.png)

And some files are generated under $SPEC/tools/bin/linux-riscv64:

![image](pictures/t31-7.png)


### Install CPU2017

```shell
$ ./install.sh -u linux-riscv64 -d /home/riscv/benchmarks/cpu2017_install
```

![image](pictures/t31-8.png)

### Run SPEC CPU

Before running SPEC CPU, we need to set stack size to unlimited:
```
$ ulimit -s unlimited
```

INT SPEED
```
runcpu -c gcc-test.cfg --noreportable -n 1 -I -T base intspeed
```

INT RATE
```
runcpu -c gcc-test.cfg --noreportable -n 1 -I -T base -C 4 intrate
```

FP SPEED
```
runcpu -c gcc-test.cfg --noreportable -n 1 -I -T base fpspeed
```

FP RATE
```
runcpu -c gcc-test.cfg --noreportable -n 1 -I -T base -C 4 fprate
```

### Config file

#### difference between GCC9 and GCC10

Notice line 160 in config file:

```
%define GCCge10  # EDIT: remove the '#' from column 1 if using GCC 10 or later
```

IF GCC version is before 10, this line should be commented. Otherwise, will cause this error:

```
gfortran: error: unrecognized command line option '-fallow-argument-mismatch'; dd id you mean '-Wno-argument-mismatch'?
```
Becuase flag `-fallow-argument-mismatch` is newly introduced in GCC10.

#### Config file we use for GCC

```
#------------------------------------------------------------------------------
# SPEC CPU(R) 2017 config for gcc/g++/gfortran on Linux x86
#------------------------------------------------------------------------------
#
# Usage: (1) Copy this to a new name
#             cd $SPEC/config
#             cp Example-x.cfg myname.cfg
#        (2) Change items that are marked 'EDIT' (search for it)
#
# SPEC tested this config file with:
#    Compiler version(s):    Various.  See note "Older GCC" below.
#    Operating system(s):    Oracle Linux Server 6, 7, 8  /
#                            Red Hat Enterprise Linux Server 6, 7, 8
#                            SUSE Linux Enterprise Server 15
#                            Ubuntu 19.04
#    Hardware:               Xeon, EPYC
#
# If your system differs, this config file might not work.
# You might find a better config file at https://www.spec.org/cpu2017/results
#
# Note: Older GCC
#
#   Please use the newest GCC that you can. The default version packaged with
#   your operating system may be very old; look for alternate packages with a
#   newer version.
#
#   If you have no choice and must use an old version, here is what to expect:
#
#    - "peak" tuning: Several benchmarks will fail at peak tuning if you use
#                     compilers older than GCC 7.
#                     In that case, please use base only.
#                     See: https://www.spec.org/cpu2017/Docs/overview.html#Q16
#                          https://www.spec.org/cpu2017/Docs/config.html#tune
#                     Peak tuning is expected to work for all or nearly all
#                     benchmarks as of GCC 7 or later.
#                     Exception:
#                        - See topic "628.pop2_s basepeak", below.
#
#    - "base" tuning: This config file is expected to work for base tuning with
#                     GCC 4.8.5 or later
#                     Exception:
#                      - Compilers vintage about 4.9 may need to turn off the
#                        tree vectorizer, by adding to the base OPTIMIZE flags:
#                             -fno-tree-loop-vectorize
#
# Unexpected errors?  Try reducing the optimization level, or try removing:
#                           -march=native
#
# Compiler issues: Contact your compiler vendor, not SPEC.
# For SPEC help:   https://www.spec.org/cpu2017/Docs/techsupport.html
#------------------------------------------------------------------------------


#--------- Label --------------------------------------------------------------
# Arbitrary string to tag binaries (no spaces allowed)
#                  Two Suggestions: # (1) EDIT this label as you try new ideas.
%ifndef %{label}
%   define label "gcc-test"           # (2)      Use a label meaningful to *you*.
%endif


#--------- Preprocessor -------------------------------------------------------
%ifndef %{bits}                # EDIT to control 32 or 64 bit compilation.  Or,
%   define  bits        64     #      you can set it on the command line using:
%endif                         #      'runcpu --define bits=nn'

%ifndef %{build_ncpus}         # EDIT to adjust number of simultaneous compiles.
%   define  build_ncpus 4      #      Or, you can set it on the command line:
%endif                         #      'runcpu --define build_ncpus=nn'

# Don't change this part.
%if %{bits} == 64
%   define model        -march=rv64imafdc
%elif %{bits} == 32
%   define model        -march=rv32
%else
%   error Please define number of bits - see instructions in config file
%endif
%if %{label} =~ m/ /
%   error Your label "%{label}" contains spaces.  Please try underscores instead.
%endif
%if %{label} !~ m/^[a-zA-Z0-9._-]+$/
%   error Illegal character in label "%{label}".  Please use only alphanumerics, underscore, hyphen, and period.
%endif


#--------- Global Settings ----------------------------------------------------
# For info, see:
#            https://www.spec.org/cpu2017/Docs/config.html#fieldname
#   Example: https://www.spec.org/cpu2017/Docs/config.html#tune

command_add_redirect = 1
flagsurl             = $[top]/config/flags/gcc.xml
ignore_errors        = 1
iterations           = 1
label                = %{label}-m%{bits}
line_width           = 1020
log_line_width       = 1020
makeflags            = --jobs=%{build_ncpus}
mean_anyway          = 1
output_format        = txt,html,cfg,pdf,csv
preenv               = 1
reportable           = 0
tune                 = base,peak  # EDIT if needed: set to "base" for old GCC.
                                  #      See note "Older GCC" above.
#--------- How Many CPUs? -----------------------------------------------------
# Both SPECrate and SPECspeed can test multiple chips / cores / hw threads
#    - For SPECrate,  you set the number of copies.
#    - For SPECspeed, you set the number of threads.
# See: https://www.spec.org/cpu2017/Docs/system-requirements.html#MultipleCPUs
#
#    q. How many should I set?
#    a. Unknown, you will have to try it and see!
#
# To get you started, some suggestions:
#
#     copies - This config file defaults to testing only 1 copy.   You might
#              try changing it to match the number of cores on your system,
#              or perhaps the number of virtual CPUs as reported by:
#                     grep -c processor /proc/cpuinfo
#              Be sure you have enough memory.  See:
#              https://www.spec.org/cpu2017/Docs/system-requirements.html#memory
#
#     threads - This config file sets a starting point.  You could try raising
#               it.  A higher thread count is much more likely to be useful for
#               fpspeed than for intspeed.
#
intrate,fprate:
   copies           = 4   # EDIT to change number of copies (see above)
intspeed,fpspeed:
   threads          = 4   # EDIT to change number of OpenMP threads (see above)


#------- Compilers ------------------------------------------------------------
default:
#  EDIT: The parent directory for your compiler.
#        Do not include the trailing /bin/
#        Do not include a trailing slash
#  Examples:
#   1  On a Red Hat system, you said:
#      'yum install devtoolset-9'
#      Use:                 %   define gcc_dir "/opt/rh/devtoolset-9/root/usr"
#
#   2  You built GCC in:                        /disk1/mybuild/gcc-10.1.0/bin/gcc
#      Use:                 %   define gcc_dir "/disk1/mybuild/gcc-10.1.0"
#
#   3  You want:                                /usr/bin/gcc
#      Use:                 %   define gcc_dir "/usr"
#      WARNING: See section "Older GCC" above.
#
%ifndef %{gcc_dir}
%   define  gcc_dir        "/usr"  # EDIT  above)
%endif

# EDIT: If your compiler version is 10 or greater, you must enable the next
#       line to avoid compile errors for several FP benchmarks
#
%define GCCge10  # EDIT: remove the '#' from column 1 if using GCC 10 or later

# EDIT if needed: the preENV line adds library directories to the runtime
#      path.  You can adjust it, or add lines for other environment variables.
#      See: https://www.spec.org/cpu2017/Docs/config.html#preenv
#      and: https://gcc.gnu.org/onlinedocs/gcc/Environment-Variables.html
   #preENV_LD_LIBRARY_PATH  = %{gcc_dir}/lib64/:%{gcc_dir}/lib/:/lib64
  #preENV_LD_LIBRARY_PATH  = %{gcc_dir}/lib64/:%{gcc_dir}/lib/:/lib64:%{ENV_LD_LIBRARY_PATH}
   SPECLANG                = %{gcc_dir}/bin/
   CC                      = $(SPECLANG)gcc     -std=c99   %{model}
   CXX                     = $(SPECLANG)g++     -std=c++03 %{model}
   FC                      = $(SPECLANG)gfortran           %{model}
   # How to say "Show me your version, please"
   CC_VERSION_OPTION       = --version
   CXX_VERSION_OPTION      = --version
   FC_VERSION_OPTION       = --version

default:
%if %{bits} == 64
   sw_base_ptrsize = 64-bit
   sw_peak_ptrsize = 64-bit
%else
   sw_base_ptrsize = 32-bit
   sw_peak_ptrsize = 32-bit
%endif


#--------- Portability --------------------------------------------------------
default:               # data model applies to all benchmarks
%if %{bits} == 32
    # Strongly recommended because at run-time, operations using modern file
    # systems may fail spectacularly and frequently (or, worse, quietly and
    # randomly) if a program does not accommodate 64-bit metadata.
    EXTRA_PORTABILITY = -D_FILE_OFFSET_BITS=64
%else
    EXTRA_PORTABILITY = -DSPEC_LP64
%endif

# Benchmark-specific portability (ordered by last 2 digits of bmark number)

500.perlbench_r,600.perlbench_s:  #lang='C'
%if %{bits} == 32
%   define suffix IA32
%else
%   define suffix X64
%endif
   PORTABILITY   = -DSPEC_LINUX_%{suffix}

521.wrf_r,621.wrf_s:  #lang='F,C'
   CPORTABILITY  = -DSPEC_CASE_FLAG
   FPORTABILITY  = -fconvert=big-endian
523.xalancbmk_r,623.xalancbmk_s:  #lang='CXX'
   PORTABILITY   = -DSPEC_LINUX

526.blender_r:  #lang='CXX,C'
   PORTABILITY   = -funsigned-char -DSPEC_LINUX

527.cam4_r,627.cam4_s:  #lang='F,C'
   PORTABILITY   = -DSPEC_CASE_FLAG

628.pop2_s:  #lang='F,C'
   CPORTABILITY  = -DSPEC_CASE_FLAG
   FPORTABILITY  = -fconvert=big-endian

#----------------------------------------------------------------------
#       GCC workarounds that do not count as PORTABILITY
#----------------------------------------------------------------------
# The workarounds in this section would not qualify under the SPEC CPU
# PORTABILITY rule.
#   - In peak, they can be set as needed for individual benchmarks.
#   - In base, individual settings are not allowed; set for whole suite.
# See:
#     https://www.spec.org/cpu2017/Docs/runrules.html#portability
#     https://www.spec.org/cpu2017/Docs/runrules.html#BaseFlags
#
# Integer workarounds - peak
#
   500.perlbench_r,600.perlbench_s=peak:    # https://www.spec.org/cpu2017/Docs/benchmarks/500.perlbench_r.html
      EXTRA_CFLAGS = -fno-strict-aliasing -fno-unsafe-math-optimizations -fno-finite-math-only
   502.gcc_r,602.gcc_s=peak:                # https://www.spec.org/cpu2017/Docs/benchmarks/502.gcc_r.html
      EXTRA_CFLAGS = -fno-strict-aliasing -fgnu89-inline
   505.mcf_r,605.mcf_s=peak:                # https://www.spec.org/cpu2017/Docs/benchmarks/505.mcf_r.html
      EXTRA_CFLAGS = -fno-strict-aliasing
   525.x264_r,625.x264_s=peak:              # https://www.spec.org/cpu2017/Docs/benchmarks/525.x264_r.html
      EXTRA_CFLAGS = -fcommon
 #
# Integer workarounds - base - combine the above - https://www.spec.org/cpu2017/Docs/runrules.html#BaseFlags
#
   intrate,intspeed=base:
      EXTRA_CFLAGS = -fno-strict-aliasing -fno-unsafe-math-optimizations -fno-finite-math-only -fgnu89-inline -fcommon
#
# Floating Point workarounds - peak
#
   511.povray_r=peak:                       # https://www.spec.org/cpu2017/Docs/benchmarks/511.povray_r.html
      EXTRA_CFLAGS = -fno-strict-aliasing
   521.wrf_r,621.wrf_s=peak:                # https://www.spec.org/cpu2017/Docs/benchmarks/521.wrf_r.html
%     ifdef %{GCCge10}                      # workaround for GCC v10 (and presumably later)
         EXTRA_FFLAGS = -fallow-argument-mismatch
%     endif
   527.cam4_r,627.cam4_s=peak:              # https://www.spec.org/cpu2017/Docs/benchmarks/527.cam4_r.html
      EXTRA_CFLAGS = -fno-strict-aliasing
%     ifdef %{GCCge10}                      # workaround for GCC v10 (and presumably later)
         EXTRA_FFLAGS = -fallow-argument-mismatch
%     endif
   # See also topic "628.pop2_s basepeak" below
   628.pop2_s=peak:                         # https://www.spec.org/cpu2017/Docs/benchmarks/628.pop2_s.html
%     ifdef %{GCCge10}                      # workaround for GCC v10 (and presumably later)
         EXTRA_FFLAGS = -fallow-argument-mismatch
%     endif
#
# FP workarounds - base - combine the above - https://www.spec.org/cpu2017/Docs/runrules.html#BaseFlags
#
   fprate,fpspeed=base:
      EXTRA_CFLAGS = -fno-strict-aliasing
%     ifdef %{GCCge10}                      # workaround for GCC v10 (and presumably later)
         EXTRA_FFLAGS = -fallow-argument-mismatch
%     endif
#-------- Tuning Flags common to Base and Peak --------------------------------
#
# Speed (OpenMP and Autopar allowed)
#
%if %{bits} == 32
   intspeed,fpspeed:
   #
   # Many of the speed benchmarks (6nn.benchmark_s) do not fit in 32 bits
   # If you wish to run SPECint2017_speed or SPECfp2017_speed, please use
   #
   #     runcpu --define bits=64
   #
   fail_build = 1
%else
   intspeed,fpspeed:
      EXTRA_OPTIMIZE = -fopenmp -DSPEC_OPENMP
   fpspeed:
      #
      # 627.cam4 needs a big stack; the preENV will apply it to all
      # benchmarks in the set, as required by the rules.
      #
      preENV_OMP_STACKSIZE = 120M
%endif

#--------  Base Tuning Flags ----------------------------------------------
# EDIT if needed -- If you run into errors, you may need to adjust the
#                   optimization - for example you may need to remove
#                   the -march=native.   See topic "Older GCC" above.
#
default=base:     # flags for all base
   OPTIMIZE       = -g -O3 -march=rv64imafdc -flto
   COPTIMIZE      = -ffast-math
#--------  Peak Tuning Flags ----------------------------------------------
default=peak:
   OPTIMIZE         = -g -Ofast -march=rv64imafdc -flto
   PASS1_FLAGS      = -fprofile-generate
   PASS2_FLAGS      = -fprofile-use

# 628.pop2_s basepeak: Depending on the interplay of several optimizations,
#            628.pop2_s might not validate with peak tuning.  Use the base
#            version instead.  See:
#            https:// www.spec.org/cpu2017/Docs/benchmarks/628.pop2_s.html
628.pop2_s=peak:
   basepeak         = yes


#------------------------------------------------------------------------------
# Tester and System Descriptions - EDIT all sections below this point
#------------------------------------------------------------------------------
#   For info about any field, see
#             https://www.spec.org/cpu2017/Docs/config.html#fieldname
#   Example:  https://www.spec.org/cpu2017/Docs/config.html#hw_memory
#-------------------------------------------------------------------------------

#--------- EDIT to match your version -----------------------------------------
default:
   sw_compiler001   = C/C++/Fortran: Version 10.3.0 of GCC, the
   sw_compiler002   = GNU Compiler Collection

#--------- EDIT info about you ------------------------------------------------
# To understand the difference between hw_vendor/sponsor/tester, see:
#     https://www.spec.org/cpu2017/Docs/config.html#test_sponsor
intrate,intspeed,fprate,fpspeed: # Important: keep this line
   hw_vendor          = SiFive
   tester             = PLCT
   test_sponsor       = PLCT
   license_num        = 0
#  prepared_by        = # Ima Pseudonym                       # Whatever you like: is never output


#--------- EDIT system availability dates -------------------------------------
intrate,intspeed,fprate,fpspeed: # Important: keep this line
                        # Example                             # Brief info about field
   hw_avail           = Sep-2021                            # Date of LAST hardware component to ship
   sw_avail           = Apr-20i21                            # Date of LAST software component to ship
   fw_bios            = 1.0.0 released Sep-2021    # Firmware information

#--------- EDIT system information --------------------------------------------
intrate,intspeed,fprate,fpspeed: # Important: keep this line
                        # Example                             # Brief info about field
  hw_cpu_name        = SiFive U74               # chip name
   hw_cpu_nominal_mhz = 1433MHz                                # Nominal chip frequency, in MHz
   hw_cpu_max_mhz     = 1536MHz                                # Max chip frequency, in MHz
#  hw_disk            = # 9 x 9 TB SATA III 9999 RPM          # Size, type, other perf-relevant info
   hw_model           =  hifive unmatched                   # system model name
  hw_nchips          =  1                                  # number chips enabled
   hw_ncores          = 4                                # number cores enabled
#   hw_ncpuorder       = 1                           # Ordering options
   hw_nthreadspercore = 1                                   # number threads enabled per core
   hw_other           = None              # Other perf-relevant hw, or "None"

#  hw_memory001       = # 999 GB (99 x 9 GB 2Rx4 PC4-2133P-R, # The 'PCn-etc' is from the JEDEC
#  hw_memory002       = # running at 1600 MHz)                # label on the DIMM.

   hw_pcache          =  32 KB I + 32 KB D on chip per core  # Primary cache size, type, location
   hw_scache          = None       # Second cache or "None"
   hw_tcache          = None           # Third  cache or "None"
   hw_ocache          = None  # Other cache or "None"
#  sw_file            = # ext99                               # File system
#  sw_os001           = # Linux Sailboat                      # Operating system
#  sw_os002           = # Distribution 7.2 SP1                # and version
   sw_other           = None              # Other perf-relevant sw, or "None"
#  sw_state           = # Run level 99                        # Software state.

#   power_management   = # briefly summarize power settings

# Note: Some commented-out fields above are automatically set to preliminary
# values by sysinfo
#       https://www.spec.org/cpu2017/Docs/config.html#sysinfo
# Uncomment lines for which you already know a better answer than sysinfo
```

#### Config file we use for LLVM

```

```
