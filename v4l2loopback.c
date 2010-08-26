/*
 * GStreamer
 * Copyright (C) 2005 Thomas Vander Stichele <thomas@apestaart.org>
 * Copyright (C) 2005 Ronald S. Bultje <rbultje@ronald.bitfreak.net>
 * Copyright (C) 2010 IOhannes m zmoelnig <zmoelnig@iem.at>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Alternatively, the contents of this file may be used under the
 * GNU Lesser General Public License Version 2.1 (the "LGPL"), in
 * which case the following provisions apply instead of the ones
 * mentioned above:
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

/**
 * SECTION:element-v4l2loopback
 *
 * pipes video data into a v4l2 loopback device
 *
 * <refsect2>
 * <title>Example launch line</title>
 * |[
 * gst-launch -v -m videotestsrc ! ffmpegcolorspace ! v4l2loopback
 * ]|
 * </refsect2>
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gst/gst.h>
#include <gst/video/gstvideosink.h>
#include "v4l2loopback.h"

#define DEFAULT_PROP_DEVICE   "/dev/video1"


GST_DEBUG_CATEGORY_STATIC (gst_v4l2_loopback_debug);
#define GST_CAT_DEFAULT gst_v4l2_loopback_debug

/* Filter signals and args */
enum
  {
    /* FILL ME */
    LAST_SIGNAL
  };

enum
  {
    PROP_0,
    PROP_DEVICE
  };

/* the capabilities of the inputs and outputs.
 *
 * describe the real formats here.
 */
static GstStaticPadTemplate sink_factory = GST_STATIC_PAD_TEMPLATE ("sink",
								    GST_PAD_SINK,
								    GST_PAD_ALWAYS,
								    GST_STATIC_CAPS ("video/x-raw-yuv, width=640, height=480, format=(fourcc)YUY2")
								    );

GST_BOILERPLATE (GstV4L2Loopback, gst_v4l2_loopback, GstVideoSink,
		 GST_TYPE_VIDEO_SINK);

//GST_BOILERPLATE_FULL (GstV4L2Loopback, gst_v4l2_loopback, GstVideoSink, GST_TYPE_VIDEO_SINK, gst_v4l2sink_init_interfaces);

static void gst_v4l2_loopback_set_property (GObject * object, guint prop_id,
					    const GValue * value, GParamSpec * pspec);
static void gst_v4l2_loopback_get_property (GObject * object, guint prop_id,
					    GValue * value, GParamSpec * pspec);

/* GObject vmethod implementations */

static void
gst_v4l2_loopback_base_init (gpointer gclass)
{
  GstElementClass *element_class = GST_ELEMENT_CLASS (gclass);

  gst_element_class_set_details_simple(element_class,
				       "v4l2loopback",
				       "V4L2 loopback sink",
				       "this allows to send your data to a v4l2 loopback device",
				       "IOhannes m zmoelnig <zmoelnig@iem.at>");

  gst_element_class_add_pad_template (element_class,
				      gst_static_pad_template_get (&sink_factory));
}

/* initialize the plugin's class */
static void
gst_v4l2_loopback_class_init (GstV4L2LoopbackClass * klass)
{
  GObjectClass *gobject_class;
  GstElementClass *gstelement_class;

  gobject_class = (GObjectClass *) klass;
  gstelement_class = (GstElementClass *) klass;

  gobject_class->set_property = gst_v4l2_loopback_set_property;
  gobject_class->get_property = gst_v4l2_loopback_get_property;

  g_object_class_install_property (gobject_class, PROP_DEVICE,
				   g_param_spec_string ("device", "Device", "Device location",
							DEFAULT_PROP_DEVICE,
							G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS));
}

/* initialize the new element
 * instantiate pads and add them to element
 * set pad calback functions
 * initialize instance structure
 */
static void
gst_v4l2_loopback_init (GstV4L2Loopback * loop,
			GstV4L2LoopbackClass * gclass)
{
  g_object_set (loop, "device", "/dev/video1", NULL);
}

static void
gst_v4l2_loopback_set_property (GObject * object, guint prop_id,
				const GValue * value, GParamSpec * pspec)
{
  GstV4L2Loopback *loop = GST_V4L2_LOOPBACK (object);

  switch (prop_id) {
  case PROP_DEVICE:
    g_free (loop->videodev);
    loop->videodev = g_value_dup_string (value);
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
    break;
  }
}

static void
gst_v4l2_loopback_get_property (GObject * object, guint prop_id,
				GValue * value, GParamSpec * pspec)
{
  GstV4L2Loopback *loop = GST_V4L2_LOOPBACK (object);

  switch (prop_id) {
  case PROP_DEVICE:
    g_value_set_string (value, loop->videodev);
    break;
  default:
    G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
    break;
  }
}

/* GstElement vmethod implementations */

/* entry point to initialize the plug-in
 * initialize the plug-in itself
 * register the element factories and other features
 */
static gboolean
plugin_init (GstPlugin * plugin)
{
  /* debug category for fltering log messages
   *
   * exchange the string 'Template plugin' with your description
   */
  GST_DEBUG_CATEGORY_INIT (gst_v4l2_loopback_debug, "v4l2loopback",
			   0, "V4L2 loopack device sink");

  return gst_element_register (plugin, "v4l2loopback", GST_RANK_NONE,
			       GST_TYPE_V4L2_LOOPBACK);
}

/* PACKAGE: this is usually set by autotools depending on some _INIT macro
 * in configure.ac and then written into and defined in config.h, but we can
 * just set it ourselves here in case someone doesn't use autotools to
 * compile this code. GST_PLUGIN_DEFINE needs PACKAGE to be defined.
 */
#ifndef PACKAGE
#define PACKAGE "v4l2loopback"
#endif

/* gstreamer looks for this structure to register plugins
 *
 * exchange the string 'Template plugin' with your plugin description
 */
GST_PLUGIN_DEFINE (
		   GST_VERSION_MAJOR,
		   GST_VERSION_MINOR,
		   "v4l2loopback",
		   "V4L2 loopback device",
		   plugin_init,
		   VERSION,
		   "LGPL",
		   "GStreamer",
		   "http://gstreamer.net/"
		   )
