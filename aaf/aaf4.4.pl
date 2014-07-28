#!/usr/bin/perl

#Ask and find! Version 4.4 stable.
#2014 by Luke V. Franklin.

#modules
#-----------------------------------------------------------------------------

use strict;
use warnings;
use autodie;
use feature 'say';
use feature 'fc';
use IO::All;
use Cwd 'abs_path';
use File::Basename;
use Term::ReadLine;
use POSIX;


#subroutines
#-----------------------------------------------------------------------------

#shows about message
sub about{
   
   say "\n\tAsk and find! Version 4.4 - new functions added!";
   say "\t2014 by Luke V. Franklin.";
   
   say "\n\tkey:value - store pairs key/value.";
   say "\tks <key> - search the keys in the current file.";
   say "\ths - histogram of the keys.";
   say "\te - edit the specified key.";
   say "\tcd - change the default dir.";
   say "\td - delete the specified key.";
   say "\tdf - delete the current file loaded.";
   say "\tl - load other keyword files.";
   say "\ta/h - show this message.";
   say "\tp - show current work directory.";
   say "\tls - show the quantity of lines of the file.";
   say "\tk - show all keys of the file.";
   say "\tv <pattern> - search for patterns in values.";
   say "\ts - sort the file alfabetically.";
   say "\tq/ex - exit the program.\n";
   say "\tHints, doubts and bugs: report to <lukevinc9\@gmail.com>\n";
   
   return 1;
}

#count lines of the file
sub count_lines
{
    my ($filename) = @_;

    open my $fh, '<', $filename or die "Error in line counting! Aborting!";

    my $count = 0;
    $count++ while (my $l = <$fh>);
    
    close($fh);

    return $count;
}

#a simple yes/no dialog, return 1 for y and 0 for anything else
sub yesno{
   my $single = pop;
   my @msgs = @_;
   
   say foreach (@msgs);
     
   print $single." (y/N): ";
   chomp( my $yesno = <STDIN> );
   
   return 1 if ($yesno eq 'y');
   return 0;
}

#show a question and wait for answer, then return it.
sub question
{
   my $single = pop;
   my @msgs = @_;
    
   say foreach (@msgs);
     
   print $single." : ";

   chomp(my $response = <STDIN>);
   
   return $response;
}

#make conversions between abs and compact filepaths
sub adjust_path 
{   
   my $mode = shift;
   my $directory = shift;
   
   $directory = $ENV{PWD}."/$directory" if ($directory !~ m/^(\\|\/)/ );  
   
   if ($mode eq 'c'){#compact mode
         
      $directory =~ s/$ENV{PWD}/\./g;
      $directory =~ s/$ENV{HOME}/~/g;
   }
   
   elsif ($mode eq 'a'){#absolute
      
      $directory =~ s/^\.(\W)/$ENV{PWD}\//;        
      $directory =~ s/~/$ENV{HOME}/;
      
   }
   
   return $directory;
}

#local variables and start
#-----------------------------------------------------------------------------

my $default;
my $dirfile;
my $dirdirfile;

my $kw_name = 'keywords.txt';#keyword name
my $adj_kw_name = adjust_path('a', $kw_name);

my $df_name = 'dirfile.txt'; #dirfile name
my $adj_df_name = adjust_path('a', $df_name);

if (-e $adj_df_name ){
  
  $dirfile = io->file($adj_df_name);
  
  while (my $line = $dirfile->chomp->getline()) {
    
    $line = adjust('a', $line);
    
    $default = $line;
    last;
    
  } 
  $dirdirfile = $adj_df_name;
}

else{

  my $answer = yesno("Do you want create the file 'dirfile.txt' to store your default directory?",
   "It will be created in $ENV{ PWD }");      
  
  if ($answer){
      io->file("$ENV{PWD}/dirfile.txt")->utf8->print("$ENV{PWD}/keywords.txt"); 
      $default = "$ENV{PWD}/keywords.txt"; 
  
      $dirdirfile = $adj_df_name;
      say "\n\tDefault directory file created successfully!\n";
  }
  else{
      say "Aborting...";
      exit();
   }
}  

unless ( $default || (-e $default) || length($default) ){
 
  say "\n\tInvalid directory, check your $df_name and check it for errors.\n";
  exit();
}

my $dir = $default;

$dir = adjust_path('a', $dir);

about();

#main loop
#------------------------------------------------------------------------------

MAIN:while ( 1 ) {
   
   my $dirname = $dir;
   
   $dirname = adjust_path('c', $dirname);
       
   unless ( -e $dir){
              
      my $answer = yesno("Do you want create '$kw_name' to store your data?",
      "It will be created in $dirname.");      
  
      if ($answer){
          io->file($dir)->utf8->print("");
             
          say "\n\tFile created successfully: $dirname\n";  
          next MAIN;  
         
      }
      else{
         say "Aborting...";
         exit();
      }
  }       
   
   my $file = io->file($dir);
                            
   print "Prompt\@$dirname: ";
   chomp( my $entry = <STDIN>);
   
   if($entry eq ''){
    
         say "\n\tError: blank key. Try another.\n";
         
         next MAIN;
   }
      
   my $count = @{[$entry =~ /:/g]};#count number of colons
    
   if ( $count > 1 ){
      say "\n\tError: more than one colon found! Try again!\n";
      
      next MAIN;
   }
   
   #keys menu
#------------------------------------------------------------------------------   
   if ($entry =~ /ks (.*)/) {
           
      print "\n";
      while (my $line = $file->chomp->getline()) {
         
         my @key = split ':', $line;
         if ($1){
            
            if ($key[0] =~ /\b\Q${1}\E/i){
            
               say "\t$key[0]";
               $count++;
            }
         }
      }
      say "\n\tKeys found: $count\n";      
      
      next MAIN;    
   }

#quit menu
#------------------------------------------------------------------------------     
      
   last MAIN if ($entry =~ /^(ex|q)$/);

  #histogram menu
#------------------------------------------------------------------------------     
   
   if ($entry eq 'hs') {
     
     my %hist;
     my @alfa = 'A' .. 'Z';
     my $total;
     while (my $line = $file->chomp->getline()) {
  
        my ($key, $value) = split ':', $line;
          
        my $initial = substr( $key, 0, 1 );
     
        foreach (@alfa){
     
          if ($key =~ m/^TO (.*)/){
            
            $hist{'Verbs'}++;
            last;
          }  
                    
          if ($initial eq $_){
           
             $hist{$_}++;
             $total++;
             last;  
          }
        }  
        
      }  
      my $sum = 0;
      my $count2 = 0;
      
      print "\n\t";
      foreach (sort keys %hist ){
       
        my $pc = ( $hist{$_} / $total ) * 30;
        
        $pc = ceil( $pc );
        
        $sum += $pc;
        print "$_: ", "*" x $pc, " ($pc) : "; 
        
        $count2++;
        
        if ($count2 > 3){
         print "\n\t";
         $count2 = 0;
        }
               
      }
      
      say "\n\n\tTotal: $sum\n";
      say "\tHint: sort the file to obtain better accuracy.\n";
      next MAIN;
   }   

   #edit menu
#------------------------------------------------------------------------------     
   if ($entry eq 'e') {
            
      my $entry = question("\n\tWhich key do you want to edit?");
          
      my %keyvalue;
      
      while (my $line = $file->chomp->getline()) {
      
         my ($word, $text) = split ':', $line;
         
         if ($entry eq $word) {#if key is in keywords
            print "\n\tText for '$word': ";
            
            chomp( my $entry = <STDIN>);
                  
            $count = @{[$entry =~ /:/g]};#count number of colons
            
            if ($count) {
               say "\n\tError: colon found in text.\n";          
               
               next MAIN;
            }
                        
            my $answer = yesno("Are you sure do you want to edit this key?");
            
            if ($answer){
               $text = $entry;
               $count++;
            }
            
            else{
               say "\n\tKey edit canceled!\n";
               next MAIN;
            }
                    
         }
         
         chomp( $text );    
         $keyvalue{$word} = $text;
      }
              
      unless ($count){
      
         say "\n\tError: key for edition not found!\n";
         next 
      }
      io->file($dir)->utf8->print("");  
          
      foreach (sort keys %keyvalue){
         
         "$_:$keyvalue{ $_ }\n" >> io->file($dir);
      }
      say "\n\tKey updated successfully in $dirname!'\n";                
      
      next MAIN;   
   }

 #change dir menu
#------------------------------------------------------------------------------   
   if ($entry eq 'cd') {
           
      my $entry2 = question("Which is the new default directory?");
           
      my $answer = yesno("\n\tAre you sure do you want change the default dir?");
      
      unless ($answer){
          say "\n\tDirectory change canceled.\n";    
          next MAIN;
      }       
            
      $entry2 = adjust_path('a', $entry2);
      
      unless (-e $entry2){
         say "\n\tError: invalid directory!\n";       
       
         next MAIN;  
      }
      
      $dir = $entry2;
      io->file($dirdirfile)->utf8->print($entry2); 
        
      say "\n\tDefault file changed successfully in $dirdirfile\n";
      next MAIN;   
   } 

   #load menu
#------------------------------------------------------------------------------   
   if ($entry eq 'l') {
      
      print ": ";
      my $entry = question("\n\tType the dir/file do you want to load your keys");
     
      my $safe = $dir;
      
      $dir = $entry;
      
      $dir = adjust_path('a', $dir);
            
      $dir = abs_path($dir) or die "$!";#add absolute path
      my $dirname = $dir;
      $dirname = adjust_path('c', $dirname);
      
      if ( -d $dir ){
            say "\n\tError: $dirname is a directory!\n";
            
            $dir = $safe;
            next MAIN;
      }   
      
      unless ( -e $dir){
         my $basename = basename($dir);

         my $answer = yesno("Do you want to create the file '$basename' to store your data?",
            "It will be created in $dirname.");
         
         if ( $answer ){
            io->file($dir)->utf8->print(""); 
            say "\n\tFile created successfully: $dirname\n"; 
         
            next MAIN;
         
         }
         else{
             say "\n\tProgram load canceled.\n";
              
             $dir = $safe;
             next MAIN;
         }
                 
      }      
      say "\n\t$dirname : ".count_lines($dir)." key(s) loaded!\n";
      
      next MAIN;      
   }
   
   #delete menu
#------------------------------------------------------------------------------   
   if ($entry eq 'd') {
            
      my $entry = question("\n\tWhich key do you want to delete?"); 
        
      my %keyvalue;
      
      while (my $line = $file->chomp->getline()) {
      
         my ($word, $text) = split ':', $line;
         
         if ($entry =~ /\b$word\b/i) {#if key is in keywords
                    
            my $answer = yesno("\tAre you sure do you want to delete '$entry'?");
            
            
            if ( $answer ){
               say "\n\tKey '$word' deleted successfully!\n";
            
            }
            else{
               say "\n\tError: key '$word' not deleted!\n";
               next MAIN;
            }
                                           
            $count++;
            next;
         }
         chomp( $text );    
         $keyvalue{ $word } = $text;
      }
              
      unless ($count){
              
         say "\n\tError: key doesn't exists!\n";
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
   if ($entry eq 'df') {
     my $basename = basename($dir);
          
     my $answer = yesno("\tAre you sure do you want to delete '$basename'?");
     
     if ($answer){
         unlink $dir;
     
         say "\n\tFile '$basename' deleted successfully!\n";
         $dir = $default;    
          
         next MAIN;  
     }
     
     else{
         say "\n\tFile delete canceled.\n";
         next MAIN;
     }
   }

   #about menu
#------------------------------------------------------------------------------   
   if ($entry =~ m/^[ah]$/) {
         
      about();
      next MAIN;  
   }

   #pwd menu
#------------------------------------------------------------------------------   
   if ($entry eq 'p') {
      say "\n\tYou are here: $ENV{PWD}\n";
      
      next MAIN;
   }
    
   #line counting menu
#------------------------------------------------------------------------------ 
    if ($entry eq 'ls') {
      
      say "\n\t".count_lines( $dir )." line(s) found in $dir\n";
      next MAIN;
   }
   
  #keywords menu
#------------------------------------------------------------------------------ 
    if ($entry eq 'k') {
      
      my $space = 0;
      while (my $line = $file->chomp->getline()) {
      
         my @keys = split ':', $line;
         
         if (length($keys[0]) > $space){
            
            $space = length($keys[0]);
         }
      }

      print "\n";
      while (my $line = $file->chomp->getline()) {
         my @keys = split ':', $line;
         
         my $size = $space - length($keys[0]) + 1;
         printf "\t%s%${size}s", $keys[0], "";   
         if ($count > 1){
            say "";
            $count = 0;
            next;
         }
         
         $count++;   
      }
           
      say "\n\n\t".count_lines($dir)." key(s) found in $dirname.\n";
            
      next MAIN;
   }   

#value menu
#------------------------------------------------------------------------------ 
    if ($entry =~ m/v (.*)/) {
       my $count = 0;
       
       print "\n";
       while (my $line = $file->chomp->getline()) {
  
          my ($key, $value) = split ':', $line;
                    
          if ($value =~ m/$1/){
            
            say "\t$key:$value"; 
            $count++;
          }
       }
       
       say "\n\t$count key(s) found.\n";
       next MAIN;
    }
 
 #sort menu
#------------------------------------------------------------------------------ 
    if ($entry eq 's') {
      $file = io->file($dir);
      my %keyvalue;
      
      while (my $line = $file->chomp->getline()) {
      
         my ($word, $text) = split ':', $line;
         
         $keyvalue{ $word } = $text;
      }
      
      io->file($dir)->utf8->print("");
            
      foreach ( sort { fc($a) cmp fc($b)}keys %keyvalue){
         
         uc($_).":$keyvalue{ $_ }\n" >> io->file( $dir );
      }
      say "\n\tKeys sorted in '$dirname' successfully!\n";                
      
      next MAIN;
       
    }
   #search and keywords handling
#------------------------------------------------------------------------------     
   my ($key, $value) = split ':', $entry;   
      
   if ( $count ){#verification to see if keys already exists
      
      if (length($key) < 2 || length($value) < 2){

         say "\n\tError: invalid key or value!\n";
         next MAIN;
      }
      
      while (my $line = $file->chomp->getline()) {
      
         if ($line =~ m/^$key:/i){
            say "\n\tThe key '$key' already exists in $dirname! Try another.\n";
             
            next MAIN; 
         }
      }
           
      "$entry\n" >> io->file( $dir );
           
      say "\n\tThe key '$key' was stored with the value '$value' in $dirname!\n";
  }
  
  else{
     
      while (my $line = $file->chomp->getline()) {
      
         if ( $line =~ m/^\Q$key\E:/i ){
            
            my @lines = split ':', $line;
            say "Eco says: $lines[1]";#search and say
            next MAIN;
         }
      }
   
   say "\n\tError: key '$key' not found in $dirname!\n";
  }
}  
 
#exit message
#------------------------------------------------------------------------------
say "Exiting...";
