using Gst, GLib, Posix, V4l2;

//unknown: 
//what is the differens between names in different structures?
//how are the names related to class name?
//why pad factory are static?//answer - this is just a struct used to registre pad, no need to keep a copy for every element
//how vala construction procedure maps to _base_init, _class_init and _init, when it is sayed that things in Gst element should be inited in _base_init, where are they should be in vala code?//partial answer:_base_init or _class_init is a class construct, _init is a construct
//what is the difference between plugin and element?//answer - plugin is something like class, element is instance
//when it is best to call Plugin.register_static?//ansewr - anywhere between Gst.Init and call to element factory

/** 
  Class that inherits from VideoSink. It should be easier to implement than subclassing Element.
 */
public class V4l2SinkLoopback : Gst.VideoSink
{
 //must always do the same thing for an element registration, as data is cached in central registry, so function is static
 public static bool plugin_init(Plugin p) {
    //create element factory and add it to plugin p
    GLib.debug("v4lSink plugin_init");
    return Element.register(p, "V4l2SinkLoopback", Rank.NONE, typeof(V4l2SinkLoopback));
  }

 //must always do the same work for a plugin registration, as data is cached in central registry, so function is static
 public static bool v4l2sink_register() {
    //static registration of a plugin, so that it can be used by application only
    GLib.debug("v4lSink register");
    bool plugin_registered = Plugin.register_static(
        VERSION_MAJOR, VERSION_MINOR, "v4loopbacksink-plugin", "sink to v4l loopback device", plugin_init, "0.01",
        "LGPL", "belongs to source",  "belongs to package", "http://code.google.com/p/v4lsink/");
    GLib.assert(plugin_registered);
    return true;
  }

  static const ElementDetails details = {//GstElementDetails equivalent fields are:
    "V4l2SinkLoopback",//longname
    "v4lsink",//klass, whatever this means, they say look at klass-draft.txt
    "sink to v4l loopback device",//description
    "vasaka <vasaka at gmail.com>"//me
  };

  static StaticPadTemplate pad_factory;//pad factory, used to create an input pad
  private int output_fd;//output device descriptor
  private weak V4l2.Capability vid_caps;
  private weak V4l2.Format vid_format;

  //element should not be instantiated by operator new, register it and then use ElementFactory.make, it will call construct.
  class construct  {
    GLib.debug("v4lSink construct");
    pad_factory.name_template = "sink";
    pad_factory.direction = PadDirection.SINK;//direction of the pad: can be sink, or src
    pad_factory.presence = PadPresence.ALWAYS;//when pad is available
    pad_factory.static_caps.str = "video/x-raw-yuv, width=640, height=480, format=(fourcc)YUY2";//types pad accepts
    add_pad_template(pad_factory.@get());//actual pad registration, this function is inherited from Element class 
    set_details(details);//set details for V4l2SinkLoopback(this klass)
  }

  construct
  {
    this.output_fd = Posix.open("/dev/video1", Posix.O_RDWR);
    GLib.assert(this.output_fd>=0); GLib.debug("device opened");
    int ret_code = Posix.ioctl(this.output_fd, V4l2.VIDIOC_QUERYCAP, &this.vid_caps);
    GLib.assert(ret_code != -1); GLib.debug("got caps");
    this.vid_format.type = V4l2.BufferType.VIDEO_OUTPUT;
    this.vid_format.fmt.pix.width = 640;
    this.vid_format.fmt.pix.height = 480;
    this.vid_format.fmt.pix.pixelformat = V4l2.PixelFormatType.YUYV;
    this.vid_format.fmt.pix.sizeimage = 640*480*2;
    this.vid_format.fmt.pix.field = V4l2.Field.NONE;
    this.vid_format.fmt.pix.bytesperline = 640*2;
    this.vid_format.fmt.pix.colorspace = V4l2.Colorspace.SRGB;
    ret_code = Posix.ioctl(this.output_fd, V4l2.VIDIOC_S_FMT, &this.vid_format);
    GLib.assert(ret_code != -1); GLib.debug("set format");
  }

  public override Gst.FlowReturn render(Gst.Buffer buf)
  {
    //GLib.debug("render");
    Posix.write(this.output_fd, buf.data, buf.size);
    return Gst.FlowReturn.OK;
  }
}


