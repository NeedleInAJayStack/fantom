//
// Copyright (c) 2007, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   9 Feb 07  Brian Frank  Creation
//
package fan.inet;

import java.io.*;
import java.net.*;
import fan.sys.*;
import fan.sys.Thread;

public class UdpSocketPeer
  extends DatagramSocket
{

//////////////////////////////////////////////////////////////////////////
// Peer Factory
//////////////////////////////////////////////////////////////////////////

  public static UdpSocketPeer make(UdpSocket fan)
  {
    try
    {
      return new UdpSocketPeer();
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public UdpSocketPeer()
    throws IOException
  {
    super((SocketAddress)null);
  }

//////////////////////////////////////////////////////////////////////////
// State
//////////////////////////////////////////////////////////////////////////

  public Boolean isBound(UdpSocket fan)
  {
    return isBound();
  }

  public Boolean isConnected(UdpSocket fan)
  {
    return isConnected();
  }

  public Boolean isClosed(UdpSocket fan)
  {
    return isClosed();
  }

//////////////////////////////////////////////////////////////////////////
// End Points
//////////////////////////////////////////////////////////////////////////

  public IpAddress localAddress(UdpSocket fan)
  {
    if (!isBound()) return null;
    InetAddress addr = getLocalAddress();
    if (addr == null) return null;
    return IpAddressPeer.make(addr);
  }

  public Long localPort(UdpSocket fan)
  {
    if (!isBound()) return null;
    int port = getLocalPort();
    if (port <= 0) return null;
    return Long.valueOf(port);
  }

  public IpAddress remoteAddress(UdpSocket fan)
  {
    if (!isConnected()) return null;
    return remoteAddr;
  }

  public Long remotePort(UdpSocket fan)
  {
    if (!isConnected()) return null;
    return Long.valueOf(remotePort);
  }

//////////////////////////////////////////////////////////////////////////
// Communication
//////////////////////////////////////////////////////////////////////////

  public UdpSocket bind(UdpSocket fan, IpAddress addr, Long port)
  {
    try
    {
      InetAddress javaAddr = (addr == null) ? null : addr.peer.java;
      int javaPort = (port == null) ? 0 : port.intValue();
      bind(new InetSocketAddress(javaAddr, javaPort));
      return fan;
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public UdpSocket connect(UdpSocket fan, IpAddress addr, Long port)
  {
    try
    {
      connect(new InetSocketAddress(addr.peer.java, port.intValue()));
      this.remoteAddr = addr;
      this.remotePort = port.intValue();
      return fan;
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public void send(UdpSocket fan, UdpPacket packet)
  {
    // map buf bytes to packet
    MemBuf data = (MemBuf)packet.data();
    byte[] buf = data.buf;
    int off = data.pos;
    int len = data.size - off;
    DatagramPacket datagram = new DatagramPacket(buf, off, len);

    // map address, port
    IpAddress addr = packet.address();
    Long port = packet.port();
    if (isConnected())
    {
      if (addr != null || port != null)
        throw ArgErr.make("Address and port must be null to send while connected").val;
    }
    else
    {
      if (addr == null || port == null)
        throw ArgErr.make("Address or port is null").val;
      datagram.setAddress(addr.peer.java);
      datagram.setPort(port.intValue());
    }

    // send
    try
    {
      send(datagram);
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }

    // lastly drain buff
    data.pos += len;
  }

  public UdpPacket receive(UdpSocket fan, UdpPacket packet)
  {
    // create packet if null
    if (packet == null)
      packet = UdpPacket.make(null, null, new MemBuf(1024));

    // map buf bytes to packet
    MemBuf data = (MemBuf)packet.data();
    byte[] buf = data.buf;
    int off = data.pos;
    int len = buf.length - off;
    DatagramPacket datagram = new DatagramPacket(buf, off, len);

    // receive
    try
    {
      receive(datagram);
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }

    // update packet with received message
    packet.address(IpAddressPeer.make(datagram.getAddress()));
    packet.port(Long.valueOf(datagram.getPort()));
    data.pos  += datagram.getLength();
    data.size += datagram.getLength();

    return packet;
  }

  public UdpSocket disconnect(UdpSocket fan)
  {
    disconnect();
    this.remoteAddr = null;
    this.remotePort = -1;
    return fan;
  }

  public Boolean close(UdpSocket fan)
  {
    try
    {
      close();
      return true;
    }
    catch (Exception e)
    {
      return false;
    }
  }

//////////////////////////////////////////////////////////////////////////
// Socket Options
//////////////////////////////////////////////////////////////////////////

  public SocketOptions options(UdpSocket fan)
  {
    if (options == null) options = SocketOptions.make(fan);
    return options;
  }

  public Boolean getBroadcast(UdpSocket fan)
  {
    try
    {
      return getBroadcast();
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public void setBroadcast(UdpSocket fan, Boolean v)
  {
    try
    {
      setBroadcast(v);
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public Long getReceiveBufferSize(UdpSocket fan)
  {
    try
    {
      return Long.valueOf(getReceiveBufferSize());
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public void setReceiveBufferSize(UdpSocket fan, Long v)
  {
    try
    {
      setReceiveBufferSize(v.intValue());
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public Long getSendBufferSize(UdpSocket fan)
  {
    try
    {
      return Long.valueOf(getSendBufferSize());
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public void setSendBufferSize(UdpSocket fan, Long v)
  {
    try
    {
      setSendBufferSize(v.intValue());
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public Boolean getReuseAddress(UdpSocket fan)
  {
    try
    {
      return getReuseAddress();
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public void setReuseAddress(UdpSocket fan, Boolean v)
  {
    try
    {
      setReuseAddress(v);
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public Duration getReceiveTimeout(UdpSocket fan)
  {
    try
    {
      int timeout = getSoTimeout();
      if (timeout <= 0) return null;
      return Duration.makeMillis(timeout);
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public void setReceiveTimeout(UdpSocket fan, Duration v)
  {
    try
    {
      if (v == null)
        setSoTimeout(0);
      else
        setSoTimeout((int)(v.millis()));
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public Long getTrafficClass(UdpSocket fan)
  {
    try
    {
      return Long.valueOf(getTrafficClass());
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

  public void setTrafficClass(UdpSocket fan, Long v)
  {
    try
    {
      setTrafficClass(v.intValue());
    }
    catch (IOException e)
    {
      throw IOErr.make(e).val;
    }
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  private IpAddress remoteAddr;
  private int remotePort = -1;
  private SocketOptions options;

}