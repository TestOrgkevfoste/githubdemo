#!/usr/bin/perl

#use strict;
use CGI qw();
use JSON;
use LWP::Simple;
use Data::Dumper;

#Encryption needed for production 
my $null_value = undef;

open my $fid, '<', '/usr/local/webhook/idfile' or die "Can't open file $!";
my $user = do { local $/; <$fid> };
chomp($user);
open my $fpw, '<', '/usr/local/webhook/pwfile' or die "Can't open file $!";
my $pass = do { local $/; <$fpw> };
chomp($pass);




print "Content-type: text/plain\n\n";
 
my $debug = 0;

#Get POST data from GitHub
my $cgi = CGI->new;
my $json_text = $cgi->param('POSTDATA') || die ("ERROR receiving GitHub payload\n");

my $jsonData = eval { decode_json $json_text };

if ( $@ ) {
    die ("ERROR: failed to parse '$json_text' as JSON:\n $@\n");
    }


# Checking test data
open PAYLOAD ,"> /tmp/entire_payload.$$.txt" or die "Cannot open /tmp/file\n" if ($debug) ;
print PAYLOAD Dumper(\$jsonData) if ($debug);
print PAYLOAD "branches_url is: $jsonData->{'repository'}->{'branches_url'}\n" if ($debug);

#Capture branch path and alter path
my $branch_url = $jsonData->{'repository'}->{'branches_url'};
print PAYLOAD "my branches path is: $branch_url\n" if ($debug);

$branch_url =~ s/\{\/branch\}/\/master\/protection/;
print PAYLOAD " branch_url is $branch_url\n" if ($debug);

#Capture issues_url and alter path
my $issues_url = $jsonData->{'repository'}->{'issues_url'};
$issues_url =~ s/\{\/number\}//;
print PAYLOAD " issues_url is $issues_url\n" if ($debug);

#Capture open_issues_count
my $open_issues_count = $jsonData->{'repository'}->{'open_issues_count'};

# Do nothing to protect the master branch unless this is the initial creation of the branch
# I'll check the open_issues_count to see if this is the first run

if ($open_issues_count == 0) {
   # Create branch protection
   
   my $ua = LWP::UserAgent->new;
   $ua->agent("MyApp/0.1");
   my $req = HTTP::Request->new(PUT => $branch_url);
   my $header = ['Content-Type' => 'application/json; charset=UTF-8'];
   $req->content_type('application/vnd.github.v3+json');
   $req->authorization_basic("$user", "$pass");
   
   # Set required parameters to update branch protection
   my $content = { "required_status_checks" => $null_value, "restrictions" => $null_value, "required_pull_request_reviews" => $null_value, "enforce_admins" => $null_value };
   my $encoded_content = encode_json($content);
   $req->content("$encoded_content");
   
   my $response = $ua->request($req);
   
   if ($response->is_success) {
      print PAYLOAD "\n Successful\n" if ($debug);
      print PAYLOAD $response->content if ($debug);
   } else {
      print PAYLOAD $response->status_line, "n" if ($debug);
   } 
   
   print PAYLOAD "Starting issue...\n" if ($debug);
   #Create issue for branch
   my $issue_ua = LWP::UserAgent->new;
   $issue_ua->agent("MyApp/0.1");
   my $issue_req = HTTP::Request->new(POST => $issues_url);
   my $issue_header = ['Accept' => 'application/vnd.github.squirrel-girl-preview', 'Content-Type' => 'application/json; charset=UTF-8'];
   $issue_req->content_type('application/vnd.github.v3+json');
   $issue_req->authorization_basic("$user", "$pass");
   
   # Set required parameters to create issues
   my $issue_content = { "title" => "Branch protection enabled", "body" => "Go to $settings_url to configure branch protection rules. Reach out to @kevfoste for questions", "owner" => "kevfoste2", "assignee" => "kevfoste2" };
   my $issue_encoded_content = encode_json($issue_content);
   $issue_req->content("$issue_encoded_content");
   
   my $issue_response = $issue_ua->request($issue_req);
   
   if ($issue_response->is_success) {
      print PAYLOAD "\n Issue Successful\n" if ($debug);
      print PAYLOAD $issue_response->content if ($debug);
   } else {
      print PAYLOAD $issue_response->status_line, "n" if ($debug);
   } 
   
   close(PAYLOAD) if ($debug);
}

exit 0;
