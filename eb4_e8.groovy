import java.util.concurrent.Semaphore

Semaphore permToMin=new Semaphore(0);
Semaphore permToAdd=new Semaphore(1);

int n2=0;
int n=50;

Thread.start{
    while(n>0){
        permToMin.acquire();
        n=n-1;
        permToAdd.release();
    }
    permToAdd.release();
    permToMin.acquire();
    print(n2);
}

Thread.start{
    while(true){
        permToAdd.acquire();
        n2=n2+2*n+1;
        permToMin.release();
    }
}