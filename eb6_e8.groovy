monitor Pizzeria{
    int small=0;
    int large=0;
    Condition LargeOrTwoSmallPizzas, SmallPizza;
    
    purchaseLargePizza(){
        while(large==0 && small<2){
            LargeOrTwoSmallPizzas.wait();
        }
        if(large==0){
            small=small-2;
        }
        else{
            large--;
        }
    }
    
    purchaseSmallPizza(){
        while(small==0){
            SmallPizza.wait();
        }
        small--;
    }
    
    bakeSmallPizza(){
        small++;
        SmallPizza.signal();
        LargeOrTwoSmallPizzas.signal();
    }
    
    bakeLargePizza(){
        large++;
        LargeOrTwoSmallPizzas.signal();
    }
}