[CCode (cprefix = "", lower_case_cprefix = "")]
namespace v4lsys{
[CCode (cheader_filename = "sys/ioctl.h")]
int ioctl (int fd, int request, ...);
[CCode (cheader_filename = "linux/videodev2.h")]
public const int VIDIOC_QUERYCAP;
[CCode (cheader_filename = "linux/videodev2.h")]
public const int VIDIOC_TRY_FMT;
[CCode (cheader_filename = "linux/videodev2.h")]
public const int VIDIOC_S_FMT;

[CCode (cheader_filename = "linux/videodev2.h")]
public const uint32 V4L2_PIX_FMT_YUV420;
[CCode (cheader_filename = "linux/videodev2.h")]
public const uint32 V4L2_PIX_FMT_RGB24;
[CCode (cheader_filename = "linux/videodev2.h")]
public const uint32 V4L2_PIX_FMT_YUYV;
[CCode (cname="struct v4l2_capability", cheader_filename = "linux/videodev2.h")]
public struct v4l2_capability
{
  public uint8[] driver; // __u8[16] i.e. "bttv"
  public uint8[] card; // __u8[32] i.e. "Hauppauge WinTV"
  public uint8[] bus_info; // __u8[32]"PCI:" + pci_name(pci_dev)
  public uint32 version;        // should use KERNEL_VERSION()
  public uint32 capabilities; // Device capabilities
  public uint32[] reserved; // __u32[4] have to be 0
}
[CCode (cname="struct v4l2_format", cheader_filename = "linux/videodev2.h")]
public struct v4l2_format
{
  public v4l2_buf_type type;
  public v4lformat fmt;
}
public struct v4lformat
{
  public v4l2_pix_format    pix;     // V4L2_BUF_TYPE_VIDEO_CAPTURE
  public v4l2_window    win;     // V4L2_BUF_TYPE_VIDEO_OVERLAY
  public v4l2_vbi_format    vbi;     // V4L2_BUF_TYPE_VBI_CAPTURE
  public v4l2_sliced_vbi_format sliced;  // V4L2_BUF_TYPE_SLICED_VBI_CAPTURE
  public uint8[]  raw_data;                   // __u8[200] user-defined
}
[CCode (cname="", cprefix="", cheader_filename = "linux/videodev2.h")]
public enum v4l2_buf_type {
  V4L2_BUF_TYPE_VIDEO_CAPTURE        = 1,
  V4L2_BUF_TYPE_VIDEO_OUTPUT         = 2,
  V4L2_BUF_TYPE_VIDEO_OVERLAY        = 3,
  V4L2_BUF_TYPE_VBI_CAPTURE          = 4,
  V4L2_BUF_TYPE_VBI_OUTPUT           = 5,
  V4L2_BUF_TYPE_SLICED_VBI_CAPTURE   = 6,
  V4L2_BUF_TYPE_SLICED_VBI_OUTPUT    = 7,
  V4L2_BUF_TYPE_VIDEO_OUTPUT_OVERLAY = 8,
  V4L2_BUF_TYPE_PRIVATE              = 0x80,
}
[CCode (cname="struct v4l2_pix_format", cheader_filename = "linux/videodev2.h")]
public struct v4l2_pix_format
{
  public uint32   width;
  public uint32   height;
  public uint32   pixelformat;
  public v4l2_field field;
  public uint32   bytesperline; /* for padding, zero if unused */
  public uint32   sizeimage;
  public v4l2_colorspace  colorspace;
  public uint32   priv;   /* private data, depends on pixelformat */
}
[CCode (cname="struct v4l2_window", cheader_filename = "linux/videodev2.h")]
public struct v4l2_window
{
  public v4l2_rect  w;
  public v4l2_field   field;
  public uint32     chromakey;
  public v4l2_clip *clips;
  public uint32     clipcount;
  public void     *bitmap;
  public uint8  global_alpha;
}
[CCode (cname="struct v4l2_vbi_format", cheader_filename = "linux/videodev2.h")]
public struct v4l2_vbi_format
{
  public uint32 sampling_rate;    /* in 1 Hz */
  public uint32 offset;
  public uint32 samples_per_line;
  public uint32 sample_format;    /* V4L2_PIX_FMT_* */
  public int32[] start;      /* __s32[2]  */
  public uint32[] count;      /* __u32[2]  */
  public uint32 flags;      /* V4L2_VBI_* */
  public uint32[] reserved;    /*  __u32[2]   must be zero */
}
[CCode (cname="struct v4l2_siced_vbi_format", cheader_filename = "linux/videodev2.h")]
public struct v4l2_sliced_vbi_format
{
  public uint16   service_set;
  /* service_lines[0][...] specifies lines 0-23 (1-23 used) of the first field
     service_lines[1][...] specifies lines 0-23 (1-23 used) of the second field
         (equals frame lines 313-336 for 625 line video
          standards, 263-286 for 525 line standards) */
  public uint16[][]   service_lines; /* uint16[2][24] */
  public uint32   io_size;
  public uint32[] reserved;            /* __u32[2] must be zero */
}
[CCode (cname="", cprefix="", cheader_filename = "linux/videodev2.h")]
public enum v4l2_field {
  V4L2_FIELD_ANY           = 0, /* driver can choose from none,
           top, bottom, interlaced
           depending on whatever it thinks
           is approximate ... */
  V4L2_FIELD_NONE          = 1, /* this device has no fields ... */
  V4L2_FIELD_TOP           = 2, /* top field only */
  V4L2_FIELD_BOTTOM        = 3, /* bottom field only */
  V4L2_FIELD_INTERLACED    = 4, /* both fields interlaced */
  V4L2_FIELD_SEQ_TB        = 5, /* both fields sequential into one
           buffer, top-bottom order */
  V4L2_FIELD_SEQ_BT        = 6, /* same as above + bottom-top order */
  V4L2_FIELD_ALTERNATE     = 7, /* both fields alternating into
           separate buffers */
  V4L2_FIELD_INTERLACED_TB = 8, /* both fields interlaced, top field
           first and the top field is
           transmitted first */
  V4L2_FIELD_INTERLACED_BT = 9, /* both fields interlaced, top field
           first and the bottom field is
           transmitted first */
}
[CCode (cname="", cprefix="", cheader_filename = "linux/videodev2.h")]
public enum v4l2_colorspace {
  /* ITU-R 601 -- broadcast NTSC/PAL */
  V4L2_COLORSPACE_SMPTE170M     = 1,

  /* 1125-Line (US) HDTV */
  V4L2_COLORSPACE_SMPTE240M     = 2,

  /* HD and modern captures. */
  V4L2_COLORSPACE_REC709        = 3,

  /* broken BT878 extents (601, luma range 16-253 instead of 16-235) */
  V4L2_COLORSPACE_BT878         = 4,

  /* These should be useful.  Assume 601 extents. */
  V4L2_COLORSPACE_470_SYSTEM_M  = 5,
  V4L2_COLORSPACE_470_SYSTEM_BG = 6,

  /* I know there will be cameras that send this.  So, this is
   * unspecified chromaticities and full 0-255 on each of the
   * Y'CbCr components
   */
  V4L2_COLORSPACE_JPEG          = 7,

  /* For RGB colourspaces, this is probably a good start. */
  V4L2_COLORSPACE_SRGB          = 8,
}
[CCode (cname="struct v4l2_rect", cheader_filename = "linux/videodev2.h")]
public struct v4l2_rect {
  public int32 left;
  public int32 top;
  public int32 width;
  public int32 height;
}
[CCode (cname="struct v4l2_clip", cheader_filename = "linux/videodev2.h")]
public struct v4l2_clip
{
  public v4l2_rect        c;
  public v4l2_clip *next;
}
}
