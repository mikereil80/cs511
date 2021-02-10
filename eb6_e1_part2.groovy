class PC{
    private Object buffer;
    private Condition full;
    private Condition empty;
    
    synchronized void produce(Object o){
        if(is_full_buffer()){
            empty.wait();
        }
        buffer=o;
        full.signal();
    }
    
    synchronized Object consume(){
        if(is_empty_buffer()){
            full.wait();
        }
        empty.signal();
        return buffer
    }
}