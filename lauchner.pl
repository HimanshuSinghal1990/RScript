#!/usr/bin/perl -U
use strict;
use warnings;
use DBI;


#my $scriptname = "launcher";

############### CHECK WHETHER R SCRIPT IS RUNNING #############################

my $scriptName = "xxxxx"; // Write your Script Name
my $cmd = "ps aux | grep " . $scriptName;
my $result = `$cmd`;
my @lines = split("\\n", $result);

foreach(@lines) {
    #ignore results for the grep command and this script
    unless ($_ =~ m/grep|launcher/){
        print "sorry script is already running \n";
        exit;
    }
}


############### WHEN R IS NOT RUNNING LOGIC #############################
my $dbh = db_connect('DBNAME');

my $sql ="";

my @result = db_op($dbh,$sql,'yes');

if(@result)
{

for(my $i = 0 ; $i<= $#result ;$i++)
{
    my $patient_id = $result[$i]->{'patient_id'};
    my $sql_update ="COMMAND"; // FIRE INSERT/UPDATE/DELTE COMMAND ACCORDING TO IT.
    my @result_update = db_op($dbh,$sql_update,'no');

//Optional If want to fetch some data set
#    my $sql_test ="SELECT COMMAND";
#    my @result_test = db_op($dbh,$sql_test,'yes');

if(@result)
{

 my $launchCMD = "nohup Rscript PATH $arg &"; // PASS THE PATH AND ARGUMENT
       system($launchCMD);

}

    exit 0;

}
}
else
{
exit 0;
}

db_disconnect($dbh);


################################### DATABASE CONNECTION COMMON FUNCTIONS ####################################

sub db_connect
{
    my $dbase = $_[0];
    #print "$dbase  from main_lib.pl <br>";
    my $dbi_usr = 'DBUSER'; ###DATABASE USERNAME
    my $dbi_pas = 'DBPASSWRD'; ###DATABASE PASSWORD
    my $dbi_dsn = 'DBI:mysql:';
    $dbi_dsn .= $dbase;
    $dbi_dsn .= ':IP/LOCALHOST';
   my $dbh;
    #print "dsn = $dbi_dsn <br> usr = $dbi_usr <br> password = $dbi_pas<br>";
    $dbh = DBI->connect($dbi_dsn, $dbi_usr, $dbi_pas) || print "Unable to connect to the database". DBI->errstr;
    #print "$dbh<br><br>";
    return $dbh;
}

sub db_op
{
    my $dbh = $_[0];
    my $sql_statement = $_[1];
    my $b_return = $_[2];
    my $b_return_no = "no";
    $sql_statement =~ s/###COMMA###/,/g;

    #print "dbh in db_op = $dbh <br> sql = $sql_statement <br> b_return = $b_return<br><br>";

    my $sth;
    my $fields;
    my @value;
    $sth = $dbh->prepare($sql_statement) || print "Unable to prepare statement".$dbh->errstr;
    $sth->execute || print "Unable to execute statement".$dbh->errstr;

    if($b_return ne $b_return_no)
    {
        while($fields = $sth->fetchrow_hashref)
        {
            $value[$#value+1] = $fields;
        }
        $sth->finish || print "Unable to finish statement";
        return @value;
    }
}


sub db_disconnect
{
     my $dbh = $_[0];
    #print "dbh to disconnect = $dbh<br><br>";
    $dbh->disconnect || print "Unable to disconnect from the database";
}

