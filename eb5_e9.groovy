track=[new Semaphore(1), new Semaphore(1)];

Thread.start{
    random rnd=new Random();
    int dir=rnd.nextInt(1);
    
    track[dir].acquire();
    track[dir].rlease();
}

Thread.start{
    Random rnd=new Random();
    int dir=rnd.nextInt(1);
    
    track[0].acquire();
    track[1].acquire();
    permToLoad.release();
    downloading.acquire();
    track[0].release();
    track[1].release();
}

Thread.start{
    while(true){
        permToLoad.acquire();
        downlaoding.release();
    }
}