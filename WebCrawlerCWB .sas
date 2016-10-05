****** Updated Date: 2016/09/22 ******
******SAS Version: 9.4 ******
****** Input: The file generated by SAS. ******
****** Output: The sas7bdat file for further analyses. ******
****** Environemt: Linux or Windows ******
****** Description: ******;

/*datalist station and period*/
data stno;
   input stno;
   do year=2015 to 2016;
      do month=1 to 12;
      output;
	  end;
      end;
   datalines;
466880
;

data stno_z2; 
   set stno; 
   format month z2.; 
   run; 
/*
466900
466910
466920
466930
466940
466950
466990
467050
467060
467080
467110
467300
467350
467410
467420
467440
467480
467490
467530
467540
467550
467570
467571
467590
467610
467620
467650
467660
467770
467780
467990
*/

DATA WORK.ST_CONTAIN;RUN;

%macro stno(st,yr,mth);
FILENAME SOURCE URL "http://e-service.cwb.gov.tw/HistoryDataQuery/MonthDataController.do?command=viewMain&station=&st&stname=%25E9%259E%258D%25E9%2583%25A8&datepicker=&yr-&mth" DEBUG;
DATA SOURCE1;
FORMAT WEBPAGE $1000.;
INFILE SOURCE LRECL=32767 DELIMITER=">" encoding='utf-8';
INPUT WEBPAGE $ @@;
RUN;

DATA SOURCE2;
SET SOURCE1;
WHERE WEBPAGE LIKE "_%<%";
TEXT=compress(TRANWRD(WEBPAGE,"%NRSTR(&nbsp;)",''));
CHAR_SIGN=FIND(TEXT,"<")-1;
station_no=&st;
RUN;


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_SOURCE2 AS 
   SELECT t1.WEBPAGE, 
          t1.TEXT, 
          t1.CHAR_SIGN, 
          /* COMPRESS_TAB */
            (COMPRESS(t1.TEXT,"	")) AS COMPRESS_TAB, 
          t1.station_no
      FROM WORK.SOURCE2 t1;
QUIT;


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_SOURCE2_0000 AS 
   SELECT t1.WEBPAGE, 
          t1.CHAR_SIGN, 
          t1.TEXT, 
          t1.COMPRESS_TAB, 
            (FIND(t1.COMPRESS_TAB,"<")-1) AS CHAR_SGIN2, 
          t1.station_no
      FROM WORK.QUERY_FOR_SOURCE2 t1;
QUIT;


PROC SQL;
   CREATE TABLE WORK.QUERY_FOR_SOURCE2_0001 AS 
   SELECT t1.WEBPAGE, 
          t1.CHAR_SIGN, 
          t1.TEXT, 
          t1.COMPRESS_TAB, 
          t1.CHAR_SGIN2, 
            (SUBSTRN(t1.COMPRESS_TAB,1,t1.CHAR_SGIN2)) AS content, 
          t1.station_no
      FROM WORK.QUERY_FOR_SOURCE2_0000 t1;
QUIT;

data daily_mod; set WORK.QUERY_FOR_SOURCE2_0001(keep=content station_no firstobs=165 obs=2208) ;
no=_n_;
run;

PROC SQL;
   CREATE TABLE WORK.QUERY_DAILY_MOD AS 
   SELECT t1.content, 
          t1.no, 
            (MOD(t1.no,2)) AS mod, 
          t1.station_no
      FROM WORK.DAILY_MOD t1
      WHERE (CALCULATED mod) = 1;
QUIT;

/*If you run in SAS University(SAS Studio),should setting function substr <poistion>. year:14 , month:19 */
data info;set WORK.QUERY_FOR_SOURCE2_0001 (keep=content firstobs=3 obs=3);
year=substr(content,10,4);
month=substr(content,15,2);
run;

%macro doloop(midname,lastname);
data setresult; run;

%do k=0 %to 30;
data day; set WORK.QUERY_DAILY_MOD(KEEP=CONTENT station_no firstobs=%eval(33*&k+1) obs=%eval((&k+1)*33));
run;

PROC TRANSPOSE DATA=day
	OUT=WORK.TRNS_day
	PREFIX=Column
	NAME=Source;
	BY station_no;
	VAR content;

RUN; QUIT;

data setresult; set setresult WORK.TRNS_day;
if Column1 ne '';
year=&midname;
month=&lastname;
run;
%end;

data result_&lastname; set setresult;
run;

%mend;

data _null_; set info(drop=content);
call execute('%doloop(' || year || ',' || month || ')');
run;

data st_&st._&yr; /*資料處理 須設置資料起始年度 目前為：01*/
set result_01-result_%sysfunc(putn(&mth,z2.));
run;

data st_&st; /*資料處理 須設置資料起始年度 目前為：2015*/
set st_&st._2015-st_&st._&yr;
run;

/*The WORK.ST_POOL is all of station and period initial datalist.*/
DATA WORK.ST_CONTAIN; SET WORK.ST_CONTAIN WORK.st_&st;
if Column1 ne '';
RUN;

PROC SQL;
   CREATE TABLE WORK.ST_POOL AS 
   SELECT DISTINCT *
      FROM WORK.ST_CONTAIN;
QUIT;

%mend;

data _null_; set work.stno_z2;
call execute('%stno(' || stno || ',' || year || ',' || month || ')');
run;

/*RENAME FROM WORK.ST_POOL*/
PROC SQL;
   CREATE TABLE WORK.ST_RENAME AS 
   SELECT t1.station_no, 
          t1.year, 
          t1.month, 
          t1.Column1 AS day, 
          t1.Column2 AS avg_atmospheric_pressure, 
          t1.Column3 AS avg_sea_level_pressure, 
          t1.Column4 AS max_atmospheric_pressure, 
          t1.Column5 AS max_atmospheric_pressure_time, 
          t1.Column6 AS min_atmospheric_pressure, 
          t1.Column7 AS min_atmospheric_pressure_time, 
          t1.Column8 AS avg_temp, 
          t1.Column9 AS max_temp, 
          t1.Column10 AS max_temp_time, 
          t1.Column11 AS min_temp, 
          t1.Column12 AS min_temp_time, 
          t1.Column13 AS avg_dew_point_temp, 
          t1.Column14 AS avg_relative_humidity, 
          t1.Column15 AS min_relative_humidity, 
          t1.Column16 AS min_relative_humidity_time, 
          t1.Column17 AS avg_wind_speed, 
          t1.Column18 AS avg_wind_direction, 
          t1.Column19 AS max_avg_wind_speed, 
          t1.Column20 AS max_avg_wind_direction, 
          t1.Column21 AS max_avg_wind_time, 
          t1.Column22 AS accumulated_precipitation, 
          t1.Column23 AS accumulated_rain_hr, 
          t1.Column24 AS max_10min_precipitation, 
          t1.Column25 AS max_10min_precipitation_time, 
          t1.Column26 AS max_hr_precipitation, 
          t1.Column27 AS max_hr_precipitation_time, 
          t1.Column28 AS accumulated_sunshine_duration, 
          t1.Column29 AS rate_of_sunshine, 
          t1.Column30 AS global_radiation, 
          t1.Column31 AS VisbMean, 
          t1.Column32 AS evaporation_A_type_pan
      FROM WORK.ST_POOL t1
   		ORDER BY t1.station_no,
                t1.year,
				t1.month;
QUIT;

