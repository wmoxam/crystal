require "llvm"
require "./syntax/ast"
require "./types"
require "./program"

module Crystal
  class Program
    def define_primitives
      define_object_primitives
      define_primitive_types_primitives
      define_reference_primitives
      define_pointer_primitives
      define_symbol_primitives
    end

    def define_object_primitives
      object.add_def Def.new("class", body: Primitive.new(:class))
      object.add_def Def.new("crystal_type_id", body: Primitive.new(:object_crystal_type_id))
      # object.metaclass.add_def Def.new("name", body: Primitive.new(:class_name))
    end

    def define_primitive_types_primitives
      binary = Primitive.new(:binary)
      cast = Primitive.new(:cast)

      ints = [int8, int16, int32, int64, uint8, uint16, uint32, uint64]
      floats = [float32, float64]
      nums = ints + floats

      # The `/` operator is only defined for int vs float combinations.
      # The `/` operator for int vs int is defined in Crystal on top
      # of unsafe div.
      # The same goes with the `%`, `>>` and `<<` operators.

      %w(+ - *).each do |op|
        nums.product(nums) do |num1, num2|
          num1.add_def Def.new(op, [Arg.new("other", restriction: Path.global(num2.to_s))], binary)
        end
      end

      floats.product(ints) do |num1, num2|
        num1.add_def Def.new("/", [Arg.new("other", restriction: Path.global(num2.to_s))], binary)
        num2.add_def Def.new("/", [Arg.new("other", restriction: Path.global(num1.to_s))], binary)
      end

      floats.product(floats) do |num1, num2|
        num1.add_def Def.new("/", [Arg.new("other", restriction: Path.global(num2.to_s))], binary)
      end

      %w(== < <= > >= !=).each do |op|
        nums.product(nums) do |num1, num2|
          num1.add_def Def.new(op, [Arg.new("other", restriction: Path.global(num2.to_s))], binary)
        end
        char.add_def Def.new(op, [Arg.new("other", restriction: Path.global(char.to_s))], binary)
      end

      %w(unsafe_shl unsafe_shr | & ^ unsafe_div unsafe_mod).each do |op|
        ints.each do |another_int|
          int.add_def Def.new(op, [Arg.new("other", restriction: Path.global(another_int.to_s))], binary)
        end
      end

      [bool, symbol].each do |type|
        %w(== !=).each do |op|
          type.add_def Def.new(op, [Arg.new("other", restriction: Path.global(type.to_s))], binary)
        end
      end

      %w(to_i to_i8 to_i16 to_i32 to_i64 to_u to_u8 to_u16 to_u32 to_u64 to_f to_f32 to_f64).each do |op|
        nums.each do |num|
          num.add_def Def.new(op, body: cast)
        end
      end

      int.add_def Def.new("chr", body: cast)
      char.add_def Def.new("ord", body: cast)
      symbol.add_def Def.new("to_i", body: cast)
    end

    def define_reference_primitives
      reference.add_def Def.new("object_id", body: Primitive.new(:object_id))
    end

    def define_pointer_primitives
      pointer.metaclass.add_def Def.new("malloc", [Arg.new("size", restriction: Path.global(uint64.to_s))], Primitive.new(:pointer_malloc))
      pointer.metaclass.add_def Def.new("new", [Arg.new("address", restriction: Path.global("UInt64"))], Primitive.new(:pointer_new))
      pointer.add_def Def.new("value", body: Primitive.new(:pointer_get))
      pointer.add_def Def.new("value=", [Arg.new("value", restriction: Path.new("T"))], Primitive.new(:pointer_set))
      pointer.add_def Def.new("address", body: Primitive.new(:pointer_address))
      pointer.add_def Def.new("realloc", [Arg.new("size", restriction: Path.global(uint64.to_s))], Primitive.new(:pointer_realloc))
      pointer.add_def Def.new("+", [Arg.new("offset", restriction: Path.global(int64.to_s))], Primitive.new(:pointer_add))
      pointer.add_def Def.new("-", [Arg.new("other", restriction: Self.new)], Primitive.new(:pointer_diff))
    end

    def define_symbol_primitives
      symbol.add_def Def.new("hash", body: Primitive.new(:symbol_hash))
      symbol.add_def Def.new("to_s", body: Primitive.new(:symbol_to_s))
    end

    def sprintf(llvm_mod)
      llvm_mod.functions["sprintf"]? || llvm_mod.functions.add("sprintf", [LLVM::VoidPointer], LLVM::Int32, true)
    end

    def printf(llvm_mod)
      llvm_mod.functions["printf"]? || llvm_mod.functions.add("printf", [LLVM::VoidPointer], LLVM::Int32, true)
    end

    def realloc(llvm_mod)
      llvm_mod.functions["realloc"]? || llvm_mod.functions.add("realloc", ([LLVM::VoidPointer, LLVM::Int64]), LLVM::VoidPointer)
    end

    def memset(llvm_mod)
      llvm_mod.functions["llvm.memset.p0i8.i32"]? || llvm_mod.functions.add("llvm.memset.p0i8.i32", [LLVM::VoidPointer, LLVM::Int8, LLVM::Int32, LLVM::Int32, LLVM::Int1], LLVM::Void)
    end

    def memcpy(llvm_mod)
      llvm_mod.functions["llvm.memcpy.p0i8.p0i8.i32"]? || llvm_mod.functions.add("llvm.memcpy.p0i8.p0i8.i32", [LLVM::VoidPointer, LLVM::VoidPointer, LLVM::Int32, LLVM::Int32, LLVM::Int1], LLVM::Void)
    end
  end
end
