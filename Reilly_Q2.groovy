
/*
Quiz 2B - 25 Sep 2020

You may not add print statements. 
You may declare semaphores (as many as you want) and make use of 
acquire and release operations.
You must ensure that the output is:

byebyebyebye....

*/

// Michael Reilly, Quiz Partner: Joseph Bertone
// I pledge my honor that I have abided by the Stevens Honor System.

import java.util.concurrent.Semaphore;

Semaphore permToB=new Semaphore(0);
Semaphore permToY=new Semaphore(0);
Semaphore permToE=new Semaphore(0);

Thread.start { // P

    while (true) {
    
	print("b");
	permToY.release();
	permToB.acquire();
    }
}

Thread.start { // Q

    while (true) {
        permToY.acquire();
	print("y");
        permToE.release();
    }
}

Thread.start { // R

    while (true) {
        permToE.acquire();
	print("e");
	permToB.release();

    }
}