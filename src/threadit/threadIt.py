import threading
import Queue

class WorkerFactory:
    def produce(self):
        raise Exception("WorkerFactory must override produce to create Workers")
    
class Worker:
    def consume(self, item):
        raise Exception("Worker must override consume to receive workItems")
    
class WorkerThread(threading.Thread):
    def __init__(self, queue, worker):
        threading.Thread.__init__(self)
        self.queue = queue
        self.worker = worker
        
    def run(self):
        while 1:
            try: 
                item = self.queue.get_nowait()
            except Queue.Empty: 
                break
                
            self.worker.consume(item)
            
            self.queue.task_done()   
    
def threadThis(numberOfThreads, workList, workerFactory):
    assert(isinstance(workList, list))
    assert(isinstance(workerFactory, WorkerFactory))
    
    queue = Queue.Queue(len(workList))
        
    for item in workList:
        queue.put(item)
    
    i = 0
    while i < numberOfThreads:
        i = i + 1
            
        t = WorkerThread(queue, workerFactory.produce())
        t.setDaemon(True)
        t.start()
            
    queue.join()

