#!/usr/bin/perl
use Encode;
use utf8;
#Convert html encoding into utf8 plain text and vice versa.
use HTML::Entities;
use warnings;
use List::BinarySearch qw( :all );
use List::BinarySearch qw( binsearch  binsearch_pos  binsearch_range );
use LWP::UserAgent;
binmode STDOUT, ":encoding(utf8)";


if (!$#ARGV == 0 ){die "Please provide the url\n";}
my $html = $ARGV[0];
#Calling main procedure
&main($html);


sub main{
  my ($html) = @_;
  #Obtains the HTML code
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get($html);
  my $htmlFileContent = $response->content if $response->is_success;
  my @array = ();
  my @contentbycomm = ();
  my @contentbypoints = ();
  #Checks for each entry
  while($htmlFileContent =~ /(<tr class='athing'.*[\s]*.*[\s]*.*[\s]*.*<\/tr>)/g){
    my $points = 0;
    my $comments = 0;
    my $htmlFilteredContent = $1;
    #Gets the entry number
    $htmlFilteredContent =~ s/(?:<span class="rank">(\d+)\.<\/span>)(.*)/$2/gs;
    push(@array, $1);
    #Gets the entry title
    $htmlFilteredContent =~ /class="storylink"\s*(?:rel="nofollow")?>(.*)[^<]*<\/a></g;
    my $title = $1;
    push(@array, $title);
    #Gets the entry number of points
    if ($htmlFilteredContent =~ /id="score\_\d+">(\d+)\spoints/g){
      $points = $1;
    }    
    push(@array, $points);
    #Gets the entry comments
    if ($htmlFilteredContent=~ /(\d+)\&nbsp\;comment(?:s)?/g){
      $comments = $1;
    }
    push(@array, $comments);
    #Checks how many words the title has
    if($title =~ /^\s*\S+(?:\s+\S+){5,}\s*$/){
      push(@contentbycomm, [@array]);
    }else{
      push(@contentbypoints, [@array]);
    }
    @array = ();
  }
  #Sorts the arrays
  @contentbypoints = sort{$a->[2] <=> $b->[2]} @contentbypoints;
  @contentbycomm = sort{$a->[3] <=> $b->[3]} @contentbycomm;

  #Prints the Arrays
  print "Sorted by Points\n";
  print "--------------------------------------------------------\n";
  &printArr(@contentbypoints);
  print "Sorted by Comments\n";
  print "--------------------------------------------------------\n";
  &printArr(@contentbycomm);
  print "Done!\n";

}

sub printArr{
  my (@arr) = @_;
  for(my $i=0; $i < $#arr; $i++){
      print "Number of Entry: ".$arr[$i][0]."\n";
      print "Title: ".$arr[$i][1]."\n";
      print "Points: ".$arr[$i][2]."\n";
      print "Comments: ".$arr[$i][3]."\n";
      print "--------------------------------------------------------\n";
    }
}