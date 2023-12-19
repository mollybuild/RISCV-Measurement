folders=("xz-5.0.0/build-aux"
"make-3.82/config"
"rxp-1.5.0"
"tar-1.25/build-aux"
"expat-2.0.1/conftools"
"specsum/build-aux"
"specinvoke")

for folder in ${folders[@]};
do
        cat config.guess > $folder/config.guess
        cat config.sub > $folder/config.sub
done
