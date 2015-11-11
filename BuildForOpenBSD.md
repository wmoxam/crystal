#!/bin/sh

Need to fetch source for PCL and manually install (I don't think there is a port, could be wrong)

In OS X:
.build/crystal build --cross-compile "OpenBSD Amd64" --target amd64-unknown-openbsd5.8 src/compiler/crystal.cr

In OpenBSD:
clang++ -c -o src/llvm/ext/llvm_ext.o src/llvm/ext/llvm_ext.cc `llvm-config --cxxflags`
clang++ crystal.o -o crystal -rdynamic  src/llvm/ext/llvm_ext.o `(llvm-config --libs --system-libs --ldflags 2> /dev/null)` -lstdc++ -levent -lpcl -lpcre -lgc -lpthread -levent_core -levent_extra
 
