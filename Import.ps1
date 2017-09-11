# HP Connect-MX Import Script
#
# This script is used to pull designated Active Directory group membership & attributes,
# and transform them into an HP CMX-compatible CSV file for import.
#
#
#

$masterADGroup=""
$masterHPGroupID=""
$uploadCap=50
$numPages=0
$masterWorkingDirectory=""

# Get member count from security group, divide by 100, save result for later pagination
$groupMemberCount = (Get-ADGroupMember $masterADGroup).count
$numPages = [math]::Round($groupMemberCount / $uploadCap)

# Get all AD members of masterADGroup, then pull the attributes, export into CSV file
echo "Generating array from $masterADGroup ..."
$userArray=Get-ADGroupMember $masterADGroup -recursive | % {
	$group=$_
	Get-ADuser $_ -Properties * | Select GivenName,sn,email,telephoneNumber,employeeID
} 

#paginate by number of pages set in numPages above
For ($i=0; $i -lt $numPages; $i++) {
    
    $iplusone = $i + 1
    echo "Generating page: $iplusone of $numpages"
    $arrayMin=$iplusone*$uploadCap
    $arrayMax=$arrayMin+$uploadCap

    $userArray[$arrayMin..$arrayMax] | Export-Csv -Path .\groupmembers.csv -NoTypeInformation

    #sleep to allow for time to save CSV file
    sleep 2

    #import same CSV file and add HP CMX required columns for GroupId, GroupName, Status, Comments, Notification, collabOptOut 
    echo "Converting page: $iplusone of $numpages"
    $list = Import-Csv .\groupmembers.csv 
    $list | Select-Object @{ expression={$_.GivenName}; label='UserFirstName' }, @{ expression={$_.sn}; label='UserLastName' },@{ expression={$_.email}; label='UserEmailAddress' },@{ expression={$_.telephoneNumber}; label='PhoneNumber' },@{ expression={$_.employeeID}; label='federatedUniqueId' },@{Name='GroupId';Expression={$masterHPGroupID} },@{Name='GroupName';Expression={NULL}},@{Name='Status';Expression={'Active'}},@{Name='Comments';Expression={NULL}},@{Name='Notification';Expression={NULL}},@{Name='collabOptOut';Expression={NULL}}`
     | Export-Csv -Path .\groupmembers.csv -NoTypeInformation

    #call HP CMX Upload process
    echo "Uploading page: $iplusone of $numpages"
    echo "HP Cloud response: "
    $HPcommand = 'java -jar importusers.jar -csvfile .\groupmembers.csv -preservelogin -emailaddress <> -servername cmx-us.connected.com -port 443 -outputdir .\'
    iex $HPcommand

}
