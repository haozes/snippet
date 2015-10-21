using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Text.RegularExpressions;
using System.IO;
using Microsoft.Win32;
using System.Runtime.InteropServices;


namespace BingWallPaper
{
    class Program
    {
        static void Main(string[] args)
        {
            Bing bing = new Bing();
            bing.SetDesktopFromBing();
        }
    }

    class Bing
    {
        public void SetDesktopFromBing()
        {
            string dst= DownloadImgFromBing(Environment.GetFolderPath(Environment.SpecialFolder.CommonPictures));
            if (!String.IsNullOrEmpty(dst))
            {
                setDesktop(dst);
            }
        }

        string getPicUrl(string html) { 
            string result=Regex.Match(html,@"g_img=\{url:'(.+?)',id:'bgDiv'").Groups[1].Value;
            return result.Replace("\\","");
        }

         string DownloadImgFromBing(string saveDir) {
             var url = "http://cn.bing.com";
             using (WebClient wc = new WebClient())
             {
                 wc.Encoding = Encoding.GetEncoding("utf-8");
                 string htmlResult = wc.DownloadString(url);
                 if (!string.IsNullOrEmpty(htmlResult))
                 {
                     var pic = getPicUrl(htmlResult);

                     string localFilename = System.IO.Path.Combine(saveDir, @"bing.jpg");
                     using (WebClient client = new WebClient())
                     {
                         client.DownloadFile(pic, localFilename);
                     }
                     return localFilename;
                 }
             }
            return "";
        }

         void setDesktop(string imgPath) {

             Wallpaper.Set(new Uri(imgPath), Wallpaper.Style.Stretched);
        }
    }


    public sealed class Wallpaper
    {
        Wallpaper() { }

        const int SPI_SETDESKWALLPAPER = 20;
        const int SPIF_UPDATEINIFILE = 0x01;
        const int SPIF_SENDWININICHANGE = 0x02;

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);

        public enum Style : int
        {
            Tiled,
            Centered,
            Stretched
        }

        public static void Set(Uri uri, Style style)
        {
            System.IO.Stream s = new System.Net.WebClient().OpenRead(uri.ToString());

            System.Drawing.Image img = System.Drawing.Image.FromStream(s);
            string tempPath = Path.Combine(Path.GetTempPath(), "wallpaper.bmp");
            img.Save(tempPath, System.Drawing.Imaging.ImageFormat.Bmp);

            RegistryKey key = Registry.CurrentUser.OpenSubKey(@"Control Panel\Desktop", true);
            if (style == Style.Stretched)
            {
                key.SetValue(@"WallpaperStyle", 2.ToString());
                key.SetValue(@"TileWallpaper", 0.ToString());
            }

            if (style == Style.Centered)
            {
                key.SetValue(@"WallpaperStyle", 1.ToString());
                key.SetValue(@"TileWallpaper", 0.ToString());
            }

            if (style == Style.Tiled)
            {
                key.SetValue(@"WallpaperStyle", 1.ToString());
                key.SetValue(@"TileWallpaper", 1.ToString());
            }

            SystemParametersInfo(SPI_SETDESKWALLPAPER,
                0,
                tempPath,
                SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
        }
    }
}
