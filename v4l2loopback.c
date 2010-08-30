/*
 * GStreamer
 * Copyright (C) 2005 Thomas Vander Stichele <thomas@apestaart.org>
 * Copyright (C) 2005 Ronald S. Bultje <rbultje@ronald.bitfreak.net>
 * Copyright (C) 2008-2009 Gorinich Zmey
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

#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>

#define DEFAULT_PROP_DEVICE_NAME 	NULL
#define DEFAULT_PROP_DEVICE   "/dev/video1"
#define DEFAULT_PROP_DEVICE_FD -1

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
    PROP_DEVICE,
    PROP_DEVICE_FD,
    PROP_DEVICE_NAME
  };

/* the capabilities of the inputs and outputs.
 *
 * describe the real formats here.
 */
static GstStaticPadTemplate sink_factory = GST_STATIC_PAD_TEMPLATE ("sink",
								    GST_PAD_SINK,
								    GST_PAD_ALWAYS,
								    GST_STATIC_CAPS ("video/x-raw-yuv, width=[48, 32768], height=[32, 32768], format=(fourcc)YUY2")
								    );

GST_BOILERPLATE (GstV4L2Loopback, gst_v4l2_loopback, GstVideoSink,
		 GST_TYPE_VIDEO_SINK);

//GST_BOILERPLATE_FULL (GstV4L2Loopback, gst_v4l2_loopback, GstVideoSink, GST_TYPE_VIDEO_SINK, gst_v4l2sink_init_interfaces);

static void gst_v4l2_loopback_set_property (GObject * object, guint prop_id,
					    const GValue * value, GParamSpec * pspec);
static void gst_v4l2_loopback_get_property (GObject * object, guint prop_id,
					    GValue * value, GParamSpec * pspec);
static void gst_v4l2_loopback_dispose (GObject * object);


/* GObject vmethod implementations */
gboolean
gst_v4l2loopback_stop (GstV4L2Loopback * v4l2loop)
{
  if(v4l2loop->video_fd<0) {
    /*
    GST_ELEMENT_ERROR (v4l2loop->element, RESOURCE, SETTINGS,
		       (_("Device is not open.")), (NULL));
    */
    return FALSE;
  }
  close(v4l2loop->video_fd);
  v4l2loop->video_fd=-1;

  return TRUE;
}

gboolean
gst_v4l2loopback_set_format (GstV4L2Loopback * v4l2loop, guint32 width, guint32 height)
{
  int ret=0;

  GST_DEBUG ("trying to set '%s' to %dx%d", v4l2loop->videodev, width, height);

 /* check whether it's an output device */
  v4l2loop->vformat.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;
  v4l2loop->vformat.fmt.pix.width = width;
  v4l2loop->vformat.fmt.pix.height = height;
  v4l2loop->vformat.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
  v4l2loop->vformat.fmt.pix.sizeimage = width*height*2;
  v4l2loop->vformat.fmt.pix.field = V4L2_FIELD_NONE;
  v4l2loop->vformat.fmt.pix.bytesperline = width*2;
  v4l2loop->vformat.fmt.pix.colorspace = V4L2_COLORSPACE_SRGB;
  ret = ioctl(v4l2loop->video_fd, VIDIOC_S_FMT, &v4l2loop->vformat);
  if(-1 == ret) {
    GST_DEBUG ("couldn't set format of '%s'", v4l2loop->videodev);
    return FALSE;
  }

  v4l2loop->width =  v4l2loop->vformat.fmt.pix.width;
  v4l2loop->height=  v4l2loop->vformat.fmt.pix.height;

  if((v4l2loop->vformat.fmt.pix.width == width) && (v4l2loop->vformat.fmt.pix.height == height)) {
  } else {
    GST_DEBUG ("couldn't set format of '%s' to %dx%d (got %dx%d)", 
               v4l2loop->videodev, 
               width, height,
               v4l2loop->vformat.fmt.pix.width,
               v4l2loop->vformat.fmt.pix.height);

    return FALSE;
  }

  return TRUE;
}


gboolean
gst_v4l2loopback_start (GstV4L2Loopback * v4l2loop)
{
  struct stat st;
  int ret=0;

  if(v4l2loop->video_fd>=0) {
    /* already open */
    return FALSE;
  }

  /* be sure we have a device */
  if (!v4l2loop->videodev)
    v4l2loop->videodev = g_strdup ("/dev/video");

  /* check if it is a device */
  if (stat (v4l2loop->videodev, &st) == -1) {
    GST_DEBUG ("Failed to stat '%s'", v4l2loop->videodev);
    return FALSE;
  }

  if (!S_ISCHR (st.st_mode)) {
    GST_DEBUG ("'%s' is no device", v4l2loop->videodev);
    return FALSE;
  }

  /* open the device */
  v4l2loop->video_fd = open (v4l2loop->videodev, O_RDWR /* | O_NONBLOCK */ );

  if(v4l2loop->video_fd < 0) {
    GST_DEBUG ("Failed to open '%s'", v4l2loop->videodev);
    return FALSE;
  }

  /* check whether it's a video device */
  ret = ioctl(v4l2loop->video_fd, VIDIOC_QUERYCAP, &v4l2loop->vcap);
  if(-1 == ret) {
    GST_DEBUG ("couldn't query caps of '%s'", v4l2loop->videodev);
    goto close_it;
  }
  if( !(v4l2loop->vcap.capabilities & V4L2_CAP_VIDEO_OUTPUT) ) {
    GST_DEBUG("device '%s' is not a video4linux2 output device", v4l2loop->videodev);
    goto close_it;
  }

  //  if(!gst_v4l2loopback_set_format (v4l2loop, v4l2loop->width, v4l2loop->height))
  //    goto close_it;

  return TRUE;

 close_it:
  gst_v4l2loopback_stop ( v4l2loop);

  return FALSE;
}

static GstStateChangeReturn
gst_v4l2loopback_change_state (GstElement * element, GstStateChange transition)
{
  GstStateChangeReturn ret = GST_STATE_CHANGE_SUCCESS;
  GstV4L2Loopback *v4l2loopback = GST_V4L2_LOOPBACK (element);

  GST_DEBUG_OBJECT (v4l2loopback, "%d -> %d",
      GST_STATE_TRANSITION_CURRENT (transition),
      GST_STATE_TRANSITION_NEXT (transition));

  switch (transition) {
    case GST_STATE_CHANGE_NULL_TO_READY:
      /* open the device */
      if (!gst_v4l2loopback_start (v4l2loopback))
        return GST_STATE_CHANGE_FAILURE;
      break;
    default:
      break;
  }

  ret = GST_ELEMENT_CLASS (parent_class)->change_state (element, transition);

  switch (transition) {
    case GST_STATE_CHANGE_READY_TO_NULL:
      /* close the device */
      if (!gst_v4l2loopback_stop (v4l2loopback))
        return GST_STATE_CHANGE_FAILURE;
      break;
    default:
      break;
  }

  return ret;
}

/* called after A/V sync to render frame */
static GstFlowReturn
gst_v4l2loopback_show_frame (GstBaseSink * bsink, GstBuffer * buf)
{
  GstV4L2Loopback *v4l2loopback = GST_V4L2_LOOPBACK (bsink);
  ssize_t ret=0;

  if(v4l2loopback->video_fd < 0) {
    return GST_FLOW_ERROR;
  }

  GST_DEBUG_OBJECT (v4l2loopback, "render buffer: %p", buf);

  ret=write(v4l2loopback->video_fd, buf->data, buf->size);

  GST_DEBUG_OBJECT (v4l2loopback, "wrote %d bytes to %d", ret, v4l2loopback->video_fd);

  return GST_FLOW_OK;
}



static gboolean
gst_v4l2_loopback_set_caps (GstBaseSink * bsink, GstCaps * caps)
{
  GstV4L2Loopback *loop = GST_V4L2_LOOPBACK (bsink);
  GstStructure *s;

  if(loop->video_fd < 0) {
    /* not opened yet! */
    return FALSE;
  }


  if (loop->current_caps) {
    GST_DEBUG_OBJECT (loop, "already have caps set.. are they equal?");
    if (gst_caps_is_equal (loop->current_caps, caps)) {
      GST_DEBUG_OBJECT (loop, "yes they are!");
      return TRUE;
    }
    GST_DEBUG_OBJECT (loop, "no they aren't!");
    gst_caps_unref (loop->current_caps);
  }

  int w=loop->width;
  int h=loop->height;

  /* negotiation succeeded, so now configure ourselves */
  s = gst_caps_get_structure (caps, 0);

  if(!gst_structure_get_int (s, "width", &w))return FALSE;
  if(!gst_structure_get_int (s, "height", &h))return FALSE;

  if(!gst_v4l2loopback_set_format(loop, w, h))
    return FALSE;

  loop->current_caps = gst_caps_ref (caps);

  return TRUE;
}



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
  GstElementClass *element_class;
  GstBaseSinkClass *basesink_class;

  gobject_class =  G_OBJECT_CLASS      (klass);
  element_class =  GST_ELEMENT_CLASS   (klass);
  basesink_class = GST_BASE_SINK_CLASS (klass);

  gobject_class->dispose = gst_v4l2_loopback_dispose;
  gobject_class->set_property = gst_v4l2_loopback_set_property;
  gobject_class->get_property = gst_v4l2_loopback_get_property;

  element_class->change_state = gst_v4l2loopback_change_state;

  g_object_class_install_property (gobject_class, PROP_DEVICE,
				   g_param_spec_string ("device", "Device", "Device location",
							DEFAULT_PROP_DEVICE,
							G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS));

  g_object_class_install_property (gobject_class, PROP_DEVICE_FD,
				   g_param_spec_int ("device-fd", "File descriptor",
						     "File descriptor of the device", -1, G_MAXINT, DEFAULT_PROP_DEVICE_FD,
						     G_PARAM_READABLE | G_PARAM_STATIC_STRINGS));

  g_object_class_install_property (gobject_class, PROP_DEVICE_NAME,
				   g_param_spec_string ("device-name", "Device name",
							"Name of the device", DEFAULT_PROP_DEVICE_NAME,
							G_PARAM_READABLE | G_PARAM_STATIC_STRINGS));

  basesink_class->preroll = GST_DEBUG_FUNCPTR (gst_v4l2loopback_show_frame);
  basesink_class->render = GST_DEBUG_FUNCPTR (gst_v4l2loopback_show_frame);

  basesink_class->set_caps = GST_DEBUG_FUNCPTR(gst_v4l2_loopback_set_caps);
  
}



static void
gst_v4l2_loopback_dispose (GObject * object)
{
  GstV4L2Loopback *loop = GST_V4L2_LOOPBACK (object);

  if (loop->current_caps) {
    gst_caps_unref (loop->current_caps);
  }

  G_OBJECT_CLASS (parent_class)->dispose (object);
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
  loop->video_fd = -1;

  loop->width = 0;
  loop->height = 0;

  loop->current_caps = NULL;
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
  case PROP_DEVICE_NAME:
    {
      const guchar *new = NULL;
      if(loop->video_fd>=0){
        new = loop->vcap.card;
      } else if (gst_v4l2loopback_start(loop)) {
	/* FIXXME: split start into open() and configure() */
        new = loop->vcap.card;
	gst_v4l2loopback_stop(loop);
      }
      g_value_set_string (value, (gchar *) new);
      break;
    }
  case PROP_DEVICE_FD:
    {
      if(loop->video_fd>=0)
        g_value_set_int (value, loop->video_fd);
      else
        g_value_set_int (value, DEFAULT_PROP_DEVICE_FD);
      break;
    }
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
