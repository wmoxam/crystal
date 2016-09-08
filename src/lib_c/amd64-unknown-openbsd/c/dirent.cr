require "./sys/types"

lib LibC
  type DIR = Void

  struct Dirent
    d_fileno : InoT
    d_off : OffT
    d_reclen : UInt16
    d_type : UChar
    d_namlen : UChar
    d_name : StaticArray(Char, 256)
  end

  fun closedir(x0 : DIR*) : Int
  fun opendir(x0 : Char*) : DIR*
  fun readdir(x0 : DIR*) : Dirent*
  fun rewinddir(x0 : DIR*) : Void
end
