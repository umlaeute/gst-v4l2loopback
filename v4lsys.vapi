[CCode (cprefix = "", lower_case_cprefix = "")]
namespace v4lsys{
[CCode (cheader_filename = "fcntl.h")]
public const int O_ACCMODE;
[CCode (cheader_filename = "fcntl.h")]
public const int O_RDONLY;
[CCode (cheader_filename = "fcntl.h")]
public const int O_WRONLY;
[CCode (cheader_filename = "fcntl.h")]
public const int O_RDWR;
[CCode (cheader_filename = "fcntl.h")]
public const int O_CREAT;
[CCode (cheader_filename = "fcntl.h")]
public const int O_EXCL;
[CCode (cheader_filename = "fcntl.h")]
public const int O_NOCTTY;
[CCode (cheader_filename = "fcntl.h")]
public const int O_TRUNC;
[CCode (cheader_filename = "fcntl.h")]
public const int O_APPEND;
[CCode (cheader_filename = "fcntl.h")]
public const int O_NONBLOCK;
[CCode (cheader_filename = "fcntl.h")]
public const int O_NDELAY;
[CCode (cheader_filename = "fcntl.h")]
public const int O_SYNC;
[CCode (cheader_filename = "fcntl.h")]
public const int O_FSYNC;
[CCode (cheader_filename = "fcntl.h")]
public const int O_ASYNC;

[CCode (cheader_filename = "unistd.h")]
public int open(string pathname, int flags);

[CCode (cheader_filename = "unistd.h")]
public ssize_t read(int fd, void* buf, size_t count);

[CCode (cheader_filename = "unistd.h")]
public ssize_t write(int fd, void* buf, size_t count);

[CCode (cheader_filename = "unistd.h")]
public int close(int fd);








[CCode (cheader_filename = "sys/ioctl.h")]
int ioctl (int fd, int request, ...);
[CCode (cheader_filename = "linux/videodev.h")]
public const int VIDIOCGCAP;
[CCode (cheader_filename = "linux/videodev.h")]
public const int VIDIOCGPICT;
[CCode (cheader_filename = "linux/videodev.h")]
public const int VIDIOCSPICT;
[CCode (cheader_filename = "linux/videodev.h")]
public const int VIDIOCGWIN;
[CCode (cheader_filename = "linux/videodev.h")]
public const int VIDIOCSWIN;
[CCode (cheader_filename = "linux/videodev.h")]
public const uint16 VIDEO_PALETTE_YUV420P;
[CCode (cheader_filename = "linux/videodev.h")]
public const uint16 VIDEO_PALETTE_YUV422P;
[CCode (cheader_filename = "linux/videodev.h")]
public const uint16 VIDEO_PALETTE_YUV420;
[CCode (cheader_filename = "linux/videodev.h")]
public const uint16 VIDEO_PALETTE_YUV422;
[CCode (cheader_filename = "linux/videodev.h")]
public const uint16 VIDEO_PALETTE_YUV410P;
[CCode (cheader_filename = "linux/videodev.h")]
public const uint16 VIDEO_PALETTE_YUV411P;
[CCode (cheader_filename = "linux/videodev.h")]
public const uint16 VIDEO_PALETTE_RGB24;
[CCode (cheader_filename = "linux/videodev.h")]
public const int VIDEO_MAX_FRAME;

[CCode (cname="struct video_capability", cheader_filename = "linux/videodev.h")]
public struct video_capability
{
  public char[] name;/* use = new char[32] */
  public int type;
  public int channels;/* Num channels */
  public int audios;/* Num audio devices */
  public int maxwidth;/* Supported width */
  public int maxheight;/* And height */
  public int minwidth;/* Supported width */
  public int minheight;/* And height */
}
[CCode (cname="struct video_clip",cheader_filename = "linux/videodev.h")]
public struct video_clip
{
  public uint32 x;
  public uint32 y;
  public int width;
  public int  height;
  public video_clip *next;/* For user use/driver use only */
}
[CCode (cname="struct video_window",cheader_filename = "linux/videodev.h")]
public struct video_window
{
  public uint32 x;
  public uint32 y;
  public uint32 width;
  public uint32 height;           /* Its size */
  public uint32 chromakey;
  public uint32 flags;
  public video_clip *clips;      /* Set only */
  public int    clipcount;
}
[CCode (cname="struct video_mbuf",cheader_filename = "linux/videodev.h")]
public struct video_mbuf
{
  public int     size;           /* Total memory to map */
  public int     frames;         /* Frames */
  public int[]   offsets;        /* use = new int[VIDEO_MAX_FRAME] */
}
[CCode (cname="struct video_picture",cheader_filename = "linux/videodev.h")]
public struct video_picture
{
  public uint16 brightness;
  public uint16 hue;
  public uint16 colour;
  public uint16 contrast;
  public uint16 whiteness;/* Black and white only */
  public uint16 depth;/* Capture depth */
  public uint16 palette;/* Palette in use */
}
}
