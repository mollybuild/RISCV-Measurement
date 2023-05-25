NJOBS=$2
NLINES=$(cat $1 | wc -l)
NSTEP=$(expr $NLINES / $NJOBS + 1)

for ((i = 1; i <= $NJOBS; i++)); do
    start=$(expr $NSTEP \* $i - $NSTEP + 1)
    end=$(expr $NSTEP \* $i)
    echo "$start - $end"

    ./getflags.sh $1 $start $end $i &
done

wait
echo "all done"

echo "merge results... ..."

cp ccoptions.sum.1 ccoptions.sum
cp cxxoptions.sum.1 cxxoptions.sum
cp fcoptions.sum.1 fcoptions.sum
cp ldoptions.sum.1 ldoptions.sum

for ((i = 2; i <= $NJOBS; i++)); do
    sort -t '|' -k 2 ccoptions.sum.$i ccoptions.sum >cctmp.sum
    awk -F '|' '{sum[$2]+=$1}END{for(c in sum){print sum[c],"|"c}}' cctmp.sum >ccoptions.sum

    sort -t '|' -k 2 cxxoptions.sum.$i cxxoptions.sum >cxxtmp.sum
    awk -F '|' '{sum[$2]+=$1}END{for(c in sum){print sum[c],"|"c}}' cxxtmp.sum >cxxoptions.sum

    sort -t '|' -k 2 fcoptions.sum.$i fcoptions.sum >fctmp.sum
    awk -F '|' '{sum[$2]+=$1}END{for(c in sum){print sum[c],"|"c}}' fctmp.sum >fcoptions.sum

    sort -t '|' -k 2 ldoptions.sum.$i ldoptions.sum >ldtmp.sum
    awk -F '|' '{sum[$2]+=$1}END{for(c in sum){print sum[c],"|"c}}' ldtmp.sum >ldoptions.sum

    rm cctmp.sum cxxtmp.sum fctmp.sum ldtmp.sum
done
