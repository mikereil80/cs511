monitor Semaphore{
    private int permits;
    private Condition permitsAvailable;
    
    Semaphore(int init_permits){
        permits=init_permits;
    }
    
    void acquire(){
        while(permits==0){
            permitsAvailable.wait();
        }
        permits--;
    }
    
    void release(){
        permits++;
        permitsAvailable.signal();
    }
}

// in java

class Semaphore{
    private int permits;
    private Lock l=new ReentrantLock();
    private Condition permitsAvailable=l.newCondition();
    
    // otherwise no changes besides adding synchronized to the functions
}