FROM python:3.12-slim
WORKDIR /app
RUN pip install boto3 --no-cache-dir
COPY notify_slack.py .
CMD ["python", "notify_slack.py"]
