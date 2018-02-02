import math

def t_stat_gini(x1, x2, s1, s2, n):
    '''
    (float, float, float, float, int) => float
    Computes the t-statistic for two datasets.
    '''
    t = (x1 - x2) / math.sqrt((s1**2 +s2**2)/n)
    return t
