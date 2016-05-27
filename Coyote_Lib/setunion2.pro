FUNCTION setunion2, a, b

superset = [a, b]
union    = superset[UNIQ(superset,SORT(superset))]

RETURN, union
END
