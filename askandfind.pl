#!/usr/bin/perl
#Program to store keys and answer when asked
#modules
#------------------------------------------------------------------------------
use strict;
use warnings;
use feature 'say';

#start
#------------------------------------------------------------------------------

my $dir = "$ENV{PWD}/keywords.txt";

#start message
#------------------------------------------------------------------------------

say "";
say "Ask and find! Version 1.0 beta.";
say "2014 by Luke V. Franklin.";

say "";
say "key:value - store the key 'key' with value 'value'";
say "keys key - search the key in the keywords.txt file";
say "edit - edit the specified keyword";
say "delete - delete the specified keyword";
say "load - load other keyword files";
say "about/help - display this message";
say "pwd - print current work directory";
say "quit/exit - exit the program";
say "";

#main loop
#------------------------------------------------------------------------------

MAIN:while ( 1 ) {
   
   unless ( -e $dir){
   
         print "Do you want to create the file 'keywords.txt' ";
         say "to store your data?";
         print "It will be created in $dir";
         say " (y/N) : ";
           
         chomp( my $entry2 = <STDIN>);
             
         unless ( $entry2 eq 'y' ){
            
            say "Aborting program...";  
            last MAIN;
         }
                        
         open my $fh, ">", $dir or
            die "Error in file writing in $dir: $!";
         
         close $fh;
      
         say "File created successfully: $dir";
         next MAIN;
    }
                
   print "Prompt\@$dir: ";
   chomp( my $entry = <STDIN>) ;
   
   my $count = @{[$entry =~ /:/g]};#count number of colons
    
   if ( $count > 1 ){
      say "Error: more than one colon matched! Try again!";
      next MAIN;
   }
   
   #keys menu
#------------------------------------------------------------------------------   
   if ($entry =~ /keys (.*)/) {
      
      open my $fh, "<", $dir or
         die "Error in file reading: $!";
         
      say "";
      while (<$fh>){
         my @key = split ':', $_;
         if ($1){
            
            if ($key[0] =~ /\b\Q${1}\E/){
            
               say $key[0];
               $count++;
            }
         }
      }
      close $fh;
      
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
      
      open my $fh, "<", $dir or
         die "Error in file reading: $!";
      
      my %file;
      
      while ( <$fh> ) {
      
         my ($word, $text) = split ':', $_;
         
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
         $file{$word} = $text;
      }
                       
      close $fh;
      
      unless ($count){
      
         say "Error: Key to edit not found!";
         next 
      }
      
      open $fh, ">", $dir or
         die "Error in file writing: $!";
          
      foreach (sort keys %file){
         
         print $fh "$_:$file{ $_ }\n";
      }
      
      close $fh;
           
      say "Key updated successfully!";
      next MAIN;   
   }

   #load menu
#------------------------------------------------------------------------------   
   if ($entry eq 'load') {
      print "Type the dir/file do you want to load your keywords: ";
      chomp( my $entry = <STDIN>);
      
      $dir = $entry;
      $dir =~ s/~/$ENV{ HOME }/;
      
      unless ( -e $dir){
   
         print "Do you want to create the file 'keywords.txt' ";
         say "to store your data?";
         print "It will be created in $dir";
         say " (y/N) : ";
           
         chomp( my $entry2 = <STDIN>);
          
         unless ( $entry2 eq 'y' ){
            
            say "Aborting program...";  
            last MAIN;
         }
                    
         open my $fh, ">", $dir or
            die "Error in file writing in $dir: $!";
         
         close $fh;
      
         say "File created successfully: $dir";
         next MAIN;
      }
   
      next MAIN;      
   }
   
   #delete menu
#------------------------------------------------------------------------------   
   if ($entry eq 'delete') {
      
      print "Which key do you want to delete? ";
      chomp( my $entry = <STDIN>);
      
      open my $fh, "<", $dir or
         die "Error in file reading: $!";
      
      my %file;
      
      while ( <$fh> ) {
      
         my ($word, $text) = split ':', $_;
         
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
         $file{$word} = $text;
      }
                 
      close $fh;
      
      unless ($count){
      
         say "Error: key to delete not found!";
         next MAIN;
      }
      
      open $fh, ">", "keywords.txt" or
         die "Error in file writing: $!";
          
      foreach (sort keys %file){
         
         print $fh "$_:$file{ $_ }\n";
      }
      
      close $fh;
           
      next MAIN;   
   }
   
   #about menu
#------------------------------------------------------------------------------   
   if ($entry eq 'about') {
      
      say "";
      say "Ask and find! Version 1.0 beta.";
      say "2014 by Luke V. Franklin.";
      say "";
      say "key:value - store the key 'key' with value 'value'";
      say "keys key - search the key in the keywords.txt file";
      say "edit - edit the specified keyword";
      say "delete - delete the specified keyword";
      say "load - load other keyword files";
      say "about/help - display this message";
      say "pwd - print current work directory";
      say "quit/exit - exit the program";
      say "";
      
      next MAIN;  
   }

   #pwd menu
#------------------------------------------------------------------------------   
   if ($entry eq 'pwd') {
      say $ENV{PWD};
      next MAIN;
   }
   
   #search and keywords handling
#------------------------------------------------------------------------------     
   my ($key, $value) = split ':', $entry;   
   
   if ( $count ){#verification to see if keys already exists
      
      open my $fh, "<", $dir or
         die "Error in file reading: $!";
      
      
      while ( <$fh> ){
      
         if (/^$key:/){
            
            say "The key '$key' already exists! Try another."; 
            next MAIN; 
         }
      }
      
      close $fh;
       
      open $fh, ">>", $dir or
         die "Error in file appending: $!";
      
      say $fh $entry;
      say "The key '$key' was stored with value '$value' in $dir!"; 
      
      close $fh;
  }
  
  else{
   
   open my $fh, "<", $dir or
      die "Error in file reading: $!";
   
      while ( <$fh> ){
      
         if ( /^\Q$key\E:/ ){
            
            my @line = split ':', $_;
            print "Echo says: $line[1]";#search and say
            next MAIN;
         }
      }
      
   close $fh;
     
   say "Error: key '$key' not found!";    
  }      
} 
#exit message
#------------------------------------------------------------------------------
say "Exiting...";
