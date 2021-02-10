monitor TWS{
    int state=1;
    Condition first, second, third;
    
    void first(){
        while(state!=1){
            first.wait();
        }
        state=2;
        second.signal();
    }
    
    void second(){
        while(state!=2){
            second.wait();
        }
        state=3l
        third.signal();
    }
    
    void third(){
        while(state!=3){
            third.wait();
        }
        state=1;
        first.signal();
    }
}