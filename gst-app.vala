using GLib,Gst;

public class VideoSinkTest : GLib.Object
{

  private Pipeline pipeline;//our custom gstreamer pipleine
  private Gst.XML stored_pipeline; //we load pipeline from external xml file

  private MainLoop loop = new MainLoop(null, false);

  //registers v4lsink plugin and starts gstreamer pipeline
  construct
  {
    GLib.debug("app_construct");
    v4lSinkLoopback.register();
    this.setup_gst_pipeline ();
    this.pipeline.set_state (State.PLAYING);
    GLib.debug("app_constructed");
  }
  // initializing pipeline from xml file
  private void setup_gst_pipeline ()
  {
    GLib.debug("app setup_pipeline");
    this.stored_pipeline = new Gst.XML();
    bool ret = this.stored_pipeline.parse_file("xmlPipe.gst", null);
    assert(ret);
    this.pipeline = (Pipeline)this.stored_pipeline.get_element ("mypipeline");
    assert(this.pipeline != null);
  }

  public int run(string[] args) {
    loop.run();
    return 0;
  }


  public static int main (string[] args)
  {
    Gst.init(ref args);
    var app = new VideoSinkTest();
    return app.run(args);
  }
}

