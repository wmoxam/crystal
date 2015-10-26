#!/bin/sh

.build/crystal build --cross-compile "OpenBSD Amd64" --target amd64-unknown-openbsd5.8 src/compiler/crystal.cr

clang++ crystal.o -o crystal `(llvm-config --libs --system-libs --ldflags 2> /dev/null)` -lstdc++ -levent -lpcl -lpcre -lgc -lpthread -levent_core -levent_extra
