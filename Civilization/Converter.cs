using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.IO.Compression;
namespace Civilization
{
    public class Converter
    {

        public void ConvertFile(string szSourceFile)
        {
            
            byte[] zlib_header = { 0x78, 0x9c };


            byte[] full_file = File.ReadAllBytes(szSourceFile);
            string str_file = File.ReadAllText(szSourceFile);
            char[] chr_file = str_file.ToCharArray();
            //Find where the z-lib bit starts
            int idx = FindSubArray(zlib_header, full_file);

            if(idx < 0)
            {
                return;
            }

            MemoryStream file_stream = new MemoryStream(full_file);
            //The 4 bytes before the zlib is the count
            idx -= 4;

            byte[] header = new byte[idx];
            file_stream.Read(header, 0, header.Length);

            byte[] tmp = new byte[4];
            file_stream.Read(tmp,0, tmp.Length);

            long count = BitConverter.ToInt32(tmp, 0);
            
            tmp = new byte[2];
            file_stream.Read(tmp, 0, tmp.Length);    //This should return us our zlib header
            bool ok = true;

            byte[] full_data = new byte[0];
            while (ok)
            {
                byte[] buffer = new byte[(int)count];
                file_stream.Read(buffer, 0, (int)count);
                tmp = new byte[4];
                file_stream.Read(tmp,0,tmp.Length);
                byte[] data;
                ok = Inflate(buffer, out data);

                if(ok)
                {
                    byte[] temp = new byte[full_data.Length + data.Length];
                    Array.Copy(full_data, 0, temp, 0, full_data.Length);
                    Array.Copy(data, 0, temp, full_data.Length, data.Length);
                    full_data = temp;
                }
            }

            File.WriteAllBytes("temp.txt", full_data);
            File.WriteAllText("strin.txt", Encoding.ASCII.GetString(full_data));
        }

        int FindSubArray(byte[] sub, byte[] full)
        {
            int idx = -1;
            int result = -1;
            while(idx < full.Length && result == -1)
            {
                idx = Array.IndexOf(full, sub[0]);

                if(idx != -1)
                {
                    int subIdx = Array.IndexOf(full, sub[1], idx);
                    if(subIdx == idx +1)
                    {
                        result = idx;
                    }
                }
            }

            return result;

        }

        bool Inflate(byte[] data_in, out byte[] data_out)
        {
            using (MemoryStream ms = new MemoryStream(data_in))
            {
                MemoryStream inner = new MemoryStream();
                using (DeflateStream z = new DeflateStream(ms, CompressionMode.Decompress))
                {
                    try
                    {
                        z.CopyTo(inner);
                        data_out = new byte[inner.Length];
                        inner.Seek(0,SeekOrigin.Begin);
                        inner.Read(data_out, 0, data_out.Length);
                        string str = Encoding.Default.GetString(data_out);
                        Console.WriteLine(str);
                    }
                    catch
                    {
                        data_out = null;
                        return false;
                    }
                }
            }

            return true;
        }
    }
}
