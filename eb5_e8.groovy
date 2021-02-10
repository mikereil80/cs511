import java.util.concurrent.Semaphore;

Semaphore useCrossing=new Semaphore(1);
endpointMutexList=[new Semaphore(1, true), new Semaphore(1, true)];
noOfCarsCrossing=[0,0];
r=new Random();

100.times{
    int myEndpoint=r.nextInt(2);
    Thread.start{
        endpointMutexList[myEndpoint].acquire();
        if(noOfCarsCrossing[myEndpoint]==0){
            useCrossing.acquire();
        }
        noOfCarsCrossing[myEndpoint]++;
        endpointMutexList[myEndpoint].release();
        
        //Cross crossing
        println("car $it crossing in direction "+myEndpoint+" current totals "+noOfCarsCrossing);
        
        endpointMutexList[myEndpoint].acquire();
        noOfCarsCrossing[myEndpoint]--;
        if(noOfCarsCrossing[myEndpoint]==0){
            useCrossing.release();
        }
        endpointMutexList[myEndpoint].release();
    }
}