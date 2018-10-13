# Intrinsics as exported by LLVM.
# Use `Intrinsics` to have a unified API across LLVM versions.
lib LibIntrinsics
  fun debugtrap = "llvm.debugtrap"
  {% if flag?(:x86_64) %}
    {% if flag?(:"compiler_has_llvm7+") %}
       fun memcpy = "llvm.memcpy.p0i8.p0i8.i64"(dest : Void*, src : Void*, len : UInt64, is_volatile : Bool)
       fun memmove = "llvm.memmove.p0i8.p0i8.i64"(dest : Void*, src : Void*, len : UInt64, is_volatile : Bool)
       fun memset = "llvm.memset.p0i8.i64"(dest : Void*, val : UInt8, len : UInt64, is_volatile : Bool)
    {% else %}
      fun memcpy = "llvm.memcpy.p0i8.p0i8.i64"(dest : Void*, src : Void*, len : UInt64, align : UInt32, is_volatile : Bool)
      fun memmove = "llvm.memmove.p0i8.p0i8.i64"(dest : Void*, src : Void*, len : UInt64, align : UInt32, is_volatile : Bool)
      fun memset = "llvm.memset.p0i8.i64"(dest : Void*, val : UInt8, len : UInt64, align : UInt32, is_volatile : Bool)
    {% end %}
  {% else %}
    {% if flag?(:"compiler_has_llvm7+") %}
      fun memcpy = "llvm.memcpy.p0i8.p0i8.i32"(dest : Void*, src : Void*, len : UInt32, is_volatile : Bool)
      fun memmove = "llvm.memmove.p0i8.p0i8.i32"(dest : Void*, src : Void*, len : UInt32, is_volatile : Bool)
      fun memset = "llvm.memset.p0i8.i32"(dest : Void*, val : UInt8, len : UInt32, is_volatile : Bool)
    {% else %}
      fun memcpy = "llvm.memcpy.p0i8.p0i8.i32"(dest : Void*, src : Void*, len : UInt32, align : UInt32, is_volatile : Bool)
      fun memmove = "llvm.memmove.p0i8.p0i8.i32"(dest : Void*, src : Void*, len : UInt32, align : UInt32, is_volatile : Bool)
      fun memset = "llvm.memset.p0i8.i32"(dest : Void*, val : UInt8, len : UInt32, align : UInt32, is_volatile : Bool)
    {% end %}
  {% end %}
  fun read_cycle_counter = "llvm.readcyclecounter" : UInt64
  fun bswap32 = "llvm.bswap.i32"(id : UInt32) : UInt32

  fun popcount8 = "llvm.ctpop.i8"(src : Int8) : Int8
  fun popcount16 = "llvm.ctpop.i16"(src : Int16) : Int16
  fun popcount32 = "llvm.ctpop.i32"(src : Int32) : Int32
  fun popcount64 = "llvm.ctpop.i64"(src : Int64) : Int64
  fun popcount128 = "llvm.ctpop.i128"(src : Int128) : Int128

  fun va_start = "llvm.va_start"(ap : Void*)
  fun va_end = "llvm.va_end"(ap : Void*)
end

module Intrinsics
  def self.debugtrap
    LibIntrinsics.debugtrap
  end

  macro memcpy(dest, src, len, is_volatile)
    {% if flag?(:"compiler_has_llvm7+") %}
      LibIntrinsics.memcpy({{dest}}, {{src}}, {{len}}, {{is_volatile}})
    {% else %}
      LibIntrinsics.memcpy({{dest}}, {{src}}, {{len}}, 0, {{is_volatile}})
    {% end %}
  end

  macro memmove(dest, src, len, is_volatile)
    {% if flag?(:"compiler_has_llvm7+") %}
      LibIntrinsics.memmove({{dest}}, {{src}}, {{len}}, {{is_volatile}})
    {% else %}
      LibIntrinsics.memmove({{dest}}, {{src}}, {{len}}, 0, {{is_volatile}})
    {% end %}
  end

  macro memset(dest, val, len, is_volatile)
    {% if flag?(:"compiler_has_llvm7+") %}
      LibIntrinsics.memset({{dest}}, {{val}}, {{len}}, {{is_volatile}})
    {% else %}
      LibIntrinsics.memset({{dest}}, {{val}}, {{len}}, 0, {{is_volatile}})
    {% end %}
  end

  def self.read_cycle_counter
    LibIntrinsics.read_cycle_counter
  end

  def self.bswap32(id)
    LibIntrinsics.bswap32(id)
  end

  def self.popcount8(src)
    LibIntrinsics.popcount8(src)
  end

  def self.popcount16(src)
    LibIntrinsics.popcount16(src)
  end

  def self.popcount32(src)
    LibIntrinsics.popcount32(src)
  end

  def self.popcount64(src)
    LibIntrinsics.popcount64(src)
  end

  def self.popcount128(src)
    LibIntrinsics.popcount128(src)
  end

  def self.va_start(ap)
    LibIntrinsics.va_start(ap)
  end

  def self.va_end(ap)
    LibIntrinsics.va_end(ap)
  end
end

macro debugger
  Intrinsics.debugtrap
end
