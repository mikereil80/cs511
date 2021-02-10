monitor Barrier{
    final int N=3;
    int c=0;
    Condition readyToPass;
    
    pass(){
        if(c<N){
            c++;
            while(c<N){
                readyToPass.wait();
            }
            readyToPass.signalAll();
        }
    }
}