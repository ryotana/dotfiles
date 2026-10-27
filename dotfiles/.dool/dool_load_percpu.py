### Load average normalized by the number of online CPUs

class dool_plugin(dool):
    """
    Load average divided by the number of online CPUs.
    1.0 means the run queue roughly matches the CPU count.
    """
    def __init__(self):
        self.name  = 'load/cpu'
        self.nick  = ('1m', '5m', '15m')
        self.vars  = ('load1', 'load5', 'load15')
        self.type  = 'f'
        self.width = 4
        self.scale = 0.5
        self.ncpu  = max(getcpunr(), 1)
        self.open('/proc/loadavg')

    def extract(self):
        for l in self.splitlines():
            if len(l) < 3: continue
            self.val['load1']  = float(l[0]) / self.ncpu
            self.val['load5']  = float(l[1]) / self.ncpu
            self.val['load15'] = float(l[2]) / self.ncpu
