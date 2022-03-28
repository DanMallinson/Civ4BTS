#!/usr/bin/perl

# Written by Peter "Gyathaar" Pettersen


use Switch;
use Compress::Zlib;


my $full_data;
my $where;
my $filename;


sub convert() {

	my $temp;

	open (FILE,"$filename") or die ("Cant open file data file\n");
	binmode FILE;
	local $/ = undef;
	my $full_file = <FILE>;
	close FILE;

	$full_data = "";

	$marker = sprintf("%c%c",0x78,0x9c);
	$where = index($full_file, $marker)-4;

	if ($where < 0){
        	$header = $full_file;
		$where = length($header);
		return;
	}


	$header = substr($full_file,0,$where);

	($i,$status) = inflateInit();

	my $temp;
        my $count = unpack("x$where l",$full_file);
	$full_file = unpack("x$where A*",$full_file);

	while ($status == Z_OK) {
		$buffer = unpack("x4 A$count",$full_file);
		$full_file = unpack("x4 x$count A*",$full_file);
		($temp, $status) = $i->inflate($buffer);

                $full_data = $full_data . $temp;

		last if($count < 65536);

		if($status == Z_STREAM_END ) {
			print "End: $staus\n";
                	last;
                }
                else {
        		$count = unpack("l",$full_file);

                }
	}


	my $footer = $full_file;

	$filename = substr($filename,0,index($filename,".Civ5Save"));

	open (OUTFILE,">${filename}_converted.Civ5Save") or die ("Cant open file data file\n");
	binmode OUTFILE;

	$marker = " FINAL_RELEASE";
	$where = index($header,$marker) - 10;
	$temp = unpack("l",substr($header,$where,4));
	$header = substr($header,0,$where).sprintf("%c%c%c%c",0x14,0x00,0x00,0x00).substr($header,$where+4,20).substr($header,$where+4+$temp);

	print OUTFILE $header;

	my $position=0;
	
	$marker = sprintf("%c%c%c%cUNIT_SETTLER",0x0c,0x00,0x00,0x00);

	my $offset = 0;
	while(($where = index($full_data, $marker,$position))>0){
		$position = $where+1;
		$where -=4;
		$temp = unpack("l",substr($full_data,$where,4));
                $temp -= 90;				
		$full_data = substr($full_data,0,$where)."Z".substr($full_data,$where+1);
	

		$marker2 = sprintf("%c%c%c%cUNIT_BARBARIAN_SWORDSMAN",0x18,0x00,0x00,0x00);
	
		
		$where = index($full_data, $marker2,$position) + length($marker2) + 4 + $offset;

		while($temp-- > 0){
			my $temp2 = unpack("l",substr($full_data,$where,4));
			$full_data = substr($full_data,0,$where).substr($full_data,$where+$temp2+8+$offset);
		}
		$offset += 12;
	        $offset %= 24;
			
	}

	$position=0;
	
	$marker = sprintf("%c%c%c%cBUILDING_FLOATING_GARDENS",0x19,0x00,0x00,0x00);

	while(($where = index($full_data, $marker,$position))>0){
		$position = $where+1;
		$where -=4;
		$temp = unpack("l",substr($full_data,$where,4));
                $temp -= 89;				
		$full_data = substr($full_data,0,$where)."Y".substr($full_data,$where+1);
	

		$marker2 = sprintf("%c%c%c%cBUILDING_SYDNEY_OPERA_HOUSE",0x1b,0x00,0x00,0x00);
	
		
		$where = index($full_data, $marker2,$position) + length($marker2) + 4;

		while($temp-- > 0){
			my $temp2 = unpack("l",substr($full_data,$where,4));
			$full_data = substr($full_data,0,$where).substr($full_data,$where+$temp2+8);
		}
			
	}

	$position=0;
	
	$marker = sprintf("%c%c%c%cPROMOTION_EMBARKATION",0x15,0x00,0x00,0x00);

	while(($where = index($full_data, $marker,$position))>0){
		$position = $where+1;
		my $datasize = (index($full_data,sprintf("%c%c%c%cPROMOTION_INSTA_HEAL",0x14,0x00,0x00,0x00),$position) - $where)-length($marker);
		$where -=4;
		$temp = unpack("l",substr($full_data,$where,4));
                $temp -= 143;				
		$full_data = substr($full_data,0,$where).sprintf("%c",0x8f).substr($full_data,$where+1);
	

		$marker2 = sprintf("%c%c%c%cPROMOTION_STRONGER_VS_DAMAGED",0x1d,0x00,0x00,0x00);
	
		
		$where = index($full_data, $marker2,$position) + length($marker2) + $datasize;


		while($temp-- > 0){
			my $temp2 = unpack("l",substr($full_data,$where,4));
			$full_data = substr($full_data,0,$where).substr($full_data,$where+$temp2+4+$datasize);
		}
			
	}


	($i,$status) = deflateInit();


	($compressed,$status)=$i->deflate($full_data);

	
	($output, $status) = $i->flush();


	$compressed = $compressed . $output;


		

	my $len;
	while(($len=length($compressed)) > 0){
		$len= 65536 if($len > 65536);
		
		$section = unpack("A$len",$compressed);
		$len = length($section);
		print OUTFILE pack("l",$len);

		$compressed = unpack("x$len A*",$compressed);
		print OUTFILE $section;
	}


	print OUTFILE $footer;
	close OUTFILE;
}


BEGIN {
    if ($^O eq "MSWin32")
    {
        require Tkx;
        require File::HomeDir;
        Tkx->import();
        File::HomeDir->import();
    }
}


$filename=$ARGV[0];

unless ($filename || $^O ne "MSWin32") {

	my $docs     = File::HomeDir->my_documents."\\My Games\\Sid Meier's\ Civilization 5\\Saves\\single";

	$filename = Tkx::tk___getOpenFile(-initialdir=>$docs);

}


convert();






		