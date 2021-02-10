import java.util.concurrent.Semaphore;

Semaphore resource=new Semaphore(1);
Semaphore mutexR=new Semaphore(1);
Semaphore access=new Semaphore(1);
int r=0;

Thread.start{ // Writer
    acces.acquire();
    resource.acquire();
    access.release();
    // write to resource
    resource.release();
}

Thread.start{ // Reader
    access.acquire();
    mutexR.acquire();
    r++;
    if(r==1){
        resource.acquire();
    }
    mutexR.release();
    access.release();
    // read to resource
    mutexR.acquire();
    r--;
    if(r==0){
        resource.release();
    }
    mutexR.release();
}