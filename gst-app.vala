using GLib,Gst,Gtk;

public class VideoSample : Window 
{

  private Pipeline pipeline;//our custom gstreamer pipleine
  private Element src; //source element of pipline 
  private Element xvsink;//sink element of pipeline
  private Element v4lsink;//our v4lsink
  private Element queue;//collect data before sending
  private Element splitter;//split data to see what is happening

  construct 
  {
    GLib.debug("app_construct");
    MyAdvancedTransform.register();
    v4lSinkLoopback.register();
    setup_gst_pipeline ();
    this.pipeline.set_state (State.PLAYING);
  }

  private void setup_gst_pipeline () 
  {
    GLib.debug("app setup_pipeline");
    this.pipeline = (Pipeline) new Pipeline ("mypipeline");//now I am looking at using this all the time and think, maybe it is better than _m suffix
    this.src = ElementFactory.make ("v4l2src", "video");//so for this project will use this. for calling class members
    this.xvsink = ElementFactory.make ("xvimagesink", "sink");
    this.queue = ElementFactory.make ("queue","buffer");
    this.queue.set("min-threshold-bytes",640);
    this.queue.set("max-size-bytes",640*480);
    this.splitter = ElementFactory.make ("tee","splitter");
    this.splitter.set("num-src-pads",2);
    this.v4lsink = ElementFactory.make("v4lSinkLoopback","myv4lsink");
    this.pipeline.add_many (this.src, this.queue,  this.v4lsink);//add elements to pipeline
    this.src.link(this.queue); this.queue.link(this.v4lsink);
    //this.src.link (this.filter);
    //this.filter.link(this.v4lsink);//link everithing
  }

  public static int main (string[] args) 
  {
    Gst.init (ref args);

    var sample = new VideoSample ();

    Gtk.main ();

    return 0;
  }
}

