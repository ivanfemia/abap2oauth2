Only the signature method 3 is implemented (used by Google for example).

# Installation

1. Install the program ZABAPGIT on your ABAP system -> https://github.com/larshp/abapGit
1. Start ZABAPGIT, "+online" of the repository https://github.com/se38/zjson, and **pull** it
1. Start ZABAPGIT, "+online" of the current repository, and **pull** it

# Configuration
 
* Connect to https://code.google.com/apis/console/b/0/
* Request your API access (see api access1.png and api access2.png)

Once completed connect into your ABAP system and create an entry with the data provided by the service you want to use.
 
For example Google (see api access3.png).

API host field should contain "https://docs.google.com/feeds/%20https://spreadsheets.google.com/feeds/%20https://docs.googleusercontent.com" without quotes

That's it! The consumer is registered in the system.

User profile registration needs a report to be performed, we have not yet created i but you could use the abap2gapps demo report right now. See instruction on that project.

# Usage

1. There is an example for Google Docs here -> https://github.com/ivanfemia/abap2gapps
