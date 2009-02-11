using GLib,Gst;

public class VideoSinkTest : GLib.Object
{

  private Pipeline pipeline;//our custom gstreamer pipleine
  public string pipeline_string {get; construct;}//create pipeline from string description
  private MainLoop loop = new MainLoop(null, false);

  public VideoSinkTest(string param)
  {
    this.pipeline_string = param;
  }
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
    pipeline = (Pipeline)Gst.parse_launch(pipeline_string);
    assert(this.pipeline != null);
  }

  public int run(string[] args) {
    loop.run();
    return 0;
  }


  public static int main (string[] args)
  {
    Gst.init(ref args);
    string param;
    if (args.length>1)
      param = args[1];
    else
      param = "v4l2src device=/dev/video0 ! ffmpegcolorspace ! v4lSinkLoopback";
    var app = new VideoSinkTest(param);
    return app.run(args);
  }
}

