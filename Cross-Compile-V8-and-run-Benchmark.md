## 源码

Google官方repo：https://github.com/v8/v8

PLCT用来开发尚未提交到google的feature用的fork：https://github.com/riscv-collab/v8

我这里编译的源码来自https://github.com/v8/v8，commit ID：9076fce

## 构建

构建参考文档：

https://v8.dev/docs/source-code

交叉编译参考：

https://github.com/riscv-collab/v8/wiki/Cross-compiled-Build

### 使用RISCV GCC交叉编译V8

目前11.4以下的版本编译时会报错：

![image](https://user-images.githubusercontent.com/26591790/176656479-2020153e-ae6d-4aae-b793-33d14044ab4d.png)

另外有一个不过需要修复：build/config/compiler/BUILD.gn文件中删除以下两行

![image](https://user-images.githubusercontent.com/26591790/176656534-aff607ae-aac3-4012-acfd-0ac71a104661.png)

RISCV Gnu toolchain也可以在这里下载：

https://github.com/riscv-collab/riscv-gnu-toolchain/releases

下载V8源码：
 
```
$ git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$ export PATH=/path/to/depot_tools:$PATH
$ mkdir V8_ROOT && cd V8_ROOT
$ fetch v8 && cd v8
$ gclient sync
```

### 使用Clang交叉编译V8

需要打patch （基于commit ID 9076fce）：

```
From 0ca13669edde3ce8f92f3a13ce06d52e95eb6526 Mon Sep 17 00:00:00 2001
From: Lu Yahan <yahan@iscas.ac.cn>
Date: Thu, 23 Jun 2022 10:12:21 +0800
Subject: [PATCH] support clang

---
 build_config.h           |  5 +++++
 config/compiler/BUILD.gn | 30 ++++++++++++++++++++++++++----
 config/riscv.gni         | 18 ++++++++++++++++++
 toolchain/linux/BUILD.gn | 35 +++++++++++++++++++++++++++++++++++
 4 files changed, 84 insertions(+), 4 deletions(-)
 create mode 100644 config/riscv.gni

diff --git a/build_config.h b/build_config.h
index a993e1e44..f1d852c74 100644
--- a/build_config.h
+++ b/build_config.h
@@ -341,6 +341,11 @@
 #define ARCH_CPU_RISCV64 1
 #define ARCH_CPU_64_BITS 1
 #define ARCH_CPU_LITTLE_ENDIAN 1
+#elif defined(__riscv) && (__riscv_xlen == 32)
+#define ARCH_CPU_RISCV_FAMILY 1
+#define ARCH_CPU_RISCV32 1
+#define ARCH_CPU_32_BITS 1
+#define ARCH_CPU_LITTLE_ENDIAN 1
 #else
 #error Please add support for your architecture in build/build_config.h
 #endif
diff --git a/config/compiler/BUILD.gn b/config/compiler/BUILD.gn
index f0a9a086a..258742d04 100644
--- a/config/compiler/BUILD.gn
+++ b/config/compiler/BUILD.gn
@@ -30,6 +30,9 @@ if (current_cpu == "mipsel" || current_cpu == "mips64el" ||
     current_cpu == "mips" || current_cpu == "mips64") {
   import("//build/config/mips.gni")
 }
+if (current_cpu == "riscv64") {
+  import("//build/config/riscv.gni")
+}
 if (is_mac) {
   import("//build/config/apple/symbols.gni")
 }
@@ -935,6 +938,19 @@ config("compiler_cpu_abi") {
         # Outline atomics crash on Exynos 9810. http://crbug.com/1272795
         cflags += [ "-mno-outline-atomics" ]
       }
+    } else if (current_cpu == "riscv32") {
+      if (is_clang) {
+        cflags += [ "--target=riscv32-unknown-linux-gnu" ]
+        ldflags += [ "--target=riscv32-unknown-linux-gnu" ]
+        if (riscv_gcc_toolchain_path != "") {
+          cflags += [ "--gcc-toolchain=$riscv_gcc_toolchain_path" ]
+          ldflags += [ "--gcc-toolchain=$riscv_gcc_toolchain_path" ]
+        }
+        if (riscv_sysroot != "") {
+          cflags += [ "--sysroot=$riscv_sysroot" ]
+          ldflags += [ "--sysroot=$riscv_sysroot" ]
+        }
+      }
     } else if (current_cpu == "mipsel" && !is_nacl) {
       ldflags += [ "-Wl,--hash-style=sysv" ]
       if (custom_toolchain == "") {
@@ -1176,11 +1192,17 @@ config("compiler_cpu_abi") {
         ldflags += [ "-m64" ]
       }
     } else if (current_cpu == "riscv64") {
-      if (is_clang) {
-        cflags += [ "--target=riscv64-linux-gnu" ]
-        ldflags += [ "--target=riscv64-linux-gnu" ]
+      if(is_clang) {
+        cflags += [ "--target=riscv64-unknown-linux-gnu" ]
+        cflags += [ "--gcc-toolchain=$riscv_gcc_toolchain_path" ]
+        cflags += [ "--sysroot=$riscv_sysroot" ]
+        ldflags += [ "--target=riscv64-unknown-linux-gnu" ]
+        ldflags += [ "--gcc-toolchain=$riscv_gcc_toolchain_path" ]
+        ldflags += [ "--sysroot=$riscv_sysroot" ]
       }
-      cflags += [ "-mabi=lp64d" ]
+      cflags += [
+        "-mabi=lp64d"
+      ]
     } else if (current_cpu == "s390x") {
       cflags += [ "-m64" ]
       ldflags += [ "-m64" ]
diff --git a/config/riscv.gni b/config/riscv.gni
new file mode 100644
index 000000000..9c3397d2a
--- /dev/null
+++ b/config/riscv.gni
@@ -0,0 +1,18 @@
+# Copyright 2022 The Chromium Authors. All rights reserved.
+# Use of this source code is governed by a BSD-style license that can be
+# found in the LICENSE file.
+
+import("//build/config/v8_target_cpu.gni")
+
+# These are primarily relevant in current_cpu == "riscv*" contexts, where
+# RISCV code is being compiled.  But they can also be relevant in the
+# other contexts when the code will change its behavior based on the
+# cpu it wants to generate code for.
+declare_args() {
+    # riscv64 clang need the gcc toolchain to link
+    riscv_gcc_toolchain_path = ""
+    # riscv64 sysroot, clang may be need
+    riscv_sysroot = ""
+
+    use_relax = true
+}
\ No newline at end of file
diff --git a/toolchain/linux/BUILD.gn b/toolchain/linux/BUILD.gn
index 102e71207..6cbb5fc40 100644
--- a/toolchain/linux/BUILD.gn
+++ b/toolchain/linux/BUILD.gn
@@ -165,6 +165,13 @@ clang_v8_toolchain("clang_x64_v8_mips64") {
   }
 }
 
+clang_v8_toolchain("clang_x86_v8_riscv32") {
+  toolchain_args = {
+    current_cpu = "x86"
+    v8_current_cpu = "riscv32"
+  }
+}
+
 clang_v8_toolchain("clang_x64_v8_riscv64") {
   toolchain_args = {
     current_cpu = "x64"
@@ -302,6 +309,16 @@ clang_toolchain("clang_riscv64") {
   }
 }
 
+clang_toolchain("clang_riscv32") {
+  enable_linker_map = true
+  toolchain_args = {
+    current_cpu = "riscv32"
+    current_os = "linux"
+    is_clang = true
+  }
+}
+
+
 gcc_toolchain("riscv64") {
   toolprefix = "riscv64-linux-gnu"
 
@@ -320,6 +337,24 @@ gcc_toolchain("riscv64") {
   }
 }
 
+gcc_toolchain("riscv32") {
+  toolprefix = "riscv32-unknown-linux-gnu"
+
+  cc = "${toolprefix}-gcc"
+  cxx = "${toolprefix}-g++"
+
+  readelf = "${toolprefix}-readelf"
+  nm = "${toolprefix}-nm"
+  ar = "${toolprefix}-ar"
+  ld = cxx
+
+  toolchain_args = {
+    current_cpu = "riscv32"
+    current_os = "linux"
+    is_clang = false
+  }
+}
+
 clang_toolchain("clang_s390x") {
   toolchain_args = {
     current_cpu = "s390x"
-- 
2.25.1
```

args.gn的设置：

```
is_component_build = false
is_debug = true
target_cpu = "riscv64"
v8_target_cpu = "riscv64"
use_goma = false
goma_dir = "None"
treat_warnings_as_errors = false
riscv_gcc_toolchain_path = "/home/cxo/riscv"
riscv_sysroot = "/home/cxo/riscv/sysroot"
use_lld = false
is_clang = true
symbol_level = 0
```

Clang直接使用V8自带的，使用自己编译的，会出现下面的错误：

```
error: unable to find plugin 'find-bad-constructs' 
```
在args.gn里加上`clang_use_chrome_plugins = false`可以解决这个报错。

## Run V8 on QEMU

copy V8_ROOT/v8/out/riscv64.native.debug/d8 V8_ROOT/v8/out/riscv64.native.debug/snapshot_blob.bin 到unmatched上。

执行hello.js:
```
$ cat hello.js
console.log("hello, world!");
$ ./d8 hello.js
hello, world!
```

## Kraken, SunSpider, Octane

参考：https://v8.dev/docs/benchmarks

Kraken有Mozilla创建的JavaScript性能测试benchmark，来源于真实应用程序和库。

![image](https://user-images.githubusercontent.com/26591790/176656676-073b9399-30a7-4b51-83d9-0fdcc8f2db7b.png)

Octane有部分测试项运行报错，详见：https://github.com/riscv-collab/v8/issues/701
