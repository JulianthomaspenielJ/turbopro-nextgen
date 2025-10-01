 
  var getBinNode = function(results, nodeCallback){
    
    var list = [];
    
    for(index in results){ 

        var pl = results[index];
        
        var pick = {
          "obj": pl.obj,
          "id": pl.id,
          "name": pl.name,
          "orderBy": pl.orderBy,
          "isDefault": pl.isDefault
        };

        //console.log(index, contact);

        list.push(pick);

    } // loop

    nodeCallback(null, list);

  } // getBinNode

  exports.binlist = getBinNode;