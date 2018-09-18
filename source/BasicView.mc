using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Timer as Timer;

enum {
  SCREEN_SHAPE_CIRC = 0x000001,
  SCREEN_SHAPE_SEMICIRC = 0x000002,
  SCREEN_SHAPE_RECT = 0x000003
}


class BasicView extends Ui.WatchFace {

    // globals
    var debug = false;
    var is_lowpower = false;

    // time
    var hour = null;
    var minute = null;
    var day = null;
    var day_of_week = null;
    var month_str = null;
    var month = null;
    var utcTime = null;
    var second = null;
    var utcHour = null;
    var utcMinute = null;
    var TIME_A = {};
    var TIME_B = {};

    // layout
    var vert_layout = false;
    var canvas_h = 0;
    var canvas_w = 0;
    var canvas_shape = 0;
    var canvas_rect = false;
    var canvas_circ = false;
    var canvas_semicirc = false;
    var canvas_tall = false;
    var canvas_r240 = false;
    var targetDc = null;
    var dw = null;
    var dh = null;
    var dw_half = null;
    var dh_half = null;

    // tz settings
    var set_timezone_p = null;
    var set_timezone_1 = null;
    var set_timezone_2 = null;


    function initialize() {
     Ui.WatchFace.initialize();
    }


    function onLayout(dc) {

      // w,h of canvas
      canvas_w = dc.getWidth();
      canvas_h = dc.getHeight();

      // check the orientation
      if ( canvas_h > (canvas_w*1.2) ) {
        vert_layout = true;
      } else {
        vert_layout = false;
      }

      // let's grab the canvas shape
      var deviceSettings = Sys.getDeviceSettings();
      canvas_shape = deviceSettings.screenShape;

      if (debug) {
        Sys.println(Lang.format("canvas_shape: $1$", [canvas_shape]));
      }

      // find out the type of screen on the device
      canvas_tall = (vert_layout && canvas_shape == SCREEN_SHAPE_RECT) ? true : false;
      canvas_rect = (canvas_shape == SCREEN_SHAPE_RECT && !vert_layout) ? true : false;
      canvas_circ = (canvas_shape == SCREEN_SHAPE_CIRC) ? true : false;
      canvas_semicirc = (canvas_shape == SCREEN_SHAPE_SEMICIRC) ? true : false;
      canvas_r240 =  (canvas_w == 240 && canvas_w == 240) ? true : false;


      // set a few constants
      // --------------------------
      // w,h of canvas
      dw = canvas_w;
      dh = canvas_h;

      // centerpoint is the middle of the canvas
      dw_half = canvas_w/2;
      dh_half = canvas_h/2;

    }


    function onShow() {
    }


    //! Update the view
    // --------------------------
    function onUpdate(dc) {

      // set the timezone globals
      set_timezone_p = TZ_LOCAL;
      set_timezone_1 = TZ_ASIA_TOKYO;
      set_timezone_2 = TZ_AMERICA_NEW_YORK;

      // fetch the timezone objects
      TIME_A = TzData.getTimeFromTZ(set_timezone_1);
      TIME_B = TzData.getTimeFromTZ(set_timezone_2);

      // grab time objects
      var clockTime = Sys.getClockTime();
      var date = Time.Gregorian.info(Time.now(),0);
      utcTime = Time.Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);

      // define time, day, utc time variables
      hour = clockTime.hour;
      minute = clockTime.min;
      utcHour = utcTime.hour;
      utcMinute = utcTime.min;

      // clear the screen
      dc.setColor(0x000000, 0x000000);
      dc.clear();

      // lets draw the time
      drawTime(dc);


    }


    // helper class to pad zeros
    // --------------------
    function setLeadingZero(lead) {

        if( lead < 10 ) {
          return "0" + lead.toString();
        } else {
          return lead.toString();
        }

    }


    // here's the onPartialUpdate() code for 1hz
    // --------------------
    function onPartialUpdate(dc) {

    }


    // drawTime()
    // --------------------
    function drawTime(targetDc) {


      // colours for each TZ offset
      var COL_MAIN = 0xffffff;
      var COL_TZ_A = 0xff0000;
      var COL_TZ_B = 0x00ff00;

      // fetch the timezone for the Main time
      var hourP = set_timezone_p == 99 ? hour : utcHour;
      var minP = set_timezone_p == 99 ? minute : utcMinute;

      // fetch the first TZ
      var hourA = TIME_A.get("time").hour;
      var minA  = TIME_A.get("time").min;
      var zoneA = TIME_A.get("abbr");

      // fetch the second TZ
      var hourB = TIME_B.get("time").hour;
      var minB  = TIME_B.get("time").min;
      var zoneB = TIME_B.get("abbr");

      var font_mid_height = targetDc.getFontHeight(Gfx.FONT_SYSTEM_NUMBER_HOT);
      var font_sml_height = targetDc.getFontHeight(Gfx.FONT_SYSTEM_NUMBER_MILD);
      var font_tny_height = targetDc.getFontHeight(Gfx.FONT_SYSTEM_XTINY);
      var padding = 10;

      // Main time
      targetDc.setColor(COL_MAIN,Gfx.COLOR_TRANSPARENT);
      targetDc.drawText(dw/2,dh_half-(font_mid_height/2),Gfx.FONT_SYSTEM_NUMBER_HOT,setLeadingZero(hourP)+":"+setLeadingZero(minP),Gfx.TEXT_JUSTIFY_CENTER);

      // first TZ - top field
      targetDc.setColor(COL_TZ_A,Gfx.COLOR_TRANSPARENT);
      targetDc.drawText(dw/2,dh_half-(font_mid_height/2)-font_sml_height-padding,Gfx.FONT_SYSTEM_NUMBER_MILD,setLeadingZero(hourA)+":"+setLeadingZero(minA),Gfx.TEXT_JUSTIFY_CENTER);
      targetDc.drawText(dw/2,dh_half-(font_mid_height/2)-font_sml_height-font_tny_height-padding,Gfx.FONT_SYSTEM_XTINY,zoneA,Gfx.TEXT_JUSTIFY_CENTER);

      // second TZ - bottom field
      targetDc.setColor(COL_TZ_B,Gfx.COLOR_TRANSPARENT);
      targetDc.drawText(dw/2,dh_half+(font_mid_height/2)+padding,Gfx.FONT_SYSTEM_NUMBER_MILD,setLeadingZero(hourB)+":"+setLeadingZero(minB),Gfx.TEXT_JUSTIFY_CENTER);
      targetDc.drawText(dw/2,dh_half+(font_mid_height/2)+font_sml_height+padding,Gfx.FONT_SYSTEM_XTINY,zoneB,Gfx.TEXT_JUSTIFY_CENTER);

    }


    function onHide() {
    }

    function onExitSleep() {
      is_lowpower = false;
    }

    function onEnterSleep() {
      is_lowpower = true;
    }


}
