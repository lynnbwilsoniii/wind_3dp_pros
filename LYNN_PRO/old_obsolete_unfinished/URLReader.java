import java.io.*;
import java.net.*;
 
public class URLReader
{
  private ByteArrayOutputStream m_buffer;
  // ********************************************************
  //
  // Constructor.	Create the reader
  //
  // ********************************************************
  public URLReader()
  {
    m_buffer = new ByteArrayOutputStream();
  }
  // ********************************************************
  //
  // readURL: read the data from the URL into our buffer
  //
  //	returns: number of bytes read (0 if invalid URL)
  //
  // NOTE: reading a new URL clears out the previous data
  //
  // ********************************************************
  public int readURL(String sURL)
  {
    URL url;
    InputStream in = null;
    m_buffer.reset();	// reset our holding buffer to 0 bytes
    int total_bytes = 0;
    byte[] tempBuffer = new byte[4096];
    try
    {
      url = new URL(sURL);
      in = url.openStream();
      int bytes_read;
      while ((bytes_read = in.read(tempBuffer)) != -1)
      {
        m_buffer.write(tempBuffer, 0, bytes_read);
        total_bytes += bytes_read;
      }
    }
    catch (Exception e)
    {
      System.err.println("Error reading URL: "+sURL);
      total_bytes = 0;
    }
    finally
    {
      try
      {
        in.close();
        m_buffer.close();
      }
      catch (Exception e) {}
    }
    return total_bytes;
  }
  // ********************************************************
  //
  // getData: return the array of bytes
  //
  // ********************************************************
  public byte[] getData()
  {
    return m_buffer.toByteArray();
  }
  // ********************************************************
  //
  // main: reads URL and reports # of bytes read
  //
  //	Usage: java URLReader <URL>
  //
  // ********************************************************
  public static void main(String[] args)
  {
    if (args.length != 1)
      System.err.println("Usage: URLReader <URL>");
    else
    {
      URLReader o = new URLReader();
      int b = o.readURL(args[0]);
      System.out.println("bytes="+b);
    }
  }
}


