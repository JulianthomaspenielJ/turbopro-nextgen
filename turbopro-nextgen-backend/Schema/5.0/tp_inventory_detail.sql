DROP procedure IF EXISTS `INV_getDetail`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INV_getDetail`(IN item_code varchar(100))
INV_getDetail: BEGIN
	select ItemCode, Description, BaseSellingPrice, ProfitMargin, ProfitPercent,
	       SV_AvgCost, SV_WhseCost, SV_Multiplier, SV_FactoryCost,
	       prInventoryOnHand, prInventoryAllocated, prInventoryAvailable,
	       prInventoryOnOrder, InActive, IsInventory, Box, WeightLbs, WeightOz,
	       website, PrimaryVendor, PrimaryVendorItemCode, SOPopup, POPopup, CUPopup 
	       Department, Category
	from v_PR_product
        where ItemCode = item_code;
END$$
DELIMITER ;
