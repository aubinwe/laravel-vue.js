# Requêtes Grafana - Gestion Notes

## Panel 1: Utilisateurs Total (Stat)
```
Query: app_users_total
Unit: short
Color: Blue
```

## Panel 2: Requêtes/sec (Graph)
```
Query A: rate(http_requests_total{status="200"}[5m])
Query B: rate(http_requests_total{status=~"4.."}[5m])
Query C: rate(http_requests_total{status=~"5.."}[5m])
Legend: {{status}} requests
```

## Panel 3: Temps de réponse (Graph)
```
Query: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
Unit: seconds
Legend: 95th percentile
```

## Panel 4: Connexions MySQL (Gauge)
```
Query: mysql_connections_active
Min: 0
Max: 100
Thresholds: 
  - Green: 0-30
  - Yellow: 30-70  
  - Red: 70-100
```

## Panel 5: Taux d'erreur (Stat)
```
Query: (rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])) * 100
Unit: percent
Thresholds:
  - Green: 0-1%
  - Yellow: 1-5%
  - Red: >5%
```

## Panel 6: Activité Business (Graph)
```
Query A: increase(app_grades_total[1h])
Query B: increase(app_claims_total[1h])
Legend A: Nouvelles notes/h
Legend B: Nouvelles réclamations/h
```

## Panel 7: Top Requêtes (Table)
```
Query: topk(10, rate(http_requests_total[5m]) by (method, endpoint))
Format: Table
Columns: Method, Endpoint, Requests/sec
```

## Variables Dashboard
```
$interval = 5m,10m,30m,1h
$status = 200,400,404,500
```

## Alertes
```
Alert 1: mysql_connections_active > 80
Alert 2: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
Alert 3: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
```