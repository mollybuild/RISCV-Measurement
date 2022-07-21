## OS/JDK version

OS: ubuntu21.04

openjdk version "19-internal"

## Command

```
~/jdk/bin/java -jar dacapo-9.12-MR1-bach.jar avrora fop h2 jython luindex lusearch lusearch-fix pmd sunflow xalan
```

## Result:
![image](https://user-images.githubusercontent.com/26591790/180114444-a55d8763-1095-4e4b-8174-81c3ac85caed.png)
![image](https://user-images.githubusercontent.com/26591790/180114527-acae1e56-3093-4587-9c05-98814622e184.png)

剩下的batik, eclipse, tomcat, tradebeans,tradesoap运行会失败。

Benchmark | Result(msec)
---|---
avrora | 34593
batik | FAIL
eclipse | FAIL
fop | 20188
h2 | 45248
jython | 134815
luindex | 16098
lusearch | 15916
lusearch-fix | 15036
pmd | 30916
sunflow | 34381
tomcat | FAIL
tradebeans | FAIL
tradesoap | FAIL
xalan | 28623
pass-rate | 67%

