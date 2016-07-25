package WunderGroundAPIKeyAndZips;

use strict;

use Exporter qw(import);
our @EXPORT_OK = qw(key);
 
sub key 
  {
  return '1234567890abcdef'; # <= you put your wunderground api key here. don't put it in GitHub. You got this.
  }

sub zips
  {
  return [78705];
  }

1;
