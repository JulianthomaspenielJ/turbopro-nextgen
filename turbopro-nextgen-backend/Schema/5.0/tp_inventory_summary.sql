DROP procedure IF EXISTS `INV_getSummary`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INV_getSummary`()
INV_getSummary: BEGIN
	select distinct(p.ItemCode), p.Description, d.Description as department,
	       p.category, p.PrimaryVendor, BaseSellingPrice,
	       p.prInventoryOnHand, p.prInventoryAllocated, p.prInventoryOnOrder
	from v_INV_product p, prMaster m, prDepartment d, v_PR_product v
        where p.prMasterID = m.prMasterID and
              p.prMasterID = v.prMasterID and
	      m.prDepartmentID = d.prDepartmentID and
	      p.InActive = 0 LIMIT 25;
END$$
DELIMITER ;
