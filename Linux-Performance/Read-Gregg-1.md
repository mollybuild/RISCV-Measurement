*本文来源：翻译自Brendan Gregg博客文章（https://netflixtechblog.com/linux-performance-analysis-in-60-000-milliseconds-accc10403c55）*

## 前言

当我们登录进一个发生性能问题的linux系统时，在最初的1分钟里，我们可以做哪些检查呢？

可以使用下面的10条命令，在1分钟内对获得对系统资源使用率和运行中进程的大致了解。查看error，saturation指标，系统利用率。

```
uptime
dmesg | tail
vmstat 1
mpstat -P ALL 1
pidstat 1
iostat -xz 1
free -m
sar -n DEV 1
sar -n TCP,ETCP 1
top
```

资源饱和度（saturation）是指一个资源的负载超过其能处理的限度，可以表现为队列的长度，或者等待时间。

这些命令显示的metrics可以帮助我们进行USE分析。USE是一个用来定位性能瓶颈的方法，通过查看所有资源的利用率（utilization）、饱和度（saturation）、和错误（error）。

接下来，介绍这10条命令。

## uptime

![image](https://user-images.githubusercontent.com/26591790/167988258-2740d403-05e8-4231-b98c-71a20a6d2ed5.png)

快速查看平均负载的方法，它指示要运行的任务（进程）的数量。在 Linux 系统上，这包括等候CPU的进程，以及在不间断 I/O（通常是磁盘 I/O）中阻塞的进程。大致可以通过它了解资源负载的情况。

Load average分别是 1分钟、5分钟、15分钟的平均值。这三个数字让我们了解负载如何随时间变化。例如，如果您被要求检查有问题的服务器，并且 1 分钟的值远低于 15 分钟的值，那么您可能登录得太晚而错过了问题。

## dmesg | tail

![image](https://user-images.githubusercontent.com/26591790/167988304-462e9968-7077-4bb4-a000-907a03dc7e8b.png)

查看最后 10 条系统消息（如果有）。 查找可能导致性能问题的错误。

不要错过这一步！ dmesg 总是值得检查的。

## vmstat 1

![image](https://user-images.githubusercontent.com/26591790/167988322-526ff2fe-1ed2-4dc9-aab9-0d2cde47ae8d.png)

vmstat(8) 是虚拟内存统计的缩写，是一种常用工具（几十年前首次为 BSD 创建）。 它在每一行打印关键服务器统计信息的摘要。

vmstat 使用参数 1 运行，以打印一秒钟的摘要。 输出的第一行显示自启动以来的平均值，而不是前一秒。

检查列：

- r：在 CPU 上运行并等待轮换的进程数。 这为确定 CPU 饱和度提供了比负载平均值更好的信号，因为它不包括 I/O。 解释：大于 CPU数目的“r”值即是饱和的。

- free：以千字节为单位的可用内存。“free -m”命令更好地解释了空闲内存的状态。

- si, so：换入和换出。 如果这俩不为零，则说明内存不足。

- us, sy, id, wa, st：它们是用户时间、系统时间（内核）、空闲时间、等待 I/O 和被盗时间（由其他guests或 Xen，guests自己的隔离驱动程序域）。

通过用户和系统时间之和来确认 CPU是否繁忙。等待I/O的恒定时间指向磁盘瓶颈；这是CPU空闲的地方，因为任务被阻塞以等待挂起的磁盘 I/O。可将等待 I/O 视为另一种形式的CPU空闲。

I/O 处理需要系统时间，系统时间如果超过20%，就需要进一步探索：可能内核处理 I/O 效率低下。


## mpstat -P ALL 1

![image](https://user-images.githubusercontent.com/26591790/167988367-d01668d5-1872-4a32-8ca3-4d117141dae3.png)

此命令打印每个CPU的时间细分，可用于检查不均衡负载。单个热CPU可以作为单线程应用程序的证据。

## pidstat 1

![image](https://user-images.githubusercontent.com/26591790/167988414-b3e65557-6cc1-45d1-972f-9af9ce0037b0.png)

Pidstat有点像top，列出每个进程摘要，但滚动打印，而不是清除屏幕。这对于观察一段时间内的模式很有用。

## iostat -xz 1

![image](https://user-images.githubusercontent.com/26591790/167988454-ff46ecd2-0b6b-428f-9608-111b214fe413.png)

这是了解块设备（磁盘）、应用的工作负载和由此产生的性能的一个很好的工具。

- r/s、w/s、rkB/s、wkB/s：这些是每秒传送到设备的读取、写入、读取千字节和写入千字节。使用这些来表征工作负载。性能问题可能仅仅是由于施加了过多的负载。
- await：I/O 的平均时间，以毫秒为单位。这是应用程序经历的时间，它包括排队时间和服务时间。大于预期的平均时间可能意味着设备饱和或设备问题。
- avgqu-sz：向设备发出的平均请求数。大于1的值可能是饱和的证据（尽管设备通常可以并行处理请求）
- %util：设备利用率。显示设备每秒工作的时间。大于60%通常会导致性能不佳（应在 await 中看到）。接近100%通常表示饱和。

如果存储设备是面向许多后端磁盘的逻辑磁盘设备，那么100%的利用率可能只是意味着100%的时间正在处理一些I/O，但是，后端磁盘可能远未饱和，并且可能能够处理更多的工作。

请记住，性能不佳的磁盘 I/O 不一定是应用程序问题。许多技术通常用于异步执行I/O，这样应用程序就不会直接阻塞和遭受延迟（例如，读取的预读和写入的缓冲）。

## free -m

![image](https://user-images.githubusercontent.com/26591790/167988478-c79ffb23-075f-4bc6-bdd1-efb0bb8ae3cc.png)

右边两列显示：

- buffers：用于缓冲区缓存，用于块设备 I/O。
- cached：用于页面缓存，由文件系统使用。

我们只想检查它们的大小是否接近于零，这会导致更高的磁盘 I/O（使用 iostat 确认）和更差的性能。 

Linux将空闲内存用于缓存，但如果应用程序需要，可以快速回收它。因此，在某种程度上，缓存内存应该包含在空闲内存列中。

## sar -n DEV 1

![image](https://user-images.githubusercontent.com/26591790/167988511-b3e1917f-1604-43fa-99c6-b2c48f7d3fd4.png)

使用此工具检查网络接口吞吐量：rxkB/s 和 txkB/s，作为工作量的衡量标准，并检查是否已达到任何限制。

这个版本还有%ifutil用于设备利用率（全双工的最大双向），我们也使用 Brendan 的 nicstat 工具来测量。

## sar -n TCP,ETCP 1

![image](https://user-images.githubusercontent.com/26591790/167988537-22a0f543-9819-4bcd-808d-3cc721838877.png)

这是一些关键 TCP 指标，包括：

- active/s：每秒本地发起的 TCP 连接数（例如，通过 connect()）。
- passive/s：每秒远程发起的 TCP 连接数（例如，通过 accept()）。
- retrans/s：每秒 TCP 重传次数。

主动和被动计数通常可用于粗略衡量服务器负载：新接受的连接数（被动）和下游连接数（主动）。将主动视为出站，将被动视为入站可能会有所帮助，但这并不完全正确（例如，考虑 localhost 到 localhost 的连接）。

重传是网络或服务器问题的标志；它可能是一个不可靠的网络（例如，公共互联网），或者可能是由于服务器过载并丢弃数据包。

## top

![image](https://user-images.githubusercontent.com/26591790/167988578-7c3d0a98-2fff-436a-8124-0620a795d22b.png)

top命令包括我们之前检查的许多指标。运行它可以很方便地查看是否有任何东西与之前的命令有很大不同，这表明负载是可变的。

top的缺点是随着时间推移更难看到模式，这在vmstat和pidstat等滚动输出的工具中可能更清楚。需要暂停输出（Ctrl-S 暂停，Ctrl-Q 继续）来观察和保存证据。

## 参考

Linux Performance Analysis in 60,000 Milliseconds

https://netflixtechblog.com/linux-performance-analysis-in-60-000-milliseconds-accc10403c55
