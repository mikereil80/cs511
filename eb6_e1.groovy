monitor Counter{
    private c=0;
    
    void inc(){
        c++;
    }
    
    void dec(){
        c--;
    }
}

// in java
class Counter{
    private c=0;
    
    synchronized void inc(){
        c++;
    }
    
    synchronized void dec(){
        c--;
    }
    
}