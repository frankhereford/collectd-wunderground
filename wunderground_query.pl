#!/usr/bin/perl

use strict;
use lib '.';
use FindBin;
use lib "$FindBin::Bin/.";
use WunderGroundAPIKeyAndZips qw(key zips);
use JSON;
use LWP;
use Data::Dumper;
use LWP::UserAgent;
use Redis;

my $redis = Redis->new;

my $ttl = 60 * 20;

my $ua = LWP::UserAgent->new;
$ua->agent("https://github.com/frankhereford/wunderground-collectd");

my @zips = @{zips()};

$redis->setex('wunderground-zips', $ttl, join('/', @zips));

foreach my $zip (@zips)
  {
  my $req = HTTP::Request->new(GET => 'http://api.wunderground.com/api/' . key() . '/conditions/q/' . $zip . '.json');
  my $response = $ua->request($req);
  my $conditions = {};
  if ($response->is_success) 
    {
    $conditions = decode_json($response->content);
    }

  #print Dumper $conditions, "\n";

  $conditions->{'current_observation'}->{'relative_humidity'} =~ s/\%//g;

  my %data = (
  $zip . '-temp'	=>	$conditions->{'current_observation'}->{'temp_f'},
  $zip . '-heatindex'	=>	($conditions->{'current_observation'}->{'heat_index_f'} =~ /NA/i ? 0 : $conditions->{'current_observation'}->{'heat_index_f'}),
  $zip . '-feelslike'	=>	$conditions->{'current_observation'}->{'feelslike_f'},
  $zip . '-pressure'	=>	$conditions->{'current_observation'}->{'pressure_in'},
  $zip . '-dewpoint'	=>	$conditions->{'current_observation'}->{'dewpoint_f'},
  $zip . '-wind'	=>	$conditions->{'current_observation'}->{'wind_mph'},
  $zip . '-windgust'	=>	$conditions->{'current_observation'}->{'wind_gust_mph'},
  $zip . '-humidity'	=>	$conditions->{'current_observation'}->{'relative_humidity'},
  $zip . '-visibility'	=>	$conditions->{'current_observation'}->{'visibility_mi'},
  $zip . '-windchill'	=>	($conditions->{'current_observation'}->{'windchill_f'} =~ /NA/i ? 0 : $conditions->{'current_observation'}->{'windchill_f'}),
  $zip . '-precip1h'	=>	$conditions->{'current_observation'}->{'precip_1hr_in'} += 0,
  $zip . '-preciptoday'	=>	$conditions->{'current_observation'}->{'precip_today_in'} += 0,
  );

  $redis->setex($zip . '-wunderground', $ttl, $conditions->{'current_observation'}->{'display_location'}->{'city'});

  foreach my $key (keys(%data))
    {
    $redis->setex($key, $ttl, $data{$key});
    }

  #print Dumper \%data, "\n";
  }

