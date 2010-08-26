# Note: plugindir is set in configure

plugin_LTLIBRARIES = libv4l2loopback.la

# sources used to compile this plug-in
libv4l2loopback_la_SOURCES = v4l2loopback.c v4l2loopback.h

# compiler and linker flags used to compile this plugin, set in configure.ac
libv4l2loopback_la_CFLAGS = $(GST_CFLAGS)
libv4l2loopback_la_LIBADD = $(GST_LIBS)
libv4l2loopback_la_LDFLAGS = $(GST_PLUGIN_LDFLAGS)
libv4l2loopback_la_LIBTOOLFLAGS = --tag=disable-static

# headers we need but don't want installed
noinst_HEADERS = v4l2loopback.h
