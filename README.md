# Onyx Sorter
This utillity is used to combine infromation from 3 difference sources for the purpose 
for reconciling hotel commissions. The the data sources are mid office data from Locomote and 
Sabre's SAM through "Travel Intelligence" (http://ti.sabrepacific.net.au) and
the hotel commission data from third party collectors like Onyx and TACS. 
__Note:  TACS and Medina files have not been tested recently__

Multiple statement files can be read in one command, but this is not recommended, as
this makes the work for accounts a little more complicated.

```sh
> ls -R
.:
20160911/  README.md  read_onyx_mos_sam.rb

./20160911:
219036.rtf                        SegmentsForOnyx.csv                
Hotel Commissions 2016-09-06.csv  
```




### Statements
Statments in the code mean line items in statement from onyx etc. 
The basic information needed for a match is the confirmation ID, 
the date and the name. The text below shows a sample line item from Onyx.

```sh
JONES LUKE                    02362393  125523240718OTH  07/11/16      1   COMM           $   228.18 $    22.82 $   0.00 $   2.28  F     $    25.10   AUD  $        25.10
```

Because the line items are expected to be fixed length in file there can be problems 
if the name of the guest is longer than expected or if the commission is larger than the fixed 
with allows. If their is a conversion fault then an error 
message will be displayed.The most common is likely to be the date, this is the last item converted in the test, so hopefully most of the other fields will be correct.

Information regarding the Hotel name etc is given on a seperate line 

### Segments
Segments come from the term used GDS's for an item of travel. Matches are made on the confirmation ID guest name and date.

```sh 
"BEST WESTERN INTL","BEST WESTERN PLUS CHARLES STUR","ABXBWC    ","WGA BEST WESTERN PLUS CHARLES STUR                ","178589","ACME","Jane Consultant" ,"22/01/2016","02/03/2016","","AUD","918437","Active","GUEST/CHRISTINE MS","","Domestic",,"$139.50","$558.00","$55.80","$558.00","10","$55.80","$0.00","0"
```

The data extraction from Sabre does some strange things to the file. This have been setup to work with the encoding when the extraction is sent with an email??? The same report will have differnet encoding or formatting depending on the extraction method. 

Both the Locomote and Sabre files are CSV delimited.


### Code Outline

1. Read in Segments from a subdirectory of today's date
2. Read in Statements from a subdirectory of today's date
3. Iterate through the Statement items and compare the with the Segments
4. Add the statement item with best matched segment to a list
5. Write the matches to a file.

#### Guest Names
When comparing guest names the first and second name as split, and then sorted alphabetically, this is because of name order inconsistancies within each system. All titles are also removed.

### Onyx File

The Onyx is a fixed width delimited file. The hotel chain, hotel and segment have different indentations. The hotel names needs to be remembered when reading in the individual items 
```sh 
VANTIS HOTEL GROUP-P


  MANTRA 2 BOND STREET   CORNER OF GEORGE AND BOND STRE  SYDNEY NS
    JONES LUKE                    02362393  125523240718OTH .........
```

#### Other Collector files
Although the application is called onyx sorter is can be used and extend 
for other collection company reports other reports included are TACS and Medina. 

### Output
#### File
The output of the file is a CSV file most of the fields are self explanatory. 
The first set of columns are copies from the statement file, this is some 
processing to calculate the commission from the collecter for each transaction. 
If the item does not use AUD then a seperate column is created for 
international transactions. 

The file name is called segment_matches\<time stamp\>.csv and saved in the 
same directory "date" directory as the statement and segment files.


#### Command line
The command line displays some basic information like the number of 
items read in each file. Once all the data is read the and the matching 
starts then a series of pluses and minuses appear. A plus denotes a match 
and a minus denotes a statement item without a match. 


# Possible Improvements
+ Faster algorithms
+ Remove any items from the segments that are not within the date range of 
the statement files
+ Test scripts
+ Extra granularity for exception handling
+ Test file formats before reading
+ A better reading method for the files rather that using a directory with 
date. What though?




# Onyx Sorter
This utillity is used to combine infromation from 3 difference sources 
for the purpose for reconciling hotel commissions. The the data sources are 
mid office data from Locomote and Sabre's SAM through "Travel Intelligence" 
(http://ti.sabrepacific.net.au) and the hotel commission data from third 
party collectors like Onyx and TACS. 


Multiple statement files can be read in one command, but this is 
not reocommended, as this makes the work for accounts a little more complicated.

### Statements
Statments in the code mean line items in statement from onyx etc. 
The basic information needed for a match is the confirmation ID, the date 
and the name. The text below show a sample line item from Onyx.

```sh
JONES LUKE                    02362393  125523240718OTH  07/11/16      1   COMM           $   228.18 $    22.82 $   0.00 $   2.28  F     $    25.10   AUD  $        25.10
```

Because the line items are expected to be fixed length in file there 
can be problems if the name of the guest is longer than expected or if the 
commission is larger than the fixed with allows. If there is an exception 
an there is a conversion fault occours then an error message will be displayed.

Information regarding the Hotel name etc is given on a seperate line 

### Segments
Segments come from the term used GDS's for an item of travel. 
Matches are made on the confirmation ID name and date.

```sh 
"BEST WESTERN INTL","BEST WESTERN PLUS CHARLES STUR","ABXBWC    ","WGA BEST WESTERN PLUS CHARLES STUR                ","178589","ACME","Jane Consultant" ,"22/01/2016","02/03/2016","","AUD","918437","Active","GUEST/CHRISTINE MS","","Domestic",,"$139.50","$558.00","$55.80","$558.00","10","$55.80","$0.00","0"
```

The data extraction from Sabre does some strange things to the file. 
This have been setup to work with the encoding when the extraction is 
sent with an email??? The same report will have differnet encoding or 
formatting depending on the extraction method. 

Both the Locomote and Sabre files are CSV delimited.


### Code Outline

1. Read in Segments from a subdirectory of today's date
2. Read in Statements from a subdirectory of today's date
3. Iterate through the Statement items and compare the with the Segments
4. Add the statement item with best matched segment to a list
5. Write the matches to a file.

### Onyx File

The Onyx is a fixed width delimited file. The hotel chain, hotel and 
segment have different indentations. The hotel names needs to be remembered 
when reading in the individual items 
```sh 
VANTIS HOTEL GROUP-P


  MANTRA 2 BOND STREET   CORNER OF GEORGE AND BOND STRE  SYDNEY NS
    JONES LUKE                    02362393  125523240718OTH .........
```

#### Other Collector files
Although the application is called onyx sorter is can be used and 
extend for other collection company reports other reports included 
are TACS and Medina. 

### Output
#### File
The output of the file is a CSV file most of the fields are self 
explanatory. The first set of columns are copies from the statement file, 
this is some processing to calculate the commission from the collecter for 
each transaction. If the item does not use AUD then a seperate column is 
created for international transactions. 

The file name is called segment_matches\<time stamp\>.csv and saved 
in the same directory "date" directory as the statement and segment files.


#### Command line
The command line displays some basic information like the number of items 
read in each file. Once all the data is read the and the matching starts 
then a series of pluses and minuses appear. A plus denotes a match and a 
minus denotes a statement item without a match. 