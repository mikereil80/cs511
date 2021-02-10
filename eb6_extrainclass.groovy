monitor PC{
    private Object buffer;
    private Condition full,empty;
    
    void produce(Object o){
        while(is_full()){
            empty.wait();
        }
        buffer=0;
        full.signal();
    }
    
    Object consume(){
        while(is_empty()){
            full.wait();
        }
        empty.signal();
        return buffer;
    }
}