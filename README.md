Soccermetrics Perl API Client
=============================

This is the `Soccermetrics::API::Client` Perl package for accessing
the Soccermetrics REST API.

# Installation

This package was built with Perl 5.18.0, but it should be compatible with
Perl 5+.  It is dependent on the following packages:

* REST::Client
* JSON
* URI::Escape

We recommend using the `Data::Dumper` package if you wish to
pretty-print the API responses.  The `utf8` package is also required to
properly resolve foreign characters.

To install the package, download the current zipped version of the source code
from GitHub, unzip the file and run the following commands from the console:

    $ perl Makefile.PL
    $ make
    $ make install
    
(You may have to run `make install` as sudo or administrator.)

We'll submit this package to CPAN so that you can download it from there in
the near future.

# Getting Started

To start using the Soccermetrics API, create a new API Client object.

## API Credentials

You'll need your Soccermetrics API credentials to use the API Client object.
These get passed to the constructor or via environment variables.

```perl
#!/usr/bin/perl

use strict;
use warnings;

use Soccermetrics::API::Client;

my $appID = "f53baabb"
my $appKey = "demo1234567890demo1234567890"
my $client = Soccermetrics::API::Client->new(('ApplicationId' => $appID,
                                              'ApplicationKey' => $appKey));

```

If you call `Soccermetrics::API::Client` without any parameters, the constructor
will look for `SOCCERMETRICS_APP_ID` and `SOCCERMETRICS_APP_KEY` variables
inside the current environment.

We recommend that you keep your credentials in environment variables.
That way you won't have to worry about accidentally posting your credentials
in a public place.

```perl
#!/usr/bin/perl

use strict;
use warnings;

use Soccermetrics::API::Client;

my $client = Soccermetrics::API::Client->new();
```

# Access Resource Links

You can access resources through the API service root:

```perl
#!/usr/bin/perl

use strict;
use warnings;

use Soccermetrics::API::Client;
use Data::Dumper;

my $client = Soccermetrics::API::Client->new();
my $resp = $client->get();

print Dumper($resp);
```

# Get Match Information

```perl
#!/usr/bin/perl

use strict;
use warnings;

use Soccermetrics::API::Client;
use utf8;

my $client = Soccermetrics::API::Client->new();
my $var = $client->get('matches/info',
    ('home_team_name' => "Everton", 'away_team_name' => "Liverpool"));

foreach my $rec (@{$var->{data}}) {
    print "Matchday $rec->{matchday}: $rec->{match_date} at $rec->{kickoff_time}\n";
    my $lineup = $client->uri($rec->{link}->{lineups},
        ('is_starting' => 1,'sort' => 'player_team_name,position'));
    my $progress = 1;
    while ($progress) {
        foreach my $lrec (@{$lineup->{data}}) {
            my $player_name = $lrec->{player_name};
            utf8::encode($player_name);
            print "$player_name - $lrec->{player_team_name} ($lrec->{position_name})\n";
        }
        if($lineup->{meta}[0]->{page} == $lineup->{meta}[0]->{total_pages}) {
            $progress = 0;
        }
        else {
            $lineup = $client->uri($lineup->{meta}[0]->{next});
        }
    }
};
```

# Get Match Statistical Data

```perl
#!/usr/bin/perl

use strict;
use warnings;

use Soccermetrics::API::Client;
use utf8;

my $client = Soccermetrics::API::Client->new();
my $resp = $client->get('personnel/players', ('full_name' => 'Robin van Persie'));
my $goals = $client->uri($resp->{data}[0]->{link}->{events}->{goals});
my $penalties = $client->uri($resp->{data}[0]->{link}->{events}->{penalties}, ('outcome_type' => 'Goal'));

my $total_goals = $goals->{meta}[0]->{total_records} + $penalties->{meta}[0]->{total_records};
my $player_name = $resp->{data}[0]->{full_name};
utf8::encode($player_name);
print "Total goals by $player_name: $total_goals\n";
```

# Learn More

* [Link to API documentation](http://soccermetrics.github.io/fmrd-summary-api).

# License Information

The Soccermetrics Perl API Client is distributed under the MIT license.
