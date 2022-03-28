using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Civilization;
namespace Front_End
{
    internal class Program
    {
        static void Main(string[] args)
        {
            const string kInputFile = "file.CivBeyondSwordSave";
            string[] directories = { 
                //@"C:\Users\Dan\Documents\My Games\beyond the sword\Saves\single\auto", 
                @"C:\Users\Dan\Documents\My Games\beyond the sword\Saves\single" };
            Converter converter = new Converter();

            for(int i = 0; i < directories.Length; ++i)
            {
                string filename = Path.Combine(directories[i],kInputFile);
                
                converter.ConvertFile(filename);
            }
        }
    }
}
