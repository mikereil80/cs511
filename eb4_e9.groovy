import java.util.concurrent.Semaphore;

int counter=0;
Semaphore mutex=new Semaphore(1);
Semaphore s=new Semaphore(-1);

Thread.start{
    10.times{
        mutex.acquire();
        counter++;
        mutex.release();
    }
    s.release();
}

Thread.start{
    10.times{
        mutex.acquire();
        counter++;
        mutex.release();
    }
    s.release();
}

s.acquire();
print(counter);