Prerequisite
 
SAPLink correctly installed on your system
ABAP JSON Document Class correctly installed on your system
Installation
 
Download nugg file from the latest release
Install nugg file using SAPLink
Configuration
 
Connect to https://code.google.com/apis/console/b/0/
Request your API access (see api access1.png and api access2.png)
Once completed connect into your ABAP system and create an entry with the data provided by the service you want to use.
 
For example Google (see api access3.png).

API host field should contain "https://docs.google.com/feeds/%20https://spreadsheets.google.com/feeds/%20https://docs.googleusercontent.com" without quotes

That's it! The consumer is registered in the system.

User profile registration needs a report to be performed, we have not yet created i but you could use the abap2gapps demo report right now. See instruction on that project.
