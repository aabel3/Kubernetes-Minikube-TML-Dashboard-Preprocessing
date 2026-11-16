# 🧮 Preprocess Types

The TML solution reads the IoT data stream from Apache Kafka and applies **preprocessing** to each sliding time window before the results are used for machine learning and the dashboard. The types applied are set in one line of `iotsolution-scripts-data/preprocess-iot-monitor-customdata.py`:

```python
preprocesslogic='MIN,MAX,COUNT,VARIANCE,OUTLIERS,ANOMPROB'
```

| Type | What it calculates |
|------|--------------------|
| `MIN` | The smallest value in the time window |
| `MAX` | The largest value in the time window |
| `COUNT` | The number of data points in the window |
| `VARIANCE` | How far the values are spread around their average |
| `OUTLIERS` | Values that sit far away from most of the data, which can point to a fault |
| `ANOMPROB` | The probability that a value is an anomaly |

## Why Preprocessing Matters

Raw device data is noisy, incomplete and arrives continuously. Preprocessing turns each window of readings into a few meaningful numbers, such as the range (`MIN`, `MAX`), the volume (`COUNT`), the spread (`VARIANCE`) and signs of trouble (`OUTLIERS`, `ANOMPROB`). Machine learning models then train on cleaner, more structured inputs, which improves the accuracy of the failure predictions shown on the dashboard. It also reduces the amount of data each model has to handle, so results appear in real time.

## Where It Shows Up

The dashboard table has a **Process Type** column next to each row's value, total messages and Kafka key. Each row is the result of one preprocess type applied to one stream (for example `Voltage`, `Power`, `Current` or `EnergyUsed`).
