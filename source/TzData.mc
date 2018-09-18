using Toybox.Time;
using Toybox.WatchUi as Ui;

enum {
  TZ_LOCAL = 99,
  TZ_UTC = 20,
  TZ_AFRICA_JOHANNESBURG = 0,
  TZ_AMERICA_ANCHORAGE = 1,
  TZ_AMERICA_LOS_ANGELES = 2,
  TZ_AMERICA_CHICAGO = 3,
  TZ_AMERICA_DENVER = 4,
  TZ_AMERICA_MEXICO_CITY = 5,
  TZ_AMERICA_SANTIAGO = 6,
  TZ_AMERICA_TORONTO = 7,
  TZ_AMERICA_NEW_YORK = 8,
  TZ_AMERICA_VANCOUVER = 9,
  TZ_ASIA_DUBAI = 10,
  TZ_ASIA_ISTANBUL = 11,
  TZ_ASIA_SEOUL = 12,
  TZ_ASIA_SHANGHAI = 13,
  TZ_ASIA_TOKYO = 14,
  TZ_ASIA_SINGAPORE = 15,
  TZ_ASIA_MANILA = 16,
  TZ_ATLANTIC_AZORES = 17,
  TZ_AUSTRALIA_PERTH = 18,
  TZ_AUSTRALIA_SYDNEY = 19,
  TZ_EUROPE_ATHENS = 21,
  TZ_EUROPE_BERLIN = 22,
  TZ_EUROPE_HELSINKI = 23,
  TZ_EUROPE_LONDON = 24,
  TZ_EUROPE_MOSCOW = 25,
  TZ_EUROPE_PARIS = 26,
  TZ_EUROPE_PRAGUE = 27,
  TZ_EUROPE_ROME = 28,
  TZ_EUROPE_STOCKHOLM = 29,
  TZ_PACIFIC_AUCKLAND = 30,
  TZ_PACIFIC_HONOLULU = 31
}


class TzData {

    function getTimeFromTZ(tz){

        // load the tz resource
        var tz_data = Ui.loadResource(Rez.JsonData.tz_data);

        var thisOffset = 0;
        var thisDate = 0;
        var hasTime = false;
        var today = Time.now().value();

        var abbr = tz_data[tz].get("abbr");

        for (var z=tz_data[tz].get("untils").size()-1;z>=0;z--) {

          if (today>tz_data[tz].get("untils")[z] && !hasTime) {
            hasTime = true;
            thisOffset = tz_data[tz].get("offsets")[z+1]*60;
            thisDate = new Time.Moment(today-thisOffset);
          }

        }

        if (hasTime == false) {
          thisOffset = tz_data[tz].get("offsets")[tz_data[tz].get("offsets").size()-1]*60;
          thisDate = new Time.Moment(today-thisOffset);
        }

        // unload the tz resource
        tz_data = null;

        var offset = {
          "abbr"=>abbr,
          "time"=>Time.Gregorian.utcInfo(thisDate, Time.FORMAT_MEDIUM)
        };

        return offset;

    }


}
