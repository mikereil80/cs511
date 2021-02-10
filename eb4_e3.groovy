import java.util.concurrent.Semaphore

Semaphore permtoI=new Semaphore(0);
Semaphore permtoO=new Semaphore(0);
Semaphore permtoOK=new Semaphore(0);

Thread.start { // P
    print("R");
    permtoI.release();
    permtoOK.acquire();
    print("OK");
}

Thread.start { // Q
    permtoI.acquire();
    print("I");
    permtoO.release();
    permtoOK.acquire();
    print("OK");
}


Thread.start{
    permtoO.acquire();
    print("O");
    permtoOK.release();
    permtoOK.release();
    print("OK");
}