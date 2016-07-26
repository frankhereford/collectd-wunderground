package Collectd::Plugins::Weather;

use strict;
no strict "subs";
use Data::Dumper;
use Redis;

use Collectd qw(:all);

my $redis = Redis->new;

my $host = `hostname -f`;
chomp $host;

sub pressure
  {
  my $zip_code = $redis->get('wunderground-zips'); #harhar
  my @zips = split('/', $zip_code); 
  foreach my $zip (@zips)
    {
    my $city = $redis->get($zip . '-wunderground');
    my $pressure = $redis->get($zip . '-pressure');

    my $data =
      {
      plugin => 'Weather',
      type => 'pressure',
      type_instance => $city,
      time => time,
      interval => plugin_get_interval(),
      host => $host,
      values => [ $pressure ],
      };

    #Collectd::plugin_log(Collectd::LOG_WARNING, Dumper $data);
    plugin_dispatch_values ($data);
    }
  return 1;
  }


sub tempurature
  {
  my $zip_code = $redis->get('wunderground-zips'); #harhar
  my @zips = split('/', $zip_code); 
  foreach my $zip (@zips)
    {
    my $city = $redis->get($zip . '-wunderground');
    my $temp = $redis->get($zip . '-temp');

    my $data =
      {
      plugin => 'Weather',
      type => 'tempurature',
      type_instance => $city,
      time => time,
      interval => plugin_get_interval(),
      host => $host,
      values => [ $temp],
      };

    #Collectd::plugin_log(Collectd::LOG_WARNING, Dumper $data);
    plugin_dispatch_values ($data);
    }
  return 1;
  }

sub humidity
  {
  my $zip_code = $redis->get('wunderground-zips'); #harhar
  my @zips = split('/', $zip_code); 
  foreach my $zip (@zips)
    {
    my $city = $redis->get($zip . '-wunderground');
    my $temp = $redis->get($zip . '-humidity');

    my $data =
      {
      plugin => 'Weather',
      type => 'humidity',
      type_instance => $city,
      time => time,
      interval => plugin_get_interval(),
      host => $host,
      values => [ $temp],
      };

    #Collectd::plugin_log(Collectd::LOG_WARNING, Dumper $data);
    plugin_dispatch_values ($data);
    }
  return 1;
  }


sub read
  {
  tempurature();
  pressure();
  humidity();
  return 1;
  }

Collectd::plugin_register(Collectd::TYPE_READ, "Weather", "read");
1;
