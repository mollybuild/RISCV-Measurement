#!/bin/bash

## This script tested on x86 Ubuntu, RV64 Ubuntu.

## Usage: ./autoRunSPECCPU.sh [GCC/LLVM] [O3/Ofast/Both]
## Getting parameters of the scripts

compiler="GCC"
version="" # x.x.x
opt=O3
SPECdir="$HOME/spec/CPU2017-v1.1.9"
script_dir=$(pwd $(dirname $0))
machine=$(hostname)
SPECCPUconfig=""

## Handle unexpect exit
trap "echo Fail unexpectedly on line \$0:\$LINENO; exit 1" ERR

function setEnv() {
    export C_INCLUDE_PATH=/usr/include/riscv64-linux-gnu/
    export CPLUS_INCLUDE_PATH=/usr/include/riscv64-linux-gnu/
    export LIBRARY_PATH=/usr/lib/riscv64-linux-gnu/
    export LD_LIBRARY_PATH=/usr/lib/riscv64-linux-gnu/

}

function unsetEnv() {
    unset C_INCLUDE_PATH
    unset CPLUS_INCLUDE_PATH
    unset LIBRARY_PATH
    unset LD_LIBRARY_PATH
}

function getnbuildsrc() {
    trap "echo Fail unexpectedly on line \$0:\$LINENO; exit 1" ERR
    if [ $compiler == "GCC" ]; then
        ## GCC part: download the newest released GCC source, and build it.
        ftp -v -n ftp.gnu.org <<EOF
user anonymous
quote pasv
passive
cd /gnu/gcc
ls -l gccList.txt
bye
EOF
        if [ $version == ""]; then
            # gccver is the newest version of gcc.
            # the line in gccList.txt goes like:
            # drwxr-xr-x    2 3003     3003         4096 Apr 08  2021 gcc-10.3.0
            # 'sort -k9 -V' natural sort of version numbers based on column 9.
            gccver=$(cat gccList.txt | grep "gcc-[0-9]\+\.[0-9]\+\.[0-9]\+$" | sort -k9 -V | awk '{print $9}' | tail -1)
            #version=$(echo $gccver | awk -F "-" '{print $2}')
        elif [[ $version =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
            gccver=gcc-$version
        else
            echo "compiler version isn't correct."
            exit 1
        fi
        # if the source code doesn't exist then download it.
        if [ ! -d "GCC-source/$gccver" ]; then
            echo "$gccver source hasn't been downloaded, now going to download it."
            wget https://ftp.gnu.org/gnu/gcc/${gccver}/${gccver}.tar.gz
            mv ${gccver}.tar.gz GCC-source
            cd GCC-source
            tar zxvf ${gccver}.tar.gz
            cd ..
        else
            echo "$gccver source exist."
        fi

        # if the version isn't installed, then compile the gcc source and install it under $HOME/opt/gcc-x.x.x
        if [ ! -d "$HOME/opt/$gccver" ]; then
            echo "$gccver hasn't been built & install, now going to build & install"
            setEnv
            cd GCC-source/$gccver
            contrib/download_prerequisites
            mkdir build && cd build
            ../configure --enable-languages=c,c++,fortran --prefix=$HOME/opt/$gccver --disable-multilib
            make -j$(nproc)
            make install
            unsetEnv
        fi
    elif [ $compiler == "LLVM" ]; then
        #LLVM part: download the newest released LLVM source, and build it.

        if [ $version == "" ]; then
            # version if empty, so get the latest release version fron github
            # get the latest llvm source code download link, but only "/llvm/llvm-project/archive/refs/tags/llvmorg-x.x.x.tar.gz" part.
            srcurl=$(curl https://github.com/llvm/llvm-project/tags | grep "/llvm/llvm-project/archive/refs/tags/llvmorg-.*\.tar\.gz" | head -1 | awk '{print $3}' | awk -F "\"" '{print $2}')
            #version=$(echo $srcurl | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")
        elif [[ $version =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
            # now srcurl goes like /llvm-project/archive/refs/tags/llvmorg-16.0.3.tar.gz
            srcurl=/llvm/llvm-project/archive/refs/tags/llvmorg-$version.tar.gz
        else
            echo "compiler version isn't correct."
            exit 1
        fi
        if [[ -n $srcurl ]]; then
            srcurl="https://github.com"$srcurl
            # get llvm version goes like llvmorg-x.x.x
            llvmver=$(basename $srcurl .tar.gz)
            # check if this version has been downloaded already. If not download it.
            if [ ! -d "LLVM-source/llvm-project-$llvmver" ]; then
                wget $srcurl
                mv ${llvmver}.tar.gz LLVM-source
                cd LLVM-source
                tar zxvf ${llvmver}.tar.gz
                cd $script_dir
            else
                echo "$llvmver source exist."
            fi

            # check if this version has been built and installed. If no build and install it.
            if [ ! -d "$HOME/opt/$llvmver" ]; then
                echo "$llvmver hasn't been built & install, now going to build & install"
                cd LLVM-source/llvm-project-$llvmver
                mkdir build && cd build
                cmake -DLLVM_ENABLE_PROJECTS="clang;flang;openmp;mlir" -DLLVM_ENABLE_RUNTIMES="compiler-rt" -DLLVM_TARGETS_TO_BUILD=host -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX=$HOME/opt/$llvmver -GNinja ../llvm
                ninja
                ninja install
                cd $script_dir
            fi

        else
            echo "srcurl is empty."
        fi
    else
        echo "compiler is neither GCC or LLVM. exit"
        exit 1
    fi
}

## main progress start from here

if [ $# -eq 0 ]; then
    echo "You don't specify compiler or opt options. So default is GCC and O3."
fi

if [ $# -ge 1 ]; then
    if [ $1 == "GCC" ] || [ $1 == "LLVM" ]; then
        compiler=$1
    elif [[ $1 =~ GCC-[0-9]+\.[0-9]+\.[0-9]+ ]] || [[ $1 =~ LLVM-[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        compiler=$(echo $1 | awk -F "-" '{print $1}')
        version=$(echo $1 | awk -F "-" '{print $2}')
    else
        echo "Usage: ./autoRunSPECCPU.sh [GCC/LLVM] [O3/Ofast/Both]"
        echo "The first parameter should be GCC or LLVM."
        exit 1
    fi
fi

if [ $# -ge 2 ]; then
    if [ $2 != "O3" ] && [ $2 != "Ofast" ] && [ $2 != "Both" ]; then
        echo "Usage: ./autoRunSPECCPU.sh [GCC/LLVM] [O3/Ofast/Both]"
        echo "The second parameter should be O3 or Ofast or Both."
        exit 1
    fi
    opt=$2
fi

if [ ! -d GCC-source ]; then
    mkdir GCC-source
fi

if [ ! -d LLVM-source ]; then
    mkdir LLVM-source
fi

## install prerequisites

sudo apt install ftp wget ninja-build

## Get GCC/LLVM source code, build and install
getnbuildsrc

## Select compiler
## list all the installed gcc and llvm
ls $HOME/opt -l | grep "^d" | grep "gcc-[0-9]\+\.[0-9]\+\.[0-9]\+$" | sort -k9 -V | awk '{print $9}' >installedGCC.list
ls $HOME/opt -l | grep "^d" | grep "llvmorg-[0-9]\+\.[0-9]\+\.[0-9]\+$" | sort -k9 -V | awk '{print $9}' >installedLLVM.list

if [ $version == "" ]; then
    ## if no any result yet, select the latest version of GCC or LLVM
    if [ ! -f result.csv ]; then
        testcompiler=$(cat installed${compiler}.list | head -1)
    else
        # if there are results, select the compiler that hasn't been tested.
        while read line; do
            if [ $(grep -c "$line" result.csv) -eq '0' ]; then
                testcompiler=$line
                break
            fi
        done <installed${compiler}.list
    fi
else
    if [ $compiler == "GCC" ]; then
        testcompiler=gcc-$version
    else
        testcompiler=llvmorg-$version
    fi
fi

echo "select compiler $compiler."

## Prepare SPEC CPU enviroment and run.
cd $SPECdir
source shrc

if [ $compiler == "GCC" ]; then
    SPECCPUconfig="my-gcc-linux-x86.cfg"
    if [ $opt == O3 ]; then
        runcpu --define gcc_dir=$HOME/opt/$testcompiler -c $SPECCPUconfig --noreportable -n 1 -I -T base all 2>&1 | tee cpu.log
    elif [ $opt == Ofast ]; then
        runcpu --define gcc_dir=$HOME/opt/$testcompiler -c $SPECCPUconfig --noreportable -n 1 -I -T peak all 2>&1 | tee cpu.log
    elif [ $opt == Both ]; then
        runcpu --define gcc_dir=$HOME/opt/$testcompiler -c $SPECCPUconfig --noreportable -n 1 -I -T all all 2>&1 | tee cpu.log
    fi
elif [ $compiler == "LLVM" ]; then
    SPECCPUconfig="my-llvm-linux-x86.cfg"
    if [ $opt == O3 ]; then
        runcpu --define gcc_dir=$HOME/opt/$testcompiler -c $SPECCPUconfig --noreportable -n 1 -I -T base all 2>&1 | tee cpu.log
    elif [ $opt == Ofast ]; then
        runcpu --define gcc_dir=$HOME/opt/$testcompiler -c $SPECCPUconfig --noreportable -n 1 -I -T peak all 2>&1 | tee cpu.log
    elif [ $opt == Both ]; then
        runcpu --define gcc_dir=$HOME/opt/$testcompiler -c $SPECCPUconfig --noreportable -n 1 -I -T all all 2>&1 | tee cpu.log
    fi
else
    echo "compiler if neither GCC or LLVM. There must be something wrong. Exit"
    Exit 1
fi
cd $script_dir

## Collecting Data
if [ $(grep -c "format: CSV ->" ${SPECdir}/cpu.log) -ne '0' ]; then
    echo "CSV file exist"
    grep "format: CSV" ${SPECdir}/cpu.log | awk '{print $4}' >CSVFile.list
    while read line; do
        echo "CSVFile $line"
        CSVbasename=$(basename $line)
        echo "filename is $CSVbasename"
        metric=$(echo $CSVbasename | awk -F '.' '{print $3}')
        echo "metric is $metric"
        base_score=$(grep "^SPEC.*2017.*base.*" $line | awk -F ',' '{print $4}')
        peak_score=$(grep "^SPEC.*2017.*peak.*" $line | awk -F ',' '{print $9}')
        echo "$compiler,$metric,$opt,$machine,$CSVbasename,$base_score,$peak_score" >>result.csv
    done <CSVFile.list
else
    echo "CSV file doesn't exist."
fi

## format
