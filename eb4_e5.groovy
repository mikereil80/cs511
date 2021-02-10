import java.util.concurrent.Semaphore

Semaphore permToF=new Semaphore(0);
Semaphore permToH=new Semaphore(0);
Semaphore permToC=new Semaphore(0);

Thread.start{
    while(true){
        print("A");
        permToF.release();
        print("B");
        permToC.acquire();
        print("C");
        print("D");
    }
}

Thread.start{
    while(true){
        print("E");
        permToH.release();
        permToF.acquire();
        print("F");
        print("G");
        permToC.release();
    }
}

Thread.start{
    while(true){
        permToH.acquire();
        print("H");
        print("I");
    }
}