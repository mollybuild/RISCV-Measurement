#!/bin/bash
set -v

# 1. collect all source code repos url for iterate and test.
#
# 2. construct the for loop to iterate all the source code repos
# In the loop, we have following operations:
# 2.1 clone riscv-gnu-toolchain, swith to current ext riscv-gcc/riscv-binutils branch and newest commit.
# 2.2 build and run testsuite.
# 2.3 run testsuite with simulator if needed.
#
# left issues: 1, like zfinx, both has 32 and 64 bit version. so need to take bit into consideration.
# 2.like zfinx, qemu also modified. but others not.

nproc=`cat /proc/cpuinfo| grep "processor"| wc -l`
RISCV64=$HOME/RISCV64
RISCV32=$HOME/RISCV32
mirror_GNU_toolchain=riscv-gnu-toolchain.20210207.tbz

#         0 1 2 3 4
ins_exts=(B K V P Zfinx)

gcc_repos[0]=https://github.com/pz9115/riscv-gcc/tree/riscv-gcc-10.2.0-rvb
gcc_repos[1]=https://github.com/WuSiYu/riscv-gcc/tree/riscv-gcc-10.2.0-crypto
gcc_repos[2]=https://github.com/riscv/riscv-gcc/tree/riscv-gcc-10.1-rvv-dev
gcc_repos[3]=https://github.com/linsinan1995/riscv-gcc/tree/riscv-gcc-experiment-p-ext
gcc_repos[4]=https://github.com/pz9115/riscv-gcc/tree/riscv-gcc-10.2.0-zfinx

binutils_repos[0]=https://github.com/pz9115/riscv-binutils-gdb/tree/riscv-binutils-experiment
binutils_repos[1]=https://github.com/pz9115/riscv-binutils-gdb/tree/riscv-binutils-2.36-k-ext
binutils_repos[2]=https://github.com/riscv/riscv-binutils-gdb/tree/rvv-1.0.x
binutils_repos[3]=https://github.com/linsinan1995/riscv-binutils-gdb/tree/riscv-binutils-experiment-p-ext
binutils_repos[4]=https://github.com/pz9115/riscv-binutils-gdb/tree/riscv-binutils-2.35-zfinx

arch64[0]=rv64gc_zba_zbb_zbc_zbe_zbf_zbm_zbp_zbr_zbs_zbt
arch64[1]=rv64imafdck
arch64[2]=rv64gcv
arch64[3]=rv64gc_zpn_zprv_zpsf
arch64[4]=rv64gc

abi64[0]=lp64d
abi64[1]=lp64d
abi64[2]=lp64d
abi64[3]=lp64d
abi64[4]=lp64d

arch32[0]=rv32gc_zba_zbb_zbc_zbe_zbf_zbm_zbp_zbr_zbs_zbt
arch32[1]=rv32imafdck
arch32[2]=rv32gcv #ToCheck
arch32[3]=rv32gc_zpn_zpsf
arch32[4]=rv32gc

abi32[0]=ilp32d
abi32[1]=ilp32d
abi32[2]=ilp32d #ToCheck
abi32[3]=ilp32d
abi32[4]=ilp32d

mkdir $RISCV64
mkdir $RISCV32

# Prerequisites

echo 'cxom313' | sudo -S apt install -y autoconf python gawk wget git build-essential tcl \
expect flex texinfo bison libpixman-1-dev libglib2.0-dev \
pkg-config zlib1g-dev ninja-build

# if gnu-toolchain not in current dir, download it.

read -p "Is Gnu toolchain source code existing and in current directory? [y/n]" input

case $input in
        [yY]*)
                echo "Gnu toolchain is existing and in current directory. "
                ;;
        [nN]*)
                echo "Gnu toolchain is not existing. Will download it."
                wget https://mirror.iscas.ac.cn/plct/$mirror_GNU_toolchain
                if [[ ! -f $mirror_GNU_toolchain ]];then
                        echo "Gnu toolchain download failed."
                        exit
                fi
                tar xjf $mirror_GNU_toolchain
                ;;
        *)
                echo "Just enter y or n, please."
                exit
                ;;
esac

# update gnu toolchain.

if [[ -d riscv-gnu-toolchain ]];then
        cd riscv-gnu-toolchain
else
        echo "folder riscv-gnu-toolchain doesn't exsit."
        exit
fi

git fetch origin master
git merge origin/master
git submodule update --init --recursive
cd ..

for(( i=1;i<${#ins_exts[@]};i++ )) do
        ext=${ins_exts[i]}
        gcc_branch=${gcc_repos[i]##*tree/}
        binutils_branch=${binutils_repos[i]##*tree/}
        echo extension is $ext, gcc branch is $gcc_branch, binutils branch is $binutils_branch
        cp -r riscv-gnu-toolchain $ext && cd $ext
        #cd $ext

        #switch gcc to $ext branch
        cd riscv-gcc
        git remote add $ext ${gcc_repos[i]%%/tree*}.git
        git fetch $ext
        git checkout $ext/$gcc_branch
        cd ..

        #swith binutils to $ext branch
        cd riscv-binutils
        git remote add $ext ${binutils_repos[i]%%/tree*}.git
        git fetch $ext
        git checkout $ext/$binutils_branch
        echo "cd .."
        cd ..
        echo "current dir is `pwd`"
        
        #swith qemu
        #Tofix

        #build 64bit version
        echo "build 64 bit version for $ext"
        mkdir build_64
        cd build_64
        ../configure --prefix=$RISCV64/$ext/ --with-arch=${arch64[i]} --with-abi=${abi64[i]} --with-multilib-generator="${arch64[i]}-${abi64[i]}--" > build.log 2>&1
        make -j $nproc >>build.log 2>&1
        make report-gcc-newlib 2>&1 > gcclog_${ext}_64.md
        make report-binutils-newlib 2>&1 > binutilslog_${ext}_64.md
        cd ..
        echo "current dir is `pwd`"

        #build 32bit version
        echo "build 32 bit version for $ext"
        mkdir build_32
        cd build_32
        ../configure --prefix=$RISCV32/$ext/ --with-arch=${arch32[i]} --with-abi=${abi32[i]} --with-multilib-generator="${arch32[i]}-${abi32[i]}--" >build.log 2>&1
        make -j $nproc >>build.log 2>&1
        make report-gcc-newlib 2>&1 > gcclog_${ext}_32.md
        make report-binutils-newlib 2>&1 > binutilslog_${ext}_32.md
        cd ..
        echo "current dir is `pwd`"

        cd ..
        echo "current dir is `pwd`"
done;
        
