tag=$4
lno=1
touch ccoptions.sum.$tag cxxoptions.sum.$tag fcoptions.sum.$tag ldoptions.sum.$tag
while read line; do
    echo "url line: $lno"
    # if [ $lno -eq 4 ]; then
    #     break
    # fi

    flagsurl=https://www.spec.org${line/txt/flags.html}
    htmlfile=$(basename $flagsurl)
    echo $flagsurl
    echo $htmlfile
    wget $flagsurl

    section=no
    while read line2; do
        if [[ $line2 =~ "CC_FCbaseoptimization" ]]; then
            section=CC_FCbaseoptimization
        elif [[ $line2 =~ "CC_CXX_FCbaseoptimization" ]]; then
            section=CC_CXX_FCbaseoptimization
        elif [[ $line2 =~ "CCbaseoptimization" ]]; then
            section=CCbaseoptimization
        elif [[ $line2 =~ "CXXbaseoptimization" ]]; then
            section=CXXbaseoptimization
        elif [[ $line2 =~ "FCbaseoptimization" ]]; then
            section=FCbaseoptimization
        elif [[ $line2 =~ "Peak Optimization Flags" ]]; then
            section=no
        fi

        if [[ $section == "CCbaseoptimization" ]]; then

            opt=$(echo $line2 | grep "flagName" | grep -Eo '>\-.*</a>' | xargs echo "|")
            if [[ $opt != "|" ]]; then
                echo $opt >>ccoptions.this.$tag
            fi
        fi

        if [[ $section == "CXXbaseoptimization" ]]; then

            opt=$(echo $line2 | grep "flagName" | grep -Eo '>\-.*</a>' | xargs echo "|")
            if [[ $opt != "|" ]]; then
                echo $opt >>cxxoptions.this.$tag
            fi
        fi

        if [[ $section == "FCbaseoptimization" ]]; then

            opt=$(echo $line2 | grep "flagName" | grep -Eo '>\-.*</a>' | xargs echo "|")
            if [[ $opt != "|" ]]; then
                echo $opt >>fcoptions.this.$tag
            fi
        fi

        if [[ $section == "CC_FCbaseoptimization" || $section == "CC_CXX_FCbaseoptimization" ]]; then
            if [[ -n $(echo $line2 | grep "flagName") ]]; then
                opt=$(echo $line2 | grep "flagName" | grep -Eo '>\-.*</a>' | xargs echo "|")
            fi
            flagvar=$(echo $line2 | grep "flagVar")

            if [[ $flagvar =~ "CC" || $flagvar =~ "COPTIMIZE" ]]; then
                #echo "CC flags"
                echo $opt >>ccoptions.this.$tag
            fi

            if [[ $flagvar =~ "CXX" || $flagvar =~ "CXXOPTIMIZE" ]]; then
                #echo "CXX flags"
                echo $opt >>cxxoptions.this.$tag
            fi

            if [[ $flagvar =~ "FC" || $flagvar =~ "FOPTIMIZE" ]]; then
                #echo "FC flags"
                echo $opt >>fcoptions.this.$tag
            fi

            if [[ $flagvar =~ "LD" || $flagvar =~ "LDFLAGS" || $flagvar =~ "LDCXXFLAGS" || $flagvar =~ "EXTRA_LIBS" ]]; then
                #echo "LD flags"
                echo $opt >>ldoptions.this.$tag
            fi
        fi

    done <$htmlfile

    if [ -f ccoptions.this.$tag ]; then
        # sort and count.
        # lines in options.this.$tag goes like "|>-DSPEC_OPENMP</a>"
        # lines in tmp.this goes like "6 |>-DSPEC_OPENMP</a>"
        sort ccoptions.this.$tag | uniq | uniq -c >cctmp.this.$tag
        # 指定分隔符是|，按照第二列排序，合并tmp.this和options.sum.$tag两个文件。那么相同选项聚集在一起，行首是它们的出现的次数。
        sort -t '|' -k 2 cctmp.this.$tag ccoptions.sum.$tag >cctmp.sum.$tag
        # 指定分隔符是|，如果第二列相同，那么就把第一列相加，合并成一行。
        awk -F '|' '{sum[$2]+=$1}END{for(c in sum){print sum[c],"|"c}}' cctmp.sum.$tag >ccoptions.sum.$tag
        rm cctmp.this.$tag cctmp.sum.$tag ccoptions.this.$tag
        wc -l ccoptions.sum.$tag
    fi

    if [ -f cxxoptions.this.$tag ]; then
        sort cxxoptions.this.$tag | uniq | uniq -c >cxxtmp.this.$tag
        sort -t '|' -k 2 cxxtmp.this.$tag cxxoptions.sum.$tag >cxxtmp.sum.$tag
        awk -F '|' '{sum[$2]+=$1}END{for(c in sum){print sum[c],"|"c}}' cxxtmp.sum.$tag >cxxoptions.sum.$tag
        rm cxxtmp.this.$tag cxxtmp.sum.$tag cxxoptions.this.$tag
        wc -l cxxoptions.sum.$tag
    fi

    if [ -f fcoptions.this.$tag ]; then
        sort fcoptions.this.$tag | uniq | uniq -c >fctmp.this.$tag
        sort -t '|' -k 2 fctmp.this.$tag fcoptions.sum.$tag >fctmp.sum.$tag
        awk -F '|' '{sum[$2]+=$1}END{for(c in sum){print sum[c],"|"c}}' fctmp.sum.$tag >fcoptions.sum.$tag
        rm fctmp.this.$tag fctmp.sum.$tag fcoptions.this.$tag
        wc -l fcoptions.sum.$tag
    fi

    if [ -f ldoptions.this.$tag ]; then
        sort ldoptions.this.$tag | uniq | uniq -c >ldtmp.this
        sort -t '|' -k 2 ldtmp.this ldoptions.sum.$tag >ldtmp.sum.$tag
        awk -F '|' '{sum[$2]+=$1}END{for(c in sum){print sum[c],"|"c}}' ldtmp.sum.$tag >ldoptions.sum.$tag
        rm ldtmp.this ldtmp.sum.$tag ldoptions.this.$tag
        wc -l ldoptions.sum.$tag
    fi

    lno=$(expr $lno + 1)
    rm $htmlfile
done < <(sed -n "$2,$3p" $1) #注意两个<之间是有一个空格的
