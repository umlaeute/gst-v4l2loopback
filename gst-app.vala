using GLib,Gst;

public class VideoSinkTest : GLib.Object 
{

  private Pipeline pipeline;//our custom gstreamer pipleine
  private Element src; //source element of pipline 
  private Element v4lsink;//our v4lsink
  private Element effect;
  private Element colorspace;
  private Bin decoder;
  private MainLoop loop = new MainLoop(null, false);

  construct 
  {
    GLib.debug("app_construct");
    v4lSinkLoopback.register();
    setup_gst_pipeline ();
    this.pipeline.set_state (State.PLAYING);
    GLib.debug("app_constructed");
  }

  /** called by decodebin when a new pad is created */
  private void on_new_pad(Pad pad)
  {
    GLib.debug("on new pad");
    this.decoder.link(this.v4lsink);
  }

  private void setup_gst_pipeline () 
  {
    GLib.debug("app setup_pipeline");
    this.pipeline = (Pipeline) new Pipeline ("mypipeline");//now I am looking at using this all the time and think, maybe it is better than _m suffix
    this.src = ElementFactory.make ("v4l2src", "video");//so for this project will use this. for calling class members
    this.src.set("blocksize",640*480*3);
    this.v4lsink = ElementFactory.make("v4lSinkLoopback","myv4lsink");
    this.decoder = (Bin)ElementFactory.make("decodebin", "decoder");
    this.colorspace = ElementFactory.make("ffmpegcolorspace", "colorspace");
    this.effect = ElementFactory.make("edgetv","effect");
    Signal.connect_swapped(decoder, "new-decoded-pad", (Callback)on_new_pad, this);
    this.pipeline.add_many (this.src, this.colorspace, this.v4lsink);//add elements to pipeline
    this.src.link(this.colorspace); this.colorspace.link(this.v4lsink);;
    //this.src.link (this.filter);
    //this.filter.link(this.v4lsink);//link everithing
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

