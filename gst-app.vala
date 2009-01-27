using GLib,Gst,Gtk;

public class VideoSample : Window 
{

  private DrawingArea drawing_area;//outosink writes here?
  private Pipeline pipeline;//our custom gstreamer pipleine
  private Element src; //source element of pipline 
  private Element sink;//sink element of pipeline
  private Element v4lsink;//our v4lsink
  private Element filter;//our test element which just checks it can see data

  construct 
  {
    GLib.debug("app_construct");
    MyAdvancedTransform.register();
    v4lSinkLoopback.register();
    create_widgets ();
    setup_gst_pipeline ();
  }

  private void create_widgets () 
  {
    var vbox = new VBox (false, 0);
    drawing_area = new DrawingArea ();
    drawing_area.set_size_request (300, 150);
    vbox.pack_start (this.drawing_area, true, true, 0);

    var play_button = new Button.from_stock (STOCK_MEDIA_PLAY);
    play_button.clicked += on_play;
    var stop_button = new Button.from_stock (STOCK_MEDIA_STOP);
    stop_button.clicked += on_stop;
    var quit_button = new Button.from_stock (STOCK_QUIT);
    quit_button.clicked += Gtk.main_quit;

    var bb = new HButtonBox ();
    bb.add (play_button);
    bb.add (stop_button);
    bb.add (quit_button);
    vbox.pack_start (bb, false, true, 0);

    add (vbox);
  }

  private void setup_gst_pipeline () 
  {
    GLib.debug("app setup_pipeline");
    this.pipeline = (Pipeline) new Pipeline ("mypipeline");//now I am looking at using this all the time and think, maybe it is better than _m suffix
    this.src = ElementFactory.make ("videotestsrc", "video");//so for this project will use this. for calling class members
    this.sink = ElementFactory.make ("xvimagesink", "sink");
    this.filter = ElementFactory.make("MyAdvancedTransform", "mymegafilter");
    this.v4lsink = ElementFactory.make("v4lSinkLoopback","myv4lsink");
    this.pipeline.add_many (this.src, this.filter, /*this.sink,*/this.v4lsink);//add elements to pipeline
    this.src.link (this.filter);this.filter.link(this.v4lsink);//link everithing
  }

  private void on_play () 
  {
    ((XOverlay) this.sink).set_xwindow_id (
      Gdk.x11_drawable_get_xid (this.drawing_area.window));
    this.pipeline.set_state (State.PLAYING);
  }

  private void on_stop () 
  {
    this.pipeline.set_state (State.READY);
  }

  public static int main (string[] args) 
  {
    Gst.init (ref args);
    Gtk.init (ref args);

    var sample = new VideoSample ();
    sample.show_all ();

    Gtk.main ();

    return 0;
  }
}

