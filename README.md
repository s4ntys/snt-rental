# snt-rental
Just a rental car... you can use it however you want :)



 If you want to change cars you do it in config.lua


## Dependencies :

QBCore Framework - https://github.com/qbcore-framework/qb-core

PolyZone - https://github.com/mkafrin/PolyZone

qb-target - https://github.com/BerkieBb/qb-target (Only needed if not using draw text)

qb-menu - https://github.com/qbcore-framework/qb-menu



## Put this line on shared.lua in your core.

```
["rentalpapers"]				 = {["name"] = "rentalpapers", 					["label"] = "Rental Papers", 			["weight"] = 50, 		["type"] = "item", 		["image"] = "rentalpapers.png", 		["unique"] = true, 		["useable"] = false, 	["shouldClose"] = false, 	["combinable"] = nil, 	["description"] = "Poprosím aby si auto vrátil :)"},
```

## IMAGINE
![image](https://github.com/SanTysss1984/snt-rental/assets/89365439/b541b28b-5a1b-4bc0-a1e7-270f1f90a267)

- Add the rentalpapers.png to your - qb-nventory -> html -> images

## Go to qb-inventory -> html -> js -> app.js and between lines 500-600 add the following code

```
          } else if (itemData.name == "rentalpapers") {
            $(".item-info-title").html('<p>' + itemData.label + '</p>')
            $(".item-info-description").html('<p><strong>Plate: </strong><span>'+ itemData.info.label + '</span></p>');
```
