import java.util.concurrent.Semaphore;

Semaphore station0=new Semaphore(1);
Semaphore station1=new Semaphore(1);
Semaphore station2=new Semaphore(1);
Semaphore permToBlast=new Semaphore(0);
Semaphore permToLeaveStation0=new Semaphore(0);
Semaphore permToRinse=new Semaphore(0);
Semaphore permToLeaveStation1=new Semaphore(0);
Semaphore permToDry=new Semaphore(0);
Semaphpre permToLeaveStation2=new Semaphore(0);

int b,r,d=0;

100.times{
    int car_id=it;
    Thread.start{
        station0.acquire();
        permToBlast.release();
        b++;
        assert b>=0 && b<2;
        println(b+","+r+","+d);
        println("Car "+car_id+" is being blasted");
        b--;
        permToLeaveStation0.acquire();
        
        station1.acquire();
        station0.release();
        
        permToRinse.release();
        r++;
        assert r>=0 && r<2;
        println(b+","+r+","+d);
        println("Car "+car_id+" is being rinsed");
        r--;
        permToLeaveStation1.acquire();
        
        station2.acquire();
        station1.release();
        
        permToDry.release();
        d++;
        assert d>=0 && d<2
        println(b+","+r+","+d);
        println("Car "+car_id+" is being dried");
        d--;
        permToLeaveStation2.acquire();
        station2.release();
        
        println("Car "+car_id+" is done");
    }
}
Thread.start{
    while(true){
        permToBlast.acquire();
        permToLeaveStation0.release();
    }
}

Thread.start{
    while(true){
        permToRinse.acquire();
        permToLeaveStation1.release();
    }
}

Thread.start{
    while(true){
        permToDry.acquire();
        permToLeaveStation2.release();
    }
}