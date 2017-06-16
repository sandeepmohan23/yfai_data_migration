#Remove specified attributes from all nodes from a TCXML file
#Usage:
#perl replace_values.pl inp_attrs.txt inp_dir out_dir

use File::Basename;
use File::Path qw(make_path);
use utf8;
use Encode qw( encode_utf8 );

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Following are a few global OS dependent variables.
#
# Variable to hold directory separator. "\\" for Windows and "/" for Unix
#
# my $dir_separator = '/';
my $dir_separator = '\\';

my $perl_file_name = basename($0);
$perl_file_name =~ s{\.[^.]+$}{};
print "$perl_file_name \n";



my $LOGFILE = "$perl_file_name.log";
# Opening log file
open LOGFILE, " > $LOGFILE" or die $!;

($inp_file, $inp_dir, $out_dir,$xml_file_name) = (shift, shift, shift,shift);
$island_filter = "island_id=\"0\"";
$reg_ptr = "([\"'])(?:(?=(\\?))\2.)*?\1";
$reg_ptr = "\"([^\"]*)\"";


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Perl trim function to remove whitespace from the start and end of the string
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# sub trim($)
# {
    # my $string = shift;
    # $string =~ s/^\s+//;
    # $string =~ s/\s+$//;
    # return $string;

# }
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

print "xml_file_name=$xml_file_name\n";
my @inp_xml_files = <$inp_dir${dir_separator}$xml_file_name.xml>;

open (INP, "< $inp_file") or die "Can not open file : $inp_file\n";

print "replace_values_inputFile.pl $inp_file, $inp_dir, $out_dir,$xml_file_name\n";

my %attr_hash;

while (<INP>) {
	chomp;
	my ($a, $b) = split/\|/;
	$attr_hash{$a} = $b;
}
foreach $inp_xml_file (@inp_xml_files) {
	$file_name = basename($inp_xml_file);
	print "Processing file: $file_name .....\n";
	print LOGFILE "Processing file: $file_name .....\n";
	$out_file = $out_dir . "${dir_separator}" . $file_name;
	open(OUT, "> $out_file") or die "Can not open file: $out_file\n";
	open(DATA, "< $inp_xml_file") or die "Can nopt open file: $inp_xml_file\n";
	while (<DATA>) {
		$line = $_;
		if (index($line, $island_filter) != -1) {
			
		foreach my $k (keys(%attr_hash)) {
			($k eq "") && next;
			$v = $attr_hash{$k};
			#$src1 = "=" . "\"" . $k . "\"";
			#$repl1 = "=" . "\"" . $v . "\"";
			#$src2 = "<" . $k;
			#$repl2 = "<" . $v;
			#print "sec = $src1 $src2 repl = $repl1 $repl2\n";
			#print "Key = $k repl = $repl\n";
			#print "$line";
			$src1 = "\"" . $k . ",";
			$repl1 = "\"" . $v . ",";
			$src2 = "\"" . $k . "\"";
			$repl2 = "\"" . $v . "\"";
			$src3 = "," . $k . "\"";
			$repl3 = "," . $v . "\"";
			
			$line =~ s/$src1/$repl1/g;
			$line =~ s/$src2/$repl2/g;
			$line =~ s/$src3/$repl3/g;
			#$line =~ s/$k/$v/g;
		}
		}
		elsif( index($line, "<A9_PartCustomerInfoStorage") != -1 ){
		

			my $search_index =  index($line,"yf5_CustomerPartName=");
	
			if ($search_index != -1)#checking search_string_1
			{

				my $search_output_str_1=substr $line, $search_index;
				
				# item_id="2115256-JA6/0605" split string with " delimiter
				my @search_string_1_split_array = split ("\"",$search_output_str_1);
						
				my $yf5_CustomerPartName=$search_string_1_split_array[1];
				$yf5_CustomerPartName =trim($yf5_CustomerPartName);
				my $bytelimit = 32;
				

				my $bytenum = testbytelength($yf5_CustomerPartName);
				print LOGFILE "-----------------------------------------\n";
				print LOGFILE "$line\n";
				print LOGFILE "SRC:yf5_CustomerPartName=$yf5_CustomerPartName    Bytes=$bytenum\n";
				
				if($bytenum > $bytelimit){
					# my $trim_yf5_CustomerPartName=trimStringByBytes($yf5_CustomerPartName,$bytelimit);
					
							my $str = $yf5_CustomerPartName;
							# my $bytelimit = shift;
							
							print "=======================================\n";  
							my $bytenum = testbytelength($str);
							my $chars = length($str);
							print "Initial num of chars = $chars\n";
							print "Initial num of bytes =  $bytenum\n";
							print LOGFILE "Initial string = \"$str \"\n";
							print "=======================================\n";

							while ($bytenum > $bytelimit) {
							print "---------------------------------------\n";
							$bytenum = testbytelength($str);
							$chars = length($str);
							print "in while counts - pre chop =  $bytenum , $chars  \n";
							#print "in while char count - pre chop =  $chars\n";
							chop ($str);
							$chars = length($str);
							$bytenum = testbytelength($str);
							print LOGFILE "in while counts - post chop =  $bytenum , $chars  \n";
							print "---------------------------------------\n";
							}
							
							print "=======================================\n";  
							chop($str);
							$bytenum = testbytelength($str);
							$chars = length($str);
							print "After num of chars = $chars\n";
							print "After num of bytes =  $bytenum\n";
							print LOGFILE "After string = \"$str\"\n";
							print "=======================================\n";

							# return $str;
	
					my $trim_yf5_CustomerPartName=$str;
	
					
					$src4 = "yf5_CustomerPartName=\"" . $yf5_CustomerPartName . "\"";
					$repl4 = "yf5_CustomerPartName=\"" . $trim_yf5_CustomerPartName . "\"";
					
					print LOGFILE "Replace:src/tgt/$src4/$repl4\n";
			
					$line =~ s/$src4/$repl4/g;
				}
				else{
					print OUT $line;
				}

			}
			
		}
		print OUT $line;
	}
	close DATA;
	close OUT;
}

sub testbytelength($)  
  {
	 my $str = shift;

     {
       use bytes;
       my $bytes = length($str);
      # print "in sub bytes $bytes\n";
      return $bytes;
     }
  }
  
sub trimStringByBytes($$)
{

    my $str = shift;
    my $bytelimit = shift;
	
	print "=======================================\n";  
	my $bytenum = testbytelength($str);
	my $chars = length($str);
	print "Initial num of chars = $chars\n";
	print "Initial num of bytes =  $bytenum\n";
	print LOGFILE "Initial string = \"$str \"\n";
	print "=======================================\n";

	while ($bytenum > $bytelimit) {
	print "---------------------------------------\n";
	$bytenum = testbytelength($str);
	$chars = length($str);
	print "in while counts - pre chop =  $bytenum , $chars  \n";
	#print "in while char count - pre chop =  $chars\n";
	chop ($str);
	$chars = length($str);
	$bytenum = testbytelength($str);
	print "in while counts - post chop =  $bytenum , $chars  \n";
	print "---------------------------------------\n";
	}
	
	print "=======================================\n";  
	$bytenum = testbytelength($str);
	$chars = length($str);
	print "After num of chars = $chars\n";
	print "After num of bytes =  $bytenum\n";
	print LOGFILE "After string = \"$str\"\n";
	print "=======================================\n";

	return $str;
} 




