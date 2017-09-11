# HP_ConnectedMX_AD
Integrate Active Directory with your HP Connected-MX SaaS solution

### Configuration
Set global variables as described below.

* **masterADgroup** - Desired Active Directory security group

* **masterHPGroupID** - Desired HP Group ID. This can be found by navigating to the desired group on the web console and pulling from the URL. (Example: https://cmx-us.connected.com/#/groups/view/ *123456789*)

* **uploadCap** - Maximum record count per .csv file - results may vary.

* **masterWorkingDirectory** - Secure directory where .csv containing PII may be generated

### Troubleshooting

#### null response from HP Cloud


```java : Bulk importing users failed: null
At line:1 char:1
+ java -jar importusers.jar -csvfile .\groupmembers.csv -emailaddress ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (Bulk importing users failed: null:String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
```

If you receive a null error from HP, try reducing $uploadCap to a lower number. Higher volume per .csv file appears to cause unexpected results.
    
