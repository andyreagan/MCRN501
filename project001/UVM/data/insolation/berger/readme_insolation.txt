Orbital Variations and Insolation Database: Insolation.readme file
-----------------------------------------------------------------------
               World Data Center A- Paleoclimatology
-----------------------------------------------------------------------
NOTE: PLEASE CITE ORIGINAL REFERENCES WHEN USING THIS DATA!!!!!

NAME OF DATA SET:  Orbital Variations and Insolation Database
LAST UPDATE:  5/92 (Addition of 1991 Solution)
CONTRIBUTOR:  A. Berger, Catholic University of Louvain
IGBP PAGES/WDCA Data Contribution Series #:  92-007
SUGGESTED DATA CITATION: 
Berger, A., 1992, Orbital Variations and Insolation Database.  
IGBP PAGES/World Data Center for Paleoclimatology 
Data Contribution Series # 92-007.  
NOAA/NGDC Paleoclimatology Program, Boulder CO, USA.

ORIGINAL REFERENCE: 
Berger A. and Loutre M.F., 1991. 
Insolation values for the climate of the last 10 million years.  
Quaternary Sciences Review, Vol. 10 No. 4, pp. 297-317, 1991.

GEOGRAPHIC REGION: Global, 10 degree latitude bands
PERIOD OF RECORD: 5,000,000 YBP - 100,000 YrAP
LIST OF FILES:  bein1 through bein11(1978 solution),
contents.78, insol91.jun, insol91.dec, orbit91, contents.91.

DESCRIPTION:  
This data set contains data on changes in the earth's orbital parameters, 
and the resulting variations in insolation.  The directory contains both 
the 1978 calculations and the latest (1991) solution by A. Berger.  
The 1978 solution is preferred for time 0 (1950 A.D.). 
The two solutions are equivalent through 800 KYBP, and the 
1991 solution is preferred for times greater than 800 KYBP.


Contents of 1978 files (files BEIN1 to BEIN11):
Age in Kyears (0=1950 A.D., negative values in thousands of years 
before present, positive values in thousands of years after present), 
Eccentricity, Longitude of Perihelion, Obliquity, Precession, Latitude, 
Mid-month insolations, January to December.
- Insolations are in langleys/day (cal/cm2/day). 
  Multiply by .4843 to convert to Watts/m2
- Solar constant taken as 1.95 cal/cm2/min for 1978 solution, 
  and 1360 W/m2 for 1991.

Files BEIN1.dat through BEIN11.dat each contain 100,000 years of orbital calculations 
at 1000 year intervals. File BEIN1.dat contains calculations for 0 KYrBp through 100KYrBP, 
File BEIN2.dat contains calculations for 100KYrBP to 200KYrBP, etc.  
File BEIN11.dat contains calculations for the next 100 KYr into the future.

Contents of 1991 files:

1. File ORBIT91: 0-5 Myr B.P.
    . first column: time in kyr (negative for the past; origin (0) 
                                 is 1950 A.D.)
    . second column: eccentricity, ECC 
    . third col: longitude of perihelion from moving vernal equinox 
      in degrees, OMEGA
    . fourth column: obliquity in degree and decimals, OBL 
    . fifth column: climatic precession, ECC . SIN(OMEGA) 
    . sixth column: mid-month insolation 65N for July in W/m**2 
    . seventh column: mid-month insolation 65S for January in W/m**2 
    . eighth column: mid-month insolation 15N for July in W/m**2
    . ninth column: mid-month insolation 15S for January in W/m**2 
 2. File INSOL91.DEC: 0-1 Myr B.P.
    . first column: time in kyr (negative for the past; origin (0) 
      is 1950 A.D.)
    . second to eighth: Dec mid-month insolation 90N, 60N, 30N, 0, 
      30S, 60S, 90S, W/m2
 3. File INSOL91.JUN: 0-1 Myr B.P.
    . first column: time in kyr (negative for the past; origin (0) 
      is 1950 A.D.)
    . second to eighth: June mid-month insolation 90N, 60N, 30N, 0, 
      30S, 60S, 90S, W/m2

