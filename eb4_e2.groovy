import java.util.concurrent.Semaphore

Semaphore permToAC=new Semaphore(0);
Semaphore permToES=new Semaphore(0);

Thread.start{ // P
    permToAC.acquire();
    print("A");
    print("C");
    permToES.release();
}

Thread.start{ // Q
    print("R");
    permToAC.release();
    permToES.acquire();
    print("E");
    print("S");
}

return;