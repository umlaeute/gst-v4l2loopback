using Gst, GLib;

// compile with:
// valac --pkg gstreamer-0.10 --pkg gstreamer-video-0.10 gst-app.vala

/** 
Class that inherits from Basetransform. It should be easier to implement than
subclassing Element, but still doesn't work.
*/
class MyAdvancedTransform : VideoFilter
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
        "alberto <albx79@gmail.com>"
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
        GLib.debug("Data is flowing!");// throw all data, or just keep unchanged? check it
        return Gst.FlowReturn.OK;
    }
}


/*

I have removed the following bits of code to minimise clutter.
They may be reintroduced in the appropriate sections later, if at all.

    // from bus callback
            case MessageType.TAG:
            {
		        TagList taglist;
		        message.parse_tag(out taglist);
		        // generates a warning in the C sources		        
		        taglist.foreach( (list, tag) => {
	                string val, niceval;
	                if (list.get_string(tag, out val))
	                    niceval = " = \""+val+"\"";
                    else
                        niceval = "";
		            stdout.printf(": %s%s", tag, niceval);
	            });      
	            break;      
            }
            case MessageType.ELEMENT:
            {
                Structure s = message.get_structure();
                // generates a warning in the C sources
                s.foreach( (field_id, val) => {
                    stdout.printf("\tfield %s\n", field_id.to_string());
                    return true;
                });                
                break;
            }
            case MessageType.STATE_CHANGED:
            {
                State oldstate, newstate, pending;
		        message.parse_state_changed(out oldstate, out newstate, out pending);
                stdout.printf(": %d -> %d (%d)", (int)oldstate, (int)newstate, (int)pending);
                break;
            }
    


    // MUST be static, otherwise valac will silently omit them in the C sources... 
    static string? vfs_location;
    static string? rtsp_location;
    static string? file_location;
    const OptionEntry[] entries = {
            {"vfs", 'v', 0, OptionArg.STRING, out vfs_location, 
            "play video from URI", "URI"},
            {"rtsp", 'r', 0, OptionArg.STRING, out rtsp_location,
            "play RTSP stream", "RTSP"},
            {"file", 'f', 0, OptionArg.FILENAME, out file_location,
            "play video from FILE", "FILE"},
            {null}
        };


        OptionContext ctx = new OptionContext(" -- play video from file or RTSP");
        OptionGroup gstgroup = Gst.init_get_option_group();
        ctx.add_main_entries(entries, null);
        ctx.add_group(#gstgroup);
        Element source;
        try
        {
            GLib.Object src;
            ctx.parse(ref args);
            if (rtsp_location != null)
            {
                src = ElementFactory.make("rtspsrc", "source");
                src.set("location", rtsp_location);
            }
            else if (vfs_location != null)
            {
                src = ElementFactory.make("gnomevfssrc", "source");
                src.set("location", vfs_location);
            }
            else if (file_location != null)
            {
                src = ElementFactory.make("filesrc", "source");
                src.set("location", file_location);
            }
            else
            {
                stdout.printf("%s", ctx.get_help(true, null));
                throw new OptionError.FAILED("please specify a file/uri to play");
            }
            assert(src != null);
            source = (Element)src;
        }
        catch (OptionError e)
        {
            stdout.printf("Error: %s\n\n", e.message);
            return 1;
        }
*/
