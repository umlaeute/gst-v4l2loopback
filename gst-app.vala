using GLib,Gst;

public class VideoSinkTest : GLib.Object 
{

  private Pipeline pipeline;//our custom gstreamer pipleine
  private Element src; //source element of pipline 
  private Element v4lsink;//our v4lsink
  private Element queue;//collect data before sending
  private MainLoop loop = new MainLoop(null, false);

  construct 
  {
    GLib.debug("app_construct");
    v4lSinkLoopback.register();
    setup_gst_pipeline ();
    this.pipeline.set_state (State.PLAYING);
  }

  private void setup_gst_pipeline () 
  {
    GLib.debug("app setup_pipeline");
    this.pipeline = (Pipeline) new Pipeline ("mypipeline");//now I am looking at using this all the time and think, maybe it is better than _m suffix
    this.src = ElementFactory.make ("v4l2src", "video");//so for this project will use this. for calling class members
    this.queue = ElementFactory.make ("queue","buffer");
    this.queue.set("min-threshold-bytes",640);
    this.queue.set("max-size-bytes",640*480);
    this.v4lsink = ElementFactory.make("v4lSinkLoopback","myv4lsink");
    this.pipeline.add_many (this.src,  this.v4lsink);//add elements to pipeline
    this.src.link(this.v4lsink);
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

