using GLib,Gst,Gtk;

public class VideoSample : Window {

    private DrawingArea drawing_area;//outosink writes here?
    private Pipeline pipeline;//our custom gstreamer pipleine
    private Element src; //source element of pipline 
    private Element sink;//sink element of pipeline
    private Element filter;//our test element which just checks it can see data

    construct {
        MyAdvancedTransform.register();
        create_widgets ();
        setup_gst_pipeline ();
    }

    private void create_widgets () {
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

    private void setup_gst_pipeline () {
        this.pipeline = (Pipeline) new Pipeline ("mypipeline");//now I am looking at it and think, maybe it is better than _m suffix
        this.src = ElementFactory.make ("videotestsrc", "video");//so for this project will use this. for calling class members
        this.sink = ElementFactory.make ("xvimagesink", "sink");
        this.filter = ElementFactory.make("MyAdvancedTransform", "mymegafilter");
        this.pipeline.add_many (this.src, this.filter, this.sink);
        this.src.link (this.filter);this.filter.link(this.sink);
    }

    private void on_play () {
        ((XOverlay) this.sink).set_xwindow_id (
                Gdk.x11_drawable_get_xid (this.drawing_area.window));
        this.pipeline.set_state (State.PLAYING);
    }

    private void on_stop () {
        this.pipeline.set_state (State.READY);
    }

    public static int main (string[] args) {
        Gst.init (ref args);
        Gtk.init (ref args);

        var sample = new VideoSample ();
        sample.show_all ();

        Gtk.main ();

        return 0;
}
    }
}
