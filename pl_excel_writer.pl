#!/usr/bin/perl -w

# version 0.1, (c) 2017 Simon John

# import modules
use strict;
use XML::DOM;
use Excel::Writer::XLSX;
    
# check our inputs
if (!$ARGV[0] || ($ARGV[0] !~ m/.nessus/) || ($ARGV[1] && $ARGV[1] !~ m/.xlsx/)) {
    print "Usage: nessus_vulns2xlsx.pl <.nessus file> [.xlsx file]\n";
    exit 0;
}

# write to given xlsx file or subsitute nessus filename
my $outfile;
if (!$ARGV[1]) {
    $outfile = $ARGV[0];
    $outfile =~ s/.nessus/.xlsx/;
}
else {
    $outfile = $ARGV[1];
}

# initialise some variables
my $parser = new XML::DOM::Parser;
my $doc = $parser->parsefile($ARGV[0]);
my @report = $doc->getElementsByTagName('Report');
my $reportname = $report[0]->getAttribute('name');

# create a new excel workbook and worksheet with a format defined
my $workbook = Excel::Writer::XLSX->new($outfile);
$workbook->set_optimization();
my $bold = $workbook->add_format(bold => 1, text_wrap => 1, align => 'top');
my $wrap = $workbook->add_format();
$wrap->set_align('top');
$wrap->set_text_wrap();
my $left = $workbook->add_format(align => 'left');

# separate tab for audit trail
my $audit_trail = $workbook->add_worksheet('Audit Trail');

# loop through each host
foreach my $report_host_elem ($doc->getElementsByTagName('ReportHost')) {
    # create a hash of hosts
    my %host;
    $host{'name'} = $report_host_elem->getAttribute('name');

    # create an excel worksheet for this host with a bold header line
    my $worksheet = $workbook->add_worksheet("$host{name}");
    $worksheet->write(0,0,'Port', $bold);
    $worksheet->write(0,1,'Service', $bold);
    $worksheet->write(0,2,'Protocol', $bold);
    $worksheet->write(0,3,'Severity', $bold);
    $worksheet->write(0,4,"Published Date", $bold);
    $worksheet->write(0,5,"Exploit Available", $bold);
    $worksheet->write(0,6,'Synopsis', $bold);
    $worksheet->write(0,7,'Plugin Output', $bold);
    $worksheet->write(0,8,'Description', $bold);
    my $row = 0;

    # make the last few columns a bit wider
    $worksheet->set_column(0,0,7);
    $worksheet->set_column(1,3,10);
    $worksheet->set_column(4,4,16);
    $worksheet->set_column(5,5,17);
    $worksheet->set_column(6,8,55);

    # get the tags from the properties
    foreach my $host_property ($report_host_elem->getElementsByTagName('HostProperties')) {
        foreach my $host_property_tag ($host_property->getChildNodes()) {
            # filter out textual data
            if ($host_property_tag->getNodeName() ne '#text') {
                my $tag = $host_property_tag->getAttribute('name');
                if (defined $host_property_tag->getFirstChild()) {
                    $host{$tag} = $host_property_tag->getFirstChild()->getNodeValue();
                }
            }
        }
    }

    # loop through items for this host
    foreach my $report_item($report_host_elem->getElementsByTagName('ReportItem')) {
        # create a hash of items
        my %item;

        # increment row count and reset column count
        my $column = 0;
        $row++;

        # loop through attributes from the element
        foreach my $attr (qw{port svc_name protocol severity}) {
            $item{$attr} = $report_item->getAttribute($attr);

            # clean up serverity
            if ($attr eq 'severity') {
                if ($item{'severity'} == 1) {
                    $item{'severity'} = 'Low';
                }
                elsif ($item{'severity'} == 2) {
                    $item{'severity'} = 'Medium';
                }
                elsif ($item{'severity'} == 3) {
                    $item{'severity'} = 'High';
                }
                elsif ($item{'severity'} == 4) {
                    # added in nessus5
                    $item{'severity'} = 'Critical';
                }
                else {
                    # should this be Info in nessus5?
                    $item{'severity'} = 'None';
                }
            }

            # add attribute to spreadsheet cell and increment column count
            $worksheet->write($row,$column,$item{$attr},$wrap);
            $column++;
        }

        # loop through sub elements just fetching the publication date
        foreach my $node ($report_item->getElementsByTagName('vuln_publication_date')) {
            my $vuln_publication_date = $node->getFirstChild()->getNodeValue();
            $worksheet->write($row,4,$vuln_publication_date,$wrap);
        }

        # loop through sub elements just fetching the exploit_available
        foreach my $node ($report_item->getElementsByTagName('exploit_available')) {
            my $exploit_available = $node->getFirstChild()->getNodeValue();
            if ($exploit_available =~ 'true') {
                $exploit_available = 'Yes';
            }
            elsif ($exploit_available =~ 'false') {
                $exploit_available = 'No';
            }
            $worksheet->write($row,5,$exploit_available,$wrap);
        }
        # loop through sub elements just fetching the synopsis
        foreach my $node ($report_item->getElementsByTagName('synopsis')) {
            # replace those pesky newlines
            my $synopsis = $node->getFirstChild()->getNodeValue();
            $synopsis =~ s/\n/ /g;
            $worksheet->write($row,6,$synopsis,$wrap);
        }

        # loop through sub elements just fetching the plugin output
        foreach my $node ($report_item->getElementsByTagName('plugin_output')) {
            # checkout we have output, some tivoli plugins are empty
            if ($node->getFirstChild()) {
                my $plugin_output = $node->getFirstChild()->getNodeValue();

                # remove leading newline
                $plugin_output =~ s/^\s+//;

                # if we find audit trail add it as separate sheet, not as row
                if ($plugin_output =~ m/Item under test/g) {
                    # point to audit trail tab
                    $worksheet->write($row,7,'See Audit Trail worksheet');

                    # remove empty lines from output
                    $plugin_output =~ s/\n\n/\n/gs;

                    # set column widths
                    $audit_trail->set_column(0,0, 30);
                    $audit_trail->set_column(1,1, 100);

                    # split lines into an array and start a counter
                    my @audit_array = split(/\n/,$plugin_output);
                    my $audit_row = 0;

                    # loop through lines, splitting on colon-space
                    foreach my $line (@audit_array) {
                        my ($key, $value) = split(/: /, $line);

                        # print two columns to sheet and increment counter
                        $audit_trail->write($audit_row,0,$key, $bold);
                        $audit_trail->write($audit_row,1,$value, $left);
                        $audit_row++;
                    }
                }
                else {
                    # write output to sheet
                    $worksheet->write($row,7,$plugin_output,$wrap) if $plugin_output;
                }
            }
        }

        # loop through sub elements just fetching the description
        foreach my $node ($report_item->getElementsByTagName('description')) {
            my $description = $node->getFirstChild()->getNodeValue();
            $worksheet->write($row,8,$description,$wrap);
        }
    }

    # add filters to all columns in each worksheet
    $worksheet->autofilter(0, 0, $row, 8);

    # display the first tab after audit trail
    $workbook->sheets(1)->activate();
}
