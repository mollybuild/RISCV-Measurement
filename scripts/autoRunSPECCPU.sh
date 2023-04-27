#!/bin/bash

## Usage: ./autoRunSPECCPU.sh [GCC/LLVM] [O3/Ofast/Both]
## Getting parameters of the scripts

GCC=true
LLVM=true
compiler=""
SPECdir="/home/chenxiaoou/spec/CPU2017-v1.1.9"
machine=$(hostname)
opt=O3


while [ $# -gt 0 ]; do
    case $1 in
    -h)
        echo "Usage: ./autoRunSPECCPU.sh [GCC/LLVM] [O3/Ofast/Both]"
        ;;
    GCC)
        LLVM=false
        ;;
    LLVM)
        GCC=false
        ;;
    O3)
        opt=O3
        ;;
    Ofast)
        opt=Ofast
        ;;
    Both)
        opt=Both
        ;;     
    esac
    shift
done

## Get GCC/LLVM source code, build and install
if [ $GCC == true ]; then

    ftp -v -n ftp.gnu.org <<EOF
user anonymous
cd /gnu/gcc
ls -l folderList.txt
bye
EOF

    folder=$(cat folderList.txt | grep "gcc-[0-9]\+\.[0-9]\+\.[0-9]\+$" | sort -k9 -V | awk '{print $9}' | tail -1)

    if [ ! -d "GCC-source/$folder" ]; then

        echo "$folder source hasn't been downloaded, now going to download it."
        

        mv ${folder}.tar.gz GCC-source
        cd GCC-source
        tar zxvf ${folder}.tar.gz
        cd ..
    else
        echo "$folder source exist."
    fi

    if [ ! -d "$HOME/opt/$folder" ]; then

        echo "$folder hasn't been built & install, now going to build & install"
        export C_INCLUDE_PATH=/usr/include/riscv64-linux-gnu/
        export CPLUS_INCLUDE_PATH=/usr/include/riscv64-linux-gnu/
        export LIBRARY_PATH=/usr/lib/riscv64-linux-gnu/
        export LD_LIBRARY_PATH=/usr/lib/riscv64-linux-gnu/
    	cd GCC-source/$folder
    	contrib/download_prerequisites
    	mkdir build && cd build
    	../configure --enable-languages=c,c++,fortran --prefix=$HOME/opt/$folder --disable-multilib
    	make -j4
    	make install
        unset C_INCLUDE_PATH
        unset CPLUS_INCLUDE_PATH
        unset LIBRARY_PATH
        unset LD_LIBRARY_PATH 

    fi

fi

#if [ $LLVM == true ]; then
#
#fi

## Determine to run which compiler
ls $HOME/opt -l | grep "^d" | grep "gcc-[0-9]\+\.[0-9]\+\.[0-9]\+$" | sort -k9 -V | awk '{print $9}' >compiler.list

if [ ! -f result.csv ]; then
    compiler=$(cat compiler.list | head -1)
else
    while read line; do
        if [ $(grep -c "$line" result.csv) -eq '0' ]; then
            compiler=$line
            break
        fi
    done < compiler.list
fi

echo "select compiler $compiler."

## Prepare SPEC CPU enviroment and run.
cd $SPECdir
source shrc

if [ $opt == O3 ];then
    runcpu --define gcc_dir=$HOME/opt/$compiler -c gcc-riscv.cfg --noreportable -n 1 -I -T base all 2>&1 | tee cpu.log
elif [ $opt == Ofast ];then
    runcpu --define gcc_dir=$HOME/opt/$compiler -c gcc-riscv.cfg --noreportable -n 1 -I -T peak all 2>&1 | tee cpu.log
elif [ $opt == Both ];then
    runcpu --define gcc_dir=$HOME/opt/$compiler -c gcc-riscv.cfg --noreportable -n 1 -I -T all all 2>&1 | tee cpu.log
fi
cd `dirname $0`

## Collecting Data
if [ $(grep -c "format: CSV ->" ${SPECdir}/cpu.log) -ne '0' ]; then
    echo "CSV file exist"
    grep "format: CSV" ${SPECdir}/cpu.log | awk '{print $4}' > CSVFile.list
    while read line; do
        echo "CSVFile $line"
        CSVbasename=$(basename $line)
        echo "filename is $CSVbasename"
        metric=$(echo $CSVbasename | awk -F '.' '{print $3}')
        echo "metric is $metric"
        base_score=$(grep "^SPEC.*2017.*base.*" $line | awk -F ',' '{print $4}')
        peak_score=$(grep "^SPEC.*2017.*peak.*" $line | awk -F ',' '{print $9}')
        echo "$compiler,$metric,$opt,$machine,$CSVbasename,$base_score,$peak_score" >> result.csv
    done < CSVFile.list
else
    echo "CSV file doesn't exist."
fi
## format
