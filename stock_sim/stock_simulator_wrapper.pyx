# distutils: language = c++
# distutils: sources = stock_simulator.cpp

from libcpp.vector cimport vector
cdef extern from "stock_simulator.h":
    cdef cppclass StockSimulator:
        StockSimulator(vector[double]& initial_prices,
                      vector[double]& means,
                      vector[double]& speeds,
                      vector[double]& volatilities) except +
        void get_next_prices(vector[double]& next_prices)

cdef class PyStockSimulator:
    cdef StockSimulator* thisptr

    def __cinit__(self, initial_prices: list, means: list, speeds: list, volatilities: list):
        cdef vector[double] ip = initial_prices
        cdef vector[double] m = means
        cdef vector[double] s = speeds
        cdef vector[double] v = volatilities
        self.thisptr = new StockSimulator(ip, m, s, v)

    def __dealloc__(self):
        del self.thisptr

    def get_next_prices(self):
        cdef vector[double] next_prices
        self.thisptr.get_next_prices(next_prices)
        return [x for x in next_prices]