//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Jan 09  Andy Frank  Creation
//   8 Jul 09  Andy Frank  Split webappClient into sys/dom
//

**
** HttpRes models the response side of an XMLHttpRequest instance.
**
** See [pod doc]`pod-doc#xhr` for details.
**
@Js
class HttpRes
{
  ** Private ctor.
  private new make() {}

  ** The HTTP status code of the response.
  Int status

  ** The response headers.
  Str:Str headers := Str:Str[:] { it.caseInsensitive = true }

  ** The text content of the response when the XMLHttpRequest
  ** `HttpReq.resType` is "text"
  Str content := ""

  ** The binary content of the response when the XMLHttpRequest
  ** `HttpReq.resType` is "arraybuffer"
  Buf contentBuf := Buf(0)
}

