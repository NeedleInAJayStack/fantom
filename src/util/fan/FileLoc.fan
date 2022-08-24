//
// Copyright (c) 2022, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   11 Aug 22  Brian Frank  Creation
//

**
** FileLoc is a location within a text file or source string.
** It includes an optional one-base line number and column number.
** This class provides a standardized API for text based tools which
** need to report the line/column numbers of errors.
**
@Js
const class FileLoc
{
  ** Constant for an unknown location
  static const FileLoc unknown := make("unknown", 0)

  ** Constant for tool input location
  static const FileLoc inputs := make("inputs", 0)

  ** Constant for synthetic location
  static const FileLoc synthetic := make("synthetic", 0)

  ** Constructor for file
  static new makeFile(File file, Int line := 0, Int col := 0)
  {
    uri := file.uri
    name := uri.scheme == "fan" ? "$uri.host::$uri.pathStr" : file.pathStr
    return make(name, line, col)
  }

  ** Constructor for filename string
  new make(Str file, Int line := 0, Int col := 0)
  {
    this.file = file
    this.line = line
    this.col  = col
  }

  ** Filename location
  const Str file

  ** One based line number or zero if unknown
  const Int line

  ** One based line column number or zero if unknown
  const Int col

  ** Hash code
  override Int hash()
  {
    file.hash.xor(line.hash).xor(col.hash.shiftl(17))
  }

  ** Equality operator
  override Bool equals(Obj? that)
  {
    x := that as FileLoc
    if (x == null) return false
    return file == x.file && line == x.line && col == x.col
  }

  ** Comparison operator
  override Int compare(Obj that)
  {
    x := (FileLoc)that
    if (file != x.file) return file <=> x.file
    if (line != x.line) return line <=> x.line
    return col <=> x.col
  }

  ** Return string representation.
  ** This is the standard format used by the Fantom compiler.
  override Str toStr()
  {
    if (line <= 0) return file
    if (col <= 0) return "$file($line)"
    return "$file($line,$col)"
  }

}
