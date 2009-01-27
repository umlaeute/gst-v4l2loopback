using GLib,Gst;

public void main (string[] args) {
    Element src;
    Element sink;
    Pipeline pipeline;

    // Initializing GStreamer
    Gst.init (ref args);

    // Creating pipeline and elements
    // NOTE: The return type of the pipeline construction method is Element,
    // not Pipeline, so we have to cast
    pipeline = (Pipeline) new Pipeline ("test");
    src = ElementFactory.make ("audiotestsrc", "my_src");
    sink = ElementFactory.make ("autoaudiosink", "my_sink");

    // Adding elements to pipeline
    pipeline.add_many (src, sink);

    // Linking source to sink
    src.link (sink);

    // Setting waveform to square
    src.set ("wave", 1);

    // Set pipeline state to PLAYING
    pipeline.set_state (State.PLAYING);

    // Creating a GLib main loop with a default context
    var loop = new MainLoop (null, false);

    // Start GLib mainloop
    loop.run ();
}
