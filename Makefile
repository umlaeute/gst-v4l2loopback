BINDIR=/usr/local/bin
BUILD_OPTIONS=--vapidir=. --pkg posix --pkg v4l2 --pkg gstreamer-0.10 --pkg gtk+-2.0 --pkg gdk-x11-2.0 --pkg gstreamer-interfaces-0.10 --pkg gstreamer-video-0.10
SOURCE_FILES=gst-app.vala gst-v4lsink-loopback.vala
OUT_FILE=--output=gst-app

all:
	valac $(OUT_FILE) $(BUILD_OPTIONS) $(SOURCE_FILES)

install:all gst-app
	cp gst-app /usr/local/bin