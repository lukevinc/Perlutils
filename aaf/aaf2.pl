#!/usr/bin/perl
#Ask and find! Version 2.0 beta.
#2014 by Luke V. Franklin.

#modules
#------------------------------------------------------------------------------
use strict;
use warnings;
use feature 'say';
use File::Slurp;

#start
#------------------------------------------------------------------------------

my $dir = "$ENV{PWD}/keywords.txt";

#start message
#------------------------------------------------------------------------------

sub about{
   say "";
   say "Ask and find! Version 2.0 beta.";
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
   return 1;
}

about();

#main loop
#------------------------------------------------------------------------------

MAIN:while ( 1 ) {
   my $dirname = $dir;
   $dirname =~ s/$ENV{ HOME }/~/;
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
                        
         write_file( $dir );
      
         say "File created successfully: $dirname";
         next MAIN;
    }
    
    my @file = read_file($dir);
                         
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
      for (@file){
         my @key = split ':', $_;
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
      
      for ( @file ) {
      
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
         $keyvalue{$word} = $text;
      }
              
      unless ($count){
      
         say "Error: Key to edit not found!";
         next 
      }
         
      write_file($dir);    
      foreach (sort keys %keyvalue){
         append_file($dir,"$_:$keyvalue{ $_ }\n"); 
      }
                      
      say "Key updated successfully in $dirname!";
      next MAIN;   
   }

   #load menu
#------------------------------------------------------------------------------   
   if ($entry eq 'load') {
      print "Type the dir/file do you want to load your keywords: ";
      chomp( my $entry = <STDIN>);
      
      $dir = $entry;
      $dir =~ s/~/$ENV{ HOME }/;#understand ~ as homedir
      $dir =~ s/\.\//$ENV{ PWD }\//;#understand dot as current directory
      
      $dir = $ENV{ PWD }."/".$dir unless ($dir =~ /^\//);#add absolute path
           
      unless ( -e $dir){
   
         print "Do you want to create the file 'keywords.txt' ";
         say "to store your data?";
         print "It will be created in $dirname";
         say " (y/N) : ";
           
         chomp( my $entry2 = <STDIN>);
          
         unless ( $entry2 eq 'y' ){
            
            say "Aborting program...";  
            last MAIN;
         }
                
         write_file($dir);
      
         say "File created successfully: $dirname";
         next MAIN;
      }
   
      next MAIN;      
   }
   
   #delete menu
#------------------------------------------------------------------------------   
   if ($entry eq 'delete') {
      
      print "Which key do you want to delete? ";
      chomp( my $entry = <STDIN>);
        
      my %keyvalue;
      
      for ( @file ) {
      
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
         $keyvalue{$word} = $text;
      }
              
      unless ($count){
      
         say "Error: key to delete not found!";
         next MAIN;
      }
           
      write_file($dir);    
      foreach (sort keys %keyvalue){
         
         append_file($dir, "$_:$keyvalue{ $_ }\n");
      }
                     
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
   
   #search and keywords handling
#------------------------------------------------------------------------------     
   my ($key, $value) = split ':', $entry;   
   
   if ( $count ){#verification to see if keys already exists
      
      for ( @file ){
      
         if (/^$key:/){
            
            say "The key '$key' already exists in $dirname! Try another."; 
            next MAIN; 
         }
      }
           
      append_file($dir, "$entry\n");
      say "The key '$key' was stored with value '$value' in $dirname!"; 
  }
  
  else{
     
      for ( @file ){
      
         if ( /^\Q$key\E:/ ){
            
            my @line = split ':', $_;
            print "Echo says: $line[1]";#search and say
            next MAIN;
         }
      }
        
   say "Error: key '$key' not found in $dirname!";    
  }      
} 
#exit message
#------------------------------------------------------------------------------
say "Exiting...";
