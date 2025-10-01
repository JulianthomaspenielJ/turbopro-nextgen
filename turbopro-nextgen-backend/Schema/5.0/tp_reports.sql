

/*
Book Date
Bill Date
Closed Date
Release Date
*/

/*
DROP TABLE IF EXISTS REPORT_reports;

CREATE TABLE `REPORT_reports` (
  reportId INT  NOT NULL  AUTO_INCREMENT,
  reportType varchar(200) NOT null, -- [JOB, SALES, ..]
  reportSubType varchar(200) NOT null,
  reportName varchar(255)  NOT NULL,
  reportDescription varchar(255)  NULL,
  myReportEntityId INT NULL,  -- null if global
  myScheduleType varchar(200) NULL, -- MONDAY, FRIDAY, END_OF_MONTH
  mySortOrder INT NOT NULL DEFAULT 0,
  myEmail varchar(255),
  lastRun datetime,
  lastRunDuration varchar(200) NULL,
  reportPage varchar(255) NULL, -- page that the report should render on.
  reportHeaderIncludeIcon varchar(255) NULL, -- url of icon
  reportHeaderIncludeDate tinyint NOT NULL DEFAULT 1,
  reportHeaderIncludeFilters tinyint NOT NULL DEFAULT 0,
  reportHeaderIncludeAddress tinyint NOT NULL DEFAULT 0,
  reportGraph1Type varchar(100) NULL, -- BAR,LINE
  reportGraph1Dimension varchar(100) NULL, -- filtertype
  reportGraph1Measure varchar(100) NULL, -- Column
  reportHide TINYINT(4) NOT NULL DEFAULT 0,
  `created` datetime  NOT NULL DEFAULT now(),
  PRIMARY KEY (reportId),
  INDEX NAME_IDX(myReportEntityId))
ENGINE = InnoDB  AUTO_INCREMENT=10000;


-- STATIC REPORTS
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1000, 'JOB', 'Open Jobs', 'Open Jobs');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1001, 'JOB', 'Bill Only', 'Bill Only');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1002, 'JOB', 'Quoted Jobs', 'Quoted Jobs');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1003, 'JOB', 'Bid List', 'Bid List');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1004, 'JOB', 'Booking Profit', 'Booking Profit');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1005, 'JOB', 'Release Profit', 'Release Profit');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1006, 'JOB', 'Vendor Releases', 'Vendor Releases');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1007, 'JOB', 'Invoice Cost Detail', 'Invoice Cost Detail');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1008, 'JOB', 'Invoice Cost Summary', 'Invoice Cost Summary');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1009, 'INVENTORY', 'Inventory Received/Not Invoiced', 'Inventory Received/Not Invoiced');
insert ignore into REPORT_reports (reportId, reportType, reportSubType, reportName) values (1010, 'INVENTORY', 'Inventory Backorders', 'Inventory Backorders');
insert ignore INTO `REPORT_reports` (`reportId`, `reportType`, `reportSubType`, `reportName`, `mySortOrder`, `lastRun`, `reportHeaderIncludeDate`, `reportHeaderIncludeFilters`, `reportHeaderIncludeAddress`, `reportHide`, `created`) VALUES ('1011', 'JOB', 'Basis of Design', 'Basis of Design', '0', 'null', '1', '0', '0', '0', now());
INSERT INTO `REPORT_reports` (`reportId`,`reportType`, `reportSubType`, `reportName`, `created`) VALUES (1012,'Rolodex', 'Rolodex', 'Rolodex', '');






DROP TABLE IF EXISTS REPORT_filterTypes;

CREATE TABLE `REPORT_filterTypes` (
  reportType varchar(200) NOT null, 
  filterName varchar(255)  NOT NULL,
  filterType varchar(100)  NOT NULL, -- [MEASURE, COMBO,TEXT,DATE,CURRENCY]
  filterOrder INT NOT NULL DEFAULT 0,
  filterDependent tinyint NOT NULL DEFAULT 0,
  isMeasure tinyint NOT NULL DEFAULT 0,
  isRequired tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (reportType,filterName),
  INDEX order_idx (reportType,isMeasure,filterOrder))
ENGINE = InnoDB ;

-- JOB
delete from REPORT_filterTypes where reportType='JOB';
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Report Type','COMBO',1,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Report Name','TEXT',2,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Division','COMBO',3,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Date Type','COMBO',4,0,0,1);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Month Date Ending','DATE',5,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Design Team','COMBO',6,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Bid Status','COMBO',7,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Quote Type','COMBO',8,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Employee Assignment','COMBO',9,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Find Job Number','TEXT',10,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Vendor','COMBO',11,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Employee','COMBO',12,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Customer','COMBO',13,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Bidder','COMBO',14,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Release Type','COMBO',15,1,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Job Status','COMBO',16,1,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Sort By','COMBO',17,1,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Quote Category','COMBO',18,0,0,0);

INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Include Bidder Contact','CHECK',1,0,1,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Quote Item Cost','CHECK',2,0,1,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Quote Item Sell Price','CHECK',3,0,1,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Quote Amount','CHECK',4,0,1,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Job Estimate Cost','CHECK',5,0,1,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Job Contact Amount','CHECK',6,0,1,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('JOB','Schedule','CHECK',7,0,1,0);

-- For Quoted job Details
INSERT INTO `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Architect', 'COMBO', '27', '0', '0', '0');
INSERT INTO `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Architect Assignment', 'COMBO', '28', '0', '0', '0');
INSERT INTO `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Status Type', 'COMBO', '29', '0', '0', '0');
INSERT INTO `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Bidder Assignment', 'COMBO', '15', '0', '0', '0');
-- For Quoted job Details update statments
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '1' WHERE (`reportType` = 'JOB') and (`filterName` = 'Report Type');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '3' WHERE (`reportType` = 'JOB') and (`filterName` = 'Division');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '4' WHERE (`reportType` = 'JOB') and (`filterName` = 'Date Type');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '6' WHERE (`reportType` = 'JOB') and (`filterName` = 'Design Team');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '7' WHERE (`reportType` = 'JOB') and (`filterName` = 'Bid Status');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '8' WHERE (`reportType` = 'JOB') and (`filterName` = 'Quote Type');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '9' WHERE (`reportType` = 'JOB') and (`filterName` = 'Employee Assignment');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '11' WHERE (`reportType` = 'JOB') and (`filterName` = 'Vendor');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '12' WHERE (`reportType` = 'JOB') and (`filterName` = 'Employee');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '13' WHERE (`reportType` = 'JOB') and (`filterName` = 'Customer');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '14' WHERE (`reportType` = 'JOB') and (`filterName` = 'Bidder');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '15' WHERE (`reportType` = 'JOB') and (`filterName` = 'Bidder Assignment');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '16' WHERE (`reportType` = 'JOB') and (`filterName` = 'Release Type');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '17' WHERE (`reportType` = 'JOB') and (`filterName` = 'Job Status');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '18' WHERE (`reportType` = 'JOB') and (`filterName` = 'Sort By');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '19' WHERE (`reportType` = 'JOB') and (`filterName` = 'Quote Category');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '20' WHERE (`reportType` = 'JOB') and (`filterName` = 'Manufacturer');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '21' WHERE (`reportType` = 'JOB') and (`filterName` = 'Engineer');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '22' WHERE (`reportType` = 'JOB') and (`filterName` = 'Engineer Assignment');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '23' WHERE (`reportType` = 'JOB') and (`filterName` = 'Salesrep');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '24' WHERE (`reportType` = 'JOB') and (`filterName` = 'Costing');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '25' WHERE (`reportType` = 'JOB') and (`filterName` = 'Take-Off');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '26' WHERE (`reportType` = 'JOB') and (`filterName` = 'Quoted Jobs');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '27' WHERE (`reportType` = 'JOB') and (`filterName` = 'Architect');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '28' WHERE (`reportType` = 'JOB') and (`filterName` = 'Architect Assignment');
UPDATE  `REPORT_filterTypes` SET `filterOrder` = '29' WHERE (`reportType` = 'JOB') and (`filterName` = 'Status Type');

-- Basic of design
INSERT INTO   `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Take-Off', 'COMBO', '24', '0', '0', '0');
INSERT INTO   `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Costing', 'COMBO', '23', '0', '0', '0');
INSERT INTO   `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Salesrep', 'COMBO', '22', '0', '0', '0');
INSERT INTO   `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Engineer Assignment', 'COMBO', '21', '0', '0', '0');
INSERT INTO   `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Engineer', 'COMBO', '20', '0', '0', '0');
INSERT INTO   `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Manufacturer', 'COMBO', '19', '0', '0', '0');


-- INVENTORY
delete from REPORT_filterTypes where reportType='INVENTORY';
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('INVENTORY','Report Type','COMBO',1,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('INVENTORY','Report Name','TEXT',2,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('INVENTORY','Division','COMBO',3,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('INVENTORY','Warehouse','COMBO',4,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('INVENTORY','Month Date Ending','DATE',5,0,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('INVENTORY','Sort By','COMBO',6,1,0,0);
INSERT into REPORT_filterTypes (reportType,filterName,filterType,filterOrder,filterDependent,isMeasure,isRequired) values ('INVENTORY','Schedule','CHECK',7,0,1,0);


-- Rolodex

INSERT INTO  `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('ROLODEX', 'Report Name', 'TEXT', '1', '0', '0', '0');
INSERT INTO  `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('ROLODEX', 'Report Type', 'COMBO', '2', '0', '0', '0');
INSERT INTO  `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('ROLODEX', 'Category', 'COMBO', '3', '0', '0', '0');
INSERT INTO  `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('ROLODEX', 'Salesrep', 'COMBO', '4', '0', '0', '0');
INSERT INTO  `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('ROLODEX', 'Sort By', 'COMBO', '5', '1', '0', '0');
INSERT INTO  `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('ROLODEX', 'Include Contacts', 'CHECK', '6', '0', '0', '0');
INSERT INTO  `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('ROLODEX', 'Schedule', 'CHECK', '7', '0', '0', '0');


-- Quoted Jobs
INSERT INTO  `REPORT_filterTypes` (`reportType`, `filterName`, `filterType`, `filterOrder`, `filterDependent`, `isMeasure`, `isRequired`) VALUES ('JOB', 'Quoted Jobs', 'COMBO', '25', '0', '0', '0');

-- Quoted Job Details
INSERT INTO `REPORT_reports` (`reportId`, `reportType`, `reportSubType`, `reportName`, `reportHide`) VALUES ('1013', 'JOB', 'Quoted Job Details', 'Quoted Job Details', '0');




DROP TABLE IF EXISTS `REPORT_myFilters`;

CREATE TABLE `REPORT_myFilters` (
  myFilterId INT  NOT NULL  AUTO_INCREMENT,
  myReportId INT  NOT NULL,
  myFilterName varchar(255)  NOT NULL,
  myFilterValueId varchar(255) NULL,
  myFilterValueDateFrom date  NULL,
  myFilterValueDateTo date  NULL,
  myFilterValueText varchar(100)  NULL,
  myFilterValueCurrency decimal(19,4)  NULL,
  myIsMeasure tinyint NOT NULL DEFAULT 0,
  myIsChangable tinyint NOT NULL DEFAULT 1,
  myIsHidden tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (myFilterId),
  UNIQUE INDEX FILTER_IDX(myReportId,myFilterName))
ENGINE = InnoDB AUTO_INCREMENT=10000;


-- =====================================================================
-- Below are inserts that finetune how the filters should be set. 
-- They can override the filterTypes above.  The filterTypes are the superset
-- of filters available for the Report Type
--

-- JOB Open Jobs
delete from REPORT_myFilters where myReportId=1000;
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Report Type',0,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Month Date Ending',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Date Type',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Bidder',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Customer',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Division',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Employee',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Employee Assignment',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Find job Number',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'job Status',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Report Name',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Sort By',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Include Bidder Contact',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Quote Item Cost',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Quote Item Sell Price',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Quote Amount',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Job Estimate Cost',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1000,'Job Contact Amount',1,1);

-- JOB Bill Only
delete from REPORT_myFilters where myReportId=1001;
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Report Type',0,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Month Date Ending',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Date Type',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Bidder',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Customer',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Division',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Employee',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Employee Assignment',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Find job Number',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'job Status',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Report Name',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Sort By',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Include Bidder Contact',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Quote Item Cost',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Quote Item Sell Price',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Quote Amount',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Job Estimate Cost',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1001,'Job Contact Amount',1,1);

-- INVENTORY Inventory Backorders
delete from REPORT_myFilters where myReportId=1009;
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1010,'Report Type',0,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1010,'Month Date Ending',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1010,'Division',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1010,'Report Name',0,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1010,'Sort By',1,1);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1010,'Warehouse',1,0);


-- INVOICE COST DETAILS
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1007,'Report Type',0,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1007,'Report Name',0,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1007,'Month Date Ending',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1007,'Customer',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1007,'Employee',1,0);


-- INVOICE COST SUMMARY
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1008,'Report Type',0,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1008,'Report Name',0,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1008,'Month Date Ending',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1008,'Customer',1,0);
INSERT INTO REPORT_myFilters(myReportId,myFilterName,myIsChangable,myIsHidden) VALUES (1008,'Employee',1,0);


-- Basic of design

INSERT INTO  `REPORT_myFilters` ( `myReportId`, `myFilterName`,`myFilterValueId`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ('1011', 'Report Type','JOB', '0', '0', '0');
INSERT INTO  `REPORT_myFilters` ( `myReportId`, `myFilterName`,`myFilterValueId`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ( '1011', 'Report Name','Basic of Design', '0', '0', '0');
INSERT INTO  `REPORT_myFilters` ( `myReportId`, `myFilterName`, `myFilterValueId`,`myIsChangable`, `myIsHidden`) VALUES ( '1011', 'Month Date Ending', '3', '1', '0');
INSERT INTO  `REPORT_myFilters` ( `myReportId`, `myFilterName`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ('1011', 'Manufacturer', '0', '1', '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ('1011', 'Engineer', '0', '1', '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ('1011', 'Engineer Assignment', '0', '1', '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ('1011', 'Salesrep', '0', '1', '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ('1011', 'Costing', '0', '1', '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ('1011', 'Take-Off', '0', '1', '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ('1011', 'Job Status', '0', '1', '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsMeasure`, `myIsChangable`, `myIsHidden`) VALUES ('1011', 'Division', '0', '1', '0');


-- Rolodex

INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`,`myFilterValueId`,`myIsChangable`,`myIsHidden`) VALUES ('1012', 'Report Type','ROLODEX',0,0);
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`,`myFilterValueId`,`myIsChangable`,`myIsHidden`) VALUES ('1012', 'Report Name','ROLODEX',0,0);
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`,`myIsChangable`,`myIsHidden`) VALUES ('1012', 'Category',1,0);
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`,`myIsChangable`,`myIsHidden`) VALUES ('1012', 'Salesrep',1,0);
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`,`myFilterValueId`,`myIsChangable`,`myIsHidden`) VALUES ('1012', 'Sort By','Name',1,0);
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`,`myIsChangable`,`myIsHidden`) VALUES ('1012', 'Include Contacts',1,0);


-- Quoted Jobs


INSERT INTO `REPORT_myFilters` (`myReportId`, `myFilterName`,`myFilterValueId`, `myIsChangable`) VALUES ('1002', 'Report Name', 'Quoted Jobs' '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`,`myFilterValueId`, `myIsChangable`) VALUES ('1002', 'Report Type', 'JOB' '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`) VALUES ('1002', 'Month Date Ending');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`) VALUES ('1002', 'Quoted Job');

-- Quoted Job Details

INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myFilterValueId`, `myIsChangable`) VALUES ('1013', 'Report Type', 'JOB', '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myFilterValueId`, `myIsChangable`) VALUES ('1013', 'Report Name', 'Quoted Job Details', '0');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', ' Month Date Ending, '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Division', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Job Status', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Status Type', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Salesrep', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Architect', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Architect Assignment', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Engineer', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Engineer Assignment', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Bidder', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Bidder Assignment', '1');
INSERT INTO  `REPORT_myFilters` (`myReportId`, `myFilterName`, `myIsChangable`) VALUES ('1013', 'Quote Type', '1');






*/





-- ==============================================

-- update or create a static report (based on if reportId is null).
-- call REPORT_report('UPDATE_STATIC_REPORT',1,null,'JOB','Static A',null,null,null,null,null); 
-- call REPORT_report('UPDATE_STATIC_REPORT',1,null,'JOB','Static B',null,null,null,null,null); 

-- clone a report into a new report
-- call REPORT_report('CLONE_REPORT',1,1001,null,null,null,null,null,null,null); 

-- update or create a user report (based on if reportId is null).
-- call REPORT_report('UPDATE_MY_REPORT',1,null,'JOB','MyReport A',null,null,null,null,null); 
-- call REPORT_report('UPDATE_MY_REPORT',1,null,'JOB','MyReport B',null,null,null,null,null); 
-- call REPORT_report('UPDATE_MY_REPORT',null,1002,null,'Renamed',null,null,null,null,null); 


-- get static reports (userID is null).
-- call REPORT_report('GET_REPORTS',null,null,null,null,null,null,null,null,null); 

-- get myReports (userID is NOT null).
-- call REPORT_report('GET_REPORTS',1,null,null,null,null,null,null,null,null); 


-- call REPORT_report('RUN_REPORT',null,1000,null,null,null,null,null,null,null); 

-- ==============================================
DROP procedure IF EXISTS `REPORT_report`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `REPORT_report`(
	IN _action varchar(100),
    IN _userID INT,
    IN _reportId INT,
    IN _reportType varchar(255),
    IN _reportName varchar(255),
    IN _reportDescription varchar(255),
    IN _myScheduleType varchar(255), 
    IN _mySortOrder tinyint, 
    IN _myEmail varchar(255),
    IN _DEBUG tinyint
)
REPORT_report : BEGIN

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE _reportSequence tinyint;
DECLARE _newReportId INT;
DECLARE _scheduleMyFilterValueId tinyint;
DECLARE _reportSubType varchar(100);
DECLARE _myFilterValueId varchar(100);

DECLARE _allReportFilters varchar(5000);
DECLARE _filterName varchar(100);
DECLARE _countMyreports INT DEFAULT 0;

IF (_DEBUG=1) THEN
	select _action,_userID,_reportID,_reportType,_reportName,_mySortOrder;
END IF;


if (_action = 'UPDATE_STATIC_REPORT' ) THEN

	if (_reportId is null and _reportName is not null and _reportType is not null) THEN
	
		insert into REPORT_reports (reportType, reportName, myReportEntityId, myScheduleType, mySortOrder, myEmail)
		values (_reportType,_reportName,null,null,0,null);
    
		SELECT LAST_INSERT_ID() INTO _reportId;

		select GROUP_CONCAT(reportId) into _reports from REPORT_reports where myReportEntityId is null order by reportName;
		
        set _reportSequence=0;
        
        IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
									
			 set _aReportId=SUBSTRING_INDEX(_reports, ',', 1);
				
				update REPORT_reports set mySortOrder = _reportSequence where reportId=_aReportId;
                set _reportSequence = _reportSequence+1;
                
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
			 SET _reports = MID(_reports, SubStrLen, strLen);

			 IF _reports = '' or _reports is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
											
		END IF; 
        
    ELSEIF (_reportId is NOT null) THEN

		update REPORT_reports set reportName=_reportName where reportId = _reportId;
    
    END IF;
    
    select _reportId as reportId;
    
elseif (_action = 'UPDATE_MY_REPORT') THEN

	if (_reportId is null and _userID is not null and _reportName is not null) THEN

		select count(*)+1 into _mySortOrder from REPORT_reports where myReportEntityId=_userID;

		
		set _myScheduleType = 'NONE';
        
		insert into REPORT_reports (reportType, reportName, myReportEntityId, myScheduleType, mySortOrder, myEmail)
		values (_reportType,_reportName,_userID,_myScheduleType,_mySortOrder,_myEmail);
		
        SELECT max(reportId) INTO _reportId from REPORT_reports;
        
    ELSE

		if (_mySortOrder is not null) THEN
			select GROUP_CONCAT(reportId) into _reports from REPORT_reports where reportId=_reportId and mySortOrder >= _mySortOrder;
		END IF;
		if (_myScheduleType is null and _myEmail is null) then
		set _scheduleMyFilterValueId  = null;
		else 
		set _scheduleMyFilterValueId = 1;
		end if;
        
		update REPORT_reports set reportName=_reportName, myScheduleType=_myScheduleType, myEmail=_myEmail,mySortOrder=ifnull(_mySortOrder,mySortOrder)
        where reportId = _reportId;

		 UPDATE REPORT_myFilters set myFilterValueId = _reportName where myFilterName = 'Report Name' and myReportId = _reportId;

		 UPDATE REPORT_myFilters set myFilterValueId = _scheduleMyFilterValueId where myFilterName = 'Schedule' and myReportId = _reportId;

        set _reportSequence = _mySortOrder+1;
        
		IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
									
			 set _aReportId=SUBSTRING_INDEX(_reports, ',', 1);
				
				update REPORT_reports set mySortOrder = _reportSequence where reportId=_aReportId;
                set _reportSequence = _reportSequence+1;
                
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
			 SET _reports = MID(_reports, SubStrLen, strLen);

			 IF _reports = '' or _reports is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
											
		END IF; 
    
    END IF;
    
    select _reportId as reportId;

elseif (_action = 'UPDATE_ADD_MY_REPORT') THEN

	if (_reportId is null and _userID is not null and _reportName is not null) THEN

		select count(*)+1 into _mySortOrder from REPORT_reports where myReportEntityId=_userID;

		
		set _myScheduleType = null;
        
		insert into REPORT_reports (reportType, reportName, myReportEntityId, myScheduleType, mySortOrder, myEmail)
		values (_reportType,_reportName,_userID,_myScheduleType,_mySortOrder,_myEmail);
		
        SELECT max(reportId) INTO _reportId from REPORT_reports;
        
        
		select GROUP_CONCAT(filterName) into _allReportFilters from REPORT_filterTypes where reportType= _reportType;
        
        loopFilters: 
        LOOP
		
			SET strLen = CHAR_LENGTH(_allReportFilters);
        
			SET _filterName = SUBSTRING_INDEX(_allReportFilters, ',', 1);
            
            SET _myFilterValueId = null;
            
            if (_filterName= "Report Name") Then 
				 SET _myFilterValueId = (select reportName from REPORT_reports where reportId = _reportID);
            end if;
        
			INSERT INTO REPORT_myFilters(myFilterName,myReportId, myFilterValueId) 
				values(_filterName, _reportId, IF((_filterName = "Report Type"), _reportType, _myFilterValueId) );
        
			SET _allReportFilters = MID(_allReportFilters, CHAR_LENGTH(_filterName)+2, strLen);
						
			IF _allReportFilters = ''  Then
				leave loopFilters;
			END IF;
        END LOOP loopFilters;
        
        select * from REPORT_reports where reportId = _reportId;
        
    ELSE

		if (_mySortOrder is not null) THEN
			select GROUP_CONCAT(reportId) into _reports from REPORT_reports where reportId=_reportId and mySortOrder >= _mySortOrder;
		END IF;
        
		update REPORT_reports set reportName=_reportName, myScheduleType=_myScheduleType, myEmail=_myEmail,mySortOrder=ifnull(_mySortOrder,mySortOrder)
        where reportId = _reportId;

        set _reportSequence = _mySortOrder+1;
        
		IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
									
			 set _aReportId=SUBSTRING_INDEX(_reports, ',', 1);
				
				update REPORT_reports set mySortOrder = _reportSequence where reportId=_aReportId;
                set _reportSequence = _reportSequence+1;
                
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
			 SET _reports = MID(_reports, SubStrLen, strLen);

			 IF _reports = '' or _reports is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
											
		END IF; 
    
    END IF;
    
    select _reportId as reportId;
elseif (_action = 'CLONE_REPORT' and _reportId is not null) THEN

		select count(*)+1 into _countMyreports from REPORT_reports where myReportEntityId=_userID;
		
        select reportType,reportName into  _reportType,_reportName  from REPORT_reports where reportId = _reportId;
		set _reportSubType = _reportName;
        
		set _reportName = concat(_reportName,'_',_countMyreports);
		set _myScheduleType = null;
        
         IF (_DEBUG=1) THEN
			select _reportName, _reportType, _reportId, _userID;
		END IF;
        
		insert into REPORT_reports (reportType, reportSubType, reportName, myReportEntityId, myScheduleType, mySortOrder, myEmail)
		values (_reportType, _reportSubType, _reportName, _userID,_myScheduleType,0,null);
    
		SELECT LAST_INSERT_ID() INTO _newReportId;

		
		



		set _reportId = _newReportId;

		select _reportId as reportId;

elseif (_action = 'GET_REPORT_TYPE') THEN

	select reportType from REPORT_filterTypes group by reportType order by reportType desc;

elseif (_action = 'DELETE_REPORT') THEN

	delete from REPORT_reports where reportId =_reportID;
	call REPORT_filters('DELETE_FILTER_BY_REPORTID',_userID,_reportID,null,null,null,null,null,null,null,null,null,null);

elseif (_action = 'GET_REPORTS') THEN

	if (_userID is null) THEN
		select * from REPORT_reports where myReportEntityId is null and reportHide = 0 order by reportName;
        select * from tsUserSetting;
    else
		select * from REPORT_reports where myReportEntityId = _userID and reportHide = 0 order by mySortOrder;
        select * from tsUserSetting;
    END IF;

elseif (_action = 'GET_RUN_REPORTS') then
	select * from REPORT_reports where reportId = _reportId;
    select * from tsUserSetting;
     
elseif (_action = 'RUN_REPORT') THEN

	if (_reportId is not null) THEN

        SET @l_sql = null;

        select reportType,reportSubType into _reportType,_reportName from REPORT_reports where reportId = _reportId;

		if (_reportType='JOB') THEN
			if (locate(_reportName,'Open Jobs')>0) THEN
				set @l_sql = REPORT_build_JOB_OPEN_Query(_reportId);
			ELSEif (locate(_reportName,'Bill Only')>0) THEN
				set @l_sql = REPORT_build_JOB_Bill_Only_Query(_reportId);
                ELSEif (locate(_reportName,'Invoice Cost Detail')>0) THEN
                set @l_sql = REPORT_build_JOB_Invoice_Cost_Details(_reportId);
			elseif(locate(_reportName,'Invoice Cost Summary')>0) then
				set @l_sql = REPORT_build_JOB_InvoiceCostDetails_Summary(_reportId);
			elseif(locate(_reportName,'Basis of Design')>0) then
				set @l_sql = REPORT_build_Basis_Of_Design(_reportId);
			 elseif(locate(_reportName,'QUOTED JOBS')>0) then
			 	set @l_sql = REPORT_build_Quoted_Jobs(_reportId);
			elseif(_reportName = 'Quoted Job Details') then
			 	set @l_sql = REPORT_build_Quoted_Jobs_Details(_reportId); 
            ELSE
				set @l_sql = REPORT_build_JOB_Query(_reportId);
			END IF;
		
		elseif (_reportType='INVENTORY') THEN
        
			if (locate(_reportName,'Inventory Backorders')>0) THEN
				set @l_sql = REPORT_build_INVENTORY_backorders_Query(_reportId);
			END IF;
		
		elseif(locate(_reportName,'ROLODEX')>0) then
			set @l_sql = REPORT_Rolodex_Assigned(_reportId);
        else 
			select 'reportType not supported';
            leave REPORT_report;
        END IF;
        
		IF (@l_sql is not null) THEN

			IF (_DEBUG=1) THEN
				select @l_sql;
			END IF;
		
			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;

		END IF;

		update REPORT_reports set lastRun = now() where reportId = _reportId;
		
        
    END IF;    
    
END IF;


IF (_DEBUG=1) THEN
	select * from REPORT_reports order by myReportEntityId;
	call REPORT_filters('GET_FILTER_TYPES',_userID,_reportId,_reportType,null,null,null,null,null,null,null,null,null);
END IF;
END$$

DELIMITER ;


-- ==============================================

-- get filters and defaults for a filter.  reportId and filterType required (used for myReports)
-- call REPORT_filters('GET_FILTER_TYPES',1,1000,'JOB',null,null,null,null,null,null,null,null,null);
-- call REPORT_filters('GET_FILTER_TYPES',1,null,null,null,null,null,null,null,null,null,null,null);

-- get filtersTypes by reportType (used for new reports and static reports)
-- call REPORT_filters('GET_FILTER_TYPES',null,null,'JOB',null,null,null,null,null,null,null,null,null);
-- call REPORT_filters('GET_FILTER_TYPES',null,null,'INVENTORY',null,null,null,null,null,null,null,null,null);

-- update myfilters, reportId, filterName, values required
-- call REPORT_filters('UPDATE_MY_FILTER',1,1001,'JOB',null,'Division',1000,null,null,null,null,null,null);

-- update myfilters measures, reportId, filterName, isMeasure=1 required
-- call REPORT_filters('UPDATE_MY_FILTER',1,1001,'JOB',null,'Include Bidder Contact',1,null,null,null,null,1,null);
-- call REPORT_filters('UPDATE_MY_FILTER',1,1000,'JOB',10002,'Date Type',1,'Month To End',null,'2005-12-29 00:00:00','2015-12-29 00:00:00',null,null);

-- clear filters by reportId
-- call REPORT_filters('DELETE_FILTER_BY_REPORTID',null,1000,null,null,null,null,null,null,null,null,null,null);


-- clear filters by reportId
-- call REPORT_filters('GET_FILTER_DATA',null,null,'JOB',null,null,null,null,null,null,null,null,null);
-- call REPORT_filters('GET_FILTER_DATA',null,1000,null,null,'Quote Category',null,null,null,null,null,null,null);
-- call REPORT_filters('GET_FILTER_DATA',null,1000,'JOB',null,'Division,Job Status,Bid Status,Employee Assignment,Employee,Customer,Quote Types,Quote Category,Release Type, Sort By',null,null,null,null,null,null,1);




-- ==============================================
DROP procedure IF EXISTS `REPORT_filters`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `REPORT_filters`(
	IN _action varchar(100),
    IN _userID INT,
    IN _reportID INT,
    IN _reportType varchar(255),
    IN _filterId INT,
    IN _filterName varchar(500),
    IN _filterValueId varchar(500), 
    IN _filterValueText varchar(255),
    IN _filterCurrency decimal(19,4),
    IN _filterDateFrom date,
    IN _filterDateTo date,
    IN _isMeasure tinyint,
    IN _DEBUG tinyint
)
REPORT_report : BEGIN
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _unionAll varchar(25);
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE _myFilter_ReportName varchar(200);
DECLARE _myFilter_myFilterId int;
DECLARE _myFilter_myFilterVal varchar(200);
DECLARE _count int default 0;

IF (_DEBUG=1) THEN
	select _action,_userID,_reportID,_reportType,_isMeasure,_filterId,_filterName,_filterValueId;
END IF;

select reportSubType into @_reportSubType from REPORT_reports where reportId = _reportID;

if (_action = 'GET_FILTER_TYPES') THEN

    if (_reportID is not null) THEN
    
		select t.*,m.myFilterId, m.myReportId,ifnull(m.myIsChangable,1) as myIsChangable,ifnull(m.myIsHidden,0) as myIsHidden,
        m.myFilterValueId,m.myFilterValueDateFrom,m.myFilterValueDateTo,m.myFilterValueText,m.myFilterValueCurrency,
        ifnull(m.myIsMeasure,0) as myIsMeasure
        from REPORT_filterTypes t
        right join REPORT_myFilters m on ( t.filterName = m.myFilterName and m.myReportId = _reportID and m.myIsHidden != "1") 
		where t.reportType = _reportType
        order by t.isMeasure,t.filterOrder;
        
        
    ELSE
    
		select * from REPORT_filterTypes where reportType=_reportType order by isMeasure,filterOrder;

	END IF;

elseif (_action = 'GET_FILTER_DATA') THEN

	set @l_sql = '';
	set _unionAll = '';

	set @l_sql = concat(@l_sql, _unionAll,
	'SELECT \'Report Type\' as Filter, reportType AS id, reportType AS `value`,reportType  AS `name` FROM REPORT_filterTypes group by reportType');
	set _unionAll = ' UNION ALL ';

                
	if (_filterName is not null) THEN
		set _reports = _filterName;
    elseif (_filterName is null and _reportType is not null) THEN
		-- select GROUP_CONCAT(filterName) into _reports from REPORT_filterTypes where reportType=_reportType and isMeasure=0 and filterType in ('COMBO','RADIO');
        select GROUP_CONCAT(myFilterName) into _reports from REPORT_myFilters where myReportId=_reportID ;
	END IF;
   -- select _reports;
		IF (_DEBUG=1) THEN
			select _reports;
		END IF;

        
		IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
			 set _count=_count+1;
			 set _filterName=SUBSTRING_INDEX(_reports, ',', 1);

			IF (LOCATE('Division',_filterName)>0) THEN
		
			set @l_sql = concat(@l_sql, _unionAll,
           -- SELECT \'Division\' as Filter, 0 AS id, \'All Divisions\' AS `value`,\'All Divisions\'  AS `name` 
			-- UNION ALL
			
			'SELECT \'Division\' as Filter, coDivisionID AS id, Description AS `value`,Description  AS `name` FROM coDivision where InActive=0');
			
			set _unionAll = ' UNION ALL ';

			elseIF (LOCATE('Warehouse',_filterName)>0) THEN
-- SELECT \'Warehouse\' as Filter, 0 AS id, \'All Divisions\' AS `value`,\'All Warehouses\'  AS `name` 
				-- UNION ALL
				set @l_sql = concat(@l_sql, _unionAll,
				'SELECT \'Warehouse\' as Filter, prWarehouseID AS id, Description AS `value`,Description  AS `name` FROM prWarehouse where InActive=0');
				
				set _unionAll = ' UNION ALL ';

			elseIF (LOCATE('Design Team',_filterName)>0) THEN 

				set @l_sql = concat(@l_sql, _unionAll,'        
				select \'Design Team\' as Filter, 1 AS id, rxMasterCategory1Desc  AS `value`, rxMasterCategory1Desc AS `name` from sysInfo where length(rxMasterCategory1Desc) >1
				union all
				select \'Design Team\' as Filter, 2 AS id, rxMasterCategory2Desc  AS `value`, rxMasterCategory2Desc AS `name` from sysInfo where length(rxMasterCategory2Desc) >1
				union all
				select \'Design Team\' as Filter, 3 AS id, rxMasterCategory3Desc  AS `value`, rxMasterCategory3Desc AS `name` from sysInfo where length(rxMasterCategory3Desc) >1
				union all
				select \'Design Team\' as Filter, 4 AS id, rxMasterCategory4Desc  AS `value`, rxMasterCategory4Desc AS `name` from sysInfo where length(rxMasterCategory4Desc) >1
				union all
				select \'Design Team\' as Filter, 5 AS id, rxMasterCategory5Desc  AS `value`, rxMasterCategory5Desc AS `name` from sysInfo where length(rxMasterCategory5Desc) >1
				union all
				select \'Design Team\' as Filter, 6 AS id, rxMasterCategory6Desc  AS `value`, rxMasterCategory6Desc AS `name` from sysInfo where length(rxMasterCategory6Desc) >1
				union all
				select \'Design Team\' as Filter, 7 AS id, rxMasterCategory7Desc  AS `value`, rxMasterCategory7Desc AS `name` from sysInfo where length(rxMasterCategory7Desc) >1
				union all
				select \'Design Team\' as Filter, 8 AS id, rxMasterCategory8Desc  AS `value`, rxMasterCategory8Desc AS `name` from sysInfo where length(rxMasterCategory8Desc) >1
				');
        
				set _unionAll = ' UNION ALL ';
			elseIF (LOCATE('Date Type',_filterName)>0) THEN
			set @l_sql = concat(@l_sql, _unionAll,'        
				select \'Date Type\' as Filter, 1 AS id, \'Billed Date\'  AS `value`, \'Billed Date\' AS `name`
				union all
				select \'Date Type\' as Filter, 2 AS id, \'Book Date\'  AS `value`, \'Book Date\' AS `name`
				union all
				select \'Date Type\' as Filter, 3 AS id, \'Closed Date\'  AS `value`, \'Closed Date\' AS `name`
				union all
				select \'Date Type\' as Filter, 4 AS id, \'Release Date\'  AS `value`, \'Release Date\' AS `name`
				');
				set _unionAll = ' UNION ALL ';
			elseIF (LOCATE('job Status',_filterName)>0) THEN
				set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'job Status\' as Filter, joStatusID AS id, JobStatus AS `value`, JobStatus AS `name` FROM joStatus');
				set _unionAll = ' UNION ALL ';
				set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Job Status\' as Filter, joStatusID AS id, JobStatus AS `value`, JobStatus AS `name` FROM joStatus');
				set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Bid Status',_filterName)>0) THEN
					set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Bid Status\' as Filter, joBidStatusID AS id, Description AS `value`, Description AS `name` FROM joBidStatus where InActive=0');
					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Employee Assignment',_filterName)>0) THEN
					set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Employee Assignment\' as Filter, sysAssignmentID AS id, Title AS `value`, Title AS `name` FROM sysAssignment');
					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Employee',_filterName)>0) THEN
					set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Employee\' as Filter, UserLoginID AS id, FullName AS `value`, FullName AS `name` FROM tsUserLogin where Inactive=0 and FullName is not null');
					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Customer',_filterName)>0) THEN
					set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Customer\' as Filter,rxMasterID  AS id, Name AS `value`, Name AS `name` FROM rxMaster where length(Name)>1 and IsCustomer=1');
					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Vendor',_filterName)>0) THEN
					set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Vendor\' as Filter,veFactoryID  AS id, Description AS `value`, Description AS `name` FROM veFactory where length(Description)>1 and InActive=0');
					set _unionAll = ' UNION ALL ';
                    
            elseIF (_filterName = "Bidder Assignment") THEN
                    set @l_sql = concat(@l_sql , _unionAll , 'SELECT \'Bidder Assignment\' as Filter,  b.UserLoginID  AS id, t.FullName AS `value`, t.FullName AS `name` FROM joBidder b
					left join tsUserLogin t on b.UserLoginID = t.UserLoginID where t.FullName is not null and t.FullName <>" " 
                    and t.InActive = 0 group by b.UserLoginID having t.FullName is not null  ');
					set _unionAll = ' UNION  ALL ';
                    
				elseIF (LOCATE('Bidder',_filterName)>0) THEN
					
					set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Bidder\' as Filter,  b.rxMasterID  AS id, t.Name AS `value`, t.Name AS `name` FROM joBidder b
					left join rxMaster t on b.rxMasterID = t.rxMasterID where t.Name is not null and t.Name != ""  and t.InActive = 0 
					group by b.rxMasterID
					having t.Name is not null  ');
                    set _unionAll = ' UNION ALL ';
                    

				elseIF (LOCATE('Quote Type',_filterName)>0) THEN
					-- set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Quote Type\' as Filter, cuMasterTypeID AS id, Description AS `value`, Description AS `name` FROM cuMasterType where InActive=0');
					set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Quote Type\' as Filter, cuMasterTypeID AS id, Code AS `value`, Code AS `name` FROM cuMasterType where InActive=0');
                    set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Quote Category',_filterName)>0) THEN
					set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Quote Category\' as Filter, id AS id, description AS `value`, description AS `name` FROM joQuoteCategory ');
					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Release Type',_filterName)>0) THEN
					set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Release Type\' as Filter, joReleaseTypeID AS id, Description AS `value`, Description AS `name` FROM joReleaseType ');
					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Sort By',_filterName)>0 and _reportType != 'ROLODEX' and @_reportSubType = 'Bill Only') THEN
					-- set @l_sql = concat(@l_sql, _unionAll, 'SELECT \'Sort By\' as Filter, filterName AS id, filterName AS `value`, filterName AS `name` FROM REPORT_filterTypes where isMeasure=0 and reportType=\'',_reportType,'\'');
                    set @l_sql = concat(@l_sql, _unionAll, ' select \'Sort By\' as Filter, "Customer" AS id, "Customer" AS `value`,"Customer" AS `name`
									union all
									select \'Sort By\' as Filter, "Salesrep" AS id,"Salesrep" AS `value`,"Salesrep" AS `name` ');
					set _unionAll = ' UNION ALL ';
				
				elseIF (LOCATE('Salesrep',_filterName)>0 and _reportType != 'ROLODEX') THEN
					set @l_sql = concat(@l_sql, _unionAll, 'select \'Salesrep\' as Filter, UserLoginID AS id, FullName AS `value`, FullName AS name from tsUserLogin where Inactive=0 and Employee0 = 1');
					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Costing',_filterName)>0 and _reportType is not null) THEN
					set @l_sql = concat(@l_sql, _unionAll, 'select \'Costing\' as Filter, UserLoginID AS id, FullName AS `value`, FullName AS `name` from tsUserLogin where UserLoginID in 
					(select cuAssignmentID2 from joMaster where cuAssignmentID2 is not null and cuAssignmentID2 !=\'\' ) and Inactive=0 and FullName is not null group by value');

					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Quoted By',_filterName)>0 and _reportType is not null) THEN
					set @l_sql = concat(@l_sql, _unionAll, 'select \'Quoted By\' as Filter, UserLoginID AS id, FullName AS `value`, FullName AS `name` from tsUserLogin where UserLoginID in 
					(select cuAssignmentID6 from joMaster where cuAssignmentID6 is not null and cuAssignmentID6 !=\'\' ) and Inactive=0 and FullName is not null group by value' );
        
					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Take-Off',_filterName)>0 and _reportType is not null) THEN
					set @l_sql = concat(@l_sql, _unionAll,'select \'Take-Off\' as Filter, UserLoginID AS id, FullName AS `value`, FullName AS `name` from tsUserLogin where UserLoginID in 
					(select cuAssignmentID5 from joMaster where cuAssignmentID5 is not null and cuAssignmentID5 !=\'\' ) and Inactive=0 and FullName is not null group by value');

					set _unionAll = ' UNION ALL ';
				elseIF (_filterName = "Engineer") THEN
				   if (LOCATE('Engineer',_filterName) >0 and _reportType is not null) then
						set @l_sql = concat(@l_sql, _unionAll,'select \'Engineer\' as Filter, rxMasterId AS id, Name AS `value`, Name AS `name` 
						from rxMaster where rxMasterId in (select rxCategory2 from joMaster where rxCategory2 is not null and rxCategory2 !=0 group by rxCategory2)
						and name is not null and name != \'NONE\' and name != \'\' group by id ');
				    end if;
				elseIF (_filterName = "Architect") THEN
				   if (LOCATE('Architect',_filterName) >0 and _reportType is not null) then
						set @l_sql = concat(@l_sql, _unionAll,'select \'Architect\' as Filter, rxMasterId AS id, Name AS `value`, Name AS `name` 
						from rxMaster where rxMasterId in (select rxCategory1 from joMaster where rxCategory1 is not null and rxCategory1 !=0 group by rxCategory1)
						and name is not null and name != \'NONE\' and name != \'\' group by id ');
				    end if;                    
					set _unionAll = ' UNION ALL ';
				elseIF (LOCATE('Manufacturer',_filterName)>0 and _reportType is not null) THEN
						set @l_sql = concat(@l_sql, _unionAll, 'select * from (select \'Manufacturer\' as Filter,rxMasterID as id, CONCAT(Name, \' \',FirstName) as value, CONCAT(Name, \' \',FirstName) as name 
						from rxMaster where IsVendor=1) as tt where value is not null and value !=\'\' group by value'); 
						set _unionAll = ' UNION ALL ';
			elseIF (_filterName = "Engineer Assignment") THEN
			   if (LOCATE('Engineer Assignment',_filterName) >0 and _reportType is not null) then
					set @l_sql = concat(@l_sql, _unionAll, 'select \'Engineer Assignment\' as Filter, UserLoginID AS id, FullName AS `value`, FullName AS `name` from  tsUserLogin
					where userLoginID in (select cuAssignmentID0 from rxMasterCategory2 where cuAssignmentID0  is not null and cuAssignmentID0 !=\'\') and Inactive=0 and FullName is not null group by value');
					set _unionAll = ' UNION ALL ';
			  end if;
			elseIF (_filterName = "Architect Assignment") THEN
			    if (LOCATE('Architect Assignment',_filterName) >0 ) then
					set @l_sql = concat(@l_sql, _unionAll, 'select \'Architect Assignment\' as Filter, UserLoginID AS id, FullName AS `value`, FullName AS `name` from  tsUserLogin
					where userLoginID in (select cuAssignmentID0 from rxMasterCategory1 where cuAssignmentID0  is not null and cuAssignmentID0 !=\'\') and Inactive=0 and FullName is not null group by value');
					set _unionAll = ' UNION ALL ';
			  end if;
              
 			elseIF (_filterName = "Status Type") THEN
			    if (LOCATE('Status Type',_filterName) >0 ) then
					set @l_sql = concat(@l_sql, _unionAll, 'select \'Status Type\' as Filter, joBidStatusID AS id, Description AS `value`, Description AS `name` from  joBidStatus ');
					set _unionAll = ' UNION ALL ';
			  end if;             
        
	
			elseIF (_filterName = "Category") THEN
               if (LOCATE('Category',_filterName) >0 and _reportType is not null) then
					set @l_sql = concat(@l_sql, _unionAll, 'select * from  (select \'Category\' as Filter, 1 as id,"Customer" as `value`, "Customer" as `name`
					union all
                    select \'Category\' as Filter, 2 as id,"Vendor" as `value`, "Vendor" as `name`
					union all
					select \'Category\' as Filter, 3 as id,"Employee" as `value`, "Employee" as `name`
					union all
					SELECT \'Category\' as Filter,4 as id, rxMasterCategory1Desc as `value`, rxMasterCategory1Desc as `name` FROM sysInfo where sysInfoID=1 and rxMasterCategory1Desc is not null
					union all
					SELECT \'Category\' as Filter,5 as id,rxMasterCategory2Desc as `value`, rxMasterCategory2Desc as `name` FROM sysInfo where sysInfoID=1 and rxMasterCategory2Desc is not null
					union all
					SELECT \'Category\' as Filter,6 as id,rxMasterCategory3Desc as `value`, rxMasterCategory3Desc as `name` FROM sysInfo where sysInfoID=1 and rxMasterCategory3Desc is not null
					union all
					SELECT \'Category\' as Filter,7 as id,rxMasterCategory4Desc as `value`, rxMasterCategory4Desc as `name` FROM sysInfo where sysInfoID=1 and rxMasterCategory4Desc is not null
					union all
					SELECT \'Category\' as Filter,8 as id,rxMasterCategory5Desc as `value`, rxMasterCategory5Desc as `name` FROM sysInfo where sysInfoID=1 and rxMasterCategory5Desc is not null
					union all
					SELECT \'Category\' as Filter,9 as id,rxMasterCategory6Desc as `value`, rxMasterCategory6Desc as `name` FROM sysInfo where sysInfoID=1 and rxMasterCategory6Desc is not null
					union all
					SELECT \'Category\' as Filter,10 as id,rxMasterCategory7Desc as `value`, rxMasterCategory7Desc as `name` FROM sysInfo where sysInfoID=1 and rxMasterCategory7Desc is not null
					union all
					SELECT \'Category\' as Filter,11 as id,rxMasterCategory8Desc as `value`, rxMasterCategory8Desc as `name` FROM sysInfo where sysInfoID=1 and rxMasterCategory8Desc is not null)as a where a.value !="" ');

					set _unionAll = ' UNION ALL ';
				end if;
                


			elseIF (_filterName = "Salesrep") THEN
               if (LOCATE('Salesrep',_filterName) >0 and _reportType = 'ROLODEX') then
					set @l_sql = concat(@l_sql, _unionAll, 'select * from (select \'Salesrep\' as Filter,cuM.cuAssignmentID0 as id, ts.FullName AS `value`, ts.FullName AS `name` from cuMaster cuM left join tsUserLogin ts on ts.UserLoginID = cuM.cuAssignmentID0 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx1.cuAssignmentID0 as id, ts.FullName AS `value`, ts.FullName AS `name` from  rxMasterCategory1 rx1 left join tsUserLogin ts on ts.UserLoginID = rx1.cuAssignmentID0 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx1.cuAssignmentID1 as id, ts.FullName AS `value`, ts.FullName AS `name` from  rxMasterCategory1 rx1 left join tsUserLogin ts on ts.UserLoginID = rx1.cuAssignmentID1 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx1.cuAssignmentID2 as id, ts.FullName AS `value`, ts.FullName AS `name` from  rxMasterCategory1 rx1 left join tsUserLogin ts on ts.UserLoginID = rx1.cuAssignmentID2 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx1.cuAssignmentID3 as id, ts.FullName AS `value`, ts.FullName AS `name` from  rxMasterCategory1 rx1 left join tsUserLogin ts on ts.UserLoginID = rx1.cuAssignmentID3 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx1.cuAssignmentID4 as id, ts.FullName AS `value`, ts.FullName AS `name` from  rxMasterCategory1 rx1 left join tsUserLogin ts on ts.UserLoginID = rx1.cuAssignmentID4 where ts.Employee0=1

					union all select \'Salesrep\' as Filter,rx2.cuAssignmentID0 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory2 rx2 left join tsUserLogin ts on ts.UserLoginID = rx2.cuAssignmentID0 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx2.cuAssignmentID1 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory2 rx2 left join tsUserLogin ts on ts.UserLoginID = rx2.cuAssignmentID1 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx2.cuAssignmentID2 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory2 rx2 left join tsUserLogin ts on ts.UserLoginID = rx2.cuAssignmentID2 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx2.cuAssignmentID3 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory2 rx2 left join tsUserLogin ts on ts.UserLoginID = rx2.cuAssignmentID3 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx2.cuAssignmentID4 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory2 rx2 left join tsUserLogin ts on ts.UserLoginID = rx2.cuAssignmentID4 where ts.Employee0=1

					union all select \'Salesrep\' as Filter,rx3.cuAssignmentID0 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory4 rx3 left join tsUserLogin ts on ts.UserLoginID = rx3.cuAssignmentID0 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx3.cuAssignmentID1 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory4 rx3 left join tsUserLogin ts on ts.UserLoginID = rx3.cuAssignmentID1 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx3.cuAssignmentID2 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory4 rx3 left join tsUserLogin ts on ts.UserLoginID = rx3.cuAssignmentID2 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx3.cuAssignmentID3 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory4 rx3 left join tsUserLogin ts on ts.UserLoginID = rx3.cuAssignmentID3 where ts.Employee0=1
					union all select \'Salesrep\' as Filter,rx3.cuAssignmentID4 as id, ts.FullName AS `value`, ts.FullName AS `name` from rxMasterCategory4 rx3 left join tsUserLogin ts on ts.UserLoginID = rx3.cuAssignmentID4 where ts.Employee0=1) as a group by a.id');

					set _unionAll = ' UNION ALL ';
				end if;
			elseIF (_filterName = "Sort By") THEN
               if (LOCATE('Sort By',_filterName) >0 and _reportType = 'ROLODEX') then
					set @l_sql = concat(@l_sql, _unionAll, '
					select \'Sort By\' as Filter, "Name" as id, "Name" as `value`, "Name" as `name` 
					union all select \'Sort By\' as Filter, "Category" as id, "Category" as `value`, "Category" as `name` 
					union all select \'Sort By\' as Filter, "Salesrep" as id, "Salesrep" as `value`, "Salesrep" as `name` ');

					set _unionAll = ' UNION ALL ';
				end if;
                
				elseIF (_filterName = "Quoted Jobs") THEN
					-- select _filterName;
					set @l_sql = concat(@l_sql, _unionAll, ' 
					select \'Quoted Jobs\' as Filter, "Bid Status" as id, "Bid Status" as `value`, "Bid Status" as `name` 
					union all select \'Quoted Jobs\' as Filter, "Bidder" as id, "Bidder" as `value`, "Bidder" as `Bidder`
					union all select \'Quoted Jobs\' as Filter, "Created By" as id, "Created By" as `value`, "Created By" as `Created By` 
					union all select \'Quoted Jobs\' as Filter, "Division" as id, "Division" as `value`, "Division" as `Division`
					union all select \'Quoted Jobs\' as Filter, "Job Status" as id, "Job Status" as `value`, "Job Status" as `Job Status` 
					union all select \'Quoted Jobs\' as Filter, "Quote Type" as id, "Quote Type" as `value`, "Quote Type" as `Quote Type`
					union all select \'Quoted Jobs\' as Filter, "Take-Off Name" as id, "Take-Off Name" as `value`, "Take-Off Name" as `Take-Off Name` 
					');

					set _unionAll = ' UNION ALL ';
                    
              
              
              
              
			-- elseIF (LOCATE('Bidder Assignment',_filterName)>0) THEN


		END IF;
                
		SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
		SET _reports = MID(_reports, SubStrLen, strLen);
        -- select _reports;
		IF _reports = '' or _reports is null THEN
			LEAVE do_this;
		END IF;
	END LOOP do_this;
	-- select _count;
										
END IF; 

IF (_DEBUG=1) THEN
	select @l_sql;
END IF;
    
    
IF (length(@l_sql)>0) THEN

	set @l_sql = concat(@l_sql,' order by Filter,`name`');
	PREPARE stmt FROM @l_sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END IF;


elseif (_action = 'DELETE_FILTER_BY_REPORTID') THEN

	delete from REPORT_myFilters where  myReportId=_reportID and myIsChangable=1;

elseif (_action = 'UPDATE_MY_FILTER') THEN


	if (_filterId is not null) THEN
		
        update REPORT_myFilters set myFilterValueText=_filterValueText,myFilterValueCurrency=_filterCurrency,
        myFilterValueDateFrom=_filterDateFrom,myFilterValueDateTo=_filterDateTo,myFilterValueId=_filterValueId, myIsMeasure= ifnull(_isMeasure,0)
        where myFilterId=_filterId and myIsChangable=1;
        
        -- if(_filterName = 'Schedule') then
		-- 	update REPORT_reports set myScheduleType = null, myEmail = null where reportId=_filterId;
		-- end if;
        
	elseif (_reportID is not null and _filterName is not null) THEN
    
		delete from REPORT_myFilters where myReportId =_reportID and myFilterName=_filterName and myIsChangable=1;
        
        select reportName into _myFilter_ReportName from REPORT_reports where reportId = _reportID;
        
        if(_filterName = 'Report Name') then
			set _filterValueId = _myFilter_ReportName;
	 	end if;

		insert ignore into REPORT_myFilters(myReportId, myFilterName, myFilterValueText, myFilterValueCurrency, myFilterValueDateFrom,myFilterValueDateTo, myFilterValueId,myIsMeasure)
        values (_reportId, _filterName, _filterValueText, _filterCurrency, _filterDateFrom,_filterDateTo , _filterValueId,ifnull(_isMeasure,0));

        select * from REPORT_reports where reportId = _reportId;
        
        SELECT LAST_INSERT_ID() INTO _reportId;

	elseif (_action = "DELETE_FILTER_INCLUDE_THE_FOLLOWING") then 
		delete from REPORT_myFilters where reportID = _reportID and myFilterName = _filterName;
        
    end if;

elseif(_action = 'UPDATE_SCHEDULE_DATES') then  
	SELECT myFilterId,myFilterValueId into _myFilter_myFilterId, _myFilter_myFilterVal  FROM REPORT_myFilters
	WHERE myReportId = _reportID AND myFilterName = 'Month Date Ending';
      
 
		if(_myFilter_myFilterVal = 0 ) then
		UPDATE REPORT_myFilters SET myFilterValueDateFrom= _filterDateFrom, myFilterValueDateTo= _filterDateFrom WHERE myFilterId= _myFilter_myFilterId;
	ELSEIF(_myFilter_myFilterVal = 1) then
		UPDATE REPORT_myFilters SET myFilterValueDateTo= _filterDateFrom WHERE myFilterId= _myFilter_myFilterId;
	ELSEIF(_myFilter_myFilterVal = 2) then
		SET _filterDateFrom = (SELECT date_add(date_add(LAST_DAY(_filterDateTo),interval 1 DAY),interval -1 MONTH));
        SET _filterDateTo = (SELECT LAST_DAY(_filterDateTo));
		UPDATE REPORT_myFilters SET myFilterValueDateFrom= _filterDateFrom, myFilterValueDateTo= _filterDateTo WHERE myFilterId= _myFilter_myFilterId;
	ELSEIF(_myFilter_myFilterVal = 3) then
		SET _filterDateFrom = (SELECT MAKEDATE(year(_filterDateTo),1)) ;
         SET _filterDateTo = (SELECT LAST_DAY(_filterDateTo));
		UPDATE REPORT_myFilters SET myFilterValueDateFrom= _filterDateFrom, myFilterValueDateTo= _filterDateTo WHERE myFilterId= _myFilter_myFilterId;
	END IF;

        
	if (_reportID is not null) THEN
    select * from REPORT_reports,tsUserSetting where REPORT_reports.myReportEntityId is not null and REPORT_reports.myScheduleType is not null AND REPORT_reports.reportId = _reportID;
    end if;
END IF;
END$$

DELIMITER ;

-- ====================================
-- FUNCTION
-- ====================================

-- select REPORT_build_JOB_Query(1000);

DROP FUNCTION IF EXISTS `REPORT_build_JOB_Query`;


DELIMITER //
CREATE  FUNCTION `REPORT_build_JOB_Query`( 

 _reportId INT

) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _and varchar(25);
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _sql text;
DECLARE _filterName varchar(50);
DECLARE _myFilterValueId varchar(50);
DECLARE _myFilterValueText varchar(50);
DECLARE _myFilterValueCurrency varchar(50);

DECLARE _employeeAssignmentID int;
DECLARE _sortBy varchar(100);
DECLARE _dateTypeId int; -- booked/released/open/closed but will contain an id
DECLARE _dateTypeName varchar(100); -- monthToDateEnding
DECLARE _dateFrom Date;
DECLARE _dateTo Date;


	-- check to see if employee assignment was hit.
 		select m.myFilterValueId
        into _employeeAssignmentID
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Employee Assignment';

 		select m.myFilterValueText
        into _sortBy
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Sort By';

 		select m.myFilterValueId,myFilterValueText,myFilterValueDateFrom,myFilterValueDateTo
        into _dateTypeId,_dateTypeName,_dateFrom,_dateTo
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Date Type';

        
	set _sql = 'select ';

		-- code to handle the columns.

set _sql = concat(_sql,'WHJA_Division,  WHJA_DivisionCode, WHJA_JobNumber, WHJA_JobName, WHJA_JobStatus, WHJA_BidStatus, ');
set _sql = concat(_sql,'WHJA_QuoteCreatedBy,WHJA_Customer, ');
set _sql = concat(_sql,'WHJA_EmployeeAssigned5, WHJA_EmployeeAssigned4, WHJA_EmployeeAssigned3, ');
set _sql = concat(_sql,'WHJA_EmployeeAssigned2, WHJA_EmployeeAssigned1, WHJA_EmployeeAssigned0, ');
set _sql = concat(_sql,'WHJA_BidderName, WHJA_BidderContactName, WHJA_QuoteItemVendor,');
set _sql = concat(_sql,'WHJA_JoOwner, WHJA_BondAgent,WHJA_BidderLowBid, ');
set _sql = concat(_sql,'WHJA_Architect, WHJA_Engineer, WHJA_GeneralContractor,');
set _sql = concat(_sql,'WHJA_QuoteNumberType, WHJA_JobNumberTypeRev,WHJA_QuoteType, WHJA_QuoteItemCategory, ');
set _sql = concat(_sql,'WHJA_QuoteRevision, WHJA_QuoteItemCost, WHJA_QuoteHeaderAmount, WHJA_QuoteItemSellPrice, ');
set _sql = concat(_sql,'WHJA_JobTotalAmount_Calc, ');
set _sql = concat(_sql,'WHJA_JobProfitAmount_Calc, WHJA_ChangeOrderProfitAmount_Calc, WHJA_JobTotalProfitAmount_Calc,'); 
set _sql = concat(_sql,'WHJA_JobProfitMargin_Calc, WHJA_PercentOfQuota_Calc, WHJA_JobEstimatedCost, WHJA_JobContractAmount, ');
set _sql = concat(_sql,'WHJA_ChangeOrderCost, WHJA_ChangeOrderAmount, WHJA_Allocated, ');
set _sql = concat(_sql,'WHJA_LastActivityDate,WHJA_BidDate, WHJA_BookedDate, WHJA_ClosedDate, WHJA_ChangeOrderDate, WHJA_ReleaseDate, ');
set _sql = concat(_sql,'WHJA_BidStatusID,WHJA_cuAssignmentID0, WHJA_cuAssignmentID1, WHJA_cuAssignmentID2, WHJA_cuAssignmentID3, WHJA_cuAssignmentID4, WHJA_cuAssignmentID5, WHJA_cuAssignmentID6,');
set _sql = concat(_sql,'WHJA_coDivisionID,WHJA_CustomerID,WHJA_BidderID,WHJA_JobStatusID');

	set _sql = concat(_sql,' from WH_JobActivity where WHJA_CreatedOn is not null ');

	if (_dateTypeId is not null) THEN
    	
        -- need to write code to deal with _dateTypeName [Month To Date Ending, ...]
        -- if (_dateTypeName='Month To Date Ending) THEN
        
        if (_dateTypeId = 1) THEN
			set _sql = concat(_sql, ' AND WHJA_BidDate<=\'',ifnull(_dateTo,Date(now())),' 23:59:00\'');
        elseif (_dateTypeId = 2) THEN
			set _sql = concat(_sql, ' AND WHJA_BookedDate<=\'',ifnull(_dateTo,Date(now())),' 23:59:00\'');
        elseif (_dateTypeId = 3) THEN
			set _sql = concat(_sql, ' AND WHJA_ClosedDate<=\'',ifnull(_dateTo,Date(now())),' 23:59:00\'');
        elseif (_dateTypeId = 4) THEN
			set _sql = concat(_sql, ' AND WHJA_ReleaseDate<=\'',ifnull(_dateTo,Date(now())),' 23:59:00\'');
        END IF;
        
    END IF;    

 		select GROUP_CONCAT(myFilterId) 
        into _reports
        from REPORT_myFilters m 
        left join REPORT_filterTypes t on ( t.filterName = m.myFilterName) 
		where m.myReportId = _reportId and t.isMeasure = 0;
        
		IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
									
			 set _aReportId=SUBSTRING_INDEX(_reports, ',', 1);


 		select m.myFilterName, m.myFilterValueId,m.myFilterValueText,m.myFilterValueCurrency
        into _filterName,_myFilterValueId,_myFilterValueText,_myFilterValueCurrency
        from REPORT_myFilters m
		where m.myFilterId = _aReportId;

	IF (LOCATE('Division',_filterName)>0) THEN
        set _and = ' AND ';
		if (_myFilterValueId <> 0) THEN set _sql = concat(_sql, _and, ' WHJA_coDivisionID=',_myFilterValueId); END IF;
	-- elseIF (LOCATE('Design Team',_filterName)>0) THEN
        -- set _and = ' AND ';
		-- set _sql = concat(_sql, _and, '');
	elseIF (LOCATE('job Status',_filterName)>0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, ' WHJA_JobStatusID=',_myFilterValueId);
	elseIF (LOCATE('Bid Status',_filterName)>0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, ' WHJA_BidStatusID=',_myFilterValueId);
	elseIF (LOCATE('Employee',_filterName)>0 and LOCATE('Employee Assignment',_filterName)=0 ) THEN
        set _and = ' AND ';
        -- based on Employee Assignment, we need to figure out 0-6
		if( _employeeAssignmentID=0 ) THEN set _sql = concat(_sql, _and, 'WHJA_cuAssignmentID0 =',_myFilterValueId); 
		elseif( _employeeAssignmentID=1 ) THEN set _sql = concat(_sql, _and, 'WHJA_cuAssignmentID1 =',_myFilterValueId); 
		elseif( _employeeAssignmentID=2 ) THEN set _sql = concat(_sql, _and, 'WHJA_cuAssignmentID2 =',_myFilterValueId); 
		elseif( _employeeAssignmentID=3 ) THEN set _sql = concat(_sql, _and, 'WHJA_cuAssignmentID3 =',_myFilterValueId); 
		elseif( _employeeAssignmentID=4 ) THEN set _sql = concat(_sql, _and, 'WHJA_cuAssignmentID4 =',_myFilterValueId); 
		elseif( _employeeAssignmentID=5 ) THEN set _sql = concat(_sql, _and, 'WHJA_cuAssignmentID5 =',_myFilterValueId); 
		elseif( _employeeAssignmentID=6 ) THEN set _sql = concat(_sql, _and, 'WHJA_cuAssignmentID6 =',_myFilterValueId); 
        END IF;
        
		-- set _employeeAssignmentID = null;
    elseIF (LOCATE('Customer',_filterName)>0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'WHJA_CustomerID =',_myFilterValueId);
	elseIF (LOCATE('Bidder',_filterName)>0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'WHJA_BidderID =',_myFilterValueId);
	elseIF (LOCATE('Quote Type',_filterName)>0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'WHJA_QuoteTypeID =',_myFilterValueId);
	elseIF (LOCATE('Quote Category',_filterName)>0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'WHJA_QuoteItemCategoryID =',_myFilterValueId);
	elseIF (LOCATE('Vendor',_filterName)>0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'WHJA_VendorRxMasterID =',_myFilterValueId);
	elseIF (LOCATE('Release Type',_filterName)>0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, ' WHJA_ReleaseTypeID= ',_myFilterValueId);
	END IF;
                
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
			 SET _reports = MID(_reports, SubStrLen, strLen);

			 IF _reports = '' or _reports is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
											
		END IF; 

	IF (_sortBy is not null) THEN
    
		
		if (_myFilterValueText='Division') THEN set _sql = concat(_sql, ' order by WHJA_Division,WHJA_JobNumber' ); 
		elseif (_myFilterValueText='job Status') THEN set _sql = concat(_sql, ' order by WHJA_Division,WHJA_JobNumber' ); 
		elseif (_myFilterValueText='Bid Status') THEN set _sql = concat(_sql, ' order by WHJA_BidStatus,WHJA_JobNumber' ); 
		elseif (_myFilterValueText='Customer') THEN set _sql = concat(_sql, ' order by WHJA_Customer,WHJA_JobNumber' ); 
		elseif (_myFilterValueText='Bidder') THEN set _sql = concat(_sql, ' order by WHJA_BidderName,WHJA_JobNumber' ); 
		elseif (_myFilterValueText='Quote Type') THEN set _sql = concat(_sql, ' order by WHJA_QuoteType,WHJA_JobNumber' ); 
		elseif (_myFilterValueText='Quote Category') THEN set _sql = concat(_sql, ' order by WHJA_QuoteItemCategory,WHJA_JobNumber' ); 
		elseif (_myFilterValueText='Release Type') THEN set _sql = concat(_sql, ' order by WHJA_ReleaseType,WHJA_JobNumber' ); 
		elseif (_myFilterValueText='Vendor') THEN set _sql = concat(_sql, ' order by WHJA_VendorName,WHJA_JobNumber' ); 
		elseif (_myFilterValueText='Employee') THEN
        
			if( _employeeAssignmentID=0 ) THEN set _sql = concat(_sql, ' order by WHJA_EmployeeAssigned0,WHJA_JobNumber'); 
			elseif( _employeeAssignmentID=1 ) THEN set _sql = concat(_sql, ' order by WHJA_EmployeeAssigned1,WHJA_JobNumber'); 
			elseif( _employeeAssignmentID=2 ) THEN set _sql = concat(_sql, ' order by WHJA_EmployeeAssigned2,WHJA_JobNumber');  
			elseif( _employeeAssignmentID=3 ) THEN set _sql = concat(_sql, ' order by WHJA_EmployeeAssigned3,WHJA_JobNumber'); 
			elseif( _employeeAssignmentID=4 ) THEN set _sql = concat(_sql, ' order by WHJA_EmployeeAssigned4,WHJA_JobNumber');  
			elseif( _employeeAssignmentID=5 ) THEN set _sql = concat(_sql, ' order by WHJA_EmployeeAssigned5,WHJA_JobNumber ');  
			-- elseif( _employeeAssignmentID=6 ) THEN set _sql = concat(_sql, ' order by WHJA_EmployeeAssigned0'); 
            END IF;
        
        else

        set _sql = concat(_sql, ' order by WHJA_JobNumber ');
                
        END IF;
        
	ELSE

        set _sql = concat(_sql, ' order by WHJA_JobNumber ');
        
	END IF;


	set _sql = concat(_sql, ';');

RETURN _sql;
END //
DELIMITER ;


-- ==================================================================================
-- select REPORT_build_JOB_OPEN_Query(1000);

-- select * from REPORT_myFilters where myReportId=1000;

-- select REPORT_build_JOB_OPEN_Query(1000);

DROP FUNCTION IF EXISTS `REPORT_build_JOB_OPEN_Query`;

DELIMITER //
CREATE  FUNCTION `REPORT_build_JOB_OPEN_Query`( 

 _reportId INT

) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _and varchar(25);
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _sql text;
DECLARE _filterName varchar(50);
DECLARE _myFilterValueId varchar(50);
DECLARE _myFilterValueText varchar(50);
DECLARE _myFilterValueCurrency varchar(50);

DECLARE _employeeAssignmentID int;
DECLARE _sortBy varchar(100);
DECLARE _dateTypeId int; -- booked/released/open/closed but will contain an id
DECLARE _dateTypeName varchar(100); -- monthToDateEnding
DECLARE _dateFrom Date;
DECLARE _dateTo Date;
DECLARE _report_JobNumber VARCHAR(100);

/*
	-- check to see if employee assignment was hit.
 		select m.myFilterValueId,m.myFilterName
        into _employee,_filterName
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Employee';

 		select m.myFilterValueText,m.myFilterName
        into _sortBy
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Sort By';

 		select m.myFilterValueId,myFilterValueText,myFilterValueDateFrom,myFilterValueDateTo
        into _dateTypeId,_dateTypeName,_dateFrom,_dateTo
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Date Type';
        
        select myFilterValueId into _report_JobNumber from REPORT_myFilters where myFilterName = 'Find Job Number'
        and myReportId = _reportId;
        */

SET _sql = "SELECT RXM.Name AS 100_Customer,JOM.Description AS 173_Project,JOM.JobNumber as `90_Job #`,TSU.Initials AS REP,
						(IFNULL(JOM.ContractAmount,0.0000)+IFNULL((SELECT SUM(IFNULL(ChangeAmount,0.0000)) FROM joChange WHERE joMasterID = JOM.joMasterID),0.0000))AS `Rev Booking`, 
						IFNULL(I.SumSubTotal,0.0000) AS Invoiced,(IFNULL((IFNULL(JOM.ContractAmount,0.0000)+(IFNULL((SELECT SUM(IFNULL(ChangeAmount,0.0000)) FROM joChange WHERE joMasterID = JOM.joMasterID),0.0000)) - 
						IFNULL((I.SumSubTotal),0.0000)),0.0000) - IFNULL(((IFNULL(JOM.ContractAmount,0.0000)+IFNULL((SELECT SUM(IFNULL(ChangeAmount,0.0000)) FROM joChange WHERE joMasterID = JOM.joMasterID),0.0000)) - 
						IFNULL(R.SumREstimatedBilling,0.0000)),0.0000)) AS  UnInvoiced, IFNULL(((IFNULL(JOM.ContractAmount,0.0000)+IFNULL((SELECT SUM(IFNULL(ChangeAmount,0.0000)) 
						FROM joChange WHERE joMasterID = JOM.joMasterID),0.0000)) - IFNULL(R.SumREstimatedBilling,0.0000)),0.0000) AS `UnReleased`, 
						IFNULL(((IFNULL(I.SumInvoiceAmount,0.0000)-IFNULL(I.SumTaxAmount,0.0000))-(IFNULL(VB.SumVBBillAmount,0.0000)-
						IFNULL(VB.SumVBTaxamount,0.0000))-(IFNULL(P.SumCusoCostTotal,0.0000))),0.0000) AS Profit, " ;
set _sql = concat(_sql, "date_format(JOM.ChangedOn, '%m/%d/%Y') AS Changed FROM joMaster AS JOM ");
						
set _sql = concat(_sql, "LEFT JOIN tsUserLogin TSU ON TSU.UserLoginID=JOM.cuAssignmentID0 
						LEFT JOIN (SELECT joMaster.joMasterID,SUM(IFNULL(joRelease.EstimatedBilling,0.0000)) AS SumREstimatedBilling FROM joMaster 
						RIGHT JOIN joRelease ON joMaster.joMasterID = joRelease.joMasterID  WHERE (joMaster.JobStatus=3)  GROUP BY joMaster.joMasterID) AS R ON JOM.joMasterID = R.joMasterID 
						LEFT JOIN (SELECT joMaster.joMasterID, 
						SUM(IFNULL(cuInvoice.InvoiceAmount,0.0000)) AS SumInvoiceAmount, SUM(IFNULL(cuInvoice.Subtotal,0.0000)) AS SumSubTotal, 
						SUM(IFNULL(cuInvoice.Freight,0.0000)) AS SumFreight, SUM(IFNULL(cuInvoice.TaxAmount,0.0000)) AS SumTaxAmount, 
						SUM(IFNULL(cuInvoice.AppliedAmount,0.0000)) AS SumAppliedAmount, SUM(IFNULL(cuInvoice.DiscountAmt,0.0000)) AS SumDiscountAmt 
						FROM joMaster RIGHT JOIN (joReleaseDetail RIGHT JOIN cuInvoice ON joReleaseDetail.joReleaseDetailID = cuInvoice.joReleaseDetailID) ON joMaster.joMasterID = joReleaseDetail.joMasterID WHERE (joMaster.JobStatus=3  AND cuInvoice.TransactionStatus>0) GROUP BY joMaster.joMasterID) AS I ON JOM.joMasterID = I.joMasterID 
						LEFT JOIN (SELECT joMaster.joMasterID, SUM(IFNULL(veBill.BillAmount,0.0000)) AS SumVBBillAmount,SUM(IFNULL(veBill.TaxAmount,0.0000)) AS SumVBTaxamount, 
						SUM(IFNULL(veBill.AdditionalFreight,0.0000)) AS SumVBAdditional,IFNULL(veBill.TransactionStatus,0) AS vBTransactionStatus FROM joMaster 
						RIGHT JOIN (joReleaseDetail RIGHT JOIN veBill ON joReleaseDetail.joReleaseDetailID = veBill.joReleaseDetailID) 
						ON joMaster.joMasterID = joReleaseDetail.joMasterID WHERE (joMaster.JobStatus=3 AND veBill.TransactionStatus>0) 
						GROUP BY joMaster.joMasterID) AS VB ON JOM.joMasterID = VB.joMasterID LEFT JOIN (SELECT joMaster.joMasterID, SUM(IFNULL(vePO.Subtotal,0.0000)) AS SumVepoSubtotal, SUM(IFNULL(vePO.TaxTotal,0.0000)) AS SumVepoTaxTotal, 
						SUM(IFNULL(vePO.Freight,0.0000)) AS SumVepoFreight FROM joMaster RIGHT JOIN (joRelease RIGHT JOIN vePO ON joRelease.joReleaseID = vePO.joReleaseID) ON joMaster.joMasterID = joRelease.joMasterID WHERE (joMaster.JobStatus=3)GROUP BY joMaster.joMasterID) AS VP ON 
						JOM.joMasterID = VP.joMasterID LEFT JOIN (SELECT joMaster.joMasterID, SUM(IFNULL(cuSO.CostTotal,0.0000)) AS SumCusoCostTotal FROM joMaster RIGHT JOIN (joReleaseDetail RIGHT JOIN cuSO ON joReleaseDetail.joReleaseID = cuSO.joReleaseID) ON joMaster.joMasterID = joReleaseDetail.joMasterID WHERE (joMaster.JobStatus=3) 
						GROUP BY joMaster.joMasterID) AS P ON JOM.joMasterID = P.joMasterID LEFT JOIN rxMaster RXM ON JOM.rxCustomerID = RXM.rxMasterID WHERE JOM.JobStatus=3 ");
                        
  		select GROUP_CONCAT(myFilterId) 
        into _reports
        from REPORT_myFilters m 
        left join REPORT_filterTypes t on ( t.filterName = m.myFilterName) 
		where m.myReportId = _reportId and t.isMeasure = 0;
        
                        
                        
			IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
									
			 set _aReportId=SUBSTRING_INDEX(_reports, ',', 1);


 		select m.myFilterName, ifnull(m.myFilterValueId,-1),ifnull(m.myFilterValueText,-1),ifnull(m.myFilterValueCurrency,-1)
        into _filterName,_myFilterValueId,_myFilterValueText,_myFilterValueCurrency
        from REPORT_myFilters m
		where m.myFilterId = _aReportId;


	-- IF (LOCATE('Employee',_filterName)>0 and LOCATE('Employee Assignment',_filterName)=0 and _myFilterValueId > 0 ) THEN
    IF (LOCATE('Employee',_filterName)>0 and _myFilterValueId > 0 ) THEN
        set _and = ' AND ';
        -- based on Employee Assignment, we need to figure out 0-6
		set _sql = concat(_sql, _and, ' TSU.UserLoginID =',_myFilterValueId); 
        
		-- set _employeeAssignmentID = null;

    elseIF (LOCATE('Customer',_filterName)>0 and _myFilterValueId > 0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'RXM.rxMasterID =',_myFilterValueId);
 
	end if;
   
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
			 SET _reports = MID(_reports, SubStrLen, strLen);

			 IF _reports = '' or _reports is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
											
		END IF; 



set _sql = concat(_sql,' GROUP BY JOM.joMasterID  ORDER BY RXM.Name, JOM.JobNumber');

	set _sql = concat(_sql, ';');
/*
				if (employeeID is null and customerID is null) then
					set _sql=concat(_sql," GROUP BY JOM.joMasterID ORDER BY RXM.Name, JOM.JobNumber");
				elseif (employeeID = null && customerID is not null) then
					set _sql=concat(_sql," AND JOM.rxCustomerID=", customerID);
					set _sql=concat(_sql," GROUP BY JOM.joMasterID ORDER BY RXM.Name, JOM.JobNumber");

				elseif (customerID = null && employeeID is not null) then
					set _sql=concat(_sql," AND TSU.UserLoginID =", employeeID);
					set _sql=concat(_sql," GROUP BY JOM.joMasterID ORDER BY RXM.Name, JOM.JobNumber");
				else 
					set _sql=concat(_sql," AND JOM.rxCustomerID=", customerID);
					set _sql=concat(_sql," AND TSU.UserLoginID =", employeeID);
					set _sql=concat(_sql," GROUP BY JOM.joMasterID ORDER BY RXM.Name, JOM.JobNumber");
				
			   end if;
               */		
RETURN _sql;
END //
DELIMITER ;

/*
DELIMITER //
CREATE  FUNCTION `REPORT_build_JOB_OPEN_Query`( 

 _reportId INT

) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _and varchar(25);
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _sql text;
DECLARE _filterName varchar(50);
DECLARE _myFilterValueId varchar(50);
DECLARE _myFilterValueText varchar(50);
DECLARE _myFilterValueCurrency varchar(50);

DECLARE _employeeAssignmentID int;
DECLARE _sortBy varchar(100);
DECLARE _dateTypeId int; -- booked/released/open/closed but will contain an id
DECLARE _dateTypeName varchar(100); -- monthToDateEnding
DECLARE _dateFrom Date;
DECLARE _dateTo Date;
DECLARE _report_JobNumber VARCHAR(100);


	-- check to see if employee assignment was hit.
 		select m.myFilterValueId
        into _employeeAssignmentID
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Employee Assignment';

 		select m.myFilterValueText
        into _sortBy
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Sort By';

 		select m.myFilterValueId,myFilterValueText,myFilterValueDateFrom,myFilterValueDateTo
        into _dateTypeId,_dateTypeName,_dateFrom,_dateTo
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Date Type';
        
        select myFilterValueId into _report_JobNumber from REPORT_myFilters where myFilterName = 'Find Job Number'
        and myReportId = _reportId;



set _sql = 'SELECT RXM.Name AS 100_Customer,';

set _sql = concat(_sql,'JOM.Description AS 173_Project, ');
set _sql = concat(_sql,'JOM.JobNumber AS `90_Job #`, ');
set _sql = concat(_sql,'TSU.Initials AS REP, ');
set _sql = concat(_sql,'(IFNULL(JOM.ContractAmount,0.0000)+IFNULL((SELECT SUM(IFNULL(ChangeAmount,0.0000)) FROM joChange WHERE joMasterID = JOM.joMasterID),0.0000)) AS `Rev Booking`, ');
set _sql = concat(_sql,'IFNULL((I.SumSubTotal+I.SumFreight),0.0000) AS Invoiced, ');
set _sql = concat(_sql,'(IFNULL((IFNULL(JOM.ContractAmount,0.0000)+(IFNULL((SELECT SUM(IFNULL(ChangeAmount,0.0000)) FROM joChange WHERE joMasterID = JOM.joMasterID),0.0000)) - IFNULL((I.SumSubTotal+I.SumFreight),0.0000)),0.0000) - ');
set _sql = concat(_sql,'IFNULL(((IFNULL(JOM.ContractAmount,0.0000)+IFNULL((SELECT SUM(IFNULL(ChangeAmount,0.0000)) FROM joChange WHERE joMasterID = JOM.joMasterID),0.0000)) - R.SumREstimatedBilling),0.0000)) AS  UnInvoiced, ');
set _sql = concat(_sql,'IFNULL(((IFNULL(JOM.ContractAmount,0.0000)+IFNULL((SELECT SUM(IFNULL(ChangeAmount,0.0000)) FROM joChange WHERE joMasterID = JOM.joMasterID),0.0000)) - R.SumREstimatedBilling),0.0000) AS UnReleased, ');
set _sql = concat(_sql,'IFNULL(((I.SumSubTotal)-(VB.SumVBBillAmount+VB.SumVBTaxamount)),0.0000) AS Profit, ');
-- set _sql = concat(_sql,'IFNULL(IF((IFNULL(JOM.EstimatedProfit,0.0000)-IFNULL(JOM.ActualProfitToDate,0.0000))<0.0000,0.0000,(IFNULL(JOM.EstimatedProfit,0.0000)-IFNULL(JOM.ActualProfitToDate,0.0000))),0.0000) AS EstimatedProfit, ');
set _sql = concat(_sql,'date_format(JOM.ChangedOn, "%m/%d/%Y") AS Changed ');
-- set _sql = concat(_sql,'IFNULL((SELECT SUM(IFNULL(ChangeAmount,0.0000)) FROM joChange WHERE joMasterID = JOM.joMasterID),0.0000) AS Changes, ');
-- set _sql = concat(_sql,'IFNULL(JOM.ContractAmount,0.0000) AS ContractAmount ');
set _sql = concat(_sql,'FROM joMaster AS JOM  ');
set _sql = concat(_sql,'LEFT JOIN tsUserLogin TSU ON TSU.UserLoginID=JOM.cuAssignmentID0  ');
set _sql = concat(_sql,'LEFT JOIN  ');
set _sql = concat(_sql,'(SELECT joMaster.joMasterID,SUM(IFNULL(joRelease.EstimatedBilling,0.0000)) AS SumREstimatedBilling FROM joMaster RIGHT JOIN joRelease ON joMaster.joMasterID = joRelease.joMasterID  WHERE (joMaster.JobStatus=3)  GROUP BY joMaster.joMasterID) AS R ON JOM.joMasterID = R.joMasterID  ');
set _sql = concat(_sql,'LEFT JOIN  ');
set _sql = concat(_sql,'(SELECT joMaster.joMasterID, SUM(IFNULL(cuInvoice.InvoiceAmount,0.0000)) AS SumInvoiceAmount, SUM(IFNULL(cuInvoice.Subtotal,0.0000)) AS SumSubTotal, SUM(IFNULL(cuInvoice.Freight,0.0000)) AS SumFreight, SUM(IFNULL(cuInvoice.TaxAmount,0.0000)) AS SumTaxAmount, SUM(IFNULL(cuInvoice.AppliedAmount,0.0000)) AS SumAppliedAmount, SUM(IFNULL(cuInvoice.DiscountAmt,0.0000)) AS SumDiscountAmt FROM joMaster RIGHT JOIN (joReleaseDetail RIGHT JOIN cuInvoice ON joReleaseDetail.joReleaseDetailID = cuInvoice.joReleaseDetailID) ON joMaster.joMasterID = joReleaseDetail.joMasterID WHERE (joMaster.JobStatus=3  AND cuInvoice.TransactionStatus>0) GROUP BY joMaster.joMasterID) AS I ON JOM.joMasterID = I.joMasterID  ');
set _sql = concat(_sql,'LEFT JOIN  ');
set _sql = concat(_sql,'(SELECT joMaster.joMasterID, SUM(IFNULL(veBill.BillAmount,0.0000)) AS SumVBBillAmount,SUM(IFNULL(veBill.TaxAmount,0.0000)) AS SumVBTaxamount, SUM(IFNULL(veBill.AdditionalFreight,0.0000)) AS SumVBAdditional,IFNULL(veBill.TransactionStatus,0) AS vBTransactionStatus FROM joMaster RIGHT JOIN (joReleaseDetail RIGHT JOIN veBill ON joReleaseDetail.joReleaseDetailID = veBill.joReleaseDetailID) ON joMaster.joMasterID = joReleaseDetail.joMasterID WHERE (joMaster.JobStatus=3 AND veBill.TransactionStatus>0) GROUP BY joMaster.joMasterID) AS VB ON JOM.joMasterID = VB.joMasterID  ');
set _sql = concat(_sql,'LEFT JOIN  ');
set _sql = concat(_sql,'(SELECT joMaster.joMasterID, SUM(IFNULL(vePO.Subtotal,0.0000)) AS SumVepoSubtotal, SUM(IFNULL(vePO.TaxTotal,0.0000)) AS SumVepoTaxTotal, SUM(IFNULL(vePO.Freight,0.0000)) AS SumVepoFreight FROM joMaster RIGHT JOIN (joRelease RIGHT JOIN vePO ON joRelease.joReleaseID = vePO.joReleaseID) ON joMaster.joMasterID = joRelease.joMasterID WHERE (joMaster.JobStatus=3)GROUP BY joMaster.joMasterID) AS VP ON JOM.joMasterID = VP.joMasterID LEFT JOIN (SELECT joMaster.joMasterID, SUM(IFNULL(cuSO.CostTotal,0.0000)) AS SumCusoCostTotal FROM joMaster RIGHT JOIN (joRelease RIGHT JOIN cuSO ON joRelease.joReleaseID = cuSO.joReleaseID) ON joMaster.joMasterID = joRelease.joMasterID WHERE (joMaster.JobStatus=3) GROUP BY joMaster.joMasterID) AS P ON JOM.joMasterID = P.joMasterID '); 
set _sql = concat(_sql,'LEFT JOIN rxMaster RXM ON JOM.rxCustomerID = RXM.rxMasterID  ');

set _sql = concat(_sql,'WHERE JOM.JobStatus=3 ');
if(_report_JobNumber is not null) then 
	set _sql = concat(_sql,' and JOM.JobNumber = \'', _report_JobNumber, '\'');  
end if;


-- RXM.rxMasterID -- customer
-- TSU.UserLoginID -- cuAssignmentID0

 		select GROUP_CONCAT(myFilterId) 
        into _reports
        from REPORT_myFilters m 
        left join REPORT_filterTypes t on ( t.filterName = m.myFilterName) 
		where m.myReportId = _reportId and t.isMeasure = 0;
        
		IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
									
			 set _aReportId=SUBSTRING_INDEX(_reports, ',', 1);


 		select m.myFilterName, ifnull(m.myFilterValueId,-1),ifnull(m.myFilterValueText,-1),ifnull(m.myFilterValueCurrency,-1)
        into _filterName,_myFilterValueId,_myFilterValueText,_myFilterValueCurrency
        from REPORT_myFilters m
		where m.myFilterId = _aReportId;


	IF (LOCATE('Employee',_filterName)>0 and LOCATE('Employee Assignment',_filterName)=0 and _myFilterValueId > 0 ) THEN
        set _and = ' AND ';
        -- based on Employee Assignment, we need to figure out 0-6
		set _sql = concat(_sql, _and, ' TSU.UserLoginID =',_myFilterValueId); 
        
		-- set _employeeAssignmentID = null;

    elseIF (LOCATE('Customer',_filterName)>0 and _myFilterValueId > 0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'RXM.rxMasterID =',_myFilterValueId);
 
	end if;
   
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
			 SET _reports = MID(_reports, SubStrLen, strLen);

			 IF _reports = '' or _reports is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
											
		END IF; 



set _sql = concat(_sql,' GROUP BY JOM.joMasterID  ORDER BY RXM.Name, JOM.JobNumber');

	set _sql = concat(_sql, ';');

RETURN _sql;
END //
DELIMITER ;
*/

-- ==================================================================================
-- select REPORT_build_JOB_Bill_Only_Query(1001);

-- select * from REPORT_build_JOB_Bill_Only_Query where myReportId=1001;

-- select REPORT_build_JOB_Bill_Only_Query(1001);

DROP FUNCTION IF EXISTS `REPORT_build_JOB_Bill_Only_Query`;


DELIMITER //
CREATE DEFINER=`root`@`%` FUNCTION `REPORT_build_JOB_Bill_Only_Query`( 

 _reportId INT

) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _and varchar(25);
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _sql text;
DECLARE _filterName varchar(50);
DECLARE _myFilterValueId varchar(50);
DECLARE _myFilterValueText varchar(50);
DECLARE _myFilterValueCurrency varchar(50);

DECLARE _employee int;
DECLARE _sortBy varchar(100);
DECLARE _dateTypeId int; 
DECLARE _dateTypeName varchar(100); 
DECLARE _dateFrom Date;
DECLARE _dateTo Date;
DECLARE _report_JobNumber VARCHAR(100);


	
 		select m.myFilterValueText
        into _employee
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Employee';

 		select m.myFilterValueId
        into _sortBy
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Sort By';

 		select m.myFilterValueId,myFilterValueText,myFilterValueDateFrom,IFNULL(myFilterValueDateTo,Date(now()))
        into _dateTypeId,_dateTypeName,_dateFrom,_dateTo
        from REPORT_myFilters m
		where m.myReportId = _reportId and 
        m.myFilterName='Month Date Ending' or m.myFilterName='Year Date Ending' or m.myFilterName='Date Range' or m.myFilterName='Single Date'; 
	
        select myFilterValueId into _report_JobNumber from REPORT_myFilters where myFilterName = 'Find Job Number'
        and myReportId = _reportId;
        
        set _sql = 'SELECT ';

	IF (_sortBy = 'Customer') THEN
		set _sql = concat(_sql,' rx.Name AS Customer,  date_format(ReleaseDate, "%m/%d/%Y") as ReleaseDate, '); 
        set _sql = concat(_sql,'log1.FullName AS "Sales rep", ');

    ELSEIF (_sortBy = 'Date Type') THEN
		set _sql = concat(_sql,' date_format(ReleaseDate, "%m/%d/%Y") as ReleaseDate, rx.Name AS Customer, '); 
		set _sql = concat(_sql,'log1.FullName AS "Sales rep", ');
    ELSEIF (_sortBy = 'Salesrep') THEN
		set _sql = concat(_sql,'log1.FullName AS "Sales rep", rx.Name AS Customer, ');
        set _sql = concat(_sql,'date_format(ReleaseDate, "%m/%d/%Y") as ReleaseDate, ');   
	ELSE 
		set _sql = concat(_sql,' rx.Name AS Customer,  date_format(ReleaseDate, "%m/%d/%Y") as ReleaseDate, '); 
        set _sql = concat(_sql,'log1.FullName AS "Sales rep", ');
    END IF;
    
		set _sql = concat(_sql,' jo.Description as Description, concat(jo.JobNumber, UPPER(INTTOLETTER(jr.seq_Number))) AS "Release Number",  ');
        set _sql = concat(_sql,' EstimatedBilling As "Estimated Billing", ');
		set _sql = concat(_sql,'(IFNULL((EstimatedBilling),0) - IFNULL(SUM(ci.Subtotal),0)) BalanceAmount ');
    
	
set _sql = concat(_sql,'FROM ');
set _sql = concat(_sql,'    joRelease jr ');
set _sql = concat(_sql,'	LEFT JOIN joMaster jo ON jo.joMasterID = jr.joMasterID ');
if(_report_JobNumber is not null) then 
	set _sql = concat(_sql,' and JOM.JobNumber = \'', _report_JobNumber, '\'');  
end if;
set _sql = concat(_sql,'	LEFT JOIN rxMaster rx ON (rx.rxMasterID = jo.rxCustomerID) ');
set _sql = concat(_sql,'	LEFT JOIN tsUserLogin log1 ON (jo.cuAssignmentID0 = log1.UserLoginID) ');
set _sql = concat(_sql,'    LEFT JOIN joReleaseDetail jrDe ON (jrDe.joReleaseID = jr.joReleaseID) ');
set _sql = concat(_sql,'	LEFT JOIN  cuInvoice ci ON (ci.joReleaseDetailID = jrDe.joReleaseDetailID)'); 

set _sql = concat(_sql,'WHERE ReleaseType = 3 and ci.cuInvoiceID is  null  and jo.JobStatus <> 4 and EstimatedBilling > 0 ');

set _sql = concat(_sql,' ');



 		select GROUP_CONCAT(myFilterId) 
        into _reports
        from REPORT_myFilters m 
        left join REPORT_filterTypes t on ( t.filterName = m.myFilterName) 
		where m.myReportId = _reportId and t.isMeasure = 0;
        
		IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
									
			 set _aReportId=SUBSTRING_INDEX(_reports, ',', 1);


 		select m.myFilterName, ifnull(m.myFilterValueId,-1),ifnull(m.myFilterValueText,-1),ifnull(m.myFilterValueCurrency,-1)
        into _filterName,_myFilterValueId,_myFilterValueText,_myFilterValueCurrency
        from REPORT_myFilters m
		where m.myFilterId = _aReportId;


	IF (LOCATE('Employee',_filterName)>0 and LOCATE('Employee Assignment',_filterName)=0 and _myFilterValueId > 0 ) THEN

        set _and = ' AND ';
		set _sql = concat(_sql, _and, '	jo.cuAssignmentID0 = ',_myFilterValueId );

		
    elseIF (LOCATE('Customer',_filterName)>0 and _myFilterValueId > 0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, '  jo.rxCustomerID = ',_myFilterValueId);
    
		
	end if;
 
 
 
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
			 SET _reports = MID(_reports, SubStrLen, strLen);

			 IF _reports = '' or _reports is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
											
		END IF; 
        
      set _and = ' AND ';
		if (_dateFrom is not null and _dateTo is not null) THEN 
         set _and = ' AND ';
			set _sql = concat(_sql, _and, '	(Date(jr.ReleaseDate) >= \'',_dateFrom,'\') ');
			set _sql = concat(_sql, _and, '	(Date(jr.ReleaseDate) <= \'',_dateTo,'\') ');
		ELSEif (_dateFrom is not null ) THEN 
         set _and = ' AND ';
			set _sql = concat(_sql, _and, '	(Date(jr.ReleaseDate) = \'',_dateFrom,'\') ');
		else
         set _and = ' AND '; 
			set _sql = concat(_sql, _and, '	(Date(jr.ReleaseDate) <= \'',_dateTo,'\') '); 
        END IF;
/*        
        set _sql = concat(_sql, _and, 'CASE');
		set _sql = concat(_sql, _and, 'WHEN ( \'',_dateFrom,'\' IS NOT NULL AND \'',_dateFrom,'\' != '') AND (', _dateTo,'\' IS NOT NULL AND', _dateTo ,'\' != '') THEN ');
		set _sql = concat(_sql, _and, '	(Date(jr.ReleaseDate) >= \'',_dateFrom,'\') AND ');
		set _sql = concat(_sql, _and, '	(Date(jr.ReleaseDate) <= \'',_dateTo,'\'}) ');
		set _sql = concat(_sql, _and, ' ELSE (Date(jr.ReleaseDate) = \'',_dateFrom,'\') END '); 
*/

set _sql = concat(_sql, ' GROUP BY jr.joReleaseID having BalanceAmount != 0  ORDER BY');

	IF (_sortBy = 'Customer') THEN
		set _sql = concat(_sql, ' Customer ASC');    
    ELSEIF (_sortBy = 'Date Type') THEN
		set _sql = concat(_sql, ' ReleaseDate ASC');    
    ELSEIF (_sortBy = 'Salesrep') THEN
		set _sql = concat(_sql, ' log1.FullName ASC');    
    ELSE
		set _sql = concat(_sql, ' ReleaseDate ASC');    
    END IF;
    
	set _sql = concat(_sql, ';');

RETURN _sql;
END //
DELIMITER ;


-- ==================================================================================
-- select REPORT_build_INVENTORY_backorders_Query(1010);

-- select * from REPORT_build_INVENTORY_backorders_Query where myReportId=1010;

-- select REPORT_build_INVENTORY_backorders_Query(1010);

DROP FUNCTION IF EXISTS `REPORT_build_INVENTORY_backorders_Query`;


DELIMITER //
CREATE  FUNCTION `REPORT_build_INVENTORY_backorders_Query`( 

 _reportId INT

) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _and varchar(25);
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _sql text;
DECLARE _filterName varchar(50);
DECLARE _myFilterValueId varchar(50);
DECLARE _myFilterValueText varchar(50);
DECLARE _myFilterValueCurrency varchar(50);
DECLARE _myFilterDateFrom Date;
DECLARE _myFilterDateTo Date;

DECLARE _employeeAssignmentID int;
DECLARE _sortBy varchar(100);
DECLARE _dateTypeId int;
DECLARE _dateTypeName varchar(100);
DECLARE _dateFrom Date;
DECLARE _dateTo Date;


SET _sql = 'SELECT ';



SET _sql = concat(_sql,' rx.Name as Customer, date_format(s.createdDate, "%m/%d/%Y") as Date ,s.SONumber as "SO Number",s.Tag as "Job Name", b.ItemCode, d.QuantityOrdered as Ordered, d.QuantityBilled as Billed, ');
SET _sql = concat(_sql,' sum( InventoryAllocated - InventoryOnHand) as "B/O",(d.QuantityOrdered * d.whseCost) as Amount,  b.whDescription as Warehouse ');

SET _sql = concat(_sql,' from v_INV_bin b  ');
SET _sql = concat(_sql,'  left join cuSO s on (s.prFromWarehouseID = b.prWarehouseID)  ');
SET _sql = concat(_sql,'  left join cuSODetail d on (d.cuSOID = s.cuSOID and d.prMasterID = b.prMasterID) ');
SET _sql = concat(_sql,'  left join prWarehouse w on (w.prWarehouseID = b.prWarehouseID) ');
SET _sql = concat(_sql,'  left join rxMaster rx on (rx.rxMasterID = s.rxCustomerID)  ');
SET _sql = concat(_sql,'  left join joRelease joR on (joR.joReleaseID = s.joReleaseID)  ');
SET _sql = concat(_sql,'  left join joMaster joM on (joM.joMasterID = joR.joMasterID)  ');
SET _sql = concat(_sql,'  JOIN tsUserSetting tsSet ON tsSet.CompanyID=1 where b.InventoryOnHand < b.InventoryAllocated and (s.cuSOID is  null or s.TransactionStatus = 1) and d.QuantityOrdered <> d.QuantityBilled '); 

SET _sql = concat(_sql,' ');

-- RXM.rxMasterID -- customer
-- TSU.UserLoginID -- cuAssignmentID0

 		SELECT GROUP_CONCAT(myFilterId) 
        INTO _reports
        FROM REPORT_myFilters m 
        LEFT JOIN REPORT_filterTypes t ON ( t.filterName = m.myFilterName) 
		WHERE m.myReportId = _reportId AND t.isMeasure = 0;
        
		IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
									
			 SET _aReportId=SUBSTRING_INDEX(_reports, ',', 1);


 		SELECT m.myFilterName, ifnull(m.myFilterValueId,-1),ifnull(m.myFilterValueText,-1),ifnull(m.myFilterValueCurrency,-1),m.myFilterValueDateFrom,m.myFilterValueDateTo
        INTO _filterName,_myFilterValueId,_myFilterValueText,_myFilterValueCurrency,_myFilterDateFrom,_myFilterDateTo
        FROM REPORT_myFilters m
		WHERE m.myFilterId = _aReportId;

    IF (LOCATE('Warehouse',_filterName)>0 AND _myFilterValueId > 0) THEN
        SET _and = ' AND ';
		SET _sql = concat(_sql, _and, ' b.prWarehouseID = ',_myFilterValueId);
    -- end if;
    
	elseIF (LOCATE('Division',_filterName)>0 AND _myFilterValueId > 0) THEN
        SET _and = ' AND ';
		SET _sql = concat(_sql, _and, ' joM.coDivisionID = ',_myFilterValueId);
    -- end if;
    elseIF ((LOCATE('Year Date Ending',_filterName)>0 or LOCATE('Month Date Ending',_filterName)>0 or LOCATE('Single Date',_filterName)>0 or LOCATE('Date Range',_filterName)>0) and _myFilterDateTo is not null) THEN

        SET _and = ' AND ';

        IF (_myFilterDateFrom is not null and _myFilterDateTo is not null) THEN 
			SET _sql = concat(_sql, _and, '	(Date(s.createdDate) >= \'',_myFilterDateFrom,'\') ');
			SET _sql = concat(_sql, _and, '	(Date(s.createdDate) <= \'',_myFilterDateTo,'\') ');
		ELSEif (_myFilterDateFrom is not null ) THEN 
			SET _sql = concat(_sql, _and, '	(Date(s.createdDate) = \'',_myFilterDateFrom,'\') ');
		ELSE
			SET _sql = concat(_sql, _and, '	(Date(s.createdDate) <= \'',_myFilterDateTo,'\') ');
        END IF;
	
    end if;
 
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
			 SET _reports = MID(_reports, SubStrLen, strLen);

			 IF _reports = '' or _reports is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
											
		END IF; 
        
	SET _sql = concat(_sql,' group by b.prMasterID, b.prWarehouseID, d.cuSODetailID order by createdDate,s.cuSOID asc');
    
	SET _sql = concat(_sql, ';');

RETURN _sql;
END //
DELIMITER ;

-- ==================================================================================
-- select REPORT_build_JOB_Invoice_Cost_Details(1007);

-- select * from REPORT_build_JOB_Invoice_Cost_Details where myReportId=1007;

DROP function IF EXISTS `REPORT_build_JOB_Invoice_Cost_Details`;


DELIMITER //

CREATE DEFINER=`root`@`%` FUNCTION `REPORT_build_JOB_Invoice_Cost_Details`( 
_reportId int
) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE _sql text;
DECLARE _salesRepId INT;
DECLARE _CustomerID int;
DECLARE _dateTypeId int; -- booked/released/open/closed but will contain an id
DECLARE _dateTypeName varchar(100); -- monthToDateEnding
DECLARE _dateFrom Date;
DECLARE _dateTo Date;
DECLARE _report_JobNumber VARCHAR(100);
DECLARE _myReportEntityId tinyint;
DECLARE _sortBy VARCHAR(100);

 		select m.myFilterValueId
        into _salesRepId
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Employee';

 		select m.myFilterValueId
        into _CustomerID
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Customer';

 		select m.myFilterValueId,myFilterValueText,myFilterValueDateFrom,myFilterValueDateTo
        into _dateTypeId,_dateTypeName,_dateFrom,_dateTo
        from REPORT_myFilters m
		where m.myReportId = _reportId and m.myFilterName='Month Date Ending' or m.myFilterName='Year Date Ending' or m.myFilterName='Date Range' or m.myFilterName='Single Date';
        
        select myReportEntityId into _myReportEntityId from REPORT_reports where reportId = _reportId;
        

set _sql = 'select ';

IF (_salesRepId>0) THEN 
    SET _sortBy= 'Customer';
    SET _sql = concat(_sql,'rxm.Name AS customerName,DATE_FORMAT(ci.InvoiceDate, "%m/%d/%Y") AS InvoiceDate,jm.JobNumber,
        jrt.Description AS ReleaseType,ci.InvoiceNumber, tsu.FullName AS SalesRepName, ');
ELSE 
	SET _sortBy= 'SalesRep';
        SET _sql = concat(_sql,'tsu.FullName AS "SalesRepName",DATE_FORMAT(ci.InvoiceDate, "%m/%d/%Y") AS InvoiceDate,jm.JobNumber,
        jrt.Description AS ReleaseType,ci.InvoiceNumber,rxm.Name AS customerName, ');
END IF;


set _sql = concat(_sql,' IFNULL(ci.`CostTotal`, 0) AS `StockCost`,
		IFNULL(vb.BillAmount,0) AS POCost,(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0)) AS InvoiceAmount,
		(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0)) AS Profit,
		IFNULL(ROUND(ROUND_TO_EVEN((((IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0)))/(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))*100),2),2),0) AS Margin
		 FROM cuInvoice ci
		LEFT JOIN tsUserLogin tsu ON(ci.cuAssignmentID0=tsu.UserLoginID)
		LEFT JOIN rxMaster rxm ON(ci.rxCustomerID=rxm.rxMasterID)
		LEFT JOIN joReleaseDetail jrd ON(ci.joReleaseDetailID=jrd.joReleaseDetailID)
		LEFT JOIN joRelease jr ON(jrd.joReleaseID=jr.joReleaseID)
		LEFT JOIN joReleaseType jrt ON(jr.ReleaseType=jrt.joReleaseTypeID)
		LEFT JOIN joMaster jm ON(jr.joMasterID=jm.joMasterID)
		LEFT JOIN veBill vb ON(ci.joReleaseDetailID=vb.joReleaseDetailID and vb.joReleaseDetailID > 0)
		 WHERE ci.cuAssignmentID0 IS NOT NULL and ci.cuAssignmentID0>0 ');
         
IF (_CustomerID>0) THEN
	SET _sql=CONCAT(_sql,' and ci.rxCustomerID=',_CustomerID);
END IF;
IF (_salesRepId>0) THEN
	SET _sql=CONCAT(_sql,' and ci.cuAssignmentID0=',_salesRepId);
END IF;
IF (_dateFrom IS NOT NULL AND _dateFrom<>'' AND (_dateTo IS NULL OR _dateTo='')) THEN
    SET _dateFrom=DATE_FORMAT(_dateFrom, "%Y-%m-%d");
    SET _sql=CONCAT(_sql,' and ci.InvoiceDate=\'',_dateFrom,'\'');
ELSE
	IF (_dateFrom IS NOT NULL AND _dateFrom<>'') THEN
		SET _dateFrom=DATE_FORMAT(_dateFrom, "%Y-%m-%d");
		SET _sql=CONCAT(_sql,' and ci.InvoiceDate>=\'',_dateFrom,' 00:00:00\'');
	END IF;
	IF (_dateTo IS NOT NULL AND _dateTo<>'') THEN
		SET _dateTo=DATE_FORMAT(_dateTo, "%Y-%m-%d");    
		SET _sql=CONCAT(_sql,' and ci.InvoiceDate<=\'',_dateTo,' 23:59:59\'');
	END IF;
	
END IF;
		
        SET _sql=CONCAT(_sql,'union all   ');
        SET _sql=CONCAT(_sql,'select   ');
        
IF (_salesRepId>0) THEN 
    SET _sql = concat(_sql,'rxm.Name AS customerName, DATE_FORMAT(vec.CommDate, "%m/%d/%Y") AS InvoiceDate,jm.JobNumber,
        jrt.Description AS ReleaseType,vec.InvoiceNumber,tsu.FullName AS SalesRepName, ');
ELSE 
        SET _sql = concat(_sql,'tsu.FullName AS "SalesRepName",DATE_FORMAT(vec.CommDate, "%m/%d/%Y") AS InvoiceDate,jm.JobNumber,
        jrt.Description AS ReleaseType,vec.InvoiceNumber,rxm.Name AS customerName, ');
END IF;

        SET _sql=CONCAT(_sql,' 0 AS `StockCost`,0 AS POCost,vec.CommAmount AS InvoiceAmount,vec.CommAmount -0-0 AS Profit,
		 IFNULL(ROUND(ROUND_TO_EVEN((vec.CommAmount/vec.CommAmount)*100,2),2),0) AS Margin
		 FROM joMaster jm
         LEFT JOIN joRelease jr ON(jm.joMasterID=jr.joMasterID)
         LEFT JOIN joReleaseDetail jrd ON(jr.joReleaseID=jrd.joReleaseID)
         LEFT JOIN joReleaseType jrt ON(jr.ReleaseType=jrt.joReleaseTypeID)
         LEFT join veCommDetail vec on (vec.joReleaseDetailID = jrd.joReleaseDetailID)
		 LEFT JOIN tsUserLogin tsu ON(jm.cuAssignmentID0=tsu.UserLoginID)
		 LEFT JOIN rxMaster rxm ON(jm.rxCustomerID=rxm.rxMasterID)
		 LEFT join cuInvoice ci ON(ci.joReleaseDetailID=jrd.joReleaseDetailID)
		 LEFT JOIN veBill vb ON(ci.joReleaseDetailID=vb.joReleaseDetailID and vb.joReleaseDetailID > 0)
		 WHERE jm.cuAssignmentID0 IS NOT NULL and jm.cuAssignmentID0>0');
  IF (_CustomerID>0) THEN
	SET _sql=CONCAT(_sql,' and jm.rxCustomerID=',_CustomerID);
END IF;
IF (_salesRepId>0) THEN
	SET _sql=CONCAT(_sql,' and jm.cuAssignmentID0=',_salesRepId);
END IF;
IF (_dateFrom IS NOT NULL AND _dateFrom<>'' AND (_dateTo IS NULL OR _dateTo='')) THEN
    SET _dateFrom=DATE_FORMAT(_dateFrom, "%Y-%m-%d");
    SET _sql=CONCAT(_sql,' and vec.CommDate=\'',_dateFrom,'\'');
ELSE
	IF (_dateFrom IS NOT NULL AND _dateFrom<>'') THEN
		SET _dateFrom=DATE_FORMAT(_dateFrom, "%Y-%m-%d");
		SET _sql=CONCAT(_sql,' and vec.CommDate>=\'',_dateFrom,' 00:00:00\'');
	END IF;
	IF (_dateTo IS NOT NULL AND _dateTo<>'') THEN
		SET _dateTo=DATE_FORMAT(_dateTo, "%Y-%m-%d");    
		SET _sql=CONCAT(_sql,' and vec.CommDate<=\'',_dateTo,' 23:59:59\'');
	END IF;
	
END IF;
  
IF (_sortBy='SalesRep') THEN
	SET _sql=CONCAT(_sql,' order by SalesRepName asc,InvoiceDate'); 
    SET _sql = concat("SELECT SalesRepName AS 'SalesRepName',InvoiceDate, JobNumber as `Job #`, ReleaseType, InvoiceNumber, customerName, StockCost,  POCost, InvoiceAmount,Profit,Margin FROM (",_sql,") as InvoiceCostDetails"); 
ELSE
	SET _sql=CONCAT(_sql,' order by SalesRepName asc,InvoiceDate'); 
     SET _sql = concat("SELECT customerName,InvoiceDate, JobNumber as `Job #`, ReleaseType, InvoiceNumber,SalesRepName AS 'Sales Rep Name', StockCost,  POCost, InvoiceAmount,Profit,Margin FROM (",_sql,") as InvoiceCostDetails");
END IF;
set _sql = concat(_sql, ';');
RETURN _sql;
END //
DELIMITER ;

-- ==================================================================================
-- select REPORT_build_JOB_InvoiceCostDetails_Summary(1008);
-- select * from REPORT_build_JOB_InvoiceCostDetails_Summary where myReportId=1008;

DROP FUNCTION IF EXISTS `REPORT_build_JOB_InvoiceCostDetails_Summary`;


DELIMITER //

CREATE  FUNCTION `REPORT_build_JOB_InvoiceCostDetails_Summary`(_reportId INT) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE rxCustomerId INT;
DECLARE fromDate DATE;
DECLARE toDate DATE;
DECLARE salesRepId INT;
DECLARE sortBy VARCHAR(100);
-- DECLARE employee INT;


SELECT myFilterValueId INTO salesRepId FROM REPORT_myFilters
	WHERE myReportId = _reportId AND myFilterName='Employee';

SELECT myFilterValueId INTO rxCustomerId FROM REPORT_myFilters
	WHERE myReportId = _reportId AND myFilterName='Customer';

SELECT myFilterValueDateFrom, myFilterValueDateTo INTO fromDate, toDate FROM REPORT_myFilters
    WHERE myReportId = _reportId AND
         (myFilterName='Month Date Ending' or myFilterName='Year Date Ending' 
         or myFilterName='Date Range' or myFilterName='Single Date');
         
-- SELECT myFilterValueText INTO sortBy FROM REPORT_myFilters 
	-- WHERE myReportId = _reportId and myFilterName='Sort By';
IF (salesRepId>0) THEN 
    SET sortBy= 'Customer';
ELSE 
	SET sortBy= 'SalesRep';
END IF;
-- ci.cuAssignmentID0 AS salesRepId,  , ci.rxCustomerID AS info_rxCustomerID, rxm.Name AS customerName,
SET @l_sql = 'SELECT ci.cuAssignmentID0 AS salesRepId, tsu.FullName AS salesRepName,ci.rxCustomerID AS info_rxCustomerID, rxm.Name AS customerName,
		SUM(IFNULL(ci.`CostTotal`, 0)) AS `stockCost`,
		SUM(IFNULL(vb.BillAmount,0)) AS poCost,SUM((IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))) AS InvoiceAmountWOTax,
		SUM((IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0))) AS profit,
		IFNULL(ROUND(ROUND_TO_EVEN((SUM((IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0)))/SUM(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))*100),2),2),0) AS margin
		 FROM cuInvoice ci
		LEFT JOIN tsUserLogin tsu ON(ci.cuAssignmentID0=tsu.UserLoginID)
		LEFT JOIN rxMaster rxm ON(ci.rxCustomerID=rxm.rxMasterID)
		LEFT JOIN joReleaseDetail jrd ON(ci.joReleaseDetailID=jrd.joReleaseDetailID)
		LEFT JOIN joRelease jr ON(jrd.joReleaseID=jr.joReleaseID)
		LEFT JOIN joReleaseType jrt ON(jr.ReleaseType=jrt.joReleaseTypeID)
		LEFT JOIN joMaster jm ON(jr.joMasterID=jm.joMasterID)
		LEFT JOIN veBill vb ON(ci.joReleaseDetailID=vb.joReleaseDetailID and vb.joReleaseDetailID > 0)
	 	WHERE ci.cuAssignmentID0 IS NOT NULL and ci.cuAssignmentID0>0 ';
IF (rxCustomerId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and ci.rxCustomerID=',rxCustomerId);
END IF;
IF (salesRepId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and ci.cuAssignmentID0=',salesRepId);
END IF;
IF (fromDate IS NOT NULL AND fromDate<>'' AND (toDate IS NULL OR toDate='')) THEN
    SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
    SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate=\'',fromDate,'\'');
ELSE
	IF (fromDate IS NOT NULL AND fromDate<>'') THEN
		SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
		SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate>=\'',fromDate,' 00:00:00\'');
	END IF;
	IF (toDate IS NOT NULL AND toDate<>'') THEN
		SET toDate=DATE_FORMAT(toDate, "%Y-%m-%d");    
		SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate<=\'',toDate,' 23:59:59\'');
	END IF;
	
END IF;

	SET @l_sql=CONCAT(@l_sql,' group by salesRepId ');

 SET @l_sql=CONCAT(@l_sql,'union all   ');
  SET @l_sql=CONCAT(@l_sql,'SELECT jm.cuAssignmentID0 AS salesRepId,tsu.FullName AS salesRepName,
		jm.rxCustomerID AS info_rxCustomerID,
		rxm.Name AS customerName,SUM(IFNULL(ci.`CostTotal`, 0)) AS `stockCost`,
		0 AS poCost,SUM((IFNULL(vec.CommAmount,0))) AS InvoiceAmountWOTax,
		SUM(IFNULL(vec.CommAmount,0)) AS profit,
		IFNULL(ROUND(ROUND_TO_EVEN(SUM(IFNULL(vec.CommAmount,0))*100,2),2),0) AS margin
		 FROM joMaster jm
         LEFT JOIN joRelease jr ON(jm.joMasterID=jr.joMasterID)
         LEFT JOIN joReleaseDetail jrd ON(jr.joReleaseID=jrd.joReleaseID)
         LEFT JOIN joReleaseType jrt ON(jr.ReleaseType=jrt.joReleaseTypeID)
         left join veCommDetail vec on (vec.joReleaseDetailID = jrd.joReleaseDetailID)
		LEFT JOIN tsUserLogin tsu ON(jm.cuAssignmentID0=tsu.UserLoginID)
		LEFT JOIN rxMaster rxm ON(jm.rxCustomerID=rxm.rxMasterID)
		left join cuInvoice ci ON(ci.joReleaseDetailID=jrd.joReleaseDetailID)
		LEFT JOIN veBill vb ON(ci.joReleaseDetailID=vb.joReleaseDetailID and vb.joReleaseDetailID > 0)
		WHERE jm.cuAssignmentID0 IS NOT NULL and jm.cuAssignmentID0>0');
        
        
        IF (rxCustomerId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and jm.rxCustomerID=',rxCustomerId);
END IF;
IF (salesRepId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and jm.cuAssignmentID0=',salesRepId);
END IF;
IF (fromDate IS NOT NULL AND fromDate<>'' AND (toDate IS NULL OR toDate='')) THEN
    SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
    SET @l_sql=CONCAT(@l_sql,' and vec.CommDate=\'',fromDate,'\'');
ELSE
	IF (fromDate IS NOT NULL AND fromDate<>'') THEN
		SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
		SET @l_sql=CONCAT(@l_sql,' and vec.CommDate>=\'',fromDate,' 00:00:00\'');
	END IF;
	IF (toDate IS NOT NULL AND toDate<>'') THEN
		SET toDate=DATE_FORMAT(toDate, "%Y-%m-%d");    
		SET @l_sql=CONCAT(@l_sql,' and vec.CommDate<=\'',toDate,' 23:59:59\'');
	END IF;
	
END IF;

IF (sortBy='SalesRep') THEN
	SET @l_sql=CONCAT(@l_sql,' group by salesRepId order by salesRepName');
ELSE
	SET @l_sql=CONCAT(@l_sql,' group by salesRepId order by customerName');
END IF;

IF (salesRepId>0) then 
    set @l_sql = CONCAT("select customerName as 'Customer Name',sum(stockCost) as StockCost ,sum(poCost) as POCost,sum(InvoiceAmountWOTax) as InvoiceAmount,sum(profit) as Profit,sum(margin) as Margin
 from (",@l_sql,") as test group by salesRepId order by customerName asc"); 
else
	set @l_sql = CONCAT("select salesRepName as 'SalesRepName',sum(stockCost) as StockCost ,sum(poCost) as POCost,sum(InvoiceAmountWOTax) as InvoiceAmount,sum(profit) as Profit,sum(margin) as Margin
 from (",@l_sql,") as test group by salesRepId order by salesRepName asc"); 
end if;

 RETURN @l_sql;
END //
DELIMITER ;

-- ========================================================================

DROP FUNCTION IF EXISTS `REPORT_build_Basis_Of_Design`;
DELIMITER //

CREATE DEFINER=`root`@`%` FUNCTION `REPORT_build_Basis_Of_Design`(_reportId INT) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _and varchar(25);
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _sql text;
DECLARE _filterName varchar(50);
DECLARE _myFilterValueId varchar(50);
DECLARE _myFilterValueText varchar(50);
DECLARE _myFilterValueCurrency varchar(50);

DECLARE _employeeAssignmentID int;
DECLARE _sortBy varchar(100);
DECLARE _dateTypeId int; 
DECLARE _dateTypeName varchar(100); 
DECLARE _dateFrom Date;
DECLARE _dateTo Date;
DECLARE _report_JobNumber VARCHAR(100);

DECLARE _manufacture int; 
DECLARE _takeOff int; 
DECLARE _engineer int; 
DECLARE _assignEngineer int; 
DECLARE _costing int; 
DECLARE _salesRep int; 
DECLARE _division int;


SET _sql = "select
 aa.Vendor, aa.JobNumber as `Job Number`,date_format(aa.BidDate, '%m/%d/%Y') as BidDate,aa. JobName as `Job Name`, aa.SalesRep, aa.Costing, aa.Takeoff as `Take-Off`, aa.QuotedBy as `Quoted By`,
 aa.Engineer, aa.SalesEngineer as `Sales Engineer`, aa.JobStatus as `Job Status`, aa.ContractAmount as `Contract Amount`
from (SELECT
				rM.`Name` as Vendor, joM.JobNumber, joM.BidDate, joM.Description as 'JobName', 
				(select FullName from tsUserLogin where userLoginID = joM.cuAssignmentID0) as Salesrep, 
				(select FullName from tsUserLogin where userLoginID = joM.cuAssignmentID2) as Costing,
				(select FullName from tsUserLogin where userLoginID = joM.cuAssignmentID5) as `TakeOff`,
				(select FullName from tsUserLogin where userLoginID = joM.cuAssignmentID6) as `QuotedBy`,
				(select Name from rxMaster where rxMasterID= joM.rxCategory2) as Engineer,
				(select FullName from tsUserLogin where userLoginID = 
					(select cuAssignmentID0 from rxMasterCategory1 where rxMasterCategory1ID =joM.rxCategory2)) as 'SalesEngineer',
				js.JobStatus as 'JobStatus' , joM.ContractAmount as 'ContractAmount' ,
                                	rM.rxMasterID,joM.rxCategory2,rx1.cuAssignmentID0 as rxCuAssignmentID0,joM.cuAssignmentID0 as joCuAssignmentID0,
                    joM.cuAssignmentID2,joM.cuAssignmentID5, js.joStatusID, coDiv.coDivisionID
			FROM joMaster joM
				left join joStatus js on (joM.JobStatus = js.joStatusID)
				left join coDivision coDiv on (joM.coDivisionID = coDiv.coDivisionID)
				left join joMasterManufacturer jmm on (jmm.joMasterID = joM.joMasterID )
				left join joManufacturers jm on (jm.rxMasterId = jmm.rxMasterId )
				left join tsUserLogin tsU on (tsU.UserLoginID = joM.CreatedByID) 
				left join rxMaster rM on (rM.rxMasterId = jm.rxMasterId)
                    left join rxMasterCategory1 rx1 on (rx1.rxMasterCategory1ID = joM.rxCategory2)
			WHERE
				isBodChecked = 1 and coDiv.InActive = 0 and  tsU.Inactive = 0 and jmm.isBod = 1 and joManufacturersId is not null) as aa where aa.JobNumber is not null";

select m.myFilterValueId into _manufacture from REPORT_myFilters m  where m.myReportId = _reportId and m.myFilterName='Manufacturer';
select m.myFilterValueId into _engineer from REPORT_myFilters m where m.myReportId = _reportId and m.myFilterName='Engineer';
        
select m.myFilterValueId into _assignEngineer from REPORT_myFilters m where m.myReportId = _reportId and m.myFilterName='Engineer Assignment';
        
select m.myFilterValueId into _costing from REPORT_myFilters m where m.myReportId = _reportId and m.myFilterName='Costing';

select m.myFilterValueId into _salesRep from REPORT_myFilters m where m.myReportId = _reportId and m.myFilterName='Salesrep';

select m.myFilterValueId into _division from REPORT_myFilters m where m.myReportId = _reportId and m.myFilterName='Division';

select m.myFilterValueId,myFilterValueText,myFilterValueDateFrom,IFNULL(myFilterValueDateTo,Date(now()))
into _dateTypeId,_dateTypeName,_dateFrom,_dateTo from REPORT_myFilters m where m.myReportId = _reportId and 
m.myFilterName='Month Date Ending' or m.myFilterName='Year Date Ending' or m.myFilterName='Date Range' or m.myFilterName='Single Date';


  		select GROUP_CONCAT(myFilterId) 
        into _reports
        from REPORT_myFilters m 
        left join REPORT_filterTypes t on ( t.filterName = m.myFilterName) 
		where m.myReportId = _reportId and t.isMeasure = 0;
        
                        
                        
			IF (_reports is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_reports);
									
			 set _aReportId=SUBSTRING_INDEX(_reports, ',', 1);


 		select m.myFilterName, ifnull(m.myFilterValueId,-1),ifnull(m.myFilterValueText,-1),ifnull(m.myFilterValueCurrency,-1)
        into _filterName,_myFilterValueId,_myFilterValueText,_myFilterValueCurrency
        from REPORT_myFilters m
		where m.myFilterId = _aReportId;
        
	IF (LOCATE('Manufacturer',_filterName)>0 and _myFilterValueId > 0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'aa.rxMasterID =',_myFilterValueId);
	elseIF (_filterName = 'Engineer') THEN
		IF (LOCATE('Engineer',_filterName)>0 and _myFilterValueId > 0)THEN
        set _and = ' AND ';

         set _sql = concat(_sql, _and, 'aa.rxCategory2 =',_myFilterValueId);
        END IF;
	elseIF ( _filterName = 'Engineer Assignment') THEN
    if (LOCATE('Engineer Assignment',_filterName)>0 and _myFilterValueId > 0)then
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'aa.rxCuAssignmentID0 =',_myFilterValueId);
	end if;
	elseIF (LOCATE('Salesrep',_filterName)>0 and _myFilterValueId > 0) THEN
        set _and = ' AND ';
        set _sql = concat(_sql, _and, 'aa.jocuAssignmentID0 =',_myFilterValueId);
	elseIF (LOCATE('Costing',_filterName)>0 and _myFilterValueId > 0) THEN
        set _and = ' AND ';
        set _sql = concat(_sql, _and, 'aa.cuAssignmentID2 =',_myFilterValueId);
	elseIF (LOCATE('Take-Off',_filterName)>0 and _myFilterValueId > 0) THEN
        set _and = ' AND ';
        set _sql = concat(_sql, _and, 'aa.cuAssignmentID5 =',_myFilterValueId);
	elseIF (LOCATE('Job Status',_filterName)>0 and _myFilterValueId > 0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'aa.joStatusID =',_myFilterValueId);
	elseIF (LOCATE('Division',_filterName)>0 and _myFilterValueId > 0) THEN
        set _and = ' AND ';
		set _sql = concat(_sql, _and, 'aa.coDivisionID =',_myFilterValueId);
	end if;
   
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_reports, ',', 1))+2;
			 SET _reports = MID(_reports, SubStrLen, strLen);

			 IF _reports = '' or _reports is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;				
		END IF; 
 -- RETURN _sql;
  set _and = ' AND ';
		if (_dateFrom is not null and _dateTo is not null) THEN 
         set _and = ' AND ';
			set _sql = concat(_sql, _and, '	(Date(aa.BidDate) >= \'',_dateFrom,'\') ');
			set _sql = concat(_sql, _and, '	(Date(aa.BidDate) <= \'',_dateTo,'\') ');
		ELSEif (_dateFrom is not null ) THEN 
         set _and = ' AND ';
			set _sql = concat(_sql, _and, '	(Date(aa.BidDate) = \'',_dateFrom,'\') ');
		else
         set _and = ' AND '; 
			set _sql = concat(_sql, _and, '	(Date(joM.BidDate) <= \'',_dateTo,'\') '); 
        END IF;
set _sql = concat(_sql, ' order by aa.JobNumber'); 


	set _sql = concat(_sql, ';');

RETURN _sql;
END //
DELIMITER ;
-- ========================================================================

DROP function IF EXISTS `REPORT_Rolodex_Assigned`;

DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `REPORT_Rolodex_Assigned`(_reportId INT) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _and varchar(25);
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _sql text;
DECLARE _filterName varchar(50);
DECLARE _myFilterValueId varchar(50);
DECLARE _myFilterValueText varchar(50);
DECLARE _myFilterValueCurrency varchar(50);
DECLARE _sortByMyFilterName varchar(50);
declare _include_contacts tinyint;
declare _salesRep_value varchar(50);

select myFilterValueId into _include_contacts from REPORT_myFilters where myReportId = _reportId and myFilterName = "Include Contacts";
select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportId = _reportId and myFilterName = "Category";
select myFilterValueId into _salesRep_value from REPORT_myFilters where myReportId = _reportId and myFilterName = "Salesrep";

if(_include_contacts >0 )then
	set _sql = 'select  test.Name as `150_Name`, test.SalesRep,test.FirstName,test.LastName,test.JobPosition,test.DirectLine as `DirectLine`,test.Cell as `Cell`,test.EMail,test.Division as `100_Division` from( ';
    if(_myFilterValueId=1) then
		set _sql=concat(_sql,'select rxM.rxMasterID,rxM.InActive,if(length(rxM.Name)>0,rxM.Name,rxM.SearchName) as Name,
			rxM.IsCustomer,cu.cuMasterID,ts1.UserLoginID,ts1.FullName as SalesRep,
			rxC.FirstName,rxC.LastName,rxC.JobPosition,rxC.DirectLine,rxC.Cell ,rxC.EMail,rxC.Division from rxMaster rxM 
			left join rxContact rxC on rxM.rxMasterID=rxC.rxMasterID
			left join cuMaster cu on rxM.rxMasterID=cu.cuMasterID
			left join tsUserLogin ts1 on cu.cuAssignmentID0=ts1.UserLoginID
			where rxM.IsCustomer=1  and rxM.InActive=0 and (Name is not null and Name<>"") and length(rxC.rxContactID)>0 ');
            if((_salesRep_value>0 and _salesRep_value<>'') )then
				set _sql=concat(_sql,'and ts1.UserLoginID= ',_salesRep_value);
			end if;
    elseif(_myFilterValueId=4)then
		set _sql=concat(_sql,'select rxM.rxMasterID,rxM.InActive,if(length(rxM.Name)>0,rxM.Name,rxM.SearchName) as Name,rxM.IsCategory1,rc1.rxMasterCategory1ID,ts1.UserLoginID,ts1.FullName as SalesRep,
			rxC.FirstName,rxC.LastName,rxC.JobPosition,rxC.DirectLine,rxC.Cell ,rxC.EMail,rxC.Division from rxMaster rxM 
			left join rxContact rxC on rxM.rxMasterID=rxC.rxMasterID
			left join rxMasterCategory1 rc1 on rxM.rxMasterID=rc1.rxMasterCategory1ID
			left join tsUserLogin ts1 on rc1.cuAssignmentID0=ts1.UserLoginID
			where rxM.IsCategory1=1  and rxM.InActive=0 and (Name is not null and Name<>"") and length(rxC.rxContactID)>0 ');
            if((_salesRep_value>0 and _salesRep_value<>'') )then
				set _sql=concat(_sql,'and ts1.UserLoginID= ',_salesRep_value);
			end if;
    elseif(_myFilterValueId=5)then
		set _sql=concat(_sql,'select rxM.rxMasterID,rxM.InActive,if(length(rxM.Name)>0,rxM.Name,rxM.SearchName) as Name,
			rxM.IsCategory2,rc2.rxMasterCategory2ID,ts1.UserLoginID,ts1.FullName as SalesRep,
			rxC.FirstName,rxC.LastName,rxC.JobPosition,rxC.DirectLine,rxC.Cell ,rxC.EMail,rxC.Division from rxMaster rxM 
			left join rxContact rxC on rxM.rxMasterID=rxC.rxMasterID
			left join rxMasterCategory2 rc2 on rxM.rxMasterID=rc2.rxMasterCategory2ID
			left join tsUserLogin ts1 on rc2.cuAssignmentID0=ts1.UserLoginID
			where rxM.IsCategory2=1  and rxM.InActive=0 and (Name is not null and Name<>"") and length(rxC.rxContactID)>0 ');
            if((_salesRep_value>0 and _salesRep_value<>'') )then
				set _sql=concat(_sql,'and ts1.UserLoginID= ',_salesRep_value);
			end if;
    elseif(_myFilterValueId=7)then
		set _sql=concat(_sql,'select rxM.rxMasterID,rxM.InActive,if(length(rxM.Name)>0,rxM.Name,rxM.SearchName) as Name,
			rxM.IsCategory4,rc4.rxMasterCategory4ID,ts1.UserLoginID,ts1.FullName as SalesRep,
			rxC.FirstName,rxC.LastName,rxC.JobPosition,rxC.DirectLine,rxC.Cell ,rxC.EMail,rxC.Division from rxMaster rxM 
			left join rxContact rxC on rxM.rxMasterID=rxC.rxMasterID
			left join rxMasterCategory4 rc4 on rxM.rxMasterID=rc4.rxMasterCategory4ID
			left join tsUserLogin ts1 on rc4.cuAssignmentID0=ts1.UserLoginID
			where rxM.IsCategory4=1  and rxM.InActive=0 and (Name is not null and Name<>"") and length(rxC.rxContactID)>0 ');
            if((_salesRep_value>0 and _salesRep_value<>'') )then
				set _sql=concat(_sql,'and ts1.UserLoginID= ',_salesRep_value);
			end if;
     elseif(_myFilterValueId in(2,3,6,8,9,10))then
		set _sql=concat(_sql,'select rxM.rxMasterID,rxM.IsVendor,rxM.IsEmployee,rxM.IsCategory3,rxM.IsCategory5,rxM.IsCategory6,rxM.IsCategory7,rxM.IsCategory8,
			rxM.InActive,if(length(rxM.Name)>0,rxM.Name,rxM.SearchName) as Name,null as SalesRep,rxC.FirstName,rxC.LastName,rxC.JobPosition,rxC.DirectLine,rxC.Cell ,rxC.EMail,rxC.Division
			from rxMaster rxM 
			left join rxContact rxC on rxM.rxMasterID=rxC.rxMasterID
			where  rxM.InActive=0 and (Name is not null and Name<>"") and length(rxC.rxContactID)>0 ');
            set _and = ' AND ';
			if(_myFilterValueId = 2)then
				set _sql = concat(_sql, _and, ' rxM.IsVendor =', 1 );
			elseif(_myFilterValueId = 3)then
				set _sql = concat(_sql, _and, ' rxM.IsEmployee = ', 1 );
			elseif(_myFilterValueId = 6)then
				set _sql = concat(_sql, _and, 'rxM.IsCategory3 = ', 1 );
			elseif(_myFilterValueId = 8)then
				set _sql = concat(_sql, _and, ' rxM.IsCategory5 = ', 1 );
			elseif(_myFilterValueId = 9)then
				set _sql = concat(_sql, _and, ' rxM.IsCategory6 = ', 1 );
			elseif(_myFilterValueId = 10)then
				set _sql = concat(_sql, _and, ' rxM.IsCategory7 = ', 1 );
			elseif(_myFilterValueId = 11)then
				set _sql = concat(_sql, _and, ' rxM.IsCategory8 = ', 1 );
            end if;
	elseif(_myFilterValueId is null and _salesRep_value is null)then
		set _sql=concat(_sql,'select rxM.rxMasterID,rxM.InActive,if(length(rxM.Name)>0,rxM.Name,rxM.SearchName) as Name,null as SalesRep,
			rxC.FirstName,rxC.LastName,rxC.JobPosition,rxC.DirectLine,rxC.Cell ,rxC.EMail,rxC.Division
			from rxMaster rxM 
			left join rxContact rxC on rxM.rxMasterID=rxC.rxMasterID
			where  rxM.InActive=0 and (Name is not null and Name<>"") and length(rxC.rxContactID)>0 ');
  elseif(_myFilterValueId is null  and (_salesRep_value>0 and _salesRep_value <> '') )then
	set _sql=concat(_sql,'select rxM.rxMasterID,rxM.IsCustomer,rxM.IsCategory1,rxM.IsCategory2,rxM.IsCategory4,rxM.InActive,if(length(rxM.Name)>0 ,rxM.Name,rxM.SearchName) as Name, 
			SalesRepVal.FullName as SalesRep,
			rxC.FirstName,rxC.LastName,rxC.JobPosition,rxC.DirectLine,rxC.Cell ,rxC.EMail,rxC.Division from rxMaster rxM 
			left join rxContact rxC on rxM.rxMasterID=rxC.rxMasterID
			left join (select cu.cuMasterID as rxId,ts.UserLoginID,cu.cuAssignmentID0,ts.FullName from cuMaster cu
			left join tsUserLogin ts on cu.cuAssignmentID0=ts.UserloginID union 
			select rc1.rxMasterCategory1ID as rxId,ts.UserLoginID,rc1.cuAssignmentID0,ts.FullName from rxMasterCategory1 rc1
			left join tsUserLogin ts on rc1.cuAssignmentID0=ts.UserloginID union 
			select rc2.rxMasterCategory2ID as rxId,ts.UserLoginID,rc2.cuAssignmentID0,ts.FullName from rxMasterCategory2 rc2
			left join tsUserLogin ts on rc2.cuAssignmentID0=ts.UserloginID union
			select rc4.rxMasterCategory4ID as rxId,ts.UserLoginID,rc4.cuAssignmentID0,ts.FullName from rxMasterCategory4 rc4
			left join tsUserLogin ts on rc4.cuAssignmentID0=ts.UserloginID
			) as SalesRepVal on rxM.rxMasterID=SalesRepVal.rxId
			where 1 in (rxM.IsCategory1,rxM.IsCategory2,rxM.IsCategory4,rxM.IsCustomer) and rxM.InActive=0 and (Name is not null and Name<>"") and length(rxC.rxContactID)>0 and SalesRepVal.UserLoginId= ',_salesRep_value);        
 end if;
    set _sql=concat(_sql,') as test ');
else
	set _sql='select test.Name as `150_Name`, test.SalesRep, test.Address1,test.Address2,test.City,test.State,test.Zip,test.Phone1 from( ';
	if(_myFilterValueId=1)then
		set _sql=concat(_sql,'select ts.UserLoginID,rxM.rxMasterID,rxM.IsCustomer,rxM.InActive,if(length(rxM.Name)>0,rxM.Name,rxM.SearchName) as Name,cu.cuMasterID,cu.cuAssignmentID0,ts.FullName as SalesRep,
			rxA.rxAddressID,rxA.addressOrder,rxA.IsDefault,rxA.IsMailing,rxA.IsShipTo,rxA.Address1,rxA.Address2,rxA.City,rxA.State,
			rxA.Zip,if(length(rxA.phone1)>0,rxA.Phone1,rxM.phone1) as Phone1 from rxMaster rxM 
			left join cuMaster cu on rxM.rxMasterID = cu.cuMasterID 
			left join tsUserLogin ts on cu.cuAssignmentID0 = ts.UserLoginID
			left join ( select ra.Address1,ra.Address2,ra.City,ra.State,ra.Zip,ra.Phone1,ra.IsDefault,ra.IsMailing,ra.IsShipTo,
			ra.rxMasterID,ra.rxAddressID,case when ra.IsDefault=1 then 1 when ra.IsDefault=0 and ra.IsMailing=1 then 2 
			when ra.IsDefault=0 and IsMailing=0 and ra.IsShipTo=1 then 3 else 4 end as addressOrder 
			from rxAddress ra )as rxA on rxA.rxMasterID=rxM.rxMasterID 
			join(select rxMasterID, MIN(addressOrder) AS minAddressOrder from (select ra.rxMasterID,case when ra.isdefault = 1 then 1
			when ra.isdefault=0 and ra.isMailing=1 then 2 when ra.isdefault=0 and ra.isMailing=0 and ra.isShipTo =1 then 3 else 4 end as addressOrder
			from rxAddress ra) as subquery group by rxMasterID)
			as minAddressOrders ON rxA.rxMasterID = minAddressOrders.rxMasterID AND rxA.addressOrder = minAddressOrders.minAddressOrder 
			where rxM.IsCustomer=1  and rxM.InActive=0 and (Name is not null and Name<>"") and length(rxA.rxAddressID)>0 ');
			if((_salesRep_value>0 and _salesRep_value<>'') )then
				set _sql=concat(_sql,'and ts.UserLoginId= ',_salesRep_value);
			end if;
    elseif(_myFilterValueId=4)then
		set _sql=concat(_sql,'select ts.UserLoginID,rxM.rxMasterID,rxM.IsCategory1,rxM.InActive,if(length(rxM.Name)>0 ,rxM.Name,rxM.SearchName) as Name,rc1.rxMasterCategory1ID,rc1.cuAssignmentID0,ts.FullName as SalesRep,
			rxA.rxAddressID,rxA.addressOrder,rxA.IsDefault,rxA.IsMailing,rxA.IsShipTo,rxA.Address1,rxA.Address2,rxA.City,rxA.State,
			rxA.Zip,if(length(rxA.phone1)>0,rxA.Phone1,rxM.phone1) as Phone1 from rxMaster rxM 
			left join rxMasterCategory1 rc1 on rxM.rxMasterID = rc1.rxMasterCategory1ID
			left join tsUserLogin ts on rc1.cuAssignmentID0 = ts.UserLoginID
			left join ( select ra.Address1,ra.Address2,ra.City,ra.State,ra.Zip,ra.Phone1,ra.IsDefault,ra.IsMailing,ra.IsShipTo,
			ra.rxMasterID,ra.rxAddressID,case when ra.IsDefault=1 then 1 when ra.IsDefault=0 and ra.IsMailing=1 then 2 
			when ra.IsDefault=0 and IsMailing=0 and ra.IsShipTo=1 then 3 else 4 end as addressOrder 
			from rxAddress ra )as rxA on rxA.rxMasterID=rxM.rxMasterID 
			join(select rxMasterID, MIN(addressOrder) AS minAddressOrder from (select ra.rxMasterID,case when ra.isdefault = 1 then 1
			when ra.isdefault=0 and ra.isMailing=1 then 2 when ra.isdefault=0 and ra.isMailing=0 and ra.isShipTo =1 then 3 else 4 end as addressOrder
			from rxAddress ra) as subquery group by rxMasterID)
			as minAddressOrders ON rxA.rxMasterID = minAddressOrders.rxMasterID AND rxA.addressOrder = minAddressOrders.minAddressOrder 
			where rxM.IsCategory1=1  and rxM.InActive=0 and (Name is not null and Name<>"") and length(rxA.rxAddressID)>0 ');
            if((_salesRep_value>0 and _salesRep_value<>'') )then
				set _sql=concat(_sql,'and ts.UserLoginId= ',_salesRep_value);
			end if;
   elseif(_myFilterValueId=5)then
		set _sql=concat(_sql,'select ts.UserLoginID,rxM.rxMasterID,rxM.IsCategory2,rxM.InActive,if(length(rxM.Name)>0,rxM.Name,rxM.SearchName) as Name,rc2.rxMasterCategory2ID,rc2.cuAssignmentID0,ts.FullName as SalesRep,
			rxA.rxAddressID,rxA.addressOrder,rxA.IsDefault,rxA.IsMailing,rxA.IsShipTo,rxA.Address1,rxA.Address2,rxA.City,rxA.State,
			rxA.Zip,if(length(rxA.phone1)>0,rxA.Phone1,rxM.phone1) as Phone1 from rxMaster rxM 
			left join rxMasterCategory2 rc2 on rxM.rxMasterID = rc2.rxMasterCategory2ID
			left join tsUserLogin ts on rc2.cuAssignmentID0 = ts.UserLoginID
			left join ( select ra.Address1,ra.Address2,ra.City,ra.State,ra.Zip,ra.Phone1,ra.IsDefault,ra.IsMailing,ra.IsShipTo,
			ra.rxMasterID,ra.rxAddressID,case when ra.IsDefault=1 then 1 when ra.IsDefault=0 and ra.IsMailing=1 then 2
			 when ra.IsDefault=0 and IsMailing=0 and ra.IsShipTo=1 then 3 else 4 end as addressOrder 
			from rxAddress ra )as rxA on rxA.rxMasterID=rxM.rxMasterID 
			join(select rxMasterID, MIN(addressOrder) AS minAddressOrder from (select ra.rxMasterID,case when ra.isdefault = 1 then 1
			when ra.isdefault=0 and ra.isMailing=1 then 2 when ra.isdefault=0 and ra.isMailing=0 and ra.isShipTo =1 then 3 else 4 end as addressOrder
			from rxAddress ra) as subquery group by rxMasterID)
			as minAddressOrders ON rxA.rxMasterID = minAddressOrders.rxMasterID AND rxA.addressOrder = minAddressOrders.minAddressOrder 
			where rxM.IsCategory2=1  and rxM.InActive=0 and (Name is not null and Name<>"") and length(rxA.rxAddressID)>0 ');
            if((_salesRep_value>0 and _salesRep_value<>'') )then
				set _sql=concat(_sql,'and ts.UserLoginId= ',_salesRep_value);
			end if;
  elseif(_myFilterValueId=7)then
	   set _sql=concat(_sql,'select ts.UserLoginID,rxM.rxMasterID,rxM.IsCategory4,rxM.InActive,if(length(rxM.Name)>0 ,rxM.Name,rxM.SearchName) as Name,rc4.rxMasterCategory4ID,rc4.cuAssignmentID0,ts.FullName as SalesRep,
			rxA.rxAddressID,rxA.addressOrder,rxA.IsDefault,rxA.IsMailing,rxA.IsShipTo,rxA.Address1,rxA.Address2,rxA.City,rxA.State,
			rxA.Zip,if(length(rxA.phone1)>0,rxA.Phone1,rxM.phone1) as Phone1 from rxMaster rxM 
			left join rxMasterCategory4 rc4 on rxM.rxMasterID = rc4.rxMasterCategory4ID  
			left join tsUserLogin ts on rc4.cuAssignmentID0 = ts.UserLoginID
			left join ( select ra.Address1,ra.Address2,ra.City,ra.State,ra.Zip,ra.Phone1,ra.IsDefault,ra.IsMailing,ra.IsShipTo,ra.rxMasterID,ra.rxAddressID,case when ra.IsDefault=1 then 1
			when ra.IsDefault=0 and ra.IsMailing=1 then 2 when ra.IsDefault=0 and IsMailing=0 and ra.IsShipTo=1 then 3 else 4 end as addressOrder 
			from rxAddress ra )as rxA on rxA.rxMasterID=rxM.rxMasterID 
			join(select rxMasterID, MIN(addressOrder) AS minAddressOrder from (select ra.rxMasterID,case when ra.isdefault = 1 then 1
			when ra.isdefault=0 and ra.isMailing=1 then 2 when ra.isdefault=0 and ra.isMailing=0 and ra.isShipTo =1 then 3 else 4 end as addressOrder
			from rxAddress ra) as subquery group by rxMasterID)
			as minAddressOrders ON rxA.rxMasterID = minAddressOrders.rxMasterID AND rxA.addressOrder = minAddressOrders.minAddressOrder 
			where rxM.IsCategory4=1  and rxM.InActive=0  and (Name is not null and Name<>"") and length(rxA.rxAddressID)>0 ');
            if((_salesRep_value>0 and _salesRep_value<>'') )then
				set _sql=concat(_sql,'and ts.UserLoginId= ',_salesRep_value);
			end if;
   elseif(_myFilterValueId in(2,3,6,8,9,10,11))then
		set _sql=concat(_sql,'select rxM.rxMasterID,rxM.IsVendor,rxM.IsEmployee,rxM.IsCategory3,rxM.IsCategory5,rxM.IsCategory6,
			rxM.IsCategory7,rxM.IsCategory8,rxM.InActive,if(length(rxM.Name)>0,rxM.Name,rxM.SearchName) as Name,null as SalesRep,
			rxA.rxAddressID,rxA.addressOrder,rxA.IsDefault,rxA.IsMailing,rxA.IsShipTo,rxA.Address1,rxA.Address2,rxA.City,rxA.State,
			rxA.Zip,if(length(rxA.phone1)>0,rxA.Phone1,rxM.phone1) as Phone1 from rxMaster rxM 
			left join ( select ra.Address1,ra.Address2,ra.City,ra.State,ra.Zip,ra.Phone1,ra.IsDefault,ra.IsMailing,ra.IsShipTo,
			ra.rxMasterID,ra.rxAddressID,case when ra.IsDefault=1 then 1 when ra.IsDefault=0 and ra.IsMailing=1 then 2 
			when ra.IsDefault=0 and IsMailing=0 and ra.IsShipTo=1 then 3 else 4 end as addressOrder 
			from rxAddress ra )as rxA on rxA.rxMasterID=rxM.rxMasterID 
			join(select rxMasterID, MIN(addressOrder) AS minAddressOrder from (select ra.rxMasterID,case when ra.isdefault = 1 then 1
			when ra.isdefault=0 and ra.isMailing=1 then 2 when ra.isdefault=0 and ra.isMailing=0 and ra.isShipTo =1 then 3 else 4 end as addressOrder
			from rxAddress ra) as subquery group by rxMasterID)
			as minAddressOrders on rxA.rxMasterID = minAddressOrders.rxMasterID and rxA.addressOrder = minAddressOrders.minAddressOrder 
			where  rxM.InActive=0 and (Name is not null and Name<>"") and length(rxA.rxAddressID)>0 ');
			set _and = ' AND ';
			if(_myFilterValueId = 2)then
				set _sql = concat(_sql, _and, ' rxM.IsVendor =', 1 );
			elseif(_myFilterValueId = 3)then
				set _sql = concat(_sql, _and, ' rxM.IsEmployee = ', 1 );
			elseif(_myFilterValueId = 6)then
				set _sql = concat(_sql, _and, 'rxM.IsCategory3 = ', 1 );
			elseif(_myFilterValueId = 8)then
				set _sql = concat(_sql, _and, ' rxM.IsCategory5 = ', 1 );
			elseif(_myFilterValueId = 9)then
				set _sql = concat(_sql, _and, ' rxM.IsCategory6 = ', 1 );
			elseif(_myFilterValueId = 10)then
				set _sql = concat(_sql, _and, ' rxM.IsCategory7 = ', 1 );
			elseif(_myFilterValueId = 11)then
				set _sql = concat(_sql, _and, ' rxM.IsCategory8 = ', 1 );
            end if;
  elseif(_myFilterValueId is null  and _salesRep_value is null )then
	set _sql=concat(_sql,'select rxM.rxMasterID,rxM.InActive,if(length(rxM.Name)>0 ,rxM.Name,rxM.SearchName) as Name,null as SalesRep,
			rxA.rxAddressID,rxA.addressOrder,rxA.IsDefault,rxA.IsMailing,rxA.IsShipTo,rxA.Address1,rxA.Address2,rxA.City,rxA.State,
			rxA.Zip,if(length(rxA.phone1)>0,rxA.Phone1,rxM.phone1) as Phone1 from rxMaster rxM 
			left join ( select ra.Address1,ra.Address2,ra.City,ra.State,ra.Zip,ra.Phone1,ra.IsDefault,ra.IsMailing,ra.IsShipTo,
			ra.rxMasterID,ra.rxAddressID,case when ra.IsDefault=1 then 1 when ra.IsDefault=0 and ra.IsMailing=1 then 2 
			when ra.IsDefault=0 and IsMailing=0 and ra.IsShipTo=1 then 3 else 4 end as addressOrder 
			from rxAddress ra )as rxA on rxA.rxMasterID=rxM.rxMasterID 
			join(select rxMasterID, MIN(addressOrder) AS minAddressOrder from (select ra.rxMasterID,case when ra.isdefault = 1 then 1
			when ra.isdefault=0 and ra.isMailing=1 then 2 when ra.isdefault=0 and ra.isMailing=0 and ra.isShipTo =1 then 3 else 4 end as addressOrder
			from rxAddress ra) as subquery group by rxMasterID)
			as minAddressOrders ON rxA.rxMasterID = minAddressOrders.rxMasterID AND rxA.addressOrder = minAddressOrders.minAddressOrder 
			where rxM.InActive=0 and (Name is not null and Name<>"") and length(rxA.rxAddressID)>0 ');
  elseif(_myFilterValueId is null  and (_salesRep_value>0 and _salesRep_value <> '') )then
	set _sql=concat(_sql,'select rxM.rxMasterID,rxM.IsCustomer,rxM.IsCategory1,rxM.IsCategory2,rxM.IsCategory4,rxM.InActive,if(length(rxM.Name)>0 ,rxM.Name,rxM.SearchName) as Name, 
			SalesRepVal.FullName as SalesRep,SalesRepVal.UserLoginID,rxA.rxAddressID,rxA.addressOrder,rxA.IsDefault,rxA.IsMailing,rxA.IsShipTo,rxA.Address1,rxA.Address2,rxA.City,rxA.State,
			rxA.Zip,if(length(rxA.phone1)>0,rxA.Phone1,rxM.phone1) as Phone1 from rxMaster rxM
			left join (select cu.cuMasterID as rxId,ts.UserLoginID,cu.cuAssignmentID0,ts.FullName from cuMaster cu
						left join tsUserLogin ts on cu.cuAssignmentID0=ts.UserloginID union 
						select rc1.rxMasterCategory1ID as rxId,ts.UserLoginID,rc1.cuAssignmentID0,ts.FullName from rxMasterCategory1 rc1
						left join tsUserLogin ts on rc1.cuAssignmentID0=ts.UserloginID union 
						select rc2.rxMasterCategory2ID as rxId,ts.UserLoginID,rc2.cuAssignmentID0,ts.FullName from rxMasterCategory2 rc2
						left join tsUserLogin ts on rc2.cuAssignmentID0=ts.UserloginID union
						select rc4.rxMasterCategory4ID as rxId,ts.UserLoginID,rc4.cuAssignmentID0,ts.FullName from rxMasterCategory4 rc4
						left join tsUserLogin ts on rc4.cuAssignmentID0=ts.UserloginID
			) as SalesRepVal on rxM.rxMasterID=SalesRepVal.rxId
			 left join ( select ra.Address1,ra.Address2,ra.City,ra.State,ra.Zip,ra.Phone1,ra.IsDefault,ra.IsMailing,ra.IsShipTo,ra.rxMasterID,ra.rxAddressID,case when ra.IsDefault=1 then 1
						when ra.IsDefault=0 and ra.IsMailing=1 then 2 when ra.IsDefault=0 and IsMailing=0 and ra.IsShipTo=1 then 3 else 4 end as addressOrder 
						from rxAddress ra )as rxA on rxA.rxMasterID=rxM.rxMasterID 
						join(select rxMasterID, MIN(addressOrder) AS minAddressOrder from (select ra.rxMasterID,case when ra.isdefault = 1 then 1
						when ra.isdefault=0 and ra.isMailing=1 then 2 when ra.isdefault=0 and ra.isMailing=0 and ra.isShipTo =1 then 3 else 4 end as addressOrder
						from rxAddress ra) as subquery group by rxMasterID)
						as minAddressOrders ON rxA.rxMasterID = minAddressOrders.rxMasterID AND rxA.addressOrder = minAddressOrders.minAddressOrder    
			where 1 in (rxM.IsCategory1,rxM.IsCategory2,rxM.IsCategory4,rxM.IsCustomer) and rxM.InActive=0 and (Name is not null and Name<>"") and length(rxA.rxAddressID)>0 and SalesRepVal.UserLoginId= ',_salesRep_value);
 end if;
    set _sql=concat(_sql,') as test ');  
end if;



select myFilterValueId into _sortByMyFilterName from REPORT_myFilters where myFilterName = "Sort By" and myReportId = _reportId;
select myFilterValueId into @_CategoryVal from REPORT_myFilters where myFilterName = "Category" and myReportId = _reportId;
 if(_sortByMyFilterName = "Category")then
	if(@_CategoryVal='1') then
		set _sortByMyFilterName='IsCustomer';
    elseif(@_CategoryVal='2') then
		set _sortByMyFilterName='IsVendor';
    elseif(@_CategoryVal='3') then
		set _sortByMyFilterName='IsEmployee';
    elseif(@_CategoryVal='4') then
		set _sortByMyFilterName='IsCategory1';
    elseif(@_CategoryVal='5') then
		set _sortByMyFilterName='IsCategory2';
    elseif(@_CategoryVal='6') then
		set _sortByMyFilterName='IsCategory3';
    elseif(@_CategoryVal='7') then  
		set _sortByMyFilterName='IsCategory4';    
	elseif(@_CategoryVal='8') then
		set _sortByMyFilterName='IsCategory5';
    elseif(@_CategoryVal='9') then
		set _sortByMyFilterName='IsCategory6';
    elseif(@_CategoryVal='10') then
		set _sortByMyFilterName='IsCategory7';
    elseif(@_CategoryVal='11') then
		set _sortByMyFilterName='IsCategory8';
    end if;    
 end if;       
set _sql = concat(_sql, ' order by test.', _sortByMyFilterName , ' asc'); 
set _sql = concat(_sql, ';');

RETURN _sql;
END$$

DELIMITER ;


-- ========================================================================
DROP function IF EXISTS `REPORT_build_Quoted_Jobs`;

DELIMITER $$

CREATE  FUNCTION `REPORT_build_Quoted_Jobs`(_reportId INT) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _and varchar(25);
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _sql longtext;
DECLARE _filterName varchar(50);
DECLARE _myFilterValueId varchar(50);
DECLARE _myFilterValueText varchar(50);
DECLARE _myFilterValueCurrency varchar(50);
DECLARE _dateFrom Date;
DECLARE _dateTo Date;
DECLARE _dateFilterValueId INT;

select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Quoted Jobs";

select myFilterValueDateFrom,myFilterValueDateTo,myFilterValueId
into _dateFrom,_dateTo,_dateFilterValueId from REPORT_myFilters m
where m.myReportId = _reportId and m.myFilterName='Month Date Ending' or m.myFilterName='Year Date Ending' or m.myFilterName='Date Range' or m.myFilterName='Single Date';


if(_myFilterValueId='Division') then
	set _sql='select a.BidYear, a.BidMonth,a.Division,count(distinct(Quotes)) AS Quotes, sum(a.TotalAmount) AS TotalAmount from (SELECT YEAR(BidDate) AS BidYear,
    MONTH(BidDate) AS BidMonth,Division, concat(JobNumber,QuoteType) AS Quotes,QuoteAmount AS TotalAmount FROM SalesActivityView WHERE ';
	set _filterName='Division';
    
elseif(_myFilterValueId='Take-Off Name') then
    set _sql='select a.BidYear, a.BidMonth,a.TakeOffName,count(distinct(Quotes)) AS Quotes , sum(a.TotalAmount) AS TotalAmount from (SELECT YEAR(BidDate) AS BidYear,
	MONTH(BidDate) AS BidMonth,TakeOffName, concat(JobNumber,QuoteType) AS Quotes,QuoteAmount AS TotalAmount FROM SalesActivityView WHERE ';        
    set  _filterName='TakeOffName';
    
elseif(_myFilterValueId='Bid Status') then
    set _sql='select a.BidYear, a.BidMonth,a.BidStatusDescription,count(distinct(Quotes)) AS Quotes, sum(a.TotalAmount) AS TotalAmount from (SELECT YEAR(BidDate) AS BidYear,
    MONTH(BidDate) AS BidMonth,BidStatusDescription, concat(JobNumber,QuoteType) AS Quotes,QuoteAmount AS TotalAmount FROM SalesActivityView WHERE ';         
    set _filterName='BidStatusDescription';
    
elseif(_myFilterValueId='Job Status')then
	set _sql='select a.BidYear, a.BidMonth,a.JobStatus,count(distinct(Quotes)) AS Quotes, sum(a.TotalAmount) AS TotalAmount from (SELECT YEAR(BidDate) AS BidYear,
    MONTH(BidDate) AS BidMonth,JobStatus, concat(JobNumber,QuoteType) AS Quotes,QuoteAmount AS TotalAmount FROM SalesActivityView WHERE ';
    set _filterName='JobStatus';
    
elseif(_myFilterValueId='Created By')then
    set _sql='select a.BidYear, a.BidMonth,a.CreatedBy,count(distinct(Quotes)) AS Quotes, sum(a.TotalAmount) AS TotalAmount from (SELECT YEAR(BidDate) AS BidYear,
    MONTH(BidDate) AS BidMonth,CreatedBy, concat(JobNumber,QuoteType) AS Quotes,QuoteAmount AS TotalAmount FROM SalesActivityView WHERE ';          
    set _filterName='CreatedBy';
    
elseif(_myFilterValueId='Quote Type')then
	set _sql='select a.BidYear, a.BidMonth,a.QuoteType,count(distinct(Quotes)) AS Quotes, sum(a.TotalAmount) AS TotalAmount from (SELECT YEAR(BidDate) AS BidYear,
    MONTH(BidDate) AS BidMonth,QuoteType, concat(JobNumber,QuoteType) AS Quotes,QuoteAmount AS TotalAmount FROM SalesActivityView WHERE ';           
    set _filterName='QuoteType';
    
elseif(_myFilterValueId='Bidder')then
	set _sql='select a.BidYear, a.BidMonth,a.BidderName,count(distinct(Quotes)) AS Quotes, sum(a.TotalAmount) AS TotalAmount from (SELECT YEAR(BidDate) AS BidYear,
    MONTH(BidDate) AS BidMonth,BidderName, concat(JobNumber,QuoteType) AS Quotes,QuoteAmount AS TotalAmount FROM SalesActivityView WHERE '; 
    set _filterName='BidderName';
    
elseif(_myFilterValueId='Name')then 
	set _sql='select a.BidYear, a.BidMonth,a.SalesRepName,count(distinct(Quotes)), sum(a.TotalAmount) from (SELECT YEAR(BidDate) AS BidYear,
    MONTH(BidDate) AS BidMonth,SalesRepName, concat(JobNumber,QuoteType) AS Quotes,QuoteAmount AS TotalAmount FROM SalesActivityView WHERE 
    SalesRepName IN (SELECT ts.FullName from tsUserLogin ts left join joMaster j on ts.UserLoginID=j.cuAssignmentID0) '; 
    set _filterName='SalesRepName';
    
end if;

if(_dateFilterValueId=0) then
	set _sql=concat(_sql,'Year(BidDate) =',Year(_dateFrom) ,' ','and Month(BidDate) =',Month(_dateFrom),' ','and day(BidDate)=',Day(_dateFrom),' ');
elseif(_dateFilterValueId in (1,2,3))then
	set _sql=concat(_sql,'Year(BidDate) >=',Year(_dateFrom),' ','and Month(BidDate) >=',Month(_dateFrom),' ','and day(BidDate)>=',Day(_dateFrom),' ');
	set _sql=concat(_sql,'and Year(BidDate) <=',Year(_dateTo),' ','and Month(BidDate) <=',Month(_dateTo),' ','and day(BidDate)<=',Day(_dateTo),' ');
 end if;


set _sql=concat(_sql,'group by joQuoteHeaderID ORDER BY YEAR(BidDate)) as a  group by a.', _filterName ); 
-- set _sql = concat(_sql, 'group by joQuoteHeaderID' ,' ORDER BY YEAR(BidDate) ',';');

RETURN _sql;
END$$

DELIMITER ;

-- ========================================================================

DROP function IF EXISTS `REPORT_build_Quoted_Jobs_Details`;

DELIMITER $$
CREATE DEFINER=`root`@`%` FUNCTION `REPORT_build_Quoted_Jobs_Details`(_reportId INT) RETURNS text CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE _reports varchar(500);
DECLARE _aReportId int;
DECLARE _sql longtext;
DECLARE _filterName varchar(50);
DECLARE _myFilterValueId varchar(50);
DECLARE _myFilterValueText varchar(50);
DECLARE _dateFrom Date;
DECLARE _dateTo Date;
DECLARE _dateFilterValueId INT;
DECLARE _SalesrepCategory  varchar(256);
DECLARE _CostingCategory  varchar(256);
DECLARE _TakeOffCategory  varchar(256);
DECLARE _architect varchar(256);
DECLARE _engineer varchar(256);


    
select myFilterValueDateFrom,myFilterValueDateTo,myFilterValueId
into _dateFrom,_dateTo,_dateFilterValueId from REPORT_myFilters m
where m.myReportId = _reportId and m.myFilterName='Month Date Ending' or m.myFilterName='Year Date Ending' or m.myFilterName='Date Range' or m.myFilterName='Single Date';

select Category into _SalesrepCategory from jocategory where Category="Salesrep";
select Category into _CostingCategory from jocategory where Category="Costing";
select Category into _TakeOffCategory from jocategory where Category="Take-Off";
select rxMasterCategory1Desc,rxMasterCategory2Desc into _architect,_engineer from sysInfo ;
 
set  _sql='Select DATE_FORMAT(jm.BidDate, "%m/%d/%Y") as "Bid Date",jm.JobNumber as "Job #",jm.Description as "Job Name" ';
if(_SalesrepCategory='Salesrep') then
	set _sql=concat(_sql,' ,ts1.FullName as ',_SalesrepCategory);
end if; 
if(_CostingCategory='Costing') then
	set _sql=concat(_sql,' ,ts2.FullName as ',_CostingCategory);
end if;
if(_TakeOffCategory='Take-Off') then
	set _sql=concat(_sql,' ,ts3.FullName as ', "TakeOff" );
end if;

set _sql=concat(_sql,' ,js.JobStatus as "Status",jbs.Description as "Bid Status" ');

if(_architect='Architect') then
	set _sql=concat(_sql,' ,rxm1.Name  as ',_architect);
end if;
if(_engineer='Engineer') then
	set _sql=concat(_sql,' ,rxm2.Name  as ',_engineer);
end if;

                
set _sql=concat(_sql,' ,rxm3.Name as "Bidder",concat(rc.FirstName," ",rc.LastName) as "Bidder Contact",ts6.FullName as "Bidder Salesrep",
                concat(cmt.Code,jq.QuoteRev) as "Quote Type",DATE_FORMAT(jq.QuoteDate, "%m/%d/%Y") as "Quoted Date",quoteAmount as "Amount"
				from joMaster jm
				left join tsUserLogin ts1 on jm.cuAssignmentID0=ts1.UserLoginID 
				left join tsUserLogin ts2 on jm.cuAssignmentID2=ts2.UserLoginID
				left join tsUserLogin ts3 on jm.cuAssignmentID5=ts3.UserLoginID
				left join joStatus js on jm.JobStatus=js.joStatusID
				left join joBidStatus jbs on jm.joBidStatusID=jbs.joBidStatusID   
				left join coDivision cd on jm.coDivisionID=cd.coDivisionID        
				left join joChange jc on jm.joMasterID=jc.joMasterID
				left join rxMaster rxm1 on jm.rxCategory1=rxm1.rxMasterID 
				left join rxMasterCategory1 rxmc1 on jm.rxCategory1=rxmc1.rxMasterCategory1ID
				left join  tsUserLogin ts4 on rxmc1.cuAssignmentID0=ts4.UserLoginID
				left join rxMaster rxm2 on jm.rxCategory2=rxm2.rxMasterID        
				left join rxMasterCategory2 rxmc2 on jm.rxCategory2=rxmc2.rxMasterCategory2ID   
				left join tsUserLogin ts5 on rxmc2.cuAssignmentID0=ts5.UserLoginID				 
				left join joQuoteHistory jq on jm.joMasterID=jq.joMasterID
				left join rxMaster rxm3 on jq.rxMasterID=rxm3.rxMasterID       
				left join cuMaster cm on rxm3.rxMasterID=cm.cuMasterID
				left join tsUserLogin ts6 on cm.cuAssignmentID0=ts6.UserLoginID
				left join rxContact rc on jq.rxContactID=rc.rxContactID
				left join cuMasterType cmt on jq.quoteTypeID=cmt.cuMasterTypeID
				where jm.joMasterID is not null and jq.joMasterID is not null  ');
			/*left join joBidder jb on jm.joMasterID=jb.joMasterID
                left join tsUserLogin ts7 on jb.UserLoginID=ts7.UserLoginID
				left join tsUserLogin ts8 on jb.UserLoginID=ts8.UserLoginID*/

  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Division";
  if(_myFilterValueId is not null and _myFilterValueId <>'' and _myFilterValueId!=0) then
	 set _sql=concat(_sql,'and jm.coDivisionID=',_myFilterValueId,' ');

  end if;
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Quote Type";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and jq.quoteTypeID=',_myFilterValueId,' ');
     
  end if;
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Bidder Assignment";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and ts6.UserLoginID=',_myFilterValueId,' ');
  end if;
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Bidder";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and jq.rxMasterID=',_myFilterValueId,' ');
  end if; 
  
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Job Status";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and jm.JobStatus=',_myFilterValueId,' ');
  end if;
  
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Engineer";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and jm.rxCategory2=',_myFilterValueId,' ');
  end if;
  
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Engineer Assignment";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and rxmc2.cuAssignmentID0=',_myFilterValueId,' ');
  end if;
  
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Salesrep";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and ts1.UserLoginID=',_myFilterValueId,' ');
  end if;
  
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Architect";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and jm.rxCategory1=',_myFilterValueId,' ');
  end if;
  
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Architect Assignment";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and rxmc1.cuAssignmentID0=',_myFilterValueId,' ');
  end if;
  
  select myFilterValueId into _myFilterValueId from REPORT_myFilters where myReportID = _reportId and myFilterName = "Status Type";
  if(_myFilterValueId is not null and _myFilterValueId <>'') then
	 set _sql=concat(_sql,' and jm.joBidStatusID=',_myFilterValueId,' ');
  end if;

  if(_dateFilterValueId=0) then
	set _sql=concat(_sql,' and Date(jm.BidDate)= \'',Date(_dateFrom),'\' ');
 elseif(_dateFilterValueId in (1,2,3))then
	set _sql=concat(_sql ,' and Date(jm.BidDate) Between \'',Date(_dateFrom),'\' and \'',Date(_dateTo),'\' ');
 end if;  
 
  set _sql=concat(_sql,' order by jm.BidDate,jm.jobNumber  asc;  ');
  
  
RETURN _sql;
END$$

DELIMITER ;

-- ========================================================================
