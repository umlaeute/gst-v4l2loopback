using Gst, GLib;

/** 
Class that inherits from VideoFilter. It should be easier to implement than
*/
class MyAdvancedTransform : Gst.VideoFilter
{
  public static bool plugin_init(Plugin p)
  {
    return Element.register(p, "MyAdvancedTransform", Rank.NONE, typeof(MyAdvancedTransform));
  }

  public static void register()
  {
    bool plugin_registered = Plugin.register_static(
        VERSION_MAJOR, VERSION_MINOR, "my-plugin-name", "description of it", plugin_init, "0.1",
        "GPL", "source",  "package name", "http://mywebsite.nil");
    assert(plugin_registered);
  }

  static const ElementDetails details = {
        "MyAdvancedTransform",
        "Example/SecondExample",
        "Try to make a plugin using Vala",
        "prototyping - alberto"
    };
    
    static StaticPadTemplate sink_factory;    
    static StaticPadTemplate src_factory;
    
    class construct
    {
        sink_factory.name_template = "sink";
        sink_factory.direction = PadDirection.SINK;
        sink_factory.presence = PadPresence.ALWAYS;
        sink_factory.static_caps.str = "ANY";
        src_factory.name_template = "src";
        src_factory.direction = PadDirection.SRC;
        src_factory.presence = PadPresence.ALWAYS;
        src_factory.static_caps.str = "ANY";
        add_pad_template(src_factory.@get());
        add_pad_template(sink_factory.@get());        
        set_details(details);
    }
    
    public override Gst.FlowReturn transform_ip(Buffer buf)
    {
        GLib.debug("Data is flowing!");// keep data unchanged
        return Gst.FlowReturn.OK;
    }
}

