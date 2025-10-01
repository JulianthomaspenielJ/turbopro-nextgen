 
  var getPicklistNode = function(results, picklistCallback){
    
    var picklists = [];
    
    for(index in results){ 

        var pl = results[index];
        
        var pick = {
          "obj": pl.obj,
          "id": pl.id,
          "name": pl.name,
          "orderBy": pl.orderBy,
          "isDefault": pl.isDefault,
          "Value": pl.Value
        };

        //console.log(index, contact);

        picklists.push(pick);

    } // loop

    picklistCallback(null, picklists);

  } // getPicklistNode

  exports.picklists = getPicklistNode;