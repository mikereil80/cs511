monitor RW{
    int readers=0;
    int writers=0;
    Condition okToRead, okToWrite;
    int writersWaiting=0;
    
    startRead(){
        while(writers!=0 || writersWaiting!=0){
            okToRead.wait();
        }
        readers++;
        okToRead.signal();
    }
    
    stopRead(){
        readers--;
        okToWrite.signal();
    }
    
    startWrite(){
        while(writers!=0 || readers!=0){
            writersWaiting++;
            okToWrite.wait();
            writersWaiting--;
        }
        writers=1;;
    }
    
    stopWrite(){
        writers=0;
        okToRead.signalAll();
        okToWrite.signal();
    }
}