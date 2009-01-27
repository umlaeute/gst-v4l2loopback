using GLib,Gst,Gtk;

public class VideoSample : Window {

    private DrawingArea drawing_area;
    private Pipeline pipeline;
    private Element src;
    private Element sink;

    construct {
        create_widgets ();
        setup_gst_pipeline ();
    }

    private void create_widgets () {
        var vbox = new VBox (false, 0);
        this.drawing_area = new DrawingArea ();
        this.drawing_area.set_size_request (300, 150);
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
        this.pipeline = (Pipeline) new Pipeline ("mypipeline");
        this.src = ElementFactory.make ("videotestsrc", "video");
        this.sink = ElementFactory.make ("xvimagesink", "sink");
        this.pipeline.add_many (this.src, this.sink);
        this.src.link (this.sink);
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
