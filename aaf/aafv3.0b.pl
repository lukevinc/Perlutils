#!/usr/bin/perl
#Ask and find! Version 3.0 beta.
#2014 by Luke V. Franklin.

#modules
#------------------------------------------------------------------------------

use strict;
use warnings;
use feature 'say';
use IO::All;
use Cwd 'abs_path';
use File::Basename;

#subroutines
#-----------------------------------------------------------------------------

#shows about message
sub about{
   say "";
   say "\tAsk and find! Version 3.0 beta.";
   say "\t2014 by Luke V. Franklin.";

   say "";
   say "\tkey:value - store the key 'key' with value 'value'";
   say "\tkeys key - search the key in the keywords.txt file";
   say "\tedit - edit the specified keyword";
   say "\tdelete - delete the specified keyword";
   say "\tdelfile - delete the current keyword file";
   say "\tload - load other keyword files";
   say "\tabout/help - display this message";
   say "\tpwd - print current work directory";
   say "\tlines - show the lines of the file";
   say "\tkeywords - show all the keywords of the file";
   say "\tquit/exit - exit the program";
   say "";
   return 1;
}

#count lines of the file
sub count_lines
{
    my ($filename) = @_;

    open my $fh, '<', $filename;

    my $count = 0;
    while (my $l = <$fh>)
    {
        $count++;
    }

    close($fh);

    return $count;
}

#local variables and start
#-----------------------------------------------------------------------------
my $default = "$ENV{PWD}/keywords.txt"; 
my $dir = $default;

about();

#main loop
#------------------------------------------------------------------------------

MAIN:while ( 1 ) {
   
   my $dirname = $dir;
   $dirname =~ s/$ENV{ HOME }/~/;
  
   unless ( -e $dir){
   
         print "Do you want to create the file 'keywords.txt' ";
         say "to store your data?";
         print "It will be created in $dirname";
         print " (y/N) : ";
           
         chomp( my $entry2 = <STDIN>);
             
         unless ( $entry2 eq 'y' ){
            
            say "Aborting program...";  
            last MAIN;
         }
                        
         io->file($dir)->utf8->print("");
      
         say "File created successfully: $dirname";
         next MAIN;
   }
    
   my $file = io->file($dir);
   
                         
   print "Prompt\@$dirname: ";
   chomp( my $entry = <STDIN>) ;
   
   my $count = @{[$entry =~ /:/g]};#count number of colons
    
   if ( $count > 1 ){
      say "Error: more than one colon matched! Try again!";
      next MAIN;
   }
   
   #keys menu
#------------------------------------------------------------------------------   
   if ($entry =~ /keys (.*)/) {
           
      say "";
      while (my $line = $file->chomp->getline()) {
         
         my @key = split ':', $line;
         if ($1){
            
            if ($key[0] =~ /\b\Q${1}\E/){
            
               say $key[0];
               $count++;
            }
         }
      }
            
      say "Keys matched: $count";
      say "";
      next MAIN;    
   }
   
   last MAIN if ($entry =~ /^(exit|quit)$/);
     
   #edit menu
#------------------------------------------------------------------------------     
   if ($entry eq 'edit') {
      
      print "Which key do you want to edit? ";
      chomp( my $entry = <STDIN>) ;
          
      my %keyvalue;
      
      while (my $line = $file->chomp->getline()) {
      
         my ($word, $text) = split ':', $line;
         
         if ($entry eq $word) {#if key is in keywords
         
            print "Text for '$word': ";
            chomp( my $entry = <STDIN>);
                  
            $count = @{[$entry =~ /:/g]};#count number of colons
            
            if ($count) {
            
               say "Error: colon matched at text.";
               next MAIN;
            }
            
            print "Are you sure do you want to edit this key? (y/N): ";
            chomp( my $yesno = <STDIN> );           
            
            unless ($yesno eq 'y'){
            
               say 'Key edit canceled!';
               next MAIN;
            }
               
            $text = $entry;
            $count++;
         }
         chomp( $text );    
         $keyvalue{$word} = $text;
      }
              
      unless ($count){
      
         say "Error: Key to edit not found!";
         next 
      }
      io->file($dir)->utf8->print("");  
          
      foreach (sort keys %keyvalue){
         
         "$_:$keyvalue{ $_ }\n" >> io->file($dir);
      }
                      
      say "Key updated successfully in $dirname!";
      next MAIN;   
   }

   #load menu
#------------------------------------------------------------------------------   
   if ($entry eq 'load') {
      print "Type the dir/file do you want to load your keywords: ";
      chomp( my $entry = <STDIN>);
     
      my $safe = $dir;
      
      $dir = $entry;
      $dir =~ s/~/$ENV{ HOME }/;#understand ~ as homedir
      
      $dir = abs_path($dir) or die "$!";#add absolute path
      my $dirname = $dir;
      $dirname =~ s/$ENV{ HOME }/~/;
      
      if ( -d $dir ){
            say "Error: $dirname is a directory!";
            $dir = $safe;
            next MAIN;
      }   
      
      unless ( -e $dir){
         my $basename = basename($dir);
         print "Do you want to create the file '$basename' ";
         say "to store your data?";
         print "It will be created in $dirname";
         say " (y/N) : ";
           
         chomp( my $entry2 = <STDIN>);
          
         unless ( $entry2 eq 'y' ){
            
            say "Loading program canceled.";  
            $dir = $safe;
            next MAIN;
         }
                    
         io->file($dir)->utf8->print(""); 
      
         say "File created successfully: $dirname";
         next MAIN;
      }
      
      say "";
      say "\t$dirname : ".count_lines($dir)." keys loaded!";
      say "";
      
      next MAIN;      
   }
   
   #delete menu
#------------------------------------------------------------------------------   
   if ($entry eq 'delete') {
      
      print "Which key do you want to delete? ";
      chomp( my $entry = <STDIN>);
        
      my %keyvalue;
      
      while (my $line = $file->chomp->getline()) {
      
         my ($word, $text) = split ':', $line;
         
         if ($entry eq $word) {#if key is in keywords
         
            print "Are you sure you want to delete ";
            print "'$entry'? (y/N) : ";
            chomp( my $entry = <STDIN>) ;
            
            if ($entry eq 'y'){
               say "Key '$word' deleted successfully!";
            }
            
            else{
               say "Error: key not deleted!";
            }
                        
            $count++;
            next;
            
         }
         chomp( $text );    
         $keyvalue{$word} = $text;
      }
              
      unless ($count){
      
         say "Error: key to delete not found!";
         next MAIN;
      }
           
      io->file($dir)->utf8->print("");  
         
      foreach (sort keys %keyvalue){
         
         "$_:$keyvalue{ $_ }\n" >> io->file( $dir );
      }
                     
      next MAIN;   
   }

   #delete file menu
#------------------------------------------------------------------------------   
   if ($entry eq 'delfile') {
     my $basename = basename($dir);
     print "Are you sure do you want delete '$basename'? (y/N)";
     
     chomp( my $entry = <STDIN> );
     
      unless ( $entry eq 'y' ){
            
            say "Deleting file canceled.";  
            next MAIN;
         }
         
     unlink $dir;
     say "File '$basename' deleted successfully!";  
     $dir = $default;    
          
     next MAIN;  
   }

   #about menu
#------------------------------------------------------------------------------   
   if ($entry eq 'about') {
      
      about();
      
      next MAIN;  
   }

   #pwd menu
#------------------------------------------------------------------------------   
   if ($entry eq 'pwd') {
      say $ENV{PWD};
      next MAIN;
   }
    
   #line counting menu
#------------------------------------------------------------------------------ 
    if ($entry eq 'lines') {
      
      say "";
      say "\t".count_lines( $dir )." line(s) found in $dir";
      say "";
      next MAIN;
   }
   
  #keywords menu
#------------------------------------------------------------------------------ 
    if ($entry eq 'keywords') {
      
      my $space = 0;
      while (my $line = $file->chomp->getline()) {
      
         my @keys = split ':', $line;
         
         if (length($keys[0]) > $space){
            
            $space = length($keys[0]);
         
         }
     }
      
      say "";
      while (my $line = $file->chomp->getline()) {
         my @keys = split ':', $line;
         
         my $size = $space - length($keys[0]) + 2;
         printf "\t%s%${size}s", $keys[0], "";   
         if ($count > 3){
            say "";
            $count = 0;
            next;
         }
         
         $count++;   
         
      }
      
      say "\n";
      say "\t".count_lines($dir)." key(s) found in $dir";
      say "";
      
      next MAIN;
   }   
  
   #search and keywords handling
#------------------------------------------------------------------------------     
   my ($key, $value) = split ':', $entry;   
   
   if ( $count ){#verification to see if keys already exists
      
      while (my $line = $file->chomp->getline()) {
      
         if ($line =~ m/^$key:/){
            
            say "The key '$key' already exists in $dirname! Try another."; 
            next MAIN; 
         }
      }
           
      "$entry\n" >> io->file( $dir );
      
      say "The key '$key' was stored with value '$value' in $dirname!"; 
  }
  
  else{
     
      while (my $line = $file->chomp->getline()) {
      
         if ( $line =~ m/^\Q$key\E:/ ){
            
            my @lines = split ':', $line;
            say "Echo says: $lines[1]";#search and say
            next MAIN;
         }
      }
        
   say "Error: key '$key' not found in $dirname!";    
  }      
} 
#exit message
#------------------------------------------------------------------------------
say "Exiting...";
