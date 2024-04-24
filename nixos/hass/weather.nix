{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.home-assistant.config = {
    weather = [
      {
        platform = "darksky";
        name = "Hangzhou";
        mode = "daily";
        api_key = "!secret darksky_api_key";
        latitude = "!secret alt_latitude";
        longitude = "!secret alt_longitude";
      }
    ];
    sensor = [
      {
        platform = "darksky";
        latitude = "!secret alt_latitude";
        longitude = "!secret alt_longitude";
        language = "zh";
        api_key = "!secret darksky_api_key";
        scan_interval = "00:10:00";
        forecast = [ 1 ];
        monitored_conditions = [
          "apparent_temperature"
          "apparent_temperature_high"
          "apparent_temperature_low"
          "daily_summary"
          "hourly_summary"
          "humidity"
          "precip_probability"
          "precip_type"
          "summary"
        ];
      }
    ];
  };
}
