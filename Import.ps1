# HP Connected-MX | AD Bulk User Import
#
# This script is designed to pull designated Active Directory group membership & attributes,
# and transform those results into an HP CMX-compatible CSV file for automated Bulk User Import.
#
# Place into a scheduled task to automatically sync AD Security group memberships with your HP Connected-MX User base.
#

$masterADGroup=''
$masterHPGroupID=''

# Get all AD members of group "", then pull the required LDAP attributes, export into CSV file
Get-ADGroupMember $masterADGroup -recursive | % {
	$group=$_
	Get-ADuser $_ -Properties * | select GivenName,sn,telephoneNumber,employeeID,mail
} | Export-Csv -Path .\members.csv -NoTypeInformation

# Import same CSV file and add HP CMX required columns for GroupId, GroupName, Status, Comments, Notification, collabOptOut 
$list = Import-Csv .\members.csv 
$list | Select-Object @{ expression={$_.GivenName}; label='UserFirstName' }, @{ expression={$_.sn}; label='UserLastName' }`
,@{ expression={$_.mail}; label='UserEmailAddress' },@{ expression={$_.telephoneNumber}; label='PhoneNumber' }`
,@{ expression={$_.employeeID}; label='federatedUniqueId' },@{Name='GroupId';Expression={$masterHPGroupID} }`
,@{Name='GroupName';Expression={NULL}},@{Name='Status';Expression={'Active'}},@{Name='Comments';Expression={NULL}}`
,@{Name='Notification';Expression={NULL}},@{Name='collabOptOut';Expression={NULL}}`
 | Export-Csv -Path .\members.csv -NoTypeInformation

#call HP CMX Upload process
$HPcommand = 'java -jar importusers.jar -csvfile .\members.csv -emailaddress '' -servername cmx-us.connected.com -port 443 -outputdir .\'
iex $HPcommand
