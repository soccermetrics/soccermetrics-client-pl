#!/usr/bin/perl

package Soccermetrics::API::Client;

use strict;
use warnings;
use REST::Client;
use JSON;
use URI::Escape 'uri_escape';

our $VERSION = '0.5';
our $Debug = 0;

sub API_URL  { 'https://api-summary.soccermetrics.net' };
sub API_VERSION { 'v0' };

my %app_id = ();
my %app_key = ();
my %api_version = ();
my %client = ();

sub new {
    my $class = shift;
    my %args = @_;

    my $self = bless \(my $ref), $class;

    $app_id      {$self} = $args{ApplicationId} || $ENV{SOCCERMETRICS_APP_ID};
    $app_key     {$self} = $args{ApplicationKey} || $ENV{SOCCERMETRICS_APP_KEY};
    $api_version {$self} = $args{VERSION} || API_VERSION();

    return $self;
}

sub toList {
    my $data = shift;
    my $key = shift;
    if (ref($data->{$key}) eq 'ARRAY') {
        $data->{$key};
    } elsif (ref($data->{$key}) eq 'HASH') {
        [$data->{$key}];
    } else {
        [];
    }
}

sub get {
    return _do_request(shift, METHOD => 'GET', RESOURCE => shift, VERSIONED => 1, @_);
}

sub head {
    _do_request(shift, METHOD => 'HEAD', RESOURCE => shift, VERSIONED => 1, @_);
}

sub options {
    _do_request(shift, METHOD => 'OPTIONS', RESOURCE => shift, VERSIONED => 1, @_);
}

sub uri {
    return _do_request(shift, METHOD => 'GET', RESOURCE => shift, VERSIONED => 0, @_);
}

sub _do_request {
    my $self = shift;
    my %args = @_;

    my $json = new JSON;
    my $client = REST::Client->new(host => API_URL(),timeout => 60);
    $client->setFollow(1);

    my $method = delete $args{METHOD};
    my $addversion = delete $args{VERSIONED};
    my $uri = '';

    if ($addversion) {
        my $resource = delete $args{RESOURCE} || '';
        $uri = "/$api_version{$self}/$resource";
    }
    else {
        my $resource = delete $args{RESOURCE} || die('Resource URL required.');
        $uri = $resource;
    }

    $args{'app_id'} = $app_id{$self};
    $args{'app_key'} = $app_key{$self};

    my $content = '';
    if( keys %args ) {
        $content = _build_content( %args );

        if( $method eq 'GET' && $uri =~ m/\?/) {
            $uri .= '&' . $content;
        }
        else {
            $uri .= '?' . $content;
        }
    }

    $client->request($method, $uri);
    my $response = $json->utf8->decode($client->responseContent());
    my $status = $client->responseCode();

    print STDERR "Request sent: " . $uri . "\n" if $Debug;

    if($status == 200) {
        return { status  => $status,
                 meta => toList($response,'meta'),
                 data => toList($response,'result')
               };
    } else {
        return { status => $status,
                 url => $response->{'uri'},
                 message => $response->{'message'}
               };
    }

}

## builds a string suitable for LWP's content() method
sub _build_content {
    my %args = @_;

    my @args = ();
    for my $key ( keys %args ) {
        $args{$key} = ( defined $args{$key} ? $args{$key} : '' );
        push @args, uri_escape($key) . '=' . uri_escape($args{$key});
    }

    return join('&', @args) || '';
}

sub DESTROY {
    my $self = $_[0];

    delete $app_id {$self};
    delete $app_key {$self};
    delete $api_version {$self};
    delete $client {$self};

    my $super = $self->can("SUPER::DESTROY");
    goto &$super if $super;
}

1;

=head1 NAME

Soccermetrics::API::Client - Interface for access to the Soccermetrics REST API

=head1 ABSTRACT

The Soccermetrics APIs are sports modeling and analytics layers on top of
in-match football (soccer) data sources at various levels of complexity.
These services make it easier for end-users to create their own customized
analysis tools on football data.