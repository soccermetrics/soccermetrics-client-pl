use 5.018000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Soccermetrics::API::Client',
    VERSION_FROM      => 'lib/Soccermetrics/API/Client.pm',
    PREREQ_PM         => {REST::Client, JSON, URI::Escape},
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Soccermetrics/API/Client.pm', # retrieve abstract from module
       AUTHOR         => 'Howard Hamilton <hhamilton@soccermetrics.net>') : ()),
);
