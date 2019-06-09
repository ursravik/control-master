#!/usr/bin/perl -w

use strict;
use Config;


######################
#
# Methods
#
######################

#---------------------------------------------------------------------
# Method: getOSPatchVersionForLinux
# This method gets the patch version for various flavours of Linux.
#---------------------------------------------------------------------
sub getOSPatchVersionForLinux {
    
    my $linuxDistribution;
    my $linuxDistributionVersion;
    my $linuxPatchLevel;
    
    if ( -f "/etc/redhat-release" ) {
        
        # This is a redhat distribution. Diagnosing further.
        $linuxDistribution = "RedHat";
        
        my $versionString = `cat /etc/redhat-release`;
        $versionString =~ s/[^0-9.^0-9]//g;
        
        my @versionData = split('\.', $versionString);
        $linuxDistributionVersion = $versionData[0];
        
        if ( $linuxDistributionVersion > 30 ){
            my @values = split( //, $linuxDistributionVersion );
            $linuxDistributionVersion = $values[0];
            $linuxPatchLevel = $values[1];
        } else {
            $linuxPatchLevel = $versionData[1];
        }
        
    }    
    
    chomp ( $linuxDistribution ) if ( $linuxDistribution );
    chomp ( $linuxDistributionVersion ) if ( $linuxDistributionVersion );
    chomp ( $linuxPatchLevel ) if ( $linuxPatchLevel );
    
    my $result;
    
    if ( defined $linuxPatchLevel ){
        $result = $linuxDistribution . "~" . $linuxDistributionVersion . "~" . $linuxPatchLevel;
    } else {
        $result = $linuxDistribution . "~" . $linuxDistributionVersion . "~";
    }
    
    
    return $result;
    
}


#---------------------------------------------------------------------
# Method: getOSPatchVersionForSolaris
# This method gets the patch version for various flavours of Solaris.
#---------------------------------------------------------------------
sub getOSPatchVersionForSolaris {
    
}


#---------------------------------------------------------------------
# Method: getOSPatchVersionForAix
# This method gets the patch version for various flavours of Aix.
#---------------------------------------------------------------------
sub getOSPatchVersionForAix {
    
    my $osString = `oslevel -s`;
    my @osData = split("-", $osString);
    
    my $osRelease = $osData[0];
    my $tlVersion = $osData[1];
    my $spVersion = $osData[2];
    
    return "AIX" . "~" . $osRelease . "~" . $tlVersion . "~" . $spVersion;
    
}


#---------------------------------------------------------------------
# Method: getOSPatchVersionForHPUX
# This method gets the patch version for various flavours of HP-UX.
#---------------------------------------------------------------------
sub getOSPatchVersionForHPUX {
    

}


######################
#
# Main Block
#
######################

# Check the Operating System and execute the version command accordingly
my $patchVersion;

if ( $Config{ 'osname' } eq "aix" ) {
    
    $patchVersion = getOSPatchVersionForAix();
    
} elsif ( $Config{ 'osname' } eq "linux" ) {
    
    $patchVersion = getOSPatchVersionForLinux();

}    

print $patchVersion;