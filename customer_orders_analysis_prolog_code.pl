:-consult(data).

%number1
list_orders(CustomerUserName, Orders) :-
    customer(CustID, CustomerUserName),
    list_orders_helper(CustID, Orders).

list_orders_helper(CustomerID, Orders) :-
    find_next_order_(CustomerID, 1, [], Orders).

find_next_order_(CustomerID, OrderID, Acc, Orders) :-
    order(CustomerID, OrderID, Items),
    NewAcc = [order(CustomerID, OrderID, Items) | Acc],
    NextOrderID is OrderID + 1,
    find_next_order_(CustomerID, NextOrderID, NewAcc, Orders).
find_next_order_(_, _, Orders, Orders). 

%number2
getcustomer_id(CustUserName, CustID) :-
    customer(CustID, CustUserName).

countOrdersOfCustomer(CustUserName, Count) :-
    getcustomer_id(CustUserName, CustID),
    countOrdersHelper(CustID, 0, Count).

countOrdersHelper(CustID, Acc, Count) :-
    order(CustID, _, _), 
    NewAcc is Acc + 1,
    find_next_order(CustID, NewAcc, Count).

countOrdersHelper(_, Count, Count).


find_next_order(CustID, Acc, Count) :-
    order(CustID, OrderID, _), 
    NewAcc is Acc + 1,
    find_next_order(CustID, OrderID, NewAcc, Count).


find_next_order( _, LastOrderID, LastOrderID, Count) :-
    !,
    Count = LastOrderID. 

find_next_order(CustID, CurrentOrderID, Acc, Count) :-
    NextOrderID is CurrentOrderID + 1,
    find_next_order(CustID, NextOrderID, Acc, Count).

%number3
getItemsInOrderById(Cust_user_name,OrderID,Items):-
    customer(CustID, Cust_user_name),
    order(CustID,OrderID,Items).

%number4
getNumOfItems(CustomerName, OrderID, Count) :-
    customer(CustomerID, CustomerName),
    order(CustomerID, OrderID, Items),
    countItems(Items, Count).
countItems([], 0). 
countItems([_|Rest], Count) :-
    countItems(Rest, RestCount),
    Count is RestCount + 1.

%number5
calcPriceOfOrder(CustomerName, OrderID, TotalPrice) :-
    customer(CustomerID, CustomerName),
    order(CustomerID, OrderID, Items),
    calculateTotalPrice(Items, 0, TotalPrice).
calculateTotalPrice([], Acc, Acc).
calculateTotalPrice([Item|Rest], Acc, TotalPrice) :-
    item(Item, _, ItemPrice),
    NewAcc is Acc + ItemPrice,
    calculateTotalPrice(Rest, NewAcc, TotalPrice).

%number6
isBoycott(Name):-
    boycottcompany(Name, ).

isBoycott(Name):-
    alternative(Name,_). 

alternative_item(ItemName):-
    alternative(ItemName,_).

%number7
whyToBoycott(ItemName, Justification):-
    item(ItemName, CompanyName, _),
    boycott_company(CompanyName,Justification).

%number8
removeBoycottItemsFromAnOrder(CustomerUserName, OrderID, NewList) :-
    customer(CustomerID, CustomerUserName),
    order(CustomerID, OrderID, Items),
    removeBoycottItems(Items, NewList).

% Rule to remove boycott items from a list
removeBoycottItems([], []).
removeBoycottItems([Item|Rest], [Item|RestFiltered]) :-
    \+ boycott_item(Item), 
    removeBoycottItems(Rest, RestFiltered).
removeBoycottItems([_|Rest], NewList) :-
    removeBoycottItems(Rest, NewList).

boycott_item(ItemName) :-
    item(ItemName, Company, _),
    boycott_company(Company, _).

%number9
% Predicate to replace boycott items from an order
replaceBoycottItemsFromAnOrder(CustUserName, OrderID, UpdatedItems) :-
    customer(CustID, CustUserName), 
    order(CustID, OrderID, Items),  
    replace_boycott_items(Items, UpdatedItems). 

% Predicate to replace boycott items with alternatives
replace_boycott_items([], []).
replace_boycott_items([Item|Rest], [UpdatedItem|UpdatedRest]) :-
    (   boycott_company_of_item(Item, _), 
        alternative(Item, Alternative), 
        UpdatedItem = Alternative        
    ;   UpdatedItem = Item               
    ),
    replace_boycott_items(Rest, UpdatedRest).

boycott_company_of_item(Item, Company) :-
    item(Item, Company, _),
    boycott_company(Company, _).

%number10
calcPriceAfterReplacingBoycottItemsFromAnOrder(CustUserName, OrderID, UpdatedItems, TotalPrice) :-
    customer(CustID, CustUserName), 
    order(CustID, OrderID, Items),  
    replace_boycott_items_and_calc_price(Items, UpdatedItems, TotalPrice). 

replace_boycott_items_and_calc_price([], [], 0).
replace_boycott_items_and_calc_price([Item|Rest], [UpdatedItem|UpdatedRest], TotalPrice) :-
    (   boycott_company_of_item(Item, _), 
        alternative(Item, Alternative),  
        UpdatedItem = Alternative,      

        (number(Alternative) -> Price = Alternative ; item(Alternative, _, Price))
    ;   UpdatedItem = Item,              
        item(Item, _, Price)            
    ),

    replace_boycott_items_and_calc_price(Rest, UpdatedRest, RestTotalPrice),
    TotalPrice is Price + RestTotalPrice.

boycott_company_of_item(Item, Company) :-
    item(Item, Company, _),
    boycott_company(Company, _).

%number11
getItemPrice(ItemName, Price) :-
    item(ItemName,_ , Price).

getTheDifferenceInPriceBetweenItemAndAlternative(ItemName, AlternativeItem, DiffPrice) :-
    item(ItemName,_ , ItemPrice),
    alternative(ItemName, AlternativeItem),
    getItemPrice(AlternativeItem, AltPrice),
    DiffPrice is ItemPrice - AltPrice.

%number12
:- dynamic item/3.
:- dynamic alternative/2.
:- dynamic boycott_company/2.


add_item(ItemName, CompanyName, Price) :-
    assert(item(ItemName, CompanyName, Price)).

remove_item(ItemName, CompanyName, Price) :-
    retract(item(ItemName, CompanyName, Price)).

add_alternative(ItemName, AlternativeItem) :-
    assert(alternative(ItemName, AlternativeItem)).

remove_alternative(ItemName, AlternativeItem) :-
    retract(alternative(ItemName, AlternativeItem)).

add_boycott_company(CompanyName, Justification) :-
    assert(boycott_company(CompanyName, Justification)).

remove_boycott_company(CompanyName, Justification) :-
    retract(boycott_company(CompanyName, Justification)).
