//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   8 Jan 09  Andy Frank  Creation
//   8 Jul 09  Andy Frank  Split webappClient into sys/dom
//

**
** HttpReq models the request side of an XMLHttpRequest instance.
**
** See [pod doc]`pod-doc#xhr` for details.
**
@Js
class HttpReq
{
  ** Create a new HttpReq instance.
  new make(|This|? f := null)
  {
    if (f != null) f(this)
  }

  ** The Uri to send the request.
  Uri uri := `#`

  ** The request headers to send.
  Str:Str headers := Str:Str[:]

  ** If true then perform this request asynchronously.
  ** Defaults to 'true'
  Bool async := true

  ** The type of data contained in the response. It also lets the
  ** author change the response type. If an empty string is set as
  ** the value, the default value of '"text"' is used.  Set this
  ** field to "arraybuffer" to access response as Buf.
  Str resType := ""

  **
  ** Indicates whether or not cross-site 'Access-Control' requests
  ** should be made using credentials such as cookies, authorization
  ** headers or TLS client certificates. Setting 'withCredentials' has
  ** no effect on same-site requests. The default is 'false'.
  **
  ** Requests from a different domain cannot set cookie values  for
  ** their own domain unless 'withCredentials' is set to 'true' before
  ** making the request. The third-party cookies obtained by setting
  ** 'withCredentials' to 'true' will still honor same-origin policy and
  ** hence can not be accessed by the requesting script through
  ** `Doc.cookies` or from response headers.
  **
  Bool withCredentials := false

  **
  ** Optional callback to track progress of request transfers, where
  ** 'loaded' is the number of bytes that have been transferred, and
  ** 'total' is the total number of bytes to be transferred.
  **
  ** For 'GET' requests, the progress will track the response being
  ** downloaded to the browser.  For 'PUT' and 'POST' requests, the
  ** progress will track the content being uploaded to the server.
  **
  ** Note this callback is only invoked when 'lengthComputable' is
  ** 'true' on the underlying progress events.
  **
  Void onProgress(|Int loaded, Int total| f) { this.cbProgress = f }

  private Func? cbProgress

  **
  ** Send a request with the given content using the given
  ** HTTP method (case does not matter).  After receiving
  ** the response, call the given closure with the resulting
  ** HttpRes object.
  **
  native Void send(Str method, Obj? content, |HttpRes res| c)

  ** Convenience for 'send("GET", "", c)'.
  Void get(|HttpRes res| c)
  {
    send("GET", null, c)
  }

  ** Convenience for 'send("POST", content, c)'.
  Void post(Obj content, |HttpRes res| c)
  {
    send("POST", content, c)
  }

  **
  ** Post the 'form' map as a HTML form submission.  Formats
  ** the map into a valid url-encoded content string, and sets
  ** 'Content-Type' header to 'application/x-www-form-urlencoded'.
  **
  native Void postForm(Str:Str form, |HttpRes res| c)

  **
  ** Post the 'form' as a 'multipart/form-data' submission. Formats
  ** map into multipart key value pairs, where 'DomFile' values will
  ** be encoded with file contents.
  **
  native Void postFormMultipart(Str:Obj form, |HttpRes res| c)
}

