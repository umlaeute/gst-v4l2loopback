using Gst, GLib;

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
public class v4lSinkLoopback : Gst.VideoSink
{
  public static bool plugin_init(Plugin p)//must always do the same thing for an element registration, as data is cached in central registry, so function is static
  {
    //create element factory and add it to plugin p
    GLib.debug("v4lSink plugin_init");
    return Element.register(p, "v4lSinkLoopback", Rank.NONE, typeof(v4lSinkLoopback));
  }

  public static void register()//must always do the same work for a plugin registration, as data is cached in central registry, so function is static
  {
    //static registration of a plugin, so that it can be used by application only
    GLib.debug("v4lSink register");
    bool plugin_registered = Plugin.register_static(
        VERSION_MAJOR, VERSION_MINOR, "v4loopbacksink-plugin", "sink to v4l loopback device", plugin_init, "0.01",
        "LGPL", "belongs to source",  "belongs to package", "http://code.google.com/p/v4lsink/");
    assert(plugin_registered);
  }

  static const ElementDetails details = {//GstElementDetails equivalent fields are:
    "v4lSinkLoopback",//longname
    "v4lsink",//klass, whatever this means, they say look at klass-draft.txt
    "sink to v4l loopback device",//description
    "vasaka <vasaka at gmail.com>"//me
  };

  static StaticPadTemplate pad_factory;//pad factory, used to create an input pad
  GLib.File device;
  GLib.OutputStream out_stream;

  class construct//element should not be instantiated by operator new, register it and then use ElementFactory.make, it will call construct.
  {
    GLib.debug("v4lSink construct");
    pad_factory.name_template = "sink";
    pad_factory.direction = PadDirection.SINK;//direction of the pad: can be sink, or src
    pad_factory.presence = PadPresence.ALWAYS;//when pad is available
    pad_factory.static_caps.str = "ANY";//types pad accepts
    add_pad_template(pad_factory.@get());//actual pad registration, this function is inherited from Element class 
    set_details(details);//set details for v4lSinkLoopback(this klass)
 }

  construct
  {
    this.device = GLib.File.new_for_path("new_file");
    this.out_stream = device.replace(null,false,GLib.FileCreateFlags.NONE,null);
  }

  public override Gst.FlowReturn render(Gst.Buffer buf)
  {
    GLib.debug("Data is sinked out!");//data just passes through, we leave a messge
    out_stream.write(buf.data,buf.size,null);//TODO(vasaka) get rid of a warning
    return Gst.FlowReturn.OK;
  }
}
