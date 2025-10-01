
-- ==================================================================
/*
call TEST_manager('CLEAN-ALL',null,null);
call TEST_manager('RUN-ALL',null,3);
call TEST_manager('RESULTS',null,null);


call TEST_manager('RUN','CARD_so_void_out_ticket',null);
call TEST_manager('RUN','CARD_so_onhold_to_open',null);
call TEST_manager('RUN','CARD_so_ticket_invoice_full',1);
call TEST_manager('RUN','CARD_so_ticket_invoice_partial',1);

call TEST_manager('RUN','CARD_submittal_create_new',1);

-- to be written below:

call TEST_manager('RUN','CARD_signature_??',1);
call TEST_manager('RUN','CARD_quote_note_??',1);
call TEST_manager('RUN','CARD_batch_email_??',1);

call TEST_manager('RUN','CARD_so_delete_noJob',1); -- vinay failing?
call TEST_manager('RUN','CARD_so_update_product_noJob',1); -- vinay failing?
call TEST_manager('RUN','CARD_so_delete_job',1); -- vinay failing?
call TEST_manager('RUN','CARD_so_update_product_job',1); -- vinay failing?

call TEST_manager('RUN','CARD_so_multiple_invoice_partial',null);
call TEST_manager('RUN','CARD_so_negative',null);


call TEST_manager('RUN','CARD_ticket_invoice_all',null);
call TEST_manager('RUN','CARD_ticket_invoice_partial',null);
call TEST_manager('RUN','CARD_ticket_invoice_partial_invoice_final',null);


-- ADD NEW CARD HERE

*/
-- ==================================================================


-- ==================================================================
-- TESTING CARDS ===================================================
-- ==================================================================
DROP procedure IF EXISTS `TEST_card`;

DELIMITER $$
CREATE PROCEDURE `TEST_card`(IN _action varchar(100), _batch varchar(100), _card varchar(100), _DEBUG tinyint )
TEST_card: BEGIN

-- TEST CONDITIONS
DECLARE _condition1 tinyint default 0;
DECLARE _condition2 tinyint default 0;
DECLARE _condition3 tinyint default 0;
DECLARE _condition4 tinyint default 0;
DECLARE _condition5 tinyint default 0;
DECLARE _condition6 tinyint default 0;
DECLARE _condition7 tinyint default 0;
DECLARE _condition8 tinyint default 0;
DECLARE _output text DEFAULT '';
DECLARE _executionStart time;
DECLARE _executionEnd time;

DECLARE _freight  decimal(19,4);

-- ==================================================================
-- call TEST_card(null,null,null,null); 
-- call TEST_card('CLEANUP',1,null,null); 
-- call TEST_card('RUN',1,'name of card or cards',null); 
-- ==================================================================

    IF (_action = 'CLEANUP' ) THEN
		call TEST_cardSetup('DELETE',_batch,null,_DEBUG); 
        Leave TEST_card;
	END IF;

    IF (_action = 'RUN' ) THEN
 
		if (_DEBUG=1) THEN
			select concat('RUN ',_card) as _card,_batch;
        END IF;

		insert into TEST_results (batch,card,startTime) values (_batch,_card,now());



-- ===============================================
-- CARD ????
-- call TEST_manager('RUN','?????',1);
-- author: DLR
-- ===============================================
-- << new card instructions >>
-- 1. copy a card below that is similar to the test.
-- 2. Modifications to call TEST_cardSetup('CREATE',_batch,'BASETABLES,???',_DEBUG); to handle table setup
-- 3. Modifications to TEST_Id('GET','cuSODetailID1',null,null); to create ID's not yet supported.
-- 4. Modifications to set _output = concat(_output, TEST_output ('Bin','\t','','',_batch)); for formatted output



-- ===============================================
-- CARD CARD_so_ticket_invoice_partial
-- call TEST_manager('RUN','CARD_so_ticket_invoice_partial',1);
-- author: DLR
-- ===============================================
		IF (_card = 'CARD_so_ticket_invoice_partial' ) THEN
 	
			-- TABLE SETUP FOR TEST
            call TEST_cardSetup('CREATE',_batch,'BASETABLES,CUSO',_DEBUG);

            -- ==================================================
            -- DATA ADJUSTMENT FOR TEST
            -- ==================================================
			update bin set InventoryOnHand=100,InventoryAllocated=15,AverageCost=10 where binId = TEST_Id('GET','fromBinID1',null,null);
			update bin set InventoryOnHand=100,InventoryAllocated=15,AverageCost=10 where binId = TEST_Id('GET','fromBinID2',null,null);
            
            set _freight =10;
            update cuSO set Freight=_freight where cuSOID =  TEST_Id('GET','cuSOID1',null,null);
			update cuSODetail set QuantityOrdered=150,UnitCost=10,Taxable=1 where cuSODetailID = TEST_Id('GET','cuSODetailID1',null,null);
            -- ==================================================

			set _output = concat(_output,'\n',_card,' ',_batch,'\n');
			set _output = concat(_output,'\n================RUN SETUP==============\n\n');

			set _output = concat(_output, TEST_output ('Bin','\t','','',_batch));
			set _output = concat(_output, TEST_output ('cuSO','\t','','',_batch));

			set _output = concat(_output,'\n================RUN TEST==============\n\n');
            
 -- select _output;

			-- RUN TEST ==================================================
            
            set _executionStart = now();
			call INV_updateInventoryOH('SALESORDER',null,null,null,null,'REFERENCE','REASON',null,null,TEST_Id('GET','cuSODetailID1',null,null),null,TEST_Id('GET','userId',null,null));
            set _executionEnd = now();

			set _output = concat(_output,'\t','call INV_updateInventoryOH(\'SALESORDER\',null,null,null,null,\'REFERENCE\',\'REASON\',null,null,',TEST_Id('GET','cuSODetailID1',null,null),',null,',TEST_Id('GET','userId',null,null),');',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');

-- select _output;

			set _output = concat(_output, TEST_output ('Bin','\t\t','','',_batch));
			set _output = concat(_output, TEST_output ('cuSODetailBin','\t\t','','',_batch));

--  select _output;			
            set _executionStart = now();
            call INV_createPickTicket_v2('CREATE',TEST_Id('GET','cuSOID1',null,null),_DEBUG );
            set _executionEnd = now();

			set _output = concat(_output,'\n\t','call INV_createPickTicket_v2(\'CREATE\',',TEST_Id('GET','cuSOID1',null,null),',_DEBUG);',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');
			set _output = concat(_output, TEST_output ('cuSODetailTicket','\t\t','','',_batch));
            
--  select _output;
			set _executionStart = now();
			call INVOICE_updateInvoice('UPDATE',null,TEST_Id('GET','cuSOID1',null,null), null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,TEST_Id('GET','coDivisionID',null,null), null, null, TEST_Id('GET','coTaxTerritoryID',null,null), TEST_Id('GET','cuTermsID',null,null), null,TEST_Id('GET','userID',null,null),_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null );
            set _executionEnd = now();

			select TEST_Id('SET','cuInvoiceID1','cuSOID1',_batch);
            
			set _output = concat(_output,'\n\t','call INVOICE_updateInvoice(\'UPDATE\',null,',TEST_Id('GET','cuSODetailID1',null,null),', null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,',TEST_Id('GET','coDivisionID',null,null),', null, null,',TEST_Id('GET','coTaxTerritoryID',null,null),',',TEST_Id('GET','cuTermsID',null,null),', null,',TEST_Id('GET','userID',null,null),',',_freight,',null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');

			set _output = concat(_output, TEST_output ('cuInvoice','\t\t','','',_batch));
                            
 -- select _output;
			set _executionStart = now();
			call INVOICE_updateInvoiceDetail('UPDATE',TEST_Id('GET','cuInvoiceID1',null,_batch),null,TEST_Id('GET','cuSODetailID1',null,_batch),null,null,100,10,1,1,null,null,TEST_Id('GET','userID',null,_batch));
            set _executionEnd = now();
			set _output = concat(_output,'\n\t','call INVOICE_updateInvoiceDetail(\'UPDATE\',',TEST_Id('GET','cuInvoiceID1',null,_batch),',null,',TEST_Id('GET','cuSODetailID1',null,_batch),',null,null,100,10,1,1,null,null,',TEST_Id('GET','userID',null,_batch),');',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');

			set _output = concat(_output, TEST_output ('cuInvoiceDetail','\t\t','','',_batch));
            
 -- select _output;
			set _executionStart = now();
			call INVOICE_recalculate('CUSTOMERINVOICE',TEST_Id('GET','cuInvoiceID1',null,_batch),0,TEST_Id('GET','userID',null,_batch),null,0,0,0,0,0);
            set _executionEnd = now();
			set _output = concat(_output,'\n\t','call INVOICE_recalculate(\'CUSTOMERINVOICE\',',TEST_Id('GET','cuInvoiceID1',null,_batch),',0,',TEST_Id('GET','userID',null,_batch),',null,0,0,0,0,0);',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');
           
			set _output = concat(_output, TEST_output ('cuInvoice','\t\t','','',_batch));
 
			set _executionStart = now();
            call INV_createPickTicket_v2('INVOICE',TEST_Id('GET','cuSOID1',null,null),_DEBUG );
            set _executionEnd = now();

			set _output = concat(_output,'\n\t','call INV_createPickTicket_v2(\'INVOICE\',',TEST_Id('GET','cuSOID1',null,null),',_DEBUG);',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');
			set _output = concat(_output, TEST_output ('cuSODetailTicket','\t\t','','',_batch));
 
 -- select _output;
				
            -- END TEST ==================================================

			-- ==================================================
			-- EVALUATE RESULTS
			-- ==================================================
/*

15.0000	15.0000
85.0000	65.0000

1 joRelease 1645.4000
*/
			select count(*) into _condition1 from bin where binId=TEST_Id('GET','fromBinID1',null,null) and InventoryOnHand=15 and InventoryAllocated=15;
			select count(*) into _condition2 from bin where binId=TEST_Id('GET','fromBinID2',null,null) and InventoryOnHand=85 and InventoryAllocated=65;        
			-- select count(*) into _condition3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 124.5800 and veBillID=TEST_Id('GET','cuInvoiceID1',null,_batch);        
			-- select count(*) into _condition4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1634.5800 and veBillID=TEST_Id('GET','cuInvoiceID1',null,_batch);        
			-- select count(*) into _condition5 from cuSODetailTicket where cuSODetailId=TEST_Id('GET','cuSOID1',null,null) and binId=TEST_Id('GET','fromBinID2',null,null) and ticketStatus=1;        

			set _output = concat(_output,'\n================POST RUN RESULTS==============\n\n');
			set _output = concat(_output,'\t',' Expected _condition1:Bin=',TEST_Id('GET','fromBinID1',null,null),' InventoryOnHand=15 and InventoryAllocated=15','\n');
			set _output = concat(_output,'\t',' Expected _condition2:Bin=',TEST_Id('GET','fromBinID2',null,null),' InventoryOnHand=85 and InventoryAllocated=65','\n');
			-- set _output = concat(_output,'\t',' Expected _condition3:glTransaction= g.credit = 124.5800','\n');
			-- set _output = concat(_output,'\t',' Expected _condition4:glTransaction= g.debit = 1634.5800','\n');
			-- set _output = concat(_output,'\t',' Expected _condition5:cuSODetailTicket cuSODetailId=',TEST_Id('GET','cuSOID1',null,null),' and binId=',TEST_Id('GET','fromBinID2',null,null),' and ticketStatus=1','\n\n');

			set _output = concat(_output,'\n');
			
            set _output = concat(_output,'\t',' _condition1=',_condition1,' _condition2=',_condition2,'\n');

-- select _output;
			
			if (_condition1 = 1 and _condition2 = 1 ) THEN
				set _output = concat(_output,'\n\t',' PASS','\n');
				update TEST_results set passFail='PASS'  where batch=_batch and card=_card;
			ELSE
				set _output = concat(_output,'\n\t',' FAIL','\n');
				update TEST_results set passFail='FAIL'  where batch=_batch and card=_card;
			END IF;   

-- select _output;

			set _output = concat(_output,'\n');
			set _output = concat(_output, TEST_output ('Bin','\t','Actual','',_batch));
			set _output = concat(_output, TEST_output ('cuInvoice','\t','Actual','',_batch));
			set _output = concat(_output, TEST_output ('glTransaction','\t','Actual','',_batch));
            			            
        END IF; -- END CARD
        


-- ===============================================
-- CARD CARD_so_ticket_invoice_full
-- call TEST_manager('RUN','CARD_so_ticket_invoice_full',1);
-- author: DLR
-- ===============================================
		IF (_card = 'CARD_so_ticket_invoice_full' ) THEN
 	
			-- TABLE SETUP FOR TEST
            call TEST_cardSetup('CREATE',_batch,'BASETABLES,CUSO',_DEBUG);

            -- ==================================================
            -- DATA ADJUSTMENT FOR TEST
            -- ==================================================
			update bin set InventoryOnHand=100,InventoryAllocated=15,AverageCost=10 where binId = TEST_Id('GET','fromBinID1',null,null);
			update bin set InventoryOnHand=100,InventoryAllocated=15,AverageCost=10 where binId = TEST_Id('GET','fromBinID2',null,null);
            
            set _freight =10;
            update cuSO set Freight=_freight where cuSOID =  TEST_Id('GET','cuSOID1',null,null);
			update cuSODetail set QuantityOrdered=150,UnitCost=10,Taxable=1 where cuSODetailID = TEST_Id('GET','cuSODetailID1',null,null);
            -- ==================================================

			set _output = concat(_output,'\n',_card,' ',_batch,'\n');
			set _output = concat(_output,'\n================RUN SETUP==============\n\n');

			set _output = concat(_output, TEST_output ('Bin','\t','','',_batch));
			set _output = concat(_output, TEST_output ('cuSO','\t','','',_batch));

			set _output = concat(_output,'\n================RUN TEST==============\n\n');
            
 -- select _output;

			-- RUN TEST ==================================================
            
            set _executionStart = now();
			call INV_updateInventoryOH('SALESORDER',null,null,null,null,'REFERENCE','REASON',null,null,TEST_Id('GET','cuSODetailID1',null,null),null,TEST_Id('GET','userId',null,null));
            set _executionEnd = now();

			set _output = concat(_output,'\t','call INV_updateInventoryOH(\'SALESORDER\',null,null,null,null,\'REFERENCE\',\'REASON\',null,null,',TEST_Id('GET','cuSODetailID1',null,null),',null,',TEST_Id('GET','userId',null,null),');',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');

-- select _output;

			set _output = concat(_output, TEST_output ('Bin','\t\t','','',_batch));
			set _output = concat(_output, TEST_output ('cuSODetailBin','\t\t','','',_batch));

--  select _output;			
            set _executionStart = now();
            call INV_createPickTicket_v2('CREATE',TEST_Id('GET','cuSOID1',null,null),_DEBUG );
            set _executionEnd = now();

			set _output = concat(_output,'\n\t','call INV_createPickTicket_v2(\'CREATE\',',TEST_Id('GET','cuSOID1',null,null),',_DEBUG);',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');
			set _output = concat(_output, TEST_output ('cuSODetailTicket','\t\t','','',_batch));
            
--  select _output;
			set _executionStart = now();
			call INVOICE_updateInvoice('UPDATE',null,TEST_Id('GET','cuSOID1',null,null), null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,TEST_Id('GET','coDivisionID',null,null), null, null, TEST_Id('GET','coTaxTerritoryID',null,null), TEST_Id('GET','cuTermsID',null,null), null,TEST_Id('GET','userID',null,null),_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null );
            set _executionEnd = now();

			select TEST_Id('SET','cuInvoiceID1','cuSOID1',_batch);
            
			set _output = concat(_output,'\n\t','call INVOICE_updateInvoice(\'UPDATE\',null,',TEST_Id('GET','cuSODetailID1',null,null),', null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,',TEST_Id('GET','coDivisionID',null,null),', null, null,',TEST_Id('GET','coTaxTerritoryID',null,null),',',TEST_Id('GET','cuTermsID',null,null),', null,',TEST_Id('GET','userID',null,null),',',_freight,',null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');

			set _output = concat(_output, TEST_output ('cuInvoice','\t\t','','',_batch));
                            
 -- select _output;
			set _executionStart = now();
			call INVOICE_updateInvoiceDetail('UPDATE',TEST_Id('GET','cuInvoiceID1',null,_batch),null,TEST_Id('GET','cuSODetailID1',null,_batch),null,null,150,10,1,1,null,null,TEST_Id('GET','userID',null,_batch));
            set _executionEnd = now();
			set _output = concat(_output,'\n\t','call INVOICE_updateInvoiceDetail(\'UPDATE\',',TEST_Id('GET','cuInvoiceID1',null,_batch),',null,',TEST_Id('GET','cuSODetailID1',null,_batch),',null,null,150,10,1,1,null,null,',TEST_Id('GET','userID',null,_batch),');',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');

			set _output = concat(_output, TEST_output ('cuInvoiceDetail','\t\t','','',_batch));
            
 -- select _output;
			set _executionStart = now();
			call INVOICE_recalculate('CUSTOMERINVOICE',TEST_Id('GET','cuInvoiceID1',null,_batch),0,TEST_Id('GET','userID',null,_batch),null,0,0,0,0,0);
            set _executionEnd = now();
			set _output = concat(_output,'\n\t','call INVOICE_recalculate(\'CUSTOMERINVOICE\',',TEST_Id('GET','cuInvoiceID1',null,_batch),',0,',TEST_Id('GET','userID',null,_batch),',null,0,0,0,0,0);',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');
           
			set _output = concat(_output, TEST_output ('cuInvoice','\t\t','','',_batch));
           
 -- select _output;
				
            -- END TEST ==================================================

			-- ==================================================
			-- EVALUATE RESULTS
			-- ==================================================
/*
4 gl's
0.0000	1500.0000
0.0000	125.4000
0.0000	20.0000
1645.4000	0.0000

15.0000	15.0000
35.0000	15.0000

1 joRelease 1645.4000
*/
			select count(*) into _condition1 from bin where binId=TEST_Id('GET','fromBinID1',null,null) and InventoryOnHand=15 and InventoryAllocated=15;
			select count(*) into _condition2 from bin where binId=TEST_Id('GET','fromBinID2',null,null) and InventoryOnHand=35 and InventoryAllocated=15;        
			select count(*) into _condition3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 124.5800 and veBillID=TEST_Id('GET','cuInvoiceID1',null,_batch);        
			select count(*) into _condition4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1634.5800 and veBillID=TEST_Id('GET','cuInvoiceID1',null,_batch);        
			-- select count(*) into _condition5 from cuSODetailTicket where cuSODetailId=TEST_Id('GET','cuSOID1',null,null) and binId=TEST_Id('GET','fromBinID2',null,null) and ticketStatus=1;        

			set _output = concat(_output,'\n================POST RUN RESULTS==============\n\n');
			set _output = concat(_output,'\t',' Expected _condition1:Bin=',TEST_Id('GET','fromBinID1',null,null),' InventoryOnHand=15 and InventoryAllocated=15','\n');
			set _output = concat(_output,'\t',' Expected _condition2:Bin=',TEST_Id('GET','fromBinID2',null,null),' InventoryOnHand=35 and InventoryAllocated=15','\n');
			set _output = concat(_output,'\t',' Expected _condition3:glTransaction= g.credit = 124.5800','\n');
			set _output = concat(_output,'\t',' Expected _condition4:glTransaction= g.debit = 1634.5800','\n');
			-- set _output = concat(_output,'\t',' Expected _condition5:cuSODetailTicket cuSODetailId=',TEST_Id('GET','cuSOID1',null,null),' and binId=',TEST_Id('GET','fromBinID2',null,null),' and ticketStatus=1','\n\n');

			set _output = concat(_output,'\n');
			
            set _output = concat(_output,'\t',' _condition1=',_condition1,' _condition2=',_condition2,' _condition3=',_condition3,' _condition4=',_condition4,'\n');

-- select _output;
			
			if (_condition1 = 1 and _condition2 = 1 and _condition3 = 1 and _condition4 = 1) THEN
				set _output = concat(_output,'\n\t',' PASS','\n');
				update TEST_results set passFail='PASS'  where batch=_batch and card=_card;
			ELSE
				set _output = concat(_output,'\n\t',' FAIL','\n');
				update TEST_results set passFail='FAIL'  where batch=_batch and card=_card;
			END IF;   

-- select _output;

			set _output = concat(_output,'\n');
			set _output = concat(_output, TEST_output ('Bin','\t','Actual','',_batch));
			set _output = concat(_output, TEST_output ('cuInvoice','\t','Actual','',_batch));
			set _output = concat(_output, TEST_output ('glTransaction','\t','Actual','',_batch));
            			            
        END IF; -- END CARD

        
-- ===============================================
-- CARD CARD_so_void_out_ticket
-- call TEST_manager('RUN','CARD_so_void_out_ticket',null);
-- ===============================================
        
		IF (_card = 'CARD_so_void_out_ticket' ) THEN
 	
			-- TABLE SETUP FOR TEST
            call TEST_cardSetup('CREATE',_batch,'BASETABLES,CUSO',_DEBUG);

            -- ==================================================
            -- DATA ADJUSTMENT FOR TEST
            -- ==================================================
			update bin set InventoryOnHand=100,InventoryAllocated=15,AverageCost=10 where binId = TEST_Id('GET','fromBinID1',null,null);
			update bin set InventoryOnHand=100,InventoryAllocated=15,AverageCost=10 where binId = TEST_Id('GET','fromBinID2',null,null);
            
            update cuSO set Freight=10 where cuSOID =  TEST_Id('GET','cuSOID1',null,null);
			update cuSODetail set QuantityOrdered=150,UnitCost=10,Taxable=1 where cuSODetailID = TEST_Id('GET','cuSODetailID1',null,null);
            -- ==================================================

			set _output = concat(_output,'\n',_card,' ',_batch,'\n');
			set _output = concat(_output,'\n================RUN SETUP==============\n\n');

			set _output = concat(_output, TEST_output ('Bin','\t','','',_batch));
			set _output = concat(_output, TEST_output ('cuSO','\t','','',_batch));

			set _output = concat(_output,'\n================RUN TEST==============\n\n');
            
-- select _output;

			-- RUN TEST ==================================================

            
            set _executionStart = now();
			call INV_updateInventoryOH('SALESORDER',null,null,null,null,'REFERENCE','REASON',null,null,TEST_Id('GET','cuSODetailID1',null,null),null,TEST_Id('GET','userId',null,null));
            set _executionEnd = now();

			set _output = concat(_output,'\t','call INV_updateInventoryOH(\'SALESORDER\',null,null,null,null,\'REFERENCE\',\'REASON\',null,null,',TEST_Id('GET','cuSODetailID1',null,null),',null,',TEST_Id('GET','userId',null,null),');',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');

-- select _output;

			set _output = concat(_output, TEST_output ('Bin','\t\t','','',_batch));
			set _output = concat(_output, TEST_output ('cuSODetailBin','\t\t','','',_batch));

            set _executionStart = now();
            call INV_createPickTicket_v2('CREATE',TEST_Id('GET','cuSOID1',null,null),_DEBUG );
            set _executionEnd = now();

			set _output = concat(_output,'\n\t','call INV_createPickTicket_v2(\'CREATE\',',TEST_Id('GET','cuSOID1',null,null),',_DEBUG);',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');

			set _output = concat(_output, TEST_output ('cuSODetailTicket','\t\t','','',_batch));
			
-- select _output;

			-- 	case 'Void' setStatus = -1; 
			-- 	case 'Quote' setStatus = -2;
			-- 	case 'OnHold' setStatus = 0;
			-- 	case 'Open' setStatus = 1;
			-- 	case 'Book as Job' setStatus = 3;
			-- 	case 'Import to Job' setStatus = 4;
			-- 	case 'Closed' setStatus = 2;


            set _executionStart = now();
			call SO_updateSO('SET_STATUS',TEST_Id('GET','cuSOID1',null,null),-1,TEST_Id('GET','userId',null,null),_DEBUG);
            set _executionEnd = now();

			set _output = concat(_output,'\n\t','SO_updateSO(\'SET_STATUS\',',TEST_Id('GET','cuSOID1',null,null),',-1,',TEST_Id('GET','userId',null,null),',_DEBUG); -- VOID',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n');

-- select _output;
				
            -- END TEST ==================================================

			-- ==================================================
			-- EVALUATE RESULTS
			-- ==================================================
			select count(*) into _condition1 from bin where binId=TEST_Id('GET','fromBinID1',null,null) and InventoryOnHand=100 and InventoryAllocated=15;
			select count(*) into _condition2 from bin where binId=TEST_Id('GET','fromBinID2',null,null) and InventoryOnHand=100 and InventoryAllocated=15;        
			select count(*) into _condition3 from cuSO  where cuSOID=TEST_Id('GET','cuSOID1',null,null) and TransactionStatus=-1;        
			select count(*) into _condition4 from cuSODetailTicket where cuSODetailId=TEST_Id('GET','cuSOID1',null,null) and binId=TEST_Id('GET','fromBinID1',null,null) and ticketStatus=2;        
			select count(*) into _condition5 from cuSODetailTicket where cuSODetailId=TEST_Id('GET','cuSOID1',null,null) and binId=TEST_Id('GET','fromBinID2',null,null) and ticketStatus=2;        

			set _output = concat(_output,'\n================POST RUN RESULTS==============\n\n');
			set _output = concat(_output,'\t',' Expected _condition1:Bin=',TEST_Id('GET','fromBinID1',null,null),' InventoryOnHand=100 and InventoryAllocated=15','\n');
			set _output = concat(_output,'\t',' Expected _condition2:Bin=',TEST_Id('GET','fromBinID2',null,null),' InventoryOnHand=100 and InventoryAllocated=15','\n');
			set _output = concat(_output,'\t',' Expected _condition3:cuSO=',TEST_Id('GET','cuSOID1',null,null),' TransactionStatus=-1','\n');
			set _output = concat(_output,'\t',' Expected _condition4:cuSODetailTicket cuSODetailId=',TEST_Id('GET','cuSOID1',null,null),' and binId=',TEST_Id('GET','fromBinID1',null,null),' and ticketStatus=2','\n');
			set _output = concat(_output,'\t',' Expected _condition5:cuSODetailTicket cuSODetailId=',TEST_Id('GET','cuSOID1',null,null),' and binId=',TEST_Id('GET','fromBinID2',null,null),' and ticketStatus=2','\n\n');


			set _output = concat(_output,'\n');
			set _output = concat(_output,'\t',' _condition1=',_condition1,' _condition2=',_condition2,' _condition3=',_condition3,' _condition4=',_condition4,' _condition5=',_condition5,'\n');
			
			if (_condition1 = 1 and _condition2 = 1  and _condition3 = 1 and _condition4 = 1 and _condition5 = 1) THEN
				set _output = concat(_output,'\n\t',' PASS','\n');
				update TEST_results set passFail='PASS'  where batch=_batch and card=_card;
			ELSE
				set _output = concat(_output,'\n\t',' FAIL','\n');
				update TEST_results set passFail='FAIL'  where batch=_batch and card=_card;
			END IF;   

			set _output = concat(_output,'\n');
            
			set _output = concat(_output, TEST_output ('Bin','\t',' ACTUAL','',_batch));
			set _output = concat(_output, TEST_output ('cuSO','\t',' ACTUAL','',_batch));
			set _output = concat(_output, TEST_output ('cuSODetailTicket','\t',' ACTUAL','',_batch));
                        
        END IF; -- END CARD


-- ===============================================
-- CARD CARD_so_onhold_to_open
-- call TEST_manager('RUN','CARD_so_onhold_to_open',1);
-- call TEST_card ('RUN',n,'CARD_so_onhold_to_open',1);
-- ===============================================
		IF (_card = 'CARD_so_onhold_to_open' ) THEN
 	
			-- TABLE SETUP FOR TEST
            call TEST_cardSetup('CREATE',_batch,'BASETABLES,CUSO',_DEBUG);

            -- ==================================================
            -- DATA ADJUSTMENT FOR TEST
            -- ==================================================
			update bin set InventoryOnHand=100,InventoryAllocated=15,AverageCost=10 where binId = TEST_Id('GET','fromBinID1',null,null);
			update bin set InventoryOnHand=100,InventoryAllocated=15,AverageCost=10 where binId = TEST_Id('GET','fromBinID2',null,null);
            
            update cuSO set Freight=10 where cuSOID =  TEST_Id('GET','cuSOID1',null,null);
			update cuSODetail set QuantityOrdered=150,UnitCost=10,Taxable=1 where cuSODetailID = TEST_Id('GET','cuSODetailID1',null,null);
            -- ==================================================

			set _output = concat(_output,'\n',_card,' ',_batch,'\n');
			set _output = concat(_output,'\n================RUN SETUP==============\n\n');

			set _output = concat(_output, TEST_output ('Bin','\t','','',_batch));
			set _output = concat(_output, TEST_output ('cuSO','\t','','',_batch));

			set _output = concat(_output,'\n================RUN TEST==============\n\n');
            
			-- RUN TEST ==================================================

            
            set _executionStart = now();
			call INV_updateInventoryOH('SALESORDER',null,null,null,null,'REFERENCE','REASON',null,null,TEST_Id('GET','cuSODetailID1',null,null),null,TEST_Id('GET','userId',null,null));
            set _executionEnd = now();

			set _output = concat(_output,'\t','call INV_updateInventoryOH(\'SALESORDER\',null,null,null,null,\'REFERENCE\',\'REASON\',null,null,',TEST_Id('GET','cuSODetailID1',null,null),',null,',TEST_Id('GET','userId',null,null),');',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');

-- select _output;

			set _output = concat(_output, TEST_output ('Bin','\t\t','','',_batch));
			set _output = concat(_output, TEST_output ('cuSODetailBin','\t\t','','',_batch));
			
            set _executionStart = now();
            call INV_createPickTicket_v2('CREATE',TEST_Id('GET','cuSOID1',null,null),_DEBUG );
            set _executionEnd = now();

			set _output = concat(_output,'\n\t','call INV_createPickTicket_v2(\'CREATE\',',TEST_Id('GET','cuSOID1',null,null),',_DEBUG);',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n\n');
			
			set _output = concat(_output, TEST_output ('cuSODetailTicket','\t\t','','',_batch));
            

-- select _output;

			-- 	case 'Void' setStatus = -1; 
			-- 	case 'Quote' setStatus = -2;
			-- 	case 'OnHold' setStatus = 0;
			-- 	case 'Open' setStatus = 1;
			-- 	case 'Book as Job' setStatus = 3;
			-- 	case 'Import to Job' setStatus = 4;
			-- 	case 'Closed' setStatus = 2;

			-- ticket will become unallocated?
            set _executionStart = now();
			call SO_updateSO('SET_STATUS',TEST_Id('GET','cuSOID1',null,null),0,TEST_Id('GET','userId',null,null),_DEBUG);
            set _executionEnd = now();

			set _output = concat(_output,'\n\t','SO_updateSO(\'SET_STATUS\',',TEST_Id('GET','cuSOID1',null,null),',0,',TEST_Id('GET','userId',null,null),',_DEBUG); -- ONHOLD',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),'\n');

			-- ticket will return to allocated
            set _executionStart = now();
			call SO_updateSO('SET_STATUS',TEST_Id('GET','cuSOID1',null,null),1,TEST_Id('GET','userId',null,null),_DEBUG);
            set _executionEnd = now();

			set _output = concat(_output,'\n\t','SO_updateSO(\'SET_STATUS\',',TEST_Id('GET','cuSOID1',null,null),',1,',TEST_Id('GET','userId',null,null),',_DEBUG); -- OPEN',' EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart),' -- FIX OnOPEN to recalculate bin allocation\n');

-- select _output;
				
            -- END TEST ==================================================

			-- ==================================================
			-- EVALUATE RESULTS
			-- ==================================================
			select count(*) into _condition1 from bin where binId=TEST_Id('GET','fromBinID1',null,null) and InventoryOnHand=100 and InventoryAllocated=100;
			select count(*) into _condition2 from bin where binId=TEST_Id('GET','fromBinID2',null,null) and InventoryOnHand=100 and InventoryAllocated=80;        
			select count(*) into _condition3 from cuSO  where cuSOID=TEST_Id('GET','cuSOID1',null,null) and TransactionStatus=1;        
			select count(*) into _condition4 from cuSODetailTicket where cuSODetailId=TEST_Id('GET','cuSOID1',null,null) and binId=TEST_Id('GET','fromBinID1',null,null) and ticketStatus=1;        
			select count(*) into _condition5 from cuSODetailTicket where cuSODetailId=TEST_Id('GET','cuSOID1',null,null) and binId=TEST_Id('GET','fromBinID2',null,null) and ticketStatus=1;        

			set _output = concat(_output,'\n================POST RUN RESULTS==============\n\n');

			set _output = concat(_output,'\t',' Expected _condition1:Bin=',TEST_Id('GET','fromBinID1',null,null),' InventoryOnHand=100 and InventoryAllocated=100','\n');
			set _output = concat(_output,'\t',' Expected _condition2:Bin=',TEST_Id('GET','fromBinID2',null,null),' InventoryOnHand=100 and InventoryAllocated=80','\n');
			set _output = concat(_output,'\t',' Expected _condition3:cuSO=',TEST_Id('GET','cuSOID1',null,null),' TransactionStatus=1','\n');
			set _output = concat(_output,'\t',' Expected _condition4:cuSODetailTicket cuSODetailId=',TEST_Id('GET','cuSOID1',null,null),' and binId=',TEST_Id('GET','fromBinID1',null,null),' and ticketStatus=1','\n');
			set _output = concat(_output,'\t',' Expected _condition5:cuSODetailTicket cuSODetailId=',TEST_Id('GET','cuSOID1',null,null),' and binId=',TEST_Id('GET','fromBinID2',null,null),' and ticketStatus=1','\n\n');
            
			set _output = concat(_output,'\n');
			set _output = concat(_output,'\t',' _condition1=',_condition1,' _condition2=',_condition2,' _condition3=',_condition3,' _condition4=',_condition4,' _condition5=',_condition5,'\n');

			
			if (_condition1 = 1 and _condition2 = 1  and _condition3 = 1 and _condition4 = 1 and _condition5 = 1) THEN
				set _output = concat(_output,'\n\t',' PASS','\n');
				update TEST_results set passFail='PASS'  where batch=_batch and card=_card;
			ELSE
				set _output = concat(_output,'\n\t',' FAIL','\n');
				update TEST_results set passFail='FAIL'  where batch=_batch and card=_card;
			END IF;   


			set _output = concat(_output,'\n');

			set _output = concat(_output, TEST_output ('Bin','\t',' ACTUAL','',_batch));
			set _output = concat(_output, TEST_output ('cuSO','\t',' ACTUAL','',_batch));
			set _output = concat(_output, TEST_output ('cuSODetailTicket','\t',' ACTUAL','',_batch));
          
        END IF; -- END CARD


-- ===============================================
-- CARD CARD_submittal_create_new
-- call TEST_manager('RUN','CARD_submittal_create_new',1);
-- call TEST_card ('RUN',now(),'CARD_submittal_create_new',1); -- call TEST_manager('CLEAN-ALL',null,null); required afterward
-- ===============================================
		IF (_card = 'CARD_submittal_create_new' ) THEN
        
			-- TABLE SETUP FOR TEST
            call TEST_cardSetup('CREATE',_batch,'JOMASTER',_DEBUG);

			-- ==================================================
            -- DATA ADJUSTMENT FOR TEST
            -- ==================================================

			set _output = concat(_output,'\n',_card,' ',_batch,'\n');
			set _output = concat(_output,'\n================RUN SETUP==============\n\n');

			set _output = concat(_output, TEST_output ('joSubmittal','\t','','',_batch));

			set _output = concat(_output,'\n================RUN TEST==============\n\n');
            
			-- RUN TEST ==================================================

			set _executionStart = now();
			-- get josubmittal details, will insert a joSubmittal
			CALL SUBMITTAL_submittal('GET', TEST_Id('GET','joMasterID',null,null), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
			set _executionEnd = now();

			set _output = concat(_output, '\t', 'CALL SUBMITTAL_submittal(\'GET\',', TEST_Id('GET','joMasterID',null,null),', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);', ' EXECUTION TIME=', TIMEDIFF(_executionEnd, _executionStart), '\n\n');
				
			-- ==================================================
			-- EVALUATE RESULTS
			-- ==================================================
			select count(*) into _condition1 from joSubmittal where joMasterID = TEST_Id('GET','joMasterID',null,null);
			select count(*) into _condition2 from joSubmittalDetail where joMasterID = TEST_Id('GET','joMasterID',null,null);
			
			set _output = concat(_output,'\n================POST RUN RESULTS==============\n\n');

			set _output = concat(_output,'\t',' Expected _condition1:joSubmittal where joMasterID =',TEST_Id('GET','joMasterID',null,null),' and totalCost = 670','\n');
			set _output = concat(_output,'\t',' Expected _condition2:joSubmittalDetail where joMasterID =',TEST_Id('GET','joMasterID',null,null),'\n');
            
			set _output = concat(_output,'\n');
			set _output = concat(_output,'\t',' _condition1=',_condition1,' _condition2=',_condition2,'\n');

			
			if (_condition1 = 1 and _condition2 = 1 ) THEN
				set _output = concat(_output,'\n\t',' PASS','\n');
				update TEST_results set passFail='PASS'  where batch=_batch and card=_card;
			ELSE
				set _output = concat(_output,'\n\t',' FAIL','\n');
				update TEST_results set passFail='FAIL'  where batch=_batch and card=_card;
			END IF;   


			set _output = concat(_output,'\n');
			set _output = concat(_output, TEST_output ('joSubmittal','\t',' ACTUAL','',_batch));

			UPDATE TEST_results SET endTime = NOW(), results=_output WHERE batch=_batch AND card=_card;
            
        END IF; -- END CARD

-- ===============================================
-- CARD CARD_signature_quotenote
-- call TEST_manager('RUN','CARD_signature_quotenote',1);
-- call TEST_card ('RUN',now(),'CARD_signature_quotenote',1); -- call TEST_manager('CLEAN-ALL',null,null); required afterward
-- ===============================================
-- add here!
        IF (_card = 'CARD_signature_quotenote' ) THEN
        
			-- TABLE SETUP FOR TEST
            call TEST_cardSetup('CREATE',_batch,'USER',_DEBUG);

			-- ==================================================
            -- DATA ADJUSTMENT FOR TEST
            -- ==================================================

			set _output = concat(_output,'\n',_card,' ',_batch,'\n');
			set _output = concat(_output,'\n================RUN SETUP==============\n\n');

			set _output = concat(_output, TEST_output ('signature_quotenote','\t','','',_batch));

			set _output = concat(_output,'\n================RUN TEST==============\n\n');
            
			-- RUN TEST ==================================================

			set _executionStart = now();
			-- get signature and email quote note
				select `signature`,emailNotes from tsUserLogin where UserLoginID = TEST_Id('GET','userId',null,null);
			set _executionEnd = now();

			SET _output = CONCAT(_output, '\t', 'select `signature`,emailNotes from tsUserLogin where UserLoginID = ',TEST_Id('GET', 'userId', NULL, NULL),');, EXECUTION TIME=', TIMEDIFF(_executionEnd, _executionStart), '\n\n');
				
			-- ==================================================
			-- EVALUATE RESULTS
			-- ==================================================
			select count(*) into _condition1 from tsUserLogin where UserLoginID = TEST_Id('GET','userId',null,null) and `signature` = "signature" and emailNotes = "email_Notes";
			
			set _output = concat(_output,'\n================POST RUN RESULTS==============\n\n');

			SET _output = CONCAT(_output,'\t',' Expected _condition1:tsUserLogin where UserLoginID =',TEST_Id('GET','userId',NULL,NULL),' and signature = signature and emailNotes = email_Notes','\n');
            
			set _output = concat(_output,'\n');
			set _output = concat(_output,'\t',' _condition1=',_condition1,'\n');

			
			if (_condition1 = 1) THEN
				set _output = concat(_output,'\n\t',' PASS','\n');
				update TEST_results set passFail='PASS'  where batch=_batch and card=_card;
			ELSE
				set _output = concat(_output,'\n\t',' FAIL','\n');
				update TEST_results set passFail='FAIL'  where batch=_batch and card=_card;
			END IF;   


			set _output = concat(_output,'\n');
			set _output = concat(_output, TEST_output ('signature_quotenote','\t',' ACTUAL','',_batch));
			
			UPDATE TEST_results SET endTime = NOW(), results=_output  WHERE batch=_batch AND card=_card;
            
        END IF; -- END CARD

-- ===============================================
-- CARD CARD_batch_email
-- call TEST_manager('RUN','CARD_batch_email',1);
-- call TEST_card ('RUN',now(),'CARD_batch_email',1); -- call TEST_manager('CLEAN-ALL',null,null); required afterward
-- ===============================================

		IF (_card = 'CARD_batch_email' ) THEN
        
			-- TABLE SETUP FOR TEST
            call TEST_cardSetup('CREATE',_batch,'USER',_DEBUG);

			-- ==================================================
            -- DATA ADJUSTMENT FOR TEST
            -- ==================================================

			set _output = concat(_output,'\n',_card,' ',_batch,'\n');
			set _output = concat(_output,'\n================RUN SETUP==============\n\n');

			set _output = concat(_output, TEST_output ('batch_email_setup','\t','','',_batch));

			set _output = concat(_output,'\n================RUN TEST==============\n\n');
            
			-- RUN TEST ==================================================

			set _executionStart = now();
			-- Insert email details
				call NOTIFICATION_notification("INSERT", TEST_Id('GET','userId',null,null), null, "from@gmail.com", "to@gmail.com", "subject", "content", null, null, null, null, "Quote_CSY221007(MC)Revision#1_[West Shore Home Distribution Center ].pdf", null, "Quotes#CSY221007_Eddie Ortuno.pdf", null, "QuoteMail", "/usr/local/tomcat7_BartosUAT/webapps/turbotracker/uploads/Quotes#CSY221007_Eddie Ortuno.pdf", null, null,"readyon");
			set _executionEnd = now();

			set _output = concat(_output,'\t', 'CALL NOTIFICATION_notification(\'INSERT\', ',TEST_Id('GET','userId',null,null),', \'NULL\', \'from@gmail.com\', \'to@gmail.com\', \'subject\', content, \'NULL\', \'NULL\', \'NULL\', \'NULL\', \'Quote_CSY221007(MC)Revision#1_[West Shore Home Distribution Center ].pdf\', \'NULL\', \'Quotes#CSY221007_Eddie Ortuno.pdf\', \'NULL\', \'QuoteMail\', \'/usr/local/tomcat7_BartosUAT/webapps/turbotracker/uploads/Quotes#CSY221007_Eddie Ortuno.pdf\', \'NULL\', \'NULL\', \'30-12-2023\');', ' EXECUTION TIME=', TIMEDIFF(_executionEnd, _executionStart), '\n\n');
				
			-- ==================================================
			-- EVALUATE RESULTS
			-- ==================================================
			select count(*) into _condition1 from tsUser_global_notification where UserLoginID = TEST_Id('GET','userId',null,null) and fromEmailId = "from@gmail.com" and toEmailId = "to@gmail.com";
			
			set _output = concat(_output,'\n================POST RUN RESULTS==============\n\n');

			SET _output = CONCAT(_output,'\t',' Expected _condition1:tsUser_global_notification where UserLoginID =',TEST_Id('GET','userId',NULL,NULL),' and fromEmailId = from@gmail.com and toEmailId = to@gmail.com','\n');
            
			set _output = concat(_output,'\n');
			set _output = concat(_output,'\t',' _condition1=',_condition1,'\n');

			
			if (_condition1 = 1) THEN
				set _output = concat(_output,'\n\t',' PASS','\n');
				update TEST_results set passFail='PASS'  where batch=_batch and card=_card;
			ELSE
				set _output = concat(_output,'\n\t',' FAIL','\n');
				update TEST_results set passFail='FAIL'  where batch=_batch and card=_card;
			END IF;   


			set _output = concat(_output,'\n');
			set _output = concat(_output, TEST_output ('batch_email','\t',' ACTUAL','',_batch));
			
			UPDATE TEST_results SET endTime = NOW(), results=_output  WHERE batch=_batch AND card=_card;
            
        END IF; -- END CARD

-- ===============================================
-- CARD CARD_search_engine
-- call TEST_manager('RUN','CARD_search_engine',1);
-- call TEST_card ('RUN',now(),'CARD_search_engine',1); -- call TEST_manager('CLEAN-ALL',null,null); required afterward
-- ===============================================

		IF (_card = 'CARD_search_engine' ) THEN
        
			-- TABLE SETUP FOR TEST
            call TEST_cardSetup('CREATE',_batch,'JOMASTER,BASETABLES,CUSO,VEPO,USER',_DEBUG);

			-- ==================================================
            -- DATA ADJUSTMENT FOR TEST
            -- ==================================================

			set _output = concat(_output,'\n',_card,' ',_batch,'\n');
			set _output = concat(_output,'\n================RUN SETUP==============\n\n');

			set _output = concat(_output, TEST_output ('search_engine','\t','','',_batch));

			set _output = concat(_output,'\n================RUN TEST==============\n\n');
            
			-- RUN TEST ==================================================

			set _executionStart = now();
			-- search job details
				CALL SEARCH_manager('SEARCH',"JOB","ABC123",NULL,0,0,NULL,0);
			set _executionEnd = now();
			set _output = concat(_output, '\t', 'CALL SEARCH_manager(\'SEARCH\',\'JOB\',',TEST_Id('GET','joMasterID',null,null),',\'ABC123\',NULL,0,0,NULL,0);', ' EXECUTION TIME=', TIMEDIFF(_executionEnd, _executionStart), '\n\n');

			set _executionStart = now();
			-- search rolodex details
				CALL SEARCH_manager('SEARCH',"DEX","9725381513",NULL,0,0,NULL,0);
			set _executionEnd = now();
			set _output = concat(_output, '\t', 'CALL SEARCH_manager(\'SEARCH\',\'DEX\',',TEST_Id('GET','rxMasterID',null,null),',\'9725381513\',NULL,0,0,NULL,0);', ' EXECUTION TIME=', TIMEDIFF(_executionEnd, _executionStart), '\n\n');
			
			set _executionStart = now();
			-- search ineventory details
				CALL SEARCH_manager('SEARCH',"INV","Round Nut",NULL,0,0,NULL,0);
			set _executionEnd = now();
			set _output = concat(_output, '\t', 'CALL SEARCH_manager(\'SEARCH\',\'INV\',',TEST_Id('GET','rxMasterID',null,null),',\'Round Nut\',NULL,0,0,NULL,0);', ' EXECUTION TIME=', TIMEDIFF(_executionEnd, _executionStart), '\n\n');
			
			set _executionStart = now();
			-- search cuSO orders details
				CALL SEARCH_manager('SEARCH',"ORDER","12345",NULL,0,0,NULL,0);
			set _executionEnd = now();
			set _output = concat(_output, '\t', 'CALL SEARCH_manager(\'SEARCH\',\'ORDER\',',TEST_Id('GET','rxMasterID',null,null),',\'12345\',NULL,0,0,NULL,0);', ' EXECUTION TIME=', TIMEDIFF(_executionEnd, _executionStart), '\n\n');
			
			set _executionStart = now();
			-- search vePO orders details
				CALL SEARCH_manager('SEARCH',"ORDER","6789",NULL,0,0,NULL,0);
			set _executionEnd = now();
			set _output = concat(_output, '\t', 'CALL SEARCH_manager(\'SEARCH\',\'ORDER\',',TEST_Id('GET','rxMasterID',null,null),',\'6789\',NULL,0,0,NULL,0);', ' EXECUTION TIME=', TIMEDIFF(_executionEnd, _executionStart), '\n\n');
			-- ==================================================
			-- EVALUATE RESULTS
			-- ==================================================
			select count(*) into _condition1 from SEARCH_engine where id = TEST_Id('GET','joMasterID',null,null) AND category = "JOB";
			select count(*) into _condition2 from SEARCH_engine where id = TEST_Id('GET','rxMasterID',null,null) AND category = "DEX";
			select count(*) into _condition3 from SEARCH_engine where id = TEST_Id('GET','prMasterID1',null,null) AND category = "INV";
			select count(*) into _condition4 from SEARCH_engine where id = TEST_Id('GET','vePOID',null,null) AND category = "ORDER";
			select count(*) into _condition5 from SEARCH_engine where id = TEST_Id('GET','cuSOID1',null,null) AND category = "ORDER";
			
			set _output = concat(_output,'\n================POST RUN RESULTS==============\n\n');

			SET _output = CONCAT(_output,'\t',' Expected _condition1:SEARCH_engine where joMasterID =',TEST_Id('GET','joMasterID',NULL,NULL),'\n');
			SET _output = CONCAT(_output,'\t',' Expected _condition2:SEARCH_engine where rxMasterID =',TEST_Id('GET','rxMasterID',NULL,NULL),'\n');
			SET _output = CONCAT(_output,'\t',' Expected _condition3:SEARCH_engine where prMasterID =',TEST_Id('GET','prMasterID1',NULL,NULL),'\n');
			SET _output = CONCAT(_output,'\t',' Expected _condition4:SEARCH_engine where vePOID =',TEST_Id('GET','vePOID',NULL,NULL),'\n');
			SET _output = CONCAT(_output,'\t',' Expected _condition5:SEARCH_engine where cuSOID =',TEST_Id('GET','cuSOID1',NULL,NULL),'\n');
            
			set _output = concat(_output,'\n');
			set _output = concat(_output,'\t','_condition1=',_condition1,', _condition2=',_condition2,', _condition3=',_condition3,', _condition4=',_condition4,', _condition5=',_condition5,'\n');

			
			if (_condition1 = 1 and _condition2 = 1 and _condition3 = 1 and _condition4 = 1 and _condition5 = 1) THEN
				set _output = concat(_output,'\n\t',' PASS','\n');
				update TEST_results set passFail='PASS'  where batch=_batch and card=_card;
			ELSE
				set _output = concat(_output,'\n\t',' FAIL','\n');
				update TEST_results set passFail='FAIL'  where batch=_batch and card=_card;
			END IF;   


			set _output = concat(_output,'\n');
			set _output = concat(_output, TEST_output ('search_engine','\t',' ACTUAL','',_batch));
			
			UPDATE TEST_results SET endTime = NOW(), results=_output  WHERE batch=_batch AND card=_card;
            
        END IF; -- END CARD

    END IF; -- END Action=RUN

	if (_DEBUG=1 and length(_card)>2) THEN
		-- select 'REMEMBER TO RUN call TEST_manager(\'CLEAN-ALL\',null,null);',_output;
		select _card,_output;
	END IF;

    
END$$

DELIMITER ;

-- ==================================================================
-- ==================================================================
-- ==================================================================