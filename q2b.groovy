
/*
Quiz 2B - 25 Sep 2020

You may not add print statements. 
You may declare semaphores (as many as you want) and make use of 
acquire and release operations.
You must ensure that the output is:

byebyebyebye....

*/

import java.util.concurrent.Semaphore;



Thread.start { // P

    while (true) {

	print("b");

    }
}

Thread.start { // Q

    while (true) {

	print("y");

    }
}

Thread.start { // R

    while (true) {

	print("e");

    }
}
