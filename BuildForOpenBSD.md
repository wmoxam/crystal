#!/bin/sh

In OS X:
.build/crystal build --cross-compile "OpenBSD x86_64" --target amd64-unknown-openbsd5.8 src/compiler/crystal.cr

In OpenBSD:
pkg_add llvm pcre boehm-gc libevent

Manually install libpcl (http://www.xmailserver.org/libpcl.html)

clang++ -c -o src/llvm/ext/llvm_ext.o src/llvm/ext/llvm_ext.cc `llvm-config --cxxflags`
clang++ crystal.o -o crystal -rdynamic  src/llvm/ext/llvm_ext.o `(llvm-config --libs --system-libs --ldflags 2> /dev/null)` -lstdc++ -levent -lpcl -lpcre -lgc -lpthread -levent_core -levent_extra
