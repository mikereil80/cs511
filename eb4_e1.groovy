import java.util.concurrent.Semaphore

Semaphore permtoF=new Semaphore(0);
Semaphore permtoC=new Semaphore(0);

Thread.start{ // P
    print("A");
    permtoF.release();
    print("B");
    permtoC.acquire();
    print("C");
}

Thread.start{ // Q
    print("E");
    permtoF.acquire();
    print("F");
    permtoC.release();
    print("G");
}