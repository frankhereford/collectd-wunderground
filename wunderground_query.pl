#!/usr/bin/perl

use strict;
use lib '.';
use WunderGroundAPIKey qw(key);
use JSON;
use LWP;
use Data::Dumper;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
$ua->agent("https://github.com/frankhereford/wunderground-collectd");

my $zip = 78705;


my $req = HTTP::Request->new(GET => 'http://api.wunderground.com/api/' . key() . '/conditions/q/' . $zip . '.json');

my $response = $ua->request($req);

my $conditions = {};
if ($response->is_success) 
  {
  $conditions = decode_json($response->content);
  }

print Dumper $conditions, "\n";
